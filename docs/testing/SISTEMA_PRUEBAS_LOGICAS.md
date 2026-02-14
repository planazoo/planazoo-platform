# Sistema de pruebas lógicas (JSON + evaluadores + reportes)

> Documentación del sistema de pruebas por casos de datos (inputs/outputs) usado para login, contraseñas, eventos y futuras áreas.  
> **Objetivo:** ejecutar pruebas deterministas sin UI ni Firebase, generar reportes reutilizables (p. ej. para IA) y mantener coherencia con `TESTING_CHECKLIST.md`.

---

## ⚠️ Recordatorio de mantenimiento

**Al añadir o cambiar lógica de negocio (validaciones, auth, reglas de eventos, etc.):**

- Valorar si esa lógica se puede probar por datos (input → output).
- Si sí: añadir o actualizar casos en `tests/<área>_cases.json`, el evaluador en `lib/testing/<área>_logic.dart` y el test en `test/features/.../<área>_logic_test.dart` (ver sección 5).
- Si se crea una nueva área: registrar la nueva fila en la tabla "Áreas cubiertas" (sección 3) de este documento.

Así el sistema de pruebas lógicas crece con la app y los reportes siguen siendo útiles.

---

## 1. Visión general

- **Casos de prueba:** definidos en JSON (datos, no código).
- **Evaluadores:** funciones en `lib/testing/*.dart` que reciben el `input` de cada caso y devuelven un resultado comparable al `expected`.
- **Ejecución:**
  - **Tests Dart:** `flutter test test/features/...` lee el JSON, llama al evaluador y compara resultado.
  - **Runner CLI (login):** `dart run bin/run_tests.dart` lee `tests/login_cases.json`, genera `reports/login_report.json` (resumen + detalle por caso, útil para IA).
- **Código de producción:** no se modifica para “encajar” en las pruebas; los evaluadores encapsulan o replican reglas de negocio ya existentes (o las definen de forma explícita para nuevos requisitos).

---

## 2. Estructura en el repositorio

| Elemento | Ubicación | Descripción |
|----------|-----------|-------------|
| Casos JSON | `tests/<área>_cases.json` | Lista de casos: `id`, `description`, `target`, `input`, `expected`. |
| Evaluadores | `lib/testing/<área>_logic.dart` | Función que dado `input` devuelve resultado (mapa JSON-friendly). |
| Tests Dart | `test/features/<feature>/<área>_logic_test.dart` | Lee el JSON, invoca evaluador, compara con `expected`. |
| Runner CLI (login) | `bin/run_tests.dart` | Solo login por ahora; escribe `reports/login_report.json`. |
| Reportes | `reports/login_report.json` | Resumen (passed/failed/errors) + detalle por caso (input, expected, actual, diff). |

**Convención de `target`:** identifica qué evaluador usar, p. ej. `{ "module": "auth", "scenario": "login" }` o `{ "module": "calendar", "scenario": "eventCreation" }`.

---

## 3. Áreas cubiertas actualmente

| Área | JSON | Evaluador | Test Dart | Runner CLI |
|------|------|-----------|-----------|------------|
| Login (LOGIN-001…009) | `tests/login_cases.json` | `lib/testing/login_logic.dart` → `evaluateAuthLogin()` | `test/features/auth/login_logic_test.dart` | `bin/run_tests.dart` → `reports/login_report.json` |
| Contraseñas (REG-005) | `tests/password_cases.json` | `lib/testing/password_logic.dart` → `evaluatePassword()` | `test/features/auth/password_logic_test.dart` | — |
| Eventos (EVENT-C-*) | `tests/event_cases.json` | `lib/testing/event_logic.dart` → `evaluateEventCreation()` | `test/features/calendar/event_logic_test.dart` | — |

Los casos están alineados con los IDs del [TESTING_CHECKLIST.md](../configuracion/TESTING_CHECKLIST.md) (LOGIN-*, REG-005, EVENT-C-001, C-002, etc.).

---

