import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';

/// Utilidades para validación de plan: días vacíos, participantes sin eventos, etc.
class PlanValidationUtils {
  /// Resultado de validación
  final bool isValid;
  final List<String> warnings; // Avisos no críticos
  final List<String> errors; // Errores críticos (bloquean)

  PlanValidationUtils({
    this.isValid = true,
    this.warnings = const [],
    this.errors = const [],
  });
}

/// Validaciones adicionales del plan (VALID-1, VALID-2)
class PlanValidationService {
  /// Detectar días vacíos en un plan (sin eventos confirmados)
  static List<DateTime> detectEmptyDays(Plan plan, List<Event> events) {
    // Filtrar solo eventos confirmados (no borradores)
    final confirmedEvents = events
        .where((e) => e.isBaseEvent && !e.isDraft)
        .toList();

    // Obtener todas las fechas con eventos
    final datesWithEvents = confirmedEvents
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();

    // Generar lista de todas las fechas del plan
    final allDates = <DateTime>[];
    var currentDate = DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day);
    final endDate = DateTime(plan.endDate.year, plan.endDate.month, plan.endDate.day);

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      allDates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Detectar días sin eventos
    final emptyDays = allDates
        .where((date) => !datesWithEvents.contains(date))
        .toList();

    return emptyDays;
  }

  /// Detectar participantes sin eventos asignados
  static List<String> detectParticipantsWithoutEvents(
    List<PlanParticipation> participations,
    List<Event> events,
  ) {
    // Filtrar solo participantes reales (no observadores)
    final realParticipants = participations
        .where((p) => p.role != 'observer')
        .map((p) => p.userId)
        .toSet();

    // Filtrar solo eventos confirmados
    final confirmedEvents = events
        .where((e) => e.isBaseEvent && !e.isDraft)
        .toList();

    // Obtener todos los participantes que tienen al menos un evento
    final participantsWithEvents = <String>{};
    
    for (final event in confirmedEvents) {
      final isForAll = event.commonPart?.isForAllParticipants ?? false;
      final participantIds = event.commonPart?.participantIds ?? 
                            event.participantTrackIds;
      
      if (isForAll) {
        // Si es para todos, añadir todos los participantes
        participantsWithEvents.addAll(realParticipants);
      } else if (participantIds.isNotEmpty) {
        // Añadir participantes específicos
        participantsWithEvents.addAll(participantIds);
      }
      
      // También añadir el creador del evento
      participantsWithEvents.add(event.userId);
    }

    // Detectar participantes sin eventos
    final participantsWithoutEvents = realParticipants
        .where((participantId) => !participantsWithEvents.contains(participantId))
        .toList();

    return participantsWithoutEvents;
  }

  /// Validar un plan antes de confirmar (VALID-1, VALID-2)
  static PlanValidationUtils validatePlanForConfirmation({
    required Plan plan,
    required List<Event> events,
    required List<PlanParticipation> participations,
  }) {
    final emptyDays = detectEmptyDays(plan, events);
    final participantsWithoutEvents = detectParticipantsWithoutEvents(
      participations,
      events,
    );

    final warnings = <String>[];
    final errors = <String>[];

    // AVISOS (no bloquean, pero se informan)
    if (emptyDays.isNotEmpty) {
      warnings.add(
        'Hay ${emptyDays.length} día${emptyDays.length > 1 ? 's' : ''} sin eventos en el plan.',
      );
    }

    if (participantsWithoutEvents.isNotEmpty) {
      warnings.add(
        'Hay ${participantsWithoutEvents.length} participante${participantsWithoutEvents.length > 1 ? 's' : ''} sin eventos asignados.',
      );
    }

    // Actualmente no hay errores críticos que bloqueen la confirmación
    // En el futuro se pueden añadir: mínimo de participantes, mínimo de eventos, etc.

    return PlanValidationUtils(
      isValid: errors.isEmpty,
      warnings: warnings,
      errors: errors,
    );
  }
}

