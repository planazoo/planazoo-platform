import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/testing/demo_data_generator.dart';
import 'package:unp_calendario/features/testing/family_users_generator.dart';
import 'package:unp_calendario/features/testing/mini_frank_simple_generator.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  bool _isTimezoneBannerLoading = false;
  bool _isCalendarView = false;
  // ignore: unused_field
  final PlanParticipationService _planParticipationService = PlanParticipationService();
  
  // NUEVO: Estado de navegación para W31
  String currentScreen = 'calendar'; // 'calendar', 'planData', 'participants', 'profile', etc.
  String _previousScreen = 'calendar';
  
  // NUEVO: Estado para trackear qué widget de W14-W25 está seleccionado
  String? selectedWidgetId; // 'W14', 'W15', 'W16', etc.
  String selectedFilter = 'todos'; // 'todos', 'estoy_in', 'pendientes', 'cerrados'

  // Flag para evitar procesar transiciones múltiples veces en la misma carga
  List<String> _processedPlanIds = [];
  final PlanParticipationService _participationService = PlanParticipationService();
  final Map<String, List<String>> _planParticipantNames = {};
  final Map<String, StreamSubscription<List<PlanParticipation>>> _participantSubscriptions = {};
  final Map<String, String> _userNameCache = {};
  final InvitationService _invitationService = InvitationService();
  
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

  Widget _buildTimezoneBanner(
    BuildContext context, {
    required String? configuredTimezone,
    required String deviceTimezone,
  }) {
    final loc = AppLocalizations.of(context)!;
    final userTz = configuredTimezone ?? deviceTimezone;
    final deviceDisplay = TimezoneService.getTimezoneDisplayName(deviceTimezone);
    final userDisplay = TimezoneService.getTimezoneDisplayName(userTz);
    final shouldShowDifference = configuredTimezone != null && configuredTimezone != deviceTimezone;

    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            const Color(0xFF2C2C2C),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.travel_explore, color: AppColorScheme.color2),
              const SizedBox(width: 8),
              Text(
                loc.timezoneBannerTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            loc.timezoneBannerMessage(deviceDisplay, userDisplay),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!shouldShowDifference)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                loc.profileTimezoneDialogDeviceHint,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorScheme.color2,
                      AppColorScheme.color2.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorScheme.color2.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isTimezoneBannerLoading
                      ? null
                      : () async {
                          setState(() {
                            _isTimezoneBannerLoading = true;
                          });
                          try {
                            await ref.read(authNotifierProvider.notifier).updateDefaultTimezone(deviceTimezone);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loc.timezoneBannerUpdateSuccess),
                                backgroundColor: Colors.green.shade600,
                              ),
                            );
                            if (mounted) {
                              setState(() {
                                _isTimezoneBannerLoading = false;
                              });
                            }
                          } catch (e) {
                            if (!mounted) return;
                            setState(() {
                              _isTimezoneBannerLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loc.timezoneBannerUpdateError),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isTimezoneBannerLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          loc.timezoneBannerUpdateButton(deviceDisplay),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).dismissTimezoneSuggestion();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.timezoneBannerKeepMessage(userDisplay)),
                      backgroundColor: Colors.blueGrey.shade700,
                    ),
                  );
                  setState(() {
                    _isTimezoneBannerLoading = false;
                  });
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  loc.timezoneBannerKeepButton(userDisplay),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        return _CreatePlanModal(
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
    });
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
        backgroundColor: Colors.grey.shade900,
        body: Stack(
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
                    child: _buildTimezoneBanner(
                      context,
                      configuredTimezone: configuredTimezone,
                      deviceTimezone: deviceTimezoneSuggestion,
                    ),
                  ),
                ),
              ),
          ],
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
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Inicializando Firestore...'),
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Firestore Inicializado'),
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
                  const Text(
                    '👥 Usuarios de Prueba:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Todos los usuarios usan la contraseña: test123456',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Todos los emails llegan a: unplanazoo@gmail.com',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  if (needsReLogin) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '⚠️ Nota: Tu sesión actual puede haber cambiado. Si es necesario, vuelve a hacer login.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    '📊 Índices de Firestore:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '⚠️ IMPORTANTE: Los índices NO se despliegan automáticamente desde la app.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Debes desplegarlos manualmente usando:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'firebase deploy --only firestore:indexes',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      backgroundColor: Colors.black12,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'O desde Firebase Console:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Ve a Firebase Console\n'
                    '2. Firestore Database → Indexes\n'
                    '3. Verifica que hay 25 índices definidos\n'
                    '4. Los índices se crearán automáticamente',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '📝 Ver documentación completa:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'docs/configuracion/FIRESTORE_INDEXES_AUDIT.md\n'
                    'docs/configuracion/USUARIOS_PRUEBA.md',
                    style: TextStyle(
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
                child: const Text('Entendido'),
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
            content: Text('❌ Error al inicializar Firestore: $e'),
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

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('🗑️ Eliminar Usuarios de Prueba'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona los usuarios que deseas eliminar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '⚠️ ADVERTENCIA: Esta acción eliminará los usuarios de Firebase Auth y Firestore. No se puede deshacer.',
                    style: TextStyle(
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
                              ? 'Deseleccionar todos'
                              : 'Seleccionar todos',
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: selectedUsers.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('${AppLocalizations.of(context)!.delete} (${selectedUsers.length})'),
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
            Text('Eliminando ${userEmails.length} usuario(s)...'),
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Eliminación Completada'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eliminados de Firestore: $deletedFirestoreCount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'No encontrados: $notFoundCount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (errorCount > 0)
                    Text(
                      'Errores: $errorCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  if (errors.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Errores detallados:',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                  const Text(
                    '⚠️ NOTA: Los usuarios también deben eliminarse manualmente de Firebase Auth Console si existen ahí.',
                    style: TextStyle(
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
                child: const Text('Entendido'),
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
            content: Text('❌ Error al eliminar usuarios: $e'),
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
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('🧟 Generando plan Frankenstein...'),
          ],
        ),
        duration: Duration(seconds: 10),
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
            content: const Text('🎉 Plan Frankenstein generado exitosamente!'),
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
          const SnackBar(
            content: Text('❌ Error al generar plan Frankenstein'),
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
          color: Colors.grey.shade900,
          child: Stack(
            children: [
              // Grid de fondo
              CustomPaint(
                painter: GridPainter(
                  cellWidth: columnWidth,
                  cellHeight: rowHeight,
                  daysPerWeek: 17, // Total de columnas en el dashboard
                ),
              ),
              // W1: Barra lateral (C1, R1-R13)
              _buildW1(columnWidth, rowHeight, gridHeight),
              // W2: Logo de la app (C2-C3, R1)
              _buildW2(columnWidth, rowHeight),
              // W3: Botón nuevo planazoo (C4, R1)
              _buildW3(columnWidth, rowHeight),
              // W4: Menú de opciones (C5, R1)
              _buildW4(columnWidth, rowHeight),
              // W5: Icono planazoo seleccionado (C6, R1)
              _buildW5(columnWidth, rowHeight),
              // W6: Información del planazoo seleccionado (C7-C11, R1)
              _buildW6(columnWidth, rowHeight),
              // W7: Info (C12, R1)
              _buildW7(columnWidth, rowHeight),
              // W8: Presupuesto (C13, R1)
              _buildW8(columnWidth, rowHeight),
              // W9: Contador participantes (C14, R1)
              _buildW9(columnWidth, rowHeight),
              // W10: Mi estado en el planazoo (C15, R1)
              _buildW10(columnWidth, rowHeight),
              // W11: Libre (C16, R1)
              _buildW11(columnWidth, rowHeight),
              // W12: Menu opciones (C17, R1)
              _buildW12(columnWidth, rowHeight),
              // W13: Campo de búsqueda (C2-C5, R2)
              _buildW13(columnWidth, rowHeight),
              // W14: Acceso info planazoo (C6, R2)
              _buildW14(columnWidth, rowHeight),
              // W15: Acceso calendario (C7, R2)
              _buildW15(columnWidth, rowHeight),
              // W16: Por definir (C8, R2)
              _buildW16(columnWidth, rowHeight),
              // W17: Por definir (C9, R2)
              _buildW17(columnWidth, rowHeight),
              // W18: Por definir (C10, R2)
              _buildW18(columnWidth, rowHeight),
              // W19: Por definir (C11, R2)
              _buildW19(columnWidth, rowHeight),
              // W20: Por definir (C12, R2)
              _buildW20(columnWidth, rowHeight),
              // W21: Por definir (C13, R2)
              _buildW21(columnWidth, rowHeight),
              // W22: Por definir (C14, R2)
              _buildW22(columnWidth, rowHeight),
              // W23: Por definir (C15, R2)
              _buildW23(columnWidth, rowHeight),
              // W24: Icono notificaciones (C16, R2)
              _buildW24(columnWidth, rowHeight),
              // W25: Icono mensajes (C17, R2)
              _buildW25(columnWidth, rowHeight),
              // W26: Filtros fijos (C2-C5, R3)
              _buildW26(columnWidth, rowHeight),
              // W27: Espacio extra (C2-C5, R4)
              _buildW27(columnWidth, rowHeight),
              // W28: Lista de planazoos (C2-C5, R5-R12)
              _buildW28(columnWidth, rowHeight),
              // W29: Por definir (C2-C5, R13)
              _buildW29(columnWidth, rowHeight),
              // W30: Por definir (C6-C17, R13)
              _buildW30(columnWidth, rowHeight),
              // W31: Pantalla principal (C6-C17, R3-R12)
              _buildW31(columnWidth, rowHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildW1(double columnWidth, double rowHeight, double gridHeight) {
    // W1: C1 (R1-R13) - Barra lateral izquierda
    final w1X = 0.0; // Empieza en la columna C1 (índice 0)
    final w1Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w1Width = columnWidth; // Ancho de 1 columna
    final w1Height = gridHeight; // Alto de todas las filas (R1-R13)
    final loc = AppLocalizations.of(context)!;
    
    return Positioned(
      left: w1X,
      top: w1Y,
      child: Container(
        width: w1Width,
        height: w1Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2, // Color de elementos interactivos de la app
          // Sin borderRadius - esquinas cuadradas
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Tooltip(
                message: loc.adminInsightsTooltip,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentScreen = 'adminInsights';
                      selectedPlanId = null;
                      selectedPlan = null;
                      selectedWidgetId = null;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.table_chart_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Tooltip(
                message: loc.profileTooltip,
                child: GestureDetector(
                  onTap: () {
                    _changeScreen('profile');
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24), // Icono redondo
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildW2(double columnWidth, double rowHeight) {
    // W2: C2-C3 (R1) - Logo de la app
    final w2X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w2Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w2Width = columnWidth * 2; // Ancho de 2 columnas (C2-C3)
    final w2Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w2X,
      top: w2Y,
      child: Container(
        width: w2Width,
        height: w2Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade700.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'planazoo',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW3(double columnWidth, double rowHeight) {
    // W3: C4 (R1) - Botón nuevo planazoo
    final w3X = columnWidth * 3; // Empieza en la columna C4 (índice 3)
    final w3Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w3Width = columnWidth; // Ancho de 1 columna (C4)
    final w3Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w3X,
      top: w3Y,
      child: Container(
        width: w3Width,
        height: w3Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade700.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: GestureDetector(
            onTap: () => _showCreatePlanDialog(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorScheme.color3,
                    AppColorScheme.color3.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColorScheme.color3.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '+',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW4(double columnWidth, double rowHeight) {
    // W4: C5 (R1) - Botón temporal para UI Showcase
    final w4X = columnWidth * 4; // Empieza en la columna C5 (índice 4)
    final w4Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w4Width = columnWidth; // Ancho de 1 columna (C5)
    final w4Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w4X,
      top: w4Y,
      child: Container(
        width: w4Width,
        height: w4Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade700.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UIShowcasePage(),
                ),
              );
            },
            icon: Icon(Icons.palette, color: AppColorScheme.color2),
            tooltip: 'UI Showcase',
          ),
        ),
      ),
    );
  }

  Widget _buildW5(double columnWidth, double rowHeight) {
    // W5: C6 (R1) - Foto del plan seleccionado
    final w5X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
    final w5Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w5Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w5Height = rowHeight; // Alto de 1 fila (R1)
    
    // Calcular el tamaño del círculo (responsive)
    final circleSize = (w5Width < w5Height ? w5Width : w5Height) * 0.8;
    
    return Positioned(
      left: w5X,
      top: w5Y,
      child: Container(
        width: w5Width,
        height: w5Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color2,
          // Sin borde - mismo color que el fondo
        ),
        child: Center(
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColorScheme.color2, width: 2),
            ),
            child: ClipOval(
              child: _buildPlanImage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanImage() {
    if (selectedPlan?.imageUrl != null && ImageService.isValidImageUrl(selectedPlan!.imageUrl)) {
      return CachedNetworkImage(
        imageUrl: selectedPlan!.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColorScheme.color2.withOpacity(0.1),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultIcon(),
      );
    } else {
      return _buildDefaultIcon();
    }
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: AppColorScheme.color2.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColorScheme.color1, // Cambiado a color1 para que sea visible
          size: 28,
        ),
      ),
    );
  }

  Widget _buildW6(double columnWidth, double rowHeight) {
    // W6: C7-C11 (R1) - Información del planazoo seleccionado
    final w6X = columnWidth * 6 - 1; // Empieza en la columna C7 (índice 6) - 1px para superponerse
    final w6Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w6Width = columnWidth * 5 + 1; // Ancho de 5 columnas + 1px para cubrir la línea
    final w6Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w6X,
      top: w6Y,
      child: Container(
        width: w6Width,
        height: w6Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorScheme.color2,
              AppColorScheme.color2.withOpacity(0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorScheme.color2.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: selectedPlan != null 
          ? _buildPlanInfoContent()
          : _buildNoPlanSelectedInfo(),
      ),
    );
  }

  /// Construye el contenido de información del plan seleccionado
  Widget _buildPlanInfoContent() {
    final loc = AppLocalizations.of(context)!;
    final roleLabel = _currentPlanRoleLabel(loc);
    final currentUser = ref.watch(currentUserProvider);
    final handle = _formatUserHandle(currentUser);

    return Padding(
      padding: const EdgeInsets.all(3.0), // Reducido aún más
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedPlan!.name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatDate(selectedPlan!.startDate)} - ${_formatDate(selectedPlan!.endDate)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            [
              if (handle.isNotEmpty) handle,
              if (roleLabel != null) loc.planRoleLabel(roleLabel),
            ].where((segment) => segment.isNotEmpty).join(' • '),
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Construye el contenido cuando no hay plan seleccionado
  Widget _buildNoPlanSelectedInfo() {
    return Center(
      child: Text(
        'Selecciona un plan',
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: Colors.white.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Formatea una fecha para mostrar
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? _currentPlanRoleLabel(AppLocalizations loc) {
    final plan = selectedPlan;
    if (plan == null || plan.id == null) return null;
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return null;
    if (plan.userId == currentUser.id) {
      return loc.planRoleOrganizer;
    }
    final participantsAsync = ref.watch(planParticipantsProvider(plan.id!));
    final role = participantsAsync.maybeWhen<String?>(
      data: (participants) {
        for (final participation in participants) {
          if (participation.userId == currentUser.id) {
            return participation.role;
          }
        }
        return null;
      },
      orElse: () => null,
    );
    return _mapRoleToText(role, loc);
  }

  String _mapRoleToText(String? role, AppLocalizations loc) {
    switch (role) {
      case 'organizer':
        return loc.planRoleOrganizer;
      case 'participant':
        return loc.planRoleParticipant;
      case 'observer':
        return loc.planRoleObserver;
      default:
        return loc.planRoleUnknown;
    }
  }

  String _formatUserHandle(UserModel? user) {
    if (user == null) return '';
    final username = user.username?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return '';
  }

  Widget _buildW7(double columnWidth, double rowHeight) {
    // W7: C12 (R1) - Fondo color2, vacío
    final w7X = columnWidth * 11 - 1; // Empieza en la columna C12 (índice 11) - 1px para superponerse
    final w7Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w7Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w7Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w7X,
      top: w7Y,
      child: Container(
        width: w7Width,
        height: w7Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorScheme.color2,
              AppColorScheme.color2.withOpacity(0.85),
            ],
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW8(double columnWidth, double rowHeight) {
    // W8: C13 (R1) - Fondo color2, vacío
    final w8X = columnWidth * 12 - 1; // Empieza en la columna C13 (índice 12) - 1px para superponerse
    final w8Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w8Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w8Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w8X,
      top: w8Y,
      child: Container(
        width: w8Width,
        height: w8Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorScheme.color2,
              AppColorScheme.color2.withOpacity(0.85),
            ],
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW9(double columnWidth, double rowHeight) {
    // W9: C14 (R1) - Fondo color2, vacío
    final w9X = columnWidth * 13 - 1; // Empieza en la columna C14 (índice 13) - 1px para superponerse
    final w9Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w9Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w9Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w9X,
      top: w9Y,
      child: Container(
        width: w9Width,
        height: w9Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorScheme.color2,
              AppColorScheme.color2.withOpacity(0.85),
            ],
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW10(double columnWidth, double rowHeight) {
    // W10: C15 (R1) - Fondo color2, vacío
    final w10X = columnWidth * 14 - 1; // Empieza en la columna C15 (índice 14) - 1px para superponerse
    final w10Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w10Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w10Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w10X,
      top: w10Y,
      child: Container(
        width: w10Width,
        height: w10Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorScheme.color2,
              AppColorScheme.color2.withOpacity(0.85),
            ],
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW11(double columnWidth, double rowHeight) {
    // W11: C16 (R1) - Fondo color2, vacío
    final w11X = columnWidth * 15 - 1; // Empieza en la columna C16 (índice 15) - 1px para superponerse
    final w11Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w11Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w11Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w11X,
      top: w11Y,
      child: Container(
        width: w11Width,
        height: w11Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorScheme.color2,
              AppColorScheme.color2.withOpacity(0.85),
            ],
          ),
          // Sin borde
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW12(double columnWidth, double rowHeight) {
    // W12: C17 (R1) - Fondo color2, vacío
    final w12X = columnWidth * 16 - 1; // Empieza en la columna C17 (índice 16) - 1px para superponerse
    final w12Y = 0.0; // Empieza en la fila R1 (índice 0)
    final w12Width = columnWidth + 1; // Ancho de 1 columna + 1px para cubrir la línea
    final w12Height = rowHeight; // Alto de 1 fila (R1)
    
    return Positioned(
      left: w12X,
      top: w12Y,
      child: Container(
        width: w12Width,
        height: w12Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorScheme.color2,
              AppColorScheme.color2.withOpacity(0.85),
            ],
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW14(double columnWidth, double rowHeight) {
    // W14: C6 (R2) - Acceso info planazoo
    final w14X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
    final w14Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w14Width = columnWidth; // Ancho de 1 columna (C6)
    final w14Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W14';
    final iconColor = AppColorScheme.color2;
    final textColor = isSelected ? Colors.white : Colors.grey.shade400;
    
    return Positioned(
      left: w14X,
      top: w14Y,
      child: Container(
        width: w14Width,
        height: w14Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColorScheme.color2.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            _selectWidget('W14');
            _changeScreen('planData');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono "i" color2
                Icon(
                  Icons.info,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                // Texto "planazoo" debajo del icono
                Text(
                  'planazoo',
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW15(double columnWidth, double rowHeight) {
    // W15: C7 (R2) - Acceso calendario
    final w15X = columnWidth * 6; // Empieza en la columna C7 (índice 6)
    final w15Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w15Width = columnWidth; // Ancho de 1 columna (C7)
    final w15Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W15';
    final iconColor = AppColorScheme.color2;
    final textColor = isSelected ? Colors.white : Colors.grey.shade400;
    
    return Positioned(
      left: w15X,
      top: w15Y,
      child: Container(
        width: w15Width,
        height: w15Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColorScheme.color2.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            _selectWidget('W15');
            _changeScreen('calendar');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono calendario color2
                Icon(
                  Icons.calendar_today,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                // Texto "calendario" debajo del icono
                Text(
                  'calendario',
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW16(double columnWidth, double rowHeight) {
    // W16: C8 (R2) - Participante del plan
    final w16X = columnWidth * 7; // Empieza en la columna C8 (índice 7)
    final w16Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w16Width = columnWidth; // Ancho de 1 columna (C8)
    final w16Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W16';
    final iconColor = AppColorScheme.color2;
    final textColor = isSelected ? Colors.white : Colors.grey.shade400;
    
    return Positioned(
      left: w16X,
      top: w16Y,
      child: Container(
        width: w16Width,
        height: w16Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColorScheme.color2.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            _selectWidget('W16');
            _changeScreen('participants');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono "formas de personas" color2
                Icon(
                  Icons.group,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                // Texto "in" debajo del icono
                Text(
                  'in',
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW17(double columnWidth, double rowHeight) {
    // W17: C9 (R2) - T113: Estadísticas del plan
    final w17X = columnWidth * 8; // Empieza en la columna C9 (índice 8)
    final w17Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w17Width = columnWidth; // Ancho de 1 columna (C9)
    final w17Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W17';
    final iconColor = AppColorScheme.color2;
    final textColor = isSelected ? Colors.white : Colors.grey.shade400;
    
    return Positioned(
      left: w17X,
      top: w17Y,
      child: Container(
        width: w17Width,
        height: w17Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColorScheme.color2.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            _selectWidget('W17');
            _changeScreen('stats');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono estadísticas color2
                Icon(
                  Icons.bar_chart,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                // Texto "stats" debajo del icono
                Text(
                  'stats',
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW18(double columnWidth, double rowHeight) {
    // W18: C10 (R2) - T102: Resumen de pagos
    final w18X = columnWidth * 9; // Empieza en la columna C10 (índice 9)
    final w18Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w18Width = columnWidth; // Ancho de 1 columna (C10)
    final w18Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W18';
    final iconColor = AppColorScheme.color2;
    final textColor = isSelected ? Colors.white : Colors.grey.shade400;
    
    return Positioned(
      left: w18X,
      top: w18Y,
      child: Container(
        width: w18Width,
        height: w18Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColorScheme.color2.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            _selectWidget('W18');
            _changeScreen('payments');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono pagos color2
                Icon(
                  Icons.payment,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                // Texto "pagos" debajo del icono
                Text(
                  'pagos',
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW19(double columnWidth, double rowHeight) {
    // W19: C11 (R2) - Widget básico
    final w19X = columnWidth * 10; // Empieza en la columna C11 (índice 10)
    final w19Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w19Width = columnWidth; // Ancho de 1 columna (C11)
    final w19Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W19';
    
    return Positioned(
      left: w19X,
      top: w19Y,
      child: Container(
        width: w19Width,
        height: w19Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW20(double columnWidth, double rowHeight) {
    // W20: C12 (R2) - Widget básico
    final w20X = columnWidth * 11; // Empieza en la columna C12 (índice 11)
    final w20Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w20Width = columnWidth; // Ancho de 1 columna (C12)
    final w20Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W20';
    
    return Positioned(
      left: w20X,
      top: w20Y,
      child: Container(
        width: w20Width,
        height: w20Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW21(double columnWidth, double rowHeight) {
    // W21: C13 (R2) - Widget básico
    final w21X = columnWidth * 12; // Empieza en la columna C13 (índice 12)
    final w21Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w21Width = columnWidth; // Ancho de 1 columna (C13)
    final w21Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W21';
    
    return Positioned(
      left: w21X,
      top: w21Y,
      child: Container(
        width: w21Width,
        height: w21Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW22(double columnWidth, double rowHeight) {
    // W22: C14 (R2) - Widget básico
    final w22X = columnWidth * 13; // Empieza en la columna C14 (índice 13)
    final w22Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w22Width = columnWidth; // Ancho de 1 columna (C14)
    final w22Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W22';
    
    return Positioned(
      left: w22X,
      top: w22Y,
      child: Container(
        width: w22Width,
        height: w22Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW23(double columnWidth, double rowHeight) {
    // W23: C15 (R2) - Widget básico
    final w23X = columnWidth * 14; // Empieza en la columna C15 (índice 14)
    final w23Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w23Width = columnWidth; // Ancho de 1 columna (C15)
    final w23Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W23';
    
    return Positioned(
      left: w23X,
      top: w23Y,
      child: Container(
        width: w23Width,
        height: w23Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW24(double columnWidth, double rowHeight) {
    // W24: C16 (R2) - Widget básico
    final w24X = columnWidth * 15; // Empieza en la columna C16 (índice 15)
    final w24Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w24Width = columnWidth; // Ancho de 1 columna (C16)
    final w24Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W24';
    
    return Positioned(
      left: w24X,
      top: w24Y,
      child: Container(
        width: w24Width,
        height: w24Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        // Sin contenido
      ),
    );
  }

  Widget _buildW25(double columnWidth, double rowHeight) {
    // W25: C17 (R2) - Widget básico
    final w25X = columnWidth * 16; // Empieza en la columna C17 (índice 16)
    final w25Y = rowHeight; // Empieza en la fila R2 (índice 1)
    final w25Width = columnWidth; // Ancho de 1 columna (C17)
    final w25Height = rowHeight; // Alto de 1 fila (R2)
    
    // Determinar colores según el estado de selección
    final isSelected = selectedWidgetId == 'W25';
    
    return Positioned(
      left: w25X,
      top: w25Y,
      child: Container(
        width: w25Width,
        height: w25Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ]
                : [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        // Sin contenido
      ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade700.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8), // Padding para el TextField
        child: PlanSearchWidget(onSearchChanged: _filterPlanazoos),
      ),
    );
  }

  Widget _buildW26(double columnWidth, double rowHeight) {
    // W26: C2-C5 (R3) - Filtros fijos de la lista de planazoos
    final w26X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w26Y = rowHeight * 2; // Empieza en la fila R3 (índice 2)
    final w26Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w26Height = rowHeight; // Alto de 1 fila (R3)
    
    return Positioned(
      left: w26X,
      top: w26Y,
      child: Container(
        width: w26Width,
        height: w26Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade700.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4), // Padding para los botones
        child: Row(
          children: [
            _buildFilterButton('todos', 'Todos', columnWidth, rowHeight),
            const SizedBox(width: 2),
            _buildFilterButton('estoy_in', 'Estoy in', columnWidth, rowHeight),
            const SizedBox(width: 2),
            _buildFilterButton('pendientes', 'Pendientes', columnWidth, rowHeight),
            const SizedBox(width: 2),
            _buildFilterButton('cerrados', 'Cerrados', columnWidth, rowHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filterValue, String label, double columnWidth, double rowHeight) {
    final isSelected = selectedFilter == filterValue;
    return Expanded(
      child: Container(
        height: rowHeight * 0.6, // Altura menor (60% de la altura de fila)
        margin: EdgeInsets.symmetric(vertical: rowHeight * 0.2), // Centrado vertical
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade800,
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColorScheme.color2.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedFilter = filterValue;
            });
            // De momento no hacen nada (sin funcionalidad)
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW27(double columnWidth, double rowHeight) {
    // W27: C2-C5 (R4) - Auxiliar
    final w27X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w27Y = rowHeight * 3; // Empieza en la fila R4 (índice 3)
    final w27Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w27Height = rowHeight; // Alto de 1 fila (R4)
    final loc = AppLocalizations.of(context)!;
    
    return Positioned(
      left: w27X,
      top: w27Y,
      child: Container(
        width: w27Width,
        height: w27Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade700.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF2C2C2C),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey.shade700.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ToggleButtons(
            isSelected: [
              !_isCalendarView,
              _isCalendarView,
            ],
            onPressed: (index) {
              setState(() {
                _isCalendarView = index == 1;
              });
            },
            borderRadius: BorderRadius.circular(24),
            renderBorder: false,
            fillColor: AppColorScheme.color2,
            selectedColor: Colors.white,
            color: Colors.grey.shade400,
            constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.view_list_outlined,
                      color: !_isCalendarView ? Colors.white : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.planViewModeList,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: !_isCalendarView ? Colors.white : Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: _isCalendarView ? Colors.white : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.planViewModeCalendar,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _isCalendarView ? Colors.white : Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade700.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
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
    );
  }

  Widget _buildW30(double columnWidth, double rowHeight) {
    // W30: C6-C17 (R13) - Pie de página informaciones app
    final w30X = columnWidth * 5; // Empieza en la columna C6 (índice 5)
    final w30Y = rowHeight * 12; // Empieza en la fila R13 (índice 12)
    final w30Width = columnWidth * 12; // Ancho de 12 columnas (C6-C17)
    final w30Height = rowHeight * 0.75; // Alto de 0.75 filas (R13)
    
    return Positioned(
      left: w30X,
      top: w30Y,
      child: Container(
        width: w30Width,
        height: w30Height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorScheme.color2,
              AppColorScheme.color2.withOpacity(0.85),
            ],
          ),
        ),
        // Sin contenido
      ),
    );
  }

    Widget _buildW31(double columnWidth, double rowHeight) {
    // W31: C6-C17 (R3-R12) - Pantalla principal con navegación
    final w31X = columnWidth * 5;
    final w31Y = rowHeight * 2;
    final w31Width = columnWidth * 12;
    final w31Height = rowHeight * 10;
    
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              const Color(0xFF2C2C2C),
            ],
          ),
          border: Border.all(
            color: AppColorScheme.color2.withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
          // Sección de invitaciones pendientes
          if (user != null) _buildPendingInvitationsBanner(),
          
          const SizedBox(height: 32),
          
          // Mensaje de no planes
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppColorScheme.color2,
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes planes',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer plan con el botón +',
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

  Widget _buildPendingInvitationsBanner() {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    
    return FutureBuilder<List<PlanInvitation>>(
      future: _invitationService.getPendingInvitationsByEmail(user.email),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        
        final invitations = snapshot.data ?? [];
        if (invitations.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            border: Border.all(
              color: Colors.orange.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.mail_outline, color: Colors.orange.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tienes ${invitations.length} invitación(es) pendiente(s)',
                      style: AppTypography.titleStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...invitations.map((inv) => _buildInvitationCard(inv)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAcceptRejectDialog(),
                  icon: const Icon(Icons.vpn_key_outlined),
                  label: const Text('Aceptar/Rechazar por token'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvitationCard(PlanInvitation invitation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan: ${invitation.planId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (invitation.role != null)
                  Text(
                    'Rol: ${invitation.role}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (invitation.token != null)
                  TextButton.icon(
                    onPressed: () async {
                      final link = _invitationService.generateInvitationLink(invitation.token!);
                      await Clipboard.setData(ClipboardData(text: link));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copiado al portapapeles')),
                        );
                      }
                    },
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('Copiar link'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
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
        const SnackBar(
          content: Text('❌ Debes iniciar sesión para aceptar invitaciones'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Gestionar invitación por token'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Link o token de invitación',
                    hintText: 'Pega el link completo o solo el token',
                    helperText: 'Ejemplo: https://planazoo.app/invitation/abc123... o solo abc123...',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Introduce el link o token';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Aceptar'),
                        value: true,
                        groupValue: isAccept,
                        onChanged: (v) => setDialogState(() => isAccept = v ?? true),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Rechazar'),
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
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Continuar'),
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
            const SnackBar(
              content: Text('❌ Token inválido'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      bool ok = false;
      if (isAccept) {
        ok = await _invitationService.acceptInvitationByToken(token, user.id);
        if (ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Invitación aceptada. Has sido añadido al plan.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {}); // Refrescar para mostrar cambios
        } else if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo procesar el token. Verifica que sea válido y no haya expirado.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ok = await _invitationService.rejectInvitationByToken(token);
        if (ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Invitación rechazada'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {}); // Refrescar para mostrar cambios
        } else if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo procesar el token. Verifica que sea válido y no haya expirado.'),
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
    
    // Añadir banner de invitaciones pendientes en la parte superior
    return Column(
      children: [
        _buildPendingInvitationsBanner(),
        Expanded(child: content),
      ],
    );
  }

  // NUEVO: Pantalla de datos principales del plan
  Widget _buildPlanDataScreen() {
    if (selectedPlan == null) return const SizedBox.shrink();
    return PlanDataScreen(
      plan: selectedPlan!,
      onPlanDeleted: () {
        // Actualizar la lista de planes después de eliminar
        setState(() {
          planazoos.removeWhere((p) => p.id == selectedPlan!.id);
          filteredPlanazoos = List.from(planazoos);
          selectedPlan = null;
          selectedPlanId = null;
          currentScreen = 'calendar'; // Volver al calendario
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
                'email',
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
                  hintText: 'Introduce el mail',
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
            'Selecciona un Planazoo',
            style: AppTypography.titleStyle.copyWith(
              color: AppColorScheme.color4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Haz clic en un planazoo de la lista\nderecha para ver su calendario',
            style: AppTypography.bodyStyle.copyWith(
              color: AppColorScheme.color4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  // Nuevo método para mostrar el calendario
  Widget _buildCalendarWidget() {
    if (selectedPlan == null) {
      return _buildNoPlanSelected();
    }
    return CalendarScreen(
      key: ValueKey(selectedPlan!.id), // Forzar rebuild cuando cambie el plan
      plan: selectedPlan!,
    );
  }



  Widget _buildW29(double columnWidth, double rowHeight) {
    // W29: C2-C5 (R13) - Pie de página publicitario
    final w29X = columnWidth; // Empieza en la columna C2 (índice 1)
    final w29Y = rowHeight * 12; // Empieza en la fila R13 (índice 12)
    final w29Width = columnWidth * 4; // Ancho de 4 columnas (C2-C5)
    final w29Height = rowHeight * 0.75; // Alto de 0.75 filas (R13)
    
    return Positioned(
      left: w29X,
      top: w29Y,
      child: Container(
        width: w29Width,
        height: w29Height,
        decoration: BoxDecoration(
          color: AppColorScheme.color0, // Fondo color0
          border: Border(
            top: BorderSide(
              color: AppColorScheme.color1, // Borde superior color1
              width: 1,
            ),
          ),
          // Sin borderRadius (esquinas en ángulo recto)
        ),
        // Sin contenido
      ),
    );
  }

  // NUEVO: Pantalla de participantes del plan
  Widget _buildParticipantsScreen() {
    if (selectedPlan == null) {
      return const Center(
        child: Text(
          'Selecciona un plan para ver los participantes',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
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

  // T113: Pantalla de estadísticas del plan
  Widget _buildPaymentsScreen() {
    if (selectedPlan == null) {
      return const Center(
        child: Text(
          'Selecciona un plan para ver el resumen de pagos',
          textAlign: TextAlign.center,
        ),
      );
    }
    return PaymentSummaryPage(plan: selectedPlan!);
  }

  Widget _buildStatsScreen() {
    if (selectedPlan == null) {
      return const Center(
        child: Text(
          'Selecciona un plan para ver las estadísticas',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return PlanStatsPage(plan: selectedPlan!);
  }
}

// Modal para crear plan con tamaño específico (R1-R17, C2-C3)
class _CreatePlanModal extends ConsumerStatefulWidget {
  final Function(Plan) onPlanCreated;

  const _CreatePlanModal({
    required this.onPlanCreated,
  });

  @override
  ConsumerState<_CreatePlanModal> createState() => _CreatePlanModalState();
}

class _CreatePlanModalState extends ConsumerState<_CreatePlanModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unpIdController = TextEditingController();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _generateAutoUnpId();
  }

  Future<void> _generateAutoUnpId() async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final planService = ref.read(planServiceProvider);
        final generatedId = await planService.generateUniqueUnpId(
          currentUser.id,
          username: currentUser.username,
        );
        if (mounted) {
          setState(() {
            _unpIdController.text = generatedId;
          });
        }
      }
    } catch (e) {
      LoggerService.error('Error generating auto UNP ID', context: 'CREATE_PLAN_MODAL', error: e);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unpIdController.dispose();
    super.dispose();
  }

  Future<void> _createPlan() async {
    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }
    if (!formState.validate()) {
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    final loc = AppLocalizations.of(context)!;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.createPlanAuthError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final now = DateTime.now();
      final sanitizedName = Sanitizer.sanitizePlainText(_nameController.text, maxLength: 100);
      final sanitizedUnpId = Sanitizer.sanitizePlainText(_unpIdController.text, maxLength: 40);
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(const Duration(days: 6));
      final columnCount = endDate.difference(startDate).inDays + 1;

      final plan = Plan(
        name: sanitizedName,
        unpId: sanitizedUnpId,
        userId: currentUser.id,
        baseDate: startDate,
        startDate: startDate,
        endDate: endDate,
        columnCount: columnCount,
        description: null,
        state: 'borrador',
        visibility: 'private',
        timezone: TimezoneService.getSystemTimezone(),
        currency: 'EUR',
        participants: 0,
        createdAt: now,
        updatedAt: now,
        savedAt: now,
      );

      final planService = ref.read(planServiceProvider);
      final planId = await planService.createPlan(plan);

      if (planId == null) {
        throw Exception('plan-create-error');
      }

      final createdPlan = await planService.getPlanById(planId);

      if (!mounted) return;

      Navigator.of(context).pop();
      if (createdPlan != null) {
        widget.onPlanCreated(createdPlan);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.createPlanGenericError),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.createPlan),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: loc.createPlanNameLabel,
                  hintText: loc.createPlanNameHint,
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.createPlanNameRequiredError;
                  }
                  if (value.trim().length < 3) {
                    return loc.createPlanNameTooShortError;
                  }
                  if (value.trim().length > 100) {
                    return loc.createPlanNameTooLongError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Text(
                _unpIdController.text.isEmpty
                    ? loc.createPlanUnpIdLoading
                    : loc.createPlanUnpIdHeader(_unpIdController.text),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.createPlanQuickIntro,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createPlan,
          child: _isCreating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(loc.createPlanContinueButton),
        ),
      ],
    );
  }
}

