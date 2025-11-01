import 'package:flutter/material.dart';
import '../../domain/services/plan_state_service.dart';
import '../../domain/models/plan.dart';

/// Widget que muestra un badge con el estado actual del plan
/// 
/// Usa los colores y etiquetas definidos en `PlanStateService.getStateDisplayInfo()`
class PlanStateBadge extends StatelessWidget {
  final Plan plan;
  final bool showIcon;
  final EdgeInsets? padding;
  final double? fontSize;

  const PlanStateBadge({
    super.key,
    required this.plan,
    this.showIcon = true,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final stateInfo = PlanStateService.getStateDisplayInfo(plan.state);
    final stateLabel = stateInfo['label'] as String;
    final stateColor = Color(stateInfo['color'] as int);
    final stateIcon = stateInfo['icon'] as IconData;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: stateColor.withOpacity(0.1),
        border: Border.all(color: stateColor.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              stateIcon,
              size: (fontSize ?? 12) + 2,
              color: stateColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            stateLabel,
            style: TextStyle(
              color: stateColor,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Versión compacta del badge (solo texto, sin icono)
class PlanStateBadgeCompact extends StatelessWidget {
  final Plan plan;
  final double? fontSize;

  const PlanStateBadgeCompact({
    super.key,
    required this.plan,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return PlanStateBadge(
      plan: plan,
      showIcon: false,
      padding: EdgeInsets.symmetric(
        horizontal: fontSize != null && fontSize! < 8 ? 4 : 6, 
        vertical: fontSize != null && fontSize! < 8 ? 1 : 2,
      ),
      fontSize: fontSize ?? 10,
    );
  }
}

