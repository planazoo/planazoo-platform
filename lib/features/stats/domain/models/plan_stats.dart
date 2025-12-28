import 'package:unp_calendario/features/budget/domain/models/budget_summary.dart';

/// T113: Modelo de estadísticas del plan
class PlanStats {
  // Resumen general
  final int totalEvents;
  final int confirmedEvents; // No borradores
  final int draftEvents;
  final int totalDurationMinutes; // Duración total en minutos
  
  // Eventos por tipo (family)
  final Map<String, int> eventsByFamily;
  
  // Eventos por subtipo
  final Map<String, int> eventsBySubtype;
  
  // Distribución temporal
  final Map<DateTime, int> eventsByDate; // Eventos por día
  
  // Eventos por participante
  final Map<String, int> eventsByParticipant; // userId -> cantidad de eventos
  
  // Eventos con participantes específicos vs "para todos"
  final int eventsForAllParticipants;
  final int eventsWithSpecificParticipants;
  
  // Participantes del plan
  final int totalParticipants;
  final int activeParticipants; // Participantes con al menos 1 evento
  
  // T101: Presupuesto
  final BudgetSummary? budgetSummary; // Resumen de presupuesto (opcional)
  
  const PlanStats({
    required this.totalEvents,
    required this.confirmedEvents,
    required this.draftEvents,
    required this.totalDurationMinutes,
    required this.eventsByFamily,
    required this.eventsBySubtype,
    required this.eventsByDate,
    required this.eventsByParticipant,
    required this.eventsForAllParticipants,
    required this.eventsWithSpecificParticipants,
    required this.totalParticipants,
    required this.activeParticipants,
    this.budgetSummary,
  });
  
  // Getters útiles
  double get averageDurationMinutes => totalEvents > 0 ? totalDurationMinutes / totalEvents : 0.0;
  double get averageDurationHours => averageDurationMinutes / 60.0;
  
  double get draftPercentage => totalEvents > 0 ? (draftEvents / totalEvents) * 100 : 0.0;
  double get confirmedPercentage => totalEvents > 0 ? (confirmedEvents / totalEvents) * 100 : 0.0;
  
  int get daysWithEvents => eventsByDate.length;
  int get daysWithoutEvents => 0; // Se calculará desde el plan
  
  double get eventsPerDay => daysWithEvents > 0 ? totalEvents / daysWithEvents : 0.0;
  
  double get participantActivityPercentage => totalParticipants > 0 
      ? (activeParticipants / totalParticipants) * 100 
      : 0.0;
}

