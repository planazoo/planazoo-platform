# Propuesta: agrupar en 1 fila los 3 controles sobre el calendario (iOS)

**Objetivo:** Reducir el espacio vertical **por encima** del encabezado del calendario en iOS para que se vean más horas del grid sin hacer scroll.

**Contexto:** En la pestaña Calendario del detalle del plan (iOS/móvil) hay **tres filas de controles** antes de que empiece el grid del calendario (encabezados de día + fila de alojamientos + filas de horas):

1. **Fila 1 – Selector Calendario / Mi plan:**  
   En `pg_plan_detail_page` → `_buildCalendarTabContent()`: una fila con dos botones de segmento **«Calendario»** y **«Mi resumen»** (padding vertical 8 + altura de botones). Permite alternar entre vista calendario y vista “Mi resumen”.

2. **Fila 2 – Selector de días del plan:**  
   AppBar de `CalendarMobilePage`: barra con **«Días X–Y de Z»** (p. ej. «Días 1-3 de 7») y flechas anterior/siguiente para mover el grupo de días mostrado. Ocupa la altura del AppBar (toolbar).

3. **Fila 3 – Selector de días a visualizar:**  
   En el mismo `CalendarMobilePage`, `AppBar` con `bottom`: una fila con botones **«1 día»**, **«2 días»**, **«3 días»** para elegir cuántos días se muestran a la vez (`PreferredSize` 56px).

Esas **tres filas** suman bastante altura y dejan poco espacio para las horas del calendario en pantallas pequeñas.

---

## Propuesta: una sola fila “barra de controles” compacta

Sustituir las **tres filas** por **una única fila** (p. ej. **40–48px** de altura total) que agrupe en una sola barra horizontal:

| Control actual | Cómo integrarlo en la fila única |
|----------------|----------------------------------|
| **Calendario \| Mi resumen** | Segmento compacto a la izquierda (solo texto corto o iconos: “Cal.” \| “Resumen”, o icono calendario \| icono resumen). |
| **Días X–Y de Z** y flechas | En el centro: texto corto “D1–3/7” o “1–3 de 7” + iconos &lt; y &gt; (mismo comportamiento que ahora). |
| **1 día \| 2 días \| 3 días** | A la derecha: tres chips o botones pequeños “1” “2” “3” (o “1d” “2d” “3d”) para elegir cuántos días se visualizan. |

Todo en **una sola Row** (o barra fija) por encima del grid, sin AppBar con `bottom` y sin la fila extra del segmento Calendario/Mi resumen por separado.

### Esquema visual (idea)

```
Antes (3 filas):
┌─────────────────────────────────────────┐
│  [ Calendario ]  [ Mi resumen ]          │  ← Fila 1 (selector modo)
├─────────────────────────────────────────┤
│  <   Días 1-3 de 7   >     [acciones]   │  ← Fila 2 (AppBar: rango + nav)
├─────────────────────────────────────────┤
│      [ 1 día ]  [ 2 días ]  [ 3 días ]  │  ← Fila 3 (días a visualizar)
├─────────────────────────────────────────┤
│  (aquí empieza el grid: encabezados     │
│   de día, fila alojamientos, horas)     │
└─────────────────────────────────────────┘

Después (1 fila):
┌─────────────────────────────────────────┐
│ Cal.|Resumen   < D1-3/7 >   [1][2][3]   │  ← Una sola barra (~40–48px)
├─────────────────────────────────────────┤
│  (grid del calendario)                  │
└─────────────────────────────────────────┘
```

### Detalles a decidir en implementación

1. **Dónde vive la barra:**  
   - Opción A: La barra única es la única “cabecera” del contenido de la pestaña Calendario (dentro de `_buildCalendarTabContent`), y `CalendarMobilePage` ya no lleva AppBar propio en móvil; el “back” y título del plan pueden seguir en el AppBar de `PlanDetailPage`.  
   - Opción B: La barra única se integra como `title` o `flexibleSpace` del AppBar de `CalendarMobilePage`, y se elimina el `bottom` y se integra el segmento Calendario/Mi resumen en esa misma barra (requiere pasar estado/callbacks desde el padre).

2. **Orden y ancho:** Reparto izquierda / centro / derecha (p. ej. 30% / 40% / 30%) o con `Expanded`/`Flexible` para que el bloque central (rango de días + flechas) tenga más peso.

3. **Acciones adicionales:** Si en web el calendario tiene más acciones (resumen, filtros, etc.), en móvil se pueden llevar a un menú “…” en esa misma barra para no añadir altura.

4. **Altura concreta** (40 vs 48px) según legibilidad y touch targets (mín. 44pt en iOS).

5. **Solo iOS/móvil:** Esta agrupación en 1 fila aplicaría en `CalendarMobilePage` o cuando se detecte ancho &lt; 600px; en web se puede mantener el layout actual de 3 filas.

### Beneficio esperado

- Pasar de **3 filas** (segmento + AppBar + bottom) a **1 fila** → se recuperan aproximadamente **60–80px** de altura para el grid del calendario.
- Misma funcionalidad: cambiar entre Calendario/Mi resumen, navegar por grupos de días y elegir 1/2/3 días visibles.

### Alcance

- **Solo iOS / móvil** (p. ej. cuando la pestaña Calendario muestre `CalendarMobilePage` en pantallas estrechas).
- Coordinación entre `pg_plan_detail_page` (segmento Calendario/Mi resumen) y `CalendarMobilePage` (AppBar + bottom): o bien se unifica todo en un solo widget de “barra calendario” que reciba callbacks, o se mueve el segmento dentro de la pantalla de calendario para tener una sola barra.

---

*Documento de propuesta; sin implementación. Cuando se apruebe, se puede añadir una tarea en TASKS.md y referenciar este doc.*
