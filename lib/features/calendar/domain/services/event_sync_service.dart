import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import 'event_notification_service.dart';

/// Servicio para sincronizar cambios en la parte común de eventos entre copias de participantes
class EventSyncService {
  static const String _collectionName = 'events';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EventNotificationService _notificationService = EventNotificationService();

  /// Propaga cambios en la parte común de un evento a todas sus copias
  /// 
  /// [eventId] - ID del evento original (base)
  /// [newCommonPart] - Nueva parte común a propagar
  /// [changedBy] - ID del usuario que hizo el cambio
  /// 
  /// Retorna true si la propagación fue exitosa
  Future<bool> propagateCommonPartChanges({
    required String eventId,
    required EventCommonPart newCommonPart,
    required String changedBy,
  }) async {
    try {
      // 1. Obtener el evento original
      final baseEventDoc = await _firestore.collection(_collectionName).doc(eventId).get();
      if (!baseEventDoc.exists) {
        return false; // No existe el evento
      }
      
      final baseEvent = Event.fromFirestore(baseEventDoc);
      if (!baseEvent.isBaseEvent) {
        return false; // No es un evento base válido
      }

      // 2. Buscar todas las copias del evento
      final eventCopies = await _getEventCopies(eventId);
      
      // 3. Usar transacción para actualizar todas las copias atómicamente
      return await _firestore.runTransaction((transaction) async {
        // Actualizar el evento original directamente (sin usar saveEvent para evitar bucles)
        final baseEventRef = _firestore.collection(_collectionName).doc(eventId);
        transaction.update(baseEventRef, {
          'commonPart': newCommonPart.toMap(),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
          'lastSyncBy': changedBy,
          'lastSyncAt': Timestamp.fromDate(DateTime.now()),
        });

        // Actualizar todas las copias directamente (sin usar saveEvent para evitar bucles)
        for (final copy in eventCopies) {
          final copyRef = _firestore.collection(_collectionName).doc(copy.id);
          transaction.update(copyRef, {
            'commonPart': newCommonPart.toMap(),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
            'lastSyncBy': changedBy,
            'lastSyncAt': Timestamp.fromDate(DateTime.now()),
          });
        }

        return true;
      });

      // 4. Crear notificaciones después de la transacción (para evitar problemas)
      final affectedUserIds = eventCopies.map((e) => e.userId).toList();
      if (affectedUserIds.isNotEmpty) {
        _notificationService.notifyCommonPartChange(
          eventId: eventId,
          eventTitle: newCommonPart.description,
          changedBy: changedBy,
          affectedUserIds: affectedUserIds,
          changeDescription: 'Se actualizó la información general del evento',
        );
      }

      return true;
    } catch (e) {
      // Error propagating common part changes: $e
      return false;
    }
  }

  /// Crea copias de un evento para todos los participantes
  /// 
  /// [baseEvent] - Evento original
  /// [participantIds] - Lista de IDs de participantes para crear copias
  /// 
  /// Retorna lista de IDs de eventos creados
  Future<List<String>> createEventCopies({
    required Event baseEvent,
    required List<String> participantIds,
  }) async {
    if (!baseEvent.isBaseEvent) {
      throw ArgumentError('Solo se pueden crear copias desde eventos base');
    }

    try {
      final createdIds = <String>[];
      
      // Usar batch para crear todas las copias atómicamente
      final batch = _firestore.batch();
      
      for (final participantId in participantIds) {
        // Crear copia del evento para el participante
        final eventCopy = baseEvent.createCopyForParticipant(participantId);
        
        // Añadir al batch
        final docRef = _firestore.collection(_collectionName).doc();
        batch.set(docRef, eventCopy.toFirestore());
        createdIds.add(docRef.id);
      }
      
      await batch.commit();
      return createdIds;
    } catch (e) {
      // Error creating event copies: $e
      return [];
    }
  }

