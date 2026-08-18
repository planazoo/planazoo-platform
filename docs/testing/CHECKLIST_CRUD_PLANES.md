# Checklist CRUD de planes (agente + humano)

> Dominio **#2**. Contrato: [`FLUJO_CRUD_PLANES.md`](../flujos/FLUJO_CRUD_PLANES.md).  
> Tarea: [`T277_PRUEBAS_AGENTE_CRUD_PLAN.md`](../tareas/T277_PRUEBAS_AGENTE_CRUD_PLAN.md).  
> Hallazgos: [`LISTA_PUNTOS_CORREGIR_APP.md`](./LISTA_PUNTOS_CORREGIR_APP.md).

Marca qué debe correr el agente. Por defecto, en esta fase: **solo automáticos**.

## Cómo lanzar

```
Prueba dominio #2 Planes. Ejecuta los casos automáticos. No implementes fixes.
```

```bash
flutter test test/features/calendar/plan_logic_test.dart test/features/calendar/plan_service_create_test.dart test/features/calendar/plan_service_list_test.dart test/features/calendar/plan_state_service_test.dart test/features/calendar/plan_state_permissions_test.dart test/features/calendar/plan_service_delete_test.dart test/features/calendar/wd_create_plan_modal_test.dart test/features/calendar/plan_state_ui_test.dart test/features/calendar/delete_plan_dialog_test.dart test/features/calendar/plan_date_range_validation_test.dart
```

## Casos

| Id | Caso | Quién | Estado |
|----|------|--------|--------|
| P1 | Crear plan básico (nombre válido → doc + organizador + workspace notas) | **Agente** (`plan_service_create_test`) | |
| P2 | Nombre vacío / corto / largo | **Agente** (`plan_logic_test`, PLAN-C-002*) | |
| P3 | Releer plan por id; id inexistente → null | **Agente** | |
| P4 | UNP ID único incrementa (`ua-1` → `ua-2`) | **Agente** | |
| P5 | Modal en app: crear y ver en lista (web/iOS/Android) | Humano | |
| P5w | Modal widget: nombre vacío/corto, cancelar, crear OK | **Agente** (`wd_create_plan_modal_test`) | |
| P6 | Editar campos y guardar (`updatePlan`, no toca `createdAt`) | **Agente** (`plan_service_create_test`) | |
| P7 | Cambiar estado (transiciones + `changePlanState` owner vs participante) | **Agente** (`plan_state_service_test`) | |
| P8 | Cancelar (estado `cancelado`; no es borrar) | **Agente** (`plan_state_service_test`) | |
| P9 | PLAN-R-001 lista de planes propios | **Agente** (`plan_service_list_test`) | |
| P10 | PLAN-R-002 ver plan como participante | **Agente** (`plan_service_list_test`) | |
| P11 | PLAN-R-004 filtrar lista por estado | **Agente** (`plan_service_list_test`) | |
| P12 | PLAN-R-003 detalle / lookup por UNP ID | **Agente** (`plan_service_list_test`) | |
| P13 | PLAN-R-005 filtrar lista por nombre | **Agente** (`plan_service_list_test`) | |
| P14 | Matriz permisos por estado (`PlanStatePermissions`) | **Agente** (`plan_state_permissions_test`) | |
| P15 | Borrar plan sin eventos (PLAN-D-001 slice) | **Agente** (`plan_service_delete_test`) | |
| P16 | Cascada borrar: invitaciones/permisos/notas + eventos y alojamientos del plan; otros planes intactos | **Agente** (`plan_service_delete_test`) — **126** y **127** cerrados | |
| P17 | Transiciones automáticas por fecha (`checkAndExecuteAutomaticTransitions`) | **Agente** (`plan_state_service_test`) | |
| P18 | Badge de estado + menú de transiciones + diálogo confirmar/cancelar | **Agente** (`plan_state_service_test`, `plan_state_ui_test`) | |
| P19 | PLAN-D-003 confirmación al borrar (dashboard + Info con contraseña) | **Agente** (`delete_plan_dialog_test`) | |
| P20 | PLAN-C-003 rango de fechas (fin ≥ inicio, mismo día OK) | **Agente** (`plan_logic_test`, `plan_date_range_validation_test`, `plan_service_create_test`) | |

## Resultado de la última pasada agente

- Fecha: 2026-08-18
- Comando: `flutter test test/features/calendar/plan_logic_test.dart test/features/calendar/plan_service_create_test.dart test/features/calendar/plan_service_list_test.dart test/features/calendar/plan_state_service_test.dart test/features/calendar/plan_state_permissions_test.dart test/features/calendar/plan_service_delete_test.dart test/features/calendar/wd_create_plan_modal_test.dart test/features/calendar/plan_state_ui_test.dart test/features/calendar/delete_plan_dialog_test.dart test/features/calendar/plan_date_range_validation_test.dart`
- Automáticos: ✅ (53 tests)
- Hallazgos LISTA: **126**, **127** cerrados; P17–P20 añadidos
