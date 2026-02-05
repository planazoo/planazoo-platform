import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/color_scheme.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/notifications/domain/models/notification_model.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../../features/calendar/domain/services/invitation_service.dart';
import '../../features/calendar/presentation/providers/plan_participation_providers.dart';
import '../../shared/utils/date_formatter.dart';
import '../../shared/services/logger_service.dart';

/// Diálogo que muestra la lista de notificaciones del usuario
class NotificationListDialog extends ConsumerWidget {
  const NotificationListDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final currentUser = ref.watch(currentUserProvider);

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
                    'Notificaciones',
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
                                'Todas las notificaciones marcadas como leídas',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.grey.shade800,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Marcar todas como leídas',
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
            // Lista de notificaciones
            Flexible(
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
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
                              'No hay notificaciones',
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
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationItem(
                        notification: notification,
                        onTap: () {
                          _handleNotificationTap(context, ref, notification);
                        },
                        onDelete: currentUser != null
                            ? () async {
                                final notificationService = ref.read(notificationServiceProvider);
                                await notificationService.deleteNotification(
                                  currentUser.id,
                                  notification.id!,
                                );
                              }
                            : null,
                        onAction: currentUser != null
                            ? (action) {
                                _handleNotificationAction(context, ref, notification, action);
                              }
                            : null,
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
                          'Error cargando notificaciones',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    // Marcar como leída
    if (!notification.isRead) {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.markAsRead(
        currentUser.id,
        notification.id!,
      );
    }

    // Navegar según el tipo de notificación
    if (notification.planId != null) {
      // TODO: Navegar al plan correspondiente
      // Por ahora, solo cerramos el diálogo
    }
    
    Navigator.of(context).pop();
  }

  Future<void> _handleNotificationAction(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
    String action,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      if (notification.type == NotificationType.invitation) {
        final token = notification.data?['token'] as String?;
        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: Token de invitación no encontrado',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final invitationService = InvitationService();
        
        if (action == 'accept') {
          final success = await invitationService.acceptInvitationByToken(
            token,
            currentUser.id,
          );

          if (context.mounted) {
            if (success) {
              // Marcar notificación como leída
              final notificationService = ref.read(notificationServiceProvider);
              await notificationService.markAsRead(
                currentUser.id,
                notification.id!,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ Invitación aceptada',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '❌ Error al aceptar la invitación',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else if (action == 'reject') {
          final success = await invitationService.rejectInvitationByToken(token);

          if (context.mounted) {
            if (success) {
              // Marcar notificación como leída
              final notificationService = ref.read(notificationServiceProvider);
              await notificationService.markAsRead(
                currentUser.id,
                notification.id!,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Invitación rechazada',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.orange,
                ),
              );

              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '❌ Error al rechazar la invitación',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      LoggerService.error(
        'Error handling notification action: $action',
        context: 'NOTIFICATION_DIALOG',
        error: e,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Widget para un item de notificación
class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Function(String)? onAction;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    this.onDelete,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final typeIcon = _getTypeIcon(notification.type);
    final typeColor = _getTypeColor(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.grey.shade800.withOpacity(0.5) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade700,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                typeIcon,
                color: typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColorScheme.color2,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormatter.formatDateTime(notification.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  // Botones de acción según el tipo
                  if (_hasActions(notification.type) && onAction != null) ...[
                    const SizedBox(height: 12),
                    _buildActionButtons(),
                  ],
                ],
              ),
            ),
            // Botón eliminar
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasActions(NotificationType type) {
    return type == NotificationType.invitation;
  }

  Widget _buildActionButtons() {
    if (notification.type == NotificationType.invitation) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => onAction?.call('reject'),
              icon: const Icon(Icons.close, size: 16),
              label: Text(
                'Rechazar',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade300,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onAction?.call('accept'),
              icon: const Icon(Icons.check, size: 16),
              label: Text(
                'Aceptar',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.color2,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.eventCreated:
      case NotificationType.eventUpdated:
      case NotificationType.eventDeleted:
        return Icons.event;
      case NotificationType.invitation:
      case NotificationType.invitationAccepted:
      case NotificationType.invitationRejected:
        return Icons.mail;
      case NotificationType.planStateChanged:
        return Icons.flag;
      case NotificationType.participantAdded:
      case NotificationType.participantRemoved:
        return Icons.person;
      case NotificationType.alarm:
        return Icons.alarm;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return AppColorScheme.color2;
      case NotificationType.eventCreated:
      case NotificationType.eventUpdated:
        return Colors.blue;
      case NotificationType.eventDeleted:
        return Colors.red;
      case NotificationType.invitation:
      case NotificationType.invitationAccepted:
        return Colors.green;
      case NotificationType.invitationRejected:
        return Colors.orange;
      case NotificationType.planStateChanged:
        return Colors.purple;
      case NotificationType.participantAdded:
        return Colors.teal;
      case NotificationType.participantRemoved:
        return Colors.red;
      case NotificationType.alarm:
        return Colors.orange;
    }
  }
}
