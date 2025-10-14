## 📚 Documento de Capacidades del Calendario

Este documento describe de forma funcional (sin código) qué puede hacer el calendario ahora mismo, cómo se usa cada interacción y qué partes están pendientes o degradadas. Sirve como referencia para no romper flujos existentes al introducir cambios.

### 🧭 Alcance
- Describe UX, comportamientos, dependencias de datos y restricciones.
- Incluye estados: Funciona, Degradado, Pendiente.
- No contiene código, solo especificaciones funcionales y de UX.

---

## 🎯 Objetivo del Calendario
- **Planificación visual** por días y horas con soporte de eventos y alojamientos.
- **Interacciones clave**: crear, editar, mover (drag & drop) y visualizar eventos; mostrar alojamientos por día.
- **Fuente de datos**: Firestore (lectura/escritura de eventos y alojamientos).

---

## 🖼️ Estructura de la Pantalla
- **AppBar**: Título del plan y accesos (botón alojamientos, añadir/eliminar días, selector de fecha).
- **Encabezado de tabla** (fila fija): columnas por día del plan.
- **Fila de alojamientos** (fija): una franja debajo del encabezado para mostrar el alojamiento del día.
- **Cuerpo con scroll vertical**: 24 filas (00:00–23:00) con una columna fija de horas y columnas por día.

### 🧱 Capas de Renderizado (Stack)
- **Capa 1 – Tabla (datos)**
  - Contiene las filas/columnas de la rejilla: columna fija de horas, columnas por día y la fila fija de alojamientos.
  - Va dentro de un `SingleChildScrollView` vertical; la rejilla hace clipping natural al salir del viewport.
  - Es la referencia de posicionamiento vertical (minutos → píxeles) y horizontal (día → columna).

- **Capa 2 – Eventos (Positioned)**
  - Eventos renderizados como widgets posicionados respecto a la rejilla (x por día, y por minutos desde 00:00).
  - Se inyectan como hijos de un `Stack` colocado DENTRO del mismo `SingleChildScrollView` que la tabla.
  - Motivo: que los eventos se desplacen y se recorten exactamente igual que la tabla (clip y scroll sincronizado).
  - Interacciones: los eventos capturan sus propios gestos (tap para editar, drag & drop con magnetismo). 

Notas de interacción entre capas:
- Para crear por doble click, el gesto se resuelve en las celdas de la tabla (capa 1), evitando interferir con los gestos de eventos.
- Evitar detectores de gestos “globales” por encima de los eventos, ya que pueden bloquear tap/drag de la capa 2.
- Cualquier overlay adicional debe respetar el z-order: los eventos deben poder recibir sus gestos cuando estén bajo el puntero.

### Guía visual (UX / estilo)
- **Colores** (aprox.):
  - Fondo encabezado de días: azul claro (`#BBDEFB`).
  - Líneas de la rejilla: gris claro (`#E0E0E0`).
  - Columna de horas: gris muy claro (`#FAFAFA`).
  - Eventos: paleta por tipo (blue/green/orange/purple/red/teal/indigo/pink); borde 1px más oscuro.
  - Texto sobre eventos: contraste automático según color de evento.
- **Tipografía**: `Roboto`.
  - Encabezados: 10–12 px, bold.
  - Horas: 12 px.
  - Texto de evento: 6–10 px adaptativo según altura del evento (ver más abajo).
- **Medidas**:
  - Altura por hora: 60 px.
  - Encabezado: 50 px.
  - Alojamientos: 40 px.
  - Columna de horas: 80 px.

---

## 🧩 Datos y Sincronización
- **Fuente**: Firestore a través de servicios y providers (Riverpod).
- **Eventos**:
  - Lectura por plan y fecha.
  - Escritura en creación/edición/drag.
  - Invalida providers al cambiar datos para refrescar la UI.
- **Scroll sincronizado**: columna de horas y tabla de datos se mueven coordinadas.

Estado: **Funciona** (autoscroll, sincronización y carga de datos; ver notas de auto-scroll abajo).

---

