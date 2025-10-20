import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

/// Clase con utilidades y cálculos para el calendario
class CalendarUtils {
  /// Calcula el ancho de una subcolumna (track de participante)
  static double getSubColumnWidth(double availableWidth, int trackCount) {
    if (trackCount == 0) return 0;
    return availableWidth / trackCount;
  }

  /// Calcula el ancho de un día
  static double getDayWidth(double availableWidth, int visibleDays) {
    return availableWidth / visibleDays;
  }

  /// Calcula el ancho disponible para el contenido
  static double getAvailableWidth(BuildContext context) {
    return MediaQuery.of(context).size.width - 16.0; // Margen lateral
  }

  /// Verifica si un día está en el rango visible
  static bool isDayInRange(int dayNumber, int currentDayGroup, int visibleDays, int totalDays) {
    final startDay = currentDayGroup * visibleDays + 1;
    final endDay = startDay + visibleDays - 1;
    return dayNumber >= startDay && dayNumber <= endDay && dayNumber <= totalDays;
  }

  /// Calcula el número de día basado en el índice
  static int getDayNumber(int dayIndex, int currentDayGroup, int visibleDays) {
    return currentDayGroup * visibleDays + dayIndex + 1;
  }

  /// Verifica si es el día actual
  static bool isToday(int dayNumber) {
    return dayNumber == DateTime.now().day;
  }

  /// Obtiene las iniciales de un nombre
  static String getInitials(String name) {
    return name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').join('');
  }

  /// Calcula la posición de un track basado en su posición
  static double getTrackPosition(ParticipantTrack track, double subColumnWidth) {
    return track.position * subColumnWidth;
  }

  /// Verifica si un track está visible
  static bool isTrackVisible(ParticipantTrack track) {
    return track.isVisible;
  }

  /// Obtiene el color de un track
  static Color getTrackColor(ParticipantTrack track) {
    if (track.customColor is Color) {
      return track.customColor as Color;
    }
    return AppColorScheme.color1;
  }

  /// Calcula la altura de una fila de eventos
  static double getEventRowHeight() {
    return 60.0;
  }

  /// Calcula la altura de una fila de alojamientos
  static double getAccommodationRowHeight() {
    return 30.0;
  }

  /// Calcula la altura del header
  static double getHeaderHeight() {
    return 40.0;
  }

  /// Calcula la altura del header mini
  static double getMiniHeaderHeight() {
    return 20.0;
  }

  /// Obtiene el color de la línea de la cuadrícula
  static Color getGridLineColor() {
    return AppColorScheme.gridLineColor;
  }

  /// Crea un borde para la cuadrícula
  static Border createGridBorder({Color? color}) {
    return Border.all(color: color ?? getGridLineColor());
  }

  /// Crea una decoración con borde
  static BoxDecoration createBorderedDecoration({
    Color? color,
    Color? borderColor,
    double borderRadius = 0,
  }) {
    return BoxDecoration(
      color: color,
      border: createGridBorder(color: borderColor),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Formatea una hora para mostrar
  static String formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  /// Calcula el margen para centrar contenido
  static EdgeInsets getCenteredMargin() {
    return const EdgeInsets.all(2);
  }

  /// Obtiene el estilo de texto para headers
  static TextStyle getHeaderTextStyle({bool isToday = false}) {
    return TextStyle(
      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
      color: isToday ? AppColorScheme.color1 : Colors.black87,
      fontSize: 14,
    );
  }

  /// Obtiene el estilo de texto para participantes
  static TextStyle getParticipantTextStyle() {
    return const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
  }

  /// Obtiene el estilo de texto para participantes mini
  static TextStyle getMiniParticipantTextStyle() {
    return const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w600,
      color: Colors.black54,
    );
  }

  /// Obtiene el estilo de texto para eventos
  static TextStyle getEventTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
  }

  /// Obtiene el estilo de texto para alojamientos
  static TextStyle getAccommodationTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 8,
      fontWeight: FontWeight.w500,
    );
  }
}
