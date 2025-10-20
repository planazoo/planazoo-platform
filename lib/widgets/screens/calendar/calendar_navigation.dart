import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';

/// Clase que maneja la navegación del calendario
class CalendarNavigation {
  final Plan plan;
  final int currentDayGroup;
  final int visibleDays;

  CalendarNavigation({
    required this.plan,
    required this.currentDayGroup,
    required this.visibleDays,
  });

  /// Verifica si se puede navegar al grupo anterior
  bool canNavigatePrevious() {
    return currentDayGroup > 0;
  }

  /// Verifica si se puede navegar al grupo siguiente
  bool canNavigateNext() {
    final totalDays = plan.durationInDays;
    final startDay = currentDayGroup * visibleDays + 1;
    final endDay = startDay + visibleDays - 1;
    return endDay < totalDays;
  }

  /// Obtiene el número de día de inicio del grupo actual
  int getStartDay() {
    return currentDayGroup * visibleDays + 1;
  }

  /// Obtiene el número de día de fin del grupo actual
  int getEndDay() {
    return getStartDay() + visibleDays - 1;
  }

  /// Obtiene el número total de días del plan
  int getTotalDays() {
    return plan.durationInDays;
  }

  /// Calcula el número de grupos de días
  int getTotalDayGroups() {
    return (getTotalDays() / visibleDays).ceil();
  }

  /// Verifica si el grupo actual es válido
  bool isCurrentGroupValid() {
    final totalDays = getTotalDays();
    final currentStartDay = getStartDay();
    return currentStartDay <= totalDays;
  }

  /// Obtiene el grupo anterior válido
  int? getPreviousGroup() {
    if (!canNavigatePrevious()) return null;
    return currentDayGroup - 1;
  }

  /// Obtiene el grupo siguiente válido
  int? getNextGroup() {
    if (!canNavigateNext()) return null;
    return currentDayGroup + 1;
  }

  /// Obtiene el primer grupo válido
  int getFirstGroup() {
    return 0;
  }

  /// Obtiene el último grupo válido
  int getLastGroup() {
    return getTotalDayGroups() - 1;
  }

  /// Verifica si el grupo actual es el primero
  bool isFirstGroup() {
    return currentDayGroup == getFirstGroup();
  }

  /// Verifica si el grupo actual es el último
  bool isLastGroup() {
    return currentDayGroup == getLastGroup();
  }

  /// Obtiene el texto de navegación
  String getNavigationText() {
    final startDay = getStartDay();
    final endDay = getEndDay();
    final totalDays = getTotalDays();
    return 'Días $startDay-$endDay de $totalDays ($visibleDays visibles)';
  }

  /// Obtiene el porcentaje de progreso
  double getProgressPercentage() {
    final totalDays = getTotalDays();
    final currentEndDay = getEndDay();
    return (currentEndDay / totalDays).clamp(0.0, 1.0);
  }

  /// Calcula cuántos días quedan
  int getRemainingDays() {
    final totalDays = getTotalDays();
    final currentEndDay = getEndDay();
    return (totalDays - currentEndDay).clamp(0, totalDays);
  }

  /// Verifica si un día específico está en el rango visible
  bool isDayInRange(int dayNumber) {
    final startDay = getStartDay();
    final endDay = getEndDay();
    return dayNumber >= startDay && dayNumber <= endDay;
  }

  /// Obtiene el índice del día en el grupo actual
  int getDayIndex(int dayNumber) {
    final startDay = getStartDay();
    return dayNumber - startDay;
  }

  /// Verifica si un día es válido
  bool isValidDay(int dayNumber) {
    return dayNumber >= 1 && dayNumber <= getTotalDays();
  }

  /// Obtiene el grupo que contiene un día específico
  int getGroupForDay(int dayNumber) {
    if (!isValidDay(dayNumber)) return 0;
    return ((dayNumber - 1) / visibleDays).floor();
  }

  /// Navega a un día específico
  int navigateToDay(int dayNumber) {
    if (!isValidDay(dayNumber)) return currentDayGroup;
    return getGroupForDay(dayNumber);
  }

  /// Navega al primer día
  int navigateToFirstDay() {
    return getFirstGroup();
  }

  /// Navega al último día
  int navigateToLastDay() {
    return getLastGroup();
  }

  /// Navega al día actual
  int navigateToToday() {
    final today = DateTime.now().day;
    return navigateToDay(today);
  }

  /// Obtiene información de navegación para debugging
  Map<String, dynamic> getNavigationInfo() {
    return {
      'currentGroup': currentDayGroup,
      'visibleDays': visibleDays,
      'startDay': getStartDay(),
      'endDay': getEndDay(),
      'totalDays': getTotalDays(),
      'totalGroups': getTotalDayGroups(),
      'canNavigatePrevious': canNavigatePrevious(),
      'canNavigateNext': canNavigateNext(),
      'isFirstGroup': isFirstGroup(),
      'isLastGroup': isLastGroup(),
      'progressPercentage': getProgressPercentage(),
      'remainingDays': getRemainingDays(),
    };
  }
}
