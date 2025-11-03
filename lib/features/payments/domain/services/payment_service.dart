import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/personal_payment.dart';

/// T102: Servicio para gestión CRUD de pagos individuales
class PaymentService {
  static const String _collectionName = 'personal_payments';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener todos los pagos de un plan
  Stream<List<PersonalPayment>> getPaymentsByPlanId(String planId) {
    return _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PersonalPayment.fromFirestore(doc))
          .toList();
    });
  }

  /// Obtener pagos de un participante específico en un plan
  Stream<List<PersonalPayment>> getPaymentsByParticipant(
    String planId,
    String participantId,
  ) {
    return _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .where('participantId', isEqualTo: participantId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PersonalPayment.fromFirestore(doc))
          .toList();
    });
  }

  /// Obtener pagos asociados a un evento específico
  Stream<List<PersonalPayment>> getPaymentsByEventId(String eventId) {
    return _firestore
        .collection(_collectionName)
        .where('eventId', isEqualTo: eventId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PersonalPayment.fromFirestore(doc))
          .toList();
    });
  }

  /// Crear un nuevo pago
  Future<String?> createPayment(PersonalPayment payment) async {
    try {
      final now = DateTime.now();
      final paymentToCreate = payment.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _firestore
          .collection(_collectionName)
          .add(paymentToCreate.toFirestore());

      LoggerService.database(
        'Payment created: ${docRef.id} for participant ${payment.participantId}',
        operation: 'CREATE',
      );

      return docRef.id;
    } catch (e) {
      LoggerService.error(
        'Error creating payment',
        context: 'PaymentService',
        error: e,
      );
      return null;
    }
  }

  /// Actualizar un pago existente
  Future<bool> updatePayment(PersonalPayment payment) async {
    if (payment.id == null) return false;

    try {
      final updatedPayment = payment.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .doc(payment.id)
          .update(updatedPayment.toFirestore());

      LoggerService.database(
        'Payment updated: ${payment.id}',
        operation: 'UPDATE',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error updating payment: ${payment.id}',
        context: 'PaymentService',
        error: e,
      );
      return false;
    }
  }

  /// Eliminar un pago
  Future<bool> deletePayment(String paymentId) async {
    try {
      await _firestore.collection(_collectionName).doc(paymentId).delete();

      LoggerService.database(
        'Payment deleted: $paymentId',
        operation: 'DELETE',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting payment: $paymentId',
        context: 'PaymentService',
        error: e,
      );
      return false;
    }
  }

  /// Guardar pago (crear o actualizar)
  Future<bool> savePayment(PersonalPayment payment) async {
    if (payment.id == null) {
      final id = await createPayment(payment);
      return id != null;
    } else {
      return await updatePayment(payment);
    }
  }

  /// Obtener total pagado por un participante en un plan
  Future<double> getTotalPaidByParticipant(
    String planId,
    String participantId,
  ) async {
    try {
      final payments = await getPaymentsByParticipant(planId, participantId)
          .first
          .timeout(const Duration(seconds: 10));

      // Solo contar pagos con status 'paid'
      return payments
          .where((p) => p.status == 'paid')
          .fold<double>(0.0, (sum, payment) => sum + payment.amount);
    } catch (e) {
      LoggerService.error(
        'Error getting total paid',
        context: 'PaymentService',
        error: e,
      );
      return 0.0;
    }
  }

  /// Obtener total pagado en un plan (todos los participantes)
  Future<double> getTotalPaidInPlan(String planId) async {
    try {
      final payments = await getPaymentsByPlanId(planId)
          .first
          .timeout(const Duration(seconds: 10));

      return payments
          .where((p) => p.status == 'paid')
          .fold<double>(0.0, (sum, payment) => sum + payment.amount);
    } catch (e) {
      LoggerService.error(
        'Error getting total paid in plan',
        context: 'PaymentService',
        error: e,
      );
      return 0.0;
    }
  }
}


