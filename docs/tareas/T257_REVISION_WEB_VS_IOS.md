# T257 – Revisión web vs iOS (prioridad iOS)

**Objetivo:** Revisar las diferencias entre la versión web y la versión iOS de Planazoo, priorizando que **iOS** tenga paridad funcional y de experiencia con la web. La web está más desarrollada; iOS es la plataforma más importante para el producto.

**Referencia en lista:** `docs/tareas/TASKS.md` (T257).  
**Checklist y hallazgos detallados:** `docs/configuracion/REVISION_IOS_VS_WEB.md`.

---

## Contexto

- **Entrada autenticada:** Web → `DashboardPage` (grid, sidebar W1, pestañas W14–W20, lista de planes, panel de contenido). iOS → `PlansListPage` (lista de planes, barra inferior notificaciones/chat/perfil).
- **Detalle de plan:** Web → contenido en panel W31 (mismas pantallas). iOS → `PlanDetailPage` con `PlanNavigationBar` (Info, Mi resumen, Calendario, Participantes, Stats, Pagos, Chat).
- **Calendario:** Web → `CalendarScreen` (desktop). iOS → `CalendarMobilePage` (vista adaptada 1–3 días).
- La decisión de qué UI mostrar se toma en `app.dart` con `PlatformUtils.shouldShowMobileUI(context)`.

---

## Alcance de la tarea

- **Incluye:**
  - Recorrer flujos principales en web y en iOS y anotar diferencias de comportamiento, pantallas faltantes o textos/estados distintos.
  - Priorizar incidencias que afecten solo a iOS (o que en iOS sean peores que en web).
  - Cerrar o documentar cada diferencia: ya corregida, aceptada como distinto por plataforma, o pendiente de implementación (con subtarea si aplica).
  - Actualizar `docs/configuracion/REVISION_IOS_VS_WEB.md` con el estado actual y un checklist de paridad (web vs iOS) por área.
- **No incluye:**
  - Rediseño completo de ninguna plataforma; solo alinear funcionalidad y UX donde tenga sentido.

---

## Áreas a revisar (checklist) – rellenado Marzo 2026

- [x] **Lista de planes:** Filtros, búsqueda, creación, card (imagen, iconos, navegación). **Paridad:** iOS tiene filtros (todos, estoy in, pendientes, cerrados), búsqueda, crear plan, card con imagen e iconos; navegación a detalle. Igual que web.
- [x] **Detalle del plan / pestañas:** Info, Mi resumen, Calendario, Participantes, Estadísticas, Pagos, Chat. **Paridad:** Las 7 pestañas existen en iOS con las mismas pantallas (PlanDataScreen, MyPlanSummaryScreen, CalendarMobilePage, Participants, Chat, Stats, Payments).
- [x] **Calendario:** Crear/editar evento, arrastrar, ver alojamientos, tracks. **Paridad funcional:** CalendarMobilePage tiene tracks, eventos, alojamientos y diálogos; vista adaptada a 1–3 días.
- [x] **Notificaciones e invitaciones:** Aceptar/rechazar, navegación tras aceptar. **Paridad + 1 pendiente:** Tras aceptar en móvil ya se navega a `PlanDetailPage(plan)`. Pendiente: deep link (Universal Links o URL scheme) para abrir app desde link.
- [x] **Perfil y ajustes:** **Paridad:** Perfil accesible desde barra inferior en iOS; misma ProfilePage (edición, idioma, zona horaria, eliminar cuenta).
- [x] **Multi-idioma:** **OK.** PlansListPage e InvitationPage usan solo AppLocalizations. Sustituidos en InvitationPage todos los textos visibles (header, detalles del plan, aviso email incorrecto, fecha expiración) por claves ES/EN.
- [x] **Safe area y navegación:** **OK:** PlansListPage y PlanDetailPage usan SafeArea. Barra de pestañas: 7 opciones; en iPhone pequeño puede hacer falta scroll (prueba manual pendiente).
- [x] **Consistencia visual:** **OK:** Cards, iconos naranja para no leídos, estilo ancho completo y bordes aplicado en web e iOS.

---

## Pendientes prioritarios (tras rellenar checklist)

- ~~**Multi-idioma:**~~ Hecho (InvitationPage y PlansListPage usan solo AppLocalizations).
- ~~**FCM / Info.plist (UIBackgroundModes):**~~ Hecho: añadido `remote-notification` en `ios/Runner/Info.plist`. Pendiente: comprobar GoogleService-Info.plist y APNs en Firebase.
- ~~**Descripciones cámara/fotos:**~~ Hecho: añadidos `NSPhotoLibraryUsageDescription` y `NSCameraUsageDescription` en Info.plist.
- **Deep link:** Decidir e implementar Universal Links o URL scheme para invitaciones (abrir app desde link).
- **Prueba manual:** Barra de pestañas del plan en iPhone pequeño (SE).

---

## Entregables

1. `docs/configuracion/REVISION_IOS_VS_WEB.md` actualizado con estado por sección y checklist de paridad (tabla §3 y §3b).
2. Lista de incidencias cerradas o pendientes en la tabla §3 (pre–TestFlight) y en este documento.
3. Si se detectan bugs o huecos solo en iOS, priorizarlos y, si aplica, crear ítems en TASKS.md o anotarlos en esta tarea.

---

## Referencias

- `docs/configuracion/REVISION_IOS_VS_WEB.md` – Problemas y mejoras ya detectadas (multi-idioma, invitación, deep links, Safe area, barra pestañas).
- `docs/configuracion/CONTEXT.md` – Norma de consistencia web e iOS en todos los cambios.
