# T278 — Pruebas ejecutables por agente: CRUD de evento

> Dominio: **#3 Eventos**. No aparca el WIP #1 (T259) ni cierra #2.  
> Contrato: [`FLUJO_CRUD_EVENTOS.md`](../flujos/FLUJO_CRUD_EVENTOS.md).  
> Checklist: [`CHECKLIST_CRUD_EVENTOS.md`](../testing/CHECKLIST_CRUD_EVENTOS.md).

## Objetivo

Que un agente de Cursor pueda **crear un evento, releerlo, listarlo, editarlo y borrarlo** en Firestore falso, y decir si el resultado es OK.

No sustituye calendario en dispositivo ni Places/vuelos.

## Fase 1

- `PaymentService` inyecta `FirebaseFirestore` (T273 sync no rompe tests).
- `createEvent` / `updateEvent` rechazan descripción vacía (EVENT-C-002).
- Tests: create/read, no-participante, lista + excluye alojamiento, filtro tipo, update, borrador, coste/tipo, delete + event_participants.
- Casos lógicos: `tests/event_cases.json` + `event_logic_test.dart`.

## Fase 2 (esta pasada)

- Validadores de dominio (`event_field_validation.dart`): duración ≤24h, coste ≥0, cupo, día civil dentro del plan.
- `createEvent` / `updateEvent` / `deleteEvent` aplican esas reglas y la matriz de estado (`PlanStatePermissions`).
- Persistencia: duración, `maxParticipants`, timezone, `commonPart` (audiencia), `requiresConfirmation` + filas pending vía `saveEvent`.
- EVENT-D-003: `showDeleteEventConfirmDialog` extraído de `wd_event_dialog`.
- `saveEvent` usa el `EventParticipantService` inyectado (no `FirebaseFirestore.instance`).
- Confirmaciones pendientes (C-010): incluyen al organizador, no solo `role: participant`.

## Fuera de alcance agente

UI real (`wd_event_dialog` completo), drag & drop, Places, Amadeus, adjuntos Storage, copias `isBaseEvent` (`EventSyncService` aún usa instancia global).

## Comando

```bash
flutter test test/features/calendar/event_logic_test.dart test/features/calendar/event_field_validation_test.dart test/features/calendar/event_service_crud_test.dart test/features/calendar/plan_state_permissions_test.dart test/features/calendar/delete_event_dialog_test.dart
```
