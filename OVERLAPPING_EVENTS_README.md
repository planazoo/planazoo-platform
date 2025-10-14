# 🎯 Sistema de Eventos Solapados - Planazoo

## 📋 **Descripción del Problema**

En aplicaciones de calendario, es común que múltiples eventos se solapen en el tiempo. Por ejemplo:
- **Desayuno**: 8:00 - 9:00
- **Visita al museo**: 8:30 - 10:30 (se solapa con desayuno)
- **Tren nocturno**: 22:00 - 06:00 del día siguiente (evento multi-día)

El calendario debe visualizar correctamente estos solapamientos y eventos multi-día.

## 🚀 **Solución Actual: Sistema EventSegment**

### **1. EventSegment - Inspirado en Google Calendar**

El sistema divide eventos multi-día en **segmentos** (uno por día):

```dart
class EventSegment {
  final Event originalEvent;      // Evento original completo
  final DateTime segmentDate;     // Fecha de este segmento
  final int startMinute;          // Minuto de inicio (0-1440)
  final int endMinute;            // Minuto de fin (0-1440)
  final bool isFirst;             // ¿Es el primer segmento?
  final bool isLast;              // ¿Es el último segmento?
  
  String get id => '${originalEvent.id}_segment_${segmentDate.toIso8601String().split('T')[0]}';
  int get durationMinutes => endMinute - startMinute;
}
```

**Ejemplo: Tren nocturno 22:00 - 06:00**
```dart
// Día 1 - Segmento 1 (isFirst: true, isLast: false)
EventSegment(startMinute: 1320, endMinute: 1440) // 22:00 - 23:59

// Día 2 - Segmento 2 (isFirst: false, isLast: true)
EventSegment(startMinute: 0, endMinute: 360)     // 00:00 - 06:00
```

**Ventajas:**
- ✅ **Eventos multi-día** se manejan como eventos normales en cada día
- ✅ **Drag & Drop** solo desde el primer segmento (evita confusión)
- ✅ **Click** en cualquier segmento abre el mismo diálogo
- ✅ **Solapamientos** funcionan correctamente en TODOS los días

### **2. OverlappingSegmentGroup - Detección de Solapamientos**

Agrupa segmentos que se solapan en el tiempo:

```dart
class OverlappingSegmentGroup {
  final List<EventSegment> segments;  // Segmentos que se solapan
  final DateTime date;                // Fecha del grupo
  final int startMinute;              // Minuto de inicio del grupo
  final int endMinute;                // Minuto de fin del grupo
  final int maxOverlap;               // Número máximo de segmentos solapados
  
  static List<OverlappingSegmentGroup> detectOverlappingGroups(List<EventSegment> allSegments) {
    // Algoritmo: BFS para agrupar segmentos conectados
    // Excluye alojamientos del análisis
    // Retorna grupos de segmentos solapados
  }
}
```

**Algoritmo de Detección:**
1. Filtrar segmentos regulares (excluir alojamientos)
2. Ordenar por `startMinute`
3. Para cada segmento no procesado:
   - Usar BFS para encontrar todos los segmentos conectados (que se solapan)
   - Crear grupo con rango total y máximo overlap
4. Retornar lista de grupos

### **3. Regla de Negocio: Máximo 3 Eventos Simultáneos**

**⚠️ LIMITACIÓN CRÍTICA:**
> El calendario permite un **máximo de 3 eventos solapados** en cualquier momento.

**Justificación:**
- ✅ Con 3 eventos: ~33% del ancho cada uno (legible, clickeable)
- ❌ Con 4+ eventos: <25% del ancho (texto ilegible, difícil de arrastrar)

**Validación:**
- ✅ Al **crear** evento nuevo
- ✅ Al **editar** hora/duración
- ✅ Al **arrastrar** evento (drag & drop)

**Indicador Visual:**
- ⚠️ Icono naranja en el último evento cuando hay exactamente 3 solapados

## 🏗️ **Arquitectura del Sistema**

```
┌──────────────────────────────────────────────────────────────────┐
│                    wd_calendar_screen.dart                       │
├──────────────────────────────────────────────────────────────────┤
│  1. _buildEventsLayer()                                          │
│     ├─ Para cada día visible                                    │
│     ├─ _expandEventsToSegments() → List<EventSegment>          │
│     ├─ _detectOverlappingSegments() → List<OverlappingSegmentGroup>│
│     └─ _buildOverlappingSegmentWidgets() → Widgets             │
├──────────────────────────────────────────────────────────────────┤
│  2. _buildSegmentWidget()                                        │
│     ├─ Si isFirst → Draggable (mueve todo el evento)           │
│     ├─ Si !isFirst → Solo clickeable (abre diálogo)            │
│     └─ _formatSegmentTime() → "22:00 - 23:59 +1"              │
├──────────────────────────────────────────────────────────────────┤
│  3. _wouldExceedOverlapLimit()                                   │
│     ├─ Valida regla de máximo 3 eventos                        │
│     ├─ Comprueba minuto a minuto                               │
│     └─ Retorna true si excede límite                           │
└──────────────────────────────────────────────────────────────────┘
```

