import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/features/auth/presentation/widgets/auth_guard.dart';
import 'package:unp_calendario/features/language/presentation/providers/language_providers.dart';
import 'package:unp_calendario/features/offline/presentation/providers/realtime_sync_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/providers/fcm_providers.dart';
import 'package:unp_calendario/shared/services/fcm_service.dart';
import 'package:unp_calendario/pages/pg_dashboard_page.dart';
import 'package:unp_calendario/pages/pg_plans_list_page.dart';
import 'package:unp_calendario/shared/utils/platform_utils.dart';
import 'package:unp_calendario/features/help/presentation/pages/help_manual_page.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {

  @override
  void initState() {
    super.initState();
    // Cargar idioma guardado al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageNotifier = ref.read(languageNotifierProvider);
      languageNotifier.loadSavedLanguage();
      
      // Verificar si hay una notificación que abrió la app
      FCMService.getInitialMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(currentLanguageSyncProvider);
    
    // Inicializar servicios de sincronización en tiempo real (solo observa, no usa el valor)
    ref.watch(realtimeSyncInitializerProvider);
    
    // Inicializar FCM cuando el usuario se autentica (solo observa, no usa el valor)
    ref.watch(fcmInitializerProvider);
    
    return MaterialApp(
      title: 'UNP Calendario',
      theme: AppTheme.lightTheme,
      locale: currentLanguage,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Español
        Locale('en'), // Inglés
      ],
      // Rutas (T104)
      // En iOS/móviles o web móvil, mostrar lista de planes. En web desktop, mostrar Dashboard completo
      // No usar 'home:' cuando hay rutas dinámicas, usar onGenerateRoute para todas las rutas
      onGenerateRoute: (settings) {
        // Ruta pública para manual rápido durante fase de pruebas.
        if (settings.name == '/help') {
          return MaterialPageRoute(
            builder: (context) => const HelpManualPage(),
            settings: settings,
          );
        }

        // Ruta por defecto (requiere autenticación).
        // Invitaciones: solo por email (notificación) o directa a usuario registrado; no hay página por token.
        return MaterialPageRoute(
          builder: (context) => AuthGuard(
            child: Builder(
              builder: (context) {
                final showMobileUI = PlatformUtils.shouldShowMobileUI(context);
                return showMobileUI
                    ? const PlansListPage()
                    : const DashboardPage();
              },
            ),
          ),
          settings: settings,
        );
      },
      // Ruta inicial: si no hay ruta específica, usar la ruta por defecto
      initialRoute: '/',
    );
  }
} 