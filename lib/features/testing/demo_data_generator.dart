// ignore_for_file: empty_catches, unused_element

import 'package:flutter/foundation.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/accommodation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/testing/family_users_generator.dart';
import 'package:unp_calendario/shared/models/user_role.dart';
import 'package:unp_calendario/shared/services/permission_service.dart';

/// Generador de datos de prueba para el plan "Frankenstein"
/// 
/// Este plan contiene todos los tipos de eventos, casos edge y
/// complejidades implementadas para testing completo.
class DemoDataGenerator {
  static const String demoPlanName = '🧟 Frankenstein';
  static const String demoPlanId = 'FRANK001';
  
  static final PlanService _planService = PlanService();
  static final EventService _eventService = EventService();
  static final AccommodationService _accommodationService = AccommodationService();
  static final PlanParticipationService _participationService = PlanParticipationService();
  static final PermissionService _permissionService = PermissionService();

  /// Genera el plan completo "Frankenstein" con todos los datos de prueba
  static Future<String?> generateFrankensteinPlan(String userId) async {
    try {
      if (!kDebugMode) {
        return null;
      }

      // Limpiar lista de eventos para validación de conflictos
      _createdEvents.clear();

      // 1. Verificar si ya existe y eliminarlo
      await deleteFrankensteinPlan();

      // 2. Crear plan base
      final plan = await _createDemoPlan(userId);
      if (plan?.id == null) {
        return null;
      }
      
      final planNonNull = plan!;

      // 3. Crear usuarios de la familia (excluyendo cristian_claraso)
      final allFamilyUserIds = await FamilyUsersGenerator.generateFamilyUsers();
      // Filtrar para excluir cristian_claraso y tomar solo 4 usuarios
      final familyUserIds = allFamilyUserIds.where((id) => id != 'cristian_claraso').take(4).toList();
      
      // 4. Crear participación del creador como organizador (autoAccept: true porque es el creador)
      await _participationService.createParticipation(
        planId: planNonNull.id!,
        userId: userId,
        role: 'organizer',
        autoAccept: true,
      );
      
      // 5. Crear participaciones para los miembros de la familia (autoAccept: true en tests)
      for (final familyUserId in familyUserIds) {
        await _participationService.createParticipation(
          planId: planNonNull.id!,
          userId: familyUserId,
          role: 'participant',
          invitedBy: userId,
          autoAccept: true,
        );
      }

      // 6. Asignar roles de permisos granulares
      await _assignPermissionRoles(planNonNull.id!, userId, familyUserIds);

      // 7. Generar eventos por categoría
      await _generateBasicEvents(planNonNull, userId, familyUserIds);
      await _generateOverlappingEvents(planNonNull, userId, familyUserIds);
      await _generateMultiDayEvents(planNonNull, userId, familyUserIds);
      await _generateEventTypes(planNonNull, userId, familyUserIds);
      await _generateEdgeCases(planNonNull, userId, familyUserIds);
      await generateTimezoneEvents(planNonNull, userId, familyUserIds);

      // 8. Generar alojamientos
      await _generateAccommodations(planNonNull, userId, familyUserIds);

      return planNonNull.id;
    } catch (e) {
      return null;
    }
  }

  /// Elimina el plan Frankenstein existente si existe
  static Future<void> deleteFrankensteinPlan() async {
    try {
      // ⚠️ Usa getPlans() (deprecado) porque este generador de datos de prueba
      // necesita buscar planes por nombre en toda la base de datos, no por usuario.
      final allPlans = await _planService.getPlans().first; // Uso válido: generador de prueba
      final frankensteinPlans = allPlans.where((p) => p.name.contains('Frankenstein')).toList();

      for (final plan in frankensteinPlans) {
        if (plan.id != null) {
          
          // Eliminar eventos
          await _eventService.deleteEventsByPlanId(plan.id!);
          
          // Eliminar alojamientos (están en events con typeFamily='alojamiento')
          final accommodations = await _accommodationService.getAccommodations(plan.id!).first;
          for (final acc in accommodations) {
            if (acc.id != null) {
              await _accommodationService.deleteAccommodation(acc.id!);
            }
          }
          
          // Eliminar plan
          await _planService.deletePlan(plan.id!);
        }
      }
    } catch (e) {
    }
  }

  // ==================== CREACIÓN DE PLAN BASE ====================

