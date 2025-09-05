import 'package:flutter/foundation.dart';
import 'event.dart';

/// Estado de carga para diferentes operaciones del calendario
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// Estado específico para operaciones de eventos
enum EventOperationState {
  idle,
  loading,
  creating,
  updating,
  deleting,
  moving,
  resizing,
}

/// Estado del calendario que maneja toda la lógica de negocio
@immutable
class CalendarState {
  final List<Event> events;
  final LoadingState loadingState;
  final String? errorMessage;
  final EventOperationState eventOperationState;
  final String? currentOperationId;
  final Map<String, dynamic> pendingOperations;
  final DateTime selectedDate;
  final int columnCount;
  final bool hasUnsavedChanges;
  final DateTime? lastSyncTime;

  const CalendarState({
    required this.events,
    required this.loadingState,
    this.errorMessage,
    required this.eventOperationState,
    this.currentOperationId,
    required this.pendingOperations,
    required this.selectedDate,
    required this.columnCount,
    required this.hasUnsavedChanges,
    this.lastSyncTime,
  });

  /// Estado inicial del calendario
  factory CalendarState.initial({
    required DateTime selectedDate,
    int columnCount = 7,
  }) {
    return CalendarState(
      events: [],
      loadingState: LoadingState.idle,
      eventOperationState: EventOperationState.idle,
      pendingOperations: {},
      selectedDate: selectedDate,
      columnCount: columnCount,
      hasUnsavedChanges: false,
    );
  }

  /// Copiar con cambios
  CalendarState copyWith({
    List<Event>? events,
    LoadingState? loadingState,
    String? errorMessage,
    EventOperationState? eventOperationState,
    String? currentOperationId,
    Map<String, dynamic>? pendingOperations,
    DateTime? selectedDate,
    int? columnCount,
    bool? hasUnsavedChanges,
    DateTime? lastSyncTime,
    bool clearError = false,
    bool clearPendingOperations = false,
  }) {
    return CalendarState(
      events: events ?? this.events,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      eventOperationState: eventOperationState ?? this.eventOperationState,
      currentOperationId: currentOperationId ?? this.currentOperationId,
      pendingOperations: clearPendingOperations 
          ? {} 
          : (pendingOperations ?? this.pendingOperations),
      selectedDate: selectedDate ?? this.selectedDate,
      columnCount: columnCount ?? this.columnCount,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  /// Verificar si hay operaciones pendientes
  bool get hasPendingOperations => pendingOperations.isNotEmpty;

  /// Verificar si está cargando algo
  bool get isLoading => loadingState == LoadingState.loading;

  /// Verificar si hay un error
  bool get hasError => errorMessage != null;

  /// Verificar si se puede realizar una operación
  bool get canPerformOperation => 
      eventOperationState == EventOperationState.idle && 
      !isLoading;

  /// Obtener eventos para una fecha específica
  List<Event> getEventsForDate(DateTime date) {
    return events.where((event) => 
        event.date.year == date.year &&
        event.date.month == date.month &&
        event.date.day == date.day
    ).toList();
  }

  /// Obtener eventos para una fecha y hora específica
  List<Event> getEventsForDateTime(DateTime date, int hour) {
    return events.where((event) => 
        event.date.year == date.year &&
        event.date.month == date.month &&
        event.date.day == date.day &&
        event.hour == hour
    ).toList();
  }

  /// Verificar si hay conflictos de horarios (para validaciones)
  bool hasTimeConflict(Event event, DateTime targetDate, int targetHour) {
    // Permitir eventos solapados - no hay conflictos de horarios
    return false;
  }

  /// Validar movimiento de evento
  bool validateMove(Event event, DateTime targetDate, int targetHour) {
    // Validar que la fecha sea válida (no en el pasado muy lejano)
    final now = DateTime.now();
    final minDate = DateTime(now.year - 1, now.month, now.day);
    if (targetDate.isBefore(minDate)) {
      return false;
    }
    
    // Validar que la hora esté en el rango válido (0-23)
    if (targetHour < 0 || targetHour > 23) {
      return false;
    }
    
    // Validar que la duración del evento no exceda el día
    if (targetHour + event.duration > 24) {
      return false;
    }
    
    // Permitir eventos solapados - no hay conflictos de horarios
    return true;
  }

  /// Validar resize de evento
  bool validateResize(Event event, int proposedDuration) {
    // Permitir eventos solapados - no hay conflictos de horarios
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarState &&
        listEquals(other.events, events) &&
        other.loadingState == loadingState &&
        other.errorMessage == errorMessage &&
        other.eventOperationState == eventOperationState &&
        other.currentOperationId == currentOperationId &&
        mapEquals(other.pendingOperations, pendingOperations) &&
        other.selectedDate == selectedDate &&
        other.columnCount == columnCount &&
        other.hasUnsavedChanges == hasUnsavedChanges &&
        other.lastSyncTime == lastSyncTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(events),
      loadingState,
      errorMessage,
      eventOperationState,
      currentOperationId,
      Object.hashAll(pendingOperations.entries),
      selectedDate,
      columnCount,
      hasUnsavedChanges,
      lastSyncTime,
    );
  }

  @override
  String toString() {
    return 'CalendarState(events: ${events.length}, loadingState: $loadingState, errorMessage: $errorMessage, eventOperationState: $eventOperationState, pendingOperations: ${pendingOperations.length})';
  }
}
