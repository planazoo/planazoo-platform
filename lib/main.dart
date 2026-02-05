import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'features/calendar/domain/services/timezone_service.dart';
import 'features/offline/domain/services/hive_service.dart';

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
  
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
