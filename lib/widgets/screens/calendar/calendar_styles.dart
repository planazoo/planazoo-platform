import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';

/// Clase que maneja los estilos del calendario
///
/// Tokens alineados a [GUIA_UI.md]: fondo página, superficie, bordes y franjas
/// de la rejilla (sin grises Material ni `gridLineColor` claro heredado).
class CalendarStyles {
  // —— UI-SP (tokens base) ——
  static const Color cPageBg = Color(0xFF111827);
  static const Color cSurfaceBg = Color(0xFF1F2937);
  /// Franja de columna-día más clara (alterna por índice de columna **visible**: 0,2,4…).
  /// Ligeramente por encima de [cSurfaceBg] para contrastar el grid con tarjetas (opción B).
  static const Color cGridStripeLight = Color(0xFF303B4F);
  /// Franja alterna oscura de columna-día (índices impares en la vista).
  static const Color cGridStripeAlt = Color(0xFF182331);
  static const double aBorderStrong = 0.12;

  /// Borde estándar de celdas / líneas de rejilla (GUIA: blanco ~0.12).
  static Color get calendarGridLineColor =>
      Colors.white.withValues(alpha: aBorderStrong);

  /// Separador vertical entre días (móvil).
  static Color get calendarDaySeparatorMobile => Colors.white.withValues(
        alpha: CalendarConstants.calendarSeparatorOpacityMobile,
      );

  /// Separador vertical entre días (web).
  static Color get calendarDaySeparatorWeb => Colors.white.withValues(
        alpha: CalendarConstants.calendarSeparatorOpacityWeb,
      );

  /// Obtiene el estilo del header de días
  static TextStyle getDayHeaderStyle({bool isToday = false}) {
    return GoogleFonts.poppins(
      fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
      color: isToday
          ? AppColorScheme.color2
          : Colors.white,
      fontSize: CalendarConstants.headerFontSize,
    );
  }

  /// Obtiene el estilo del header de participantes
  static TextStyle getParticipantHeaderStyle() {
    return GoogleFonts.poppins(
      fontSize: CalendarConstants.participantFontSize,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
  }

  /// Obtiene el estilo del header mini de participantes
  static TextStyle getMiniParticipantHeaderStyle() {
    return GoogleFonts.poppins(
      fontSize: CalendarConstants.miniParticipantFontSize,
      fontWeight: FontWeight.w600,
      color: Colors.white70,
    );
  }

  /// Obtiene el estilo del texto de eventos
  static TextStyle getEventTextStyle() {
    return GoogleFonts.poppins(
      color: Colors.white,
      fontSize: CalendarConstants.eventFontSize,
      fontWeight: FontWeight.w500,
    );
  }

  /// Obtiene el estilo del texto de alojamientos
  static TextStyle getAccommodationTextStyle() {
    return GoogleFonts.poppins(
      color: Colors.white,
      fontSize: CalendarConstants.accommodationFontSize,
      fontWeight: FontWeight.w500,
    );
  }

  /// Obtiene el estilo del texto de horas
  static TextStyle getHourTextStyle() {
    return GoogleFonts.poppins(
      fontSize: 12,
      color: Colors.white70,
      fontWeight: FontWeight.w500,
    );
  }

  /// Obtiene el estilo del texto de alojamiento en la columna fija
  static TextStyle getFixedAccommodationTextStyle() {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      fontSize: CalendarConstants.participantFontSize,
      color: Colors.white,
    );
  }

  /// Obtiene la decoración del header de días (sin bordes, estilo limpio)
  static BoxDecoration getDayHeaderDecoration() {
    return const BoxDecoration(
      color: cSurfaceBg,
    );
  }

  /// Obtiene la decoración del header de participantes (sin bordes)
  static BoxDecoration getParticipantHeaderDecoration() {
    return const BoxDecoration(
      color: cSurfaceBg,
    );
  }

  /// Obtiene la decoración del header mini de participantes (sin bordes)
  static BoxDecoration getMiniParticipantHeaderDecoration() {
    return BoxDecoration(
      color: cSurfaceBg.withValues(alpha: 0.6),
    );
  }

  /// Obtiene la decoración de un evento
  static BoxDecoration getEventDecoration(Color eventColor) {
    return BoxDecoration(
      color: eventColor,
      borderRadius: BorderRadius.circular(CalendarConstants.borderRadius),
      // Sin borde (estilo base)
    );
  }

  /// Obtiene la decoración de un alojamiento
  static BoxDecoration getAccommodationDecoration() {
    final fill = AppColorScheme.color2.withValues(
      alpha: CalendarConstants.accommodationBackgroundOpacity,
    );
    final stroke = AppColorScheme.color2.withValues(
      alpha: CalendarConstants.accommodationBorderOpacity,
    );
    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(3),
      border: Border.all(
        color: stroke,
        width: 1,
      ),
    );
  }

  /// Obtiene la decoración de la columna fija de horas (sin bordes)
  static BoxDecoration getFixedHoursColumnDecoration() {
    return const BoxDecoration(
      color: cSurfaceBg,
    );
  }

  /// Obtiene la decoración de una celda de hora
  static BoxDecoration getHourCellDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: calendarGridLineColor,
        width: 0.5,
      ),
      color: cSurfaceBg,
    );
  }

  /// Obtiene la decoración de la fila fija de alojamientos (sin bordes)
  static BoxDecoration getFixedAccommodationRowDecoration() {
    return const BoxDecoration(
      color: cSurfaceBg,
    );
  }

  /// Obtiene el margen para eventos
  static EdgeInsets getEventMargin() {
    return const EdgeInsets.all(CalendarConstants.defaultMargin);
  }

  /// Obtiene el margen para alojamientos
  static EdgeInsets getAccommodationMargin() {
    return const EdgeInsets.symmetric(horizontal: CalendarConstants.defaultMargin);
  }

  /// Obtiene el padding para horas
  static EdgeInsets getHourPadding() {
    return const EdgeInsets.only(top: CalendarConstants.defaultPadding);
  }

  /// Obtiene el color de fondo del AppBar
  static Color getAppBarBackgroundColor() {
    return cSurfaceBg;
  }

  /// Obtiene el color de texto del AppBar
  static Color getAppBarForegroundColor() {
    return Colors.white;
  }

  /// Obtiene la altura del AppBar
  static double getAppBarHeight() {
    return 48.0;
  }

  /// Obtiene el color de los iconos del AppBar
  static Color getAppBarIconColor() {
    return Colors.white;
  }
}
