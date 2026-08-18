// ignore_for_file: unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/security/services/rate_limiter_service.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/event.dart';
import 'plan_participation_service.dart';
import 'event_participant_service.dart';
import 'event_sync_service.dart';
import 'timezone_service.dart';
import 'plan_event_accent_colors.dart';
import 'guarantee_payment_sync.dart';

class EventService {
  EventService({
    FirebaseFirestore? firestore,
    EventParticipantService? eventParticipantService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _eventParticipantServiceOverride = eventParticipantService;

  static const String _collectionName = 'events';
  final FirebaseFirestore _firestore;
  final EventParticipantService? _eventParticipantServiceOverride;
  PlanParticipationService? _lazyParticipationService;
  EventParticipantService? _lazyEventParticipantService;
  EventSyncService? _lazyEventSyncService;
  GuaranteePaymentSync? _lazyGuaranteePaymentSync;

  PlanParticipationService get _participationService =>
      _lazyParticipationService ??=
          PlanParticipationService(firestore: _firestore);

  EventParticipantService get _eventParticipantService =>
      _eventParticipantServiceOverride ??
      (_lazyEventParticipantService ??=
          EventParticipantService(firestore: _firestore));

  EventSyncService get _eventSyncService =>
      _lazyEventSyncService ??= EventSyncService();

  GuaranteePaymentSync get _guaranteePaymentSync =>
      _lazyGuaranteePaymentSync ??= GuaranteePaymentSync();

  /// Excluye documentos de la colección 'events' que son alojamientos (typeFamily == 'alojamiento').
  static bool _isEventDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return data == null || data['typeFamily'] != 'alojamiento';
  }

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
              final events = snapshot.docs
                  .where(_isEventDoc)
                  .map((doc) => Event.fromFirestore(doc))
                  .toList();
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
        .where(_isEventDoc)
        .map((doc) => Event.fromFirestore(doc))
        .toList();
  }

  /// Obtiene los eventos del plan desde el servidor (evita caché local).
  /// Útil tras guardar cambios para que la UI muestre datos actualizados en iOS/web.
  Future<List<Event>> getEventsByPlanIdFromServer(String planId, String userId) async {
    final isParticipant = await _participationService.isUserParticipant(planId, userId);
    if (!isParticipant) return <Event>[];
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .orderBy('date')
        .orderBy('hour')
        .get(const GetOptions(source: Source.server));
    return snapshot.docs
        .where(_isEventDoc)
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
                .where(_isEventDoc)
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
        .where(_isEventDoc)
        .map((doc) => Event.fromFirestore(doc))
        .toList();
  }

