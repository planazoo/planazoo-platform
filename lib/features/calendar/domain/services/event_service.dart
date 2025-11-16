import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/security/services/rate_limiter_service.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/event.dart';
import '../models/plan_participation.dart';
import 'plan_participation_service.dart';
import 'event_participant_service.dart';
import 'event_sync_service.dart';
import 'timezone_service.dart';

class EventService {
  static const String _collectionName = 'events';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlanParticipationService _participationService = PlanParticipationService();
  final EventParticipantService _eventParticipantService = EventParticipantService();
  final EventSyncService _eventSyncService = EventSyncService();

  // Obtener todos los eventos de un plan (solo para participantes)
  Stream<List<Event>> getEventsByPlanId(String planId, String userId) {
    return _participationService.isUserParticipant(planId, userId).asStream().asyncExpand((isParticipant) async* {

      if (isParticipant) {
        yield* _firestore
            .collection(_collectionName)
            .where('planId', isEqualTo: planId)
            .orderBy('date')
            .orderBy('hour')
            .snapshots()
            .map((snapshot) {
              final events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

              return events;
            });
      } else {

        yield <Event>[];
      }
    });
  }

  Future<List<Event>> _getEventsForParticipant(String planId, String userId) async {
    final isParticipant = await _participationService.isUserParticipant(planId, userId);
    if (!isParticipant) return <Event>[];
    
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .orderBy('date')
        .orderBy('hour')
        .get();
    
    return snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .toList();
  }

