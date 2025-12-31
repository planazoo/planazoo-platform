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

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      // Esquema de colores personalizado para modo oscuro
      colorScheme: ColorScheme.dark(
        primary: AppColorScheme.color2,
        secondary: AppColorScheme.color3,
        surface: Colors.grey.shade900,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      
      // Tipografías
      textTheme: TextTheme(
        displayLarge: AppTypography.largeTitle.copyWith(color: Colors.white),
        displayMedium: AppTypography.titleStyle.copyWith(color: Colors.white),
        displaySmall: AppTypography.mediumTitle.copyWith(color: Colors.white),
        headlineLarge: AppTypography.titleStyle.copyWith(color: Colors.white),
        headlineMedium: AppTypography.mediumTitle.copyWith(color: Colors.white),
        headlineSmall: AppTypography.mediumTitle.copyWith(color: Colors.white),
        titleLarge: AppTypography.titleStyle.copyWith(color: Colors.white),
        titleMedium: AppTypography.mediumTitle.copyWith(color: Colors.white),
        titleSmall: AppTypography.mediumTitle.copyWith(color: Colors.white),
        bodyLarge: AppTypography.bodyStyle.copyWith(color: Colors.white),
        bodyMedium: AppTypography.bodyStyle.copyWith(color: Colors.white),
        bodySmall: AppTypography.smallBody.copyWith(color: Colors.grey.shade400),
        labelLarge: AppTypography.interactiveStyle.copyWith(color: Colors.white),
        labelMedium: AppTypography.interactiveStyle.copyWith(color: Colors.white),
        labelSmall: AppTypography.caption.copyWith(color: Colors.grey.shade400),
      ),
      
      // Tema de AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
        titleTextStyle: AppTypography.titleStyle.copyWith(color: Colors.white),
      ),
      
      // Tema de botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.color3,
          foregroundColor: Colors.white,
          textStyle: AppTypography.interactiveStyle.copyWith(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Tema de tarjetas
      cardTheme: CardThemeData(
        color: Colors.grey.shade800,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      useMaterial3: true,
    );
  }
} 