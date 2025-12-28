import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

/// Servicio para cálculos complejos de vuelos y eventos con timezones
class FlightCalculationService {
  
  /// Calcula la información completa de un vuelo considerando timezones
  static FlightCalculationResult calculateFlightTimes({
    required DateTime departureDate,
    required int departureHour,
    required int departureMinute,
    required int flightDurationMinutes,
    required String departureTimezone,
    required String arrivalTimezone,
    required String organizerTimezone,
  }) {
    
    // 1. Crear DateTime de salida en timezone de origen
    final departureDateTime = DateTime(
      departureDate.year,
      departureDate.month,
      departureDate.day,
      departureHour,
      departureMinute,
    );
    
    // 2. Convertir salida a UTC
    final departureUtc = TimezoneService.localToUtc(departureDateTime, departureTimezone);
    
    // 3. Calcular llegada en UTC
    final arrivalUtc = departureUtc.add(Duration(minutes: flightDurationMinutes));
    
    // 4. Convertir llegada a timezone de destino
    final arrivalInDestinationTimezone = TimezoneService.utcToLocal(arrivalUtc, arrivalTimezone);
    
    // 5. Convertir llegada a timezone del organizador (para mostrar en calendario)
    final arrivalInOrganizerTimezone = TimezoneService.utcToLocal(arrivalUtc, organizerTimezone);
    
    // 6. Calcular información de días
    final departureDay = departureDate;
    final arrivalDay = arrivalInOrganizerTimezone;
    
    // 7. Determinar si cruza días
    final crossesDays = arrivalDay.day != departureDay.day;
    
    return FlightCalculationResult(
      departureDateTime: departureDateTime,
      departureUtc: departureUtc,
      arrivalUtc: arrivalUtc,
      arrivalInDestinationTimezone: arrivalInDestinationTimezone,
      arrivalInOrganizerTimezone: arrivalInOrganizerTimezone,
      departureDay: departureDay,
      arrivalDay: arrivalDay,
      crossesDays: crossesDays,
      flightDurationMinutes: flightDurationMinutes,
      departureTimezone: departureTimezone,
      arrivalTimezone: arrivalTimezone,
      organizerTimezone: organizerTimezone,
    );
  }
  
  /// Calcula los segmentos de un vuelo para mostrar en el calendario
  static List<FlightSegment> calculateFlightSegments(FlightCalculationResult result) {
    final segments = <FlightSegment>[];
    
    if (!result.crossesDays) {
      // Vuelo en el mismo día
      segments.add(FlightSegment(
        day: result.departureDay,
        startHour: result.departureDateTime.hour,
        startMinute: result.departureDateTime.minute,
        endHour: result.arrivalInOrganizerTimezone.hour,
        endMinute: result.arrivalInOrganizerTimezone.minute,
        isDeparture: true,
        isArrival: true,
        timezone: result.departureTimezone,
        cityName: _getCityName(result.departureTimezone),
      ));
    } else {
      // Vuelo que cruza días
      
      // Segmento de salida (día de partida)
      segments.add(FlightSegment(
        day: result.departureDay,
        startHour: result.departureDateTime.hour,
        startMinute: result.departureDateTime.minute,
        endHour: 23,
        endMinute: 59,
        isDeparture: true,
        isArrival: false,
        timezone: result.departureTimezone,
        cityName: _getCityName(result.departureTimezone),
      ));
      
      // Segmentos intermedios (días completos de vuelo)
      final currentDay = result.departureDay.add(const Duration(days: 1));
      while (currentDay.isBefore(DateTime(
        result.arrivalDay.year,
        result.arrivalDay.month,
        result.arrivalDay.day,
      ))) {
        segments.add(FlightSegment(
          day: currentDay,
          startHour: 0,
          startMinute: 0,
          endHour: 23,
          endMinute: 59,
          isDeparture: false,
          isArrival: false,
          timezone: result.organizerTimezone,
          cityName: 'En vuelo',
        ));
        currentDay.add(const Duration(days: 1));
      }
      
      // Segmento de llegada (día de llegada)
      segments.add(FlightSegment(
        day: result.arrivalDay,
        startHour: 0,
        startMinute: 0,
        endHour: result.arrivalInOrganizerTimezone.hour,
        endMinute: result.arrivalInOrganizerTimezone.minute,
        isDeparture: false,
        isArrival: true,
        timezone: result.arrivalTimezone,
        cityName: _getCityName(result.arrivalTimezone),
      ));
    }
    
    return segments;
  }
  
