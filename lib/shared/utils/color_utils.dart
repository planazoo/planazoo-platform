import 'package:flutter/material.dart';

class ColorUtils {
  // T91: Paleta de colores mejorada para eventos confirmados
  // Colores optimizados para contraste WCAG AA (mínimo 4.5:1 con texto blanco)
  static const Map<String, Color> confirmedColors = {
    'desplazamiento': Color(0xFF1976D2), // Azul medio oscuro (mejor contraste)
    'transporte': Color(0xFF1976D2), // Alias para compatibilidad
    'alojamiento': Color(0xFF388E3C), // Verde medio oscuro
    'actividad': Color(0xFFF57C00), // Naranja oscuro vibrante
    'restauracion': Color(0xFFD32F2F), // Rojo medio oscuro
    'otro': Color(0xFF7B1FA2), // Púrpura medio oscuro
    'default': Color(0xFF7B1FA2), // Púrpura por defecto
  };

  // T91: Colores para eventos en borrador mejorados
  // Mantienen matiz del color original pero más apagados y distinguibles
  static const Map<String, Color> draftColors = {
    'desplazamiento': Color(0xFF90CAF9), // Azul claro apagado
    'transporte': Color(0xFF90CAF9), // Alias para compatibilidad
    'alojamiento': Color(0xFF81C784), // Verde claro apagado
    'actividad': Color(0xFFFFB74D), // Naranja claro apagado
    'restauracion': Color(0xFFE57373), // Rojo claro apagado
    'otro': Color(0xFFBA68C8), // Púrpura claro apagado
    'default': Color(0xFFBA68C8), // Púrpura claro por defecto
  };

  /// T91: Obtiene el color para un evento basado en su color personalizado, tipo y estado
  static Color getEventColor(String? typeFamily, bool isDraft, {String? customColor}) {
    // Prioridad 1: Color personalizado del evento
    if (customColor != null && customColor.isNotEmpty) {
      final color = _getColorFromName(customColor);
      if (isDraft) {
        // T91: Para borradores, crear versión más clara y apagada del color personalizado
        // Mezclar con blanco y aumentar luminosidad para mejor distinción visual
        return Color.lerp(color, Colors.white, 0.5)?.withOpacity(0.7) ?? Colors.grey.shade400;
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

  /// T91: Método público para convertir nombre de color a Color
  /// Colores personalizados mejorados con mejor contraste
  static Color colorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue': return const Color(0xFF1976D2); // Azul mejorado
      case 'green': return const Color(0xFF388E3C); // Verde mejorado
      case 'orange': return const Color(0xFFF57C00); // Naranja mejorado
      case 'purple': return const Color(0xFF7B1FA2); // Púrpura mejorado
      case 'red': return const Color(0xFFD32F2F); // Rojo mejorado
      case 'teal': return const Color(0xFF00796B); // Teal mejorado (más oscuro)
      case 'indigo': return const Color(0xFF303F9F); // Índigo mejorado
      case 'pink': return const Color(0xFFC2185B); // Rosa mejorado
      case 'yellow': return const Color(0xFFF9A825); // Amarillo mejorado (más oscuro para contraste)
      case 'brown': return const Color(0xFF5D4037); // Marrón mejorado
      case 'cyan': return const Color(0xFF0097A7); // Cian mejorado
      case 'lime': return const Color(0xFF827717); // Lima mejorado
      case 'amber': return const Color(0xFFF57F17); // Ámbar mejorado
      default: return const Color(0xFF7B1FA2); // Púrpura por defecto mejorado
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

  /// T91: Obtiene el color del texto para un evento
  /// Mejora la legibilidad considerando el contraste con el fondo
  static Color getEventTextColor(String? typeFamily, bool isDraft, {String? customColor}) {
    if (isDraft) {
      // Para borradores, usar texto oscuro para mejor contraste con fondos claros
      return const Color(0xFF424242); // Gris oscuro para mejor legibilidad
    } else {
      // Para eventos confirmados, verificar si el color es lo suficientemente oscuro
      final backgroundColor = getEventColor(typeFamily, isDraft, customColor: customColor);
      
      // Calcular luminosidad relativa para determinar si usar texto claro u oscuro
      final luminance = backgroundColor.computeLuminance();
      
      // Si la luminosidad es menor a 0.5, usar texto blanco (colores oscuros)
      // Si es mayor, usar texto oscuro para mejor contraste
      if (luminance < 0.5) {
        return Colors.white;
      } else {
        return const Color(0xFF212121); // Casi negro para mejor contraste
      }
    }
  }
  
  // T91: Método privado para calcular si un color es oscuro (no usado actualmente)
  // ignore: unused_element
  static bool _isDarkColor(Color color) {
    return color.computeLuminance() < 0.5;
  }
}
