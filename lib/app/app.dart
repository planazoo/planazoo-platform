import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/features/auth/presentation/widgets/auth_guard.dart';
import 'package:unp_calendario/features/language/presentation/providers/language_providers.dart';
import 'package:unp_calendario/features/offline/presentation/providers/realtime_sync_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/pages/pg_dashboard_page.dart';
import 'package:unp_calendario/pages/pg_invitation_page.dart';
import 'package:unp_calendario/pages/pg_plans_list_page.dart';
import 'dart:io' show Platform;

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  // Detectar si estamos en una plataforma móvil (iOS o Android)
  // En web, kIsWeb será true, así que _isMobilePlatform será false
  bool get _isMobilePlatform {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  @override
  void initState() {
    super.initState();
    // Cargar idioma guardado al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageNotifier = ref.read(languageNotifierProvider);
      languageNotifier.loadSavedLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(currentLanguageSyncProvider);
    
    // Inicializar servicios de sincronización en tiempo real (solo observa, no usa el valor)
    ref.watch(realtimeSyncInitializerProvider);
    
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
      // En iOS/móviles, mostrar lista simple de planes. En web/desktop, mostrar Dashboard completo
      home: AuthGuard(
        child: _isMobilePlatform
            ? const PlansListPage()
            : const DashboardPage(),
      ),
      onGenerateRoute: (settings) {
        // Manejar URLs como /invitation/{token} (T104)
        if (settings.name?.startsWith('/invitation/') ?? false) {
          final token = settings.name!.split('/invitation/').last;
          if (token.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => InvitationPage(token: token),
              settings: settings,
            );
          }
        }
        // Ruta por defecto
        return MaterialPageRoute(
          builder: (context) => AuthGuard(
            child: _isMobilePlatform
                ? const PlansListPage()
                : const DashboardPage(),
          ),
        );
      },
    );
  }
} 