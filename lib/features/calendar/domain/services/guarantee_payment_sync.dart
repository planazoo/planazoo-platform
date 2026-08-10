import '../../../../shared/services/logger_service.dart';
import '../../../payments/domain/models/personal_payment.dart';
import '../../../payments/domain/services/payment_service.dart';
import '../models/reservation_cancellation.dart';

/// Sincroniza la garantía (T273) con `personal_payments` para Pagos/balances.
class GuaranteePaymentSync {
  final PaymentService _paymentService;

  GuaranteePaymentSync({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService();

  /// Upsert o elimina el pago `guarantee` ligado al evento o alojamiento.
  Future<void> sync({
    required String planId,
    String? eventId,
    String? accommodationId,
    required ReservationCancellation? reservation,
    required String itemLabel,
    String? registeredBy,
  }) async {
    try {
      if ((eventId == null || eventId.isEmpty) &&
          (accommodationId == null || accommodationId.isEmpty)) {
        return;
      }

      final existing = await _findGuaranteePayment(
        planId: planId,
        eventId: eventId,
        accommodationId: accommodationId,
      );

      final hasGuarantee = reservation != null &&
          reservation.hasGuarantee &&
          reservation.guaranteePayerUserId != null &&
          reservation.guaranteePayerUserId!.isNotEmpty;

      if (!hasGuarantee) {
        if (existing?.id != null) {
          await _paymentService.deletePayment(existing!.id!);
        }
        return;
      }

      final amount = reservation.guaranteeAmount!;
      final payerId = reservation.guaranteePayerUserId!;
      final status = _mapGuaranteeStatus(reservation.guaranteeStatus);
      final concept = _conceptFor(itemLabel);
      final now = DateTime.now();

      if (existing == null) {
        await _paymentService.createPayment(
          PersonalPayment(
            planId: planId,
            participantId: payerId,
            eventId: eventId,
            accommodationId: accommodationId,
            paymentKind: 'guarantee',
            amount: amount,
            paymentDate: now,
            concept: concept,
            description: reservation.guaranteeNote,
            status: status,
            registeredBy: registeredBy,
            createdAt: now,
            updatedAt: now,
          ),
          createdBy: registeredBy,
        );
      } else {
        await _paymentService.updatePayment(
          existing.copyWith(
            participantId: payerId,
            amount: amount,
            concept: concept,
            description: reservation.guaranteeNote,
            status: status,
            updatedAt: now,
          ),
        );
      }
    } catch (e, st) {
      LoggerService.error(
        'GuaranteePaymentSync failed plan=$planId event=$eventId acc=$accommodationId',
        context: 'T273',
        error: e,
        stackTrace: st,
      );
    }
  }

  String _mapGuaranteeStatus(String guaranteeStatus) {
    switch (guaranteeStatus) {
      case 'paid':
        return 'paid';
      case 'refunded':
        return 'refunded';
      case 'retained':
        return 'paid'; // el dinero sigue “adelantado” hasta resolver
      case 'pending':
      default:
        return 'pending';
    }
  }

  String _conceptFor(String itemLabel) {
    final label = itemLabel.trim();
    final base = label.isEmpty ? 'Garantía reserva' : 'Garantía: $label';
    if (base.length <= 100) return base;
    return '${base.substring(0, 97)}...';
  }

  Future<PersonalPayment?> _findGuaranteePayment({
    required String planId,
    String? eventId,
    String? accommodationId,
  }) async {
    final list = await _paymentService.getPaymentsByPlanId(planId).first;
    for (final p in list) {
      if (p.paymentKind != 'guarantee') continue;
      if (eventId != null &&
          eventId.isNotEmpty &&
          p.eventId == eventId) {
        return p;
      }
      if (accommodationId != null &&
          accommodationId.isNotEmpty &&
          p.accommodationId == accommodationId) {
        return p;
      }
    }
    return null;
  }
}
