import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'logger_service.dart' show LoggerService;

/// Servicio para gestionar Firebase Cloud Messaging (FCM)
/// 
/// Responsabilidades:
/// - Obtener y registrar tokens FCM
/// - Guardar tokens en Firestore
/// - Manejar notificaciones recibidas
/// - Actualizar tokens cuando cambian
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static String? _currentToken;
  static String? _currentUserId;
  static bool _isInitialized = false;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _onMessageSubscription;
  static StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;
  static Future<void> Function(RemoteMessage message)? _notificationTapHandler;
  static String? _lastForegroundDedupKey;
  static DateTime? _lastForegroundDedupAt;
  /// UI opcional cuando llega un push en primer plano (SnackBar, etc.).
  static void Function(RemoteMessage message)? onForegroundMessage;

  static String _shortToken(String? token) {
    if (token == null || token.isEmpty) return 'null';
    if (token.length <= 12) return token;
    return '${token.substring(0, 8)}...${token.substring(token.length - 4)}';
  }

  /// Una sola suscripción a [FirebaseMessaging.onMessage] durante toda la vida del proceso.
  /// En iOS conviene registrarla pronto (desde [main]); no cancelarla en [cleanup].
  static void attachForegroundMessageListener() {
    if (kIsWeb) return;
    if (_onMessageSubscription != null) {
      LoggerService.info(
        'attachForegroundMessageListener(skip) onMessage ya activo',
        context: 'FCM_SERVICE',
      );
      return;
    }
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(_emitForegroundFromPlugin);
    LoggerService.info('attachForegroundMessageListener()', context: 'FCM_SERVICE');
  }

  static void _emitForegroundFromPlugin(RemoteMessage message) {
    _emitForegroundUi(message, source: 'plugin');
  }

  static void _emitForegroundUi(RemoteMessage message, {required String source}) {
    final dedupKey =
        '${message.messageId ?? ""}|${message.notification?.title}|${message.notification?.body}';
    final now = DateTime.now();
    if (_lastForegroundDedupKey == dedupKey &&
        _lastForegroundDedupAt != null &&
        now.difference(_lastForegroundDedupAt!) < const Duration(seconds: 2)) {
      debugPrint('FCM foreground ui dedup skip source=$source key=$dedupKey');
      return;
    }
    _lastForegroundDedupKey = dedupKey;
    _lastForegroundDedupAt = now;

    debugPrint(
      'FCM foreground ui source=$source messageId=${message.messageId} '
      'notification=${message.notification?.title} data=${message.data}',
    );
    LoggerService.info(
      'Notificación recibida en primer plano: ${message.notification?.title}',
      context: 'FCM_SERVICE',
    );
    final ui = onForegroundMessage;
    if (ui != null) {
      try {
        ui(message);
      } catch (e, st) {
        LoggerService.error(
          'Error en onForegroundMessage',
          context: 'FCM_SERVICE',
          error: e,
          stackTrace: st,
        );
      }
    }
  }
  
  /// Inicializa FCM y solicita permisos
  /// 
  /// [userId] - ID del usuario autenticado
  /// Retorna true si la inicialización fue exitosa
  static Future<bool> initialize(String userId) async {
    try {
      LoggerService.info(
        'initialize(start) userId=$userId initialized=$_isInitialized currentUser=$_currentUserId',
        context: 'FCM_SERVICE',
      );
      if (_isInitialized && _currentUserId == userId) {
        LoggerService.info(
          'initialize(skip) ya inicializado para este usuario',
          context: 'FCM_SERVICE',
        );
        return true;
      }
      _currentUserId = userId;
      
      // FCM no está disponible en web
      if (kIsWeb) {
        LoggerService.info('FCM no está disponible en web', context: 'FCM_SERVICE');
        return false;
      }
      
      // Solicitar permisos (iOS)
      if (Platform.isIOS) {
        LoggerService.info('iOS requestPermission(start)', context: 'FCM_SERVICE');
        final settings = await _messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        
        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          LoggerService.warning(
            'Permisos de notificaciones denegados',
            context: 'FCM_SERVICE',
          );
          return false;
        }
        LoggerService.info(
          'iOS requestPermission(done) status=${settings.authorizationStatus.name}',
          context: 'FCM_SERVICE',
        );

        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // iOS: APNs puede tardar unos segundos tras conceder permisos.
        // Esperamos un poco para evitar errores "apns-token-not-set" al pedir el token FCM.
        await _waitForApnsToken();
      }
      
      // Obtener token inicial
      LoggerService.info('getToken(initial) start', context: 'FCM_SERVICE');
      await _getAndSaveToken();
      
      // Escuchar cambios en el token
      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) {
        LoggerService.info('Token FCM actualizado', context: 'FCM_SERVICE');
        _currentToken = newToken;
        _saveTokenToFirestore(newToken);
      });
      
      // Configurar handlers de notificaciones
      _setupNotificationHandlers();
      _isInitialized = true;
      
      LoggerService.info('FCM inicializado correctamente', context: 'FCM_SERVICE');
      return true;
    } catch (e) {
      LoggerService.error(
        'Error inicializando FCM',
        context: 'FCM_SERVICE',
        error: e,
      );
      return false;
    }
  }
  
  /// Obtiene el token FCM actual y lo guarda en Firestore
  static Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        LoggerService.info(
          'getToken(success) token=${_shortToken(token)}',
          context: 'FCM_SERVICE',
        );
        _currentToken = token;
        await _saveTokenToFirestore(token);
        LoggerService.info('Token FCM obtenido y guardado', context: 'FCM_SERVICE');
      } else {
        LoggerService.warning('getToken(null)', context: 'FCM_SERVICE');
      }
    } catch (e) {
      // iOS: si APNs aún no está listo, reintentar durante una ventana corta.
      if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
        LoggerService.warning(
          'getToken(apns-token-not-set) reintentos iniciados',
          context: 'FCM_SERVICE',
        );
        for (int i = 0; i < 10; i++) {
          await Future<void>.delayed(const Duration(seconds: 2));
          try {
            final retryToken = await _messaging.getToken();
            if (retryToken != null) {
              LoggerService.info(
                'getToken(retry#$i success) token=${_shortToken(retryToken)}',
                context: 'FCM_SERVICE',
              );
              _currentToken = retryToken;
              await _saveTokenToFirestore(retryToken);
              LoggerService.info(
                'Token FCM obtenido y guardado tras espera APNs',
                context: 'FCM_SERVICE',
              );
              return;
            }
            LoggerService.warning(
              'getToken(retry#$i null)',
              context: 'FCM_SERVICE',
            );
          } catch (retryError) {
            LoggerService.warning(
              'getToken(retry#$i error): $retryError',
              context: 'FCM_SERVICE',
            );
          }
        }
      }
      LoggerService.error(
        'Error obteniendo token FCM',
        context: 'FCM_SERVICE',
        error: e,
      );
    }
  }

  /// iOS: espera breve a que el token APNs esté disponible.
  static Future<void> _waitForApnsToken() async {
    for (int i = 0; i < 5; i++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        LoggerService.info(
          'getAPNSToken(success retry#$i) token=${_shortToken(apnsToken)}',
          context: 'FCM_SERVICE',
        );
        return;
      }
      LoggerService.warning('getAPNSToken(empty retry#$i)', context: 'FCM_SERVICE');
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    LoggerService.warning(
      'getAPNSToken(timeout) tras 5 intentos',
      context: 'FCM_SERVICE',
    );
  }
  
  /// Guarda el token FCM en Firestore
  /// 
  /// Estructura: users/{userId}/fcmTokens/{tokenId}
  /// Cada token tiene: token, deviceInfo, createdAt, updatedAt
  static Future<void> _saveTokenToFirestore(String token) async {
    if (_currentUserId == null) {
      LoggerService.warning(
        'No se puede guardar token: userId no está disponible',
        context: 'FCM_SERVICE',
      );
      return;
    }
    
    try {
      // Usar el token como ID del documento (único por dispositivo)
      final tokenRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('fcmTokens')
          .doc(token);
      
      final now = Timestamp.now();
      final snapshot = await tokenRef.get();

      if (!snapshot.exists) {
        final deviceInfo = _getDeviceInfo();
        await tokenRef.set({
          'token': token,
          'deviceInfo': deviceInfo,
          'createdAt': now,
          'updatedAt': now,
        });
      } else {
        // Mantener token/deviceInfo/createdAt intactos para cumplir reglas.
        await tokenRef.set({
          'updatedAt': now,
        }, SetOptions(merge: true));
      }
      
      LoggerService.database(
        'Token FCM guardado en Firestore: users/$_currentUserId/fcmTokens/${_shortToken(token)}',
        operation: 'SAVE',
      );
    } catch (e) {
      LoggerService.error(
        'Error guardando token FCM en Firestore',
        context: 'FCM_SERVICE',
        error: e,
      );
    }
  }
  
  /// Obtiene información del dispositivo
  static Map<String, dynamic> _getDeviceInfo() {
    return {
      'platform': Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'unknown'),
      'osVersion': Platform.operatingSystemVersion,
    };
  }
  
  /// Configura los handlers para notificaciones
  static void _setupNotificationHandlers() {
    LoggerService.info('setupNotificationHandlers()', context: 'FCM_SERVICE');
    // Foreground: [attachForegroundMessageListener] se llama desde main (una vez).
    _onMessageOpenedSubscription?.cancel();
    // Notificación recibida cuando la app está en segundo plano y el usuario la toca
    _onMessageOpenedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      LoggerService.info(
        'Notificación abierta desde segundo plano: ${message.notification?.title}',
        context: 'FCM_SERVICE',
      );
      final handler = _notificationTapHandler;
      if (handler != null) {
        handler(message);
      }
    });
  }
  
  /// Obtiene el token FCM actual
  static String? get currentToken => _currentToken;
  
  /// Limpia el token cuando el usuario cierra sesión
  static Future<void> cleanup() async {
    LoggerService.info(
      'cleanup() user=$_currentUserId token=${_shortToken(_currentToken)}',
      context: 'FCM_SERVICE',
    );
    await _tokenRefreshSubscription?.cancel();
    await _onMessageOpenedSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _onMessageOpenedSubscription = null;
    onForegroundMessage = null;

    if (_currentToken != null && _currentUserId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection('fcmTokens')
            .doc(_currentToken)
            .delete();
        
        LoggerService.database(
          'Token FCM eliminado de Firestore: users/$_currentUserId/fcmTokens',
          operation: 'DELETE',
        );
      } catch (e) {
        LoggerService.error(
          'Error eliminando token FCM',
          context: 'FCM_SERVICE',
          error: e,
        );
      }
    }
    
    _currentToken = null;
    _currentUserId = null;
    _isInitialized = false;
  }
  
  /// Obtiene el handler para notificaciones cuando la app se abre desde terminada
  /// Este método debe ser llamado desde main.dart
  static Future<void> getInitialMessage() async {
    if (kIsWeb) return;
    
    LoggerService.info('getInitialMessage(check)', context: 'FCM_SERVICE');
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      LoggerService.info(
        'Notificación abierta desde estado terminado: ${message.notification?.title}',
        context: 'FCM_SERVICE',
      );
      final handler = _notificationTapHandler;
      if (handler != null) {
        await handler(message);
      }
    }
  }

  /// Registra un callback para manejar taps en notificaciones push.
  static void setNotificationTapHandler(
    Future<void> Function(RemoteMessage message)? handler,
  ) {
    _notificationTapHandler = handler;
    LoggerService.info(
      'setNotificationTapHandler(registered=${handler != null})',
      context: 'FCM_SERVICE',
    );
  }

  /// Registra feedback en UI cuando la app está en primer plano (p. ej. SnackBar).
  static void setForegroundMessageHandler(void Function(RemoteMessage message)? handler) {
    onForegroundMessage = handler;
    LoggerService.info(
      'setForegroundMessageHandler(registered=${handler != null})',
      context: 'FCM_SERVICE',
    );
  }
}
