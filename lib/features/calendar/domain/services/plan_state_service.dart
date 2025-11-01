import 'package:flutter/material.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/plan.dart';
import 'plan_service.dart';
import 'event_service.dart';
import 'plan_participation_service.dart';

/// Resultado de validación de transición
class ValidationResult {
  final bool allowed;
  final String? reason;

  ValidationResult({required this.allowed, this.reason});
}

/// Servicio para gestionar transiciones de estado de planes
/// 
/// Valida transiciones según FLUJO_ESTADOS_PLAN.md y gestiona
/// los cambios de estado con sus validaciones correspondientes.
class PlanStateService {
  final PlanService _planService;
  final EventService _eventService;
  final PlanParticipationService _participationService;

  PlanStateService({
    PlanService? planService,
    EventService? eventService,
    PlanParticipationService? participationService,
  })  : _planService = planService ?? PlanService(),
        _eventService = eventService ?? EventService(),
        _participationService = participationService ?? PlanParticipationService();

  /// Estados válidos según FLUJO_ESTADOS_PLAN.md
  static const List<String> validStates = [
    'borrador',
    'planificando',
    'confirmado',
    'en_curso',
    'finalizado',
    'cancelado',
  ];

  /// Valida si una transición de estado es válida
  /// 
  /// Retorna `true` si la transición es válida según el flujo definido.
  bool isValidTransition(String currentState, String newState) {
    if (!validStates.contains(currentState) || !validStates.contains(newState)) {
      return false;
    }

    // Mismo estado (permitido)
    if (currentState == newState) return true;

    // Transiciones válidas según FLUJO_ESTADOS_PLAN.md
    switch (currentState) {
      case 'borrador':
        // Borrador → Planificando (automático al guardar)
        // Borrador → Cancelado
        return newState == 'planificando' || newState == 'cancelado';

      case 'planificando':
        // Planificando → Confirmado (manual)
        // Planificando → Cancelado
        return newState == 'confirmado' || newState == 'cancelado';

      case 'confirmado':
        // Confirmado → En Curso (automático o manual)
        // Confirmado → Cancelado
        // Confirmado → Planificando (raro, pero permitido con confirmación)
        return newState == 'en_curso' ||
            newState == 'cancelado' ||
            newState == 'planificando';

      case 'en_curso':
        // En Curso → Finalizado (automático o manual)
        // En Curso NO puede ir a Cancelado (usar Finalizar)
        return newState == 'finalizado';

      case 'finalizado':
        // Finalizado es terminal, no puede cambiar
        return false;

      case 'cancelado':
        // Cancelado es terminal, no puede cambiar
        return false;

      default:
        return false;
    }
  }

  /// Verifica si el usuario es organizador del plan
  Future<bool> _isPlanOwner(String planId, String userId) async {
    try {
      final plan = await _planService.getPlanById(planId);
      return plan?.userId == userId;
    } catch (e) {
      LoggerService.error('Error checking plan ownership', 
          context: 'PLAN_STATE_SERVICE', error: e);
      return false;
    }
  }

  /// Cambia el estado de un plan
  /// 
  /// Valida la transición, permisos y ejecuta el cambio.
  /// Retorna `true` si el cambio fue exitoso.
  Future<bool> changePlanState({
    required String planId,
    required String newState,
    required String userId,
    bool skipValidation = false,
  }) async {
    try {
      // Obtener plan actual
      final plan = await _planService.getPlanById(planId);
      if (plan == null) {
        LoggerService.error('Plan not found: $planId', 
            context: 'PLAN_STATE_SERVICE');
        return false;
      }

      final currentState = plan.state ?? 'borrador';

      // Validar transición
      if (!skipValidation && !isValidTransition(currentState, newState)) {
        LoggerService.warning(
            'Invalid state transition: $currentState → $newState for plan $planId');
        return false;
      }

      // Verificar permisos: solo organizador puede cambiar estados
      // (excepto transiciones automáticas)
      if (!skipValidation && !await _isPlanOwner(planId, userId)) {
        LoggerService.warning(
            'User $userId is not owner of plan $planId, cannot change state');
        return false;
      }

      // Validaciones previas según el estado destino
      if (!skipValidation) {
        final validationResult = await _validateStateTransition(
          plan: plan,
          newState: newState,
        );
        if (!validationResult.allowed) {
          LoggerService.warning(
              'State transition validation failed: ${validationResult.reason}');
          throw Exception(validationResult.reason);
        }
      }

      // Actualizar estado
      final updatedPlan = plan.copyWith(
        state: newState,
        updatedAt: DateTime.now(),
      );

      final success = await _planService.updatePlan(updatedPlan);
      if (success) {
        LoggerService.database(
            'Plan state changed: $planId from $currentState to $newState',
            operation: 'UPDATE');
      }

      return success;
    } catch (e) {
      LoggerService.error('Error changing plan state: $planId to $newState',
          context: 'PLAN_STATE_SERVICE', error: e);
      rethrow;
    }
  }

