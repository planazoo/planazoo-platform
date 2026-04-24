import 'dart:math' as math;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_navigation_bar.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_data_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_my_plan_summary_screen.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';
import 'package:unp_calendario/widgets/wd_accommodation_dialog.dart';
import 'package:unp_calendario/widgets/dialogs/summary_preview_modals.dart';
import 'package:unp_calendario/pages/pg_calendar_mobile_page.dart';
import 'package:unp_calendario/widgets/screens/wd_participants_screen.dart';
import 'package:unp_calendario/features/stats/presentation/pages/plan_stats_page.dart';
import 'package:unp_calendario/features/payments/presentation/pages/payment_summary_page.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_chat_screen.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_user_status_label.dart';
import 'package:unp_calendario/widgets/help/help_icon_button.dart';
import 'package:unp_calendario/shared/constants/help_context_ids.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/pages/pg_plans_list_page.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_notifications_screen.dart';
import 'package:unp_calendario/features/payments/presentation/widgets/add_expense_dialog.dart';
import 'package:unp_calendario/features/payments/presentation/providers/payment_providers.dart';
import 'package:unp_calendario/features/chat/presentation/providers/chat_providers.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
import 'package:unp_calendario/features/stats/presentation/providers/plan_stats_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/notifications/domain/services/notification_helper.dart';
import 'package:unp_calendario/features/plan_notes/presentation/pages/plan_notes_screen.dart';

/// Página de detalle del plan para mobile
/// Incluye barra de navegación horizontal y contenido según la opción seleccionada
class PlanDetailPage extends ConsumerStatefulWidget {
  final Plan plan;
  /// Pestaña inicial al abrir (p. ej. 'mySummary', 'chat').
  final String? initialTab;

  const PlanDetailPage({
    super.key,
    required this.plan,
    this.initialTab,
  });

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  static const Color _cPageBg = Color(0xFF111827);
  static const Color _cTextPrimary = Colors.white;
  static const Color _cTextSecondary = Colors.white70;
  static const double _aBorderStrong = 0.12;

  late String _selectedOption;
  String _summaryViewMode = 'mine';
  bool _summaryDraftOnly = false;
  bool _summaryShowDraftFilter = false;
  bool _hasSetInitialTabForParticipant = false;
  /// Estado del calendario embebido: días visibles (1/2/3) y grupo actual (barra unificada).
  /// iOS: 3 días por defecto (lista §3.1 / ID 51).
  int _calendarVisibleDays =
      (defaultTargetPlatform == TargetPlatform.iOS) ? 3 : 1;
  /// Índice 1-based: primera columna del calendario embebido (ítem 99: anclar a hoy al abrir).
  late int _calendarFirstPlanDay;

  /// [widget.plan] solo refleja el plan al abrir la pantalla; al guardar fechas/duración en Info,
  /// el documento en Firestore cambia pero el constructor no. Usamos [plansStreamProvider] para
  /// que calendario, resumen y demás pestañas vean el plan actualizado.
  Plan _planFromStreamWatch() {
    final id = widget.plan.id;
    if (id == null) return widget.plan;
    final async = ref.watch(plansStreamProvider);
    return async.when(
      data: (plans) {
        for (final p in plans) {
          if (p.id == id) return p;
        }
        return widget.plan;
      },
      loading: () => widget.plan,
      error: (_, __) => widget.plan,
    );
  }

