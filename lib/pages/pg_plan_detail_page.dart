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
import 'package:unp_calendario/widgets/screens/wd_calendar_screen.dart';
import 'package:unp_calendario/pages/pg_calendar_mobile_page.dart';
import 'package:unp_calendario/pages/pg_plan_participants_page.dart';
import 'package:unp_calendario/features/stats/presentation/pages/plan_stats_page.dart';
import 'package:unp_calendario/features/payments/presentation/pages/payment_summary_page.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_chat_screen.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan_state_badge.dart';
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
  /// T252: Dentro de la pestaña Calendario, modo 'calendar' (rejilla) o 'summary' (mi itinerario).
  String _calendarViewMode = 'calendar';

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
        // Estado del plan a la derecha solo cuando se está en la página Info del plan
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
        return MyPlanSummaryScreen(plan: widget.plan);
      
      case 'calendar':
        return _buildCalendarTabContent();
      
      case 'participants':
        return PlanParticipantsPage(
          plan: widget.plan,
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

  /// T252: Pestaña Calendario con selector "Ver como calendario" / "Ver mi resumen".
  Widget _buildCalendarTabContent() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _CalendarSegmentButton(
                  label: loc.calendarViewModeCalendar,
                  isSelected: _calendarViewMode == 'calendar',
                  onTap: () => setState(() => _calendarViewMode = 'calendar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CalendarSegmentButton(
                  label: loc.myPlanSummaryTab,
                  isSelected: _calendarViewMode == 'summary',
                  onTap: () => setState(() => _calendarViewMode = 'summary'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _calendarViewMode == 'calendar'
              ? CalendarMobilePage(plan: widget.plan)
              : MyPlanSummaryScreen(plan: widget.plan),
        ),
      ],
    );
  }
}

/// Botón de segmento para Calendario / Mi resumen (T252).
class _CalendarSegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarSegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColorScheme.color2 : Colors.grey.shade800,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

