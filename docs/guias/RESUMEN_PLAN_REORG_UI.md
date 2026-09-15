# Reorganización UI — Resumen del plan

**Estado:** acordado para implementación (2026-09-13)  
**Demo de evaluación:** `/demo/my-summary-reorg` (hub UI Review → «Resumen reorg (nuevo)»)  
**Pantalla producción:** plan → pestaña resumen (`MyPlanSummaryScreen` + shell móvil `PlanDetailPage` / web dashboard)

## Filosofía

- **resumen** = revisar y actuar  
- **agenda** = planificar y modificar  
- No convertir el resumen en una segunda agenda ni en edición compleja.  
- Reorganizar jerarquía; **no** rediseñar el design system (colores, tipografía, iconos, tokens `IosFormColors` / `AppColorScheme`).

## Decisiones cerradas (chat 2026-09-13)

| Tema | Decisión |
|------|---------|
| Notas y stats | Fuera de la nav de 5; viven en **info** del plan |
| Gastos | Mantienen peso en pestaña **pagos** |
| Barra inferior | Solo utilidades: **buscar · chat · notificaciones** |
| Crear | Botón **+** en fila de fecha (evento / alojamiento); no en barra inferior |
| Cabecera demo | Cover obligatoria; sin compartir ni menú ⋯ |
| Cabecera prod | Usar `plan.imageUrl` si existe; si no, fallback corporativo existente (`PlanCoverImage` / placeholder) |
| Filtro categorías | Sheet con familias canónicas + alojamiento; chip **filtrar** activo cuando hay filtro |
| Plataforma | Móvil + web (misma jerarquía; web sin forzar marco teléfono) |
| Minúsculas | Solo controles de esta pantalla (nav, mío/todos, filtrar, buscar…); section labels del sistema intactas |
| Datos demo | Mock fijo Cotswolds |

## Estructura vertical

1. Cabecera visual del plan (imagen + ← nombre · fechas · estado in/out/pendiente)  
2. Nav 5: **info · resumen · agenda · personas · pagos** (icono + texto)  
3. **mío \| todos** + **filtrar** (categorías)  
4. Selector horizontal de días (un día a la vez; marcar **hoy**)  
5. Fila fecha completa + **mapa** + **+**  
6. Cronología del día (evento actual reforzado si plan en curso)  
7. **esta noche · [hotel]** al final cuando corresponda  
8. Barra inferior fija: buscar + chat + notificaciones  

## Expressamente descartado

- Tarjeta «ahora / siguiente» independiente  
- FAB sueltos de mapa / crear  
- Chat y notificaciones en nav superior  
- Título redundante «mi resumen»  
- Menú ⋯ en cabecera  
- Nuevas paletas / tipografías / iconotecas  

## Criterios de look (demo validados)

- Evento actual (plan en curso): anillo en el punto de timeline + card acentuada + pastilla de icono `color2` + etiqueta «ahora»  
- Pasados atenuados; futuros con punto hueco / línea más suave  
- Swipe horizontal entre días  
- Empty state de día sin eventos  
- Cabecera compacta al scroll: fondo agrupado + borde acento + nombre + estado  

## Implementación producción — estado (2026-09-13)

Hecho en código:
- Nav 5 (móvil + web dashboard)
- Barra inferior móvil: buscar · chat · notificaciones
- Resumen un-día (chips, swipe, mapa/+, esta noche)
- Timeline del día alineada a la demo (`wd_plan_summary_timeline.dart`): rail hora + puntos + cards + pastilla icono + «ahora»
- Sin título «mi resumen» en la sección
- Cabecera cover colapsable en pestaña resumen (móvil): `PlanCollapsingHeader` (altura 107.52)
- Notas / stats accesibles desde Info (sección «Más»; stats solo organizador)
- Acceso web a chat/avisos: utilidades a la derecha de la nav de 5 (`WdDashboardNavTabs.utilityTabs`; W13 = búsqueda de planes en lista)
- Buscar en el plan: móvil barra inferior; web utilidad **buscar** (sheet eventos + alojamientos)
- Filtrar por categorías en resumen (familias + alojamiento)
- **Entrada al plan:** al seleccionar un plan (lista móvil / W28 web) se abre la pestaña **resumen** (`mySummary`), no Info ni agenda
- **Agenda por defecto:** vista **Mi agenda** (track del usuario actual); Plan completo / Personalizada en el selector de vista
- **Vista personalizada:** nombres reales (`planParticipantDisplayNamesProvider`) + Seleccionar/Deseleccionar todos

Aplazado:
- ~~Buscar / filtrar reales~~ → hecho
- ~~Entradas notas/stats dentro de Info~~ → hecho (sección «Más» en Info)
- ~~Acceso web a chat/notif~~ → hecho (utilidades W19/W20 en fila nav)
- ~~Timeline visual demo → prod~~ → hecho

## Implementación producción — notas

- **No** reescribir lógica de negocio (providers, Firestore, permisos).  
- Reutilizar filas / acciones de `wd_my_plan_summary_screen.dart` y `PlanCoverImage`.  
- IDs de pestaña internos pueden mantenerse (`planData`, `mySummary`, `calendar`, …); las **etiquetas** visibles van en minúsculas (agenda = calendario).  
- Al abrir un plan: `PlanDetailPage` / dashboard → `mySummary` por defecto (pending preview → Info).  
- Agenda: `CalendarViewMode.personal` por defecto (`wd_calendar_screen` / `pg_calendar_mobile_page`).  
- Acceso a chat/notif: móvil → barra inferior; web → utilidades a la derecha de la nav (mismas pantallas/`W19`/`W20`).  
- Buscar en el plan: móvil → campo de la barra inferior; web → utilidad **buscar** (`planInSearch`).  
- Notas / stats: enlaces o secciones dentro de Info (no reintroducir tabs arriba).  
- Filtro por categorías: sheet desde chip **filtrar** del resumen.  
- Mapa y **+** crear: solo en la fila de fecha del resumen (no duplicar mapa en la barra mío/todos).  

## Referencias

- Spec consolidada del usuario (documento largo «Planoon — Especificación de reorganización UI»)  
- Demo: `lib/features/auth/presentation/pages/my_summary_reorg_demo_page.dart`  
- Guía visual: `docs/guias/GUIA_UI.md` § Mi resumen / itinerario  
