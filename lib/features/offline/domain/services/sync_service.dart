import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../features/calendar/domain/models/plan.dart';
import '../../../../features/calendar/domain/models/event.dart';
import '../../../../features/calendar/domain/models/plan_participation.dart';
import '../../../../features/calendar/domain/services/plan_service.dart';
import '../../../../features/calendar/domain/services/event_service.dart';
import '../../../../features/calendar/domain/services/plan_participation_service.dart';
import '../../../../shared/services/logger_service.dart';
import 'plan_local_service.dart';
import 'event_local_service.dart';
import 'participation_local_service.dart';
import 'sync_queue_service.dart';
import '../models/sync_queue_item.dart';
import 'hive_service.dart';

/// Servicio de sincronización con resolución de conflictos (solo móviles)
/// 
/// Implementa la estrategia "último cambio gana" basada en `updatedAt`.
/// Sincroniza datos entre Hive (local) y Firestore (remoto).
class SyncService {
  final PlanLocalService _planLocalService = PlanLocalService();
  final EventLocalService _eventLocalService = EventLocalService();
  final ParticipationLocalService _participationLocalService = ParticipationLocalService();
  final SyncQueueService _syncQueueService = SyncQueueService();
  final PlanService _planService = PlanService();
  final EventService _eventService = EventService();
  final PlanParticipationService _participationService = PlanParticipationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verifica si estamos en móvil
  bool get isMobile => HiveService.isMobile;

  /// Sincroniza todos los datos pendientes
  /// 
  /// Proceso:
  /// 1. Sincroniza cola de cambios locales -> remoto
  /// 2. Sincroniza cambios remotos -> local (con resolución de conflictos)
  Future<SyncResult> syncAll({String? userId}) async {
    if (!isMobile) {
      LoggerService.info('SyncService.syncAll ignorado (no móvil)', context: 'SYNC_SERVICE');
      return SyncResult(success: true, itemsProcessed: 0, conflictsResolved: 0);
    }

    try {
      LoggerService.database('Iniciando sincronización completa', operation: 'SYNC_START');
      
      // 1. Sincronizar cola de cambios locales -> remoto
      final queueResult = await _syncLocalToRemote();
      
      // 2. Sincronizar cambios remotos -> local (solo si tenemos userId)
      int conflictsResolved = 0;
      if (userId != null) {
        conflictsResolved = await _syncRemoteToLocal(userId);
      }
      
      LoggerService.database(
        'Sincronización completada: ${queueResult.itemsProcessed} items procesados, $conflictsResolved conflictos resueltos',
        operation: 'SYNC_COMPLETE',
      );
      
      return SyncResult(
        success: true,
        itemsProcessed: queueResult.itemsProcessed,
        conflictsResolved: conflictsResolved,
      );
    } catch (e) {
      LoggerService.error('Error en sincronización completa', context: 'SYNC_SERVICE', error: e);
      return SyncResult(success: false, itemsProcessed: 0, conflictsResolved: 0);
    }
  }

  /// Sincroniza cambios locales -> remoto (procesa la cola)
  Future<QueueSyncResult> _syncLocalToRemote() async {
    final retryableItems = await _syncQueueService.getRetryableItems();
    int processed = 0;
    int failed = 0;

    for (var item in retryableItems) {
      try {
        final success = await _processSyncQueueItem(item);
        if (success) {
          await _syncQueueService.markAsCompleted(item.id);
          processed++;
        } else {
          await _syncQueueService.markAsFailed(item.id, 'Error procesando item');
          failed++;
        }
      } catch (e) {
        await _syncQueueService.markAsFailed(item.id, e.toString());
        failed++;
      }
    }

    // Limpiar items que excedieron el máximo de reintentos
    await _syncQueueService.cleanupFailedItems();

    return QueueSyncResult(itemsProcessed: processed, itemsFailed: failed);
  }

  /// Procesa un item de la cola de sincronización
  Future<bool> _processSyncQueueItem(SyncQueueItem item) async {
    try {
      switch (item.collection) {
        case 'plans':
          return await _syncPlanItem(item);
        case 'events':
          return await _syncEventItem(item);
        case 'participations':
          return await _syncParticipationItem(item);
        default:
          LoggerService.warning('Colección desconocida en cola: ${item.collection}', context: 'SYNC_SERVICE');
          return false;
      }
    } catch (e) {
      LoggerService.error('Error procesando item de cola: ${item.id}', context: 'SYNC_SERVICE', error: e);
      return false;
    }
  }

