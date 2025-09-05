# 🎯 Sistema de Eventos Solapados - UNP Calendario

## 📋 **Descripción del Problema**

En aplicaciones de calendario, es común que múltiples eventos se solapen en el tiempo. Por ejemplo:
- **Desayuno**: 8:00 - 9:00
- **Visita al museo**: 8:30 - 10:30 (se solapa con desayuno)

El sistema anterior solo mostraba **UN evento por celda**, ocultando los conflictos de horarios.

## 🚀 **Solución Implementada**

### **1. Modelo de Grupos Solapados (`OverlappingEventGroup`)**

```dart
class OverlappingEventGroup {
  final List<Event> events;        // Lista de eventos que se solapan
  final DateTime date;             // Fecha del grupo
  final int startHour;             // Hora de inicio más temprana
  final int endHour;               // Hora de fin más tardía
  final int maxOverlap;            // Número máximo de eventos solapados
}
```

**Funcionalidades:**
- ✅ **Detección automática** de eventos solapados
- ✅ **Agrupación inteligente** por rangos de tiempo
- ✅ **Cálculo de posiciones** para visualización
- ✅ **Validación de conflictos** en tiempo real

### **2. Widget de Celdas Solapadas (`OverlappingEventsCell`)**

**Características visuales:**
- 🎨 **Colores diferenciados** para cada evento
- 📱 **Layout responsivo** que se adapta al número de eventos
- 🔍 **Indicadores visuales** de conflicto
- ⚡ **Interacción táctil** individual para cada evento

**Comportamiento:**
- Si hay **1 evento**: Usa `EventCell` normal
- Si hay **múltiples eventos**: Crea layout superpuesto
- **Posicionamiento automático** para evitar superposición

### **3. Indicadores Visuales (`OverlapIndicator`)**

- 🔴 **Círculo naranja** con número de eventos solapados
- 📏 **Líneas de continuación** para eventos largos
- 🎯 **Bordes especiales** para celdas con conflictos

## 🏗️ **Arquitectura del Sistema**

```
┌─────────────────────────────────────────────────────────────┐
│                    CalendarPage                             │
├─────────────────────────────────────────────────────────────┤
│  _getOverlappingGroupForCell() → OverlappingEventGroup     │
├─────────────────────────────────────────────────────────────┤
│  cellBuilder:                                               │
│  ├─ Sin eventos → Container vacío                          │
│  ├─ 1 evento → EventCell                                   │
│  └─ Múltiples eventos → OverlappingEventsCell              │
└─────────────────────────────────────────────────────────────┘
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

### **1. Detección de Solapamientos**

```dart
static bool _hasOverlap(int start1, int end1, int start2, int end2) {
  return (start1 <= end2) && (end1 >= start2);
}
```

**Algoritmo:**
1. Ordenar eventos por hora de inicio
2. Para cada evento, buscar otros que se solapen
3. Crear grupos de eventos conectados
4. Calcular rangos totales de cada grupo

### **2. Cálculo de Posiciones**

```dart
// Distribuir ancho disponible
final eventWidth = (width * 0.8) / activeEvents.length;
final spacing = (width * 0.2) / (activeEvents.length + 1);

// Posicionar cada evento
final eventLeft = spacing + (index * (eventWidth + spacing));
```

**Fórmula:**
- **80% del ancho** para eventos
- **20% del ancho** para espaciado
- **Posicionamiento uniforme** sin superposición

### **3. Renderizado Inteligente**

```dart
// Si solo hay un evento, usar EventCell normal
if (overlappingGroup.maxOverlap == 1) {
  return EventCell(...);
}

// Si hay múltiples eventos, usar OverlappingEventsCell
if (overlappingGroup.maxOverlap > 1) {
  return OverlappingEventsCell(...);
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

## 🚀 **Próximas Mejoras**

### **Fase 2: Funcionalidades Avanzadas**
- 🔄 **Drag & Drop** entre eventos solapados
- 📱 **Gestos táctiles** para reorganizar
- 🎨 **Temas personalizables** de colores
- 📊 **Estadísticas** de conflictos de horarios

### **Fase 3: Inteligencia Artificial**
- 🤖 **Sugerencias automáticas** para resolver conflictos
- 📅 **Optimización automática** de horarios
- 🚨 **Alertas inteligentes** de conflictos
- 📈 **Análisis predictivo** de uso del tiempo

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

## 🎉 **Conclusión**

El sistema de eventos solapados transforma la experiencia del usuario al:

✅ **Mostrar todos los eventos** sin ocultar conflictos
✅ **Proporcionar visualización clara** de horarios
✅ **Mantener la interactividad** individual de cada evento
✅ **Escalar automáticamente** según la complejidad

**Resultado**: Un calendario más inteligente, visual y útil para planificar viajes complejos con múltiples actividades simultáneas.
