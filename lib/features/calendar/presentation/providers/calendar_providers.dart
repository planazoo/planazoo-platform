import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/services/logger_service.dart';
import '../../domain/models/calendar_state.dart';
import '../../domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import '../../domain/services/event_service.dart';
import '../../domain/services/plan_service.dart';
import '../../domain/services/invitation_service.dart';
import 'invitation_providers.dart';
import 'plan_participation_providers.dart';
import '../notifiers/calendar_notifier.dart';

/// Provider para EventService
final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

/// Provider para PlanService (reutiliza InvitationService del provider)
final planServiceProvider = Provider<PlanService>((ref) {
  return PlanService(invitationService: ref.read(invitationServiceProvider));
});

/// StreamProvider para todos los planes (actualización automática)
/// Incluye planes donde el usuario es participante Y planes con invitaciones pendientes
final plansStreamProvider = StreamProvider<List<Plan>>((ref) async* {
  final authState = ref.watch(authNotifierProvider);
  final planService = ref.watch(planServiceProvider);
  final invitationService = ref.watch(invitationServiceProvider);

  if (!authState.isAuthenticated || authState.user == null) {
    yield const <Plan>[];
    return;
  }

  // Obtener planes donde el usuario es participante
  await for (final userPlans in planService.getPlansForUser(authState.user!.id)) {
    // Obtener planes con participaciones pendientes (userId) - método principal
    final participationService = ref.read(planParticipationServiceProvider);
    final participations = await participationService.getUserParticipations(authState.user!.id).first;
    final pendingParticipations = participations.where((p) => p.status == 'pending').toList();
    
    // Obtener planes de participaciones pendientes
    final pendingPlanIdsFromParticipations = pendingParticipations.map((p) => p.planId).toSet();
    final pendingPlans = <Plan>[];
    
    for (final planId in pendingPlanIdsFromParticipations) {
      try {
        final plan = await planService.getPlanById(planId);
        if (plan != null) {
          pendingPlans.add(plan);
        }
      } catch (e) {
        LoggerService.error(
          'Error getting plan for pending participation: $planId',
          context: 'PLANS_STREAM_PROVIDER',
          error: e,
        );
      }
    }
    
    // Si no hay participaciones pendientes, buscar invitaciones por email (primera vez)
    if (pendingPlans.isEmpty) {
      final pendingInvitations = await invitationService.getPendingInvitationsByUserId(
        authState.user!.id,
        authState.user!.email,
      );

      // Obtener planes de las invitaciones pendientes
      final pendingPlanIdsFromInvitations = pendingInvitations.map((inv) => inv.planId).toSet();
      
      for (final planId in pendingPlanIdsFromInvitations) {
        try {
          final plan = await planService.getPlanById(planId);
          if (plan != null && !pendingPlans.any((p) => p.id == planId)) {
            pendingPlans.add(plan);
          }
        } catch (e) {
          LoggerService.error(
            'Error getting plan for pending invitation: $planId',
            context: 'PLANS_STREAM_PROVIDER',
            error: e,
          );
        }
      }
    }

    // Combinar planes del usuario y planes con invitaciones pendientes
    // Usar un Map para evitar duplicados (si un plan tiene invitación pendiente pero ya es participante)
    final allPlansMap = <String, Plan>{};
    
    // Añadir planes del usuario
    for (final plan in userPlans) {
      if (plan.id != null) {
        allPlansMap[plan.id!] = plan;
      }
    }
    
    // Añadir planes con invitaciones pendientes (no sobrescribir si ya existe)
    for (final plan in pendingPlans) {
      if (plan.id != null && !allPlansMap.containsKey(plan.id!)) {
        allPlansMap[plan.id!] = plan;
      }
    }

    yield allPlansMap.values.toList();
  }
});

/// FutureProvider para un plan específico por ID
/// 
/// Usa getPlanById directamente en lugar de iterar todos los planes (más eficiente).
/// Nota: Si necesitas actualización en tiempo real, considera crear un StreamProvider
/// que escuche cambios en el documento específico de Firestore.
final planByIdStreamProvider = FutureProvider.family<Plan?, String>((ref, planId) async {
  final planService = ref.watch(planServiceProvider);
  try {
    return await planService.getPlanById(planId);
  } catch (e) {
    // Plan no encontrado o error
    LoggerService.error(
      'Error getting plan by ID: $planId',
      context: 'PLAN_BY_ID_PROVIDER',
      error: e,
    );
    return null;
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
