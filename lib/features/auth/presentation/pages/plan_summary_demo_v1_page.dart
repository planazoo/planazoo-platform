import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

class PlanSummaryDemoV1Page extends StatefulWidget {
  const PlanSummaryDemoV1Page({super.key});

  @override
  State<PlanSummaryDemoV1Page> createState() => _PlanSummaryDemoV1PageState();
}

class _PlanSummaryDemoV1PageState extends State<PlanSummaryDemoV1Page> {
  String? _activeQuickPanel;

  static const _days = <(String, List<(String, String, IconData)>)>[
    (
      'Día 1 · Lun 01 Jun',
      [
        ('07:30', 'Vuelo BCN -> NRT', Icons.flight_takeoff_rounded),
        ('14:00', 'Llegada y traslado al hotel', Icons.directions_car_filled_rounded),
        ('19:30', 'Cena en Shinjuku', Icons.restaurant_rounded),
      ],
    ),
    (
      'Día 2 · Mar 02 Jun',
      [
        ('09:00', 'Asakusa + Senso-ji', Icons.temple_buddhist_rounded),
        ('13:00', 'Almuerzo en Ueno', Icons.ramen_dining_rounded),
        ('17:30', 'Tokyo Skytree', Icons.apartment_rounded),
      ],
    ),
    (
      'Día 3 · Mié 03 Jun',
      [
        ('08:30', 'Tren a Nikko', Icons.train_rounded),
        ('11:00', 'Ruta templos Nikko', Icons.landscape_rounded),
        ('20:00', 'Regreso a Tokio', Icons.nightlife_rounded),
      ],
    ),
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
          title: Text(
            'Resumen del plan (demo)',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          children: [
            _heroCard(),
            const SizedBox(height: 14),
            _quickAccessChips(),
            if (_activeQuickPanel != null) ...[
              const SizedBox(height: 8),
              _quickPanelCard(),
            ],
            const SizedBox(height: 10),
            _sectionCard(
              title: 'Plan completo',
              subtitle: 'Visible por defecto',
              icon: Icons.route_rounded,
              expanded: true,
              onTap: null,
              body: _fullPlanTimeline(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _quickChip('participants', Icons.group_outlined, 'Participantes'),
        _quickChip('travel', Icons.luggage_rounded, 'Viaje'),
        _quickChip('notes', Icons.description_outlined, 'Notas'),
      ],
    );
  }

  Widget _quickChip(String key, IconData icon, String label) {
    final active = _activeQuickPanel == key;
    return InkWell(
      onTap: () {
        setState(() {
          _activeQuickPanel = active ? null : key;
        });
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? AppColorScheme.color2.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? AppColorScheme.color2
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? Colors.white : Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: active ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickPanelCard() {
    final key = _activeQuickPanel;
    String title;
    Widget body;
    switch (key) {
      case 'participants':
        title = 'Participantes';
        body = _simpleList(const ['Emma (organiza)', 'Carlos', 'Marta', 'Luís']);
        break;
      case 'travel':
        title = 'Vuelos y alojamientos';
        body = _simpleList(const [
          'Vuelo ida: BCN -> NRT (AF123)',
          'Hotel: Shinjuku Garden (3 noches)',
          'Vuelo vuelta: HND -> BCN (AF124)',
        ]);
        break;
      case 'notes':
      default:
        title = 'Notas y documentación';
        body = _simpleList(const [
          'Seguro de viaje compartido en drive',
          'Checklist equipaje',
          'Tarjetas transporte y pass',
        ]);
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColorScheme.color2.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.public_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Japón 2026',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '01 Jun - 10 Jun · 10 días',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColorScheme.color2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'in',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fullPlanTimeline() {
    return Column(
      children: _days.map((day) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.$1,
                  style: GoogleFonts.poppins(
                    color: AppColorScheme.color2,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ...day.$2.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 46,
                          child: Text(
                            item.$1,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(item.$3, size: 15, color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.$2,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _simpleList(List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                '- $line',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool expanded,
    required VoidCallback? onTap,
    required Widget body,
    bool compactWhenCollapsed = false,
  }) {
    final isCompactClosed = compactWhenCollapsed && !expanded;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: isCompactClosed ? 8 : 11,
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white70, size: isCompactClosed ? 16 : 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isCompactClosed ? 12 : 13,
                          ),
                        ),
                        if (!isCompactClosed) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white70,
                      size: isCompactClosed ? 20 : 24,
                    ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: body,
            ),
        ],
      ),
    );
  }
}
