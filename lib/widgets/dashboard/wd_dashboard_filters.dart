import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Filtros y vista del dashboard (W26–W27): un botón de filtros (menú) + toggle Lista / Calendario en la misma fila.
/// Paridad con `PlansListPage` (iOS/móvil).
class WdDashboardFilters extends StatelessWidget {
  final double columnWidth;
  final double rowHeight;
  final String selectedFilter;
  final bool isCalendarView;
  final void Function(String) onFilterChanged;
  final void Function(bool isCalendarView) onViewModeChanged;

  const WdDashboardFilters({
    super.key,
    required this.columnWidth,
    required this.rowHeight,
    required this.selectedFilter,
    required this.isCalendarView,
    required this.onFilterChanged,
    required this.onViewModeChanged,
  });

  String _filterLabel(AppLocalizations loc) {
    switch (selectedFilter) {
      case 'estoy_in':
        return loc.dashboardFilterEstoyIn;
      case 'pendientes':
        return loc.dashboardFilterPending;
      case 'cerrados':
        return loc.dashboardFilterClosed;
      case 'todos':
      default:
        return loc.dashboardFilterAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double controlHeight = 36;
    final panelBg = const Color(0xFF111827);
    final controlBg = const Color(0xFF1F2937);
    const textColor = Colors.white;
    final controlBorderColor = AppColorScheme.color2.withValues(alpha: 0.7);
    const controlBorderWidth = 1.5;
    final loc = AppLocalizations.of(context)!;
    return Positioned(
      left: columnWidth,
      top: rowHeight * 2,
      child: Container(
        width: columnWidth * 4,
        height: rowHeight,
        decoration: BoxDecoration(color: panelBg),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: controlHeight,
                        child: PopupMenuButton<String>(
                          tooltip: loc.plansListFiltersButton,
                          initialValue: selectedFilter,
                          color: panelBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: controlBorderColor,
                              width: controlBorderWidth,
                            ),
                          ),
                          onSelected: onFilterChanged,
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'todos',
                              child: _filterMenuRow(loc, loc.dashboardFilterAll, 'todos'),
                            ),
                            PopupMenuItem<String>(
                              value: 'estoy_in',
                              child: _filterMenuRow(loc, loc.dashboardFilterEstoyIn, 'estoy_in'),
                            ),
                            PopupMenuItem<String>(
                              value: 'pendientes',
                              child: _filterMenuRow(loc, loc.dashboardFilterPending, 'pendientes'),
                            ),
                            PopupMenuItem<String>(
                              value: 'cerrados',
                              child: _filterMenuRow(loc, loc.dashboardFilterClosed, 'cerrados'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: controlBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: controlBorderColor,
                                width: controlBorderWidth,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.filter_list, color: AppColorScheme.color2, size: 20),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _filterLabel(loc),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: loc.plansListViewModeTooltip,
                      child: ToggleButtons(
                        isSelected: [!isCalendarView, isCalendarView],
                        onPressed: (index) {
                          onViewModeChanged(index == 1);
                        },
                        borderRadius: BorderRadius.circular(12),
                        renderBorder: false,
                        fillColor: AppColorScheme.color2,
                        selectedColor: Colors.white,
                        color: Colors.white70,
                        constraints: BoxConstraints(
                          minHeight: controlHeight,
                          minWidth: 44,
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Icon(Icons.view_list, size: 20),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Icon(Icons.calendar_month, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 4, color: AppColorScheme.color2),
          ],
        ),
      ),
    );
  }

  Widget _filterMenuRow(AppLocalizations loc, String label, String filterValue) {
    final selected = selectedFilter == filterValue;
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: selected
              ? Icon(Icons.check, size: 18, color: AppColorScheme.color2)
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
