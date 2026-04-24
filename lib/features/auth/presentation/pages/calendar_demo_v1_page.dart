import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

class _DemoAcc {
  final int day;
  final int firstTrack;
  final int lastTrack;
  final String title;
  final String subtitle;
  final IconData icon;

  const _DemoAcc({
    required this.day,
    required this.firstTrack,
    required this.lastTrack,
    required this.title,
    required this.subtitle,
    this.icon = Icons.hotel_class_outlined,
  });
}

class _DemoEvent {
  final int day;
  final int hour;
  final int firstTrack;
  final int lastTrack;
  final String title;
  final String subtitle;
  final IconData icon;

  const _DemoEvent({
    required this.day,
    required this.hour,
    required this.firstTrack,
    required this.lastTrack,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Demo UI del calendario del plan (mobile-first). Estilo «acento suave», datos mock.
class CalendarDemoV1Page extends StatefulWidget {
  const CalendarDemoV1Page({super.key});

  @override
  State<CalendarDemoV1Page> createState() => _CalendarDemoV1PageState();
}

class _CalendarDemoV1PageState extends State<CalendarDemoV1Page> {
  int _visibleDays = 3;
  int _startDayIndex = 2;
  final int _totalDays = 7;

  static const _hours = <int>[8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  static const double _hoursColW = 56;
  static const double _accommodationRowH = 48;
  static const double _headerRowH = 72;

  static const _participantInitials = ['AG', 'BL', 'CM'];
  static const int _trackCount = 3;

  static const _weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  static const _accommodationDemos = <_DemoAcc>[
    _DemoAcc(
      day: 2,
      firstTrack: 0,
      lastTrack: 2,
      title: 'Ryokan Odaiba',
      subtitle: 'Todos',
    ),
    _DemoAcc(
      day: 3,
      firstTrack: 0,
      lastTrack: 1,
      title: 'Duplex Shibuya',
      subtitle: 'AG · BL',
      icon: Icons.cottage_outlined,
    ),
    _DemoAcc(
      day: 4,
      firstTrack: 0,
      lastTrack: 2,
      title: 'Hotel Haneda',
      subtitle: 'Todos',
    ),
  ];

  static const _eventDemos = <_DemoEvent>[
    _DemoEvent(
      day: 2,
      hour: 15,
      firstTrack: 0,
      lastTrack: 1,
      title: 'Cena reserva',
      subtitle: 'Solo AG · BL',
      icon: Icons.restaurant_outlined,
    ),
    _DemoEvent(
      day: 3,
      hour: 10,
      firstTrack: 0,
      lastTrack: 2,
      title: 'Briefing del plan',
      subtitle: 'Todos',
      icon: Icons.groups_outlined,
    ),
    _DemoEvent(
      day: 4,
      hour: 11,
      firstTrack: 1,
      lastTrack: 2,
      title: 'Compras / outlet',
      subtitle: 'Solo BL · CM',
      icon: Icons.shopping_bag_outlined,
    ),
    _DemoEvent(
      day: 4,
      hour: 17,
      firstTrack: 0,
      lastTrack: 2,
      title: 'Cena despedida',
      subtitle: 'Todos',
      icon: Icons.celebration_outlined,
    ),
  ];

  Color _sepDay() => Colors.white.withValues(alpha: 0.11);

  Color _sepTrack() => Colors.white.withValues(alpha: 0.06);

  Color _eventFill() => AppColorScheme.color2.withValues(alpha: 0.22);

  @override
  Widget build(BuildContext context) {
    final endDay = (_startDayIndex + _visibleDays - 1).clamp(1, _totalDays);
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFF111827),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111827),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'planaz',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: 'oo',
                      style: GoogleFonts.poppins(
                        color: AppColorScheme.color2,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Calendario (demo)',
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _unifiedDayBar(endDay: endDay),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Zona horaria del plan: Europe/Madrid',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    children: [
                      _dayHeaders(endDay: endDay),
                      _accommodationRow(endDay: endDay),
                      Expanded(
                        child: _hourGrid(endDay: endDay),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unifiedDayBar({required int endDay}) {
    final canPrev = _startDayIndex > 1;
    final canNext = endDay < _totalDays;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _navCircle(
                  icon: Icons.chevron_left_rounded,
                  enabled: canPrev,
                  onTap: () {
                    if (!canPrev) return;
                    setState(() {
                      _startDayIndex = (_startDayIndex - _visibleDays).clamp(1, _totalDays);
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'D$_startDayIndex–$endDay/$_totalDays',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                _navCircle(
                  icon: Icons.chevron_right_rounded,
                  enabled: canNext,
                  onTap: () {
                    if (!canNext) return;
                    setState(() {
                      final next = _startDayIndex + _visibleDays;
                      _startDayIndex = next > _totalDays ? _totalDays - _visibleDays + 1 : next;
                      if (_startDayIndex < 1) _startDayIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final d in [1, 2, 3]) ...[
                  if (d > 1) const SizedBox(width: 6),
                  _dayWidthChip(d),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navCircle({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 22,
            color: enabled ? Colors.white : Colors.white24,
          ),
        ),
      ),
    );
  }

  Widget _dayWidthChip(int days) {
    final selected = _visibleDays == days;
    return InkWell(
      onTap: () => setState(() => _visibleDays = days),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColorScheme.color2 : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColorScheme.color2 : Colors.white.withValues(alpha: 0.12),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          '$days',
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _dayHeaders({required int endDay}) {
    return Container(
      height: _headerRowH,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _sepDay()),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _hoursColW,
            child: ColoredBox(
              color: Colors.white.withValues(alpha: 0.02),
              child: Center(
                child: Text(
                  'Día',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(_visibleDays, (i) {
                final dayNum = _startDayIndex + i;
                if (dayNum > _totalDays) {
                  return Expanded(child: ColoredBox(color: Colors.black.withValues(alpha: 0.15)));
                }
                final wd = _weekdays[(dayNum - 1) % _weekdays.length];
                final highlight = dayNum == 3;
                final lastDayCol = i == _visibleDays - 1 || (_startDayIndex + i + 1) > _totalDays;
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: lastDayCol ? BorderSide.none : BorderSide(color: _sepDay(), width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: _dayAndDateOneLine(
                            weekday: wd,
                            dayNum: dayNum,
                            highlight: highlight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _miniParticipantHeaders(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayAndDateOneLine({
    required String weekday,
    required int dayNum,
    required bool highlight,
  }) {
    final base = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
    final muted = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Colors.white54,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(weekday, style: muted),
        Text(' · ', style: muted),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: highlight
                ? AppColorScheme.color2.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'D$dayNum',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Text(' · ', style: muted),
        Text('$dayNum jun', style: base),
      ],
    );
  }

  Widget _miniParticipantHeaders() {
    return Row(
      children: List.generate(_participantInitials.length, (t) {
        final last = t == _participantInitials.length - 1;
        return Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              border: last
                  ? null
                  : Border(
                      right: BorderSide(color: _sepTrack(), width: 1),
                    ),
            ),
            child: Text(
              _participantInitials[t],
              style: GoogleFonts.poppins(
                fontSize: _visibleDays == 3 ? 11 : 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _accommodationRow({required int endDay}) {
    return Container(
      height: _accommodationRowH,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _sepDay()),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _hoursColW,
            child: InkWell(
              onTap: () {},
              child: ColoredBox(
                color: Colors.white.withValues(alpha: 0.02),
                child: Center(
                  child: Icon(
                    Icons.home_outlined,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(_visibleDays, (i) {
                final dayNum = _startDayIndex + i;
                if (dayNum > endDay) {
                  return Expanded(child: ColoredBox(color: Colors.black.withValues(alpha: 0.2)));
                }
                final lastDayCol = i == _visibleDays - 1 || (_startDayIndex + i + 1) > _totalDays;
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: lastDayCol ? BorderSide.none : BorderSide(color: _sepDay(), width: 1),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final dayW = constraints.maxWidth;
                        final tw = dayW / _trackCount;
                        final acc = _accForDay(dayNum);
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              children: List.generate(_trackCount, (t) {
                                final last = t == _trackCount - 1;
                                return Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: last
                                          ? null
                                          : Border(
                                              right: BorderSide(color: _sepTrack(), width: 1),
                                            ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (acc != null)
                              Positioned(
                                left: acc.firstTrack * tw + 2,
                                width: (acc.lastTrack - acc.firstTrack + 1) * tw - 4,
                                top: 2,
                                bottom: 2,
                                child: _planStripPill(
                                  title: acc.title,
                                  subtitle: acc.subtitle,
                                  icon: acc.icon,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  _DemoAcc? _accForDay(int dayNum) {
    for (final a in _accommodationDemos) {
      if (a.day == dayNum) return a;
    }
    return null;
  }

  _DemoEvent? _eventAt(int dayNum, int hour) {
    for (final e in _eventDemos) {
      if (e.day == dayNum && e.hour == hour) return e;
    }
    return null;
  }

  Widget _hourGrid({required int endDay}) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: _hours.length,
      itemBuilder: (context, index) {
        final h = _hours[index];
        final label = '${h.toString().padLeft(2, '0')}:00';
        return Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _sepTrack()),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _hoursColW,
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.02),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, top: 2),
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(_visibleDays, (col) {
                    final dayNum = _startDayIndex + col;
                    if (dayNum > endDay) {
                      return Expanded(child: ColoredBox(color: Colors.black.withValues(alpha: 0.15)));
                    }
                    final lastDayCol = col == _visibleDays - 1 || (_startDayIndex + col + 1) > _totalDays;
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: lastDayCol ? BorderSide.none : BorderSide(color: _sepDay(), width: 1),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final dayW = constraints.maxWidth;
                            final tw = dayW / _trackCount;
                            final ev = _eventAt(dayNum, h);
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: List.generate(_trackCount, (trackIndex) {
                                    final last = trackIndex == _trackCount - 1;
                                    return Expanded(
                                      child: _trackCellBorder(isLastTrack: last),
                                    );
                                  }),
                                ),
                                if (ev != null)
                                  Positioned(
                                    left: ev.firstTrack * tw + 2,
                                    width: (ev.lastTrack - ev.firstTrack + 1) * tw - 4,
                                    top: 2,
                                    bottom: 2,
                                    child: _planStripPill(
                                      title: ev.title,
                                      subtitle: ev.subtitle,
                                      icon: ev.icon,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _trackCellBorder({required bool isLastTrack}) {
    return Container(
      decoration: BoxDecoration(
        border: isLastTrack
            ? null
            : Border(
                right: BorderSide(color: _sepTrack(), width: 1),
              ),
      ),
    );
  }

  Widget _planStripPill({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final fill = _eventFill();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        height: 1.15,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
