import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_summary_share_text.dart';

void main() {
  final day = DateTime(2026, 8, 4);
  final day2 = DateTime(2026, 8, 5);

  Event event({
    required String id,
    required DateTime date,
    required String description,
    String? location,
    String? url,
    String? family,
    Map<String, dynamic>? extra,
    int hour = 9,
  }) {
    return Event(
      id: id,
      planId: 'p1',
      userId: 'u1',
      date: date,
      hour: hour,
      duration: 1,
      startMinute: 0,
      durationMinutes: 60,
      description: description,
      createdAt: date,
      updatedAt: date,
      typeFamily: family,
      commonPart: EventCommonPart(
        description: description,
        date: date,
        startHour: hour,
        startMinute: 0,
        durationMinutes: 60,
        location: location,
        url: url,
        family: family,
        extraData: extra,
      ),
    );
  }

  test('markdown uses short labels and hotels after events per day', () {
    final text = PlanSummaryShareText.build(
      planName: 'Roma',
      planStart: day,
      planEnd: day2,
      viewLabel: 'Vista: mío',
      formatEventTime: (_) => '09:00–10:00',
      mapsLabel: 'maps',
      webLabel: 'web',
      routeLabel: 'ruta',
      events: [
        event(
          id: 'e1',
          date: day,
          description: 'Coliseo',
          location: 'Coliseo, Roma',
          url: 'https://www.colosseum.it/',
        ),
      ],
      accommodations: [
        Accommodation(
          id: 'a1',
          planId: 'p1',
          checkIn: day,
          checkOut: day2,
          hotelName: 'Hotel Centro',
          createdAt: day,
          updatedAt: day,
          commonPart: AccommodationCommonPart(
            hotelName: 'Hotel Centro',
            checkIn: day,
            checkOut: day2,
            address: 'Via Roma 1',
            url: 'https://hotel.example',
          ),
        ),
      ],
    );

    expect(text, isNot(contains('— Alojamientos —')));
    expect(text, contains('[maps](https://www.google.com/maps/search/'));
    expect(text, contains('[web](https://www.colosseum.it/)'));
    expect(text, contains('Coliseo'));
    expect(text, contains('Hotel Centro'));
    final coliseoIndex = text.indexOf('Coliseo');
    final hotelIndex = text.indexOf('Hotel Centro');
    expect(hotelIndex, greaterThan(coliseoIndex));
  });

  test('html uses short route label with full href', () {
    final content = PlanSummaryShareContent.fromData(
      planName: 'Viaje',
      planStart: null,
      planEnd: null,
      viewLabel: 'Vista: todos',
      formatEventTime: (_) => '11:00–12:00',
      routeLabel: 'ruta',
      events: [
        event(
          id: 't1',
          date: day,
          description: 'Taxi',
          family: 'Desplazamiento',
          hour: 11,
          extra: {
            'taxiOriginAddress': 'Aeropuerto',
            'taxiDestinationAddress': 'Hotel Centro',
          },
        ),
      ],
      accommodations: const [],
    );

    final html = content.toHtml();
    expect(html, contains('<a href="https://www.google.com/maps/dir/'));
    expect(html, contains('>ruta</a>'));
    expect(html, isNot(contains('Aeropuerto →')));
  });

  test('hotel appears on each active night at end of day section', () {
    final content = PlanSummaryShareContent.fromData(
      planName: 'Viaje',
      planStart: day,
      planEnd: day2,
      viewLabel: 'Vista: todos',
      formatEventTime: (_) => '10:00',
      accommodations: [
        Accommodation(
          id: 'a1',
          planId: 'p1',
          checkIn: day,
          checkOut: day2,
          hotelName: 'Hotel Centro',
          createdAt: day,
          updatedAt: day,
        ),
      ],
      events: const [],
    );

    expect(content.daySections, hasLength(1));
    expect(content.daySections.first.items, hasLength(1));
    expect(content.daySections.first.items.first.isAccommodation, isTrue);
  });
}
