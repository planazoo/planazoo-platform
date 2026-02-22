# Plan de codificación – Sistema de notificaciones

> Implementación según [NOTIFICACIONES_ESPECIFICACION.md](NOTIFICACIONES_ESPECIFICACION.md).  
> **Versión:** 1.0  
> **Fecha:** Febrero 2026

---

## 1. Objetivo

- **Campana** → lista global: todas las notificaciones (cronológica, filtro por acción, badge con total no leídas).
- **W20** → notificaciones del plan seleccionado (planId = seleccionado) + sección "Eventos desde correo pendientes".

---

## 2. Fases

### Fase 1: Modelo y agregación para la lista global

**Objetivo:** Poder obtener una única lista ordenada por fecha que combine todas las fuentes.

1. **Modelo unificado de lectura (opcional pero recomendado)**  
   - Definir un DTO o clase "UnifiedNotification" con: `id`, `type` (enum: invitation, emailEvent, announcement, eventChange, …), `title`, `body`, `createdAt`, `isRead`, `planId`, `data` (payload para acciones), `source` (origen: plan_invitations, pending_email_events, users/.../notifications, event_notifications).  
   - No implica migrar datos; es una capa de lectura que mapea desde las colecciones existentes.

2. **Servicio o provider "lista global"**  
   - Suscribirse a: invitaciones pendientes (por userId/email), pending_email_events (por authUid), users/{uid}/notifications, y si aplica event_notifications (por userId).  
   - Combinar streams (e.g. Rx.combineLatest o equivalente en Dart: listen a cada fuente y merge con timestamp).  
   - Ordenar por `createdAt` descendente.  
   - Exponer: `Stream<List<UnifiedNotification>>` y, para el badge, `Stream<int>` de total no leídas (invitaciones pendientes + eventos pendientes + notifications no leídas; definir si event_notifications cuenta como "no leída").

3. **Clasificación "Pendientes de acción" vs "Solo informativas"**  
   - En el modelo unificado, asignar a cada tipo una bandera `requiresAction` (true: invitaciones, eventos desde correo; false: avisos, cambios en eventos).  
   - El filtro en UI usa esta bandera.

**Entregables:** Clase/record UnifiedNotification (o similar), servicio/use-case "global notifications stream", provider(s) Riverpod que expongan lista global y total no leídas.

---

### Fase 2: UI lista global (campana)

1. **Pantalla o diálogo "Lista global de notificaciones"**  
   - Sustituir o reutilizar el contenido actual de `NotificationListDialog` (campana).  
   - Por defecto: una sola lista cronológica con todas las notificaciones (usar `UnifiedNotification`). Cada fila muestra tipo, título, fecha y si aplica botones (aceptar/rechazar, asignar a plan, etc.).  
   - Añadir filtro (pestañas o chips): "Todas" | "Pendientes de acción" | "Solo informativas".  
   - Opción "Marcar todas como leídas" (solo para las que tengan concepto de "leída" en su fuente).

2. **Badge en la campana**  
   - El icono de la campana (WdNotificationBadge o equivalente) debe mostrar el **total de notificaciones no leídas** (usar el stream de la Fase 1).  
   - Si el total es 0, ocultar el badge o mostrar solo el icono.

3. **Acciones desde la lista global**  
   - Reutilizar lógica existente: aceptar/rechazar invitación (InvitationService), asignar/descartar evento desde correo (PendingEmailEventActions). Al marcar NotificationModel como leída, usar NotificationService.  
   - Tras cada acción, invalidar providers para refrescar lista y badge.

**Entregables:** Pantalla/diálogo de lista global con filtro y acciones; badge en campana conectado al total no leídas.

---

### Fase 3: W20 – Notificaciones del plan seleccionado

1. **Pantalla W20**  
   - Recibe `planId` (plan seleccionado) del dashboard.  
   - Contenido:  
     - **Bloque 1:** Notificaciones con `planId` = plan seleccionado (invitaciones a ese plan, avisos del plan, cambios en eventos de ese plan). Orden cronológico.  
     - **Bloque 2:** Sección "Eventos desde correo pendientes" (misma fuente que lista global), con acciones "Asignar a **este** plan" y "Descartar".  
   - Puede reutilizar las mismas cards/acciones que la lista global (invitation card, WdPendingEventCard, etc.), filtrando por planId en el bloque 1.

2. **Navegación**  
   - El dashboard ya pasa el plan seleccionado; asegurar que la pantalla de W20 recibe `selectedPlan.id` y usa ese `planId` para filtrar y para "Asignar a plan" en eventos desde correo.

3. **Eliminar o no duplicar**  
   - Si actualmente W20 abre `WdUnifiedNotificationsScreen` (lista mezclada sin filtro por plan), sustituir por la nueva pantalla "notificaciones del plan" (con bloque 1 + bloque 2). La lista global solo se abre desde la campana.

**Entregables:** Pantalla W20 que muestra notificaciones del plan + eventos desde correo pendientes; asignar a este plan desde W20.

---

### Fase 4: Reglas, índices y pruebas

1. **Firestore**  
   - Verificar que las reglas permitan las lecturas necesarias para la lista global (invitaciones por usuario, pending_email_events por auth.uid, notifications por userId, event_notifications si se usa).  
   - Añadir índices compuestos si las consultas lo requieren (p. ej. event_notifications por userId + isRead + createdAt).

2. **Testing**  
   - Casos de checklist: `docs/configuracion/TESTING_CHECKLIST.md` sección 7.4 (NOTIF-001 a NOTIF-007).  
   - Pruebas unitarias o de integración opcionales: provider de lista global devuelve ítems ordenados; filtro por acción filtra correctamente; badge refleja total no leídas.

3. **Documentación**  
   - Actualizar "Implementación actual" en `FLUJO_INVITACIONES_NOTIFICACIONES.md` cuando cada fase esté hecha.  
   - Mantener `NOTIFICACIONES_ESPECIFICACION.md` y `BUZON_UNIFICADO_NOTIFICACIONES.md` como referencia.

**Entregables:** Reglas e índices revisados; checklist 7.4 ejecutable; doc actualizada.

---

## 3. Orden recomendado

1. Fase 1 (modelo + agregación + providers).  
2. Fase 2 (UI lista global + badge).  
3. Fase 3 (W20 por plan).  
4. Fase 4 (reglas, pruebas, docs).

---

## 4. Dependencias

- Auth: `authService.currentUser?.uid` y usuario actual para invitaciones/participaciones.  
- Plan seleccionado: estado del dashboard (`selectedPlan` / `selectedPlanId`) para W20.  
- Servicios existentes: InvitationService, PendingEmailEventService, NotificationService, EventNotificationService (si se integra).

---

## 5. Riesgos y mitigación

- **Múltiples fuentes con formatos distintos:** Usar un modelo unificado de lectura (UnifiedNotification) y mapear cada fuente a ese modelo; así la UI solo depende de un tipo.  
- **Rendimiento con muchos ítems:** Limitar a N más recientes (ej. 50) y ordenar en cliente si hace falta; paginación o "cargar más" en fases posteriores si se requiere.  
- **event_notifications en otra colección:** Decidir si se integra en la lista global desde el inicio; si no, dejarlo para una iteración posterior y la lista global solo agrega invitaciones, pending_email_events y users/.../notifications.
