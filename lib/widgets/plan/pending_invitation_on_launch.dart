import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/widgets/dialogs/invitation_response_dialog.dart';
import 'package:unp_calendario/widgets/notifications/wd_notification_list_dialog.dart';

/// Evita mostrar el modal/campana más de una vez por sesión de proceso (diagrama §1.1 decisión 2).
bool _pendingInviteModalShownThisSession = false;

/// Si el usuario tiene invitaciones pendientes accionables:
/// - **1** → modal aceptar/rechazar
/// - **varias** → campana en filtro «Mis invitaciones» (T269 / §1.3)
/// Una vez por sesión de app.
Future<void> maybeShowPendingInvitationModalOnLaunch(
  BuildContext context,
  WidgetRef ref,
) async {
  if (_pendingInviteModalShownThisSession) return;
  if (!context.mounted) return;

  // En móvil Firestore puede emitir vacío en el primer frame; dar margen.
  await Future<void>.delayed(const Duration(milliseconds: 600));
  if (!context.mounted) return;

  var user = ref.read(currentUserProvider);
  if (user == null) {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) return;
    user = ref.read(currentUserProvider);
  }
  if (user == null) return;

  try {
    var planIds = await _collectActionablePendingPlanIds(ref, user.id, user.email);
    if (planIds.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!context.mounted) return;
      planIds = await _collectActionablePendingPlanIds(ref, user.id, user.email);
    }
    if (planIds.isEmpty || !context.mounted) return;

    // Marcar solo tras confirmar que vamos a presentar UI.
    if (planIds.length == 1) {
      final plan = await PlanService().getPlanById(planIds.first);
      if (plan == null || !context.mounted) return;
      _pendingInviteModalShownThisSession = true;
      LoggerService.info(
        'Pending invite launch: 1 plan → modal (${plan.id})',
        context: 'PENDING_INVITE_MODAL',
      );
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (dialogContext) => InvitationResponseDialog(plan: plan),
      );
      return;
    }

    // Varias: abrir campana en «Mis invitaciones» (no modal).
    _pendingInviteModalShownThisSession = true;
    LoggerService.info(
      'Pending invite launch: ${planIds.length} plans → campana Mis invitaciones',
      context: 'PENDING_INVITE_MODAL',
    );
    ref.read(globalNotificationsFilterProvider.notifier).state = 3;
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => const NotificationListDialog(),
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

Future<List<String>> _collectActionablePendingPlanIds(
  WidgetRef ref,
  String userId,
  String? email,
) async {
  final partSvc = ref.read(planParticipationServiceProvider);
  final invSvc = ref.read(invitationServiceProvider);
  final ids = <String>{};

  try {
    final participations = await partSvc.getUserParticipations(userId).first
        .timeout(const Duration(seconds: 8), onTimeout: () => []);
    for (final p in participations.where((p) => p.isActive && p.isPending)) {
      final check = await invSvc.evaluateInvitationActionability(
        planId: p.planId,
        userId: userId,
        cleanupIfInvalid: true,
      );
      if (check.actionable) ids.add(p.planId);
    }
  } catch (e, st) {
    LoggerService.error(
      'collect pending participations',
      context: 'PENDING_INVITE_MODAL',
      error: e,
      stackTrace: st,
    );
  }

  // También invitaciones por email / userId (no solo participaciones).
  try {
    final invites = await invSvc.getPendingInvitationsByUserId(userId, email);
    for (final inv in invites) {
      final planId = inv.planId;
      if (planId.isEmpty || ids.contains(planId)) continue;
      final check = await invSvc.evaluateInvitationActionability(
        planId: planId,
        userId: userId,
        cleanupIfInvalid: true,
      );
      if (check.actionable) ids.add(planId);
    }
  } catch (e, st) {
    LoggerService.error(
      'collect pending invitations',
      context: 'PENDING_INVITE_MODAL',
      error: e,
      stackTrace: st,
    );
  }

  if (kDebugMode) {
    LoggerService.info(
      'Actionable pending planIds=${ids.length}: $ids',
      context: 'PENDING_INVITE_MODAL',
    );
  }

  return ids.toList();
}

/// Solo tests / hot-restart controlado.
@visibleForTesting
void resetPendingInvitationModalSessionFlag() {
  _pendingInviteModalShownThisSession = false;
}
