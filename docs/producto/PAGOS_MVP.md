# Pagos en el primer MVP

> Tema abierto: incluir pagos en el primer MVP. Este documento resume el estado actual y lo que queda por decidir/cerrar. **Sin implementación por ahora.**

**Última actualización:** Febrero 2026

---

## 1. Objetivo

Retomar el tema de **pagos** con la intención de que formen parte del **primer MVP**. Aquí se recoge qué hay ya hecho, qué falta por decidir y qué pasos dar antes de codificar.

---

## 1.1 Presupuesto del plan ≠ Sistema de pagos

No es lo mismo:

| Concepto | Qué es | Referencia técnica |
|----------|--------|---------------------|
| **Presupuesto del plan** | Qué cuesta el plan: costes por evento y alojamiento, total estimado/real, desglose en estadísticas. Responde a "¿cuánto va a costar / ha costado el plan?" | T101, `BudgetService`, `FLUJO_PRESUPUESTO_PAGOS.md` § 1–2 |
| **Sistema de pagos** | Quién ha pagado qué: pagos individuales de participantes, balances (deuda/crédito), sugerencias de transferencias. Responde a "¿quién ha puesto dinero y quién debe a quién?" | T102, `PaymentService`, `BalanceService`, `FLUJO_PRESUPUESTO_PAGOS.md` § 3–5 |

Este documento (**Pagos MVP**) y las tareas T217–T222 se refieren al **sistema de pagos** (T102). El presupuesto del plan (T101) ya está implementado y es un concepto distinto, aunque en la UI ambos se apoyan (p. ej. el coste por participante del presupuesto se usa para calcular el balance de pagos).

---

## 2. Qué hay ya implementado (referencia)

Tanto presupuesto (T101) como sistema de pagos (T102) tienen base implementada; para el MVP de **pagos** importa sobre todo T102:

- **T101 (completada):** Sistema de presupuesto del plan  
  - `BudgetService`, coste en eventos y alojamientos, integración en estadísticas del plan.  
  - Ver `docs/flujos/FLUJO_PRESUPUESTO_PAGOS.md` y `COMPLETED_TASKS.md` (T101).

- **T102 (completada):** Sistema de pagos personales  
  - Registro de pagos individuales (`PersonalPayment`), `PaymentService`, `BalanceService`.  
  - Cálculo de balances por participante (deuda/crédito), sugerencias de transferencias.  
  - **Web:** pestaña "Pagos" (W18) en el dashboard → `PaymentSummaryPage` (resumen de balances, listado de pagos).  
  - Diálogo para registrar pago: `PaymentDialog` (montos, moneda, conversión).

- **T153 (completada):** Multi-moneda  
  - Moneda del plan (EUR, USD, GBP, JPY), conversión en eventos/alojamientos/pagos, formateo en UI.

- **Firestore:** colección `personal_payments`; reglas y limpieza al borrar usuario documentadas.

**Dónde se usa hoy:**  
- **Dashboard web:** al seleccionar un plan, pestaña "Pagos" muestra `PaymentSummaryPage` (flujo real).  
- **Vista móvil del plan** (`pg_plan_detail_page.dart`): la opción "Pagos" muestra un **placeholder "Próximamente"** (no enlaza a `PaymentSummaryPage`).

---

## 3. Qué queda abierto / por decidir para el MVP

### 3.1 Alcance funcional del MVP

- **Registro de pagos:** ¿Solo organizador o también participantes pueden registrar “yo pagué X”? (Hoy el modelo y la UI permiten asociar un pago a un participante; falta cerrar permisos por rol.)
- **Solo “cuadre interno”:** ¿El MVP se limita a registrar quién ha pagado qué y a mostrar balances/sugerencias de quién le debe a quién, **sin** cobros reales (sin pasarela de pago)?
- **Bote común:** El flujo documenta “bote común”; en la implementación actual está marcado como pendiente/opcional. ¿Entra o no en el primer MVP?

### 3.2 UX y rutas

- **Mobile:** Sustituir el placeholder "Próximamente" por la misma lógica que en web (p. ej. abrir `PaymentSummaryPage` y, si aplica, flujo de registro de pago desde móvil).
- **Acceso:** ¿Pagos siempre desde el plan (dashboard web + detalle plan móvil) o además desde otro sitio (ej. notificación “te deben X”)?

