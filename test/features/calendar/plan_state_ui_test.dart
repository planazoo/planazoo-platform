import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan_state_badge.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/state_transition_dialog.dart';

import 'plan_test_helpers.dart';

Future<void> _pumpConfirmDialog(
  WidgetTester tester, {
  required void Function(bool value) onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await showStateTransitionDialog(
                context: context,
                plan: samplePlan(userId: 'user-ua', name: 'Viaje'),
                newState: 'confirmado',
              );
              onResult(result);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P18 PlanStateBadge', () {
    testWidgets('shows PLANIFICANDO for default state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlanStateBadge(
              plan: samplePlan(userId: 'user-ua', name: 'Viaje'),
            ),
          ),
        ),
      );

      expect(find.text('PLANIFICANDO'), findsOneWidget);
    });

    testWidgets('shows CONFIRMADO when state is confirmado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlanStateBadge(
              plan: samplePlan(
                userId: 'user-ua',
                name: 'Viaje',
                state: 'confirmado',
              ),
            ),
          ),
        ),
      );

      expect(find.text('CONFIRMADO'), findsOneWidget);
    });
  });

  group('P18 StateTransitionDialog', () {
    testWidgets('Cancelar closes without confirming', (tester) async {
      bool? confirmed;
      await _pumpConfirmDialog(tester, onResult: (value) => confirmed = value);

      expect(find.text('Confirmar Plan'), findsWidgets);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
      expect(find.byType(StateTransitionDialog), findsNothing);
    });

    testWidgets('Confirmar returns true', (tester) async {
      bool? confirmed;
      await _pumpConfirmDialog(tester, onResult: (value) => confirmed = value);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(find.byType(StateTransitionDialog), findsNothing);
    });
  });
}
