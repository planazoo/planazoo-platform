# Estado del usuario en el plan – W10, W6, card y flujos

Documento de referencia para **dónde y cómo** mostramos el estado del usuario en el plan (invitación pendiente, aceptado, rechazado, rol) y cómo se aceptan/rechazan invitaciones y se cambia el estado.

**Última actualización:** Marzo 2026

---

## 1. Modelos de datos

- **PlanInvitation** (email, planId, status: pending | accepted | rejected | expired, role, token…). La invitación por email o directa crea este documento.
- **PlanParticipation** (userId, planId, role, **status**: pending | accepted | rejected | expired). Se crea al invitar directamente (usuario ya registrado) o al aceptar una invitación por email. `status == 'pending'` = invitado pero aún no ha aceptado/rechazado.

Flujos que mantenemos:
1. **Invitación por email**: organizador crea invitación → se envía/copia enlace → invitado entra en la app, inicia sesión (o se registra) → acepta/rechaza desde **Notificaciones** (lista global).
2. **Invitación directa**: organizador invita a usuario ya registrado → se crea participación `pending` (y/o invitación) → invitado acepta/rechaza desde **Notificaciones**.

---

## 2. Estado actual en la UI

### 2.1 W6 – Información del plan (header)

- **Ubicación:** Barra superior del dashboard (C7–C11, R1). Implementado en `WdDashboardHeaderBar._buildW6` / `_buildPlanInfoContent`.
- **Qué se muestra hoy:**
  - Nombre del plan.
  - Fechas inicio–fin.
  - Línea tercera: `handle` (ej. @usuario o email) y **rol** (Organizador / Participante / Observador) si el usuario está en `planParticipantsProvider`; enlace “Ver mi resumen” (T252) si aplica.
- **Qué no se muestra:**
  - **Estado de participación** del usuario actual (pendiente / aceptado / rechazado). Si el usuario solo tiene **invitación pendiente** (aún no participación), no aparece en participantes → en W6 solo se ve nombre del plan y fechas; no se indica “Invitación pendiente” ni “Tu estado: Pendiente”.
  - Estado del plan (planificando, confirmado, etc.) en esta barra; en la última iteración se acordó mostrarlo en la **barra superior de Info del plan** (pestaña dentro del plan), no obligatoriamente en W6.

**Resumen:** W6 muestra rol cuando ya hay participación aceptada; no distingue “invitación pendiente” ni “participación pendiente”.

### 2.2 W10 – “Mi estado”

- **Especificación (GUIA_UI):** W10 = “Mi estado” (C15, R1).
- **Implementación actual:** Las celdas W7–W12 (C12–C17, R1) están implementadas como **placeholders** vacíos (`WdDashboardHeaderPlaceholders`): mismo fondo que el header, sin contenido. **W10 no está implementado.**

### 2.3 Card del plan (W28)

- **Ubicación:** Lista de planes (W28). Widget: `PlanCardWidget` (`wd_plan_card_widget.dart`).
- **Qué se muestra hoy:**
  - Nombre, fechas, “X días”, badge de **estado del plan** (planificando, confirmado, etc.), participantes, iconos (resumen, notificaciones, chat).
  - **Badge “Invitación”** (naranja) cuando `userPendingInvitationsProvider` contiene una invitación pendiente para ese plan.
- **Qué no se muestra:**
  - “Mi estado” como participante (ej. “Pendiente de aceptar”, “Aceptado”, “Solo invitación”) cuando ya hay **participación** con `status == 'pending'`. Hoy la card solo reacciona a *invitación* pendiente, no a participación pendiente.

**Resumen:** La card ya indica “tienes invitación pendiente” para ese plan; no indica explícitamente “tu participación está pendiente” cuando la invitación ya se convirtió en participación pending.

### 2.4 Aceptar / rechazar invitaciones

- **Dónde:** Lista global de notificaciones (icono campana / W24) → `NotificationListDialog` → para cada notificación de tipo invitación se usa `InvitationNotificationTile`.
- **Acciones:** Botones “Aceptar” y “Rechazar” que llaman a `acceptInvitationByPlanId(planId, userId)` y `rejectInvitationByPlanId(planId, userId)`. Tras aceptar se crea/actualiza participación y se marca invitación como aceptada; tras rechazar se actualiza invitación y opcionalmente participación.
- **W29:** Mensaje tipo “Tienes N invitación(es) pendiente(s)” y enlace “Ver notificaciones” que abre la misma lista global. No hay flujo por token ni pegar token en dashboard.

**Resumen:** Aceptar/rechazar está centralizado en la lista de notificaciones; no hay otra entrada (token/enlace mágico en la app).

### 2.5 Cambiar el estado del usuario en el plan

- **Participante:**
  - **Aceptar/Rechazar:** Solo desde notificaciones (arriba).
  - **Salir del plan:** Desde Info del plan o pestaña Participantes (“Salir del plan”); actualiza participación (baja o marca inactivo según implementación).
