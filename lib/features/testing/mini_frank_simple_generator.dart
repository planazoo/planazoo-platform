import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/accommodation_service.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';

/// Generador para el plan Mini Frank Londres
/// 4 días en Londres (3-6 nov 2025) con 3 usuarios y eventos de transporte
class MiniFrankSimpleGenerator {
  static final _planService = PlanService();
  static final _eventService = EventService();
  static final _planParticipationService = PlanParticipationService();
  static final _accommodationService = AccommodationService();

  /// Genera el plan Mini Frank Londres
  static Future<Plan> generateMiniFrankPlan(String userId) async {
    
    // Eliminar plan existente si existe
    await _deleteMiniFrankPlan();
    
    // Crear plan con fechas específicas: 3-6 noviembre 2025
    final baseDate = DateTime(2025, 11, 3); // 3 de noviembre de 2025
    final plan = Plan(
      name: 'Mini Frank Londres',
      description: 'Plan de prueba para Londres: 4 días con vuelos y taxi',
      startDate: baseDate,
      endDate: baseDate.add(const Duration(days: 3)), // 6 de noviembre
      baseDate: baseDate,
      userId: userId,
      unpId: 'mini-frank-london-${DateTime.now().millisecondsSinceEpoch}',
      participants: 3,
      columnCount: 4,
      state: 'planificando', // Para testing
      visibility: 'private',
      timezone: 'Europe/London', // Londres
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      savedAt: DateTime.now(),
    );

    final planId = await _planService.createPlan(plan);
    if (planId == null) {
      throw Exception('Error al crear el plan');
    }
    
    // Crear participantes (3 usuarios)
    final participants = await _createParticipants(planId, userId);
    
    // Crear eventos del plan
    await _createLondonEvents(planId, userId, participants);
    
    return plan.copyWith(id: planId);
  }

  /// Elimina el plan Mini Frank existente si existe
  static Future<void> _deleteMiniFrankPlan() async {
    try {
      final allPlans = await _planService.getPlans().first;
      final miniFrankPlans = allPlans.where((p) => p.name.contains('Mini Frank')).toList();

      for (final plan in miniFrankPlans) {
        if (plan.id != null) {
          await _eventService.deleteEventsByPlanId(plan.id!);
          await _planParticipationService.removeAllPlanParticipations(plan.id!);
          await _planService.deletePlan(plan.id!);
        }
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Crea participantes para Londres
  static Future<List<String>> _createParticipants(String planId, String userId) async {
    final participants = [
      userId, // Organizador original
      'mini_frank_participant', // Participante
      'mini_frank_observer', // Observador
    ];
    
    // Crear participaciones (autoAccept: true en tests)
    await _planParticipationService.createParticipation(
      planId: planId, 
      userId: userId, 
      role: 'organizer',
      autoAccept: true,
    );
    
    await _planParticipationService.createParticipation(
      planId: planId, 
      userId: 'mini_frank_participant', 
      role: 'participant',
      autoAccept: true,
    );
    
    await _planParticipationService.createParticipation(
      planId: planId, 
      userId: 'mini_frank_observer', 
      role: 'observer',
      autoAccept: true,
    );
    
    // Actualizar con timezones personales
    final participations = await _planParticipationService.getPlanParticipations(planId).first;
    
    for (final participation in participations) {
      String? timezone;
      if (participation.userId == userId) {
        timezone = 'Europe/Madrid'; // Organizador en Barcelona (Madrid timezone)
      } else if (participation.userId == 'mini_frank_participant') {
        timezone = 'Europe/London'; // Participante en UK
      } else if (participation.userId == 'mini_frank_observer') {
        timezone = 'Europe/Madrid'; // Observador en Barcelona (Madrid timezone)
      }
      
      if (timezone != null) {
        final updatedParticipation = participation.copyWith(personalTimezone: timezone);
        await _planParticipationService.updateParticipation(updatedParticipation);
      }
    }
    
    return participants;
  }

  /// Crea todos los eventos del plan Londres
  static Future<void> _createLondonEvents(String planId, String userId, List<String> participants) async {
    final day1 = DateTime(2025, 11, 3); // 3 de noviembre
    final day2 = DateTime(2025, 11, 4); // 4 de noviembre
    final day3 = DateTime(2025, 11, 5); // 5 de noviembre
    
    // Evento 1: Vuelo Barcelona → Londres (Día 1, solo organizador)
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day1,
      hour: 21,
      startMinute: 0,
      durationMinutes: 180, // 3 horas
      description: 'Vuelo Barcelona → Londres',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Avión',
      color: 'blue',
      participantTrackIds: [userId], // Solo organizador
      timezone: 'Europe/Madrid', // Barcelona
      arrivalTimezone: 'Europe/London', // Londres
    );
    
    // Evento 2: Taxi aeropuerto → Hotel (Día 2, organizador + participante)
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day2,
      hour: 1,
      startMinute: 30,
      durationMinutes: 90, // 1.5 horas
      description: 'Taxi aeropuerto → Hotel London Regent',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Taxi',
      color: 'green',
      participantTrackIds: [userId, 'mini_frank_participant'], // Organizador + participante
      timezone: 'Europe/London', // UK timezone
    );
    
    // Evento 3: Alojamiento Hotel London Regent (Días 2-3)
    await _createAccommodation(
      planId: planId,
      checkInDate: day2,
      checkInHour: 3,
      checkInMinute: 0,
      checkOutDate: day3,
      checkOutHour: 12,
      checkOutMinute: 0,
      hotelName: 'Hotel London Regent',
      color: 'purple',
      participantTrackIds: [userId, 'mini_frank_participant'], // Organizador + participante
    );
    
    // Evento 4: Vuelo Londres → Barcelona (Día 3, solo organizador)
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day3,
      hour: 22,
      startMinute: 0,
      durationMinutes: 180, // 3 horas
      description: 'Vuelo Londres → Barcelona',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Avión',
      color: 'blue',
      participantTrackIds: [userId], // Solo organizador
      timezone: 'Europe/London', // Londres
      arrivalTimezone: 'Europe/Madrid', // Barcelona
    );
  }

