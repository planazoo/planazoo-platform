import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/widgets/dialogs/invitation_response_dialog.dart';

/// Evita mostrar el modal más de una vez por sesión de proceso (diagrama §1.1 decisión 2).
bool _pendingInviteModalShownThisSession = false;

/// Si el usuario tiene una participación/invitación pending accionable, abre el modal
/// aceptar/rechazar (una vez por sesión de app).
Future<void> maybeShowPendingInvitationModalOnLaunch(
  BuildContext context,
  WidgetRef ref,
) async {
  if (_pendingInviteModalShownThisSession) return;
  if (!context.mounted) return;

  final user = ref.read(currentUserProvider);
  if (user == null) return;

  try {
    final partSvc = ref.read(planParticipationServiceProvider);
    final invSvc = ref.read(invitationServiceProvider);
    final participations = await partSvc.getUserParticipations(user.id).first;
    final pendingParts =
        participations.where((p) => p.isActive && p.isPending).toList();

    String? planId;
    if (pendingParts.isNotEmpty) {
      planId = pendingParts.first.planId;
    } else {
      final invites = await invSvc.getPendingInvitationsByUserId(
        user.id,
        user.email,
      );
      if (invites.isNotEmpty) {
        planId = invites.first.planId;
      }
    }
    if (planId == null || planId.isEmpty) return;

    final check = await invSvc.evaluateInvitationActionability(
      planId: planId,
      userId: user.id,
    );
    if (!check.actionable) return;

    final plan = await PlanService().getPlanById(planId);
    if (plan == null || !context.mounted) return;

    _pendingInviteModalShownThisSession = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => InvitationResponseDialog(plan: plan),
    );
  } catch (e, st) {
    LoggerService.error(
      'maybeShowPendingInvitationModalOnLaunch',
      context: 'PENDING_INVITE_MODAL',
      error: e,
      stackTrace: st,
    );
  }
}

/// Solo tests / hot-restart controlado.
@visibleForTesting
void resetPendingInvitationModalSessionFlag() {
  _pendingInviteModalShownThisSession = false;
}
