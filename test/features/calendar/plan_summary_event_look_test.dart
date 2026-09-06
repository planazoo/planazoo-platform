import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/l10n/app_localizations_es.dart';
import 'package:unp_calendario/widgets/plan/plan_summary_event_look.dart';

import 'plan_test_helpers.dart';

void main() {
  final loc = AppLocalizationsEs();

  test('formatEventTime usa rango inicio–fin como Mi resumen', () {
    final day = DateTime(2026, 9, 26);
    final event = sampleEvent(
      planId: 'p',
      userId: 'u',
      description: 'Visita Broadway',
      date: day,
      hour: 12,
      durationMinutes: 90,
    );
    expect(PlanSummaryEventLook.formatEventTime(event, loc), '12:00–13:30');
  });

  test('chronologicalTitle antepone el código de vuelo', () {
    final day = DateTime(2026, 9, 26);
    final event = sampleEvent(
      planId: 'p',
      userId: 'u',
      description: 'MAD → FCO',
      date: day,
      hour: 8,
      typeFamily: 'Desplazamiento',
      commonPart: EventCommonPart(
        description: 'MAD → FCO',
        date: day,
        startHour: 8,
        startMinute: 0,
        durationMinutes: 150,
        family: 'Desplazamiento',
        extraData: const {'flightNumber': 'IB3412'},
      ),
    );
    expect(
      PlanSummaryEventLook.chronologicalTitle(event),
      'IB3412 · MAD → FCO',
    );
  });
}
