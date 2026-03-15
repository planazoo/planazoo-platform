# Estructura del resumen del plan (Mi resumen) – repaso y mejoras

Vista actual en `MyPlanSummaryScreen` (wd_my_plan_summary_screen.dart). Orden de bloques de arriba a abajo:

---

## 1. Barra superior (fija)

- **Título:** "Mi resumen"
- **Subtítulo (solo participantes):** "Esta es tu vista como participante"
- Altura 48px, color2, sombra

**Posibles mejoras:**
- Añadir acciones en la barra (ej. compartir resumen, exportar).
- Opción de orden: "por fecha" vs "por tipo" (solo si tiene sentido para el usuario).

---

## 2. Bloque "Lo más importante" (`_buildImportantBlock`)

**Contenido actual:**
- Título localizado (`myPlanSummaryImportant`).
- Rango del plan: fecha inicio – fecha fin.
- Timezone del plan (si existe).
- **"Mi información":** solo si hay eventos de hoy/mañana con `personalParts` del usuario y campos rellenados; se muestran líneas tipo "Descripción del evento: campo1: valor1, campo2: valor2". Cada línea es enlace al evento (modal previo → evento completo).

**Posibles mejoras:**
- **Nombre del plan** en este bloque (ahora no se muestra en el resumen).
- Si no hay "mi información", el bloque puede sentirse vacío: considerar texto tipo "No tienes datos personales en eventos de hoy o mañana" o recolocar solo rango + timezone en un bloque más pequeño.
- Definir mejor qué es "lo más importante" (¿solo fechas del plan + datos personales hoy/mañana?) y si conviene otro título o desglose (ej. "Resumen del plan" + "Mis datos para hoy/mañana").

---

## 3. Hoy / Mañana (`_buildTodayTomorrowSection`)

- Dos tarjetas: **Hoy** (fecha de hoy) y **Mañana** (fecha de mañana).
- En cada una: lista de eventos del usuario ese día, "HH:mm Descripción", con enlace al evento.
- Si no hay eventos: "—".

**Posibles mejoras:**
- Mostrar **hora de inicio y fin** (ahora solo hora inicio) para ver duración a simple vista.
- Indicador de **tipo** (icono o etiqueta: vuelo, hotel, comida, etc.) junto a cada evento.
- Si hoy/mañana no caen dentro del rango del plan, opción: ocultar bloque o mostrar mensaje "Fuera del periodo del plan".
- **Orden dentro del día:** ya está por hora; podría ofrecer agrupación por "mañana / tarde / noche" si se desea.

---

## 4. Accesos rápidos (`_buildQuickAccessSection`)

- **Vuelos:** eventos con `typeFamily == 'Desplazamiento' && typeSubtype == 'Avión'` o tipo que contenga "vuelo". Formato: "fecha HH:mm descripción". Enlace al evento.
- **Alojamiento:** alojamientos del usuario. Formato: "Nombre hotel (check-in – check-out)". Enlace al alojamiento.

**Posibles mejoras:**
- **Criterio de "vuelos":** ampliar a más subtipos (ej. tren, coche) si se quiere "Desplazamientos" en vez de solo vuelos; o dejar solo vuelos y renombrar a "Vuelos" explícitamente.
- En alojamiento: mostrar **número de noches** o **dirección** (si existe) en una línea secundaria.
- Orden: por fecha de salida (vuelos) y por check-in (alojamientos).

---

## 5. Lista cronológica (`_buildChronologicalSection`)

- **Todos** los eventos del usuario en el plan, ordenados por fecha y hora.
- Cada fila: "dd/mm  HH:mm  Descripción" + icono enlace.
- Sin agrupación por día (lista plana).

**Posibles mejoras:**
- **Agrupar por día** con un pequeño encabezado "Lunes 15/3", "Martes 16/3", etc., para escanear más rápido.
- Mostrar **duración** (ej. "10:00–12:00" o "1h 30min") cuando aporte valor.
- **Límite o "ver más":** si hay muchos eventos, mostrar por ejemplo "Próximos 7 días" o un tope N eventos con "Ver todos" que expanda o lleve a una vista filtrada.
- **Filtros opcionales:** por tipo (vuelos, alojamiento, actividades) o por rango de fechas (esta semana, todo el plan).

---

## 6. Aspectos transversales

**Enlaces:**
- Todos los eventos y alojamientos son enlaces → modal de vista previa → "Abrir evento/alojamiento" → diálogo completo. Bien para no abrir directamente el formulario pesado.

**Datos:**
- Solo se muestran eventos (y alojamientos) donde el usuario está en `participantTrackIds` o el evento no tiene tracks asignados. Coherente con "mi resumen".

**Vacíos:**
- Si no hay eventos ni alojamientos, las secciones muestran "—". Podría haber un estado único "Aún no tienes eventos en este plan" con CTA (ej. "Ir al calendario") cuando todo esté vacío.

**Localización:**
- Títulos de sección usan `loc.myPlanSummary*`. Revisar que todas las cadenas estén en arb y que el tono sea consistente ("Mi información", "Vuelos", "Alojamiento", "Lista cronológica").

**Responsive / compacto:**
- Mismo layout en móvil y web. En pantallas muy pequeñas se podría colapsar "Hoy/Mañana" en pestañas o acordeón para ganar espacio.

---

## Resumen de prioridades sugeridas

| Prioridad | Mejora |
|----------|--------|
| Alta     | Agrupar lista cronológica por día con encabezados de fecha. |
| Alta     | Estado vacío unificado cuando no hay eventos ni alojamientos (mensaje + CTA). |
| Media    | Nombre del plan visible en el resumen (ej. en el bloque "Lo más importante"). |
| Media    | Hora inicio–fin o duración en eventos (Hoy/Mañana y/o cronológica). |
| Media    | Refinar bloque "Lo más importante" cuando no hay "mi información" (evitar bloque grande con poco contenido). |
| Baja     | Icono o etiqueta de tipo en cada evento. |
| Baja     | Filtros o "ver más" en lista cronológica si hay muchos eventos. |
| Baja     | En accesos rápidos: más detalle en alojamiento (noches, dirección) y criterio explícito para "vuelos". |

Si quieres, podemos bajar al detalle de una sección concreta (por ejemplo solo "Lo más importante" o solo la lista cronológica) y definir los textos y comportamientos exactos.
