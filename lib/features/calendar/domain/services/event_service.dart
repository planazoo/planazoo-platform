import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/plan_participation.dart';
import 'plan_participation_service.dart';

class EventService {
  static const String _collectionName = 'events';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlanParticipationService _participationService = PlanParticipationService();

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
            .map((snapshot) => snapshot.docs
                .map((doc) => Event.fromFirestore(doc))
                .toList());
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
      // Error getting event by id: $e
      return null;
    }
  }

  // Crear un nuevo evento (solo para participantes del plan)
  Future<String?> createEvent(Event event) async {
    try {
      // Verificar que el usuario participa en el plan
      final isParticipant = await _participationService.isUserParticipant(event.planId, event.userId);
      if (!isParticipant) {
        return null;
      }

      final docRef = await _firestore.collection(_collectionName).add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      // Error creating event: $e
      return null;
    }
  }

  // Actualizar un evento existente (solo para participantes del plan)
  Future<bool> updateEvent(Event event) async {
    try {
      if (event.id == null) return false;
      
      // Verificar que el usuario participa en el plan
      final isParticipant = await _participationService.isUserParticipant(event.planId, event.userId);
      if (!isParticipant) {
        return false;
      }

      await _firestore.collection(_collectionName).doc(event.id).update(event.toFirestore());
      return true;
    } catch (e) {
      // Error updating event: $e
      return false;
    }
  }

  // Eliminar un evento
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collectionName).doc(eventId).delete();
      return true;
    } catch (e) {
      // Error deleting event: $e
      return false;
    }
  }

  // Guardar evento (crear o actualizar)
  Future<Event?> saveEvent(Event event) async {
    if (event.id == null) {
      final now = DateTime.now();
      final newEvent = event.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      final id = await createEvent(newEvent);
      if (id != null) {
        return newEvent.copyWith(id: id);
      }
      return null;
    } else {
      final updatedEvent = event.copyWith(
        updatedAt: DateTime.now(),
      );
      final success = await updateEvent(updatedEvent);
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
      // Error toggling draft status: $e
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
  Future<bool> deleteEventsByPlanId(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      // Error deleting events by planId: $e
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
} 