## 📱 **Ejemplos de Uso**

### **Ejemplo 1: Dos eventos solapados**
```
8:00 - 9:00  │ Desayuno (azul) │
8:30 - 10:30 │ Museo (verde)   │
```

**Resultado visual:**
- Celda dividida en dos columnas
- Evento azul a la izquierda
- Evento verde a la derecha
- Indicador "2 eventos" en esquina superior

### **Ejemplo 2: Tres eventos solapados**
```
12:00 - 13:00 │ Almuerzo (naranja) │
12:30 - 14:30 │ Paseo (morado)     │
13:00 - 14:00 │ Café (amarillo)    │
```

**Resultado visual:**
- Celda dividida en tres columnas
- Espaciado automático entre eventos
- Indicador "3 eventos" en esquina superior
- Colores diferenciados para cada evento

## 🔧 **Implementación Técnica**

### **1. Detección de Solapamientos (Minuto a Minuto)**

```dart
static bool _hasOverlap(int start1, int end1, int start2, int end2) {
  return (start1 < end2) && (end1 > start2);
}
```

**Algoritmo BFS para Grupos:**
1. Filtrar segmentos regulares (excluir `typeFamily == 'alojamiento'`)
2. Ordenar por `startMinute`
3. Para cada segmento no procesado:
   - Iniciar BFS desde ese segmento
   - Cola: segmentos a procesar
   - Buscar todos los segmentos que se solapan con los de la cola
   - Marcar como procesados
4. Crear `OverlappingSegmentGroup` con:
   - `segments`: todos los segmentos del grupo
   - `startMinute`: mínimo de todos
   - `endMinute`: máximo de todos
   - `maxOverlap`: número de segmentos

### **2. Cálculo de Posiciones (Sistema de Columnas)**

```dart
// Para cada segmento en el grupo
final totalWidth = dayColumnWidth;
final segmentWidth = totalWidth / group.maxOverlap;
final segmentIndex = group.segments.indexOf(segment);
final left = dayColumnStart + (segmentIndex * segmentWidth);

// Positioned widget
Positioned(
  left: left,
  top: (segment.startMinute / 60) * cellHeight,
  width: segmentWidth,
  height: (segment.durationMinutes / 60) * cellHeight,
  child: _buildSegmentWidget(segment),
)
```

**Distribución:**
- **Ancho total** dividido equitativamente entre segmentos
- **Sin espaciado** para maximizar espacio clickeable
- **Índice** determina posición horizontal

### **3. Renderizado y Formateo de Tiempo**

```dart
String _formatSegmentTime(EventSegment segment) {
  final startHour = segment.startMinute ~/ 60;
  final startMin = segment.startMinute % 60;
  final endHour = segment.endMinute ~/ 60;
  final endMin = segment.endMinute % 60;
  
  if (!segment.isLast && segment.endMinute == 1440) {
    return '$startHour:${startMin.toString().padLeft(2, '0')} - 23:59 +1';
  }
  
  if (!segment.isFirst && segment.startMinute == 0) {
    return '00:00 - $endHour:${endMin.toString().padLeft(2, '0')}';
  }
  
  return '$startHour:${startMin.toString().padLeft(2, '0')} - '
         '$endHour:${endMin.toString().padLeft(2, '0')}';
}
```

## 🎨 **Personalización Visual**

### **Colores por Tipo de Evento**
- 🔵 **Azul**: Desplazamiento
- 🟢 **Verde**: Actividades
- 🟠 **Naranja**: Restauración
- 🔴 **Rojo**: Eventos especiales
- 🟡 **Amarillo**: Pausas
- 🟣 **Morado**: Actividades culturales

### **Iconos por Subtipo**
- ✈️ **Avión**: Viajes aéreos
- 🚂 **Tren**: Viajes ferroviarios
- 🍽️ **Restaurante**: Comidas
- 🏛️ **Museo**: Actividades culturales
- 🏃 **Deportes**: Actividades físicas

## 📊 **Métricas y Rendimiento**

### **Complejidad Algorítmica**
- **Detección de solapamientos**: O(n²) en peor caso
- **Renderizado**: O(n) por celda
- **Memoria**: O(n) para grupos de eventos

### **Optimizaciones Implementadas**
- ✅ **Cache de grupos** por fecha
- ✅ **Lazy rendering** solo en celdas visibles
- ✅ **Reutilización de widgets** cuando es posible
- ✅ **Validación temprana** de conflictos

## 🧪 **Testing y Demostración**

