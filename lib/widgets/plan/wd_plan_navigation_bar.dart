import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Barra de navegación horizontal para las opciones del plan en mobile
/// Equivalente a los widgets W14-W25 del dashboard web
class PlanNavigationBar extends StatelessWidget {
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;
  /// Si false, la pestaña Estadísticas no se muestra (solo visible para organizador).
  final bool showStatsTab;

  const PlanNavigationBar({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
    this.showStatsTab = true,
  });

  // Opciones principales del plan (T252: añadida "Mi resumen")
  static List<NavigationOption> _allOptions(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      NavigationOption(
        id: 'planData',
        icon: Icons.info,
        label: 'Info',
      ),
      NavigationOption(
        id: 'mySummary',
        icon: Icons.list_alt,
        label: loc.myPlanSummaryTab,
      ),
      NavigationOption(
        id: 'calendar',
        icon: Icons.calendar_today,
        label: 'Calendario',
      ),
      NavigationOption(
        id: 'participants',
        icon: Icons.group,
        label: 'Participantes',
      ),
      NavigationOption(
        id: 'chat',
        icon: Icons.chat_bubble_outline,
        label: 'Chat',
      ),
      // P17: Pagos entre Chat y Estadística (lista de puntos a corregir)
      NavigationOption(
        id: 'payments',
        icon: Icons.payment,
        label: 'Pagos',
      ),
      NavigationOption(
        id: 'stats',
        icon: Icons.bar_chart,
        label: 'Stats',
      ),
      NavigationOption(
        id: 'planNotifications',
        icon: Icons.notifications_outlined,
        label: loc.notificationsTitle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final options = _allOptions(context)
        .where((o) => o.id != 'stats' || showStatsTab)
        .toList();
    // P3: pantallas muy estrechas (p. ej. iPhone SE) — menos padding e iconos algo más pequeños
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 360;
    final barHeight = compact ? 52.0 : 56.0;
    final hPad = compact ? 6.0 : 12.0;
    final vPad = compact ? 6.0 : 8.0;
    final tabPad = compact ? 2.0 : 4.0;
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade700.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = selectedOption == option.id;
          
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: tabPad),
            child: _NavigationButton(
              option: option,
              isSelected: isSelected,
              compact: compact,
              onTap: () => onOptionSelected(option.id),
            ),
          );
        },
      ),
    );
  }
}

class NavigationOption {
  final String id;
  final IconData icon;
  final String label;

  const NavigationOption({
    required this.id,
    required this.icon,
    required this.label,
  });
}

class _NavigationButton extends StatelessWidget {
  final NavigationOption option;
  final bool isSelected;
  final VoidCallback onTap;
  /// P3: modo compacto para pantallas estrechas
  final bool compact;

  const _NavigationButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final side = compact ? 42.0 : 48.0;
    final iconSize = compact ? 20.0 : 24.0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: side,
        height: side,
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
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
                ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColorScheme.color2.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Center(
          child: Semantics(
            label: option.label,
            button: true,
            selected: isSelected,
            child: Icon(
              option.icon,
              color: isSelected ? Colors.white : AppColorScheme.color2,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

