# Documentación de Eventos - Calendario

## 📋 Índice
1. [Conceptos Básicos](#conceptos-básicos)
2. [Propiedades del Evento](#propiedades-del-evento)
3. [Estados del Evento](#estados-del-evento)
4. [Interacciones del Usuario](#interacciones-del-usuario)
5. [Visualización](#visualización)
6. [Validaciones y Límites](#validaciones-y-límites)
7. [Estados de Error](#estados-de-error)

---

## 🎯 Conceptos Básicos

### ¿Qué es un Evento?
Un evento es una unidad de contenido que representa una actividad, tarea o cita programada en el calendario. Cada evento ocupa un período de tiempo específico y puede interactuar con otros eventos de diversas maneras.

### Características Principales
- **Temporalidad**: Cada evento tiene una hora de inicio y una duración específica
- **Posicionamiento**: Se ubica en una fecha y hora específicas del calendario
- **Interactividad**: Permite múltiples operaciones (crear, editar, mover, redimensionar, eliminar)
- **Visualización**: Se representa gráficamente con colores y estilos distintivos

---

## 🏷️ Propiedades del Evento

### Propiedades Obligatorias
- **`id`**: Identificador único del evento (String)
- **`description`**: Descripción o título del evento (String)
- **`date`**: Fecha del evento (DateTime)
- **`hour`**: Hora de inicio (int, 0-23)
- **`duration`**: Duración en horas (int, 1-24)

### Propiedades Opcionales
- **`color`**: Color del evento (String, por defecto 'blue')
- **`typeFamily`**: Familia del tipo de evento (String: 'transporte', 'alojamiento', 'actividad', 'restauracion')
- **`typeSubtype`**: Subtipo específico del evento (String: 'taxi', 'avion', 'comida', 'museo', etc.)
- **`details`**: Detalles específicos por tipo (Map<String, dynamic>)
- **`documents`**: Documentos adjuntos (List<EventDocument>)
- **`isDraft`**: Indica si el evento es un borrador (bool, por defecto false)
- **`planId`**: ID del plan al que pertenece (String)
- **`createdAt`**: Fecha de creación (DateTime)
- **`updatedAt`**: Fecha de última actualización (DateTime)

### Ejemplo de Estructura
```dart
Event(
  id: 'event_123',
  description: 'Reunión de equipo',
  date: DateTime(2024, 1, 15),
  hour: 9,
  duration: 2,
  color: 'blue',
  planId: 'plan_456',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
)
```

---

## 🔄 Estados del Evento

### 1. Evento Individual
- **Definición**: Evento que no comparte espacio temporal con otros eventos
- **Visualización**: Ocupa todo el ancho de la celda
- **Comportamiento**: Funcionalidades completas disponibles

### 2. Evento Solapado
- **Definición**: Evento que comparte espacio temporal con otros eventos
- **Visualización**: Se distribuye horizontalmente con otros eventos solapados
- **Comportamiento**: Funcionalidades adaptadas al espacio compartido

### 3. Evento en Borrador
- **Definición**: Evento no confirmado, en estado de edición
- **Visualización**: Colores grises según tipo + texto "BORRADOR"
- **Comportamiento**: Funcionalidades completas + opción de confirmar

### 4. Evento Vacío
- **Definición**: Celda sin eventos
- **Visualización**: Fondo gris claro (#FAFAFA)
- **Comportamiento**: Permite crear nuevos eventos al hacer clic

---

## 🖱️ Interacciones del Usuario

### 1. Crear Evento
- **Trigger**: Clic en celda vacía
- **Proceso**: 
  1. Abre diálogo de creación
  2. Usuario completa información
  3. Valida datos
  4. Guarda en Firestore
  5. Actualiza calendario
- **Resultado**: Nuevo evento visible en el calendario

### 2. Editar Evento
- **Trigger**: Clic en evento existente
- **Proceso**:
  1. Abre diálogo con datos actuales
  2. Usuario modifica información
  3. Valida cambios
  4. Actualiza en Firestore
  5. Refresca visualización
- **Resultado**: Evento actualizado con nuevos datos

### 3. Eliminar Evento
- **Trigger**: Botón eliminar en diálogo
- **Proceso**:
  1. Confirma eliminación
  2. Elimina de Firestore
  3. Actualiza estado local
  4. Refresca calendario
- **Resultado**: Evento removido del calendario

### 4. Drag & Drop Vertical
- **Trigger**: Arrastrar evento verticalmente
- **Proceso**:
  1. Detecta inicio de arrastre
  2. Calcula nueva hora basada en posición
  3. Valida límites (0-23h)
  4. Actualiza evento
  5. Refresca visualización
- **Resultado**: Evento movido a nueva hora

### 5. Drag & Drop Horizontal
- **Trigger**: Arrastrar evento horizontalmente
- **Proceso**:
  1. Detecta inicio de arrastre
  2. Calcula nueva fecha basada en posición
  3. Valida límites de calendario
  4. Actualiza evento
  5. Refresca visualización
- **Resultado**: Evento movido a nueva fecha

### 6. Resize (Botones +/-)
- **Trigger**: Clic en botones + o - en última hora del evento
- **Proceso**:
  1. Detecta clic en botón
  2. Calcula nueva duración
  3. Valida límites (1-24h)
  4. Actualiza evento
  5. Refresca visualización
- **Resultado**: Evento redimensionado

### 7. Confirmar Borrador
- **Trigger**: Botón "Confirmar" en diálogo de evento borrador
- **Proceso**:
  1. Cambia estado de borrador a confirmado
  2. Actualiza en Firestore
  3. Refresca visualización
  4. Muestra mensaje de confirmación
- **Resultado**: Evento confirmado con colores normales

### 8. Marcar como Borrador
- **Trigger**: Botón "Marcar como Borrador" en diálogo de evento confirmado
- **Proceso**:
  1. Cambia estado de confirmado a borrador
  2. Actualiza en Firestore
  3. Refresca visualización
  4. Muestra mensaje de confirmación
- **Resultado**: Evento en borrador con colores grises

---

## 🎨 Visualización

### Colores de Eventos

#### Eventos Confirmados
- **Transporte**: `#2196F3` (Azul) - Vuelos, taxis, transporte público
- **Alojamiento**: `#4CAF50` (Verde) - Hoteles, apartamentos, hostales
- **Actividad**: `#FF9800` (Naranja) - Museos, tours, entretenimiento
- **Restauración**: `#F44336` (Rojo) - Restaurantes, bares, cafés
- **Por defecto**: `#9C27B0` (Púrpura) - Otros tipos

#### Eventos en Borrador
- **Transporte**: `#9E9E9E` (Gris azulado)
- **Alojamiento**: `#8D8D8D` (Gris verdoso)
- **Actividad**: `#A0A0A0` (Gris anaranjado)
- **Restauración**: `#B0B0B0` (Gris rojizo)
- **Por defecto**: `#9A9A9A` (Gris púrpura)

#### Estados Especiales
- **Gris Vacío**: `#FAFAFA` - Celdas sin eventos
- **Indicador Borrador**: Texto "BORRADOR" en blanco sobre fondo gris

### Colores de Texto
- **Eventos Confirmados**: `#FFFFFF` (Blanco) - Texto legible sobre fondos de color
- **Eventos en Borrador**: `#616161` (Gris oscuro) - Texto legible sobre fondos grises
- **Indicador Borrador**: `#FFFFFF` (Blanco) - Siempre visible sobre fondo gris

### Distribución de Eventos Solapados
- **2 eventos**: Cada uno ocupa 50% del ancho
- **3 eventos**: Cada uno ocupa 33.33% del ancho
- **4+ eventos**: Distribución proporcional

### Posicionamiento
- **Altura**: 60px por celda de hora
- **Ancho**: Variable según número de eventos solapados
- **Posición**: Calculada dinámicamente basada en índice

### Visualización de Eventos Multi-hora
- **Primera hora**: Muestra descripción completa + indicador "BORRADOR" (si aplica)
- **Horas intermedias**: Solo color de fondo, sin texto
- **Última hora**: Botones de resize (+/-) si está habilitado
- **Lógica**: `widget.hour == widget.event!.hour` para primera hora

### Bordes de Eventos Multi-hora
- **Evento de 1 hora**: Borde uniforme completo con todas las esquinas redondeadas (8px)
- **Primera hora multi-hora**: Borde uniforme con esquinas superiores redondeadas (8px)
- **Horas intermedias**: Borde uniforme sin esquinas redondeadas
- **Última hora multi-hora**: Borde uniforme con esquinas inferiores redondeadas (8px)
- **Implementación**: `Border.all()` uniforme + `BorderRadius` específico por posición
- **Resultado**: Apariencia de recuadro continuo con esquinas suaves en los extremos

### Botones de Resize
- **Posición**: Esquina inferior derecha de la última hora del evento
- **Estilo**: Botones circulares con iconos + y -
- **Visibilidad**: Solo en la última hora del evento
- **Cursor**: `SystemMouseCursors.click`

---

## ✅ Validaciones y Límites

### Límites de Duración
- **Mínimo**: 1 hora
- **Máximo**: 24 horas
- **Validación**: Se aplica en tiempo real

### Límites de Horario
- **Hora de inicio**: 0-23
- **Hora de fin**: No puede exceder 23:59
- **Validación**: Se aplica en drag & drop

### Límites de Fecha
- **Fecha mínima**: Fecha actual del calendario
- **Fecha máxima**: Límite del calendario visible
- **Validación**: Se aplica en drag & drop horizontal

### Validaciones de Datos
- **Descripción**: No puede estar vacía
- **ID**: Debe ser único
- **Plan ID**: Debe existir en el sistema

---

## ⚠️ Estados de Error

### Error de Creación
- **Causa**: Datos inválidos o error de conexión
- **Comportamiento**: Muestra mensaje de error, no crea evento
- **Recuperación**: Usuario puede reintentar

### Error de Actualización
- **Causa**: Evento no encontrado o error de conexión
- **Comportamiento**: Mantiene estado anterior, muestra error
- **Recuperación**: Usuario puede reintentar

### Error de Eliminación
- **Causa**: Evento no encontrado o error de conexión
- **Comportamiento**: Mantiene evento, muestra error
- **Recuperación**: Usuario puede reintentar

### Error de Drag & Drop
- **Causa**: Posición inválida o error de conexión
- **Comportamiento**: Revierte a posición original
- **Recuperación**: Usuario puede reintentar

---

## 🔧 Implementación Técnica

### Archivos Principales
- **`wd_event_cell.dart`**: Widget principal del evento
- **`wd_event_dialog.dart`**: Diálogo de creación/edición
- **`event_service.dart`**: Servicio de Firestore
- **`calendar_notifier.dart`**: Gestión de estado
- **`color_utils.dart`**: Utilidades de colores y visualización

### Dependencias
- **Riverpod**: Gestión de estado
- **Firebase**: Persistencia de datos
- **Flutter**: Framework de UI

### Patrones Utilizados
- **State Management**: Riverpod con StateNotifier
- **Repository Pattern**: EventService para datos
- **Observer Pattern**: Notificaciones de cambios
- **Command Pattern**: Operaciones de evento

### Métodos de Visualización
- **`_isFirstHourOfEvent()`**: Verifica si es la primera hora del evento
- **`_isLastHourOfEvent()`**: Verifica si es la última hora del evento
- **`_getBorderRadius()`**: Calcula esquinas redondeadas específicas según posición (8px)
- **`_getEventBorder()`**: Crea borde uniforme para evitar conflictos con BorderRadius
- **`ColorUtils.getEventColor()`**: Obtiene color de fondo según tipo y estado
- **`ColorUtils.getEventTextColor()`**: Obtiene color de texto según estado
- **`ColorUtils.getEventBackgroundColor()`**: Obtiene color de fondo con transparencia
- **`ColorUtils.getEventBorderColor()`**: Obtiene color de borde

---

## 📝 Notas de Desarrollo

### Consideraciones de UX
- **Feedback Visual**: Cursor cambia según acción disponible
- **Responsividad**: Eventos se adaptan al tamaño de pantalla
- **Accesibilidad**: Controles claros y predecibles
- **Legibilidad**: Texto visible solo en primera hora para evitar duplicación
- **Consistencia**: Colores de texto apropiados para cada estado
- **Apariencia Continua**: Eventos multi-hora se ven como recuadros unificados
- **Estabilidad Visual**: Sin errores de renderizado que interrumpan la experiencia

### Consideraciones de Rendimiento
- **Lazy Loading**: Eventos se cargan según necesidad
- **Optimistic Updates**: Cambios se reflejan inmediatamente
- **Debouncing**: Operaciones se agrupan para eficiencia

### Consideraciones de Mantenimiento
- **Código Limpio**: Sin debug prints en producción
- **Separación de Responsabilidades**: Lógica separada por capas
- **Documentación**: Código bien documentado y comentado

### Limitaciones Técnicas y Soluciones
- **BorderRadius con Bordes Parciales**: Flutter no permite borderRadius con bordes de colores diferentes
- **Solución Implementada**: Bordes uniformes (`Border.all()`) para todos los eventos
- **Trade-off**: Eventos multi-hora sin esquinas redondeadas para mantener estabilidad
- **Beneficio**: Apariencia de recuadro continuo sin errores de renderizado
