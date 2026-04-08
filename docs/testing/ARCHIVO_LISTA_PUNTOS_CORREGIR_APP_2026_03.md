# Archivo — Lista de puntos corregidos (cerrados)

**Este documento es solo histórico.** Puedes borrarlo cuando ya no lo necesites.

- **Origen:** volcado desde `LISTA_PUNTOS_CORREGIR_APP.md` el **2026-03-12**.  
- **Contenido:** puntos **P3–P20** cerrados (incl. **P3** y **P12** marcados hechos en esa fecha).  
- **Pendiente de infra:** **P1** y **P2** no se archivaron aquí; siguen en **`ACCIONES_PENDIENTES_APP.md`**.
- **Actualización:** el **2026-04-06** se movió aquí el bloque histórico residual de puntos **1-33** (agrupación y progreso) para limpiar la lista viva.

---

## Tabla resumen (estado al archivar)

| ID | Plataforma | Pantalla / flujo | Tipo | Gravedad | Descripción breve | Estado |
|----|------------|------------------|------|----------|-------------------|--------|
| 3 | iOS | Barra de pestañas del plan | mejora UX | baja | Revisar barra en iPhone pequeño (scroll, legibilidad) | hecho |
| 4 | iOS | Crear plan / volver | bug | alta | Tras crear plan, atrás dejaba pantalla en blanco | hecho |
| 5 | iOS | Estado inicial del plan | bug | media | Estado por defecto no “Planificando” | hecho |
| 6 | iOS | Cambio de estado del plan | mejora UX | media | Cambiar estado desde icono en Info | hecho |
| 7 | iOS | Calendario – scroll | bug / rendimiento | alta | Scroll vertical muy lento | hecho |
| 8 | iOS | Card de plan – iconos | mejora UX | media | Iconos derecha alineados verticalmente | hecho |
| 9 | iOS | Info plan – títulos campos | mejora visual | baja | Tamaño títulos recuadro Info | hecho |
| 10 | iOS | Eliminar plan | mejora funcional | media | Opción visible eliminar en Info | hecho |
| 11 | iOS | Info plan – participantes | mejora visual | baja | “Participantes” en título del recuadro | hecho |
| 12 | iOS | Secciones Info expansibles | mejora UX | media | Participantes, Avisos, Zona de peligro plegables | hecho |
| 13 | iOS | Formulario evento – UI | mejora UX | media | Unificar UI de campos | hecho |
| 14 | iOS | Eventos → refresco vistas | bug | alta | Refresco calendario/resumen al CRUD evento | hecho |
| 15 | iOS | Participantes – barra superior | mejora UX | baja | Barra verde con título | hecho |
| 16 | iOS | Chat y Pagos – navegación | mejora UX | baja | Quitar flecha que sacaba del plan | hecho |
| 17 | iOS | Orden de pestañas | mejora UX | baja | Pagos entre Chat y Estadística | hecho |
| 18 | iOS / Web | Estado personal en el plan | mejora funcional | media | pending / in / out; copy y ayuda | hecho |
| 19 | iOS | Form evento – tipo/subtipo | bug / UX | media | Tipo visible al elegir subtipo | hecho |
| 20 | iOS | Form evento – fecha/hora/duración | mejora UX | media | Formato claro fecha/hora/duración | hecho |

**Referencia extra (fuera de tabla):** manual `/help`, pestaña notificaciones del plan, accesos rápidos en `PlanDetailPage`, notificaciones leídas/no leídas, iconos en Mi resumen; ver `CONTEXT.md`, `CALENDAR_CAPABILITIES.md`.

---

## Detalle por punto (copia de la lista al archivar)

### P3. Barra de pestañas del plan en iPhone pequeño

- **Descripción:** En iPhones pequeños, muchas pestañas en `PlanDetailPage` pueden apretar la barra.
- **Estado:** **hecho** (cierre 2026-03-12).

### P4. Crear plan y volver deja pantalla en blanco

- **Solución:** `PlanDetailPage`: back con `Navigator.pop()` o `pushReplacement` a `PlansListPage` si `canPop == false`.

### P5. Estado inicial = Planificando

- **Solución:** Creación con `state: 'planificando'`; `Plan` y `PlanStateService` normalizan legacy/nulos.

### P6. Cambio de estado desde icono en Info

- **Solución:** `wd_plan_data_screen.dart` — `_openPlanStateTransitionMenu`, menú anclado al badge.

### P7. Scroll calendario lento

- **Solución:** `CalendarMobilePage` — sincronización scroll controllers, `_isAutoScrolling`, sin `setState` agresivo en listeners.

### P8. Iconos card de plan

- **Solución:** `wd_plan_card_widget.dart` / lista iOS — columna acciones con espaciado.

### P9. Títulos Info del plan

- **Solución:** `wd_plan_data_screen.dart` — labels ~14px.

### P10. Eliminar plan visible

- **Solución:** Zona de peligro arriba en móvil embebido (`showAppBar: false`).

### P11. Participantes en Info

- **Solución:** Título dentro del card en `wd_plan_data_screen.dart`.

### P12. Secciones Participantes / Avisos / Zona de peligro expansibles

- **Descripción:** Reducir ruido con bloques plegables.
- **Estado:** **hecho** (cierre 2026-03-12).

### P13. Formulario evento – UI unificada

- **Solución:** `wd_event_dialog.dart` — timezones y campos alineados al patrón “título sobre borde”.

### P14. Refresco tras eventos

- **Solución:** `CalendarMobilePage` — `_invalidateEventProviders()` en guardado/borrado.

### P15. Barra superior Participantes

- **Solución:** `ParticipantsScreen` — header verde en compact embebido.

