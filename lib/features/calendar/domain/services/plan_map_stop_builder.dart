import 'dart:math' as math;

import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_map_stop.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_event_accent_colors.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_map_day_colors.dart';

/// Construye pines y recorridos del mapa a partir de eventos y alojamientos con coordenadas.
class PlanMapStopBuilder {
  PlanMapStopBuilder._();

  /// Un aeropuerto más lejos que esto de visitas/hoteles no se pinta (evita MAD en un mapa de Roma).
  static const double _airportNearPlanKm = 180;

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static int _dayIndex(DateTime day, DateTime planStart) =>
      _dayOnly(day).difference(_dayOnly(planStart)).inDays;

  static bool _isTransport(Event event) {
    final family = PlanEventAccentColors.normalizeFamily(
      event.commonPart?.family ?? event.typeFamily,
    );
    return family == 'Desplazamiento';
  }

  static bool _isPlane(Event event) {
    if (!_isTransport(event)) return false;
    final sub =
        (event.commonPart?.subtype ?? event.typeSubtype ?? '').trim().toLowerCase();
    return sub == 'avión' || sub == 'avion';
  }

  static DateTime _eventStart(Event event) {
    final date = event.date;
    return DateTime(
      date.year,
      date.month,
      date.day,
      event.hour,
      event.startMinute,
    );
  }

  static DateTime _eventEnd(Event event) {
    return _eventStart(event).add(Duration(minutes: event.durationMinutes));
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }

  static Map<String, dynamic>? _extraOf(Event event) {
    final extra = event.commonPart?.extraData;
    final details = event.details;
    if (extra == null && details == null) return null;
    return {
      if (details != null) ...details,
      if (extra != null) ...extra,
    };
  }

  static ({double lat, double lng})? _coords(Map<String, dynamic>? extra) {
    if (extra == null) return null;
    final lat = _asDouble(extra['placeLat']) ?? _asDouble(extra['lat']);
    final lng = _asDouble(extra['placeLng']) ?? _asDouble(extra['lng']);
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    return (lat: lat, lng: lng);
  }

  static String? _geocodeQuery(Event event, {required String title}) {
    final extra = _extraOf(event);
    for (final value in [
      extra?['placeAddress'],
      extra?['placeName'],
      event.commonPart?.location,
      extra?['formattedAddress'],
    ]) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    if (title.isNotEmpty) return title;
    return null;
  }

  static ({double lat, double lng})? _namedCoords(
    Map<String, dynamic>? extra, {
    required String latKey,
    required String lngKey,
  }) {
    final lat = _asDouble(extra?[latKey]);
    final lng = _asDouble(extra?[lngKey]);
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    return (lat: lat, lng: lng);
  }

