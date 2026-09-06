/// Parada del mapa del plan (T279): lugar a visitar, hotel o aeropuerto.
enum PlanMapStopKind {
  place,
  accommodation,
  airport,
}

class PlanMapStop {
  const PlanMapStop({
    required this.id,
    required this.kind,
    required this.title,
    required this.day,
    required this.dayIndex,
    required this.colorHex,
    required this.visibleOnDayIndexes,
    this.lat,
    this.lng,
    this.geocodeQuery,
    this.sequenceInDay,
    this.address,
    this.startAt,
    this.eventId,
    this.accommodationId,
    this.arrivalOnDayIndexes = const [],
    this.departureOnDayIndexes = const [],
  });

  /// `event:{id}` o `acc:{id}`.
  final String id;
  final PlanMapStopKind kind;
  final double? lat;
  final double? lng;
  /// Texto a geocodificar en el mapa si no hay lat/lng (p. ej. Places no elegido).
  final String? geocodeQuery;
  final String title;
  final String? address;
  final DateTime day;
  /// Día civil respecto al inicio del plan (0 = primer día).
  final int dayIndex;
  /// 1-based en el día; null en alojamientos y aeropuertos.
  final int? sequenceInDay;
  final String colorHex;
  final DateTime? startAt;
  final String? eventId;
  final String? accommodationId;
  final List<int> visibleOnDayIndexes;
  /// Días en los que este aeropuerto es llegada de un vuelo.
  final List<int> arrivalOnDayIndexes;
  /// Días en los que este aeropuerto es salida de un vuelo.
  final List<int> departureOnDayIndexes;

  bool get hasPosition => lat != null && lng != null;

  bool get isVisit => kind == PlanMapStopKind.place && sequenceInDay != null;

  bool get isLetterPin =>
      kind == PlanMapStopKind.accommodation || kind == PlanMapStopKind.airport;

  bool isArrivalOn(int dayIndex) => arrivalOnDayIndexes.contains(dayIndex);

  bool isDepartureOn(int dayIndex) => departureOnDayIndexes.contains(dayIndex);

  bool isVisibleOnDay(int? dayIndexFilter) {
    if (dayIndexFilter == null) return true;
    return visibleOnDayIndexes.contains(dayIndexFilter);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (geocodeQuery != null && geocodeQuery!.isNotEmpty)
          'geocodeQuery': geocodeQuery,
        'title': title,
        if (address != null) 'address': address,
        'dayIndex': dayIndex,
        if (sequenceInDay != null) 'sequenceInDay': sequenceInDay,
        'colorHex': colorHex,
        if (startAt != null) 'startAtIso': startAt!.toIso8601String(),
        if (eventId != null) 'eventId': eventId,
        if (accommodationId != null) 'accommodationId': accommodationId,
        'visibleOnDayIndexes': visibleOnDayIndexes,
        if (arrivalOnDayIndexes.isNotEmpty)
          'arrivalOnDayIndexes': arrivalOnDayIndexes,
        if (departureOnDayIndexes.isNotEmpty)
          'departureOnDayIndexes': departureOnDayIndexes,
      };
}

class PlanMapDayRoute {
  const PlanMapDayRoute({
    required this.dayIndex,
    required this.colorHex,
    required this.points,
  });

  final int dayIndex;
  final String colorHex;
  final List<({double lat, double lng})> points;

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'colorHex': colorHex,
        'points': [
          for (final p in points) {'lat': p.lat, 'lng': p.lng},
        ],
      };
}

class PlanMapData {
  const PlanMapData({
    required this.stops,
    required this.routes,
    required this.dayIndexes,
  });

  final List<PlanMapStop> stops;
  final List<PlanMapDayRoute> routes;
  /// Días con al menos un pin, ordenados.
  final List<int> dayIndexes;

  bool get isEmpty => stops.isEmpty;

  List<PlanMapStop> visibleStops(int? dayIndex) =>
      stops.where((s) => s.isVisibleOnDay(dayIndex)).toList();

  /// Orden de lista: día, A llegada, visitas, A salida, hotel (al final, no es parada).
  List<PlanMapStop> orderedVisibleStops(int? dayIndex) {
    final list = visibleStops(dayIndex);
    list.sort((a, b) {
      final day = a.dayIndex.compareTo(b.dayIndex);
      if (day != 0) return day;
      final ga = _listGroup(a, dayIndex);
      final gb = _listGroup(b, dayIndex);
      if (ga != gb) return ga.compareTo(gb);
      final ta = a.startAt ?? a.day;
      final tb = b.startAt ?? b.day;
      final time = ta.compareTo(tb);
      if (time != 0) return time;
      return (a.sequenceInDay ?? 0).compareTo(b.sequenceInDay ?? 0);
    });
    return list;
  }

  static int _listGroup(PlanMapStop stop, int? filterDay) {
    if (stop.kind == PlanMapStopKind.airport) {
      final day = filterDay ?? stop.dayIndex;
      final arrival = stop.isArrivalOn(day);
      final departure = stop.isDepartureOn(day);
      if (departure && !arrival) return 2;
      return 0;
    }
    if (stop.kind == PlanMapStopKind.accommodation) return 3;
    return 1;
  }

  List<PlanMapDayRoute> visibleRoutes(int? dayIndex) {
    if (dayIndex == null) return routes;
    return routes.where((r) => r.dayIndex == dayIndex).toList();
  }
}
