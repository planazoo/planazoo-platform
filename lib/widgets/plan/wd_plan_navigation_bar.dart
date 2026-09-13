import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Barra de navegación horizontal para las opciones del plan en mobile.
/// Nav por defecto: 5 pestañas (info · resumen · agenda · personas · pagos).
/// Chat / notificaciones van en la barra inferior; notas / stats viven en Info.
class PlanNavigationBar extends StatelessWidget {
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;
  /// Legacy: stats ya no está en la nav por defecto; se ignora salvo allowedOptionIds.
  final bool showStatsTab;
  /// T276: si no es null, solo se muestran estas pestañas (p. ej. preview pending).
  final Set<String>? allowedOptionIds;

  const PlanNavigationBar({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
    this.showStatsTab = true,
    this.allowedOptionIds,
  });

  /// IDs visibles cuando [allowedOptionIds] es null.
  static const Set<String> defaultOptionIds = {
    'planData',
    'mySummary',
    'calendar',
    'participants',
    'payments',
  };

  /// Catálogo completo (ids de routing estables). Etiquetas en minúsculas de presentación.
  static List<NavigationOption> _allOptions(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      const NavigationOption(
        id: 'planData',
        icon: Icons.info_outline,
        label: 'info',
      ),
      const NavigationOption(
        id: 'mySummary',
        icon: Icons.list_alt,
        label: 'resumen',
      ),
      const NavigationOption(
        id: 'calendar',
        icon: Icons.calendar_today_outlined,
        label: 'agenda',
      ),
      const NavigationOption(
        id: 'participants',
        icon: Icons.group_outlined,
        label: 'personas',
      ),
      const NavigationOption(
        id: 'payments',
        icon: Icons.payments_outlined,
        label: 'pagos',
      ),
      // Fuera de la nav por defecto; se conservan para allowedOptionIds / deep links.
      NavigationOption(
        id: 'chat',
        icon: Icons.chat_bubble_outline,
        label: 'chat',
      ),
      NavigationOption(
        id: 'planNotifications',
        icon: Icons.notifications_outlined,
        label: loc.notificationsTitle.toLowerCase(),
      ),
      NavigationOption(
        id: 'planNotes',
        icon: Icons.note_alt_outlined,
        label: loc.planNotesTabTitle.toLowerCase(),
      ),
      const NavigationOption(
        id: 'stats',
        icon: Icons.bar_chart,
        label: 'stats',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable — showStatsTab conservado por API; stats fuera de nav default.
    final _ = showStatsTab;
    final options = _allOptions(context).where((o) {
      if (allowedOptionIds != null) {
        return allowedOptionIds!.contains(o.id);
      }
      return defaultOptionIds.contains(o.id);
    }).toList();

    return Material(
      color: IosFormColors.pageBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: [
            for (final option in options)
              Expanded(
                child: _NavigationButton(
                  option: option,
                  isSelected: selectedOption == option.id,
                  onTap: () => onOptionSelected(option.id),
                ),
              ),
          ],
        ),
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

  const _NavigationButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppColorScheme.color2 : IosFormColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Semantics(
          label: option.label,
          button: true,
          selected: isSelected,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(option.icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppColorScheme.color2 : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
