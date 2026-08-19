# Informe Cloud Agent — chequeo autónomo

**Fecha (UTC):** 2026-08-19 14:46  
**Agente:** Cloud Agent (VM, no Mac)  
**Commit analizado:** `e4f819714d6a87bf5743a6f2c2fbc55f876ada2e` (`main`)  
**Entorno:** Flutter 3.47.0 / Dart 3.13.0

Este archivo es el resumen humano del chequeo. El detalle de login está en [`login_report.json`](./login_report.json).

## Qué se ejecutó

| Check | Comando | Resultado |
| --- | --- | --- |
| Pruebas lógicas de login (CLI) | `dart run bin/run_tests.dart` | 8 passed / **1 failed** / 0 errors |
| Tests lógicos Flutter | `flutter test` login + password + event | **2 passed / 1 failed** (el fallo es LOGIN-009) |
| Analizador | `flutter analyze` | **5 errors**, 1 warning, 1 info |

## Hallazgo 1 — LOGIN-009 (usuario inactivo)

El caso espera `messageKey: user-inactive` y el evaluador devuelve `loginUnknownError`.

- Input: `inactive@example.com` / `backendResult: inactive_user`
- Expected: `{ "status": "error", "messageKey": "user-inactive" }`
- Actual: `{ "status": "error", "messageKey": "loginUnknownError" }`

Contraseñas (REG-005) y creación de eventos (EVENT-C-*) pasaron.

## Hallazgo 2 — `flutter analyze` (5 errors)

Todos en `lib/widgets/screens/wd_calendar_screen.dart`, getters/parámetros de `CalendarStyles` que no existen o faltan:

- `calendarDaySeparatorWeb` (undefined getter, L458)
- `gridLineOpacity` (required argument missing, L497)
- `calendarGridLineColor` (undefined getter, L627 y L858)
- `cSurfaceBg` (undefined getter, L880)

También: warning `unawaited_return_in_try_block` en `lib/shared/services/help_text_service.dart:47` e info de deprecación `onReorder` en `calendar_track_reorder.dart:115`.

## Alcance (a propósito)

- No se ha tocado código de la app.
- No se ha intentado corregir LOGIN-009 ni el calendario.
- El Mac no ha participado: el informe vive en esta rama / PR.

## Cómo usar este PR

1. Revisar el diff de `reports/`.
2. Cerrar el PR si solo era la prueba de flujo.
3. Si el informe te vale como registro, fusionarlo; los hallazgos siguen abiertos hasta que alguien los arregle.
