import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_summary_share_text.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_map_day_colors.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_service.dart';
import 'package:unp_calendario/widgets/plan/wd_participants_list_widget.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_map_screen.dart';
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
  final bool showTopSummaryBar;
  final String? viewMode;
  final ValueChanged<String>? onViewModeChanged;
  final bool? draftOnlyFilter;
  final ValueChanged<bool>? onDraftOnlyFilterChanged;
  final ValueChanged<bool>? onDraftFilterVisibilityChanged;

  const MyPlanSummaryScreen({
    super.key,
    required this.plan,
    this.onOpenEvent,
    this.onOpenAccommodation,
    this.onGoToCalendar,
    this.onRequestCreateEvent,
    this.onRequestCreateAccommodation,
    this.showTopSummaryBar = true,
    this.viewMode,
    this.onViewModeChanged,
    this.draftOnlyFilter,
    this.onDraftOnlyFilterChanged,
    this.onDraftFilterVisibilityChanged,
  });

  @override
  ConsumerState<MyPlanSummaryScreen> createState() => _MyPlanSummaryScreenState();
}

class _MyPlanSummaryScreenState extends ConsumerState<MyPlanSummaryScreen> {
  static const Color _pageBg = Color(0xFF111827);
  static const Color _surface = Color(0xFF1F2937);
  static const Color _border = Color(0x1FFFFFFF);
  static const Color _textSecondary = Colors.white70;
  static const Color _textTertiary = Colors.white60;
  static const Color _textMuted = Color(0x8AFFFFFF);