### 3.3 Pruebas y calidad

- En `TESTING_CHECKLIST.md`, los casos de **Sistema de Pagos (T102)** (PAY-001, PAY-002, etc.) y los de presupuesto (BUD-003, etc.) están listados pero **sin marcar como probados**. Para el MVP conviene definir y ejecutar una batería mínima (registro de pago, ver balance, sugerencias).
- Incluir **pagos en el plan E2E** de tres usuarios (UA/UB/UC): por ejemplo, UA registra un pago de UB, se comprueba balance y que UC ve el resumen si aplica.

### 3.4 Legal y cumplimiento

- Dejar explícito que la app **no procesa cobros** (solo anotación y cuadre entre usuarios). Si más adelante se añade pasarela, hará falta revisar términos, privacidad y normativa de pagos.
- Retención de datos: cuánto tiempo se conservan pagos/balances (alineado con política de privacidad y borrado de usuario).

### 3.5 Prioridad frente a otras tareas MVP

- T150 (Definición de MVP y roadmap) es donde encajar “pagos en el primer MVP” de forma explícita.
- Decidir orden respecto a otras funcionalidades MVP (legal, cookies, notificaciones, etc.) para no bloquear lanzamiento.

---

## 4. Resumen de decisiones a tomar

| Tema | Pregunta | Opciones / Notas |
|------|----------|-------------------|
| Alcance | ¿Solo cuadre interno (sin cobro real)? | Recomendable para MVP: sí, solo registro y balances. |
| Quién registra pagos | ¿Solo organizador o también el participante “yo pagué X”? | Definir por rol; documentar en flujo y permisos. |
| Bote común | ¿Incluido en primer MVP? | Incluir o posponer; si se pospone, dejarlo en backlog. |
| Mobile | ¿Pestaña Pagos con flujo real en móvil? | Objetivo: sí para MVP (sustituir placeholder). |
| Pruebas | ¿Batería mínima de pagos + E2E? | Definir casos y añadir al plan E2E tres usuarios. |
| Legal | ¿Texto “solo anotación, no cobro”? | Incluir en términos/FAQ y en la propia UI si hace falta. |

---

## 5. Puntos a decidir (revisión)

Ninguna decisión está cerrada hasta que la revises y la confirmes. Para cada punto se indican opciones; anota tu decisión y, cuando estén todas, las pasamos a "Decisiones tomadas".

---

### 5.1 Alcance: ¿solo cuadre interno o algo más?

**Pregunta:** ¿El MVP se limita a registrar quién ha pagado qué y a mostrar balances/sugerencias, sin cobros reales (sin pasarela de pago)?

| Opción | Descripción |
|--------|-------------|
| **A** | Sí, solo cuadre interno: la app no procesa cobros; solo anotación y sugerencias de transferencias entre el grupo. |
| **B** | Incluir en el MVP algo más (ej. enlace a Bizum/PayPal "pagarte fuera de la app"; solo documentar; etc.). Describir: ___ |

**Tu decisión:** **A** (solo cuadre interno; la app no procesa cobros).

---

### 5.2 Quién puede registrar pagos

**Pregunta:** ¿Quién puede registrar un pago (quién pagó cuánto)?

| Opción | Descripción |
|--------|-------------|
| **A** | Solo el organizador: registra pagos de cualquier participante. |
| **B** | Organizador registra cualquier pago; el participante además puede registrar "yo pagué X" (solo el suyo). |
| **C** | Cualquier participante puede registrar cualquier pago (máxima flexibilidad, más riesgo de errores). |
| **D** | Otra: ___ |

**Tu decisión:** **B** (organizador registra cualquier pago; participante solo "yo pagué X").

---

### 5.3 Bote común

**Pregunta:** ¿El "bote común" (fondo compartido del grupo) entra en el primer MVP?

| Opción | Descripción |
|--------|-------------|
| **A** | No; fuera del MVP. Se pospone a una fase posterior. |
| **B** | Sí; incluir bote común en el MVP (implica definir flujo: quién pone, quién gasta, cómo se refleja en balances). |

**Tu decisión:** **B** (sí, incluir bote común en el MVP; definir flujo: quién pone, quién gasta, reflejo en balances).

