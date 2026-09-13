import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Demo UI: reorganización de la pantalla resumen del plan (mock, sin lógica real).
/// Ruta: `/demo/my-summary-reorg`
class MySummaryReorgDemoPage extends StatefulWidget {
  const MySummaryReorgDemoPage({super.key});

  @override
  State<MySummaryReorgDemoPage> createState() => _MySummaryReorgDemoPageState();
}

class _MySummaryReorgDemoPageState extends State<MySummaryReorgDemoPage> {
  static const _coverUrl =
      'https://images.unsplash.com/photo-1513635269975-59663e9ac4ea?auto=format&fit=crop&w=1200&q=80';

  static const _tabs = <(String, IconData)>[
    ('info', Icons.info_outline),
    ('resumen', Icons.list_alt),
    ('agenda', Icons.calendar_today_outlined),
    ('personas', Icons.group_outlined),
    ('pagos', Icons.payments_outlined),
  ];

  static const _days = <_DemoDay>[
    _DemoDay(weekdayShort: 'mié', day: 24),
    _DemoDay(weekdayShort: 'jue', day: 25),
    _DemoDay(weekdayShort: 'vie', day: 26),
    _DemoDay(weekdayShort: 'sáb', day: 27),
    _DemoDay(weekdayShort: 'dom', day: 28),
  ];

  static const _eventsByDayIndex = <List<_DemoEvent>>[
    [
      _DemoEvent(
        time: '16:00',
        title: 'llegada a the swan hotel',
        subtitle: 'check-in',
        icon: Icons.hotel_outlined,
      ),
      _DemoEvent(
        time: '20:00 – 21:30',
        title: 'cena en the swan',
        subtitle: 'reserva confirmada',
        icon: Icons.restaurant_outlined,
        trailing: _DemoTrailing.maps,
      ),
    ],
    [
      _DemoEvent(
        time: '08:00',
        title: 'desayuno en el hotel',
        subtitle: 'the swan hotel',
        icon: Icons.free_breakfast_outlined,
      ),
      _DemoEvent(
        time: '10:30 – 11:45',
        title: 'traslado a ral',
        subtitle: '1 h 15 min · 82 km',
        icon: Icons.directions_car_outlined,
        trailing: _DemoTrailing.route,
        durationLabel: '1 h 15 min',
      ),
      _DemoEvent(
        time: '12:00',
        title: 'paseo por el pueblo',
        subtitle: 'bourton-on-the-water',
        icon: Icons.place_outlined,
        trailing: _DemoTrailing.maps,
      ),
      _DemoEvent(
        time: '13:00 – 14:30',
        title: 'almuerzo',
        subtitle: 'the crown & thistle · reserva',
        icon: Icons.restaurant_outlined,
        trailing: _DemoTrailing.web,
      ),
      _DemoEvent(
        time: '15:30',
        title: 'visita castillo',
        subtitle: 'sudeley castle',
        icon: Icons.account_balance_outlined,
        trailing: _DemoTrailing.maps,
      ),
      _DemoEvent(
        time: '18:00',
        title: 'regreso al hotel',
        subtitle: 'the swan hotel',
        icon: Icons.hotel_outlined,
      ),
    ],
    [
      _DemoEvent(
        time: '09:30',
        title: 'mercado local',
        subtitle: 'stow-on-the-wold',
        icon: Icons.storefront_outlined,
        trailing: _DemoTrailing.maps,
      ),
      _DemoEvent(
        time: '13:00',
        title: 'picnic',
        subtitle: 'hyde park · oxford',
        icon: Icons.park_outlined,
      ),
    ],
    [
      // sáb 27 — vacío a propósito (empty state)
    ],
    [
      _DemoEvent(
        time: '10:00',
        title: 'check-out',
        subtitle: 'the swan hotel',
        icon: Icons.logout,
      ),
      _DemoEvent(
        time: '12:30 – 14:00',
        title: 'traslado al aeropuerto',
        subtitle: '1 h 30 min',
        icon: Icons.directions_car_outlined,
        trailing: _DemoTrailing.route,
        durationLabel: '1 h 30 min',
      ),
    ],
  ];

  static const _nightHotels = <String?>[
    'the swan hotel',
    'the swan hotel',
    'the swan hotel',
    null,
    null,
  ];

  static const _fullDates = <String>[
    'miércoles, 24 de septiembre',
    'jueves, 25 de septiembre',
    'viernes, 26 de septiembre',
    'sábado, 27 de septiembre',
    'domingo, 28 de septiembre',
  ];

