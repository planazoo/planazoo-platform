import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/testing/demo_data_generator.dart';
import 'package:unp_calendario/features/testing/family_users_generator.dart';
import 'package:unp_calendario/features/testing/mini_frank_simple_generator.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/security/utils/sanitizer.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

import 'package:unp_calendario/widgets/grid/wd_grid_painter.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_data_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_calendar_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_participants_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_admin_insights_screen.dart';
import 'package:unp_calendario/features/stats/presentation/pages/plan_stats_page.dart';
import 'package:unp_calendario/features/payments/presentation/pages/payment_summary_page.dart';
import 'package:unp_calendario/widgets/plan/plan_list_widget.dart';
import 'package:unp_calendario/widgets/plan/plan_calendar_view.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_search_widget.dart';
import 'package:unp_calendario/pages/pg_profile_page.dart';
import 'package:unp_calendario/pages/pg_ui_showcase_page.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/invitation_service.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_invitation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_chat_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_pending_email_events_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_unified_notifications_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_notifications_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_summary_screen.dart';
import 'package:unp_calendario/widgets/dashboard/wd_timezone_banner.dart';
import 'package:unp_calendario/widgets/dashboard/wd_dashboard_nav_tabs.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
import 'package:unp_calendario/widgets/dashboard/wd_dashboard_sidebar.dart';
import 'package:unp_calendario/widgets/dashboard/wd_dashboard_header_bar.dart';
import 'package:unp_calendario/widgets/dashboard/wd_dashboard_filters.dart';
import 'package:unp_calendario/widgets/dashboard/wd_dashboard_header_placeholders.dart';
import 'package:unp_calendario/widgets/dialogs/wd_create_plan_modal.dart';
import 'package:unp_calendario/widgets/notifications/wd_notification_list_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  // Estado para el planazoo seleccionado
  String? selectedPlanId;
  Plan? selectedPlan;
  List<Plan> planazoos = [];
  List<Plan> filteredPlanazoos = [];
  bool isLoading = true;
  bool _isCalendarView = false;
  // ignore: unused_field
  final PlanParticipationService _planParticipationService = PlanParticipationService();
  
  // NUEVO: Estado de navegación para W31
  String currentScreen = 'calendar'; // 'calendar', 'planData', 'participants', 'profile', etc.
  String _previousScreen = 'calendar';
  
  // NUEVO: Estado para trackear qué widget de W14-W25 está seleccionado
  String? selectedWidgetId; // 'W14', 'W15', 'W16', etc.
  String selectedFilter = 'todos'; // 'todos', 'estoy_in', 'pendientes', 'cerrados'
  /// En pestaña Calendario: 'calendar' = cuadrícula, 'summary' = resumen del plan (solo en W31).
  String _calendarPanelView = 'calendar';

  // Flag para evitar procesar transiciones múltiples veces en la misma carga
  List<String> _processedPlanIds = [];
  final PlanParticipationService _participationService = PlanParticipationService();
  final Map<String, List<String>> _planParticipantNames = {};
  final Map<String, StreamSubscription<List<PlanParticipation>>> _participantSubscriptions = {};
  final Map<String, String> _userNameCache = {};
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final subscription in _participantSubscriptions.values) {
      subscription.cancel();
    }
    _participantSubscriptions.clear();
    _planParticipantNames.clear();
    _userNameCache.clear();
    super.dispose();
  }

  // Método helper para procesar cambios en la lista de planes
  void _processPlansUpdate(List<Plan> plans, {bool forceUpdate = false}) {
    if (!mounted) return;
    
    // Comparar si la lista realmente cambió (comparación por referencia e IDs)
    final plansChanged = forceUpdate || !_listsEqual(planazoos, plans);
    
    // SIEMPRE actualizar isLoading a false, incluso si la lista no cambió
    // Esto asegura que la pantalla "Aún no tienes planes" se muestre correctamente
    final shouldUpdate = plansChanged || isLoading;
    
    if (!shouldUpdate) return; // No hacer nada si no cambió y ya no está cargando
    
    _syncParticipantListeners(plans);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      setState(() {
        planazoos = plans;
        filteredPlanazoos = List.from(plans);
        isLoading = false;
        
        // Seleccionar automáticamente el primer plan si no hay ninguno seleccionado
        if (selectedPlan == null && plans.isNotEmpty) {
          selectedPlanId = plans.first.id;
          selectedPlan = plans.first;
          selectedWidgetId ??= 'W15';
          currentScreen = 'calendar';
        }
        
        // Si el plan seleccionado fue actualizado, actualizar la referencia
        if (selectedPlanId != null) {
          try {
            final updatedPlan = plans.firstWhere(
              (p) => p.id == selectedPlanId,
              orElse: () => selectedPlan!,
            );
            selectedPlan = updatedPlan;
          } catch (e) {
            // Si el plan seleccionado ya no existe, limpiar la selección
            if (plans.isEmpty || !plans.any((p) => p.id == selectedPlanId)) {
              selectedPlanId = null;
              selectedPlan = null;
            }
          }
        }
      });
      
      // Procesar transiciones automáticas solo si la lista cambió
      Future.microtask(() async {
        final stateService = PlanStateService();
        for (final plan in plans) {
          if (plan.id != null && mounted && !_processedPlanIds.contains(plan.id!)) {
            _processedPlanIds.add(plan.id!);
            // Ejecutar en background, no bloquear UI
            stateService.checkAndExecuteAutomaticTransitions(planId: plan.id!).catchError((e) {
              LoggerService.error('Error checking automatic transitions for plan ${plan.id}',
                  context: 'DASHBOARD', error: e);
            });
          }
        }
        // Limpiar IDs procesados después de un tiempo
        if (_processedPlanIds.length > plans.length * 2) {
          _processedPlanIds.removeWhere((id) => !plans.any((p) => p.id == id));
        }
      });
    });
  }
  
  // Helper para comparar si dos listas son iguales
  bool _listsEqual(List<Plan> list1, List<Plan> list2) {
    if (list1.length != list2.length) return false; // Diferentes
    if (identical(list1, list2)) return true; // Misma referencia
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || list1[i].updatedAt != list2[i].updatedAt) {
        return false; // Diferentes
      }
    }
    return true; // Iguales
  }

  void _syncParticipantListeners(List<Plan> plans) {
    final activeIds = plans
        .where((plan) => plan.id != null)
        .map((plan) => plan.id!)
        .toSet();

    for (final planId in activeIds) {
      if (_participantSubscriptions.containsKey(planId)) continue;

      final subscription = _participationService.getPlanParticipations(planId).listen(
        (participations) async {
          final activeParticipants = participations
              .where((participant) => participant.isActive && !participant.isObserver)
              .toList();

          final names = <String>[];
          for (final participant in activeParticipants) {
            final resolvedName = await _resolveParticipantName(participant.userId);
            if (!names.contains(resolvedName)) {
              names.add(resolvedName);
            }
          }

          if (!mounted) return;
          final previous = _planParticipantNames[planId];
          if (previous != null && _listEquals(previous, names)) {
            return;
          }

          setState(() {
            _planParticipantNames[planId] = names;
          });
        },
        onError: (error, stackTrace) {
          LoggerService.error(
            'Error loading participants for plan $planId',
            context: 'DASHBOARD_PARTICIPANTS',
            error: error,
          );
        },
      );

      _participantSubscriptions[planId] = subscription;
    }

    final toRemove = _participantSubscriptions.keys
        .where((id) => !activeIds.contains(id))
        .toList();

    for (final planId in toRemove) {
      _participantSubscriptions[planId]?.cancel();
      _participantSubscriptions.remove(planId);
      _planParticipantNames.remove(planId);
    }
  }

  Future<String> _resolveParticipantName(String userId) async {
    final cached = _userNameCache[userId];
    if (cached != null) return cached;

    try {
      final userService = ref.read(userServiceProvider);
      final user = await userService.getUser(userId);

      String resolved;
      if (user == null) {
        resolved = userId;
      } else if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        resolved = user.displayName!.trim();
      } else if (user.username != null && user.username!.trim().isNotEmpty) {
        resolved = '@${user.username!.trim()}';
      } else if (user.email != null && user.email!.trim().isNotEmpty) {
        resolved = user.email!.trim();
      } else {
        resolved = userId;
      }

      _userNameCache[userId] = resolved;
      return resolved;
    } catch (_) {
      _userNameCache[userId] = userId;
      return userId;
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _showCreatePlanDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WdCreatePlanModal(
          onPlanCreated: (plan) {
            if (plan.id != null && mounted) {
              setState(() {
                selectedPlanId = plan.id;
                selectedPlan = plan;
                currentScreen = 'planData';
              });
            }
          },
        );
      },
    );
  }

  void _filterPlanazoos(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPlanazoos = List.from(planazoos);
      } else {
        final searchQuery = query.toLowerCase();
        filteredPlanazoos = planazoos.where((planazoo) {
          final nameMatch = planazoo.name.toLowerCase().contains(searchQuery);
          final stateMatch = (planazoo.state ?? '').toLowerCase().contains(searchQuery);
          final startMatch = DateFormatter.formatDate(planazoo.startDate).toLowerCase().contains(searchQuery);
          final endMatch = DateFormatter.formatDate(planazoo.endDate).toLowerCase().contains(searchQuery);
          final participantNames = _planParticipantNames[planazoo.id] ?? const <String>[];
          final participantsMatch = participantNames.any((name) => name.toLowerCase().contains(searchQuery));
          final participantsCountMatch = (planazoo.participants?.toString() ?? '').contains(searchQuery);

          return nameMatch ||
              stateMatch ||
              startMatch ||
              endMatch ||
              participantsMatch ||
              participantsCountMatch;
        }).toList();
      }
    });
  }



  // NUEVO: Método para cambiar la pantalla mostrada en W31
  void _changeScreen(String screen) {
    setState(() {
      if (screen == 'profile') {
        if (currentScreen != 'profile') {
          _previousScreen = currentScreen;
        }
      } else {
        _previousScreen = screen;
      }
      currentScreen = screen;
      if (screen == 'calendar') _calendarPanelView = 'calendar';
    });
  }
  
  void _closeProfileScreen() {
    setState(() {
      final target = _previousScreen == 'profile' ? 'calendar' : _previousScreen;
      currentScreen = target;
    });
  }
  
  // NUEVO: Método para seleccionar widgets de W14-W25
  void _selectWidget(String widgetId) {
    setState(() {
      selectedWidgetId = widgetId;
    });
  }

  List<DashboardNavTabItem> _dashboardTabItemsWithBadge(BuildContext context) {
    final baseTabs = WdDashboardNavTabs.tabItems(context);
    final planUnread = ref.watch(planUnreadCountProvider(selectedPlanId));
    final count = planUnread.valueOrNull ?? 0;
    return baseTabs
        .map((t) => t.id == 'W20' ? t.copyWith(badgeCount: count) : t)
        .toList();
  }

  void _selectPlanazoo(String planId) {
    setState(() {
      selectedPlanId = planId;
      // Buscar el plan completo en la lista
      try {
        selectedPlan = planazoos.firstWhere((p) => p.id == planId);
        
        // Verificar y ejecutar transiciones automáticas al seleccionar plan
        if (selectedPlan?.id != null) {
          final stateService = PlanStateService();
          stateService.checkAndExecuteAutomaticTransitions(planId: selectedPlan!.id!).then((changed) {
            // Si cambió el estado, recargar el plan actualizado
            if (changed && mounted) {
              final planService = ref.read(planServiceProvider);
              planService.getPlanById(selectedPlan!.id!).then((updatedPlan) {
                if (updatedPlan != null && mounted) {
                  setState(() {
                    selectedPlan = updatedPlan;
                    // Actualizar también en la lista
                    final index = planazoos.indexWhere((p) => p.id == planId);
                    if (index != -1) {
                      planazoos[index] = updatedPlan;
                      filteredPlanazoos = List.from(planazoos);
                    }
                  });
                }
              });
            }
          }).catchError((e) {
            LoggerService.error('Error checking automatic transitions for selected plan',
                context: 'DASHBOARD', error: e);
          });
        }
      } catch (e) {
        selectedPlan = null;
      }
      // NUEVO: Activar calendario por defecto al seleccionar plan
      selectedWidgetId = 'W15';
      currentScreen = 'calendar';
      _calendarPanelView = 'calendar';
    });
  }

  void _showSummaryInPanel() {
    setState(() => _calendarPanelView = 'summary');
  }

  Future<void> _deletePlanazoo(String planId) async {
    try {
      // Mostrar confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDeleteTitle),
          content: Text(AppLocalizations.of(context)!.confirmDeleteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // Eliminar de Firebase
        final planService = ref.read(planServiceProvider);
        final success = await planService.deletePlan(planId);
        
        if (success) {
          // Si el plan eliminado estaba seleccionado, limpiar la selección
          if (selectedPlanId == planId) {
            setState(() {
              selectedPlanId = null;
              selectedPlan = null;
            });
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${AppLocalizations.of(context)!.deleteSuccess}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('No se pudo eliminar el plan');
        }
      }
    } catch (e) {
      LoggerService.error('Error deleting planazoo', context: 'MAIN_PAGE', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${AppLocalizations.of(context)!.deleteError}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final authState = ref.watch(authNotifierProvider);
    final timezoneSuggestion = authState.timezoneSuggestion;
    final deviceTimezoneSuggestion = authState.deviceTimezone;
    final configuredTimezone = authState.user?.defaultTimezone;
    
    // Usar plansStreamProvider directamente con Riverpod
    ref.watch(plansStreamProvider);
    
    // Escuchar cambios en el stream y actualizar el estado local
    // ref.listen solo se ejecuta cuando el valor cambia, no en cada build
    ref.listen<AsyncValue<List<Plan>>>(plansStreamProvider, (previous, next) {
      // Procesar cuando hay datos disponibles (incluso si es una lista vacía)
      if (next.hasValue && next.value != null) {
        final plans = next.value!;
        _processPlansUpdate(plans);
      } else if (next.hasValue && next.value == null) {
        // Si el valor es null, tratar como lista vacía
        _processPlansUpdate([]);
      }
      
      // Manejar errores
      if (next.hasError) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
            LoggerService.error('Error loading planazoos', context: 'MAIN_PAGE', error: next.error);
            final messenger = ScaffoldMessenger.maybeOf(context);
            if (messenger != null && mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('❌ ${AppLocalizations.of(context)!.loadError}: ${next.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        }
      }
    });
    
    // También verificar el estado actual del provider para manejar el caso inicial
    final plansAsync = ref.read(plansStreamProvider);
    if (plansAsync.hasValue && plansAsync.value != null) {
      // Si ya hay datos disponibles, procesarlos inmediatamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _processPlansUpdate(plansAsync.value!);
        }
      });
    } else if (plansAsync.hasValue && plansAsync.value == null) {
      // Si el valor es null, tratar como lista vacía
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _processPlansUpdate([]);
        }
      });
    }
    
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800, // Color sólido, sin gradiente
          ),
          child: Stack(
            children: [
              _buildGrid(),
              if (timezoneSuggestion != null && deviceTimezoneSuggestion != null)
                Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: WdTimezoneBanner(
                        configuredTimezone: configuredTimezone,
                        deviceTimezone: deviceTimezoneSuggestion,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: null,
      ),
    );
  }

  /// Genera usuarios invitados para testing
  Future<void> _generateGuestUsers() async {
    // Mostrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 16),
            Text('👥 ${AppLocalizations.of(context)!.generateGuests}'),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    
    // Generar usuarios invitados
    final guestIds = await FamilyUsersGenerator.generateGuestUsers();
    
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${guestIds.length} ${AppLocalizations.of(context)!.guestsGenerated}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  /// Genera el plan Mini-Frank de testing paso a paso
  Future<void> _generateMiniFrankPlan(UserModel? currentUser) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.userNotAuthenticated),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Mostrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 16),
            Text('🧬 ${AppLocalizations.of(context)!.generateMiniFrank}'),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    
    try {
      // Generar plan Mini-Frank
        final plan = await MiniFrankSimpleGenerator.generateMiniFrankPlan(currentUser.id);
      
      if (!mounted) return;
      
      // Invalidar providers del calendario para forzar actualización
      if (plan.id != null) {
        final calendarParams = CalendarNotifierParams(
          planId: plan.id!,
          userId: plan.userId,
          initialDate: plan.startDate,
          initialColumnCount: plan.columnCount,
        );
        ref.invalidate(calendarNotifierProvider(calendarParams));
      }
      
      // No es necesario llamar _loadPlanazoos() - el stream se actualiza automáticamente
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ${AppLocalizations.of(context)!.miniFrankGenerated}'),
            backgroundColor: Colors.blue,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.view,
              textColor: Colors.white,
              onPressed: () {
                // Seleccionar el plan Mini-Frank generado
                setState(() {
                  selectedPlanId = plan.id;
                  selectedPlan = filteredPlanazoos.firstWhere(
                    (p) => p.id == plan.id,
                    orElse: () => filteredPlanazoos.first,
                  );
                  currentScreen = 'calendar';
                  selectedWidgetId = 'W15';
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${AppLocalizations.of(context)!.generateMiniFrankError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// TEMPORAL T152/T153: Inicializar todo lo necesario en Firestore y crear usuarios de prueba
  Future<void> _initializeFirestore() async {
    if (!mounted) return;
    
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(AppLocalizations.of(context)!.dashboardFirestoreInitializing),
          ],
        ),
      ),
    );

    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      
      final results = <String, String>{};
      
      // 1. Inicializar tipos de cambio
      await firestore.collection('exchange_rates').doc('current').set({
        'baseCurrency': 'EUR',
        'rates': {
          'USD': 1.08,
          'GBP': 0.85,
          'JPY': 160.0,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
      results['Exchange Rates'] = '✅ Inicializados';
      
      // 2. Crear usuarios de prueba
      // Guardar usuario actual antes de crear usuarios
      final currentAuthUser = auth.currentUser;
      final currentUserEmail = currentAuthUser?.email;
      
      const testPassword = 'test123456';
      final testUsers = [
        {'email': 'unplanazoo+admin@gmail.com', 'role': 'Organizador', 'displayName': 'Admin Test'},
        {'email': 'unplanazoo+coorg@gmail.com', 'role': 'Coorganizador', 'displayName': 'Coorganizador Test'},
        {'email': 'unplanazoo+part1@gmail.com', 'role': 'Participante 1', 'displayName': 'Participante 1'},
        {'email': 'unplanazoo+part2@gmail.com', 'role': 'Participante 2', 'displayName': 'Participante 2'},
        {'email': 'unplanazoo+part3@gmail.com', 'role': 'Participante 3', 'displayName': 'Participante 3'},
        {'email': 'unplanazoo+obs@gmail.com', 'role': 'Observador', 'displayName': 'Observador Test'},
        {'email': 'unplanazoo+reject@gmail.com', 'role': 'Para rechazar invitaciones', 'displayName': 'Reject Test'},
        {'email': 'unplanazoo+expired@gmail.com', 'role': 'Para invitaciones expiradas', 'displayName': 'Expired Test'},
        {'email': 'unplanazoo+valid@gmail.com', 'role': 'Para validaciones', 'displayName': 'Valid Test'},
      ];
      
      final userService = UserService();
      int createdCount = 0;
      int existingCount = 0;
      int errorCount = 0;
      int firestoreCreatedCount = 0;
      int firestoreExistingCount = 0;
      
      for (final user in testUsers) {
        try {
          // Crear usuario en Firebase Auth
          final userCredential = await auth.createUserWithEmailAndPassword(
            email: user['email']!,
            password: testPassword,
          );
          
          // Actualizar displayName en Firebase Auth si se proporciona
          if (user['displayName'] != null && userCredential.user != null) {
            await userCredential.user!.updateDisplayName(user['displayName']);
            await userCredential.user!.reload();
          }
          
          // Crear usuario en Firestore collection 'users'
          final firebaseUser = userCredential.user!;
          final userModel = UserModel.fromFirebaseAuth(firebaseUser);
          
          // Añadir displayName si se proporcionó
          final userModelWithName = user['displayName'] != null
              ? userModel.copyWith(displayName: user['displayName'])
              : userModel;
          
          try {
            await userService.createUser(userModelWithName);
            firestoreCreatedCount++;
          } catch (firestoreError) {
            // Si el usuario ya existe en Firestore, verificar si es el mismo
            final existingUser = await userService.getUser(firebaseUser.uid);
            if (existingUser != null) {
              firestoreExistingCount++;
            } else {
              // Error al crear en Firestore pero el usuario de Auth se creó
              LoggerService.error('Error creando usuario en Firestore ${user['email']}', error: firestoreError);
            }
          }
          
          // Cerrar sesión inmediatamente para no afectar el usuario actual
          await auth.signOut();
          
          createdCount++;
        } catch (e) {
          // Si el usuario ya existe en Auth, es un error esperado
          if (e.toString().contains('email-already-in-use') || 
              e.toString().contains('already exists')) {
            existingCount++;
            
            // Intentar crear en Firestore si el usuario de Auth ya existe
            try {
              final existingAuthUser = await auth.signInWithEmailAndPassword(
                email: user['email']!,
                password: testPassword,
              );
              
              if (existingAuthUser.user != null) {
                final userModel = UserModel.fromFirebaseAuth(existingAuthUser.user!);
                final userModelWithName = user['displayName'] != null
                    ? userModel.copyWith(displayName: user['displayName'])
                    : userModel;
                
                try {
                  await userService.createUser(userModelWithName);
                  firestoreCreatedCount++;
                } catch (firestoreError) {
                  final existingUser = await userService.getUser(existingAuthUser.user!.uid);
                  if (existingUser != null) {
                    firestoreExistingCount++;
                  }
                }
              }
              
              // Cerrar sesión después de verificar
              await auth.signOut();
            } catch (authError) {
              // Ignorar errores al intentar crear en Firestore para usuarios existentes
            }
          } else {
            errorCount++;
            LoggerService.error('Error creando usuario ${user['email']}', error: e);
          }
        }
      }
      
      // Si había un usuario autenticado antes y no era uno de los usuarios de prueba,
      // intentar restaurar su sesión (solo si sabemos su email)
      // Nota: Si el usuario actual era uno de los usuarios de prueba que acabamos de crear,
      // no podemos restaurarlo sin la contraseña. El usuario deberá volver a hacer login.
      bool needsReLogin = false;
      if (currentUserEmail != null && currentUserEmail != auth.currentUser?.email) {
        // El usuario actual cambió, puede necesitar volver a hacer login
        needsReLogin = true;
        // Intentar restaurar la sesión original si es posible
        // (Nota: Firebase Auth no permite esto sin la contraseña, así que solo informamos)
      }
      
      results['Usuarios de Prueba (Auth)'] = '✅ Creados: $createdCount | Existentes: $existingCount | Errores: $errorCount';
      results['Usuarios de Prueba (Firestore)'] = '✅ Creados: $firestoreCreatedCount | Existentes: $firestoreExistingCount';

      if (!mounted) return;
      
      // Cerrar diálogo de carga
      Navigator.of(context).pop();
      
      // Mostrar diálogo con información completa
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.dashboardFirestoreInitialized),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resultados
                  ...results.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                  const SizedBox(height: 16),
                  Text(
                    l10n.dashboardTestUsersLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dashboardTestUsersPasswordNote,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dashboardTestUsersEmailNote,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  if (needsReLogin) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.dashboardFirestoreSessionNote,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    l10n.dashboardFirestoreIndexes,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dashboardFirestoreIndexesWarning,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.dashboardFirestoreIndexesDeployHint,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dashboardFirestoreIndexesDeployCommand,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      backgroundColor: Colors.black12,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.dashboardFirestoreConsoleHint,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dashboardFirestoreConsoleSteps,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.dashboardFirestoreDocs,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dashboardFirestoreDocsPaths,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.understood),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dashboardFirestoreInitError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// TEMPORAL: Eliminar usuarios de prueba
  Future<void> _showDeleteTestUsersDialog() async {
    if (!mounted) return;

    // Lista de usuarios de prueba que pueden eliminarse
    final testUsers = [
      {'email': 'unplanazoo+admin@gmail.com', 'label': 'Admin (Organizador)'},
      {'email': 'unplanazoo+coorg@gmail.com', 'label': 'Coorganizador'},
      {'email': 'unplanazoo+part1@gmail.com', 'label': 'Participante 1'},
      {'email': 'unplanazoo+part2@gmail.com', 'label': 'Participante 2'},
      {'email': 'unplanazoo+part3@gmail.com', 'label': 'Participante 3'},
      {'email': 'unplanazoo+obs@gmail.com', 'label': 'Observador'},
      {'email': 'unplanazoo+reject@gmail.com', 'label': 'Reject (Para rechazar invitaciones)'},
      {'email': 'unplanazoo+expired@gmail.com', 'label': 'Expired (Para invitaciones expiradas)'},
      {'email': 'unplanazoo+valid@gmail.com', 'label': 'Valid (Para validaciones)'},
      {'email': 'unplanazoo+temp1@gmail.com', 'label': 'Temp1 (Temporal)'},
      {'email': 'unplanazoo+temp2@gmail.com', 'label': 'Temp2 (Temporal)'},
      {'email': 'unplanazoo+invite1@gmail.com', 'label': 'Invite1 (Temporal)'},
    ];

    final selectedUsers = <String>{};

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.dashboardDeleteTestUsersTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dashboardDeleteTestUsersSelect,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.dashboardDeleteTestUsersWarning,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...testUsers.map((user) => CheckboxListTile(
                    title: Text(user['label']!),
                    subtitle: Text(
                      user['email']!,
                      style: const TextStyle(fontSize: 11),
                    ),
                    value: selectedUsers.contains(user['email']),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedUsers.add(user['email']!);
                        } else {
                          selectedUsers.remove(user['email']!);
                        }
                      });
                    },
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (selectedUsers.length == testUsers.length) {
                              selectedUsers.clear();
                            } else {
                              selectedUsers.addAll(testUsers.map((u) => u['email']!));
                            }
                          });
                        },
                        child: Text(
                          selectedUsers.length == testUsers.length
                              ? l10n.dashboardDeselectAll
                              : l10n.dashboardSelectAll,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: selectedUsers.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('${l10n.delete} (${selectedUsers.length})'),
            ),
          ],
        ),
      ),
    );

    if (result == true && selectedUsers.isNotEmpty && mounted) {
      await _deleteTestUsers(selectedUsers.toList());
    }
  }

  /// Elimina usuarios de prueba seleccionados
  Future<void> _deleteTestUsers(List<String> userEmails) async {
    if (!mounted) return;

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.dashboardDeletingUsersCount(userEmails.length)),
          ],
        ),
      ),
    );

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      final userService = UserService();

      int deletedAuthCount = 0;
      int deletedFirestoreCount = 0;
      int notFoundCount = 0;
      int errorCount = 0;
      final errors = <String>[];

      // Obtener usuario actual para evitar eliminarlo
      final currentUser = auth.currentUser;
      final currentUserEmail = currentUser?.email;

      for (final email in userEmails) {
        try {
          // Validación de seguridad: solo eliminar usuarios con alias (+)
          if (!email.contains('+') || !email.contains('@gmail.com')) {
            errorCount++;
            errors.add('$email: No es un usuario de prueba válido (debe contener +)');
            continue;
          }

          // No eliminar el usuario actual
          if (email == currentUserEmail) {
            errorCount++;
            errors.add('$email: No se puede eliminar el usuario actual');
            continue;
          }

          // Buscar usuario en Firebase Auth por email
          try {
            // Firebase Auth no tiene método directo para buscar por email,
            // así que intentamos hacer signIn y luego eliminar
            // Nota: Esto requiere la contraseña, así que usaremos Admin SDK si está disponible
            // Por ahora, usaremos un enfoque alternativo: buscar en Firestore primero
            
            // Buscar en Firestore collection 'users' por email
            final usersQuery = await firestore
                .collection('users')
                .where('email', isEqualTo: email)
                .limit(1)
                .get();

            if (usersQuery.docs.isNotEmpty) {
              final userId = usersQuery.docs.first.id;
              
              // Eliminar de Firestore
              try {
                await firestore.collection('users').doc(userId).delete();
                deletedFirestoreCount++;
              } catch (e) {
                errors.add('$email: Error eliminando de Firestore: $e');
              }

              // Intentar eliminar de Firebase Auth usando Admin SDK si está disponible
              // Por ahora, solo eliminamos de Firestore
              // Nota: Para eliminar de Auth, necesitaríamos Firebase Admin SDK o hacerlo manualmente desde Console
              deletedAuthCount++; // Contamos como intentado, aunque no se elimine de Auth
            } else {
              notFoundCount++;
            }
          } catch (e) {
            errorCount++;
            errors.add('$email: Error: $e');
            LoggerService.error('Error eliminando usuario $email', error: e);
          }
        } catch (e) {
          errorCount++;
          errors.add('$email: Error general: $e');
          LoggerService.error('Error procesando usuario $email', error: e);
        }
      }

      if (!mounted) return;

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      // Mostrar resultados
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.dashboardDeletionCompleted),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dashboardDeletedFromFirestore(deletedFirestoreCount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    l10n.dashboardNotFoundCount(notFoundCount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (errorCount > 0)
                    Text(
                      l10n.dashboardErrorsCount(errorCount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  if (errors.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.dashboardErrorsDetail,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...errors.map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        error,
                        style: const TextStyle(fontSize: 11),
                      ),
                    )),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    l10n.dashboardDeleteAuthNote,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.understood),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dashboardDeleteUsersError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Genera el plan Frankenstein de testing
  Future<void> _generateFrankensteinPlan(UserModel? currentUser) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.userNotAuthenticated),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Mostrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 16),
            Text(AppLocalizations.of(context)!.dashboardGeneratingFrankenstein),
          ],
        ),
        duration: const Duration(seconds: 10),
      ),
    );
    
    // Generar plan
    final planId = await DemoDataGenerator.generateFrankensteinPlan(currentUser.id);
    
    if (planId != null) {
      // No es necesario llamar _loadPlanazoos() - el stream se actualiza automáticamente
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dashboardFrankensteinSuccess),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.view,
              textColor: Colors.white,
              onPressed: () {
                // Seleccionar el plan Frankenstein generado
                setState(() {
                  selectedPlanId = planId;
                  selectedPlan = filteredPlanazoos.firstWhere(
                    (p) => p.id == planId,
                    orElse: () => filteredPlanazoos.first,
                  );
                  currentScreen = 'calendar';
                  selectedWidgetId = 'W15';
                });
              },
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dashboardFrankensteinError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = constraints.maxWidth;
        final gridHeight = constraints.maxHeight;
        final columnWidth = gridWidth / 17;
        final rowHeight = gridHeight / 13;
        
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade800, // Color sólido, sin gradiente
          ),
          child: Stack(
            children: [
              // Grid de fondo (oculto - solo para referencia de desarrollo)
              // CustomPaint(
              //   painter: GridPainter(
              //     cellWidth: columnWidth,
              //     cellHeight: rowHeight,
              //     daysPerWeek: 17, // Total de columnas en el dashboard
              //   ),
              // ),
              // W1: Barra lateral (C1, R1-R13)
              WdDashboardSidebar(
                columnWidth: columnWidth,
                gridHeight: gridHeight,
                onProfileTap: () => _changeScreen('profile'),
              ),
              // W2–W6: Logo, +, showcase, imagen e info del plan (C2–C11, R1)
              WdDashboardHeaderBar(
                columnWidth: columnWidth,
                rowHeight: rowHeight,
                selectedPlan: selectedPlan,
                onCreatePlan: _showCreatePlanDialog,
              ),
              // W7–W12: Celdas vacías header (C12–C17, R1)
              WdDashboardHeaderPlaceholders(
                columnWidth: columnWidth,
                rowHeight: rowHeight,
              ),
              // W13: Campo de búsqueda (C2-C5, R2)
              _buildW13(columnWidth, rowHeight),
              // W14–W25: Pestañas de navegación (C6–C17, R2)
              WdDashboardNavTabs(
                columnWidth: columnWidth,
                rowHeight: rowHeight,
                tabs: _dashboardTabItemsWithBadge(context),
                selectedId: selectedWidgetId,
                onTabTap: (id, screen) {
                  _selectWidget(id);
                  _changeScreen(screen);
                },
              ),
              // W26–W27: Filtros y toggle lista/calendario (C2-C5, R3–R4)
              WdDashboardFilters(
                columnWidth: columnWidth,
                rowHeight: rowHeight,
                selectedFilter: selectedFilter,
                isCalendarView: _isCalendarView,
                onFilterChanged: (value) => setState(() => selectedFilter = value),
                onViewModeChanged: (isCalendar) =>
                    setState(() => _isCalendarView = isCalendar),
              ),
              // W28: Lista de planazoos (C2-C5, R5-R12)
              _buildW28(columnWidth, rowHeight),
              // W29: Por definir (C2-C5, R13)
              _buildW29(columnWidth, rowHeight),
              // W30: oculto en UI (T194); ver _buildW30 en código por si se necesita
              // W31: Pantalla principal (C6-C17, R3 hasta final); sin recuadro (T194)
              _buildW31(columnWidth, rowHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildW13(double columnWidth, double rowHeight) {
    // W13: C2-C5 (R2) - Campo de búsqueda
    final w13X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w13Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w13Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w13Height = rowHeight; // Alto de 1 fila (R2)
    
    return Positioned(
      left: w13X,
      top: w13Y,
      child: Container(
        width: w13Width,
        height: w13Height,
        decoration: BoxDecoration(color: Colors.grey.shade700),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: PlanSearchWidget(onSearchChanged: _filterPlanazoos),
              ),
            ),
            Container(width: 4, color: AppColorScheme.color2),
          ],
        ),
      ),
    );
  }

  Widget _buildW28(double columnWidth, double rowHeight) {
    // W28: C2-C5 (R5-R12) - Lista de planazoos con imagen, información e iconos
    final w28X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w28Y = rowHeight * 4; // Empieza en la fila R5 (índice 4)
    final w28Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w28Height = rowHeight * 8; // Alto de 8 filas (R5-R12)
    
    return Positioned(
      left: w28X,
      top: w28Y,
      child: Container(
        width: w28Width,
        height: w28Height,
        decoration: BoxDecoration(color: Colors.grey.shade700),
        child: Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isCalendarView
              ? PlanCalendarView(
                  key: const ValueKey('plan-calendar-view'),
                  plans: filteredPlanazoos,
                  isLoading: isLoading,
                  onPlanSelected: (plan) {
                    if (plan.id != null) {
                      _selectPlanazoo(plan.id!);
                    }
                  },
                )
              : PlanListWidget(
                  key: const ValueKey('plan-list-view'),
                  plans: filteredPlanazoos,
                  selectedPlanId: selectedPlanId,
                  isLoading: isLoading,
                  onPlanSelected: _selectPlanazoo,
                  onPlanDeleted: _deletePlanazoo,
                ),
              ),
            ),
            Container(width: 4, color: AppColorScheme.color2),
          ],
        ),
      ),
    );
  }

  Widget _buildW30(double columnWidth, double rowHeight) {
    // W30: C6-C17 (R13) - Pie de página informaciones app
    final w30X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
    final w30Y = rowHeight * 12; // Empieza en la fila R13 (índice 12)
    final w30Width = columnWidth * 12; // Ancho de 12 columnas (C6-C17)
    final w30Height = rowHeight; // Alto de 1 fila (R13)
    
    return Positioned(
      left: w30X,
      top: w30Y,
      child: Container(
        width: w30Width,
        height: w30Height,
        decoration: BoxDecoration(
          color: Colors.grey.shade800, // Color sólido, sin gradiente
          // Sin borderRadius (esquinas en ángulo recto)
          // Sin borde
          // Sin sombras
        ),
        // Sin contenido
      ),
    );
  }

    Widget _buildW31(double columnWidth, double rowHeight) {
    // W31: C6-C17 (R3 hasta final de pantalla) - Pantalla principal; sin recuadro (T194)
    final w31X = columnWidth * 5;
    final w31Y = rowHeight * 2;
    final w31Width = columnWidth * 12;
    final w31Height = rowHeight * 11; // Hasta R13 (final de pantalla)
    
    if (currentScreen == 'profile') {
      final overlayLeft = columnWidth;
      final overlayTop = 0.0;
      final overlayWidth = columnWidth * 16;
      final overlayHeight = rowHeight * 13;

      return Positioned(
        left: overlayLeft,
        top: overlayTop,
        child: Container(
          width: overlayWidth,
          height: overlayHeight,
          color: AppColorScheme.color0,
          child: _buildProfileScreen(),
        ),
      );
    }

    // Si no hay planes y no estamos cargando, mostrar estado vacío general
    final bool noPlans = !isLoading && planazoos.isEmpty;

    final screensRequiringPlan = <String>{
      'planData',
      'stats',
      'payments',
      'participants',
    };
    final needsPlanSelection = screensRequiringPlan.contains(currentScreen);
    final hasSelectedPlan = selectedPlanId != null;

    return Positioned(
      left: w31X,
      top: w31Y,
      child: Container(
        width: w31Width,
        height: w31Height,
        // Sin recuadro de color (T194)
        child: noPlans
            ? _buildNoPlansYet()
            : (needsPlanSelection && !hasSelectedPlan)
                ? _buildNoPlanSelected()
                : _buildScreenContent(),
      ),
    );
  }

  Widget _buildNoPlansYet() {
    final user = ref.watch(currentUserProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          // Mensaje de no planes
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppColorScheme.color2,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.dashboardNoPlansYet,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.dashboardCreateFirstPlanHint,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showAcceptRejectDialog() async {
    final tokenController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isAccept = true;
    final user = ref.read(currentUserProvider);
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mustSignInToAcceptInvitations),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.dashboardManageInvitationByToken),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tokenController,
                  decoration: InputDecoration(
                    labelText: l10n.dashboardInvitationLinkOrTokenLabel,
                    hintText: l10n.dashboardInvitationLinkOrTokenHint,
                    helperText: l10n.dashboardInvitationLinkOrTokenHelper,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.dashboardInvitationLinkOrTokenRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text(l10n.accept),
                        value: true,
                        groupValue: isAccept,
                        onChanged: (v) => setDialogState(() => isAccept = v ?? true),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text(l10n.reject),
                        value: false,
                        groupValue: isAccept,
                        onChanged: (v) => setDialogState(() => isAccept = v ?? false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.continueButton),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      String input = tokenController.text.trim();
      String token = input;
      if (input.contains('/invitation/')) {
        final parts = input.split('/invitation/');
        if (parts.length > 1) {
          token = parts[1].split('?').first;
        }
      }
      
      if (token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invalidToken),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      bool ok = false;
      if (isAccept) {
        ok = await ref.read(invitationServiceProvider).acceptInvitationByToken(token, user.id);
        if (ok && mounted) {
          ref.invalidate(userPendingInvitationsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invitationAcceptedAddedToPlan),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {}); // Refrescar para mostrar cambios
        } else if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.tokenProcessingFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ok = await ref.read(invitationServiceProvider).rejectInvitationByToken(token);
        if (ok && mounted) {
          ref.invalidate(userPendingInvitationsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invitationRejectedSuccess),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {}); // Refrescar para mostrar cambios
        } else if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.tokenProcessingFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // NUEVO: Método para mostrar contenido según la pantalla seleccionada
  Widget _buildScreenContent() {
    Widget content;
    switch (currentScreen) {
      case 'planData':
        content = _buildPlanDataScreen();
        break;
      case 'stats':
        content = _buildStatsScreen();
        break;
      case 'payments':
        content = _buildPaymentsScreen();
        break;
      case 'profile':
        content = _buildProfileScreen();
        break;
      case 'email':
        content = _buildEmailScreen();
        break;
      case 'participants':
        content = _buildParticipantsScreen();
        break;
      case 'chat':
        content = _buildChatScreen();
        break;
      case 'pendingEvents':
      case 'unifiedNotifications':
        content = selectedPlan != null
            ? WdPlanNotificationsScreen(plan: selectedPlan!)
            : Center(
                child: Text(
                  AppLocalizations.of(context)!.dashboardSelectPlanToSeeNotifications,
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              );
        break;
      case 'adminInsights':
        content = AdminInsightsScreen(
          onClose: () {
            setState(() {
              currentScreen = 'calendar';
            });
          },
        );
        break;
      case 'calendar':
      default:
        content = _buildCalendarWidget();
        break;
    }
    
    return content;
  }

  // NUEVO: Pantalla de datos principales del plan
  Widget _buildPlanDataScreen() {
    if (selectedPlan == null) return const SizedBox.shrink();
    return PlanDataScreen(
      plan: selectedPlan!,
      onPlanDeleted: () {
        setState(() {
          planazoos.removeWhere((p) => p.id == selectedPlan!.id);
          filteredPlanazoos = List.from(planazoos);
          selectedPlan = null;
          selectedPlanId = null;
          currentScreen = 'calendar';
        });
      },
      onManageParticipants: () {
        setState(() {
          currentScreen = 'participants';
          selectedWidgetId = 'W16';
        });
      },
    );
  }

  // NUEVO: Pantalla de perfil
  Widget _buildProfileScreen() {
    return ProfilePage(
      onClose: _closeProfileScreen,
    );
  }

  // NUEVO: Pantalla de email (temporal)
  Widget _buildEmailScreen() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Label
            Container(
              width: 81,
              height: 38,
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.dashboardEmailLabel,
                style: AppTypography.bodyStyle.copyWith(
                  fontSize: 16,
                  color: AppColorScheme.color4,
                ),
              ),
            ),
            
            const SizedBox(width: 24), // Espaciado entre label y campo
            
            // Campo de texto
            Container(
              width: 320,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.dashboardIntroduceEmail,
                  hintStyle: AppTypography.interactiveStyle.copyWith(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: AppTypography.interactiveStyle.copyWith(
                  fontSize: 14,
                  color: AppColorScheme.color4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO: Método para mostrar mensaje cuando no hay plan seleccionado
  Widget _buildNoPlanSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: AppColorScheme.color2,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.dashboardSelectPlanazoo,
            style: AppTypography.titleStyle.copyWith(
              color: AppColorScheme.color4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.dashboardClickPlanToSeeCalendar,
            style: AppTypography.bodyStyle.copyWith(
              color: AppColorScheme.color4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  // Nuevo método para mostrar el calendario (o resumen, solo en W31 desde esta pestaña)
  Widget _buildCalendarWidget() {
    if (selectedPlan == null) {
      return _buildNoPlanSelected();
    }
    if (_calendarPanelView == 'summary') {
      final user = ref.watch(currentUserProvider);
      if (user == null) return CalendarScreen(key: ValueKey(selectedPlan!.id), plan: selectedPlan!, onShowSummary: _showSummaryInPanel);
      return WdPlanSummaryScreen(
        key: ValueKey('summary-${selectedPlan!.id}'),
        plan: selectedPlan!,
        userId: user.id,
        onShowCalendar: () => setState(() => _calendarPanelView = 'calendar'),
      );
    }
    return CalendarScreen(
      key: ValueKey(selectedPlan!.id),
      plan: selectedPlan!,
      onShowSummary: _showSummaryInPanel,
    );
  }



  Widget _buildW29(double columnWidth, double rowHeight) {
    // W29: C2-C5 (R13) - Centro de mensajes. Si hay invitaciones pendientes, mensaje + link a notificaciones.
    final w29X = columnWidth;
    final w29Y = rowHeight * 12;
    final w29Width = columnWidth * 4;
    final w29Height = rowHeight;
    final loc = AppLocalizations.of(context)!;
    final invitationsAsync = ref.watch(userPendingInvitationsProvider);

    return Positioned(
      left: w29X,
      top: w29Y,
      child: Container(
        width: w29Width,
        height: w29Height,
        decoration: BoxDecoration(color: Colors.grey.shade800),
        child: Row(
          children: [
            Expanded(
              child: invitationsAsync.when(
          data: (invitations) {
            if (invitations.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.dashboardInvitationsPendingCount(invitations.length),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade300,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const NotificationListDialog(),
                      );
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      foregroundColor: AppColorScheme.color2,
                    ),
                    child: Text(
                      loc.dashboardMessageCenterOpenNotifications,
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            Container(width: 4, color: AppColorScheme.color2),
          ],
        ),
      ),
    );
  }

  // NUEVO: Pantalla de participantes del plan
  Widget _buildParticipantsScreen() {
    if (selectedPlan == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.dashboardSelectPlanToSeeParticipants,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return ParticipantsScreen(
      plan: selectedPlan!,
      onBack: () {
        setState(() {
          currentScreen = 'calendar';
        });
      },
    );
  }

  // T190: Pantalla de chat del plan
  Widget _buildChatScreen() {
    if (selectedPlan == null || selectedPlan!.id == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.dashboardSelectPlanToSeeChat,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }

    return PlanChatScreen(
      planId: selectedPlan!.id!,
      planName: selectedPlan!.name,
    );
  }

  // T113: Pantalla de estadísticas del plan
  Widget _buildPaymentsScreen() {
    if (selectedPlan == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.dashboardSelectPlanToSeePayments,
          textAlign: TextAlign.center,
        ),
      );
    }
    return PaymentSummaryPage(plan: selectedPlan!);
  }

  Widget _buildStatsScreen() {
    if (selectedPlan == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.dashboardSelectPlanToSeeStats,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return PlanStatsPage(plan: selectedPlan!);
  }
}
