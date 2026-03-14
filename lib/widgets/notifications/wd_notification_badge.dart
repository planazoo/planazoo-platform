import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/color_scheme.dart';
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
        final hasUnread = count > 0;
        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: hasUnread ? AppColorScheme.color3 : (iconColor ?? Colors.white),
                size: iconSize,
              ),
              if (count > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: AppColorScheme.color3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColorScheme.color2, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            _showNotificationList(context, ref);
          },
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
