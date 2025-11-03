import '../../../../shared/services/logger_service.dart';
import '../models/budget_summary.dart';
import '../../../../features/calendar/domain/models/event.dart';
import '../../../../features/calendar/domain/models/accommodation.dart';
import '../../../../features/calendar/domain/models/plan_participation.dart';

/// T101: Servicio para calcular análisis de presupuesto
class BudgetService {
  /// Calcular resumen de presupuesto del plan
  BudgetSummary calculateBudgetSummary({
    required List<Event> events,
    required List<Accommodation> accommodations,
    required List<PlanParticipation> participations,
  }) {
    // Filtrar solo eventos base confirmados con coste
    final eventsWithCost = events
        .where((e) => e.isBaseEvent && !e.isDraft && e.cost != null)
        .toList();
    
    // Filtrar solo alojamientos con coste
    final accommodationsWithCost = accommodations
        .where((a) => a.cost != null)
        .toList();
    
    // Suma total de eventos
    final eventsCost = eventsWithCost
        .fold<double>(0.0, (sum, event) => sum + (event.cost ?? 0.0));
    
    // Suma total de alojamientos
    final accommodationsCost = accommodationsWithCost
        .fold<double>(0.0, (sum, acc) => sum + (acc.cost ?? 0.0));
    
    // Coste total
    final totalCost = eventsCost + accommodationsCost;
    
    // Costes por tipo (family)
    final costByEventType = <String, double>{};
    for (final event in eventsWithCost) {
      final family = event.typeFamily ?? event.commonPart?.family ?? 'otro';
      final cost = event.cost ?? 0.0;
      costByEventType[family] = (costByEventType[family] ?? 0.0) + cost;
    }
    
    // Costes por subtipo
    final costBySubtype = <String, double>{};
    for (final event in eventsWithCost) {
      final subtype = event.typeSubtype ?? event.commonPart?.subtype;
      if (subtype != null && subtype.isNotEmpty) {
        final cost = event.cost ?? 0.0;
        costBySubtype[subtype] = (costBySubtype[subtype] ?? 0.0) + cost;
      }
    }
    
    // Costes por participante (estimado)
    final costByParticipant = <String, double>{};
    final realParticipants = participations
        .where((p) => p.role != 'observer')
        .map((p) => p.userId)
        .toSet();
    
    for (final event in eventsWithCost) {
      final cost = event.cost ?? 0.0;
      final isForAll = event.commonPart?.isForAllParticipants ?? false;
      final participantIds = event.commonPart?.participantIds ?? 
                            event.participantTrackIds;
      
      if (isForAll && realParticipants.isNotEmpty) {
        // Dividir el coste entre todos los participantes
        final costPerParticipant = cost / realParticipants.length;
        for (final participantId in realParticipants) {
          costByParticipant[participantId] = 
              (costByParticipant[participantId] ?? 0.0) + costPerParticipant;
        }
      } else if (participantIds.isNotEmpty) {
        // Dividir el coste entre los participantes específicos
        final costPerParticipant = cost / participantIds.length;
        for (final participantId in participantIds) {
          costByParticipant[participantId] = 
              (costByParticipant[participantId] ?? 0.0) + costPerParticipant;
        }
      }
    }
    
    return BudgetSummary(
      totalCost: totalCost,
      eventsCost: eventsCost,
      accommodationsCost: accommodationsCost,
      costByEventType: costByEventType,
      costBySubtype: costBySubtype,
      costByParticipant: costByParticipant,
      eventsWithCost: eventsWithCost.length,
      accommodationsWithCost: accommodationsWithCost.length,
    );
  }
}

