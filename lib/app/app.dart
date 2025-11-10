import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/features/auth/presentation/widgets/auth_guard.dart';
import 'package:unp_calendario/features/language/presentation/providers/language_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/pages/pg_dashboard_page.dart';
import 'package:unp_calendario/pages/pg_invitation_page.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(currentLanguageSyncProvider);
    
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
      home: const AuthGuard(
        child: DashboardPage(),
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
          builder: (context) => const AuthGuard(
            child: DashboardPage(),
          ),
        );
      },
    );
  }
} 