import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'features/calendar/domain/services/timezone_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  
  // Inicializar base de datos de timezones
  TimezoneService.initialize();
  
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
