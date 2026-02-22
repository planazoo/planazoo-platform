import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/testing/login_logic.dart';

void main() {
  group('auth/login logical scenarios (from tests/login_cases.json)', () {
    late List<dynamic> cases;

    setUpAll(() async {
      final file = File('tests/login_cases.json');
      expect(await file.exists(), isTrue,
          reason: 'tests/login_cases.json must exist');
      final raw = await file.readAsString();
      cases = jsonDecode(raw) as List<dynamic>;
    });

    test('all LOGIN-00X cases match expected logical outputs', () async {
      for (final dynamic entry in cases) {
        expect(entry, isA<Map<String, dynamic>>());
        final map = entry as Map<String, dynamic>;
        final id = map['id']?.toString() ?? 'unknown';
        final target =
            (map['target'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
        final input =
            (map['input'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
        final expected =
            (map['expected'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

        // Nos centramos solo en los escenarios de auth/login definidos.
        if (target['module'] != 'auth' || target['scenario'] != 'login') {
          continue;
        }

        final actual = evaluateAuthLogin(input);
        final diff = compareOutputs(expected, actual);

        expect(
          diff,
          isNull,
          reason:
              'Case $id failed.\nExpected: $expected\nActual:   $actual\nDiff:     $diff',
        );
      }
    });
  });
}

