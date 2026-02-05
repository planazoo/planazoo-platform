import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Provider para NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider para obtener las notificaciones del usuario actual
final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value([]);
  }

  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getNotifications(currentUser.id);
});

/// Provider para obtener solo notificaciones no leídas
final unreadNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value([]);
  }

  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getNotifications(
    currentUser.id,
    unreadOnly: true,
  );
});

/// Provider para obtener el contador de notificaciones no leídas
final unreadCountProvider = StreamProvider<int>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value(0);
  }

  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getUnreadCount(currentUser.id);
});

/// Provider para crear una notificación
final createNotificationProvider = Provider.family<Future<String?>, NotificationModel>((ref, notification) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.createNotification(
    notification.userId,
    notification,
  );
});

/// Provider para crear notificaciones para múltiples usuarios
final createNotificationsForUsersProvider = Provider.family<Future<int>, ({List<String> userIds, NotificationModel notification})>((ref, params) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.createNotificationsForUsers(
    params.userIds,
    params.notification,
  );
});

/// Provider para marcar notificación como leída
final markNotificationAsReadProvider = Provider.family<Future<bool>, ({String userId, String notificationId})>((ref, params) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.markAsRead(
    params.userId,
    params.notificationId,
  );
});

/// Provider para marcar todas las notificaciones como leídas
final markAllNotificationsAsReadProvider = Provider.family<Future<bool>, String>((ref, userId) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.markAllAsRead(userId);
});

/// Provider para eliminar una notificación
final deleteNotificationProvider = Provider.family<Future<bool>, ({String userId, String notificationId})>((ref, params) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.deleteNotification(
    params.userId,
    params.notificationId,
  );
});

/// Provider para eliminar todas las notificaciones leídas
final deleteReadNotificationsProvider = Provider.family<Future<bool>, String>((ref, userId) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.deleteReadNotifications(userId);
});
