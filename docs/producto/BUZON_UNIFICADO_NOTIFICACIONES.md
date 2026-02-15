# Buzón unificado de notificaciones

> **Estado:** Sustituido por la [Especificación del sistema de notificaciones](NOTIFICACIONES_ESPECIFICACION.md).  
> Este documento conserva el contexto histórico y enlaza la implementación actual con la especificación final.

---

## Objetivo (histórico)

Centralizar en un único buzón todo lo que requiere atención del usuario o proviene de "fuera" de la app: invitaciones, eventos desde correo y (opcional) actividad reciente.

---

## Decisión final (Febrero 2026)

La especificación cerrada está en **[NOTIFICACIONES_ESPECIFICACION.md](NOTIFICACIONES_ESPECIFICACION.md)**. Resumen:

| Entrada | Contenido |
|--------|-----------|
| **Campana** | Lista **global**: todas las notificaciones (cronológica, filtro por acción, badge con total no leídas). |
| **W20** | Notificaciones **del plan seleccionado** (planId = seleccionado) + sección "Eventos desde correo pendientes" para asignar a este plan. |

- W20 forma parte de W14–W25 (pestañas del plan seleccionado). Siempre hay un plan seleccionado en ese contexto.
- Lista global: vista por defecto cronológica; opción de filtrar por "Pendientes de acción" / "Solo informativas".

---

## Estado de implementación (pre-especificación)

- **Hecho:** Pantalla unificada que mostraba invitaciones + eventos desde correo en una sola pantalla; pestaña W20 "Notificaciones" abría esa pantalla; campana abría `NotificationListDialog` (solo NotificationModel).
- **Pendiente (según especificación):**  
  - Campana → lista global agregada (todas las fuentes, cronológica, filtro por acción, badge total no leídas).  
  - W20 → vista filtrada por plan seleccionado + sección eventos desde correo pendientes.  
  - Ver [Plan de codificación – Notificaciones](NOTIFICACIONES_PLAN_CODIFICACION.md).

---

## Documentación relacionada

- [NOTIFICACIONES_ESPECIFICACION.md](NOTIFICACIONES_ESPECIFICACION.md) – Especificación y decisiones.
- [NOTIFICACIONES_PLAN_CODIFICACION.md](NOTIFICACIONES_PLAN_CODIFICACION.md) – Plan de implementación.
- [FLUJO_INVITACIONES_NOTIFICACIONES.md](../flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md) – Flujos de invitaciones y notificaciones.