  static Future<Plan?> _createDemoPlan(String userId) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day); // Hoy a las 00:00
    final endDate = startDate.add(const Duration(days: 6)); // 7 días en total

    final plan = Plan(
      name: demoPlanName,
      unpId: demoPlanId,
      userId: userId,
      baseDate: startDate,
      startDate: startDate,
      endDate: endDate,
      columnCount: 7,
      participants: 5, // 1 organizador + 4 miembros de la familia
      description: 'Plan de testing completo con todos los tipos de eventos, '
          'solapamientos, casos edge y complejidades implementadas. '
          '¡Un verdadero monstruo de Frankenstein! 🧟',
      state: 'planificando', // Para testing, directamente en planificando
      visibility: 'private',
      timezone: 'Europe/Madrid',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      savedAt: DateTime.now(),
    );

    final success = await _planService.savePlanByUnpId(plan);
    if (!success) return null;

    // ⚠️ Usa getPlans() (deprecado) porque este generador de datos de prueba
    // necesita buscar planes por unpId en toda la base de datos, no por usuario.
    final allPlans = await _planService.getPlans().first; // Uso válido: generador de prueba
    return allPlans.firstWhere((p) => p.unpId == demoPlanId);
  }

  // ==================== DÍA 1: EVENTOS CON DIFERENTES PARTICIPANTES ====================

  static Future<void> _generateBasicEvents(Plan plan, String userId, List<String> familyUserIds) async {
    final day1 = plan.startDate;

    // Evento solo del organizador (30 min)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day1,
      hour: 8,
      startMinute: 0,
      durationMinutes: 30, // 08:00 - 08:30
      description: 'Reunión matutina (solo organizador)',
      typeFamily: 'Otro',
      color: 'indigo',
      participantTrackIds: [userId], // Solo el organizador
    );

    // Evento de 1 participante de la familia (30 min)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day1,
      hour: 9,
      startMinute: 0,
      durationMinutes: 30, // 09:00 - 09:30
      description: 'Café rápido (solo Cristian)',
      typeFamily: 'Restauración',
      typeSubtype: 'Bebida',
      color: 'brown',
      participantTrackIds: [familyUserIds[0]], // Solo Cristian
    );

    // Evento de 2 participantes (2h) - organizador + 1 familia
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day1,
      hour: 10,
      startMinute: 0,
      durationMinutes: 120, // 10:00 - 12:00
      description: 'Visita museo (organizador + Cristian)',
      typeFamily: 'Actividad',
      typeSubtype: 'Museo',
      color: 'purple',
      participantTrackIds: [userId, familyUserIds[0]], // Organizador + Cristian
    );

    // Evento de 3 participantes (1.5h) - organizador + 2 familia
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day1,
      hour: 12,
      startMinute: 30,
      durationMinutes: 90, // 12:30 - 14:00
      description: 'Almuerzo familiar (organizador + 2 familia)',
      typeFamily: 'Restauración',
      typeSubtype: 'Comida',
      color: 'green',
      participantTrackIds: [userId, familyUserIds[0], familyUserIds[1]], // Organizador + 2 familia
    );

    // Evento de TODOS los participantes (4h) - organizador + todos los familia
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day1,
      hour: 14,
      startMinute: 0,
      durationMinutes: 240, // 14:00 - 18:00
      description: 'Tarde en la playa (TODOS)',
      typeFamily: 'Actividad',
      typeSubtype: 'Parque',
      color: 'teal',
      participantTrackIds: [userId, ...familyUserIds], // Organizador + todos los familia
    );

    // Evento solo del organizador (2h) - borrador
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day1,
      hour: 20,
      startMinute: 0,
      durationMinutes: 120, // 20:00 - 22:00
      description: 'Cena (por confirmar)',
      typeFamily: 'Restauración',
      typeSubtype: 'Cena',
      color: 'orange',
      isDraft: true,
      participantTrackIds: [userId], // Solo el organizador
    );

    debugPrint('✅ Eventos con diferentes participantes generados (6 eventos: organizador solo, 1 familia, organizador+1, organizador+2, TODOS, organizador solo)');
  }

  // ==================== DÍA 2: EVENTOS SOLAPADOS CON DIFERENTES PARTICIPANTES ====================

  static Future<void> _generateOverlappingEvents(Plan plan, String userId, List<String> familyUserIds) async {
    debugPrint('📅 Generando eventos solapados con diferentes participantes (Día 2)...');
    final day2 = plan.startDate.add(const Duration(days: 1));

    // Evento solo del organizador (1h)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 9,
      startMinute: 0,
      durationMinutes: 60, // 09:00 - 10:00
      description: 'Trabajo administrativo (solo organizador)',
      typeFamily: 'Otro',
      color: 'gray',
      participantTrackIds: [userId], // Solo el organizador
    );

    // 2 eventos solapados parcialmente - diferentes participantes
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 10,
      startMinute: 0,
      durationMinutes: 120, // 10:00 - 12:00
      description: 'Taller de fotografía (organizador + 1 familia)',
      typeFamily: 'Actividad',
      color: 'indigo',
      participantTrackIds: [userId, familyUserIds[0]], // Organizador + 1 familia
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 11,
      startMinute: 0,
      durationMinutes: 90, // 11:00 - 12:30
      description: 'Coffee break (1 familia)',
      typeFamily: 'Restauración',
      typeSubtype: 'Bebida',
      color: 'brown',
      participantTrackIds: [familyUserIds[1]], // 1 familia
    );

    // 3 eventos completamente solapados - diferentes participantes (SIN conflictos en el mismo track)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 15,
      startMinute: 0,
      durationMinutes: 60,
      description: 'Obra de teatro (3 familia)',
      typeFamily: 'Actividad',
      typeSubtype: 'Teatro',
      color: 'red',
      participantTrackIds: [familyUserIds[0], familyUserIds[2], familyUserIds[3]], // Solo 3 familia (SIN organizador)
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 15,
      startMinute: 0,
      durationMinutes: 60,
      description: 'Película (organizador + 1 familia)',
      typeFamily: 'Actividad',
      color: 'blue',
      participantTrackIds: [userId, familyUserIds[1]], // Organizador + Emma
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 15,
      startMinute: 0,
      durationMinutes: 60,
      description: 'Concierto (1 familia)',
      typeFamily: 'Actividad',
      typeSubtype: 'Concierto',
      color: 'purple',
      participantTrackIds: [familyUserIds[2]], // Solo 1 familia (SIN organizador)
    );

    // Evento separado - organizador + 1 familia
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 18,
      startMinute: 0,
      durationMinutes: 120, // 18:00 - 20:00
      description: 'Cena con espectáculo (organizador + 1 familia)',
      typeFamily: 'Restauración',
      typeSubtype: 'Cena',
      color: 'orange',
      participantTrackIds: [userId, familyUserIds[3]], // Organizador + 1 familia
    );

    // Evento después de la cena - solo organizador
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 21,
      startMinute: 0,
      durationMinutes: 60, // 21:00 - 22:00
      description: 'Show en vivo (solo organizador)',
      typeFamily: 'Actividad',
      typeSubtype: 'Concierto',
      color: 'pink',
      participantTrackIds: [userId], // Solo el organizador
    );

    // Evento en borrador que se solapa con el show (para mostrar que los borradores SÍ pueden solaparse)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 21,
      startMinute: 30,
      durationMinutes: 30, // 21:30 - 22:00 (se solapa con el show)
      description: 'Cena tardía (borrador)',
      typeFamily: 'Restauración',
      typeSubtype: 'Cena',
      color: 'orange',
      isDraft: true, // BORRADOR - puede solaparse
      participantTrackIds: [userId], // Solo el organizador
    );

    debugPrint('✅ Eventos solapados con diferentes participantes generados (8 eventos: organizador solo, organizador+1, 1 familia, TODOS, 2 familia, 1 familia, organizador+1, organizador solo, organizador borrador)');
  }

  // ==================== DÍA 3: EVENTOS QUE CRUZAN DÍAS CON DIFERENTES PARTICIPANTES ====================

  static Future<void> _generateMultiDayEvents(Plan plan, String userId, List<String> familyUserIds) async {
    debugPrint('📅 Generando eventos que cruzan días con diferentes participantes (Día 3-4)...');
    final day3 = plan.startDate.add(const Duration(days: 2));
    final day4 = plan.startDate.add(const Duration(days: 3));

    // Evento solo del organizador en día 3 (separado de los nocturnos)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day3,
      hour: 9,
      startMinute: 0,
      durationMinutes: 180, // 3 horas (09:00-12:00)
      description: 'Trabajo remoto (solo organizador)',
      typeFamily: 'Otro',
      color: 'gray',
      participantTrackIds: [userId], // Solo el organizador
    );

    // Evento que termina al día siguiente - algunos participantes
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day3,
      hour: 20,
      startMinute: 0,
      durationMinutes: 300, // 5 horas (20:00 - 01:00 día siguiente)
      description: 'Teatro + cena tardía (3 familia)',
      typeFamily: 'Actividad',
      typeSubtype: 'Teatro',
      color: 'purple',
      participantTrackIds: [familyUserIds[1], familyUserIds[2], familyUserIds[3]], // Solo 3 familia (SIN organizador)
    );

    // Viaje nocturno (cruza medianoche) - organizador + 1 familia
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day3,
      hour: 22,
      startMinute: 0,
      durationMinutes: 480, // 8 horas (22:00 - 06:00 día siguiente)
      description: 'Tren nocturno Madrid-Barcelona (organizador + 1 familia)',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Tren',
      color: 'blue',
      participantTrackIds: [userId, familyUserIds[0]], // Organizador + 1 familia
    );

    // Evento en día 4 (después de que termine el Tren) - organizador + 2 familia
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 7,
      startMinute: 0,
      durationMinutes: 60, // 1 hora (07:00-08:00) - Tren termina a las 06:00
      description: 'Pesca en el lago (organizador + 2 familia)',
      typeFamily: 'Actividad',
      color: 'teal',
      participantTrackIds: [userId, familyUserIds[1], familyUserIds[2]], // Organizador + 2 familia
    );

    debugPrint('✅ Eventos que cruzan días con diferentes participantes generados (4 eventos: organizador solo, TODOS, organizador+1, organizador+2)');
  }

  // ==================== DÍA 4: TODOS LOS TIPOS DE EVENTOS CON DIFERENTES PARTICIPANTES ====================

  static Future<void> _generateEventTypes(Plan plan, String userId, List<String> familyUserIds) async {
    debugPrint('📅 Generando todos los tipos de eventos con diferentes participantes (Día 4)...');
    final day4 = plan.startDate.add(const Duration(days: 3));

    // DESPLAZAMIENTO - diferentes participantes
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 8,
      startMinute: 0,
      durationMinutes: 30,
      description: 'Taxi al aeropuerto (solo organizador)',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Taxi',
      color: 'blue',
      participantTrackIds: [userId], // Solo el organizador
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 20,
      startMinute: 0,
      durationMinutes: 1320, // 22 horas (Madrid-Sídney típico)
      description: 'Vuelo Madrid → Sídney (TODOS)',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Avión',
      color: 'blue',
      participantTrackIds: [userId, ...familyUserIds], // TODOS (organizador + familia)
      timezone: 'Europe/Madrid', // Timezone de salida
      arrivalTimezone: 'Australia/Sydney', // Timezone de llegada
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 12,
      startMinute: 0,
      durationMinutes: 45,
      description: 'Autobús al centro (organizador + 1 familia)',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Autobús',
      color: 'blue',
      participantTrackIds: [userId, familyUserIds[0]], // Organizador + 1 familia
    );

    // RESTAURACIÓN - diferentes participantes
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 13,
      startMinute: 30,
      durationMinutes: 90,
      description: 'Comida italiana (organizador + 2 familia)',
      typeFamily: 'Restauración',
      typeSubtype: 'Comida',
      color: 'red',
      participantTrackIds: [userId, familyUserIds[0], familyUserIds[1]], // Organizador + 2 familia
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 17,
      startMinute: 0,
      durationMinutes: 30,
      description: 'Merienda (1 familia)',
      typeFamily: 'Restauración',
      typeSubtype: 'Snack',
      color: 'orange',
      participantTrackIds: [familyUserIds[2]], // 1 familia
    );

    // ACTIVIDAD - diferentes participantes
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 18,
      startMinute: 0,
      durationMinutes: 120,
      description: 'Visita Sagrada Familia (TODOS)',
      typeFamily: 'Actividad',
      typeSubtype: 'Monumento',
      color: 'purple',
      participantTrackIds: [userId, ...familyUserIds], // TODOS (organizador + familia)
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 21,
      startMinute: 0,
      durationMinutes: 150,
      description: 'Teatro del Liceo (organizador + 1 familia)',
      typeFamily: 'Actividad',
      typeSubtype: 'Teatro',
      color: 'pink',
      participantTrackIds: [userId, familyUserIds[3]], // Organizador + 1 familia
    );

    debugPrint('✅ Todos los tipos de eventos con diferentes participantes generados (7 eventos: organizador solo, TODOS, organizador+1, organizador+2, 1 familia, TODOS, organizador+1)');
  }

  // ==================== DÍA 5: CASOS EDGE CON DIFERENTES PARTICIPANTES ====================

  static Future<void> _generateEdgeCases(Plan plan, String userId, List<String> familyUserIds) async {
    debugPrint('📅 Generando casos edge con diferentes participantes (Día 5)...');
    final day5 = plan.startDate.add(const Duration(days: 4));

    // Evento a las 00:00 (medianoche) - solo organizador
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 0,
      startMinute: 0,
      durationMinutes: 60, // 00:00 - 01:00
      description: 'Evento medianoche (solo organizador)',
      typeFamily: 'Otro',
      color: 'indigo',
      participantTrackIds: [userId], // Solo el organizador
    );

    // Evento de 15 minutos - organizador + 1 familia
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 10,
      startMinute: 0,
      durationMinutes: 15, // 10:00 - 10:15
      description: 'Llamada rápida (organizador + 1 familia)',
      typeFamily: 'Otro',
      color: 'orange',
      participantTrackIds: [userId, familyUserIds[0]], // Organizador + 1 familia
    );

    // 3 reuniones solapadas (justo en el límite) - diferentes participantes (SIN conflictos en el mismo track)
    final participantGroups = [
      [userId], // Solo organizador
      [familyUserIds[0]], // Solo 1 familia (SIN organizador)
      [familyUserIds[1], familyUserIds[2]], // 2 familia (SIN organizador)
    ];
    
    for (int i = 0; i < 3; i++) {
      await _createEvent(
        planId: plan.id!,
        userId: userId,
        date: day5,
        hour: 14,
        startMinute: i * 10, // 14:00, 14:10, 14:20 (separados por 10 min)
        durationMinutes: 15, // 15 minutos cada una (más cortas)
        description: 'Reunión ${i + 1} (${participantGroups[i].length} personas)',
        typeFamily: 'Otro',
        color: i % 2 == 0 ? 'blue' : 'red',
        participantTrackIds: participantGroups[i],
      );
    }

    // Evento largo (8h) que NO se solapa con las reuniones - organizador + 2 familia
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 15,
      startMinute: 0,
      durationMinutes: 480, // 8 horas (15:00 - 23:00)
      description: 'Excursión tarde completa (organizador + 2 familia)',
      typeFamily: 'Actividad',
      color: 'green',
      participantTrackIds: [userId, familyUserIds[1], familyUserIds[2]], // Organizador + 2 familia
    );

    // Evento a las 23:45 que cruza medianoche - solo organizador
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 23,
      startMinute: 45,
      durationMinutes: 30, // 23:45 - 00:15 del día 6
      description: 'Evento fin del día (solo organizador)',
      typeFamily: 'Otro',
      color: 'purple',
      participantTrackIds: [userId], // Solo el organizador
    );

    debugPrint('✅ Casos edge con diferentes participantes generados (6 eventos: organizador solo, organizador+1, organizador solo, 1 familia, 2 familia, organizador+2, organizador solo)');
  }

  // ==================== ALOJAMIENTOS ====================

  static Future<void> _generateAccommodations(Plan plan, String userId, List<String> familyUserIds) async {
    debugPrint('🏨 No generando alojamientos - empezando desde cero...');
    // No crear ningún alojamiento para empezar desde cero
    debugPrint('✅ Sin alojamientos generados - plan limpio');
  }

  // ==================== HELPERS ====================

  /// Lista de eventos creados para validar conflictos
  static final List<Event> _createdEvents = [];

  /// Valida si un evento crearía conflictos de solapamiento
  static bool _wouldCreateConflict({
    required DateTime date,
    required int hour,
    required int startMinute,
    required int durationMinutes,
    required List<String> participantTrackIds,
    bool isDraft = false,
  }) {
    // Los borradores pueden solaparse, no validar
    if (isDraft) return false;

    final eventStartMinutes = hour * 60 + startMinute;
    final eventEndMinutes = eventStartMinutes + durationMinutes;

    // Buscar eventos existentes en la misma fecha
    for (final existingEvent in _createdEvents) {
      if (existingEvent.date != date) continue;
      if (existingEvent.isDraft) continue; // Ignorar borradores

      final existingStartMinutes = existingEvent.hour * 60 + existingEvent.startMinute;
      final existingEndMinutes = existingStartMinutes + existingEvent.durationMinutes;

      // Verificar si hay solapamiento temporal
      if (eventStartMinutes < existingEndMinutes && eventEndMinutes > existingStartMinutes) {
        // Verificar si hay participantes en común
        for (final participantId in participantTrackIds) {
          if (existingEvent.participantTrackIds.contains(participantId)) {
            final existingDescription = existingEvent.description;
            debugPrint('⚠️ CONFLICTO DETECTADO: $participantId en $existingDescription (${existingEvent.hour}:${existingEvent.startMinute.toString().padLeft(2, '0')}) y nuevo evento ($hour:${startMinute.toString().padLeft(2, '0')})');
            return true; // HAY CONFLICTO
          }
        }
      }
    }

    return false; // NO HAY CONFLICTO
  }

  /// Encuentra participantes alternativos para evitar conflictos
  static List<String> _findAlternativeParticipants({
    required List<String> allParticipants,
    required List<String> preferredParticipants,
    required DateTime date,
    required int hour,
    required int startMinute,
    required int durationMinutes,
  }) {
    // Si no hay conflicto con los participantes preferidos, usarlos
    if (!_wouldCreateConflict(
      date: date,
      hour: hour,
      startMinute: startMinute,
      durationMinutes: durationMinutes,
      participantTrackIds: preferredParticipants,
    )) {
      return preferredParticipants;
    }

    // Buscar combinaciones alternativas
    for (int count = preferredParticipants.length; count >= 1; count--) {
      for (final participant in allParticipants) {
        if (!preferredParticipants.contains(participant)) {
          final alternativeParticipants = [participant];
          
          if (!_wouldCreateConflict(
            date: date,
            hour: hour,
            startMinute: startMinute,
            durationMinutes: durationMinutes,
            participantTrackIds: alternativeParticipants,
          )) {
            debugPrint('🔄 Usando participante alternativo: $participant');
            return alternativeParticipants;
          }
        }
      }
    }

    // Si no se encuentra alternativa, devolver lista vacía (evento sin participantes)
    debugPrint('⚠️ No se encontraron participantes alternativos, creando evento sin participantes');
    return [];
  }

  static Future<void> _createEvent({
    required String planId,
    required String userId,
    required DateTime date,
    required int hour,
    required int startMinute,
    required int durationMinutes,
    required String description,
    String? typeFamily,
    String? typeSubtype,
    String? color,
    bool isDraft = false,
    List<String>? participantTrackIds,
    String? timezone,
    String? arrivalTimezone,
  }) async {
    // Usar Europe/Madrid como timezone por defecto si no se especifica
    final finalTimezone = timezone ?? 'Europe/Madrid';
    final participants = participantTrackIds ?? [];
    
    // Validar conflictos solo para eventos confirmados
    if (!isDraft && participants.isNotEmpty) {
      // Obtener todos los participantes disponibles
      final allParticipants = [userId, ...participants];
      
      // Buscar participantes alternativos si hay conflicto
      final finalParticipants = _findAlternativeParticipants(
        allParticipants: allParticipants,
        preferredParticipants: participants,
        date: date,
        hour: hour,
        startMinute: startMinute,
        durationMinutes: durationMinutes,
      );
      
      if (finalParticipants.isEmpty) {
        debugPrint('⚠️ Evento "$description" creado sin participantes debido a conflictos');
      }
      
      participantTrackIds = finalParticipants;
    }

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
      isDraft: isDraft,
      participantIds: participantTrackIds ?? [],
    );

    // Construir EventPersonalPart para cada participante con datos de ejemplo
    final Map<String, EventPersonalPart> personalParts = {};
    for (final participantId in participantTrackIds ?? []) {
      personalParts[participantId] = EventPersonalPart(
        participantId: participantId,
        fields: {
          'asiento': _generateSampleSeat(typeFamily, typeSubtype),
          'menu': _generateSampleMenu(typeFamily),
          'preferencias': _generateSamplePreferences(typeFamily),
          'numeroReserva': _generateSampleReservationNumber(),
          'gate': _generateSampleGate(typeFamily),
          'tarjetaObtenida': _generateSampleCardStatus(),
          'notasPersonales': _generateSamplePersonalNotes(description, participantId),
        },
      );
    }

    final event = Event(
      planId: planId,
      userId: userId,
      date: date,
      hour: hour,
      duration: (durationMinutes / 60).ceil(),
      startMinute: startMinute,
      durationMinutes: durationMinutes,
      description: description,
      color: color,
      typeFamily: typeFamily,
      typeSubtype: typeSubtype,
      participantTrackIds: participantTrackIds ?? [],
      isDraft: isDraft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      commonPart: commonPart,
      personalParts: personalParts,
      timezone: finalTimezone,
      arrivalTimezone: arrivalTimezone,
    );

    // Añadir a la lista de eventos creados para futuras validaciones
    _createdEvents.add(event);

    await _eventService.createEvent(event);
  }

  static Future<void> _createAccommodation({
    required String planId,
    required String hotelName,
    required DateTime checkIn,
    required DateTime checkOut,
    required String type,
    required String color,
    String? description,
    List<String> participantTrackIds = const [],
  }) async {
    final accommodation = Accommodation(
      planId: planId,
      hotelName: hotelName,
      checkIn: checkIn,
      checkOut: checkOut,
      typeSubtype: type,
      color: color,
      description: description,
      participantTrackIds: participantTrackIds,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _accommodationService.saveAccommodation(accommodation);
  }

  // ==================== GENERADORES DE DATOS PERSONALES ====================

  /// Genera un asiento de ejemplo según el tipo de evento
  static String? _generateSampleSeat(String? typeFamily, String? typeSubtype) {
    if (typeFamily == 'Desplazamiento') {
      switch (typeSubtype) {
        case 'Avión':
          return '${_randomInt(1, 30)}${_randomLetter()}'; // Ej: 12A, 25F
        case 'Tren':
          return 'Vagón ${_randomInt(1, 8)}, Asiento ${_randomInt(1, 60)}';
        case 'Autobús':
          return 'Asiento ${_randomInt(1, 50)}';
        default:
          return null;
      }
    } else if (typeFamily == 'Actividad') {
      switch (typeSubtype) {
        case 'Teatro':
        case 'Concierto':
          return 'Fila ${_randomInt(1, 20)}, Asiento ${_randomInt(1, 30)}';
        default:
          return null;
      }
    }
    return null;
  }

  /// Genera un menú de ejemplo según el tipo de evento
  static String? _generateSampleMenu(String? typeFamily) {
    if (typeFamily == 'Restauración') {
      final menus = [
        'Menú vegetariano',
        'Sin gluten',
        'Menú del día',
        'Especialidad local',
        'Menú infantil',
        'Dieta mediterránea',
      ];
      return menus[_randomInt(0, menus.length - 1)];
    } else if (typeFamily == 'Desplazamiento') {
      final meals = [
        'Comida vegetariana',
        'Snack sin azúcar',
        'Bebida caliente',
        'Fruta fresca',
      ];
      return meals[_randomInt(0, meals.length - 1)];
    }
    return null;
  }

  /// Genera preferencias de ejemplo según el tipo de evento
  static String? _generateSamplePreferences(String? typeFamily) {
    final preferences = [
      'Cerca de la salida',
      'Zona silenciosa',
      'Vista panorámica',
      'Acceso fácil',
      'Zona familiar',
      'Sin humo',
    ];
    return preferences[_randomInt(0, preferences.length - 1)];
  }

  /// Genera un número de reserva de ejemplo
  static String? _generateSampleReservationNumber() {
    final prefixes = ['ABC', 'XYZ', 'RES', 'BOOK', 'CONF'];
    final prefix = prefixes[_randomInt(0, prefixes.length - 1)];
    final number = _randomInt(100000, 999999);
    return '$prefix$number';
  }

  /// Genera una puerta/gate de ejemplo según el tipo de evento
  static String? _generateSampleGate(String? typeFamily) {
    if (typeFamily == 'Desplazamiento') {
      final gates = ['Gate A12', 'Gate B8', 'Puerta 3', 'Terminal 2', 'Sala 15'];
      return gates[_randomInt(0, gates.length - 1)];
    } else if (typeFamily == 'Actividad') {
      final entrances = ['Entrada Principal', 'Acceso VIP', 'Puerta Norte', 'Entrada Lateral'];
      return entrances[_randomInt(0, entrances.length - 1)];
    }
    return null;
  }

  /// Genera el estado de tarjeta obtenida (70% probabilidad de true)
  static bool _generateSampleCardStatus() {
    return _randomInt(1, 10) <= 7; // 70% probabilidad
  }

  /// Genera notas personales de ejemplo
  static String? _generateSamplePersonalNotes(String description, String participantId) {
    final notes = [
      'Recordar llevar documento de identidad',
      'Confirmar horario 1 hora antes',
      'Llevar cámara de fotos',
      'Revisar pronóstico del tiempo',
      'Coordenadas GPS guardadas',
      'Contacto de emergencia: +34 600 123 456',
    ];
    return notes[_randomInt(0, notes.length - 1)];
  }

  /// Genera un número aleatorio entre min y max (ambos incluidos)
  static int _randomInt(int min, int max) {
    return min + (DateTime.now().millisecondsSinceEpoch % (max - min + 1));
  }

  /// Genera una letra aleatoria
  static String _randomLetter() {
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return letters[_randomInt(0, letters.length - 1)];
  }

  /// Asigna roles de permisos granulares a los usuarios del plan Frankenstein
  static Future<void> _assignPermissionRoles(String planId, String creatorUserId, List<String> familyUserIds) async {
    try {
      // 1. Creador del plan = Administrador (acceso completo)
      await _permissionService.assignPermissions(
        planId: planId,
        userId: creatorUserId,
        role: UserRole.admin,
        assignedBy: creatorUserId,
        metadata: {
          'assignedReason': 'Plan creator',
          'frankensteinPlan': true,
        },
      );
      debugPrint('🔐 Admin asignado: $creatorUserId (creador del plan)');

      // 2. Primer participante = Administrador (para testing de múltiples admins)
      if (familyUserIds.isNotEmpty) {
        await _permissionService.assignPermissions(
          planId: planId,
          userId: familyUserIds[0],
          role: UserRole.admin,
          assignedBy: creatorUserId,
          metadata: {
            'assignedReason': 'Secondary admin for testing',
            'frankensteinPlan': true,
          },
        );
        debugPrint('🔐 Admin asignado: ${familyUserIds[0]} (admin secundario)');
      }

      // 3. Segundo participante = Participante activo (permisos normales)
      if (familyUserIds.length > 1) {
        await _permissionService.assignPermissions(
          planId: planId,
          userId: familyUserIds[1],
          role: UserRole.participant,
          assignedBy: creatorUserId,
          metadata: {
            'assignedReason': 'Active participant',
            'frankensteinPlan': true,
          },
        );
        debugPrint('🔐 Participante asignado: ${familyUserIds[1]}');
      }

      // 4. Tercer participante = Participante activo (permisos normales)
      if (familyUserIds.length > 2) {
        await _permissionService.assignPermissions(
          planId: planId,
          userId: familyUserIds[2],
          role: UserRole.participant,
          assignedBy: creatorUserId,
          metadata: {
            'assignedReason': 'Active participant',
            'frankensteinPlan': true,
          },
        );
        debugPrint('🔐 Participante asignado: ${familyUserIds[2]}');
      }

      // 5. Cuarto participante = Observador (solo lectura)
      if (familyUserIds.length > 3) {
        await _permissionService.assignPermissions(
          planId: planId,
          userId: familyUserIds[3],
          role: UserRole.observer,
          assignedBy: creatorUserId,
          metadata: {
            'assignedReason': 'Observer for testing read-only access',
            'frankensteinPlan': true,
          },
        );
        debugPrint('🔐 Observador asignado: ${familyUserIds[3]}');
      }

      debugPrint('✅ Roles de permisos asignados correctamente');
    } catch (e) {
      debugPrint('❌ Error asignando roles de permisos: $e');
    }
  }

  // ==================== EVENTOS CON TIMEZONES ====================

  /// Genera eventos de prueba con diferentes timezones
  static Future<void> generateTimezoneEvents(Plan plan, String userId, List<String> familyUserIds) async {
    debugPrint('🌍 Generando eventos con diferentes timezones...');
    
    final day5 = plan.startDate.add(const Duration(days: 4));

    // Evento en Madrid (GMT+1/+2)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 10,
      startMinute: 0,
      durationMinutes: 120,
      description: 'Reunión en Madrid (GMT+1)',
      typeFamily: 'Otro',
      color: 'blue',
      participantTrackIds: [userId, familyUserIds[0]],
      timezone: 'Europe/Madrid',
    );

    // Evento en Nueva York (GMT-5/-4)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 14,
      startMinute: 0,
      durationMinutes: 90,
      description: 'Conferencia en Nueva York (GMT-5)',
      typeFamily: 'Actividad',
      color: 'red',
      participantTrackIds: [userId, familyUserIds[1]],
      timezone: 'America/New_York',
    );

    // Evento en Tokio (GMT+9)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 18,
      startMinute: 0,
      durationMinutes: 60,
      description: 'Cena en Tokio (GMT+9)',
      typeFamily: 'Restauración',
      color: 'green',
      participantTrackIds: [userId, familyUserIds[2]],
      timezone: 'Asia/Tokyo',
    );

    // Evento en Londres (GMT+0/+1)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 20,
      startMinute: 0,
      durationMinutes: 120,
      description: 'Teatro en Londres (GMT+0)',
      typeFamily: 'Actividad',
      color: 'purple',
      participantTrackIds: [userId, familyUserIds[3]],
      timezone: 'Europe/London',
    );

    debugPrint('✅ Eventos con timezones generados (4 eventos: Madrid, Nueva York, Tokio, Londres)');
  }
}

