import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

/// Representa un "segmento" de un evento para un día específico.
/// 
/// Cuando un evento cruza medianoche (ej: 22:00 día 1 hasta 06:00 día 2),
/// se divide en múltiples segmentos:
/// - Segmento día 1: 22:00-23:59 (isFirst: true, isLast: false)
/// - Segmento día 2: 00:00-06:00 (isFirst: false, isLast: true)
/// 
/// Inspirado en Google Calendar: cada segmento se renderiza y participa
/// en la detección de solapamientos de forma independiente, pero todos
/// apuntan al mismo Event original.
class EventSegment {
  /// Evento original del que proviene este segmento
  final Event originalEvent;
  
  /// Fecha del día que representa este segmento
  final DateTime segmentDate;
  
  /// Minuto de inicio en ESTE día específico (0-1439)
  final int startMinute;
  
  /// Minuto de fin en ESTE día específico (0-1440)
  /// Nota: puede ser 1440 (medianoche del día siguiente)
  final int endMinute;
  
  /// ¿Es este el primer segmento del evento?
  final bool isFirst;
  
  /// ¿Es este el último segmento del evento?
  final bool isLast;

  const EventSegment({
    required this.originalEvent,
    required this.segmentDate,
    required this.startMinute,
    required this.endMinute,
    required this.isFirst,
    required this.isLast,
  });

  /// ID único del segmento (combina ID del evento + fecha del segmento)
  String get id => '${originalEvent.id}_segment_${segmentDate.toIso8601String().split('T')[0]}';

  /// Duración del segmento en minutos
  int get durationMinutes => endMinute - startMinute;

  /// Hora de inicio (0-23)
  int get hour => startMinute ~/ 60;

  /// Minutos de inicio (0-59)
  int get minute => startMinute % 60;

  /// Hora de fin (0-24)
  int get endHour => endMinute ~/ 60;

  /// Minutos de fin (0-59)
  int get endMinute_ => endMinute % 60;

  /// Propiedades delegadas al evento original
  String? get eventId => originalEvent.id;
  String get description => originalEvent.description;
  String? get typeFamily => originalEvent.typeFamily;
  String? get color => originalEvent.color;
  bool get isDraft => originalEvent.isDraft;

  /// Crea segmentos de un evento para un rango de fechas
  /// 
  /// Si el evento solo ocupa 1 día, devuelve 1 segmento.
  /// Si cruza medianoche, devuelve múltiples segmentos (uno por día).
  /// 
  /// NUEVO: Aplica lógica de timezones antes de crear segmentos para eventos
  /// con timezones diferentes (ej: vuelos Madrid-Sídney).
  static List<EventSegment> createSegmentsForEvent(Event event, {DateTime? startDate, DateTime? endDate}) {
    final segments = <EventSegment>[];
    
    // PASO 1: Aplicar lógica de timezones si el evento tiene timezones diferentes
    if (_hasDifferentTimezones(event)) {
      return _createSegmentsForTimezoneEvent(event, startDate: startDate, endDate: endDate);
    }
    
    // PASO 2: Lógica original para eventos sin timezones diferentes
    final eventStartMinutes = event.hour * 60 + event.startMinute;
    
    // FALLBACK: Si durationMinutes es 0 o muy pequeño, usar duration (en horas) como backup
    final actualDurationMinutes = (event.durationMinutes > 0) 
        ? event.durationMinutes 
        : event.duration * 60;
    
    final eventEndMinutes = eventStartMinutes + actualDurationMinutes;
    
    // ¿El evento cruza medianoche?
    if (eventEndMinutes <= 1440) {
      // NO cruza medianoche - un solo segmento
      segments.add(EventSegment(
        originalEvent: event,
        segmentDate: event.date,
        startMinute: eventStartMinutes,
        endMinute: eventEndMinutes,
        isFirst: true,
        isLast: true,
      ));
    } else {
      // SÍ cruza medianoche - múltiples segmentos
      
      // Primer segmento (día inicial)
      segments.add(EventSegment(
        originalEvent: event,
        segmentDate: event.date,
        startMinute: eventStartMinutes,
        endMinute: 1440, // Hasta medianoche
        isFirst: true,
        isLast: false,
      ));
      
      // Segmentos intermedios y final
      int remainingMinutes = eventEndMinutes - 1440;
      int dayOffset = 1;
      
      while (remainingMinutes > 0) {
        final segmentDate = event.date.add(Duration(days: dayOffset));
        final segmentEnd = remainingMinutes > 1440 ? 1440 : remainingMinutes;
        final isLast = remainingMinutes <= 1440;
        
        segments.add(EventSegment(
          originalEvent: event,
          segmentDate: segmentDate,
          startMinute: 0, // Empieza a las 00:00
          endMinute: segmentEnd,
          isFirst: false,
          isLast: isLast,
        ));
        
        remainingMinutes -= 1440;
        dayOffset++;
      }
    }
    
    // Filtrar por rango de fechas si se especifica
    if (startDate != null || endDate != null) {
      return segments.where((segment) {
        final date = segment.segmentDate;
        final afterStart = startDate == null || date.isAfter(startDate.subtract(const Duration(days: 1)));
        final beforeEnd = endDate == null || date.isBefore(endDate.add(const Duration(days: 1)));
        return afterStart && beforeEnd;
      }).toList();
    }
    
    return segments;
  }

