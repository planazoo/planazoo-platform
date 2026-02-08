import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Filtros y toggle de vista del dashboard (W26–W27): botones Todos/Estoy in/Pendientes/Cerrados
/// y toggle Lista / Calendario.
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildW26(columnWidth, rowHeight),
        _buildW27(context, columnWidth, rowHeight),
      ],
    );
  }

  Widget _buildW26(double columnWidth, double rowHeight) {
    return Positioned(
      left: columnWidth,
      top: rowHeight * 2,
      child: Container(
        width: columnWidth * 4,
        height: rowHeight,
        decoration: BoxDecoration(color: Colors.grey.shade800),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildFilterButton('todos', 'Todos', columnWidth, rowHeight),
            const SizedBox(width: 2),
            _buildFilterButton('estoy_in', 'Estoy in', columnWidth, rowHeight),
            const SizedBox(width: 2),
            _buildFilterButton('pendientes', 'Pendientes', columnWidth, rowHeight),
            const SizedBox(width: 2),
            _buildFilterButton('cerrados', 'Cerrados', columnWidth, rowHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    String filterValue,
    String label,
    double columnWidth,
    double rowHeight,
  ) {
    final isSelected = selectedFilter == filterValue;
    return Expanded(
      child: Container(
        height: rowHeight * 0.6,
        margin: EdgeInsets.symmetric(vertical: rowHeight * 0.2),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade800,
          border: isSelected
              ? Border.all(color: AppColorScheme.color2, width: 2)
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColorScheme.color2.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: () => onFilterChanged(filterValue),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildW27(
    BuildContext context,
    double columnWidth,
    double rowHeight,
  ) {
    final loc = AppLocalizations.of(context)!;

    return Positioned(
      left: columnWidth,
      top: rowHeight * 3,
      child: Container(
        width: columnWidth * 4,
        height: rowHeight,
        decoration: BoxDecoration(color: Colors.grey.shade800),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ToggleButtons(
            isSelected: [!isCalendarView, isCalendarView],
            onPressed: (index) {
              onViewModeChanged(index == 1);
            },
            borderRadius: BorderRadius.circular(24),
            renderBorder: false,
            fillColor: AppColorScheme.color2,
            selectedColor: Colors.white,
            color: Colors.grey.shade400,
            constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.view_list_outlined,
                      color:
                          !isCalendarView ? Colors.white : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.planViewModeList,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            !isCalendarView ? Colors.white : Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color:
                          isCalendarView ? Colors.white : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.planViewModeCalendar,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            isCalendarView ? Colors.white : Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
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
