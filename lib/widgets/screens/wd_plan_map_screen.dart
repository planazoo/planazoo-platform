import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_map_stop.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_map_api_key.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_map_day_colors.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_map_html.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_map_stop_builder.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_summary_share_text.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:unp_calendario/widgets/plan/plan_map_google_js_view.dart';
import 'package:unp_calendario/widgets/plan/plan_summary_event_look.dart';
import 'package:unp_calendario/widgets/plan/plan_summary_link_row.dart';
import 'package:url_launcher/url_launcher.dart';

/// T279: mapa del plan con color por día, número de secuencia y lista sincronizada.
class PlanMapScreen extends StatefulWidget {
  const PlanMapScreen({
    super.key,
    required this.plan,
    required this.events,
    required this.accommodations,
    this.onOpenEvent,
    this.onOpenAccommodation,
  });

  final Plan plan;
  final List<Event> events;
  final List<Accommodation> accommodations;
  final void Function(Event event)? onOpenEvent;
  final void Function(Accommodation accommodation)? onOpenAccommodation;

  static Future<void> open(
    BuildContext context, {
    required Plan plan,
    required List<Event> events,
    required List<Accommodation> accommodations,
    void Function(Event event)? onOpenEvent,
    void Function(Accommodation accommodation)? onOpenAccommodation,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PlanMapScreen(
          plan: plan,
          events: events,
          accommodations: accommodations,
          onOpenEvent: onOpenEvent,
          onOpenAccommodation: onOpenAccommodation,
        ),
      ),
    );
  }

  @override
  State<PlanMapScreen> createState() => _PlanMapScreenState();
}

class _PlanMapScreenState extends State<PlanMapScreen> {
  static const double _wideBreakpoint = 720;

  int? _selectedDayIndex;
  String? _selectedStopId;
  var _mapError = false;
  final _listController = ScrollController();
  final _itemKeys = <String, GlobalKey>{};

