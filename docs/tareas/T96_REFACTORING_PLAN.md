# 📋 Plan de Refactorización T96 - CalendarScreen

> **Objetivo:** Dividir `wd_calendar_screen.dart` (4424 líneas) en componentes más pequeños y mantenibles

## 📊 Análisis Actual

### **Estado del Archivo:**
- **Líneas totales:** ~4084 (reducido de 4424, ~340 líneas extraídas)
- **Componentes ya extraídos:**
  - ✅ `calendar_app_bar.dart` - AppBar del calendario
  - ✅ `calendar_utils.dart` - Utilidades y helpers
  - ✅ `calendar_filters.dart` - Sistema de filtros
  - ✅ `calendar_event_logic.dart` - Lógica de eventos
  - ✅ `calendar_accommodation_logic.dart` - Lógica de alojamientos
  - ✅ `calendar_styles.dart` - Estilos
  - ✅ `calendar_navigation.dart` - Navegación
  - ✅ `calendar_validations.dart` - Validaciones
  - ✅ `calendar_calculations.dart` - Cálculos
  - ✅ `calendar_track_reorder.dart` - Reordenación de tracks
  - ✅ `calendar_constants.dart` - Constantes

### **Componentes a Crear (Según T96):**

1. **CalendarGrid** ✅ - Estructura base del grid (horas + columnas) - **COMPLETADO**
2. **CalendarTracks** ✅ - Columnas de participantes (headers y estructura) - **COMPLETADO**
3. **CalendarEvents** ⏳ - Eventos y overlays (renderizado de eventos) - **PENDIENTE** (complejo, requiere análisis)
4. **CalendarInteractions** ⏳ - Drag & drop y clicks (interacciones) - **PENDIENTE** (complejo, requiere análisis)

---

## 🏗️ Arquitectura Propuesta

### **Jerarquía de Componentes:**

```
CalendarScreen (orchestrator - ~200 líneas)
├── CalendarAppBar ✅ (ya existe)
├── CalendarGrid (estructura base - ~300 líneas)
│   ├── CalendarHoursColumn (columna de horas - ~150 líneas)
│   └── CalendarDataArea (área de datos - ~150 líneas)
│       ├── CalendarTracks (headers de tracks - ~200 líneas)
│       └── CalendarEvents (eventos - ~800 líneas)
│           └── CalendarInteractions (drag & drop - ~400 líneas)
```

### **Componentes Detallados:**

#### **1. CalendarGrid** (`calendar_grid.dart`)
**Responsabilidad:** Estructura base del grid (horas + área de datos)

**Contiene:**
- `_buildFixedHoursColumn()` - Columna de horas fija
- `_buildDataColumns()` - Columnas de datos
- Lógica de scroll sincronizado
- Layout base Row con horas + datos

**Líneas estimadas:** ~300

---

#### **2. CalendarTracks** (`calendar_tracks.dart`)
**Responsabilidad:** Headers y estructura de tracks (participantes)

**Contiene:**
- `_buildFixedRows()` - Filas fijas de headers
- `_buildHeaderContent()` - Contenido del header por día
- `_buildMiniParticipantHeaders()` - Headers mini de participantes
- `_buildAccommodationTracks()` - Tracks de alojamientos

**Líneas estimadas:** ~400

---

#### **3. CalendarEvents** (`calendar_events.dart`)
**Responsabilidad:** Renderizado de eventos y overlays

**Contiene:**
- `_buildDataRows()` - Filas de datos con eventos
- `_buildEventCellWithSubColumns()` - Celdas de eventos
- `_buildEventWidget()` - Widget de evento
- `_buildSegmentWidget()` - Widget de segmento
- `_buildContinuationWidget()` - Widget de continuación
- `_buildAccommodationCell()` - Celda de alojamiento
- Lógica de posicionamiento de eventos

**Líneas estimadas:** ~800

---

#### **4. CalendarInteractions** (`calendar_interactions.dart`)
**Responsabilidad:** Drag & drop y clicks

