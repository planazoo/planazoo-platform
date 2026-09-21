import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/payments/domain/models/personal_payment.dart';
import 'package:unp_calendario/features/payments/domain/models/plan_expense.dart';
import 'package:unp_calendario/features/payments/domain/services/balance_service.dart';

void main() {
  final now = DateTime(2026, 3, 1);
  final names = {
    for (var i = 1; i <= 9; i++) 'u$i': 'User $i',
  };

  List<PlanParticipation> nineParticipants() => [
        for (var i = 1; i <= 9; i++)
          PlanParticipation(
            planId: 'plan1',
            userId: 'u$i',
            role: i == 1 ? 'organizer' : 'participant',
            joinedAt: now,
          ),
      ];

  Event dinnerEvent({
    bool isForAll = true,
    List<String> participantIds = const [],
  }) =>
      Event(
        id: 'ev-dinner',
        planId: 'plan1',
        userId: 'u1',
        date: now,
        hour: 20,
        duration: 2,
        description: 'Cena Cotswolds',
        createdAt: now,
        updatedAt: now,
        commonPart: EventCommonPart(
          description: 'Cena Cotswolds',
          date: now,
          startHour: 20,
          startMinute: 0,
          durationMinutes: 120,
          isForAllParticipants: isForAll,
          participantIds: participantIds,
        ),
      );

  PersonalPayment guaranteePayment({
    required double amount,
    String participantId = 'u1',
    String? eventId = 'ev-dinner',
  }) =>
      PersonalPayment(
        id: 'pay-g',
        planId: 'plan1',
        participantId: participantId,
        eventId: eventId,
        paymentKind: 'guarantee',
        amount: amount,
        paymentDate: now,
        status: 'paid',
        createdAt: now,
        updatedAt: now,
      );

  group('guaranteeShareParticipantIds', () {
    test('evento para todos → participantes reales del plan', () {
      final ids = guaranteeShareParticipantIds(
        payment: guaranteePayment(amount: 90),
        events: [dinnerEvent()],
        accommodations: const [],
        realParticipantIds: names.keys.toSet(),
      );
      expect(ids, names.keys.toSet());
    });

    test('evento con lista concreta → solo esos IDs', () {
      final ids = guaranteeShareParticipantIds(
        payment: guaranteePayment(amount: 90),
        events: [
          dinnerEvent(
            isForAll: false,
            participantIds: const ['u1', 'u2', 'u3'],
          ),
        ],
        accommodations: const [],
        realParticipantIds: names.keys.toSet(),
      );
      expect(ids, {'u1', 'u2', 'u3'});
    });
  });

  group('BalanceService guarantee cost', () {
    final service = BalanceService();

    test('garantía se reparte entre participantes del evento (caso Cotswolds)',
        () {
      final participations = nineParticipants();
      final expense = PlanExpense(
        id: 'exp1',
        planId: 'plan1',
        payerId: 'u1',
        amount: 350,
        expenseDate: now,
        participantIds: names.keys.toList(),
        equalSplit: true,
        createdAt: now,
        updatedAt: now,
        concept: 'Cena',
      );
      final summary = service.calculatePaymentSummary(
        events: [dinnerEvent()],
        accommodations: const [],
        participations: participations,
        payments: [guaranteePayment(amount: 90)],
        userIdToName: names,
        planExpenses: [expense],
        includeEventBaseCosts: false,
      );

      // Coste por persona: 350/9 + 90/9
      final expectedCost = 350 / 9 + 90 / 9;
      for (final uid in names.keys) {
        final b = summary.balancesByParticipant[uid]!;
        expect(b.totalCost, closeTo(expectedCost, 0.001));
      }

      final cristian = summary.balancesByParticipant['u1']!;
      expect(cristian.totalPaid, closeTo(350 + 90, 0.001));
      expect(cristian.balance, closeTo(350 + 90 - expectedCost, 0.001));

      final sumBalances = summary.balancesByParticipant.values
          .fold<double>(0, (s, b) => s + b.balance);
      expect(sumBalances, closeTo(0, 0.01));
    });

    test('garantía con subset de participantes del evento', () {
      final participations = nineParticipants();
      final summary = service.calculatePaymentSummary(
        events: [
          dinnerEvent(
            isForAll: false,
            participantIds: const ['u1', 'u2', 'u3'],
          ),
        ],
        accommodations: const [],
        participations: participations,
        payments: [guaranteePayment(amount: 90)],
        userIdToName: names,
        planExpenses: const [],
        includeEventBaseCosts: false,
      );

      expect(summary.balancesByParticipant['u1']!.totalCost, closeTo(30, 0.001));
      expect(summary.balancesByParticipant['u2']!.totalCost, closeTo(30, 0.001));
      expect(summary.balancesByParticipant['u3']!.totalCost, closeTo(30, 0.001));
      expect(summary.balancesByParticipant['u4']!.totalCost, closeTo(0, 0.001));
      expect(summary.balancesByParticipant['u1']!.totalPaid, closeTo(90, 0.001));
      expect(summary.balancesByParticipant['u1']!.balance, closeTo(60, 0.001));
    });
  });
}
