import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  static const String _collectionName = 'events';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los eventos de un plan
  Stream<List<Event>> getEventsByPlanId(String planId) {
    return _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .orderBy('date')
        .orderBy('hour')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc))
            .toList());
  }

  // Obtener eventos de un plan para una fecha específica
  Stream<List<Event>> getEventsByPlanIdAndDate(String planId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .orderBy('hour')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc))
            .toList());
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

  // Crear un nuevo evento
  Future<String?> createEvent(Event event) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      // Error creating event: $e
      return null;
    }
  }

  // Actualizar un evento existente
  Future<bool> updateEvent(Event event) async {
    try {
      if (event.id == null) return false;
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
  Future<bool> saveEvent(Event event) async {
    if (event.id == null) {
      final now = DateTime.now();
      final newEvent = event.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      final id = await createEvent(newEvent);
      return id != null;
    } else {
      final updatedEvent = event.copyWith(
        updatedAt: DateTime.now(),
      );
      return await updateEvent(updatedEvent);
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

  // Obtener solo eventos confirmados de un plan
  Stream<List<Event>> getConfirmedEventsByPlanId(String planId) {
    return _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .where('isDraft', isEqualTo: false)
        .orderBy('date')
        .orderBy('hour')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc))
            .toList());
  }

  // Obtener solo eventos en borrador de un plan
  Stream<List<Event>> getDraftEventsByPlanId(String planId) {
    return _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .where('isDraft', isEqualTo: true)
        .orderBy('date')
        .orderBy('hour')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc))
            .toList());
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
} 