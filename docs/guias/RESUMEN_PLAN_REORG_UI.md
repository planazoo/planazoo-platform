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
| Filtro categorías | Aparcar panel real; chip **filtrar** estático de momento |
| Plataforma | Móvil + web (misma jerarquía; web sin forzar marco teléfono) |
| Minúsculas | Solo controles de esta pantalla (nav, mío/todos, filtrar, buscar…); section labels del sistema intactas |
| Datos demo | Mock fijo Cotswolds |

## Estructura vertical

1. Cabecera visual del plan (imagen + ← nombre · fechas · estado in/out/pendiente)  
2. Nav 5: **info · resumen · agenda · personas · pagos** (icono + texto)  
3. **mío \| todos** + **filtrar** (stub)  
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
- Barra inferior móvil: buscar stub · chat · notificaciones
- Resumen un-día (chips, swipe, mapa/+, esta noche, acento evento actual en `en_curso`)
- Sin título «mi resumen» en la sección
- Cabecera cover colapsable en pestaña resumen (móvil): `PlanCollapsingHeader`

Aplazado:
- Buscar / filtrar reales
- Entradas notas/stats dentro de Info
- Acceso web a chat/notif (sin bottom bar)
- ~~Cabecera con cover colapsable~~ → hecho en móvil resumen (`PlanCollapsingHeader` + `NestedScrollView`)

## Implementación producción — notas

- **No** reescribir lógica de negocio (providers, Firestore, permisos).  
- Reutilizar filas / acciones de `wd_my_plan_summary_screen.dart` y `PlanCoverImage`.  
- IDs de pestaña internos pueden mantenerse (`planData`, `mySummary`, `calendar`, …); las **etiquetas** visibles van en minúsculas (agenda = calendario).  
- Acceso a chat/notif: barra inferior (mismas acciones que antes).  
- Notas / stats: enlaces o secciones dentro de Info (no reintroducir tabs arriba).  
- Filtro por categorías: fuera del alcance inicial (chip stub).  

## Referencias

- Spec consolidada del usuario (documento largo «Planoon — Especificación de reorganización UI»)  
- Demo: `lib/features/auth/presentation/pages/my_summary_reorg_demo_page.dart`  
- Guía visual: `docs/guias/GUIA_UI.md` § Mi resumen / itinerario  
