/// Constantes para el calendario
class CalendarConstants {
  // Alturas de filas
  static const double eventRowHeight = 54.0;
  static const double accommodationRowHeight = 30.0;
  /// Día + iniciales de participantes (fecha + mini-headers).
  static const double headerHeight = 52.0;
  /// Por debajo de esta duración (min), en calendario solo se muestra el título del evento.
  static const int shortEventTitleOnlyMaxMinutes = 45;
  static const double miniHeaderHeight = 18.0;
  
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
  /// Tope técnico histórico (validaciones); la UX web de «todo el plan» usa [singleScreenMaxVisibleDays].
  static const int maxVisibleDays = 45;
  static const int minVisibleDays = 1;
  /// Preset «7 días» y máximo de columnas en una sola pantalla (web).
  static const int defaultVisibleDays = 7;
  static const int singleScreenMaxVisibleDays = 7;

  /// True si el plan cabe entero en una pantalla (2…7 días).
  static bool canShowAllPlanDaysOnScreen(int planDurationDays) {
    return planDurationDays >= 2 &&
        planDurationDays <= singleScreenMaxVisibleDays;
  }

  /// Ajusta días visibles: no menos de 1, no más del plan ni del tope de pantalla.
  static int resolveVisibleDays(int requested, int planDurationDays) {
    final planDays = planDurationDays < 1 ? 1 : planDurationDays;
    final screenCap = planDays <= singleScreenMaxVisibleDays
        ? planDays
        : singleScreenMaxVisibleDays;
    var value = requested;
    if (value < minVisibleDays) value = minVisibleDays;
    if (value > screenCap) value = screenCap;
    return value;
  }
  
  // Colores de estado
  static const double todayHighlightOpacity = 0.1;
  static const double trackHighlightOpacity = 0.05;
}
