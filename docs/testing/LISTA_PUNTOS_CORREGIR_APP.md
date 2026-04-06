## Lista de puntos a corregir en la app

**Objetivo:** un único sitio para **nuevos** hallazgos en pruebas (bugs, UX, copy, iOS/web).

**Última limpieza:** 2026-03-12 — ítems cerrados **P3–P20** archivados; acciones abiertas **P1/P2 (infra)** en [`ACCIONES_PENDIENTES_APP.md`](./ACCIONES_PENDIENTES_APP.md). Histórico: [`ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_03.md`](./ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_03.md) *(borrable cuando no haga falta).* **Backlog:** §3.1 **2026-03-24** (IDs **34–61**); §3.2 **2026-03-27** pruebas **iOS** (IDs **62–109**).

---

### 1. Información del build (rellenar en cada ronda)

- **Versión de la app**: 
- **Origen**: TestFlight / Web / Android / …
- **Fecha de la ronda de pruebas**: 
- **Build ID (si aplica)**: 

---

### 2. Cómo anotar cada punto

Para cada tema nuevo:

- **ID**: número secuencial (siguiente libre **110** tras §3.2; el histórico en archivo llegó hasta **20**, §3.1 usa **34–61**). **No confundir** con códigos **Txxx** de `docs/tareas/TASKS.md` (p. ej. ítem **94** aquí ≠ **T94** allí).
- **Plataforma**: iOS / Web / Ambas / …
- **Pantalla / flujo**: (ej. Lista de planes, Detalle → Calendario, …)
- **Tipo**: bug / mejora / copy
- **Gravedad**: alta / media / baja
- **Descripción breve**: una línea.
- **Pasos para reproducir** (opcional pero recomendable).
- **Resultado esperado** / **resultado real**.
- **Estado**: pendiente → en curso → hecho (o mover a archivo al cerrar si quieres historial).

---

### 3. Puntos detectados

| ID | Plataforma | Pantalla / flujo | Tipo | Gravedad | Descripción breve | Estado |
|----|------------|------------------|------|----------|---------------------|--------|
| — | | | | | *Filas detalladas en §3.1 (34–61), §3.2 (62–109) y histórico/archivo.* | |

**Resumen:** *actualizar a mano:* pendiente **·** en curso **·** hecho **.**

### 3.1 Ronda 2026-03-24 — nuevos hallazgos (IDs 34–61)

**Orden sugerido para implementar** (mismo archivo / dependencias juntos; ajustar si una rama bloquea otra):

| Paso | IDs | Bloque | Por qué este orden |
|------|-----|--------|---------------------|
| 1 | **57** | Barra superior (nombre plan) | Cambio localizado; baja riesgo. |
| 2 | **34** | Chat iOS | Aislado (badge no leídos). |
| 3 | **35–38** | Info del plan | Misma pantilla/formulario; cerrar duplicados iOS antes de pulir copy. |
| 4 | **51–56** | Calendario | Constantes/vista días; base visual antes de refinar textos en celdas. |
| 5 | **45–50** | Formulario evento + modelo/datos | Timezone, localización, participantes, “mi información”, número vuelo/tren persistido (afecta calendario y resumen). |
| 6 | **39–44** | Resumen del plan | UI + FAB/CRUD/refresh; conviene tras datos de evento (p. ej. 50) si el resumen muestra vuelo/tren. |
| 7 | **59–60** | Resumen pagos / bote | Pantallas de pagos. |
| 8 | **61** | Participantes | Lista/invitaciones. |
| 9 | **58** | General | Verificación **offline first** (manual/QA; no codifica comportamiento hasta confirmar). |