## 4. Cómo ejecutar las pruebas

```bash
# Desde la raíz del proyecto (p. ej. /Users/.../unp_calendario)

# Tests Dart por área
flutter test test/features/auth/login_logic_test.dart
flutter test test/features/auth/password_logic_test.dart
flutter test test/features/calendar/event_logic_test.dart

# Todas las pruebas del proyecto (incluyen las lógicas)
flutter test

# Runner CLI solo login (genera reporte para IA)
dart run bin/run_tests.dart
# → Salida: reports/login_report.json y resumen en consola (passed/failed/errors)
```

---

## 5. Cómo añadir una nueva área de pruebas

Sigue el mismo patrón que login / contraseñas / eventos:

1. **Definir casos en JSON**  
   Crear `tests/<área>_cases.json` con estructura:
   - `id`: identificador único (recomendable alinear con TESTING_CHECKLIST, p. ej. `PAY-001_...`).
   - `description`: texto breve.
   - `target`: `{ "module": "...", "scenario": "..." }` para que el test sepa qué evaluador usar.
   - `input`: mapa con los datos de entrada (campos que necesite tu regla de negocio).
   - `expected`: mapa con el resultado esperado (p. ej. `{ "created": true, "errorCode": null }` o `{ "status": "error", "messageKey": "..." }`).

2. **Implementar evaluador**  
   En `lib/testing/<área>_logic.dart`:
   - Una función principal que reciba `Map<String, dynamic> input` y devuelva `Map<String, dynamic>` (mismo “shape” que `expected`).
   - Opcional: función de comparación `compareXxxOutputs(expected, actual)` que devuelva `null` si son iguales o un mensaje de diff si no.

3. **Añadir test Dart**  
   En `test/features/<feature>/<área>_logic_test.dart`:
   - `setUpAll`: leer `tests/<área>_cases.json` y parsear como lista.
   - Un test que recorra cada entrada, filtre por `target.module`/`target.scenario`, llame al evaluador con `input`, compare resultado con `expected` y use `expect(..., isNull)` sobre el diff (o equivalente).

4. **Opcional: integrar en el runner CLI**  
   Si quieres reporte tipo `reports/<área>_report.json` para esa área:
   - En `bin/run_tests.dart`, añadir lectura de `tests/<área>_cases.json`, llamada al nuevo evaluador según `target`, y escritura de resultados en `reports/<área>_report.json` (mismo formato que `login_report.json` si conviene).

---

## 6. Uso del reporte con IA

- El archivo `reports/login_report.json` (y los que se añadan) tiene:
  - `metadata`: idioma, fecha, commit, entorno.
  - `summary`: total, passed, failed, errors.
  - `cases`: por cada caso, `id`, `status` (`passed`|`failed`|`error`), y si falla: `input`, `expected`, `actual`, `diff`.

- **Flujo sugerido:**  
  Dar a la IA el código relevante (p. ej. `login_logic.dart` o el módulo de auth) + el `report.json`. Prompt tipo: *“Este es el código y este el reporte de pruebas. Los casos X e Y fallan con este diff. Propón cambios para que pasen.”*

- **Generar un caso que falle a propósito:**  
  Añadir en el JSON un caso cuyo `expected` refleje un requisito aún no implementado (p. ej. `messageKey: "user-inactive"`). El evaluador devolverá otro valor → el reporte mostrará ese caso como `failed` y el diff servirá de especificación para implementar.

---

## 7. Referencias

- **Checklist de pruebas:** [docs/configuracion/TESTING_CHECKLIST.md](../configuracion/TESTING_CHECKLIST.md) — fuente de escenarios (LOGIN-*, REG-*, EVENT-C-*, etc.).
- **Contexto del proyecto:** [docs/configuracion/CONTEXT.md](../configuracion/CONTEXT.md).
- **Testing offline:** [docs/testing/TESTING_OFFLINE_FIRST.md](TESTING_OFFLINE_FIRST.md).

---

*Última actualización: Febrero 2026*
