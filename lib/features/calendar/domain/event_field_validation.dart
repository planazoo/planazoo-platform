import 'plan_date_range_validation.dart';

/// Duración máxima de un evento de calendario (EVENT-C-006). Más → alojamiento.
const kEventMaxDurationMinutes = 24 * 60;

enum EventDurationValidationError { tooLong }

enum EventCostValidationError { negative }

enum EventMaxParticipantsValidationError { exceeded }

enum EventPlanRangeValidationError { outside }

EventDurationValidationError? validateEventDurationMinutes(int minutes) {
  if (minutes > kEventMaxDurationMinutes) {
    return EventDurationValidationError.tooLong;
  }
  return null;
}

EventCostValidationError? validateEventCost(num? cost) {
  if (cost != null && cost.toDouble() < 0) {
    return EventCostValidationError.negative;
  }
  return null;
}

EventMaxParticipantsValidationError? validateEventMaxParticipants({
  required int? maxParticipants,
  required int participantsCount,
}) {
  if (maxParticipants == null) return null;
  if (participantsCount > maxParticipants) {
    return EventMaxParticipantsValidationError.exceeded;
  }
  return null;
}

/// Compara días civiles, igual que el rango del plan (EVENT-C-017).
EventPlanRangeValidationError? validateEventInPlanRange(
  DateTime eventDate,
  DateTime planStart,
  DateTime planEnd,
) {
  final day = planCivilDate(eventDate);
  final start = planCivilDate(planStart);
  final end = planCivilDate(planEnd);
  if (day.isBefore(start) || day.isAfter(end)) {
    return EventPlanRangeValidationError.outside;
  }
  return null;
}
