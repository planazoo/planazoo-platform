import 'dart:convert';

import 'package:unp_calendario/features/security/utils/validator.dart';

/// Evaluador lógico para validación de contraseñas.
///
/// Envuelve a `Validator.validatePassword` y devuelve un mapa JSON-friendly:
///   { "isValid": bool, "errorCode": String? }
Map<String, dynamic> evaluatePassword(Map<String, dynamic> input) {
  final password = input['password']?.toString();
  final result = Validator.validatePassword(password);
  return {
    'isValid': result.isValid,
    'errorCode': result.errorCode,
  };
}

/// Compara salidas esperada/real de validación de contraseña.
String? comparePasswordOutputs(
  Map<String, dynamic> expected,
  Map<String, dynamic> actual,
) {
  final expectedJson = jsonEncode(expected);
  final actualJson = jsonEncode(actual);
  if (expectedJson == actualJson) {
    return null;
  }
  return 'expected $expectedJson but got $actualJson';
}