  // Obtener un evento específico
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(eventId).get();
      if (doc.exists && _isEventDoc(doc)) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting event by id', context: 'EVENT_SERVICE', error: e);
      return null;
    }
  }

  /// Obtiene un evento por ID desde el servidor (evita caché).
  Future<Event?> getEventByIdFromServer(String eventId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(eventId)
          .get(const GetOptions(source: Source.server));
      if (doc.exists && _isEventDoc(doc)) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting event by id from server', context: 'EVENT_SERVICE', error: e);
      return null;
    }
  }

  // Crear un nuevo evento (solo para participantes del plan)
  Future<String?> createEvent(Event event) async {
    try {
      // Verificar rate limiting para creación de eventos
      final rateLimiter = RateLimiterService();
      final eventLimitCheck = await rateLimiter
          .checkEventCreation(event.planId)
          .timeout(const Duration(seconds: 2), onTimeout: () {
        // En offline no bloqueamos creación por rate-limit remoto.
        return RateLimitResult(
          allowed: true,
          remainingAttempts: 1,
          requiresCaptcha: false,
        );
      });

      if (!eventLimitCheck.allowed) {
        throw Exception(eventLimitCheck.getErrorMessage());
      }
      
      // Verificar que el usuario participa en el plan
      final isParticipant = await _participationService
          .isUserParticipant(event.planId, event.userId)
          .timeout(const Duration(seconds: 2), onTimeout: () {
        // En offline permitimos continuar; Firestore/rules validará al sincronizar.
        return true;
      });
      if (!isParticipant) {
        LoggerService.warning(
          'createEvent blocked: user ${event.userId} is not participant of plan ${event.planId}',
          context: 'EVENT_SERVICE',
        );
        return null;
      }

      // Guardar evento tal como está (sin conversión a UTC por ahora)
      Event eventToSave = event;

      final docRef = await _firestore.collection(_collectionName).add(eventToSave.toFirestore());

      // Registrar creación exitosa de evento
      await rateLimiter.recordEventCreation(event.planId);

      LoggerService.database('Event created: ${docRef.id}', operation: 'CREATE');
      await _guaranteePaymentSync.sync(
        planId: event.planId,
        eventId: docRef.id,
        reservation: event.reservationCancellation,
        itemLabel: event.description,
        registeredBy: event.userId,
      );
      return docRef.id;
    } catch (e, st) {
      LoggerService.error(
        'Error creating event for plan ${event.planId}',
        context: 'EVENT_SERVICE',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // Actualizar un evento existente (solo para participantes del plan)
  Future<bool> updateEvent(Event event, {bool skipSync = false}) async {
    try {
      if (event.id == null) return false;
      
      // Verificar que el usuario participa en el plan (solo si no es actualización de sincronización)
      if (!skipSync) {
        final isParticipant = await _participationService
            .isUserParticipant(event.planId, event.userId)
            .timeout(const Duration(seconds: 2), onTimeout: () => true);
        if (!isParticipant) {
          return false;
        }
      }

      // Guardar evento tal como está (sin conversión a UTC por ahora)
      Event eventToSave = event;

      final data = eventToSave.toFirestore();
      if (eventToSave.reservationCancellation?.nextDeadline == null) {
        data['nextCancellationDeadline'] = FieldValue.delete();
      }

      await _firestore.collection(_collectionName).doc(event.id).update(data);
      await _guaranteePaymentSync.sync(
        planId: event.planId,
        eventId: event.id,
        reservation: event.reservationCancellation,
        itemLabel: event.description,
        registeredBy: event.userId,
      );
      return true;
    } catch (e) {
      LoggerService.error('Error updating event', context: 'EVENT_SERVICE', error: e);
      return false;
    }
  }

  /// T272: actualiza color/carril de todos los eventos del plan cuya familia esté en [typeFamilies].
  /// Familia «Otro» incluye eventos sin `typeFamily`. Devuelve el número de documentos tocados.
  Future<int> updateAccentColorForTypeFamilies({
    required String planId,
    required List<String> typeFamilies,
    required String colorName,
  }) async {
    if (planId.isEmpty || typeFamilies.isEmpty || colorName.trim().isEmpty) {
      return 0;
    }
    final targets = typeFamilies
        .map(PlanEventAccentColors.normalizeFamily)
        .toSet();
    final includeEmptyAsOtro = targets.contains('Otro');
    final color = colorName.trim();

    try {
      final snap = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .get();

      final refs = <DocumentReference<Map<String, dynamic>>>[];
      for (final doc in snap.docs) {
        if (!_isEventDoc(doc)) continue;
        final data = doc.data();
        final topFamily = data['typeFamily']?.toString();
        final common = data['commonPart'];
        final commonFamily = common is Map ? common['family']?.toString() : null;
        final rawFamily = (topFamily != null && topFamily.trim().isNotEmpty)
            ? topFamily
            : commonFamily;
        final normalized = PlanEventAccentColors.normalizeFamily(rawFamily);
        final empty =
            rawFamily == null || rawFamily.trim().isEmpty;
        if (!targets.contains(normalized) &&
            !(includeEmptyAsOtro && empty)) {
          continue;
        }
        refs.add(doc.reference);
      }

      const chunkSize = 400;
      for (var i = 0; i < refs.length; i += chunkSize) {
        final batch = _firestore.batch();
        final end = (i + chunkSize < refs.length) ? i + chunkSize : refs.length;
        for (var j = i; j < end; j++) {
          batch.update(refs[j], {
            'color': color,
            'commonPart.customColor': color,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }
        await batch.commit();
      }
      return refs.length;
    } catch (e, st) {
      LoggerService.error(
        'Error updating accent colors for plan $planId',
        context: 'EVENT_SERVICE',
        error: e,
        stackTrace: st,
      );
      return 0;
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
                .where(_isEventDoc)
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
        .where(_isEventDoc)
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
                .where(_isEventDoc)
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
        .where(_isEventDoc)
        .map((doc) => Event.fromFirestore(doc))
        .toList();
  }

  static bool _isAccommodationDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return data != null && data['typeFamily'] == 'alojamiento';
  }

  /// Eliminar todos los documentos de `events` del plan (eventos y alojamientos).
  ///
  /// También borra event_participants y copias de eventos base.
  Future<bool> deleteEventsByPlanId(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return true;
      }

      final eventDocs = querySnapshot.docs.where(_isEventDoc).toList();
      final accommodationDocs =
          querySnapshot.docs.where(_isAccommodationDoc).toList();

      if (eventDocs.isEmpty && accommodationDocs.isEmpty) {
        return true;
      }

      for (final doc in eventDocs) {
        final eventId = doc.id;
        final eventData = doc.data();
        final isBaseEvent = eventData['isBaseEvent'] as bool? ?? false;

        await _eventParticipantService.deleteAllParticipants(eventId);

        if (isBaseEvent) {
          await _eventSyncService.deleteEventCopies(eventId);
        }
      }

      final batch = _firestore.batch();
      for (final doc in eventDocs) {
        batch.delete(doc.reference);
      }
      for (final doc in accommodationDocs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      LoggerService.database(
        'All events/accommodations deleted for plan: $planId '
        '(${eventDocs.length} events, ${accommodationDocs.length} accommodations)',
        operation: 'DELETE',
      );
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

      // Filtrar eventos que no tienen userId o tienen userId vacío (excluir alojamientos)
      final eventsToMigrate = querySnapshot.docs.where((doc) {
        if (!_isEventDoc(doc)) return false;
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
