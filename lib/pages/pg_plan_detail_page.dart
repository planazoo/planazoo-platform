import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_navigation_bar.dart';
import 'package:unp_calendario/widgets/plan/plan_summary_button.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_data_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_my_plan_summary_screen.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';
import 'package:unp_calendario/widgets/wd_accommodation_dialog.dart';
import 'package:unp_calendario/widgets/dialogs/summary_preview_modals.dart';
import 'package:unp_calendario/widgets/screens/wd_calendar_screen.dart';
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
import 'package:unp_calendario/widgets/dialogs/payment_dialog.dart';
import 'package:unp_calendario/features/chat/presentation/providers/chat_providers.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';

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
  late String _selectedOption;
  bool _hasSetInitialTabForParticipant = false;
  /// Estado del calendario embebido: días visibles (1/2/3) y grupo actual (barra unificada).
  int _calendarVisibleDays = 1;
  int _calendarDayGroup = 0;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialTab ?? 'planData';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final planId = widget.plan.id;
    final isOrganizer = currentUser?.id == widget.plan.userId;
    // Si no es organizador y está en Estadísticas, redirigir a Info
    if (!isOrganizer && _selectedOption == 'stats') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedOption = 'planData');
      });
    }
    // T252: Si el usuario es participante (no organizador), abrir por defecto en "Mi resumen"
    if (widget.initialTab == null && planId != null && currentUser != null && widget.plan.userId != currentUser.id && !_hasSetInitialTabForParticipant) {
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
        backgroundColor: Colors.grey.shade900,
        appBar: _buildAppBar(),
        bottomNavigationBar: _buildQuickActionsBar(),
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
              // Contenido según la opción seleccionada
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Barra superior: nombre del plan, chip mi estado (dentro/fuera/pend.) y ayuda P18.
  PreferredSizeWidget _buildAppBar() {
    final loc = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: AppColorScheme.color2,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        widget.plan.name,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
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
                  plan: widget.plan,
                  compact: true,
                ),
              ),
              HelpIconButton(
                helpId: HelpContextIds.planDetailMyStatus,
                contextLabel: loc.planMyStatusHelpTitle,
                defaultBody: loc.planMyStatusHelpDefault,
                iconSize: 18,
                iconColor: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsBar() {
    final loc = AppLocalizations.of(context)!;
    final planId = widget.plan.id;
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade900,
              const Color(0xFF171717),
            ],
          ),
          border: Border(
            top: BorderSide(color: Colors.grey.shade700.withOpacity(0.4), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionButton(
              icon: Icons.add_circle_outline,
              onTap: _quickCreateEvent,
              tooltip: 'Crear evento',
              isActive: _selectedOption == 'calendar',
            ),
            _buildQuickActionButton(
              icon: Icons.hotel_outlined,
              onTap: _quickCreateAccommodation,
              tooltip: 'Crear alojamiento',
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
              icon: Icons.payment_outlined,
              onTap: _quickCreatePayment,
              tooltip: loc.paymentsRegisterPayment,
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
    final iconColor = isActive ? Colors.white : AppColorScheme.color2;
    final bg = isActive ? AppColorScheme.color2 : Colors.transparent;
    final borderColor = isActive ? AppColorScheme.color2 : Colors.grey.shade700.withOpacity(0.7);

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
                      color: AppColorScheme.color2.withOpacity(0.35),
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
                      border: Border.all(color: Colors.black.withOpacity(0.2), width: 0.5),
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

  Widget _buildContent() {
    switch (_selectedOption) {
      case 'planData':
        return PlanDataScreen(
          plan: widget.plan,
          showAppBar: false,
          onOpenSummary: () => setState(() => _selectedOption = 'mySummary'),
          onPlanDeleted: () {
            Navigator.of(context).pop();
          },
        );

      case 'mySummary':
        return MyPlanSummaryScreen(
          plan: widget.plan,
          onOpenEvent: _openEventFromSummary,
          onOpenAccommodation: _openAccommodationFromSummary,
          onGoToCalendar: () => setState(() => _selectedOption = 'calendar'),
        );
      
      case 'calendar':
        return _buildCalendarTabContent();
      
      case 'participants':
        return ParticipantsScreen(
          plan: widget.plan,
          embedInScaffold: false,
        );
      
      case 'chat':
        return PlanChatScreen(
          planId: widget.plan.id!,
          planName: widget.plan.name,
          embedInPlanDetail: true,
        );

      case 'planNotifications':
        return WdPlanNotificationsScreen(plan: widget.plan);

      case 'stats':
        return PlanStatsPage(
          plan: widget.plan,
          embedInPlanDetail: true,
        );
      
      case 'payments':
        return PaymentSummaryPage(
          plan: widget.plan,
          embedInPlanDetail: true,
        );
      
      default:
        return PlanDataScreen(
          plan: widget.plan,
          showAppBar: false,
          onOpenSummary: () => setState(() => _selectedOption = 'mySummary'),
          onPlanDeleted: () {
            Navigator.of(context).pop();
          },
        );
    }
  }

  void _openEventFromSummary(Event event) {
    if (widget.plan.id == null) return;
    showEventSummaryPreviewModal(
      context: context,
      event: event,
      onOpenFull: () => _showEventDialog(event),
    );
  }

  void _showEventDialog(Event event) async {
    Event eventToShow = event;
    if (event.id != null) {
      final fresh = await ref.read(eventServiceProvider).getEventByIdFromServer(event.id!);
      if (fresh != null) eventToShow = fresh;
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => EventDialog(
        event: eventToShow,
        planId: widget.plan.id!,
        onSaved: (_) => setState(() {}),
        onDeleted: (_) => setState(() {}),
      ),
    );
  }

  void _openAccommodationFromSummary(Accommodation accommodation) {
    if (widget.plan.id == null) return;
    showAccommodationSummaryPreviewModal(
      context: context,
      accommodation: accommodation,
      onOpenFull: () => _showAccommodationDialog(accommodation),
    );
  }

  void _showAccommodationDialog(Accommodation accommodation) {
    final planEnd = widget.plan.startDate.add(Duration(days: widget.plan.durationInDays));
    showDialog<void>(
      context: context,
      builder: (context) => AccommodationDialog(
        accommodation: accommodation,
        planId: widget.plan.id!,
        planStartDate: widget.plan.startDate,
        planEndDate: planEnd,
        onSaved: (_) => setState(() {}),
        onDeleted: (_) => setState(() {}),
      ),
    );
  }

  void _quickCreateEvent() {
    if (widget.plan.id == null) return;
    setState(() => _selectedOption = 'calendar');
    showDialog<void>(
      context: context,
      builder: (context) => EventDialog(
        planId: widget.plan.id!,
        initialDate: widget.plan.startDate,
        onSaved: (_) {
          if (!mounted) return;
          setState(() => _selectedOption = 'calendar');
        },
      ),
    );
  }

  void _quickCreateAccommodation() {
    if (widget.plan.id == null) return;
    final planEnd = widget.plan.startDate.add(Duration(days: widget.plan.durationInDays));
    setState(() => _selectedOption = 'calendar');
    showDialog<void>(
      context: context,
      builder: (context) => AccommodationDialog(
        planId: widget.plan.id!,
        planStartDate: widget.plan.startDate,
        planEndDate: planEnd,
        initialCheckIn: widget.plan.startDate,
        onSaved: (_) {
          if (!mounted) return;
          setState(() => _selectedOption = 'calendar');
        },
      ),
    );
  }

  void _quickOpenChat() {
    setState(() => _selectedOption = 'chat');
  }

  void _quickCreatePayment() {
    if (widget.plan.id == null) return;
    setState(() => _selectedOption = 'payments');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => PaymentDialog(
          planId: widget.plan.id!,
          plan: widget.plan,
          onSaved: () {
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

  /// Pestaña Calendario con barra unificada (rango días + 1/2/3).
  Widget _buildCalendarTabContent() {
    final totalDays = widget.plan.durationInDays;
    final startDay = _calendarDayGroup * _calendarVisibleDays + 1;
    final endDay = startDay + _calendarVisibleDays - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildUnifiedCalendarBar(totalDays, startDay, endDay),
        Expanded(
          child: CalendarMobilePage(
            plan: widget.plan,
            hideAppBar: true,
            visibleDays: _calendarVisibleDays,
            currentDayGroup: _calendarDayGroup,
            onVisibleDaysChanged: (days) {
              setState(() {
                _calendarVisibleDays = days;
                final currentStart =
                    _calendarDayGroup * _calendarVisibleDays + 1;
                if (currentStart > totalDays) {
                  _calendarDayGroup = 0;
                }
              });
            },
            onPreviousDayGroup: () {
              if (_calendarDayGroup > 0) {
                setState(() => _calendarDayGroup--);
              }
            },
            onNextDayGroup: () {
              if (endDay < totalDays) {
                setState(() => _calendarDayGroup++);
              }
            },
          ),
        ),
      ],
    );
  }

  /// Barra única: rango D1-3/7 + botones 1/2/3 días.
  Widget _buildUnifiedCalendarBar(int totalDays, int startDay, int endDay) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade700.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Centro: < D1-3/7 >
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: _calendarDayGroup > 0
                      ? () => setState(() => _calendarDayGroup--)
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                Expanded(
                  child: Text(
                    'D$startDay-$endDay/$totalDays',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: endDay < totalDays
                      ? () => setState(() => _calendarDayGroup++)
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Derecha: 1 | 2 | 3 días
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildUnifiedDayChip(1),
                const SizedBox(width: 4),
                _buildUnifiedDayChip(2),
                const SizedBox(width: 4),
                _buildUnifiedDayChip(3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedDayChip(int days) {
    final isSelected = _calendarVisibleDays == days;
    return GestureDetector(
      onTap: () {
        setState(() {
          _calendarVisibleDays = days;
          final currentStart = _calendarDayGroup * days + 1;
          if (currentStart > widget.plan.durationInDays) {
            _calendarDayGroup = 0;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColorScheme.color2 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '$days',
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey.shade400,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

