import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/plan/plan_status_chip_actions.dart';

/// Estado de aceptación: pendiente, rechazado o aceptado (in).
enum _AcceptanceState { pending, rejected, accepted }

/// Muestra el estado de aceptación del usuario en el plan: Aceptado | Pendiente de aceptar | Invitación pendiente | Rechazado.
/// En modo [compact] (iOS AppBar): etiquetas cortas l10n (p. ej. ES: dentro / fuera / pend.).
///
/// Con [enableChipActions] (por defecto true): al pulsar pending/in se abren los mismos diálogos que en la card del plan.
class PlanUserStatusLabel extends ConsumerWidget {
  final Plan plan;
  /// Si true, etiquetas cortas para iOS: in / out / pending.
  final bool compact;
  /// Tap → aceptar/rechazar (pending) o salir del plan (in, participante).
  final bool enableChipActions;

  const PlanUserStatusLabel({
    super.key,
    required this.plan,
    this.compact = false,
    this.enableChipActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);

    if (plan.id == null || currentUser == null) {
      return _buildLabel(context, loc.myStatusLabel, state: _AcceptanceState.accepted);
    }

    final pendingInvitations = ref.watch(userPendingInvitationsProvider);
    final hasPendingInvitation = pendingInvitations.maybeWhen(
      data: (list) => list.any((inv) => inv.planId == plan.id),
      orElse: () => false,
    );

    final participantsAsync = ref.watch(planParticipantsProvider(plan.id!));
    final hasPendingParticipation = participantsAsync.maybeWhen(
      data: (participants) => participants.any((p) =>
          p.userId == currentUser.id && p.isPending),
      orElse: () => false,
    );
    final hasRejectedParticipation = participantsAsync.maybeWhen(
      data: (participants) => participants.any((p) =>
          p.userId == currentUser.id && p.isRejected),
      orElse: () => false,
    );

    String label;
    _AcceptanceState state;
    if (hasPendingInvitation || hasPendingParticipation) {
      label = compact ? '?' : (hasPendingInvitation ? loc.statusInvitationPending : loc.statusPendingToAccept);
      state = _AcceptanceState.pending;
    } else if (hasRejectedParticipation) {
      label = compact ? 'out' : loc.statusRejected;
      state = _AcceptanceState.rejected;
    } else {
      label = compact ? 'in' : loc.statusAccepted;
      state = _AcceptanceState.accepted;
    }

    Widget w = _buildLabel(context, label, state: state);
    final semanticsLabel = switch (state) {
      _AcceptanceState.pending => loc.planStatusSemanticsPending,
      _AcceptanceState.rejected => loc.planStatusSemanticsOut,
      _AcceptanceState.accepted => loc.planStatusSemanticsIn,
    };
    w = Semantics(
      label: semanticsLabel,
      button: enableChipActions,
      child: w,
    );

    if (!enableChipActions) return w;

    final pid = plan.id!;
    final uid = currentUser.id;

    if (state == _AcceptanceState.pending) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => planStatusChipShowPendingActions(
            context,
            ref,
            planId: pid,
            userId: uid,
            hasPendingInvitation: hasPendingInvitation,
            hasPendingParticipation: hasPendingParticipation,
          ),
          borderRadius: BorderRadius.circular(8),
          child: w,
        ),
      );
    }
    if (state == _AcceptanceState.accepted) {
      if (plan.userId == uid) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.planCardOrganizerChipMessage)),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: w,
          ),
        );
      }
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => planStatusChipShowLeavePlan(context, ref, plan: plan, userId: uid),
          borderRadius: BorderRadius.circular(8),
          child: w,
        ),
      );
    }
    if (state == _AcceptanceState.rejected) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.planStatusRejectedSnackbar, style: GoogleFonts.poppins(color: Colors.white)),
                backgroundColor: Colors.grey.shade800,
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: w,
        ),
      );
    }
    return w;
  }

  Widget _buildLabel(BuildContext context, String label, {required _AcceptanceState state}) {
    final isPending = state == _AcceptanceState.pending;
    final isRejected = state == _AcceptanceState.rejected;

    if (compact) {
      Color bgColor;
      Color borderColor;
      Color textColor;
      if (isPending) {
        bgColor = Colors.orange.shade400.withOpacity(0.25);
        borderColor = Colors.orange.shade400;
        textColor = Colors.orange.shade100;
      } else if (isRejected) {
        bgColor = Colors.red.shade400.withOpacity(0.25);
        borderColor = Colors.red.shade400;
        textColor = Colors.red.shade100;
      } else {
        bgColor = AppColorScheme.color2.withOpacity(0.3);
        borderColor = AppColorScheme.color2;
        textColor = Colors.white;
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isPending
              ? Colors.orange.shade200
              : isRejected
                  ? Colors.red.shade300
                  : AppColorScheme.color2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Colores del estado in/out/pending para reutilizar en cards y chips.
class PlanUserStatusColors {
  static Color get inBg => AppColorScheme.color2.withOpacity(0.3);
  static Color get inBorder => AppColorScheme.color2;
  static Color get inText => Colors.white;

  static Color get outBg => Colors.red.shade400.withOpacity(0.25);
  static Color get outBorder => Colors.red.shade400;
  static Color get outText => Colors.red.shade100;

  static Color get pendingBg => Colors.orange.shade400.withOpacity(0.25);
  static Color get pendingBorder => Colors.orange.shade400;
  static Color get pendingText => Colors.orange.shade100;
}
