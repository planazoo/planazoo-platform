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
- **Sistema de permisos**: Roles granulares (Admin, Participante, Observador) con permisos específicos por funcionalidad.

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
- **Tema:** La app usa Estilo Base (tema oscuro); ver `docs/ux/estilos/ESTILO_SOFISTICADO.md`. Los colores de referencia que siguen pueden variar en pantalla.
- **Colores** (aprox.):
  - Líneas de la rejilla: `AppColorScheme.gridLineColor` con opacidad (`CalendarConstants.gridLineOpacity`).
  - Eventos: paleta por tipo; borde más oscuro. Texto: contraste automático.
- **Tipografía:** `GoogleFonts.poppins` (calendar_styles.dart). Tamaños: `CalendarConstants.headerFontSize` (14), `participantFontSize` (10), `eventFontSize` (10), `accommodationFontSize` (8). Horas: 12 px.
- **Medidas** (CalendarConstants):
  - Altura por hora: 60 px (`eventRowHeight`).
  - Encabezado: 40 px (`headerHeight`).
  - Alojamientos: 30 px (`accommodationRowHeight`).
  - Columna de horas: 80 px (`hoursColumnWidth`).

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
- **Interacción funcional:** Click para crear/editar alojamiento existente.
- **Iconos visuales:** ➡️ para check-in (primer día), ⬅️ para check-out (último día).
- **Sistema de tracks:** Alojamientos se muestran en tracks de participantes seleccionados.
- **Agrupación:** Alojamientos en tracks consecutivos se muestran como un solo bloque.

Estado: **Funciona** (crear/editar/eliminar completamente operativo).

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
>
> **Regla de Eventos Borradores:**
> - Los eventos en borrador (`isDraft=true`) pueden solaparse entre sí dentro del mismo track
> - Los eventos que NO están en borrador NO pueden solaparse en un mismo track
> - Esta regla permite crear borradores sin restricciones, pero una vez guardados no pueden solaparse con otros eventos confirmados

Estado: **Funciona**.

### Editar Evento
- **Click** sobre un evento abre diálogo de edición con datos actuales.
- Guardar actualiza en Firestore y refresca la UI.

Estado: **Funciona** (interacción de click completamente operativa).

### Eliminar Evento
- Desde el diálogo de edición (botón Eliminar) con confirmación implícita.

Estado: **Funciona** (revisar refresco inmediato de UI en todos los casos).

### Drag & Drop de Eventos
- **Arrastre vertical**: ajusta la hora de inicio; magnetismo a intervalos de 15 minutos.
- **Arrastre horizontal**: mueve entre días; magnetismo a columnas.
- **Visual**: feedback con sombra y traslación suave durante el arrastre; al soltar, se persiste y refresca la UI.
- **Ámbito de plataforma**: esta interacción está habilitada **solo en Web/Dashboard**.
- **Móvil (iOS/Android)**: **sin drag & drop** por decisión de producto; en móvil se edita por tap y diálogo.

Estado: **Funciona en Web** / **No aplica en móvil** (decisión explícita).

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
- En móvil, validar que no hay drag accidental y que tap abre edición correctamente.
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
- **Editar eventos**: Funciona (interacción de click completamente operativa)
- **Eliminar eventos**: Funciona (revisar refresco inmediato)
- **Drag & drop**: Funciona (completamente operativo tras optimizaciones)
- **Multi-día**: Funciona
- **Auto-scroll**: Funciona
- **Alojamientos**: Funciona (crear/editar/eliminar completamente operativo)
- **Encabezado "Día X + fecha"**: Pendiente

---

## ✅ Próximos Pasos Recomendados
1. ✅ **Completado:** Edición y drag & drop funcionan correctamente.
2. ✅ **Completado:** Flujo completo de alojamientos operativo con iconos visuales.
3. Completar encabezado de días con formato "Día X" + fecha (alineado con la UX).
4. Mantener este documento como fuente de verdad; actualizarlo en cada cambio funcional.

---

## 🌍 Visualización de Timezones (T100)

### Indicadores Visuales Implementados
- **Indicador en AppBar**: Icono de reloj (⏰) junto al selector de usuario con formato "Madrid (GMT+1)"
- **Barra lateral de color en tracks**: Barra de 3px en el lado izquierdo de cada track con colores basados en offset UTC
  - América del Oeste: Azul oscuro
  - América Central/Este: Azul medio
  - GMT: Verde
  - Europa: Naranja
  - Asia/Oceanía: Rosa/Morado
- **Tooltips informativos**: 
  - En headers de tracks: muestra timezone completa al hacer hover
  - En eventos: muestra información de timezone de salida y llegada (para vuelos/desplazamientos)

### Ubicación de Indicadores
- Headers mini de participantes
- Celdas de datos (sub-columnas)
- Fila de alojamientos
- AppBar (selector de perspectiva)

Estado: **Funciona** (T100 completada).

---

## 👥 Tracks: Filtros y Reordenación

### Filtros de Vista (Plan Completo / Mi Agenda / Personalizada)
- Selector en AppBar para cambiar de modo de vista.
- Personalizada: diálogo con checkboxes; botón Aplicar refresca inmediatamente la UI.
- Ancho de columnas se ajusta al número de tracks visibles.
Estado: Funciona.

---

## 🔐 Sistema de Permisos Granulares

### Roles de Usuario
- **Administrador**: Acceso completo al plan, puede gestionar participantes, eventos, alojamientos y configuración.
- **Participante**: Puede crear y editar eventos propios, gestionar su información personal.
- **Observador**: Solo lectura, puede ver eventos pero no modificarlos.

### Permisos por Categoría
- **Plan**: Ver, editar, eliminar, gestionar participantes y administradores.
- **Eventos**: Ver, crear, editar propios/cualquiera, eliminar propios/cualquiera, ver/editar información personal de otros.
- **Alojamientos**: Ver, crear, editar propios/cualquiera, eliminar propios/cualquiera.
- **Tracks**: Ver, reordenar, gestionar visibilidad.
- **Filtros**: Usar filtros, guardar filtros personalizados.

### Implementación en UI
- **EventDialog**: Campos editables/readonly según permisos, badges de rol en título, indicadores visuales.
- **Validación**: Verificación de permisos antes de operaciones críticas.
- **Cache**: Permisos cacheados localmente para optimización de rendimiento.
- **Persistencia**: Permisos almacenados en Firestore con soporte para expiración temporal.

Estado: Funciona (T63 completada).

### Reordenación de Tracks (Drag & Drop en diálogo)
- Accesos: botón en AppBar o doble click en iniciales del encabezado.
- Diálogo con ReorderableListView; arrastrar para reordenar.
- Persistencia global por plan en Firestore (`plans/{planId}.trackOrderParticipantIds`); ver `TrackService` (`lib/features/calendar/domain/services/track_service.dart`).
- Aplicación del orden: al iniciar pantalla y tras sincronizar participantes.
Estado: Funciona.

---

*Documento de capacidades del calendario. Última actualización: Febrero 2026 (medidas y tipografía alineadas con CalendarConstants y calendar_styles; tema Estilo Base; sección duplicada de permisos eliminada).*

