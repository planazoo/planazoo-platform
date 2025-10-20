/// Enum que define los diferentes modos de vista del calendario
enum CalendarViewMode {
  /// Muestra todos los participantes
  all,
  
  /// Muestra solo el usuario actual
  personal,
  
  /// Muestra participantes seleccionados personalmente
  custom,
}

/// Extensión para obtener información de display del modo de vista
extension CalendarViewModeExtension on CalendarViewMode {
  /// Nombre para mostrar en la UI
  String get displayName {
    switch (this) {
      case CalendarViewMode.all:
        return 'Plan Completo';
      case CalendarViewMode.personal:
        return 'Mi Agenda';
      case CalendarViewMode.custom:
        return 'Personalizada';
    }
  }
  
  /// Icono para mostrar en la UI
  String get iconName {
    switch (this) {
      case CalendarViewMode.all:
        return 'calendar_view_day';
      case CalendarViewMode.personal:
        return 'person';
      case CalendarViewMode.custom:
        return 'filter_list';
    }
  }
}
