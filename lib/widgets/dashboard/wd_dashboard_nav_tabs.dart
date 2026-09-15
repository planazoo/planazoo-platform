import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

/// Definición de una pestaña de navegación del dashboard (W14–W20).
class DashboardNavTabItem {
  final String id;
  final IconData icon;
  final String label;
  final String screen;
  /// Badge de no leídas (p. ej. en W20).
  final int? badgeCount;

  const DashboardNavTabItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.screen,
    this.badgeCount,
  });

  DashboardNavTabItem copyWith({int? badgeCount}) {
    return DashboardNavTabItem(
      id: id,
      icon: icon,
      label: label,
      screen: screen,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }
}

/// Fila de pestañas de navegación del dashboard (W14–W25).
/// Las primeras [tabs.length] celdas son secciones; [utilityTabs] van después
/// (chat / avisos, paridad con barra inferior móvil). El resto son celdas vacías.
class WdDashboardNavTabs extends StatelessWidget {
  final double columnWidth;
  final double rowHeight;
  final List<DashboardNavTabItem> tabs;
  /// Utilidades a la derecha (chat, notificaciones): no forman parte de las 5 secciones.
  final List<DashboardNavTabItem> utilityTabs;
  final String? selectedId;
  final void Function(String id, String screen) onTabTap;

  const WdDashboardNavTabs({
    super.key,
    required this.columnWidth,
    required this.rowHeight,
    required this.tabs,
    this.utilityTabs = const [],
    required this.selectedId,
    required this.onTabTap,
  });

  /// Nav de 5 (alineada a mobile): info · resumen · agenda · personas · pagos.
  static List<DashboardNavTabItem> tabItems(BuildContext context) {
    return [
      DashboardNavTabItem(
        id: 'W14',
        icon: Icons.info_outline,
        label: 'info',
        screen: 'planData',
      ),
      DashboardNavTabItem(
        id: 'W15_MYSUMMARY',
        icon: Icons.list_alt,
        label: 'resumen',
        screen: 'mySummary',
      ),
      DashboardNavTabItem(
        id: 'W15',
        icon: Icons.calendar_today_outlined,
        label: 'agenda',
        screen: 'calendar',
      ),
      DashboardNavTabItem(
        id: 'W16',
        icon: Icons.group_outlined,
        label: 'personas',
        screen: 'participants',
      ),
      DashboardNavTabItem(
        id: 'W18',
        icon: Icons.payments_outlined,
        label: 'pagos',
        screen: 'payments',
      ),
    ];
  }

  /// Chat / avisos / buscar (utilidades; badges vía [DashboardNavTabItem.badgeCount]).
  /// Buscar abre sheet (no cambia pantalla); chat/avisos sí.
  static List<DashboardNavTabItem> utilityTabItems() {
    return const [
      DashboardNavTabItem(
        id: 'W13_PLAN_SEARCH',
        icon: Icons.search,
        label: 'buscar',
        screen: 'planInSearch',
      ),
      DashboardNavTabItem(
        id: 'W19',
        icon: Icons.chat_bubble_outline,
        label: 'chat',
        screen: 'chat',
      ),
      DashboardNavTabItem(
        id: 'W20',
        icon: Icons.notifications_outlined,
        label: 'avisos',
        screen: 'unifiedNotifications',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // W14 empieza en C6 (índice 5); hay 12 celdas hasta W25 (C17).
    const startColumn = 5;
    const totalCells = 12;
    // 1 celda vacía entre secciones y utilidades.
    final gapAfterTabs = tabs.isNotEmpty && utilityTabs.isNotEmpty ? 1 : 0;
    final usedCells = tabs.length + gapAfterTabs + utilityTabs.length;

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
              else if (i >= tabs.length + gapAfterTabs &&
                  i < usedCells) ...[
                Builder(
                  builder: (context) {
                    final uIndex = i - tabs.length - gapAfterTabs;
                    final item = utilityTabs[uIndex];
                    return _NavUtilityCell(
                      width: columnWidth,
                      height: rowHeight,
                      item: item,
                      isSelected: selectedId == item.id,
                      onTap: () => onTabTap(item.id, item.screen),
                    );
                  },
                ),
              ] else
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
    final badgeCount = item.badgeCount ?? 0;
    final hasUnread = badgeCount > 0;
    final cellBg = const Color(0xFF111827);
    final textColor = isSelected
        ? Colors.white
        : (hasUnread
            ? AppColorScheme.color3
            : Colors.white70);
    const fontSize = 11.0;
    final pillWidth = width - 12;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: cellBg,
        ),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Container(
              width: pillWidth,
              height: 30,
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColorScheme.color2,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: Text(
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
            ),
          ),
        ),
      ),
    );
  }
}

class _NavUtilityCell extends StatelessWidget {
  final double width;
  final double height;
  final DashboardNavTabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavUtilityCell({
    required this.width,
    required this.height,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeCount = item.badgeCount ?? 0;
    final accent = AppColorScheme.color2;
    final color = isSelected ? Colors.white : Colors.white70;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: const Color(0xFF111827),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: isSelected
                  ? BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Badge(
                    isLabelVisible: badgeCount > 0,
                    label: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(fontSize: 9),
                    ),
                    child: Icon(item.icon, size: 16, color: color),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.label,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
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
          color: const Color(0xFF111827),
          border: isSelected
              ? Border.all(color: AppColorScheme.color2, width: 2)
              : null,
        ),
      ),
    );
  }
}
