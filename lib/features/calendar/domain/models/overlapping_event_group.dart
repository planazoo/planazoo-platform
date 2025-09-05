import 'event.dart';

/// Representa un grupo de eventos que se solapan en el tiempo
class OverlappingEventGroup {
  final List<Event> events;
  final DateTime date;
  final int startHour;
  final int endHour;
  final int maxOverlap;

  const OverlappingEventGroup({
    required this.events,
    required this.date,
    required this.startHour,
    required this.endHour,
    required this.maxOverlap,
  });

  /// Crea grupos de eventos solapados para una fecha específica
  static List<OverlappingEventGroup> createGroups(
    List<Event> events,
    DateTime date,
  ) {
    // Filtrar eventos de la fecha específica (excluyendo alojamiento)
    final dateEvents = events.where((event) {
      if (event.typeFamily == 'alojamiento') return false;
      
      return event.date.year == date.year &&
             event.date.month == date.month &&
             event.date.day == date.day;
    }).toList();

    if (dateEvents.isEmpty) return [];

    // Ordenar eventos por hora de inicio
    dateEvents.sort((a, b) => a.hour.compareTo(b.hour));

    final groups = <OverlappingEventGroup>[];
    final processedEvents = <String>{};

    for (final event in dateEvents) {
      if (processedEvents.contains(event.id)) continue;

      final group = _findOverlappingGroup(event, dateEvents, processedEvents);
      if (group.events.isNotEmpty) {
        groups.add(group);
        processedEvents.addAll(group.events.map((e) => e.id ?? ''));
      }
    }

    return groups;
  }

  /// Encuentra todos los eventos que se solapan con el evento dado
  static OverlappingEventGroup _findOverlappingGroup(
    Event startEvent,
    List<Event> allEvents,
    Set<String> processedEvents,
  ) {
    final overlappingEvents = <Event>[startEvent];
    final eventQueue = <Event>[startEvent];
    processedEvents.add(startEvent.id ?? '');

    int startHour = startEvent.hour;
    int endHour = startEvent.hour + startEvent.duration - 1;

    while (eventQueue.isNotEmpty) {
      final currentEvent = eventQueue.removeAt(0);
      
      for (final otherEvent in allEvents) {
        if (processedEvents.contains(otherEvent.id)) continue;
        if (otherEvent.id == currentEvent.id) continue;

        // Verificar solapamiento
        final otherStart = otherEvent.hour;
        final otherEnd = otherEvent.hour + otherEvent.duration - 1;

        if (_hasOverlap(startHour, endHour, otherStart, otherEnd)) {
          overlappingEvents.add(otherEvent);
          eventQueue.add(otherEvent);
          processedEvents.add(otherEvent.id ?? '');
          
          // Actualizar rango del grupo
          startHour = startHour < otherStart ? startHour : otherStart;
          endHour = endHour > otherEnd ? endHour : otherEnd;
        }
      }
    }

    // Ordenar eventos por hora de inicio
    overlappingEvents.sort((a, b) => a.hour.compareTo(b.hour));

    return OverlappingEventGroup(
      events: overlappingEvents,
      date: startEvent.date,
      startHour: startHour,
      endHour: endHour,
      maxOverlap: overlappingEvents.length,
    );
  }

  /// Verifica si dos rangos de tiempo se solapan
  static bool _hasOverlap(int start1, int end1, int start2, int end2) {
    return (start1 <= end2) && (end1 >= start2);
  }

  /// Obtiene la posición horizontal para un evento específico en el grupo
  double getEventPosition(Event event) {
    final index = events.indexOf(event);
    if (index == -1) return 0.0;
    
    // Calcular posición basada en el índice y el ancho disponible
    return (index * 100.0) / maxOverlap;
  }

  /// Obtiene el ancho para un evento específico en el grupo
  double getEventWidth(double totalWidth) {
    // Distribuir el ancho disponible entre todos los eventos
    return totalWidth / maxOverlap;
  }

  /// Verifica si un evento está en una hora específica
  bool isEventAtHour(Event event, int hour) {
    return hour >= event.hour && hour <= (event.hour + event.duration - 1);
  }

  /// Obtiene todos los eventos que están activos en una hora específica
  List<Event> getEventsAtHour(int hour) {
    return events.where((event) => isEventAtHour(event, hour)).toList();
  }

  /// Obtiene la posición vertical del evento en la celda
  double getEventVerticalPosition(Event event, int hour) {
    if (!isEventAtHour(event, hour)) return 0.0;
    
    // Si es la primera hora del evento, posición 0
    if (hour == event.hour) return 0.0;
    
    // Si no es la primera hora, calcular posición basada en la hora
    return (hour - event.hour) * 60.0; // 60px por hora
  }

  /// Obtiene la altura del evento en la celda
  double getEventHeight(Event event, int hour) {
    if (!isEventAtHour(event, hour)) return 0.0;
    
    // Si es la última hora del evento, altura completa
    if (hour == event.hour + event.duration - 1) return 60.0;
    
    // Si no es la última hora, altura completa
    return 60.0;
  }
}