  /// Crea un segmento para un día específico (si el evento lo ocupa)
  /// Devuelve null si el evento no está activo en ese día
  static EventSegment? createSegmentForDate(Event event, DateTime date) {
    final segments = createSegmentsForEvent(event);
    
    try {
      return segments.firstWhere((segment) {
        return segment.segmentDate.year == date.year &&
               segment.segmentDate.month == date.month &&
               segment.segmentDate.day == date.day;
      });
    } catch (e) {
      return null; // El evento no está activo en este día
    }
  }

  @override
  String toString() {
    return 'EventSegment(${originalEvent.description}, ${segmentDate.toIso8601String().split('T')[0]}, $startMinute-$endMinute, first:$isFirst, last:$isLast)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventSegment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ========== MÉTODOS HELPER PARA TIMEZONES ==========

  /// Verifica si un evento tiene timezones diferentes
  static bool _hasDifferentTimezones(Event event) {
    return event.timezone != null && 
           event.timezone!.isNotEmpty && 
           event.arrivalTimezone != null && 
           event.arrivalTimezone!.isNotEmpty &&
           event.timezone != event.arrivalTimezone;
  }

  /// Crea segmentos para eventos con timezones diferentes
  /// 
  /// Para eventos como vuelos Madrid-Sídney, calcula las fechas reales
  /// de salida y llegada antes de crear los segmentos.
  static List<EventSegment> _createSegmentsForTimezoneEvent(Event event, {DateTime? startDate, DateTime? endDate}) {
    final segments = <EventSegment>[];
    
    // 1. Calcular fechas reales usando timezones
    final departureDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );
    
    // 2. Convertir salida a UTC
    final departureUtc = TimezoneService.localToUtc(departureDateTime, event.timezone!);
    
    // 3. Calcular llegada en UTC (añadir duración)
    final arrivalUtc = departureUtc.add(Duration(minutes: event.durationMinutes));
    
    // 4. Convertir llegada a timezone de destino
    final arrivalInDestinationTimezone = TimezoneService.utcToLocal(arrivalUtc, event.arrivalTimezone!);
    
    // 5. Crear segmentos basados en las fechas reales
    final departureDate = DateTime(departureDateTime.year, departureDateTime.month, departureDateTime.day);
    final arrivalDate = DateTime(arrivalInDestinationTimezone.year, arrivalInDestinationTimezone.month, arrivalInDestinationTimezone.day);
    
    // 6. Calcular días de diferencia
    final daysDifference = arrivalDate.difference(departureDate).inDays;
    
    if (daysDifference == 0) {
      // Mismo día - un solo segmento
      final startMinutes = event.hour * 60 + event.startMinute;
      final endMinutes = arrivalInDestinationTimezone.hour * 60 + arrivalInDestinationTimezone.minute;
      
      segments.add(EventSegment(
        originalEvent: event,
        segmentDate: departureDate,
        startMinute: startMinutes,
        endMinute: endMinutes,
        isFirst: true,
        isLast: true,
      ));
    } else {
      // Múltiples días - crear segmentos
      
      // Segmento 1: Día de salida
      final startMinutes = event.hour * 60 + event.startMinute;
      segments.add(EventSegment(
        originalEvent: event,
        segmentDate: departureDate,
        startMinute: startMinutes,
        endMinute: 1440, // Hasta medianoche
        isFirst: true,
        isLast: false,
      ));
      
      // Segmentos intermedios (si los hay)
      for (int dayOffset = 1; dayOffset < daysDifference; dayOffset++) {
        final intermediateDate = departureDate.add(Duration(days: dayOffset));
        segments.add(EventSegment(
          originalEvent: event,
          segmentDate: intermediateDate,
          startMinute: 0, // Empieza a las 00:00
          endMinute: 1440, // Hasta medianoche
          isFirst: false,
          isLast: false,
        ));
      }
      
      // Segmento final: Día de llegada
      final arrivalMinutes = arrivalInDestinationTimezone.hour * 60 + arrivalInDestinationTimezone.minute;
      segments.add(EventSegment(
        originalEvent: event,
        segmentDate: arrivalDate,
        startMinute: 0, // Empieza a las 00:00
        endMinute: arrivalMinutes,
        isFirst: false,
        isLast: true,
      ));
    }
    
    // Filtrar por rango de fechas si se especifica
    if (startDate != null || endDate != null) {
      return segments.where((segment) {
        final date = segment.segmentDate;
        final afterStart = startDate == null || date.isAfter(startDate.subtract(const Duration(days: 1)));
        final beforeEnd = endDate == null || date.isBefore(endDate.add(const Duration(days: 1)));
        return afterStart && beforeEnd;
      }).toList();
    }
    
    return segments;
  }
}