  /// Sincroniza un Plan desde la cola
  Future<bool> _syncPlanItem(SyncQueueItem item) async {
    try {
      if (item.operation == 'create') {
        // Crear nuevo plan - convertir datos a formato Firestore
        final firestoreData = _convertToFirestoreFormat(item.data);
        final plan = _planFromMap(item.documentId, firestoreData);
        final planId = await _planService.createPlan(plan);
        if (planId != null) {
          // Actualizar el ID local con el ID remoto
          final updatedPlan = plan.copyWith(id: planId);
          await _planLocalService.savePlan(updatedPlan);
          return true;
        }
        return false;
      } else if (item.operation == 'update') {
        // Actualizar plan existente
        final firestoreData = _convertToFirestoreFormat(item.data);
        final plan = _planFromMap(item.documentId, firestoreData);
        return await _planService.updatePlan(plan);
      } else if (item.operation == 'delete') {
        // Eliminar plan
        if (item.documentId.isNotEmpty) {
          return await _planService.deletePlan(item.documentId);
        }
        return false;
      }
      return false;
    } catch (e) {
      LoggerService.error('Error sincronizando plan: ${item.id}', context: 'SYNC_SERVICE', error: e);
      return false;
    }
  }

  /// Sincroniza un Event desde la cola
  Future<bool> _syncEventItem(SyncQueueItem item) async {
    try {
      if (item.operation == 'create') {
        final firestoreData = _convertToFirestoreFormat(item.data);
        final event = _eventFromMap(item.documentId, firestoreData);
        final eventId = await _eventService.createEvent(event);
        if (eventId != null) {
          final updatedEvent = event.copyWith(id: eventId);
          await _eventLocalService.saveEvent(updatedEvent);
          return true;
        }
        return false;
      } else if (item.operation == 'update') {
        final firestoreData = _convertToFirestoreFormat(item.data);
        final event = _eventFromMap(item.documentId, firestoreData);
        return await _eventService.updateEvent(event, skipSync: true);
      } else if (item.operation == 'delete') {
        if (item.documentId.isNotEmpty) {
          return await _eventService.deleteEvent(item.documentId);
        }
        return false;
      }
      return false;
    } catch (e) {
      LoggerService.error('Error sincronizando evento: ${item.id}', context: 'SYNC_SERVICE', error: e);
      return false;
    }
  }

