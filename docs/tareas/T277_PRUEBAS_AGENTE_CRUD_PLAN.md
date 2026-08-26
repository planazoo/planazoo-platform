# T277 — Pruebas ejecutables por agente: CRUD de plan

> Dominio: **#2 Planes**. No aparca el WIP #1 (participantes / T259).  
> Contrato: [`FLUJO_CRUD_PLANES.md`](../flujos/FLUJO_CRUD_PLANES.md).  
> Checklist: [`CHECKLIST_CRUD_PLANES.md`](../testing/CHECKLIST_CRUD_PLANES.md).

## Objetivo

Que un agente de Cursor pueda **crear un plan, releerlo y decir si el resultado es OK**, sin pulsar la UI.

No sustituye Sesión A (iPhone / Android / web). Cubre la capa de servicio + validación.

## Fase 1 (esta pasada)

- Inyectar `FirebaseFirestore` en `PlanService` y `PlanParticipationService`.
- Test con Firestore falso: `createPlan` → `getPlanById` + participación organizador + workspace de notas.
- Casos lógicos de nombre (`tests/plan_cases.json`), misma regla que el modal.
- Skill `.cursor/skills/probar-dominio/`.

## Fase 2

- **Hecho:** Update de campos (`updatePlan` sin tocar `createdAt`) — P6.
- **Hecho:** Lista propios (PLAN-R-001), como participante (PLAN-R-002), filtro por estado (PLAN-R-004).
- **Hecho:** Estados P7 — matriz `isValidTransition` + `changePlanState` (owner / no-owner / ilegal).

## Fase 3 (esta pasada)

- **Hecho:** Cancelar P8 — `planificando`→`cancelado` (sigue en lista); no se puede desde `en_curso`.
- **Hecho:** PLAN-R-003 lookup por UNP ID; PLAN-R-005 filtro por nombre.
- **Hecho:** P14 matriz `PlanStatePermissions`.
## Fase 4 (esta pasada)

- **Hecho:** P5w widget test del modal (nombre vacío/corto, cancelar, crear OK).
- **Hecho:** P15 `deletePlan` sin eventos (plan + participación + workspace).

## Fase 5

- **Hecho:** P16 cascada — `deletePlan` borra invitaciones, permisos, notas, event_participants, **eventos y alojamientos**.
- **Cerrado (2026-08-18):** LISTA **126** (dashboard huérfanos) y **127** (alojamientos): `deleteEventsByPlanId` incluye `typeFamily: alojamiento`; `deletePlan` lo llama.
- Pendiente: P5 dispositivo.

## Pendiente humano (no agente)

- **P5** crear plan en app y verlo en lista (web/iOS/Android).
- LISTA **125** overflow iOS (validar).
- T259 AASA + Mail/Safari; LISTA **123**/**124**.

## Fase 6

- **Hecho:** P17 transiciones automáticas por fecha — confirmado→en_curso al pasar inicio; en_curso→finalizado al pasar fin; no salta dos estados en una llamada; planificando/cancelado no avanzan.

## Fase 7

- **Hecho:** P18 menú de transiciones (`availableManualTransitions`) + widget `PlanStateBadge` y `StateTransitionDialog` (cancelar no confirma).

## Fase 8

- **Hecho:** P19 PLAN-D-003 — diálogo dashboard (cancelar/eliminar) y diálogo Info con contraseña (vacío, cancelar, auth KO, OK).

## Fase 9

- **Hecho:** P20 PLAN-C-003 — `validatePlanDateRange` / `clampPlanEndToStart`; create/update rechazan fin < inicio; Info clampa al mover el inicio.

## Comando

```bash
flutter test test/features/calendar/plan_logic_test.dart test/features/calendar/plan_service_create_test.dart test/features/calendar/plan_service_list_test.dart test/features/calendar/plan_state_service_test.dart test/features/calendar/plan_state_permissions_test.dart test/features/calendar/plan_service_delete_test.dart test/features/calendar/wd_create_plan_modal_test.dart test/features/calendar/plan_state_ui_test.dart test/features/calendar/delete_plan_dialog_test.dart test/features/calendar/plan_date_range_validation_test.dart
```

## Criterio de cierre de fase 1

Los tests de arriba pasan en local. El agente, con el skill, produce un informe ✅/❌ por caso P1–P4.
