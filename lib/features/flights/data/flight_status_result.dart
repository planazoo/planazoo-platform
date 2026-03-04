/// Resultado normalizado de Amadeus On-Demand Flight Status (T246).
class FlightStatusResult {
  final String flightNumber;
  final String? carrierCode;
  final String? originIata;
  final String? destinationIata;
  final String? originName;
  final String? destinationName;
  final String? departureScheduled;
  final String? arrivalScheduled;
  final int? durationMinutes;
  final String? airlineName;

  const FlightStatusResult({
    required this.flightNumber,
    this.carrierCode,
    this.originIata,
    this.destinationIata,
    this.originName,
    this.destinationName,
    this.departureScheduled,
    this.arrivalScheduled,
    this.durationMinutes,
    this.airlineName,
  });

  factory FlightStatusResult.fromMap(Map<String, dynamic> map) {
    return FlightStatusResult(
      flightNumber: map['flightNumber'] as String? ?? '',
      carrierCode: map['carrierCode'] as String?,
      originIata: map['originIata'] as String?,
      destinationIata: map['destinationIata'] as String?,
      originName: map['originName'] as String?,
      destinationName: map['destinationName'] as String?,
      departureScheduled: map['departureScheduled'] as String?,
      arrivalScheduled: map['arrivalScheduled'] as String?,
      durationMinutes: map['durationMinutes'] as int?,
      airlineName: map['airlineName'] as String?,
    );
  }

  /// Descripción corta para el evento: "IB6842 Madrid (MAD) → Roma (FCO)".
  String get shortDescription {
    final from = originIata ?? originName ?? '';
    final to = destinationIata ?? destinationName ?? '';
    if (from.isEmpty && to.isEmpty) return flightNumber;
    if (from.isEmpty) return '$flightNumber → $to';
    if (to.isEmpty) return '$flightNumber $from →';
    return '$flightNumber $from → $to';
  }
}
