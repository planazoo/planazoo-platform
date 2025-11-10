import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/security/utils/validator.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

class PasswordRulesChecklist extends StatelessWidget {
  const PasswordRulesChecklist({
    super.key,
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final status = Validator.getPasswordRulesStatus(password);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.isValid
              ? Colors.green.shade200
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.passwordRulesTitle,
            style: AppTypography.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorScheme.color4,
            ),
          ),
          const SizedBox(height: 12),
          _RuleRow(
            fulfilled: status.hasMinLength,
            label: loc.passwordMinLength,
          ),
          _RuleRow(
            fulfilled: status.hasLowercase,
            label: loc.passwordNeedsLowercase,
          ),
          _RuleRow(
            fulfilled: status.hasUppercase,
            label: loc.passwordNeedsUppercase,
          ),
          _RuleRow(
            fulfilled: status.hasNumber,
            label: loc.passwordNeedsNumber,
          ),
          _RuleRow(
            fulfilled: status.hasSpecialChar,
            label: loc.passwordNeedsSpecialChar,
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.fulfilled,
    required this.label,
  });

  final bool fulfilled;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = fulfilled ? Colors.green.shade600 : Colors.grey.shade500;
    final icon = fulfilled ? Icons.check_circle : Icons.radio_button_unchecked;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyStyle.copyWith(
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

