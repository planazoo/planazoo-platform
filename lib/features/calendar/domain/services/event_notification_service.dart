import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para notificaciones de cambios en eventos
class EventNotificationService {
  static const String _collectionName = 'event_notifications';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crea una notificación de cambio en evento
  /// 
  /// [eventId] - ID del evento que cambió
  /// [eventTitle] - Título del evento
  /// [changeType] - Tipo de cambio (common_part, personal_part, participants)
  /// [changedBy] - ID del usuario que hizo el cambio
  /// [affectedUserIds] - Lista de usuarios afectados por el cambio
  /// [changeDescription] - Descripción del cambio
  Future<bool> createEventChangeNotification({
    required String eventId,
    required String eventTitle,
    required String changeType,
    required String changedBy,
    required List<String> affectedUserIds,
    required String changeDescription,
  }) async {
    try {
      final now = DateTime.now();
      
      // Crear notificación para cada usuario afectado
      final batch = _firestore.batch();
      
      for (final userId in affectedUserIds) {
        final notificationRef = _firestore.collection(_collectionName).doc();
        
        batch.set(notificationRef, {
          'id': notificationRef.id,
          'eventId': eventId,
          'eventTitle': eventTitle,
          'changeType': changeType,
          'changedBy': changedBy,
          'userId': userId, // Usuario que recibe la notificación
          'changeDescription': changeDescription,
          'isRead': false,
          'createdAt': Timestamp.fromDate(now),
        });
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      // Error creating event change notification: $e
      return false;
    }
  }

  /// Obtiene notificaciones no leídas de un usuario
  /// 
  /// [userId] - ID del usuario
  /// [limit] - Límite de notificaciones (por defecto 50)
  Future<List<Map<String, dynamic>>> getUnreadNotifications(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // Error getting unread notifications: $e
      return [];
    }
  }

  /// Marca una notificación como leída
  /// 
  /// [notificationId] - ID de la notificación
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collectionName).doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      // Error marking notification as read: $e
      return false;
    }
  }

  /// Marca todas las notificaciones de un usuario como leídas
  /// 
  /// [userId] - ID del usuario
  Future<bool> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return true;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      // Error marking all notifications as read: $e
      return false;
    }
  }

  /// Elimina notificaciones antiguas (más de 30 días)
  /// 
  /// [userId] - ID del usuario (opcional, si no se especifica elimina de todos)
  Future<bool> cleanupOldNotifications({String? userId}) async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      
      Query query = _firestore
          .collection(_collectionName)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate));
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) return true;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      // Error cleaning up old notifications: $e
      return false;
    }
  }

  /// Obtiene el contador de notificaciones no leídas
  /// 
  /// [userId] - ID del usuario
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      // Error getting unread count: $e
      return 0;
    }
  }

  /// Crea notificación específica para cambio en parte común
  Future<bool> notifyCommonPartChange({
    required String eventId,
    required String eventTitle,
    required String changedBy,
    required List<String> affectedUserIds,
    required String changeDescription,
  }) async {
    return await createEventChangeNotification(
      eventId: eventId,
      eventTitle: eventTitle,
      changeType: 'common_part',
      changedBy: changedBy,
      affectedUserIds: affectedUserIds,
      changeDescription: changeDescription,
    );
  }

  /// Crea notificación específica para cambio en participantes
  Future<bool> notifyParticipantChange({
    required String eventId,
    required String eventTitle,
    required String changedBy,
    required List<String> affectedUserIds,
    required String changeDescription,
  }) async {
    return await createEventChangeNotification(
      eventId: eventId,
      eventTitle: eventTitle,
      changeType: 'participants',
      changedBy: changedBy,
      affectedUserIds: affectedUserIds,
      changeDescription: changeDescription,
    );
  }
}
