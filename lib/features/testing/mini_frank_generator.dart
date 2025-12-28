import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/flight_calculation_service.dart';

class MiniFrankGenerator {
  static final PlanService _planService = PlanService();
  static final EventService _eventService = EventService();

  /// Genera el Plan Mini-Frank para pruebas paso a paso
  static Future<Plan> generateMiniFrankPlan(String userId) async {
    
    // Inicializar TimezoneService
    TimezoneService.initialize();
    
    // 1. Verificar si ya existe y eliminarlo
    await _deleteMiniFrankPlan();
    
    // Crear plan con fechas específicas: 22/10 al 24/10
    final baseDate = DateTime(2024, 10, 22); // 22 de octubre de 2024
    final plan = Plan(
      name: 'Mini Frank',
      description: 'Plan de prueba para verificar funcionalidades de timezones paso a paso',
      unpId: 'mini-frank-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      baseDate: baseDate,
      startDate: baseDate,
      endDate: baseDate.add(const Duration(days: 3)), // 25 de octubre
      columnCount: 4,
      state: 'planificando', // Para testing
      visibility: 'private',
      timezone: 'Europe/Madrid',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      savedAt: DateTime.now(),
    );
    
    final planId = await _planService.createPlan(plan);
    if (planId == null) {
      throw Exception('Error al crear el plan');
    }
    
    
    // Crear participantes
    await _createParticipants(planId, userId);
    
    // Solo el evento del vuelo a Sídney (se crea en _createDay1Events)
    

    
    // Invalidar providers para forzar actualización del calendario

    await Future.delayed(const Duration(milliseconds: 500));
    
    // Retornar el plan con el ID asignado
    return plan.copyWith(id: planId);
  }

  /// Elimina el plan Mini Frank existente si existe
  static Future<void> _deleteMiniFrankPlan() async {
    try {
      // Buscar planes con nombre Mini Frank
      final allPlans = await _planService.getPlans().first;
      final miniFrankPlans = allPlans.where((p) => p.name.contains('Mini Frank')).toList();

      for (final plan in miniFrankPlans) {
        if (plan.id != null) {

          
          // Eliminar eventos
          await _eventService.deleteEventsByPlanId(plan.id!);
          
          // Eliminar participaciones
          final participationService = PlanParticipationService();
          await participationService.removeAllPlanParticipations(plan.id!);
          
          // Eliminar plan
          await _planService.deletePlan(plan.id!);
          

        }
      }
    } catch (e) {

    }
  }

  /// Crea participantes para el plan (simplificado)
  static Future<List<String>> _createParticipants(String planId, String userId) async {
    // Crear solo 3 participantes para pruebas
    final participants = [
      userId, // Organizador original
      'mini_frank_participant', // Participante
      'mini_frank_observer', // Observador
    ];
    
    // Crear participaciones en el plan para cada usuario
    final participationService = PlanParticipationService();
    
    // Organizador (autoAccept: true en tests)
    await participationService.createParticipation(
      planId: planId, 
      userId: userId, 
      role: 'organizer',
      autoAccept: true,
    );
    
    // Participante
    await participationService.createParticipation(
      planId: planId, 
      userId: 'mini_frank_participant', 
      role: 'participant',
      autoAccept: true,
    );
    
    // Observador
    await participationService.createParticipation(
      planId: planId, 
      userId: 'mini_frank_observer', 
      role: 'observer',
      autoAccept: true,
    );
    
    // Actualizar con timezones personales usando el método correcto
    await participationService.updateUserTimezone(userId, 'Europe/Madrid'); // Organizador en Madrid
    await participationService.updateUserTimezone('mini_frank_participant', 'America/New_York'); // Participante en Nueva York
    await participationService.updateUserTimezone('mini_frank_observer', 'Europe/Paris'); // Observador en París
    




    
    return participants;
  }

  /// DÍA 1: Eventos básicos (sin timezones) - 22/10
  static Future<void> _createDay1Events(String planId, String userId, List<String> participants) async {
    final day1 = DateTime(2024, 10, 22); // 22 de octubre
    

    
    // Evento 1: Desayuno (sin timezone)
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day1,
      hour: 8,
      startMinute: 0,
      durationMinutes: 60,
      description: 'Desayuno (sin timezone)',
      typeFamily: 'Restauración',
      typeSubtype: 'Desayuno',
      color: 'orange',
      participantTrackIds: participants,
    );
    
