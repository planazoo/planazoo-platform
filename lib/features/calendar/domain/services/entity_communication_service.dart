import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/communication_attachment.dart';
import '../models/entity_communication.dart';
import '../models/pending_email_event.dart';

const String _eventsCollection = 'events';
const String _communications = 'communications';
const String _pendingCollection = 'pending_email_events';

class EntityCommunicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _pendingRef(String userId, String id) {
    return _firestore.collection('users').doc(userId).collection(_pendingCollection).doc(id);
  }

  DocumentReference<Map<String, dynamic>> _commRef(String entityId, String id) {
    return _firestore.collection(_eventsCollection).doc(entityId).collection(_communications).doc(id);
  }

  Stream<List<EntityCommunication>> streamForEntity(String entityId) {
    return _firestore
        .collection(_eventsCollection)
        .doc(entityId)
        .collection(_communications)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(EntityCommunication.fromFirestore).toList();
      list.sort((a, b) {
        final da = a.placedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.placedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });
      return list;
    });
  }

  /// Mueve el pending al evento/alojamiento. [visibility] = `plan` | `private`.
  Future<void> placeOn({
    required String userId,
    required PendingEmailEvent pending,
    required String entityId,
    required String visibility,
  }) async {
    final vis = visibility == 'private' ? 'private' : 'plan';
    DocumentSnapshot<Map<String, dynamic>>? eventSnap;
    for (var i = 0; i < 8; i++) {
      eventSnap = await _firestore.collection(_eventsCollection).doc(entityId).get();
      if (eventSnap.exists) break;
      await Future<void>.delayed(Duration(milliseconds: 80 * (i + 1)));
    }
    if (eventSnap == null || !eventSnap.exists) {
      throw StateError('Entity not found');
    }
    final planId = eventSnap.data()?['planId'] as String?;
    if (planId == null || planId.isEmpty) {
      throw StateError('Entity has no planId');
    }

    final commRef = _commRef(entityId, pending.id);
    final pendingRef = _pendingRef(userId, pending.id);
    final fresh = await pendingRef.get();
    final latest = fresh.exists ? PendingEmailEvent.fromFirestore(fresh) : pending;
    // El objeto del wizard puede ser anterior a `setAttachments` / ingest MIME.
    final attachments = latest.attachments.isNotEmpty ? latest.attachments : pending.attachments;
    final data = <String, dynamic>{
      'kind': latest.kind.isNotEmpty ? latest.kind : 'email',
      'subject': latest.subject,
      'bodyPlain': latest.bodyPlain,
      'visibility': vis,
      'ownerId': userId,
      'planId': planId,
      'attachments': CommunicationAttachment.listToMaps(attachments),
      'createdAt': latest.createdAt != null
          ? Timestamp.fromDate(latest.createdAt!)
          : FieldValue.serverTimestamp(),
      'placedAt': FieldValue.serverTimestamp(),
    };
    if (latest.fromEmail != null && latest.fromEmail!.isNotEmpty) {
      data['fromEmail'] = latest.fromEmail;
    }
    if (latest.bodyHtml != null && latest.bodyHtml!.trim().isNotEmpty) {
      data['bodyHtml'] = latest.bodyHtml;
    }
    if (latest.templateId != null && latest.templateId!.isNotEmpty) {
      data['templateId'] = latest.templateId;
    }
    final batch = _firestore.batch();
    batch.set(commRef, data);
    batch.update(pendingRef, {
      'status': 'placed',
      'entityId': entityId,
      'planId': planId,
      'visibility': vis,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// Quita la copia de la ficha y la devuelve al buzón.
  Future<void> unplace({
    required String userId,
    required String entityId,
    required EntityCommunication communication,
  }) async {
    if (communication.ownerId != userId) {
      throw StateError('Not owner');
    }
    final commRef = _commRef(entityId, communication.id);
    final pendingRef = _pendingRef(userId, communication.id);
    final pendingSnap = await pendingRef.get();
    final pendingAtts = pendingSnap.exists
        ? PendingEmailEvent.fromFirestore(pendingSnap).attachments
        : const <CommunicationAttachment>[];
    final attachments =
        communication.attachments.isNotEmpty ? communication.attachments : pendingAtts;
    final batch = _firestore.batch();
    batch.set(pendingRef, {
      'subject': communication.subject,
      'bodyPlain': communication.bodyPlain,
      'status': 'pending',
      'createdAt': communication.createdAt != null
          ? Timestamp.fromDate(communication.createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (communication.fromEmail != null && communication.fromEmail!.trim().isNotEmpty)
        'fromEmail': communication.fromEmail,
      if (communication.bodyHtml != null && communication.bodyHtml!.trim().isNotEmpty)
        'bodyHtml': communication.bodyHtml,
      if (communication.parsed != null) 'parsed': communication.parsed,
      if (communication.templateId != null && communication.templateId!.isNotEmpty)
        'templateId': communication.templateId,
      'attachments': CommunicationAttachment.listToMaps(attachments),
      'kind': communication.kind.isNotEmpty ? communication.kind : 'email',
    });
    batch.delete(commRef);
    await batch.commit();
  }

  Future<void> setVisibility({
    required String entityId,
    required String communicationId,
    required String visibility,
  }) async {
    final vis = visibility == 'private' ? 'private' : 'plan';
    await _commRef(entityId, communicationId).update({'visibility': vis});
  }

  /// Crea una nota/comunicación ya colocada en el evento o alojamiento.
  Future<String> createManualOnEntity({
    required String userId,
    required String entityId,
    required String subject,
    required String bodyPlain,
    required String visibility,
  }) async {
    final vis = visibility == 'private' ? 'private' : 'plan';
    final eventSnap = await _firestore.collection(_eventsCollection).doc(entityId).get();
    if (!eventSnap.exists) {
      throw StateError('Entity not found');
    }
    final planId = eventSnap.data()?['planId'] as String?;
    if (planId == null || planId.isEmpty) {
      throw StateError('Entity has no planId');
    }
    final ref = _firestore
        .collection(_eventsCollection)
        .doc(entityId)
        .collection(_communications)
        .doc();
    await ref.set({
      'kind': 'manual',
      'subject': subject,
      'bodyPlain': bodyPlain,
      'visibility': vis,
      'ownerId': userId,
      'planId': planId,
      'attachments': const <Map<String, dynamic>>[],
      'createdAt': FieldValue.serverTimestamp(),
      'placedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> setAttachments({
    required String entityId,
    required String communicationId,
    required List<CommunicationAttachment> attachments,
  }) async {
    await _commRef(entityId, communicationId).update({
      'attachments': CommunicationAttachment.listToMaps(attachments),
    });
  }

  Future<void> updateManual({
    required String entityId,
    required String communicationId,
    required String subject,
    required String bodyPlain,
    required List<CommunicationAttachment> attachments,
  }) async {
    await _commRef(entityId, communicationId).update({
      'subject': subject,
      'bodyPlain': bodyPlain,
      'attachments': CommunicationAttachment.listToMaps(attachments),
    });
  }
}
