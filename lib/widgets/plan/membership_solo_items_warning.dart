import 'package:unp_calendario/features/calendar/domain/services/plan_membership_side_effects.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Etiquetas cortas para la notificación al organizador (LISTA 121 B3).
List<String> soloOwnedItemLabelsForNotification(List<SoloOwnedPlanItem> items) {
  return items
      .map((i) => i.isAccommodation ? 'Alojamiento: ${i.title}' : 'Evento: ${i.title}')
      .toList(growable: false);
}

/// Formatea el aviso B3 (LISTA 121) para diálogos de salir / expulsar.
String formatMembershipSoloItemsWarning(
  AppLocalizations loc,
  List<SoloOwnedPlanItem> items, {
  required bool leavingSelf,
  int maxListed = 5,
}) {
  if (items.isEmpty) return '';
  final lines = <String>[];
  final shown = items.take(maxListed).toList();
  for (final item in shown) {
    lines.add(
      item.isAccommodation
          ? loc.membershipSoloItemAccommodationBullet(item.title)
          : loc.membershipSoloItemEventBullet(item.title),
    );
  }
  final remaining = items.length - shown.length;
  if (remaining > 0) {
    lines.add(loc.membershipSoloItemsAndMore(remaining));
  }
  final list = lines.join('\n');
  return leavingSelf
      ? loc.membershipSoloItemsLeaveWarning(list)
      : loc.membershipSoloItemsRemoveWarning(list);
}
