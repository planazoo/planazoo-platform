# T273 — Reserva / cancelación: garantía, tramos y avisos

**Estado:** En progreso (v1 + pulidos UI 2026-08-10)  
**Prioridad:** Alta  
**Ámbito:** Eventos y alojamientos (mismo bloque) · Pagos/balances · Avisos al organizador  
**Sistema de procesos:** contrato de producto (capa 1) para este dominio piloto → ver [`MAPA_FLUJOS.md`](../flujos/MAPA_FLUJOS.md). Índices: eventos / alojamientos / pagos.

---

## Problema

Al reservar (hotel, restaurante, actividad, etc.) suele pedirse un **pago como garantía** ligado a una **política de cancelación**. Hoy la app solo tiene `cost` en evento/alojamiento; no hay depósito, fechas límite ni avisos. La spec antigua de alojamientos (`ACCOMMODATION_FORM_FIELDS.md`) ya mencionaba depósito / día límite, pero no está en el modelo.

---

## Objetivo

Permitir registrar en **evento** y **alojamiento**:

1. Garantía de la reserva (importe + quién la adelantó).
2. Política de cancelación con hasta **2 tramos** (fecha+hora + % que se recupera).
3. Cargo fijo opcional al cancelar (p. ej. 5 € de gestión).
4. Avisos al **organizador** antes de cada límite.
5. Que la garantía cuente en **Pagos / balances** del plan.

---

## Decisiones de producto (acordadas)

| # | Tema | Acuerdo |
|---|------|---------|
| 1 | Quién recibe avisos | Solo **organizador** |
| 2 | Pagos / balances | Sí: saber **quién ha adelantado** el dinero |
| 3 | Momento del límite | **Fecha + hora** en zona horaria del **ítem** |
| 4 | Tramos | Hasta **2**; **1 solo es válido** |
| 5 | Significado del % | Lo que **recuperas** del depósito |
| 6 | Pagador de la garantía | **Un solo** pagador en v1 |
| 7 | Ámbito | **Mismo bloque** en evento y alojamiento |
| 8 | Cargo fijo | Opcional, **un fijo por ítem** (no por tramo): p. ej. «al cancelar en ventana de reembolso se pierden 5 €» |

---

## Modelo de datos (borrador)

Bloque conceptual `reservationGuarantee` / `cancellationPolicy` en evento y alojamiento (nombres finales al implementar):

### Garantía

- `amount` (`double?`) — importe de la garantía / depósito  
- `currency` — moneda del plan (o heredada)  
- `payerUserId` (`String?`) — único adelanto  
- `status` — `pending` | `paid` | `refunded` | `retained` (u equivalente)  
- `note` (`String?`) — texto libre corto  

### Política de cancelación

- Hasta 2 tramos, cada uno:
  - `deadlineAt` — `DateTime` (instante; UI en TZ del ítem)
  - `refundPercent` — 0–100, lo que **se recupera** del depósito
- `cancellationFixedFee` (`double?`) — cargo fijo al cancelar dentro de ventanas con derecho a reembolso (opcional)
- `timezone` del ítem — reutilizar / añadir campo TZ en evento y alojamiento si aún no existe de forma usable

### Integración pagos

- La garantía pagada genera (o se vincula a) un movimiento visible en W18 Pagos / balances (p. ej. `PersonalPayment` o tipo dedicado con `eventId` / `accommodationId`).
- No confundir con el `cost` del ítem (precio total de la actividad/estancia).

---

## UX

- Apartado **«Reserva / cancelación»** en formularios de evento y alojamiento (mismo layout).
- Lectura clara: «Hasta *fecha/hora (TZ)* recuperas el **X %** del depósito; se pierde un fijo de **Y €** (si hay).»
- Calendario: icono `CancellationDeadlineBadge` en evento y chip de alojamiento si hay límite en ≤14 días (naranja si ≤48 h).
- Info del plan: sección **«Próximas cancelaciones»** (`UpcomingCancellationsSection`) con deadlines futuros de eventos y alojamientos.

---

## Avisos

- Canal: campana + push al **organizador**.
- **Programación por ítem** (selector en formulario «Reserva / cancelación»):
  - Sin aviso / solo el día / 24 h / 48 h / 1 semana (± el día del límite).
  - Persistido en `reminderLeadHours` + `reminderAlsoOnDay` (default efectivo si falta: 48 h + día).
- Fases de dedupe: `h24` | `h48` | `h168` | `day` (`dedupeKey = itemId|deadlineIso|percent|phase`).
- **Programados:** Cloud Function `checkCancellationDeadlines` (pubsub `every 60 minutes`, TZ `Europe/Madrid`).
- **Refuerzo in-app:** al abrir el plan (`CancellationDeadlineReminder`).
- **Prueba manual / Scheduler HTTP:** `triggerCancellationDeadlineCheck` — **QA pendiente** (no validado aún en dispositivos).
- Campo denormalizado `nextCancellationDeadline` al guardar evento/alojamiento (índice futuro).
- Relacionado con alarmas futuras **T110** / recordatorios por fecha.

---

## Fuera de alcance (v1)

- Varios pagadores de la misma garantía.
- Más de 2 tramos o % distinto por persona.
- Cargo fijo distinto por tramo.
- Universal Links / deep links (ajeno).
- Cancelación automática del ítem.

---

## Criterios de aceptación (borrador)

- [x] Crear/editar garantía + 0–2 tramos + fijo opcional en evento y en alojamiento.
- [x] Persistencia Firestore (`reservationCancellation`); TZ del ítem en UI de deadlines.
- [x] Garantía con pagador visible en Pagos/balances (`paymentKind: guarantee`).
- [x] Organizador recibe aviso al abrir el plan si el límite está en ≤48 h (campana + push).
- [x] Avisos programados CF: respeta preset del ítem (`checkCancellationDeadlines`); **QA del cron pendiente**.
- [x] Selector en formulario para programar el aviso (antelación + día).
- [x] l10n ES/EN.
- [x] Indicador en calendario + lista «Próximas cancelaciones» en Info del plan.
- [ ] Docs: actualizar `ACCOMMODATION_FORM_FIELDS.md` / flujo eventos y `PAGOS_MVP` o anexo breve.
- [x] Validación QA en dispositivos (garantía + nombres + moneda plan) — 2026-08-10.
- [ ] Validación QA avisos programados (cron / trigger HTTP) — pendiente.
- [x] Desplegar `firestore.rules` (campos `accommodationId` / `paymentKind` en personal_payments) — 2026-08-10.
- [x] Desplegar Cloud Functions T273 (`checkCancellationDeadlines`, `triggerCancellationDeadlineCheck`) — 2026-08-10 (redeploy al cambiar presets).

---

## Referencias

- `docs/especificaciones/ACCOMMODATION_FORM_FIELDS.md` (depósito / día límite — propuesta antigua)
- `docs/flujos/FLUJO_CRUD_ALOJAMIENTOS.md`, `FLUJO_CRUD_EVENTOS.md`
- `docs/producto/PAGOS_MVP.md`
- `docs/tareas/TASKS.md` → **T273**