  /// Alinea la 1ª línea de textos con tamaños distintos (hora vs título) al mismo borde superior.
  static const TextHeightBehavior _tightFirstLineHeight = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: true,
  );

  /// Día seleccionado en el selector horizontal (clave civil).
  DateTime? _selectedDay;
  final ScrollController _dayChipsScrollController = ScrollController();
  /// 'mine' = solo mis eventos; 'plan' = todos los participantes.
  String _internalViewMode = 'mine';
  /// Ítem 81: en planificando, mostrar solo eventos borrador / no confirmados.
  bool _internalDraftOnlyFilter = false;

  String get _viewMode => widget.viewMode ?? _internalViewMode;
  bool get _draftOnlyFilter => widget.draftOnlyFilter ?? _internalDraftOnlyFilter;

  @override
  void dispose() {
    _dayChipsScrollController.dispose();
    super.dispose();
  }

  void _setViewMode(String mode) {
    if (widget.onViewModeChanged != null) {
      widget.onViewModeChanged!(mode);
      return;
    }
    setState(() => _internalViewMode = mode);
  }

  void _setDraftOnlyFilter(bool value) {
    if (widget.onDraftOnlyFilterChanged != null) {
      widget.onDraftOnlyFilterChanged!(value);
      return;
    }
    setState(() => _internalDraftOnlyFilter = value);
  }

  /// Orden por fecha, hora de inicio, creación e id (lista §3.2 ítem 88).
  static int _compareEventsBySchedule(Event a, Event b) {
    final c = a.date.compareTo(b.date);
    if (c != 0) return c;
    final h = (a.hour * 60 + a.startMinute).compareTo(b.hour * 60 + b.startMinute);
    if (h != 0) return h;
    final t = a.createdAt.compareTo(b.createdAt);
    if (t != 0) return t;
    return (a.id ?? '').compareTo(b.id ?? '');
  }

  /// Ítem 69: evento ya terminado (día pasado o mismo día con hora fin antes de ahora).
  static bool _isEventPast(Event e, DateTime now) {
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

  /// Evento cuyo rango horario contiene «ahora».
  static bool _isEventHappeningNow(Event e, DateTime now) {
    final eventDay = DateTime(e.date.year, e.date.month, e.date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (eventDay != today) return false;
    final startMin = e.hour * 60 + e.startMinute;
    final endMin = e.durationMinutes > 0
        ? startMin + e.durationMinutes
        : startMin + 30;
    final nowMin = now.hour * 60 + now.minute;
    return nowMin >= startMin && nowMin <= endMin;
  }

  /// Evento actual (en curso) o el siguiente próximo del día.
  static Event? _currentOrNextEvent(List<Event> events, DateTime now) {
    Event? happening;
    Event? next;
    for (final e in events) {
      if (_isEventHappeningNow(e, now)) {
        happening = e;
        break;
      }
      if (!_isEventPast(e, now)) {
        next ??= e;
      }
    }
    return happening ?? next;
  }

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
          style: GoogleFonts.poppins(
            color: _textSecondary,
          ),
        ),
      );
    }

    final userId = currentUser.id;

    final participantNamesAsync = ref.watch(planParticipantDisplayNamesProvider(planId));
    final participantNamesMap = participantNamesAsync.valueOrNull ?? <String, String>{};

    return eventsAsync.when(
      data: (allEvents) {
        final planStateNorm = widget.plan.state ?? 'planificando';
        final hasDrafts =
            allEvents.any((e) => e.isDraft || (e.commonPart?.isDraft == true));
        final showDraftFilter = planStateNorm == 'planificando' && hasDrafts;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onDraftFilterVisibilityChanged?.call(showDraftFilter);
          if (!showDraftFilter && _draftOnlyFilter) {
            _setDraftOnlyFilter(false);
          }
        });

        var displayEvents = _viewMode == 'plan'
            ? List<Event>.from(allEvents)
            : allEvents
                .where((e) =>
                    e.participantTrackIds.isEmpty ||
                    e.participantTrackIds.contains(userId))
                .toList();
        if (_draftOnlyFilter) {
          displayEvents = displayEvents
              .where((e) => e.isDraft || (e.commonPart?.isDraft == true))
              .toList();
        }
        displayEvents.sort(_compareEventsBySchedule);

        final dimPastInCourse = widget.plan.state == 'en_curso';

        final displayAccommodations = _viewMode == 'plan'
            ? List<Accommodation>.from(accommodations)
            : accommodations
                .where((a) =>
                    a.participantTrackIds.isEmpty ||
                    a.participantTrackIds.contains(userId))
                .toList();

        final mapEvents = _viewMode == 'plan'
            ? List<Event>.from(allEvents)
            : allEvents
                .where((e) =>
                    e.participantTrackIds.isEmpty ||
                    e.participantTrackIds.contains(userId))
                .toList();
        final mapAccommodations = _viewMode == 'plan'
            ? List<Accommodation>.from(accommodations)
            : accommodations
                .where((a) =>
                    a.participantTrackIds.isEmpty ||
                    a.participantTrackIds.contains(userId))
                .toList();

        final bar = _buildSummaryBar(
          loc: loc,
          viewMode: _viewMode,
          onViewModeChanged: _setViewMode,
          showDraftFilter: showDraftFilter,
          draftsOnlyActive: _draftOnlyFilter,
          onDraftOnlyToggle: () => _setDraftOnlyFilter(!_draftOnlyFilter),
          onShare: () => _shareVisibleSummary(
            loc: loc,
            events: displayEvents,
            accommodations: displayAccommodations,
          ),
          onOpenMap: () => PlanMapScreen.open(
            context,
            plan: widget.plan,
            events: mapEvents,
            accommodations: mapAccommodations,
            onOpenEvent: widget.onOpenEvent,
            onOpenAccommodation: widget.onOpenAccommodation,
          ),
        );

        final isEmpty = displayEvents.isEmpty && displayAccommodations.isEmpty;
        final showParticipantLabels = _viewMode == 'plan';
        final planDays = _planDayRange(displayEvents, displayAccommodations);
        final selectedDay = _resolveSelectedDay(planDays);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showTopSummaryBar) bar,
            if (!widget.showTopSummaryBar)
              _buildMineFilterRow(
                loc: loc,
                viewMode: _viewMode,
                onViewModeChanged: _setViewMode,
                showDraftFilter: showDraftFilter,
                draftsOnlyActive: _draftOnlyFilter,
                onDraftOnlyToggle: () => _setDraftOnlyFilter(!_draftOnlyFilter),
              ),
            Expanded(
              child: ColoredBox(
                color: Colors.transparent,
                child: isEmpty
                    ? _buildEmptyState(loc)
                    : GestureDetector(
                        onHorizontalDragEnd: (details) {
                          final v = details.primaryVelocity ?? 0;
                          if (v < -280) {
                            _shiftSelectedDay(planDays, 1);
                          } else if (v > 280) {
                            _shiftSelectedDay(planDays, -1);
                          }
                        },
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                          children: [
                            _buildDaySelector(planDays),
                            if (selectedDay != null)
                              _buildDateActionsRow(
                                loc: loc,
                                day: selectedDay,
                                onOpenMap: () => PlanMapScreen.open(
                                  context,
                                  plan: widget.plan,
                                  events: mapEvents,
                                  accommodations: mapAccommodations,
                                  onOpenEvent: widget.onOpenEvent,
                                  onOpenAccommodation:
                                      widget.onOpenAccommodation,
                                ),
                              ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: selectedDay == null
                                  ? const SizedBox.shrink()
                                  : _buildSelectedDayContent(
                                      context,
                                      loc,
                                      selectedDay,
                                      displayEvents,
                                      displayAccommodations,
                                      showParticipantLabels,
                                      participantNamesMap,
                                      dimPastInCourse: dimPastInCourse,
                                    ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showTopSummaryBar)
            _buildSummaryBar(
              loc: loc,
              viewMode: _viewMode,
              onViewModeChanged: _setViewMode,
              showDraftFilter: false,
              draftsOnlyActive: false,
              onDraftOnlyToggle: () {},
            ),
          Expanded(
            child: ColoredBox(
              color: Colors.transparent,
              child: const Center(
                child: CircularProgressIndicator(color: AppColorScheme.color2),
              ),
            ),
          ),
        ],
      ),
      error: (err, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showTopSummaryBar)
            _buildSummaryBar(
              loc: loc,
              viewMode: _viewMode,
              onViewModeChanged: _setViewMode,
              showDraftFilter: false,
              draftsOnlyActive: false,
              onDraftOnlyToggle: () {},
            ),
          Expanded(
            child: ColoredBox(
              color: Colors.transparent,
              child: Center(
                child: Text(
                  err.toString(),
                  style: GoogleFonts.poppins(color: Colors.red.shade300, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barra superior (web): acciones mínimas sin título «Mi resumen».
  Widget _buildSummaryBar({
    required AppLocalizations loc,
    required String viewMode,
    required void Function(String) onViewModeChanged,
    required bool showDraftFilter,
    required bool draftsOnlyActive,
    required VoidCallback onDraftOnlyToggle,
    VoidCallback? onShare,
    VoidCallback? onOpenMap,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
      ),
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
          if (showDraftFilter) ...[
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: loc.myPlanSummaryDraftsOnlyTooltip,
              onPressed: onDraftOnlyToggle,
              icon: Icon(
                draftsOnlyActive ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: draftsOnlyActive
                    ? Colors.orange.shade200
                    : Colors.white70,
                size: 22,
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: loc.planMapTooltip,
            onPressed: onOpenMap,
            icon: Icon(
              Icons.map_outlined,
              color: AppColorScheme.color2,
              size: 22,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: loc.myPlanSummaryShareTooltip,
            onPressed: onShare,
            icon: Icon(
              Icons.ios_share,
              color: onShare != null ? Colors.white : Colors.white38,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  /// Fila mío/todos + filtrar (stub) para mobile (sin barra superior).
  Widget _buildMineFilterRow({
    required AppLocalizations loc,
    required String viewMode,
    required void Function(String) onViewModeChanged,
    required bool showDraftFilter,
    required bool draftsOnlyActive,
    required VoidCallback onDraftOnlyToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
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
          if (showDraftFilter) ...[
            const SizedBox(width: 6),
            Material(
              color: draftsOnlyActive
                  ? Colors.orange.shade200.withValues(alpha: 0.2)
                  : _surface,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onDraftOnlyToggle,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Icon(
                    draftsOnlyActive
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                    size: 18,
                    color: draftsOnlyActive
                        ? Colors.orange.shade200
                        : Colors.white70,
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),
          Material(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.filter),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 18,
                      color: AppColorScheme.color2,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      loc.filter.toLowerCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareVisibleSummary({
    required AppLocalizations loc,
    required List<Event> events,
    required List<Accommodation> accommodations,
  }) async {
    final planName = widget.plan.name.trim().isEmpty
        ? loc.myPlanSummaryTab
        : widget.plan.name.trim();
    final content = PlanSummaryShareContent.fromData(
      planName: planName,
      planStart: widget.plan.startDate,
      planEnd: widget.plan.endDate,
      viewLabel: _viewMode == 'plan'
          ? loc.myPlanSummaryShareViewPlan
          : loc.myPlanSummaryShareViewMine,
      events: events,
      accommodations: accommodations,
      formatEventTime: (e) => _formatEventTime(e, loc),
      mapsLabel: loc.myPlanSummaryShareMapsLabel,
      webLabel: loc.myPlanSummaryShareWebLabel,
      routeLabel: loc.myPlanSummaryShareRouteLabel,
    );

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _pageBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 16 + MediaQuery.viewInsetsOf(ctx).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.myPlanSummarySharePreviewTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.myPlanSummarySharePreviewHint,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(ctx).height * 0.52,
                  ),
                  child: SingleChildScrollView(
                    child: _buildSharePreviewBody(loc, content),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _shareSummaryContent(loc, content);
                  },
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: Text(loc.myPlanSummaryShareSend),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorScheme.color2,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSharePreviewBody(
    AppLocalizations loc,
    PlanSummaryShareContent content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.planName,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        for (final line in content.headerLines)
          Text(
            line,
            style: GoogleFonts.poppins(fontSize: 13, color: _textSecondary),
          ),
        if (content.daySections.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            loc.myPlanSummaryShareSectionItinerary,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          for (final section in content.daySections) ...[
            const SizedBox(height: 8),
            Text(
              section.dayLabel,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColorScheme.color2,
              ),
            ),
            for (final b in section.items) _buildSharePreviewBlock(b),
          ],
        ],
      ],
    );
  }

  Widget _buildSharePreviewBlock(PlanSummaryShareBlock block) {
    return Padding(
      padding: EdgeInsets.only(
        top: block.isAccommodation ? 10 : 0,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.isAccommodation)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Divider(color: Colors.white.withValues(alpha: 0.15)),
            ),
          Text(
            block.title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontStyle:
                  block.isAccommodation ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (block.subtitle != null && block.subtitle!.trim().isNotEmpty)
            Text(
              block.subtitle!,
              style: GoogleFonts.poppins(fontSize: 12, color: _textTertiary),
            ),
          if (block.links.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                spacing: 12,
                runSpacing: 2,
                children: [
                  for (final link in block.links)
                    InkWell(
                      onTap: () => _openWebUrl(link.url),
                      child: Text(
                        link.label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColorScheme.color2,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColorScheme.color2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _shareSummaryContent(
    AppLocalizations loc,
    PlanSummaryShareContent content,
  ) async {
    final subject = loc.myPlanSummaryShareSubject(content.planName);
    final markdown = content.toMarkdown();
    final htmlBytes = content.toHtmlBytes();
    final safeName = content.planName
        .replaceAll(RegExp(r'[^\w\-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final fileName =
        'resumen_${safeName.isEmpty ? 'plan' : safeName}.html';

    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      await Share.shareXFiles(
        [
          XFile.fromData(
            htmlBytes,
            mimeType: 'text/html',
            name: fileName,
          ),
        ],
        subject: subject,
        text: markdown,
        sharePositionOrigin: origin,
      );
    } catch (_) {
      try {
        await Share.share(
          markdown,
          subject: subject,
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.myPlanSummaryShareFailed)),
        );
      }
    }
  }

  Widget _buildViewModeChip(String label, bool selected, VoidCallback onTap) {
    return Material(
      color: selected ? AppColorScheme.color2 : _surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : _textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _showSummaryDetailSheet(BuildContext context, String title, Widget body) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _pageBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 4, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white70,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: _border,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: body,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Ítem 75: accesos Importante / Participantes / hoy / mañana en una fila → modal.
  // ignore: unused_element
  Widget _buildSummaryQuickAccessRow(
    BuildContext context,
    AppLocalizations loc, {
    required int participantCount,
    required bool isPlanInCourse,
    required DateTime today,
    required DateTime tomorrow,
    required List<Event> todayEvents,
    required List<Event> tomorrowEvents,
    required bool showParticipantLabels,
    required Map<String, String> participantNamesMap,
    required bool dimPastInCourse,
  }) {
    final planId = widget.plan.id;
    final entries = <({IconData icon, String label, String modalTitle, Widget body})>[];

    entries.add((
      icon: Icons.info_outline,
      label: loc.myPlanSummaryQuickImportant,
      modalTitle: loc.myPlanSummaryImportant,
      body: _buildImportantBlockContent(loc, participantCount),
    ));
    if (planId != null) {
      entries.add((
        icon: Icons.people_outline,
        label: loc.myPlanSummaryQuickParticipants,
        modalTitle: loc.myPlanSummaryParticipantsSection,
        body: ParticipantsListWidget(
          planId: planId,
          showActions: false,
          compact: true,
        ),
      ));
    }
    if (isPlanInCourse) {
      entries.add((
        icon: Icons.wb_sunny_outlined,
        label: loc.myPlanSummaryQuickToday,
        modalTitle: '${loc.myPlanSummaryToday} · ${DateFormatter.formatDate(today)}',
        body: _buildDayBlockContent(
          todayEvents,
          showParticipantLabels,
          participantNamesMap,
          loc,
          dimPastInCourse: dimPastInCourse,
        ),
      ));
      entries.add((
        icon: Icons.nights_stay_outlined,
        label: loc.myPlanSummaryQuickTomorrow,
        modalTitle: '${loc.myPlanSummaryTomorrow} · ${DateFormatter.formatDate(tomorrow)}',
        body: _buildDayBlockContent(
          tomorrowEvents,
          showParticipantLabels,
          participantNamesMap,
          loc,
          dimPastInCourse: dimPastInCourse,
        ),
      ));
    }

    final rowChildren = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      if (i > 0) {
        rowChildren.add(
          Container(
            width: 1,
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: _border,
          ),
        );
      }
      final e = entries[i];
      rowChildren.add(
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSummaryDetailSheet(context, e.modalTitle, e.body),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(e.icon, color: AppColorScheme.color2, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      e.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(children: rowChildren),
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
              color: _textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              loc.myPlanSummaryEmpty,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: _textSecondary,
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
      backgroundColor: _pageBg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.event,
                color: Colors.white,
              ),
              title: Text(
                loc.createEvent,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                widget.onRequestCreateEvent?.call();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.hotel_outlined,
                color: Colors.white,
              ),
              title: Text(
                loc.tooltipCreateAccommodation,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
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
  // ignore: unused_element
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
                      color: framed
                          ? AppColorScheme.color2
                          : Colors.white,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 26,
              color: _textSecondary,
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
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (expanded) ...[
            Divider(
              height: 1,
              color: _border,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  /// Contenido del bloque "Lo más importante" (ítem 74: nombre, fechas, estado, participantes).
  Widget _buildImportantBlockContent(AppLocalizations loc, int participantCount) {
    final plan = widget.plan;
    final stateLabel =
        PlanStateService.getStateDisplayInfo(plan.state)['label'] as String;
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          stateLabel,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.myPlanSummaryParticipantsCount(participantCount),
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  /// Contenido de un bloque de día (Hoy/Mañana): lista de eventos o "—".
  Widget _buildDayBlockContent(
    List<Event> events,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap,
    AppLocalizations loc, {
    required bool dimPastInCourse,
  }) {
    if (events.isEmpty) {
      return Text(
        '—',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: _textTertiary,
        ),
      );
    }
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: events
          .map((e) {
            final subtitle = showParticipantLabels ? _participantLabelForEvent(e, participantNamesMap, loc) : null;
            final code = _transportCodeLabel(e);
            final head = code != null
                ? '${_formatEventTime(e, loc)} $code · ${e.description}'
                : '${_formatEventTime(e, loc)} ${e.description}';
            final past = dimPastInCourse && _isEventPast(e, now);
            final typeBadge = _inlineTypeBadge(e, loc);
            return _buildSummaryLinkRow(
              text: head,
              onOpenDetail: widget.onOpenEvent != null ? () => widget.onOpenEvent!(e) : null,
              mapsQuery: e.commonPart?.location,
              routeUrl: PlanSummaryShareContent.eventRouteUrl(e),
              webUrl: e.commonPart?.url,
              leadingIcon: _eventTypeIcon(e),
              subtitle: subtitle,
              subtitleEmphasizeAll: showParticipantLabels && e.participantTrackIds.isEmpty,
              mutedPast: past,
              typeBadgeIcon: typeBadge?.icon,
              typeBadgeTooltip: typeBadge?.tooltip,
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

  /// Hora de inicio o rango inicio–fin; ítem 72: cruces de medianoche con sufijo (+1).
  String _formatEventTime(Event e, AppLocalizations loc) {
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

  /// Fila de itinerario (altura fija): icono · [hora] · título · Maps/Web reservados.
  static const double _summaryRowHeight = 48;
  static const double _summaryLinkChipSize = 26;
  static const double _summaryLinkChipIconSize = 15;
  static const double _summaryLinkChipGap = 4;
  static const double _summaryTimeColWidth = 82;
  static const double _summaryLeadingIconWidth = 22;
  static const double _summaryRowGap = 2;

  /// Fila de resumen con hasta 3 acciones: detalle interno, Maps/ruta y URL.
  Widget _buildSummaryLinkRow({
    required String text,
    VoidCallback? onOpenDetail,
    String? mapsQuery,
    String? routeUrl,
    String? webUrl,
    IconData? leadingIcon,
    String? timeLabel,
    String? subtitle,
    /// Lista §3.2 ítem 78: evento/alojamiento para todos los participantes.
    bool subtitleEmphasizeAll = false,
    /// Ítem 69: plan en curso, evento ya pasado.
    bool mutedPast = false,
    /// Plan en curso: evento actual / siguiente del día.
    bool isCurrent = false,
    /// Mostrar etiqueta «ahora» (solo si el evento está en curso ahora).
    bool showNowLabel = false,
    bool showDraftBadge = false,
    /// Icono compacto (18×18, como badge B) + tooltip (desplazamiento, restauración…).
    IconData? typeBadgeIcon,
    String? typeBadgeTooltip,
    /// Mostrar icono líder también en móvil (p. ej. alojamiento).
    bool forceShowLeadingIcon = false,
  }) {
    final loc = AppLocalizations.of(context)!;
    final hasRoute = routeUrl != null && routeUrl.trim().isNotEmpty;
    final hasMaps =
        !hasRoute && mapsQuery != null && mapsQuery.trim().isNotEmpty;
    final hasWebUrl = webUrl != null && webUrl.trim().isNotEmpty;
    final safeMapsQuery = mapsQuery ?? '';
    final safeRouteUrl = routeUrl ?? '';
    final safeWebUrl = webUrl ?? '';
    final accent = AppColorScheme.color2;
    final titleColor = isCurrent
        ? accent
        : (mutedPast
            ? _textMuted
            : (onOpenDetail != null ? AppColorScheme.color2 : _textSecondary));
    final subColor = mutedPast
        ? _textMuted
        : (subtitleEmphasizeAll ? Colors.orange.shade200 : _textTertiary);
    final subWeight = mutedPast
        ? FontWeight.w400
        : (subtitleEmphasizeAll ? FontWeight.w600 : FontWeight.w400);
    final iconColor = mutedPast ? _textMuted : _textTertiary;
    final timeColor = isCurrent
        ? accent
        : (mutedPast ? _textMuted : _textSecondary);
    final hasSubtitle = subtitle != null && subtitle.isNotEmpty;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final showLeadingIcon =
        leadingIcon != null && (!isMobile || forceShowLeadingIcon);
    final showTypeBadge = typeBadgeIcon != null;
    final typeBadgeColor = mutedPast ? _textMuted : AppColorScheme.color2;

    return Padding(
      padding: const EdgeInsets.only(bottom: _summaryRowGap),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isCurrent ? accent.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isCurrent
              ? Border.all(color: accent.withValues(alpha: 0.65), width: 1.2)
              : null,
        ),
        child: SizedBox(
          height: isCurrent ? _summaryRowHeight + 12 : _summaryRowHeight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOpenDetail,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isCurrent ? 8 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isCurrent) ...[
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          border: Border.all(color: accent, width: 2),
                        ),
                      ),
                    ],
                    if (showLeadingIcon) ...[
                      SizedBox(
                        width: _summaryLeadingIconWidth,
                        child: Icon(leadingIcon, size: 18, color: iconColor),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (timeLabel != null) ...[
                      SizedBox(
                        width: _summaryTimeColWidth,
                        child: Text(
                          timeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: isCurrent ? 13 : 12,
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w400,
                            color: timeColor,
                            height: 1.2,
                          ),
                          textHeightBehavior: _tightFirstLineHeight,
                        ),
                      ),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (showNowLabel)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                'ahora',
                                style: GoogleFonts.poppins(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                          if (showDraftBadge) ...[
                            Tooltip(
                              message: loc.eventStatusDraft,
                              child: Container(
                                width: 18,
                                height: 18,
                                margin: const EdgeInsets.only(right: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade800
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.orange.shade300
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                child: Text(
                                  loc.myPlanSummaryDraftBadgeLetter,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange.shade100,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (showTypeBadge) ...[
                            Tooltip(
                              message: typeBadgeTooltip ?? '',
                              child: Container(
                                width: 18,
                                height: 18,
                                margin: const EdgeInsets.only(right: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: typeBadgeColor.withValues(
                                    alpha: mutedPast ? 0.15 : 0.22,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: typeBadgeColor.withValues(
                                      alpha: mutedPast ? 0.35 : 0.55,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  typeBadgeIcon,
                                  size: 12,
                                  color: mutedPast
                                      ? _textMuted
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              text,
                              maxLines: hasSubtitle ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: timeLabel != null ? 14 : 13,
                                color: titleColor,
                                height: 1.2,
                              ),
                              textHeightBehavior: _tightFirstLineHeight,
                            ),
                          ),
                        ],
                      ),
                      if (hasSubtitle) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: subColor,
                            fontWeight: subWeight,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasRoute || hasMaps || hasWebUrl) ...[
                  const SizedBox(width: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasRoute)
                        SizedBox(
                          width: _summaryLinkChipSize,
                          height: _summaryLinkChipSize,
                          child: Tooltip(
                            message: loc.openRouteInGoogleMaps,
                            child: _buildMapLinkChip(
                              onTap: () => _openWebUrl(safeRouteUrl),
                              icon: Icons.route,
                            ),
                          ),
                        ),
                      if (hasRoute && (hasMaps || hasWebUrl))
                        const SizedBox(width: _summaryLinkChipGap),
                      if (hasMaps)
                        SizedBox(
                          width: _summaryLinkChipSize,
                          height: _summaryLinkChipSize,
                          child: _buildMapLinkChip(
                            onTap: () => _openMapsQuery(safeMapsQuery),
                          ),
                        ),
                      if (hasMaps && hasWebUrl)
                        const SizedBox(width: _summaryLinkChipGap),
                      if (hasWebUrl)
                        SizedBox(
                          width: _summaryLinkChipSize,
                          height: _summaryLinkChipSize,
                          child: _buildWebLinkChip(
                            onTap: () => _openWebUrl(safeWebUrl),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }

  Color get _linkChipIconColor => AppColorScheme.color2;

  Widget _buildMapLinkChip({
    required VoidCallback onTap,
    IconData icon = Icons.location_on,
  }) {
    return Material(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColorScheme.color2.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Icon(
            icon,
            size: _summaryLinkChipIconSize,
            color: _linkChipIconColor,
          ),
        ),
      ),
    );
  }

  /// Misma huella visual que [_buildMapLinkChip] (lista §3.2 ítem 83).
  Widget _buildWebLinkChip({required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColorScheme.color2.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Icon(
            Icons.public,
            size: _summaryLinkChipIconSize,
            color: _linkChipIconColor,
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

  bool _isDisplacementEvent(Event e) {
    final fam = (e.typeFamily ?? '').toLowerCase();
    return fam.contains('desplazamiento') || fam.contains('desplaz');
  }

  bool _isDiningEvent(Event e) {
    final fam = (e.typeFamily ?? '').toLowerCase();
    final sub = (e.typeSubtype ?? '').toLowerCase();
    return fam.contains('restauración') ||
        fam.contains('restauracion') ||
        sub.contains('comida') ||
        sub.contains('restaurant') ||
        sub.contains('restauración') ||
        sub.contains('restauracion');
  }

  /// Badge inline 18×18 (como la B) para tipos que conviene destacar.
  ({IconData icon, String tooltip})? _inlineTypeBadge(
    Event e,
    AppLocalizations loc,
  ) {
    if (_isDisplacementEvent(e)) {
      return (icon: _eventTypeIcon(e), tooltip: loc.myPlanSummaryFlights);
    }
    if (_isDiningEvent(e)) {
      return (
        icon: Icons.restaurant,
        tooltip: loc.planEventColorsFamilyRestauracion,
      );
    }
    return null;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  /// Noches de estancia: [checkIn, checkOut). Si misma fecha, solo ese día.
  Iterable<DateTime> _accommodationStayDays(Accommodation a) sync* {
    var d = _dateOnly(a.checkIn);
    final end = _dateOnly(a.checkOut);
    if (!end.isAfter(d)) {
      yield d;
      return;
    }
    while (d.isBefore(end)) {
      yield d;
      d = d.add(const Duration(days: 1));
    }
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

  List<DateTime> _planDayRange(
    List<Event> events,
    List<Accommodation> accommodations,
  ) {
    final start = _dateOnly(widget.plan.startDate);
    final end = _dateOnly(widget.plan.endDate);
    if (!end.isBefore(start)) {
      final days = <DateTime>[];
      var d = start;
      while (!d.isAfter(end)) {
        days.add(d);
        d = DateTime(d.year, d.month, d.day + 1);
      }
      return days;
    }
    return _buildDayEntries(events, accommodations).map((e) => e.day).toList();
  }

  DateTime? _resolveSelectedDay(List<DateTime> days) {
    if (days.isEmpty) return null;
    if (_selectedDay != null &&
        days.any((d) => _dayKey(d) == _dayKey(_selectedDay!))) {
      return _selectedDay;
    }
    final today = _dateOnly(DateTime.now());
    for (final d in days) {
      if (_dayKey(d) == _dayKey(today)) return d;
    }
    return days.first;
  }

  void _selectDay(List<DateTime> days, int index) {
    if (index < 0 || index >= days.length) return;
    final day = days[index];
    if (_selectedDay != null && _dayKey(_selectedDay!) == _dayKey(day)) return;
    setState(() => _selectedDay = day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dayChipsScrollController.hasClients) return;
      const chipWidth = 72.0;
      final target = (index * chipWidth) - 48;
      _dayChipsScrollController.animateTo(
        target.clamp(0.0, _dayChipsScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  void _shiftSelectedDay(List<DateTime> days, int delta) {
    if (days.isEmpty) return;
    final current = _resolveSelectedDay(days);
    if (current == null) return;
    final idx = days.indexWhere((d) => _dayKey(d) == _dayKey(current));
    if (idx < 0) return;
    _selectDay(days, idx + delta);
  }

  Widget _buildDaySelector(List<DateTime> days) {
    if (days.isEmpty) return const SizedBox.shrink();
    final localeTag = Localizations.localeOf(context).toString();
    final today = _dateOnly(DateTime.now());
    final selected = _resolveSelectedDay(days);
    final selectedKey = selected != null ? _dayKey(selected) : null;

    return SizedBox(
      height: 72,
      child: ListView.separated(
        controller: _dayChipsScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = selectedKey == _dayKey(day);
          final isToday = _dayKey(day) == _dayKey(today);
          final weekdayShort =
              DateFormat.E(localeTag).format(day).replaceAll('.', '');
          final bg = selected ? AppColorScheme.color2 : _surface;
          return Material(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _selectDay(days, index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !selected
                      ? Border.all(color: AppColorScheme.color2, width: 1.4)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekdayShort.toLowerCase(),
                      style: GoogleFonts.poppins(
                        color: selected ? Colors.white : _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: GoogleFonts.poppins(
                        color: selected ? Colors.white : Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 2),
                      Text(
                        'hoy',
                        style: GoogleFonts.poppins(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.9)
                              : AppColorScheme.color2,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateActionsRow({
    required AppLocalizations loc,
    required DateTime day,
    required VoidCallback onOpenMap,
  }) {
    final localeTag = Localizations.localeOf(context).toString();
    final fullDate = DateFormat.yMMMMEEEEd(localeTag).format(day);
    final isToday = _dayKey(day) == _dayKey(DateTime.now());
    final canCreate = widget.onRequestCreateEvent != null &&
        widget.onRequestCreateAccommodation != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(text: fullDate.toLowerCase()),
                  if (isToday)
                    TextSpan(
                      text: ' · hoy',
                      style: GoogleFonts.poppins(
                        color: AppColorScheme.color2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: loc.planMapTooltip,
            onPressed: onOpenMap,
            icon: Icon(Icons.map_outlined, color: AppColorScheme.color2),
          ),
          if (canCreate) ...[
            const SizedBox(width: 4),
            Material(
              color: AppColorScheme.color3,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _showCreateChooser(context, loc),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDayContent(
    BuildContext context,
    AppLocalizations loc,
    DateTime day,
    List<Event> allEvents,
    List<Accommodation> allAccommodations,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap, {
    required bool dimPastInCourse,
  }) {
    final dayKey = _dayKey(day);
    final events = allEvents
        .where((e) => _dayKey(_dateOnly(e.date)) == dayKey)
        .toList()
      ..sort(_compareEventsBySchedule);
    final accommodations = allAccommodations
        .where((a) =>
            _accommodationStayDays(a).any((d) => _dayKey(d) == dayKey))
        .toList();
    final now = DateTime.now();
    final today = _dateOnly(now);
    final emphasizeCurrent =
        dimPastInCourse && _dayKey(day) == _dayKey(today);
    Event? happeningNow;
    if (emphasizeCurrent) {
      for (final e in events) {
        if (_isEventHappeningNow(e, now)) {
          happeningNow = e;
          break;
        }
      }
    }
    final highlight = emphasizeCurrent
        ? (happeningNow ?? _currentOrNextEvent(events, now))
        : null;
    final highlightId = highlight?.id;
    final showNowLabel =
        happeningNow != null && highlight?.id == happeningNow.id;

    if (events.isEmpty && accommodations.isEmpty) {
      return _buildEmptyDay(loc);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final e in events)
          _buildEventDayRow(
            loc,
            e,
            showParticipantLabels,
            participantNamesMap,
            dimPastInCourse: dimPastInCourse,
            now: now,
            isCurrent: highlightId != null && e.id == highlightId,
            showNowLabel: showNowLabel && e.id == highlightId,
          ),
        for (final a in accommodations)
          _buildNightStayRow(
            loc,
            a,
            day,
            showParticipantLabels,
            participantNamesMap,
          ),
      ],
    );
  }

  Widget _buildEmptyDay(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 36,
            color: AppColorScheme.color2.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'nada previsto este día',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'usa + para crear un evento o un alojamiento',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightStayRow(
    AppLocalizations loc,
    Accommodation a,
    DateTime day,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap,
  ) {
    final badgeColor = _stayMarkerColor(day);
    final subtitleParts = <String>[];
    if (showParticipantLabels) {
      subtitleParts.add(
        _participantLabelForAccommodation(a, participantNamesMap, loc),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            _stayHBadge(badgeColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'esta noche · ${a.hotelName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitleParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.onOpenAccommodation != null)
              IconButton(
                tooltip: loc.planMapTooltip,
                onPressed: () => widget.onOpenAccommodation!(a),
                icon: Icon(
                  Icons.chevron_right,
                  color: AppColorScheme.color2,
                  size: 20,
                ),
              )
            else if ((a.commonPart?.address ?? '').trim().isNotEmpty)
              Icon(
                Icons.place_outlined,
                size: 18,
                color: AppColorScheme.color2,
              ),
          ],
        ),
      ),
    );
  }

  List<({DateTime day, List<Accommodation> accommodations, List<Event> events})>
      _buildDayEntries(
    List<Event> events,
    List<Accommodation> accommodations,
  ) {
    final map = <DateTime, ({List<Accommodation> accommodations, List<Event> events})>{};

    void ensure(DateTime day) {
      map.putIfAbsent(
        day,
        () => (accommodations: <Accommodation>[], events: <Event>[]),
      );
    }

    for (final a in accommodations) {
      for (final day in _accommodationStayDays(a)) {
        ensure(day);
        map[day]!.accommodations.add(a);
      }
    }
    for (final e in events) {
      final day = _dateOnly(e.date);
      ensure(day);
      map[day]!.events.add(e);
    }

    final days = map.keys.toList()..sort();
    return [
      for (final day in days)
        (
          day: day,
          accommodations: map[day]!.accommodations,
          events: map[day]!.events,
        ),
    ];
  }

  // ignore: unused_element — legacy collapsible kept for reference during reorg
  Widget _buildCollapsibleDaySection(
    BuildContext context,
    AppLocalizations loc,
    ({DateTime day, List<Accommodation> accommodations, List<Event> events}) entry,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap, {
    required bool dimPastInCourse,
  }) {
    final localeTag = Localizations.localeOf(context).toString();
    final dayLabel = DateFormat.yMMMMEEEEd(localeTag).format(entry.day);
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                dayLabel,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: _border),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final e in entry.events)
                    _buildEventDayRow(
                      loc,
                      e,
                      showParticipantLabels,
                      participantNamesMap,
                      dimPastInCourse: dimPastInCourse,
                      now: now,
                    ),
                  if (entry.accommodations.isNotEmpty) ...[
                    _stayListHeader(loc),
                    for (final a in entry.accommodations)
                      _buildAccommodationDayRow(
                        loc,
                        a,
                        entry.day,
                        showParticipantLabels,
                        participantNamesMap,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stayListHeader(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
      child: Row(
        children: [
          const Icon(
            Icons.hotel_outlined,
            size: 14,
            color: _textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            loc.planMapLegendHotel.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _stayMarkerColor(DateTime day) {
    final start = _dateOnly(widget.plan.startDate);
    final index = _dateOnly(day).difference(start).inDays;
    final hex = PlanMapDayColors.hexForDay(index).replaceFirst('#', '');
    if (hex.length != 6) return AppColorScheme.color2;
    return Color(int.parse('FF$hex', radix: 16));
  }

  Widget _stayHBadge(Color color) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        'H',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAccommodationDayRow(
    AppLocalizations loc,
    Accommodation a,
    DateTime day,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap,
  ) {
    final stayDays = _accommodationStayDays(a).toList();
    final total = stayDays.isEmpty ? 1 : stayDays.length;
    final dayOnly = _dateOnly(day);
    var current = stayDays.indexWhere((d) => d == dayOnly) + 1;
    if (current <= 0) current = 1;

    final parts = <String>[
      loc.myPlanSummaryAccommodationRowLabel,
      loc.myPlanSummaryAccommodationNightOf(current, total),
    ];
    if (showParticipantLabels) {
      parts.add(_participantLabelForAccommodation(a, participantNamesMap, loc));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _stayHBadge(_stayMarkerColor(day)),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryLinkRow(
            text: a.hotelName,
            leadingIcon: Icons.hotel_outlined,
            forceShowLeadingIcon: true,
            onOpenDetail: widget.onOpenAccommodation != null
                ? () => widget.onOpenAccommodation!(a)
                : null,
            mapsQuery: a.commonPart?.address,
            webUrl: a.commonPart?.url,
            subtitle: parts.join(' · '),
            subtitleEmphasizeAll:
                showParticipantLabels && a.participantTrackIds.isEmpty,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDayRow(
    AppLocalizations loc,
    Event e,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap, {
    required bool dimPastInCourse,
    required DateTime now,
    bool isCurrent = false,
    bool showNowLabel = false,
  }) {
    final participantLabel = showParticipantLabels
        ? _participantLabelForEvent(e, participantNamesMap, loc)
        : null;
    final past = dimPastInCourse && _isEventPast(e, now) && !isCurrent;
    final isDraft = e.isDraft || (e.commonPart?.isDraft == true);
    final typeBadge = _inlineTypeBadge(e, loc);
    return _buildSummaryLinkRow(
      text: _chronologicalEventTitle(e),
      timeLabel: _formatEventTime(e, loc),
      leadingIcon: _eventTypeIcon(e),
      onOpenDetail:
          widget.onOpenEvent != null ? () => widget.onOpenEvent!(e) : null,
      mapsQuery: e.commonPart?.location,
      routeUrl: PlanSummaryShareContent.eventRouteUrl(e),
      webUrl: e.commonPart?.url,
      subtitle: participantLabel,
      subtitleEmphasizeAll:
          showParticipantLabels && e.participantTrackIds.isEmpty,
      mutedPast: past,
      isCurrent: isCurrent,
      showNowLabel: showNowLabel,
      showDraftBadge: isDraft,
      typeBadgeIcon: typeBadge?.icon,
      typeBadgeTooltip: typeBadge?.tooltip,
    );
  }
}
