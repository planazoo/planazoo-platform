import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  
  /// Inicializa FCM y solicita permisos
  /// 
  /// [userId] - ID del usuario autenticado
  /// Retorna true si la inicialización fue exitosa
  static Future<bool> initialize(String userId) async {
    try {
      if (_isInitialized && _currentUserId == userId) {
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

        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      
      // Obtener token inicial
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
        _currentToken = token;
        await _saveTokenToFirestore(token);
        LoggerService.info('Token FCM obtenido y guardado', context: 'FCM_SERVICE');
      }
    } catch (e) {
      LoggerService.error(
        'Error obteniendo token FCM',
        context: 'FCM_SERVICE',
        error: e,
      );
    }
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
      final deviceInfo = _getDeviceInfo();
      
      await tokenRef.set({
        'token': token,
        'deviceInfo': deviceInfo,
        'createdAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
      
      LoggerService.database(
        'Token FCM guardado en Firestore: users/$_currentUserId/fcmTokens',
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
    _onMessageSubscription?.cancel();
    // Notificación recibida cuando la app está en primer plano
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LoggerService.info(
        'Notificación recibida en primer plano: ${message.notification?.title}',
        context: 'FCM_SERVICE',
      );
      // TODO: Mostrar notificación local o actualizar UI
    });
    
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
    await _tokenRefreshSubscription?.cancel();
    await _onMessageSubscription?.cancel();
    await _onMessageOpenedSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _onMessageSubscription = null;
    _onMessageOpenedSubscription = null;

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
  }
}
