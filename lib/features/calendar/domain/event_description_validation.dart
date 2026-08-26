/// Descripción al crear/editar evento (modal + EVENT-C-002).
enum EventDescriptionValidationError { empty }

EventDescriptionValidationError? validateEventDescription(String? value) {
  if ((value?.trim() ?? '').isEmpty) {
    return EventDescriptionValidationError.empty;
  }
  return null;
}
