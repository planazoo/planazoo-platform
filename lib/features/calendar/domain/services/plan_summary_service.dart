import 'package:intl/intl.dart';
import '../models/plan.dart';
import '../models/event.dart';
import '../models/accommodation.dart';
import '../models/plan_participation.dart';
import '../../../auth/domain/services/user_service.dart';
import 'event_service.dart';
import 'accommodation_service.dart';
import 'plan_participation_service.dart';

/// T193: Genera el resumen en texto de un plan (cabecera + listado cronológico por día).
class PlanSummaryService {
  final EventService _eventService = EventService();
  final AccommodationService _accommodationService = AccommodationService();
  final PlanParticipationService _participationService = PlanParticipationService();
  final UserService _userService = UserService();

  static final _dateFormat = DateFormat('d/M/yyyy');
  static final _dateFormatLong = DateFormat('EEEE d MMMM yyyy', 'es_ES');
  static const _sinEventosSinAlojamiento = 'Sin eventos, sin alojamiento.';

  static DateTime _toDate(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Genera el texto del resumen del plan. Requiere [userId] para permisos de lectura de eventos.
  Future<String> generatePlanSummaryText(Plan plan, String userId) async {
    final planId = plan.id!;

    // Cargar participaciones, eventos y alojamientos en paralelo
    final results = await Future.wait([
      _participationService.getPlanParticipations(planId).first,
      _eventService.getEventsByPlanId(planId, userId).first.then(
            (list) => list.where((e) => e.typeFamily != 'alojamiento').toList(),
          ).catchError((_) => <Event>[]),
      _accommodationService.getAccommodations(planId).first.catchError((_) => <Accommodation>[]),
    ]);
    final participations = results[0] as List<PlanParticipation>;
    final events = results[1] as List<Event>;
    final accommodations = results[2] as List<Accommodation>;

    // Resolver usuarios en paralelo (evita N consultas secuenciales)
    final users = await Future.wait(
      participations.map((p) => _userService.getUser(p.userId)),
    );

    final buffer = StringBuffer();

    // Cabecera
    buffer.writeln(plan.name);
    buffer.writeln();
    buffer.writeln('Fechas: ${_dateFormat.format(plan.startDate)} - ${_dateFormat.format(plan.endDate)}');
    buffer.writeln();

    // Participantes
    buffer.writeln('Participantes (${participations.length}):');
    if (participations.isEmpty) {
      buffer.writeln('  (ninguno)');
    } else {
      for (var i = 0; i < participations.length; i++) {
        final p = participations[i];
        final user = i < users.length ? users[i] : null;
        final displayName = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : (user?.email ?? 'Usuario');
        final userLabel = user != null
            ? (user.username != null && user.username!.isNotEmpty ? '@${user.username}' : user.email)
            : p.userId;
        buffer.writeln('  - $displayName ($userLabel)${p.role != 'participant' ? ' [${p.role}]' : ''}');
      }
    }
    buffer.writeln();

    // Agrupar eventos y alojamientos por día (una sola pasada)
    final eventsByDay = <DateTime, List<Event>>{};
    for (final e in events) {
      final key = _toDate(e.date);
      eventsByDay.putIfAbsent(key, () => []).add(e);
    }
    final start = _toDate(plan.startDate);
    final end = _toDate(plan.endDate);
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      buffer.writeln(_dateFormatLong.format(d));
      final dayEvents = eventsByDay[d] ?? [];
      final dayAccommodations = accommodations.where((a) {
        final checkIn = _toDate(a.checkIn);
        final checkOut = _toDate(a.checkOut);
        return !d.isBefore(checkIn) && !d.isAfter(checkOut);
      }).toList();

      if (dayEvents.isEmpty && dayAccommodations.isEmpty) {
        buffer.writeln('  $_sinEventosSinAlojamiento');
      } else {
        for (final e in dayEvents) {
          final time = '${e.hour.toString().padLeft(2, '0')}:${e.startMinute.toString().padLeft(2, '0')}';
          buffer.writeln('  - $time ${e.description}');
        }
        for (final a in dayAccommodations) {
          buffer.writeln('  - Alojamiento: ${a.hotelName}');
        }
      }
      buffer.writeln();
    }

    return buffer.toString().trim();
  }
}