  late final PlanMapData _data = PlanMapStopBuilder.build(
    plan: widget.plan,
    events: widget.events,
    accommodations: widget.accommodations,
  );
  late final Map<String, Event> _eventsById = {
    for (final e in widget.events)
      if (e.id != null) e.id!: e,
  };
  late final Map<String, Accommodation> _accommodationsById = {
    for (final a in widget.accommodations)
      if (a.id != null) a.id!: a,
  };
  late final String? _mapHtml =
      PlanMapApiKey.isConfigured && _data.stops.isNotEmpty
          ? PlanMapHtml.build(
              apiKey: PlanMapApiKey.value,
              stops: _data.stops,
              routes: _data.routes,
            )
          : null;

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Color _colorFromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length != 6) return IosFormColors.accent;
    return Color(int.parse('FF$h', radix: 16));
  }

  DateTime _dateForDayIndex(int dayIndex) => DateTime(
        widget.plan.startDate.year,
        widget.plan.startDate.month,
        widget.plan.startDate.day,
      ).add(Duration(days: dayIndex));

  List<PlanMapStop> get _listStops =>
      _data.orderedVisibleStops(_selectedDayIndex);

  List<PlanMapStop> get _visibleStops => _data.visibleStops(_selectedDayIndex);

  GlobalKey _keyFor(String id) => _itemKeys.putIfAbsent(id, GlobalKey.new);

  void _selectStop(String id) {
    setState(() => _selectedStopId = id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _keyFor(id).currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.25,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _onMapMessage(Map<String, dynamic> message) {
    final action = message['action'] as String?;
    if (action == 'error') {
      setState(() => _mapError = true);
      return;
    }
    if (action == 'select') {
      final id = message['id'] as String?;
      if (id == null) return;
      _selectStop(id);
    }
  }

  Future<void> _openDayRoute() async {
    final url = PlanMapStopBuilder.googleMapsDirUrl(_visibleStops);
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _onMapRowTap(PlanMapStop stop) {
    if (_selectedStopId == stop.id) {
      _openSelectedEntity(stop);
      return;
    }
    _selectStop(stop.id);
  }

  Event? _eventFor(PlanMapStop stop) {
    final id = stop.eventId;
    if (id == null) return null;
    return _eventsById[id];
  }

  Accommodation? _accommodationFor(PlanMapStop stop) {
    final id = stop.accommodationId;
    if (id == null) return null;
    return _accommodationsById[id];
  }

  void _openSelectedEntity(PlanMapStop stop) {
    if (stop.eventId != null && widget.onOpenEvent != null) {
      for (final e in widget.events) {
        if (e.id == stop.eventId) {
          widget.onOpenEvent!(e);
          return;
        }
      }
    }
    if (stop.accommodationId != null && widget.onOpenAccommodation != null) {
      for (final a in widget.accommodations) {
        if (a.id == stop.accommodationId) {
          widget.onOpenAccommodation!(a);
          return;
        }
      }
    }
  }

  String _dayChipLabel(AppLocalizations loc, int dayIndex) {
    if (dayIndex >= 0) return loc.planMapDayChip(dayIndex + 1);
    return DateFormatter.formatDateShort(_dateForDayIndex(dayIndex));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hasKey = PlanMapApiKey.isConfigured;
    final mapHtml = _mapHtml;
    final showMap = mapHtml != null && !_mapError;
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Scaffold(
      backgroundColor: IosFormColors.pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(loc),
            if (_data.dayIndexes.length > 1) _buildDayChips(loc),
            Expanded(
              child: _data.stops.isEmpty
                  ? _buildMessage(
                      loc.planMapEmpty,
                      loc.planMapEmptyHint,
                    )
                  : showMap
                      ? _buildMapAndList(
                          loc,
                          mapHtml: mapHtml,
                          wide: wide,
                        )
                      : _buildFallbackList(
                          loc,
                          missingKey: !hasKey,
                          mapError: _mapError,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapAndList(
    AppLocalizations loc, {
    required String mapHtml,
    required bool wide,
  }) {
    final mapPane = PlanMapGoogleJsView(
      html: mapHtml,
      selectedDayIndex: _selectedDayIndex,
      selectedStopId: _selectedStopId,
      onMessage: _onMapMessage,
    );
    final listPane = _buildPlacesList(loc);
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: mapPane),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: IosFormColors.separator,
          ),
          Expanded(flex: 2, child: listPane),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 3, child: mapPane),
        const Divider(height: 1, thickness: 1, color: IosFormColors.separator),
        Expanded(flex: 2, child: listPane),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    final canOpenDay =
        PlanMapStopBuilder.googleMapsDirUrl(_visibleStops) != null;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: IosFormColors.pageBg,
        border: Border(
          bottom: BorderSide(color: IosFormColors.separator),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: loc.planMapClose,
            onPressed: () => Navigator.of(context).pop(),
            icon:
                const Icon(Icons.arrow_back, color: IosFormColors.textPrimary),
          ),
          Expanded(
            child: Text(
              loc.planMapTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: IosFormColors.textPrimary,
              ),
            ),
          ),
          if (canOpenDay)
            IconButton(
              tooltip: loc.planMapOpenDayRoute,
              onPressed: _openDayRoute,
              icon: const Icon(
                Icons.route,
                color: IosFormColors.textSecondary,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayChips(AppLocalizations loc) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _chip(
            label: loc.planMapAllDays,
            selected: _selectedDayIndex == null,
            color: IosFormColors.accent,
            onTap: () => setState(() {
              _selectedDayIndex = null;
              _selectedStopId = null;
            }),
          ),
          for (final dayIndex in _data.dayIndexes) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: DateFormatter.formatDate(_dateForDayIndex(dayIndex)),
              child: _chip(
                label: _dayChipLabel(loc, dayIndex),
                selected: _selectedDayIndex == dayIndex,
                color: _colorFromHex(PlanMapDayColors.hexForDay(dayIndex)),
                onTap: () => setState(() {
                  _selectedDayIndex = dayIndex;
                  _selectedStopId = null;
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 32,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.28)
                : IosFormColors.groupedBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : IosFormColors.separator,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? IosFormColors.textPrimary
                  : IosFormColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(String title, String hint) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: IosFormColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: IosFormColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackList(
    AppLocalizations loc, {
    required bool missingKey,
    required bool mapError,
  }) {
    final hint = missingKey
        ? loc.planMapMissingKey
        : mapError
            ? loc.planMapLoadError
            : loc.planMapEmptyHint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            hint,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: IosFormColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: _buildPlacesList(loc, showTitle: false)),
      ],
    );
  }

  Widget _buildPlacesList(
    AppLocalizations loc, {
    bool showTitle = true,
  }) {
    final stops = _listStops;
    final showHeaders =
        _selectedDayIndex == null && _data.dayIndexes.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle)
          SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  loc.planMapPlacesList,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: IosFormColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _listController,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              final showHeader = showHeaders &&
                  (index == 0 || stops[index - 1].dayIndex != stop.dayIndex);
              final showStayHeader = stop.kind == PlanMapStopKind.accommodation &&
                  (index == 0 ||
                      stops[index - 1].kind != PlanMapStopKind.accommodation ||
                      stops[index - 1].dayIndex != stop.dayIndex);
              return KeyedSubtree(
                key: _keyFor(stop.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showHeader) _dayListHeader(loc, stop.dayIndex),
                    if (showStayHeader) _stayListHeader(loc),
                    _stopRow(loc, stop),
                    const SizedBox(height: 2),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _stayListHeader(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(
        children: [
          Icon(
            Icons.hotel_outlined,
            size: 14,
            color: IosFormColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            loc.planMapLegendHotel.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: IosFormColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayListHeader(AppLocalizations loc, int dayIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Text(
        '${_dayChipLabel(loc, dayIndex)} · ${DateFormatter.formatDate(_dateForDayIndex(dayIndex))}',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _colorFromHex(PlanMapDayColors.hexForDay(dayIndex)),
        ),
      ),
    );
  }

  String? _airportRoleLabel(AppLocalizations loc, PlanMapStop stop) {
    if (stop.kind != PlanMapStopKind.airport) return null;
    final day = _selectedDayIndex ?? stop.dayIndex;
    final arrival = stop.isArrivalOn(day);
    final departure = stop.isDepartureOn(day);
    if (arrival && departure) {
      return '${loc.planMapLegendAirport} · ${loc.planMapAirportArrival} / ${loc.planMapAirportDeparture}';
    }
    if (departure) {
      return '${loc.planMapLegendAirport} · ${loc.planMapAirportDeparture}';
    }
    return '${loc.planMapLegendAirport} · ${loc.planMapAirportArrival}';
  }

  Widget _stopRow(AppLocalizations loc, PlanMapStop stop) {
    final color = _colorFromHex(stop.colorHex);
    final selected = stop.id == _selectedStopId;
    final isStay = stop.kind == PlanMapStopKind.accommodation;
    final badge = isStay
        ? 'H'
        : (stop.kind == PlanMapStopKind.airport
            ? 'A'
            : (stop.sequenceInDay?.toString() ?? '•'));
    final event = _eventFor(stop);
    final accommodation = _accommodationFor(stop);
    final dimPast = widget.plan.state == 'en_curso';
    final now = DateTime.now();

    late final Widget summary;
    if (event != null) {
      final typeBadge = PlanSummaryEventLook.inlineTypeBadge(event, loc);
      final airportRole = stop.kind == PlanMapStopKind.airport
          ? _airportRoleLabel(loc, stop)
          : null;
      summary = PlanSummaryLinkRow(
        text: PlanSummaryEventLook.chronologicalTitle(event),
        timeLabel: PlanSummaryEventLook.formatEventTime(event, loc),
        leadingIcon: PlanSummaryEventLook.typeIcon(event),
        forceShowLeadingIcon: true,
        mapsQuery: event.commonPart?.location,
        routeUrl: PlanSummaryShareContent.eventRouteUrl(event),
        webUrl: event.commonPart?.url,
        subtitle: airportRole,
        mutedPast: dimPast && PlanSummaryEventLook.isPast(event, now),
        showDraftBadge: event.isDraft || (event.commonPart?.isDraft == true),
        typeBadgeIcon: typeBadge?.icon,
        typeBadgeTooltip: typeBadge?.tooltip,
        onOpenDetail: () => _onMapRowTap(stop),
      );
    } else if (accommodation != null) {
      summary = PlanSummaryLinkRow(
        text: accommodation.hotelName,
        leadingIcon: Icons.hotel_outlined,
        forceShowLeadingIcon: true,
        mapsQuery: accommodation.commonPart?.address,
        webUrl: accommodation.commonPart?.url,
        subtitle: _hotelSubtitle(loc, stop),
        onOpenDetail: () => _onMapRowTap(stop),
      );
    } else {
      summary = PlanSummaryLinkRow(
        text: stop.title,
        leadingIcon: stop.kind == PlanMapStopKind.airport
            ? Icons.flight
            : Icons.place_outlined,
        forceShowLeadingIcon: true,
        subtitle: _airportRoleLabel(loc, stop) ?? loc.planMapLegendHotel,
        onOpenDetail: () => _onMapRowTap(stop),
      );
    }

    return Material(
      color: selected ? color.withValues(alpha: 0.22) : IosFormColors.groupedBg,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : IosFormColors.separator,
            width: selected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _onMapRowTap(stop),
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isStay ? color.withValues(alpha: 0.18) : color,
                  shape: isStay ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: isStay ? BorderRadius.circular(6) : null,
                  border: isStay ? Border.all(color: color, width: 1.5) : null,
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isStay ? color : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: summary),
          ],
        ),
      ),
    );
  }

  String _hotelSubtitle(AppLocalizations loc, PlanMapStop stop) {
    final day = _selectedDayIndex ?? stop.dayIndex;
    final arrival = stop.isArrivalOn(day);
    final departure = stop.isDepartureOn(day);
    if (arrival && departure) {
      return '${loc.myPlanSummaryAccommodationRowLabel} · ${loc.planMapAirportArrival} / ${loc.planMapAirportDeparture}';
    }
    if (departure) {
      return '${loc.myPlanSummaryAccommodationRowLabel} · ${loc.planMapAirportDeparture}';
    }
    if (arrival) {
      return '${loc.myPlanSummaryAccommodationRowLabel} · ${loc.planMapAirportArrival}';
    }
    return loc.myPlanSummaryAccommodationRowLabel;
  }
}