  /// Valida que se cumplen las condiciones para cambiar de estado
  Future<ValidationResult> _validateStateTransition({
    required Plan plan,
    required String newState,
  }) async {
    switch (newState) {
      case 'planificando':
        // Borrador → Planificando: siempre permitido
        return ValidationResult(allowed: true);

      case 'confirmado':
        // Planificando → Confirmado: validaciones opcionales
        // (pueden hacerse más estrictas en el futuro)
        return ValidationResult(allowed: true);

      case 'en_curso':
        // Confirmado → En Curso: debe estar en fecha inicio o después
        final now = DateTime.now();
        if (plan.startDate.isAfter(now)) {
          // Todavía no es la fecha de inicio, pero se puede forzar manualmente
          return ValidationResult(allowed: true);
        }
        return ValidationResult(allowed: true);

      case 'finalizado':
        // En Curso → Finalizado: debe estar en fecha fin o después
        final now = DateTime.now();
        if (plan.endDate.isAfter(now)) {
          // Todavía no es la fecha de fin, pero se puede forzar manualmente
          return ValidationResult(allowed: true);
        }
        return ValidationResult(allowed: true);

      case 'cancelado':
        // Cualquier estado → Cancelado: siempre permitido para organizador
        // Pero NO desde "En Curso"
        if (plan.state == 'en_curso') {
          return ValidationResult(
              allowed: false,
              reason: 'No se puede cancelar un plan que está en curso. Usa "Finalizar" en su lugar.');
        }
        return ValidationResult(allowed: true);

      default:
        return ValidationResult(allowed: true);
    }
  }

  /// Transición automática: Borrador → Planificando
  /// 
  /// Se ejecuta automáticamente cuando se guarda un plan por primera vez.
  Future<bool> transitionToPlanningIfDraft({
    required String planId,
  }) async {
    try {
      final plan = await _planService.getPlanById(planId);
      if (plan == null) return false;

      // Solo transicionar si está en borrador
      if (plan.state == 'borrador') {
        return await changePlanState(
          planId: planId,
          newState: 'planificando',
          userId: plan.userId,
          skipValidation: true, // Transición automática, saltar validación de permisos
        );
      }

      return true; // Ya está en otro estado, no hacer nada
    } catch (e) {
      LoggerService.error('Error in auto-transition to planning: $planId',
          context: 'PLAN_STATE_SERVICE', error: e);
      return false;
    }
  }

  /// Verifica y ejecuta transiciones automáticas basadas en fechas
  /// 
  /// - Confirmado → En Curso: si fecha inicio ya pasó
  /// - En Curso → Finalizado: si fecha fin ya pasó
  /// 
  /// Retorna `true` si se realizó una transición, `false` si no hubo cambios
  Future<bool> checkAndExecuteAutomaticTransitions({
    required String planId,
  }) async {
    try {
      final plan = await _planService.getPlanById(planId);
      if (plan == null) return false;

      final now = DateTime.now();
      final currentState = plan.state ?? 'borrador';

      // Confirmado → En Curso (automático)
      if (currentState == 'confirmado' && 
          (plan.startDate.isBefore(now) || 
           plan.startDate.isAtSameMomentAs(now))) {
        final changed = await changePlanState(
          planId: planId,
          newState: 'en_curso',
          userId: plan.userId,
          skipValidation: true,
        );
        if (changed) return true;
      }

      // En Curso → Finalizado (automático)
      if (currentState == 'en_curso' && 
          (plan.endDate.isBefore(now) || 
           plan.endDate.isAtSameMomentAs(now))) {
        final changed = await changePlanState(
          planId: planId,
          newState: 'finalizado',
          userId: plan.userId,
          skipValidation: true,
        );
        if (changed) return true;
      }

      return false; // No hubo transiciones automáticas
    } catch (e) {
      LoggerService.error('Error checking automatic transitions: $planId',
          context: 'PLAN_STATE_SERVICE', error: e);
      return false;
    }
  }

  /// Obtiene el estado de visualización para el badge
  /// 
  /// Retorna un mapa con: label, color, icon
  static Map<String, dynamic> getStateDisplayInfo(String? state) {
    final normalizedState = state ?? 'borrador';

    switch (normalizedState) {
      case 'borrador':
        return {
          'label': 'BORRADOR',
          'color': 0xFF9E9E9E, // Grey
          'icon': Icons.edit_outlined,
        };

      case 'planificando':
        return {
          'label': 'PLANIFICANDO',
          'color': 0xFF2196F3, // Blue
          'icon': Icons.event_note,
        };

      case 'confirmado':
        return {
          'label': 'CONFIRMADO',
          'color': 0xFF4CAF50, // Green
          'icon': Icons.check_circle_outline,
        };

      case 'en_curso':
        return {
          'label': 'EN CURSO',
          'color': 0xFFFF9800, // Orange
          'icon': Icons.play_circle_outline,
        };

      case 'finalizado':
        return {
          'label': 'FINALIZADO',
          'color': 0xFF607D8B, // Blue Grey
          'icon': Icons.check_circle,
        };

      case 'cancelado':
        return {
          'label': 'CANCELADO',
          'color': 0xFFF44336, // Red
          'icon': Icons.cancel_outlined,
        };

      default:
        return {
          'label': 'DESCONOCIDO',
          'color': 0xFF9E9E9E,
          'icon': Icons.help_outline,
        };
    }
  }
}