| ID | Plataforma | Pantalla / flujo | Tipo | Gravedad | Descripción breve | Estado |
|----|------------|------------------|------|----------|---------------------|--------|
| 34 | iOS | Chat / badge no leídos | bug | media | Al leer el chat, el icono de “no leído” no se actualiza. | hecho (2026-03-24: `markAll` vía `ChatService` directo; `FutureProvider` cacheaba y no re-ejecutaba) |
| 35 | Ambas | Info del plan | mejora | media | Revisar **orden** de campos y dejar **espacio** entre campos. | hecho (2026-03-24: más aire entre bloques `cardSpacing` 28; nombre/desc/notas) |
| 36 | Ambas | Info del plan → descripción | mejora | media | Descripción a **ancho completo**; control “ampliar” **dentro** del campo (p. ej. esquina superior derecha), no botón aparte. | hecho (2026-03-24: `Stack` + `IconButton` esquina sup. dcha, padding derecho al texto) |
| 37 | iOS | Info del plan | bug | media | Hay **dos** secciones “Eliminar plan”; dejar **solo** la del **final** del formulario. | hecho (2026-03-24: eliminado duplicado cuando `showAppBar: false`) |
| 38 | Ambas | Info del plan → Avisos | mejora | media | Sección **Avisos** solo visible para **admin**. | hecho (2026-03-24: solo organizador `isOrganizer`) |
| 39 | Ambas | Resumen del plan | mejora | baja | Aumentar un poco el **tamaño de texto** general. | hecho (2026-03-24: tipografías de cabecera, subtítulos, enlaces y cronológico subidas en `MyPlanSummaryScreen`) |
| 40 | Ambas | Resumen del plan → evento | mejora | baja | Quitar **icono** de acceso al evento si el acceso ya va por **texto enlazado**. | hecho (2026-03-24: eliminado icono `open_in_new`; acceso queda en texto clicable) |
| 41 | Ambas | Resumen → “Mis vuelos” | copy | baja | No mostrar el texto **“Eventos de tipo avión”** (u equivalente). | hecho (2026-03-24: eliminado `myPlanSummaryFlightsHint`) |
| 42 | Ambas | Resumen (links web / mapa) | mejora | media | Iconos más **grandes** y visibles: enlace con estilo **“www”**; mapas con **marcador de ubicación**. | hecho (2026-03-24: chips grandes `www` y marcador en filas de resumen + cronológico) |
| 43 | Ambas | Resumen (itinerario / vuelos / alojamientos) | mejora | media | Secciones **expandibles** **sin** recuadro/enmarcado. | hecho (2026-03-24: secciones expandibles con modo `framed: false`) |
| 44 | Ambas | Resumen del plan | feature | alta | **FAB “+”** para crear evento o alojamiento desde resumen; **no** navegar al calendario al usar “+” / crear alojamiento en **barra inferior** si ya estamos en resumen; tras **crear/editar/borrar** evento o alojamiento desde resumen, **refrescar** la pantalla de resumen. **Criterio:** mismo flujo que en calendario (mismos modales/diálogos); solo evitar el salto de pestaña. | hecho (2026-03-24: FAB de alta rápida en resumen + persistencia create/update y refresco con invalidación de providers sin salto de pestaña) |
| 45 | Ambas | Evento (no desplazamiento) | mejora | media | Campo **hora**: selector de **timezone** con el **mismo patrón** que aeropuerto de salida (vuelos). | hecho (2026-03-25: selector rápido con chip/círculo de zona horaria en eventos no desplazamiento, reutilizando picker de vuelos) |
| 46 | Ambas | Evento → localización | mejora | media | Localización a **ancho completo**, estética estándar; **solo** icono **marcador**; sin otros iconos extra. | hecho (2026-03-25: campo único de localización a ancho completo + acceso Maps con icono marcador) |
| 47 | Ambas | Evento → participantes | mejora + tarea | media | Mover **límite de participantes** y **requiere confirmación** al **final** del formulario. **Acción aparte:** revisar **lógica de participantes** (coherencia con reglas del plan). | en curso (2026-03-25: reubicados al final del formulario; queda pendiente la revisión funcional profunda de reglas) |
| 48 | Ambas | Evento | mejora | media | **“Este evento es para todos los participantes”** debajo de **Notas largas**. **Moneda + coste** en **una línea**, debajo de ese selector. | hecho (2026-03-25: selector movido bajo notas largas y fila única moneda+coste justo debajo) |
| 49 | Ambas | Evento → “Mi información” | feature | media | Contenido según **tipo de evento** (p. ej. actividad: **código o archivo** de entrada). | hecho (2026-03-25: Actividad muestra `ticketCode` + `ticketDocUrl` en Mi información; persistidos en `EventPersonalPart.fields`) |
| 50 | Ambas | Evento / calendario / resumen | bug/mejora | media | **Número de vuelo, tren, etc.:** persistir y mostrar en **vista calendario** y **vista resumen**. | hecho (2026-03-24: persistencia en `extraData.flightNumber` desde `EventDialog`; render en resumen y título de tarjetas en calendario web/móvil) |
| 51 | iOS | Calendario | mejora | media | Abrir por defecto vista **3 días**. | hecho (2026-03-24: `PlanDetailPage` + `CalendarMobilePage` con `defaultTargetPlatform == iOS`) |
| 52 | Ambas | Calendario | mejora | media | Columnas de días con fondos **intercalados** (claro/oscuro) incl. **cabeceras** para separar días. | hecho (2026-03-24: `CalendarTracks` + rejilla `pg_calendar_mobile_page`) |
| 53 | Ambas | Calendario | QA | media | **Probar scroll horizontal** (regresión). | pendiente (manual; layout sin cambio estructural) |
| 54 | Ambas | Calendario → cabeceras | mejora | baja | **Línea superior e inferior** en la fila de encabezados de días. | hecho (2026-03-24: borde sup/inf cabecera + columna horas en `CalendarTracks` / `calendar_grid`) |
| 55 | Ambas | Calendario | mejora | baja | Reducir ~**10%** la altura de la **fila de horas** (slot). | hecho (2026-03-24: `AppConstants.cellHeight` 50→45, `eventRowHeight` 60→54) |
| 56 | Ambas | Calendario → celdas evento | mejora | media | Eventos **&lt; 45 min**: mostrar **solo el título** (sin texto extra que no quepa). | hecho (2026-03-24: `CalendarConstants.shortEventTitleOnlyMaxMinutes` + móvil y `wd_calendar_screen`) |
| 57 | Ambas | Barra superior global | mejora | baja | Reducir tamaño de fuente del **nombre del plan** en AppBar. | hecho (2026-03-24: `PlanDetailPage` título 18→16 px) |
| 58 | Ambas | App / datos | verificación | ? | **Confirmar si offline first funciona** (comportamiento esperado + casos de prueba). Persistencia Firestore no desactivada en código; falta QA en dispositivo. | pendiente |
| 59 | Ambas | Resumen pagos → registrar pago | mejora | media | Formulario **registrar pago** alineado con **UI estándar** de la app. | hecho (2026-04-04: `PaymentDialog` — mismos patrones que `AddExpenseDialog`, l10n, `FilledButton`, fechas con etiqueta, métodos de pago por id + legacy) |
| 60 | Ambas | Resumen pagos → bote común | bug | media | Campos **desalineados**; contenido se **sale por la derecha**. | hecho (2026-03-25: `KittyContributionDialog`/`KittyExpenseDialog` eliminar `width: 400` rígido y usar `maxWidth` responsivo) |
| 61 | Ambas | Participantes | mejora | media | Diferenciar más claro **quienes ya participan** vs **zona de invitación**; lista de **usuarios registrados** más visible. | hecho (2026-03-25: `pg_plan_participants_page` añade sección “Invitaciones pendientes” usando `pendingInvitationsProvider`) |

