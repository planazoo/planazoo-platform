import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/event_field_validation.dart';

void main() {
  group('EVENT-C-006 duration', () {
    test('allows 24h exactly and custom 45 min', () {
      expect(validateEventDurationMinutes(45), isNull);
      expect(validateEventDurationMinutes(kEventMaxDurationMinutes), isNull);
    });

    test('rejects more than 24h', () {
      expect(
        validateEventDurationMinutes(1500),
        EventDurationValidationError.tooLong,
      );
    });
  });

  group('EVENT-C-011 cost', () {
    test('allows null and positive; rejects negative', () {
      expect(validateEventCost(null), isNull);
      expect(validateEventCost(25.5), isNull);
      expect(validateEventCost(-1), EventCostValidationError.negative);
    });
  });

  group('EVENT-C-009 max participants', () {
    test('allows under/equal max; rejects over', () {
      expect(
        validateEventMaxParticipants(maxParticipants: null, participantsCount: 99),
        isNull,
      );
      expect(
        validateEventMaxParticipants(maxParticipants: 5, participantsCount: 5),
        isNull,
      );
      expect(
        validateEventMaxParticipants(maxParticipants: 3, participantsCount: 5),
        EventMaxParticipantsValidationError.exceeded,
      );
    });
  });

  group('EVENT-C-017 plan range', () {
    test('inside inclusive civil days; outside rejected', () {
      final start = DateTime(2026, 8, 16, 22);
      final end = DateTime(2026, 8, 22, 1);
      expect(
        validateEventInPlanRange(DateTime(2026, 8, 16, 0), start, end),
        isNull,
      );
      expect(
        validateEventInPlanRange(DateTime(2026, 8, 22, 23), start, end),
        isNull,
      );
      expect(
        validateEventInPlanRange(DateTime(2026, 8, 23), start, end),
        EventPlanRangeValidationError.outside,
      );
    });
  });
}
