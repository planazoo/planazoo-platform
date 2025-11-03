import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/shared/utils/days_remaining_utils.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

/// T112: Widget para mostrar el indicador de días restantes hasta el inicio del plan
/// Se actualiza automáticamente cada minuto para reflejar cambios de día
class DaysRemainingIndicator extends StatefulWidget {
  final Plan plan;
  final double? fontSize;
  final bool compact; // Si true, muestra versión compacta (solo número o badge)
  final bool showIcon;
  final bool showStartingSoonBadge;

  const DaysRemainingIndicator({
    super.key,
    required this.plan,
    this.fontSize,
    this.compact = false,
    this.showIcon = true,
    this.showStartingSoonBadge = true,
  });

  @override
  State<DaysRemainingIndicator> createState() => _DaysRemainingIndicatorState();
}

class _DaysRemainingIndicatorState extends State<DaysRemainingIndicator> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Configurar timer para actualizar cada minuto (para cambios de día)
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          // Forzar reconstrucción para recalcular días restantes
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    // Solo mostrar si el plan está en estado "confirmado"
    if (!DaysRemainingUtils.shouldShowDaysRemaining(plan)) {
      return const SizedBox.shrink();
    }

    final daysRemaining = DaysRemainingUtils.calculateDaysRemaining(plan);
    if (daysRemaining == null) return const SizedBox.shrink();

    final isStartingSoon = DaysRemainingUtils.shouldShowStartingSoon(plan);
    final text = DaysRemainingUtils.getDaysRemainingText(daysRemaining);

    if (widget.compact) {
      return _buildCompactVersion(daysRemaining, isStartingSoon);
    } else {
      return _buildFullVersion(daysRemaining, isStartingSoon, text);
    }
  }

  Widget _buildCompactVersion(int daysRemaining, bool isStartingSoon) {
    if (widget.showStartingSoonBadge && isStartingSoon) {
      // Badge compacto "Inicia pronto"
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: widget.fontSize ?? 10,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              daysRemaining == 0 ? 'Hoy' : '$daysRemaining',
              style: TextStyle(
                fontSize: widget.fontSize ?? 10,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      );
    } else {
      // Solo número
      return Text(
        '$daysRemaining',
        style: TextStyle(
          fontSize: widget.fontSize ?? 12,
          fontWeight: FontWeight.bold,
          color: AppColorScheme.color2,
        ),
      );
    }
  }

  Widget _buildFullVersion(int daysRemaining, bool isStartingSoon, String text) {
    Color textColor;
    Color? backgroundColor;
    IconData icon;

    if (daysRemaining == 0) {
      // Inicia hoy - destacado
      textColor = Colors.white;
      backgroundColor = Colors.green;
      icon = Icons.today;
    } else if (isStartingSoon) {
      // Inicia pronto - advertencia
      textColor = Colors.orange.shade700;
      backgroundColor = Colors.orange.shade50;
      icon = Icons.access_time;
    } else {
      // Normal
      textColor = AppColorScheme.color2;
      backgroundColor = null;
      icon = Icons.calendar_today;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: backgroundColor != null
            ? Border.all(color: textColor.withOpacity(0.3), width: 1)
            : null,
      ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcon)
              Icon(
                icon,
                size: widget.fontSize != null ? widget.fontSize! + 2 : 14,
                color: textColor,
              ),
            if (widget.showIcon) const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: widget.fontSize ?? 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (widget.showStartingSoonBadge && isStartingSoon) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Inicia pronto',
                style: TextStyle(
                  fontSize: (widget.fontSize ?? 12) - 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

