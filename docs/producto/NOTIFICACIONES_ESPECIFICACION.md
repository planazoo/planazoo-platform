# Especificación del sistema de notificaciones

> Decisiones de producto y UX para el sistema unificado de notificaciones.  
> **Versión:** 1.0  
> **Fecha:** Febrero 2026

---

## 1. Objetivo

- **Un espacio global** donde el usuario ve **todas** las notificaciones de la app (vengan de donde vengan).
- **Vistas contextuales** en cada parte de la app: en cada zona (p. ej. un plan concreto) se muestran solo las notificaciones de esa parte.

---

## 2. Decisiones tomadas

### 2.1 Contenido del espacio global

En la lista global entran **todas** las notificaciones: invitaciones a planes, eventos desde correo, avisos publicados, cambios en eventos, alarmas (y las que se añadan en el futuro). Sin excepción por tipo.

### 2.2 Vista por defecto y filtros (lista global)

- **Vista por defecto:** una sola lista **cronológica** (lo más reciente arriba), todo mezclado. Cada fila indica el tipo (invitación, aviso, evento desde correo, etc.).
- **Opción de filtrar:** por **acción**:
  - **Pendientes de acción** (invitaciones, eventos desde correo, etc.).
  - **Solo informativas** (avisos, cambios en eventos, etc.).
No se requiere filtro por tipo; con "por acción" es suficiente.

### 2.3 Dónde se accede a qué

| Entrada | Contenido |
|--------|-----------|
| **Campana** (icono notificaciones) | Abre la **lista global**: todas las notificaciones, cronológica, con filtro por acción. |
| **W20** (pestaña "Notificaciones" del dashboard) | Notificaciones **del plan seleccionado**. W20 forma parte del grupo W14–W25, ligado al plan seleccionado (siempre hay un plan seleccionado en ese contexto). |

### 2.4 Contenido de W20 (notificaciones del plan seleccionado)

- Notificaciones con **planId = plan seleccionado**:
  - Invitaciones a ese plan.
  - Avisos publicados en ese plan.
  - Cambios en eventos de ese plan.
- **Sección aparte:** "Eventos desde correo pendientes", para poder asignarlos a **este plan** desde la misma pantalla (los mismos ítems que en la lista global, con acción "asignar a plan" / descartar).

### 2.5 Badge en la campana

- **Sí:** la campana muestra un **badge con número**.
- El número es el **total de notificaciones no leídas** (en la lista global).

### 2.6 Relación W14–W25 con el plan seleccionado

W14–W25 son las pestañas del dashboard ligadas al **plan seleccionado** (documentado en `docs/guias/GUIA_UI.md` y en las páginas UX de W14, W15, W16). W20 es "Notificaciones de este plan" y se comporta como el resto del grupo.

---

## 3. Resumen de flujos

### 3.1 Usuario abre la campana

1. Ve la **lista global** (todas las notificaciones, cronológica).
2. Puede filtrar por "Pendientes de acción" o "Solo informativas".
3. El badge muestra el total de no leídas.

### 3.2 Usuario hace clic en W20 (con un plan seleccionado)

1. Ve solo notificaciones **de ese plan** (invitaciones al plan, avisos del plan, cambios en eventos del plan).
2. Ve además la sección **"Eventos desde correo pendientes"** para asignar a este plan o descartar.

### 3.3 Fuentes de datos (sin cambiar por ahora)

- **Invitaciones:** `plan_invitations` (+ participaciones).
- **Eventos desde correo:** `users/{userId}/pending_email_events`.
- **Notificaciones de actividad:** `users/{userId}/notifications` (NotificationModel).
- **Cambios en eventos:** `event_notifications` (si se integra en la lista global).

La lista global **agrega** todas estas fuentes en una sola vista (cronológica y filtrable por acción). W20 **filtra** por `planId = selectedPlan.id` y añade la sección de eventos desde correo pendientes.

---

## 4. Documentación relacionada

- **Plan de codificación:** `docs/producto/NOTIFICACIONES_PLAN_CODIFICACION.md`
- **Flujo detallado invitaciones y notificaciones:** `docs/flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md`
- **Buzón unificado (estado anterior / evolución):** `docs/producto/BUZON_UNIFICADO_NOTIFICACIONES.md`
- **UI y widgets W14–W25:** `docs/guias/GUIA_UI.md`, `docs/ux/pages/w14_plan_info_access.md`, etc.
- **FCM (push):** `docs/configuracion/FCM_FASE1_IMPLEMENTACION.md`
- **Testing:** `docs/configuracion/TESTING_CHECKLIST.md` (sección 7.4 Sistema de notificaciones) y `docs/testing/SISTEMA_PRUEBAS_LOGICAS.md`

---

## 5. Criterios de coherencia

Para que la documentación sea coherente con este tema:

1. **Campana** = siempre "lista global de notificaciones" (todas, cronológica, filtro por acción, badge con total no leídas).
2. **W20** = siempre "notificaciones del plan seleccionado" (planId + sección eventos desde correo pendientes).
3. **W14–W25** = grupo de pestañas del dashboard asociado al plan seleccionado; no mencionar W20 como "buzón global" sino como "notificaciones del plan".
4. Cualquier flujo o checklist que hable de "notificaciones" debe distinguir entre lista global (campana) y vista por plan (W20) cuando sea relevante.
