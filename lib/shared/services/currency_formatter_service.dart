import 'package:intl/intl.dart';
import '../models/currency.dart';

/// T153: Servicio para formatear montos según la moneda
class CurrencyFormatterService {
  /// Formatear monto según moneda (con símbolo)
  static String formatAmount(double amount, String currencyCode) {
    final currency = Currency.fromCodeOrEur(currencyCode);
    
    return NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
      locale: currency.locale,
    ).format(amount);
  }

  /// Formatear monto sin símbolo (solo número formateado)
  static String formatAmountWithoutSymbol(double amount, String currencyCode) {
    final currency = Currency.fromCodeOrEur(currencyCode);
    
    return NumberFormat.decimalPattern(currency.locale).format(amount);
  }

  /// Obtener símbolo de moneda
  static String getSymbol(String currencyCode) {
    return Currency.fromCodeOrEur(currencyCode).symbol;
  }

  /// Obtener nombre de moneda
  static String getName(String currencyCode) {
    return Currency.fromCodeOrEur(currencyCode).name;
  }

  /// Validar si un código de moneda es válido
  static bool isValidCurrencyCode(String code) {
    return Currency.fromCode(code) != null;
  }

  /// Obtener lista de códigos de monedas soportadas
  static List<String> getSupportedCurrencyCodes() {
    return Currency.supportedCurrencies.map((c) => c.code).toList();
  }

  /// Obtener lista de monedas soportadas
  static List<Currency> getSupportedCurrencies() {
    return Currency.supportedCurrencies;
  }
}

