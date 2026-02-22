import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/pending_email_event.dart';
import 'package:unp_calendario/features/calendar/domain/services/pending_email_event_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/notifications/domain/models/unified_notification.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/screens/wd_pending_event_card.dart';
import 'package:unp_calendario/widgets/notifications/wd_unified_notification_item.dart';

/// Notificaciones del plan seleccionado (W20): bloque 1 = notificaciones con planId; bloque 2 = eventos desde correo pendientes.
class WdPlanNotificationsScreen extends ConsumerWidget {
  final Plan plan;

  const WdPlanNotificationsScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authUid = ref.watch(authServiceProvider).currentUser?.uid;
    final listAsync = ref.watch(globalNotificationsListProvider);
    final loc = AppLocalizations.of(context)!;

    if (user == null || authUid == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return listAsync.when(
      data: (allList) {
        final planId = plan.id;
        if (planId == null) {
          return Center(
            child: Text(
              loc.notificationsEmpty,
              style: AppTypography.bodyStyle.copyWith(color: AppColorScheme.color4),
            ),
          );
        }
        final planNotifications = allList
            .where((n) => n.planId == planId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return StreamBuilder<List<PendingEmailEvent>>(
          stream: PendingEmailEventService().streamPendingEvents(authUid),
          builder: (context, snapshot) {
            final pendingEvents = (snapshot.data ?? [])
                .where((e) => e.status == 'pending')
                .toList();
            final hasPlanNotif = planNotifications.isNotEmpty;
            final hasEvents = pendingEvents.isNotEmpty;

            if (!hasPlanNotif && !hasEvents) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppColorScheme.color4.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        loc.notificationsEmpty,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyStyle.copyWith(color: AppColorScheme.color4),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                if (hasPlanNotif) ...[
                  _SectionHeader(
                    icon: Icons.notifications_active,
                    title: '${loc.notificationsTitle} - ${plan.name}',
                    color: AppColorScheme.color2,
                  ),
                  const SizedBox(height: 8),
                  ...planNotifications.map((n) => UnifiedNotificationItem(
                        notification: n,
                        userId: user.id,
                        authUid: authUid,
                        onInvitationResponded: () => ref.invalidate(userPendingInvitationsProvider),
                        onPendingEventAction: () {
                          ref.invalidate(globalNotificationsListProvider);
                          ref.invalidate(globalUnreadCountProvider);
                        },
                      )),
                  const SizedBox(height: 24),
                ],
                if (hasEvents) ...[
                  _SectionHeader(
                    icon: Icons.email_outlined,
                    title: loc.notificationsSectionEmailEvents,
                    color: AppColorScheme.color1,
                  ),
                  const SizedBox(height: 8),
                  ...pendingEvents.map((item) => WdPendingEventCard(
                        pending: item,
                        userId: authUid,
                        onAssign: () => PendingEmailEventActions.showAssignDialog(context, ref, item, authUid),
                        onDiscard: () => PendingEmailEventActions.discard(context, ref, item, authUid),
                      )),
                ],
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Error: $e',
            textAlign: TextAlign.center,
            style: AppTypography.bodyStyle.copyWith(color: Colors.red.shade700),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTypography.titleStyle.copyWith(fontSize: 16, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
