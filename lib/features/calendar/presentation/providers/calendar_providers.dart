import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/services/logger_service.dart';
import '../../domain/models/calendar_state.dart';
import '../../domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import '../../domain/services/event_service.dart';
import '../../domain/services/plan_service.dart';
import '../notifiers/calendar_notifier.dart';

/// Provider para EventService
final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

/// Provider para PlanService
final planServiceProvider = Provider<PlanService>((ref) {
  return PlanService();
});

/// StreamProvider para todos los planes (actualización automática)
final plansStreamProvider = StreamProvider<List<Plan>>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final planService = ref.watch(planServiceProvider);

  if (!authState.isAuthenticated || authState.user == null) {
    return Stream.value(const <Plan>[]);
  }

  return planService.getPlansForUser(authState.user!.id);
});

/// StreamProvider para un plan específico por ID (T107: actualización automática cuando se expande)
final planByIdStreamProvider = StreamProvider.family<Plan?, String>((ref, planId) async* {
  final planService = ref.watch(planServiceProvider);
  // Escuchar cambios en todos los planes y filtrar por ID
  await for (final plans in planService.getPlans()) {
    try {
      final plan = plans.firstWhere((p) => p.id == planId);
      yield plan;
    } catch (e) {
      // Plan no encontrado
      yield null;
    }
  }
});

/// Provider para CalendarNotifier
final calendarNotifierProvider = StateNotifierProvider.family<CalendarNotifier, CalendarState, CalendarNotifierParams>(
  (ref, params) {
    ref.watch(authNotifierProvider);
    final eventService = ref.read(eventServiceProvider);
    
    return CalendarNotifier(
      planId: params.planId,
      userId: params.userId,
      eventService: eventService,
      initialDate: params.initialDate,
      initialColumnCount: params.initialColumnCount,
    );
  },
);

/// Parámetros para crear CalendarNotifier
class CalendarNotifierParams {
  final String planId;
  final String userId;
  final DateTime initialDate;
  final int initialColumnCount;

  const CalendarNotifierParams({
    required this.planId,
    required this.userId,
    required this.initialDate,
    this.initialColumnCount = 7,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarNotifierParams &&
        other.planId == planId &&
        other.userId == userId &&
        other.initialDate == initialDate &&
        other.initialColumnCount == initialColumnCount;
  }

  @override
  int get hashCode => Object.hash(planId, userId, initialDate, initialColumnCount);
}

/// Provider para el estado actual del calendario
final calendarStateProvider = Provider.family<CalendarState, CalendarNotifierParams>(
  (ref, params) {
    return ref.watch(calendarNotifierProvider(params));
  },
);

/// Provider para verificar si el calendario está cargando
final calendarLoadingProvider = Provider.family<bool, CalendarNotifierParams>(
  (ref, params) {
    final state = ref.watch(calendarStateProvider(params));
    return state.isLoading;
  },
);

/// Provider para verificar si hay errores en el calendario
final calendarErrorProvider = Provider.family<String?, CalendarNotifierParams>(
  (ref, params) {
    final state = ref.watch(calendarStateProvider(params));
    return state.errorMessage;
  },
);

/// Provider para verificar si hay operaciones pendientes
final calendarPendingOperationsProvider = Provider.family<bool, CalendarNotifierParams>(
  (ref, params) {
    final state = ref.watch(calendarStateProvider(params));
    return state.hasPendingOperations;
  },
);

/// Provider para verificar si se puede realizar una operación
final calendarCanPerformOperationProvider = Provider.family<bool, CalendarNotifierParams>(
  (ref, params) {
    final state = ref.watch(calendarStateProvider(params));
    return state.canPerformOperation;
  },
);

/// Provider para obtener eventos de una fecha específica
final eventsForDateProvider = Provider.family<List<Event>, EventsForDateParams>(
  (ref, params) {
    final calendarState = ref.watch(calendarStateProvider(params.calendarParams));
    return calendarState.getEventsForDate(params.date);
  },
);

/// Parámetros para obtener eventos de una fecha
class EventsForDateParams {
  final CalendarNotifierParams calendarParams;
  final DateTime date;

