import 'package:flutter/material.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Confirmación simple (dashboard). No borra: el caller llama a `deletePlan`.
Future<bool> showDeletePlanConfirmDialog(BuildContext context) async {
  final loc = AppLocalizations.of(context)!;
  return IosFormConfirmSheet.show(
    context: context,
    title: loc.confirmDeleteTitle,
    message: loc.confirmDeleteMessage,
    cancelLabel: loc.cancel,
    confirmLabel: loc.delete,
    destructive: true,
  );
}

/// Confirmación con contraseña (Info del plan) — bottom sheet patrón D.
Future<bool> showDeletePlanPasswordSheet(
  BuildContext context, {
  required AppLocalizations loc,
  required Future<bool> Function(String password) onDelete,
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
    builder: (ctx) => _DeletePlanPasswordSheet(
      loc: loc,
      onDelete: onDelete,
    ),
  );
  return result ?? false;
}

class _DeletePlanPasswordSheet extends StatefulWidget {
  const _DeletePlanPasswordSheet({
    required this.loc,
    required this.onDelete,
  });

  final AppLocalizations loc;
  final Future<bool> Function(String password) onDelete;

  @override
  State<_DeletePlanPasswordSheet> createState() =>
      _DeletePlanPasswordSheetState();
}

class _DeletePlanPasswordSheetState extends State<_DeletePlanPasswordSheet> {
  late final TextEditingController _passwordController;
  bool _isDeleting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _errorText = widget.loc.planDeleteDialogPasswordRequired;
      });
      return;
    }
    setState(() {
      _isDeleting = true;
      _errorText = null;
    });
    final success = await widget.onDelete(password);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isDeleting = false;
        _errorText = widget.loc.planDeleteDialogAuthError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
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
                widget.loc.planDeleteDialogTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: IosFormColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.loc.planDeleteDialogMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: IosFormColors.textSecondary,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              IosGroupedCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !_isDeleting,
                      style: const TextStyle(
                        color: IosFormColors.textPrimary,
                        fontSize: 17,
                      ),
                      cursorColor: IosFormColors.accent,
                      decoration: InputDecoration(
                        labelText: widget.loc.planDeleteDialogPasswordLabel,
                        labelStyle: const TextStyle(
                          color: IosFormColors.textSecondary,
                          fontSize: 13,
                        ),
                        errorText: _errorText,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              IosFormSheetActions(
                cancelLabel: widget.loc.cancelChanges,
                confirmLabel: widget.loc.planDeleteDialogConfirm,
                confirmDestructive: true,
                onCancel: _isDeleting
                    ? () {}
                    : () => Navigator.of(context).pop(false),
                onConfirm: _isDeleting ? () {} : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