  static String _firstNonEmpty(Iterable<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String _eventTitle(Event event) {
    final d = (event.commonPart?.description ?? event.description).trim();
    if (d.isNotEmpty) return d;
    final place = (event.commonPart?.extraData?['placeName'] as String?)?.trim();
    if (place != null && place.isNotEmpty) return place;
    return (event.commonPart?.location ?? '').trim();
  }

  static double _distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthKm = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * math.pi / 180;

  static String _geoKey(double lat, double lng) =>
      '${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}';

  static PlanMapData build({
    required Plan plan,
    required List<Event> events,
    required List<Accommodation> accommodations,
  }) {
    final planStart = _dayOnly(plan.startDate);
    final visits = <PlanMapStop>[];

    final datedEvents = [...events]..sort((a, b) {
        final c = _eventStart(a).compareTo(_eventStart(b));
        if (c != 0) return c;
        return (a.id ?? '').compareTo(b.id ?? '');
      });

    final sequenceByDay = <int, int>{};

    for (final event in datedEvents) {
      if (_isTransport(event)) continue;
      final extra = _extraOf(event);
      final coords = _coords(extra);
      final title = _eventTitle(event);
      if (title.isEmpty) continue;
      final query = coords == null ? _geocodeQuery(event, title: title) : null;
      if (coords == null && (query == null || query.isEmpty)) continue;
      final start = _eventStart(event);
      final day = _dayOnly(start);
      final dayIndex = _dayIndex(day, planStart);
      final seq = (sequenceByDay[dayIndex] ?? 0) + 1;
      sequenceByDay[dayIndex] = seq;
      final placeName =
          (extra?['placeName'] as String?)?.trim() ?? '';
      final placeAddress =
          (extra?['placeAddress'] as String?)?.trim() ??
              '';
      final location = (event.commonPart?.location ?? '').trim();
      final address = placeAddress.isNotEmpty
          ? placeAddress
          : (location.isNotEmpty && location != title ? location : null);
      visits.add(
        PlanMapStop(
          id: 'event:${event.id ?? title}',
          kind: PlanMapStopKind.place,
          lat: coords?.lat,
          lng: coords?.lng,
          geocodeQuery: query,
          title: title,
          address: address ?? (placeName.isNotEmpty && placeName != title ? placeName : null),
          day: day,
          dayIndex: dayIndex,
          sequenceInDay: seq,
          colorHex: PlanMapDayColors.hexForDay(dayIndex),
          startAt: start,
          eventId: event.id,
          visibleOnDayIndexes: [dayIndex],
        ),
      );
    }

    final hotels = <PlanMapStop>[];
    for (final acc in accommodations) {
      final extra = acc.commonPart?.extraData;
      final coords = _coords(extra);
      if (coords == null) continue;
      final hotelName = (acc.commonPart?.hotelName ?? acc.hotelName).trim();
      if (hotelName.isEmpty) continue;
      final checkIn = _dayOnly(acc.commonPart?.checkIn ?? acc.checkIn);
      final dayIndex = _dayIndex(checkIn, planStart);
      final visibleDays = <int>[];
      var cursor = checkIn;
      final checkOut = _dayOnly(acc.commonPart?.checkOut ?? acc.checkOut);
      while (cursor.isBefore(checkOut)) {
        visibleDays.add(_dayIndex(cursor, planStart));
        cursor = cursor.add(const Duration(days: 1));
      }
      if (visibleDays.isEmpty) {
        visibleDays.add(dayIndex);
      }
      final address = (acc.commonPart?.address ?? '').trim();
      hotels.add(
        PlanMapStop(
          id: 'acc:${acc.id ?? hotelName}',
          kind: PlanMapStopKind.accommodation,
          lat: coords.lat,
          lng: coords.lng,
          title: hotelName,
          address: address.isNotEmpty && address != hotelName ? address : null,
          day: checkIn,
          dayIndex: dayIndex,
          sequenceInDay: null,
          colorHex: PlanMapDayColors.hexForDay(dayIndex),
          startAt: acc.commonPart?.checkIn ?? acc.checkIn,
          accommodationId: acc.id,
          visibleOnDayIndexes: visibleDays,
        ),
      );
    }

    final airports = _buildAirports(
      events: datedEvents,
      planStart: planStart,
      anchors: [...visits, ...hotels],
    );

    final routes = <PlanMapDayRoute>[];
    final daySet = <int>{};
    for (final s in visits) {
      daySet.add(s.dayIndex);
    }
    for (final s in hotels) {
      daySet.addAll(s.visibleOnDayIndexes);
    }
    for (final s in airports) {
      daySet.addAll(s.visibleOnDayIndexes);
    }
    final dayIndexes = daySet.toList()..sort();

    for (final dayIndex in dayIndexes) {
      final points = <({double lat, double lng})>[];
      void addPoint(PlanMapStop stop) {
        if (!stop.hasPosition) return;
        if (points.isNotEmpty &&
            points.last.lat == stop.lat &&
            points.last.lng == stop.lng) {
          return;
        }
        points.add((lat: stop.lat!, lng: stop.lng!));
      }

      final dayAirports = airports.where((s) => s.isVisibleOnDay(dayIndex));
      for (final stop in dayAirports.where((s) => s.isArrivalOn(dayIndex))) {
        addPoint(stop);
      }
      final dayVisits = visits.where((s) => s.dayIndex == dayIndex).toList()
        ..sort((a, b) => (a.sequenceInDay ?? 0).compareTo(b.sequenceInDay ?? 0));
      for (final stop in dayVisits) {
        addPoint(stop);
      }
      for (final stop in dayAirports.where((s) => s.isDepartureOn(dayIndex))) {
        addPoint(stop);
      }
      if (points.length < 2) continue;
      routes.add(
        PlanMapDayRoute(
          dayIndex: dayIndex,
          colorHex: PlanMapDayColors.hexForDay(dayIndex),
          points: points,
        ),
      );
    }

    return PlanMapData(
      stops: [...visits, ...hotels, ...airports],
      routes: routes,
      dayIndexes: dayIndexes,
    );
  }

  static List<PlanMapStop> _buildAirports({
    required List<Event> events,
    required DateTime planStart,
    required List<PlanMapStop> anchors,
  }) {
    final merged = <String, _AirportAgg>{};

    void addEndpoint({
      required Event event,
      required ({double lat, double lng}) coords,
      required String title,
      required String? address,
      required DateTime at,
      required bool arrival,
    }) {
      final name = title.trim();
      if (name.isEmpty) return;
      final day = _dayOnly(at);
      final dayIndex = _dayIndex(day, planStart);
      final key = _geoKey(coords.lat, coords.lng);
      final agg = merged.putIfAbsent(
        key,
        () => _AirportAgg(
          lat: coords.lat,
          lng: coords.lng,
          title: name,
          address: address,
          eventId: event.id,
          startAt: at,
          day: day,
          dayIndex: dayIndex,
        ),
      );
      if (name.length > agg.title.length) agg.title = name;
      if ((agg.address == null || agg.address!.isEmpty) &&
          address != null &&
          address.isNotEmpty) {
        agg.address = address;
      }
      if (at.isBefore(agg.startAt)) {
        agg.startAt = at;
        agg.day = day;
        agg.dayIndex = dayIndex;
      }
      agg.visible.add(dayIndex);
      if (arrival) {
        agg.arrivals.add(dayIndex);
      } else {
        agg.departures.add(dayIndex);
      }
    }

    for (final event in events) {
      if (!_isPlane(event)) continue;
      final extra = event.commonPart?.extraData;
      final dep = _namedCoords(
        extra,
        latKey: 'departureAirportLat',
        lngKey: 'departureAirportLng',
      );
      final arr = _namedCoords(
        extra,
        latKey: 'arrivalAirportLat',
        lngKey: 'arrivalAirportLng',
      );
      if (dep != null) {
        addEndpoint(
          event: event,
          coords: dep,
          title: _firstNonEmpty([
            extra?['departureAirport'],
            extra?['originName'],
            extra?['originIata'],
          ]),
          address: (extra?['departureAirportAddress'] as String?)?.trim(),
          at: _eventStart(event),
          arrival: false,
        );
      }
      if (arr != null) {
        addEndpoint(
          event: event,
          coords: arr,
          title: _firstNonEmpty([
            extra?['arrivalAirport'],
            extra?['destinationName'],
            extra?['destinationIata'],
          ]),
          address: (extra?['arrivalAirportAddress'] as String?)?.trim(),
          at: _eventEnd(event),
          arrival: true,
        );
      }
    }

    bool nearPlan(_AirportAgg agg) {
      final positioned = anchors.where((a) => a.hasPosition);
      if (positioned.isEmpty) return true;
      for (final anchor in positioned) {
        if (_distanceKm(agg.lat, agg.lng, anchor.lat!, anchor.lng!) <=
            _airportNearPlanKm) {
          return true;
        }
      }
      return false;
    }

    final stops = <PlanMapStop>[];
    for (final agg in merged.values) {
      if (!nearPlan(agg)) continue;
      final visible = agg.visible.toList()..sort();
      final arrivals = agg.arrivals.toList()..sort();
      final departures = agg.departures.toList()..sort();
      stops.add(
        PlanMapStop(
          id: 'airport:${_geoKey(agg.lat, agg.lng)}',
          kind: PlanMapStopKind.airport,
          lat: agg.lat,
          lng: agg.lng,
          title: agg.title,
          address: agg.address,
          day: agg.day,
          dayIndex: agg.dayIndex,
          sequenceInDay: null,
          colorHex: PlanMapDayColors.hexForDay(agg.dayIndex),
          startAt: agg.startAt,
          eventId: agg.eventId,
          visibleOnDayIndexes: visible,
          arrivalOnDayIndexes: arrivals,
          departureOnDayIndexes: departures,
        ),
      );
    }
    return stops;
  }

  /// Google Maps admite origen + destino + hasta 8 waypoints (10 puntos).
  static const int maxMapsDirPoints = 10;

  /// Radio (km) para emparejar origen/destino de un desplazamiento con dos pines.
  static const double _transportMatchKm = 0.85;

  /// URL de direcciones Google Maps para las visitas de un día (máx. 10 puntos).
  /// Por compatibilidad usa `walking` y solo el primer tramo si hay más de 10.
  static String? googleMapsDirUrl(List<PlanMapStop> dayVisits) {
    final urls = googleMapsDirUrls(
      dayVisits,
      mode: PlanMapsTravelMode.walking,
    );
    return urls.isEmpty ? null : urls.first;
  }

  /// URLs de Google Maps para tramos del [mode] en el día representado por [dayStops].
  ///
  /// - **driving (prueba):** todos los pines del día con coordenadas, en orden,
  ///   como una sola ruta `travelmode=driving` (partes si hay >10 puntos).
  /// - **walking:** visita el itinerario andando; corta solo si hay Coche/Taxi/Caminar
  ///   con origen→destino cerca de dos pines consecutivos.
  static List<String> googleMapsDirUrls(
    List<PlanMapStop> dayStops, {
    required PlanMapsTravelMode mode,
    List<Event> events = const [],
    int? dayIndex,
  }) {
    if (mode == PlanMapsTravelMode.driving) {
      final points = _routeStopsForMaps(dayStops);
      return _urlsForStops(points, travelMode: 'driving');
    }

    final segments = dayRouteSegments(
      dayStops,
      events: events,
      dayIndex: dayIndex,
    ).where((s) => s.mode == mode).toList();
    final urls = <String>[];
    for (final segment in segments) {
      urls.addAll(_urlsForStops(segment.stops, travelMode: segment.travelModeParam));
    }
    return urls;
  }

  /// Segmenta el recorrido del día en tramos walking/driving.
  static List<PlanMapsRouteSegment> dayRouteSegments(
    List<PlanMapStop> dayStops, {
    List<Event> events = const [],
    int? dayIndex,
  }) {
    final points = _routeStopsForMaps(dayStops);
    if (points.isEmpty) return const [];

    final resolvedDay = dayIndex ??
        (points.map((p) => p.dayIndex).toSet().length == 1
            ? points.first.dayIndex
            : null);

    DateTime? civilDay;
    if (resolvedDay != null) {
      for (final s in dayStops) {
        if (s.dayIndex == resolvedDay) {
          civilDay = _dayOnly(s.day);
          break;
        }
      }
    }
    civilDay ??= points.isNotEmpty ? _dayOnly(points.first.day) : null;

    final dayTransports = events.where((e) {
      if (!_isTransport(e)) return false;
      if (civilDay == null) return true;
      return _dayOnly(_eventStart(e)) == civilDay;
    }).toList()
      ..sort((a, b) => _eventStart(a).compareTo(_eventStart(b)));

    if (points.length == 1) {
      return [
        PlanMapsRouteSegment(mode: PlanMapsTravelMode.walking, stops: points),
      ];
    }

    final edgeModes = <PlanMapsTravelMode>[];
    for (var i = 0; i < points.length - 1; i++) {
      edgeModes.add(_edgeTravelMode(points[i], points[i + 1], dayTransports));
    }

    final segments = <PlanMapsRouteSegment>[];
    void flush(PlanMapsTravelMode mode, List<PlanMapStop> buf) {
      if (buf.length >= 2) {
        segments.add(PlanMapsRouteSegment(mode: mode, stops: List.of(buf)));
      }
    }

    for (final target in PlanMapsTravelMode.values) {
      List<PlanMapStop>? buf;
      for (var i = 0; i < edgeModes.length; i++) {
        if (edgeModes[i] == target) {
          buf ??= [points[i]];
          final next = points[i + 1];
          if (buf.last.lat != next.lat || buf.last.lng != next.lng) {
            buf.add(next);
          }
        } else if (buf != null) {
          flush(target, buf);
          buf = null;
        }
      }
      if (buf != null) flush(target, buf);
    }

    // Desplazamientos en coche con O/D propios que no encajan como arista.
    for (final e in dayTransports) {
      if (_mapsModeForEvent(e) != PlanMapsTravelMode.driving) continue;
      final o = _transportOrigin(e);
      final d = _transportDestination(e);
      if (o == null || d == null) continue;
      final already = segments.any((s) {
        if (s.mode != PlanMapsTravelMode.driving || s.stops.length < 2) {
          return false;
        }
        return _near(s.stops.first.lat!, s.stops.first.lng!, o.lat, o.lng) &&
            _near(s.stops.last.lat!, s.stops.last.lng!, d.lat, d.lng);
      });
      if (already) continue;
      segments.add(
        PlanMapsRouteSegment(
          mode: PlanMapsTravelMode.driving,
          stops: [
            PlanMapStop(
              id: 'drive-o:${e.id ?? e.hashCode}',
              kind: PlanMapStopKind.place,
              lat: o.lat,
              lng: o.lng,
              title: _firstNonEmpty([
                e.commonPart?.extraData?['taxiOriginName'],
                'Origen',
              ]),
              day: _dayOnly(_eventStart(e)),
              dayIndex: resolvedDay ?? 0,
              colorHex: '#000000',
              visibleOnDayIndexes: [resolvedDay ?? 0],
              startAt: _eventStart(e),
              eventId: e.id,
            ),
            PlanMapStop(
              id: 'drive-d:${e.id ?? e.hashCode}',
              kind: PlanMapStopKind.place,
              lat: d.lat,
              lng: d.lng,
              title: _firstNonEmpty([
                e.commonPart?.extraData?['taxiDestinationName'],
                'Destino',
              ]),
              day: _dayOnly(_eventStart(e)),
              dayIndex: resolvedDay ?? 0,
              colorHex: '#000000',
              visibleOnDayIndexes: [resolvedDay ?? 0],
              startAt: _eventEnd(e),
              eventId: e.id,
            ),
          ],
        ),
      );
    }

    if (segments.isEmpty && points.length >= 2) {
      // Sin tipado: un solo tramo andando (comportamiento previo).
      segments.add(
        PlanMapsRouteSegment(mode: PlanMapsTravelMode.walking, stops: points),
      );
    }
    return segments;
  }

  static PlanMapsTravelMode? _mapsModeForEvent(Event event) {
    final sub =
        (event.commonPart?.subtype ?? event.typeSubtype ?? '').trim();
    switch (sub) {
      case 'Caminar':
        return PlanMapsTravelMode.walking;
      case 'Coche':
      case 'Taxi':
      case 'Recogida vehículo alquiler':
      case 'Entrega vehículo alquiler':
        return PlanMapsTravelMode.driving;
      default:
        // Avión / tren / bus / shuttle: no van a los botones andando/coche.
        return null;
    }
  }

  static ({double lat, double lng})? _transportOrigin(Event event) {
    final extra = _extraOf(event);
    // Solo origen explícito de Desplazamiento (no placeLat del evento).
    return _namedCoords(extra, latKey: 'taxiOriginLat', lngKey: 'taxiOriginLng');
  }

  static ({double lat, double lng})? _transportDestination(Event event) {
    final extra = _extraOf(event);
    return _namedCoords(
      extra,
      latKey: 'taxiDestinationLat',
      lngKey: 'taxiDestinationLng',
    );
  }

  static bool _near(double lat1, double lng1, double lat2, double lng2) =>
      _distanceKm(lat1, lng1, lat2, lng2) <= _transportMatchKm;

  /// Modo de la arista entre dos pines.
  /// Solo corta el itinerario si hay Coche/Taxi/Caminar con origen→destino
  /// cerca de esos dos pines (no por hora suelta: eso partía el día en pares).
  static PlanMapsTravelMode _edgeTravelMode(
    PlanMapStop a,
    PlanMapStop b,
    List<Event> dayTransports,
  ) {
    if (!a.hasPosition || !b.hasPosition) {
      return PlanMapsTravelMode.walking;
    }
    for (final e in dayTransports) {
      final mode = _mapsModeForEvent(e);
      if (mode == null) continue;
      final o = _transportOrigin(e);
      final d = _transportDestination(e);
      if (o == null || d == null) continue;
      if (_near(o.lat, o.lng, a.lat!, a.lng!) &&
          _near(d.lat, d.lng, b.lat!, b.lng!)) {
        return mode;
      }
    }
    return PlanMapsTravelMode.walking;
  }

  static List<String> _urlsForStops(
    List<PlanMapStop> points, {
    required String travelMode,
  }) {
    final withPos = points.where((p) => p.hasPosition).toList();
    if (withPos.isEmpty) return const [];
    if (withPos.length == 1) {
      final p = withPos.first;
      return ['https://www.google.com/maps?q=${p.lat},${p.lng}'];
    }
    final urls = <String>[];
    var start = 0;
    while (start < withPos.length) {
      final remaining = withPos.length - start;
      // Tras un solape, un único punto suelto ya era el destino del tramo anterior.
      if (remaining == 1 && urls.isNotEmpty) break;
      final take = remaining <= maxMapsDirPoints
          ? remaining
          : maxMapsDirPoints;
      final chunk = withPos.sublist(start, start + take);
      final url = _dirUrlForChunk(chunk, travelMode: travelMode);
      if (url != null) urls.add(url);
      if (start + take >= withPos.length) break;
      // Solape de 1 punto para encadenar partes.
      start += take - 1;
    }
    return urls;
  }

  static String? _dirUrlForChunk(
    List<PlanMapStop> limited, {
    required String travelMode,
  }) {
    if (limited.isEmpty) return null;
    if (limited.length == 1) {
      final p = limited.first;
      return 'https://www.google.com/maps?q=${p.lat},${p.lng}';
    }
    final origin = '${limited.first.lat},${limited.first.lng}';
    final destination = '${limited.last.lat},${limited.last.lng}';
    final waypoints = limited.length <= 2
        ? ''
        : limited
            .sublist(1, limited.length - 1)
            .map((p) => '${p.lat},${p.lng}')
            .join('|');
    final params = <String, String>{
      'api': '1',
      'origin': origin,
      'destination': destination,
      'travelmode': travelMode,
    };
    if (waypoints.isNotEmpty) {
      params['waypoints'] = waypoints;
    }
    return Uri.https('www.google.com', '/maps/dir/', params).toString();
  }

  static List<PlanMapStop> _routeStopsForMaps(List<PlanMapStop> stops) {
    final visitDays = stops.where((s) => s.isVisit).map((s) => s.dayIndex).toSet();
    final airportDays = <int>{};
    for (final s in stops.where((s) => s.kind == PlanMapStopKind.airport)) {
      airportDays.addAll(s.visibleOnDayIndexes);
    }
    final singleDay = visitDays.length == 1
        ? visitDays.single
        : (visitDays.isEmpty && airportDays.length == 1 ? airportDays.single : null);

    final visits = stops.where((s) => s.isVisit).toList()
      ..sort((a, b) {
        final day = a.dayIndex.compareTo(b.dayIndex);
        if (day != 0) return day;
        return (a.sequenceInDay ?? 0).compareTo(b.sequenceInDay ?? 0);
      });

    if (singleDay == null) return visits;

    final ordered = <PlanMapStop>[];
    void addUnique(PlanMapStop stop) {
      if (!stop.hasPosition) return;
      if (ordered.any((s) => s.lat == stop.lat && s.lng == stop.lng)) return;
      ordered.add(stop);
    }

    for (final s in stops.where(
      (s) => s.kind == PlanMapStopKind.airport && s.isArrivalOn(singleDay),
    )) {
      addUnique(s);
    }
    for (final s in visits.where((s) => s.dayIndex == singleDay)) {
      addUnique(s);
    }
    for (final s in stops.where(
      (s) => s.kind == PlanMapStopKind.airport && s.isDepartureOn(singleDay),
    )) {
      addUnique(s);
    }
    return ordered;
  }
}

class _AirportAgg {
  _AirportAgg({
    required this.lat,
    required this.lng,
    required this.title,
    required this.address,
    required this.eventId,
    required this.startAt,
    required this.day,
    required this.dayIndex,
  });

  final double lat;
  final double lng;
  String title;
  String? address;
  final String? eventId;
  DateTime startAt;
  DateTime day;
  int dayIndex;
  final visible = <int>{};
  final arrivals = <int>{};
  final departures = <int>{};
}
