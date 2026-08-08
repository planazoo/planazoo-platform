import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';

/// Rol semántico de la ubicación sugerida (para textos de UI).
enum PreviousLocationRole {
  /// Sitio de un evento (museo, restaurante…) o genérico.
  place,

  /// Destino de un desplazamiento anterior (taxi, tren, avión…).
  transportDestination,

  /// Alojamiento del día.
  accommodation,
}

/// Ubicación reutilizable del ítem inmediatamente anterior (mismo día).
class PreviousPlanLocation {
  const PreviousPlanLocation({
    required this.address,
    required this.sourceKind,
    required this.sourceId,
    this.lat,
    this.lng,
    this.sourceLabel,
    this.role = PreviousLocationRole.place,
  });

  /// Texto para el campo de localización / origen / destino.
  final String address;
  final double? lat;
  final double? lng;

  /// `event` | `accommodation`
  final String sourceKind;
  final String sourceId;

  /// Nombre legible (hotel, descripción, etc.) para UI.
  final String? sourceLabel;

  final PreviousLocationRole role;
}

/// Resuelve ubicaciones del plan para reutilizarlas en el formulario de evento.
///
/// Reglas:
/// - Mismo día civil que [targetStart].
/// - Solo ítems donde participa [userId].
/// - Eventos con inicio estrictamente anterior a [targetStart].
/// - En **Desplazamiento** se usa solo el **destino** (nunca el origen).
/// - Alojamientos activos ese día ([Accommodation.isDateInRange]).
class PreviousPlanLocationHelper {
  PreviousPlanLocationHelper._();

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _userInEvent(Event event, String userId) {
    final common = event.commonPart;
    if (common != null) {
      if (common.isForAllParticipants) return true;
      if (common.participantIds.contains(userId)) return true;
    }
    return event.participantTrackIds.contains(userId);
  }

  static bool _userInAccommodation(Accommodation acc, String userId) {
    final common = acc.commonPart;
    if (common != null) {
      if (common.isForAllParticipants || common.participantIds.isEmpty) {
        return true;
      }
      if (common.participantIds.contains(userId)) return true;
    }
    return acc.participantTrackIds.contains(userId);
  }

