import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Presentación de un evento como en Mi resumen (icono, hora, título, badges).
class PlanSummaryEventLook {
  PlanSummaryEventLook._();

  static bool isPast(Event e, DateTime now) {
    final eventDay = DateTime(e.date.year, e.date.month, e.date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (eventDay.isBefore(today)) return true;
    if (eventDay.isAfter(today)) return false;
    final startMin = e.hour * 60 + e.startMinute;
    final endMin =
        e.durationMinutes > 0 ? startMin + e.durationMinutes : startMin;
    final nowMin = now.hour * 60 + now.minute;
    return endMin < nowMin;
  }

  static IconData typeIcon(Event e) {
    final sub = (e.typeSubtype ?? '').toLowerCase();
    final fam = (e.typeFamily ?? '').toLowerCase();
    if (sub.contains('avión') ||
        sub.contains('avion') ||
        sub.contains('vuelo')) {
      return Icons.flight;
    }
    if (sub.contains('taxi') || sub.contains('coche') || sub.contains('car')) {
      return Icons.directions_car;
    }
    if (sub.contains('tren') || sub.contains('train')) {
      return Icons.train;
    }
    if (sub.contains('hotel') || sub.contains('alojamiento')) {
      return Icons.hotel;
    }
    if (sub.contains('comida') ||
        sub.contains('restaurant') ||
        sub.contains('restauración')) {
      return Icons.restaurant;
    }
    if (sub.contains('museo')) {
      return Icons.museum;
    }
    if (fam.contains('desplazamiento')) {
      return Icons.directions_car;
    }
    if (fam.contains('restauración') || fam.contains('restauracion')) {
      return Icons.restaurant;
    }
    if (fam.contains('actividad')) {
      return Icons.event;
    }
    return Icons.event;
  }

  static String formatEventTime(Event e, AppLocalizations loc) {
    final startH = e.hour.toString().padLeft(2, '0');
    final startM = e.startMinute.toString().padLeft(2, '0');
    final startStr = '$startH:$startM';
    if (e.durationMinutes <= 0) return startStr;
    const dayMin = 24 * 60;
    final endTotal = e.totalEndMinutes;
    if (endTotal < dayMin) {
      final endH = e.endHour.toString().padLeft(2, '0');
      final endM = e.endMinute.toString().padLeft(2, '0');
      return '$startStr–$endH:$endM';
    }
    final rem = endTotal % dayMin;
    final endH = (rem ~/ 60).toString().padLeft(2, '0');
    final endM = (rem % 60).toString().padLeft(2, '0');
    return '$startStr–$endH:$endM${loc.myPlanSummaryTimeNextDaySuffix}';
  }

  static String? transportCodeLabel(Event e) {
    final ed = e.commonPart?.extraData;
    if (ed == null) return null;
    for (final key in ['flightNumber', 'trainNumber', 'transportNumber']) {
      final v = ed[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  static String chronologicalTitle(Event e) {
    final c = transportCodeLabel(e);
    return c != null ? '$c · ${e.description}' : e.description;
  }

  static bool isDisplacement(Event e) {
    final fam = (e.typeFamily ?? '').toLowerCase();
    return fam.contains('desplazamiento') || fam.contains('desplaz');
  }

  static bool isDining(Event e) {
    final fam = (e.typeFamily ?? '').toLowerCase();
    final sub = (e.typeSubtype ?? '').toLowerCase();
    return fam.contains('restauración') ||
        fam.contains('restauracion') ||
        sub.contains('comida') ||
        sub.contains('restaurant') ||
        sub.contains('restauración') ||
        sub.contains('restauracion');
  }

  static ({IconData icon, String tooltip})? inlineTypeBadge(
    Event e,
    AppLocalizations loc,
  ) {
    if (isDisplacement(e)) {
      return (icon: typeIcon(e), tooltip: loc.myPlanSummaryFlights);
    }
    if (isDining(e)) {
      return (
        icon: Icons.restaurant,
        tooltip: loc.planEventColorsFamilyRestauracion,
      );
    }
    return null;
  }
}
