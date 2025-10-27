import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_scheme.dart';

class AppTypography {
  // Tipografía: Noto Sans (igual que Google Calendar)
  // Usando Google Fonts para cargar Noto Sans
  
  // Estilos de títulos
  static TextStyle get titleStyle => GoogleFonts.notoSans(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.titleColor,
  );
  
  // Estilos de cuerpo
  static TextStyle get bodyStyle => GoogleFonts.notoSans(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.bodyColor,
  );
  
  // Estilos de texto interactivo
  static TextStyle get interactiveStyle => GoogleFonts.notoSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.interactiveColor,
  );
  
  // Variaciones de tamaños
  static TextStyle get largeTitle => GoogleFonts.notoSans(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.titleColor,
  );
  
  static TextStyle get mediumTitle => GoogleFonts.notoSans(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.titleColor,
  );
  
  static TextStyle get smallBody => GoogleFonts.notoSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.bodyColor,
  );
  
  static TextStyle get caption => GoogleFonts.notoSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.color4,
  );
}
