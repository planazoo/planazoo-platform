import 'package:flutter/material.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Confirmación al borrar un evento (EVENT-D-003). No borra: el caller llama a `deleteEvent`.
Future<bool> showDeleteEventConfirmDialog(
  BuildContext context, {
  required String description,
}) async {
  final loc = AppLocalizations.of(context)!;
  return IosFormConfirmSheet.show(
    context: context,
    title: loc.confirmDeleteTitle,
    message: loc.confirmDeleteEventMessage(description),
    cancelLabel: loc.cancel,
    confirmLabel: loc.delete,
    destructive: true,
  );
}
