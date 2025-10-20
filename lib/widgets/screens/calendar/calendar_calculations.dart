import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';

/// Clase que maneja los cálculos del calendario
class CalendarCalculations {
  /// Calcula el ancho disponible para el contenido
  static double calculateAvailableWidth(BuildContext context) {
    return MediaQuery.of(context).size.width - CalendarConstants.lateralMargin;
  }

  /// Calcula el ancho de un día
  static double calculateDayWidth(double availableWidth, int visibleDays) {
    return availableWidth / visibleDays;
  }

  /// Calcula el ancho de una subcolumna (track de participante)
  static double calculateSubColumnWidth(double dayWidth, int trackCount) {
    if (trackCount == 0) return 0;
    return dayWidth / trackCount;
  }

  /// Calcula la posición horizontal de un elemento
  static double calculateHorizontalPosition(int position, double subColumnWidth) {
    return position * subColumnWidth;
  }

  /// Calcula el ancho de un elemento basado en su span
  static double calculateElementWidth(int span, double subColumnWidth) {
    return span * subColumnWidth;
  }

  /// Calcula la altura total del header
  static double calculateHeaderHeight() {
    return CalendarConstants.headerHeight + 
           CalendarConstants.participantFontSize + 
           CalendarConstants.miniHeaderHeight;
  }

  /// Calcula la altura total de una fila de eventos
  static double calculateEventRowHeight() {
    return CalendarConstants.eventRowHeight;
  }

  /// Calcula la altura total de una fila de alojamientos
  static double calculateAccommodationRowHeight() {
    return CalendarConstants.accommodationRowHeight;
  }

  /// Calcula el número total de filas necesarias
  static int calculateTotalRows(int totalDays, int visibleDays) {
    return (totalDays / visibleDays).ceil();
  }

  /// Calcula el número de grupos de días
  static int calculateDayGroups(int totalDays, int visibleDays) {
    return (totalDays / visibleDays).ceil();
  }

  /// Calcula el índice de un día en un grupo
  static int calculateDayIndex(int dayNumber, int currentGroup, int visibleDays) {
    return dayNumber - (currentGroup * visibleDays + 1);
  }

  /// Calcula el número de día basado en el índice
  static int calculateDayNumber(int dayIndex, int currentGroup, int visibleDays) {
    return currentGroup * visibleDays + dayIndex + 1;
  }

  /// Calcula la duración de un evento en horas
  static double calculateEventDurationInHours(Event event) {
    final durationMinutes = event.commonPart?.durationMinutes ?? 60;
    return durationMinutes / 60.0;
  }

  /// Calcula la duración de un alojamiento en días
  static int calculateAccommodationDurationInDays(Accommodation accommodation) {
    return accommodation.checkOut.difference(accommodation.checkIn).inDays;
  }

  /// Calcula el porcentaje de progreso del plan
  static double calculatePlanProgress(Plan plan, int currentDay) {
    if (plan.durationInDays <= 0) return 0.0;
    return (currentDay / plan.durationInDays).clamp(0.0, 1.0);
  }

  /// Calcula el porcentaje de progreso del día actual
  static double calculateDayProgress(DateTime currentTime) {
    final startOfDay = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final totalMinutes = endOfDay.difference(startOfDay).inMinutes;
    final elapsedMinutes = currentTime.difference(startOfDay).inMinutes;
    return (elapsedMinutes / totalMinutes).clamp(0.0, 1.0);
  }

  /// Calcula el número de eventos por día
  static int calculateEventsPerDay(List<Event> events, int dayNumber) {
    return events.where((event) => 
      event.commonPart?.date.day == dayNumber
    ).length;
  }

  /// Calcula el número de alojamientos por día
  static int calculateAccommodationsPerDay(List<Accommodation> accommodations, int dayNumber) {
    return accommodations.where((acc) => 
      acc.checkIn.day == dayNumber || acc.checkOut.day == dayNumber
    ).length;
  }

  /// Calcula la densidad de eventos en un rango de días
  static double calculateEventDensity(List<Event> events, int startDay, int endDay) {
    final totalDays = endDay - startDay + 1;
    if (totalDays <= 0) return 0.0;
    
    final eventsInRange = events.where((event) {
      final eventDay = event.commonPart?.date.day ?? 0;
      return eventDay >= startDay && eventDay <= endDay;
    }).length;
    
    return eventsInRange / totalDays;
  }

  /// Calcula la densidad de alojamientos en un rango de días
  static double calculateAccommodationDensity(List<Accommodation> accommodations, int startDay, int endDay) {
    final totalDays = endDay - startDay + 1;
    if (totalDays <= 0) return 0.0;
    
    final accommodationsInRange = accommodations.where((acc) {
      return acc.checkIn.day >= startDay && acc.checkIn.day <= endDay;
    }).length;
    
    return accommodationsInRange / totalDays;
  }

