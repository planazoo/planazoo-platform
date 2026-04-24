import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';

class PlansListDemoV1Page extends StatefulWidget {
  const PlansListDemoV1Page({super.key});

  @override
  State<PlansListDemoV1Page> createState() => _PlansListDemoV1PageState();
}

class _PlansListDemoV1PageState extends State<PlansListDemoV1Page> {
  bool _calendarView = false;
  String _filter = 'Todos';

  final List<(String, String, String, String, int, int)> _items = const [
    ('Japón 2026', '01 Jun - 10 Jun', 'planificando', 'in', 2, 4),
    ('Roma express', '14 Jul - 17 Jul', 'en_curso', 'pending', 1, 0),
    ('Escapada Pirineos', '05 Sep - 09 Sep', 'confirmado', 'out', 0, 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFF111827),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111827),
          elevation: 0,
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'planaz',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                TextSpan(
                  text: 'oo',
                  style: GoogleFonts.poppins(
                    color: AppColorScheme.color2,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Crear plan',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o fechas',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showMenu<String>(
                          context: context,
                          position: const RelativeRect.fromLTRB(16, 170, 16, 0),
                          items: const [
                            PopupMenuItem(value: 'Todos', child: Text('Todos')),
                            PopupMenuItem(value: 'Estoy in', child: Text('Estoy in')),
                            PopupMenuItem(value: 'Pendientes', child: Text('Pendientes')),
                            PopupMenuItem(value: 'Cerrados', child: Text('Cerrados')),
                          ],
                        );
                        if (picked != null) setState(() => _filter = picked);
                      },
                      icon: const Icon(Icons.filter_list),
                      label: Text(_filter),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ToggleButtons(
                    isSelected: [!_calendarView, _calendarView],
                    onPressed: (i) => setState(() => _calendarView = i == 1),
                    constraints: const BoxConstraints(minHeight: 40, minWidth: 44),
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: Colors.white,
                    fillColor: AppColorScheme.color2,
                    children: const [
                      Icon(Icons.view_list, size: 20),
                      Icon(Icons.calendar_month, size: 20),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _calendarView
                    ? Center(
                        child: Text(
                          'Vista calendario (demo)',
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F2937),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: AppColorScheme.color2.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.luggage, color: AppColorScheme.color2),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.$1,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.$2,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _statusChip(item.$4),
                                            const SizedBox(width: 6),
                                            _planStateSymbolChip(item.$3),
                                          ],
                                        ),
                                        if ((item.$5 + item.$6) > 0) ...[
                                          const SizedBox(height: 6),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: _activityDot(item.$5 + item.$6),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 58,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navIconWithBadge(
                  icon: Icons.notifications_none,
                  badgeCount: 3,
                  active: true,
                ),
                _navIconWithBadge(
                  icon: Icons.chat_bubble_outline,
                  badgeCount: 5,
                  active: true,
                ),
                _navIconWithBadge(icon: Icons.help_outline),
                _navIconWithBadge(icon: Icons.person_outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    IconData icon;
    switch (status) {
      case 'pending':
        bg = AppColorScheme.color3.withValues(alpha: 0.22);
        fg = const Color(0xFFFFD9C2);
        icon = Icons.schedule_rounded;
        break;
      case 'out':
        bg = const Color(0xFFB91C1C).withValues(alpha: 0.25);
        fg = const Color(0xFFFFD4DB);
        icon = Icons.close_rounded;
        break;
      case 'in':
      default:
        bg = AppColorScheme.color2;
        fg = Colors.white;
        icon = Icons.check_rounded;
        break;
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: fg,
      ),
    );
  }

  Widget _planStateSymbolChip(String planState) {
    IconData icon;
    Color bg;
    Color fg;
    switch (planState) {
      case 'cancelado':
        icon = Icons.cancel_outlined;
        bg = const Color(0xFFB91C1C).withValues(alpha: 0.28);
        fg = const Color(0xFFFFD4DB);
        break;
      case 'finalizado':
        icon = Icons.check_circle;
        bg = AppColorScheme.color4.withValues(alpha: 0.45);
        fg = Colors.white;
        break;
      case 'en_curso':
        icon = Icons.play_circle_outline;
        bg = AppColorScheme.color3.withValues(alpha: 0.26);
        fg = const Color(0xFFFFE8D2);
        break;
      case 'confirmado':
        icon = Icons.check_circle_outline;
        bg = AppColorScheme.color2;
        fg = Colors.white;
        break;
      case 'planificando':
        icon = Icons.event_note;
        bg = AppColorScheme.color4.withValues(alpha: 0.30);
        fg = Colors.white.withValues(alpha: 0.95);
        break;
      default:
        icon = Icons.help_outline;
        bg = AppColorScheme.color4.withValues(alpha: 0.30);
        fg = Colors.white.withValues(alpha: 0.95);
        break;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: fg,
      ),
    );
  }

  Widget _navIconWithBadge({
    required IconData icon,
    int badgeCount = 0,
    bool active = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          color: active ? AppColorScheme.color3 : Colors.white,
          size: 24,
        ),
        if (badgeCount > 0)
          Positioned(
            right: -7,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColorScheme.color3,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _activityDot(int count) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColorScheme.color3,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$count',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
