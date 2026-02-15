import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/models/unified_notification.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/services/global_notifications_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../calendar/presentation/providers/invitation_providers.dart';

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

/// Provider para obtener el contador de notificaciones no leídas (solo users/.../notifications)
final unreadCountProvider = StreamProvider<int>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value(0);
  }

  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getUnreadCount(currentUser.id);
});

/// Lista global agregada: invitaciones + eventos desde correo + notificaciones (users/.../notifications).
/// Orden cronológico descendente. Usado por la campana.
final globalNotificationsListProvider = StreamProvider<List<UnifiedNotification>>((ref) {
  final authUid = ref.watch(authServiceProvider).currentUser?.uid;
  final user = ref.watch(currentUserProvider);
  final invitationsAsync = ref.watch(userPendingInvitationsProvider);
  if (authUid == null || user == null) return Stream.value([]);
  final invitations = invitationsAsync.valueOrNull ?? [];
  final service = GlobalNotificationsService();
  return service.streamGlobalNotifications(
    invitations: invitations,
    authUid: authUid,
    userId: user.id,
  );
});

/// Contador global de "no leídas": pendientes de acción + notificaciones no leídas. Para badge de la campana.
final globalUnreadCountProvider = StreamProvider<int>((ref) {
  final authUid = ref.watch(authServiceProvider).currentUser?.uid;
  final user = ref.watch(currentUserProvider);
  final invitationsAsync = ref.watch(userPendingInvitationsProvider);
  if (authUid == null || user == null) return Stream.value(0);
  final invitations = invitationsAsync.valueOrNull ?? [];
  final service = GlobalNotificationsService();
  return service.streamUnreadCount(
    invitations: invitations,
    authUid: authUid,
    userId: user.id,
  );
});

/// Filtro de la lista global: 0 = Todas, 1 = Pendientes de acción, 2 = Solo informativas.
final globalNotificationsFilterProvider = StateProvider<int>((ref) => 0);

/// Número de notificaciones no leídas para un plan (para badge en W20).
/// Si [planId] es null, retorna 0.
final planUnreadCountProvider = Provider.family<AsyncValue<int>, String?>((ref, planId) {
  final listAsync = ref.watch(globalNotificationsListProvider);
  if (planId == null) return const AsyncValue.data(0);
  return listAsync.when(
    data: (list) {
      final count = list
          .where((n) =>
              n.planId == planId && (n.requiresAction || !n.isRead))
          .length;
      return AsyncValue.data(count);
    },
    loading: () => const AsyncValue.data(0),
    error: (e, _) => const AsyncValue.data(0),
  );
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
