import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/services/logger_service.dart';

/// T153: Servicio para obtener y calcular tipos de cambio desde Firestore
class ExchangeRateService {
  static const String _collectionName = 'exchange_rates';
  static const String _documentId = 'current'; // Documento único con tipos de cambio
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache en memoria (válido hasta cierre de app)
  Map<String, double>? _cachedRates;
  String? _cachedBaseCurrency;
  DateTime? _cacheTimestamp;

  /// Obtener tipos de cambio desde Firestore
  Future<Map<String, double>> _getExchangeRates() async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .get();

      if (!doc.exists) {
        LoggerService.warning('Exchange rates document not found, using defaults');
        return _getDefaultRates();
      }

      final data = doc.data();
      if (data == null) {
        return _getDefaultRates();
      }

      final baseCurrency = data['baseCurrency'] as String? ?? 'EUR';
      final rates = data['rates'] as Map<String, dynamic>?;

      if (rates == null) {
        return _getDefaultRates();
      }

      // Convertir a Map<String, double>
      final ratesMap = <String, double>{};
      rates.forEach((key, value) {
        if (value is num) {
          ratesMap[key] = value.toDouble();
        }
      });

      // Cachear
      _cachedRates = ratesMap;
      _cachedBaseCurrency = baseCurrency;
      _cacheTimestamp = DateTime.now();

      return ratesMap;
    } catch (e) {
      LoggerService.error(
        'Error getting exchange rates',
        context: 'ExchangeRateService',
        error: e,
      );
      return _getDefaultRates();
    }
  }

  /// Tipos de cambio por defecto (valores aproximados)
  Map<String, double> _getDefaultRates() {
    return {
      'USD': 1.08, // 1 EUR = 1.08 USD
      'GBP': 0.85, // 1 EUR = 0.85 GBP
      'JPY': 160.0, // 1 EUR = 160 JPY
    };
  }

  /// Obtener tipo de cambio entre dos monedas
  Future<double?> getExchangeRate(String fromCurrency, String toCurrency) async {
    // Misma moneda
    if (fromCurrency.toUpperCase() == toCurrency.toUpperCase()) {
      return 1.0;
    }

    // Obtener rates (usar cache si está disponible)
    Map<String, double> rates;
    String baseCurrency;
    
    if (_cachedRates != null && _cachedBaseCurrency != null) {
      rates = _cachedRates!;
      baseCurrency = _cachedBaseCurrency!;
    } else {
      rates = await _getExchangeRates();
      baseCurrency = _cachedBaseCurrency ?? 'EUR';
    }

    // Caso 1: fromCurrency es la base
    if (fromCurrency.toUpperCase() == baseCurrency.toUpperCase()) {
      final rate = rates[toCurrency.toUpperCase()];
      return rate;
    }

    // Caso 2: toCurrency es la base
    if (toCurrency.toUpperCase() == baseCurrency.toUpperCase()) {
      final rate = rates[fromCurrency.toUpperCase()];
      return rate != null ? 1.0 / rate : null; // Inversa
    }

    // Caso 3: Ninguna es la base - convertir ambas a base y calcular
    final fromRate = rates[fromCurrency.toUpperCase()];
    final toRate = rates[toCurrency.toUpperCase()];

    if (fromRate == null || toRate == null) {
      return null;
    }

    // Convertir fromCurrency -> base -> toCurrency
    // 1 fromCurrency = 1/fromRate base
    // 1 base = toRate toCurrency
    // Por tanto: 1 fromCurrency = (1/fromRate) * toRate toCurrency
    return (1.0 / fromRate) * toRate;
  }

  /// Convertir monto entre monedas
  Future<double?> convertAmount(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    final rate = await getExchangeRate(fromCurrency, toCurrency);
    if (rate == null) {
      return null;
    }
    return amount * rate;
  }

  /// Obtener base currency actual
  Future<String> getBaseCurrency() async {
    if (_cachedBaseCurrency != null) {
      return _cachedBaseCurrency!;
    }
    
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final baseCurrency = data?['baseCurrency'] as String? ?? 'EUR';
        _cachedBaseCurrency = baseCurrency;
        return baseCurrency;
      }
    } catch (e) {
      LoggerService.error(
        'Error getting base currency',
        context: 'ExchangeRateService',
        error: e,
      );
    }
    
    return 'EUR'; // Default
  }

  /// Invalidar cache (para forzar actualización)
  void invalidateCache() {
    _cachedRates = null;
    _cachedBaseCurrency = null;
    _cacheTimestamp = null;
  }

  /// Obtener timestamp del cache
  DateTime? get cacheTimestamp => _cacheTimestamp;
}