### P16. Chat / Pagos sin flecha incorrecta

- **Solución:** `embedInPlanDetail` + `automaticallyImplyLeading: false` donde aplica.

### P17. Orden pestañas Pagos

- **Solución:** `wd_plan_navigation_bar.dart` — orden Info … Chat, Pagos, Stats, Notificaciones.

### P18. Estado personal en el plan

- **Solución:** `plan_status_chip_actions.dart`, chips, ayuda, SnackBar rechazo; doc `ESTADO_USUARIO_EN_EL_PLAN.md`.

### P19. Tipo / subtipo evento

- **Solución:** `wd_event_dialog.dart` — `Wrap` en selector colapsado.

### P20. Fecha / hora / duración

- **Solución:** `DateFormatter.formatTimeOnly`, `_formatDuration` + l10n duración.

---

## Anexo (movido desde la lista viva el 2026-04-06)

### Puntos 22-3-2026 — agrupación por zona (prioridad iOS)

| Zona | IDs | Notas |
|------|-----|--------|
| **Info del plan** (`wd_plan_data_screen` y relacionados) | 1, 4, 10, 11, 20, 24 | Incluye modal eliminar, guardar/cancelar, descripción, docs (9 solo diseño) |
| **Resumen del plan / Mi resumen** | 2, 27, 28 | Lista participantes, separadores día, borradores |
| **Formulario y modal de eventos** | 3, 14-17, 19, 21-23, 26, 30, 32, 33 | Tipos/subtipos, timezone vuelos, duración, texto largo, localizaciones |
| **Calendario web** | 13, 16, 18 (opinión), 29 | FAB, modal que no se cierra al click fuera, vista días |
| **Lista de planes / vista calendario iOS** | 8 | Calendario en iOS |
| **Login** | 6 | Snackbars error/info |
| **Perfil iOS** | 5 | Tamaño userid en AppBar |
| **Administrador** | 7 | Huérfanos Firestore |
| **Invitaciones / participantes** | 12 | Añadir sin invitar, asignar antes de invitar |
| **Catálogo tipos de evento / alojamiento** | 25, 31 | Crucero, ancho cards |
| **UX transversal** | 9 | Anexar documentos (solo conversación) |

**Progreso (implementado en código, 2026-03-12 ronda amplia):**

| Punto | Qué se hizo |
|-------|-------------|
| **1, 4, 6** | (ronda anterior) Secciones plegadas, iconos, “Eliminar plan”, modal eliminar con tema, snackbar login. |
| **2** | Mi resumen: sección **Participantes** con `ParticipantsListWidget` (compacto, sin acciones); **todas las secciones plegadas por defecto** (`_importantExpanded`, hoy/mañana, participantes, cronológico). |
| **3** | Form evento: `hasSubtype` por texto de subtipo (no solo si está en la lista de subtipos) para que tipo + subtipo sigan visibles. |
| **5** | Perfil: usuario en cabecera con `mediumTitle` 16px, `Flexible` + ellipsis (ya no `largeTitle` 32px). |
| **7** | Admin: tarjeta **“Registros huérfanos”** -> `PlanParticipationService.auditParticipations(deleteOrphans: false)` + resultado. |
| **8** | Lista de planes (móvil): **toggle lista / calendario** con `PlanCalendarView` y apertura de `PlanDetailPage`. |
| **10** | Info plan: botones Guardar/Cancelar más visibles (`color3`, padding); **PopScope** + diálogo al salir con cambios; back llama a confirmación. |
| **11** | Descripción: botón **ampliar** (`Icons.open_in_full`) abre modal de edición larga. |
| **13** | Web calendario: **FAB** `+` (solo `kIsWeb` y si el plan permite crear eventos). *Defaults al pulsar FAB:* ver **ítem 94** §3.2 (`NewEventFromButtonDefaults`: **en_curso** = ahora; otro estado = día en rango + 10:00). |
| **16** | `EventDialog`: `barrierDismissible: false` en `showDialog` (plan detalle, calendario web/móvil, dashboard). |
| **20** | Campo Firestore `referenceNotes` en `Plan` + formulario “Notas y referencias del plan” en Info. |
| **21** | Nuevo evento: hasta elegir tipo válido solo selector + hint; pestaña General oculta el resto; validación al guardar sin tipo. |
| **24** | Al cargar plan en evento nuevo, **timezone por defecto** = `plan.timezone` (salida y llegada). |
| **15** | Evento vuelo: al seleccionar origen/destino con Places, se intenta **autocalcular timezone** por coordenadas (normalizada a la lista común del selector). |
| **25** | Alojamiento: tipo **Crucero** en desplegable. |
| **26** | Evento: campo **Notas largas** (`commonPart.notes`, hasta 8000 chars sanitizado). |
| **27** | Resumen cronológico: **línea fina** entre días distintos. |
| **28** | Resumen: chip **“Borrador”** si `isDraft` o `commonPart.isDraft`. |
| **29** | Calendario: menú opciones -> **“Todos los días del plan”** (hasta `maxVisibleDays` 45); `calendar_constants` actualizado. |
| **30** | Subtipo **Tour** en Actividad. |
| **31** | Ancho de tarjeta de evento: ~**94%** de subcolumna (`_calculateEventPosition`). |
| **32** | Subtipos **Shuttle** y **Transfer** en Desplazamiento. |
| **23** | Nueva familia **Acción** (Embarque, Recogida, Entrega, Otro) con iconos. |

**Sin código / pendiente / solo diseño:** **9** (documentos en descripción), **12**, **14-15**, **17-19**, **22**, **33**; **18** opinión UX modal vs página.
