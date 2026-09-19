import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_map_stop.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_map_day_colors.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_map_stop_builder.dart';

import 'plan_test_helpers.dart';

Event _placeEvent({
  required String id,
  required DateTime date,
  required int hour,
  required int minute,
  required String description,
  required double lat,
  required double lng,
  String? family,
  String? location,
}) {
  final day = DateTime(date.year, date.month, date.day);
  return sampleEvent(
    planId: 'plan1',
    userId: 'owner',
    description: description,
    date: day,
    hour: hour,
    typeFamily: family ?? 'Actividad',
    commonPart: EventCommonPart(
      description: description,
      date: day,
      startHour: hour,
      startMinute: minute,
      durationMinutes: 60,
      location: location,
      family: family ?? 'Actividad',
      extraData: {
        'placeLat': lat,
        'placeLng': lng,
        'placeName': description,
      },
    ),
  ).copyWith(id: id);
}

void main() {
  final planStart = DateTime(2026, 8, 10);
  final plan = samplePlan(userId: 'owner', name: 'Roma').copyWith(
    startDate: planStart,
    endDate: planStart.add(const Duration(days: 4)),
    baseDate: planStart,
    columnCount: 5,
  );

  group('PlanMapStopBuilder', () {
    test('numera visitas por día y usa un color distinto cada día', () {
      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: [
          _placeEvent(
            id: 'e1',
            date: planStart,
            hour: 10,
            minute: 0,
            description: 'Coliseo',
            lat: 41.89,
            lng: 12.49,
          ),
          _placeEvent(
            id: 'e2',
            date: planStart,
            hour: 16,
            minute: 0,
            description: 'Foro',
            lat: 41.892,
            lng: 12.485,
          ),
          _placeEvent(
            id: 'e3',
            date: planStart.add(const Duration(days: 1)),
            hour: 11,
            minute: 0,
            description: 'Vaticano',
            lat: 41.902,
            lng: 12.453,
          ),
        ],
        accommodations: const [],
      );

      expect(data.stops, hasLength(3));
      expect(data.dayIndexes, [0, 1]);
      final day0 = data.visibleStops(0).where((s) => s.isVisit).toList();
      expect(day0.map((s) => s.sequenceInDay), [1, 2]);
      expect(day0.map((s) => s.title), ['Coliseo', 'Foro']);
      expect(day0.first.colorHex, PlanMapDayColors.hexForDay(0));
      final day1 = data.visibleStops(1).where((s) => s.isVisit).toList();
      expect(day1.single.sequenceInDay, 1);
      expect(day1.single.colorHex, PlanMapDayColors.hexForDay(1));
      expect(day0.first.colorHex, isNot(day1.single.colorHex));
      expect(data.routes, hasLength(1));
      expect(data.routes.single.dayIndex, 0);
      expect(data.routes.single.points, hasLength(2));
    });

    test('excluye desplazamientos y eventos sin lugar ni título', () {
      final taxiDay = DateTime(planStart.year, planStart.month, planStart.day);
      final taxi = sampleEvent(
        planId: 'plan1',
        userId: 'owner',
        description: 'Taxi',
        date: taxiDay,
        hour: 9,
        typeFamily: 'Desplazamiento',
        commonPart: EventCommonPart(
          description: 'Taxi',
          date: taxiDay,
          startHour: 9,
          startMinute: 0,
          durationMinutes: 30,
          family: 'Desplazamiento',
          extraData: {
            'placeLat': 41.9,
            'placeLng': 12.5,
            'taxiDestinationLat': 41.91,
            'taxiDestinationLng': 12.51,
          },
        ),
      ).copyWith(id: 'taxi');
      final empty = sampleEvent(
        planId: 'plan1',
        userId: 'owner',
        description: '',
        date: taxiDay,
        hour: 12,
        typeFamily: 'Actividad',
        commonPart: EventCommonPart(
          description: '',
          date: taxiDay,
          startHour: 12,
          startMinute: 0,
          durationMinutes: 60,
          family: 'Actividad',
        ),
      ).copyWith(id: 'empty');

      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: [taxi, empty],
        accommodations: const [],
      );
      expect(data.stops, isEmpty);
    });

    test('visita sin coords pero con lugar entra para geocodificar', () {
      final day = DateTime(planStart.year, planStart.month, planStart.day);
      final walk = sampleEvent(
        planId: 'plan1',
        userId: 'owner',
        description: 'Paseo por Oxford',
        date: day,
        hour: 10,
        typeFamily: 'Actividad',
        commonPart: EventCommonPart(
          description: 'Paseo por Oxford',
          date: day,
          startHour: 10,
          startMinute: 0,
          durationMinutes: 120,
          location: 'Oxford',
          family: 'Actividad',
          extraData: const {'placeName': 'Oxford'},
        ),
      ).copyWith(id: 'oxford-walk');

      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: [walk],
        accommodations: const [],
      );

      expect(data.stops, hasLength(1));
      expect(data.stops.single.title, 'Paseo por Oxford');
      expect(data.stops.single.hasPosition, isFalse);
      expect(data.stops.single.geocodeQuery, 'Oxford');
      expect(data.stops.single.sequenceInDay, 1);
    });

    test('acepta placeLat/placeLng guardados como texto', () {
      final day = DateTime(planStart.year, planStart.month, planStart.day);
      final visita = sampleEvent(
        planId: 'plan1',
        userId: 'owner',
        description: 'Visita Hidcote',
        date: day,
        hour: 11,
        typeFamily: 'Actividad',
        commonPart: EventCommonPart(
          description: 'Visita Hidcote',
          date: day,
          startHour: 11,
          startMinute: 0,
          durationMinutes: 60,
          family: 'Actividad',
          subtype: 'Visita',
          extraData: const {
            'placeLat': '52.083',
            'placeLng': '-1.744',
            'placeName': 'Hidcote',
          },
        ),
      ).copyWith(id: 'hidcote');

      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: [visita],
        accommodations: const [],
      );
      expect(data.stops, hasLength(1));
      expect(data.stops.single.title, 'Visita Hidcote');
      expect(data.stops.single.lat, closeTo(52.083, 0.001));
    });

    test('vuelo pinta aeropuerto cercano con A y oculta el de casa', () {
      final flightDay = DateTime(planStart.year, planStart.month, planStart.day);
      final flight = sampleEvent(
        planId: 'plan1',
        userId: 'owner',
        description: 'MAD-FCO',
        date: flightDay,
        hour: 8,
        durationMinutes: 150,
        typeFamily: 'Desplazamiento',
        commonPart: EventCommonPart(
          description: 'MAD-FCO',
          date: flightDay,
          startHour: 8,
          startMinute: 0,
          durationMinutes: 150,
          family: 'Desplazamiento',
          subtype: 'Avión',
          extraData: {
            'departureAirport': 'Madrid Barajas',
            'departureAirportLat': 40.49,
            'departureAirportLng': -3.57,
            'arrivalAirport': 'Roma Fiumicino',
            'arrivalAirportLat': 41.80,
            'arrivalAirportLng': 12.25,
          },
        ),
      ).copyWith(id: 'flight1', typeSubtype: 'Avión');

      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: [
          flight,
          _placeEvent(
            id: 'cena',
            date: planStart,
            hour: 20,
            minute: 0,
            description: 'Cena',
            lat: 41.895,
            lng: 12.482,
            family: 'Restauración',
          ),
        ],
        accommodations: const [],
      );

      final airports =
          data.stops.where((s) => s.kind == PlanMapStopKind.airport).toList();
      expect(airports, hasLength(1));
      expect(airports.single.title, contains('Fiumicino'));
      expect(airports.single.sequenceInDay, isNull);
      expect(airports.single.isArrivalOn(0), isTrue);
      expect(
        data.stops.where((s) => s.isVisit).single.sequenceInDay,
        1,
      );
      expect(data.orderedVisibleStops(0).first.kind, PlanMapStopKind.airport);
      expect(data.orderedVisibleStops(0).last.title, 'Cena');
      expect(data.routes.single.points.first.lat, closeTo(41.80, 0.01));
    });

    test('vuelo nocturno marca la llegada al día siguiente', () {
      final flightDay = DateTime(planStart.year, planStart.month, planStart.day);
      final flight = sampleEvent(
        planId: 'plan1',
        userId: 'owner',
        description: 'Vuelo noche',
        date: flightDay,
        hour: 22,
        durationMinutes: 8 * 60,
        typeFamily: 'Desplazamiento',
        commonPart: EventCommonPart(
          description: 'Vuelo noche',
          date: flightDay,
          startHour: 22,
          startMinute: 0,
          durationMinutes: 8 * 60,
          family: 'Desplazamiento',
          subtype: 'Avión',
          extraData: {
            'departureAirport': 'Madrid Barajas',
            'departureAirportLat': 40.49,
            'departureAirportLng': -3.57,
            'arrivalAirport': 'Roma Fiumicino',
            'arrivalAirportLat': 41.80,
            'arrivalAirportLng': 12.25,
          },
        ),
      ).copyWith(id: 'night', typeSubtype: 'Avión');

      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: [
          flight,
          _placeEvent(
            id: 'museo',
            date: planStart.add(const Duration(days: 1)),
            hour: 11,
            minute: 0,
            description: 'Museo',
            lat: 41.89,
            lng: 12.49,
          ),
        ],
        accommodations: const [],
      );

      final airport = data.stops.singleWhere(
        (s) => s.kind == PlanMapStopKind.airport,
      );
      expect(airport.isArrivalOn(1), isTrue);
      expect(airport.isArrivalOn(0), isFalse);
      expect(airport.isVisibleOnDay(1), isTrue);
      expect(airport.isVisibleOnDay(0), isFalse);
    });

    test('alojamiento no entra en la secuencia y cubre las noches', () {
      final checkIn = planStart;
      final checkOut = planStart.add(const Duration(days: 3));
      final hotel = Accommodation(
        id: 'h1',
        planId: 'plan1',
        checkIn: checkIn,
        checkOut: checkOut,
        hotelName: 'Hotel Roma',
        createdAt: checkIn,
        updatedAt: checkIn,
        commonPart: AccommodationCommonPart(
          hotelName: 'Hotel Roma',
          checkIn: checkIn,
          checkOut: checkOut,
          address: 'Via del Corso 1',
          extraData: const {'placeLat': 41.9, 'placeLng': 12.48},
        ),
      );

      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: [
          _placeEvent(
            id: 'e1',
            date: planStart,
            hour: 18,
            minute: 0,
            description: 'Cena',
            lat: 41.895,
            lng: 12.482,
            family: 'Restauración',
          ),
        ],
        accommodations: [hotel],
      );

      final hotelStop = data.stops.singleWhere(
        (s) => s.kind == PlanMapStopKind.accommodation,
      );
      expect(hotelStop.sequenceInDay, isNull);
      expect(hotelStop.visibleOnDayIndexes, [0, 1, 2]);
      expect(hotelStop.isVisibleOnDay(1), isTrue);
      expect(hotelStop.isVisibleOnDay(3), isFalse);
      expect(data.visibleStops(0).where((s) => s.isVisit).single.sequenceInDay, 1);
      final ordered = data.orderedVisibleStops(0);
      expect(ordered.first.title, 'Cena');
      expect(ordered.last.kind, PlanMapStopKind.accommodation);
    });

    test('googleMapsDirUrl ordena origen, waypoints y destino', () {
      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: [
          _placeEvent(
            id: 'a',
            date: planStart,
            hour: 9,
            minute: 0,
            description: 'A',
            lat: 1,
            lng: 1,
          ),
          _placeEvent(
            id: 'b',
            date: planStart,
            hour: 11,
            minute: 0,
            description: 'B',
            lat: 2,
            lng: 2,
          ),
          _placeEvent(
            id: 'c',
            date: planStart,
            hour: 13,
            minute: 0,
            description: 'C',
            lat: 3,
            lng: 3,
          ),
        ],
        accommodations: const [],
      );
      final url = PlanMapStopBuilder.googleMapsDirUrl(data.visibleStops(0));
      expect(url, isNotNull);
      expect(url, contains('origin=1.0%2C1.0'));
      expect(url, contains('destination=3.0%2C3.0'));
      expect(url, contains('waypoints=2.0%2C2.0'));
    });

    test('separa tramos andando y coche según Desplazamiento', () {
      final events = [
        _placeEvent(
          id: 'a',
          date: planStart,
          hour: 9,
          minute: 0,
          description: 'A',
          lat: 41.90,
          lng: 12.49,
        ),
        _placeEvent(
          id: 'b',
          date: planStart,
          hour: 11,
          minute: 0,
          description: 'B',
          lat: 41.901,
          lng: 12.491,
        ),
        sampleEvent(
          planId: 'plan1',
          userId: 'owner',
          description: 'Taxi al C',
          date: planStart,
          hour: 12,
          typeFamily: 'Desplazamiento',
          commonPart: EventCommonPart(
            description: 'Taxi al C',
            date: planStart,
            startHour: 12,
            startMinute: 0,
            durationMinutes: 30,
            family: 'Desplazamiento',
            subtype: 'Taxi',
            extraData: {
              'taxiOriginLat': 41.901,
              'taxiOriginLng': 12.491,
              'taxiDestinationLat': 41.89,
              'taxiDestinationLng': 12.48,
            },
          ),
        ).copyWith(id: 'taxi1', typeSubtype: 'Taxi'),
        _placeEvent(
          id: 'c',
          date: planStart,
          hour: 13,
          minute: 0,
          description: 'C',
          lat: 41.89,
          lng: 12.48,
        ),
        _placeEvent(
          id: 'd',
          date: planStart,
          hour: 16,
          minute: 0,
          description: 'D',
          lat: 41.892,
          lng: 12.485,
        ),
      ];
      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: events,
        accommodations: const [],
      );
      final dayStops = data.visibleStops(0);
      final segments = PlanMapStopBuilder.dayRouteSegments(
        dayStops,
        events: events,
        dayIndex: 0,
      );
      expect(
        segments.where((s) => s.mode == PlanMapsTravelMode.walking).length,
        2,
      );
      expect(
        segments.where((s) => s.mode == PlanMapsTravelMode.driving).length,
        1,
      );

      final walkUrls = PlanMapStopBuilder.googleMapsDirUrls(
        dayStops,
        mode: PlanMapsTravelMode.walking,
        events: events,
        dayIndex: 0,
      );
      final driveUrls = PlanMapStopBuilder.googleMapsDirUrls(
        dayStops,
        mode: PlanMapsTravelMode.driving,
        events: events,
        dayIndex: 0,
      );
      expect(walkUrls, isNotEmpty);
      expect(walkUrls.every((u) => u.contains('travelmode=walking')), isTrue);
      // Coche (prueba): todos los pines del día en una ruta driving (A,B,C,D).
      expect(driveUrls.length, 1);
      expect(driveUrls.single, contains('travelmode=driving'));
      expect(driveUrls.single, contains('origin='));
      expect(driveUrls.single, contains('destination='));
      expect(driveUrls.single, contains('waypoints='));
    });

    test('parte URLs si hay más de 10 puntos en un tramo', () {
      final events = <Event>[
        for (var i = 0; i < 12; i++)
          _placeEvent(
            id: 'p$i',
            date: planStart,
            hour: 8 + (i ~/ 2),
            minute: (i % 2) * 30,
            description: 'P$i',
            lat: 41.9 + i * 0.001,
            lng: 12.5 + i * 0.001,
          ),
      ];
      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: events,
        accommodations: const [],
      );
      final urls = PlanMapStopBuilder.googleMapsDirUrls(
        data.visibleStops(0),
        mode: PlanMapsTravelMode.walking,
        events: events,
        dayIndex: 0,
      );
      // 12 puntos → 10 + solape + resto (3), sin tramo fantasma de 1 punto.
      expect(urls.length, 2);
      expect(urls.every((u) => u.contains('/maps/dir/')), isTrue);
    });

    test('6 visitas sin taxi O/D → un solo tramo andando con las 6', () {
      final events = <Event>[
        for (var i = 0; i < 6; i++)
          _placeEvent(
            id: 'v$i',
            date: planStart,
            hour: 9 + i,
            minute: 0,
            description: 'V$i',
            lat: 41.9 + i * 0.002,
            lng: 12.5 + i * 0.002,
          ),
        // Taxi sin coords O/D no debe partir el día (antes lo hacía por hora).
        sampleEvent(
          planId: 'plan1',
          userId: 'owner',
          description: 'Taxi suelto',
          date: planStart,
          hour: 11,
          typeFamily: 'Desplazamiento',
          commonPart: EventCommonPart(
            description: 'Taxi suelto',
            date: planStart,
            startHour: 11,
            startMinute: 0,
            durationMinutes: 20,
            family: 'Desplazamiento',
            subtype: 'Taxi',
          ),
        ).copyWith(id: 'taxi-loose', typeSubtype: 'Taxi'),
      ];
      final data = PlanMapStopBuilder.build(
        plan: plan,
        events: events,
        accommodations: const [],
      );
      final dayStops = data.visibleStops(0);
      final segments = PlanMapStopBuilder.dayRouteSegments(
        dayStops,
        events: events,
        dayIndex: 0,
      );
      final walking =
          segments.where((s) => s.mode == PlanMapsTravelMode.walking).toList();
      expect(walking.length, 1);
      expect(walking.single.stops.length, 6);
      final urls = PlanMapStopBuilder.googleMapsDirUrls(
        dayStops,
        mode: PlanMapsTravelMode.walking,
        events: events,
        dayIndex: 0,
      );
      expect(urls.length, 1);
      expect(urls.single, contains('waypoints='));
    });
  });

  group('PlanMapDayColors', () {
    test('cicla la paleta', () {
      expect(PlanMapDayColors.hexForDay(0), isNot(PlanMapDayColors.hexForDay(1)));
      expect(
        PlanMapDayColors.hexForDay(PlanMapDayColors.hexPalette.length),
        PlanMapDayColors.hexForDay(0),
      );
    });
  });
}
