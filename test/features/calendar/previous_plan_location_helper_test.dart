import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/services/previous_plan_location_helper.dart';

Event _event({
  required String id,
  required DateTime date,
  required int hour,
  required int minute,
  required String userId,
  String? location,
  String? family,
  Map<String, dynamic>? extraData,
  bool isForAll = false,
  List<String>? participantIds,
}) {
  final day = DateTime(date.year, date.month, date.day);
  return Event(
    id: id,
    planId: 'plan1',
    userId: 'owner',
    date: day,
    hour: hour,
    duration: 1,
    startMinute: minute,
    durationMinutes: 60,
    description: 'E$id',
    createdAt: day,
    updatedAt: day,
    commonPart: EventCommonPart(
      description: 'E$id',
      date: day,
      startHour: hour,
      startMinute: minute,
      durationMinutes: 60,
      location: location,
      family: family,
      participantIds: participantIds ?? [userId],
      isForAllParticipants: isForAll,
      extraData: extraData,
    ),
  );
}

Accommodation _hotel({
  required String id,
  required DateTime checkIn,
  required DateTime checkOut,
  required String userId,
  String address = 'Calle Hotel 1',
  String hotelName = 'Hotel Test',
  bool isForAll = false,
}) {
  return Accommodation(
    id: id,
    planId: 'plan1',
    checkIn: checkIn,
    checkOut: checkOut,
    hotelName: hotelName,
    createdAt: checkIn,
    updatedAt: checkIn,
    participantTrackIds: isForAll ? const [] : [userId],
    commonPart: AccommodationCommonPart(
      hotelName: hotelName,
      address: address,
      checkIn: checkIn,
      checkOut: checkOut,
      participantIds: isForAll ? const [] : [userId],
      isForAllParticipants: isForAll,
      extraData: const {'placeLat': 41.0, 'placeLng': 2.0},
    ),
  );
}