  /// Obtiene el nombre de la ciudad de una timezone
  static String _getCityName(String timezone) {
    switch (timezone) {
      case 'Europe/Madrid':
        return 'Madrid';
      case 'Australia/Sydney':
        return 'Sídney';
      case 'America/New_York':
        return 'Nueva York';
      case 'America/Los_Angeles':
        return 'Los Ángeles';
      case 'Europe/London':
        return 'Londres';
      case 'Europe/Paris':
        return 'París';
      case 'Asia/Tokyo':
        return 'Tokio';
      case 'America/Argentina/Buenos_Aires':
        return 'Buenos Aires';
      default:
        return timezone.split('/').last;
    }
  }
}

/// Resultado del cálculo de un vuelo
class FlightCalculationResult {
  final DateTime departureDateTime;
  final DateTime departureUtc;
  final DateTime arrivalUtc;
  final DateTime arrivalInDestinationTimezone;
  final DateTime arrivalInOrganizerTimezone;
  final DateTime departureDay;
  final DateTime arrivalDay;
  final bool crossesDays;
  final int flightDurationMinutes;
  final String departureTimezone;
  final String arrivalTimezone;
  final String organizerTimezone;
  
  const FlightCalculationResult({
    required this.departureDateTime,
    required this.departureUtc,
    required this.arrivalUtc,
    required this.arrivalInDestinationTimezone,
    required this.arrivalInOrganizerTimezone,
    required this.departureDay,
    required this.arrivalDay,
    required this.crossesDays,
    required this.flightDurationMinutes,
    required this.departureTimezone,
    required this.arrivalTimezone,
    required this.organizerTimezone,
  });
  
  /// Obtiene la duración total del vuelo en formato legible
  String get flightDurationFormatted {
    final hours = flightDurationMinutes ~/ 60;
    final minutes = flightDurationMinutes % 60;
    return '${hours}h ${minutes}m';
  }
  
  /// Obtiene el rango de tiempo formateado para mostrar
  String get timeRangeFormatted {
    final departureTime = '${departureDateTime.hour.toString().padLeft(2, '0')}:${departureDateTime.minute.toString().padLeft(2, '0')}';
    final arrivalTime = '${arrivalInOrganizerTimezone.hour.toString().padLeft(2, '0')}:${arrivalInOrganizerTimezone.minute.toString().padLeft(2, '0')}';
    
    final departureCity = FlightCalculationService._getCityName(departureTimezone);
    final arrivalCity = FlightCalculationService._getCityName(arrivalTimezone);
    
    if (crossesDays) {
      return '$departureCity $departureTime - $arrivalCity $arrivalTime+${arrivalDay.difference(departureDay).inDays}';
    } else {
      return '$departureCity $departureTime - $arrivalCity $arrivalTime';
    }
  }
}

/// Segmento de un vuelo para mostrar en el calendario
class FlightSegment {
  final DateTime day;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool isDeparture;
  final bool isArrival;
  final String timezone;
  final String cityName;
  
  const FlightSegment({
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.isDeparture,
    required this.isArrival,
    required this.timezone,
    required this.cityName,
  });
  
  /// Obtiene la duración del segmento en minutos
  int get durationMinutes {
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    return endMinutes - startMinutes;
  }
  
  /// Obtiene el rango de tiempo del segmento
  String get timeRange {
    final startTime = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
    final endTime = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }
  
  /// Obtiene la descripción del segmento
  String get description {
    if (isDeparture && isArrival) {
      return 'Vuelo completo ($cityName)';
    } else if (isDeparture) {
      return 'Salida ($cityName)';
    } else if (isArrival) {
      return 'Llegada ($cityName)';
    } else {
      return 'En vuelo';
    }
  }
}
