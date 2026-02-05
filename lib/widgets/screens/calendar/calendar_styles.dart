import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';

/// Clase que maneja los estilos del calendario
class CalendarStyles {
  /// Obtiene el estilo del header de días
  static TextStyle getDayHeaderStyle({bool isToday = false}) {
    return GoogleFonts.poppins(
      fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
      color: isToday ? AppColorScheme.color2 : Colors.white,
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
      color: Colors.grey.shade400,
    );
  }

  /// Obtiene el estilo del texto de eventos
  static TextStyle getEventTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: CalendarConstants.eventFontSize,
      fontWeight: FontWeight.w500,
    );
  }

  /// Obtiene el estilo del texto de alojamientos
  static TextStyle getAccommodationTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: CalendarConstants.accommodationFontSize,
      fontWeight: FontWeight.w500,
    );
  }

  /// Obtiene el estilo del texto de horas
  static TextStyle getHourTextStyle() {
    return GoogleFonts.poppins(
      fontSize: 12,
      color: Colors.grey.shade400,
      fontWeight: FontWeight.w500,
    );
  }

  /// Obtiene el estilo del texto de alojamiento en la columna fija
  static TextStyle getFixedAccommodationTextStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold, 
      fontSize: CalendarConstants.participantFontSize,
    );
  }

  /// Obtiene la decoración del header de días
  static BoxDecoration getDayHeaderDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade800, // Color sólido, sin gradiente
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade700.withOpacity(CalendarConstants.gridLineOpacity),
          width: 0.5,
        ),
      ),
    );
  }

  /// Obtiene la decoración del header de participantes
  static BoxDecoration getParticipantHeaderDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade800, // Color sólido, sin gradiente
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade700.withOpacity(0.3),
          width: 0.5,
        ),
      ),
    );
  }

  /// Obtiene la decoración del header mini de participantes
  static BoxDecoration getMiniParticipantHeaderDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade800.withOpacity(0.5), // Color sólido, sin gradiente
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade700.withOpacity(0.2),
          width: 0.5,
        ),
      ),
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
    return BoxDecoration(
      color: Colors.green.withOpacity(CalendarConstants.accommodationBackgroundOpacity),
      borderRadius: BorderRadius.circular(3),
      border: Border.all(
        color: Colors.green.withOpacity(CalendarConstants.accommodationBorderOpacity),
        width: 1,
      ),
    );
  }

  /// Obtiene la decoración de la columna fija de horas
  static BoxDecoration getFixedHoursColumnDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade800, // Color sólido, sin gradiente
      border: Border.all(
        color: Colors.grey.shade700.withOpacity(0.3),
        width: 0.5,
      ),
    );
  }

  /// Obtiene la decoración de una celda de hora
  static BoxDecoration getHourCellDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Colors.grey.shade700.withOpacity(0.3),
        width: 0.5,
      ),
      color: Colors.grey.shade800.withOpacity(0.3),
    );
  }

  /// Obtiene la decoración de la fila fija de alojamientos
  static BoxDecoration getFixedAccommodationRowDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade800, // Color sólido, sin gradiente
      border: Border.all(
        color: Colors.grey.shade700.withOpacity(0.3),
        width: 0.5,
      ),
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
    return Colors.grey.shade800;
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
