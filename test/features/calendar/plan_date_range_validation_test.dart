import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/plan_date_range_validation.dart';

void main() {
  group('P20 PLAN-C-003 validatePlanDateRange', () {
    test('rejects civil end before start', () {
      expect(
        validatePlanDateRange(DateTime(2026, 8, 18), DateTime(2026, 8, 17)),
        PlanDateRangeValidationError.endBeforeStart,
      );
    });

    test('allows same civil day even if clock times invert', () {
      expect(
        validatePlanDateRange(
          DateTime(2026, 8, 18, 15),
          DateTime(2026, 8, 18, 8),
        ),
        isNull,
      );
    });

    test('allows end after start', () {
      expect(
        validatePlanDateRange(DateTime(2026, 8, 18), DateTime(2026, 8, 24)),
        isNull,
      );
    });

    test('clampPlanEndToStart equalizes inverted range', () {
      final start = DateTime(2026, 8, 18);
      final clamped = clampPlanEndToStart(start, DateTime(2026, 8, 10));
      expect(clamped, DateTime(2026, 8, 18));
      expect(clampPlanEndToStart(start, DateTime(2026, 8, 20)), DateTime(2026, 8, 20));
    });
  });
}
