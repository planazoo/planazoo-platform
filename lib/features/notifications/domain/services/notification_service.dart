import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/notification_model.dart';

/// Servicio para gestionar notificaciones del usuario
/// 
/// Las notificaciones se guardan en: users/{userId}/notifications/{notificationId}
class NotificationService {
  static const String _collectionName = 'users';
  static const String _subCollectionName = 'notifications';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crear una notificación para un usuario
  /// 
  /// [userId] - ID del usuario que recibe la notificación
  /// [notification] - Datos de la notificación
  /// Retorna el ID de la notificación creada o null si hay error
  Future<String?> createNotification(
    String userId,
    NotificationModel notification,
  ) async {
    try {
      // Validar que el userId coincida
      if (notification.userId != userId) {
        LoggerService.warning(
          'Notification userId mismatch: expected $userId, got ${notification.userId}',
          context: 'NOTIFICATION_SERVICE',
        );
        return null;
      }

      // Guardar en Firestore
      final docRef = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection(_subCollectionName)
          .add(notification.toFirestore());

      LoggerService.database(
        'Notification created: $userId/${docRef.id}',
        operation: 'CREATE',
      );

      return docRef.id;
    } catch (e) {
      LoggerService.error(
        'Error creating notification for user: $userId',
        context: 'NOTIFICATION_SERVICE',
        error: e,
      );
      return null;
    }
  }

  /// Crear notificaciones para múltiples usuarios
  /// 
  /// [userIds] - Lista de IDs de usuarios que recibirán la notificación
  /// [notification] - Datos base de la notificación (se copiará para cada usuario)
  /// Retorna el número de notificaciones creadas exitosamente
  Future<int> createNotificationsForUsers(
    List<String> userIds,
    NotificationModel notification,
  ) async {
    if (userIds.isEmpty) return 0;

    try {
      final batch = _firestore.batch();
      int count = 0;

      for (final userId in userIds) {
        final notificationRef = _firestore
            .collection(_collectionName)
            .doc(userId)
            .collection(_subCollectionName)
            .doc();

        final userNotification = notification.copyWith(userId: userId);
        batch.set(notificationRef, userNotification.toFirestore());
        count++;
      }

      await batch.commit();

      LoggerService.database(
        'Notifications created for $count users',
        operation: 'CREATE_BATCH',
      );

      return count;
    } catch (e) {
      LoggerService.error(
        'Error creating notifications for users',
        context: 'NOTIFICATION_SERVICE',
        error: e,
      );
      return 0;
    }
  }

  /// Obtener todas las notificaciones de un usuario
  /// 
  /// [userId] - ID del usuario
  /// [limit] - Límite de notificaciones (por defecto 50)
  /// [unreadOnly] - Si es true, solo retorna no leídas
  Stream<List<NotificationModel>> getNotifications(
    String userId, {
    int limit = 50,
    bool unreadOnly = false,
  }) {
    Query query = _firestore
        .collection(_collectionName)
        .doc(userId)
        .collection(_subCollectionName)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Obtener el número de notificaciones no leídas
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .collection(_subCollectionName)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Marcar una notificación como leída
  Future<bool> markAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection(_subCollectionName)
          .doc(notificationId)
          .update({'isRead': true});

      LoggerService.database(
        'Notification marked as read: $userId/$notificationId',
        operation: 'UPDATE',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error marking notification as read: $userId/$notificationId',
        context: 'NOTIFICATION_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<bool> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection(_subCollectionName)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return true;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      LoggerService.database(
        'All notifications marked as read: $userId',
        operation: 'UPDATE_BATCH',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error marking all notifications as read: $userId',
        context: 'NOTIFICATION_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Eliminar una notificación
  Future<bool> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection(_subCollectionName)
          .doc(notificationId)
          .delete();

      LoggerService.database(
        'Notification deleted: $userId/$notificationId',
        operation: 'DELETE',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting notification: $userId/$notificationId',
        context: 'NOTIFICATION_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Eliminar todas las notificaciones leídas
  Future<bool> deleteReadNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection(_subCollectionName)
          .where('isRead', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) return true;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      LoggerService.database(
        'Read notifications deleted: $userId',
        operation: 'DELETE_BATCH',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting read notifications: $userId',
        context: 'NOTIFICATION_SERVICE',
        error: e,
      );
      return false;
    }
  }
}
