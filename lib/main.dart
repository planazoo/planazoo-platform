import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'features/calendar/domain/services/timezone_service.dart';
import 'features/offline/domain/services/hive_service.dart';
import 'shared/services/fcm_service.dart';

/// Handler de mensajes push en background (FCM).
/// Debe ser top-level para que Flutter/Firebase lo pueda invocar.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } catch (_) {
    // Ignorar duplicate-app y otros casos donde ya está inicializado.
  }
  debugPrint(
    'FCM background message: id=${message.messageId}, data=${message.data}',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar estrategia de URL para web (sin # en las URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  
  // Inicializar Firebase (solo si no está ya inicializado)
  // En iOS, Firebase se inicializa automáticamente si existe GoogleService-Info.plist
  try {
    await Firebase.initializeApp(
      options: firebaseOptions,
    );
  } catch (e) {
    // Si Firebase ya está inicializado (error duplicate-app), usar la instancia existente
    if (e.toString().contains('duplicate-app')) {
      Firebase.app(); // Obtener la instancia existente
    } else {
      rethrow; // Re-lanzar otros errores
    }
  }
  
  // Inicializar base de datos de timezones
  TimezoneService.initialize();
  
  // Inicializar Hive (solo para móviles)
  await HiveService.initialize();

  // Registrar handler de notificaciones en background (A1 / ítem 109).
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    // iOS: registrar foreground lo antes posible (antes de runApp) para no perder el stream.
    FCMService.attachForegroundMessageListener();
  }
  
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