  /// Crea un alojamiento usando el AccommodationService existente
  static Future<void> _createAccommodation({
    required String planId,
    required DateTime checkInDate,
    required int checkInHour,
    required int checkInMinute,
    required DateTime checkOutDate,
    required int checkOutHour,
    required int checkOutMinute,
    required String hotelName,
    required String color,
    required List<String> participantTrackIds,
  }) async {
    
    // Crear fechas de check-in y check-out
    final checkInDateTime = DateTime(checkInDate.year, checkInDate.month, checkInDate.day, checkInHour, checkInMinute);
    final checkOutDateTime = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day, checkOutHour, checkOutMinute);
    
    // Crear el alojamiento usando el modelo existente
    final accommodation = Accommodation(
      id: null, // Se generará automáticamente
      planId: planId,
      checkIn: checkInDateTime,
      checkOut: checkOutDateTime,
      hotelName: hotelName,
      description: 'Alojamiento en $hotelName',
      color: color,
      typeFamily: 'alojamiento',
      typeSubtype: 'hotel',
      participantTrackIds: participantTrackIds,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Crear alojamiento usando el servicio existente
    try {
      await _accommodationService.createAccommodation(accommodation);
    } catch (e) {
      // Error silencioso para no interrumpir la generación
    }
  }

  /// Crea un evento individual
  static Future<void> _createEvent({
    required String planId,
    required String userId,
    required DateTime date,
    required int hour,
    required int startMinute,
    required int durationMinutes,
    required String description,
    required String typeFamily,
    required String typeSubtype,
    required String color,
    required List<String> participantTrackIds,
    String? timezone,
    String? arrivalTimezone,
  }) async {
    
    // Construir EventCommonPart
    final commonPart = EventCommonPart(
      description: description,
      date: date,
      startHour: hour,
      startMinute: startMinute,
      durationMinutes: durationMinutes,
      customColor: color,
      family: typeFamily,
      subtype: typeSubtype,
      isDraft: false,
      participantIds: participantTrackIds,
    );

    // Construir EventPersonalPart para cada participante
    final Map<String, EventPersonalPart> personalParts = {};
    for (final participantId in participantTrackIds) {
      personalParts[participantId] = EventPersonalPart(
        participantId: participantId,
        fields: {
          'asiento': null,
          'menu': null,
          'preferencias': null,
          'numeroReserva': null,
          'gate': null,
          'tarjetaObtenida': false,
          'notasPersonales': null,
        },
      );
    }

    final event = Event(
      id: null,
      planId: planId,
      userId: userId,
      date: date,
      hour: hour,
      duration: (durationMinutes / 60).ceil(), // Campo requerido
      startMinute: startMinute,
      durationMinutes: durationMinutes,
      description: description,
      typeFamily: typeFamily,
      typeSubtype: typeSubtype,
      color: color,
      participantTrackIds: participantTrackIds,
      timezone: timezone,
      arrivalTimezone: arrivalTimezone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      commonPart: commonPart,
      personalParts: personalParts,
    );

    // Crear evento
    try {
      await _eventService.createEvent(event);
    } catch (e) {
      // Error silencioso para no interrumpir la generación
    }
  }
}