import 'package:flutter/material.dart';
import 'color_scheme.dart';

class AppTypography {
  // Tipografías según la propuesta del usuario
  static const String titleFont = 'Roboto';
  static const String bodyFont = 'Roboto';
  static const String interactiveFont = 'Open Sans';
  
  // Estilos de títulos
  static const TextStyle titleStyle = TextStyle(
    fontFamily: titleFont,
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
    color: AppColorScheme.titleColor,
  );
  
  // Estilos de cuerpo
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
    color: AppColorScheme.bodyColor,
  );
  
  // Estilos de texto interactivo
  static const TextStyle interactiveStyle = TextStyle(
    fontFamily: interactiveFont,
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: AppColorScheme.interactiveColor,
  );
  
  // Variaciones de tamaños
  static const TextStyle largeTitle = TextStyle(
    fontFamily: titleFont,
    fontWeight: FontWeight.bold,
    fontSize: 32.0,
    color: AppColorScheme.titleColor,
  );
  
  static const TextStyle mediumTitle = TextStyle(
    fontFamily: titleFont,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
    color: AppColorScheme.titleColor,
  );
  
  static const TextStyle smallBody = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
    color: AppColorScheme.bodyColor,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.normal,
    fontSize: 12.0,
    color: AppColorScheme.color4,
  );
}
