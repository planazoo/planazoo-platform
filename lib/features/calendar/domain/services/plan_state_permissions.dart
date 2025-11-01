import '../models/plan.dart';

/// Helper para verificar permisos de acciones según el estado del plan
/// 
/// Basado en FLUJO_ESTADOS_PLAN.md - Matriz de permisos por estado
class PlanStatePermissions {
  /// Verifica si se puede modificar fecha inicio/fin del plan
  static bool canModifyDates(Plan plan) {
    final state = plan.state ?? 'borrador';
    // Solo permitido en Borrador y Planificando
    return state == 'borrador' || state == 'planificando';
  }

  /// Verifica si se puede añadir eventos
  static bool canAddEvents(Plan plan) {
    final state = plan.state ?? 'borrador';
    // No permitido en Finalizado o Cancelado
    return state != 'finalizado' && state != 'cancelado';
  }

  /// Verifica si se puede eliminar eventos
  static bool canDeleteEvents(Plan plan) {
    final state = plan.state ?? 'borrador';
    // No permitido en Finalizado o Cancelado
    // En "En Curso" solo eventos futuros (lógica adicional necesaria)
    return state != 'finalizado' && state != 'cancelado';
  }

  /// Verifica si se puede modificar eventos
  static bool canModifyEvents(Plan plan) {
    final state = plan.state ?? 'borrador';
    // No permitido en Finalizado o Cancelado
    // En "Confirmado" y "En Curso" hay restricciones adicionales (lógica adicional necesaria)
    return state != 'finalizado' && state != 'cancelado';
  }

  /// Verifica si se puede añadir participantes
  static bool canAddParticipants(Plan plan) {
    final state = plan.state ?? 'borrador';
    // No permitido en Finalizado, Cancelado, o En Curso (solo excepciones)
    return state != 'finalizado' && 
           state != 'cancelado' && 
           state != 'en_curso';
  }

  /// Verifica si se puede eliminar participantes
  static bool canRemoveParticipants(Plan plan) {
    final state = plan.state ?? 'borrador';
    // No permitido en Finalizado, Cancelado, o En Curso (solo excepciones)
    return state != 'finalizado' && 
           state != 'cancelado' && 
           state != 'en_curso';
  }

  /// Verifica si se puede modificar presupuesto
  static bool canModifyBudget(Plan plan) {
    final state = plan.state ?? 'borrador';
    // No permitido en Finalizado, Cancelado, o En Curso
    // En "Confirmado" solo aumentos <50% (lógica adicional necesaria)
    return state != 'finalizado' && 
           state != 'cancelado' && 
           state != 'en_curso';
  }

  /// Verifica si se puede añadir fotos
  static bool canAddPhotos(Plan plan) {
    final state = plan.state ?? 'borrador';
    // Permitido en todos los estados
    return true;
  }

  /// Verifica si se puede exportar a PDF
  static bool canExportPdf(Plan plan) {
    final state = plan.state ?? 'borrador';
    // Permitido en todos los estados
    return true;
  }

  /// Verifica si se puede cancelar el plan
  static bool canCancelPlan(Plan plan) {
    final state = plan.state ?? 'borrador';
    // No se puede cancelar desde "En Curso" o estados finales
    return state != 'en_curso' && 
           state != 'finalizado' && 
           state != 'cancelado';
  }

  /// Verifica si el plan es de solo lectura
  static bool isReadOnly(Plan plan) {
    final state = plan.state ?? 'borrador';
    return state == 'finalizado' || state == 'cancelado';
  }

  /// Verifica si se puede editar información básica (nombre, descripción, etc.)
  static bool canEditBasicInfo(Plan plan) {
    final state = plan.state ?? 'borrador';
    // No permitido en Finalizado o Cancelado
    return state != 'finalizado' && state != 'cancelado';
  }

  /// Obtiene un mensaje explicativo de por qué una acción está bloqueada
  static String? getBlockedReason(String action, Plan plan) {
    final state = plan.state ?? 'borrador';
    
    // Caso especial para 'view' (solo lectura)
    if (action == 'view') {
      if (state == 'finalizado') {
        return 'Este plan está finalizado. Solo se permite visualización.';
      }
      if (state == 'cancelado') {
        return 'Este plan está cancelado. No se pueden realizar cambios.';
      }
      return null;
    }
    
    if (state == 'finalizado') {
      return 'Este plan está finalizado. Solo se permite visualización.';
    }
    
    if (state == 'cancelado') {
      return 'Este plan está cancelado. No se pueden realizar cambios.';
    }
    
    if (state == 'en_curso') {
      switch (action) {
        case 'modify_dates':
          return 'El plan está en curso. Las fechas no se pueden modificar.';
        case 'add_participants':
          return 'El plan está en curso. Solo se pueden añadir participantes en casos excepcionales.';
        case 'remove_participants':
          return 'El plan está en curso. Solo se pueden eliminar participantes en casos excepcionales.';
        case 'modify_budget':
          return 'El plan está en curso. El presupuesto no se puede modificar.';
      }
    }
    
    if (state == 'confirmado') {
      switch (action) {
        case 'modify_dates':
          return 'El plan está confirmado. Las fechas no se pueden modificar.';
      }
    }
    
    return null; // No hay razón específica, acción permitida
  }
}

