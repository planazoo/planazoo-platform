import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Definición de una pestaña de navegación del dashboard (W14–W20).
class DashboardNavTabItem {
  final String id;
  final IconData icon;
  final String label;
  final String screen;
  /// Badge de no leídas (p. ej. en W20).
  final int? badgeCount;
  /// Si true, el label usa fuente más pequeña (p. ej. "notificaciones").
  final bool smallLabel;

  const DashboardNavTabItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.screen,
    this.badgeCount,
    this.smallLabel = false,
  });

  DashboardNavTabItem copyWith({int? badgeCount}) {
    return DashboardNavTabItem(
      id: id,
      icon: icon,
      label: label,
      screen: screen,
      badgeCount: badgeCount ?? this.badgeCount,
      smallLabel: smallLabel,
    );
  }
}

/// Fila de pestañas de navegación del dashboard (W14–W25).
/// Las primeras [tabs.length] celdas son tappable; el resto son celdas vacías.
class WdDashboardNavTabs extends StatelessWidget {
  final double columnWidth;
  final double rowHeight;
  final List<DashboardNavTabItem> tabs;
  final String? selectedId;
  final void Function(String id, String screen) onTabTap;

  const WdDashboardNavTabs({
    super.key,
    required this.columnWidth,
    required this.rowHeight,
    required this.tabs,
    required this.selectedId,
    required this.onTabTap,
  });

  /// Lista de pestañas (W14–W20) con etiquetas localizadas.
  static List<DashboardNavTabItem> tabItems(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      DashboardNavTabItem(id: 'W14', icon: Icons.info, label: loc.dashboardTabPlanazoo, screen: 'planData'),
      DashboardNavTabItem(id: 'W15', icon: Icons.calendar_today, label: loc.dashboardTabCalendar, screen: 'calendar'),
      DashboardNavTabItem(id: 'W16', icon: Icons.group, label: loc.dashboardTabIn, screen: 'participants'),
      DashboardNavTabItem(id: 'W17', icon: Icons.bar_chart, label: loc.dashboardTabStats, screen: 'stats'),
      DashboardNavTabItem(id: 'W18', icon: Icons.payment, label: loc.dashboardTabPayments, screen: 'payments'),
      DashboardNavTabItem(id: 'W19', icon: Icons.chat_bubble_outline, label: loc.dashboardTabChat, screen: 'chat'),
      DashboardNavTabItem(id: 'W20', icon: Icons.notifications_outlined, label: loc.dashboardTabNotifications, screen: 'unifiedNotifications', smallLabel: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // W14 empieza en C6 (índice 5); hay 12 celdas hasta W25 (C17).
    const startColumn = 5;
    const totalCells = 12;

    return Positioned(
      left: columnWidth * startColumn,
      top: rowHeight,
      child: SizedBox(
        width: columnWidth * totalCells,
        height: rowHeight,
        child: Row(
          children: [
            for (int i = 0; i < totalCells; i++) ...[
              if (i < tabs.length)
                _NavTabCell(
                  width: columnWidth,
                  height: rowHeight,
                  item: tabs[i],
                  isSelected: selectedId == tabs[i].id,
                  onTap: () => onTabTap(tabs[i].id, tabs[i].screen),
                )
              else
                _EmptyNavCell(
                  width: columnWidth,
                  height: rowHeight,
                  isSelected: false,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavTabCell extends StatelessWidget {
  final double width;
  final double height;
  final DashboardNavTabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTabCell({
    required this.width,
    required this.height,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? Colors.white : Colors.grey.shade400;
    final fontSize = item.smallLabel ? 10.0 : 12.0;
    final badgeCount = item.badgeCount ?? 0;
    final showBadge = badgeCount > 0;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColorScheme.color2 : Colors.grey.shade800,
          borderRadius: isSelected
              ? const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )
              : null,
          border: isSelected
              ? Border.all(color: AppColorScheme.color2, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
          onTap: onTap,
          borderRadius: isSelected
              ? const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )
              : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: textColor,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (showBadge)
                Positioned(
                  top: 2,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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

class _EmptyNavCell extends StatelessWidget {
  final double width;
  final double height;
  final bool isSelected;

  const _EmptyNavCell({
    required this.width,
    required this.height,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColorScheme.color2 : Colors.grey.shade800,
          border: isSelected
              ? Border.all(color: AppColorScheme.color2, width: 2)
              : null,
        ),
      ),
    );
  }
}
