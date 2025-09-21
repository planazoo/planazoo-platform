import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/calendar_state.dart';
import '../../domain/models/event.dart';
import '../../domain/services/event_service.dart';


/// Notifier que maneja el estado del calendario y todas sus operaciones
class CalendarNotifier extends StateNotifier<CalendarState> {
  final EventService _eventService;
  final String planId;
  final String userId;
  
  StreamSubscription<List<Event>>? _eventsSubscription;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  CalendarNotifier({
    required this.planId,
    required this.userId,
    required EventService eventService,
    required DateTime initialDate,
    int initialColumnCount = 7,
  }) : _eventService = eventService,
       super(CalendarState.initial(
         selectedDate: initialDate,
         columnCount: initialColumnCount,
       )) {
    _initializeCalendar();
  }

  /// Inicializar el calendario
  Future<void> _initializeCalendar() async {
    await _loadEvents();
  }

  /// Cargar eventos con manejo robusto de errores
  Future<void> _loadEvents() async {
    if (state.loadingState == LoadingState.loading) return;

    state = state.copyWith(
      loadingState: LoadingState.loading,
      clearError: true,
    );

    try {
      // Cancelar suscripción anterior si existe
      _eventsSubscription?.cancel();
      
      // Crear nueva suscripción
      _eventsSubscription = _eventService.getEventsByPlanId(planId, userId).listen(
        (events) {
          if (state.loadingState != LoadingState.loading) return;
          
          state = state.copyWith(
            events: events,
            loadingState: LoadingState.success,
            lastSyncTime: DateTime.now(),
            clearError: true,
          );
          
          // Resetear contador de reintentos
          _retryCount = 0;
        },
        onError: (error) {
          _handleError('Error al cargar eventos: $error', _retryLoadEvents);
        },
      );
    } catch (e) {
      _handleError('Error al inicializar suscripción: $e', _retryLoadEvents);
    }
  }

  /// Reintentar carga de eventos
  Future<void> _retryLoadEvents() async {
    if (_retryCount >= _maxRetries) {
      _handleMaxRetriesExceeded('No se pudieron cargar los eventos después de $_maxRetries intentos');
      return;
    }

    _retryCount++;
    state = state.copyWith(
      errorMessage: 'Reintentando... ($_retryCount/$_maxRetries)',
    );

    _retryTimer = Timer(_retryDelay, () {
      _loadEvents();
    });
  }

