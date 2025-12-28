import '../models/personal_payment.dart';
import '../models/payment_summary.dart';
import '../../../../features/calendar/domain/models/event.dart';
import '../../../../features/calendar/domain/models/accommodation.dart';
import '../../../../features/calendar/domain/models/plan_participation.dart';
import '../../../../features/budget/domain/services/budget_service.dart';

/// T102: Servicio para calcular balances y deudas entre participantes
class BalanceService {
  final BudgetService _budgetService = BudgetService();

  /// Calcular resumen completo de pagos y balances
  PaymentSummary calculatePaymentSummary({
    required List<Event> events,
    required List<Accommodation> accommodations,
    required List<PlanParticipation> participations,
    required List<PersonalPayment> payments,
    required Map<String, String> userIdToName, // userId -> nombre para mostrar
  }) {
    // Paso 1: Calcular coste por participante usando BudgetService
    final budgetSummary = _budgetService.calculateBudgetSummary(
      events: events,
      accommodations: accommodations,
      participations: participations,
    );

    // Paso 2: Calcular pagos por participante
    final paymentsByParticipant = <String, List<PersonalPayment>>{};
    for (final payment in payments.where((p) => p.status == 'paid')) {
      if (!paymentsByParticipant.containsKey(payment.participantId)) {
        paymentsByParticipant[payment.participantId] = [];
      }
      paymentsByParticipant[payment.participantId]!.add(payment);
    }

    // Paso 3: Calcular balances
    final balancesByParticipant = <String, ParticipantBalance>{};
    
    // Procesar solo participantes reales (excluir observadores)
    final realParticipants = participations
        .where((p) => p.role != 'observer')
        .toList();

    for (final participation in realParticipants) {
      final userId = participation.userId;
      final totalCost = budgetSummary.costByParticipant[userId] ?? 0.0;
      final participantPayments = paymentsByParticipant[userId] ?? [];
      final totalPaid = participantPayments.fold<double>(
        0.0,
        (sum, payment) => sum + payment.amount,
      );
      
      final balance = totalPaid - totalCost;
      
      // Convertir pagos a PaymentItems
      final paymentItems = participantPayments.map((payment) {
        // Buscar descripción del evento si está asociado
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
      }).toList();

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
    // añadirlos también
    for (final entry in budgetSummary.costByParticipant.entries) {
      if (!balancesByParticipant.containsKey(entry.key)) {
        final payments = paymentsByParticipant[entry.key] ?? [];
        final totalPaid = payments.fold<double>(
          0.0,
          (sum, payment) => sum + payment.amount,
        );
        final balance = totalPaid - entry.value;

        final paymentItems = payments.map((payment) {
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
        }).toList();

        balancesByParticipant[entry.key] = ParticipantBalance(
          userId: entry.key,
          userName: userIdToName[entry.key] ?? entry.key,
          totalCost: entry.value,
          totalPaid: totalPaid,
          balance: balance,
          payments: paymentItems,
          status: _determinePaymentStatus(balance, entry.value, totalPaid),
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

