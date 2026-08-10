# T273 — Reserva / cancelación: garantía, tramos y avisos

**Estado:** ✅ Completada (Ago 2026)  
**Prioridad:** Alta  
**Ámbito:** Eventos y alojamientos · Pagos/balances · Avisos al organizador  
**Sistema de procesos:** contrato de producto (piloto) → [`MAPA_FLUJOS.md`](../flujos/MAPA_FLUJOS.md).

---

## Problema

Al reservar suele pedirse un **pago como garantía** ligado a una **política de cancelación**. Antes solo había `cost`; no había depósito, fechas límite ni avisos.

---

## Objetivo (cumplido)

1. Garantía (importe + un pagador + estado + nota).
2. Hasta **2 tramos** (fecha+hora + % recuperado).
3. Cargo fijo opcional.
4. Avisos al **organizador** (preset + cron + refuerzo al abrir plan).
5. Visibilidad en **Pagos / balances**.

---

## Decisiones de producto

| # | Tema | Acuerdo |
|---|------|---------|
| 1 | Avisos | Solo **organizador** |
| 2 | Pagos | Sí: quién adelantó |
| 3 | Límite | Fecha + hora (TZ del ítem) |
| 4 | Tramos | Hasta 2; 1 válido |
| 5 | % | Lo que **se recupera** |
| 6 | Pagador | Uno en v1 |
| 7 | Ámbito | Mismo bloque evento/alojamiento |
| 8 | Fijo | Opcional, un fijo por ítem |

---

## Implementación (resumen)

- Modelo: `reservationCancellation` (+ `nextCancellationDeadline`).
- UI: `ReservationCancellationFormSection` (compacta, notas multilínea).
- Sync pagos: `GuaranteePaymentSync` → `paymentKind: guarantee`.
- Badge calendario + lista Info «Próximas cancelaciones».
- CF: `checkCancellationDeadlines` (cada 60 min) + `triggerCancellationDeadlineCheck`.
- Preset aviso: `reminderLeadHours` / `reminderAlsoOnDay`.

---

## Criterios de aceptación

- [x] Garantía + 0–2 tramos + fijo en evento y alojamiento.
- [x] Persistencia + TZ en UI.
- [x] Garantía en Pagos/balances.
- [x] Aviso al abrir plan (≤ ventana del preset).
- [x] Cron CF + selector de antelación.
- [x] l10n, badge, lista Info.
- [x] Anexos en `EVENT_FORM_FIELDS`, `ACCOMMODATION_FORM_FIELDS`, `PAGOS_MVP`.
- [x] Rules + deploy CF.
- [x] QA garantía UI (2026-08-10).
- [x] Smoke CF trigger (2026-08-10): HTTP 200, scan OK (`notified`/`skipped` coherentes). Validación push en dispositivo cuando haya un límite en ventana: opcional / regresión.

---

## QA cron (cómo repetir)

1. Ítem con tramo cuyo `deadlineAt` esté en la ventana del preset (p. ej. ≤48 h).
2. `GET/POST` → `https://us-central1-planazoo.cloudfunctions.net/triggerCancellationDeadlineCheck`
3. Esperado: JSON `success: true`; si no había dedupe, campana (+ push) al organizador.
4. Segunda llamada: `skipped` ↑ / `notified: 0` (dedupe).

---

## Fuera de alcance (v1)

Varios pagadores, >2 tramos, fijo por tramo, auto-cancelar ítem, Universal Links.

---

## Referencias

- Specs: anexos T273 en EVENT / ACCOMMODATION FORM_FIELDS · `PAGOS_MVP.md`
- Índices: `docs/flujos/FLUJO_CRUD_EVENTOS.md`, `FLUJO_CRUD_ALOJAMIENTOS.md`, `FLUJO_PRESUPUESTO_PAGOS.md`
- Código: `reservation_cancellation.dart`, `guarantee_payment_sync.dart`, `cancellation_deadline_reminder.dart`, `functions/index.js`
