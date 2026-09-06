# Eventos — índice de proceso

> **Stub vivo** (Ago 2026). La prosa enciclopédica está en [`archivo/FLUJO_CRUD_EVENTOS.md`](./archivo/FLUJO_CRUD_EVENTOS.md).

## Contrato / trabajo

| Qué | Dónde |
|-----|--------|
| Campos del formulario | [`docs/especificaciones/EVENT_FORM_FIELDS.md`](../especificaciones/EVENT_FORM_FIELDS.md) |
| Reserva / cancelación | [`docs/tareas/archivo/T273_RESERVA_CANCELACION_DEPOSITO.md`](../tareas/archivo/T273_RESERVA_CANCELACION_DEPOSITO.md) |
| Capacidades calendario | [`docs/especificaciones/CALENDAR_CAPABILITIES.md`](../especificaciones/CALENDAR_CAPABILITIES.md) |
| Patrón común/personal | [`docs/guias/GUIA_PATRON_COMUN_PERSONAL.md`](../guias/GUIA_PATRON_COMUN_PERSONAL.md) |
| Trabajo (TASKS) | Índice dominio Eventos en `TASKS.md` (**T278**) · mail al evento: **T134 ✅** [`COMUNICACIONES_MAIL_PLAN.md`](../producto/COMUNICACIONES_MAIL_PLAN.md) — copias en `events/{id}/communications` |
| Prueba agente | [`CHECKLIST_CRUD_EVENTOS.md`](../testing/CHECKLIST_CRUD_EVENTOS.md) |
| Mapa de procesos | [`MAPA_FLUJOS.md`](./MAPA_FLUJOS.md) |

## Código de entrada

- UI: `lib/widgets/wd_event_dialog.dart` (sección Comunicaciones aparte de Adjuntos)
- Dominio: `lib/features/calendar/domain/services/event_service.dart` · T134 `entity_communication_service.dart`
- Modelo reserva: `lib/features/calendar/domain/models/reservation_cancellation.dart`
- **T279 mapa del plan:** `wd_plan_map_screen.dart` desde Mi resumen; pines con Places; vuelos = pin **A**; spec [`T279_MAPA_PLAN_LUGARES.md`](../tareas/T279_MAPA_PLAN_LUGARES.md)
