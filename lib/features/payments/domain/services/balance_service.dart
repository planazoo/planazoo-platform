import '../models/personal_payment.dart';
import '../models/payment_summary.dart';
import '../models/kitty_contribution.dart';
import '../models/kitty_expense.dart';
import '../models/plan_expense.dart';
import '../../../../features/calendar/domain/models/event.dart';
import '../../../../features/calendar/domain/models/accommodation.dart';
import '../../../../features/calendar/domain/models/plan_participation.dart';
import '../../../../features/budget/domain/services/budget_service.dart';

/// T102: Servicio para calcular balances y deudas entre participantes
class BalanceService {
  final BudgetService _budgetService = BudgetService();

  String? _planExpenseEventDescription(List<Event> events, PlanExpense e) {
    final id = e.eventId;
    if (id == null || id.isEmpty) return null;
    for (final ev in events) {
      if (ev.id == id) {
        final d = ev.description.trim();
        return d.isNotEmpty ? d : 'Evento';
      }
    }
    return null;
  }

  /// Calcular resumen completo de pagos y balances
  /// T219: [kittyContributions] y [kittyExpenses] integran el bote común en balances
  /// Gastos tipo Tricount: [planExpenses] añaden coste por participante (reparto) y lo pagado por el pagador
  PaymentSummary calculatePaymentSummary({
    required List<Event> events,
    required List<Accommodation> accommodations,
    required List<PlanParticipation> participations,
    required List<PersonalPayment> payments,
    required Map<String, String> userIdToName, // userId -> nombre para mostrar
    List<KittyContribution> kittyContributions = const [],
    List<KittyExpense> kittyExpenses = const [],
    List<PlanExpense> planExpenses = const [],
    bool includeEventBaseCosts = false,
  }) {
    // Paso 1: Calcular coste por participante usando BudgetService.
    // El coste base de los eventos puede incluirse o no en el cálculo de pagos según configuración.
    final effectiveEvents = includeEventBaseCosts ? events : <Event>[];
    final budgetSummary = _budgetService.calculateBudgetSummary(
      events: effectiveEvents,
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

    // Gastos tipo Tricount: coste por participante (su parte) y lo pagado por el pagador
    final expenseCostByParticipant = <String, double>{};
    final paidFromPlanExpensesByUser = <String, double>{};
    for (final exp in planExpenses) {
      paidFromPlanExpensesByUser[exp.payerId] =
          (paidFromPlanExpensesByUser[exp.payerId] ?? 0.0) + exp.amount;
      for (final uid in exp.participantIds) {
        expenseCostByParticipant[uid] =
            (expenseCostByParticipant[uid] ?? 0.0) + exp.shareFor(uid);
      }
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
      final expenseCost = expenseCostByParticipant[userId] ?? 0.0;
      final totalCost = baseCost + kittyExpensePerParticipant + expenseCost;
      final participantPayments = paymentsByParticipant[userId] ?? [];
      final paidFromPayments = participantPayments.fold<double>(
        0.0,
        (sum, payment) => sum + payment.amount,
      );
      final paidFromKitty = kittyContributionsByUser[userId] ?? 0.0;
      final paidFromExpenses = paidFromPlanExpensesByUser[userId] ?? 0.0;
      final totalPaid = paidFromPayments + paidFromKitty + paidFromExpenses;
      
      final balance = totalPaid - totalCost;
      
      // Convertir pagos a PaymentItems (incl. aportes al bote T219 y gastos tipo Tricount)
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
        ...planExpenses
            .where((e) => e.payerId == userId)
            .map((e) => PaymentItem(
                  paymentId: 'expense_${e.id}',
                  eventId: e.eventId,
                  eventDescription:
                      _planExpenseEventDescription(events, e),
                  amount: e.amount,
                  paymentDate: e.expenseDate,
                  paymentMethod: null,
                  concept: e.concept ?? 'Gasto',
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
    // añadirlos también (T219: incluir bote en coste y pago; gastos Tricount)
    for (final entry in budgetSummary.costByParticipant.entries) {
      if (!balancesByParticipant.containsKey(entry.key)) {
        final uid = entry.key;
        final payments = paymentsByParticipant[uid] ?? [];
        final paidFromPayments = payments.fold<double>(
          0.0,
          (sum, payment) => sum + payment.amount,
        );
        final paidFromKitty = kittyContributionsByUser[uid] ?? 0.0;
        final paidFromExpenses = paidFromPlanExpensesByUser[uid] ?? 0.0;
        final expenseCost = expenseCostByParticipant[uid] ?? 0.0;
        final totalPaid = paidFromPayments + paidFromKitty + paidFromExpenses;
        final totalCost = entry.value + kittyExpensePerParticipant + expenseCost;
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
              .where((c) => c.participantId == uid)
              .map((c) => PaymentItem(
                    paymentId: 'kitty_${c.id}',
                    eventId: null,
                    eventDescription: null,
                    amount: c.amount,
                    paymentDate: c.contributionDate,
                    paymentMethod: null,
                    concept: c.concept ?? 'Aporte al bote',
                  )),
          ...planExpenses
              .where((e) => e.payerId == uid)
              .map((e) => PaymentItem(
                    paymentId: 'expense_${e.id}',
                    eventId: e.eventId,
                    eventDescription:
                        _planExpenseEventDescription(events, e),
                    amount: e.amount,
                    paymentDate: e.expenseDate,
                    paymentMethod: null,
                    concept: e.concept ?? 'Gasto',
                  )),
        ];

        balancesByParticipant[uid] = ParticipantBalance(
          userId: uid,
          userName: userIdToName[uid] ?? uid,
          totalCost: totalCost,
          totalPaid: totalPaid,
          balance: balance,
          payments: paymentItems,
          status: _determinePaymentStatus(balance, totalCost, totalPaid),
        );
      }
    }

    // Participantes que solo aparecen en gastos Tricount (pagador o en reparto)
    final expenseParticipantIds = <String>{};
    for (final e in planExpenses) {
      expenseParticipantIds.add(e.payerId);
      expenseParticipantIds.addAll(e.participantIds);
    }
    for (final uid in expenseParticipantIds) {
      if (balancesByParticipant.containsKey(uid)) continue;
      final paidFromPayments = (paymentsByParticipant[uid] ?? []).fold<double>(
        0.0,
        (sum, p) => sum + p.amount,
      );
      final paidFromKitty = kittyContributionsByUser[uid] ?? 0.0;
      final paidFromExpenses = paidFromPlanExpensesByUser[uid] ?? 0.0;
      final expenseCost = expenseCostByParticipant[uid] ?? 0.0;
      final totalPaid = paidFromPayments + paidFromKitty + paidFromExpenses;
      final totalCost = kittyExpensePerParticipant + expenseCost;
      final balance = totalPaid - totalCost;
      final paymentItems = <PaymentItem>[
        ...(paymentsByParticipant[uid] ?? []).map((p) => PaymentItem(
              paymentId: p.id ?? '',
              eventId: p.eventId,
              eventDescription: null,
              amount: p.amount,
              paymentDate: p.paymentDate,
              paymentMethod: p.paymentMethod,
              concept: p.concept,
            )),
        ...kittyContributions
            .where((c) => c.participantId == uid)
            .map((c) => PaymentItem(
                  paymentId: 'kitty_${c.id}',
                  eventId: null,
                  eventDescription: null,
                  amount: c.amount,
                  paymentDate: c.contributionDate,
                  paymentMethod: null,
                  concept: c.concept ?? 'Aporte al bote',
                )),
        ...planExpenses
            .where((e) => e.payerId == uid)
            .map((e) => PaymentItem(
                  paymentId: 'expense_${e.id}',
                  eventId: e.eventId,
                  eventDescription:
                      _planExpenseEventDescription(events, e),
                  amount: e.amount,
                  paymentDate: e.expenseDate,
                  paymentMethod: null,
                  concept: e.concept ?? 'Gasto',
                )),
      ];
      balancesByParticipant[uid] = ParticipantBalance(
        userId: uid,
        userName: userIdToName[uid] ?? uid,
        totalCost: totalCost,
        totalPaid: totalPaid,
        balance: balance,
        payments: paymentItems,
        status: _determinePaymentStatus(balance, totalCost, totalPaid),
      );
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