**Agrupación rápida por zona (misma tabla 34–61):** Chat **34** · Info plan **35–38** · Resumen **39–44** · Eventos **45–50** · Calendario **51–56** · General **57–58** · Pagos **59–60** · Participantes **61**.

---

### 3.2 Ronda 2026-03-27 — pruebas en **iOS** (IDs 62–109)

**Origen:** feedback tras uso en dispositivo. **Prioridad de implementación:** iOS; en la columna *Web / notas* se indica si conviene **paridad web** (misma UX), **adaptar** (densidad/desktop) o **solo iOS**.

**Cómo leer duplicados / conflictos con §3.1**

| Relación | Detalle |
|----------|---------|
| **58** (offline) | El feedback **65** refuerza la necesidad de **offline first real**; mantener **58** como verificación hasta tener plan técnico (T56–T62, `CONTEXT.md`). |
| **44** (FAB resumen) | **79** proponía quitar el FAB; **decisión 2026-03-27:** **mantener** el FAB de momento (coherente con **44** hecho). Revisar de nuevo solo si se adopta el rediseño de barras (**64**). |
| **48** (selector participantes) | **91** indica **regresión o desalineación** visual tras cambios; revisar de nuevo el bloque del selector. |
| **39–43** (resumen hecho) | Varios ítems **69–88** **refinan de nuevo** Mi resumen (layout, copy, modales). No borran el histórico; son iteración UI. |
| **Vuelos vs desplazamientos** | **84** alinea con idea ya en **41** (quitar jerga “tipo avión”); aquí se pide **ampliar sección** a todos los desplazamientos. |

**Documentación ya existente (solo referencia, sin implementar aquí)**

- Publicidad / monetización: [`docs/especificaciones/PATROCINIOS_Y_MONETIZACION.md`](../especificaciones/PATROCINIOS_Y_MONETIZACION.md) (T143; patrocinio contextual, afiliados).
- Notificaciones push móvil: [`docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md`](../configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md), [`docs/testing/ACCIONES_PENDIENTES_APP.md`](./ACCIONES_PENDIENTES_APP.md), tareas/notificaciones en `TASKS.md`.
- Tipos/subtipos evento: [`docs/especificaciones/EVENT_FORM_FIELDS.md`](../especificaciones/EVENT_FORM_FIELDS.md), [`docs/tareas/T250`](../tareas/TASKS.md) (matriz tipo/subtipo).
- Icono app: [`docs/tareas/T258_ICONO_APP.md`](../tareas/T258_ICONO_APP.md) — **63** encaja como brief creativo adicional.

**Ítems solo para hablar (no codificar aún)**

- **64** — Rediseño barras inferiores + FAB (unificar, FAB rojo `+` central, menú por contexto + “Otros…”).
- **66** — Recogida/entrega **vehículo alquiler** (coche/moto/bici): modelo de datos, documentación del contrato, ¿evento tipo Acción/Desplazamiento? — enlazar con **95** y EVENT_FORM_FIELDS.
- **98** — **Asistente “inteligente”** (reglas: vuelo→¿taxi?, estado plan vs fechas, etc.): producto/epic; posible base transversal, no paralelo; IA futura opcional.

**Orden sugerido de trabajo** (ajustar según dependencias)

| Paso | IDs | Bloque |
|------|-----|--------|
| A | **89**, **91** | Bugs/regresión evento (doble guardado, layout selector). |
| B | **99**, **100** | Calendario iOS (hoy primero, separador columnas). |
| C | **67** | Transversal campos con clear “×” (widget reutilizable → web + iOS). |
| D | **68** | Info plan (orden nombre/foto). |
| E | **69–88** | Mi resumen / plan completo (gran bloque; subir **74–75** si condiciona el resto). |
| F | **92–97**, **90**, **94–95** | Catálogo eventos / copy subtipos / campos traslado. |
| G | **64** | Rediseño barras/FAB (el **79** quedó **sin aplicar**: se mantiene FAB). |
| H | **101–107**, **106** | Pagos (eliminar bote, Tricount, eventos). |
| I | **62**, **80**, **81**, **82–83** | iOS pulido lista planes + resumen + alojamientos. |
| J | **63**, **108** | Icono app + prueba publicidad estática. |
| K | **65**, **58** | Offline first (especificación + tareas; no código hasta acuerdo). |
| L | **109** | Push notificaciones (infra). |
| — | **64**, **66**, **98** | Reuniones de producto sin código. |

