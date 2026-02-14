import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pending_email_event.dart';

const String _collectionName = 'pending_email_events';

class PendingEmailEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream de eventos pendientes del usuario, ordenados por fecha de creación (más recientes primero).
  Stream<List<PendingEmailEvent>> streamPendingEvents(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PendingEmailEvent.fromFirestore(doc)).toList());
  }

  /// Lista una sola vez; filtra por status 'pending' en memoria (evita índice compuesto).
  Future<List<PendingEmailEvent>> getPendingEvents(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PendingEmailEvent.fromFirestore(doc))
        .where((e) => e.status == 'pending')
        .toList();
  }

  /// Cuenta de pendientes con status 'pending' (en memoria).
  Future<int> countPending(String userId) async {
    final list = await getPendingEvents(userId);
    return list.length;
  }

  /// Marca el documento como asignado (tras crear el evento en un plan).
  Future<void> markAsAssigned(String userId, String pendingEventId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collectionName)
        .doc(pendingEventId)
        .update({
      'status': 'assigned',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Elimina el documento (alternativa a marcar asignado).
  Future<void> delete(String userId, String pendingEventId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collectionName)
        .doc(pendingEventId)
        .delete();
  }

  /// Marca como descartado.
  Future<void> markAsDiscarded(String userId, String pendingEventId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(_collectionName)
        .doc(pendingEventId)
        .update({
      'status': 'discarded',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
