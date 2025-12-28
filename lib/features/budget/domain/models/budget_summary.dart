/// T101: Resumen de presupuesto del plan
class BudgetSummary {
  // Costes totales
  final double totalCost; // Coste total del plan
  final double eventsCost; // Suma de costes de eventos
  final double accommodationsCost; // Suma de costes de alojamientos
  
  // Costes por tipo (eventos)
  final Map<String, double> costByEventType; // family -> coste
  
  // Costes por subtipo
  final Map<String, double> costBySubtype;
  
  // Costes por participante (estimado)
  final Map<String, double> costByParticipant; // userId -> coste estimado
  
  // Estadísticas
  final int eventsWithCost; // Eventos con coste definido
  final int accommodationsWithCost; // Alojamientos con coste definido
  
  const BudgetSummary({
    required this.totalCost,
    required this.eventsCost,
    required this.accommodationsCost,
    required this.costByEventType,
    required this.costBySubtype,
    required this.costByParticipant,
    required this.eventsWithCost,
    required this.accommodationsWithCost,
  });
  
  // Getters útiles
  int get totalItems => eventsWithCost + accommodationsWithCost;
  
  double get averageCostPerItem => totalItems > 0 ? totalCost / totalItems : 0.0;
  
  double get coveragePercentage => totalItems > 0 ? (totalItems / _totalItems()) * 100 : 0.0;
  
  int _totalItems() => 0; // Se calculará desde el servicio
}

