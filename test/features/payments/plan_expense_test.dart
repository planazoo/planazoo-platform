import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/payments/domain/models/plan_expense.dart';
import 'package:unp_calendario/widgets/plan/event_payments_tab.dart';

void main() {
  group('PlanExpense accommodationId', () {
    final base = PlanExpense(
      planId: 'plan1',
      payerId: 'user1',
      amount: 42.5,
      expenseDate: DateTime(2026, 3, 1),
      participantIds: const ['user1', 'user2'],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );

    test('toFirestore writes accommodationId when set', () {
      final expense = base.copyWith(
        accommodationId: 'acc-99',
        eventId: null,
      );
      final map = expense.toFirestore();
      expect(map['accommodationId'], 'acc-99');
      expect(map.containsKey('eventId'), isFalse);
    });

    test('fromFirestore reads accommodationId', () {
      final expense = PlanExpense.fromFirestore(
        _FakeDocumentSnapshot(
          id: 'exp1',
          data: {
            'planId': 'plan1',
            'payerId': 'user1',
            'amount': 10.0,
            'expenseDate': Timestamp.fromDate(DateTime(2026, 3, 1)),
            'participantIds': ['user1'],
            'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
            'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
            'accommodationId': 'acc-1',
          },
        ),
      );
      expect(expense.accommodationId, 'acc-1');
    });

    test('copyWith preserves and overrides accommodationId', () {
      final withAcc = base.copyWith(accommodationId: 'a1');
      expect(withAcc.accommodationId, 'a1');
      final copy = withAcc.copyWith(accommodationId: 'a2');
      expect(copy.accommodationId, 'a2');
    });
  });

  group('planExpenseMatchesEntityLink', () {
    PlanExpense expense({String? eventId, String? accommodationId}) =>
        PlanExpense(
          planId: 'p',
          payerId: 'u',
          amount: 1,
          expenseDate: DateTime(2026),
          participantIds: const ['u'],
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          eventId: eventId,
          accommodationId: accommodationId,
        );

    test('matches event when accommodationId filter absent', () {
      expect(
        planExpenseMatchesEntityLink(
          expense(eventId: 'e1'),
          eventId: 'e1',
        ),
        isTrue,
      );
      expect(
        planExpenseMatchesEntityLink(
          expense(eventId: 'e2'),
          eventId: 'e1',
        ),
        isFalse,
      );
    });

    test('matches accommodation when accommodationId filter set', () {
      expect(
        planExpenseMatchesEntityLink(
          expense(accommodationId: 'a1'),
          accommodationId: 'a1',
        ),
        isTrue,
      );
      expect(
        planExpenseMatchesEntityLink(
          expense(eventId: 'e1'),
          accommodationId: 'a1',
        ),
        isFalse,
      );
    });

    test('returns false when no entity id provided', () {
      expect(
        planExpenseMatchesEntityLink(expense(eventId: 'e1')),
        isFalse,
      );
    });
  });
}

class _FakeDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  _FakeDocumentSnapshot({required this.id, required Map<String, dynamic> data})
      : _data = data;

  @override
  final String id;

  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
