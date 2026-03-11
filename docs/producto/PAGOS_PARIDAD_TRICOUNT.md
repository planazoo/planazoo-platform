# Paridad del apartado de pagos con Tricount

> Objetivo: que el apartado de pagos tenga la misma funcionalidad que la app Tricount (reparto de gastos en grupo).

**Referencia:** [Tricount](https://www.tricount.com/features) – app de gastos grupales (expense splitting).

---

## 1. Comparativa Tricount vs estado actual

| Funcionalidad Tricount | Estado actual en la app | Acción |
|------------------------|-------------------------|--------|
| **Añadir gasto** (quién pagó, importe, concepto, reparto entre participantes) | Existe "Registrar pago" (quién pagó, importe, concepto, opcional evento). No hay "gasto" con reparto explícito entre personas. | Añadir **gastos tipo Tricount**: pagador + importe + concepto + reparto (igual o personalizado). |
| **Reparto desigual** (cada uno paga lo suyo) | El coste viene del presupuesto (eventos/alojamiento) o del bote; no hay reparto por gasto. | Permitir **reparto personalizado** por gasto (opcional: importe por participante). |
| **Lista / actividad de gastos** | Resumen de balances y listado de pagos dentro de cada participante; no hay timeline único de "todos los gastos". | Añadir sección **Actividad** en la página de pagos: lista cronológica de gastos (y opcionalmente pagos/bote). |
| **Sugerencias de transferencias** (quién debe a quién) | Ya implementado: `calculateTransferSuggestions`. | Mantener. |
| **Múltiples monedas** | Moneda del plan (T153); conversión en pagos. | Mantener. |
| **Tipos: gasto, ingreso, transferencia** | Solo pagos (y bote: aportación/gasto). | Fase 2: **ingreso** y **transferencia** como tipos de movimiento. |
| **Calculadora** al dividir | No. | Fase 2: calculadora en el diálogo de añadir gasto. |
| **Solicitar dinero** (recordatorio a quien debe) | No. | Fase 2: "Solicitar X a Y" desde el resumen. |
| **Fotos en gastos** | No. | Fase 2: adjuntar foto/recibo. |

---

## 2. Decisiones de diseño (paridad tipo Tricount)

- **Gasto (PlanExpense):** Quién pagó, importe, concepto, fecha, y **reparto** entre participantes:
  - **Reparto igual:** entre N participantes seleccionados.
  - **Reparto personalizado:** importe por participante (suma = importe del gasto).
- El **coste** de cada participante para el balance se forma por:
  - Presupuesto (eventos + alojamiento), como hasta ahora.
  - Parte del **bote común** (gasto del bote repartido), como hasta ahora.
  - **Su parte en cada gasto tipo Tricount** (nuevo).
- Lo que ha **pagado** cada uno: pagos registrados + aportaciones al bote + **importes que haya pagado en gastos** (como pagador en PlanExpense).
- **Actividad:** Una sola lista en la página de pagos con: gastos (Tricount), pagos registrados y movimientos del bote, ordenados por fecha.

---

## 3. Implementación (fases)

### Fase 1 – Núcleo Tricount (este documento)

1. **Modelo y persistencia**
   - `PlanExpense`: planId, payerId, amount, concept, date, participantIds (quién entra en el reparto), equalSplit (bool), customShares (Map<userId, double>).
   - Colección Firestore `plan_expenses`; reglas de lectura/escritura por plan.
   - `ExpenseService`: crear, actualizar, eliminar, stream por planId.

2. **Cálculo de balances**
   - `BalanceService.calculatePaymentSummary` acepta `List<PlanExpense>`.
   - Para cada gasto: pagador suma `amount` a lo pagado; cada participante en el reparto suma su parte (igual o customShares) al coste.
   - Integrar en el provider que ya alimenta `PaymentSummaryPage` (traer gastos y pasarlos al balance).

3. **UI**
   - **Diálogo "Añadir gasto"**: pagador, importe, concepto, fecha, participantes en el reparto, reparto igual (por defecto) o personalizado (Fase 1 puede ser solo igual).
   - **Sección "Actividad"** en la página de pagos: lista de gastos (y, si se desea, pagos y bote) por fecha.

### Fase 2 (backlog)

- Reparto personalizado (importe por persona) en el diálogo de gasto.
- Calculadora en el diálogo.
- Tipos: ingreso y transferencia entre participantes.
- Solicitar dinero (recordatorio).
- Fotos en gastos.

---

## 4. Archivos y referencias

- **Modelo:** `lib/features/payments/domain/models/plan_expense.dart` (nuevo).
- **Servicio:** `lib/features/payments/domain/services/expense_service.dart` (nuevo).
- **Balance:** `lib/features/payments/domain/services/balance_service.dart` (extender con planExpenses).
- **Providers:** `lib/features/payments/presentation/providers/payment_providers.dart` (incluir gastos en el resumen).
- **UI:** diálogo añadir gasto, sección Actividad en `payment_summary_page.dart`.
- **Reglas:** `firestore.rules` (colección `plan_expenses`).
- **Flujo:** actualizar `docs/flujos/FLUJO_PRESUPUESTO_PAGOS.md` cuando esté implementada la Fase 1.

---

*Documento de producto – Paridad pagos con Tricount*
