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
import 'package:unp_calendario/widgets/plan/wd_participants_list_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
  /// FAB "+": mismo flujo que calendario sin cambiar de pestaña (ID 44).
  final VoidCallback? onRequestCreateEvent;
  final VoidCallback? onRequestCreateAccommodation;

  const MyPlanSummaryScreen({
    super.key,
    required this.plan,
    this.onOpenEvent,
    this.onOpenAccommodation,
    this.onGoToCalendar,
    this.onRequestCreateEvent,
    this.onRequestCreateAccommodation,
  });

  @override
  ConsumerState<MyPlanSummaryScreen> createState() => _MyPlanSummaryScreenState();
}

class _MyPlanSummaryScreenState extends ConsumerState<MyPlanSummaryScreen> {
  static const int _chronoLimit = 15;
  bool _chronoExpanded = false;
  bool _importantExpanded = false;
  bool _todayExpanded = false;
  bool _tomorrowExpanded = false;
  /// 'mine' = solo mis eventos; 'plan' = todos los participantes.
  String _viewMode = 'mine';
  bool _participantsSectionExpanded = false;
  bool _flightsQuickExpanded = true;
  bool _accommodationQuickExpanded = true;
  bool _itinerarySectionExpanded = true;

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
                      clipBehavior: Clip.none,
                      children: [
                        ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                          children: [
                            if (widget.plan.id != null) ...[
                              _buildExpandableSection(
                                title: loc.myPlanSummaryParticipantsSection,
                                subtitle: null,
                                expanded: _participantsSectionExpanded,
                                onToggle: () => setState(() => _participantsSectionExpanded = !_participantsSectionExpanded),
                                child: ParticipantsListWidget(
                                  planId: widget.plan.id!,
                                  showActions: false,
                                  compact: true,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
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
                            _buildExpandableSection(
                              title: loc.myPlanSummaryFlights,
                              subtitle: null,
                              expanded: _flightsQuickExpanded,
                              framed: false,
                              onToggle: () => setState(() => _flightsQuickExpanded = !_flightsQuickExpanded),
                              child: _buildFlightsQuickContent(
                                loc,
                                flights,
                                showParticipantLabels,
                                participantNamesMap,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildExpandableSection(
                              title: loc.myPlanSummaryAccommodation,
                              subtitle: null,
                              expanded: _accommodationQuickExpanded,
                              framed: false,
                              onToggle: () => setState(() => _accommodationQuickExpanded = !_accommodationQuickExpanded),
                              child: _buildAccommodationQuickContent(
                                loc,
                                displayAccommodations,
                                showParticipantLabels,
                                participantNamesMap,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildExpandableSection(
                              title: loc.myPlanSummaryChronological,
                              subtitle: null,
                              expanded: _itinerarySectionExpanded,
                              framed: false,
                              onToggle: () => setState(() => _itinerarySectionExpanded = !_itinerarySectionExpanded),
                              child: _buildChronologicalSectionBody(loc, displayEvents, showParticipantLabels, participantNamesMap),
                            ),
                          ],
                        ),
                        if (widget.onRequestCreateEvent != null && widget.onRequestCreateAccommodation != null)
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              onPressed: () => _showCreateChooser(context, loc),
                              backgroundColor: AppColorScheme.color3,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.add),
                            ),
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
          Flexible(
            child: Text(
              loc.myPlanSummaryTab,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  _buildViewModeChip(
                    loc.myPlanSummaryViewMine,
                    viewMode == 'mine',
                    () => onViewModeChanged('mine'),
                  ),
                  const SizedBox(width: 8),
                  _buildViewModeChip(
                    loc.myPlanSummaryViewPlan,
                    viewMode == 'plan',
                    () => onViewModeChanged('plan'),
                  ),
                ],
              ),
            ),
          ),
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
              fontSize: 13,
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
                fontSize: 15,
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

  void _showCreateChooser(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event, color: Colors.white),
              title: Text(loc.createEvent, style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                widget.onRequestCreateEvent?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.hotel_outlined, color: Colors.white),
              title: Text(loc.tooltipCreateAccommodation, style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                widget.onRequestCreateAccommodation?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Sección expandible: [framed] false = sin recuadro (ID 43).
  Widget _buildExpandableSection({
    required String title,
    String? subtitle,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
    bool framed = true,
  }) {
    final header = InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: framed ? 16 : 4, vertical: 12),
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
                      fontSize: framed ? 15 : 16,
                      fontWeight: FontWeight.w600,
                      color: framed ? AppColorScheme.color2 : Colors.white,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 26,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );

    if (!framed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
              child: child,
            ),
        ],
      );
    }

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
          header,
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          '${DateFormatter.formatDate(plan.startDate)} – ${DateFormatter.formatDate(plan.endDate)}',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        ),
        if (plan.timezone != null) ...[
          const SizedBox(height: 4),
          Text(
            plan.timezone!,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
        if (myInfoLines.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            loc.myPlanSummaryNoMyInfo,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
        if (myInfoLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            loc.myPlanSummaryMyInfo,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          ...myInfoLines.map((item) => _buildSummaryLinkRow(
                text: item.line,
                onOpenDetail: widget.onOpenEvent != null ? () => widget.onOpenEvent!(item.event) : null,
                mapsQuery: item.event.commonPart?.location,
                webUrl: item.event.commonPart?.url,
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
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: events
          .map((e) {
            final subtitle = showParticipantLabels ? _participantLabelForEvent(e, participantNamesMap, loc) : null;
            final code = _transportCodeLabel(e);
            final head = code != null ? '${_formatEventTime(e)} $code · ${e.description}' : '${_formatEventTime(e)} ${e.description}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildSummaryLinkRow(
                text: head,
                onOpenDetail: widget.onOpenEvent != null ? () => widget.onOpenEvent!(e) : null,
                mapsQuery: e.commonPart?.location,
                webUrl: e.commonPart?.url,
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

  /// Fila de resumen con hasta 3 acciones: detalle interno, Maps y URL.
  Widget _buildSummaryLinkRow({
    required String text,
    VoidCallback? onOpenDetail,
    String? mapsQuery,
    String? webUrl,
    IconData? leadingIcon,
    String? subtitle,
  }) {
    final hasMaps = mapsQuery != null && mapsQuery.trim().isNotEmpty;
    final hasWebUrl = webUrl != null && webUrl.trim().isNotEmpty;
    final safeMapsQuery = mapsQuery ?? '';
    final safeWebUrl = webUrl ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 17, color: Colors.grey.shade500),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: onOpenDetail != null ? AppColorScheme.color2 : Colors.white70,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasMaps) _buildMapLinkChip(onTap: () => _openMapsQuery(safeMapsQuery)),
                  if (hasWebUrl) _buildWebWwwChip(onTap: () => _openWebUrl(safeWebUrl)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapLinkChip({required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Material(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Icon(Icons.location_on, size: 22, color: AppColorScheme.color2),
          ),
        ),
      ),
    );
  }

  Widget _buildWebWwwChip({required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Material(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              'www',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColorScheme.color2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMapsQuery(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWebUrl(String rawUrl) async {
    final normalized = _normalizeUrl(rawUrl);
    if (normalized == null) return;
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String? _normalizeUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://$value';
  }

  Widget _buildFlightsQuickContent(
    AppLocalizations loc,
    List<Event> flights,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap,
  ) {
    if (flights.isEmpty) {
      return Text(
        '—',
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: flights.map((e) {
        final subtitle = showParticipantLabels ? _participantLabelForEvent(e, participantNamesMap, loc) : null;
        final code = _transportCodeLabel(e);
        final line = code != null
            ? '${DateFormatter.formatDate(e.date)} ${_formatEventTime(e)} $code · ${e.description}'
            : '${DateFormatter.formatDate(e.date)} ${_formatEventTime(e)} ${e.description}';
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildSummaryLinkRow(
            text: line,
            onOpenDetail: widget.onOpenEvent != null ? () => widget.onOpenEvent!(e) : null,
            mapsQuery: e.commonPart?.location,
            webUrl: e.commonPart?.url,
            subtitle: subtitle,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccommodationQuickContent(
    AppLocalizations loc,
    List<Accommodation> accommodations,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap,
  ) {
    if (accommodations.isEmpty) {
      return Text(
        '—',
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: accommodations.map((a) {
        final nights = a.duration;
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
            onOpenDetail: widget.onOpenAccommodation != null ? () => widget.onOpenAccommodation!(a) : null,
            mapsQuery: a.commonPart?.address,
            webUrl: a.commonPart?.url,
            subtitle: subtitle,
          ),
        );
      }).toList(),
    );
  }

  /// Número vuelo/tren/etc. desde extraData (ID 50).
  String? _transportCodeLabel(Event e) {
    final ed = e.commonPart?.extraData;
    if (ed == null) return null;
    for (final key in ['flightNumber', 'trainNumber', 'transportNumber']) {
      final v = ed[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  String _chronologicalEventTitle(Event e) {
    final c = _transportCodeLabel(e);
    return c != null ? '$c · ${e.description}' : e.description;
  }

  Widget _buildChronologicalSectionBody(
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
        if (events.isEmpty)
          Text(
            '—',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
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
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColorScheme.color2),
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
        if (currentDay != null) {
          list.add(
            Divider(
              height: 20,
              thickness: 1,
              color: Colors.grey.shade700.withValues(alpha: 0.6),
            ),
          );
        }
        currentDay = day;
        final dayLabel = '${DateFormat.E().format(e.date)} ${DateFormatter.formatDateShort(e.date)}';
        list.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              dayLabel,
              style: GoogleFonts.poppins(
                fontSize: 13,
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
                  Icon(_eventTypeIcon(e), size: 18, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 76,
                    child: Text(
                      _formatEventTime(e),
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (e.isDraft || (e.commonPart?.isDraft == true)) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(right: 6, top: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade800.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.orange.shade300.withValues(alpha: 0.6)),
                                ),
                                child: Text(
                                  'Borrador',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade100,
                                  ),
                                ),
                              ),
                            ],
                            Expanded(
                              child: Text(
                                _chronologicalEventTitle(e),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: widget.onOpenEvent != null ? AppColorScheme.color2 : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (participantLabel != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            participantLabel,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (e.commonPart?.location != null && e.commonPart!.location!.trim().isNotEmpty)
                        _buildMapLinkChip(onTap: () => _openMapsQuery(e.commonPart!.location!)),
                      if (e.commonPart?.url != null && e.commonPart!.url!.trim().isNotEmpty)
                        _buildWebWwwChip(onTap: () => _openWebUrl(e.commonPart!.url!)),
                    ],
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
