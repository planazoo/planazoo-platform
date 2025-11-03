/// Modelo de moneda para soporte multi-moneda (T153)
class Currency {
  final String code; // ISO 4217: EUR, USD, GBP, JPY, etc.
  final String symbol; // €, $, £, ¥
  final String name; // Euro, US Dollar, British Pound
  final int decimalDigits; // 2 para EUR/USD, 0 para JPY
  final String locale; // es_ES, en_US, etc.

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.decimalDigits,
    required this.locale,
  });

  // Monedas predefinidas comunes
  static const Currency eur = Currency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    decimalDigits: 2,
    locale: 'es_ES',
  );

  static const Currency usd = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    decimalDigits: 2,
    locale: 'en_US',
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    decimalDigits: 2,
    locale: 'en_GB',
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    decimalDigits: 0,
    locale: 'ja_JP',
  );

  // Lista de monedas soportadas (Fase 1: solo estas, expandir en futuro)
  static const List<Currency> supportedCurrencies = [
    eur,
    usd,
    gbp,
    jpy,
  ];

  /// Obtener moneda por código ISO
  static Currency? fromCode(String code) {
    try {
      return supportedCurrencies.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtener moneda por código con fallback a EUR
  static Currency fromCodeOrEur(String code) {
    return fromCode(code) ?? eur;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code ($symbol)';
}

