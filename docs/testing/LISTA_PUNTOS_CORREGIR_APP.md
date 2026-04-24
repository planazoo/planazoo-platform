## Lista de puntos a corregir en la app (solo abiertos)

**Objetivo:** mantener aquí solo los puntos **pendientes / en progreso** de QA.

**Histórico de cerrados:**
- `ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_03.md` (bloque histórico 1-33 y P3-P20).
- `ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_04.md` (cierres de 34-109; **109** push iOS cerrado 2026-04-19).

---

### 1. Información del build (rellenar en cada ronda)

- **Versión de la app**:
- **Origen**: TestFlight / Web / Android / …
- **Fecha de la ronda de pruebas**:
- **Build ID (si aplica)**:

---

### 2. Cómo anotar cada punto nuevo

- **ID**: siguiente libre **113**.
- **Plataforma**: iOS / Web / Ambas / …
- **Pantalla / flujo**.
- **Tipo**: bug / mejora / copy / producto / discusión.
- **Gravedad**: alta / media / baja.
- **Descripción breve**.
- **Estado**: pendiente / en progreso / hecho.

> Al cerrar un punto: moverlo al archivo histórico del periodo para que esta lista siga limpia.

---

### 3. Resumen actual

- **Pendientes:** 3
- **En progreso:** 0
- **Movidos a TASKS.md como tareas nuevas:** `63`→`T263`, `64`→`T264`, `65`→`T265`, `98`→`T266`; **Android push/app:** `T267`
- **Hechos/cerrados en histórico:** 72 (incluye cierre **109** push iOS, 2026-04-19 — ver `ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_04.md`)

---

### 4. Puntos abiertos

#### 110. Calendario — opción "Todos los días del plan" no aplicada en selector
- **Plataforma:** iOS / Android / Web
- **Pantalla / flujo:** Calendario del plan → menú opciones → "Todos los días del plan"
- **Tipo:** bug
- **Gravedad:** media
- **Descripción breve:** En la auditoría de código, el menú expone la opción `days_all_plan`, pero no aparece gestionada en el `switch` de selección del menú. Debemos confirmar comportamiento real y, si aplica, completar wiring para que aplique `visibleDays` al rango esperado (`maxVisibleDays`).
- **Estado:** pendiente
- **Referencia histórica:** ítem 29 / `REG-2026-014`

#### 111. Calendario — separadores verticales entre días (criterio de constantes) no trazado al 100%
- **Plataforma:** iOS / Android / Web
- **Pantalla / flujo:** Calendario multi-día (columnas de días/tracks)
- **Tipo:** bug / revisión técnica
- **Gravedad:** baja
- **Descripción breve:** Hay constantes específicas de separador vertical (`calendarVerticalSeparator*`), pero la creación de bordes sigue en utilidades genéricas (`createGridBorder`). Visualmente puede estar correcto, pero falta trazabilidad clara al criterio técnico definido para el ítem.
- **Estado:** pendiente
- **Referencia histórica:** ítem 100 / `REG-2026-018`

#### 112. Calendario — alinear rejilla interna real con la demo v1 aprobada
- **Plataforma:** iOS / Android / Web
- **Pantalla / flujo:** Plan detalle → pestaña Calendario (rejilla interna `CalendarMobilePage`)
- **Tipo:** mejora UI / refactor visual
- **Gravedad:** media
- **Descripción breve:** La versión real ya adopta el marco externo de la demo (`barra unificada`, `chips 1/2/3`, `zona horaria`, contenedor). Falta trasladar los ajustes visuales de la rejilla interna aprobada en `demo/calendar-v1` (estética de celdas/pastillas y consistencia visual) a los componentes reales (`CalendarGrid`/tracks/eventos/alojamientos), sin romper lógica productiva.
- **Estado:** pendiente
- **Referencia:** acuerdo de revisión UI en chat (2026-04-22)

---

### 5. Referencias rápidas

- Normas: `docs/configuracion/CONTEXT.md`
- Tareas Txxx relacionadas: `docs/tareas/TASKS.md`
- Offline móvil (58 cerrado): `docs/testing/TESTING_OFFLINE_FIRST.md`
- Push iOS: `docs/testing/ACCIONES_PENDIENTES_APP.md`, `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md`
- Testing formal / regresiones: `docs/configuracion/TESTING_CHECKLIST.md`

---

### 6. Cierre técnico UI-SP (2026-04-23)

- **Objetivo cerrado:** unificación visual dark UI-SP y limpieza técnica de presentación sin tocar lógica de negocio.
- **Validación técnica:** `flutter analyze` sobre 21 archivos tocados en esta iteración → `No issues found`.
- **Limpieza de deuda UI:** en el scope trabajado no quedan usos visuales de `kIsWeb` ni `withOpacity(...)`.
- **Cobertura del bloque pendiente (19/19):**
  - **Ajustados con cambios UI-SP:** 17.
  - **Revisados sin cambio necesario:** `pg_admin_page`, `fullscreen_calendar_page`.
- **Trazabilidad de errores autocorregidos:** actualizado `docs/configuracion/LOG_ERRORES_AUTOFIX.md` con incidencia de scope (`_surface` fuera de alcance en `wd_notification_list_dialog`).

### 7. Consolidación técnica global (2026-04-24)

- **Validación global:** `flutter analyze lib` → `No issues found`.
- **Directorios verificados por bloques:** `lib/features`, `lib/widgets`, `lib/pages`, `lib/shared`, `lib/app`.
- **Chequeo UI-SP de deuda visual (global `lib/`):**
  - `withOpacity(...)`: 0 coincidencias.
  - `Colors.grey.shade*`: 0 coincidencias.
  - `kIsWeb`: solo usos funcionales de plataforma (sin decisiones de estilo visual por plataforma).
- **Trazabilidad técnica:** añadido registro en `docs/configuracion/LOG_ERRORES_AUTOFIX.md` para el cierre final de analyzer en `main.dart`.