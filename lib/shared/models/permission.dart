/// Permisos específicos del sistema
enum Permission {
  // ============ PERMISOS DE PLAN ============
  /// Ver información del plan
  planView,
  
  /// Editar información del plan
  planEdit,
  
  /// Eliminar el plan
  planDelete,
  
  /// Gestionar participantes del plan
  planManageParticipants,
  
  /// Gestionar admins del plan
  planManageAdmins,

  // ============ PERMISOS DE EVENTOS ============
  /// Ver eventos del plan
  eventView,
  
  /// Crear eventos
  eventCreate,
  
  /// Editar eventos propios
  eventEditOwn,
  
  /// Editar cualquier evento
  eventEditAny,
  
  /// Eliminar eventos propios
  eventDeleteOwn,
  
  /// Eliminar cualquier evento
  eventDeleteAny,
  
  /// Ver información personal de otros en eventos
  eventViewOthersPersonal,
  
  /// Editar información personal de otros en eventos
  eventEditOthersPersonal,

  // ============ PERMISOS DE ALOJAMIENTOS ============
  /// Ver alojamientos del plan
  accommodationView,
  
  /// Crear alojamientos
  accommodationCreate,
  
  /// Editar alojamientos propios
  accommodationEditOwn,
  
  /// Editar cualquier alojamiento
  accommodationEditAny,
  
  /// Eliminar alojamientos propios
  accommodationDeleteOwn,
  
  /// Eliminar cualquier alojamiento
  accommodationDeleteAny,

  // ============ PERMISOS DE TRACKS ============
  /// Ver tracks del plan
  trackView,
  
  /// Reordenar tracks
  trackReorder,
  
  /// Gestionar visibilidad de tracks
  trackManageVisibility,

  // ============ PERMISOS DE FILTROS ============
  /// Usar filtros de vista
  filterUse,
  
  /// Guardar filtros personalizados
  filterSaveCustom,
}

extension PermissionExtension on Permission {
  /// Nombre legible del permiso
  String get displayName {
    switch (this) {
      // Plan
      case Permission.planView:
        return 'Ver plan';
      case Permission.planEdit:
        return 'Editar plan';
      case Permission.planDelete:
        return 'Eliminar plan';
      case Permission.planManageParticipants:
        return 'Gestionar participantes';
      case Permission.planManageAdmins:
        return 'Gestionar administradores';
      
      // Eventos
      case Permission.eventView:
        return 'Ver eventos';
      case Permission.eventCreate:
        return 'Crear eventos';
      case Permission.eventEditOwn:
        return 'Editar eventos propios';
      case Permission.eventEditAny:
        return 'Editar cualquier evento';
      case Permission.eventDeleteOwn:
        return 'Eliminar eventos propios';
      case Permission.eventDeleteAny:
        return 'Eliminar cualquier evento';
      case Permission.eventViewOthersPersonal:
        return 'Ver información personal de otros';
      case Permission.eventEditOthersPersonal:
        return 'Editar información personal de otros';
      
      // Alojamientos
      case Permission.accommodationView:
        return 'Ver alojamientos';
      case Permission.accommodationCreate:
        return 'Crear alojamientos';
      case Permission.accommodationEditOwn:
        return 'Editar alojamientos propios';
      case Permission.accommodationEditAny:
        return 'Editar cualquier alojamiento';
      case Permission.accommodationDeleteOwn:
        return 'Eliminar alojamientos propios';
      case Permission.accommodationDeleteAny:
        return 'Eliminar cualquier alojamiento';
      
      // Tracks
      case Permission.trackView:
        return 'Ver tracks';
      case Permission.trackReorder:
        return 'Reordenar tracks';
      case Permission.trackManageVisibility:
        return 'Gestionar visibilidad de tracks';
      
      // Filtros
      case Permission.filterUse:
        return 'Usar filtros';
      case Permission.filterSaveCustom:
        return 'Guardar filtros personalizados';
    }
  }

