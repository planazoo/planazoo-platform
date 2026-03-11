import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/payment_service.dart';
import '../../domain/services/balance_service.dart';
import '../../domain/services/kitty_service.dart';
import '../../domain/services/expense_service.dart';
import '../../domain/models/personal_payment.dart';
import '../../domain/models/payment_summary.dart';
import '../../domain/models/kitty_contribution.dart';
import '../../domain/models/kitty_expense.dart';
import '../../domain/models/plan_expense.dart';
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

/// T219: Provider del servicio de bote común
final kittyServiceProvider = Provider<KittyService>((ref) {
  return KittyService();
});

/// T219: Aportaciones al bote por plan
final kittyContributionsProvider = StreamProvider.family<List<KittyContribution>, String>((ref, planId) {
  return ref.watch(kittyServiceProvider).getContributionsByPlanId(planId);
});

/// T219: Gastos del bote por plan
final kittyExpensesProvider = StreamProvider.family<List<KittyExpense>, String>((ref, planId) {
  return ref.watch(kittyServiceProvider).getExpensesByPlanId(planId);
});

/// Gastos tipo Tricount por plan
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

/// Stream de gastos tipo Tricount por plan
final planExpensesProvider = StreamProvider.family<List<PlanExpense>, String>((ref, planId) {
  return ref.watch(expenseServiceProvider).getExpensesByPlanId(planId);
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

  // T219: Obtener bote común (aportes y gastos)
  final kittyService = ref.watch(kittyServiceProvider);
  final kittyContributions = await kittyService.getContributionsByPlanIdFirst(planId);
  final kittyExpenses = await kittyService.getExpensesByPlanIdFirst(planId);

  // Gastos tipo Tricount
  final expenseService = ref.watch(expenseServiceProvider);
  final planExpenses = await expenseService.getExpensesByPlanIdFirst(planId);

  // Obtener nombres de usuarios (displayName o email, no IDs) para todos los que puedan aparecer en balances
  final userService = ref.read(userServiceProvider);
  final userIdsToResolve = <String>{};
  for (final p in participations) {
    userIdsToResolve.add(p.userId);
  }
  for (final payment in payments) {
    if (payment.participantId != null) userIdsToResolve.add(payment.participantId!);
  }
  for (final c in kittyContributions) {
    userIdsToResolve.add(c.participantId);
  }
  for (final event in events) {
    userIdsToResolve.add(event.userId);
    userIdsToResolve.addAll(event.participantTrackIds);
    final partIds = event.commonPart?.participantIds ?? event.participantTrackIds;
    userIdsToResolve.addAll(partIds);
  }
  for (final e in planExpenses) {
    userIdsToResolve.add(e.payerId);
    userIdsToResolve.addAll(e.participantIds);
  }
  final userIdToName = <String, String>{};
  for (final userId in userIdsToResolve) {
    try {
      final user = await userService.getUser(userId);
      final name = (user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName
              : user?.email) ??
          userId;
      userIdToName[userId] = name;
    } catch (e) {
      userIdToName[userId] = userId;
    }
  }

  // Calcular resumen (T219: incluye bote común; gastos tipo Tricount)
  return balanceService.calculatePaymentSummary(
    events: events,
    accommodations: accommodations,
    participations: participations,
    payments: payments,
    userIdToName: userIdToName,
    kittyContributions: kittyContributions,
    kittyExpenses: kittyExpenses,
    planExpenses: planExpenses,
    // De momento, el coste base de los eventos no se incluye automáticamente en el cálculo de pagos.
    // Si en el futuro se quiere hacer configurable desde la UI, este flag se puede vincular a una preferencia.
    includeEventBaseCosts: false,
  );
});


