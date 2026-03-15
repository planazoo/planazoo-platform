import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// T252: Vista "Mi resumen" / "Mi itinerario" para participantes del plan.
/// Muestra: lo más importante del plan, hoy/mañana, accesos rápidos (vuelos, alojamiento), lista cronológica.
class MyPlanSummaryScreen extends ConsumerStatefulWidget {
  final Plan plan;
  /// Al pulsar un evento en el resumen, abrir su detalle (p. ej. EventDialog).
  final void Function(Event event)? onOpenEvent;
  /// Al pulsar un alojamiento en el resumen, abrir su detalle (p. ej. AccommodationDialog).
  final void Function(Accommodation accommodation)? onOpenAccommodation;
  /// Cuando el resumen está vacío, CTA "Ir al calendario" (p. ej. cambiar a pestaña Calendario).
  final VoidCallback? onGoToCalendar;

  const MyPlanSummaryScreen({
    super.key,
    required this.plan,
    this.onOpenEvent,
    this.onOpenAccommodation,
    this.onGoToCalendar,
  });

  @override
  ConsumerState<MyPlanSummaryScreen> createState() => _MyPlanSummaryScreenState();
}

class _MyPlanSummaryScreenState extends ConsumerState<MyPlanSummaryScreen> {
  static const int _chronoLimit = 15;
  bool _chronoExpanded = false;
  bool _importantExpanded = true;
  bool _todayExpanded = true;
  bool _tomorrowExpanded = true;
  /// 'mine' = solo mis eventos; 'plan' = todos los participantes.
  String _viewMode = 'mine';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final planId = widget.plan.id ?? '';
    final eventsAsync = ref.watch(planEventsStreamProvider(planId));
    final accommodations = ref.watch(accommodationsProvider(AccommodationNotifierParams(planId: planId)));

    if (currentUser == null) {
      return Center(
        child: Text(
          loc.loginTitle,
          style: GoogleFonts.poppins(color: Colors.grey.shade400),
        ),
      );
    }

    final userId = currentUser.id;

    /// Barra superior: título + selector en una fila.
    final bar = _buildSummaryBar(
      loc: loc,
      viewMode: _viewMode,
      onViewModeChanged: (mode) => setState(() => _viewMode = mode),
    );

    final participantNamesAsync = ref.watch(planParticipantDisplayNamesProvider(planId));
    final participantNamesMap = participantNamesAsync.valueOrNull ?? <String, String>{};

