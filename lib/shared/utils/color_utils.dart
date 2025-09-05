import 'package:flutter/material.dart';

class ColorUtils {
  // Colores para eventos confirmados por tipo
  static const Map<String, Color> confirmedColors = {
    'transporte': Colors.blue,
    'alojamiento': Colors.green,
    'actividad': Colors.orange,
    'restauracion': Colors.red,
    'default': Colors.purple,
  };

  // Colores para eventos en borrador por tipo (versiones grises)
  static const Map<String, Color> draftColors = {
    'transporte': Color(0xFF9E9E9E), // Gris azulado
    'alojamiento': Color(0xFF8D8D8D), // Gris verdoso
    'actividad': Color(0xFFA0A0A0), // Gris anaranjado
    'restauracion': Color(0xFFB0B0B0), // Gris rojizo
    'default': Color(0xFF9A9A9A), // Gris púrpura
  };

  /// Obtiene el color para un evento basado en su tipo y estado
  static Color getEventColor(String? typeFamily, bool isDraft) {
    final type = typeFamily?.toLowerCase() ?? 'default';
    
    if (isDraft) {
      return draftColors[type] ?? draftColors['default']!;
    } else {
      return confirmedColors[type] ?? confirmedColors['default']!;
    }
  }

  /// Obtiene el color de fondo para un evento
  static Color getEventBackgroundColor(String? typeFamily, bool isDraft) {
    final baseColor = getEventColor(typeFamily, isDraft);
    return baseColor.withOpacity(0.2);
  }

  /// Obtiene el color del borde para un evento
  static Color getEventBorderColor(String? typeFamily, bool isDraft) {
    final baseColor = getEventColor(typeFamily, isDraft);
    return baseColor.withOpacity(0.5);
  }

  /// Obtiene el color del texto para un evento
  static Color getEventTextColor(String? typeFamily, bool isDraft) {
    final baseColor = getEventColor(typeFamily, isDraft);
    return isDraft ? Colors.grey.shade700 : baseColor;
  }
}
