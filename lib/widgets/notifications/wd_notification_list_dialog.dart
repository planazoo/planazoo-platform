import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/color_scheme.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/notifications/domain/models/unified_notification.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../../features/calendar/presentation/providers/invitation_providers.dart';
import '../../features/notifications/domain/services/test_notification_generator.dart';
import 'wd_unified_notification_item.dart';
import '../../l10n/app_localizations.dart';

/// Diálogo que muestra la lista global de notificaciones (campana).
class NotificationListDialog extends ConsumerWidget {
  const NotificationListDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(globalNotificationsListProvider);
    final filterIndex = ref.watch(globalNotificationsFilterProvider);
    final currentUser = ref.watch(currentUserProvider);
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    loc.notificationsTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (currentUser != null)
                    TextButton(
                      onPressed: () async {
                        final notificationService = ref.read(notificationServiceProvider);
                        final success = await notificationService.markAllAsRead(currentUser.id);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loc.notificationsMarkAllAsRead,
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.grey.shade800,
                            ),
                          );
                        }
                      },
                      child: Text(
                        loc.notificationsMarkAllAsRead,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColorScheme.color2,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Filtros
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _FilterChip(
                    label: loc.notificationsFilterAll,
                    selected: filterIndex == 0,
                    onTap: () => ref.read(globalNotificationsFilterProvider.notifier).state = 0,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: loc.notificationsFilterAction,
                    selected: filterIndex == 1,
                    onTap: () => ref.read(globalNotificationsFilterProvider.notifier).state = 1,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: loc.notificationsFilterInfo,
                    selected: filterIndex == 2,
                    onTap: () => ref.read(globalNotificationsFilterProvider.notifier).state = 2,
                  ),
                ],
              ),
            ),
            // Lista
            Flexible(
              child: listAsync.when(
                data: (list) {
                  final filtered = _filterList(list, filterIndex);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              loc.notificationsEmpty,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final n = filtered[index];
                      return UnifiedNotificationItem(
                        notification: n,
                        userId: currentUser?.id,
                        authUid: ref.read(authServiceProvider).currentUser?.uid,
                        onInvitationResponded: () => ref.invalidate(userPendingInvitationsProvider),
                        onPendingEventAction: () {
                          ref.invalidate(globalNotificationsListProvider);
                          ref.invalidate(globalUnreadCountProvider);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $error',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Botón generar datos de prueba
            if (currentUser != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final authUid = ref.read(authServiceProvider).currentUser?.uid;
                    if (authUid == null) return;
                    final generator = TestNotificationGenerator();
                    final result = await generator.generate(
                      userId: currentUser!.id,
                      authUid: authUid,
                      userEmail: currentUser.email ?? '',
                    );
                    if (!context.mounted) return;
                    ref.invalidate(userPendingInvitationsProvider);
                    ref.invalidate(globalNotificationsListProvider);
                    ref.invalidate(globalUnreadCountProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          loc.notificationsTestDataGenerated(
                            result.invitations,
                            result.pendingEvents,
                            result.appNotifications,
                          ),
                        ),
                        backgroundColor: Colors.green.shade800,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(loc.notificationsGenerateTestData),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColorScheme.color2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static List<UnifiedNotification> _filterList(List<UnifiedNotification> list, int filterIndex) {
    if (filterIndex == 1) return list.where((n) => n.requiresAction).toList();
    if (filterIndex == 2) return list.where((n) => !n.requiresAction).toList();
    return list;
  }

}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColorScheme.color2 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: selected ? Colors.white : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

