import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import 'wd_notification_list_dialog.dart';

/// Widget que muestra un badge con el contador de notificaciones no leídas
/// 
/// Al hacer clic, abre un diálogo con la lista de notificaciones
class NotificationBadge extends ConsumerWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final double iconSize;

  const NotificationBadge({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(globalUnreadCountProvider);

    return unreadCountAsync.when(
      data: (count) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: iconColor ?? Colors.white,
                size: iconSize,
              ),
              onPressed: () {
                _showNotificationList(context, ref);
              },
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => IconButton(
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor ?? Colors.white,
          size: iconSize,
        ),
        onPressed: null,
      ),
      error: (_, __) => IconButton(
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor ?? Colors.white,
          size: iconSize,
        ),
        onPressed: () {
          _showNotificationList(context, ref);
        },
      ),
    );
  }

  void _showNotificationList(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const NotificationListDialog(),
    );
  }
}
