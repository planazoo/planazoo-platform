# Lab: qué mostrar en cada caso (tarjeta × strip × roster)

Documento vivo para alinear UX y código del **laboratorio de tarjetas de evento**. La implementación de referencia está en:

[`calendar_event_cards_lab_page.dart`](../../lib/features/auth/presentation/pages/calendar_event_cards_lab_page.dart)

Ruta demo: **`/demo/calendar-event-cards-lab`** (acceso típico: dashboard escritorio → W1).

---

## 1. Dimensiones que cruzamos

| Eje | Qué significa en el lab | Valores típicos en chips |
|-----|--------------------------|---------------------------|
| **Tipo de tarjeta (estilo UI-ST)** | Variante visual A–E | A relleno, B carril, C chip tiempo, D tint, E split tiempo |
| **Días visibles en el strip** | Cuántos días ocupan una fila horizontal | `1`, `3`, `7` |
| **Participantes (columnas/día)** | Roster sintético; ancho útil por evento ~ `ancho día / N` | `1` … `10` |

Además:

- **Ancho del evento** en columnas: `spanCols ∈ [1..N]` (los eventos sintéticos simulan coberturas 100%, ~50%, ~25%, ~5% sobre el roster).
- **Alto del bloque** en píxeles: derivado del calendario real con **`AppConstants.cellHeight` (45 px por hora)** y la duración en minutos del evento sintético.

Este documento **no** lista aún todas las combinaciones en tabla; vas rellenando la sección §6 con decisiones UX.

---

## 2. Alto horario y eventos cortos (paridad prod)

| Regla | Constante | Uso |
|-------|-----------|-----|
| Píxeles por hora en grid | [`AppConstants.cellHeight`](../../lib/shared/utils/constants.dart) | `altura_bloque = durationMinutes / 60 * cellHeight` |
| Ocultar “segunda línea” en modo rico cuando el evento es corto | [`CalendarConstants.shortEventTitleOnlyMaxMinutes`](../../lib/widgets/screens/calendar/calendar_constants.dart) (**45**) | Solo en presentación **`full`**: si duración `< 45` min → sin subtítulo (solo título) |

---

## 3. Nivel de densidad (`_LabCardPresentation`) — cómo está implementado

Se define un **`score`** (entero):

### 3.1 Tensión por strip

- **`dayPart`**: `1 día → 0` · `3 días → 1` · `7 días → 2`
- **`rosterPart`** (para `n` participantes clamp 1–99):  
  `n ≤ 2 → 0` · `n ≤ 4 → 1` · `n ≤ 7 → 2` · `n ≥ 8 → 3`

**`grid = dayPart + rosterPart`** (entre 0 y 5 en escenarios típicos).

### 3.2 Penalización si el evento no abarca todo el roster (`span < n`)

`r = span / n`:

| Condición sobre `r` | `spanPenalty` |
|---------------------|---------------|
| `r ≤ 0.12` | `+4` |
| `r ≤ 0.30` | `+3` |
| `r ≤ 0.55` | `+2` |
| mayor (pero aún `< 1`) | `+1` |

Si **`n ≤ 1`** o **`span ≥ n`**: `spanPenalty = 0`.

### 3.3 Mapeo `score = grid + spanPenalty → presentación**

| Umbral sobre `score` | Presentación | Idea de contenido |
|----------------------|----------------|-------------------|
| `≤ 3` | **`full`** | Título + (si aplica) segunda línea; estilo según variante A–E |
| `4 … 5` | **`compact`** | Menos líneas; ej. sólo chip en C o una línea combinada en E |
| `6 … 8` | **`glyph`** | Etiqueta corta monospace (clave hora / token reducido) |
| **`≥ 9`** | **`swatch`** | Principalmente bloque de color (+ mínimos de cada variante) |

Ejemplos de referencia ya modelados:

- **`7` días × `10` pax × `1` columna** → típicamente **`swatch`**.
- **`7` días × `10` pax × ancho total** → suele **`compact`**, sin llegar a **swatch** si no hay penalización de franja muy estrecha.

### 3.4 Ajustes por hueco físico (LayoutBuilder)

Con restricciones de layout muy pequeñas, incluso dentro de **`full`**, puede activarse **`_microSlot`** para no desbordar (tipografía mínima / micro layout).

---

## 4. Tipos de evento (estilos del lab — A–E)

| Id | Rol | Idea |
|----|-----|------|
| **A** | Relleno sobre acento | Fondo **`cAccent`/tier**, texto alto contraste |
| **B** | Superficie + carril | Superficie + borde + carrillito lateral semántico |
| **C** | Chip denso | Marca tiempo en mono + texto |
| **D** | Tint muy suave sobre superficie | No gradientes fuertes |
| **E** | Split tiempo / contenido | Zona tiempo + zona título/meta |

Aquí puedes **ampliar** con capturas y “en **glyph** debe verse X en variante **C**”.

---

## 5. Menú contextual (solo esta demo lab)

| Comportamiento | Detalle |
|----------------|---------|
| **Disparador** | **Clic derecho** sobre el bloque del evento (`onSecondaryTapDown`) |
| **Plataforma** | Pensado para **web escritorio con ratón**; en táctil puro puede no aplicarse |
| **Acciones mostradas** | Editar · Copiar · Borrar (mismos textos **`AppLocalizations`** que el calendario); la demo muestra sólo **`SnackBar`** |

---

## 6. Matriz a completar (decisiones UX / diseño)

Añade filas cuando fijemos reglas nuevas (*“en **full** + **E** + **7×10** + **span medio** debe mostrar …”*):

| Prioridad | Tipo tarjeta | Días visibles | N participantes | span | Duración típima | ¿Qué mostrar? | Notas / captura |
|-----------|---------------|---------------|-----------------|------|------------------|---------------|-----------------|
| (ej.) | C | 7 | 10 | 1 | 38 min | swatch/glyph … | Pendiente revisión |
| | | | | | | | |

---

## 7. Calendario real (producción)

La variante **B** del lab (superficie + carril semántico sobre `cSurfaceBg`) está aplicada en la pantalla **`CalendarScreen`** del plan: [`wd_calendar_screen.dart`](../../lib/widgets/screens/wd_calendar_screen.dart).

---

### Historial rápido (mantener cuando haya cambios importantes)

- **2026-05**: Matriz inicial en código (`_labCardPresentation`); alto hora **`AppConstants.cellHeight`**; demo menú sólo clic derecho; doc creado.
- **2026-05**: Tarjetas en **`wd_calendar_screen`** alineadas a **opción B** (lab).
