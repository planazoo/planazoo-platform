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

  /// Convierte un QuerySnapshot a lista de PlanMessage (ordenada por createdAt).
  static List<PlanMessage> _snapshotToMessages(QuerySnapshot snapshot) {
    final list = snapshot.docs
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
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  /// Obtener todos los mensajes del chat del plan (stream en tiempo real).
  /// Primera emisión desde servidor (Source.server) para evitar caché incompleta entre clientes;
  /// luego snapshots() para actualizaciones en tiempo real.
  Stream<List<PlanMessage>> getMessages(String planId) {
    try {
      final ref = _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName);

      return _streamWithInitialServerFetch(ref, planId);
    } catch (e) {
      LoggerService.error(
        'Error creating messages stream for plan: $planId',
        context: 'CHAT_SERVICE',
        error: e,
      );
      return Stream.error(e);
    }
  }

  Stream<List<PlanMessage>> _streamWithInitialServerFetch(
    CollectionReference<Map<String, dynamic>> ref,
    String planId,
  ) async* {
    try {
      // Primera carga desde servidor para ver todos los mensajes (evita caché incompleta por cliente)
      final serverSnapshot = await ref.get(const GetOptions(source: Source.server));
      yield _snapshotToMessages(serverSnapshot);

      // Luego escuchar cambios en tiempo real; solo emitir cuando los datos vienen del servidor
      // para no sobrescribir con caché local (que podría tener solo los mensajes de este cliente)
      await for (final snapshot in ref.snapshots().handleError((error, stackTrace) {
        LoggerService.error(
          'Error in messages stream for plan: $planId',
          context: 'CHAT_SERVICE',
          error: error,
          stackTrace: stackTrace,
        );
        throw error;
      })) {
        if (!snapshot.metadata.isFromCache) {
          yield _snapshotToMessages(snapshot);
        }
      }
    } catch (e) {
      LoggerService.error(
        'Error in messages stream for plan: $planId',
        context: 'CHAT_SERVICE',
        error: e,
      );
      rethrow;
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

  /// Añade o quita una reacción del usuario en un mensaje (toggle).
  /// [emoji] es el carácter de la reacción (ej. "👍", "❤️").
  Future<bool> toggleReaction(
    String planId,
    String messageId,
    String userId,
    String emoji,
  ) async {
    if (emoji.isEmpty) return false;
    try {
      final messageRef = _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .doc(messageId);

      final messageDoc = await messageRef.get();
      if (!messageDoc.exists) return false;

      final data = messageDoc.data()!;
      final reactionsRaw = data['reactions'];
      final Map<String, List<String>> reactions = reactionsRaw != null && reactionsRaw is Map
          ? PlanMessage.parseReactions(reactionsRaw)
          : {};

      final list = reactions[emoji] ?? [];
      final newList = List<String>.from(list);
      if (newList.contains(userId)) {
        newList.remove(userId);
      } else {
        newList.add(userId);
      }

      if (newList.isEmpty) {
        reactions.remove(emoji);
      } else {
        reactions[emoji] = newList;
      }

      await messageRef.update({
        'reactions': reactions.map((k, v) => MapEntry(k, v)),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.database(
        'Reaction toggled: $planId/$messageId emoji=$emoji by $userId',
        operation: 'UPDATE',
      );
      return true;
    } catch (e) {
      LoggerService.error(
        'Error toggling reaction: $planId/$messageId',
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
