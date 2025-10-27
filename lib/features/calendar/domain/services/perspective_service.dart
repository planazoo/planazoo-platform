import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

/// Servicio para manejar la perspectiva de visualización de eventos
/// según el rol y timezone del usuario
class PerspectiveService {
  /// Determina la perspectiva de un evento para un usuario específico
  static EventPerspective getEventPerspective({
    required Event event,
    required PlanParticipation userParticipation,
    required String? userCurrentTimezone,
  }) {
    // Determinar timezone del usuario
    final userTimezone = userCurrentTimezone ?? 
                        userParticipation.personalTimezone ?? 
                        'Europe/Madrid'; // Fallback

    // Determinar si es un evento de desplazamiento
    final isDisplacement = event.typeFamily == 'Desplazamiento' || 
                          event.typeFamily == 'Transporte';

    // Determinar si el usuario es participante o observador
    final isParticipant = userParticipation.isParticipant || userParticipation.isOrganizer;
    final isObserver = userParticipation.isObserver;

    if (isDisplacement) {
      return _getDisplacementPerspective(
        event: event,
        userParticipation: userParticipation,
        userTimezone: userTimezone,
        isParticipant: isParticipant,
        isObserver: isObserver,
      );
    } else {
      return _getRegularEventPerspective(
        event: event,
        userParticipation: userParticipation,
        userTimezone: userTimezone,
      );
    }
  }

  /// Obtiene la perspectiva para eventos de desplazamiento
  static EventPerspective _getDisplacementPerspective({
    required Event event,
    required PlanParticipation userParticipation,
    required String userTimezone,
    required bool isParticipant,
    required bool isObserver,
  }) {
    if (isParticipant) {
      // Participante: ve desde su timezone personal
      final participantTimezone = userParticipation.personalTimezone ?? userTimezone;
      
      // Calcular salida en timezone del participante
      final departureTime = _getLocalTime(event, event.timezone ?? participantTimezone);
      
      // Calcular llegada en timezone del participante
      final arrivalTime = _calculateArrivalTime(event, participantTimezone);
      
      return EventPerspective(
        displayStartTime: departureTime,
        displayEndTime: arrivalTime,
        displayTimezone: participantTimezone,
        isCrossDay: _isCrossDay(event, participantTimezone),
        perspectiveType: EventPerspectiveType.participant,
        description: _getParticipantDescription(event),
      );
    } else if (isObserver) {
      // Observador: ve desde su timezone (hora de llegada en su timezone)
      return EventPerspective(
        displayStartTime: _getLocalTime(event, event.timezone ?? userTimezone),
        displayEndTime: _getObserverArrivalTime(event, userTimezone),
        displayTimezone: userTimezone,
        isCrossDay: _isCrossDay(event, userTimezone),
        perspectiveType: EventPerspectiveType.observer,
        description: _getObserverDescription(event, userTimezone),
      );
    } else {
      // Fallback: perspectiva regular
      return _getRegularEventPerspective(
        event: event,
        userParticipation: userParticipation,
        userTimezone: userTimezone,
      );
    }
  }

  /// Obtiene la perspectiva para eventos regulares
  static EventPerspective _getRegularEventPerspective({
    required Event event,
    required PlanParticipation userParticipation,
    required String userTimezone,
  }) {
    return EventPerspective(
      displayStartTime: _getLocalTime(event, userTimezone),
      displayEndTime: _getLocalTime(event, userTimezone).add(Duration(minutes: event.durationMinutes)),
      displayTimezone: userTimezone,
      isCrossDay: false,
      perspectiveType: EventPerspectiveType.regular,
      description: event.description,
    );
  }

  /// Convierte la hora del evento a la timezone especificada
  static DateTime _getLocalTime(Event event, String timezone) {
    final eventDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );

