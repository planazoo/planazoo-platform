import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/color_scheme.dart';
import '../../features/calendar/domain/models/plan_invitation.dart';
import '../../features/calendar/domain/models/pending_email_event.dart';
import '../../features/calendar/domain/services/plan_service.dart';
import '../../features/calendar/presentation/providers/calendar_providers.dart';
import '../../features/notifications/domain/models/unified_notification.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../../features/calendar/presentation/providers/invitation_providers.dart';
import '../../features/calendar/presentation/providers/plan_participation_providers.dart';
import '../../widgets/screens/wd_pending_event_card.dart';
import '../../widgets/dialogs/invitation_response_dialog.dart';
import '../../shared/utils/date_formatter.dart';
import '../../l10n/app_localizations.dart';

/// Fila/card reutilizable para una UnifiedNotification (lista global o W20).
class UnifiedNotificationItem extends ConsumerWidget {
  final UnifiedNotification notification;
  final String? userId;
  final String? authUid;
  final VoidCallback? onInvitationResponded;
  final VoidCallback? onPendingEventAction;

  const UnifiedNotificationItem({
    super.key,
    required this.notification,
    this.userId,
    this.authUid,
    this.onInvitationResponded,
    this.onPendingEventAction,
  });

  Future<void> _openInvitationDialog(BuildContext context, WidgetRef ref) async {
    final planId = notification.planId;
    if (planId == null || planId.isEmpty) return;
    final plan = await PlanService().getPlanById(planId);
    if (!context.mounted || plan == null) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => InvitationResponseDialog(plan: plan),
    );
    if (userId != null &&
        notification.source == UnifiedNotificationSource.usersNotifications) {
      final id = notification.data?['notificationId'] as String?;
      if (id != null) {
        await ref.read(notificationServiceProvider).markAsRead(userId!, id);
      }
    }
    onInvitationResponded?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notification.type == UnifiedNotificationType.invitation) {
      if (notification.sourcePayload is PlanInvitation && userId != null) {
        final inv = notification.sourcePayload as PlanInvitation;
        return InvitationNotificationTile(
          invitation: inv,
          userId: userId!,
          onResponded: onInvitationResponded ?? () {},
          onOpenDialog: () => _openInvitationDialog(context, ref),
        );
      }
      // Invitación directa (NotificationModel): abrir modal al tocar.
      return InformativeNotificationTile(
        notification: notification,
        userId: userId,
        onMarkRead: null,
        onTap: () => _openInvitationDialog(context, ref),
      );
    }
    if (notification.type == UnifiedNotificationType.emailEvent &&
        notification.sourcePayload is PendingEmailEvent &&
        authUid != null) {
      final pending = notification.sourcePayload as PendingEmailEvent;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: WdPendingEventCard(
          pending: pending,
          userId: authUid!,
          onAssign: () => PendingEmailEventActions.showAssignDialog(context, ref, pending, authUid!),
          onDiscard: () => PendingEmailEventActions.discard(context, ref, pending, authUid!),
          compact: true,
        ),
      );
    }
    return InformativeNotificationTile(
      notification: notification,
      userId: userId,
      onMarkRead: userId != null && notification.source == UnifiedNotificationSource.usersNotifications
          ? () async {
              final id = notification.data?['notificationId'] as String?;
              if (id != null) {
                await ref.read(notificationServiceProvider).markAsRead(userId!, id);
              }
            }
          : null,
    );
  }
}

class InvitationNotificationTile extends ConsumerStatefulWidget {
  final PlanInvitation invitation;
  final String userId;
  final VoidCallback onResponded;
  final VoidCallback? onOpenDialog;

  const InvitationNotificationTile({
    super.key,
    required this.invitation,
    required this.userId,
    required this.onResponded,
    this.onOpenDialog,
  });

  @override
  ConsumerState<InvitationNotificationTile> createState() =>
      _InvitationNotificationTileState();
}

