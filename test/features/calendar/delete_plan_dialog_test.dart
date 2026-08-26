import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/dialogs/delete_plan_dialogs.dart';

Widget _app({required Widget home}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P19 PLAN-D-003 showDeletePlanConfirmDialog (dashboard)', () {
    testWidgets('Cancelar does not confirm', (tester) async {
      bool? confirmed;
      await tester.pumpWidget(
        _app(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  confirmed = await showDeletePlanConfirmDialog(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar eliminación'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });

    testWidgets('Eliminar confirms', (tester) async {
      bool? confirmed;
      await tester.pumpWidget(
        _app(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  confirmed = await showDeletePlanConfirmDialog(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });
  });

  group('P19 PLAN-D-003 showDeletePlanPasswordSheet (Info)', () {
    Future<void> open(
      WidgetTester tester, {
      required Future<bool> Function(String password) onDelete,
      required void Function(bool? value) onClosed,
    }) async {
      await tester.pumpWidget(
        _app(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  final loc = AppLocalizations.of(context)!;
                  onClosed(
                    await showDeletePlanPasswordSheet(
                      context,
                      loc: loc,
                      onDelete: onDelete,
                    ),
                  );
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

    testWidgets('Cancelar cambios does not call onDelete', (tester) async {
      var deleted = false;
      bool? closed;
      await open(
        tester,
        onDelete: (_) async {
          deleted = true;
          return true;
        },
        onClosed: (value) => closed = value,
      );

      await tester.tap(find.text('Cancelar cambios'));
      await tester.pumpAndSettle();

      expect(deleted, isFalse);
      expect(closed, isFalse);
    });

    testWidgets('empty password shows error and does not call onDelete',
        (tester) async {
      var deleted = false;
      await open(
        tester,
        onDelete: (_) async {
          deleted = true;
          return true;
        },
        onClosed: (_) {},
      );

      await tester.tap(find.text('Eliminar plan').last);
      await tester.pumpAndSettle();

      expect(find.text('Introduce tu contraseña para confirmar.'), findsOneWidget);
      expect(deleted, isFalse);
    });

    testWidgets('password + onDelete true closes confirmed', (tester) async {
      String? received;
      bool? closed;
      await open(
        tester,
        onDelete: (password) async {
          received = password;
          return true;
        },
        onClosed: (value) => closed = value,
      );

      await tester.enterText(find.byType(TextFormField), 'secret');
      await tester.tap(find.text('Eliminar plan').last);
      await tester.pumpAndSettle();

      expect(received, 'secret');
      expect(closed, isTrue);
    });

    testWidgets('password + onDelete false stays open with auth error',
        (tester) async {
      await open(
        tester,
        onDelete: (_) async => false,
        onClosed: (_) {},
      );

      await tester.enterText(find.byType(TextFormField), 'wrong');
      await tester.tap(find.text('Eliminar plan').last);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Contraseña incorrecta o sin permisos para eliminar este plan.',
        ),
        findsOneWidget,
      );
    });
  });
}
