import 'package:cloud_functions/cloud_functions.dart';
import 'package:unp_calendario/features/flights/data/flight_status_result.dart';

/// Servicio para obtener datos de un vuelo por número (T246 — Amadeus On-Demand Flight Status).
/// Llama a la Cloud Function [flightStatus] que usa Amadeus API.
class FlightStatusService {
  /// Obtiene datos del vuelo [flightNumber] (ej. IB6842) para la fecha [date] (YYYY-MM-DD).
  /// Si [date] es null, se usa la fecha actual.
  Future<FlightStatusResult?> getFlightStatus({
    required String flightNumber,
    String? date,
  }) async {
    final trimmed = flightNumber.trim();
    if (trimmed.isEmpty) return null;
    final dateStr = date ?? _todayIso();
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('flightStatus')
          .call(<String, dynamic>{
        'flightNumber': trimmed,
        'date': dateStr,
      });
      final data = result.data as Map<String, dynamic>?;
      if (data == null) return null;
      return FlightStatusResult.fromMap(data);
    } on FirebaseFunctionsException {
      rethrow;
    }
  }

  static String _todayIso() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
