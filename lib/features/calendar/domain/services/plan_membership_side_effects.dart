import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';

/// Ítem futuro que desaparecerá al salir/expulsar (único participante).
class SoloOwnedPlanItem {
  final String id;
  final String title;
  final bool isAccommodation;
  final DateTime? date;

  const SoloOwnedPlanItem({
    required this.id,
    required this.title,
    required this.isAccommodation,
    this.date,
  });
}

/// Side effects de membresía en el plan (LISTA 121 — A2 + B2 + B3).
///
/// - **Al aceptar (A2):** ítems futuros `isForAllParticipants` → arrays + confirmación.
/// - **Al salir/expulsar (B2):** quitar userId de arrays en ítems futuros compartidos.
/// - **Al salir/expulsar (B3):** borrar ítems futuros donde era el **único** participante
///   (no «para todos»). Avisar en UI con [previewSoloOwnedFutureItems].
class PlanMembershipSideEffects {
  final FirebaseFirestore _firestore;

  PlanMembershipSideEffects({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _isOnOrAfterToday(DateTime? date) {
    if (date == null) return true;
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(_startOfToday());
  }

  static DateTime? _itemDate(Map<String, dynamic> data) {
    final isAloj = data['typeFamily']?.toString() == 'alojamiento';
    if (isAloj) {
      final checkIn = data['checkIn'] ??
          (data['commonPart'] is Map
              ? (data['commonPart'] as Map)['date']
              : null);
      return _asDate(checkIn) ?? _asDate(data['date']);
    }
    final common = data['commonPart'];
    if (common is Map) {
      return _asDate(common['date']) ?? _asDate(data['date']);
    }
    return _asDate(data['date']);
  }

  static DateTime? _asDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static bool _isForAll(Map<String, dynamic> data) {
    final common = data['commonPart'];
    if (common is Map && common.containsKey('isForAllParticipants')) {
      return common['isForAllParticipants'] == true;
    }
    if (data.containsKey('isForAllParticipants')) {
      return data['isForAllParticipants'] == true;
    }
    return true;
  }

  static Set<String> _effectiveParticipantIds(Map<String, dynamic> data) {
    final tracks = (data['participantTrackIds'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty) ??
        const <String>[];
    final common = data['commonPart'];
    final ids = common is Map
        ? ((common['participantIds'] as List?)
                ?.map((e) => e.toString())
                .where((e) => e.isNotEmpty) ??
            const <String>[])
        : const <String>[];
    return {...tracks, ...ids};
  }

  static String _itemTitle(Map<String, dynamic> data) {
    final common = data['commonPart'];
    if (common is Map) {
      final d = common['description']?.toString().trim();
      if (d != null && d.isNotEmpty) return d;
    }
    final top = data['description']?.toString().trim();
    if (top != null && top.isNotEmpty) return top;
    return data['typeFamily']?.toString() == 'alojamiento'
        ? 'Alojamiento'
        : 'Evento';
  }

  /// True si el ítem es selectivo y el único en las listas es [userId].
  static bool _isSoloOwnedBy(Map<String, dynamic> data, String userId) {
    if (_isForAll(data)) return false;
    final effective = _effectiveParticipantIds(data);
    return effective.length == 1 && effective.contains(userId);
  }

  /// Lista para el diálogo de confirmación (B3).
  Future<List<SoloOwnedPlanItem>> previewSoloOwnedFutureItems({
    required String planId,
    required String userId,
  }) async {
    try {
      final snap = await _firestore
          .collection('events')
          .where('planId', isEqualTo: planId)
          .get();
      final out = <SoloOwnedPlanItem>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        if (!_isOnOrAfterToday(_itemDate(data))) continue;
        if (!_isSoloOwnedBy(data, userId)) continue;
        out.add(
          SoloOwnedPlanItem(
            id: doc.id,
            title: _itemTitle(data),
            isAccommodation: data['typeFamily']?.toString() == 'alojamiento',
            date: _itemDate(data),
          ),
        );
      }
      out.sort((a, b) {
        final da = a.date ?? DateTime(1970);
        final db = b.date ?? DateTime(1970);
        return da.compareTo(db);
      });
      return out;
    } catch (e, st) {
      LoggerService.error(
        'previewSoloOwnedFutureItems failed: $planId / $userId',
        context: 'PLAN_MEMBERSHIP_SIDE_EFFECTS',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }

  /// A2: asignar a ítems compartidos futuros + confirmaciones pendientes.
  Future<void> onParticipantJoined({
    required String planId,
    required String userId,
  }) async {
    try {
      final snap = await _firestore
          .collection('events')
          .where('planId', isEqualTo: planId)
          .get();

      WriteBatch batch = _firestore.batch();
      var ops = 0;
      final confirmationEventIds = <String>[];

      Future<void> flush() async {
        if (ops == 0) return;
        await batch.commit();
        batch = _firestore.batch();
        ops = 0;
      }

      for (final doc in snap.docs) {
        final data = doc.data();
        if (!_isOnOrAfterToday(_itemDate(data))) continue;
        if (!_isForAll(data)) continue;

        batch.update(doc.reference, {
          'participantTrackIds': FieldValue.arrayUnion([userId]),
          'commonPart.participantIds': FieldValue.arrayUnion([userId]),
        });
        ops++;
        if (data['requiresConfirmation'] == true) {
          confirmationEventIds.add(doc.id);
        }
        if (ops >= 400) await flush();
      }
      await flush();

      for (final eventId in confirmationEventIds) {
        await _ensurePendingConfirmation(eventId: eventId, userId: userId);
      }

      LoggerService.info(
        'LISTA 121 A2: joined $userId plan $planId — shared future items + ${confirmationEventIds.length} confirmations',
        context: 'PLAN_MEMBERSHIP_SIDE_EFFECTS',
      );
    } catch (e, st) {
      LoggerService.error(
        'onParticipantJoined failed: $planId / $userId',
        context: 'PLAN_MEMBERSHIP_SIDE_EFFECTS',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _ensurePendingConfirmation({
    required String eventId,
    required String userId,
  }) async {
    try {
      final existing = await _firestore
          .collection('event_participants')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        final data = existing.docs.first.data();
        if (data['confirmationStatus'] == null) {
          await existing.docs.first.reference.update({
            'confirmationStatus': 'pending',
          });
        }
        return;
      }
      await _firestore.collection('event_participants').add({
        'eventId': eventId,
        'userId': userId,
        'registeredAt': Timestamp.fromDate(DateTime.now()),
        'confirmationStatus': 'pending',
      });
    } catch (e) {
      LoggerService.warning(
        'Could not ensure pending confirmation for $userId event $eventId: $e',
      );
    }
  }

  /// B2 + B3: borrar ítems futuros solo-suyos; quitar userId del resto.
  Future<void> onParticipantLeft({
    required String planId,
    required String userId,
  }) async {
    try {
      final snap = await _firestore
          .collection('events')
          .where('planId', isEqualTo: planId)
          .get();

      WriteBatch batch = _firestore.batch();
      var ops = 0;
      var deleted = 0;
      var stripped = 0;
      final deletedEventIds = <String>[];

      Future<void> flush() async {
        if (ops == 0) return;
        await batch.commit();
        batch = _firestore.batch();
        ops = 0;
      }

      for (final doc in snap.docs) {
        final data = doc.data();
        if (!_isOnOrAfterToday(_itemDate(data))) continue;

        if (_isSoloOwnedBy(data, userId)) {
          batch.delete(doc.reference);
          deletedEventIds.add(doc.id);
          deleted++;
          ops++;
          if (ops >= 400) await flush();
          continue;
        }

        final effective = _effectiveParticipantIds(data);
        if (!effective.contains(userId)) continue;

        batch.update(doc.reference, {
          'participantTrackIds': FieldValue.arrayRemove([userId]),
          'commonPart.participantIds': FieldValue.arrayRemove([userId]),
        });
        stripped++;
        ops++;
        if (ops >= 400) await flush();
      }
      await flush();

      for (final eventId in deletedEventIds) {
        await _deleteEventParticipantsForEvent(eventId);
      }

      LoggerService.info(
        'LISTA 121 B2+B3: left $userId plan $planId — deleted $deleted solo items, stripped $stripped',
        context: 'PLAN_MEMBERSHIP_SIDE_EFFECTS',
      );
    } catch (e, st) {
      LoggerService.error(
        'onParticipantLeft failed: $planId / $userId',
        context: 'PLAN_MEMBERSHIP_SIDE_EFFECTS',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _deleteEventParticipantsForEvent(String eventId) async {
    try {
      final snap = await _firestore
          .collection('event_participants')
          .where('eventId', isEqualTo: eventId)
          .get();
      if (snap.docs.isEmpty) return;
      WriteBatch batch = _firestore.batch();
      var ops = 0;
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
        ops++;
        if (ops >= 400) {
          await batch.commit();
          batch = _firestore.batch();
          ops = 0;
        }
      }
      if (ops > 0) await batch.commit();
    } catch (e) {
      LoggerService.warning(
        'Could not delete event_participants for event $eventId: $e',
      );
    }
  }
}
