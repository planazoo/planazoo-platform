# Alojamientos — índice de proceso

> **Stub vivo** (Ago 2026). Histórico: [`archivo/FLUJO_CRUD_ALOJAMIENTOS.md`](./archivo/FLUJO_CRUD_ALOJAMIENTOS.md).

## Contrato / trabajo

| Qué | Dónde |
|-----|--------|
| Campos del formulario | [`docs/especificaciones/ACCOMMODATION_FORM_FIELDS.md`](../especificaciones/ACCOMMODATION_FORM_FIELDS.md) |
| Reserva / cancelación | [`docs/tareas/archivo/T273_RESERVA_CANCELACION_DEPOSITO.md`](../tareas/archivo/T273_RESERVA_CANCELACION_DEPOSITO.md) |
| Patrón común/personal | [`docs/guias/GUIA_PATRON_COMUN_PERSONAL.md`](../guias/GUIA_PATRON_COMUN_PERSONAL.md) |
| Mapa de procesos | [`MAPA_FLUJOS.md`](./MAPA_FLUJOS.md) |

## Código de entrada

- UI: `lib/widgets/wd_accommodation_dialog.dart`
- Dominio: `lib/features/calendar/domain/services/accommodation_service.dart` (colección `events`, `typeFamily: alojamiento`)
