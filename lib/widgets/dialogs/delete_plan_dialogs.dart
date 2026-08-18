import 'package:flutter/material.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Confirmación simple (dashboard). No borra: el caller llama a `deletePlan`.
Future<bool> showDeletePlanConfirmDialog(BuildContext context) async {
  final loc = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(loc.confirmDeleteTitle),
      content: Text(loc.confirmDeleteMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(loc.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Confirmación con contraseña (Info del plan).
class DeletePlanPasswordDialog extends StatefulWidget {
  final AppLocalizations loc;
  final Future<bool> Function(String password) onDelete;

  const DeletePlanPasswordDialog({
    super.key,
    required this.loc,
    required this.onDelete,
  });

  @override
  State<DeletePlanPasswordDialog> createState() =>
      _DeletePlanPasswordDialogState();
}

class _DeletePlanPasswordDialogState extends State<DeletePlanPasswordDialog> {
  late TextEditingController _passwordController;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AlertDialog(
      backgroundColor: cs.surface,
      surfaceTintColor: cs.surfaceTint,
      title: Text(
        widget.loc.planDeleteDialogTitle,
        style: theme.textTheme.titleLarge?.copyWith(color: cs.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.loc.planDeleteDialogMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            enabled: !_isDeleting,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: widget.loc.planDeleteDialogPasswordLabel,
              errorText: _errorText,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: cs.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              _isDeleting ? null : () => Navigator.of(context).pop(false),
          child: Text(widget.loc.cancelChanges),
        ),
        FilledButton(
          onPressed: _isDeleting
              ? null
              : () async {
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
                  if (!context.mounted) return;
                  if (success) {
                    Navigator.of(context).pop(true);
                  } else {
                    setState(() {
                      _isDeleting = false;
                      _errorText = widget.loc.planDeleteDialogAuthError;
                    });
                  }
                },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.loc.planDeleteDialogConfirm),
        ),
      ],
    );
  }
}
