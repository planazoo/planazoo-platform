import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';

import 'plan_test_helpers.dart';

void main() {
  test('withSchedule actualiza hora de la rejilla y commonPart', () {
    final day = DateTime(2026, 9, 26);
    final event = sampleEvent(
      planId: 'plan1',
      userId: 'owner',
      description: 'Bourton',
      date: day,
      hour: 18,
      commonPart: EventCommonPart(
        description: 'Bourton',
        date: day,
        startHour: 18,
        startMinute: 0,
        durationMinutes: 75,
        family: 'Actividad',
      ),
    );

    final moved = event.withSchedule(
      date: day,
      hour: 16,
      startMinute: 45,
      updatedAt: DateTime(2026, 9, 5, 12),
    );

    expect(moved.hour, 16);
    expect(moved.startMinute, 45);
    expect(moved.commonPart!.startHour, 16);
    expect(moved.commonPart!.startMinute, 45);
    expect(moved.description, 'Bourton');
  });
}
