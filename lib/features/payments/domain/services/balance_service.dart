import '../models/personal_payment.dart';
import '../models/payment_summary.dart';
import '../models/kitty_contribution.dart';
import '../models/kitty_expense.dart';
import '../../../../features/calendar/domain/models/event.dart';
import '../../../../features/calendar/domain/models/accommodation.dart';
import '../../../../features/calendar/domain/models/plan_participation.dart';
import '../../../../features/budget/domain/services/budget_service.dart';

/// T102: Servicio para calcular balances y deudas entre participantes
class BalanceService {
  final BudgetService _budgetService = BudgetService();

  /// Calcular resumen completo de pagos y balances
  /// T219: [kittyContributions] y [kittyExpenses] integran el bote común en balances
  PaymentSummary calculatePaymentSummary({
    required List<Event> events,
    required List<Accommodation> accommodations,
    required List<PlanParticipation> participations,
    required List<PersonalPayment> payments,
    required Map<String, String> userIdToName, // userId -> nombre para mostrar
    List<KittyContribution> kittyContributions = const [],
    List<KittyExpense> kittyExpenses = const [],
  }) {
    // Paso 1: Calcular coste por participante usando BudgetService
    final budgetSummary = _budgetService.calculateBudgetSummary(
      events: events,
      accommodations: accommodations,
      participations: participations,
    );

    // Paso 2: Calcular pagos por participante (incl. aportes al bote T219)
    final paymentsByParticipant = <String, List<PersonalPayment>>{};
    for (final payment in payments.where((p) => p.status == 'paid')) {
      if (!paymentsByParticipant.containsKey(payment.participantId)) {
        paymentsByParticipant[payment.participantId] = [];
      }
      paymentsByParticipant[payment.participantId]!.add(payment);
    }
    // T219: total gastos del bote (repartido entre todos) y aportes por participante
    final totalKittyExpenses = kittyExpenses.fold<double>(0.0, (s, e) => s + e.amount);
    final kittyContributionsByUser = <String, double>{};
    for (final c in kittyContributions) {
      kittyContributionsByUser[c.participantId] =
          (kittyContributionsByUser[c.participantId] ?? 0.0) + c.amount;
    }

    // Paso 3: Calcular balances
    final balancesByParticipant = <String, ParticipantBalance>{};
    
    // Procesar solo participantes reales (excluir observadores)
    final realParticipants = participations
        .where((p) => p.role != 'observer')
        .toList();
    final numParticipants = realParticipants.isEmpty ? 1 : realParticipants.length;
    final kittyExpensePerParticipant = totalKittyExpenses / numParticipants;

    for (final participation in realParticipants) {
      final userId = participation.userId;
      final baseCost = budgetSummary.costByParticipant[userId] ?? 0.0;
      final totalCost = baseCost + kittyExpensePerParticipant;
      final participantPayments = paymentsByParticipant[userId] ?? [];
      final paidFromPayments = participantPayments.fold<double>(
        0.0,
        (sum, payment) => sum + payment.amount,
      );
      final paidFromKitty = kittyContributionsByUser[userId] ?? 0.0;
      final totalPaid = paidFromPayments + paidFromKitty;
      
      final balance = totalPaid - totalCost;
      
      // Convertir pagos a PaymentItems (incl. aportes al bote T219)
      final paymentItems = <PaymentItem>[
        ...participantPayments.map((payment) {
          String? eventDescription;
          if (payment.eventId != null) {
            final event = events.firstWhere(
              (e) => e.id == payment.eventId,
              orElse: () => events.first,
            );
            eventDescription = event.description;
          }
          return PaymentItem(
            paymentId: payment.id ?? '',
            eventId: payment.eventId,
            eventDescription: eventDescription,
            amount: payment.amount,
            paymentDate: payment.paymentDate,
            paymentMethod: payment.paymentMethod,
            concept: payment.concept,
          );
        }),
        ...kittyContributions
            .where((c) => c.participantId == userId)
            .map((c) => PaymentItem(
                  paymentId: 'kitty_${c.id}',
                  eventId: null,
                  eventDescription: null,
                  amount: c.amount,
                  paymentDate: c.contributionDate,
                  paymentMethod: null,
                  concept: c.concept ?? 'Aporte al bote',
                )),
      ];

      // Determinar estado del pago
      final status = _determinePaymentStatus(balance, totalCost, totalPaid);

      balancesByParticipant[userId] = ParticipantBalance(
        userId: userId,
        userName: userIdToName[userId] ?? userId,
        totalCost: totalCost,
        totalPaid: totalPaid,
        balance: balance,
        payments: paymentItems,
        status: status,
      );
    }

    // Si hay participantes con coste pero sin entrada en participations,
    // añadirlos también (T219: incluir bote en coste y pago)
    for (final entry in budgetSummary.costByParticipant.entries) {
      if (!balancesByParticipant.containsKey(entry.key)) {
        final payments = paymentsByParticipant[entry.key] ?? [];
        final paidFromPayments = payments.fold<double>(
          0.0,
          (sum, payment) => sum + payment.amount,
        );
        final paidFromKitty = kittyContributionsByUser[entry.key] ?? 0.0;
        final totalPaid = paidFromPayments + paidFromKitty;
        final totalCost = entry.value + kittyExpensePerParticipant;
        final balance = totalPaid - totalCost;

        final paymentItems = <PaymentItem>[
          ...payments.map((payment) {
            String? eventDescription;
            if (payment.eventId != null) {
              final event = events.firstWhere(
                (e) => e.id == payment.eventId,
                orElse: () => events.first,
              );
              eventDescription = event.description;
            }
            return PaymentItem(
              paymentId: payment.id ?? '',
              eventId: payment.eventId,
              eventDescription: eventDescription,
              amount: payment.amount,
              paymentDate: payment.paymentDate,
              paymentMethod: payment.paymentMethod,
              concept: payment.concept,
            );
          }),
          ...kittyContributions
              .where((c) => c.participantId == entry.key)
              .map((c) => PaymentItem(
                    paymentId: 'kitty_${c.id}',
                    eventId: null,
                    eventDescription: null,
                    amount: c.amount,
                    paymentDate: c.contributionDate,
                    paymentMethod: null,
                    concept: c.concept ?? 'Aporte al bote',
                  )),
        ];

        balancesByParticipant[entry.key] = ParticipantBalance(
          userId: entry.key,
          userName: userIdToName[entry.key] ?? entry.key,
          totalCost: totalCost,
          totalPaid: totalPaid,
          balance: balance,
          payments: paymentItems,
          status: _determinePaymentStatus(balance, totalCost, totalPaid),
        );
      }
    }

    return PaymentSummary(
      planId: participations.isNotEmpty ? participations.first.planId : '',
      balancesByParticipant: balancesByParticipant,
    );
  }