  /// Demo: plan en curso; el día 25 es “hoy” y el 3.er evento es el actual.
  static const int _demoTodayIndex = 1;
  static const int _demoCurrentEventIndex = 2;
  static const double _expandedHeaderHeight = 168.0;

  String _selectedTab = 'resumen';
  String _viewMode = 'mine'; // mine | plan
  int _selectedDayIndex = 1; // jue 25
  bool _headerCollapsed = false;
  final _scrollController = ScrollController();
  final _dayChipsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onOuterScroll);
  }

  void _onOuterScroll() {
    if (!_scrollController.hasClients) return;
    final collapsed = _scrollController.offset >
        _expandedHeaderHeight - kToolbarHeight - 20;
    if (collapsed != _headerCollapsed) {
      setState(() => _headerCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onOuterScroll);
    _scrollController.dispose();
    _dayChipsScrollController.dispose();
    super.dispose();
  }

  void _selectDay(int index) {
    if (index < 0 || index >= _days.length) return;
    if (index == _selectedDayIndex) return;
    setState(() => _selectedDayIndex = index);
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final content = _buildShell();

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: IosFormColors.pageBg,
        body: width >= 900
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: content,
                  ),
                ),
              )
            : content,
      ),
    );
  }

  Widget _buildShell() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: _selectedTab == 'resumen'
                ? (details) {
                    final v = details.primaryVelocity ?? 0;
                    if (v < -280) {
                      _selectDay(_selectedDayIndex + 1);
                    } else if (v > 280) {
                      _selectDay(_selectedDayIndex - 1);
                    }
                  }
                : null,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildCollapsingHeader(collapsed: _headerCollapsed),
                SliverToBoxAdapter(child: _buildPlanNav()),
                if (_selectedTab == 'resumen') ...[
                  SliverToBoxAdapter(child: _buildMineFilterRow()),
                  SliverToBoxAdapter(child: _buildDaySelector()),
                  SliverToBoxAdapter(
                    child: _buildDateActionsRow(_selectedDayIndex),
                  ),
                  ..._buildDayContentSlivers(_selectedDayIndex),
                ] else
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildStubTab(),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  _TimelinePhase _phaseFor(int dayIndex, int eventIndex) {
    if (dayIndex != _demoTodayIndex) {
      return dayIndex < _demoTodayIndex
          ? _TimelinePhase.past
          : _TimelinePhase.upcoming;
    }
    if (eventIndex < _demoCurrentEventIndex) return _TimelinePhase.past;
    if (eventIndex == _demoCurrentEventIndex) return _TimelinePhase.current;
    return _TimelinePhase.upcoming;
  }

  Widget _buildEmptyDay() {
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
          const Text(
            'nada previsto este día',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: IosFormColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'usa + para crear un evento o un alojamiento',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: IosFormColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDayContentSlivers(int dayIndex) {
    final events = _eventsByDayIndex[dayIndex];
    final hotel = _nightHotels[dayIndex];
    if (events.isEmpty) {
      return [
        SliverToBoxAdapter(child: _buildEmptyDay()),
        if (hotel != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: _NightStayRow(hotelName: hotel),
            ),
          ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final event = events[index];
              final isLast = index == events.length - 1 && hotel == null;
              return _TimelineRow(
                event: event,
                isFirst: index == 0,
                isLast: isLast,
                showLineBelow: index < events.length - 1 || hotel != null,
                phase: _phaseFor(dayIndex, index),
                lineBelowDashed: dayIndex == _demoTodayIndex &&
                    index >= _demoCurrentEventIndex,
              );
            },
            childCount: events.length,
          ),
        ),
      ),
      if (hotel != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: _NightStayRow(hotelName: hotel),
          ),
        ),
    ];
  }

  Widget _buildCollapsingHeader({required bool collapsed}) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: _expandedHeaderHeight,
      backgroundColor:
          collapsed ? IosFormColors.groupedBg : IosFormColors.pageBg,
      surfaceTintColor: Colors.transparent,
      elevation: collapsed ? 0.5 : 0,
      scrolledUnderElevation: collapsed ? 2 : 0,
      shadowColor: Colors.black54,
      forceElevated: collapsed,
      leading: IconButton(
        tooltip: 'volver',
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: collapsed ? 1 : 0,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'cotswolds 2026',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: IosFormColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _statusPill(compact: true),
          ],
        ),
      ),
      bottom: collapsed
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColorScheme.color2.withValues(alpha: 0.35),
              ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1C1C1E),
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: AppColorScheme.color2.withValues(alpha: 0.8),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(56, 8, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'cotswolds 2026',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '24 sep – 1 oct 2026',
                                style: TextStyle(
                                  color: Color(0xCCFFFFFF),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _statusPill(compact: false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill({required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF66BB6A).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 14, color: Color(0xFFA5D6A7)),
          const SizedBox(width: 4),
          Text(
            'in',
            style: TextStyle(
              color: const Color(0xFFE8F5E9),
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanNav() {
    return Material(
      color: IosFormColors.pageBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: [
            for (final tab in _tabs)
              Expanded(
                child: _NavTab(
                  label: tab.$1,
                  icon: tab.$2,
                  selected: _selectedTab == tab.$1,
                  onTap: () => setState(() => _selectedTab = tab.$1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMineFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          _SegmentChip(
            label: 'mío',
            selected: _viewMode == 'mine',
            onTap: () => setState(() => _viewMode = 'mine'),
          ),
          const SizedBox(width: 8),
          _SegmentChip(
            label: 'todos',
            selected: _viewMode == 'plan',
            onTap: () => setState(() => _viewMode = 'plan'),
          ),
          const Spacer(),
          Material(
            color: IosFormColors.groupedBg,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('filtro (stub) — aparcado en la demo'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 18,
                      color: AppColorScheme.color2,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'filtrar',
                      style: TextStyle(
                        color: IosFormColors.textPrimary,
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

  Widget _buildDaySelector() {
    return Container(
      color: IosFormColors.pageBg,
      padding: const EdgeInsets.only(bottom: 4),
      height: 72,
      child: ListView.separated(
        controller: _dayChipsScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = _days[index];
          final selected = index == _selectedDayIndex;
          final isToday = index == _demoTodayIndex;
          final bg = selected
              ? AppColorScheme.color2
              : IosFormColors.groupedBg;
          return Material(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _selectDay(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !selected
                      ? Border.all(
                          color: AppColorScheme.color2,
                          width: 1.4,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.weekdayShort,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : IosFormColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : IosFormColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 2),
                      Text(
                        'hoy',
                        style: TextStyle(
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

  Widget _buildDateActionsRow(int dayIndex) {
    final isToday = dayIndex == _demoTodayIndex;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: IosFormColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(text: _fullDates[dayIndex]),
                  if (isToday)
                    TextSpan(
                      text: ' · hoy',
                      style: TextStyle(
                        color: AppColorScheme.color2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'mapa',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('mapa (stub)'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(Icons.map_outlined, color: AppColorScheme.color2),
          ),
          const SizedBox(width: 4),
          Material(
            color: AppColorScheme.color3,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _showCreateSheet,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStubTab() {
    final label = _selectedTab;
    final hint = switch (label) {
      'info' => 'aquí irían info del plan, notas y stats',
      'agenda' => 'aquí iría la agenda / calendario',
      'personas' => 'aquí iría la lista de participantes',
      'pagos' => 'aquí irían pagos y gastos (peso de la sección)',
      _ => '',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_outlined,
                size: 36, color: AppColorScheme.color2),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: IosFormColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: IosFormColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Material(
      color: IosFormColors.groupedBg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: IosFormColors.pageBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 20,
                        color: IosFormColors.textTertiary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'buscar en el plan...',
                          style: TextStyle(
                            color: IosFormColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _BottomIconButton(
                icon: Icons.chat_bubble_outline,
                badge: '3',
                tooltip: 'chat',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('chat (stub)'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              _BottomIconButton(
                icon: Icons.notifications_outlined,
                badge: '1',
                tooltip: 'notificaciones',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('notificaciones (stub)'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: IosFormColors.groupedBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: IosFormColors.separator,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.event, color: AppColorScheme.color2),
                title: const Text('crear evento'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: Icon(Icons.hotel_outlined, color: AppColorScheme.color2),
                title: const Text('crear alojamiento'),
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _DemoDay {
  const _DemoDay({required this.weekdayShort, required this.day});
  final String weekdayShort;
  final int day;
}

enum _DemoTrailing { none, maps, route, web }

enum _TimelinePhase { past, current, upcoming }

class _DemoEvent {
  const _DemoEvent({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing = _DemoTrailing.none,
    this.durationLabel,
  });

  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final _DemoTrailing trailing;
  final String? durationLabel;
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColorScheme.color2 : IosFormColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 28,
              decoration: BoxDecoration(
                color: selected ? AppColorScheme.color2 : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColorScheme.color2 : IosFormColors.groupedBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : IosFormColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.isFirst,
    required this.isLast,
    required this.showLineBelow,
    required this.phase,
    required this.lineBelowDashed,
  });

  final _DemoEvent event;
  final bool isFirst;
  final bool isLast;
  final bool showLineBelow;
  final _TimelinePhase phase;
  final bool lineBelowDashed;

  @override
  Widget build(BuildContext context) {
    final accent = AppColorScheme.color2;
    final isCurrent = phase == _TimelinePhase.current;
    final isPast = phase == _TimelinePhase.past;
    final contentOpacity = isPast ? 0.55 : 1.0;
    final lineColor = isPast
        ? accent.withValues(alpha: 0.35)
        : accent.withValues(alpha: 0.55);
    final timeColor = isCurrent
        ? accent
        : (isPast
            ? IosFormColors.textTertiary
            : IosFormColors.textSecondary);

    return Opacity(
      opacity: contentOpacity,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 56,
              child: Padding(
                padding: EdgeInsets.only(top: isCurrent ? 16 : 14),
                child: Text(
                  event.time.split(' – ').first,
                  style: TextStyle(
                    color: timeColor,
                    fontSize: isCurrent ? 13 : 12,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 24,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (!isFirst || showLineBelow)
                    Positioned(
                      top: isFirst ? 22 : 0,
                      bottom: showLineBelow ? 0 : null,
                      height: showLineBelow ? null : 22,
                      child: SizedBox(
                        width: 2,
                        child: lineBelowDashed && !isPast
                            ? CustomPaint(
                                painter: _DashedLinePainter(
                                  color: accent.withValues(alpha: 0.4),
                                ),
                              )
                            : ColoredBox(color: lineColor),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: isCurrent ? 12 : 14),
                    child: _TimelineDot(phase: phase, accent: accent),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 6),
                padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? accent.withValues(alpha: 0.14)
                      : IosFormColors.groupedBg,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrent
                      ? Border.all(color: accent.withValues(alpha: 0.65), width: 1.2)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isCurrent ? 0.35 : 0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        event.icon,
                        size: 18,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isCurrent)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                'ahora',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          Text(
                            event.time.contains('–') ? event.time : event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrent
                                  ? accent
                                  : IosFormColors.textSecondary,
                              fontSize: event.time.contains('–') ? 11 : 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (event.time.contains('–')) ...[
                            const SizedBox(height: 2),
                            Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: IosFormColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 2),
                            Text(
                              event.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: IosFormColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (event.durationLabel != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              event.durationLabel!,
                              style: TextStyle(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else if (event.time.contains('–')) ...[
                            const SizedBox(height: 2),
                            Text(
                              event.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: IosFormColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (event.trailing != _DemoTrailing.none) ...[
                      const SizedBox(width: 6),
                      _ActionChip(kind: event.trailing),
                    ],
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: isCurrent
                          ? accent
                          : IosFormColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.phase, required this.accent});

  final _TimelinePhase phase;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case _TimelinePhase.current:
        return Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent, width: 2.5),
            color: Colors.transparent,
          ),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
        );
      case _TimelinePhase.past:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
        );
      case _TimelinePhase.upcoming:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: IosFormColors.pageBg,
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.7), width: 2),
          ),
        );
    }
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0 || !size.height.isFinite) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dash = 4.0;
    const gap = 3.0;
    var y = 0.0;
    final x = size.width / 2;
    while (y < size.height) {
      final y2 = (y + dash).clamp(0.0, size.height);
      canvas.drawLine(Offset(x, y), Offset(x, y2), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.kind});
  final _DemoTrailing kind;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (kind) {
      _DemoTrailing.route => (Icons.route, 'ruta'),
      _DemoTrailing.maps => (Icons.place_outlined, null),
      _DemoTrailing.web => (Icons.open_in_new, null),
      _DemoTrailing.none => (Icons.circle, null),
    };
    if (label != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColorScheme.color2.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColorScheme.color2),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColorScheme.color2,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: 26,
      height: 26,
      child: Icon(icon, size: 16, color: AppColorScheme.color2),
    );
  }
}

class _NightStayRow extends StatelessWidget {
  const _NightStayRow({required this.hotelName});
  final String hotelName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: IosFormColors.groupedBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColorScheme.color2.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'H',
              style: TextStyle(
                color: IosFormColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'esta noche · $hotelName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: IosFormColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.place_outlined, size: 18, color: AppColorScheme.color2),
        ],
      ),
    );
  }
}

class _BottomIconButton extends StatelessWidget {
  const _BottomIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: badge != null,
        label: badge != null ? Text(badge!) : null,
        child: Icon(icon, color: IosFormColors.textPrimary),
      ),
    );
  }
}
