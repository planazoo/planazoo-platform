import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Esquema de colores personalizado
      colorScheme: ColorScheme.light(
        primary: AppColorScheme.color2,
        secondary: AppColorScheme.color3,
        surface: AppColorScheme.color0,
        onPrimary: AppColorScheme.color0,
        onSecondary: AppColorScheme.color0,
        onSurface: AppColorScheme.color4,
      ),
      
      // Tipografías
      textTheme: TextTheme(
        displayLarge: AppTypography.largeTitle,
        displayMedium: AppTypography.titleStyle,
        displaySmall: AppTypography.mediumTitle,
        headlineLarge: AppTypography.titleStyle,
        headlineMedium: AppTypography.mediumTitle,
        headlineSmall: AppTypography.mediumTitle,
        titleLarge: AppTypography.titleStyle,
        titleMedium: AppTypography.mediumTitle,
        titleSmall: AppTypography.mediumTitle,
        bodyLarge: AppTypography.bodyStyle,
        bodyMedium: AppTypography.bodyStyle,
        bodySmall: AppTypography.smallBody,
        labelLarge: AppTypography.interactiveStyle,
        labelMedium: AppTypography.interactiveStyle,
        labelSmall: AppTypography.caption,
      ),
      
      // Tema de AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColorScheme.color1,
        foregroundColor: AppColorScheme.color4,
        titleTextStyle: AppTypography.titleStyle,
      ),
      
      // Tema de botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.color3,
          foregroundColor: AppColorScheme.color0,
          textStyle: AppTypography.interactiveStyle,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Tema de tarjetas
      cardTheme: CardThemeData(
        color: AppColorScheme.color0,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      useMaterial3: true,
    );
  }
} 