---

### 5.4 Mobile: pestaña Pagos

**Pregunta:** ¿En la vista móvil del plan, la opción "Pagos" debe mostrar el flujo real (resumen de balances, registrar pago) o seguir con "Próximamente"?

| Opción | Descripción |
|--------|-------------|
| **A** | Sí: sustituir el placeholder por la misma experiencia que en web (PaymentSummaryPage + registrar pago según permisos). |
| **B** | No por ahora: dejar "Próximamente" en móvil para el MVP. |

**Tu decisión:** **A** (sí, misma experiencia que en web en móvil; sustituir "Próximamente").

---

### 5.5 Pruebas

**Pregunta:** ¿Incluir en el MVP una batería mínima de pruebas de pagos y una fase de pagos en el plan E2E de tres usuarios?

| Opción | Descripción |
|--------|-------------|
| **A** | Sí: casos PAY-* (registro, balance, sugerencias) + fase en E2E (ej. UA registra pago de UB, comprobar balance y vista de UC). |
| **B** | Solo pruebas manuales sin formalizar en checklist/E2E. |
| **C** | No priorizar pruebas de pagos para el MVP. |

**Tu decisión:** **A** (sí: casos PAY-* + fase de pagos en plan E2E tres usuarios). Las pruebas se han integrado en el sistema de pruebas definido (plan E2E y TESTING_CHECKLIST); ver sección 6 y docs/testing.

---

### 5.6 Legal y aviso en UI

**Pregunta:** ¿Incluir texto explícito de que la app no procesa cobros (solo anotación y cuadre)?

| Opción | Descripción |
|--------|-------------|
| **A** | Sí: en términos/FAQ y además un aviso breve en la pantalla de pagos (ej. "La app no procesa cobros; solo sirve para anotar y cuadrar entre el grupo"). |
| **B** | Solo en términos/FAQ, sin aviso en la pantalla de pagos. |
| **C** | No añadir por ahora. |

**Tu decisión:** **A** (sí: términos/FAQ + aviso breve en la pantalla de pagos; ej. "La app no procesa cobros; solo sirve para anotar y cuadrar entre el grupo").

---

---

## 5.7 Resumen: Decisiones tomadas (Febrero 2026)

| Tema | Decisión |
|------|----------|
| **5.1 Alcance** | **A** — Solo cuadre interno; la app no procesa cobros. |
| **5.2 Quién registra pagos** | **B** — Organizador registra cualquier pago; participante solo "yo pagué X". |
| **5.3 Bote común** | **B** — Sí en el MVP; definir flujo (quién pone, quién gasta, reflejo en balances). |
| **5.4 Mobile** | **A** — Sí; misma experiencia que en web; sustituir "Próximamente". |
| **5.5 Pruebas** | **A** — Sí; casos PAY-* + fase de pagos en plan E2E (integrado en docs/testing y TESTING_CHECKLIST). |
| **5.6 Legal y aviso en UI** | **A** — Términos/FAQ + aviso breve en la pantalla de pagos. |

---

## 6. Próximos pasos (cuando estén cerradas las decisiones)

Los siguientes pasos se concretan en función de lo que decidas en la sección 5.

1. **Tareas:** Ya documentadas en `docs/tareas/TASKS.md` § 12: **T217** (unificar web/mobile), **T218** (permisos por rol), **T219** (bote común), **T220** (aviso UI + legal), **T221** (actualizar FLUJO_PRESUPUESTO_PAGOS.md), **T222** (ejecutar fase E2E y PAY-*). Vincular a T150 (MVP).
2. **Flujo y permisos:** Actualizar `FLUJO_PRESUPUESTO_PAGOS.md` con las decisiones (quién registra qué, sin bote común en MVP) y la matriz de permisos por rol/estado del plan.
3. **Testing:** Añadir al plan E2E (tres usuarios) la fase de pagos; ejecutar casos PAY-* de `TESTING_CHECKLIST.md` cuando se implemente.
4. **Legal:** Incluir en términos/FAQ que la app no procesa cobros; añadir el aviso breve en la pantalla de pagos.

Cuando estén hechas las tareas anteriores, el bloque pagos MVP queda cerrado para lanzamiento.

---

*Documento de producto – Pagos en el primer MVP*
