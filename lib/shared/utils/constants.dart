class AppConstants {
  // Constantes del calendario
  static const double cellHeight = 45.0; // ~10% menos que 50 (slot hora calendario)
  static const double minCellHeightForTwoLines = 45.0; // alineado con cellHeight
  static const double firstColumnWidth = 56.0; // ancho de la columna fija de horas (reducido para móvil)
  static const double lodgingBandHeight = 14.4; // altura de la banda de alojamiento bajo encabezados (20% más alta)
  
  // Constantes de columnas y filas
  static const int defaultColumnCount = 7; // número de columnas por defecto (7 días)
  static const int defaultRowCount = 24; // número de filas por defecto (24 horas)
  
  // Date picker constants
  static const int minYear = 2020;
  static const int maxYear = 2030;
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
} 