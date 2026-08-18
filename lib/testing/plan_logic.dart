import 'package:unp_calendario/features/calendar/domain/plan_name_validation.dart';
import 'package:unp_calendario/features/calendar/domain/plan_date_range_validation.dart';

/// Evaluador lógico para creación de planes (casos PLAN-C-*).
///
/// Cubre la validación del nombre (misma regla que el modal) y del rango
/// de fechas si el caso incluye `startDate`/`endDate` ISO.
/// No escribe en Firestore; el create+read real está en
/// `test/features/calendar/plan_service_create_test.dart`.
///
/// Devuelve: `{ "created": bool, "errorCode": String?, "state": String? }`
Map<String, dynamic> evaluatePlanCreation(Map<String, dynamic> input) {
  final name = input['name'] as String?;
  final error = validatePlanName(name);
  if (error != null) {
    return {
      'created': false,
      'errorCode': switch (error) {
        PlanNameValidationError.empty => 'missingName',
        PlanNameValidationError.tooShort => 'nameTooShort',
        PlanNameValidationError.tooLong => 'nameTooLong',
      },
    };
  }

  final startRaw = input['startDate'];
  final endRaw = input['endDate'];
  if (startRaw is String && endRaw is String) {
    final rangeError = validatePlanDateRange(
      DateTime.parse(startRaw),
      DateTime.parse(endRaw),
    );
    if (rangeError != null) {
      return {
        'created': false,
        'errorCode': 'endBeforeStart',
      };
    }
  }

  return {
    'created': true,
    'errorCode': null,
    'state': 'planificando',
  };
}

String? comparePlanOutputs(
  Map<String, dynamic> expected,
  Map<String, dynamic> actual,
) {
  final diffs = <String>[];
  for (final key in expected.keys) {
    if (expected[key] != actual[key]) {
      diffs.add('$key: expected ${expected[key]}, actual ${actual[key]}');
    }
  }
  if (diffs.isEmpty) return null;
  return diffs.join('; ');
}
