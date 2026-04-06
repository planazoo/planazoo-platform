/// Constantes para el calendario
class CalendarConstants {
  // Alturas de filas
  static const double eventRowHeight = 54.0;
  static const double accommodationRowHeight = 30.0;
  static const double headerHeight = 40.0;
  /// Por debajo de esta duración (min), en calendario solo se muestra el título del evento.
  static const int shortEventTitleOnlyMaxMinutes = 45;
  static const double miniHeaderHeight = 20.0;
  
  // Anchos (columna de horas reducida en iOS/móvil para más espacio a los días)
  static const double hoursColumnWidth = 56.0;
  static const double lateralMargin = 16.0;

  /// Fracción del ancho de cada columna-día reservada a cada lado del contenido (eventos / tracks).
  /// Aumenta la separación visual entre días sin cambiar el grid.
  static const double dayColumnHorizontalInsetFraction = 0.04;
  
  // Opacidades
  static const double gridLineOpacity = 0.3;

  /// Línea vertical entre columnas (días / tracks): más visible (lista §3.2 ítem 100).
  static const double calendarVerticalSeparatorWidth = 1.0;
  static const double calendarSeparatorOpacityWeb = 0.55;
  static const double calendarSeparatorOpacityMobile = 0.38;
  static const double accommodationBackgroundOpacity = 0.3;
  static const double accommodationBorderOpacity = 0.5;
  
  // Tamaños de fuente (encabezados más grandes para mejor lectura en móvil)
  static const double headerFontSize = 17.0;
  static const double participantFontSize = 12.0;
  static const double miniParticipantFontSize = 10.0;
  static const double eventFontSize = 10.0;
  static const double accommodationFontSize = 8.0;
  
  // Márgenes y padding
  static const double defaultMargin = 2.0;
  static const double defaultPadding = 4.0;
  static const double borderRadius = 4.0;
  
  // Límites
  /// Límite superior para poder mostrar todo el plan en una vista (p. ej. 2–3 semanas).
  static const int maxVisibleDays = 45;
  static const int minVisibleDays = 1;
  static const int defaultVisibleDays = 7;
  
  // Colores de estado
  static const double todayHighlightOpacity = 0.1;
  static const double trackHighlightOpacity = 0.05;
}
