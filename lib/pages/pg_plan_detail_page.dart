import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_navigation_bar.dart';
import 'package:unp_calendario/widgets/plan/plan_summary_button.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_data_screen.dart';
import 'package:unp_calendario/widgets/screens/wd_calendar_screen.dart';
import 'package:unp_calendario/pages/pg_calendar_mobile_page.dart';
import 'package:unp_calendario/pages/pg_plan_participants_page.dart';
import 'package:unp_calendario/features/stats/presentation/pages/plan_stats_page.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_chat_screen.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';

/// Página de detalle del plan para mobile
/// Incluye barra de navegación horizontal y contenido según la opción seleccionada
class PlanDetailPage extends ConsumerStatefulWidget {
  final Plan plan;

  const PlanDetailPage({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage> {
  String _selectedOption = 'planData'; // Opción por defecto

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Barra de navegación horizontal
            PlanNavigationBar(
              selectedOption: _selectedOption,
              onOptionSelected: (option) {
                setState(() {
                  _selectedOption = option;
                });
              },
            ),
            // Contenido según la opción seleccionada
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey.shade900,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
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
        if (widget.plan.id != null)
          PlanSummaryButton(
            plan: widget.plan,
            iconOnly: false,
            foregroundColor: Colors.white,
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
          onPlanDeleted: () {
            Navigator.of(context).pop();
          },
        );
      
      case 'calendar':
        return CalendarMobilePage(
          plan: widget.plan,
        );
      
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
        // TODO: Implementar página de pagos (Tarea futura - Sistema de pagos)
        // Ver: docs/tareas/TASKS.md para más detalles sobre funcionalidades pendientes
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment,
                size: 64,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Pagos',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Próximamente',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      
      default:
        return PlanDataScreen(
          plan: widget.plan,
          showAppBar: false,
        );
    }
  }
}

