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
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/pages/pg_plan_detail_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  final PlanService _planService = PlanService();
  static const Set<String> _allowedPlanTabs = {
    'planData',
    'planNotes',
    'mySummary',
    'calendar',
    'participants',
    'chat',
    'planNotifications',
    'stats',
    'payments',
  };

  String? _normalizeInitialTab(String? rawTab) {
    if (rawTab == null) return null;
    final tab = rawTab.trim();
    if (tab.isEmpty) return null;
    return _allowedPlanTabs.contains(tab) ? tab : null;
  }

  String? _inferInitialTabFromPayload(Map<String, dynamic> data) {
    final rawType = (data['type'] ?? data['notificationType'] ?? data['category'])
        ?.toString()
        .trim()
        .toLowerCase();
    switch (rawType) {
      case 'chat':
      case 'message':
      case 'new_message':
        return 'chat';
      case 'announcement':
      case 'plan_notification':
      case 'event_change':
      case 'event_proposed':
      case 'invitation':
      case 'invitation_accepted':
      case 'invitation_rejected':
        return 'planNotifications';
      case 'payment':
      case 'expense':
      case 'balance':
        return 'payments';
      default:
        return null;
    }
  }

  Future<void> _handlePushTap(RemoteMessage message) async {
    final data = message.data;
    final rawPlanId = data['planId'] ?? data['plan_id'];
    if (rawPlanId == null || rawPlanId.toString().trim().isEmpty) {
      return;
    }
    final planId = rawPlanId.toString();
    final plan = await _planService.getPlanById(planId);
    if (!mounted || plan == null) return;

    final rawTab = data['tab'] ?? data['initialTab'];
    final initialTab = _normalizeInitialTab(rawTab?.toString()) ??
        _inferInitialTabFromPayload(data);
    final nav = _rootNavigatorKey.currentState;
    if (nav == null) return;

    nav.push(
      MaterialPageRoute<void>(
        builder: (context) => PlanDetailPage(
          plan: plan,
          initialTab: initialTab,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Cargar idioma guardado al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageNotifier = ref.read(languageNotifierProvider);
      languageNotifier.loadSavedLanguage();

      // Registrar navegación desde push (A1 / ítem 109).
      FCMService.setNotificationTapHandler(_handlePushTap);
      
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
      navigatorKey: _rootNavigatorKey,
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