import 'dart:convert';

/// Logical evaluator for auth/login scenarios used by both
/// the CLI test runner and unit tests.
///
/// Input is a plain JSON-like map (coming from tests/login_cases.json),
/// output is a normalized result:
///   { "status": "success"|"error", "messageKey": String? }
Map<String, dynamic> evaluateAuthLogin(Map<String, dynamic> input) {
  final backendResult = input['backendResult']?.toString() ?? 'unknown';

  switch (backendResult) {
    case 'ok':
      return {
        'status': 'success',
        'messageKey': null,
      };
    case 'user_not_found_email':
      return {
        'status': 'error',
        'messageKey': 'user-not-found',
      };
    case 'user_not_found_username':
      return {
        'status': 'error',
        'messageKey': 'username-not-found',
      };
    case 'wrong_password':
      return {
        'status': 'error',
        'messageKey': 'wrong-password',
      };
    case 'invalid_identifier_format':
      return {
        'status': 'error',
        'messageKey': 'invalid-email-or-username',
      };
    default:
      return {
        'status': 'error',
        'messageKey': 'loginUnknownError',
      };
  }
}

/// Utility to compare expected vs actual maps. Returns `null` if equal,
/// otherwise a short human-readable diff.
String? compareOutputs(Map<String, dynamic> expected, Map<String, dynamic> actual) {
  final expectedJson = jsonEncode(expected);
  final actualJson = jsonEncode(actual);
  if (expectedJson == actualJson) {
    return null;
  }
  return 'expected $expectedJson but got $actualJson';
}