  Plan _planFromStreamRead() {
    final id = widget.plan.id;
    if (id == null) return widget.plan;
    final async = ref.read(plansStreamProvider);
    return async.when(
      data: (plans) {
        for (final p in plans) {
          if (p.id == id) return p;
        }
        return widget.plan;
      },
      loading: () => widget.plan,
      error: (_, __) => widget.plan,
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialTab ?? 'planData';
    _calendarFirstPlanDay =
        Plan.initialVisiblePlanDayIndex(widget.plan, _calendarVisibleDays);
  }

  @override
  Widget build(BuildContext context) {
    final plan = _planFromStreamWatch();
    final currentUser = ref.watch(currentUserProvider);
    final planId = plan.id;
    final isOrganizer = currentUser?.id == plan.userId;
    // Si no es organizador y está en Estadísticas, redirigir a Info
    if (!isOrganizer && _selectedOption == 'stats') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedOption = 'planData');
      });
    }
    // T252: Si el usuario es participante (no organizador), abrir por defecto en "Mi resumen"
    if (widget.initialTab == null && planId != null && currentUser != null && plan.userId != currentUser.id && !_hasSetInitialTabForParticipant) {
      final participantsAsync = ref.watch(planParticipantsProvider(planId));
      participantsAsync.whenData((participants) {
        final isParticipant = participants.any((p) => p.userId == currentUser.id);
        if (isParticipant && _selectedOption == 'planData') {
          _hasSetInitialTabForParticipant = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedOption = 'mySummary');
          });
        }
      });
    }
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: _cPageBg,
        appBar: _buildAppBar(plan),
        bottomNavigationBar: _buildQuickActionsBar(plan),
        body: SafeArea(
          child: Column(
            children: [
              // Barra de navegación horizontal (Estadísticas solo para organizador)
              PlanNavigationBar(
                selectedOption: _selectedOption,
                onOptionSelected: (option) {
                  setState(() {
                    _selectedOption = option;
                  });
                },
                showStatsTab: isOrganizer,
              ),
              _buildSectionTitleBar(),
              // Contenido según la opción seleccionada
              Expanded(
                child: _buildContent(plan),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Barra superior: nombre del plan, chip mi estado (dentro/fuera/pend.) y ayuda P18.
  PreferredSizeWidget _buildAppBar(Plan plan) {
    final loc = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: _cPageBg,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: _cTextPrimary,
        ),
        onPressed: () {
          // Si al hacer pop no queda nada debajo (pantalla negra), aseguramos volver a la lista de planes.
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PlansListPage()),
            );
          }
        },
      ),
      title: Text(
        plan.name,
        style: GoogleFonts.poppins(
          color: _cTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: PlanUserStatusLabel(
                  plan: plan,
                  compact: true,
                ),
              ),
              HelpIconButton(
                helpId: HelpContextIds.planDetailMyStatus,
                contextLabel: loc.planMyStatusHelpTitle,
                defaultBody: loc.planMyStatusHelpDefault,
                iconSize: 18,
                iconColor: _cTextSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitleBar() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _cPageBg,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              _currentSectionTitle(loc),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_selectedOption == 'mySummary') ...[
            const SizedBox(width: 8),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSummaryViewModeChip(
                        label: loc.myPlanSummaryViewMine,
                        selected: _summaryViewMode == 'mine',
                        onTap: () => setState(() => _summaryViewMode = 'mine'),
                      ),
                      const SizedBox(width: 6),
                      _buildSummaryViewModeChip(
                        label: loc.myPlanSummaryViewPlan,
                        selected: _summaryViewMode == 'plan',
                        onTap: () => setState(() => _summaryViewMode = 'plan'),
                      ),
                      if (_summaryShowDraftFilter) ...[
                        const SizedBox(width: 6),
                        _buildSummaryHeaderFilterButton(
                          tooltip: loc.myPlanSummaryDraftsOnlyTooltip,
                          active: _summaryDraftOnly,
                          onTap: () => setState(() => _summaryDraftOnly = !_summaryDraftOnly),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (_selectedOption == 'payments') ...[
            const SizedBox(width: 8),
            Tooltip(
              message: loc.paymentsAddExpense,
              child: InkWell(
                onTap: _quickCreatePayment,
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryHeaderFilterButton({
    required String tooltip,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active
                ? Colors.orange.shade200.withValues(alpha: 0.2)
                : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: active
                  ? Colors.orange.shade200.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Icon(
            active ? Icons.filter_alt : Icons.filter_alt_outlined,
            color: active ? Colors.orange.shade200 : Colors.white70,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryViewModeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColorScheme.color2.withValues(alpha: 0.22) : const Color(0xFF1F2937),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  String _currentSectionTitle(AppLocalizations loc) {
    switch (_selectedOption) {
      case 'planData':
        return 'Info';
      case 'mySummary':
        return loc.myPlanSummaryTab;
      case 'calendar':
        return _capitalize(loc.dashboardTabCalendar);
      case 'participants':
        return loc.participants;
      case 'chat':
        return _capitalize(loc.dashboardTabChat);
      case 'payments':
        return loc.paymentsSummaryTitle;
      case 'planNotifications':
        return loc.notificationsTitle;
      case 'planNotes':
        return loc.planNotesTabTitle;
      case 'stats':
        return _capitalize(loc.dashboardTabStats);
      default:
        return 'Info';
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  Widget _buildQuickActionsBar(Plan plan) {
    final loc = AppLocalizations.of(context)!;
    final planId = plan.id;
    final unreadChat = planId != null
        ? (ref.watch(unreadMessagesCountProvider(planId)).valueOrNull ?? 0)
        : 0;
    final unreadNotifications = planId != null
        ? (ref.watch(planUnreadCountProvider(planId)).valueOrNull ?? 0)
        : 0;

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: _cPageBg,
          border: Border(
            top: BorderSide(
              color: _cTextPrimary.withValues(alpha: _aBorderStrong),
              width: 1,
            ),
          ),
          boxShadow: null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionButton(
              icon: Icons.add_circle_outline,
              onTap: _quickCreateEvent,
              tooltip: loc.createEvent,
              isActive: _selectedOption == 'calendar',
            ),
            _buildQuickActionButton(
              icon: Icons.hotel_outlined,
              onTap: _quickCreateAccommodation,
              tooltip: loc.tooltipCreateAccommodation,
              isActive: _selectedOption == 'calendar',
            ),
            _buildQuickActionButton(
              icon: _selectedOption == 'chat' ? Icons.chat_bubble : Icons.chat_bubble_outline,
              onTap: _quickOpenChat,
              tooltip: loc.dashboardTabChat,
              isActive: _selectedOption == 'chat',
              badgeCount: unreadChat,
            ),
            _buildQuickActionButton(
              icon: Icons.receipt_long_outlined,
              onTap: _quickCreatePayment,
              tooltip: loc.paymentsAddExpense,
              isActive: _selectedOption == 'payments',
            ),
            _buildQuickActionButton(
              icon: _selectedOption == 'planNotifications' ? Icons.notifications : Icons.notifications_outlined,
              onTap: _quickOpenNotifications,
              tooltip: loc.notificationsTitle,
              isActive: _selectedOption == 'planNotifications',
              badgeCount: unreadNotifications,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    required bool isActive,
    int badgeCount = 0,
  }) {
    final iconColor = isActive
        ? _cTextPrimary
        : _cTextSecondary;
    final bg = isActive
        ? AppColorScheme.color2
        : Colors.transparent;
    final borderColor = isActive
        ? AppColorScheme.color2
        : _cTextPrimary.withValues(alpha: _aBorderStrong);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isActive ? 1.6 : 1),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColorScheme.color2.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColorScheme.color3,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 0.5),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Plan plan) {
    switch (_selectedOption) {
      case 'planData':
        return PlanDataScreen(
          plan: plan,
          showAppBar: false,
          onOpenSummary: () => setState(() => _selectedOption = 'mySummary'),
          onPlanDeleted: () {
            Navigator.of(context).pop();
          },
        );

      case 'planNotes':
        return PlanNotesScreen(
          plan: plan,
          embedInPlanDetail: true,
        );

      case 'mySummary':
        return MyPlanSummaryScreen(
          plan: plan,
          onOpenEvent: _openEventFromSummary,
          onOpenAccommodation: _openAccommodationFromSummary,
          onGoToCalendar: () => setState(() => _selectedOption = 'calendar'),
          onRequestCreateEvent: () => _openCreateEventDialog(switchToCalendar: false),
          onRequestCreateAccommodation: () => _openCreateAccommodationDialog(switchToCalendar: false),
          showTopSummaryBar: false,
          viewMode: _summaryViewMode,
          onViewModeChanged: (mode) => setState(() => _summaryViewMode = mode),
          draftOnlyFilter: _summaryDraftOnly,
          onDraftOnlyFilterChanged: (value) => setState(() => _summaryDraftOnly = value),
          onDraftFilterVisibilityChanged: (visible) {
            if (_summaryShowDraftFilter != visible) {
              setState(() => _summaryShowDraftFilter = visible);
            }
          },
        );
      
      case 'calendar':
        return _buildCalendarTabContent(plan);
      
      case 'participants':
        return ParticipantsScreen(
          plan: plan,
          embedInScaffold: false,
          showEmbeddedHeader: false,
        );
      
      case 'chat':
        return PlanChatScreen(
          planId: plan.id!,
          planName: plan.name,
          embedInPlanDetail: true,
        );

      case 'planNotifications':
        return WdPlanNotificationsScreen(plan: plan);

      case 'stats':
        return PlanStatsPage(
          plan: plan,
          embedInPlanDetail: true,
        );
      
      case 'payments':
        return PaymentSummaryPage(
          plan: plan,
          embedInPlanDetail: true,
        );
      
      default:
        return PlanDataScreen(
          plan: plan,
          showAppBar: false,
          onOpenSummary: () => setState(() => _selectedOption = 'mySummary'),
          onPlanDeleted: () {
            Navigator.of(context).pop();
          },
        );
    }
  }

  void _openEventFromSummary(Event event) {
    final p = _planFromStreamRead();
    if (p.id == null) return;
    showEventSummaryPreviewModal(
      context: context,
      event: event,
      onOpenFull: () => _showEventDialog(event),
    );
  }

  /// Paridad con `pg_calendar_mobile_page` / `wd_calendar_screen`: `EventDialog` solo construye
  /// el modelo; hay que persistir en Firestore y cerrar el diálogo aquí.
  void _invalidateEventProviders() {
    final p = _planFromStreamRead();
    if (p.id == null) {
      if (mounted) setState(() {});
      return;
    }
    final calendarParams = CalendarNotifierParams(
      planId: p.id!,
      userId: p.userId,
      initialDate: p.startDate,
      initialColumnCount: p.durationInDays,
    );
    ref.read(calendarNotifierProvider(calendarParams).notifier).refreshEvents();
    ref.invalidate(planStatsProvider(p.id!));
    ref.invalidate(planEventsStreamProvider(p.id!));
    if (mounted) setState(() {});
  }

  Future<void> _persistEventFromDialog(Event event) async {
    final eventService = ref.read(eventServiceProvider);
    final p = _planFromStreamRead();
    if (event.id == null) {
      final eventId = await eventService.createEvent(event);
      if (event.isDraft && event.userId != p.userId && p.id != null) {
        // Best-effort: no bloquear cierre de diálogo ni UX en offline.
        Future<void>(() async {
          try {
            await NotificationHelper()
                .notifyEventProposed(
                  organizerUserId: p.userId,
                  planId: p.id!,
                  planName: p.name,
                  eventId: eventId,
                  eventDescription: event.description,
                )
                .timeout(const Duration(seconds: 2));
          } catch (_) {}
        });
      }
    } else {
      await eventService.updateEvent(event);
    }
  }

  void _showEventDialog(Event event) async {
    Event eventToShow = event;
    if (event.id != null) {
      final fresh = await ref.read(eventServiceProvider).getEventByIdFromServer(event.id!);
      if (fresh != null) eventToShow = fresh;
    }
    if (!mounted) return;
    final p = _planFromStreamRead();
    if (p.id == null) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EventDialog(
        event: eventToShow,
        planId: p.id!,
        onSaved: (updatedEvent) async {
          await _persistEventFromDialog(updatedEvent);
          _invalidateEventProviders();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        onDeleted: (eventId) async {
          final eventService = ref.read(eventServiceProvider);
          await eventService.deleteEvent(eventId);
          _invalidateEventProviders();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _openAccommodationFromSummary(Accommodation accommodation) {
    if (_planFromStreamRead().id == null) return;
    showAccommodationSummaryPreviewModal(
      context: context,
      accommodation: accommodation,
      onOpenFull: () => _showAccommodationDialog(accommodation),
    );
  }

  void _showAccommodationDialog(Accommodation accommodation) {
    final p = _planFromStreamRead();
    if (p.id == null) return;
    showDialog<void>(
      context: context,
      builder: (context) => AccommodationDialog(
        accommodation: accommodation,
        planId: p.id!,
        planStartDate: p.startDate,
        planEndDate: p.endDate,
        onSaved: (acc) async {
          final notifier = ref.read(
            accommodationNotifierProvider(AccommodationNotifierParams(planId: p.id!)).notifier,
          );
          final success = await notifier.saveAccommodation(acc);
          _invalidateEventProviders();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al guardar el alojamiento. Por favor, inténtalo de nuevo.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (mounted) setState(() {});
        },
        onDeleted: (accommodationId) async {
          final notifier = ref.read(
            accommodationNotifierProvider(AccommodationNotifierParams(planId: p.id!)).notifier,
          );
          final success = await notifier.deleteAccommodation(accommodationId);
          _invalidateEventProviders();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al eliminar el alojamiento. Por favor, inténtalo de nuevo.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _quickCreateEvent() {
    final stayOnSummary = _selectedOption == 'mySummary';
    _openCreateEventDialog(switchToCalendar: !stayOnSummary);
  }

  void _openCreateEventDialog({required bool switchToCalendar}) {
    final p = _planFromStreamRead();
    if (p.id == null) return;
    if (switchToCalendar) {
      setState(() => _selectedOption = 'calendar');
    }
    final defaults = NewEventFromButtonDefaults.forPlan(p);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => EventDialog(
        planId: p.id!,
        initialDate: defaults.date,
        initialHour: defaults.hour,
        initialStartMinute: defaults.startMinute,
        onSaved: (ev) async {
          await _persistEventFromDialog(ev);
          _invalidateEventProviders();
          if (!mounted) return;
          if (switchToCalendar) {
            setState(() => _selectedOption = 'calendar');
          } else {
            setState(() {});
          }
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  void _quickCreateAccommodation() {
    final stayOnSummary = _selectedOption == 'mySummary';
    _openCreateAccommodationDialog(switchToCalendar: !stayOnSummary);
  }

  void _openCreateAccommodationDialog({required bool switchToCalendar}) {
    final p = _planFromStreamRead();
    if (p.id == null) return;
    if (switchToCalendar) {
      setState(() => _selectedOption = 'calendar');
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AccommodationDialog(
        planId: p.id!,
        planStartDate: p.startDate,
        planEndDate: p.endDate,
        initialCheckIn: p.startDate,
        onSaved: (acc) async {
          final notifier = ref.read(
            accommodationNotifierProvider(AccommodationNotifierParams(planId: p.id!)).notifier,
          );
          await notifier.saveAccommodation(acc);
          _invalidateEventProviders();
          if (!mounted) return;
          if (switchToCalendar) {
            setState(() => _selectedOption = 'calendar');
          } else {
            setState(() {});
          }
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  void _quickOpenChat() {
    setState(() => _selectedOption = 'chat');
  }

  void _quickCreatePayment() {
    final p = _planFromStreamRead();
    if (p.id == null) return;
    setState(() => _selectedOption = 'payments');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => AddExpenseDialog(
          plan: p,
          onSaved: () {
            ref.invalidate(paymentSummaryProvider(p.id!));
            if (!mounted) return;
            setState(() => _selectedOption = 'payments');
          },
        ),
      ),
    );
  }

  void _quickOpenNotifications() {
    setState(() => _selectedOption = 'planNotifications');
  }

  /// Pestaña Calendario: mismo marco visual que [CalendarDemoV1Page] (demo/calendar-v1).
  Widget _buildCalendarTabContent(Plan plan) {
    final totalDays = plan.durationInDays;
    if (totalDays > 0 && _calendarFirstPlanDay > totalDays) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_calendarFirstPlanDay > plan.durationInDays) {
          setState(() {
            _calendarFirstPlanDay =
                Plan.initialVisiblePlanDayIndex(plan, _calendarVisibleDays);
          });
        }
      });
    }
    final startDay = _calendarFirstPlanDay;
    final endDay = startDay + _calendarVisibleDays - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: _buildUnifiedCalendarBar(plan, totalDays, startDay, endDay),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  plan.timezone != null && plan.timezone!.trim().isNotEmpty
                      ? 'Zona horaria del plan: ${plan.timezone}'
                      : 'Zona horaria del plan: no configurada',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: CalendarMobilePage(
                key: ValueKey(
                  'cal-${plan.id}-${plan.startDate.toIso8601String()}-${plan.endDate.toIso8601String()}',
                ),
                plan: plan,
                hideAppBar: true,
                visibleDays: _calendarVisibleDays,
                firstVisiblePlanDayIndex: _calendarFirstPlanDay,
                onVisibleDaysChanged: (days) {
                  setState(() {
                    _calendarVisibleDays = days;
                    if (_calendarFirstPlanDay > totalDays && totalDays > 0) {
                      _calendarFirstPlanDay =
                          Plan.initialVisiblePlanDayIndex(plan, days);
                    }
                  });
                },
                onPreviousDayGroup: () {
                  if (_calendarFirstPlanDay > 1) {
                    setState(() {
                      _calendarFirstPlanDay = math.max(
                        1,
                        _calendarFirstPlanDay - _calendarVisibleDays,
                      );
                    });
                  }
                },
                onNextDayGroup: () {
                  if (totalDays > 0 && endDay < totalDays) {
                    setState(() {
                      final next = _calendarFirstPlanDay + _calendarVisibleDays;
                      _calendarFirstPlanDay = next > totalDays
                          ? math.max(1, totalDays - _calendarVisibleDays + 1)
                          : next;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Barra unificada alineada con la demo V1: tarjeta redondeada + chips 1|2|3.
  Widget _buildUnifiedCalendarBar(Plan plan, int totalDays, int startDay, int endDay) {
    final canPrev = startDay > 1;
    final canNext = totalDays > 0 && endDay < totalDays;
    final displayTotal = math.max(1, totalDays);

    void goNext() {
      if (!canNext) return;
      setState(() {
        final next = _calendarFirstPlanDay + _calendarVisibleDays;
        _calendarFirstPlanDay = next > totalDays
            ? math.max(1, totalDays - _calendarVisibleDays + 1)
            : next;
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _calendarNavCircle(
                  icon: Icons.chevron_left_rounded,
                  enabled: canPrev,
                  onTap: () {
                    if (!canPrev) return;
                    setState(() {
                      _calendarFirstPlanDay = math.max(
                        1,
                        _calendarFirstPlanDay - _calendarVisibleDays,
                      );
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'D$startDay–$endDay/$displayTotal',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                _calendarNavCircle(
                  icon: Icons.chevron_right_rounded,
                  enabled: canNext,
                  onTap: goNext,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final d in [1, 2, 3]) ...[
                  if (d > 1) const SizedBox(width: 6),
                  _buildUnifiedDayChip(plan, d),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarNavCircle({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 22,
            color: enabled ? Colors.white : Colors.white24,
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedDayChip(Plan plan, int days) {
    final selected = _calendarVisibleDays == days;
    return InkWell(
      onTap: () {
        setState(() {
          _calendarVisibleDays = days;
          final t = plan.durationInDays;
          if (t > 0 && _calendarFirstPlanDay > t) {
            _calendarFirstPlanDay =
                Plan.initialVisiblePlanDayIndex(plan, days);
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColorScheme.color2
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColorScheme.color2
                : Colors.white.withValues(alpha: 0.12),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          '$days',
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