  /// Elimina todas las copias de un evento base
  /// 
  /// [baseEventId] - ID del evento original
  /// 
  /// Retorna true si la eliminación fue exitosa
  Future<bool> deleteEventCopies(String baseEventId) async {
    try {
      // Buscar todas las copias
      final eventCopies = await _getEventCopies(baseEventId);
      
      if (eventCopies.isEmpty) {
        return true; // No hay copias que eliminar
      }

      // Usar batch para eliminar todas las copias atómicamente
      final batch = _firestore.batch();
      for (final copy in eventCopies) {
        batch.delete(_firestore.collection(_collectionName).doc(copy.id!));
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      // Error deleting event copies: $e
      return false;
    }
  }

  /// Sincroniza cambios en la lista de participantes
  /// 
  /// [baseEventId] - ID del evento original
  /// [newParticipantIds] - Nueva lista de participantes
  /// [changedBy] - ID del usuario que hizo el cambio
  /// 
  /// Retorna true si la sincronización fue exitosa
  Future<bool> syncParticipantChanges({
    required String baseEventId,
    required List<String> newParticipantIds,
    required String changedBy,
  }) async {
    try {
      // 1. Obtener el evento original
      final baseEvent = await _eventService.getEventById(baseEventId);
      if (baseEvent == null || !baseEvent.isBaseEvent) {
        return false;
      }

      // 2. Obtener copias existentes
      final existingCopies = await _getEventCopies(baseEventId);
      final existingParticipantIds = existingCopies.map((e) => e.userId).toSet();

      // 3. Identificar cambios
      final toAdd = newParticipantIds.where((id) => !existingParticipantIds.contains(id)).toList();
      final toRemove = existingParticipantIds.where((id) => !newParticipantIds.contains(id)).toList();

      // 4. Usar transacción para aplicar cambios
      return await _firestore.runTransaction((transaction) async {
        // Eliminar copias de participantes que ya no están
        for (final copy in existingCopies) {
          if (toRemove.contains(copy.userId)) {
            transaction.delete(_firestore.collection(_collectionName).doc(copy.id!));
          }
        }

        // Crear copias para nuevos participantes
        for (final participantId in toAdd) {
          final eventCopy = baseEvent.createCopyForParticipant(participantId);
          final docRef = _firestore.collection(_collectionName).doc();
          transaction.set(docRef, eventCopy.toFirestore());
        }

        // Actualizar el evento base con la nueva lista de participantes
        final baseEventRef = _firestore.collection(_collectionName).doc(baseEventId);
        transaction.update(baseEventRef, {
          'commonPart.participantIds': newParticipantIds,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
          'lastSyncBy': changedBy,
          'lastSyncAt': Timestamp.fromDate(DateTime.now()),
        });

        return true;
      });
    } catch (e) {
      // Error syncing participant changes: $e
      return false;
    }
  }

  /// Obtiene todas las copias de un evento base
  /// 
  /// [baseEventId] - ID del evento original
  /// 
  /// Retorna lista de eventos copia
  Future<List<Event>> _getEventCopies(String baseEventId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('baseEventId', isEqualTo: baseEventId)
          .get();

      return snapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error getting event copies: $e
      return [];
    }
  }

  /// Obtiene el evento base y todas sus copias
  /// 
  /// [baseEventId] - ID del evento original
  /// 
  /// Retorna mapa con el evento base y sus copias
  Future<Map<String, List<Event>>> getEventWithCopies(String baseEventId) async {
    try {
      // Obtener evento base
      final baseEventDoc = await _firestore.collection(_collectionName).doc(baseEventId).get();
      if (!baseEventDoc.exists) {
        return {'base': [], 'copies': []};
      }

      final baseEvent = Event.fromFirestore(baseEventDoc);

      // Obtener copias
      final copies = await _getEventCopies(baseEventId);

      return {
        'base': [baseEvent],
        'copies': copies,
      };
    } catch (e) {
      // Error getting event with copies: $e
      return {'base': [], 'copies': []};
    }
  }

  /// Detecta si un cambio afecta la parte común o personal
  /// 
  /// [oldEvent] - Evento antes del cambio
  /// [newEvent] - Evento después del cambio
  /// 
  /// Retorna true si el cambio afecta la parte común
  bool isCommonPartChange(Event oldEvent, Event newEvent) {
    if (oldEvent.commonPart == null || newEvent.commonPart == null) {
      return false;
    }

    final oldCommon = oldEvent.commonPart!;
    final newCommon = newEvent.commonPart!;

    return oldCommon.description != newCommon.description ||
           oldCommon.date != newCommon.date ||
           oldCommon.startHour != newCommon.startHour ||
           oldCommon.startMinute != newCommon.startMinute ||
           oldCommon.durationMinutes != newCommon.durationMinutes ||
           oldCommon.location != newCommon.location ||
           oldCommon.notes != newCommon.notes ||
           oldCommon.family != newCommon.family ||
           oldCommon.subtype != newCommon.subtype ||
           oldCommon.customColor != newCommon.customColor ||
           oldCommon.participantIds != newCommon.participantIds ||
           oldCommon.isForAllParticipants != newCommon.isForAllParticipants ||
           oldCommon.isDraft != newCommon.isDraft;
  }

  /// Detecta si un cambio afecta solo la parte personal
  /// 
  /// [oldEvent] - Evento antes del cambio
  /// [newEvent] - Evento después del cambio
  /// 
  /// Retorna true si el cambio afecta solo la parte personal
  bool isPersonalPartChange(Event oldEvent, Event newEvent) {
    // Si no hay cambios en la parte común, entonces es cambio personal
    return !isCommonPartChange(oldEvent, newEvent);
  }
}