  /// Calcula el número de participantes activos en un día
  static int calculateActiveParticipants(List<Event> events, List<Accommodation> accommodations, int dayNumber) {
    final eventParticipants = events
        .where((event) => event.commonPart?.date.day == dayNumber)
        .expand((event) => event.commonPart?.participantIds ?? [])
        .toSet();
    
    final accommodationParticipants = accommodations
        .where((acc) => acc.checkIn.day == dayNumber || acc.checkOut.day == dayNumber)
        .expand((acc) => acc.participantTrackIds)
        .toSet();
    
    return {...eventParticipants, ...accommodationParticipants}.length;
  }

  /// Calcula el número de horas ocupadas en un día
  static int calculateOccupiedHours(List<Event> events, int dayNumber) {
    final eventsForDay = events.where((event) => 
      event.commonPart?.date.day == dayNumber
    ).toList();
    
    int totalMinutes = 0;
    for (final event in eventsForDay) {
      totalMinutes += event.commonPart?.durationMinutes ?? 0;
    }
    
    return (totalMinutes / 60).ceil();
  }

  /// Calcula el número de horas libres en un día
  static int calculateFreeHours(List<Event> events, int dayNumber) {
    const totalHoursInDay = 24;
    final occupiedHours = calculateOccupiedHours(events, dayNumber);
    return (totalHoursInDay - occupiedHours).clamp(0, totalHoursInDay);
  }

  /// Calcula el porcentaje de ocupación de un día
  static double calculateDayOccupancy(List<Event> events, int dayNumber) {
    const totalHoursInDay = 24;
    final occupiedHours = calculateOccupiedHours(events, dayNumber);
    return (occupiedHours / totalHoursInDay).clamp(0.0, 1.0);
  }

  /// Calcula el número de días con eventos
  static int calculateDaysWithEvents(List<Event> events) {
    final daysWithEvents = events
        .map((event) => event.commonPart?.date.day ?? 0)
        .where((day) => day > 0)
        .toSet();
    
    return daysWithEvents.length;
  }

  /// Calcula el número de días con alojamientos
  static int calculateDaysWithAccommodations(List<Accommodation> accommodations) {
    final daysWithAccommodations = <int>{};
    
    for (final acc in accommodations) {
      for (int day = acc.checkIn.day; day <= acc.checkOut.day; day++) {
        daysWithAccommodations.add(day);
      }
    }
    
    return daysWithAccommodations.length;
  }

  /// Calcula el número de días activos (con eventos o alojamientos)
  static int calculateActiveDays(List<Event> events, List<Accommodation> accommodations) {
    final activeDays = <int>{};
    
    // Días con eventos
    for (final event in events) {
      final day = event.commonPart?.date.day ?? 0;
      if (day > 0) activeDays.add(day);
    }
    
    // Días con alojamientos
    for (final acc in accommodations) {
      for (int day = acc.checkIn.day; day <= acc.checkOut.day; day++) {
        activeDays.add(day);
      }
    }
    
    return activeDays.length;
  }

  /// Calcula el porcentaje de días activos
  static double calculateActiveDaysPercentage(List<Event> events, List<Accommodation> accommodations, int totalDays) {
    if (totalDays <= 0) return 0.0;
    final activeDays = calculateActiveDays(events, accommodations);
    return (activeDays / totalDays).clamp(0.0, 1.0);
  }

  /// Calcula estadísticas generales del calendario
  static Map<String, dynamic> calculateCalendarStats({
    required Plan plan,
    required List<Event> events,
    required List<Accommodation> accommodations,
    required int currentDay,
  }) {
    return {
      'totalDays': plan.durationInDays,
      'totalEvents': events.length,
      'totalAccommodations': accommodations.length,
      'totalParticipants': plan.participants ?? 0,
      'daysWithEvents': calculateDaysWithEvents(events),
      'daysWithAccommodations': calculateDaysWithAccommodations(accommodations),
      'activeDays': calculateActiveDays(events, accommodations),
      'activeDaysPercentage': calculateActiveDaysPercentage(events, accommodations, plan.durationInDays),
      'planProgress': calculatePlanProgress(plan, currentDay),
      'currentDayOccupancy': calculateDayOccupancy(events, currentDay),
      'averageEventDensity': calculateEventDensity(events, 1, plan.durationInDays),
      'averageAccommodationDensity': calculateAccommodationDensity(accommodations, 1, plan.durationInDays),
    };
  }
}