  static DateTime _eventStart(Event event) {
    final common = event.commonPart;
    final date = common?.date ?? event.date;
    final hour = common?.startHour ?? event.hour;
    final minute = common?.startMinute ?? event.startMinute;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Inicio simbólico del alojamiento ese día: check-in si es el día de entrada;
  /// si no, medianoche del día (ya estás en el hotel).
  static DateTime _accommodationStartOnDay(Accommodation acc, DateTime day) {
    final dayOnly = _dayOnly(day);
    final checkInDay = _dayOnly(acc.checkIn);
    if (checkInDay == dayOnly) {
      return DateTime(
        acc.checkIn.year,
        acc.checkIn.month,
        acc.checkIn.day,
        acc.checkIn.hour,
        acc.checkIn.minute,
      );
    }
    return dayOnly;
  }

  /// Destino de un desplazamiento (taxi/tren/…) o llegada de avión.
  /// Si no hay destino resoluble → null (no usar origen ni location genérica).
  static PreviousPlanLocation? _destinationFromTransport(Event event) {
    final common = event.commonPart;
    final extra = common?.extraData;
    final subtype = (common?.subtype ?? event.typeSubtype ?? '').trim();
    final label = common?.description ?? event.description;

    final taxiDestName =
        (extra?['taxiDestinationName'] as String?)?.trim() ?? '';
    final taxiDest =
        (extra?['taxiDestinationAddress'] as String?)?.trim() ?? '';
    final destText = taxiDest.isNotEmpty
        ? taxiDest
        : taxiDestName;
    if (destText.isNotEmpty) {
      return PreviousPlanLocation(
        address: destText,
        lat: (extra?['taxiDestinationLat'] as num?)?.toDouble(),
        lng: (extra?['taxiDestinationLng'] as num?)?.toDouble(),
        sourceKind: 'event',
        sourceId: event.id ?? '',
        sourceLabel: taxiDestName.isNotEmpty ? taxiDestName : null,
        role: PreviousLocationRole.transportDestination,
      );
    }

    if (subtype == 'Avión') {
      final arrival = (extra?['arrivalAirport'] as String?)?.trim() ??
          (extra?['destinationName'] as String?)?.trim() ??
          '';
      if (arrival.isNotEmpty) {
        return PreviousPlanLocation(
          address: arrival,
          sourceKind: 'event',
          sourceId: event.id ?? '',
          sourceLabel: label,
          role: PreviousLocationRole.transportDestination,
        );
      }
    }

    return null;
  }

  static PreviousPlanLocation? _locationFromEvent(Event event) {
    final common = event.commonPart;
    final extra = common?.extraData;
    final family = (common?.family ?? event.typeFamily ?? '').trim();

    if (family == 'Desplazamiento') {
      return _destinationFromTransport(event);
    }

    final placeName = (extra?['placeName'] as String?)?.trim() ?? '';
    final placeAddress = (extra?['placeAddress'] as String?)?.trim() ?? '';
    final location = (common?.location ?? event.details?['location'] as String?)
            ?.trim() ??
        '';
    final address = placeAddress.isNotEmpty
        ? placeAddress
        : (location.isNotEmpty ? location : placeName);
    if (address.isEmpty) return null;

    return PreviousPlanLocation(
      address: address,
      lat: (extra?['placeLat'] as num?)?.toDouble(),
      lng: (extra?['placeLng'] as num?)?.toDouble(),
      sourceKind: 'event',
      sourceId: event.id ?? '',
      sourceLabel: placeName.isNotEmpty
          ? placeName
          : (location.isNotEmpty && location != address ? location : null),
      role: PreviousLocationRole.place,
    );
  }

  static PreviousPlanLocation? _locationFromAccommodation(Accommodation acc) {
    final common = acc.commonPart;
    final extra = common?.extraData;
    final address = (common?.address ?? '').trim();
    final hotel = (common?.hotelName ?? acc.hotelName).trim();
    final text = address.isNotEmpty
        ? address
        : (hotel.isNotEmpty ? hotel : '');
    if (text.isEmpty) return null;

    return PreviousPlanLocation(
      address: text,
      lat: (extra?['placeLat'] as num?)?.toDouble(),
      lng: (extra?['placeLng'] as num?)?.toDouble(),
      sourceKind: 'accommodation',
      sourceId: acc.id ?? '',
      sourceLabel: hotel.isNotEmpty ? hotel : text,
      role: PreviousLocationRole.accommodation,
    );
  }

  /// Ubicación del ítem anterior (evento o hotel), o null.
  static PreviousPlanLocation? find({
    required String userId,
    required DateTime targetStart,
    required List<Event> events,
    required List<Accommodation> accommodations,
    String? excludeEventId,
  }) {
    if (userId.isEmpty) return null;

    final targetDay = _dayOnly(targetStart);
    PreviousPlanLocation? best;
    DateTime? bestStart;

    void consider(PreviousPlanLocation? loc, DateTime start) {
      if (loc == null) return;
      if (loc.address.trim().isEmpty) return;
      if (!start.isBefore(targetStart)) return;
      if (bestStart == null || start.isAfter(bestStart!)) {
        best = loc;
        bestStart = start;
      }
    }

    for (final event in events) {
      if (excludeEventId != null &&
          event.id != null &&
          event.id == excludeEventId) {
        continue;
      }
      if (!_userInEvent(event, userId)) continue;
      final start = _eventStart(event);
      if (!_sameDay(start, targetDay)) continue;
      consider(_locationFromEvent(event), start);
    }

    for (final acc in accommodations) {
      if (!_userInAccommodation(acc, userId)) continue;
      if (!acc.isDateInRange(targetDay)) continue;
      final start = _accommodationStartOnDay(acc, targetDay);
      consider(_locationFromAccommodation(acc), start);
    }

    return best;
  }

  /// Alojamientos del día (con ubicación) donde participa el usuario.
  /// Para sugerir como **destino** de un desplazamiento.
  static List<PreviousPlanLocation> sameDayAccommodations({
    required String userId,
    required DateTime day,
    required List<Accommodation> accommodations,
  }) {
    if (userId.isEmpty) return const [];
    final dayOnly = _dayOnly(day);
    final result = <PreviousPlanLocation>[];
    for (final acc in accommodations) {
      if (!_userInAccommodation(acc, userId)) continue;
      if (!acc.isDateInRange(dayOnly)) continue;
      final loc = _locationFromAccommodation(acc);
      if (loc != null) result.add(loc);
    }
    result.sort((a, b) =>
        (a.sourceLabel ?? a.address).compareTo(b.sourceLabel ?? b.address));
    return result;
  }
}
