import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';

void main() {
  group('CalendarConstants visible days', () {
    test('canShowAllPlanDaysOnScreen only for 2..7', () {
      expect(CalendarConstants.canShowAllPlanDaysOnScreen(1), isFalse);
      expect(CalendarConstants.canShowAllPlanDaysOnScreen(2), isTrue);
      expect(CalendarConstants.canShowAllPlanDaysOnScreen(7), isTrue);
      expect(CalendarConstants.canShowAllPlanDaysOnScreen(8), isFalse);
    });

    test('resolveVisibleDays clamps to plan when shorter than request', () {
      expect(CalendarConstants.resolveVisibleDays(7, 4), 4);
      expect(CalendarConstants.resolveVisibleDays(3, 2), 2);
    });

    test('resolveVisibleDays keeps week strip on longer plans', () {
      expect(CalendarConstants.resolveVisibleDays(7, 14), 7);
      expect(CalendarConstants.resolveVisibleDays(3, 14), 3);
      expect(CalendarConstants.resolveVisibleDays(1, 14), 1);
    });

    test('resolveVisibleDays for all-plan equals duration when ≤7', () {
      expect(CalendarConstants.resolveVisibleDays(5, 5), 5);
      expect(CalendarConstants.resolveVisibleDays(7, 7), 7);
    });
  });
}
