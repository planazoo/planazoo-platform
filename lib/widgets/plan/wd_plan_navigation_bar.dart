import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

/// Barra de navegación horizontal para las opciones del plan en mobile
/// Equivalente a los widgets W14-W25 del dashboard web
class PlanNavigationBar extends StatelessWidget {
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;

  const PlanNavigationBar({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  // Opciones principales del plan
  static const List<NavigationOption> _options = [
    NavigationOption(
      id: 'planData',
      icon: Icons.info,
      label: 'Info',
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
    NavigationOption(
      id: 'stats',
      icon: Icons.bar_chart,
      label: 'Stats',
    ),
    NavigationOption(
      id: 'payments',
      icon: Icons.payment,
      label: 'Pagos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _options.length,
        itemBuilder: (context, index) {
          final option = _options[index];
          final isSelected = selectedOption == option.id;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _NavigationButton(
              option: option,
              isSelected: isSelected,
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

  const _NavigationButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 48,
        height: 48,
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
          child: Icon(
            option.icon,
            color: isSelected ? Colors.white : AppColorScheme.color2,
            size: 24,
          ),
        ),
      ),
    );
  }
}