    // Evento 2: Reunión (sin timezone)
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day1,
      hour: 14,
      startMinute: 0,
      durationMinutes: 120,
      description: 'Reunión (sin timezone)',
      typeFamily: 'Reunión',
      typeSubtype: 'Presencial',
      color: 'purple',
      participantTrackIds: participants,
    );
    
    // Evento 3: Vuelo Madrid → Sídney (para todos los participantes)



    
    // Calcular información del vuelo usando el servicio dedicado
    FlightCalculationService.calculateFlightTimes(
      departureDate: day1,
      departureHour: 20,
      departureMinute: 0,
      flightDurationMinutes: 1380, // 23 horas
      departureTimezone: 'Europe/Madrid',
      arrivalTimezone: 'Australia/Sydney',
      organizerTimezone: 'Europe/Madrid', // El organizador está en Madrid
    );
    







    
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day1,
      hour: 20,
      startMinute: 0,
      durationMinutes: 1380, // 23 horas (vuelo Madrid-Sídney con escalas)
      description: 'Vuelo Madrid → Sídney (TODOS)',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Avión',
      color: 'blue',
      participantTrackIds: participants, // Todos los participantes
      timezone: 'Europe/Madrid', // Timezone de salida
      arrivalTimezone: 'Australia/Sydney', // Timezone de llegada
    );

    

  }

  /// DÍA 2: Eventos con timezones (mismo día) - 23/10
  static Future<void> _createDay2Events(String planId, String userId, List<String> participants) async {
    final day2 = DateTime(2024, 10, 23); // 23 de octubre
    

    
    // Evento 1: Evento en Madrid
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day2,
      hour: 10,
      startMinute: 0,
      durationMinutes: 120,
      description: 'Evento Madrid (timezone)',
      typeFamily: 'Actividad',
      typeSubtype: 'Visita',
      color: 'green',
      participantTrackIds: participants,
      timezone: 'Europe/Madrid',
    );
    
    // Evento 2: Evento en Sídney (mismo día, diferente timezone)
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day2,
      hour: 19,
      startMinute: 0,
      durationMinutes: 90,
      description: 'Evento Sídney (timezone)',
      typeFamily: 'Actividad',
      typeSubtype: 'Visita',
      color: 'blue',
      participantTrackIds: participants,
      timezone: 'Australia/Sydney',
    );
    

  }

  /// DÍA 3: Eventos con timezones diferentes (cruza días) - 24/10
  static Future<void> _createDay3Events(String planId, String userId, List<String> participants) async {
    final day3 = DateTime(2024, 10, 24); // 24 de octubre
    

    
    // Evento 1: Evento normal en DÍA 3 (sin timezone)
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day3,
      hour: 10,
      startMinute: 0,
      durationMinutes: 120, // 2 horas
      description: 'Evento normal DÍA 3',
      typeFamily: 'Actividad',
      typeSubtype: 'General',
      color: 'green',
      participantTrackIds: participants,
    );
    

  }

  /// DÍA 4: Eventos adicionales - 25/10
  static Future<void> _createDay4Events(String planId, String userId, List<String> participants) async {
    final day4 = DateTime(2024, 10, 25); // 25 de octubre
    

    
    // Evento 1: Evento normal (sin timezone)
    await _createEvent(
      planId: planId,
      userId: userId,
      date: day4,
      hour: 9,
      startMinute: 0,
      durationMinutes: 60,
      description: 'Evento normal (25/10)',
      typeFamily: 'Actividad',
      typeSubtype: 'General',
      color: 'green',
      participantTrackIds: participants,
    );
    

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









    
    // Construir EventCommonPart (igual que Frankenstein)
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

    // Construir EventPersonalPart para cada participante (igual que Frankenstein)
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
      id: null, // Se generará automáticamente
      planId: planId,
      userId: userId,
      date: date,
      hour: hour,
      duration: (durationMinutes / 60).ceil(), // Campo requerido (igual que Frankenstein)
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
    
    // Crear evento usando EventService (igual que Frankenstein)

    try {
      await _eventService.createEvent(event);









      
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {

    }
  }
}
