import 'package:flutter/material.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/plan_validation_utils.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// VALID-1, VALID-2: validaciones del plan antes de confirmar (bottom sheet patrón D).
class PlanValidationDialog extends StatelessWidget {
  const PlanValidationDialog({
    super.key,
    required this.validation,
    this.participantNames = const [],
  });

  final PlanValidationUtils validation;
  final List<String> participantNames;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (validation.warnings.isEmpty && validation.errors.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasErrors = validation.errors.isNotEmpty;
    final title =
        hasErrors ? loc.planValidationErrorTitle : loc.planValidationReviewTitle;
    final intro = hasErrors
        ? loc.planValidationErrorsIntro
        : loc.planValidationWarningsIntro;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasErrors
                        ? Icons.error_outline
                        : Icons.warning_amber_rounded,
                    color: hasErrors
                        ? IosFormColors.danger
                        : Colors.orange.shade700,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: hasErrors
                            ? IosFormColors.danger
                            : IosFormColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: IosGroupedCard(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Text(
                          intro,
                          style: const TextStyle(
                            color: IosFormColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                      for (var i = 0; i < validation.errors.length; i++) ...[
                        const IosRowSeparator(),
                        _ValidationRow(
                          text: validation.errors[i],
                          color: IosFormColors.danger,
                          icon: Icons.error_outline,
                        ),
                      ],
                      if (validation.warnings.isNotEmpty) ...[
                        const IosRowSeparator(),
                        if (validation.errors.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Text(
                              loc.planValidationWarningsHint,
                              style: const TextStyle(
                                color: IosFormColors.textSecondary,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        for (var i = 0; i < validation.warnings.length; i++) ...[
                          const IosRowSeparator(),
                          _ValidationRow(
                            text: validation.warnings[i],
                            color: Colors.orange.shade800,
                            icon: Icons.info_outline,
                          ),
                        ],
                      ],
                      const IosRowSeparator(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 18,
                              color: IosFormColors.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hasErrors
                                    ? loc.planValidationErrorsFooter
                                    : loc.planValidationWarningsFooter,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: IosFormColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (hasErrors)
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          loc.close,
                          style: const TextStyle(
                            color: IosFormColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                IosFormSheetActions(
                  cancelLabel: loc.planValidationGoBack,
                  confirmLabel: loc.planValidationConfirmAnyway,
                  onCancel: () => Navigator.of(context).pop(false),
                  onConfirm: () => Navigator.of(context).pop(true),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  const _ValidationRow({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: IosFormColors.textPrimary,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showPlanValidationDialog({
  required BuildContext context,
  required PlanValidationUtils validation,
  List<String> participantNames = const [],
}) async {
  if (validation.warnings.isEmpty && validation.errors.isEmpty) {
    return true;
  }

  return showModalBottomSheet<bool>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: IosFormColors.groupedBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (context) => PlanValidationDialog(
      validation: validation,
      participantNames: participantNames,
    ),
  );
}
