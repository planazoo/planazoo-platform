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
import 'package:unp_calendario/features/calendar/presentation/widgets/plan_state_badge.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_user_status_label.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

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

  /// Barra superior: solo nombre del plan. Estado del plan a la derecha solo en pestaña Info.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColorScheme.color2,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
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
        // Mi estado en el plan (¿he aceptado participar?) — visible en todas las pestañas
        Center(
          child: PlanUserStatusLabel(
            plan: widget.plan,
            compact: true,
          ),
        ),
        // Estado del plan (borrador/confirmado) solo en pestaña Info
        if (_selectedOption == 'planData')
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
            child: Center(
              child: PlanStateBadgeCompact(
                plan: widget.plan,
                fontSize: 10,
                onColoredBackground: true,
              ),
            ),
          ),
      ],
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
        );
      
      case 'stats':
        return PlanStatsPage(
          plan: widget.plan,
        );
      
      case 'payments':
        return PaymentSummaryPage(plan: widget.plan);
      
      default:
        return PlanDataScreen(
          plan: widget.plan,
          showAppBar: false,
          onOpenSummary: () => setState(() => _selectedOption = 'mySummary'),
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

