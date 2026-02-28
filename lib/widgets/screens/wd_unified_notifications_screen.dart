import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/pending_email_event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_invitation.dart';
import 'package:unp_calendario/features/calendar/domain/services/pending_email_event_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/screens/wd_pending_event_card.dart';

/// Buzón unificado: invitaciones a planes + eventos desde correo en una sola pantalla.
class WdUnifiedNotificationsScreen extends ConsumerWidget {
  const WdUnifiedNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authService = ref.watch(authServiceProvider);
    final authUid = authService.currentUser?.uid;
    final invitationsAsync = ref.watch(userPendingInvitationsProvider);

    if (user == null || authUid == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return invitationsAsync.when(
      data: (invitations) {
        return StreamBuilder<List<PendingEmailEvent>>(
          stream: PendingEmailEventService().streamPendingEvents(authUid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyStyle.copyWith(color: Colors.red.shade700),
                  ),
                ),
              );
            }
            final list = snapshot.data ?? [];
            final pendingEvents = list.where((e) => e.status == 'pending').toList();
            final loc = AppLocalizations.of(context)!;
            final hasInvitations = invitations.isNotEmpty;
            final hasEvents = pendingEvents.isNotEmpty;

            if (!hasInvitations && !hasEvents) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppColorScheme.color4.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        loc.pendingEventsEmpty,
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
                if (hasInvitations) ...[
                  _SectionHeader(
                    icon: Icons.mail_outline,
                    title: loc.notificationsSectionInvitations,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  ...invitations.map((inv) => _InvitationCard(
                        invitation: inv,
                        userId: user.id,
                        onAccept: () async {
                          final ok = await ref.read(invitationServiceProvider).acceptInvitationByPlanId(inv.planId, user.id);
                          if (context.mounted) {
                            if (ok) {
                              ref.invalidate(userPendingInvitationsProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.invitationAcceptedParticipant), backgroundColor: Colors.green),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.invitationAcceptFailed), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        onReject: () async {
                          final ok = await ref.read(invitationServiceProvider).rejectInvitationByPlanId(inv.planId, user.id);
                          if (context.mounted) {
                            if (ok) {
                              ref.invalidate(userPendingInvitationsProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.invitationRejected), backgroundColor: Colors.orange),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.invitationRejectFailed), backgroundColor: Colors.red),
                              );
                            }
                          }
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
        Text(
          title,
          style: AppTypography.titleStyle.copyWith(fontSize: 16, color: color),
        ),
      ],
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final PlanInvitation invitation;
  final String userId;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _InvitationCard({
    required this.invitation,
    required this.userId,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.invitationPlanLabel(invitation.planId),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange.shade900),
            ),
            if (invitation.role != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  loc.invitationRoleLabel(invitation.role!),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(loc.reject),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColorScheme.color4,
                    side: BorderSide(color: AppColorScheme.color4),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(loc.accept),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorScheme.color2,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
