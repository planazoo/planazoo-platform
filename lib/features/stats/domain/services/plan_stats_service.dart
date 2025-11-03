import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/accommodation_service.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/plan_stats.dart';
import '../../../budget/domain/services/budget_service.dart';
import '../../../budget/domain/models/budget_summary.dart';

/// T113: Servicio para calcular estadísticas de un plan
class PlanStatsService {
  final EventService _eventService = EventService();
  final PlanParticipationService _participationService = PlanParticipationService();
  final AccommodationService _accommodationService = AccommodationService();
  final BudgetService _budgetService = BudgetService();

  /// Calcular estadísticas completas de un plan
  Future<PlanStats> calculateStats(Plan plan, String userId) async {
    try {
      if (plan.id == null) {
        return _emptyStats();
      }

      // Obtener todos los eventos del plan
      final events = await _eventService
          .getEventsByPlanId(plan.id!, userId)
          .first
          .timeout(const Duration(seconds: 10));

      // Obtener participantes del plan
      final participations = await _participationService
          .getPlanParticipations(plan.id!)
          .first
          .timeout(const Duration(seconds: 10));

      // T101: Obtener alojamientos del plan
      final accommodations = await _accommodationService
          .getAccommodations(plan.id!)
          .first
          .timeout(const Duration(seconds: 10));

      return _calculateStatsFromData(events, participations, accommodations);
    } catch (e) {
      LoggerService.error('Error calculating plan stats', error: e);
      return _emptyStats();
    }
  }

  PlanStats _calculateStatsFromData(
    List<Event> events,
    List<PlanParticipation> participations,
    List<Accommodation> accommodations,
  ) {
    // Filtrar solo eventos base (no copias)
    final baseEvents = events.where((e) => e.isBaseEvent).toList();

    // Resumen general
    final totalEvents = baseEvents.length;
    final confirmedEvents = baseEvents.where((e) => !e.isDraft).length;
    final draftEvents = baseEvents.where((e) => e.isDraft).length;
    
    // Duración total
    final totalDurationMinutes = baseEvents.fold<int>(
      0,
      (sum, event) => sum + event.durationMinutes,
    );

    // Eventos por tipo (family)
    final eventsByFamily = <String, int>{};
    for (final event in baseEvents) {
      final family = event.typeFamily ?? event.commonPart?.family ?? 'otro';
      eventsByFamily[family] = (eventsByFamily[family] ?? 0) + 1;
    }

    // Eventos por subtipo
    final eventsBySubtype = <String, int>{};
    for (final event in baseEvents) {
      final subtype = event.typeSubtype ?? event.commonPart?.subtype;
      if (subtype != null && subtype.isNotEmpty) {
        eventsBySubtype[subtype] = (eventsBySubtype[subtype] ?? 0) + 1;
      }
    }

    // Distribución temporal (eventos por día)
    final eventsByDate = <DateTime, int>{};
    for (final event in baseEvents) {
      final eventDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      eventsByDate[eventDate] = (eventsByDate[eventDate] ?? 0) + 1;
    }

    // Eventos por participante
    final eventsByParticipant = <String, int>{};
    final participantsWithEvents = <String>{};
    
    for (final event in baseEvents) {
      final isForAll = event.commonPart?.isForAllParticipants ?? false;
      final participantIds = event.commonPart?.participantIds ?? 
                            event.participantTrackIds;
      
      if (isForAll) {
        // Contar para todos los participantes
        for (final participation in participations) {
          if (participation.role != 'observer') {
            final uid = participation.userId;
            eventsByParticipant[uid] = (eventsByParticipant[uid] ?? 0) + 1;
            participantsWithEvents.add(uid);
          }
        }
      } else if (participantIds.isNotEmpty) {
        // Contar para participantes específicos
        for (final participantId in participantIds) {
          eventsByParticipant[participantId] = 
              (eventsByParticipant[participantId] ?? 0) + 1;
          participantsWithEvents.add(participantId);
        }
      }
      
      // También contar el creador del evento
      eventsByParticipant[event.userId] = 
          (eventsByParticipant[event.userId] ?? 0) + 1;
      participantsWithEvents.add(event.userId);
    }

    // Eventos "para todos" vs específicos
    final eventsForAllParticipants = baseEvents
        .where((e) => e.commonPart?.isForAllParticipants ?? false)
        .length;
    final eventsWithSpecificParticipants = baseEvents
        .where((e) => 
            !(e.commonPart?.isForAllParticipants ?? false) && 
            ((e.commonPart?.participantIds ?? e.participantTrackIds).isNotEmpty))
        .length;

    // Participantes
    final totalParticipants = participations
        .where((p) => p.role != 'observer')
        .length;
    final activeParticipants = participantsWithEvents.length;

    // T101: Calcular resumen de presupuesto
    BudgetSummary? budgetSummary;
    try {
      budgetSummary = _budgetService.calculateBudgetSummary(
        events: events,
        accommodations: accommodations,
        participations: participations,
      );
    } catch (e) {
      LoggerService.error('Error calculating budget summary', error: e);
    }

    return PlanStats(
      totalEvents: totalEvents,
      confirmedEvents: confirmedEvents,
      draftEvents: draftEvents,
      totalDurationMinutes: totalDurationMinutes,
      eventsByFamily: eventsByFamily,
      eventsBySubtype: eventsBySubtype,
      eventsByDate: eventsByDate,
      eventsByParticipant: eventsByParticipant,
      eventsForAllParticipants: eventsForAllParticipants,
      eventsWithSpecificParticipants: eventsWithSpecificParticipants,
      totalParticipants: totalParticipants,
      activeParticipants: activeParticipants,
      budgetSummary: budgetSummary,
    );
  }

  PlanStats _emptyStats() {
    return const PlanStats(
      totalEvents: 0,
      confirmedEvents: 0,
      draftEvents: 0,
      totalDurationMinutes: 0,
      eventsByFamily: {},
      eventsBySubtype: {},
      eventsByDate: {},
      eventsByParticipant: {},
      eventsForAllParticipants: 0,
      eventsWithSpecificParticipants: 0,
      totalParticipants: 0,
      activeParticipants: 0,
      budgetSummary: null,
    );
  }
}

