import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/payment_service.dart';
import '../../domain/services/balance_service.dart';
import '../../domain/models/personal_payment.dart';
import '../../domain/models/payment_summary.dart';
import '../../../../features/calendar/presentation/providers/calendar_providers.dart';
import '../../../../features/calendar/presentation/providers/accommodation_providers.dart';
import '../../../../features/calendar/presentation/providers/plan_participation_providers.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// T102: Provider del servicio de pagos
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

/// T102: Provider del servicio de balances
final balanceServiceProvider = Provider<BalanceService>((ref) {
  return BalanceService();
});

/// T102: Stream de pagos de un plan
final paymentsByPlanProvider = StreamProvider.family<List<PersonalPayment>, String>((ref, planId) {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPaymentsByPlanId(planId);
});

/// T102: Stream de pagos de un participante en un plan
final paymentsByParticipantProvider = StreamProvider.family<List<PersonalPayment>, ({String planId, String participantId})>((ref, params) {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPaymentsByParticipant(params.planId, params.participantId);
});

/// T102: Stream de pagos de un evento
final paymentsByEventProvider = StreamProvider.family<List<PersonalPayment>, String>((ref, eventId) {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPaymentsByEventId(eventId);
});

/// T102: Provider para calcular resumen de pagos y balances
final paymentSummaryProvider = FutureProvider.family<PaymentSummary, String>((ref, planId) async {
  final balanceService = ref.watch(balanceServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser?.id == null) {
    throw Exception('Usuario no autenticado');
  }

  // Obtener datos necesarios
  final planService = ref.watch(planServiceProvider);
  final eventService = ref.watch(eventServiceProvider);
  final accommodationService = ref.watch(accommodationServiceProvider);
  final participationService = ref.watch(planParticipationServiceProvider);
  final paymentService = ref.watch(paymentServiceProvider);

  // Obtener plan
  final plan = await planService.getPlanById(planId);
  if (plan == null) {
    throw Exception('Plan no encontrado');
  }

  // Obtener eventos (requiere userId)
  final events = await eventService.getEventsByPlanId(planId, currentUser!.id).first.timeout(
    const Duration(seconds: 10),
  );

  // Obtener alojamientos
  final accommodations = await accommodationService.getAccommodations(planId).first.timeout(
    const Duration(seconds: 10),
  );

  // Obtener participaciones
  final participations = await participationService.getPlanParticipations(planId).first.timeout(
    const Duration(seconds: 10),
  );

  // Obtener pagos
  final payments = await paymentService.getPaymentsByPlanId(planId).first.timeout(
    const Duration(seconds: 10),
  );

  // Obtener nombres de usuarios
  final userIdToName = <String, String>{};
  final auth = FirebaseAuth.instance;
  for (final participation in participations) {
    try {
      final userRecord = await auth.currentUser;
      // Por ahora usar el userId como nombre, luego se puede mejorar con UserService
      userIdToName[participation.userId] = participation.userId;
    } catch (e) {
      userIdToName[participation.userId] = participation.userId;
    }
  }

  // Calcular resumen
  return balanceService.calculatePaymentSummary(
    events: events,
    accommodations: accommodations,
    participations: participations,
    payments: payments,
    userIdToName: userIdToName,
  );
});


