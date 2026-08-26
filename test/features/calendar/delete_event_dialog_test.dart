import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/dialogs/delete_event_dialog.dart';

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

  group('E12 EVENT-D-003 showDeleteEventConfirmDialog', () {
    testWidgets('Cancelar does not confirm', (tester) async {
      bool? confirmed;
      await tester.pumpWidget(
        _app(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  confirmed = await showDeleteEventConfirmDialog(
                    context,
                    description: 'Cena',
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

      expect(find.text('Confirmar eliminación'), findsOneWidget);
      expect(
        find.text('¿Estás seguro de que quieres eliminar el evento "Cena"?'),
        findsOneWidget,
      );
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
                  confirmed = await showDeleteEventConfirmDialog(
                    context,
                    description: 'Cena',
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

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });
  });
}