void main() {
  final day = DateTime(2026, 8, 3);
  const user = 'userA';

  group('PreviousPlanLocationHelper', () {
    test('returns null when previous event has no location', () {
      final prev = _event(
        id: '1',
        date: day,
        hour: 9,
        minute: 0,
        userId: user,
        location: null,
      );
      final result = PreviousPlanLocationHelper.find(
        userId: user,
        targetStart: DateTime(2026, 8, 3, 11, 0),
        events: [prev],
        accommodations: const [],
      );
      expect(result, isNull);
    });

    test('picks previous same-day event location for participant', () {
      final morning = _event(
        id: '1',
        date: day,
        hour: 9,
        minute: 0,
        userId: user,
        location: 'Museo X',
      );
      final result = PreviousPlanLocationHelper.find(
        userId: user,
        targetStart: DateTime(2026, 8, 3, 12, 0),
        events: [morning],
        accommodations: const [],
      );
      expect(result, isNotNull);
      expect(result!.address, 'Museo X');
      expect(result.sourceKind, 'event');
      expect(result.sourceId, '1');
    });

    test('ignores events of other days and non-participants', () {
      final otherDay = _event(
        id: '1',
        date: DateTime(2026, 8, 2),
        hour: 18,
        minute: 0,
        userId: user,
        location: 'Ayer',
      );
      final otherUser = _event(
        id: '2',
        date: day,
        hour: 10,
        minute: 0,
        userId: 'other',
        location: 'Otro',
        participantIds: const ['other'],
      );
      final result = PreviousPlanLocationHelper.find(
        userId: user,
        targetStart: DateTime(2026, 8, 3, 12, 0),
        events: [otherDay, otherUser],
        accommodations: const [],
      );
      expect(result, isNull);
    });

    test('for transport uses destination as previous location', () {
      final taxi = _event(
        id: 't1',
        date: day,
        hour: 10,
        minute: 0,
        userId: user,
        family: 'Desplazamiento',
        location: 'ignored origin field',
        extraData: {
          'taxiDestinationAddress': 'Aeropuerto',
          'taxiDestinationLat': 40.5,
          'taxiDestinationLng': -3.5,
        },
      );
      final result = PreviousPlanLocationHelper.find(
        userId: user,
        targetStart: DateTime(2026, 8, 3, 12, 0),
        events: [taxi],
        accommodations: const [],
      );
      expect(result!.address, 'Aeropuerto');
      expect(result.lat, 40.5);
      expect(result.lng, -3.5);
      expect(result.role, PreviousLocationRole.transportDestination);
    });

    test('transport without destination is ignored (no origin fallback)', () {
      final taxi = _event(
        id: 't2',
        date: day,
        hour: 10,
        minute: 0,
        userId: user,
        family: 'Desplazamiento',
        location: 'Solo origen en location',
        extraData: {
          'taxiOriginAddress': 'Casa',
        },
      );
      final result = PreviousPlanLocationHelper.find(
        userId: user,
        targetStart: DateTime(2026, 8, 3, 12, 0),
        events: [taxi],
        accommodations: const [],
      );
      expect(result, isNull);
    });

    test('sameDayAccommodations returns hotels for destination picker', () {
      final hotel = _hotel(
        id: 'h1',
        checkIn: DateTime(2026, 8, 2, 15, 0),
        checkOut: DateTime(2026, 8, 5, 11, 0),
        userId: user,
        hotelName: 'Hotel Centro',
        address: 'Plaza 1',
      );
      final list = PreviousPlanLocationHelper.sameDayAccommodations(
        userId: user,
        day: day,
        accommodations: [hotel],
      );
      expect(list, hasLength(1));
      expect(list.first.sourceLabel, 'Hotel Centro');
      expect(list.first.role, PreviousLocationRole.accommodation);
    });

    test('checkout morning hotel is on previous day only (origin case)', () {
      // Noche del 2 → checkout el 3: activo solo el 2 (checkOut exclusive).
      final nightBefore = _hotel(
        id: 'prev',
        checkIn: DateTime(2026, 8, 2, 15, 0),
        checkOut: DateTime(2026, 8, 3, 11, 0),
        userId: user,
        hotelName: 'Hotel Ayer',
        address: 'Calle Ayer 1',
      );
      final tonight = _hotel(
        id: 'today',
        checkIn: DateTime(2026, 8, 3, 15, 0),
        checkOut: DateTime(2026, 8, 4, 11, 0),
        userId: user,
        hotelName: 'Hotel Hoy',
        address: 'Calle Hoy 1',
      );
      final forOrigin = PreviousPlanLocationHelper.sameDayAccommodations(
        userId: user,
        day: DateTime(2026, 8, 2),
        accommodations: [nightBefore, tonight],
      );
      final forDestination = PreviousPlanLocationHelper.sameDayAccommodations(
        userId: user,
        day: day,
        accommodations: [nightBefore, tonight],
      );
      expect(forOrigin.map((e) => e.sourceLabel), ['Hotel Ayer']);
      expect(forDestination.map((e) => e.sourceLabel), ['Hotel Hoy']);
    });

    test('hotel on same day can be previous location', () {
      final hotel = _hotel(
        id: 'h1',
        checkIn: DateTime(2026, 8, 2, 15, 0),
        checkOut: DateTime(2026, 8, 5, 11, 0),
        userId: user,
        address: 'Plaza Hotel 5',
      );
      final result = PreviousPlanLocationHelper.find(
        userId: user,
        targetStart: DateTime(2026, 8, 3, 10, 0),
        events: const [],
        accommodations: [hotel],
      );
      expect(result, isNotNull);
      expect(result!.address, 'Plaza Hotel 5');
      expect(result.sourceKind, 'accommodation');
      expect(result.lat, 41.0);
    });

    test('later event wins over hotel when both candidates', () {
      final hotel = _hotel(
        id: 'h1',
        checkIn: DateTime(2026, 8, 2, 15, 0),
        checkOut: DateTime(2026, 8, 5, 11, 0),
        userId: user,
      );
      final cafe = _event(
        id: 'c1',
        date: day,
        hour: 9,
        minute: 0,
        userId: user,
        location: 'Café',
      );
      final result = PreviousPlanLocationHelper.find(
        userId: user,
        targetStart: DateTime(2026, 8, 3, 11, 0),
        events: [cafe],
        accommodations: [hotel],
      );
      expect(result!.address, 'Café');
      expect(result.sourceKind, 'event');
    });

    test('excludes current event when editing', () {
      final a = _event(
        id: 'keep',
        date: day,
        hour: 8,
        minute: 0,
        userId: user,
        location: 'Antes',
      );
      final editing = _event(
        id: 'edit',
        date: day,
        hour: 10,
        minute: 0,
        userId: user,
        location: 'Actual',
      );
      final result = PreviousPlanLocationHelper.find(
        userId: user,
        targetStart: DateTime(2026, 8, 3, 10, 0),
        events: [a, editing],
        accommodations: const [],
        excludeEventId: 'edit',
      );
      // targetStart == editing start; editing excluded; 'a' starts before → ok
      expect(result!.address, 'Antes');
    });
  });
}