    return eventsAsync.when(
      data: (allEvents) {
        final displayEvents = _viewMode == 'plan'
            ? List<Event>.from(allEvents)
            : allEvents.where((e) =>
                e.participantTrackIds.isEmpty || e.participantTrackIds.contains(userId)).toList();
        displayEvents.sort((a, b) {
          final c = a.date.compareTo(b.date);
          if (c != 0) return c;
          final h = (a.hour * 60 + a.startMinute).compareTo(b.hour * 60 + b.startMinute);
          return h;
        });

        final displayAccommodations = _viewMode == 'plan'
            ? List<Accommodation>.from(accommodations)
            : accommodations.where((a) =>
                a.participantTrackIds.isEmpty || a.participantTrackIds.contains(userId)).toList();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final planStart = DateTime(widget.plan.startDate.year, widget.plan.startDate.month, widget.plan.startDate.day);
        final planEnd = DateTime(widget.plan.endDate.year, widget.plan.endDate.month, widget.plan.endDate.day);
        final isPlanInCourse = !today.isBefore(planStart) && !today.isAfter(planEnd);
        final todayEvents = displayEvents.where((e) {
          final d = DateTime(e.date.year, e.date.month, e.date.day);
          return d == today;
        }).toList();
        final tomorrowEvents = displayEvents.where((e) {
          final d = DateTime(e.date.year, e.date.month, e.date.day);
          return d == tomorrow;
        }).toList();

        final flights = displayEvents.where((e) =>
            (e.typeFamily == 'Desplazamiento' && e.typeSubtype == 'Avión') ||
            (e.typeFamily?.toLowerCase().contains('vuelo') == true)).toList();

        final isEmpty = displayEvents.isEmpty && displayAccommodations.isEmpty;
        final showParticipantLabels = _viewMode == 'plan';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            bar,
            Expanded(
              child: isEmpty
                  ? _buildEmptyState(loc)
                  : Stack(
                      children: [
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildExpandableSection(
                              title: loc.myPlanSummaryImportant,
                              subtitle: null,
                              expanded: _importantExpanded,
                              onToggle: () => setState(() => _importantExpanded = !_importantExpanded),
                              child: _buildImportantBlockContent(loc, todayEvents, tomorrowEvents, userId),
                            ),
                            if (isPlanInCourse) ...[
                              const SizedBox(height: 12),
                              _buildExpandableSection(
                                title: loc.myPlanSummaryToday,
                                subtitle: DateFormatter.formatDate(today),
                                expanded: _todayExpanded,
                                onToggle: () => setState(() => _todayExpanded = !_todayExpanded),
                                child: _buildDayBlockContent(todayEvents, showParticipantLabels, participantNamesMap, loc),
                              ),
                              const SizedBox(height: 12),
                              _buildExpandableSection(
                                title: loc.myPlanSummaryTomorrow,
                                subtitle: DateFormatter.formatDate(tomorrow),
                                expanded: _tomorrowExpanded,
                                onToggle: () => setState(() => _tomorrowExpanded = !_tomorrowExpanded),
                                child: _buildDayBlockContent(tomorrowEvents, showParticipantLabels, participantNamesMap, loc),
                              ),
                            ],
                            const SizedBox(height: 20),
                            _buildQuickAccessSection(loc, flights, displayAccommodations, showParticipantLabels, participantNamesMap),
                            const SizedBox(height: 20),
                            _buildChronologicalSection(loc, displayEvents, showParticipantLabels, participantNamesMap),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColorScheme.color2),
            ),
          ),
        ],
      ),
      error: (err, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          Expanded(
            child: Center(
              child: Text(
                err.toString(),
                style: GoogleFonts.poppins(color: Colors.red.shade300, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barra superior: título "Mi resumen" y selector (Mi resumen | Resumen todos) en la misma fila.
  Widget _buildSummaryBar({
    required AppLocalizations loc,
    required String viewMode,
    required void Function(String) onViewModeChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColorScheme.color2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            loc.myPlanSummaryTab,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(width: 16),
          _buildViewModeChip(loc.myPlanSummaryViewMine, viewMode == 'mine', () => onViewModeChanged('mine')),
          const SizedBox(width: 8),
          _buildViewModeChip(loc.myPlanSummaryViewPlan, viewMode == 'plan', () => onViewModeChanged('plan')),
        ],
      ),
    );
  }

  Widget _buildViewModeChip(String label, bool selected, VoidCallback onTap) {
    return Material(
      color: selected ? Colors.white : Colors.white24,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? AppColorScheme.color2 : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  /// Etiqueta de participante(s) para evento: "Todos" si vacío, si no nombres separados por coma.
  String _participantLabelForEvent(Event e, Map<String, String> namesMap, AppLocalizations loc) {
    if (e.participantTrackIds.isEmpty) return loc.myPlanSummaryLabelAll;
    return e.participantTrackIds.map((id) => namesMap[id] ?? id).join(', ');
  }

  /// Etiqueta de participante(s) para alojamiento.
  String _participantLabelForAccommodation(Accommodation a, Map<String, String> namesMap, AppLocalizations loc) {
    if (a.participantTrackIds.isEmpty) return loc.myPlanSummaryLabelAll;
    return a.participantTrackIds.map((id) => namesMap[id] ?? id).join(', ');
  }

  /// Estado vacío: mensaje + CTA "Ir al calendario" si [onGoToCalendar] está definido.
  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 56,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              loc.myPlanSummaryEmpty,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onGoToCalendar != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: widget.onGoToCalendar,
                icon: const Icon(Icons.calendar_month, size: 20),
                label: Text(loc.myPlanSummaryGoToCalendar),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColorScheme.color2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Sección expandible individual: cabecera (título + subtítulo opcional + chevron) y contenido al expandir.
  Widget _buildExpandableSection({
    required String title,
    String? subtitle,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColorScheme.color2,
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  /// Contenido del bloque "Lo más importante" (sin el título de sección).
  Widget _buildImportantBlockContent(
    AppLocalizations loc,
    List<Event> todayEvents,
    List<Event> tomorrowEvents,
    String userId,
  ) {
    final plan = widget.plan;
    final allNear = [...todayEvents, ...tomorrowEvents];
    final myInfoLines = <({String line, Event event})>[];
    for (final e in allNear) {
      final part = e.personalParts?[userId];
      if (part?.fields != null && part!.fields!.isNotEmpty) {
        final parts = part.fields!.entries
            .where((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty)
            .map((entry) => '${entry.key}: ${entry.value}')
            .toList();
        if (parts.isNotEmpty) {
          myInfoLines.add((line: '${e.description}: ${parts.join(', ')}', event: e));
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (plan.name.isNotEmpty) ...[
          Text(
            plan.name,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          '${DateFormatter.formatDate(plan.startDate)} – ${DateFormatter.formatDate(plan.endDate)}',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
        ),
        if (plan.timezone != null) ...[
          const SizedBox(height: 4),
          Text(
            plan.timezone!,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
        if (myInfoLines.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            loc.myPlanSummaryNoMyInfo,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
        if (myInfoLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            loc.myPlanSummaryMyInfo,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          ...myInfoLines.map((item) => _buildSummaryLinkRow(
                text: item.line,
                onTap: widget.onOpenEvent != null ? () => widget.onOpenEvent!(item.event) : null,
              )),
        ],
      ],
    );
  }

  /// Contenido de un bloque de día (Hoy/Mañana): lista de eventos o "—".
  Widget _buildDayBlockContent(
    List<Event> events,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap,
    AppLocalizations loc,
  ) {
    if (events.isEmpty) {
      return Text(
        '—',
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: events
          .map((e) {
            final subtitle = showParticipantLabels ? _participantLabelForEvent(e, participantNamesMap, loc) : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildSummaryLinkRow(
                text: '${_formatEventTime(e)} ${e.description}',
                onTap: widget.onOpenEvent != null ? () => widget.onOpenEvent!(e) : null,
                leadingIcon: _eventTypeIcon(e),
                subtitle: subtitle,
              ),
            );
          })
          .toList(),
    );
  }

  /// Icono según tipo de evento (typeSubtype / typeFamily).
  IconData _eventTypeIcon(Event e) {
    final sub = (e.typeSubtype ?? '').toLowerCase();
    final fam = (e.typeFamily ?? '').toLowerCase();
    if (sub.contains('avión') || sub.contains('avion') || sub.contains('vuelo')) return Icons.flight;
    if (sub.contains('taxi') || sub.contains('coche') || sub.contains('car')) return Icons.directions_car;
    if (sub.contains('tren') || sub.contains('train')) return Icons.train;
    if (sub.contains('hotel') || sub.contains('alojamiento')) return Icons.hotel;
    if (sub.contains('comida') || sub.contains('restaurant') || sub.contains('restauración')) return Icons.restaurant;
    if (sub.contains('museo')) return Icons.museum;
    if (fam.contains('desplazamiento')) return Icons.directions_car;
    if (fam.contains('restauración') || fam.contains('restauracion')) return Icons.restaurant;
    if (fam.contains('actividad')) return Icons.event;
    return Icons.event;
  }

  /// Hora de inicio o rango inicio–fin si el evento tiene duración.
  String _formatEventTime(Event e) {
    final startH = e.hour.toString().padLeft(2, '0');
    final startM = e.startMinute.toString().padLeft(2, '0');
    final startStr = '$startH:$startM';
    if (e.durationMinutes > 0) {
      final endH = e.endHour.toString().padLeft(2, '0');
      final endM = e.endMinute.toString().padLeft(2, '0');
      return '$startStr–$endH:$endM';
    }
    return startStr;
  }

  /// Fila de texto con enlace opcional (icono abrir) al evento/alojamiento.
  /// [leadingIcon] opcional: icono de tipo de evento. [subtitle] opcional: línea secundaria (ej. noches, dirección).
  Widget _buildSummaryLinkRow({required String text, VoidCallback? onTap, IconData? leadingIcon, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.poppins(fontSize: 12, color: onTap != null ? AppColorScheme.color2 : Colors.white70),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.open_in_new, size: 14, color: AppColorScheme.color2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(
    AppLocalizations loc,
    List<Event> flights,
    List<Accommodation> accommodations,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.myPlanSummaryFlights,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          loc.myPlanSummaryFlightsHint,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 6),
        if (flights.isEmpty)
          Text(
            '—',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
          )
        else
          ...flights.map((e) {
                final subtitle = showParticipantLabels ? _participantLabelForEvent(e, participantNamesMap, loc) : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildSummaryLinkRow(
                    text: '${DateFormatter.formatDate(e.date)} ${_formatEventTime(e)} ${e.description}',
                    onTap: widget.onOpenEvent != null ? () => widget.onOpenEvent!(e) : null,
                    subtitle: subtitle,
                  ),
                );
              }),
        const SizedBox(height: 16),
        Text(
          loc.myPlanSummaryAccommodation,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        if (accommodations.isEmpty)
          Text(
            '—',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
          )
        else
          ...accommodations.map((a) {
                final nights = a.checkOut.difference(a.checkIn).inDays;
                final address = a.commonPart?.address?.trim();
                final parts = <String>[];
                if (showParticipantLabels) parts.add(_participantLabelForAccommodation(a, participantNamesMap, loc));
                if (nights > 0) parts.add(loc.nights(nights));
                if (address != null && address.isNotEmpty) parts.add(address);
                final subtitle = parts.isEmpty ? null : parts.join(' · ');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildSummaryLinkRow(
                    text: '${a.hotelName} (${DateFormatter.formatDate(a.checkIn)} – ${DateFormatter.formatDate(a.checkOut)})',
                    onTap: widget.onOpenAccommodation != null ? () => widget.onOpenAccommodation!(a) : null,
                    subtitle: subtitle,
                  ),
                );
              }),
      ],
    );
  }

  Widget _buildChronologicalSection(
    AppLocalizations loc,
    List<Event> events,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap,
  ) {
    final showLimit = events.length > _chronoLimit && !_chronoExpanded;
    final displayEvents = showLimit ? events.take(_chronoLimit).toList() : events;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.myPlanSummaryChronological,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (events.isEmpty)
          Text(
            '—',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
          )
        else ...[
          ..._buildChronologicalGroupedByDay(displayEvents, showParticipantLabels, participantNamesMap, loc),
          if (events.length > _chronoLimit)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => setState(() => _chronoExpanded = !_chronoExpanded),
                child: Text(
                  _chronoExpanded ? loc.myPlanSummarySeeLess : loc.myPlanSummarySeeMore,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColorScheme.color2),
                ),
              ),
            ),
        ],
      ],
    );
  }

  /// Agrupa eventos por día y devuelve una lista de widgets: encabezado de día + filas de eventos.
  List<Widget> _buildChronologicalGroupedByDay(
    List<Event> events,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap,
    AppLocalizations loc,
  ) {
    final list = <Widget>[];
    DateTime? currentDay;

    for (final e in events) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      if (currentDay == null || day != currentDay) {
        currentDay = day;
        final dayLabel = '${DateFormat.E().format(e.date)} ${DateFormatter.formatDateShort(e.date)}';
        list.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              dayLabel,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        );
      }
      final participantLabel = showParticipantLabels ? _participantLabelForEvent(e, participantNamesMap, loc) : null;
      list.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(
            onTap: widget.onOpenEvent != null ? () => widget.onOpenEvent!(e) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_eventTypeIcon(e), size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 72,
                    child: Text(
                      _formatEventTime(e),
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          e.description,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: widget.onOpenEvent != null ? AppColorScheme.color2 : Colors.white70,
                          ),
                        ),
                        if (participantLabel != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            participantLabel,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.onOpenEvent != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(Icons.open_in_new, size: 14, color: AppColorScheme.color2),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return list;
  }
}
