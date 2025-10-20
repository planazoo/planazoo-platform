import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';

/// Clase que maneja los estilos del calendario
class CalendarStyles {
  /// Obtiene el estilo del header de días
  static TextStyle getDayHeaderStyle({bool isToday = false}) {
    return TextStyle(
      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
      color: isToday ? AppColorScheme.color1 : Colors.black87,
      fontSize: CalendarConstants.headerFontSize,
    );
  }

  /// Obtiene el estilo del header de participantes
  static TextStyle getParticipantHeaderStyle() {
    return const TextStyle(
      fontSize: CalendarConstants.participantFontSize,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
  }

  /// Obtiene el estilo del header mini de participantes
  static TextStyle getMiniParticipantHeaderStyle() {
    return const TextStyle(
      fontSize: CalendarConstants.miniParticipantFontSize,
      fontWeight: FontWeight.w600,
      color: Colors.black54,
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
    return const TextStyle(fontSize: 12);
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
      color: AppColorScheme.color1.withOpacity(CalendarConstants.todayHighlightOpacity),
      border: Border(
        bottom: BorderSide(color: AppColorScheme.color1.withOpacity(CalendarConstants.gridLineOpacity)),
      ),
    );
  }

  /// Obtiene la decoración del header de participantes
  static BoxDecoration getParticipantHeaderDecoration() {
    return BoxDecoration(
      color: AppColorScheme.color1.withOpacity(CalendarConstants.trackHighlightOpacity),
      border: Border(
        bottom: BorderSide(color: AppColorScheme.color1.withOpacity(0.2)),
      ),
    );
  }

  /// Obtiene la decoración del header mini de participantes
  static BoxDecoration getMiniParticipantHeaderDecoration() {
    return BoxDecoration(
      color: AppColorScheme.color1.withOpacity(0.02),
      border: Border(
        bottom: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
      ),
    );
  }

  /// Obtiene la decoración de un evento
  static BoxDecoration getEventDecoration(Color eventColor) {
    return BoxDecoration(
      color: eventColor,
      borderRadius: BorderRadius.circular(CalendarConstants.borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(CalendarConstants.gridLineOpacity),
        width: 1,
      ),
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
      border: Border.all(color: AppColorScheme.gridLineColor),
      color: AppColorScheme.color1,
    );
  }

  /// Obtiene la decoración de una celda de hora
  static BoxDecoration getHourCellDecoration() {
    return BoxDecoration(
      border: Border.all(color: AppColorScheme.gridLineColor),
      color: AppColorScheme.color0,
    );
  }

  /// Obtiene la decoración de la fila fija de alojamientos
  static BoxDecoration getFixedAccommodationRowDecoration() {
    return BoxDecoration(
      color: AppColorScheme.color1.withOpacity(CalendarConstants.gridLineOpacity),
      border: Border.all(color: AppColorScheme.gridLineColor),
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
    return AppColorScheme.color1;
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
