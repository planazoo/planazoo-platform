# 📅 Documentación del Calendario - UX y Funcionamiento

## 🎯 Propósito
Este documento describe detalladamente cada elemento visual del calendario, su comportamiento y su función dentro de la aplicación. Incluye todos los detalles técnicos necesarios para replicar la UX: colores, tipografías, posiciones, tamaños y comportamientos.

---

## 📱 El Calendario en la Aplicación

### ¿Dónde aparece?
El calendario se muestra en el área **W31** de la aplicación principal, que ocupa las columnas C6-C17 y las filas R3-R12. Es la pantalla principal cuando se selecciona un plan.

### ¿Qué ocupa?
- **Ancho**: Desde la columna C6 hasta C17 (12 columnas)
- **Alto**: Desde la fila R3 hasta R12 (10 filas)
- **Debajo**: El área W30 (C6-C17, R13) queda visible por debajo del calendario

---

## 🎨 Elementos Visuales del Calendario

### **APPBAR_HEADER**
**¿Qué es?** Barra superior completa del calendario con controles.

**Especificaciones técnicas:**
- **Color de fondo**: `#2196F3` (azul Material Design)
- **Altura**: 56px
- **Ancho**: 100% del área W31
- **Posición**: Fija en la parte superior del calendario
- **Elevación**: 4px (sombra sutil)

### **APPBAR_TITLE**
**¿Qué es?** Título del plan en el centro de la AppBar.

**Especificaciones técnicas:**
- **Texto**: Nombre del plan seleccionado
- **Color**: `#FFFFFF` (blanco)
- **Tipografía**: `Roboto`, `fontWeight: FontWeight.bold`, `fontSize: 18`
- **Posición**: Centrado horizontalmente en la AppBar
- **Comportamiento**: Se actualiza automáticamente al cambiar de plan

### **APPBAR_ACCOMMODATION_BTN**
**¿Qué es?** Botón de alojamiento (ícono hotel) en la AppBar.

**Especificaciones técnicas:**
- **Ícono**: `Icons.hotel`
- **Color**: `#FFFFFF` (blanco)
- **Tamaño**: 24px
- **Posición**: 16px desde el borde izquierdo
- **Comportamiento**: Al hacer clic abre diálogo para crear alojamiento
- **Hover**: Color cambia a `#E3F2FD` (azul muy claro)

### **APPBAR_REMOVE_DAY_BTN**
**¿Qué es?** Botón para eliminar día del plan.

**Especificaciones técnicas:**
- **Ícono**: `Icons.remove`
- **Color**: `#FFFFFF` (blanco) cuando activo, `#9E9E9E` (gris) cuando inactivo
- **Tamaño**: 24px
- **Posición**: 8px desde el botón de alojamiento
- **Comportamiento**: Elimina el último día del plan (siempre por detrás)
- **Estado**: Inactivo cuando `columnCount <= 1` (mínimo de 1 día)

### **APPBAR_ADD_DAY_BTN**
**¿Qué es?** Botón para añadir día al plan.

**Especificaciones técnicas:**
- **Ícono**: `Icons.add`
- **Color**: `#FFFFFF` (blanco)
- **Tamaño**: 24px
- **Posición**: 8px desde el botón de eliminar día
- **Comportamiento**: Añade un nuevo día al final del plan (siempre por detrás)

### **APPBAR_DATE_SELECTOR**
**¿Qué es?** Selector de fecha para cambiar la fecha de inicio del plan.

**Especificaciones técnicas:**
- **Tipo**: `DateSelector` (widget personalizado)
- **Color del texto**: `#FFFFFF` (blanco)
- **Color de fondo**: `#1976D2` (azul más oscuro)
- **Tipografía**: `Roboto`, `fontSize: 16`
- **Posición**: 16px desde el borde derecho
- **Comportamiento**: Al hacer clic abre el selector de fecha nativo

---

## 📊 La Tabla Principal del Calendario

### **CALENDAR_TABLE**
**¿Qué es?** Tabla principal que contiene todos los elementos del calendario.

**Especificaciones técnicas:**
- **Tipo**: `Table` con `TableBorder.all(color: Colors.grey.shade300)`
- **Ancho**: 100% del área disponible
- **Alto**: Variable según el contenido
- **Bordes**: `Colors.grey.shade300` (gris claro)
- **Estructura**: Dividida en filas fijas y filas con scroll

### **CALENDAR_HEADER_ROW**
**¿Qué es?** Fila de encabezados que muestra los días del plan.

