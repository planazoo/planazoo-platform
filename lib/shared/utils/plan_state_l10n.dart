import 'package:unp_calendario/l10n/app_localizations.dart';

String localizedPlanStateLabel(AppLocalizations loc, String? state) {
  final normalized = (state == null || state.isEmpty || state == 'borrador')
      ? 'planificando'
      : state;
  switch (normalized) {
    case 'planificando':
      return loc.planStateLabelPlanning;
    case 'confirmado':
      return loc.planStateLabelConfirmed;
    case 'en_curso':
      return loc.planStateLabelInProgress;
    case 'finalizado':
      return loc.planStateLabelFinished;
    case 'cancelado':
      return loc.planStateLabelCancelled;
    default:
      return loc.planStateLabelUnknown;
  }
}

String localizedPlanStateActionLabel(AppLocalizations loc, String state) {
  switch (state) {
    case 'confirmado':
      return loc.planStateActionConfirm;
    case 'en_curso':
      return loc.planStateActionMarkInProgress;
    case 'planificando':
      return loc.planStateActionBackToPlanning;
    case 'cancelado':
      return loc.planStateActionCancelPlan;
    case 'finalizado':
      return loc.planStateActionFinish;
    default:
      return localizedPlanStateLabel(loc, state);
  }
}
