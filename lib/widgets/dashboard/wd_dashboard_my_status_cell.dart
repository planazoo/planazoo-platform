import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_user_status_label.dart';

/// W10 (C15, R1): celda "Mi estado" en el header del dashboard.
/// Muestra in (verde) | out (rojo) | pending (naranja); mismo widget y gestos que AppBar del plan móvil.
class WdDashboardMyStatusCell extends ConsumerWidget {
  final double columnWidth;
  final double rowHeight;
  final Plan? selectedPlan;

  const WdDashboardMyStatusCell({
    super.key,
    required this.columnWidth,
    required this.rowHeight,
    this.selectedPlan,
  });

  static const int _w10Column = 14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);

    if (selectedPlan == null || selectedPlan!.id == null || currentUser == null) {
      return Positioned(
        left: columnWidth * _w10Column - 1,
        top: 0,
        child: _buildEmptyCell(context, loc),
      );
    }

    final plan = selectedPlan!;

    return Positioned(
      left: columnWidth * _w10Column - 1,
      top: 0,
      child: Material(
        color: Colors.grey.shade900,
        child: SizedBox(
          width: columnWidth + 1,
          height: rowHeight,
          child: Center(
            child: PlanUserStatusLabel(
              plan: plan,
              compact: true,
              enableChipActions: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCell(BuildContext context, AppLocalizations loc) {
    return Container(
      width: columnWidth + 1,
      height: rowHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade600, width: 1),
        ),
        child: Text(
          loc.myStatusLabel,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