**Especificaciones técnicas:**
- **Color de fondo**: `Colors.blue.shade100` (`#BBDEFB`)
- **Altura**: 50px
- **Posición**: Fija en la parte superior (no se mueve con scroll)
- **Bordes**: `Colors.grey.shade300`

#### **CALENDAR_HOURS_COLUMN_HEADER**
**¿Qué es?** Celda de la columna de horas en el encabezado.

**Especificaciones técnicas:**
- **Texto**: "Hora"
- **Color**: `#000000` (negro)
- **Tipografía**: `Roboto`, `fontWeight: FontWeight.bold`, `fontSize: 12`
- **Ancho**: 80px (fijo)
- **Alineación**: Centrado

#### **CALENDAR_DAY_COLUMN_HEADER**
**¿Qué es?** Celda de encabezado para cada día del plan.

**Especificaciones técnicas:**
- **Texto superior**: Nombre del día (ej: "Lunes")
  - **Color**: `#000000` (negro)
  - **Tipografía**: `Roboto`, `fontWeight: FontWeight.bold`, `fontSize: 10`
- **Texto inferior**: "Día X - DD/MM/YYYY"
  - **Color**: `#2196F3` (azul)
  - **Tipografía**: `Roboto`, `fontSize: 6`
- **Ancho**: Variable según el número de columnas
- **Alineación**: Centrado vertical y horizontal

### **CALENDAR_ACCOMMODATION_ROW**
**¿Qué es?** Fila que muestra los alojamientos para cada día.

**Especificaciones técnicas:**
- **Color de fondo**: `Colors.green.shade50` (`#E8F5E8`)
- **Altura**: 40px
- **Posición**: Fija debajo del encabezado (no se mueve con scroll)
- **Bordes**: `Colors.grey.shade300`

#### **CALENDAR_ACCOMMODATION_LABEL**
**¿Qué es?** Etiqueta "Alojamiento" en la columna de horas.

**Especificaciones técnicas:**
- **Texto**: "Alojamiento"
- **Color**: `#000000` (negro)
- **Tipografía**: `Roboto`, `fontWeight: FontWeight.bold`, `fontSize: 12`
- **Ancho**: 80px (fijo)
- **Alineación**: Centrado

#### **CALENDAR_ACCOMMODATION_CELL**
**¿Qué es?** Celda que muestra un alojamiento para un día específico.

**Especificaciones técnicas:**
- **Color de fondo**: `Colors.green` (verde) por defecto, o color personalizado del alojamiento
- **Altura**: 40px
- **Ancho**: Variable según el número de columnas
- **Bordes**: `BorderRadius.circular(4)`
- **Margen**: 2px en todos los lados
- **Padding**: 8px en todos los lados
- **Texto**: Nombre del hotel
  - **Color**: `#FFFFFF` (blanco)
  - **Tipografía**: `Roboto`, `fontSize: 12`
  - **Máximo líneas**: 2
  - **Overflow**: `TextOverflow.ellipsis`

### **CALENDAR_DATA_ROWS**
**¿Qué es?** Filas que muestran las horas del día (0:00 a 23:00).

**Especificaciones técnicas:**
- **Número de filas**: 24 (una por cada hora)
- **Altura por fila**: 60px (`AppConstants.cellHeight`)
- **Comportamiento**: Con scroll vertical
- **Posición**: Debajo de las filas fijas

#### **CALENDAR_HOURS_COLUMN**
**¿Qué es?** Columna fija que muestra las horas.

**Especificaciones técnicas:**
- **Ancho**: 80px (fijo)
- **Color de fondo**: `Colors.grey.shade50` (`#FAFAFA`)
- **Bordes**: `Colors.grey.shade300`
- **Padding**: 4px en todos los lados

#### **CALENDAR_HOUR_CELL**
**¿Qué es?** Celda individual que muestra una hora específica.

**Especificaciones técnicas:**
- **Texto**: Formato "HH:00" (ej: "00:00", "01:00")
- **Color**: `#000000` (negro)
- **Tipografía**: `Roboto`, `fontSize: 12`
- **Altura**: 60px
- **Alineación**: Centrado

#### **CALENDAR_DAY_COLUMN**
**¿Qué es?** Columna que representa un día específico del plan.

**Especificaciones técnicas:**
- **Ancho**: Variable según el número de columnas
- **Cálculo**: `availableWidth / (columnCount - 1)`
- **Máximo visible**: 5 columnas sin scroll horizontal
- **Scroll horizontal**: Se activa cuando hay más de 5 columnas