  const EventsForDateParams({
    required this.calendarParams,
    required this.date,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventsForDateParams &&
        other.calendarParams == calendarParams &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(calendarParams, date);
}

/// Provider para obtener eventos de una fecha y hora específica
final eventsForDateTimeProvider = Provider.family<List<Event>, EventsForDateTimeParams>(
  (ref, params) {
    final calendarState = ref.watch(calendarStateProvider(params.calendarParams));
    return calendarState.getEventsForDateTime(params.date, params.hour);
  },
);

/// Parámetros para obtener eventos de una fecha y hora
class EventsForDateTimeParams {
  final CalendarNotifierParams calendarParams;
  final DateTime date;
  final int hour;

  const EventsForDateTimeParams({
    required this.calendarParams,
    required this.date,
    required this.hour,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventsForDateTimeParams &&
        other.calendarParams == calendarParams &&
        other.date == date &&
        other.hour == hour;
  }

  @override
  int get hashCode => Object.hash(calendarParams, date, hour);
}

/// Provider para validar movimiento de evento
final validateMoveProvider = Provider.family<bool, ValidateMoveParams>(
  (ref, params) {
    final calendarState = ref.watch(calendarStateProvider(params.calendarParams));
    return calendarState.validateMove(params.event, params.targetDate, params.targetHour);
  },
);

/// Parámetros para validar movimiento
class ValidateMoveParams {
  final CalendarNotifierParams calendarParams;
  final Event event;
  final DateTime targetDate;
  final int targetHour;

  const ValidateMoveParams({
    required this.calendarParams,
    required this.event,
    required this.targetDate,
    required this.targetHour,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidateMoveParams &&
        other.calendarParams == calendarParams &&
        other.event == event &&
        other.targetDate == targetDate &&
        other.targetHour == targetHour;
  }

  @override
  int get hashCode => Object.hash(calendarParams, event, targetDate, targetHour);
}

/// Provider para validar resize de evento
final validateResizeProvider = Provider.family<bool, ValidateResizeParams>(
  (ref, params) {
    final calendarState = ref.watch(calendarStateProvider(params.calendarParams));
    return calendarState.validateResize(params.event, params.proposedDuration);
  },
);

/// Parámetros para validar resize
class ValidateResizeParams {
  final CalendarNotifierParams calendarParams;
  final Event event;
  final int proposedDuration;

  const ValidateResizeParams({
    required this.calendarParams,
    required this.event,
    required this.proposedDuration,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidateResizeParams &&
        other.calendarParams == calendarParams &&
        other.event == event &&
        other.proposedDuration == proposedDuration;
  }

  @override
  int get hashCode => Object.hash(calendarParams, event, proposedDuration);
}

/// Provider para obtener el alojamiento de un plan específico
final accommodationProvider = FutureProvider.family<String?, String>(
  (ref, planId) async {
    try {
      // Buscar en la colección de alojamiento usando el planId
      final accommodationDoc = await ref.read(planServiceProvider).getAccommodation(planId);
      if (accommodationDoc != null) {
        LoggerService.debug('Contenido del documento: $accommodationDoc', context: 'ACCOMMODATION_PROVIDER');
        LoggerService.debug('hotelName: ${accommodationDoc['hotelName']}', context: 'ACCOMMODATION_PROVIDER');
        LoggerService.debug('description: ${accommodationDoc['description']}', context: 'ACCOMMODATION_PROVIDER');
        
        final hotelName = accommodationDoc['hotelName'] as String?;
        final description = accommodationDoc['description'] as String?;
        
        final result = hotelName ?? description;
        
        return result;
      }
      return null;
    } catch (e) {
      LoggerService.error('Error al cargar alojamiento: $e', context: 'ACCOMMODATION_PROVIDER', error: e);
      return null;
    }
  },
);
