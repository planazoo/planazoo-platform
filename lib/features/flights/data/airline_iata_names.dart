/// Nombres de aerolínea frecuentes a partir del prefijo IATA del nº de vuelo.
/// Solo como sugerencia suave si Amadeus no devuelve [airlineName].
String? airlineNameFromFlightNumber(String flightNumber) {
  final match = RegExp(r'^([A-Za-z]{2})\s*\d').firstMatch(flightNumber.trim());
  if (match == null) return null;
  final code = match.group(1)!.toUpperCase();
  return _iataAirlineNames[code];
}

const Map<String, String> _iataAirlineNames = {
  'IB': 'Iberia',
  'I2': 'Iberia Express',
  'YW': 'Air Nostrum',
  'UX': 'Air Europa',
  'VY': 'Vueling',
  'FR': 'Ryanair',
  'U2': 'easyJet',
  'LS': 'Jet2',
  'BA': 'British Airways',
  'EI': 'Aer Lingus',
  'AF': 'Air France',
  'KL': 'KLM',
  'LH': 'Lufthansa',
  'LX': 'Swiss',
  'OS': 'Austrian',
  'SN': 'Brussels Airlines',
  'TP': 'TAP Air Portugal',
  'AZ': 'ITA Airways',
  'AY': 'Finnair',
  'SK': 'SAS',
  'DY': 'Norwegian',
  'TK': 'Turkish Airlines',
  'EK': 'Emirates',
  'QR': 'Qatar Airways',
  'EY': 'Etihad',
  'AA': 'American Airlines',
  'UA': 'United Airlines',
  'DL': 'Delta Air Lines',
  'AC': 'Air Canada',
  'QF': 'Qantas',
  'SQ': 'Singapore Airlines',
  'CX': 'Cathay Pacific',
  'NH': 'ANA',
  'JL': 'Japan Airlines',
  'W6': 'Wizz Air',
  'PC': 'Pegasus',
  'HV': 'Transavia',
  'TO': 'Transavia France',
  'EW': 'Eurowings',
  'DE': 'Condor',
  'X3': 'TUI fly',
  'OR': 'TUI fly Netherlands',
  'BY': 'TUI Airways',
};
