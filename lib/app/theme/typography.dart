import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_scheme.dart';

class AppTypography {
  // Tipografía: Noto Sans (igual que Google Calendar)
  // Usando Google Fonts para cargar Noto Sans
  
  // Helper method para obtener Noto Sans con fallback
  static TextStyle _notoSans({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    try {
      return GoogleFonts.notoSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } catch (e) {
      // Fallback a texto estándar si GoogleFonts falla
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }
  
  // Estilos de títulos
  static TextStyle get titleStyle => _notoSans(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.titleColor,
  );
  
  // Estilos de cuerpo
  static TextStyle get bodyStyle => _notoSans(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.bodyColor,
  );
  
  // Estilos de texto interactivo
  static TextStyle get interactiveStyle => _notoSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.interactiveColor,
  );
  
  // Variaciones de tamaños
  static TextStyle get largeTitle => _notoSans(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.titleColor,
  );
  
  static TextStyle get mediumTitle => _notoSans(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.titleColor,
  );
  
  static TextStyle get smallBody => _notoSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.bodyColor,
  );
  
  static TextStyle get caption => _notoSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.color4,
  );
}
