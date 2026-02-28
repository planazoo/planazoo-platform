import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/color_scheme.dart';
import '../../features/calendar/domain/models/plan_invitation.dart';
import '../../features/calendar/domain/models/pending_email_event.dart';
import '../../features/notifications/domain/models/unified_notification.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../../features/calendar/presentation/providers/invitation_providers.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../widgets/screens/wd_pending_event_card.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notification.type == UnifiedNotificationType.invitation &&
        notification.sourcePayload is PlanInvitation &&
        userId != null) {
      final inv = notification.sourcePayload as PlanInvitation;
      return InvitationNotificationTile(
        invitation: inv,
        userId: userId!,
        onResponded: onInvitationResponded ?? () {},
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

class InvitationNotificationTile extends ConsumerWidget {
  final PlanInvitation invitation;
  final String userId;
  final VoidCallback onResponded;

  const InvitationNotificationTile({
    super.key,
    required this.invitation,
    required this.userId,
    required this.onResponded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loc.invitationPlanLabel(invitation.planId),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (invitation.role != null)
            Text(
              loc.invitationRoleLabel(invitation.role!),
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await ref.read(invitationServiceProvider).rejectInvitationByPlanId(invitation.planId, userId);
                  if (context.mounted) {
                    if (ok) {
                      onResponded();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.invitationRejected), backgroundColor: Colors.orange),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.close, size: 14),
                label: Text(loc.reject, style: GoogleFonts.poppins(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColorScheme.color3,
                  side: const BorderSide(color: AppColorScheme.color3, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final ok = await ref.read(invitationServiceProvider).acceptInvitationByPlanId(invitation.planId, userId);
                  if (context.mounted) {
                    if (ok) {
                      onResponded();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.invitationAcceptedParticipant), backgroundColor: Colors.green),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.check, size: 14),
                label: Text(loc.accept, style: GoogleFonts.poppins(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorScheme.color2,
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
    );
  }
}

class InformativeNotificationTile extends StatelessWidget {
  final UnifiedNotification notification;
  final String? userId;
  final VoidCallback? onMarkRead;

  const InformativeNotificationTile({
    super.key,
    required this.notification,
    this.userId,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    // Las de acción se consideran no leídas hasta que se realiza la acción.
    final isUnread = notification.requiresAction || !notification.isRead;
    return InkWell(
      onTap: onMarkRead,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isUnread ? Colors.grey.shade800.withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border(bottom: BorderSide(color: Colors.grey.shade700, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications_none,
              color: AppColorScheme.color2,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatDateTime(notification.createdAt),
                    style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
