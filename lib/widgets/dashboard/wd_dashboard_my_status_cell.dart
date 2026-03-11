import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_user_status_label.dart';

/// W10 (C15, R1): celda "Mi estado" en el header del dashboard.
/// Muestra in (verde) | out (rojo) | pending (naranja), mismo criterio que cards e iOS.
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

  /// Columna C15 en grid 0-based = 14
  static const int _w10Column = 14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);

    if (selectedPlan == null || selectedPlan!.id == null || currentUser == null) {
      return Positioned(
        left: columnWidth * _w10Column - 1,
        top: 0,
        child: _buildCell(
          context,
          rowHeight: rowHeight,
          label: loc.myStatusLabel,
          bgColor: Colors.grey.shade800,
          borderColor: Colors.grey.shade600,
          textColor: Colors.white54,
        ),
      );
    }

    final plan = selectedPlan!;

    final pendingInvitations = ref.watch(userPendingInvitationsProvider);
    final hasPendingInvitation = pendingInvitations.maybeWhen(
      data: (list) => list.any((inv) => inv.planId == plan.id),
      orElse: () => false,
    );

    final participantsAsync = ref.watch(planParticipantsProvider(plan.id!));
    final hasPendingParticipation = participantsAsync.maybeWhen(
      data: (participants) => participants.any((p) =>
          p.userId == currentUser.id && (p.isPending || p.needsResponse)),
      orElse: () => false,
    );
    final hasRejectedParticipation = participantsAsync.maybeWhen(
      data: (participants) => participants.any((p) => p.userId == currentUser.id && p.isRejected),
      orElse: () => false,
    );

    // in (verde) | out (rojo) | pending (naranja)
    String label;
    Color bgColor;
    Color borderColor;
    Color textColor;
    if (hasPendingInvitation || hasPendingParticipation) {
      label = loc.statusShortPending;
      bgColor = PlanUserStatusColors.pendingBg;
      borderColor = PlanUserStatusColors.pendingBorder;
      textColor = PlanUserStatusColors.pendingText;
    } else if (hasRejectedParticipation) {
      label = loc.statusShortOut;
      bgColor = PlanUserStatusColors.outBg;
      borderColor = PlanUserStatusColors.outBorder;
      textColor = PlanUserStatusColors.outText;
    } else {
      label = loc.statusShortIn;
      bgColor = PlanUserStatusColors.inBg;
      borderColor = PlanUserStatusColors.inBorder;
      textColor = PlanUserStatusColors.inText;
    }

    return Positioned(
      left: columnWidth * _w10Column - 1,
      top: 0,
      child: _buildCell(
        context,
        rowHeight: rowHeight,
        label: label,
        bgColor: bgColor,
        borderColor: borderColor,
        textColor: textColor,
      ),
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required double rowHeight,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
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
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
