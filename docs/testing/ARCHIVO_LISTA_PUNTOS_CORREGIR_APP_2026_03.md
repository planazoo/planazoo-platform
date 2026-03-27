# Archivo — Lista de puntos corregidos (cerrados)

**Este documento es solo histórico.** Puedes borrarlo cuando ya no lo necesites.

- **Origen:** volcado desde `LISTA_PUNTOS_CORREGIR_APP.md` el **2026-03-12**.  
- **Contenido:** puntos **P3–P20** cerrados (incl. **P3** y **P12** marcados hechos en esa fecha).  
- **Pendiente de infra:** **P1** y **P2** no se archivaron aquí; siguen en **`ACCIONES_PENDIENTES_APP.md`**.

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