## 🧠 Auto-scroll Inteligente
- **Cuándo**: al abrir un plan o cambiar de grupo de días.
- **Regla**: se posiciona 1 hora antes del primer evento del plan; si el primer evento es de día completo, se posiciona en 00:00.
- **Bloqueo de sincronización**: durante el auto-scroll, la sincronización se desactiva para evitar rebotes; se reactiva al finalizar.

Estado: **Funciona**.

---

## 🗓️ Encabezados por Día (tabla)
- Muestra nombre del día y (pendiente) "Día X" + fecha del plan.

Estado: **Parcial** (pendiente el formato exacto "Día X" + fecha).

---

## 🏨 Alojamientos por Día
- Franja fija bajo el encabezado para mostrar alojamiento por día (nombre y color).
- Interacción prevista: click para ver/editar; botón en AppBar para crear.

Estado: **Degradado/Pendiente de verificación** (crear/editar/eliminar puede no estar operativo ahora mismo).

---

## 🗂️ Eventos: Visualización
- **Posición**:
  - Horizontal: por columna del día.
  - Vertical: por minutos desde 00:00; altura proporcional a duración.
  - Multi-día: si un evento cruza medianoche, se muestra la parte que corresponde en el siguiente día.
- **Clipping**: los eventos se desplazan con el scroll; la visibilidad se corta de forma natural al salir del viewport (comportamiento idéntico a la rejilla).
- **Tipografía adaptativa**: el tamaño de fuente se reduce en eventos muy bajos; límite 6–10 px aprox.; se usa `ellipsis` para evitar overflow; horas en una sola línea.

Estado: **Funciona** (incluye multi-día y clipping; se han mitigado errores de overflow en eventos pequeños).

---

## 🖱️ Interacciones con Eventos

### Crear Evento
- **Doble click** en celda de la tabla (área de datos) crea un evento con fecha/hora precargadas.
- Se abre un diálogo con descripción, tipo/subtipo, color, hora/minuto de inicio y duración.
- Las celdas usan `HitTestBehavior.opaque` para capturar correctamente el doble click en áreas vacías.
- **Validación 1:** Los eventos no pueden durar más de 24 horas (1440 minutos).
- **Validación 2:** Máximo 3 eventos simultáneos (ver regla de negocio abajo).
- **Selector de duración:** Ofrece opciones desde 15 minutos hasta 24 horas.

**⚠️ REGLA DE NEGOCIO 1: Eventos máximo 24h**
> Los eventos representan **FASES del plan** (actividades, desplazamientos, comidas), no bloques de tiempo genéricos.
> 
> Si necesitas algo > 24h:
> - 🏨 ¿Es alojamiento? → Usa fila de Alojamientos
> - 🎯 ¿Son actividades diferentes? → Crea eventos separados por día
> - 🚢 ¿Es viaje largo? → Eventos por tramo (ej: crucero = embarque + navegación + paradas + desembarque)

**⚠️ REGLA DE NEGOCIO 2: Máximo 3 eventos simultáneos**
> Por razones de **usabilidad** y **legibilidad**, el calendario limita a **3 eventos solapados** en cualquier momento.
> 
> **¿Por qué?**
> - Con 3 eventos, cada uno ocupa ~33% del ancho de columna (legible, clickeable)
> - Con 4+ eventos, el ancho se vuelve < 25% (texto ilegible, difícil de arrastrar)
> 
> **¿Cuándo se valida?**
> - ✅ Al crear un evento nuevo
> - ✅ Al editar hora/duración de un evento existente
> - ✅ Al arrastrar un evento a nueva posición (drag & drop)
> 
> **Comportamiento:**
> - Si intentas crear/mover un evento que causaría 4+ solapamientos → ⚠️ Mensaje de error naranja
> - El evento NO se guarda/mueve, permanece en su posición original
> - Solución: Ajustar hora, reducir duración, o eliminar otro evento
> 
> **Indicador visual:**
> - Cuando hay exactamente 3 eventos solapados, el último muestra un icono ⚠️ naranja
> - Esto indica que el horario está al límite de capacidad

Estado: **Funciona**.

