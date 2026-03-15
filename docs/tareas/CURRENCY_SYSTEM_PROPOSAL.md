# 💱 T260 – Sistema multi-moneda (especificación)

> **Tarea:** T260 en `docs/tareas/TASKS.md`.  
> Objetivo: soporte de múltiples monedas por plan y conversión de tipos de cambio en Planazoo.

**Fecha:** Enero 2025  
**Prioridad:** Media  
**Relacionado con:** T101 (presupuesto), T102 (pagos)

---

## 🎯 Objetivos

1. **Soporte multi-moneda:** Cada plan puede tener su moneda base (EUR, USD, GBP, etc.)
2. **Formateo automático:** UI muestra montos con el símbolo y formato correcto según la moneda
3. **Conversión de tipos de cambio (opcional):** Convertir entre monedas cuando se visualiza o registra

---

## 📊 Arquitectura Propuesta

### 1. Modelo de Moneda

```dart
// lib/shared/models/currency.dart

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

  // Lista de monedas soportadas
  static const List<Currency> supportedCurrencies = [
    eur, usd, gbp, jpy,
    // Añadir más según necesidad
  ];

  // Obtener moneda por código
  static Currency? fromCode(String code) {
    return supportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => eur, // Fallback a EUR
    );
  }
}
```

### 2. Modificar Modelos Existentes

#### Plan
```dart
class Plan {
  // ... campos existentes ...
  final String currency; // Código ISO: 'EUR', 'USD', etc. (default: 'EUR')
  
  // ...
}
```

#### Event / Accommodation
```dart
class Event {
  // ... campos existentes ...
  final double? cost; // Monto en la moneda del plan
  // NOTA: No añadir currency aquí, siempre usa la del plan
}

class Accommodation {
  // ... campos existentes ...
  final double? cost; // Monto en la moneda del plan
}
```

#### PersonalPayment
```dart
class PersonalPayment {
  // ... campos existentes ...
  final double amount; // Monto en la moneda del plan
  // NOTA: Pagos siempre en moneda del plan
}
```

### 3. Servicio de Formateo de Moneda

```dart
// lib/shared/services/currency_formatter_service.dart

import 'package:intl/intl.dart';
import '../models/currency.dart';

class CurrencyFormatterService {
  /// Formatear monto según moneda
  static String formatAmount(double amount, String currencyCode) {
    final currency = Currency.fromCode(currencyCode) ?? Currency.eur;
    
    return NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
      locale: currency.locale,
    ).format(amount);
  }

  /// Formatear monto sin símbolo (solo número)
  static String formatAmountWithoutSymbol(double amount, String currencyCode) {
    final currency = Currency.fromCode(currencyCode) ?? Currency.eur;
    
    return NumberFormat.decimalPattern(currency.locale).format(amount);
  }

  /// Obtener símbolo de moneda
  static String getSymbol(String currencyCode) {
    return Currency.fromCode(currencyCode)?.symbol ?? '€';
  }
}
```

### 4. Servicio de Tipo de Cambio (Opcional - Fase 2)

```dart
// lib/shared/services/exchange_rate_service.dart

class ExchangeRateService {
  // API opciones:
  // 1. exchangerate-api.com (gratis, 1500 requests/mes)
  // 2. fixer.io (tier gratuito disponible)
  // 3. Exchange Rates API (exchangerate-api.io) - gratis sin key hasta 1500 req/mes

  /// Obtener tipo de cambio entre dos monedas
  Future<double?> getExchangeRate(String fromCurrency, String toCurrency) async {
    // Implementar llamada a API
    // Cachear resultados (válido por 1 hora, por ejemplo)
  }

  /// Convertir monto entre monedas
  Future<double?> convertAmount(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    final rate = await getExchangeRate(fromCurrency, toCurrency);
    return rate != null ? amount * rate : null;
  }

  /// Obtener tipos de cambio más recientes (cache)
  Map<String, double> getCachedRates() {
    // Retornar cache local
  }
}
```

---

## 🔄 Flujo de Implementación

### Fase 1: Soporte Básico Multi-moneda (Sin conversión)
1. ✅ Crear modelo `Currency`
2. ✅ Crear `CurrencyFormatterService`
3. ✅ Añadir campo `currency` a `Plan` (default: 'EUR')
4. ✅ Actualizar UI para usar formateador de moneda
5. ✅ Actualizar diálogos de eventos/alojamientos/pagos
6. ✅ Actualizar páginas de estadísticas y pagos

### Fase 2: Conversión de Tipos de Cambio (Opcional)
1. ⚠️ Crear `ExchangeRateService`
2. ⚠️ Integrar API de tipos de cambio
3. ⚠️ Cache local de tipos de cambio
4. ⚠️ UI para mostrar conversión (ej: "€100 ≈ $108")
5. ⚠️ Opción de registrar pago en moneda diferente (convertir automáticamente)

---

## 📝 Cambios Necesarios

### Archivos a Modificar:

1. **Modelos:**
   - `lib/features/calendar/domain/models/plan.dart` - Añadir `currency`
   - `lib/shared/models/currency.dart` - NUEVO

2. **Servicios:**
   - `lib/shared/services/currency_formatter_service.dart` - NUEVO
   - `lib/shared/services/exchange_rate_service.dart` - NUEVO (Fase 2)

3. **UI (Usar formateador en lugar de hardcodeo):**
   - `lib/widgets/wd_event_dialog.dart`
   - `lib/widgets/wd_accommodation_dialog.dart`
   - `lib/widgets/dialogs/payment_dialog.dart`
   - `lib/features/stats/presentation/pages/plan_stats_page.dart`
   - `lib/features/payments/presentation/pages/payment_summary_page.dart`

4. **Configuración:**
   - UI para seleccionar moneda al crear plan (opcional: por defecto según timezone o EUR)

---

## 🎨 Consideraciones UX

1. **Selector de moneda:** Al crear plan, permitir seleccionar moneda (dropdown con monedas comunes)
2. **Indicador visual:** Mostrar código de moneda junto a montos (ej: "€100 EUR" o solo "€100")
3. **Consistencia:** Todos los montos del mismo plan deben mostrar misma moneda
4. **Conversión opcional:** Si se implementa conversión, mostrarla como información adicional, no como valor principal

---

## 📊 Monedas a Soportar Inicialmente

- **EUR** (Euro) - Principal
- **USD** (US Dollar)
- **GBP** (British Pound)
- **JPY** (Japanese Yen)
- Añadir más según necesidades de usuarios

---

## ❓ Decisiones Pendientes

1. **¿Conversión automática?** 
   - Opción A: Solo mostrar montos en moneda del plan (más simple)
   - Opción B: Permitir registrar pagos en otras monedas y convertir (más complejo)

2. **¿Moneda por evento o solo por plan?**
   - Recomendación: Solo por plan (simplifica mucho)

3. **¿API de tipos de cambio?**
   - ¿Cuál usar? ¿Gratis o de pago?
   - ¿Frecuencia de actualización?

---

## 🚀 Prioridad de Implementación

**Fase 1 (Básico):** 🟡 Media  
**Fase 2 (Conversión):** 🟢 Baja (solo si hay demanda)

---

¿Te parece bien esta propuesta? ¿Algún cambio o consideración adicional?

