import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/constants.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';

/// Tokens UI-ST (docs/guias/GUIA_UI.md) — página de laboratorio alineada al estándar.
class _UiSt {
  static const Color cPageBg = Color(0xFF111827);
  static const Color cSurfaceBg = Color(0xFF1F2937);

  static const Color cTextPrimary = Colors.white;
  static const Color cTextSecondary = Colors.white70;
  static const Color cTextTertiary = Colors.white60;

  static Color get cAccent => AppColorScheme.color2;

  /// Blanco canal alfa estándar (no usar grises Material sobre oscuro).
  static Color borderStrong() => Colors.white.withValues(alpha: aBorderStrong);
  static Color borderSubtle() => Colors.white.withValues(alpha: aBorderSubtle);

  static const double aBorderStrong = 0.12;
  static const double aBorderSubtle = 0.08;
  static const double aSurfaceMuted = 0.04;
  static const double aSurfaceChip = 0.06;
  static const double aAccentSelected = 0.32;

  static const double rCard = 12;
  static const double rInner = 8;

  static const double fsAppBar = 16;
  static const double fsSectionTitle = 12;
  static const double fsSectionSubtitle = 11;
  static const double fsControl = 12;
}

/// Misma métrica vertical que la cuadrícula del calendario (`AppConstants.cellHeight`).
class _LabTimeline {
  static const int startHour = 8;

  /// Rótulos finales inclusivos 08 … 16; cuerpo = nueve alturas tipo hora (`cellHeight`).
  static const int endHourExclusive = 17;

  static int get visibleHourCount => endHourExclusive - startHour;

  static int get startMinuteOfDay => startHour * 60;

  static double get bodyHeightPx => visibleHourCount * AppConstants.cellHeight;
}

