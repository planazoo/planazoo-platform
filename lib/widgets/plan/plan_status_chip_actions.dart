import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';

/// Diálogo aceptar/rechazar desde chip pending (card, lista iOS, header).
Future<void> planStatusChipShowPendingActions(
  BuildContext context,
  WidgetRef ref, {
  required String planId,
  required String userId,
  required bool hasPendingInvitation,
  required bool hasPendingParticipation,
}) async {
  final loc = AppLocalizations.of(context)!;
  final choice = await showDialog<String>(
    context: context,
    builder: (ctx) => Theme(
      data: AppTheme.darkTheme,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text(
          loc.statusInvitationPending,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          loc.planCardChipInvitationQuestion,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.cancel, style: GoogleFonts.poppins(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('reject'),
            child: Text(loc.reject, style: GoogleFonts.poppins(color: Colors.orange.shade300)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('accept'),
            child: Text(loc.accept, style: GoogleFonts.poppins(color: Colors.green.shade300)),
          ),
        ],
      ),
    ),
  );
  if (choice != 'accept' && choice != 'reject') return;

  final invSvc = ref.read(invitationServiceProvider);
  final partSvc = ref.read(planParticipationServiceProvider);

  try {
    if (choice == 'accept') {
      var ok = false;
      if (hasPendingInvitation) {
        ok = await invSvc.acceptInvitationByPlanId(planId, userId);
      }
      if (!ok && hasPendingParticipation) {
        ok = await partSvc.acceptInvitation(planId, userId);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? loc.invitationAcceptedAddedToPlan : loc.invitationAcceptFailed,
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    } else {
      var ok = false;
      if (hasPendingInvitation) {
        ok = await invSvc.rejectInvitationByPlanId(planId, userId);
      }
      if (!ok && hasPendingParticipation) {
        ok = await partSvc.rejectInvitation(planId, userId);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? loc.invitationRejectedSuccess : loc.invitationRejectFailed,
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  } catch (e) {
    LoggerService.error('Plan status chip pending', context: 'plan_status_chip_actions', error: e);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.invitationRejectFailed} $e', style: GoogleFonts.poppins())),
      );
    }
  }

  ref.invalidate(userPendingInvitationsProvider);
  ref.invalidate(planParticipantsProvider(planId));
  try {
    ref.read(planParticipationNotifierProvider(planId).notifier).reload();
  } catch (_) {}
}

/// Diálogo salir del plan desde chip in (participante).
Future<void> planStatusChipShowLeavePlan(
  BuildContext context,
  WidgetRef ref, {
  required Plan plan,
  required String userId,
}) async {
  final loc = AppLocalizations.of(context)!;
  final planId = plan.id;
  if (planId == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => Theme(
      data: AppTheme.darkTheme,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text(
          loc.planCardLeavePlanTitle,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          loc.planCardLeavePlanConfirmBody(plan.name),
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.cancel, style: GoogleFonts.poppins(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.planCardLeavePlanButton, style: GoogleFonts.poppins(color: Colors.orange.shade300)),
          ),
        ],
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    final partSvc = ref.read(planParticipationServiceProvider);
    final success = await partSvc.removeParticipation(planId, userId);
    if (!context.mounted) return;
    if (success) {
      ref.invalidate(plansStreamProvider);
      ref.invalidate(userPendingInvitationsProvider);
      ref.invalidate(planParticipantsProvider(planId));
      try {
        ref.read(planParticipationNotifierProvider(planId).notifier).reload();
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.planCardLeftPlanSuccess, style: GoogleFonts.poppins())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.planCardLeftPlanError, style: GoogleFonts.poppins())),
      );
    }
  } catch (e) {
    LoggerService.error('Plan status chip leave', context: 'plan_status_chip_actions', error: e);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.planCardLeftPlanError}: $e', style: GoogleFonts.poppins())),
      );
    }
  }
}