**Contiene:**
- `_startDrag()` - Iniciar arrastre
- `_updateDrag()` - Actualizar arrastre
- `_endDrag()` - Finalizar arrastre
- `_buildDraggableEvent()` - Widget draggable
- `_buildDraggableSegment()` - Segmento draggable
- Handlers de clicks en eventos
- Handlers de clicks en celdas

**Líneas estimadas:** ~500

---

## 📝 Plan de Implementación

### **Fase 1: CalendarGrid** ✅ (Paso 1) - **COMPLETADO**
1. ✅ Crear `calendar_grid.dart`
2. ✅ Extraer `_buildFixedHoursColumn()` y `_buildDataColumns()`
3. ✅ Extraer lógica de scroll sincronizado
4. ✅ Refactorizar `CalendarScreen` para usar `CalendarGrid`
5. ✅ Probar que funciona

**Reducción:** ~90 líneas extraídas

### **Fase 2: CalendarTracks** ✅ (Paso 2) - **COMPLETADO**
1. ✅ Crear `calendar_tracks.dart`
2. ✅ Extraer métodos de headers y tracks
3. ✅ Refactorizar `_buildFixedRows()` para usar `CalendarTracks`
4. ✅ Probar que funciona

**Reducción:** ~250 líneas extraídas

**Total extraído hasta ahora:** ~340 líneas

### **Fase 3: CalendarEvents** (Paso 3)
1. Crear `calendar_events.dart`
2. Extraer métodos de renderizado de eventos
3. Refactorizar para usar `CalendarEvents`
4. Probar que funciona

### **Fase 4: CalendarInteractions** (Paso 4)
1. Crear `calendar_interactions.dart`
2. Extraer lógica de drag & drop
3. Extraer handlers de clicks
4. Refactorizar para usar `CalendarInteractions`
5. Probar que funciona

### **Fase 5: Limpieza Final** (Paso 5)
1. Limpiar imports no usados
2. Verificar que `CalendarScreen` quedó reducido
3. Documentar cambios
4. Testing completo

---

## ✅ Criterios de Éxito

- [ ] `CalendarScreen` reducido a ~200-300 líneas
- [ ] Cada componente tiene una responsabilidad clara
- [ ] Funcionalidad exactamente igual que antes
- [ ] Código más legible y mantenible
- [ ] Testing completo sin regresiones

---

**Fecha de creación:** Enero 2025

---

## 📝 Progreso Actual (Actualizado)

### ✅ Completado:
- **CalendarGrid** (`lib/widgets/screens/calendar/components/calendar_grid.dart`)
  - Estructura base del grid
  - Columna de horas fija
  - Área de datos con scroll sincronizado
  - ~160 líneas

- **CalendarTracks** (`lib/widgets/screens/calendar/components/calendar_tracks.dart`)
  - Headers de días
  - Mini headers de participantes
  - Tracks de alojamientos
  - Agrupación de tracks consecutivos
  - ~490 líneas

### ⏳ Pendiente:
- **CalendarEvents**: `_buildEventsLayer` es muy complejo y depende de:
  - Múltiples providers de Riverpod
  - Estado de drag & drop
  - Lógica de timezones y multi-día
  - Métodos de cálculo de posición y overlays
  - **Recomendación:** Mantener en el archivo principal por ahora, documentar bien su estructura

- **CalendarInteractions**: Similar a CalendarEvents, muy acoplado al estado interno

### 📊 Métricas:
- **Líneas extraídas:** ~340 líneas
- **Archivo original:** 4424 líneas
- **Archivo actual:** ~4084 líneas (estimado)
- **Reducción:** ~7.7%

### 🎯 Próximos Pasos:
1. Continuar con extracciones parciales de métodos auxiliares
2. Documentar estructura de `_buildEventsLayer` para futuras mejoras
3. Considerar extraer métodos más pequeños de eventos si es posible

