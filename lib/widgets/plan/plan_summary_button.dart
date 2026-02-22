import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/dialogs/plan_summary_dialog.dart';

/// T193: Botón que abre el resumen del plan (diálogo o panel W31).
/// Si [onShowInPanel] está definido, al pulsar se llama y no se abre el diálogo (p. ej. desde la lista del dashboard).
class PlanSummaryButton extends ConsumerWidget {
  final Plan plan;
  /// true = solo icono (cards); false = icono + texto "Resumen" (página de detalle).
  final bool iconOnly;
  /// Opcional: color del icono/texto (p. ej. en PlanDataScreen se usa gris).
  final Color? foregroundColor;
  /// Si se proporciona, al pulsar se muestra el resumen en el panel (W31) en lugar del diálogo.
  final void Function(Plan plan)? onShowInPanel;

  const PlanSummaryButton({
    super.key,
    required this.plan,
    this.iconOnly = true,
    this.foregroundColor,
    this.onShowInPanel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null || plan.id == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final color = foregroundColor ?? Colors.white70;

    if (iconOnly) {
      return IconButton(
        icon: Icon(Icons.summarize, size: 20, color: color),
        onPressed: () => _openSummary(context, ref),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        tooltip: l10n.planSummaryButtonTooltip,
      );
    }

    return TextButton.icon(
      onPressed: () => _openSummary(context, ref),
      icon: Icon(Icons.summarize, size: 18, color: color),
      label: Text(l10n.planSummaryButtonLabel, style: TextStyle(color: color, fontSize: 13)),
    );
  }

  void _openSummary(BuildContext context, WidgetRef ref) {
    if (onShowInPanel != null) {
      onShowInPanel!(plan);
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    showPlanSummaryDialog(context: context, plan: plan, userId: user.id);
  }
}
