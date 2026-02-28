# T231 – Decisión: apartado «Avisos» en Info del plan

**Contexto:** En la pestaña **Info del plan** (W6 / Plan Data) hay una sección **Avisos** con timeline de mensajes unidireccionales del plan.

---

## Proceso (flujo) de los avisos

**Cuándo se generan:** Solo cuando un participante del plan publica manualmente un aviso (no hay avisos automáticos por eventos ni por el sistema).

| Paso | Quién | Dónde | Qué pasa |
|------|--------|--------|----------|
| 1. Publicar | Cualquier participante del plan (organizador o no) | Info del plan → sección Avisos → botón **«Publicar»** | Se abre el diálogo: mensaje (obligatorio), tipo opcional (info / urgente / importante). |
| 2. Guardar | El mismo usuario | Diálogo «Publicar aviso» → confirmar | Se crea un documento en Firestore `plans/{planId}/announcements`. |
| 3. Notificar | Sistema | Tras guardar el aviso | Se crean notificaciones in-app (campana) para **todos los participantes activos del plan excepto el autor**. Título según tipo: "Nuevo aviso", "Aviso importante" o "Aviso urgente" en [nombre del plan]. |
| 4. Ver historial | Cualquier participante | Info del plan → sección Avisos | El **timeline** muestra todos los avisos del plan (autor, tipo, mensaje, fecha). Quien publicó puede **borrar** su propio aviso. |
| 5. Ver notificación | Resto de participantes | Icono campana (W1) / lista de notificaciones | Aparece una notificación del tipo "Nuevo aviso en [plan]"; al abrirla pueden ir al plan y leer el aviso en Info. |

**Para qué sirven:** Anuncios unidireccionales al grupo (recordatorios, cambios, avisos urgentes). No es chat: no hay respuestas ni hilos, solo mensajes de «anuncio» del plan.

---

**Qué hace hoy (resumen técnico):**
- Cualquier participante puede **publicar** un aviso (diálogo con tipo: info, urgente, importante).
- Todos los participantes **ven** el timeline de avisos.
- Al publicar se crean **notificaciones in-app** para el resto de participantes (mediante Cloud Function `onCreateAnnouncementNotifyParticipants`, porque las reglas de Firestore no permiten que el cliente escriba en `users/{otro}/notifications`).
- Persistencia en Firestore: `plans/{planId}/announcements`.
- UI: título "Avisos", tooltip de ayuda, botón "Publicar", lista con autor, tipo, mensaje y opción de borrar (propio).

**Despliegue:** Para que el resto de participantes reciba notificación en la campana, hay que desplegar Cloud Functions: desde la raíz del proyecto, `cd functions && npm install` (si hace falta) y `npx firebase deploy --only functions`. Si solo se despliegan reglas (`firebase deploy --only firestore:rules`), los avisos se ven en Info del plan pero no se crean notificaciones para otros usuarios.

**Opciones (elegir una):**

| Opción | Descripción | Implicaciones |
|--------|-------------|----------------|
| **Mantener** | Dejar la sección tal cual. | Sin cambios. Sigue siendo un canal de anuncios del plan. |
| **Simplificar** | Reducir peso visual o funcional (ej. solo organizadores publican, menos tipos, o menos altura mínima). | Definir qué se simplifica (permisos, tipos, UI) y aplicar. |
| **Quitar** | Eliminar la sección Avisos de Info del plan (y opcionalmente el modelo/servicio/notificaciones asociados). | Ocultar o eliminar bloque en `wd_plan_data_screen.dart`, AnnouncementTimeline, botón Publicar; opcional: deprecar AnnouncementService, notificaciones de tipo announcement, colección Firestore. |

**Decisión:** *(pendiente)*

- [ ] Mantener  
- [ ] Simplificar (detallar en comentario debajo)  
- [ ] Quitar  

*Una vez decidido, actualizar este documento y, si aplica, TASKS.md / COMPLETED_TASKS.md.*