#### **CALENDAR_EVENT_CELL**
**¿Qué es?** Celda que puede contener un evento, eventos solapados o estar vacía.

**Especificaciones técnicas:**
- **Altura**: 60px
- **Ancho**: Variable según el número de columnas
- **Bordes**: `Colors.grey.shade300`
- **Comportamiento**: Click para crear/editar eventos

##### **CALENDAR_EMPTY_CELL**
**¿Qué es?** Celda vacía sin eventos.

**Especificaciones técnicas:**
- **Color de fondo**: `Colors.transparent` (transparente)
- **Ícono**: `Icons.add` (ícono de más)
- **Color del ícono**: `#9E9E9E` (gris)
- **Tamaño del ícono**: 16px
- **Comportamiento**: Click para crear nuevo evento

##### **CALENDAR_SINGLE_EVENT_CELL**
**¿Qué es?** Celda con un evento individual.

**Especificaciones técnicas:**
- **Color de fondo**: `Colors.blue` (azul) por defecto, o color personalizado del evento
- **Bordes**: `BorderRadius.circular(4)`
- **Margen**: 1px en todos los lados
- **Padding**: 4px en todos los lados
- **Texto**: Descripción del evento
  - **Color**: `#FFFFFF` (blanco)
  - **Tipografía**: `Roboto`, `fontSize: 10`, `fontWeight: FontWeight.bold`
  - **Máximo líneas**: 2
  - **Overflow**: `TextOverflow.ellipsis`
  - **Alineación**: Centrado
- **Comportamiento**: 
  - **Click**: Abre diálogo de edición
  - **Drag**: Mueve el evento a otra hora
  - **Resize**: Cambia la duración del evento

##### **CALENDAR_OVERLAPPING_EVENTS_CELL**
**¿Qué es?** Celda con múltiples eventos solapados.

**Especificaciones técnicas:**
- **Color de fondo**: `Colors.orange.withValues(alpha: 0.1)` (naranja transparente)
- **Bordes**: `Colors.orange`, `width: 2`
- **Bordes redondeados**: `BorderRadius.circular(4)`
- **Altura**: 40px
- **Indicador de solapamiento**:
  - **Posición**: Esquina superior derecha
  - **Color de fondo**: `Colors.orange`
  - **Bordes redondeados**: `BorderRadius.circular(8)`
  - **Padding**: 4px horizontal, 2px vertical
  - **Texto**: Número de eventos solapados
  - **Color del texto**: `#FFFFFF` (blanco)
  - **Tipografía**: `Roboto`, `fontSize: 10`, `fontWeight: FontWeight.bold`

---

## 🔄 Comportamientos y Interacciones

### **Scroll Horizontal**
**¿Cuándo se activa?** Cuando hay más de 5 columnas de días.

**Especificaciones técnicas:**
- **Ancho de columna**: 120px fijo cuando hay scroll
- **Indicador visual**: Barra de scroll nativa del sistema
- **Comportamiento**: Solo las columnas de días se mueven, la columna de horas permanece fija

### **Scroll Vertical**
**¿Cuándo se activa?** Siempre activo para las filas de datos (horas).

**Especificaciones técnicas:**
- **Área de scroll**: Solo las filas de datos (0:00 a 23:00)
- **Filas fijas**: Encabezado y fila de alojamientos permanecen visibles
- **Indicador visual**: Barra de scroll nativa del sistema

### **Drag & Drop de Eventos**
**¿Cómo funciona?** Los eventos se pueden arrastrar verticalmente para cambiar su hora.

**Especificaciones técnicas:**
- **Inicio**: `onPanStart` detecta el inicio del arrastre
- **Durante**: `onPanUpdate` actualiza la posición visual
- **Final**: `onPanEnd` confirma la nueva posición
- **Feedback visual**:
  - **Borde**: `Colors.white`, `width: 2`
  - **Sombra**: `Colors.black.withValues(alpha: 0.3)`, `blurRadius: 8`, `offset: Offset(0, 4)`
  - **Transformación**: `Matrix4.translationValues(0, _dragOffset, 0)`

### **Resize de Eventos**
**¿Cómo funciona?** Los eventos se pueden redimensionar verticalmente para cambiar su duración.

