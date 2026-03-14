// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in a test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:unp_calendario/app/app.dart';

void main() {
  // Requiere Firebase.initializeApp() y ProviderScope; ver docs/configuracion/EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md y DOCS_AUDIT (tests con Firebase/ProviderScope).
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  }, skip: true); // Requiere Firebase.initializeApp() en el setup; ver DOCS_AUDIT / EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.
}