### **Widget de Demo (`OverlappingEventsDemo`)**
- 📱 **Vista previa** de eventos solapados
- 🎯 **Ejemplos reales** de conflictos
- 📊 **Explicación visual** de la funcionalidad
- 🔧 **Configuración** de diferentes escenarios

### **Casos de Prueba**
1. **Sin eventos solapados**
2. **Dos eventos solapados**
3. **Tres o más eventos solapados**
4. **Eventos de diferentes duraciones**
5. **Eventos que empiezan y terminan juntos**

## 📊 **Estado Actual del Sistema**

### **✅ Completado (T54, T55)**
- ✅ Sistema `EventSegment` para eventos multi-día
- ✅ `OverlappingSegmentGroup` con algoritmo BFS
- ✅ Validación de máximo 3 eventos simultáneos
- ✅ Drag & Drop solo desde primer segmento
- ✅ Click en cualquier segmento abre diálogo
- ✅ Formateo de tiempo inteligente (22:00 - 23:59 +1)
- ✅ Indicador visual de límite alcanzado (⚠️)
- ✅ Plan Frankenstein actualizado para testing

### **📋 Archivos Clave**
- `lib/features/calendar/domain/models/event_segment.dart`
- `lib/features/calendar/domain/models/overlapping_segment_group.dart`
- `lib/widgets/screens/wd_calendar_screen.dart`

### **🧪 Testing**
- Plan Frankenstein (`lib/features/testing/demo_data_generator.dart`)
- Casos de prueba: eventos multi-día, solapamientos, límite de 3

## 🚀 **Próximas Mejoras (Futuro)**

### **Sistema de Tracks (Participantes)**
- 👥 Cada participante = columna (track) en el calendario
- 🎯 Eventos distribuidos por tracks de participantes
- 📊 Vista filtrada por participante individual
- 🔄 Modificación de evento afecta todos los tracks simultáneamente

### **Timezones (T40-T45)**
- 🌍 Sistema "UTC del Plan" con conversión por participante
- ✈️ Eventos cross-timezone (vuelos internacionales)
- 🕐 Timezone por día del plan (viajes multi-destino)

### **Offline First (T56-T62)**
- 📱 CRUD completo sin conexión
- 🔄 Sincronización automática al reconectar
- ⚙️ Resolución automática de conflictos

## 📚 **Referencias y Recursos**

### **Patrones de Diseño Utilizados**
- **Strategy Pattern**: Diferentes estrategias de renderizado
- **Factory Pattern**: Creación de widgets según el tipo
- **Observer Pattern**: Notificaciones de cambios
- **Builder Pattern**: Construcción de layouts complejos

### **Bibliotecas y Dependencias**
- **Flutter**: Framework principal
- **Firebase**: Base de datos y autenticación
- **Provider/Riverpod**: Gestión de estado (futuro)

## 🤝 **Contribución**

### **Cómo Contribuir**
1. **Fork** del repositorio
2. **Crear** rama para nueva funcionalidad
3. **Implementar** cambios con tests
4. **Crear** Pull Request con descripción detallada

### **Estándares de Código**
- **Dart/Flutter**: Seguir guías oficiales
- **Documentación**: Comentarios en inglés
- **Tests**: Cobertura mínima del 80%
- **Performance**: Sin regresiones de rendimiento

---

## 📚 **Referencias**

### **Documentos Relacionados**
- 📖 **[Decisiones Arquitectónicas](docs/ARCHITECTURE_DECISIONS.md)** - Contexto de decisiones del sistema
- 📅 **[Capacidades del Calendario](docs/CALENDAR_CAPABILITIES.md)** - Reglas de negocio y funcionalidades
- 🧟 **[Plan Frankenstein](docs/FRANKENSTEIN_PLAN_SPEC.md)** - Casos de prueba completos
- 📋 **[Tareas](docs/TASKS.md)** - T54 y T55 implementaron este sistema

### **Inspiración**
- **Google Calendar**: Sistema de segmentos para eventos multi-día
- **Algoritmo BFS**: Para agrupar eventos conectados
- **Material Design**: Guidelines de UX para calendarios

## 🎉 **Conclusión**

El sistema EventSegment + OverlappingSegmentGroup proporciona:

✅ **Eventos multi-día** sin complejidad adicional
✅ **Detección precisa** de solapamientos (minuto a minuto)
✅ **Regla de negocio** clara (máximo 3 simultáneos)
✅ **Experiencia consistente** con Google Calendar
✅ **Drag & Drop intuitivo** (solo desde primer segmento)

**Resultado**: Un calendario profesional, legible y funcional para planificar viajes complejos con múltiples actividades, incluyendo transportes nocturnos y eventos que cruzan días.

---

**Última actualización:** Diciembre 2024  
**Versión del sistema:** 2.0 (EventSegment)  
**Estado:** ✅ Completado y funcional