  // Obtener eventos de un plan para una fecha específica (solo para participantes)
  Stream<List<Event>> getEventsByPlanIdAndDate(String planId, DateTime date, String userId) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _participationService.isUserParticipant(planId, userId).asStream().asyncExpand((isParticipant) async* {
      if (isParticipant) {
        yield* _firestore
            .collection(_collectionName)
            .where('planId', isEqualTo: planId)
            .where('date', isGreaterThanOrEqualTo: startOfDay)
            .where('date', isLessThan: endOfDay)
            .orderBy('hour')
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => Event.fromFirestore(doc))
                .toList());
      } else {
        yield <Event>[];
      }
    });
  }

  Future<List<Event>> _getEventsForDateAndParticipant(String planId, DateTime startOfDay, DateTime endOfDay, String userId) async {
    final isParticipant = await _participationService.isUserParticipant(planId, userId);
    if (!isParticipant) return <Event>[];
    
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .orderBy('hour')
        .get();
    
    return snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .toList();
  }

  // Obtener un evento específico
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(eventId).get();
      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting event by id', context: 'EVENT_SERVICE', error: e);
      return null;
    }
  }

  // Crear un nuevo evento (solo para participantes del plan)
  Future<String?> createEvent(Event event) async {
    try {
      // Verificar rate limiting para creación de eventos
      final rateLimiter = RateLimiterService();
      final eventLimitCheck = await rateLimiter.checkEventCreation(event.planId);
      
      if (!eventLimitCheck.allowed) {
        throw Exception(eventLimitCheck.getErrorMessage());
      }
      
      // Verificar que el usuario participa en el plan
      final isParticipant = await _participationService.isUserParticipant(event.planId, event.userId);

      if (!isParticipant) {
        return null;
      }

      // Guardar evento tal como está (sin conversión a UTC por ahora)
      Event eventToSave = event;

      final docRef = await _firestore.collection(_collectionName).add(eventToSave.toFirestore());

      // Registrar creación exitosa de evento
      await rateLimiter.recordEventCreation(event.planId);

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Actualizar un evento existente (solo para participantes del plan)
  Future<bool> updateEvent(Event event, {bool skipSync = false}) async {
    try {
      if (event.id == null) return false;
      
      // Verificar que el usuario participa en el plan (solo si no es actualización de sincronización)
      if (!skipSync) {
        final isParticipant = await _participationService.isUserParticipant(event.planId, event.userId);
        if (!isParticipant) {
          return false;
        }
      }

      // Guardar evento tal como está (sin conversión a UTC por ahora)
      Event eventToSave = event;

      await _firestore.collection(_collectionName).doc(event.id).update(eventToSave.toFirestore());
      return true;
    } catch (e) {
      LoggerService.error('Error updating event', context: 'EVENT_SERVICE', error: e);
      return false;
    }
  }

  // Eliminar un evento
  /// 
  /// Elimina un evento y todos sus datos relacionados:
  /// 1. event_participants (participantes registrados en el evento)
  /// 2. Copias del evento (si es un evento base con copias)
  /// 3. El evento mismo
  /// 
  /// NOTA: Los documentos adjuntos en Firebase Storage deberían eliminarse
  /// desde el código que llama a este método si es necesario.
  Future<bool> deleteEvent(String eventId) async {
    try {
      final event = await getEventById(eventId);
      if (event == null) return false;
      
      // 1. Eliminar todos los event_participants del evento
      await _eventParticipantService.deleteAllParticipants(eventId);
      
      // 2. Si es un evento base, eliminar todas sus copias
      if (event.isBaseEvent) {
        await _eventSyncService.deleteEventCopies(eventId);
      }
      
      // 3. Si es una copia, no hay que hacer nada especial (las copias no tienen copias propias)
      
      // 4. Eliminar el evento
      await _firestore.collection(_collectionName).doc(eventId).delete();
      
      LoggerService.database('Event deleted successfully: $eventId', operation: 'DELETE');
      return true;
    } catch (e) {
      LoggerService.error('Error deleting event', context: 'EVENT_SERVICE', error: e);
      return false;
    }
  }

  // Guardar evento (crear o actualizar) con sincronización automática
  Future<Event?> saveEvent(Event event, {bool skipSync = false}) async {
    if (event.id == null) {
      // CREAR NUEVO EVENTO
      final now = DateTime.now();
      final newEvent = event.copyWith(
        createdAt: now,
        updatedAt: now,
        isBaseEvent: true, // Asegurar que es evento base
        baseEventId: null, // No tiene evento base
      );
      
      final id = await createEvent(newEvent);
      if (id != null) {
        final createdEvent = newEvent.copyWith(id: id);
        
        // Si requiere confirmación, crear registros pendientes para todos los participantes (T120 Fase 2)
        if (createdEvent.requiresConfirmation) {
          final eventParticipantService = EventParticipantService();
          await eventParticipantService.createPendingConfirmationsForAllParticipants(
            eventId: id,
            planId: createdEvent.planId,
          );
        }
        
        return createdEvent;
      }
      return null;
    } else {
      // ACTUALIZAR EVENTO EXISTENTE
      final oldEvent = await getEventById(event.id!);
      if (oldEvent == null) return null;
      
      final updatedEvent = event.copyWith(
        updatedAt: DateTime.now(),
      );
      
      // Si requiresConfirmation cambió de false a true, crear confirmaciones pendientes (T120 Fase 2)
      if (!oldEvent.requiresConfirmation && updatedEvent.requiresConfirmation) {
        final eventParticipantService = EventParticipantService();
        await eventParticipantService.createPendingConfirmationsForAllParticipants(
          eventId: event.id!,
          planId: updatedEvent.planId,
        );
      }
      
      // Actualizar el evento
      final success = await updateEvent(updatedEvent, skipSync: skipSync);
      return success ? updatedEvent : null;
    }
  }

  // Cambiar el estado de borrador de un evento
  Future<bool> toggleDraftStatus(String eventId, bool isDraft) async {
    try {
      await _firestore.collection(_collectionName).doc(eventId).update({
        'isDraft': isDraft,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      LoggerService.error('Error toggling draft status', context: 'EVENT_SERVICE', error: e);
      return false;
    }
  }

  // Confirmar un evento (cambiar de borrador a confirmado)
  Future<bool> confirmEvent(String eventId) async {
    return await toggleDraftStatus(eventId, false);
  }

  // Marcar un evento como borrador
  Future<bool> markAsDraft(String eventId) async {
    return await toggleDraftStatus(eventId, true);
  }

  // Obtener solo eventos confirmados de un plan (solo para participantes)
  Stream<List<Event>> getConfirmedEventsByPlanId(String planId, String userId) {
    return _participationService.isUserParticipant(planId, userId).asStream().asyncExpand((isParticipant) async* {
      if (isParticipant) {
        yield* _firestore
            .collection(_collectionName)
            .where('planId', isEqualTo: planId)
            .where('isDraft', isEqualTo: false)
            .orderBy('date')
            .orderBy('hour')
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => Event.fromFirestore(doc))
                .toList());
      } else {
        yield <Event>[];
      }
    });
  }

  Future<List<Event>> _getConfirmedEventsForParticipant(String planId, String userId) async {
    final isParticipant = await _participationService.isUserParticipant(planId, userId);
    if (!isParticipant) return <Event>[];
    
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .where('isDraft', isEqualTo: false)
        .orderBy('date')
        .orderBy('hour')
        .get();
    
    return snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .toList();
  }

  // Obtener solo eventos en borrador de un plan (solo para participantes)
  Stream<List<Event>> getDraftEventsByPlanId(String planId, String userId) {
    return _participationService.isUserParticipant(planId, userId).asStream().asyncExpand((isParticipant) async* {
      if (isParticipant) {
        yield* _firestore
            .collection(_collectionName)
            .where('planId', isEqualTo: planId)
            .where('isDraft', isEqualTo: true)
            .orderBy('date')
            .orderBy('hour')
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => Event.fromFirestore(doc))
                .toList());
      } else {
        yield <Event>[];
      }
    });
  }

  Future<List<Event>> _getDraftEventsForParticipant(String planId, String userId) async {
    final isParticipant = await _participationService.isUserParticipant(planId, userId);
    if (!isParticipant) return <Event>[];
    
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .where('isDraft', isEqualTo: true)
        .orderBy('date')
        .orderBy('hour')
        .get();
    
    return snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .toList();
  }

  // Eliminar todos los eventos de un plan
  /// 
  /// Elimina todos los eventos de un plan y sus datos relacionados.
  /// 
  /// NOTA: Los event_participants se eliminan antes desde PlanService.deletePlan(),
  /// pero este método también los elimina por si se llama directamente.
  /// 
  /// Orden de eliminación:
  /// 1. event_participants de cada evento
  /// 2. Copias de eventos base
  /// 3. Eventos del plan
  Future<bool> deleteEventsByPlanId(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return true; // No hay eventos, no hay nada que eliminar
      }

      // Eliminar datos relacionados de cada evento antes de eliminar los eventos
      for (final doc in querySnapshot.docs) {
        final eventId = doc.id;
        final eventData = doc.data();
        final isBaseEvent = eventData['isBaseEvent'] as bool? ?? false;
        
        // 1. Eliminar event_participants del evento
        await _eventParticipantService.deleteAllParticipants(eventId);
        
        // 2. Si es un evento base, eliminar sus copias
        if (isBaseEvent) {
          await _eventSyncService.deleteEventCopies(eventId);
        }
      }

      // 3. Eliminar todos los eventos en batch
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      LoggerService.database('All events deleted for plan: $planId (${querySnapshot.docs.length} events)', operation: 'DELETE');
      return true;
    } catch (e) {
      LoggerService.error('Error deleting events by planId', context: 'EVENT_SERVICE', error: e);
      return false;
    }
  }

  // Migrar eventos existentes para agregar userId
  Future<bool> migrateEventsWithUserId(String userId) async {
    try {
      // Obtener TODOS los eventos para verificar cuáles necesitan migración
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return true; // No hay eventos para migrar
      }

      // Filtrar eventos que no tienen userId o tienen userId vacío
      final eventsToMigrate = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final eventUserId = data['userId'];
        return eventUserId == null || eventUserId == '';
      }).toList();

      if (eventsToMigrate.isEmpty) {
        return true; // No hay eventos para migrar
      }

      // Actualizar todos los eventos que necesitan migración en lotes
      final batch = _firestore.batch();
      for (final doc in eventsToMigrate) {
        batch.update(doc.reference, {'userId': userId});
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== MÉTODOS DE TIMEZONE ==========
  
  /// Convierte un evento de timezone local a UTC para almacenamiento
  Event _convertEventToUtc(Event event) {
    if (event.timezone == null || event.timezone!.isEmpty) {
      return event;
    }
    
    // Crear DateTime local del evento
    final localDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );
    
    // Convertir a UTC
    final utcDateTime = TimezoneService.localToUtc(localDateTime, event.timezone!);
    
    // Crear evento con fecha/hora UTC
    return event.copyWith(
      date: utcDateTime,
      hour: utcDateTime.hour,
      startMinute: utcDateTime.minute,
    );
  }
  
  /// Convierte un evento de UTC a timezone local para mostrar
  Event _convertEventFromUtc(Event event) {
    if (event.timezone == null || event.timezone!.isEmpty) {
      return event;
    }
    
    // Crear DateTime UTC del evento
    final utcDateTime = DateTime.utc(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );
    
    // Convertir a timezone local
    final localDateTime = TimezoneService.utcToLocal(utcDateTime, event.timezone!);
    
    // Crear evento con fecha/hora local
    return event.copyWith(
      date: localDateTime,
      hour: localDateTime.hour,
      startMinute: localDateTime.minute,
    );
  }

  // ========== MÉTODOS DE SINCRONIZACIÓN ==========
  // NOTA: Los métodos de sincronización se han movido a EventSyncService
  // para evitar dependencias circulares. Usar EventSyncService directamente.
} 