  /// Descripción detallada del permiso
  String get description {
    switch (this) {
      // Plan
      case Permission.planView:
        return 'Permite ver la información básica del plan';
      case Permission.planEdit:
        return 'Permite modificar la información del plan';
      case Permission.planDelete:
        return 'Permite eliminar completamente el plan';
      case Permission.planManageParticipants:
        return 'Permite añadir, quitar y gestionar participantes';
      case Permission.planManageAdmins:
        return 'Permite asignar y quitar administradores';
      
      // Eventos
      case Permission.eventView:
        return 'Permite ver los eventos del plan';
      case Permission.eventCreate:
        return 'Permite crear nuevos eventos';
      case Permission.eventEditOwn:
        return 'Permite editar eventos creados por el usuario';
      case Permission.eventEditAny:
        return 'Permite editar cualquier evento del plan';
      case Permission.eventDeleteOwn:
        return 'Permite eliminar eventos creados por el usuario';
      case Permission.eventDeleteAny:
        return 'Permite eliminar cualquier evento del plan';
      case Permission.eventViewOthersPersonal:
        return 'Permite ver la información personal de otros en eventos';
      case Permission.eventEditOthersPersonal:
        return 'Permite editar la información personal de otros en eventos';
      
      // Alojamientos
      case Permission.accommodationView:
        return 'Permite ver los alojamientos del plan';
      case Permission.accommodationCreate:
        return 'Permite crear nuevos alojamientos';
      case Permission.accommodationEditOwn:
        return 'Permite editar alojamientos creados por el usuario';
      case Permission.accommodationEditAny:
        return 'Permite editar cualquier alojamiento del plan';
      case Permission.accommodationDeleteOwn:
        return 'Permite eliminar alojamientos creados por el usuario';
      case Permission.accommodationDeleteAny:
        return 'Permite eliminar cualquier alojamiento del plan';
      
      // Tracks
      case Permission.trackView:
        return 'Permite ver los tracks de participantes';
      case Permission.trackReorder:
        return 'Permite cambiar el orden de los tracks';
      case Permission.trackManageVisibility:
        return 'Permite mostrar/ocultar tracks';
      
      // Filtros
      case Permission.filterUse:
        return 'Permite usar filtros de vista del calendario';
      case Permission.filterSaveCustom:
        return 'Permite guardar filtros personalizados';
    }
  }

  /// Categoría del permiso para agrupación
  String get category {
    switch (this) {
      case Permission.planView:
      case Permission.planEdit:
      case Permission.planDelete:
      case Permission.planManageParticipants:
      case Permission.planManageAdmins:
        return 'Plan';
      
      case Permission.eventView:
      case Permission.eventCreate:
      case Permission.eventEditOwn:
      case Permission.eventEditAny:
      case Permission.eventDeleteOwn:
      case Permission.eventDeleteAny:
      case Permission.eventViewOthersPersonal:
      case Permission.eventEditOthersPersonal:
        return 'Eventos';
      
      case Permission.accommodationView:
      case Permission.accommodationCreate:
      case Permission.accommodationEditOwn:
      case Permission.accommodationEditAny:
      case Permission.accommodationDeleteOwn:
      case Permission.accommodationDeleteAny:
        return 'Alojamientos';
      
      case Permission.trackView:
      case Permission.trackReorder:
      case Permission.trackManageVisibility:
        return 'Tracks';
      
      case Permission.filterUse:
      case Permission.filterSaveCustom:
        return 'Filtros';
    }
  }

  /// Convierte el permiso a string para almacenamiento
  String toStorageString() {
    return name;
  }

  /// Crea un permiso desde string de almacenamiento
  static Permission fromStorageString(String value) {
    return Permission.values.firstWhere(
      (permission) => permission.name == value,
      orElse: () => Permission.eventView, // Default seguro
    );
  }
}