String _labFormatClockRangeMinuteOfDay(int startMinute, int durationMinutes) {
  String hm(int minuteOfDay) {
    final h = minuteOfDay ~/ 60;
    final m = minuteOfDay % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  final end = startMinute + durationMinutes;
  return '${hm(startMinute)}-${hm(end)}';
}

int _ceilShare(int roster, int num, int den) {
  if (den <= 0) return roster;
  return (roster * num + den - 1) ~/ den;
}

Color _accentForCoverageTier(int tier) {
  switch (tier.clamp(0, 3)) {
    case 0:
      return AppColorScheme.color2;
    case 1:
      return AppColorScheme.color3;
    case 2:
      return AppColorScheme.color4;
    case 3:
      return AppColorScheme.interactiveColor;
    default:
      return AppColorScheme.interactiveColor;
  }
}

/// Cuánta etiqueta mostrar en el lab según strip (días × roster) y anchura del evento.
enum _LabCardPresentation { full, compact, glyph, swatch }

_LabCardPresentation _labCardPresentation(int days, int roster, int spanCols) {
  final n = roster.clamp(1, 99);
  final span = spanCols.clamp(1, n);

  final dayPart = days <= 1 ? 0 : (days <= 3 ? 1 : 2);
  final rosterPart = n <= 2
      ? 0
      : (n <= 4 ? 1 : (n <= 7 ? 2 : 3));
  final grid = dayPart + rosterPart;

  var spanPenalty = 0;
  if (n > 1 && span < n) {
    final r = span / n;
    if (r <= 0.12) {
      spanPenalty = 4;
    } else if (r <= 0.30) {
      spanPenalty = 3;
    } else if (r <= 0.55) {
      spanPenalty = 2;
    } else {
      spanPenalty = 1;
    }
  }

  final score = grid + spanPenalty;
  // Swatch sólo ante grid muy cargado + franja muy estrecha (p. ej. 7×10 roster, 1 columna → 9).
  if (score >= 9) return _LabCardPresentation.swatch;
  if (score >= 6) return _LabCardPresentation.glyph;
  if (score >= 4) return _LabCardPresentation.compact;
  return _LabCardPresentation.full;
}

/// Laboratorio temporal (web escritorio): comparar opciones visuales de tarjetas
/// de evento según número de columnas por día y días visibles en el strip.
///
/// Acceso desde W1 → icono de diseño (`/demo/calendar-event-cards-lab`).
/// Matriz orientativa por caso (días × participantes × nivel): ver
/// `docs/guias/LAB_TARJETAS_EVENTO_CALENDARIO_CASOS.md`.
class CalendarEventCardsLabPage extends StatefulWidget {
  const CalendarEventCardsLabPage({super.key});

  @override
  State<CalendarEventCardsLabPage> createState() =>
      _CalendarEventCardsLabPageState();
}

class _CalendarEventCardsLabPageState extends State<CalendarEventCardsLabPage> {
  int _visibleDays = 3;
  int _participantCount = 4;

  static const List<int> _dayOptions = [1, 3, 7];
  static const List<int> _participantOptions = [1, 2, 3, 4, 5, 10];

  static const List<_CardLabStyleMeta> _styles = [
    _CardLabStyleMeta(
      style: _CardLabStyle.filledClassic,
      title: 'A · Relleno sobre acento (UI-ST)',
      subtitle:
          'cAccent de fondo, texto cTextPrimary, radio estándar 12; primario contenido.',
    ),
    _CardLabStyleMeta(
      style: _CardLabStyle.outlineRail,
      title: 'B · Superficie + carril semántico (UI-ST)',
      subtitle:
          'cSurfaceBg, borde único alpha 0.12, carril acento composición aparte.',
    ),
    _CardLabStyleMeta(
      style: _CardLabStyle.chipDense,
      subtitle:
          'Chip horario con alpha superficie chip 0.06 y borde 0.12; Poppins 12.',
      title: 'C · Compacta con chip de hora (UI-ST)',
    ),
    _CardLabStyleMeta(
      style: _CardLabStyle.multiTrackGradient,
      title: 'D · Tint tenue superficie (UI-ST)',
      subtitle:
          'Sin gradientes fuertes: mezcla mínima cAccent sobre cSurfaceBg.',
    ),
    _CardLabStyleMeta(
      style: _CardLabStyle.splitTimeRow,
      title: 'E · Split tiempo / texto (UI-ST)',
      subtitle: 'cSurfaceBg; tiempo en mono, jerarquía título/subtítulo 12/11.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: _UiSt.cPageBg,
            appBar: AppBar(
              backgroundColor: _UiSt.cPageBg,
              foregroundColor: _UiSt.cTextPrimary,
              elevation: 0,
              title: Text(
                'Lab · Tarjetas de evento (UI-ST)',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: _UiSt.fsAppBar,
                  color: _UiSt.cTextPrimary,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(_UiSt.fsSectionSubtitle,
                  _UiSt.fsSectionTitle, _UiSt.fsSectionSubtitle, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Vista alineada a tokens GUÍA_UI (UI-ST). Anchos sintéticos: '
                        '100 %, ceil(50 %), ceil(25 %), ceil(5 %) del roster (participantes). '
                        'Altura de cada hora igual que en calendario (${AppConstants.cellHeight}px / h). '
                        'La etiqueta por bloque depende también de días, roster y anchura del evento; '
                        'en situaciones muy densas sólo verás el bloque en color. '
                        'Menú contextual de demo: clic derecho sobre el bloque (web escritorio).',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: _UiSt.cTextSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Strip:',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: _UiSt.fsControl,
                              color: _UiSt.cTextPrimary,
                            ),
                          ),
                          ..._dayOptions.map((d) {
                            final sel = _visibleDays == d;
                            return ChoiceChip(
                              label: Text(
                                '$d día${d > 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: _UiSt.fsSectionTitle,
                                  fontWeight: FontWeight.w500,
                                  color: sel
                                      ? _UiSt.cTextPrimary
                                      : _UiSt.cTextSecondary,
                                ),
                              ),
                              selected: sel,
                              showCheckmark: false,
                              backgroundColor: Colors.white
                                  .withValues(alpha: _UiSt.aSurfaceChip),
                              selectedColor: _UiSt.cAccent
                                  .withValues(alpha: _UiSt.aAccentSelected),
                              side: BorderSide(color: _UiSt.borderStrong()),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(_UiSt.rCard),
                              ),
                              onSelected: (_) =>
                                  setState(() => _visibleDays = d),
                            );
                          }),
                          Text(
                            'Roster:',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: _UiSt.fsControl,
                              color: _UiSt.cTextPrimary,
                            ),
                          ),
                          ..._participantOptions.map((n) {
                            final sel = _participantCount == n;
                            return ChoiceChip(
                              label: Text(
                                '$n',
                                style: GoogleFonts.poppins(
                                  fontSize: _UiSt.fsSectionTitle,
                                  fontWeight: FontWeight.w500,
                                  color: sel
                                      ? _UiSt.cTextPrimary
                                      : _UiSt.cTextSecondary,
                                ),
                              ),
                              selected: sel,
                              showCheckmark: false,
                              backgroundColor: Colors.white
                                  .withValues(alpha: _UiSt.aSurfaceChip),
                              selectedColor: _UiSt.cAccent
                                  .withValues(alpha: _UiSt.aAccentSelected),
                              side: BorderSide(color: _UiSt.borderStrong()),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(_UiSt.rCard),
                              ),
                              onSelected: (_) =>
                                  setState(() => _participantCount = n),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),
                      for (final meta in _styles) ...[
                        Text(
                          meta.title,
                          style: GoogleFonts.poppins(
                            fontSize: _UiSt.fsSectionTitle,
                            fontWeight: FontWeight.w600,
                            color: _UiSt.cTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta.subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: _UiSt.fsSectionSubtitle,
                            color: _UiSt.cTextTertiary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _CalendarStripCardsPreview(
                          visibleDays: _visibleDays,
                          participantCount: _participantCount,
                          style: meta.style,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CardLabStyleMeta {
  final _CardLabStyle style;
  final String title;
  final String subtitle;

  const _CardLabStyleMeta({
    required this.style,
    required this.title,
    required this.subtitle,
  });
}

enum _CardLabStyle {
  filledClassic,
  outlineRail,
  chipDense,
  multiTrackGradient,
  splitTimeRow,
}

class _CalendarStripCardsPreview extends StatelessWidget {
  final int visibleDays;
  final int participantCount;
  final _CardLabStyle style;

  const _CalendarStripCardsPreview({
    required this.visibleDays,
    required this.participantCount,
    required this.style,
  });

  static const List<String> _weekdayLetters = [
    'L',
    'M',
    'X',
    'J',
    'V',
    'S',
    'D'
  ];

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: _UiSt.borderStrong());
    final base = _UiSt.cSurfaceBg;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final hourW = visibleDays <= 3 ? 40.0 : 32.0;
        final dayAvail = (w - hourW - 16).clamp(200.0, double.infinity);
        final dayW = dayAvail / visibleDays;

        return Container(
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(_UiSt.rCard),
            border: border,
          ),
          padding: const EdgeInsets.all(_UiSt.fsSectionTitle),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(width: hourW),
                  Expanded(
                    child: Row(
                      children: [
                        for (int d = 0; d < visibleDays; d++)
                          Expanded(
                            child: _DayMiniHeader(
                              dayIndex: d,
                              weekdayLetters: _weekdayLetters,
                              participantCount: participantCount,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: _LabTimeline.bodyHeightPx,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: hourW,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int hh = _LabTimeline.startHour;
                              hh < _LabTimeline.endHourExclusive;
                              hh++)
                            SizedBox(
                              height: AppConstants.cellHeight,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${hh.toString().padLeft(2, '0')}:00',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: visibleDays <= 3 ? 10 : 9,
                                      color: _UiSt.cTextTertiary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int day = 0; day < visibleDays; day++)
                            Expanded(
                              child: _DayColumnWithEvents(
                                visibleDays: visibleDays,
                                dayWidth: dayW,
                                participantCount: participantCount,
                                style: style,
                                dayIndex: day,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayMiniHeader extends StatelessWidget {
  final int dayIndex;
  final List<String> weekdayLetters;
  final int participantCount;

  const _DayMiniHeader({
    required this.dayIndex,
    required this.weekdayLetters,
    required this.participantCount,
  });

  String _participantLabel(int i) {
    if (participantCount <= 5) {
      const names = ['Ana', 'Ben', 'Cris', 'Dani', 'Eva'];
      return names[i % names.length].substring(0, 1);
    }
    return '${i + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${weekdayLetters[(3 + dayIndex) % weekdayLetters.length]} · ${12 + dayIndex} may',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: participantCount > 7 ? 9 : _UiSt.fsSectionTitle,
              color: _UiSt.cTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (int i = 0; i < participantCount; i++)
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    margin: EdgeInsets.only(
                      left: i == 0 ? 0 : 0.5,
                      right: 0,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        left: i == 0
                            ? BorderSide.none
                            : BorderSide(color: _UiSt.borderSubtle()),
                      ),
                      color:
                          Colors.white.withValues(alpha: _UiSt.aSurfaceMuted),
                    ),
                    child: Text(
                      _participantLabel(i),
                      style: GoogleFonts.poppins(
                        fontSize: participantCount > 7 ? 7.5 : 8.5,
                        fontWeight: FontWeight.w600,
                        color: _UiSt.cTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Eventos de demo con hora/duración coherentes con `AppConstants.cellHeight` como en prod.
class _SynthEvent {
  final int trackStart;
  final int trackEnd;

  /// Minutos desde medianoche en el día de referencia del lab (alineados a `_LabTimeline`).
  final int startMinuteOfDay;
  final int durationMinutes;

  /// Título de evento típico (viaje/reunión/actividad).
  final String title;

  /// Ej. `08:30-10:00` (ASCII `-` por compatibilidad con chips / split tiempo).
  final String clockRangeLabel;

  /// Segunda línea informativa (cobertura sobre el roster sintético o nota rápida).
  final String coverageDetail;
  final Color accent;

  const _SynthEvent({
    required this.trackStart,
    required this.trackEnd,
    required this.startMinuteOfDay,
    required this.durationMinutes,
    required this.title,
    required this.clockRangeLabel,
    required this.coverageDetail,
    required this.accent,
  });

  String get clockStartHm => clockRangeLabel.split('-').first.trim();
}

class _DayColumnWithEvents extends StatelessWidget {
  final int visibleDays;
  final double dayWidth;
  final int participantCount;
  final _CardLabStyle style;
  final int dayIndex;

  const _DayColumnWithEvents({
    required this.visibleDays,
    required this.dayWidth,
    required this.participantCount,
    required this.style,
    required this.dayIndex,
  });

  List<_SynthEvent> _eventsForDay() {
    final n = participantCount.clamp(1, 99);
    int spanEnd(int spanCols) => (spanCols.clamp(1, n) - 1).clamp(0, n - 1);

    final s100 = n;
    final s50 = _ceilShare(n, 1, 2);
    final s25 = _ceilShare(n, 25, 100);
    final s05 = _clampAtLeastOnePercentFive(n);

    final d = dayIndex;
    final dayHint = '${12 + dayIndex} may · día ${d + 1}';

    // Bloques sin solape; fin ≤ 17:00 (min 1020).
    const startFlight = 8 * 60 + 30;
    const durFlight = 90;
    const startShuttle = 10 * 60 + 10;
    const durShuttle = 38;
    const startTour = 11 * 60 + 5;
    const durTour = 120;
    const startTaxiAlert = 13 * 60 + 30;
    const durTaxiAlert = 38;
    const startFreePm = 14 * 60 + 35;
    const durFreePm = 145;

    return [
      _SynthEvent(
        trackStart: 0,
        trackEnd: spanEnd(s100),
        startMinuteOfDay: startFlight,
        durationMinutes: durFlight,
        title: 'Vuelo · IB3142 MAD–OPO · T4 sur',
        clockRangeLabel: _labFormatClockRangeMinuteOfDay(startFlight, durFlight),
        coverageDetail: '$s100/$n pax · equipaje etiquetado · $dayHint',
        accent: _accentForCoverageTier(0),
      ),
      _SynthEvent(
        trackStart: 0,
        trackEnd: spanEnd(s50),
        startMinuteOfDay: startShuttle,
        durationMinutes: durShuttle,
        title: 'Shuttle Aerobús · APT–Plaza Independencia',
        clockRangeLabel: _labFormatClockRangeMinuteOfDay(startShuttle, durShuttle),
        coverageDetail:
            '$s50/$n convoy · llegar 10 min antes al punto APT',
        accent: _accentForCoverageTier(1),
      ),
      _SynthEvent(
        trackStart: 0,
        trackEnd: spanEnd(s25),
        startMinuteOfDay: startTour,
        durationMinutes: durTour,
        title: 'Free tour centro histórico (guía Ana · ES)',
        clockRangeLabel: _labFormatClockRangeMinuteOfDay(startTour, durTour),
        coverageDetail: '$s25/$n plaza · encuentro plaza Mayor',
        accent: _accentForCoverageTier(2),
      ),
      _SynthEvent(
        trackStart: 0,
        trackEnd: spanEnd(s05),
        startMinuteOfDay: startTaxiAlert,
        durationMinutes: durTaxiAlert,
        title: 'Taxi aviso último grupo',
        clockRangeLabel: _labFormatClockRangeMinuteOfDay(startTaxiAlert, durTaxiAlert),
        coverageDetail:
            '$s05/$n pax · llamar antes de montar si hay retraso',
        accent: _accentForCoverageTier(3),
      ),
      _SynthEvent(
        trackStart: 0,
        trackEnd: spanEnd(s100),
        startMinuteOfDay: startFreePm,
        durationMinutes: durFreePm,
        title: 'Tarde libre · foto mirador · compras suvenir',
        clockRangeLabel: _labFormatClockRangeMinuteOfDay(startFreePm, durFreePm),
        coverageDetail: 'Todos · cena opcional por chat · $dayHint',
        accent: _accentForCoverageTier(1),
      ),
    ];
  }

  /// ceil(5%·n); mínimo 1 plaza cuando hay roster (n ≥ 1).
  static int _clampAtLeastOnePercentFive(int n) {
    final c = _ceilShare(n, 5, 100);
    return c < 1 ? 1 : c;
  }

  @override
  Widget build(BuildContext context) {
    final events = _eventsForDay();
    final trackW = dayWidth / participantCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _UiSt.cPageBg,
        borderRadius: BorderRadius.circular(_UiSt.rInner),
        // Sin borde superior/inferior: `Border.all` restaba ~2 px de alto al hijo y
        // 9 × AppConstants.cellHeight desbordaba ese espacio útil frente al strip de horas.
        border: Border(
          left: BorderSide(color: _UiSt.borderSubtle()),
          right: BorderSide(color: _UiSt.borderSubtle()),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_UiSt.rInner),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final vc = _LabTimeline.visibleHourCount;
            final cellH = AppConstants.cellHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                Row(
                  children: [
                    for (int ti = 0; ti < participantCount; ti++)
                      Expanded(
                        child: Column(
                          children: [
                            for (int hh = 0; hh < vc; hh++)
                              SizedBox(
                                height: cellH,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: ti == 0
                                          ? BorderSide.none
                                          : BorderSide(
                                              color: _UiSt.borderSubtle()),
                                      bottom: BorderSide(
                                        color: _UiSt.borderSubtle(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                ...events.map((e) {
                  final slotW = math.max(
                      1.0, (e.trackEnd - e.trackStart + 1) * trackW - 4);
                  final spanCols = e.trackEnd - e.trackStart + 1;
                  final topMin =
                      e.startMinuteOfDay - _LabTimeline.startMinuteOfDay;
                  final topPx = topMin / 60.0 * cellH;
                  final rawH = e.durationMinutes / 60.0 * cellH;
                  final slotH = math.max(6.0, rawH);
                  final maxH = math.max(0.0, h - topPx);
                  final height = math.min(slotH, maxH);

                  return Positioned(
                    left: e.trackStart * trackW + 2,
                    width: slotW,
                    top: topPx,
                    height: height,
                    child: ClipRect(
                      child: _LabEventDemoContextLayer(
                        card: _LabEventCard(
                          visibleDays: visibleDays,
                          participantCount: participantCount,
                          spanCols: spanCols,
                          style: style,
                          evt: e,
                          narrow: participantCount >= 10,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Wrapper del bloque demo: menú sólo por clic derecho (web / ratón).
class _LabEventDemoContextLayer extends StatelessWidget {
  final Widget card;

  const _LabEventDemoContextLayer({required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onSecondaryTapDown: (details) {
        _LabEventDemoMenu.showAtGlobal(context, details.globalPosition);
      },
      child: card,
    );
  }
}

class _LabEventDemoMenu {
  _LabEventDemoMenu._();

  static const String edit = 'lab_ctx_edit';
  static const String copy = 'lab_ctx_copy';
  static const String delete = 'lab_ctx_delete';

  static List<PopupMenuEntry<String>> _items(AppLocalizations l10n) {
    final style = GoogleFonts.poppins(
      fontSize: _UiSt.fsSectionSubtitle,
      color: _UiSt.cTextPrimary,
    );
    return [
      PopupMenuItem<String>(
        value: edit,
        child: Text(l10n.calendarContextEditEvent, style: style),
      ),
      PopupMenuItem<String>(
        value: copy,
        child: Text(l10n.calendarContextCopyEvent, style: style),
      ),
      PopupMenuItem<String>(
        value: delete,
        child: Text(l10n.calendarContextDeleteEvent, style: style),
      ),
    ];
  }

  static Future<void> showAtGlobal(
    BuildContext context,
    Offset globalPosition,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (overlay == null) return;

    final rect = RelativeRect.fromRect(
      Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
      Offset.zero & overlay.size,
    );

    final value = await showMenu<String>(
      context: context,
      position: rect,
      color: _UiSt.cSurfaceBg,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_UiSt.rInner),
        side: BorderSide(color: _UiSt.borderStrong()),
      ),
      items: _items(l10n),
    );

    if (!context.mounted || value == null) return;
    _feedback(context, l10n, value);
  }

  static void _feedback(BuildContext context, AppLocalizations l10n, String v) {
    final msg = switch (v) {
      edit => 'Demo · ${l10n.calendarContextEditEvent}',
      copy => 'Demo · ${l10n.calendarContextCopyEvent}',
      delete => 'Demo · ${l10n.calendarContextDeleteEvent}',
      _ => v,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: _UiSt.cSurfaceBg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _LabEventCard extends StatelessWidget {
  final int visibleDays;
  final int participantCount;
  final int spanCols;
  final _CardLabStyle style;
  final _SynthEvent evt;
  final bool narrow;
  final _LabCardPresentation presentation;

  _LabEventCard({
    required this.visibleDays,
    required this.participantCount,
    required this.spanCols,
    required this.style,
    required this.evt,
    required this.narrow,
  }) : presentation = _labCardPresentation(visibleDays, participantCount, spanCols);

  bool get _showSubtitle =>
      presentation == _LabCardPresentation.full &&
      evt.durationMinutes >= CalendarConstants.shortEventTitleOnlyMaxMinutes;

  static bool _microSlot(BoxConstraints c) =>
      c.maxHeight < 46 || c.maxWidth < 52;

  static bool _compactSlot(BoxConstraints c) =>
      c.maxHeight < 72 || c.maxWidth < 96;

  @override
  Widget build(BuildContext context) {
    if (presentation == _LabCardPresentation.swatch) {
      return _cardSwatch();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final c = constraints;
        if (c.maxWidth <= 0 || c.maxHeight <= 0) {
          return const SizedBox.shrink();
        }
        if (presentation == _LabCardPresentation.glyph) {
          return _cardGlyph(c);
        }
        if (_microSlot(c)) {
          if (presentation == _LabCardPresentation.full) {
            return _cardMicro(c);
          }
          return _cardGlyph(c);
        }
        switch (style) {
          case _CardLabStyle.filledClassic:
            return _cardFilledClassic(c);
          case _CardLabStyle.outlineRail:
            return _cardOutlineRail(c);
          case _CardLabStyle.chipDense:
            return _cardChipDense(c);
          case _CardLabStyle.multiTrackGradient:
            return _cardGradient(c);
          case _CardLabStyle.splitTimeRow:
            return _cardSplitTime(c);
        }
      },
    );
  }

  Widget _cardSwatch() {
    const r = 8.0;
    switch (style) {
      case _CardLabStyle.filledClassic:
        return ClipRRect(
          borderRadius: BorderRadius.circular(r),
          child: ColoredBox(color: evt.accent),
        );
      case _CardLabStyle.outlineRail:
        return ClipRRect(
          borderRadius: BorderRadius.circular(r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color:
                    Colors.white.withValues(alpha: _UiSt.aAccentSelected * 0.2),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(width: 3, child: ColoredBox(color: evt.accent)),
              ),
            ],
          ),
        );
      case _CardLabStyle.chipDense:
      case _CardLabStyle.multiTrackGradient:
      case _CardLabStyle.splitTimeRow:
        return ClipRRect(
          borderRadius: BorderRadius.circular(r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: evt.accent.withValues(alpha: 0.75),
              border: Border.all(color: _UiSt.borderStrong()),
            ),
          ),
        );
    }
  }

  String _glyphLabel() {
    final s = evt.clockStartHm;
    return s.length <= 6 ? s : s.substring(0, 6);
  }

  Widget _cardGlyph(BoxConstraints c) {
    final label = _glyphLabel();
    const fg = _UiSt.cTextPrimary;

    Widget core = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: GoogleFonts.robotoMono(
          fontWeight: FontWeight.w700,
          color: fg,
          fontSize: 10,
          height: 1.05,
        ),
      ),
    );

    switch (style) {
      case _CardLabStyle.filledClassic:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColoredBox(
            color: evt.accent,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: core,
              ),
            ),
          ),
        );
      case _CardLabStyle.outlineRail:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: _UiSt.cSurfaceBg),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(width: 3, child: ColoredBox(color: evt.accent)),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: core,
                  ),
                ),
              ),
            ],
          ),
        );
      case _CardLabStyle.chipDense:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _UiSt.cSurfaceBg,
              border: Border.all(color: _UiSt.borderStrong()),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withValues(alpha: _UiSt.aSurfaceChip),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _UiSt.borderStrong()),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          color: _UiSt.cTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      case _CardLabStyle.multiTrackGradient:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color:
                  Color.lerp(_UiSt.cSurfaceBg, evt.accent, 0.18) ?? _UiSt.cSurfaceBg,
              border: Border.all(color: _UiSt.borderStrong()),
            ),
            child: Center(
              child: FittedBox(fit: BoxFit.scaleDown, child: core),
            ),
          ),
        );
      case _CardLabStyle.splitTimeRow:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _UiSt.cSurfaceBg,
              border: Border.all(color: _UiSt.borderStrong()),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: math.min(26.0, c.maxWidth * 0.36).clamp(16.0, 28.0),
                  child: ColoredBox(
                    color: Colors.white
                        .withValues(alpha: _UiSt.aAccentSelected * 0.35),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.robotoMono(
                              fontWeight: FontWeight.w800,
                              fontSize: 8.5,
                              color: _UiSt.cTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Text(
                        '·',
                        style: TextStyle(
                          fontSize: 8,
                          color: _UiSt.cTextTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  EdgeInsets _padFor(BoxConstraints c) {
    final compact = _compactSlot(c);
    final h = compact
        ? math.min(6.0, c.maxWidth * 0.14)
        : _UiSt.fsSectionTitle.toDouble();
    final v = compact
        ? math.min(5.0, c.maxHeight * 0.16)
        : _UiSt.fsSectionSubtitle.toDouble();
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  int _titleMaxLines(BoxConstraints c) {
    if (presentation != _LabCardPresentation.full) return 1;
    if (narrow) return 1;
    return _compactSlot(c) ? 1 : 2;
  }

  Widget _cardMicro(BoxConstraints c) {
    final fs = math.min(
      8.5,
      math.max(5.0, math.min(c.maxHeight, c.maxWidth) * 0.19),
    );
    final pad = math.min(3.0, c.maxHeight * 0.12);
    final useLightOnAccent = style == _CardLabStyle.filledClassic;
    final bg = switch (style) {
      _CardLabStyle.filledClassic => evt.accent,
      _ => _UiSt.cSurfaceBg,
    };
    final fg = useLightOnAccent ? _UiSt.cTextPrimary : _UiSt.cTextPrimary;
    final sub = useLightOnAccent ? _UiSt.cTextSecondary : _UiSt.cTextSecondary;

    Widget text = Text(
      '${evt.title}\n${evt.clockRangeLabel}',
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        fontSize: fs,
        fontWeight: FontWeight.w600,
        height: 1.05,
        color: fg,
      ),
    );

    if (style != _CardLabStyle.filledClassic) {
      text = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            evt.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: fs,
              fontWeight: FontWeight.w700,
              height: 1.05,
              color: fg,
            ),
          ),
          Text(
            evt.clockRangeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: math.max(4.8, fs * 0.88),
              fontWeight: FontWeight.w500,
              height: 1.05,
              color: sub,
            ),
          ),
          Text(
            evt.coverageDetail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: math.max(4.5, fs * 0.8),
              fontWeight: FontWeight.w400,
              height: 1.05,
              color: _UiSt.cTextTertiary,
            ),
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Material(
        color: bg,
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: style == _CardLabStyle.filledClassic
              ? text
              : DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: _UiSt.borderStrong()),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(math.max(1.5, pad * 0.5)),
                    child: text,
                  ),
                ),
        ),
      ),
    );
  }

  TextStyle _titleStyle({required Color color}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: narrow ? 8.5 : 9.8,
        color: color,
        height: 1.15,
      );

  TextStyle _subStyle({required Color color}) => GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: narrow ? 7 : 8,
        color: color,
      );

  Widget _cardFilledClassic(BoxConstraints c) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_UiSt.rCard),
      child: Material(
        color: evt.accent,
        child: Padding(
          padding: _padFor(c),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: _showSubtitle ? 2 : 1,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    evt.title,
                    maxLines: _titleMaxLines(c),
                    overflow: TextOverflow.ellipsis,
                    style: _titleStyle(color: _UiSt.cTextPrimary),
                  ),
                ),
              ),
              if (_showSubtitle)
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${evt.clockRangeLabel} · ${evt.coverageDetail}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _subStyle(color: _UiSt.cTextSecondary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardOutlineRail(BoxConstraints c) {
    final pad = _compactSlot(c)
        ? EdgeInsets.fromLTRB(
            math.min(10.0, c.maxWidth * 0.22),
            math.min(4.0, c.maxHeight * 0.1),
            math.min(6.0, c.maxWidth * 0.16),
            math.min(4.0, c.maxHeight * 0.1),
          )
        : const EdgeInsets.fromLTRB(14, 6, 8, 6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_UiSt.rCard),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _UiSt.cSurfaceBg,
                border: Border.all(color: _UiSt.borderStrong()),
              ),
              child: Padding(
                padding: pad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: _showSubtitle ? 2 : 1,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          evt.title,
                          maxLines: _titleMaxLines(c),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: narrow ? 8 : _UiSt.fsSectionTitle,
                            height: 1.15,
                            color: _UiSt.cTextPrimary,
                          ),
                        ),
                      ),
                    ),
                    if (_showSubtitle)
                      Flexible(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '${evt.clockRangeLabel} · ${evt.coverageDetail}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: narrow ? 7 : _UiSt.fsSectionSubtitle,
                              color: _UiSt.cTextSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(width: 4, child: ColoredBox(color: evt.accent)),
          ),
        ],
      ),
    );
  }

  Widget _cardChipDense(BoxConstraints c) {
    final firstToken = evt.clockStartHm;
    final hp = math.min(
      8.0,
      math.max(3.0, c.maxWidth * 0.14),
    );
    final vp = math.min(
      6.0,
      math.max(2.5, c.maxHeight * 0.18),
    );

    final chip = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: _UiSt.aSurfaceChip),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _UiSt.borderStrong()),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: _UiSt.fsSectionSubtitle, vertical: 2),
        child: Text(
          firstToken,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.robotoMono(
            fontSize: narrow ? 7 : _UiSt.fsSectionSubtitle,
            fontWeight: FontWeight.w600,
            color: _UiSt.cTextPrimary,
          ),
        ),
      ),
    );

    final titleStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: narrow ? 8 : _UiSt.fsSectionTitle,
      color: _UiSt.cTextPrimary,
      height: 1.15,
    );

    final title = Text(
      evt.title,
      maxLines: _titleMaxLines(c),
      overflow: TextOverflow.ellipsis,
      style: titleStyle,
    );

    final boxDecoration = BoxDecoration(
      color: _UiSt.cSurfaceBg,
      borderRadius: BorderRadius.circular(_UiSt.rCard),
      border: Border.all(color: _UiSt.borderStrong()),
    );

    if (!_showSubtitle) {
      return DecoratedBox(
        decoration: boxDecoration,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: chip,
            ),
          ),
        ),
      );
    }

    if (_compactSlot(c) && c.maxWidth < 100) {
      return DecoratedBox(
        decoration: boxDecoration,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              chip,
              const SizedBox(height: 3),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: title,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: boxDecoration,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: chip,
            ),
            const SizedBox(width: 4),
            Expanded(child: title),
          ],
        ),
      ),
    );
  }

  Widget _cardGradient(BoxConstraints c) {
    final tinted = Color.lerp(_UiSt.cSurfaceBg, evt.accent, 0.10)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_UiSt.rCard),
        color: tinted,
        border: Border.all(color: _UiSt.borderStrong()),
      ),
      child: Padding(
        padding: _padFor(c),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: _showSubtitle ? 2 : 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  evt.title,
                  maxLines: _titleMaxLines(c),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: narrow ? 8 : _UiSt.fsSectionTitle,
                    color: _UiSt.cTextPrimary,
                  ),
                ),
              ),
            ),
            if (_showSubtitle)
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '${evt.clockRangeLabel} · ${evt.coverageDetail}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: narrow ? 7 : _UiSt.fsSectionSubtitle,
                      color: _UiSt.cTextSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cardSplitTime(BoxConstraints c) {
    final baseColW = narrow ? 28.0 : 32.0;
    final timeColW =
        math.min(baseColW, c.maxWidth * 0.4).clamp(18.0, baseColW);

    final deco = BoxDecoration(
      color: _UiSt.cSurfaceBg,
      borderRadius: BorderRadius.circular(_UiSt.rCard),
      border: Border.all(color: _UiSt.borderStrong()),
    );

    if (!_showSubtitle) {
      return DecoratedBox(
        decoration: deco,
        child: Padding(
          padding: _padFor(c),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${evt.clockRangeLabel} · ${evt.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: narrow ? 8 : _UiSt.fsSectionTitle,
                color: _UiSt.cTextPrimary,
              ),
            ),
          ),
        ),
      );
    }

    Widget bodyColumn({bool stacked = false}) {
      final pad = _padFor(c);
      if (stacked) {
        return Padding(
          padding: pad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                evt.clockRangeLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.robotoMono(
                  fontSize: narrow ? 7 : _UiSt.fsSectionSubtitle,
                  fontWeight: FontWeight.w700,
                  color: _UiSt.cTextPrimary,
                  height: 1.1,
                ),
              ),
              Flexible(
                flex: 2,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    evt.title,
                    maxLines: _titleMaxLines(c),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: narrow ? 8 : _UiSt.fsSectionTitle,
                      color: _UiSt.cTextPrimary,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    evt.coverageDetail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: narrow ? 7 : _UiSt.fsSectionSubtitle,
                      color: _UiSt.cTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: pad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: 2,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  evt.title,
                  maxLines: _titleMaxLines(c),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: narrow ? 8 : _UiSt.fsSectionTitle,
                    color: _UiSt.cTextPrimary,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  evt.coverageDetail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: narrow ? 7 : _UiSt.fsSectionSubtitle,
                    color: _UiSt.cTextSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final needStacked = c.maxWidth < timeColW + 30;

    if (needStacked) {
      return DecoratedBox(
        decoration: deco,
        child: bodyColumn(stacked: true),
      );
    }

    final monoMono = math.min(narrow ? 7.5 : _UiSt.fsSectionTitle.toDouble(),
        math.max(5.5, c.maxHeight * 0.2));

    return DecoratedBox(
      decoration: deco,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: timeColW,
            child: ColoredBox(
              color:
                  Colors.white.withValues(alpha: _UiSt.aAccentSelected * 0.35),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: _UiSt.fsSectionSubtitle),
                  child: Text(
                    evt.clockRangeLabel.replaceAll('-', '\n'),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.robotoMono(
                      fontSize: monoMono,
                      fontWeight: FontWeight.w700,
                      color: _UiSt.cTextPrimary,
                      height: 1.05,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: bodyColumn(stacked: false)),
        ],
      ),
    );
  }
}
