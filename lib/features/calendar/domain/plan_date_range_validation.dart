/// Validación del rango de fechas del plan (Info + create/update).
///
/// Compara **días civiles** (año/mes/día), no instantes: mismo día es válido.
enum PlanDateRangeValidationError { endBeforeStart }

DateTime planCivilDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

PlanDateRangeValidationError? validatePlanDateRange(
  DateTime start,
  DateTime end,
) {
  final s = planCivilDate(start);
  final e = planCivilDate(end);
  if (e.isBefore(s)) return PlanDateRangeValidationError.endBeforeStart;
  return null;
}

/// Si el fin queda antes del inicio, lo iguala al inicio (datepickers de Info).
DateTime clampPlanEndToStart(DateTime start, DateTime end) {
  final s = planCivilDate(start);
  final e = planCivilDate(end);
  return e.isBefore(s) ? s : e;
}