    // Si el evento tiene timezone, convertir desde esa timezone
    if (event.timezone != null && event.timezone!.isNotEmpty) {
      final utcTime = TimezoneService.localToUtc(eventDateTime, event.timezone!);
      return TimezoneService.utcToLocal(utcTime, timezone);
    } else {
      // Si no tiene timezone, asumir que está en la timezone del usuario
      return eventDateTime;
    }
  }

  /// Calcula la hora de llegada en la timezone especificada
  static DateTime _calculateArrivalTime(Event event, String arrivalTimezone) {
    final departureDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );

    // Convertir salida a UTC (verificar que timezone no sea null)
    if (event.timezone != null && event.timezone!.isNotEmpty) {
      final departureUtc = TimezoneService.localToUtc(departureDateTime, event.timezone!);
    
    // Calcular llegada en UTC (añadir duración)
    final arrivalUtc = departureUtc.add(Duration(minutes: event.durationMinutes));
    
    // Convertir llegada a timezone de destino
      final arrivalInDestinationTimezone = TimezoneService.utcToLocal(arrivalUtc, arrivalTimezone);
      
      return arrivalInDestinationTimezone;
    } else {
      // Si no tiene timezone, asumir que llega en la misma fecha/hora (sin conversión)
      return departureDateTime.add(Duration(minutes: event.durationMinutes));
    }
  }

  /// Calcula la hora de llegada desde la perspectiva del observador
  static DateTime _getObserverArrivalTime(Event event, String userTimezone) {
    if (event.arrivalTimezone == null || event.arrivalTimezone!.isEmpty) {
      return _getLocalTime(event, userTimezone).add(Duration(minutes: event.durationMinutes));
    }

    // Calcular llegada en timezone de destino
    final departureTime = _getLocalTime(event, event.timezone ?? userTimezone);
    final departureUtc = TimezoneService.localToUtc(departureTime, event.timezone ?? userTimezone);
    final arrivalUtc = departureUtc.add(Duration(minutes: event.durationMinutes));
    final arrivalInDestination = TimezoneService.utcToLocal(arrivalUtc, event.arrivalTimezone!);

    // Convertir a timezone del observador
    final arrivalUtcForObserver = TimezoneService.localToUtc(arrivalInDestination, event.arrivalTimezone!);
    return TimezoneService.utcToLocal(arrivalUtcForObserver, userTimezone);
  }

  /// Determina si el evento cruza días
  static bool _isCrossDay(Event event, String timezone) {
    final startTime = _getLocalTime(event, timezone);
    final endTime = startTime.add(Duration(minutes: event.durationMinutes));
    return endTime.day != startTime.day;
  }

  /// Genera descripción para participante
  static String _getParticipantDescription(Event event) {
    if (event.arrivalTimezone != null && event.arrivalTimezone != event.timezone) {
      final departureCity = _getCityName(event.timezone ?? 'Europe/Madrid');
      final arrivalCity = _getCityName(event.arrivalTimezone!);
      return '${event.description} ($departureCity → $arrivalCity)';
    }
    return event.description;
  }

  /// Genera descripción para observador
  static String _getObserverDescription(Event event, String userTimezone) {
    if (event.arrivalTimezone != null && event.arrivalTimezone != event.timezone) {
      final departureCity = _getCityName(event.timezone ?? 'Europe/Madrid');
      final arrivalCity = _getCityName(event.arrivalTimezone!);
      final userCity = _getCityName(userTimezone);
      return '${event.description} ($departureCity → $arrivalCity) - Vista desde $userCity';
    }
    return event.description;
  }

  /// Obtiene el nombre de la ciudad de una timezone
  static String _getCityName(String timezone) {
    final displayNames = {
      'Europe/Madrid': 'Madrid',
      'Europe/London': 'Londres',
      'America/Argentina/Buenos_Aires': 'Buenos Aires',
      'Australia/Sydney': 'Sídney',
      'Asia/Tokyo': 'Tokio',
      'America/New_York': 'Nueva York',
    };
    return displayNames[timezone] ?? timezone.split('/').last;
  }
}

/// Clase que representa la perspectiva de un evento
class EventPerspective {
  final DateTime displayStartTime;
  final DateTime displayEndTime;
  final String displayTimezone;
  final bool isCrossDay;
  final EventPerspectiveType perspectiveType;
  final String description;

  const EventPerspective({
    required this.displayStartTime,
    required this.displayEndTime,
    required this.displayTimezone,
    required this.isCrossDay,
    required this.perspectiveType,
    required this.description,
  });
}

/// Tipos de perspectiva de evento
enum EventPerspectiveType {
  participant, // Participante del evento
  observer,    // Observador del evento
  regular,     // Evento regular (no desplazamiento)
}
