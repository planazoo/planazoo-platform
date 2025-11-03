import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';

/// T107: Utilidades para detectar y manejar eventos fuera del rango del plan
class PlanRangeUtils {
  /// Calcula la fecha de fin de un evento (fecha + duración)
  static DateTime _calculateEventEndDate(Event event) {
    final eventStartDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );
    
    return eventStartDateTime.add(Duration(minutes: event.durationMinutes));
  }

  /// Detecta si un evento se extiende fuera del rango del plan
  /// Retorna null si está dentro del rango, o un mapa con información sobre la expansión necesaria
  static Map<String, dynamic>? detectEventOutsideRange(Event event, Plan plan) {
    final eventDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );
    
    final eventEndDate = _calculateEventEndDate(event);
    final eventEndDay = DateTime(
      eventEndDate.year,
      eventEndDate.month,
      eventEndDate.day,
    );
    
    final planStartDate = DateTime(
      plan.startDate.year,
      plan.startDate.month,
      plan.startDate.day,
    );
    
    final planEndDate = DateTime(
      plan.endDate.year,
      plan.endDate.month,
      plan.endDate.day,
    );

    // Verificar si el evento está fuera del rango
    bool needsExpansion = false;
    bool extendsBefore = false;
    bool extendsAfter = false;
    int daysToExpandBefore = 0;
    int daysToExpandAfter = 0;

    // Verificar si se extiende antes del inicio del plan
    if (eventDate.isBefore(planStartDate)) {
      extendsBefore = true;
      needsExpansion = true;
      daysToExpandBefore = planStartDate.difference(eventDate).inDays;
    }

    // Verificar si se extiende después del fin del plan
    if (eventEndDay.isAfter(planEndDate)) {
      extendsAfter = true;
      needsExpansion = true;
      daysToExpandAfter = eventEndDay.difference(planEndDate).inDays;
    }

    if (!needsExpansion) {
      return null;
    }

    return {
      'needsExpansion': true,
      'extendsBefore': extendsBefore,
      'extendsAfter': extendsAfter,
      'daysToExpandBefore': daysToExpandBefore,
      'daysToExpandAfter': daysToExpandAfter,
      'newStartDate': extendsBefore 
          ? eventDate 
          : planStartDate,
      'newEndDate': extendsAfter 
          ? eventEndDay 
          : planEndDate,
    };
  }

  /// Calcula los nuevos valores del plan después de expandir para incluir el evento
  static Map<String, dynamic> calculateExpandedPlanValues(
    Plan plan,
    Map<String, dynamic> expansionInfo,
  ) {
    final newStartDate = expansionInfo['newStartDate'] as DateTime;
    final newEndDate = expansionInfo['newEndDate'] as DateTime;
    
    // Calcular nuevo columnCount basado en la diferencia de días
    final daysDifference = newEndDate.difference(newStartDate).inDays + 1;
    
    // Calcular nuevo baseDate (siempre será el startDate)
    final newBaseDate = newStartDate;
    
    return {
      'baseDate': newBaseDate,
      'startDate': newStartDate,
      'endDate': newEndDate,
      'columnCount': daysDifference,
    };
  }
}

