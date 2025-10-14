import 'package:flutter/foundation.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/accommodation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';

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

  /// Genera el plan completo "Frankenstein" con todos los datos de prueba
  static Future<String?> generateFrankensteinPlan(String userId) async {
    try {
      if (!kDebugMode) {
        debugPrint('⚠️ generateFrankensteinPlan solo disponible en modo debug');
        return null;
      }

      debugPrint('🧟 Generando plan Frankenstein...');

      // 1. Verificar si ya existe y eliminarlo
      await deleteFrankensteinPlan();

      // 2. Crear plan base
      final plan = await _createDemoPlan(userId);
      if (plan?.id == null) {
        debugPrint('❌ Error al crear plan base');
        return null;
      }

      debugPrint('✅ Plan base creado: ${plan!.id}');

      // 3. Crear participación del creador como organizador
      await _participationService.createParticipation(
        planId: plan.id!,
        userId: userId,
        role: 'organizer',
      );

      // 4. Generar eventos por categoría
      await _generateBasicEvents(plan, userId);
      await _generateOverlappingEvents(plan, userId);
      await _generateMultiDayEvents(plan, userId);
      await _generateEventTypes(plan, userId);
      await _generateEdgeCases(plan, userId);

      // 5. Generar alojamientos
      await _generateAccommodations(plan);

      debugPrint('🎉 Plan Frankenstein generado exitosamente: ${plan.id}');
      return plan.id;
    } catch (e) {
      debugPrint('❌ Error generando plan Frankenstein: $e');
      return null;
    }
  }

  /// Elimina el plan Frankenstein existente si existe
  static Future<void> deleteFrankensteinPlan() async {
    try {
      // Buscar planes con nombre Frankenstein
      final allPlans = await _planService.getPlans().first;
      final frankensteinPlans = allPlans.where((p) => p.name.contains('Frankenstein')).toList();

      for (final plan in frankensteinPlans) {
        if (plan.id != null) {
          debugPrint('🗑️ Eliminando plan Frankenstein existente: ${plan.id}');
          
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
      debugPrint('⚠️ Error eliminando plan Frankenstein: $e');
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
      description: 'Plan de testing completo con todos los tipos de eventos, '
          'solapamientos, casos edge y complejidades implementadas. '
          '¡Un verdadero monstruo de Frankenstein! 🧟',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      savedAt: DateTime.now(),
    );

    final success = await _planService.savePlanByUnpId(plan);
    if (!success) return null;

    // Obtener el plan guardado con su ID
    final allPlans = await _planService.getPlans().first;
    return allPlans.firstWhere((p) => p.unpId == demoPlanId);
  }

  // ==================== DÍA 1: EVENTOS BÁSICOS ====================

  static Future<void> _generateBasicEvents(Plan plan, String userId) async {
    debugPrint('📅 Generando eventos básicos (Día 1)...');
    final day1 = plan.startDate;

    // REGLA: Máximo 3 eventos simultáneos - Eventos separados sin solapamientos

    // Evento corto (30 min)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day1,
      hour: 9,
      startMinute: 0,
      durationMinutes: 30, // 09:00 - 09:30
      description: 'Café rápido',
      typeFamily: 'Restauración',
      typeSubtype: 'Bebida',
      color: 'brown',
    );

    // Evento mediano (2h)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day1,
      hour: 10,
      startMinute: 0,
      durationMinutes: 120, // 10:00 - 12:00
      description: 'Visita museo',
      typeFamily: 'Actividad',
      typeSubtype: 'Museo',
      color: 'purple',
    );

    // Evento largo (4h)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day1,
      hour: 14,
      startMinute: 0,
      durationMinutes: 240, // 14:00 - 18:00
      description: 'Tarde en la playa',
      typeFamily: 'Actividad',
      typeSubtype: 'Parque',
      color: 'teal',
    );

    // Evento borrador (2h)
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
    );

    debugPrint('✅ Eventos básicos generados (4 eventos - sin solapamientos)');
  }

  // ==================== DÍA 2: EVENTOS SOLAPADOS ====================

  static Future<void> _generateOverlappingEvents(Plan plan, String userId) async {
    debugPrint('📅 Generando eventos solapados (Día 2)...');
    final day2 = plan.startDate.add(const Duration(days: 1));

    // REGLA: Máximo 3 eventos solapados simultáneamente

    // 2 eventos solapados parcialmente (OK - no excede límite)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 10,
      startMinute: 0,
      durationMinutes: 120, // 10:00 - 12:00
      description: 'Taller de fotografía',
      typeFamily: 'Actividad',
      color: 'indigo',
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 11,
      startMinute: 0,
      durationMinutes: 90, // 11:00 - 12:30
      description: 'Coffee break networking',
      typeFamily: 'Restauración',
      typeSubtype: 'Bebida',
      color: 'brown',
    );

    // 3 eventos completamente solapados (OK - justo en el límite, mostrará ⚠️)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 15,
      startMinute: 0,
      durationMinutes: 60,
      description: 'Obra de teatro A',
      typeFamily: 'Actividad',
      typeSubtype: 'Teatro',
      color: 'red',
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 15,
      startMinute: 0,
      durationMinutes: 60,
      description: 'Película B',
      typeFamily: 'Actividad',
      color: 'blue',
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 15,
      startMinute: 0,
      durationMinutes: 60,
      description: 'Concierto C',
      typeFamily: 'Actividad',
      typeSubtype: 'Concierto',
      color: 'purple',
    );

    // Evento separado (no se solapa con los de las 15:00)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 18,
      startMinute: 0,
      durationMinutes: 120, // 18:00 - 20:00
      description: 'Cena con espectáculo',
      typeFamily: 'Restauración',
      typeSubtype: 'Cena',
      color: 'orange',
    );

    // NO añadir Show en vivo porque causaría 2 solapados con Cena
    // En su lugar, evento después de la cena
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day2,
      hour: 21,
      startMinute: 0,
      durationMinutes: 60, // 21:00 - 22:00 (después de cena)
      description: 'Show en vivo',
      typeFamily: 'Actividad',
      typeSubtype: 'Concierto',
      color: 'pink',
    );

    debugPrint('✅ Eventos solapados generados (6 eventos - máx 3 simultáneos)');
  }

  // ==================== DÍA 3: EVENTOS QUE CRUZAN DÍAS ====================

  static Future<void> _generateMultiDayEvents(Plan plan, String userId) async {
    debugPrint('📅 Generando eventos que cruzan días (Día 3-4)...');
    final day3 = plan.startDate.add(const Duration(days: 2));
    final day4 = plan.startDate.add(const Duration(days: 3));

    // ANÁLISIS DE SOLAPAMIENTOS:
    // Teatro: 20:00 día 3 - 01:00 día 4
    // Tren:   22:00 día 3 - 06:00 día 4
    // 
    // DÍA 3:
    //   20:00-22:00: Solo Teatro (1 evento) ✅
    //   22:00-24:00: Teatro + Tren (2 eventos) ✅
    // 
    // DÍA 4:
    //   00:00-01:00: Teatro + Tren (2 eventos) ✅
    //   01:00-06:00: Solo Tren (1 evento) ✅

    // Evento que termina al día siguiente
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day3,
      hour: 20,
      startMinute: 0,
      durationMinutes: 300, // 5 horas (20:00 - 01:00 día siguiente)
      description: 'Teatro + cena tardía',
      typeFamily: 'Actividad',
      typeSubtype: 'Teatro',
      color: 'purple',
    );

    // Viaje nocturno (cruza medianoche)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day3,
      hour: 22,
      startMinute: 0,
      durationMinutes: 480, // 8 horas (22:00 - 06:00 día siguiente)
      description: 'Tren nocturno Madrid-Barcelona',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Tren',
      color: 'blue',
    );

    // Evento en día 3 (separado de los nocturnos)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day3,
      hour: 9,
      startMinute: 0,
      durationMinutes: 180, // 3 horas (09:00-12:00)
      description: 'Senderismo en montaña',
      typeFamily: 'Actividad',
      color: 'green',
    );

    // Evento en día 4 (después de que termine el Tren)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 7,
      startMinute: 0,
      durationMinutes: 60, // 1 hora (07:00-08:00) - Tren termina a las 06:00
      description: 'Pesca en el lago',
      typeFamily: 'Actividad',
      color: 'teal',
    );

    debugPrint('✅ Eventos que cruzan días generados (4 eventos multi-día)');
  }

  // ==================== DÍA 4: TODOS LOS TIPOS DE EVENTOS ====================

  static Future<void> _generateEventTypes(Plan plan, String userId) async {
    debugPrint('📅 Generando todos los tipos de eventos (Día 4)...');
    final day4 = plan.startDate.add(const Duration(days: 3));

    // DESPLAZAMIENTO
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 8,
      startMinute: 0,
      durationMinutes: 30,
      description: 'Taxi al aeropuerto',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Taxi',
      color: 'blue',
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 9,
      startMinute: 30,
      durationMinutes: 120,
      description: 'Vuelo Madrid-Barcelona',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Avión',
      color: 'blue',
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 12,
      startMinute: 0,
      durationMinutes: 45,
      description: 'Autobús al centro',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Autobús',
      color: 'blue',
    );

    // RESTAURACIÓN
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 13,
      startMinute: 30,
      durationMinutes: 90,
      description: 'Comida italiana',
      typeFamily: 'Restauración',
      typeSubtype: 'Comida',
      color: 'red',
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 17,
      startMinute: 0,
      durationMinutes: 30,
      description: 'Merienda',
      typeFamily: 'Restauración',
      typeSubtype: 'Snack',
      color: 'orange',
    );

    // ACTIVIDAD
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 18,
      startMinute: 0,
      durationMinutes: 120,
      description: 'Visita Sagrada Familia',
      typeFamily: 'Actividad',
      typeSubtype: 'Monumento',
      color: 'purple',
    );

    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day4,
      hour: 21,
      startMinute: 0,
      durationMinutes: 150,
      description: 'Teatro del Liceo',
      typeFamily: 'Actividad',
      typeSubtype: 'Teatro',
      color: 'pink',
    );

    debugPrint('✅ Todos los tipos de eventos generados (7 eventos)');
  }

  // ==================== DÍA 5: CASOS EDGE ====================

  static Future<void> _generateEdgeCases(Plan plan, String userId) async {
    debugPrint('📅 Generando casos edge (Día 5)...');
    final day5 = plan.startDate.add(const Duration(days: 4));

    // REGLA: Máximo 3 eventos simultáneos

    // Evento a las 00:00 (medianoche)
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 0,
      startMinute: 0,
      durationMinutes: 60, // 00:00 - 01:00
      description: 'Evento medianoche',
      typeFamily: 'Otro',
      color: 'indigo',
    );

    // Evento de 15 minutos
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 10,
      startMinute: 0,
      durationMinutes: 15, // 10:00 - 10:15
      description: 'Llamada rápida',
      typeFamily: 'Otro',
      color: 'orange',
    );

    // 3 reuniones solapadas (justo en el límite)
    for (int i = 0; i < 3; i++) {
      await _createEvent(
        planId: plan.id!,
        userId: userId,
        date: day5,
        hour: 14,
        startMinute: i * 5, // 14:00, 14:05, 14:10
        durationMinutes: 20, // 20 minutos cada una
        description: 'Reunión ${i + 1}',
        typeFamily: 'Otro',
        color: i % 2 == 0 ? 'blue' : 'red',
      );
    }

    // Evento largo (8h) que NO se solapa con las reuniones
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 15,
      startMinute: 0,
      durationMinutes: 480, // 8 horas (15:00 - 23:00)
      description: 'Excursión tarde completa',
      typeFamily: 'Actividad',
      color: 'green',
    );

    // Evento a las 23:45 que cruza medianoche
    await _createEvent(
      planId: plan.id!,
      userId: userId,
      date: day5,
      hour: 23,
      startMinute: 45,
      durationMinutes: 30, // 23:45 - 00:15 del día 6
      description: 'Evento fin del día',
      typeFamily: 'Otro',
      color: 'purple',
    );

    debugPrint('✅ Casos edge generados (6 eventos - máx 3 simultáneos)');
  }

  // ==================== ALOJAMIENTOS ====================

  static Future<void> _generateAccommodations(Plan plan) async {
    debugPrint('🏨 Generando alojamientos...');
    final day1 = plan.startDate;

    // Hotel día 1-3
    await _createAccommodation(
      planId: plan.id!,
      hotelName: 'Hotel Frankenstein Inn',
      checkIn: day1,
      checkOut: day1.add(const Duration(days: 2)),
      type: 'Hotel',
      color: 'blue',
      description: 'Hotel céntrico con desayuno incluido',
    );

    // Apartamento día 3-5 (overlap con hotel)
    await _createAccommodation(
      planId: plan.id!,
      hotelName: 'Apartamento Monster Place',
      checkIn: day1.add(const Duration(days: 2)),
      checkOut: day1.add(const Duration(days: 4)),
      type: 'Apartamento',
      color: 'green',
      description: 'Apartamento con cocina equipada',
    );

    // Camping día 3-7 (5 días - ahora es ALOJAMIENTO, no evento)
    await _createAccommodation(
      planId: plan.id!,
      hotelName: 'Camping Montaña Salvaje',
      checkIn: day1.add(const Duration(days: 2)),
      checkOut: day1.add(const Duration(days: 6)),
      type: 'Camping',
      color: 'purple',
      description: 'Camping con vistas a la montaña - 5 días de aventura',
    );

    // Resort día 5-7
    await _createAccommodation(
      planId: plan.id!,
      hotelName: 'Resort Playa del Terror',
      checkIn: day1.add(const Duration(days: 4)),
      checkOut: day1.add(const Duration(days: 6)),
      type: 'Resort',
      color: 'orange',
      description: 'Resort todo incluido en la playa',
    );

    debugPrint('✅ Alojamientos generados (4 alojamientos)');
  }

  // ==================== HELPERS ====================

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
  }) async {
    final event = Event(
      planId: planId,
      userId: userId,
      date: date,
      hour: hour,
      startMinute: startMinute,
      duration: (durationMinutes / 60).ceil(),
      durationMinutes: durationMinutes,
      description: description,
      typeFamily: typeFamily,
      typeSubtype: typeSubtype,
      color: color,
      isDraft: isDraft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

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
  }) async {
    final accommodation = Accommodation(
      planId: planId,
      hotelName: hotelName,
      checkIn: checkIn,
      checkOut: checkOut,
      typeSubtype: type,
      color: color,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _accommodationService.saveAccommodation(accommodation);
  }
}