  /// Sincroniza una PlanParticipation desde la cola
  Future<bool> _syncParticipationItem(SyncQueueItem item) async {
    try {
      if (item.operation == 'create') {
        final firestoreData = _convertToFirestoreFormat(item.data);
        final participation = _participationFromMap(item.documentId, firestoreData);
        final participationId = await _participationService.createParticipation(
          planId: participation.planId,
          userId: participation.userId,
          role: participation.role,
          autoAccept: participation.isAccepted,
        );
        if (participationId != null) {
          final updatedParticipation = participation.copyWith(id: participationId);
          await _participationLocalService.saveParticipation(updatedParticipation);
          return true;
        }
        return false;
      } else if (item.operation == 'update') {
        final firestoreData = _convertToFirestoreFormat(item.data);
        final participation = _participationFromMap(item.documentId, firestoreData);
        return await _participationService.updateParticipation(participation);
      } else if (item.operation == 'delete') {
        if (item.documentId.isNotEmpty) {
          // Obtener la participación para obtener planId y userId
          final doc = await _firestore.collection('plan_participations').doc(item.documentId).get();
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            final planId = data['planId'] as String;
            final userId = data['userId'] as String;
            return await _participationService.removeParticipation(planId, userId);
          }
          return false;
        }
        return false;
      }
      return false;
    } catch (e) {
      LoggerService.error('Error sincronizando participación: ${item.id}', context: 'SYNC_SERVICE', error: e);
      return false;
    }
  }

  /// Sincroniza cambios remotos -> local con resolución de conflictos
  Future<int> _syncRemoteToLocal(String userId) async {
    int conflictsResolved = 0;

    try {
      // Sincronizar planes
      conflictsResolved += await _syncPlansRemoteToLocal(userId);
      
      // Sincronizar eventos (de los planes del usuario)
      final userPlans = await _planLocalService.getPlansByUserId(userId);
      for (var plan in userPlans) {
        if (plan.id != null) {
          conflictsResolved += await _syncEventsRemoteToLocal(plan.id!);
        }
      }
      
      // Sincronizar participaciones
      conflictsResolved += await _syncParticipationsRemoteToLocal(userId);
    } catch (e) {
      LoggerService.error('Error sincronizando remoto -> local', context: 'SYNC_SERVICE', error: e);
    }

    return conflictsResolved;
  }

  /// Sincroniza planes remotos -> local con resolución de conflictos
  Future<int> _syncPlansRemoteToLocal(String userId) async {
    int conflictsResolved = 0;

    try {
      // Obtener planes remotos del usuario
      final remoteSnapshot = await _firestore
          .collection('plans')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in remoteSnapshot.docs) {
        final remotePlan = Plan.fromFirestore(doc);
        final localPlan = await _planLocalService.getPlanById(doc.id);

        if (localPlan == null) {
          // No existe localmente, guardar
          await _planLocalService.savePlan(remotePlan);
        } else {
          // Existe localmente, verificar conflictos
          if (remotePlan.updatedAt.isAfter(localPlan.updatedAt)) {
            // Remoto es más reciente, actualizar local
            await _planLocalService.savePlan(remotePlan);
            conflictsResolved++;
            LoggerService.database(
              'Conflicto resuelto (último cambio gana): Plan ${doc.id} (remoto más reciente)',
              operation: 'CONFLICT_RESOLVE',
            );
          } else if (localPlan.updatedAt.isAfter(remotePlan.updatedAt)) {
            // Local es más reciente, añadir a cola para sincronizar
            await _syncQueueService.enqueue(
              operation: 'update',
              collection: 'plans',
              documentId: doc.id,
              data: localPlan.toFirestore(),
            );
            conflictsResolved++;
            LoggerService.database(
              'Conflicto resuelto (último cambio gana): Plan ${doc.id} (local más reciente, añadido a cola)',
              operation: 'CONFLICT_RESOLVE',
            );
          }
          // Si son iguales, no hay conflicto
        }
      }
    } catch (e) {
      LoggerService.error('Error sincronizando planes remoto -> local', context: 'SYNC_SERVICE', error: e);
    }

    return conflictsResolved;
  }

  /// Sincroniza eventos remotos -> local con resolución de conflictos
  Future<int> _syncEventsRemoteToLocal(String planId) async {
    int conflictsResolved = 0;

    try {
      final remoteSnapshot = await _firestore
          .collection('events')
          .where('planId', isEqualTo: planId)
          .get();

      for (var doc in remoteSnapshot.docs) {
        final remoteEvent = Event.fromFirestore(doc);
        final localEvent = await _eventLocalService.getEventById(doc.id);

        if (localEvent == null) {
          // No existe localmente, guardar
          await _eventLocalService.saveEvent(remoteEvent);
        } else {
          // Existe localmente, verificar conflictos
          if (remoteEvent.updatedAt.isAfter(localEvent.updatedAt)) {
            // Remoto es más reciente, actualizar local
            await _eventLocalService.saveEvent(remoteEvent);
            conflictsResolved++;
            LoggerService.database(
              'Conflicto resuelto (último cambio gana): Event ${doc.id} (remoto más reciente)',
              operation: 'CONFLICT_RESOLVE',
            );
          } else if (localEvent.updatedAt.isAfter(remoteEvent.updatedAt)) {
            // Local es más reciente, añadir a cola
            await _syncQueueService.enqueue(
              operation: 'update',
              collection: 'events',
              documentId: doc.id,
              data: localEvent.toFirestore(),
            );
            conflictsResolved++;
            LoggerService.database(
              'Conflicto resuelto (último cambio gana): Event ${doc.id} (local más reciente, añadido a cola)',
              operation: 'CONFLICT_RESOLVE',
            );
          }
        }
      }
    } catch (e) {
      LoggerService.error('Error sincronizando eventos remoto -> local', context: 'SYNC_SERVICE', error: e);
    }

    return conflictsResolved;
  }

  /// Sincroniza participaciones remotas -> local con resolución de conflictos
  Future<int> _syncParticipationsRemoteToLocal(String userId) async {
    int conflictsResolved = 0;

    try {
      final remoteSnapshot = await _firestore
          .collection('plan_participations')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in remoteSnapshot.docs) {
        final remoteParticipation = PlanParticipation.fromFirestore(doc);
        final localParticipation = await _participationLocalService.getParticipation(
          remoteParticipation.planId,
          remoteParticipation.userId,
        );

        if (localParticipation == null) {
          // No existe localmente, guardar
          await _participationLocalService.saveParticipation(remoteParticipation);
        } else {
          // Existe localmente, verificar conflictos
          // PlanParticipation no tiene updatedAt, usar joinedAt como referencia
          if (remoteParticipation.joinedAt.isAfter(localParticipation.joinedAt)) {
            // Remoto es más reciente, actualizar local
            await _participationLocalService.saveParticipation(remoteParticipation);
            conflictsResolved++;
          } else if (localParticipation.joinedAt.isAfter(remoteParticipation.joinedAt)) {
            // Local es más reciente, añadir a cola
            await _syncQueueService.enqueue(
              operation: 'update',
              collection: 'participations',
              documentId: doc.id,
              data: localParticipation.toFirestore(),
            );
            conflictsResolved++;
          }
        }
      }
    } catch (e) {
      LoggerService.error('Error sincronizando participaciones remoto -> local', context: 'SYNC_SERVICE', error: e);
    }

    return conflictsResolved;
  }

  /// Convierte datos de Hive (ISO strings) a formato Firestore (Timestamps)
  Map<String, dynamic> _convertToFirestoreFormat(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (var entry in data.entries) {
      if (entry.value is String && _isIso8601Date(entry.value as String)) {
        try {
          final date = DateTime.parse(entry.value as String);
          result[entry.key] = Timestamp.fromDate(date);
        } catch (e) {
          result[entry.key] = entry.value;
        }
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Crea un Plan desde Map (similar a fromFirestore pero sin DocumentSnapshot)
  Plan _planFromMap(String? id, Map<String, dynamic> data) {
    final baseDate = (data['baseDate'] as Timestamp).toDate();
    final columnCount = data['columnCount'] ?? 1;
    final startDate = baseDate;
    final endDate = baseDate.add(Duration(days: columnCount - 1));
    
    return Plan(
      id: id,
      name: data['name'] ?? '',
      unpId: data['unpId'] ?? '',
      userId: data['userId'] ?? '',
      baseDate: baseDate,
      startDate: startDate,
      endDate: endDate,
      columnCount: columnCount,
      accommodation: data['accommodation'],
      description: data['description'],
      budget: data['budget']?.toDouble(),
      participants: data['participants'],
      imageUrl: data['imageUrl'],
      state: data['state'] ?? 'borrador',
      visibility: data['visibility'] ?? 'private',
      timezone: data['timezone'],
      currency: data['currency'] ?? 'EUR',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      savedAt: (data['savedAt'] as Timestamp).toDate(),
    );
  }

  /// Crea un Event desde Map (similar a fromFirestore pero sin DocumentSnapshot)
  /// Usa la lógica del EventLocalService pero accediendo directamente
  Event _eventFromMap(String? id, Map<String, dynamic> data) {
    // Convertir Timestamps a ISO strings para usar la lógica del servicio local
    final hiveData = <String, dynamic>{};
    for (var entry in data.entries) {
      if (entry.value is Timestamp) {
        hiveData[entry.key] = (entry.value as Timestamp).toDate().toIso8601String();
      } else {
        hiveData[entry.key] = entry.value;
      }
    }
    hiveData['_id'] = id;
    
    // Usar el método público del servicio local a través de un Future
    // Como esto es síncrono, necesitamos recrear la lógica aquí
    // Por ahora, usamos un enfoque más simple: crear el Event directamente desde los datos
    return _createEventFromData(id, data);
  }

  /// Crea un Event directamente desde datos de Firestore
  Event _createEventFromData(String? id, Map<String, dynamic> data) {
    // Helper para parsear fechas
    DateTime _parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      throw ArgumentError('Invalid date: $value');
    }

    final duration = data['duration'] ?? 1;
    final startMinute = data['startMinute'] ?? 0;
    final durationMinutes = data['durationMinutes'] ?? (duration * 60);
    
    final participantTrackIds = (data['participantTrackIds'] as List<dynamic>?)
        ?.map((id) => id.toString())
        .toList() ?? [];
    
    // Cargar parte común si existe
    EventCommonPart? commonPart;
    if (data['commonPart'] != null) {
      final cp = Map<String, dynamic>.from(data['commonPart'] as Map);
      if (cp['date'] is String) {
        cp['date'] = Timestamp.fromDate(DateTime.parse(cp['date'] as String));
      }
      commonPart = EventCommonPart.fromMap(cp);
    }
    
    // Cargar partes personales si existen
    Map<String, EventPersonalPart>? personalParts;
    if (data['personalParts'] != null) {
      final raw = Map<String, dynamic>.from(data['personalParts'] as Map);
      personalParts = raw.map((key, value) => 
        MapEntry(key, EventPersonalPart.fromMap(Map<String, dynamic>.from(value as Map))));
    }

    // Convertir documentos si existen
    List<EventDocument>? documents;
    if (data['documents'] != null) {
      final docsList = data['documents'] as List<dynamic>;
      documents = docsList.map((doc) {
        final docMap = Map<String, dynamic>.from(doc as Map);
        if (docMap['uploadedAt'] is String) {
          docMap['uploadedAt'] = Timestamp.fromDate(DateTime.parse(docMap['uploadedAt'] as String));
        }
        return EventDocument.fromMap(docMap);
      }).toList();
    }

    return Event(
      id: id,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      date: _parseDate(data['date']),
      hour: data['hour'] ?? (commonPart?.startHour ?? 0),
      duration: duration,
      startMinute: startMinute,
      durationMinutes: durationMinutes,
      description: data['description'] ?? commonPart?.description ?? '',
      color: data['color'] ?? commonPart?.customColor,
      typeFamily: data['typeFamily'] ?? commonPart?.family,
      typeSubtype: data['typeSubtype'] ?? commonPart?.subtype,
      details: (data['details'] as Map<String, dynamic>?) ?? commonPart?.extraData,
      documents: documents,
      participantTrackIds: participantTrackIds,
      isDraft: data['isDraft'] ?? false,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      commonPart: commonPart,
      personalParts: personalParts,
      baseEventId: data['baseEventId'],
      isBaseEvent: data['isBaseEvent'] ?? true,
      timezone: data['timezone'],
      arrivalTimezone: data['arrivalTimezone'],
      maxParticipants: data['maxParticipants'] as int?,
      requiresConfirmation: data['requiresConfirmation'] ?? false,
      cost: data['cost'] != null ? (data['cost'] as num).toDouble() : null,
    );
  }

  /// Crea una PlanParticipation desde Map
  PlanParticipation _participationFromMap(String? id, Map<String, dynamic> data) {
    return PlanParticipation(
      id: id,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      role: data['role'] ?? 'participant',
      personalTimezone: data['personalTimezone'],
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      invitedBy: data['invitedBy'],
      lastActiveAt: data['lastActiveAt'] != null 
          ? (data['lastActiveAt'] as Timestamp).toDate() 
          : null,
      status: data['status'],
      adminCreatedBy: data['_adminCreatedBy'],
    );
  }

  bool _isIso8601Date(String value) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(value);
  }
}

/// Resultado de una sincronización
class SyncResult {
  final bool success;
  final int itemsProcessed;
  final int conflictsResolved;

  SyncResult({
    required this.success,
    required this.itemsProcessed,
    required this.conflictsResolved,
  });
}

/// Resultado de sincronización de cola
class QueueSyncResult {
  final int itemsProcessed;
  final int itemsFailed;

  QueueSyncResult({
    required this.itemsProcessed,
    required this.itemsFailed,
  });
}