| ID | Plataforma | Pantalla / flujo | Tipo | Gravedad | Descripción breve | Web / notas | Estado |
|----|------------|------------------|------|----------|---------------------|-------------|--------|
| 62 | iOS (→Ambas) | Lista planes W28 / cards | mejora | media | Aumentar tamaño global de la **card** en iOS (referencia visual: **WhatsApp**); iconos derecha actuales OK. | **Web:** revisar densidad y `min` touch en cards compartidas; no tiene que ser idéntico al móvil. | hecho (2026-03-27: `PlanCardWidget` padding y tipografía mayores solo en iOS) |
| 63 | Ambas | Icono app / marca | diseño | baja | Icono que juegue con las **dos “oo”** de Planazoo (conexión): ideas — brújula + meeting point; dos ojos uno guiñando. | Mismo asset todas las plataformas. Ver **T258**. | pendiente |
| 64 | iOS (producto) | Navegación inferior + FAB | discusión | — | **No implementar aún.** Demasiadas barras + FABs crear. Opción a valorar: **unificar** accesos a pantallas + crear; **FAB rojo** con **+** blanco **centrado**; al pulsar menú según pantalla (calendario: evento/alojamiento; pagos: gasto…); entrada **“Otros…”** despliega el resto como hoy. | Si se adopta, **replicar patrón** en web (dock/barra) coherente con `GUIA_UI`. | pendiente (diseño) |
| 65 | Ambas | App / datos | producto | alta | Tras viaje real: **offline first** se percibe **imprescindible**; toda la información debería poder consultarse offline. Opinión técnica antes de codificar: viable con caché local + cola de sync; coste T56–T62. | **Misma necesidad** en web (PWA/caché) con matices; alinear con roadmap Offline. | pendiente |
| 66 | Ambas | Eventos / documentación | discusión | — | **No implementar.** Recogida/entrega **vehículo alquiler** (coche/moto/bici): documentación específica. ¿Qué hay en docs? Propuesta: eventos **Acción** o **Desplazamiento** + subtipos **95** + campos adjuntos/notas; enlazar contrato en Info plan T262/notas. | Igual criterio web/iOS. | pendiente (diseño) |
| 67 | Ambas | Formularios (transversal) | mejora | media | En campos de texto, mostrar **“×”** para **borrar todo** el contenido (patrón estándar). | **Paridad** en web (mismo componente o `suffixIcon`). | hecho (2026-03-27: `text_field_clear_suffix.dart` + login email/contraseña + descripción en `wd_event_dialog`) |
| 68 | Ambas | Info del plan | mejora | baja | Mover campo **Nombre del plan** **encima** del campo/imagen de **foto**. | Paridad. | hecho (2026-03-27: nombre encima de la card foto/estado en `wd_plan_data_screen`) |
| 69 | Ambas | Mi resumen | mejora | media | Plan **en marcha**: eventos **pasados** con **otro color** (distinción temporal clara). | Paridad. | hecho (2026-03-27: plan `en_curso` + `_isEventPast` + estilo atenuado en hoy/mañana, desplazamientos y plan completo) |
| 70 | Ambas | Mi resumen | mejora | media | **Todas las secciones cerradas** por defecto al abrir. *(Si ya aplicado en histórico §4, **verificar** tras rediseños recientes.)* | Paridad. | hecho (2026-03-27: vuelos, alojamientos y plan completo `expanded: false` por defecto en `wd_my_plan_summary_screen`) |
| 71 | Ambas | Mi resumen | copy | baja | Cambiar **“Mi alojamiento”** → **“Mis alojamientos”**. | Paridad; alineado con **77**: título **Alojamientos** en l10n. | hecho (2026-03-27: `myPlanSummaryAccommodation`) |
| 72 | Ambas | Mi resumen / horarios | mejora | media | Eventos que **cruzan medianoche**: revisar cómo se muestran horas; valorar **+1** o etiqueta “día siguiente”. | Paridad; cuidado con timezones. | hecho (2026-03-27: `_formatEventTime` + `myPlanSummaryTimeNextDaySuffix` cuando `totalEndMinutes` ≥ 24h) |
| 73 | iOS | Mi resumen / itinerario | mejora | media | **Alinear** hora con texto e **iconos** en bloque **itinerario completo**. | Web: comprobar si ya alineado; unificar estilo si no. | hecho (2026-03-27: fila cronológica `CrossAxisAlignment.center` + `height` en texto hora) |
| 74 | Ambas | Mi resumen | mejora | media | Reducir bloque **“Lo más importante”** a: **nombre del plan**, **fechas**, **estado**, **n.º participantes**. | Paridad. | hecho (2026-03-27: `_buildImportantBlockContent` + `PlanStateService` + `planRealParticipantsProvider` + l10n `myPlanSummaryParticipantsCount`) |
| 75 | Ambas | Mi resumen | mejora | alta | **Lo más importante**, **Participantes**, **Hoy**, **Mañana** → **cuatro iconos** en **una fila**; tap abre **modal** con el contenido actual. Iconos **Hoy**/**Mañana** = textos “hoy” / “mañana”. | Paridad; accesibilidad y tamaño táctil. | hecho (2026-03-27: `_buildSummaryQuickAccessRow` + `showModalBottomSheet`; hoy/mañana solo si plan en fechas en curso; l10n `myPlanSummaryQuick*`) |
| 76 | Ambas | Mi resumen | copy | baja | **“Mis vuelos”** → **“Vuelos”**. | Paridad. | hecho (2026-03-27: `myPlanSummaryFlights` ES/EN) |
| 77 | Ambas | Mi resumen | copy | baja | **“Mis alojamientos”** → **“Alojamientos”**. | Paridad. | hecho (2026-03-27: `myPlanSummaryAccommodation` ES/EN) |
| 78 | Ambas | Mi resumen / evento | mejora | baja | Si en evento aparece **“Todos”**, mostrarlo en **naranja** (énfasis). | Paridad. | hecho (2026-03-27: subtítulo y plan completo con `subtitleEmphasizeAll` / estilo naranja en `wd_my_plan_summary_screen`) |
| 79 | iOS (→Ambas) | Mi resumen | mejora | media | ~~Eliminar FAB~~ **Decisión 2026-03-27:** **mantener** el FAB de crear en resumen (alineado con **44**). Reabrir solo si **64** unifica creación en otro control. | — | cerrado (decisión producto) |
| 80 | iOS | Mi resumen / barra vista | bug | media | Botones **“Mi resumen”** / **“Resumen todos”** quedan **medio tapados**. Acortar textos a **“mío”** / **“todos”** (mismo criterio visual que chip borrador/confirmado). | Web: revisar si existe solape similar en toolbar. | hecho (2026-03-27: l10n `myPlanSummaryViewMine` / `myPlanSummaryViewPlan` ES/EN cortos) |
| 81 | Ambas | Mi resumen / barra superior | feature | media | Si plan en **planificando** y hay **borradores**, botón en **barra superior** para **filtrar solo borradores**. | Paridad. | hecho (2026-03-27: icono filtro en `_buildSummaryBar` + `_draftOnlyFilter` sobre lista de eventos) |
| 82 | Ambas | Mi resumen / alojamientos | mejora | baja | No mostrar **dirección** en lista; bastante **icono marcador**. | Paridad. | hecho (2026-03-27: dirección quitada del subtítulo en `_buildAccommodationQuickContent`; Maps sigue con `mapsQuery` desde dirección) |
| 83 | Ambas | Mi resumen | mejora | baja | **Igualar tamaño** icono **marcador** y **web**; cambiar **“www”** → **“web”**. | Coherente con **42** (ya tocó iconos); revisar consistencia. | hecho (2026-03-27: chip web = `Icons.public` 22px como marcador; sin texto “www”) |
| 84 | Ambas | Mi resumen | mejora | media | Ampliar **“Mis vuelos”** a **todos los desplazamientos** del plan (no solo avión). | Paridad; renombrar sección coherente con **76**. | hecho (2026-03-27: filtro `typeFamily` desplazamiento + títulos l10n Desplazamientos/Travel) |
| 85 | Ambas | Mi resumen / alojamientos | mejora | baja | En alojamientos: **fechas** y **noches** en **segunda línea**. | Paridad. | hecho (2026-03-27: título = nombre hotel; subtítulo fechas + noches + participantes en `_buildAccommodationQuickContent`) |
| 86 | Ambas | Mi resumen / plan completo | bug | media | Días del itinerario en **inglés** → **idioma usuario** + **nombre día completo** + **año** en fecha. | Paridad (`intl` / locale). | hecho (2026-03-27: `DateFormat.yMMMMEEEEd(Localizations.localeOf(context))` en encabezados de día) |
| 87 | Ambas | Mi resumen | copy | baja | Renombrar **“Itinerario completo”** → **“Plan completo”**. | Paridad l10n. | hecho (2026-03-27: `myPlanSummaryChronological` ES/EN) |
| 88 | Ambas | Mi resumen / plan completo | bug | media | Eventos ordenados por **hora**, no por **orden de creación**. | Paridad. | hecho (2026-03-27: `_compareEventsBySchedule` fecha+hora+`createdAt`+id; lista vuelos ordenada igual) |
| 89 | Ambas | Evento / guardar | bug | alta | Conexión **lenta**: varios taps en **Crear** generan **eventos duplicados**. **Debounce** / deshabilitar botón / idempotencia. | Paridad crítica. | hecho (2026-03-27: `_isSavingEvent` + botón deshabilitado e indicador en `wd_event_dialog`) |
| 90 | Ambas | Evento / traslados | feature | media | Traslados: campos **terminal**, **línea aérea**, **presentación en aeropuerto** (o textos equivalentes). | Paridad; ver T246/T250. | hecho (2026-03-27: Shuttle/Transfer en `wd_event_dialog` + `extraData`; l10n ES/EN) |
| 91 | Ambas | Evento / formulario | bug | media | Selector **“Este evento es para todos los…”** **desfasado** respecto al bloque del selector (regresión tras último cambio). Relacionado con **48**. | Paridad. | hecho (2026-03-27: mismo marco `label on border` + `CheckboxTheme` + l10n `eventDialog*`) |
| 92 | Ambas | Evento / tipo Acción | feature | baja | Nuevo subtipo **“punto de encuentro”**. | Paridad; actualizar EVENT_FORM_FIELDS / catálogo. | hecho (2026-03-27: catálogo + icono en `wd_event_dialog`) |
| 93 | Ambas | Evento / Actividad | feature | baja | Subtipo **“disfrutar hotel”** (o similar) dentro de Actividad. | Paridad. | hecho (2026-03-27: subtipo + icono + `EVENT_FORM_FIELDS`) |
| 94 | Ambas | Evento / crear | mejora | media | **Decisión:** plan **en_curso** → fecha y hora = **ahora** (iOS y web). Otro estado → día civil **dentro del rango del plan** (hoy acotado a inicio/fin) y hora **10:00**. Implementado vía `NewEventFromButtonDefaults.forPlan` (FAB web, FAB móvil, crear desde resumen/detalle). | Celdas del calendario siguen usando el día/hora de la celda. | hecho (2026-03-27) |
| 95 | Ambas | Evento / subtipos | copy | baja | Renombrar subtipo **recogida** → **recogida vehículo alquiler** (o equivalente); **entrega** → **entrega vehículo alquiler**. Alinea con **66**. | Paridad l10n. | hecho (2026-03-27: textos ES en catálogo + normalización al abrir en `wd_event_dialog`) |
| 96 | Ambas | Evento / tipo y subtipo | mejora | media | Mostrar **3 opciones por fila**, orden **alfabético**. | Web: grid responsive; iOS: mismo criterio. | hecho (2026-03-27: `GridView` 3 cols + orden A–Z en `wd_event_dialog`) |
| 97 | Ambas | Evento / Acción | feature | baja | Dos subtipos nuevos: **inicio viaje**, **fin viaje**. | Paridad. | hecho (2026-03-27: catálogo + iconos en `wd_event_dialog`) |
| 98 | Ambas | Producto / asistente | epic | — | **No implementar aún.** Sistema de **sugerencias** (vuelo→taxi, estado plan vs fechas reales, etc.) por **reglas**; IA opcional futuro. Integrar como **principio** de producto, no módulo aislado. | Misma visión todas las plataformas. | pendiente (diseño) |
| 99 | iOS (→Ambas) | Calendario | mejora | media | Al abrir, **primer día visible = hoy** (no solo default 3 días sin anclar a hoy). | Web: mismo criterio de viewport inicial. | hecho (2026-03-27: `Plan.initialVisiblePlanDayIndex` + ventana por índice 1-based en móvil embebido; web `_currentDayGroup` inicial desde mismo helper) |
| 100 | Ambas | Calendario | mejora | baja | **Línea separación** entre columnas de días **más visible** (más gruesa/contraste). | Paridad. | hecho (2026-03-27: `CalendarConstants.calendarVerticalSeparator*` + web/móvil `_createGridBorder`) |
| 101 | Ambas | Resumen pagos | mejora | media | Dejar solo **“Añadir gasto”**; **eliminar** flujo/botón **“Registrar pago”** (o unificar en uno). | Paridad. | hecho (2026-03-27: AppBar resumen = `IconButton` → `AddExpenseDialog`; FAB plan móvil = mismo; `PaymentDialog` sin entrada UI) |
| 102 | Ambas | Pagos ↔ eventos | feature | alta | **Ligar gasto con evento** y viceversa: gasto desde evento suma al plan; desde pagos elegir evento si existe. | Paridad; modelo datos + UI. | hecho (2026-03-27: `PlanExpense.eventId` + selector en `AddExpenseDialog`; icono recibo en barra `EventDialog`; resumen actividad muestra evento; `BalanceService` en ítems de gasto) |
| 103 | Ambas | Resumen pagos | feature | media | **“Te deben”** (y balances) alineados concepto **Tricount** / splits claros. | Paridad; ver `producto/PAGOS_PARIDAD_TRICOUNT.md` si aplica. | hecho (2026-03-27: copy estado “Le deben/Debe”, hint bajo Balances y subtítulo transferencias) |
| 104 | Ambas | Resumen pagos | feature | media | **Editar** y **eliminar** pagos/gastos ya registrados. | Paridad + reglas Firestore. | hecho (2026-03-27: menú en fila de gasto Tricount + `AddExpenseDialog` edición; org/pagador/registrador) |
| 105 | Ambas | Resumen pagos | feature | baja | **Sugerencias de transferencia** entre participantes. | Paridad. | hecho (ya en app; 2026-03-27: subtítulo aclaratorio l10n) |
| 106 | Ambas | Resumen pagos / bote | producto | alta | **Eliminar todo lo del bote** (kitty): ya no necesario. *(**60** fue corrección UI del bote; **106** es retirada funcional.)* | Paridad; limpiar reglas/colecciones según decisión. | hecho en UI y resumen (2026-03-27: sin sección bote; `paymentSummaryProvider` sin aportes/gastos kitty; `BalanceService` sigue aceptando listas vacías) |
| 107 | Ambas | Pagos / evento | feature | media | Al registrar gasto en **contexto evento**, preguntar **quién ha pagado** (split Tricount). | Paridad. | hecho (2026-03-27: aviso l10n en `AddExpenseDialog` con `initialEventId`) |
| 108 | Ambas | Publicidad / monetización | spike | baja | **Prueba estática** poco invasiva: dónde encaja banner/zona o **botón contextual** en formularios (ej. desplazamiento → oferta relacionada). Ver **PATROCINIOS_Y_MONETIZACION**. | Web igual; medir UX antes de red. | hecho (2026-04-06: `wd_event_dialog` muestra bloque patrocinado estático contextual para Desplazamiento con CTA externo, sin red/ads) |
| 109 | iOS (+Ambas) | Notificaciones push | infra | alta | Push **clave** para éxito. Revisar **tareas** y docs (**CHECKLIST_IOS_PUSH**, **ACCIONES_PENDIENTES**, FCM). Poner en marcha según prioridad. | Web: push/PWA según roadmap; móvil prioritario. | en progreso (2026-04-06: código listo — FCM robustecido, tap push + contrato payload + background handler; pendiente validación en iPhone físico con checklist A1) |

**Agrupación §3.2:** Lista planes **62** · Marca **63** · Navegación discusión **64** · Offline **65** · Vehículo alquiler discusión **66** · Transversal **67** · Info **68** · Resumen/layout **69–88** · Eventos **89–97** · Epic asistente **98** · Calendario **99–100** · Pagos **101–107** · Publicidad **108** · Push **109**.

**Semántica §5 vs §3.2:** el plan ya no usa estado “borrador” como tal; el ítem **81** (“filtrar borradores”) se entiende como **eventos no confirmados** (`isDraft` / mismo criterio que chip histórico **28**). Unificar copy al implementar.

---

### Referencias

- Tareas roadmap y colisión ID vs **Txxx:** [`docs/tareas/TASKS.md`](../tareas/TASKS.md) (fin del archivo: *Relación con LISTA_PUNTOS…*).
- Infra iOS (push / deep links): [`docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md`](../configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md) y [`ACCIONES_PENDIENTES_APP.md`](./ACCIONES_PENDIENTES_APP.md).
- Normas generales: [`docs/configuracion/CONTEXT.md`](../configuracion/CONTEXT.md).
- §3.2 (62–109): monetización [`PATROCINIOS_Y_MONETIZACION.md`](../especificaciones/PATROCINIOS_Y_MONETIZACION.md); pagos tipo Tricount [`PAGOS_PARIDAD_TRICOUNT.md`](../producto/PAGOS_PARIDAD_TRICOUNT.md); icono app [`T258_ICONO_APP.md`](../tareas/T258_ICONO_APP.md).


### Puntos 22-3-2026 — agrupación por zona (prioridad iOS)

| Zona | IDs | Notas |
|------|-----|--------|
| **Info del plan** (`wd_plan_data_screen` y relacionados) | 1, 4, 10, 11, 20, 24 | Incluye modal eliminar, guardar/cancelar, descripción, docs (9 solo diseño) |
| **Resumen del plan / Mi resumen** | 2, 27, 28 | Lista participantes, separadores día, borradores |
| **Formulario y modal de eventos** | 3, 14–17, 19, 21–23, 26, 30, 32, 33 | Tipos/subtipos, timezone vuelos, duración, texto largo, localizaciones |
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
| **7** | Admin: tarjeta **“Registros huérfanos”** → `PlanParticipationService.auditParticipations(deleteOrphans: false)` + resultado. |
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
| **29** | Calendario: menú opciones → **“Todos los días del plan”** (hasta `maxVisibleDays` 45); `calendar_constants` actualizado. |
| **30** | Subtipo **Tour** en Actividad. |
| **31** | Ancho de tarjeta de evento: ~**94%** de subcolumna (`_calculateEventPosition`). |
| **32** | Subtipos **Shuttle** y **Transfer** en Desplazamiento. |
| **23** | Nueva familia **Acción** (Embarque, Recogida, Entrega, Otro) con iconos. |

**Sin código / pendiente / solo diseño:** **9** (documentos en descripción), **12**, **14–15**, **17–19**, **22**, **33**; **18** opinión UX modal vs página.

### 4. Pendientes activos (prioridad iOS)

Backlog detallado: **§3.1 (IDs 34–61)** y **§3.2 (IDs 62–109)** — esta última es la **ronda iOS 2026-03-27** (Mi resumen, calendario, pagos, eventos, offline, push, etc.).

| ID | Estado | Próximo paso sugerido |
|----|--------|------------------------|
| 12 | Pendiente | Definir flujo final “añadir sin invitar” + permisos de asignación antes de invitar. |
| 14 | Hecho (2026-04-04) | Desplazamiento **no avión**: `showCityInMenuAndGmtSelected` + filas ciudad + GMT en el desplegable; cerrado solo GMT. Vuelos ya usaban bottom sheet con ciudad + GMT. |
| 15 | En curso | Implementado en app (autodetección por coordenadas); pendiente desplegar Cloud Function `placesTimezone` y validar en iOS/web. |
| 17 | Pendiente | Revisar integración de autocompletado/importación de datos de vuelos en web. |
| 18 | Decisión UX pendiente | Decidir si “Nuevo evento” web sigue en modal o pasa a página completa tipo W31. |
| 19 | Hecho (2026-04-04) | Calendario web: `departureAirport`/`arrivalAirport` (y `originName`/`destinationName`) para etiquetas de vuelo; fallback ciudad IANA. Tooltip avión alineado. |
| 22 | Pendiente | Rediseñar duración personalizada con UI más clara/consistente. |
| 33 | Pendiente | Selector de localizaciones: combinar nuevas + existentes del plan con iconografía diferenciada. |

### 5. Notas de consistencia funcional

- El flujo vigente del plan ya no contempla estado **Borrador**.  
- El punto **28** se considera resuelto a nivel histórico, pero su copy/semántica deberá migrarse a “no confirmado” o equivalente si vuelve a tocarse esa zona.

### 6. Cobertura en plan de testing

- Se añadió cobertura explícita en `docs/configuracion/TESTING_CHECKLIST.md` (sección **12.3 Regresión funcional (puntos cerrados 2026-03)**, casos `REG-2026-001` a `REG-2026-015`).
- Esta batería cubre los cierres funcionales con impacto de UX/comportamiento en iOS/web de esta lista y del archivo histórico.

*Instrucción original:* ordenar por páginas/tareas antes de codificar; prioridad **iOS**.

Recuerda que le damos prioridad a la app iOS



1. en la pagoina info, las secciones Participantes, Avisos, y zona de peligro han nde estar cerradas por defecto. añadir un icono a la de Avisos y la de de Zona de peligro. Cambiar el nombre Zona de peligro por "Eliminar plan". Hacer la sección coherente con la UI estándar.
2. En Mi Resumen, añadir la lista de participantes.
3. En el form de evento, revisar esto porque ya funcionaba: al seleccionar un tipo de evento, aparecen los subtipos. Al seleccionar un subtipo solo se que queda visible el subtipo 
4. El modal "Eliminar plan": los textos no se ven bien. Ajustar a la UI standard. 
5. En iOS: la pagina de perfil de usuario no sigue completamente la UI standard. En la barra superior, el userid es muy grande
6. En la pagina de login, si se produce un erorr aparece una barra roja en la parte inferior. si el usuario no la cierra, hacerla desaparece en unos segundos
7. En la página administrador_ crear un botón que analice la base de datos de firestore  y busque registros "huérfanos". Creo que ya tenemos algún código que hace eso, revisarlo. 
8. En iOS, en la página de planes, no podemos ver los planes en formato calendario (en web si)
9. En la info del plan, en el campo descripción, quiero poder anexar documnentos. No codifiques. Hablemos de como hacerlo
10. Info del plan, al lhgacer modificaciones aparecen los botones de Guardar y Cancelar. Son poco visibles. Hemos de añadir que al salir de esa página, si hay cambios, el sistema pregunte si queremos guardarlos o cancelarlos
11. Info del plan. El campo descrpcion, poner un incono de "+" para ampliarlo, bien en el mismo form o con un  modal, como prefieras. 
12. Invitaciones al plan. Quiero poder añadir participantes al plan sin invitarlos. A la hora de planificar el plan, quiero poder asignar eventos a participantes. Una vez lo tenga todo planificado los invito. 
13. En la página calenario en la web, añadir un botón "+" flotante para crear eventos.
14. En el modal eventos, el campo timezone de los vuelos, solo muestra GMt+n... como opciones debería mostrar los nomhres de las ciudades en el selector y solo GMT+n al mostrar la opción sleeccionada.
15. Modal de eventos. Calcular la timezone en base a la dirección seleccionada
16. Web: modal nuevo evento. Desaparece al clickar fuera del modal y se pierden los datos. 
17. Web: al seleccionar un vuelo y descargar los datos del vuelo no los localiza.
18. Web: el form de creación de enveto, es mejor que no sea un modal y que ocupe W31 como las otras páginas. ¿Qué opinas? 
19. El evento vuelo que se muestra en el calenadrio: Muestra las ciudades de origen y salida en base a la timezone. Debería ser en base a la ciudad del aeropuerto. 
20. En info del plan, necesito una sección para guardar informaciones del plan. Ejemplo: correos con la agencia, correos con los proveedores de servicio. De momento copio y pego la información en texto plano. 
21. Nuevo evento. Si no se selecciona el tipo de evento, no se muestra el resto de campo
22. El selector de duración del evento me ha de permitir poner una duración personalizada. El sistema actual no  es muy estético. 
23. En el tipo de evento, necesito un evento que sea tipo acción o algo parecido. Ejemplo: embarcar en un crucero, recoger algo, etc...
24. La zona horaria en la info del plan ha de aplicarse por defecto a todos los eventos del plan. 
25. En tipo de alojamiento añadir "Crucero"
26. En el evento, quiero poder añadir textos largos. Ejemplo: descripción que nos pasa una agencia.  Añadir un campo para poder hacerlo
27. En el resumen del plan, vamos a poner una linea fina horizontal separando los días para ver claramentte el cambio de dia
28. Resumnen del plan: si un evento está en borrador, marcar de alguna forma que el evento no está confirmado
29. Web: En el calendario, añadir la opción demostrar en pantalla todos los días del plan. 
30. Form evento: Añadir subtipo "Tour" dentro de actividad
31. Las cards de los eventos ocupan exactamanete toda la columna del día. Quiero que sea un poco más estrecha. 
32. En evento: añadir subtipo "shuttle" o "transfer" dentro de desplazamineto. Son los traslados que se hacen con el servicio del hotel. 
33. Cuando podamos buscar una localización en eventos sería bueno poder seleccionar una nueva localizacion o una existente en el plan. Es decir, si tenemos la locaclizacion de un alojamiento y hacemos traslados de y hacia ese alojamineot, en la lista de localizaciones, ese alojamiento debería estar visible para poder seleccionarlo como origen o destino. Quizás hemos de añadir un icono diferente para mostrrar localizaciones del plan. 