import 'package:flutter/material.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import '../../domain/models/plan.dart';
import '../../domain/services/plan_state_service.dart';
import '../../../../shared/utils/plan_state_l10n.dart';
import '../../../../widgets/common/ios_grouped_form.dart';

/// Confirmación para cambiar el estado de un plan (bottom sheet patrón D).
class StateTransitionDialog extends StatelessWidget {
  const StateTransitionDialog({
    super.key,
    required this.plan,
    required this.newState,
    this.customMessage,
  });

  final Plan plan;
  final String newState;
  final String? customMessage;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentState = plan.state ?? 'planificando';
    final currentLabel = localizedPlanStateLabel(loc, currentState);
    final newLabel = localizedPlanStateLabel(loc, newState);

    late final String title;
    late final String message;
    late final String confirmLabel;
    var destructive = false;

    switch (newState) {
      case 'confirmado':
        title = loc.planStateTransitionConfirmTitle;
        message = customMessage ?? loc.planStateTransitionConfirmMessage;
        confirmLabel = loc.confirm;
        break;
      case 'en_curso':
        title = loc.planStateTransitionInProgressTitle;
        message = customMessage ?? loc.planStateTransitionInProgressMessage;
        confirmLabel = loc.confirm;
        break;
      case 'finalizado':
        title = loc.planStateTransitionFinishedTitle;
        message = customMessage ?? loc.planStateTransitionFinishedMessage;
        confirmLabel = loc.confirm;
        break;
      case 'cancelado':
        title = loc.planStateTransitionCancelTitle;
        destructive = true;
        message = customMessage ?? loc.planStateTransitionCancelMessage;
        confirmLabel = loc.planStateTransitionCancelPlanButton;
        break;
      case 'planificando':
        title = loc.planStateTransitionPlanningTitle;
        message = customMessage ?? loc.planStateTransitionPlanningMessage;
        confirmLabel = loc.confirm;
        break;
      default:
        title = loc.planStateTransitionGenericTitle;
        message = customMessage ??
            loc.planStateTransitionGenericMessage(currentLabel, newLabel);
        confirmLabel = loc.confirm;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: IosFormColors.separator,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: IosFormColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            IosGroupedCard(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StateChip(label: currentLabel, state: currentState),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: IosFormColors.textSecondary,
                            ),
                          ),
                          _StateChip(label: newLabel, state: newState),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: const TextStyle(
                          color: IosFormColors.textSecondary,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IosFormSheetActions(
              cancelLabel: loc.cancel,
              confirmLabel: confirmLabel,
              confirmDestructive: destructive,
              onCancel: () => Navigator.of(context).pop(false),
              onConfirm: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.label, required this.state});

  final String label;
  final String state;

  @override
  Widget build(BuildContext context) {
    final color =
        Color(PlanStateService.getStateDisplayInfo(state)['color'] as int);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Future<bool> showStateTransitionDialog({
  required BuildContext context,
  required Plan plan,
  required String newState,
  String? customMessage,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: IosFormColors.groupedBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (context) => StateTransitionDialog(
      plan: plan,
      newState: newState,
      customMessage: customMessage,
    ),
  );
  return result ?? false;
}
