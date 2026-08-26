# Checklist CRUD de eventos (agente + humano)

> Dominio **#3**. Contrato: [`FLUJO_CRUD_EVENTOS.md`](../flujos/FLUJO_CRUD_EVENTOS.md).  
> Tarea: [`T278_PRUEBAS_AGENTE_CRUD_EVENTO.md`](../tareas/T278_PRUEBAS_AGENTE_CRUD_EVENTO.md).  
> Hallazgos: [`LISTA_PUNTOS_CORREGIR_APP.md`](./LISTA_PUNTOS_CORREGIR_APP.md).

## Cómo lanzar

```
Prueba dominio #3 Eventos. Ejecuta los casos automáticos. No implementes fixes.
```

```bash
flutter test test/features/calendar/event_logic_test.dart test/features/calendar/event_field_validation_test.dart test/features/calendar/event_service_crud_test.dart test/features/calendar/plan_state_permissions_test.dart test/features/calendar/delete_event_dialog_test.dart
```

## Casos

| Id | Caso | Quién | Estado |
|----|------|--------|--------|
| E0 | Casos lógicos EVENT-C-* (`event_cases.json`) | **Agente** (`event_logic_test`) | |
| E1 | Crear + releer (EVENT-C-001); descripción vacía (C-002); no-participante | **Agente** (`event_service_crud_test`) | |
| E2 | Lista del plan; excluye alojamiento; extraño no ve nada (R-001) | **Agente** | |
| E2b | Filtrar lista por tipo (R-004 slice) | **Agente** | |
| E3 | Editar descripción/fecha/hora (U-001/U-002) | **Agente** | |
| E4 | Borrador vs confirmado (C-012 / U-007) | **Agente** | |
| E5 | Persistir coste y tipo/subtipo (C-011 / C-014) | **Agente** | |
| E6 | Borrar evento + event_participants; otros intactos (D-001 / D-005 slice) | **Agente** | |
| E7 | Modal evento en app | Humano | |
| E8 | Duración 45 min; rechaza >24h (C-005 / C-006) | **Agente** (`event_field_validation_test`, `event_service_crud_test`) | |
| E9 | Persistir maxParticipants, timezone, audiencia commonPart; cupo (C-007 / C-009 / C-003) | **Agente** | |
| E10 | Coste negativo, fuera de rango del plan, `saveEvent` + confirmación (C-011 / C-017 / C-010) | **Agente** | |
| E11 | Plan finalizado/cancelado bloquea crear/borrar (D-004) | **Agente** (`event_service_crud_test`, `plan_state_permissions_test`) | |
| E12 | Diálogo confirmar borrar: Cancelar / Eliminar (D-003) | **Agente** (`delete_event_dialog_test`) | |

## Resultado de la última pasada agente

- Fecha: 2026-08-19
- Comando: ver arriba
- Automáticos: ✅ (28 tests)
