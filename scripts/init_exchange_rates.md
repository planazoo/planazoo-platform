# Script de Inicialización de Tipos de Cambio (T153)

Este documento describe cómo inicializar los tipos de cambio en Firestore.

## Estructura

Crear un documento en la colección `exchange_rates` con ID `current`:

```json
{
  "baseCurrency": "EUR",
  "rates": {
    "USD": 1.08,
    "GBP": 0.85,
    "JPY": 160.0
  },
  "updatedAt": [timestamp actual]
}
```

## Valores Aproximados Iniciales

- **EUR → USD:** 1.08 (1 EUR = 1.08 USD)
- **EUR → GBP:** 0.85 (1 EUR = 0.85 GBP)
- **EUR → JPY:** 160.0 (1 EUR = 160 JPY)

## Instrucciones

### Opción 1: Desde Firebase Console

1. Ir a Firestore Database
2. Crear colección `exchange_rates` (si no existe)
3. Crear documento con ID: `current`
4. Añadir campos:
   - `baseCurrency` (string): "EUR"
   - `rates` (map):
     - `USD` (number): 1.08
     - `GBP` (number): 0.85
     - `JPY` (number): 160.0
   - `updatedAt` (timestamp): Fecha/hora actual

### Opción 2: Desde Código (Firebase CLI o script Dart)

Ejecutar en consola de Firebase o script Dart:

```dart
// Ejemplo de código para inicializar
final firestore = FirebaseFirestore.instance;
await firestore.collection('exchange_rates').doc('current').set({
  'baseCurrency': 'EUR',
  'rates': {
    'USD': 1.08,
    'GBP': 0.85,
    'JPY': 160.0,
  },
  'updatedAt': FieldValue.serverTimestamp(),
});
```

## Notas

- Estos valores son aproximados y deben actualizarse periódicamente
- En el futuro se implementará actualización automática diaria
- Se pueden añadir más monedas al mapa `rates` según necesidad