### Editar Evento
- **Click** sobre un evento abre diálogo de edición con datos actuales.
- Guardar actualiza en Firestore y refresca la UI.

Estado: **Puede estar degradado** si un overlay intercepta toques o si la invalidación de providers no se dispara en algunos flujos. Revisión recomendada tras últimos cambios.

### Eliminar Evento
- Desde el diálogo de edición (botón Eliminar) con confirmación implícita.

Estado: **Funciona** (revisar refresco inmediato de UI en todos los casos).

### Drag & Drop de Eventos
- **Arrastre vertical**: ajusta la hora de inicio; magnetismo a intervalos de 15 minutos.
- **Arrastre horizontal**: mueve entre días; magnetismo a columnas.
- **Visual**: feedback con sombra y traslación suave durante el arrastre; al soltar, se persiste y refresca la UI.

Estado: **Degradado** (tras los cambios para doble click, el drag & drop puede verse interferido si un detector superior capta los gestos; actualmente el detector global de doble click está deshabilitado y el doble click se maneja en las celdas, mitigando el conflicto, pero hay que validar edición/drag en todos los casos).

---

## 🔍 Reglas de Magnetismo
- **Vertical**: pasos de 15 minutos, límite entre 00:00 y 23:59.
- **Horizontal**: alineación exacta a la columna del día destino (sin offset de media columna).

Estado: **Funciona** (se corrigieron inconsistencias previas entre preview y posición final).

---

## 🧩 Estados Especiales
- **Eventos multi-día**: divididos visualmente; la parte del segundo día se alinea correctamente a 00:00.
- **Eventos muy cortos (15 min)**: tipografía más pequeña, máximo una línea + horas en una línea; se prioriza legibilidad y evitar overflow.

Estado: **Funciona**.

---

## 🔁 Navegación por Días
- Botones anterior/siguiente para moverse en grupos de días (p. ej., de 7 en 7).
- Al cambiar de grupo, se aplica auto-scroll al primer evento del plan.

Estado: **Funciona**.

---

## 🧪 Conjunto de Casos a Validar tras Cambios
- Crear evento por doble click (varias horas y días).
- Editar evento existente (ver que la UI refresca sin reiniciar app).
- Eliminar evento y validar desaparición inmediata.
- Drag vertical con magnetismo a 15 min, incluyendo mover a 00:00.
- Drag horizontal entre columnas contiguas (sin medio desplazamiento visual).
- Multi-día: que ambas partes se dibujen y no desborden.
- Auto-scroll al primer evento del plan (y re-navegación de grupos de días).
- Alojamientos: crear/editar/eliminar/mostrar (estado actual a confirmar).

---

## ⚠️ Riesgos / Observaciones
- Superposición de detectores de gestos puede romper drag/edición (doble click global vs. eventos). Mitigado moviendo el doble click a celdas.
- Invalidación de providers: asegurar que tras crear/editar/eliminar/drag se invalida el provider correcto (por parámetros) y se fuerza rebuild.
- Overflow en eventos bajos: mitigado con `ellipsis`, `Flexible` y reducción de padding.

---

## ✅ Resumen de Estado (alto nivel)
- **Crear eventos**: Funciona (doble click con HitTestBehavior.opaque)
- **Editar eventos**: Puede estar degradado (validar tras últimos ajustes)
- **Eliminar eventos**: Funciona (revisar refresco inmediato)
- **Drag & drop**: Degradado/pendiente de validación completa tras cambios recientes
- **Multi-día**: Funciona
- **Auto-scroll**: Funciona
- **Alojamientos**: Pendiente de verificación (posible regress)
- **Encabezado "Día X + fecha"**: Pendiente

---

## ✅ Próximos Pasos Recomendados
1. Validar y, si es necesario, restaurar completamente edición y drag & drop (prioridad alta).
2. Confirmar el flujo completo de alojamientos (crear/editar/eliminar/mostrar) y documentar su UX.
3. Completar encabezado de días con formato "Día X" + fecha (alineado con la UX).
4. Mantener este documento como fuente de verdad; actualizarlo en cada cambio funcional.


