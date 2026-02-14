# Buzón unificado de notificaciones

> Un solo lugar para invitaciones, eventos desde correo y (opcional) actividad reciente.

## Objetivo

Centralizar en **un único buzón** todo lo que requiere atención del usuario o proviene de “fuera” de la app:

- **Invitaciones a planes** (aceptar / rechazar)
- **Eventos desde correo** (asignar a plan / descartar)
- **Opcional:** notificaciones de actividad (evento creado, aviso, etc.) en la misma pantalla o en una pestaña

Así el usuario tiene un solo sitio donde mirar: “¿qué tengo pendiente?”.

## Estado actual

| Origen              | Dónde se muestra hoy                          |
|---------------------|-----------------------------------------------|
| Invitaciones        | Banner arriba del dashboard + en Participantes |
| Eventos desde correo| Pestaña “Buzón” (W20)                         |
| Notificaciones (app)| Diálogo “Notificaciones” (campana)            |

## Propuesta

1. **Una pantalla “Notificaciones” (buzón unificado)** con dos bloques:
   - **Invitaciones a planes:** mismas cards que hoy (plan, inviter, aceptar/rechazar).
   - **Eventos desde correo:** mismas cards que hoy (título, ubicación, asignar a plan / descartar).

2. **Una sola entrada en el dashboard:**
   - Sustituir la pestaña “Buzón” (W20) por **“Notificaciones”** que abre esta pantalla unificada.
   - Opcional: badge en la pestaña (o en una campana) con el total: `invitaciones pendientes + eventos desde correo pendientes`.

3. **Banner de invitaciones:**
   - Opción A: Quitar el banner y que todo se vea solo en el buzón unificado.
   - Opción B: Dejar un banner breve (“Tienes X notificaciones”) que lleve a la pantalla Notificaciones.

4. **Notificaciones de actividad** (NotificationModel: evento creado, aviso, etc.):
   - Opción A: Tercer bloque en la misma pantalla (“Actividad reciente”).
   - Opción B: Dejarlas solo en el diálogo de la campana por ahora.

## Implementación (resumen)

- Crear `WdUnifiedNotificationsScreen` que muestre:
  - Sección “Invitaciones” usando `userPendingInvitationsProvider` y las cards actuales (o reutilizando el widget del banner).
  - Sección “Eventos desde correo” usando `PendingEmailEventService` y las cards actuales de `WdPendingEmailEventsScreen`.
- En el dashboard: cambiar la pestaña W20 de “Buzón” a “Notificaciones” y que apunte a esta pantalla.
- Quitar o simplificar el banner de invitaciones según la opción elegida.
- Traducciones: clave tipo “notificationsTab” o “inboxTab” para la pestaña.

## Decisiones a cerrar

- ¿Quitar el banner de invitaciones y dejar solo el buzón unificado? (recomendado: sí para no duplicar.)
- ¿Incluir en la misma pantalla las notificaciones de actividad (NotificationModel) o solo invitaciones + eventos correo? (recomendado: incluir un bloque “Actividad” si hay pocas, para tener todo en un sitio.)
