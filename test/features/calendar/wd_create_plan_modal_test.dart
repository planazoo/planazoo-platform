import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/providers/help_text_providers.dart';
import 'package:unp_calendario/shared/services/help_text_service.dart';
import 'package:unp_calendario/widgets/dialogs/wd_create_plan_modal.dart';

import 'plan_test_helpers.dart';

final _user = UserModel(
  id: 'user-ua',
  email: 'ua@test.com',
  username: 'ua',
  createdAt: DateTime(2026, 1, 1),
);

Future<void> _openModal(
  WidgetTester tester, {
  required FakeFirebaseFirestore firestore,
  required void Function(Plan) onCreated,
}) async {
  final service = planServiceWithFake(firestore);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(_user),
        planServiceProvider.overrideWithValue(service),
        helpTextServiceProvider.overrideWithValue(
          HelpTextService(firestore: firestore),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => WdCreatePlanModal(onPlanCreated: onCreated),
                );
              },
              child: const Text('open'),
            ),
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('P5 slice: WdCreatePlanModal', () {
    testWidgets('PLAN-C-002: empty name shows error and does not create',
        (tester) async {
      final firestore = FakeFirebaseFirestore();
      var created = false;
      await _openModal(
        tester,
        firestore: firestore,
        onCreated: (_) => created = true,
      );

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor ingresa un nombre'), findsOneWidget);
      expect(created, isFalse);
      expect(find.byType(WdCreatePlanModal), findsOneWidget);
    });

    testWidgets('short name shows too-short error', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await _openModal(
        tester,
        firestore: firestore,
        onCreated: (_) {},
      );

      await tester.enterText(find.byType(TextFormField), 'AB');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('El nombre debe tener al menos 3 caracteres'), findsOneWidget);
    });

    testWidgets('Cancelar closes without creating', (tester) async {
      final firestore = FakeFirebaseFirestore();
      var created = false;
      await _openModal(
        tester,
        firestore: firestore,
        onCreated: (_) => created = true,
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(WdCreatePlanModal), findsNothing);
      expect(created, isFalse);
    });

    testWidgets('valid name creates plan and pops', (tester) async {
      final firestore = FakeFirebaseFirestore();
      Plan? created;
      await _openModal(
        tester,
        firestore: firestore,
        onCreated: (plan) => created = plan,
      );

      await tester.enterText(find.byType(TextFormField), 'Londres 2026');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(created, isNotNull);
      expect(created!.name, 'Londres 2026');
      expect(created!.userId, 'user-ua');
      expect(created!.state, 'planificando');
      expect(find.byType(WdCreatePlanModal), findsNothing);

      final listed =
          await planServiceWithFake(firestore).getPlansByUserId('user-ua').first;
      expect(listed.map((p) => p.name), contains('Londres 2026'));
    });
  });
}
