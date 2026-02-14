import 'dart:convert';

/// Evaluador lógico para creación de eventos (casos EVENT-C-*).
///
/// No crea eventos reales ni toca Firestore; solo aplica reglas de negocio
/// simplificadas sobre los inputs del modal.
///
/// Inputs soportados:
///   - hasDescription, durationMinutes, participantsCount, maxParticipants
///   - cost (num?) — EVENT-C-011; si < 0 -> invalidCost
///   - planStartDate, planEndDate, eventDate (ISO date strings) — EVENT-C-017
///
/// Devuelve:
///   { "created": bool, "errorCode": String? }
Map<String, dynamic> evaluateEventCreation(Map<String, dynamic> input) {
  final hasDescription = input['hasDescription'] == true;
  final durationMinutes = (input['durationMinutes'] as num?)?.toInt() ?? 0;
  final participantsCount = (input['participantsCount'] as num?)?.toInt() ?? 0;
  final maxParticipants = input['maxParticipants'] as num?;
  final cost = input['cost'] as num?;
  final planStartStr = input['planStartDate'] as String?;
  final planEndStr = input['planEndDate'] as String?;
  final eventDateStr = input['eventDate'] as String?;

  // Regla 1: descripción obligatoria (EVENT-C-002)
  if (!hasDescription) {
    return {
      'created': false,
      'errorCode': 'missingDescription',
    };
  }

  // Regla 2: duración máxima 24h (EVENT-C-006)
  const maxDurationMinutes = 24 * 60;
  if (durationMinutes > maxDurationMinutes) {
    return {
      'created': false,
      'errorCode': 'eventDurationTooLong',
    };
  }

  // Regla 3: límite de participantes (EVENT-C-009)
  if (maxParticipants != null) {
    final max = maxParticipants.toInt();
    if (participantsCount > max) {
      return {
        'created': false,
        'errorCode': 'eventMaxParticipantsExceeded',
      };
    }
  }

  // Regla 4: coste no negativo (EVENT-C-011)
  if (cost != null && cost.toDouble() < 0) {
    return {
      'created': false,
      'errorCode': 'invalidCost',
    };
  }

  // Regla 5: evento dentro del rango del plan (EVENT-C-017)
  if (planStartStr != null && planEndStr != null && eventDateStr != null) {
    try {
      final planStart = DateTime.parse(planStartStr);
      final planEnd = DateTime.parse(planEndStr);
      final eventDate = DateTime.parse(eventDateStr);
      final eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
      final planStartOnly = DateTime(planStart.year, planStart.month, planStart.day);
      final planEndOnly = DateTime(planEnd.year, planEnd.month, planEnd.day);
      if (eventDateOnly.isBefore(planStartOnly) || eventDateOnly.isAfter(planEndOnly)) {
        return {
          'created': false,
          'errorCode': 'eventOutsidePlanRange',
        };
      }
    } catch (_) {
      // Si las fechas no parsean, no aplicamos la regla
    }
  }

  return {
    'created': true,
    'errorCode': null,
  };
}

String? compareEventOutputs(
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

