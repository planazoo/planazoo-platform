import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/testing/plan_logic.dart';

void main() {
  group('Plan creation logical cases (PLAN-C-*) from tests/plan_cases.json', () {
    late List<dynamic> cases;

    setUpAll(() async {
      final file = File('tests/plan_cases.json');
      expect(await file.exists(), isTrue, reason: 'tests/plan_cases.json must exist');
      final raw = await file.readAsString();
      cases = jsonDecode(raw) as List<dynamic>;
    });

    test('all PLAN-C-* cases match expected outputs', () {
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

        if (target['module'] != 'calendar' ||
            target['scenario'] != 'planCreation') {
          continue;
        }

        final actual = evaluatePlanCreation(input);
        final diff = comparePlanOutputs(expected, actual);

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
