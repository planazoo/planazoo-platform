---
name: probar-dominio
description: >-
  Runs agent-executable tests for a Planazoo domain and reports PASS/FAIL
  without implementing fixes. Use when the user asks to probar un dominio,
  ejecutar checklist CRUD, PLAN-C-*, createPlan, or agent QA of planes/eventos.
---

# Probar dominio (agente)

Ejecuta **solo** los casos que el usuario marque. No implementes correcciones
salvo que pida explícitamente «arregla X». No abras otro dominio WIP.

## Arranque

1. Leer `docs/flujos/ORDEN_POR_DOMINIOS.md` (WIP actual).
2. Leer el contrato del dominio pedido.
3. Leer el checklist de ese dominio (si existe).
4. Ejecutar **solo** los casos marcados (o todos los automáticos del dominio si no marca).

## Dominio #2 — Planes (CRUD)

- Contrato: `docs/flujos/FLUJO_CRUD_PLANES.md`
- Checklist: `docs/testing/CHECKLIST_CRUD_PLANES.md`
- Spec: `docs/tareas/T277_PRUEBAS_AGENTE_CRUD_PLAN.md`

### Casos que el agente puede ejecutar solo

```bash
flutter test test/features/calendar/plan_logic_test.dart test/features/calendar/plan_service_create_test.dart test/features/calendar/plan_service_list_test.dart test/features/calendar/plan_state_service_test.dart test/features/calendar/plan_state_permissions_test.dart test/features/calendar/plan_service_delete_test.dart test/features/calendar/wd_create_plan_modal_test.dart test/features/calendar/plan_state_ui_test.dart test/features/calendar/delete_plan_dialog_test.dart test/features/calendar/plan_date_range_validation_test.dart
```

- Validación de nombre (PLAN-C-002*): `plan_logic_test.dart`
- Crear + releer en Firestore falso (PLAN-C-001): `plan_service_create_test.dart`
- Editar campos sin tocar `createdAt` (P6): mismo archivo, grupo `updatePlan`
- Lista / participante / filtro estado (PLAN-R-001, R-002, R-004): `plan_service_list_test.dart`
- Estados P7: `plan_state_service_test.dart`
- Cancelar P8: mismo archivo, grupo `P8 cancel`
- PLAN-R-003 / R-005: `plan_service_list_test.dart`
- Permisos por estado P14: `plan_state_permissions_test.dart`
- Modal P5w: `wd_create_plan_modal_test.dart`
- Borrar P15 / cascada P16: `plan_service_delete_test.dart`
- Transiciones automáticas P17: `plan_state_service_test.dart` (grupo `P17`)
- Badge + diálogo de estado P18: `plan_state_service_test.dart` + `plan_state_ui_test.dart`
- Confirmación al borrar P19: `delete_plan_dialog_test.dart`
- Fechas PLAN-C-003 P20: `plan_logic_test.dart` + `plan_date_range_validation_test.dart` + `plan_service_create_test.dart`

### Casos que NO puede ejecutar solo

UI real (modal, dashboard, iPhone/Android/web). Anotarlos como **manual** en el informe.

## Dominio #3 — Eventos (CRUD)

- Contrato: `docs/flujos/FLUJO_CRUD_EVENTOS.md`
- Checklist: `docs/testing/CHECKLIST_CRUD_EVENTOS.md`
- Spec: `docs/tareas/T278_PRUEBAS_AGENTE_CRUD_EVENTO.md`

### Casos que el agente puede ejecutar solo

```bash
flutter test test/features/calendar/event_logic_test.dart test/features/calendar/event_field_validation_test.dart test/features/calendar/event_service_crud_test.dart test/features/calendar/plan_state_permissions_test.dart test/features/calendar/delete_event_dialog_test.dart
```

- Casos lógicos EVENT-C-*: `event_logic_test.dart`
- Validadores C-005/C-006/C-009/C-011/C-017: `event_field_validation_test.dart`
- CRUD servicio E1–E11: `event_service_crud_test.dart`
- Permisos D-004: `plan_state_permissions_test.dart`
- Diálogo borrar D-003: `delete_event_dialog_test.dart`

### Casos que NO puede ejecutar solo

UI real (`wd_event_dialog`, calendario, Places, vuelos). Anotarlos como **manual**.

## Informe (obligatorio)

Por cada caso: `✅` / `❌` / `⚠️` / `⏭` (no aplicable) + una línea de evidencia.

Si hay ❌/⚠️ de producto: añadir fila en `docs/testing/LISTA_PUNTOS_CORREGIR_APP.md`
(siguiente ID libre, dominio citado). No marcar tareas Completadas.

Cerrar con: qué se ejecutó, qué queda manual, comando para repetir.