class _InvitationNotificationTileState extends ConsumerState<InvitationNotificationTile> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final invitation = widget.invitation;
    final userId = widget.userId;
    final loc = AppLocalizations.of(context)!;
    final planAsync = ref.watch(planByIdStreamProvider(invitation.planId));
    final planLabel = planAsync.when(
      data: (plan) => loc.invitationPlanLabel(plan?.name ?? invitation.planId),
      loading: () => loc.invitationPlanLabel('…'),
      error: (_, __) => loc.invitationPlanLabel(invitation.planId),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _busy ? null : widget.onOpenDialog,
        borderRadius: BorderRadius.circular(6),
        child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade900.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            planLabel,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (invitation.role != null)
            Text(
              loc.invitationRoleLabel(invitation.role!),
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        try {
                          final result = await ref
                              .read(invitationServiceProvider)
                              .rejectInvitationByPlanId(invitation.planId, userId);
                          if (context.mounted) {
                            if (result.success) {
                              ref.invalidate(userPendingInvitationsProvider);
                              ref.invalidate(planParticipantsProvider(invitation.planId));
                              ref.invalidate(plansStreamProvider);
                              ref.invalidate(globalNotificationsListProvider);
                              ref.invalidate(globalUnreadCountProvider);
                              try {
                                ref
                                    .read(planParticipationNotifierProvider(invitation.planId).notifier)
                                    .reload();
                              } catch (_) {}
                              widget.onResponded();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.success ? loc.invitationRejected : result.message),
                                backgroundColor: result.success ? AppColorScheme.color4 : Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                icon: const Icon(Icons.close, size: 14),
                label: Text(loc.reject, style: GoogleFonts.poppins(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColorScheme.color4,
                  side: const BorderSide(color: AppColorScheme.color4, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        try {
                          final result = await ref
                              .read(invitationServiceProvider)
                              .acceptInvitationByPlanId(invitation.planId, userId);
                          if (context.mounted) {
                            if (result.success) {
                              ref.invalidate(userPendingInvitationsProvider);
                              ref.invalidate(planParticipantsProvider(invitation.planId));
                              ref.invalidate(plansStreamProvider);
                              ref.invalidate(globalNotificationsListProvider);
                              ref.invalidate(globalUnreadCountProvider);
                              try {
                                ref
                                    .read(planParticipationNotifierProvider(invitation.planId).notifier)
                                    .reload();
                              } catch (_) {}
                              widget.onResponded();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.success ? loc.invitationAcceptedParticipant : result.message,
                                ),
                                backgroundColor: result.success ? AppColorScheme.color3 : Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                icon: _busy
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 14),
                label: Text(loc.accept, style: GoogleFonts.poppins(fontSize: 11)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColorScheme.color3,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
      ),
    );
  }
}

class InformativeNotificationTile extends StatelessWidget {
  final UnifiedNotification notification;
  final String? userId;
  final VoidCallback? onMarkRead;
  final VoidCallback? onTap;

  const InformativeNotificationTile({
    super.key,
    required this.notification,
    this.userId,
    this.onMarkRead,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Las de acción se consideran no leídas hasta que se realiza la acción.
    final isUnread = notification.requiresAction || !notification.isRead;
    final bg = isUnread ? const Color(0xFF1F2937) : Colors.transparent;
    final borderColor = isUnread ? AppColorScheme.color2.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.12).withValues(alpha: 0.6);
    final iconColor = isUnread ? AppColorScheme.color2 : Colors.white60;
    final titleColor = isUnread ? Colors.white : Colors.white70;
    final bodyColor = isUnread ? Colors.white70 : Colors.white60;
    final timeColor = isUnread ? Colors.white70 : Colors.white60;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? onMarkRead,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isUnread ? 3 : 1,
                height: 44,
                decoration: BoxDecoration(
                  color: isUnread ? AppColorScheme.color2 : Colors.white60,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isUnread ? Icons.notifications_active_outlined : Icons.notifications_none,
                color: iconColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: GoogleFonts.poppins(fontSize: 11, color: bodyColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.formatDateTime(notification.createdAt),
                      style: GoogleFonts.poppins(fontSize: 9, color: timeColor),
                    ),
                  ],
                ),
              ),
              if (isUnread) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColorScheme.color3,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorScheme.color3.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
