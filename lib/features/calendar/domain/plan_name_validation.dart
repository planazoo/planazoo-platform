/// Validación del nombre al crear un plan (modal + pruebas lógicas).
enum PlanNameValidationError { empty, tooShort, tooLong }

const int kPlanNameMinLength = 3;
const int kPlanNameMaxLength = 100;

PlanNameValidationError? validatePlanName(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return PlanNameValidationError.empty;
  if (trimmed.length < kPlanNameMinLength) {
    return PlanNameValidationError.tooShort;
  }
  if (trimmed.length > kPlanNameMaxLength) {
    return PlanNameValidationError.tooLong;
  }
  return null;
}
