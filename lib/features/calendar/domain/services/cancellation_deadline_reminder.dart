import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/reservation_cancellation.dart';
import 'package:unp_calendario/features/notifications/domain/models/notification_model.dart';
import 'package:unp_calendario/features/notifications/domain/services/notification_service.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/services/push_notification_sender.dart';

/// Avisos al organizador cuando se acerca un límite de cancelación (T273).
///
/// - Al abrir el plan (cliente): refuerzo inmediato.
/// - Cron CF `checkCancellationDeadlines`: avisos sin abrir la app.
///
/// Fases según config del ítem (`reminderLeadHours` / `reminderAlsoOnDay`):
/// `h24` | `h48` | `h168` | `day`.
class CancellationDeadlineReminder {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  CancellationDeadlineReminder({
    FirebaseFirestore? firestore,
    NotificationService? notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService = notificationService ?? NotificationService();

  Future<void> scanPlanForOrganizer({
    required String planId,
    required String organizerUserId,
  }) async {
    try {
      final now = DateTime.now();

      final eventsSnap = await _firestore
          .collection('events')
          .where('planId', isEqualTo: planId)
          .get();

      final existing = await _existingDeadlineKeys(organizerUserId, planId);

      for (final doc in eventsSnap.docs) {
        final data = doc.data();
        final isAcc = data['typeFamily'] == 'alojamiento';
        ReservationCancellation? reservation;
        String label;
        if (isAcc) {
          final acc = Accommodation.fromFirestore(doc);
          reservation = acc.reservationCancellation;
          label = acc.hotelName;
        } else {
          final event = Event.fromFirestore(doc);
          reservation = event.reservationCancellation;
          label = event.description.isNotEmpty ? event.description : 'Evento';
        }
        if (reservation == null ||
            reservation.tiers.isEmpty ||
            !reservation.hasReminder) {
          continue;
        }

        for (final tier in reservation.tiers) {
          final deadline = tier.deadlineAt;
          if (!deadline.isAfter(now)) continue;

          for (final phase
              in reservation.activeReminderPhases(now, deadline)) {
            final key = dedupeKey(
              itemId: doc.id,
              deadline: deadline,
              refundPercent: tier.refundPercent,
              phase: phase,
            );
            if (existing.contains(key)) continue;

            final sent = await _notifyOrganizer(
              organizerUserId: organizerUserId,
              planId: planId,
              itemId: doc.id,
              isAccommodation: isAcc,
              label: label,
              tier: tier,
              phase: phase,
              dedupeKey: key,
            );
            if (sent) existing.add(key);
          }
        }
      }
    } catch (e, st) {
      LoggerService.error(
        'CancellationDeadlineReminder failed for $planId',
        context: 'T273',
        error: e,
        stackTrace: st,
      );
    }
  }

  static String dedupeKey({
    required String itemId,
    required DateTime deadline,
    required double refundPercent,
    required String phase,
  }) {
    return '$itemId|${deadline.toUtc().toIso8601String()}|$refundPercent|$phase';
  }

  Future<bool> _notifyOrganizer({
    required String organizerUserId,
    required String planId,
    required String itemId,
    required bool isAccommodation,
    required String label,
    required CancellationTier tier,
    required String phase,
    required String dedupeKey,
  }) async {
    final deadline = tier.deadlineAt;
    final deadlineStr =
        '${deadline.day.toString().padLeft(2, '0')}/'
        '${deadline.month.toString().padLeft(2, '0')}/'
        '${deadline.year} '
        '${deadline.hour.toString().padLeft(2, '0')}:'
        '${deadline.minute.toString().padLeft(2, '0')}';
    final percentStr = tier.refundPercent == tier.refundPercent.roundToDouble()
        ? tier.refundPercent.toStringAsFixed(0)
        : tier.refundPercent.toStringAsFixed(1);

    final title = phase == 'day'
        ? 'Cancelación: hoy es el límite'
        : 'Límite de cancelación próximo';
    final body = '$label: recuperas $percentStr% hasta $deadlineStr';

    final notification = NotificationModel(
      userId: organizerUserId,
      type: NotificationType.alarm,
      title: title,
      body: body,
      planId: planId,
      createdAt: DateTime.now(),
      data: {
        'kind': 'cancellationDeadline',
        'itemId': itemId,
        'isAccommodation': isAccommodation,
        'deadlineAt': deadline.toUtc().toIso8601String(),
        'refundPercent': tier.refundPercent,
        'phase': phase,
        'dedupeKey': dedupeKey,
      },
    );

    final id = await _notificationService.createNotification(
      organizerUserId,
      notification,
    );
    if (id == null) return false;

    await PushNotificationSender.trySendPushNotification(
      userId: organizerUserId,
      title: title,
      body: body,
      data: {
        'type': 'alarm',
        'planId': planId,
        'kind': 'cancellationDeadline',
        'phase': phase,
      },
    );
    return true;
  }

  Future<Set<String>> _existingDeadlineKeys(
    String userId,
    String planId,
  ) async {
    final snap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('planId', isEqualTo: planId)
        .where('type', isEqualTo: NotificationType.alarm.name)
        .get();
    final keys = <String>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      final payload = data['data'];
      if (payload is Map && payload['kind'] == 'cancellationDeadline') {
        final k = payload['dedupeKey']?.toString();
        if (k != null && k.isNotEmpty) {
          keys.add(k);
          // Compat fases antiguas `48h` → `h48`
          if (k.endsWith('|48h')) {
            keys.add('${k.substring(0, k.length - 4)}h48');
          }
        }
        final phase = payload['phase']?.toString();
        if ((phase == null || phase.isEmpty) &&
            k != null &&
            !k.contains('|h') &&
            !k.endsWith('|day') &&
            !k.endsWith('|48h')) {
          keys.add('$k|h48');
          keys.add('$k|48h');
        }
      }
    }
    return keys;
  }
}
