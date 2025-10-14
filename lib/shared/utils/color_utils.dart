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

  /// Obtiene el color para un evento basado en su color personalizado, tipo y estado
  static Color getEventColor(String? typeFamily, bool isDraft, {String? customColor}) {
    // Prioridad 1: Color personalizado del evento
    if (customColor != null && customColor.isNotEmpty) {
      final color = _getColorFromName(customColor);
      if (isDraft) {
        // Si es borrador, aplicar gris sobre el color personalizado
        return Color.lerp(color, Colors.grey, 0.6) ?? Colors.grey;
      }
      return color;
    }
    
    // Prioridad 2: Color por tipo de familia
    final type = typeFamily?.toLowerCase() ?? 'default';
    
    if (isDraft) {
      return draftColors[type] ?? draftColors['default']!;
    } else {
      return confirmedColors[type] ?? confirmedColors['default']!;
    }
  }
  
  /// Convierte nombre de color a Color de Flutter
  static Color _getColorFromName(String colorName) {
    return colorFromName(colorName);
  }

  /// Método público para convertir nombre de color a Color
  static Color colorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'red': return Colors.red;
      case 'teal': return Colors.teal;
      case 'indigo': return Colors.indigo;
      case 'pink': return Colors.pink;
      case 'yellow': return Colors.yellow;
      case 'brown': return Colors.brown;
      default: return Colors.purple;
    }
  }

  /// Obtiene el color de fondo para un evento
  static Color getEventBackgroundColor(String? typeFamily, bool isDraft, {String? customColor}) {
    final baseColor = getEventColor(typeFamily, isDraft, customColor: customColor);
    return baseColor.withValues(alpha: 0.2);
  }

  /// Obtiene el color del borde para un evento
  static Color getEventBorderColor(String? typeFamily, bool isDraft, {String? customColor}) {
    final baseColor = getEventColor(typeFamily, isDraft, customColor: customColor);
    return baseColor.withValues(alpha: 0.5);
  }

  /// Obtiene el color del texto para un evento
  static Color getEventTextColor(String? typeFamily, bool isDraft, {String? customColor}) {
    if (isDraft) {
      return Colors.grey.shade700; // Texto gris para borradores
    } else {
      return Colors.white; // Texto blanco para eventos confirmados
    }
  }
}
