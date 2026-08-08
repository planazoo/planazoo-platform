import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_event_accent_colors.dart';

Plan _plan({
  String? base,
  Map<String, String> colors = const {},
}) {
  final now = DateTime(2026, 8, 1);
  return Plan(
    name: 'Test',
    unpId: 'u1',
    userId: 'owner',
    baseDate: now,
    startDate: now,
    endDate: now.add(const Duration(days: 3)),
    columnCount: 4,
    eventAccentBaseColor: base,
    eventTypeAccentColors: colors,
    createdAt: now,
    updatedAt: now,
    savedAt: now,
  );
}

void main() {
  group('PlanEventAccentColors', () {
    test('defaults to color2 without config', () {
      final plan = _plan();
      expect(PlanEventAccentColors.baseColor(plan), 'color2');
      expect(PlanEventAccentColors.resolve(plan, 'Desplazamiento'), 'color2');
      expect(PlanEventAccentColors.resolve(plan, null), 'color2');
    });

    test('resolves family override then base', () {
      final plan = _plan(
        base: 'green',
        colors: {'Desplazamiento': 'blue'},
      );
      expect(PlanEventAccentColors.resolve(plan, 'Desplazamiento'), 'blue');
      expect(PlanEventAccentColors.resolve(plan, 'Actividad'), 'green');
    });

    test('normalizes Transporte to Desplazamiento', () {
      final plan = _plan(colors: {'Desplazamiento': 'teal'});
      expect(PlanEventAccentColors.resolve(plan, 'Transporte'), 'teal');
    });

    test('applyBaseColorChange updates families that followed old base', () {
      final before = _plan(
        base: 'color2',
        colors: {
          'Desplazamiento': 'blue',
          'Actividad': 'color2',
        },
      );
      final after =
          PlanEventAccentColors.applyBaseColorChange(before, 'purple');
      expect(after.eventAccentBaseColor, 'purple');
      expect(after.eventTypeAccentColors['Desplazamiento'], 'blue');
      expect(after.eventTypeAccentColors['Actividad'], 'purple');
      expect(
        PlanEventAccentColors.familiesAffectedByBaseChange(before, 'purple'),
        containsAll(['Actividad', 'Restauración', 'Acción', 'Otro']),
      );
      expect(
        PlanEventAccentColors.familiesAffectedByBaseChange(before, 'purple'),
        isNot(contains('Desplazamiento')),
      );
    });

    test('applyFamilyColorChange sets map entry', () {
      final plan = _plan();
      final next = PlanEventAccentColors.applyFamilyColorChange(
        plan,
        'Restauración',
        'red',
      );
      expect(next.eventTypeAccentColors['Restauración'], 'red');
    });
  });
}
