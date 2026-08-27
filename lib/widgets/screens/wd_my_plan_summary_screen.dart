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
import 'package:unp_calendario/features/calendar/domain/services/plan_state_service.dart';
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

  static const int _chronoLimit = 15;
  bool _chronoExpanded = false;
  /// Días plegados en el itinerario (clave yyyy-MM-dd). Vacío = todos desplegados.
  final Set<String> _collapsedDayKeys = {};
  /// 'mine' = solo mis eventos; 'plan' = todos los participantes.
  String _internalViewMode = 'mine';
  /// Ítem 81: en planificando, mostrar solo eventos borrador / no confirmados.
  bool _internalDraftOnlyFilter = false;

  String get _viewMode => widget.viewMode ?? _internalViewMode;
  bool get _draftOnlyFilter => widget.draftOnlyFilter ?? _internalDraftOnlyFilter;

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
    final endMin = e.durationMinutes > 0 ? startMin + e.durationMinutes : startMin;
    final nowMin = now.hour * 60 + now.minute;
    return endMin < nowMin;
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
        );

        final isEmpty = displayEvents.isEmpty && displayAccommodations.isEmpty;
        final showParticipantLabels = _viewMode == 'plan';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showTopSummaryBar) bar,
            Expanded(
              child: ColoredBox(
                color: Colors.transparent,
                child: isEmpty
                    ? _buildEmptyState(loc)
                    : Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                          children: [
                            _buildChronologicalSectionBody(
                              context,
                              loc,
                              displayEvents,
                              displayAccommodations,
                              showParticipantLabels,
                              participantNamesMap,
                              dimPastInCourse: dimPastInCourse,
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
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

  /// Barra superior: título, filtro borradores (ítem 81) y selector mío/todos.
  Widget _buildSummaryBar({
    required AppLocalizations loc,
    required String viewMode,
    required void Function(String) onViewModeChanged,
    required bool showDraftFilter,
    required bool draftsOnlyActive,
    required VoidCallback onDraftOnlyToggle,
    VoidCallback? onShare,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColorScheme.color2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
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
          if (showDraftFilter) ...[
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
          const SizedBox(width: 4),
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
    final titleColor = mutedPast
        ? _textMuted
        : (onOpenDetail != null ? AppColorScheme.color2 : _textSecondary);
    final subColor = mutedPast
        ? _textMuted
        : (subtitleEmphasizeAll ? Colors.orange.shade200 : _textTertiary);
    final subWeight = mutedPast
        ? FontWeight.w400
        : (subtitleEmphasizeAll ? FontWeight.w600 : FontWeight.w400);
    final iconColor = mutedPast ? _textMuted : _textTertiary;
    final timeColor = mutedPast ? _textMuted : _textSecondary;
    final hasSubtitle = subtitle != null && subtitle.isNotEmpty;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final showLeadingIcon =
        leadingIcon != null && (!isMobile || forceShowLeadingIcon);
    final showTypeBadge = typeBadgeIcon != null;
    final typeBadgeColor = mutedPast ? _textMuted : AppColorScheme.color2;

    return Padding(
      padding: const EdgeInsets.only(bottom: _summaryRowGap),
      child: SizedBox(
        height: _summaryRowHeight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpenDetail,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                        fontSize: 12,
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

  Widget _buildChronologicalSectionBody(
    BuildContext context,
    AppLocalizations loc,
    List<Event> events,
    List<Accommodation> accommodations,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap, {
    required bool dimPastInCourse,
  }) {
    final dayEntries = _buildDayEntries(events, accommodations);
    if (dayEntries.isEmpty) {
      return Text(
        '—',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: _textTertiary,
        ),
      );
    }

    final showLimit = dayEntries.length > _chronoLimit && !_chronoExpanded;
    final displayDays =
        showLimit ? dayEntries.take(_chronoLimit).toList() : dayEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...displayDays.map(
          (entry) => _buildCollapsibleDaySection(
            context,
            loc,
            entry,
            showParticipantLabels,
            participantNamesMap,
            dimPastInCourse: dimPastInCourse,
          ),
        ),
        if (dayEntries.length > _chronoLimit)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton(
              onPressed: () =>
                  setState(() => _chronoExpanded = !_chronoExpanded),
              child: Text(
                _chronoExpanded
                    ? loc.myPlanSummarySeeLess
                    : loc.myPlanSummarySeeMore,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColorScheme.color2,
                ),
              ),
            ),
          ),
      ],
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

  Widget _buildCollapsibleDaySection(
    BuildContext context,
    AppLocalizations loc,
    ({DateTime day, List<Accommodation> accommodations, List<Event> events}) entry,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap, {
    required bool dimPastInCourse,
  }) {
    final localeTag = Localizations.localeOf(context).toString();
    final key = _dayKey(entry.day);
    final expanded = !_collapsedDayKeys.contains(key);
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
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (expanded) {
                      _collapsedDayKeys.add(key);
                    } else {
                      _collapsedDayKeys.remove(key);
                    }
                  });
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dayLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: _textSecondary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (expanded) ...[
              Divider(height: 1, thickness: 1, color: _border),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final a in entry.accommodations)
                      _buildAccommodationDayRow(
                        loc,
                        a,
                        entry.day,
                        showParticipantLabels,
                        participantNamesMap,
                      ),
                    for (final e in entry.events)
                      _buildEventDayRow(
                        loc,
                        e,
                        showParticipantLabels,
                        participantNamesMap,
                        dimPastInCourse: dimPastInCourse,
                        now: now,
                      ),
                  ],
                ),
              ),
            ],
          ],
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
    return _buildSummaryLinkRow(
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
    );
  }

  Widget _buildEventDayRow(
    AppLocalizations loc,
    Event e,
    bool showParticipantLabels,
    Map<String, String> participantNamesMap, {
    required bool dimPastInCourse,
    required DateTime now,
  }) {
    final participantLabel = showParticipantLabels
        ? _participantLabelForEvent(e, participantNamesMap, loc)
        : null;
    final past = dimPastInCourse && _isEventPast(e, now);
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
      showDraftBadge: isDraft,
      typeBadgeIcon: typeBadge?.icon,
      typeBadgeTooltip: typeBadge?.tooltip,
    );
  }
}