  /// Manejar errores con retry automático
  void _handleError(String message, VoidCallback retryCallback) {
    state = state.copyWith(
      loadingState: LoadingState.error,
      errorMessage: message,
    );

    // Programar retry automático
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, retryCallback);
  }

  /// Manejar cuando se exceden los reintentos máximos
  void _handleMaxRetriesExceeded(String message) {
    state = state.copyWith(
      loadingState: LoadingState.error,
      errorMessage: message,
    );
    
    // Limpiar timer
    _retryTimer?.cancel();
  }

  /// Limpiar error manualmente
  void clearError() {
    state = state.copyWith(
      loadingState: LoadingState.idle,
      clearError: true,
    );
  }

  /// Cambiar fecha seleccionada
  void changeSelectedDate(DateTime newDate) {
    state = state.copyWith(
      selectedDate: newDate,
      hasUnsavedChanges: true,
    );
  }

  /// Agregar columna
  void addColumn() {
    state = state.copyWith(
      columnCount: state.columnCount + 1,
      hasUnsavedChanges: true,
    );
  }

  /// Remover columna
  void removeColumn() {
    if (state.columnCount > 1) {
      state = state.copyWith(
        columnCount: state.columnCount - 1,
        hasUnsavedChanges: true,
      );
    }
  }

  /// Crear evento
  Future<bool> createEvent(Event event) async {
    if (!state.canPerformOperation) return false;

    final operationId = _generateOperationId();
    
    // Asegurar que el evento tenga el userId correcto
    final eventWithUserId = event.userId.isEmpty ? event.copyWith(userId: userId) : event;
    
    // Actualización optimista: agregar al estado inmediatamente
    final updatedEvents = [...state.events, eventWithUserId];
    
    state = state.copyWith(
      events: updatedEvents,
      eventOperationState: EventOperationState.creating,
      currentOperationId: operationId,
      pendingOperations: {
        ...state.pendingOperations,
        operationId: {'type': 'create', 'event': eventWithUserId},
      },
    );

    try {
      final savedEvent = await _eventService.saveEvent(eventWithUserId);
      
      if (savedEvent != null) {
        // Actualizar el evento en el estado con el ID correcto
        final finalEvents = state.events.map((e) => 
          e.id == eventWithUserId.id ? savedEvent : e
        ).toList();
        
        state = state.copyWith(events: finalEvents);
        _clearOperation(operationId);
        return true;
      } else {
        // Rollback en caso de fallo
        final rollbackEvents = state.events.where((e) => e.id != eventWithUserId.id).toList();
        state = state.copyWith(events: rollbackEvents);
        _handleOperationError(operationId, 'Error al crear el evento');
        return false;
      }
    } catch (e) {
      // Rollback en caso de excepción
      final rollbackEvents = state.events.where((e) => e.id != eventWithUserId.id).toList();
      state = state.copyWith(events: rollbackEvents);
      _handleOperationError(operationId, 'Error inesperado: $e');
      return false;
    }
  }

  /// Actualizar evento
  Future<bool> updateEvent(Event event) async {
    if (!state.canPerformOperation) return false;

    final operationId = _generateOperationId();
    
    // Actualización optimista: actualizar el estado inmediatamente
    final updatedEvents = state.events.map((e) => e.id == event.id ? event : e).toList();
    
    state = state.copyWith(
      events: updatedEvents,
      eventOperationState: EventOperationState.updating,
      currentOperationId: operationId,
      pendingOperations: {
        ...state.pendingOperations,
        operationId: {'type': 'update', 'event': event},
      },
    );

    try {
      final savedEvent = await _eventService.saveEvent(event);
      
      if (savedEvent != null) {
        // Actualizar el evento en el estado con los datos actualizados
        final finalEvents = state.events.map((e) => 
          e.id == event.id ? savedEvent : e
        ).toList();
        
        state = state.copyWith(events: finalEvents);
        _clearOperation(operationId);
        return true;
      } else {
        // Rollback en caso de fallo
        final originalEvent = state.events.firstWhere((e) => e.id == event.id);
        final rollbackEvents = state.events.map((e) => e.id == event.id ? originalEvent : e).toList();
        state = state.copyWith(events: rollbackEvents);
        _handleOperationError(operationId, 'Error al actualizar el evento');
        return false;
      }
    } catch (e) {
      // Rollback en caso de excepción
      final originalEvent = state.events.firstWhere((e) => e.id == event.id);
      final rollbackEvents = state.events.map((e) => e.id == event.id ? originalEvent : e).toList();
      state = state.copyWith(events: rollbackEvents);
      _handleOperationError(operationId, 'Error inesperado: $e');
      return false;
    }
  }

  /// Eliminar evento
  Future<bool> deleteEvent(String eventId) async {
    if (!state.canPerformOperation) return false;

    final operationId = _generateOperationId();
    
    // Actualización optimista: eliminar del estado inmediatamente
    final eventToDelete = state.events.firstWhere((e) => e.id == eventId);
    final updatedEvents = state.events.where((e) => e.id != eventId).toList();
    
    state = state.copyWith(
      events: updatedEvents,
      eventOperationState: EventOperationState.deleting,
      currentOperationId: operationId,
      pendingOperations: {
        ...state.pendingOperations,
        operationId: {'type': 'delete', 'eventId': eventId, 'originalEvent': eventToDelete},
      },
    );

    try {
      final success = await _eventService.deleteEvent(eventId);
      
      if (success) {
        _clearOperation(operationId);
        return true;
      } else {
        // Rollback en caso de fallo
        final rollbackEvents = [...state.events, eventToDelete];
        state = state.copyWith(events: rollbackEvents);
        _handleOperationError(operationId, 'Error al eliminar el evento');
        return false;
      }
    } catch (e) {
      // Rollback en caso de excepción
      final rollbackEvents = [...state.events, eventToDelete];
      state = state.copyWith(events: rollbackEvents);
      _handleOperationError(operationId, 'Error inesperado: $e');
      return false;
    }
  }

  /// Mover evento
  Future<bool> moveEvent(Event event, DateTime newDate, int newHour) async {
    if (!state.canPerformOperation) return false;

    final operationId = _generateOperationId();
    
    // Actualización optimista: actualizar el estado inmediatamente
    final updatedEvent = event.copyWith(
      date: newDate,
      hour: newHour,
      updatedAt: DateTime.now(),
    );
    
    // Actualizar la lista de eventos en el estado local
    final updatedEvents = state.events.map((e) => e.id == event.id ? updatedEvent : e).toList();
    
    state = state.copyWith(
      events: updatedEvents,
      eventOperationState: EventOperationState.moving,
      currentOperationId: operationId,
      pendingOperations: {
        ...state.pendingOperations,
        operationId: {'type': 'move', 'event': event, 'newDate': newDate, 'newHour': newHour},
      },
    );

    try {
      final savedEvent = await _eventService.saveEvent(updatedEvent);
      
      if (savedEvent != null) {
        // Actualizar el evento en el estado con los datos actualizados
        final finalEvents = state.events.map((e) => 
          e.id == event.id ? savedEvent : e
        ).toList();
        
        state = state.copyWith(events: finalEvents);
        _clearOperation(operationId);
        return true;
      } else {
        // Rollback en caso de fallo
        final rollbackEvents = state.events.map((e) => e.id == event.id ? event : e).toList();
        state = state.copyWith(events: rollbackEvents);
        _handleOperationError(operationId, 'Error al mover el evento');
        return false;
      }
    } catch (e) {
      // Rollback en caso de excepción
      final rollbackEvents = state.events.map((e) => e.id == event.id ? event : e).toList();
      state = state.copyWith(events: rollbackEvents);
      _handleOperationError(operationId, 'Error inesperado: $e');
      return false;
    }
  }

  /// Redimensionar evento
  Future<bool> resizeEvent(Event event, int newDuration) async {
    if (!state.canPerformOperation) return false;

    final operationId = _generateOperationId();
    
    // Actualización optimista: actualizar el estado inmediatamente
    final updatedEvent = event.copyWith(
      duration: newDuration,
      updatedAt: DateTime.now(),
    );
    
    // Actualizar la lista de eventos en el estado local
    final updatedEvents = state.events.map((e) => e.id == event.id ? updatedEvent : e).toList();
    
    state = state.copyWith(
      events: updatedEvents,
      eventOperationState: EventOperationState.resizing,
      currentOperationId: operationId,
      pendingOperations: {
        ...state.pendingOperations,
        operationId: {'type': 'resize', 'event': event, 'newDuration': newDuration},
      },
    );

    try {
      final savedEvent = await _eventService.saveEvent(updatedEvent);
      
      if (savedEvent != null) {
        // Actualizar el evento en el estado con los datos actualizados
        final finalEvents = state.events.map((e) => 
          e.id == event.id ? savedEvent : e
        ).toList();
        
        state = state.copyWith(events: finalEvents);
        _clearOperation(operationId);
        return true;
      } else {
        // Rollback en caso de fallo
        final rollbackEvents = state.events.map((e) => e.id == event.id ? event : e).toList();
        state = state.copyWith(events: rollbackEvents);
        _handleOperationError(operationId, 'Error al redimensionar el evento');
        return false;
      }
    } catch (e) {
      // Rollback en caso de excepción
      final rollbackEvents = state.events.map((e) => e.id == event.id ? event : e).toList();
      state = state.copyWith(events: rollbackEvents);
      _handleOperationError(operationId, 'Error inesperado: $e');
      return false;
    }
  }

  /// Limpiar operación completada
  void _clearOperation(String operationId) {
    final newPendingOperations = Map<String, dynamic>.from(state.pendingOperations);
    newPendingOperations.remove(operationId);
    
    state = state.copyWith(
      eventOperationState: EventOperationState.idle,
      currentOperationId: null,
      pendingOperations: newPendingOperations,
    );
  }

  /// Manejar error en operación
  void _handleOperationError(String operationId, String errorMessage) {
    final newPendingOperations = Map<String, dynamic>.from(state.pendingOperations);
    newPendingOperations.remove(operationId);
    
    state = state.copyWith(
      eventOperationState: EventOperationState.idle,
      currentOperationId: null,
      pendingOperations: newPendingOperations,
      errorMessage: errorMessage,
    );
  }

  /// Generar ID único para operación
  String _generateOperationId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${state.pendingOperations.length}';
  }

  /// Reintentar operación fallida
  Future<bool> retryOperation(String operationId) async {
    final operation = state.pendingOperations[operationId];
    if (operation == null) return false;

    final type = operation['type'] as String;
    
    switch (type) {
      case 'create':
        return await createEvent(operation['event'] as Event);
      case 'update':
        return await updateEvent(operation['event'] as Event);
      case 'delete':
        return await deleteEvent(operation['eventId'] as String);
      case 'move':
        return await moveEvent(
          operation['event'] as Event,
          operation['newDate'] as DateTime,
          operation['newHour'] as int,
        );
      case 'resize':
        return await resizeEvent(
          operation['event'] as Event,
          operation['newDuration'] as int,
        );
      default:
        return false;
    }
  }

  /// Limpiar todas las operaciones pendientes
  void clearAllPendingOperations() {
    state = state.copyWith(
      clearPendingOperations: true,
      eventOperationState: EventOperationState.idle,
      currentOperationId: null,
    );
  }

  /// Guardar cambios del plan
  Future<bool> savePlanChanges() async {
    if (!state.hasUnsavedChanges) return true;

    try {
      // Aquí implementarías la lógica para guardar los cambios del plan
      // Por ahora solo simulamos el guardado
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(hasUnsavedChanges: false);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al guardar cambios: $e');
      return false;
    }
  }

  /// Refrescar eventos desde Firestore
  Future<void> refreshEvents() async {
    await _loadEvents();
  }

  /// Cambiar el estado de borrador de un evento
  Future<bool> toggleEventDraftStatus(Event event) async {
    if (event.id == null) return false;

    final operationId = _generateOperationId();
    final newIsDraft = !event.isDraft;
    
    // Agregar operación pendiente
    final newPendingOperations = Map<String, dynamic>.from(state.pendingOperations);
    newPendingOperations[operationId] = {
      'type': 'toggleDraft',
      'event': event,
      'newIsDraft': newIsDraft,
    };
    
    state = state.copyWith(
      eventOperationState: EventOperationState.loading,
      currentOperationId: operationId,
      pendingOperations: newPendingOperations,
      hasUnsavedChanges: true,
    );

    try {
      final success = await _eventService.toggleDraftStatus(event.id!, newIsDraft);
      
      if (success) {
        _clearOperation(operationId);
        return true;
      } else {
        _handleOperationError(operationId, 'Error al cambiar estado de borrador');
        return false;
      }
    } catch (e) {
      _handleOperationError(operationId, 'Error al cambiar estado de borrador: $e');
      return false;
    }
  }

  /// Confirmar un evento (cambiar de borrador a confirmado)
  Future<bool> confirmEvent(Event event) async {
    if (event.id == null || !event.isDraft) return false;
    return await toggleEventDraftStatus(event);
  }

  /// Marcar un evento como borrador
  Future<bool> markEventAsDraft(Event event) async {
    if (event.id == null || event.isDraft) return false;
    return await toggleEventDraftStatus(event);
  }

  /// Obtener solo eventos confirmados
  List<Event> get confirmedEvents {
    return state.events.where((event) => !event.isDraft).toList();
  }

  /// Obtener solo eventos en borrador
  List<Event> get draftEvents {
    return state.events.where((event) => event.isDraft).toList();
  }

  /// Obtener estadísticas de eventos
  Map<String, int> get eventStats {
    final total = state.events.length;
    final confirmed = confirmedEvents.length;
    final drafts = draftEvents.length;
    
    return {
      'total': total,
      'confirmed': confirmed,
      'drafts': drafts,
    };
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}