**Especificaciones técnicas:**
- **Handle**: Barra en la parte inferior del evento
- **Color**: `Colors.white.withValues(alpha: 0.7)`
- **Altura**: 4px
- **Ícono**: `Icons.drag_handle`, `size: 12`
- **Comportamiento**: `onPanStart`, `onPanUpdate`, `onPanEnd`

---

## 📱 Responsive Design

### **Adaptación al Ancho**
**¿Cómo se calcula?** El ancho de las columnas se adapta al espacio disponible.

**Fórmula:**
```
availableWidth = constraints.maxWidth - 80px (columna de horas)
cellWidth = availableWidth / (columnCount - 1)
```

### **Límites de Columnas**
- **Mínimo**: 1 columna (un día)
- **Máximo**: Sin límite (limitado por el rendimiento)
- **Scroll horizontal**: Se activa automáticamente cuando hay más de 5 columnas

### **Altura del Calendario**
**¿Cómo se limita?** El calendario se limita al área W31.

**Especificaciones técnicas:**
- **Área W31**: C6-C17, R3-R12
- **No invade W30**: El área W30 (R13) permanece visible
- **Scroll vertical**: Solo dentro del área W31

---

## 🎨 Paleta de Colores

### **Colores Principales**
- **Azul principal**: `#2196F3` (Material Design Blue)
- **Azul oscuro**: `#1976D2` (Material Design Blue 700)
- **Azul claro**: `#BBDEFB` (Material Design Blue 100)
- **Verde**: `#4CAF50` (Material Design Green)
- **Naranja**: `#FF9800` (Material Design Orange)
- **Gris claro**: `#9E9E9E` (Material Design Grey 500)
- **Gris muy claro**: `#FAFAFA` (Material Design Grey 50)

### **Colores de Texto**
- **Texto principal**: `#000000` (negro)
- **Texto sobre fondo oscuro**: `#FFFFFF` (blanco)
- **Texto secundario**: `#2196F3` (azul)

### **Colores de Bordes**
- **Bordes estándar**: `#E0E0E0` (gris claro)
- **Bordes de eventos solapados**: `#FF9800` (naranja)

---

## 📏 Medidas y Espaciados

### **Alturas**
- **AppBar**: 56px
- **Fila de encabezado**: 50px
- **Fila de alojamientos**: 40px
- **Celda de hora**: 60px
- **Handle de resize**: 4px

### **Anchos**
- **Columna de horas**: 80px (fijo)
- **Columna de día (sin scroll)**: Variable según el espacio disponible
- **Columna de día (con scroll)**: 120px (fijo)

### **Espaciados**
- **Padding estándar**: 8px
- **Padding pequeño**: 4px
- **Margen de eventos**: 1px
- **Margen de alojamientos**: 2px

---

## 🔧 Funcionalidades Implementadas

### **✅ Gestión de Días**
- **Añadir día**: Botón "+" en la AppBar
- **Eliminar día**: Botón "-" en la AppBar (mínimo 1 día)
- **Cambiar fecha de inicio**: Selector de fecha en la AppBar

### **✅ Gestión de Eventos**
- **Crear evento**: Click en celda vacía
- **Editar evento**: Click en evento existente
- **Mover evento**: Drag & drop vertical
- **Redimensionar evento**: Resize handle en la parte inferior
- **Eliminar evento**: Desde el diálogo de edición

### **✅ Gestión de Alojamientos**
- **Crear alojamiento**: Botón de hotel en la AppBar
- **Ver alojamientos**: Se muestran en la fila correspondiente
- **Editar alojamiento**: Click en alojamiento existente

### **✅ Eventos Solapados**
- **Detección automática**: Cuando hay múltiples eventos en la misma hora
- **Visualización especial**: Color naranja y contador
- **Gestión individual**: Cada evento se puede editar por separado

### **✅ Scroll y Navegación**
- **Scroll horizontal**: Para más de 5 columnas
- **Scroll vertical**: Para las 24 horas del día
- **Filas fijas**: Encabezado y alojamientos siempre visibles

---

## 📝 Notas de Desarrollo

### **Última actualización**: Diciembre 2024

### **Estado actual**: ✅ Funcional
- Todas las funcionalidades básicas implementadas
- UI responsive y adaptativa
- Gestión completa de eventos y alojamientos
- Drag & drop y resize funcionando
- Eventos solapados detectados y mostrados correctamente

### **Próximas mejoras sugeridas**:
- Indicador visual más claro para el scroll horizontal
- Animaciones suaves para las transiciones
- Mejoras en la accesibilidad
- Optimización del rendimiento para muchos eventos
