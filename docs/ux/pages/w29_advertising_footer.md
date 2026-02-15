# W29 - Centro de mensajes

## Descripción
Widget de la fila inferior del dashboard que actúa como **centro de mensajes**: si el usuario tiene invitaciones pendientes, muestra un mensaje y un enlace para abrir la lista de notificaciones y aceptar/rechazar. Si no hay invitaciones pendientes, el área permanece vacía (sin contenido visible).

**Decisión (T198):** W29 no es pie publicitario; se define como centro de mensajes con contenido condicional (invitaciones pendientes → mensaje + enlace a notificaciones).

## Ubicación en el Grid
- **Posición**: C2-C5, R13
- **Dimensiones**: 4 columnas de ancho × 1 fila de alto
- **Área**: Parte izquierda de la fila inferior del dashboard

## Diseño visual
- **Fondo**: `Colors.grey.shade800` (contenedor base).
- **Contenido**:
  - Si **hay invitaciones pendientes**: texto tipo "Tienes X invitación(es) pendiente(s)" + botón/enlace "Ver notificaciones" que abre el diálogo de lista de notificaciones (mismo que la campana).
  - Si **no hay invitaciones**: área vacía (sin texto ni botón).

## Funcionalidad
- **Datos**: `userPendingInvitationsProvider` (invitaciones pendientes del usuario).
- **Acción**: "Ver notificaciones" abre `NotificationListDialog` (lista global con filtros y aceptar/rechazar invitaciones).
- **Estado**: Condicional según existan o no invitaciones pendientes.

## Implementación técnica
- **Archivo**: `lib/pages/pg_dashboard_page.dart`, método `_buildW29`.
- **L10n**: `dashboardInvitationsPendingCount`, `dashboardMessageCenterOpenNotifications` (app_es.arb / app_en.arb).

## Historial de decisiones
- **T10 / inicial**: W29 como pie publicitario sin contenido.
- **T198 / Febrero 2026**: Redefinido como centro de mensajes; contenido condicional (invitaciones pendientes + enlace a notificaciones). Documentado en este archivo.

**Implementación actual:** `lib/pages/pg_dashboard_page.dart`, método `_buildW29`.