  /// Determinar estado de pago según balance
  PaymentStatus _determinePaymentStatus(
    double balance,
    double totalCost,
    double totalPaid,
  ) {
    if (balance == 0) {
      return PaymentStatus.settled;
    } else if (balance > 0) {
      return PaymentStatus.overpaid;
    } else {
      // Balance negativo
      if (totalPaid == 0) {
        return PaymentStatus.pending;
      } else {
        return PaymentStatus.partial;
      }
    }
  }

  /// Calcular sugerencias de transferencias mínimas para equilibrar
  List<TransferSuggestion> calculateTransferSuggestions(
    PaymentSummary summary,
  ) {
    final suggestions = <TransferSuggestion>[];

    // Ordenar deudores (más deuda primero) y acreedores (más crédito primero)
    final sortedDebtors = summary.debtors.toList();
    final sortedCreditors = summary.creditors.toList();

    int debtorIndex = 0;
    int creditorIndex = 0;

    while (debtorIndex < sortedDebtors.length && creditorIndex < sortedCreditors.length) {
      final debtor = sortedDebtors[debtorIndex];
      final creditor = sortedCreditors[creditorIndex];

      final debtAmount = debtor.balance.abs();
      final creditAmount = creditor.balance;

      // La transferencia es el mínimo entre la deuda y el crédito
      final transferAmount = debtAmount < creditAmount ? debtAmount : creditAmount;

      if (transferAmount > 0.01) { // Solo si es significativo (>1 céntimo)
        suggestions.add(TransferSuggestion(
          fromUserId: debtor.userId,
          fromUserName: debtor.userName,
          toUserId: creditor.userId,
          toUserName: creditor.userName,
          amount: transferAmount,
        ));

        // Actualizar balances virtuales
        if (debtAmount <= creditAmount) {
          // Deudor pagado completamente, pasar al siguiente
          debtorIndex++;
          // Actualizar crédito del acreedor
          if (debtAmount < creditAmount) {
            // Actualizar balance del acreedor (restar lo recibido)
            final updatedBalance = creditAmount - debtAmount;
            sortedCreditors[creditorIndex] = ParticipantBalance(
              userId: creditor.userId,
              userName: creditor.userName,
              totalCost: creditor.totalCost,
              totalPaid: creditor.totalPaid,
              balance: updatedBalance,
              payments: creditor.payments,
              status: creditor.status,
            );
          } else {
            // Acreedor también completado
            creditorIndex++;
          }
        } else {
          // Acreedor recibió todo, pasar al siguiente
          creditorIndex++;
          // Actualizar deuda del deudor
          final updatedBalance = -(debtAmount - creditAmount);
          sortedDebtors[debtorIndex] = ParticipantBalance(
            userId: debtor.userId,
            userName: debtor.userName,
            totalCost: debtor.totalCost,
            totalPaid: debtor.totalPaid,
            balance: updatedBalance,
            payments: debtor.payments,
            status: debtor.status,
          );
        }
      } else {
        // Si la cantidad es muy pequeña, avanzar
        if (debtAmount < creditAmount) {
          debtorIndex++;
        } else {
          creditorIndex++;
        }
      }
    }

    return suggestions;
  }
}

/// Sugerencia de transferencia entre participantes
class TransferSuggestion {
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;

  const TransferSuggestion({
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
  });
}