- **Organizador:**
  - Cambiar **rol** de un participante (participante, observador, etc.) desde la pantalla de Participantes.
  - No hay “revertir aceptación” explícito; si se necesita, sería una acción específica (ej. “Quitar del plan” / eliminar participación).

---

## 3. Resumen de huecos y opciones

| Dónde | Hueco actual | Opciones |
|------|----------------|----------|
| **W6** | No se muestra “Invitación pendiente” ni “Participación pendiente” cuando el usuario aún no ha aceptado. | (A) Añadir en la tercera línea un texto tipo “Invitación pendiente” o “Pendiente de aceptar” cuando haya invitación pendiente o participación pending para el plan seleccionado. (B) Dejar W6 solo con nombre, fechas y rol (y “Ver mi resumen”) y llevar “mi estado” a W10. |
| **W10** | No implementado (placeholder). | (A) Implementar W10 como “Mi estado”: un solo texto o badge (ej. “Pendiente de aceptar” / “Participante” / “Organizador”) para el plan seleccionado. (B) Unificar con W6: ampliar W6 con “mi estado” y no usar W10. (C) Dejar W10 vacío de momento y solo mejorar W6 y/o card. |
| **Card (W28)** | Solo badge “Invitación” por invitación pendiente; no “Participación pendiente”. | (A) Añadir un badge o texto “Pendiente de aceptar” cuando el plan esté en la lista por participación pending (sin invitación pendiente). (B) Unificar mensaje: “Pendiente” que cubra tanto invitación como participación pendiente. |
| **Aceptar/Rechazar** | Ya solo por notificaciones. | Sin cambio; opcional: en la card o W6 un enlace “Ver invitaciones” que abra la lista de notificaciones filtrada o scroll a invitaciones. |
| **Cambiar estado (organizador)** | Rol desde Participantes; “Salir del plan” para el propio usuario. | Documentar en flujos; opcional: en Participantes mostrar claramente “Estado: Pendiente” por usuario y permitir “Recordar” (reenviar notificación) o “Cancelar invitación”. |

---

## 4. Propuesta mínima recomendada

1. **W6:** Si hay **invitación pendiente** o **participación pendiente** para el plan seleccionado y el usuario actual, mostrar en W6 una línea o etiqueta clara: “Invitación pendiente” o “Pendiente de aceptar” (y opcionalmente enlace “Ver notificaciones”).
2. **W10:** Implementar como celda “Mi estado” con un solo texto/badge para el plan seleccionado: “Organizador” | “Participante” | “Pendiente de aceptar” | “Invitación pendiente” (según participación/invitación), para no sobrecargar W6 y alinear con GUIA_UI.
3. **Card:** Mantener badge “Invitación” cuando haya invitación pendiente; opcionalmente mostrar “Pendiente” también cuando el plan aparezca solo por participación pending (sin invitación), para consistencia.
4. **Aceptar/Rechazar:** Sin cambio; todo desde notificaciones.
5. **Participantes (organizador):** En la pantalla de participantes, mostrar estado por fila (Pendiente / Aceptado) y acciones (recordar, cancelar invitación) si se desea en una siguiente iteración.

---

## 5. iOS / móvil (PlanDetailPage)

En la **AppBar** de la página del plan (iOS/Android) se muestra **mi estado en el plan** en todas las pestañas: chip compacto con "Aceptado" | "Pendiente de aceptar" | "Invitación pendiente". Widget: `PlanUserStatusLabel` en `lib/widgets/plan/wd_plan_user_status_label.dart`, usado en `lib/pages/pg_plan_detail_page.dart` (`_buildAppBar` → `actions`).

## 6. Referencias de código

- W6: `lib/widgets/dashboard/wd_dashboard_header_bar.dart` (`_buildW6`, `_buildPlanInfoContent`, `_currentPlanRoleLabel`).
- W10: `lib/widgets/dashboard/wd_dashboard_my_status_cell.dart`; etiqueta reutilizable: `lib/widgets/plan/wd_plan_user_status_label.dart`.
- iOS AppBar: `lib/pages/pg_plan_detail_page.dart`, `lib/widgets/plan/wd_plan_user_status_label.dart`.
- W7–W12 (placeholders): `lib/widgets/dashboard/wd_dashboard_header_placeholders.dart`.
- Lista de planes / card: `lib/widgets/plan/wd_plan_card_widget.dart` (badge “Invitación” con `userPendingInvitationsProvider`).
- Lista de notificaciones e invitación: `lib/widgets/notifications/wd_notification_list_dialog.dart`, `wd_unified_notification_item.dart` (`InvitationNotificationTile`).
- Providers: `plan_participation_providers.dart`, `invitation_providers.dart` (`userPendingInvitationsProvider`), `calendar_providers.dart` (`plansStreamProvider` incluye planes con invitación/participación pendiente).
- Modelo participación: `lib/features/calendar/domain/models/plan_participation.dart` (`status`: pending, accepted, rejected, expired).
