import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../../../../features/security/utils/sanitizer.dart';
import '../models/plan_message.dart';

/// Servicio para gestionar mensajes del chat del plan en Firestore
class ChatService {
  static const String _collectionName = 'plans';
  static const String _subCollectionName = 'messages';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crear un nuevo mensaje en el chat del plan
  Future<String?> sendMessage(
    String planId,
    PlanMessage message,
  ) async {
    try {
      // Sanitizar el mensaje
      final sanitizedMessage = Sanitizer.sanitizePlainText(
        message.message,
        maxLength: 5000,
      );

      // Validar que el mensaje no esté vacío después de sanitizar
      if (sanitizedMessage.trim().isEmpty) {
        LoggerService.warning(
          'Attempted to send empty message for plan: $planId',
          context: 'CHAT_SERVICE',
        );
        return null;
      }

      // Crear mensaje con contenido sanitizado
      final sanitizedPlanMessage = message.copyWith(
        message: sanitizedMessage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Guardar en Firestore
      final docRef = await _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .add(sanitizedPlanMessage.toFirestore());

      LoggerService.database(
        'Message sent: $planId/${docRef.id}',
        operation: 'CREATE',
      );

      return docRef.id;
    } catch (e) {
      LoggerService.error(
        'Error sending message for plan: $planId',
        context: 'CHAT_SERVICE',
        error: e,
      );
      return null;
    }
  }

  /// Obtener todos los mensajes del chat del plan (stream en tiempo real)
  Stream<List<PlanMessage>> getMessages(String planId) {
    try {
      return _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .orderBy('createdAt', descending: false) // Más antiguos primero (para chat)
          .snapshots()
          .map((snapshot) {
        // Filtrar mensajes eliminados en el cliente (para evitar necesidad de índice compuesto)
        return snapshot.docs
            .map((doc) {
              try {
                return PlanMessage.fromFirestore(doc);
              } catch (e) {
                LoggerService.error(
                  'Error parsing message: ${doc.id}',
                  context: 'CHAT_SERVICE',
                  error: e,
                );
                return null;
              }
            })
            .where((message) => message != null && !message.isDeleted)
            .cast<PlanMessage>()
            .toList();
      }).handleError((error) {
        LoggerService.error(
          'Error in messages stream for plan: $planId',
          context: 'CHAT_SERVICE',
          error: error,
        );
        return <PlanMessage>[];
      });
    } catch (e) {
      LoggerService.error(
        'Error creating messages stream for plan: $planId',
        context: 'CHAT_SERVICE',
        error: e,
      );
      return Stream.value(<PlanMessage>[]);
    }
  }

  /// Marcar un mensaje como leído por un usuario
  Future<bool> markMessageAsRead(
    String planId,
    String messageId,
    String userId,
  ) async {
    try {
      final messageRef = _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .doc(messageId);

      // Obtener el mensaje actual
      final messageDoc = await messageRef.get();
      if (!messageDoc.exists) {
        LoggerService.warning(
          'Message not found: $planId/$messageId',
          context: 'CHAT_SERVICE',
        );
        return false;
      }

      final data = messageDoc.data()!;
      final readBy = List<String>.from(data['readBy'] ?? []);

      // Si el usuario ya lo leyó, no hacer nada
      if (readBy.contains(userId)) {
        return true;
      }

      // Añadir el userId a la lista de leídos
      readBy.add(userId);

      // Actualizar el mensaje
      await messageRef.update({
        'readBy': readBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.database(
        'Message marked as read: $planId/$messageId by $userId',
        operation: 'UPDATE',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error marking message as read: $planId/$messageId',
        context: 'CHAT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Marcar todos los mensajes del plan como leídos por un usuario
  Future<int> markAllMessagesAsRead(
    String planId,
    String userId,
  ) async {
    try {
      // Obtener todos los mensajes no leídos del usuario
      final messagesSnapshot = await _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .where('deletedAt', isNull: true)
          .get();

      int count = 0;
      final batch = _firestore.batch();

      for (var doc in messagesSnapshot.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);

        // Si el usuario no lo ha leído, añadirlo
        if (!readBy.contains(userId)) {
          readBy.add(userId);
          batch.update(doc.reference, {
            'readBy': readBy,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        LoggerService.database(
          '$count messages marked as read: $planId by $userId',
          operation: 'BATCH_UPDATE',
        );
      }

      return count;
    } catch (e) {
      LoggerService.error(
        'Error marking all messages as read: $planId',
        context: 'CHAT_SERVICE',
        error: e,
      );
      return 0;
    }
  }

  /// Editar un mensaje (solo el autor puede editar)
  Future<bool> editMessage(
    String planId,
    String messageId,
    String newMessage,
    String userId,
  ) async {
    try {
      // Sanitizar el nuevo mensaje
      final sanitizedMessage = Sanitizer.sanitizePlainText(
        newMessage,
        maxLength: 5000,
      );

      if (sanitizedMessage.trim().isEmpty) {
        LoggerService.warning(
          'Attempted to edit message with empty content: $planId/$messageId',
          context: 'CHAT_SERVICE',
        );
        return false;
      }

      final messageRef = _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .doc(messageId);

      // Verificar que el mensaje existe y pertenece al usuario
      final messageDoc = await messageRef.get();
      if (!messageDoc.exists) {
        LoggerService.warning(
          'Message not found: $planId/$messageId',
          context: 'CHAT_SERVICE',
        );
        return false;
      }

      final data = messageDoc.data()!;
      if (data['userId'] != userId) {
        LoggerService.warning(
          'User $userId attempted to edit message owned by ${data['userId']}',
          context: 'CHAT_SERVICE',
        );
        return false;
      }

      // Actualizar el mensaje
      await messageRef.update({
        'message': sanitizedMessage,
        'editedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.database(
        'Message edited: $planId/$messageId',
        operation: 'UPDATE',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error editing message: $planId/$messageId',
        context: 'CHAT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Eliminar un mensaje (soft delete - solo el autor puede eliminar)
  Future<bool> deleteMessage(
    String planId,
    String messageId,
    String userId,
  ) async {
    try {
      final messageRef = _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .doc(messageId);

      // Verificar que el mensaje existe y pertenece al usuario
      final messageDoc = await messageRef.get();
      if (!messageDoc.exists) {
        LoggerService.warning(
          'Message not found: $planId/$messageId',
          context: 'CHAT_SERVICE',
        );
        return false;
      }

      final data = messageDoc.data()!;
      if (data['userId'] != userId) {
        LoggerService.warning(
          'User $userId attempted to delete message owned by ${data['userId']}',
          context: 'CHAT_SERVICE',
        );
        return false;
      }

      // Soft delete: marcar como eliminado
      await messageRef.update({
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.database(
        'Message deleted: $planId/$messageId',
        operation: 'UPDATE',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting message: $planId/$messageId',
        context: 'CHAT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Obtener el número de mensajes no leídos para un usuario
  Future<int> getUnreadCount(String planId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .where('deletedAt', isNull: true)
          .get();

      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);
        if (!readBy.contains(userId)) {
          count++;
        }
      }

      return count;
    } catch (e) {
      LoggerService.error(
        'Error getting unread count for plan: $planId',
        context: 'CHAT_SERVICE',
        error: e,
      );
      return 0;
    }
  }

  /// Obtener un stream del número de mensajes no leídos
  Stream<int> getUnreadCountStream(String planId, String userId) {
    return _firestore
        .collection(_collectionName)
        .doc(planId)
        .collection(_subCollectionName)
        .where('deletedAt', isNull: true)
        .snapshots()
        .map((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);
        if (!readBy.contains(userId)) {
          count++;
        }
      }
      return count;
    });
  }
}
