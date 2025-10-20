# 📋 Lista de Tareas - Planazoo

**Siguiente código de tarea: T93**

**📊 Resumen de tareas por grupos:**
- **GRUPO 1:** T68, T69, T70, T72: Fundamentos de Tracks (4 tareas)
- **GRUPO 2:** T71, T73: Filtros y Control (2 tareas)
- **GRUPO 3:** T46, T74, T75, T76: Parte Común + Personal (4 tareas)
- **GRUPO 4:** T56-T60, T63, T64: Infraestructura Offline (7 tareas)
- **GRUPO 5:** T40-T45, T81, T82: Timezones (8 tareas)
- **GRUPO 6:** T77-T80, T83-T90: Funcionalidades Avanzadas (12 tareas)
- **Tareas Antiguas:** T18-T38: Varias pendientes (15 tareas)
- **Seguridad:** T51-T53: Validación (3 tareas)
- **Participantes:** T47-T50: Sistema básico (4 tareas)
- **Permisos:** T65-T67: Gestión de permisos (3 tareas)
- **Mejoras Visuales:** T91-T92: Colores y tipografía (2 tareas)

**Total: 66 tareas documentadas en 6 grupos principales**

## 📋 Reglas del Sistema de Tareas

### **🔢 Identificación y Códigos**
1. **Códigos únicos**: Cada tarea tiene un código único (T1, T2, T3...)
2. **Códigos no reutilizables**: Al eliminar una tarea, su código no se reutiliza para evitar confusiones
3. **Seguimiento de códigos**: La primera fila indica el siguiente código a asignar

### **📋 Gestión de Tareas**
4. **Orden de prioridad**: La posición en el documento indica el orden de trabajo (no el código)
5. **Gestión dinámica**: Añadir y eliminar tareas según aparezcan nuevas o se finalicen
6. **Trabajo iterativo**: Cada vez que acabemos una tarea, vemos cuál es la siguiente y decidimos si continuar

### **🔄 Estados y Proceso**
7. **Estados de tarea**: Pendiente → En progreso → Completada
8. **Criterios claros**: Cada tarea debe tener criterios de aceptación definidos
9. **Aprobación requerida**: Antes de marcar una tarea como completada, se debe pedir aprobación explícita del usuario. Solo se marca como completada después de recibir confirmación.
10. **Archivo de completadas**: Las tareas completadas se mueven a `docs/COMPLETED_TASKS.md` para mantener este archivo limpio

### **📦 Metodología de Grupos**
11. **Grupos de Tareas**: Las tareas relacionadas se agrupan y se implementan juntas para optimizar testing y desarrollo. Cada grupo debe tener un resultado funcional completo.
12. **Testing por Grupos**: Se prueba la funcionalidad completa al final de cada grupo, no después de cada tarea individual.
13. **Dependencias en Grupos**: Las tareas dentro de un grupo deben ser interdependientes o complementarias, evitando cambios que puedan romper funcionalidad del mismo grupo.

### **🏗️ Arquitectura del Proyecto**
14. **Arquitectura Offline First**: Todas las nuevas funcionalidades deben implementarse siguiendo el principio "Offline First" - la app debe funcionar completamente sin conexión y sincronizar cuando sea posible.
15. **Plan Frankenstein**: Al completar una tarea que añade nueva funcionalidad al calendario (eventos, alojamientos, etc.), revisar si es necesario añadir casos de prueba al Plan Frankenstein (`lib/features/testing/demo_data_generator.dart`) para que la nueva funcionalidad esté cubierta en testing

---

## 📦 GRUPOS DE TAREAS DEFINIDOS

### **Metodología de Desarrollo por Grupos**

Para optimizar el tiempo de testing y desarrollo, las tareas se organizan en grupos cohesivos que se implementan y prueban juntos.

#### **Ventajas de los Grupos:**
- ✅ **Menos tiempo de testing** (1 vez por grupo vs cada tarea)
- ✅ **Menos riesgo** (grupos cohesivos, menos conflictos)
- ✅ **Mejor debugging** (contexto completo del grupo)
- ✅ **Resultados visuales** más significativos
- ✅ **Menos interrupciones** del flujo de desarrollo

#### **Criterios para Agrupar Tareas:**
1. **Interdependencia:** Las tareas se necesitan mutuamente
2. **Resultado funcional:** El grupo completo aporta una funcionalidad usable
3. **Contexto de testing:** Se puede probar la funcionalidad completa
4. **Cambios relacionados:** Modificaciones que afectan los mismos archivos/componentes

---

### **GRUPO 1: FUNDAMENTOS DE TRACKS** 🎯
**Objetivo:** Sistema básico de tracks funcionando
**Tareas:** T68 → T69 → T70 → T72
**Duración estimada:** 1 semana
**Resultado:** Calendario con tracks, eventos multi-track, control de días

**Testing del Grupo:**
- ✅ Generar Plan Frankenstein
- ✅ Verificar tracks por participante
- ✅ Crear evento multi-participante (span)
- ✅ Probar control de días (1-7)
- ✅ Verificar performance básica

---

### **GRUPO 2: FILTROS Y CONTROL** 🔍
**Objetivo:** Navegación y filtrado de tracks
**Tareas:** T71 → T73
**Depende de:** Grupo 1
**Duración estimada:** 3-4 días
**Resultado:** Filtros de vista completos, reordenamiento de tracks

**Testing del Grupo:**
- ✅ Filtro "Mi Agenda" (solo mi track)
- ✅ Filtro "Plan Completo" (todos los tracks)
- ✅ Filtro "Personalizado" (seleccionar tracks)
- ✅ Drag & drop para reordenar tracks (admins)

---

### **GRUPO 3: PARTE COMÚN + PERSONAL** 👥
**Objetivo:** Sistema completo de eventos colaborativos
**Tareas:** T46 → T74 → T75 → T76
**Depende de:** Grupo 1
**Duración estimada:** 1.5 semanas
**Resultado:** Eventos con parte común/personal, sincronización

**Testing del Grupo:**
- ✅ Crear evento con participantes específicos
- ✅ Editar parte común vs parte personal
- ✅ Sincronización entre copias de participantes
- ✅ Permisos de edición correctos

---

### **GRUPO 4: INFRAESTRUCTURA OFFLINE** 💾
**Objetivo:** Base sólida offline + permisos
**Tareas:** T56 → T57 → T58 → T59 → T60 → T63 → T64
**Depende de:** Grupo 3
**Duración estimada:** 2 semanas
**Resultado:** Sistema offline completo, permisos granulares

**Testing del Grupo:**
- ✅ Funcionamiento sin conexión
- ✅ Sincronización automática
- ✅ Resolución de conflictos
- ✅ Permisos según roles
- ✅ Indicadores de estado

---

### **GRUPO 5: TIMEZONES** 🌍
**Objetivo:** Sistema de timezones completo
**Tareas:** T40 → T41 → T42 → T43 → T44 → T45 → T81 → T82
**Depende de:** Grupo 2
**Duración estimada:** 1.5 semanas
**Resultado:** Timezones por evento, conversión multi-track

**Testing del Grupo:**
- ✅ Eventos en diferentes timezones
- ✅ Conversión automática por participante
- ✅ Eventos cross-timezone
- ✅ Indicadores visuales de timezone

---

### **GRUPO 6: FUNCIONALIDADES AVANZADAS** ⚡
**Objetivo:** Optimizaciones y características avanzadas
**Tareas:** T77 → T78 → T79 → T80 → T83 → T84 → T85 → T86 → T87 → T88 → T89 → T90
**Depende de:** Grupos 1-5
**Duración estimada:** 2-3 semanas
**Resultado:** Sistema completo y optimizado

---

## 🚀 ORDEN DE IMPLEMENTACIÓN POR GRUPOS

### **Secuencia Recomendada:**
```
1️⃣ GRUPO 1: Fundamentos de Tracks (T68→T69→T70→T72)
2️⃣ GRUPO 2: Filtros y Control (T71→T73)
3️⃣ GRUPO 3: Parte Común + Personal (T46→T74→T75→T76)
4️⃣ GRUPO 4: Infraestructura Offline (T56→T57→T58→T59→T60→T63→T64)
5️⃣ GRUPO 5: Timezones (T40→T41→T42→T43→T44→T45→T81→T82)
6️⃣ GRUPO 6: Funcionalidades Avanzadas (resto)
```

**📌 Nota sobre Dependencias:**
- T69 es bloqueante para T71, T72, T73 (por eso T69 está en Grupo 1)
- T68 es bloqueante para T69, T73 (por eso T68 está en Grupo 1)
- T74 es bloqueante para T75, T76 (por eso están en Grupo 3)
- El orden dentro de cada grupo respeta las dependencias específicas

### **Flujo de Trabajo por Grupo:**
```
Día 1-N: Implementar todas las tareas del grupo
Día N+1: Testing completo del grupo
Día N+2: Bug fixes si es necesario
Día N+3: Commit y push del grupo completo
Día N+4: Planificación del siguiente grupo
```

---

## 🏗️ DECISIONES ARQUITECTÓNICAS FUNDAMENTALES

### ✅ Arquitectura de Datos (Decidido)
**Decisión:** Duplicación Total (MVP) + Optimización Automática (Futuro)
- Todos los eventos duplicados por participante para simplicidad de desarrollo
- Optimización automática al cerrar el plan (convertir eventos idénticos a referencias)
- Evita complejidad inicial de sincronización de referencias

### ✅ Estrategia de Sincronización (Decidido)
**Decisión:** Estrategia Híbrida
- **Transactions:** Para operaciones críticas (cambios de hora, duración, participantes)
- **Optimistic Updates:** Para cambios cosméticos (descripción, color)
- Balance entre consistencia garantizada y UX rápida

### ✅ Sistema de Timezones (Decidido)
**Decisión:** Sistema UTC del Plan
- Todos los eventos se guardan en timezone base del plan
- Conversión automática por participante para visualización
- Simplicidad máxima (como sistema de vuelos) - no hay decisiones de timezone por evento

### ✅ Arquitectura de Eventos (Decidido)
**Decisión:** Parte Común + Parte Personal
- **Parte Común:** Editada por el creador del evento (descripción, hora, duración, participantes)
- **Parte Personal:** Editada por cada participante (asientos, menús, información específica)
- **Admins del plan:** Pueden editar parte común + cualquier parte personal

### ✅ Sistema de Notificaciones (Decidido)
**Decisión:** Notificaciones Push Completas
- Notificaciones para cambios en eventos existentes
- Notificaciones para nuevos eventos
- Notificaciones para eventos eliminados
- Notificaciones para cambios de participantes
- Configuración personalizable por usuario

### ✅ Sincronización en Tiempo Real (Decidido)
**Decisión:** Firestore Listeners + Riverpod State Management
- Firestore real-time listeners para detectar cambios del servidor
- Riverpod state management para actualizaciones automáticas de UI
- Indicadores visuales de estado de conexión y sincronización

### ✅ Offline First (Decidido)
**Decisión:** Offline First Completo
- Almacenamiento local de todos los eventos (SQLite/Hive)
- CRUD completo sin conexión a internet
- Sincronización automática cuando hay conexión
- Resolución automática de conflictos (último cambio gana)
- Cola de sincronización para cambios pendientes

---

## 🗺️ ORDEN DE IMPLEMENTACIÓN RECOMENDADO

### **Opción A: Tracks Primero (Resultados visuales rápidos)**
```
1️⃣ Sistema de Tracks (T68-T77)     ← Funcionalidad CORE visual
2️⃣ Vistas Filtradas (T78-T80)       ← Completar experiencia tracks
3️⃣ Timezones (T40-T45)              ← Conversión por participante
4️⃣ Timezone Multi-Track (T81-T82)   ← Integración tracks + timezone
5️⃣ Permisos (T63-T67)               ← Seguridad y roles
6️⃣ Offline First (T56-T62)          ← Infraestructura robusta
7️⃣ Funcionalidades Avanzadas        ← Optimizaciones
```

### **Opción B: Infraestructura Primero (Robustez desde el inicio)**
```
1️⃣ Offline First (T56-T62)          ← Base sólida
2️⃣ Permisos (T63-T67)               ← Seguridad
3️⃣ Sistema de Tracks (T68-T77)      ← Funcionalidad CORE
4️⃣ Timezones (T40-T45, T81-T82)     ← Conversión completa
5️⃣ Vistas Filtradas (T78-T80)       ← Experiencia usuario
6️⃣ Funcionalidades Avanzadas        ← Refinamiento
```

### **Opción C: Incremental (Mezcla de valor y robustez)**
```
Fase 1: Base Visual
- T68 (ParticipantTrack)
- T69 (CalendarScreen multi-track)
- T70 (Eventos multi-track)

Fase 2: Infraestructura Crítica
- T56 (Base de datos local)
- T63 (Modelo de permisos)
- T74 (Parte común + personal)

Fase 3: Funcionalidad Completa
- T71-T73 (Filtros y control)
- T75-T77 (UI y sincronización)
- T40-T45 (Timezones)

Fase 4: Refinamiento
- T78-T82 (Vistas y timezone avanzado)
- T56-T62 (Offline First completo)
- T83-T90 (Funcionalidades avanzadas)
```

**📌 IMPORTANTE:** Las tareas T46-T50 son versiones simplificadas que pueden omitirse si se va directo al sistema de tracks (T68-T90).

---

## 👥 SISTEMA DE TRACKS Y VISUALIZACIÓN MULTI-PARTICIPANTE - Serie de Tareas (T68-T77)

**⚠️ CRÍTICO - FUNCIONALIDAD CORE DEL SISTEMA**

Esta serie implementa el concepto fundamental de "Participante como Track", donde cada participante del plan se visualiza como una columna (track) independiente en el calendario.

**📌 Conceptos Clave:**
- Cada participante = 1 track (columna en el calendario)
- Los eventos se muestran en los tracks de sus participantes
- Eventos multi-participante se extienden (span) por múltiples tracks
- Los tracks tienen orden fijo dentro del plan
- Vista filtrable: Todos/Individual/Personalizado

---

### T68 - Modelo ParticipantTrack
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Bloqueante para T69-T90  
**Descripción:** Crear modelo `ParticipantTrack` que representa cada participante como una columna/track en el calendario.

**Concepto clave:** 
- Cada participante del plan = 1 track
- El track contiene referencia al participante y su posición fija
- Los tracks mantienen orden consistente en todas las vistas del plan

**Criterios de aceptación:**
- Crear modelo `ParticipantTrack` con campos:
  ```dart
  class ParticipantTrack {
    String id;
    String participantId;
    String participantName;
    int position; // Orden fijo en el plan (0, 1, 2, ...)
    Color? customColor;
    bool isVisible; // Para filtros
  }
  ```
- Método para obtener tracks de un plan
- Método para reordenar tracks (cambiar position)
- Guardar configuración de tracks en Firestore
- Migración: planes existentes crean tracks automáticamente

**Archivos a crear:**
- `lib/features/calendar/domain/models/participant_track.dart`
- `lib/features/calendar/domain/services/track_service.dart`

**Reglas de negocio:**
- El orden de tracks es fijo y se mantiene en todas las vistas
- Solo admins del plan pueden reordenar tracks
- Los tracks se crean automáticamente al añadir participante al plan
- Al eliminar participante, su track se marca como inactivo (no se borra)

---

### T69 - CalendarScreen: Modo Multi-Track
**Estado:** Pendiente  
**Complejidad:** ⚠️ Muy Alta  
**Prioridad:** 🔴 Crítico  
**Depende de:** T68  
**Descripción:** Rediseñar `wd_calendar_screen.dart` para mostrar múltiples columnas (tracks), una por participante.

**Concepto clave:**
- Vista horizontal con columnas: [Horas] [Track1] [Track2] [Track3] ... [TrackN]
- Cada track muestra solo los eventos de ese participante
- Scroll horizontal para ver más tracks
- Scroll vertical compartido para las horas

**UI propuesta:**
```
┌─────┬─────────┬─────────┬─────────┬─────────┐
│Horas│  Juan   │  María  │  Pedro  │   Ana   │
├─────┼─────────┼─────────┼─────────┼─────────┤
│00:00│         │         │         │         │
│01:00│         │         │ 🛏️ Vuelo │         │
│...  │         │         │         │         │
│09:00│ 🍽️ Desay│ 🍽️ Desay│         │ 🍽️ Desay│
│10:00│ 🏛️ Museo─────────────────────────────┤│ (evento multi-track)
│11:00│         │         │         │         │
└─────┴─────────┴─────────┴─────────┴─────────┘
```

**Criterios de aceptación:**
- Rediseñar estructura de columnas del calendario:
  - Columna fija de horas (izquierda)
  - Columnas dinámicas para cada track (scroll horizontal)
- Ancho de track adaptativo según cantidad de días visibles
- Renderizar eventos en el track correspondiente
- Scroll horizontal suave para tracks
- Scroll vertical compartido para todas las columnas
- Header con nombres de participantes (sticky)
- Indicador visual de track activo/seleccionado

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart` (rediseño completo)
- Crear: `lib/widgets/wd_track_column.dart`
- Crear: `lib/widgets/wd_track_header.dart`

**Consideraciones técnicas:**
- Usar `SingleChildScrollView` horizontal para tracks
- Usar `ScrollController` compartido para scroll vertical
- Calcular ancho dinámico: `trackWidth = (screenWidth - hoursColumnWidth) / visibleDays`
- Lazy loading de tracks para performance
- Mantener compatibilidad con drag & drop de eventos

---

### T70 - Eventos Multi-Track (Span Horizontal)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🔴 Crítico  
**Depende de:** T69  
**Descripción:** Implementar eventos que se extienden (span) horizontalmente por múltiples tracks cuando tienen varios participantes.

**Concepto clave:**
- Evento con 3 participantes → se extiende por 3 tracks
- Evento "Vuelo familiar" con [Padre, Madre, Hijo] → ocupa 3 columnas adyacentes
- Visual: rectángulo ancho que abarca múltiples tracks

**Visual esperado:**
```
│  Padre  │  Madre  │  Hijo   │  Abuelo │
├─────────┼─────────┼─────────┼─────────┤
│ ✈️ Vuelo Barcelona - Londres─────────┤│         │
│ (evento de 3 participantes)           │         │
```

**Criterios de aceptación:**
- Detectar eventos multi-participante
- Calcular ancho del evento: `width = trackWidth * numberOfParticipants`
- Renderizar evento abarcando múltiples columnas
- Posicionar evento en el track del primer participante
- Evitar superposición incorrecta con otros eventos
- Interacción: click en cualquier parte del evento abre diálogo
- Drag & drop: mover evento multi-track mantiene participantes

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- `lib/features/calendar/domain/models/event_segment.dart` (añadir `spanTracks`)

**Reglas de negocio:**
- Solo eventos con `isForAllParticipants = false` y múltiples `participantIds`
- Los tracks de los participantes deben ser consecutivos para span visual
- Si no son consecutivos, el evento se renderiza en cada track individual

---

### T71 - Filtros de Vista: Individual vs Todos vs Personalizado
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Crítico  
**Depende de:** T69  
**Descripción:** Implementar sistema de filtros para cambiar qué tracks se muestran en el calendario.

**Modos de vista:**

1. **"Plan Completo"** (Vista Organizador)
   - Muestra todos los tracks de todos los participantes
   - Eventos multi-participante visibles con span
   - Scroll horizontal para ver todos

2. **"Mi Agenda"** (Vista Personal)
   - Solo muestra el track del usuario actual
   - Vista simplificada, sin scroll horizontal
   - Solo eventos donde el usuario participa

3. **"Vista Personalizada"**
   - Usuario selecciona qué tracks ver
   - Checkbox por participante
   - Útil para ver "plan de la familia" vs "plan individual"

**UI propuesta (selector en AppBar):**
```
┌──────────────────────────────────────┐
│ 📅 Calendario  [👁️ Vista: Plan Completo ▼] │
└──────────────────────────────────────┘

Al desplegar:
┌─────────────────────┐
│ ✓ Plan Completo     │
│   Mi Agenda         │
│   Personalizada...  │
└─────────────────────┘

Si selecciona "Personalizada":
┌─────────────────────┐
│ Seleccionar tracks: │
│ ☑️ Juan (Yo)        │
│ ☑️ María           │
│ ☐ Pedro            │
│ ☑️ Ana             │
└─────────────────────┘
```

**Criterios de aceptación:**
- Dropdown/BottomSheet con 3 opciones de vista
- "Plan Completo": cargar todos los tracks
- "Mi Agenda": solo track del usuario actual
- "Vista Personalizada": modal con checkboxes de participantes
- Persistir selección en estado local (no Firestore)
- Al cambiar filtro, recargar eventos correspondientes
- Indicador visual del filtro activo
- Contador de tracks visibles

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- Crear: `lib/widgets/wd_track_filter_selector.dart`
- Crear: `lib/widgets/wd_track_filter_dialog.dart`

**Consideraciones técnicas:**
- Estado del filtro: `List<String> selectedTrackIds`
- Provider para gestionar filtro activo
- Re-renderizar calendario al cambiar filtro
- Optimización: solo cargar eventos de tracks visibles

---

### T72 - Control de Días Visibles (1-7 días ajustable)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟠 Alta  
**Depende de:** T69  
**Descripción:** Permitir al usuario ajustar cuántos días se muestran simultáneamente en el calendario para optimizar espacio de tracks.

**Concepto clave:**
- Menos días visibles → más espacio para cada track
- Más días visibles → tracks más estrechos
- El usuario decide el balance óptimo

**Cálculo de ancho:**
```dart
double trackWidth = (screenWidth - hoursColumnWidth) / (visibleDays * numberOfTracks);

Ejemplo:
- Pantalla: 1200px
- Horas: 100px
- Tracks: 4 participantes
- Días visibles: 7

trackWidth = (1200 - 100) / (7 * 4) = 1100 / 28 = ~39px (MUY ESTRECHO)

Si reducimos a 3 días:
trackWidth = (1200 - 100) / (3 * 4) = 1100 / 12 = ~92px (MEJOR)
```

**UI propuesta:**
```
┌────────────────────────────────────┐
│ [◀] 3 días [▶]   📅 Calendario    │
└────────────────────────────────────┘

O con slider:
┌────────────────────────────────────┐
│ Días: [1]━━●━━━━━[7]               │
└────────────────────────────────────┘
```

**Criterios de aceptación:**
- Selector de días visibles: 1, 2, 3, 5, 7 días
- Botones +/- o slider para cambiar
- Recalcular ancho de tracks dinámicamente
- Persistir preferencia en estado local
- Indicador visual del número actual
- Auto-ajuste si tracks no caben (mínimo 1 día)
- Navegación entre rangos de días (anterior/siguiente)

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- Crear: `lib/widgets/wd_days_selector.dart`

**Reglas de negocio:**
- Por defecto: 7 días (vista semanal)
- Si no caben todos los tracks con 7 días, sugerir reducir
- Mínimo: 1 día
- Máximo: 7 días

---

### T73 - Gestión de Orden de Tracks (Drag & Drop)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Depende de:** T68, T69  
**Descripción:** Permitir a los admins reordenar los tracks (participantes) mediante drag & drop para personalizar la visualización del plan.

**Concepto clave:**
- El orden de tracks es fijo y consistente
- Admins pueden reordenar arrastrando headers de tracks
- El orden se guarda y se mantiene para todos los usuarios

**UI propuesta:**
```
[Antes del drag]
│  Juan   │  María  │  Pedro  │  Ana   │
                ↓ (admin arrastra "María" a la derecha)
[Después del drag]
│  Juan   │  Pedro  │  María  │  Ana   │
```

**Criterios de aceptación:**
- Solo admins ven icono de drag en track headers
- Drag & drop funcional en track headers
- Reordenar tracks actualiza `position` en Firestore
- Cambio se sincroniza en tiempo real para todos
- Animación suave al reordenar
- Confirmación visual del nuevo orden
- Botón "Restaurar orden original" (alfabético)

**Archivos a modificar:**
- `lib/widgets/wd_track_header.dart`
- `lib/features/calendar/domain/services/track_service.dart`

**Permisos:**
- Admin del plan: ✅ Puede reordenar
- Participante: ❌ Solo visualización
- Observador: ❌ Solo visualización

---

### T74 - Modelo Event: Estructura Parte Común + Parte Personal
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🔴 Bloqueante para T75-T77  
**Depende de:** T68  
**Descripción:** Modificar modelo Event para separar claramente la "parte común" (editada por creador) y la "parte personal" (editada por cada participante).

**Concepto clave:**
- **Parte Común:** Información compartida del evento (hora, duración, descripción, ubicación)
- **Parte Personal:** Información específica de cada participante (asiento, preferencias, notas personales)

**Estructura propuesta:**
```dart
class Event {
  String id;
  String planId;
  String createdBy; // Usuario que creó el evento
  
  // ============ PARTE COMÚN (editable por creador + admins) ============
  EventCommonPart commonPart;
  
  // ========== PARTE PERSONAL (editable por participante + admins) =========
  Map<String, EventPersonalPart> personalParts; // Key: participantId
}

class EventCommonPart {
  String description;
  DateTime date;
  int hour;
  int startMinute;
  int durationMinutes;
  String? location;
  String? notes;
  EventFamily family;
  String? subtype;
  Color? customColor;
  List<String> participantIds;
  bool isForAllParticipants;
  bool isDraft;
}

class EventPersonalPart {
  String participantId;
  
  // Campos específicos por tipo de evento:
  String? asiento;        // Para vuelos, trenes, teatro
  String? menu;           // Para restaurantes
  String? preferencias;   // Para actividades
  String? numeroReserva;  // Para hoteles, vuelos
  String? gate;           // Para vuelos
  bool? tarjetaObtenida;  // Para vuelos
  String? notasPersonales;
  
  // Campo genérico para info adicional:
  Map<String, dynamic>? extraData;
}
```

**Criterios de aceptación:**
- Migrar campos existentes a `EventCommonPart`
- Crear `EventPersonalPart` con campos personalizables
- Modificar `toFirestore()` y `fromFirestore()` para nueva estructura
- Compatibilidad hacia atrás: eventos sin parte personal funcionan
- Validación: cada participante tiene su `EventPersonalPart`
- Testing: crear evento con parte común + partes personales

**Archivos a modificar:**
- `lib/features/calendar/domain/models/event.dart`
- Crear: `lib/features/calendar/domain/models/event_common_part.dart`
- Crear: `lib/features/calendar/domain/models/event_personal_part.dart`

**Migración:**
- Eventos existentes: toda la info va a `commonPart`
- `personalParts` se crea vacío y se va llenando
- Al editar evento antiguo, se migra automáticamente

---

### T75 - EventDialog: UI Separada para Parte Común vs Personal
**Estado:** Pendiente  
**Complejidad:** ⚠️ Muy Alta  
**Prioridad:** 🔴 Crítico  
**Depende de:** T74  
**Descripción:** Rediseñar EventDialog para mostrar claramente qué campos son "parte común" vs "parte personal", con permisos de edición según el rol del usuario.

**Concepto clave:**
- Creador del evento: edita parte común + su parte personal
- Participante: solo edita su parte personal (readonly en parte común)
- Admin: edita parte común + cualquier parte personal

**UI propuesta (con tabs):**
```
┌──────────────────────────────────────┐
│  [📋 Información General] [👤 Mi Info] │
├──────────────────────────────────────┤
│                                      │
│ Tab 1: PARTE COMÚN                   │
│ ┌──────────────────────────────┐   │
│ │ 📝 Descripción: Vuelo BCN-LON │   │
│ │ 🕐 Hora: 07:00               │   │
│ │ ⏱️ Duración: 2h 30min        │   │
│ │ 📍 Ubicación: Aeropuerto     │   │
│ │ 👥 Participantes: 3          │   │
│ └──────────────────────────────┘   │
│                                      │
│ Tab 2: MI INFORMACIÓN PERSONAL       │
│ ┌──────────────────────────────┐   │
│ │ 💺 Asiento: 12A              │   │
│ │ 🚪 Gate: B15                 │   │
│ │ ✅ Tarjeta: Obtenida         │   │
│ │ 📝 Notas: Llevar pasaporte   │   │
│ └──────────────────────────────┘   │
└──────────────────────────────────────┘

Para ADMINS, aparece tab adicional:
[📋 General] [👤 Mi Info] [👥 Info de Otros]
                              ↑
                    Ver/Editar info personal de otros
```

**Criterios de aceptación:**
- **Tab "Información General" (Parte Común):**
  - Campos: descripción, fecha, hora, duración, ubicación, participantes
  - Editable si: `user == createdBy` OR `user.isAdmin`
  - Readonly si: `user != createdBy` AND `!user.isAdmin`
  - Indicador visual de permisos (🔒 si readonly)

- **Tab "Mi Información" (Parte Personal):**
  - Campos dinámicos según tipo de evento (vuelo, restaurant, etc.)
  - Siempre editable (es la parte personal del usuario)
  - Opcional: campos vacíos si no se ha personalizado

- **Tab "Información de Otros" (Solo Admins):**
  - Lista de participantes del evento
  - Click en participante → ver/editar su parte personal
  - Útil para que admin gestione info de todos (ej: sacar tarjetas)

- **Indicadores visuales:**
  - 🔓 Campo editable (borde verde claro)
  - 🔒 Campo readonly (opacidad reducida, borde gris)
  - Badge "Admin" si el usuario es admin
  - Badge "Creador" si el usuario creó el evento

**Archivos a modificar:**
- `lib/widgets/wd_event_dialog.dart` (rediseño completo)
- Crear: `lib/widgets/event_dialog/event_common_tab.dart`
- Crear: `lib/widgets/event_dialog/event_personal_tab.dart`
- Crear: `lib/widgets/event_dialog/event_others_tab.dart` (admins)

**Consideraciones técnicas:**
- Usar `TabController` con 2-3 tabs según rol
- Campos readonly: `TextField(enabled: false, ...)`
- Validación diferente por tab
- Guardar cambios: solo de tabs editables

---

### T76 - Sincronización Parte Común → Copias de Participantes
**Estado:** Pendiente  
**Complejidad:** ⚠️ Muy Alta  
**Prioridad:** 🔴 Crítico  
**Depende de:** T74, T75  
**Descripción:** Implementar lógica de sincronización para que cambios en la parte común de un evento se propaguen automáticamente a todas las copias de los participantes.

**Concepto clave:**
- Evento "Vuelo BCN-LON" tiene 3 copias (Padre, Madre, Hijo)
- Admin cambia hora de 07:00 → 08:00 en parte común
- El cambio se propaga automáticamente a las 3 copias
- Las partes personales NO se modifican

**Flujo de sincronización:**
```
1. Admin edita parte común del evento
   ↓
2. Sistema detecta que es cambio en "commonPart"
   ↓
3. Busca todas las copias del evento (mismo eventId base)
   ↓
4. Actualiza "commonPart" en todas las copias
   ↓
5. Notifica a los participantes del cambio
   ↓
6. UI se actualiza automáticamente (Firestore listeners)
```

**Criterios de aceptación:**
- **Detección de cambios:**
  - Identificar qué eventos son "copias" del mismo evento (mismo `baseEventId`)
  - Diferenciar cambios en `commonPart` vs `personalPart`

- **Propagación de cambios:**
  - Método `propagateCommonPartChanges(eventId, newCommonPart)`
  - Actualizar `commonPart` en todas las copias
  - Mantener `personalPart` intacta
  - Usar Firestore Transaction para atomicidad

- **Casos especiales:**
  - Cambio de participantes → crear/eliminar copias
  - Cambio de hora/fecha → recalcular overlaps
  - Evento borrado → eliminar todas las copias

- **Notificaciones:**
  - Notificar a participantes afectados
  - Mensaje: "El evento X fue modificado por [Admin]"
  - Destacar qué cambió (hora, descripción, etc.)

**Archivos a modificar:**
- `lib/features/calendar/domain/services/event_service.dart`
- Crear: `lib/features/calendar/domain/services/event_sync_service.dart`

**Estrategia de sincronización:**
- Usar Firestore Transaction (operación crítica)
- Batch updates para múltiples copias
- Retry automático si falla
- Log de cambios para debugging

---

### T77 - Indicadores Visuales de Permisos en UI
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja-Media  
**Prioridad:** 🟡 Media  
**Depende de:** T75  
**Descripción:** Añadir indicadores visuales claros en la UI para que el usuario sepa qué puede editar y qué no según sus permisos.

**Concepto clave:**
- Usuario debe saber de un vistazo qué campos puede editar
- Diferenciación clara entre parte común (puede/no puede) y parte personal (siempre puede)

**Indicadores propuestos:**

1. **Badges de Rol en Event Dialog:**
   ```
   ┌──────────────────────────────────┐
   │ ✈️ Vuelo BCN-LON    [👑 Admin]   │ ← Badge dorado si es admin
   │ ✈️ Vuelo BCN-LON    [✍️ Creador] │ ← Badge azul si es creador
   │ ✈️ Vuelo BCN-LON    [👤 Particip]│ ← Badge gris si es participante
   └──────────────────────────────────┘
   ```

2. **Iconos en Campos:**
   ```
   🔓 Descripción: [___________]  ← Verde claro, editable
   🔒 Descripción: [___________]  ← Gris, readonly
   ```

3. **Tooltips Informativos:**
   ```
   [Hover en campo readonly]
   ┌──────────────────────────────┐
   │ ℹ️ Solo el creador o admins   │
   │   pueden editar este campo   │
   └──────────────────────────────┘
   ```

4. **Color de Borde en Tabs:**
   ```
   [📋 Información General]  ← Borde verde si editable
   [📋 Información General]  ← Borde gris si readonly
   [👤 Mi Información]       ← Siempre verde (siempre editable)
   ```

5. **Indicador en Calendario:**
   ```
   Eventos creados por mí:  📝 (lápiz pequeño en esquina)
   Eventos de otros:        👁️ (ojo en esquina)
   ```

**Criterios de aceptación:**
- Badge de rol visible en header del EventDialog
- Iconos 🔓/🔒 en campos según permisos
- Tooltips explicativos en campos readonly
- Color de borde diferente en tabs (verde/gris)
- Opacidad reducida en campos no editables
- Indicador en evento del calendario (opcional)
- Consistencia visual en toda la app

**Archivos a modificar:**
- `lib/widgets/wd_event_dialog.dart`
- `lib/widgets/screens/wd_calendar_screen.dart`
- Crear: `lib/widgets/shared/permission_indicator.dart`
- Crear: `lib/widgets/shared/role_badge.dart`

**Paleta de colores:**
- 🔓 Editable: `Colors.green[100]` (fondo) + `Colors.green` (borde)
- 🔒 Readonly: `Colors.grey[200]` (fondo) + `Colors.grey` (borde)
- Admin: `Colors.amber` (dorado)
- Creador: `Colors.blue`
- Participante: `Colors.grey`

---

## 🌐 VISTAS FILTRADAS Y TIMEZONE POR PARTICIPANTE - Serie de Tareas (T78-T82)

### T78 - Vista "Mi Agenda" (Solo mis eventos)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟠 Alta  
**Depende de:** T69, T71  
**Descripción:** Implementar vista simplificada "Mi Agenda" que muestra solo el track del usuario actual con sus eventos.

**Concepto clave:**
- Vista personal y simplificada
- Solo 1 track (el del usuario)
- Solo eventos donde el usuario participa
- Sin scroll horizontal
- Más espacio para eventos

**UI esperada:**
```
┌─────────────────────────────────┐
│ 📅 Mi Agenda - Juan             │
├─────┬───────────────────────────┤
│00:00│                           │
│...  │                           │
│09:00│ 🍽️ Desayuno              │
│10:00│ 🏛️ Museo                 │
│...  │                           │
│20:00│ 🍽️ Cena                  │
└─────┴───────────────────────────┘
```

**Criterios de aceptación:**
- Botón/Toggle para activar vista "Mi Agenda"
- Mostrar solo track del usuario actual
- Filtrar eventos: solo donde `participantIds.contains(currentUserId)`
- Ancho completo para el track (sin scroll horizontal)
- Header personalizado: "Mi Agenda - [Nombre]"
- Eventos multi-participante se muestran pero sin span
- Opción para volver a "Plan Completo"

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- `lib/widgets/wd_track_filter_selector.dart`

---

### T79 - Vista "Plan Completo" (Todos los tracks)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟠 Alta  
**Depende de:** T69, T71  
**Descripción:** Implementar vista "Plan Completo" que muestra todos los tracks de todos los participantes con eventos multi-participante visibles.

**Concepto clave:**
- Vista de organizador/admin
- Todos los tracks visibles
- Eventos multi-participante con span horizontal
- Scroll horizontal para navegar
- Vista más compleja pero completa

**UI esperada:**
```
┌──────────────────────────────────────────┐
│ 📅 Plan Completo - Vacaciones Europa     │
├─────┬────────┬────────┬────────┬─────────┤
│Horas│  Juan  │ María  │ Pedro  │  Ana    │
├─────┼────────┼────────┼────────┼─────────┤
│09:00│ ✈️ Vuelo Barcelona - Londres──────┤│         │
│     │ (evento multi-participante)       │         │
│10:00│        │        │        │         │
│...  │        │ 🛍️ Shop│        │         │
└─────┴────────┴────────┴────────┴─────────┘
```

**Criterios de aceptación:**
- Botón/Toggle para activar vista "Plan Completo"
- Cargar todos los tracks del plan
- Mostrar eventos multi-participante con span
- Scroll horizontal funcional
- Header con nombres de todos los participantes
- Indicador de cantidad de tracks visibles
- Opción para cambiar a otras vistas

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- `lib/widgets/wd_track_filter_selector.dart`

---

### T80 - Vista "Personalizada" (Seleccionar tracks)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Depende de:** T69, T71  
**Descripción:** Implementar vista "Personalizada" donde el usuario puede seleccionar manualmente qué tracks (participantes) quiere visualizar.

**Concepto clave:**
- Usuario decide qué participantes ver
- Útil para casos como "ver solo plan familiar" excluyendo otros
- Combinación flexible de tracks

**UI esperada:**
```
1. Selector de tracks:
┌─────────────────────────┐
│ Seleccionar participantes:│
│ ☑️ Juan (Yo)            │
│ ☑️ María (Pareja)       │
│ ☐ Pedro (Amigo)         │
│ ☑️ Ana (Hija)           │
│                         │
│ [Aplicar]  [Cancelar]   │
└─────────────────────────┘

2. Vista resultante:
│  Juan  │  María │  Ana   │  ← Solo seleccionados
```

**Criterios de aceptación:**
- Botón "Vista Personalizada" abre modal/drawer
- Checkbox por cada participante del plan
- Indicador de "Yo" en el participante actual
- Aplicar filtro muestra solo tracks seleccionados
- Mínimo 1 track seleccionado (validación)
- Guardar preferencia en estado local
- Indicador visual de cuántos tracks están ocultos

**Archivos a crear:**
- `lib/widgets/wd_custom_track_selector_dialog.dart`

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- `lib/widgets/wd_track_filter_selector.dart`

---

### T81 - Conversión Timezone por Participante en Multi-Track
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🟠 Alta  
**Depende de:** T40-T45, T69  
**Descripción:** Integrar sistema de timezones con visualización multi-track, mostrando cada evento en la timezone local de cada participante.

**Concepto clave:**
- Plan tiene timezone base (ej: UTC o Europe/Madrid)
- Cada participante tiene su timezone local
- Los eventos se muestran en la hora local de cada participante

**Ejemplo:**
```
Evento: "Daily Standup" a las 09:00 (timezone base: Europe/Madrid)

│  Dev (Madrid) │  PM (Nueva York) │  QA (Tokio)   │
├───────────────┼──────────────────┼───────────────┤
│ 09:00         │ 03:00            │ 17:00         │
│ Daily Standup │ Daily Standup    │ Daily Standup │
```

**Criterios de aceptación:**
- Obtener timezone de cada participante
- Convertir hora del evento desde timezone base a timezone del participante
- Mostrar hora convertida en cada track
- Indicador visual si la hora es diferente entre tracks
- Tooltip mostrando hora original (timezone base)
- Funciona con eventos multi-participante
- Testing con al menos 3 timezones diferentes

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- `lib/widgets/wd_track_column.dart`
- `lib/features/calendar/domain/services/timezone_service.dart`

**Consideraciones técnicas:**
- Usar paquete `timezone` para conversiones
- Cachear conversiones para performance
- Manejar DST (Daylight Saving Time)
- Mostrar indicador si evento "cruza día" para algún participante

---

### T82 - Indicador Visual de Timezone Diferente
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Baja  
**Depende de:** T81  
**Descripción:** Añadir indicadores visuales cuando un evento se muestra en timezones diferentes entre participantes.

**Concepto clave:**
- Usuario debe saber cuando la hora mostrada es diferente entre tracks
- Evitar confusión en planes internacionales

**Indicadores propuestos:**

1. **Badge de Timezone en Track Header:**
   ```
   │  Dev (Madrid)  │  PM (Nueva York)  │
   │  🌍 GMT+1      │  🌍 GMT-5         │
   ```

2. **Indicador en Evento con Horas Diferentes:**
   ```
   │ 09:00 🌍       │ 03:00 🌍          │
   │ Daily Standup  │ Daily Standup     │
   ```

3. **Tooltip Informativo:**
   ```
   [Hover en evento]
   ┌──────────────────────────────┐
   │ 🌍 Evento en múltiples zonas │
   │ Madrid: 09:00                │
   │ Nueva York: 03:00            │
   │ Tokio: 17:00                 │
   └──────────────────────────────┘
   ```

4. **Línea Vertical de Referencia:**
   ```
   Mostrar línea vertical para la hora "base" del plan
   ayudando a visualizar el offset entre tracks
   ```

**Criterios de aceptación:**
- Badge con timezone en header de cada track
- Icono 🌍 en eventos con múltiples timezones
- Tooltip mostrando hora en todas las timezones
- Color diferente para tracks con timezone != base
- Opción de mostrar/ocultar indicadores (toggle)

**Archivos a modificar:**
- `lib/widgets/wd_track_header.dart`
- `lib/widgets/wd_track_column.dart`

---

## 🎯 FUNCIONALIDADES AVANZADAS - Serie de Tareas (T83-T90)

### T83 - Sistema de Grupos de Participantes (Futuro)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja (Futuro)  
**Depende de:** T68-T73  
**Descripción:** Permitir agrupar participantes en grupos lógicos (ej: "Familia", "Amigos", "Trabajo") para facilitar gestión y filtrado.

**Concepto clave:**
- Grupos = conjuntos de participantes
- Útil para planes grandes con muchos participantes
- Facilita asignación de eventos a grupos completos

**Criterios de aceptación:**
- Crear modelo `ParticipantGroup`
- UI para crear/editar grupos
- Asignar eventos a grupos enteros
- Filtrar vista por grupo
- Colores personalizados por grupo

**Archivos a crear:**
- `lib/features/calendar/domain/models/participant_group.dart`
- `lib/widgets/wd_group_management_dialog.dart`

---

### T84 - Lógica de Propagación Automática de Cambios
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🟠 Alta  
**Depende de:** T76  
**Descripción:** Optimizar y refinar el sistema de propagación de cambios para que sea más eficiente y robusto.

**Mejoras a implementar:**
- Detección inteligente de qué cambió (diff)
- Propagación solo de campos modificados
- Batch updates optimizados
- Retry con backoff exponencial
- Notificaciones agrupadas (debouncing)

---

### T85 - Notificaciones de Cambios en Eventos Compartidos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟠 Alta  
**Depende de:** T76  
**Descripción:** Implementar sistema de notificaciones específico para cambios en eventos compartidos entre participantes.

**Tipos de notificaciones:**
- "Juan cambió la hora del vuelo de 07:00 a 08:00"
- "María añadió ubicación al evento"
- "Pedro te añadió al evento 'Cena'"

---

### T86 - Sistema Adaptativo de Días Visibles
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Depende de:** T72  
**Descripción:** Sistema inteligente que sugiere automáticamente cuántos días mostrar según cantidad de tracks y tamaño de pantalla.

**Lógica:**
```dart
int calculateOptimalDays(int numberOfTracks, double screenWidth) {
  // Ancho mínimo aceptable por track: 80px
  int maxTracksPerDay = (screenWidth - 100) / 80;
  return max(1, (numberOfTracks / maxTracksPerDay).ceil());
}
```

---

### T87 - Scroll Horizontal Condicional
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Baja  
**Depende de:** T69  
**Descripción:** Activar scroll horizontal solo cuando los tracks no caben en pantalla, evitando scroll innecesario.

**Lógica:**
- Calcular ancho total necesario
- Si cabe en pantalla → sin scroll
- Si no cabe → activar scroll horizontal
- Indicador visual de "más tracks →"

---

### T88 - Rediseño Arquitectura de Capas del Calendario
**Estado:** Pendiente  
**Complejidad:** ⚠️ Muy Alta  
**Prioridad:** 🟡 Media  
**Depende de:** T69  
**Descripción:** Reorganizar la arquitectura de widgets del calendario en capas claras: Base → Tracks → Eventos → Interacciones.

**Capas propuestas:**
```
Layer 1: CalendarBase (grid de horas, fondo)
Layer 2: TracksLayer (columnas de participantes)
Layer 3: EventsLayer (eventos en tracks)
Layer 4: InteractionsLayer (drag & drop, clicks)
Layer 5: OverlaysLayer (tooltips, menus)
```

---

### T89 - Indicadores Visuales de Eventos Multi-Participante
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Baja  
**Depende de:** T70  
**Descripción:** Mejorar indicadores visuales para eventos que abarcan múltiples participantes.

**Indicadores propuestos:**
- Gradiente en evento multi-track
- Iconos de participantes en evento
- Línea conectora entre tracks
- Tooltip con lista de participantes

---

### T90 - Resaltado de Track Activo/Seleccionado
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Baja  
**Depende de:** T69  
**Descripción:** Resaltar visualmente el track del usuario actual o el track seleccionado para facilitar navegación.

**Visual propuesto:**
- Fondo levemente diferente en track activo
- Borde más grueso en track seleccionado
- Nombre en negrita
- Animación suave al cambiar selección

---

## 🏗️ IMPLEMENTACIÓN DE ARQUITECTURA OFFLINE FIRST - Serie de Tareas (T56-T62)

### T56 - Implementar Base de Datos Local
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🔴 Bloqueante para T57-T62  
**Descripción:** Implementar sistema de base de datos local para almacenamiento offline de eventos y datos del plan.

**Criterios de aceptación:**
- Implementar SQLite o Hive como base de datos local
- Crear modelos de datos para almacenamiento local
- Implementar servicios de CRUD local (Create, Read, Update, Delete)
- Migración de datos desde Firestore a local
- Testing de persistencia de datos offline

**Archivos a crear:**
- `lib/shared/database/local_database.dart`
- `lib/shared/models/local_event.dart`
- `lib/shared/services/local_event_service.dart`

---

### T57 - Implementar Cola de Sincronización
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Depende de:** T56  
**Descripción:** Implementar sistema de cola de sincronización para manejar cambios pendientes cuando no hay conexión.

**Criterios de aceptación:**
- Cola de operaciones pendientes (create, update, delete)
- Sincronización automática al recuperar conexión
- Manejo de conflictos (último cambio gana)
- Indicadores visuales de cambios pendientes
- Retry automático con backoff exponencial

---

### T58 - Implementar Resolución de Conflictos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T57  
**Descripción:** Implementar sistema de resolución automática de conflictos cuando hay cambios simultáneos.

**Criterios de aceptación:**
- Detección de conflictos por timestamp
- Resolución automática (último cambio gana)
- Notificación al usuario de conflictos resueltos
- Log de conflictos para debugging
- Testing con cambios simultáneos

---

### T59 - Implementar Indicadores de Estado Offline
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T56  
**Descripción:** Añadir indicadores visuales del estado de conexión y sincronización en la UI.

**Criterios de aceptación:**
- Indicador de conexión (online/offline)
- Contador de cambios pendientes
- Estado de sincronización en tiempo real
- Notificaciones de reconexión
- Indicadores en cada evento si tiene cambios pendientes

---

### T60 - Implementar Sincronización en Tiempo Real
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Depende de:** T56, T57  
**Descripción:** Implementar Firestore listeners para sincronización en tiempo real cuando hay conexión.

**Criterios de aceptación:**
- Firestore real-time listeners por plan
- Actualización automática de UI al recibir cambios
- Manejo de reconexión automática
- Optimización de listeners (solo cuando app está activa)
- Testing de sincronización en tiempo real

---

### T61 - Implementar Notificaciones Push Offline
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T60  
**Descripción:** Implementar sistema de notificaciones push que funcione con el sistema offline.

**Criterios de aceptación:**
- Notificaciones locales cuando está offline
- Notificaciones push cuando está online
- Configuración de notificaciones por usuario
- Notificaciones de sincronización completada
- Manejo de notificaciones duplicadas

---

### T62 - Testing Exhaustivo Offline First
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T56-T61  
**Descripción:** Testing completo del sistema offline first en diferentes escenarios.

**Criterios de aceptación:**
- Testing sin conexión desde el inicio
- Testing con pérdida de conexión durante uso
- Testing de reconexión automática
- Testing de conflictos simultáneos
- Testing de performance con muchos eventos
- Testing de migración de datos

---

## 🔐 SISTEMA DE PERMISOS GRANULARES - Serie de Tareas (T63-T67)

### T63 - Implementar Modelo de Permisos y Roles
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Bloqueante para T64-T67  
**Descripción:** Implementar el sistema base de permisos granulares con roles y permisos específicos.

**Criterios de aceptación:**
- Definir enum `UserRole` (admin, participant, observer)
- Definir enum `Permission` con todos los permisos específicos
- Crear clase `PlanPermissions` para gestionar permisos por usuario/plan
- Implementar `PermissionService` con métodos de validación
- Cache de permisos para optimización
- Testing de validación de permisos

**Archivos a crear:**
- `lib/shared/models/user_role.dart`
- `lib/shared/models/permission.dart`
- `lib/shared/models/plan_permissions.dart`
- `lib/shared/services/permission_service.dart`

---

### T64 - Implementar UI Condicional Basada en Permisos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Depende de:** T63  
**Descripción:** Modificar EventDialog y otras UIs para mostrar/ocultar elementos según permisos del usuario.

**Criterios de aceptación:**
- EventDialog con campos editables/readonly según permisos
- Indicadores visuales de permisos (iconos, badges)
- Botones de acción condicionales (crear, editar, eliminar)
- Parte personal editable solo por propietario + admins
- Parte común editable solo por creador + admins
- Responsive design mantenido

**Archivos a modificar:**
- `lib/widgets/wd_event_dialog.dart`
- `lib/widgets/screens/wd_calendar_screen.dart`
- Crear: `lib/widgets/wd_permission_based_field.dart`

---

### T65 - Implementar Gestión de Admins del Plan
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T63  
**Descripción:** Implementar funcionalidad para promover/degradar usuarios a admin del plan.

**Criterios de aceptación:**
- UI para gestionar admins del plan
- Promoción de participante a admin
- Degradación de admin a participante
- Validación: al menos 1 admin siempre
- Notificaciones de cambio de rol
- Historial de cambios de permisos

**Archivos a crear:**
- `lib/pages/pg_plan_admins_page.dart`
- `lib/widgets/wd_admin_management_dialog.dart`

---

### T66 - Implementar Transferencia de Propiedad de Eventos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T63, T64  
**Descripción:** Permitir transferir la propiedad de un evento de un usuario a otro.

**Criterios de aceptación:**
- Opción "Transferir evento" en EventDialog (solo para creador + admins)
- Selector de nuevo propietario
- Confirmación de transferencia
- Actualización de permisos automática
- Historial de transferencias
- Notificación al nuevo propietario

**Archivos a modificar:**
- `lib/widgets/wd_event_dialog.dart`
- Crear: `lib/widgets/wd_transfer_event_dialog.dart`

---

### T67 - Implementar Sistema de Observadores
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Depende de:** T63, T64  
**Descripción:** Implementar rol de observador con permisos de solo lectura.

**Criterios de aceptación:**
- Rol "Observador" con permisos de solo lectura
- UI diferenciada para observadores (sin botones de edición)
- Indicadores visuales de modo observador
- Opción para convertir participante a observador
- Acceso completo a visualización pero sin edición

**Archivos a modificar:**
- `lib/widgets/wd_event_dialog.dart`
- `lib/widgets/screens/wd_calendar_screen.dart`
- Actualizar: `lib/shared/services/permission_service.dart`

---

## 🔐 FASE 2: SEGURIDAD Y VALIDACIÓN - Serie de Tareas (T51-T53)

### T51 - Añadir Validación a Formularios
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Alta - Hacer cuando el código esté estable  
**Descripción:** Añadir validación de entrada de datos en todos los formularios para prevenir que datos inválidos entren a Firestore.

**Problema actual:** Formularios sin validación permiten:
- Nombres de plan vacíos
- IDs con caracteres inválidos
- Emails mal formateados
- Campos obligatorios sin completar

**Formularios a validar:**

#### **1. pg_create_plan_page.dart - Crear Plan**
```dart
// Campo: Nombre del Plan
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'El nombre del plan es obligatorio';
  }
  if (value.trim().length < 3) {
    return 'El nombre debe tener al menos 3 caracteres';
  }
  return null;
}

// Campo: UNP ID
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'El ID del plan es obligatorio';
  }
  if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
    return 'Solo letras mayúsculas y números';
  }
  return null;
}
```

#### **2. pg_plan_participants_page.dart - Añadir Participante**
```dart
// Campo: Email del usuario
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'El email es obligatorio';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Email inválido';
  }
  return null;
}
```

#### **3. Otros formularios a revisar:**
- `wd_event_dialog.dart` - Validar descripción obligatoria (ya existe ✅)
- `wd_accommodation_dialog.dart` - Validar nombre y fechas (ya existe ✅)
- `edit_profile_page.dart` - Validar nombre y bio (revisar)
- `account_settings_page.dart` - Validar email y contraseña (revisar)

**Criterios de aceptación:**
- Todos los `TextFormField` tienen `validator` apropiado
- Mensajes de error claros y en español
- Validación en cliente antes de enviar a Firestore
- Testing manual de cada formulario con datos inválidos
- `_formKey.currentState!.validate()` antes de guardar

**Archivos a modificar:**
- `lib/pages/pg_create_plan_page.dart`
- `lib/pages/pg_plan_participants_page.dart`
- Revisar: `lib/features/auth/presentation/pages/edit_profile_page.dart`
- Revisar: `lib/features/auth/presentation/pages/account_settings_page.dart`

---

### T52 - Añadir Checks `mounted` antes de usar Context
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja-Media  
**Prioridad:** 🟠 Media - Prevenir crashes  
**Descripción:** Añadir verificaciones `mounted` antes de usar `context` en callbacks asíncronos para prevenir errores cuando el widget ya está disposed.

**Problema actual:** Uso de `context` después de operaciones asíncronas sin verificar si el widget sigue montado → puede causar crashes.

**Patrón a implementar:**
```dart
// ❌ ANTES:
Future<void> _deleteItem() async {
  await service.delete(id);
  Navigator.of(context).pop(); // ❌ context puede estar disposed
  ScaffoldMessenger.of(context).showSnackBar(...); // ❌ crash potencial
}

// ✅ DESPUÉS:
Future<void> _deleteItem() async {
  await service.delete(id);
  if (!mounted) return;
  
  Navigator.of(context).pop();
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}
```

**Ubicaciones encontradas (~15 casos):**

1. **lib/widgets/wd_event_dialog.dart** (3 casos)
   - `_confirmDelete()` - línea ~463
   - `_saveEvent()` callback - línea ~484
   
2. **lib/pages/pg_dashboard_page.dart** (12 casos)
   - `_deletePlan()` - línea ~190
   - `_onPlanTap()` - varios callbacks
   - `_createPlanWithImage()` - línea ~1700+
   
3. **lib/widgets/wd_accommodation_dialog.dart** (3 casos)
   - `_confirmDelete()` - línea ~284
   - Callbacks ya tienen algunos checks (revisar)
   
4. **lib/pages/pg_create_plan_page.dart** (1 caso)
   - `_createPlan()` - línea ~80+

**Criterios de aceptación:**
- Añadir `if (!mounted) return;` después de operaciones async
- Verificar `mounted` antes de cada uso de `context`
- Verificar `mounted` antes de `setState()`
- Testing: verificar que no hay crashes al cerrar diálogos rápidamente
- Documentar el patrón en código cuando sea complejo

**Archivos a modificar:**
- `lib/widgets/wd_event_dialog.dart`
- `lib/widgets/wd_accommodation_dialog.dart`
- `lib/pages/pg_dashboard_page.dart`
- `lib/pages/pg_create_plan_page.dart`

---

### T53 - Reemplazar print() por LoggerService
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Baja - Mejora de debugging  
**Descripción:** Reemplazar todos los `print()` statements por `LoggerService` para mejor control de logs y performance en producción.

**Problema actual:** 33 `print()` statements que:
- Se ejecutan en producción (impacto en performance)
- No tienen control de nivel de log
- Dificultan debugging al mezclar con logs del sistema

**Patrón a implementar:**
```dart
// ❌ ANTES:
catch (e) {
  print('Error picking image: $e');
  return null;
}

// ✅ DESPUÉS:
catch (e) {
  LoggerService.error('Error picking image', error: e);
  return null;
}
```

**Casos por tipo:**

#### **Errores (usar LoggerService.error):**
- `lib/features/calendar/domain/services/image_service.dart` - 3 prints
- `lib/features/calendar/domain/services/event_service.dart` - 2 prints
- `lib/features/calendar/presentation/providers/database_overview_providers.dart` - 2 prints

#### **Debug (usar LoggerService.debug):**
- `lib/features/auth/presentation/notifiers/auth_notifier.dart` - 3 prints
- `lib/widgets/wd_overlapping_events_cell.dart` - 1 print

#### **Eliminar completamente (obsoletos):**
- `lib/widgets/screens/simple_calendar_screen.dart` - Ya eliminado ✅

**Total encontrado:** 33 statements en 8 archivos

**Criterios de aceptación:**
- 0 `print()` statements en código de producción
- Usar `LoggerService.error()` para errores
- Usar `LoggerService.debug()` para debug (solo en modo debug)
- Usar `LoggerService.info()` para información importante
- Verificar que `LoggerService` ya solo imprime en debug mode
- Testing: verificar logs en consola durante desarrollo

**Archivos a modificar:**
- `lib/features/calendar/domain/services/image_service.dart`
- `lib/features/calendar/domain/services/event_service.dart`
- `lib/features/auth/presentation/notifiers/auth_notifier.dart`
- `lib/features/calendar/presentation/providers/database_overview_providers.dart`
- `lib/widgets/wd_overlapping_events_cell.dart`
- Otros 3-4 archivos con prints menores

---

## 🌍 SISTEMA DE TIMEZONES - Serie de Tareas (T40-T45)

**⚠️ Recordatorio:** Al completar estas tareas, actualizar el Plan Frankenstein (`lib/features/testing/demo_data_generator.dart`) con casos de prueba para eventos con diferentes timezones y vuelos cross-timezone.

**📌 Nota Importante:** Esta serie debe implementarse ANTES de T46-T50 (Participantes), ya que el sistema de participantes requiere conversión de timezone por usuario.

### T40 - Fundamentos Timezone (Base)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🔴 Bloqueante para T41-T45 (y recomendado para T46-T50)  
**Descripción:** Implementar la base fundamental del sistema de timezones. Añadir soporte para que cada evento almacene y muestre su hora en la timezone local donde ocurre el evento.  

**Concepto clave:** Un evento "Almuerzo en Delhi a las 13:00h" debe mostrarse a las 13:00h tanto si lo ve alguien desde España como desde India. La hora es LOCAL del lugar donde ocurre el evento, no del dispositivo que lo visualiza.

**Criterios de aceptación:** 
- Añadir campo `timezone` (String) al modelo Event (`lib/features/calendar/domain/models/event.dart`)
- Modificar `toFirestore()` y `fromFirestore()` para incluir timezone
- Implementar conversión UTC ↔️ Timezone local del evento
- Añadir dependencia `timezone` al `pubspec.yaml`
- Inicializar base de datos de timezones en la app
- Guardar eventos en Firestore como UTC + timezone
- Mostrar eventos en calendario con hora LOCAL (convertida desde UTC usando timezone del evento)
- Migración suave: eventos existentes sin timezone usan timezone por defecto
- Testing con al menos 3 timezones diferentes (Europa, Asia, América)

**Consideraciones técnicas:**
- Usar paquete `timezone: ^0.9.0` (o última versión estable)
- Almacenar en Firestore: `DateTime` en UTC + `String timezone` (ej: "Asia/Kolkata", "Europe/Madrid")
- Para mostrar: convertir UTC → timezone del evento usando `TZDateTime`
- Formato timezone: IANA timezone database (ej: "Europe/Madrid", "Asia/Kolkata", "America/New_York")
- Manejar DST (Daylight Saving Time) automáticamente con librería timezone

**Archivos a modificar:**
- `lib/features/calendar/domain/models/event.dart` - añadir campo timezone
- `lib/features/calendar/domain/services/event_service.dart` - manejar conversión UTC
- `lib/widgets/screens/wd_calendar_screen.dart` - mostrar hora local del evento
- `pubspec.yaml` - añadir dependencia timezone

---

### T41 - EventDialog: Selector de Timezone
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T40  
**Descripción:** Añadir selector de timezone en EventDialog para que el usuario pueda especificar en qué timezone ocurre el evento.

**Concepto clave:** 
- El evento ocurre en una ubicación física específica con su timezone
- Ej: "Reunión en Nueva York" → timezone: America/New_York
- Ej: "Vuelo a Tokio" → timezone: Asia/Tokyo

**Criterios de aceptación:**
- Dropdown de timezone en EventDialog
- Búsqueda/filtrado de timezones por nombre o ciudad
- Mostrar offset GMT actual (ej: "GMT-5", "GMT+9")
- Timezone por defecto: timezone del plan
- Validación: timezone obligatoria
- Autocompletado de timezone según ubicación (si se introduce)
- Visual: mostrar hora local del evento en la timezone seleccionada

**UI propuesta:**
```
┌──────────────────────────────────┐
│ 📍 Ubicación: Nueva York         │
│ 🌍 Timezone: America/New_York ▼  │
│    (GMT-5)                       │
│                                  │
│ 🕐 Hora: 14:00 (hora local)      │
└──────────────────────────────────┘
```

**Archivos a modificar:**
- `lib/widgets/wd_event_dialog.dart`
- Crear: `lib/widgets/wd_timezone_selector.dart`

---

### T42 - Conversión de Timezone en Calendario
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Depende de:** T40, T41  
**Descripción:** Mostrar eventos en el calendario con conversión automática de timezone según el evento.

**Concepto clave:**
- Evento guardado en UTC + timezone del evento
- Calendario muestra hora LOCAL del evento (no del dispositivo)
- "Reunión en NY a las 14:00" siempre se muestra a las 14:00

**Criterios de aceptación:**
- Convertir UTC → timezone del evento para mostrar
- Formato de hora según timezone del evento
- Indicador visual si timezone del evento != timezone del plan
- Tooltip mostrando hora en UTC y hora local del dispositivo
- Manejo correcto de DST (Daylight Saving Time)
- Performance: cachear conversiones

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- `lib/features/calendar/domain/services/timezone_service.dart`

---

### T43 - Migración de Eventos Existentes a Timezone
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T40  
**Descripción:** Migrar eventos existentes sin timezone al nuevo sistema.

**Concepto clave:**
- Eventos antiguos no tienen campo timezone
- Asignar timezone por defecto (timezone del plan)
- Migración transparente sin pérdida de datos

**Criterios de aceptación:**
- Script de migración para eventos existentes
- Asignar timezone del plan como default
- Convertir fechas/horas existentes correctamente
- Validación post-migración
- Rollback automático si falla
- Log de eventos migrados

**Archivos a crear:**
- `lib/features/calendar/data/migrations/timezone_migration.dart`

---

### T44 - Testing de Timezones
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T40-T43  
**Descripción:** Testing exhaustivo del sistema de timezones con múltiples casos.

**Casos de prueba:**
1. Evento en timezone positiva (GMT+9 Tokio)
2. Evento en timezone negativa (GMT-5 Nueva York)
3. Evento cross-timezone (vuelo Londres → Nueva York)
4. Evento durante cambio DST
5. Evento en UTC
6. Múltiples eventos en diferentes timezones
7. Performance con muchos eventos

**Criterios de aceptación:**
- Tests unitarios de conversión UTC ↔️ timezone
- Tests de widget con timezones
- Tests de migración
- Tests de performance
- Casos edge documentados
- Sin errores de precisión (minutos exactos)

**Archivos a crear:**
- `test/features/calendar/timezone_test.dart`
- `test/features/calendar/timezone_widget_test.dart`

---

### T45 - Plan Frankenstein: Casos de Timezone
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Depende de:** T40-T44  
**Descripción:** Añadir casos de prueba de timezones al Plan Frankenstein.

**Casos a añadir:**
```dart
// Día 6: Eventos en diferentes timezones
- Evento 1: "Llamada con NY" (America/New_York, GMT-5)
- Evento 2: "Reunión Madrid" (Europe/Madrid, GMT+1)
- Evento 3: "Call con Tokio" (Asia/Tokyo, GMT+9)
- Evento 4: "Vuelo cross-timezone" (cambia timezone durante evento)
```

**Criterios de aceptación:**
- Al menos 4 eventos con timezones diferentes
- Incluir timezone positiva, negativa y UTC
- Evento que cruza cambio de timezone (vuelo)
- Visual claro de diferencias de timezone
- Documentar en FRANKENSTEIN_PLAN_SPEC.md

**Archivos a modificar:**
- `lib/features/testing/demo_data_generator.dart`
- `docs/FRANKENSTEIN_PLAN_SPEC.md`

---

### T47 - EventDialog: Selector de participantes
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Depende de:** T46  
**Descripción:** Añadir al EventDialog la funcionalidad para seleccionar participantes del evento. Incluir opción "todos los participantes" y selector multi-selección.

**UI propuesta:**
```
┌─────────────────────────────────────┐
│ ☑️ Este evento es para todos        │
│                                     │
│ Si no está marcado:                 │
│ ┌─────────────────────────────┐    │
│ │ Seleccionar participantes:   │    │
│ │ ☑️ Juan Pérez (Organizador)  │    │
│ │ ☑️ María García             │    │
│ │ ☐ Pedro López               │    │
│ │ ☑️ Ana Martínez             │    │
│ └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Criterios de aceptación:**
- **Checkbox principal:** "Este evento es para todos los participantes del plan"
  - Por defecto: checked (true)
  - Al marcar: ocultar lista de participantes, `isForAllParticipants = true`
  - Al desmarcar: mostrar lista de participantes del plan

- **Lista de participantes** (solo visible si checkbox principal está desmarcado):
  - Cargar participantes activos del plan desde `PlanParticipation`
  - Mostrar cada participante con checkbox individual
  - Indicar rol: "(Organizador)" o "(Participante)"
  - **El creador del evento** aparece pre-seleccionado y deshabilitado (siempre incluido)
  - Validación: Al menos 1 participante debe estar seleccionado

- **Guardar evento:**
  - Si checkbox principal ON → `isForAllParticipants = true`, `participantIds = []`
  - Si checkbox principal OFF → `isForAllParticipants = false`, `participantIds = [IDs seleccionados]`

- **Editar evento existente:**
  - Cargar estado desde `event.isForAllParticipants` y `event.participantIds`
  - Pre-seleccionar participantes correctamente

- **Visual responsive:** funcional en móvil y desktop
- **Performance:** No recargar lista en cada rebuild

**Archivos a modificar:**
- `lib/widgets/wd_event_dialog.dart`

**Consideraciones técnicas:**
- Usar `ref.watch(planParticipantsProvider(planId))` para obtener participantes
- Mantener estado local con `List<String> _selectedParticipantIds`
- Toggle principal controla visibilidad de la lista
- Validación antes de guardar

---

### T48 - Lógica de filtrado: Eventos por participante
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T46  
**Descripción:** Implementar lógica de filtrado de eventos según el participante seleccionado. Un usuario solo debe ver eventos donde está incluido.

**Lógica de filtrado:**
```dart
bool shouldShowEvent(Event event, String currentUserId) {
  // Caso 1: Evento para todos
  if (event.isForAllParticipants) return true;
  
  // Caso 2: Usuario es el creador
  if (event.userId == currentUserId) return true;
  
  // Caso 3: Usuario está en la lista de participantes
  if (event.participantIds.contains(currentUserId)) return true;
  
  // No mostrar
  return false;
}
```

**Criterios de aceptación:**
- Crear método de filtrado en `EventService` o como extensión de `Event`
- Aplicar filtro en providers que sirven eventos (`eventsForDateProvider`, etc.)
- **Filtro automático:** Por defecto, un usuario solo ve:
  1. Eventos con `isForAllParticipants = true`
  2. Eventos donde `event.participantIds.contains(userId)`
  3. Eventos creados por él (`event.userId == userId`)

- **Respetar permisos:** No mostrar eventos privados de otros usuarios
- Testing: Verificar que cada usuario ve solo sus eventos relevantes
- Performance: Filtrar en query de Firestore si es posible (evaluar índices)

**Archivos a modificar:**
- `lib/features/calendar/domain/services/event_service.dart`
- `lib/features/calendar/presentation/providers/calendar_providers.dart`

**Consideraciones técnicas:**
- Si Firestore no puede hacer query compuesta (isForAllParticipants OR participantIds contains), filtrar en cliente
- Cachear resultados para evitar recálculos
- Documentar comportamiento del filtro

---

### T49 - UI Calendario: Filtro de participantes
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Depende de:** T46, T48  
**Descripción:** Añadir filtro visual en el calendario para ver eventos de participantes específicos o de todos.

**⚠️ NOTA:** Esta es una versión simplificada del filtro. Cuando se implemente el sistema de tracks (T71), esta funcionalidad se reemplazará por los filtros avanzados de T71, T78, T79 y T80. Considerar si implementar esta tarea o pasar directamente al sistema de tracks.

**UI propuesta (en AppBar del calendario):**
```
┌──────────────────────────────────────┐
│  📅 Calendario    [🔍 Filtrar: Todos ▼] │
└──────────────────────────────────────┘

Al desplegar:
┌─────────────────────┐
│ ✓ Todos los eventos │
│   Solo mis eventos  │
│   ─────────────────  │
│   Juan Pérez        │
│   María García      │
│   Ana Martínez      │
└─────────────────────┘
```

**Criterios de aceptación:**
- **Dropdown/BottomSheet** con opciones:
  1. "Todos los eventos" (default) - muestra eventos según reglas de T48
  2. "Solo mis eventos" - solo `userId == currentUser` o `participantIds.contains(currentUser)` y no `isForAllParticipants`
  3. Lista de participantes del plan - eventos específicos de ese participante

- **Indicador visual activo:**
  - Badge o color en dropdown cuando hay filtro aplicado
  - Texto: "Filtrando por: [Nombre]" si no es "Todos"

- **Persistencia:**
  - Guardar filtro seleccionado en estado local (no Firestore)
  - Al cambiar de plan, resetear a "Todos"

- **Integración con providers:**
  - Pasar `filteredUserId` a providers de eventos
  - Re-fetch eventos al cambiar filtro

- **Contador de eventos filtrados** (opcional):
  - "Mostrando 15 de 23 eventos" si hay filtro activo

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- Posiblemente crear widget específico: `lib/widgets/wd_event_filter_dropdown.dart`

**Consideraciones técnicas:**
- Usar `DropdownButton` o `PopupMenuButton`
- Estado del filtro: `String? _selectedParticipantId` (null = todos)
- Re-invalidar providers al cambiar filtro

---

### T50 - Indicadores visuales de participantes en eventos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Depende de:** T46, T47  
**Descripción:** Añadir indicadores visuales en los eventos del calendario para mostrar rápidamente si un evento es para todos o para participantes específicos.

**⚠️ NOTA:** Esta tarea es para el calendario tradicional (sin tracks). Cuando se implemente el sistema de tracks (T69), esta funcionalidad evolucionará a T89 (Indicadores Visuales de Eventos Multi-Participante). Evaluar si implementar o esperar a tracks.

**Indicadores propuestos:**

1. **Badge de participantes:**
   ```
   ┌──────────────────────┐
   │ 🍽️ Cena restaurante  │
   │ 19:00 - 21:00        │
   │ 👥 3 participantes   │ ← Badge pequeño
   └──────────────────────┘
   ```

2. **Icono según tipo:**
   - 👥 Todos los participantes (isForAllParticipants = true)
   - 👤 Evento personal (solo 1 participante)
   - 👥 N participantes seleccionados (ej: "👥 3")

3. **Color/estilo diferente:**
   - Borde más grueso para eventos de todos
   - Opacidad reducida para eventos donde no participo pero puedo ver

**Criterios de aceptación:**
- Mostrar icono/badge solo si el evento NO es para todos y tiene espacio visual (height > 30px)
- Badge muestra:
  - Si `isForAllParticipants = true` → icono 👥 o texto "Todos"
  - Si `isForAllParticipants = false` → "👥 X" donde X = número de participantes
- Tooltip al hacer hover (en web/desktop): lista de nombres de participantes
- No sobrecargar visualmente: diseño minimalista
- Adaptativo según tamaño del evento

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart` (en `_buildDraggableEvent` y `_buildDraggableEventForNextDay`)

**Consideraciones técnicas:**
- Calcular número de participantes: `event.participantIds.length`
- Cargar nombres de participantes solo para tooltip (lazy loading)
- Considerar que eventos muy pequeños no tienen espacio para badge

---

## 👥 SISTEMA DE PARTICIPANTES EN EVENTOS - Serie de Tareas (T46-T50)

**⚠️ Recordatorio:** Al completar estas tareas, actualizar el Plan Frankenstein (`lib/features/testing/demo_data_generator.dart`) con casos de prueba para eventos con participantes específicos.

**📌 Nota:** Se recomienda implementar T40-T45 (Timezones) ANTES de esta serie, ya que cada participante puede tener su timezone local.

### T46 - Modelo Event: Añadir participantes y campos multiusuario
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Bloqueante para T47-T50  
**Descripción:** Modificar el modelo Event para incluir sistema de participantes. Añadir campos para gestionar qué participantes del plan están incluidos en cada evento.

**Concepto clave:** Un evento puede ser para:
- **Todos los participantes del plan** (por defecto) - `isForAllParticipants = true`
- **Solo algunos participantes seleccionados** - `isForAllParticipants = false` + lista `participantIds`
- El `userId` sigue siendo el creador/propietario del evento

**Campos a añadir:**
```dart
class Event {
  final String userId;                    // Creador (ya existe)
  final List<String> participantIds;      // NUEVO: IDs de participantes incluidos
  final bool isForAllParticipants;        // NUEVO: true = todos, false = solo seleccionados
  // ... resto de campos existentes
}
```

**Criterios de aceptación:**
- Añadir `participantIds` (List<String>, nullable o vacía por defecto) al modelo Event
- Añadir `isForAllParticipants` (bool, default: true) al modelo Event
- Modificar `toFirestore()` para guardar nuevos campos
- Modificar `fromFirestore()` para leer nuevos campos (con compatibilidad hacia atrás)
- Actualizar `copyWith()` para incluir nuevos campos
- Actualizar `==` operator y `hashCode`
- **Migración suave:** Eventos existentes sin estos campos se interpretan como `isForAllParticipants = true`
- Testing: crear evento con todos los participantes vs solo algunos

**Archivos a modificar:**
- `lib/features/calendar/domain/models/event.dart`

**Reglas de negocio:**
- Si `isForAllParticipants = true` → `participantIds` puede estar vacía (se ignora)
- Si `isForAllParticipants = false` → `participantIds` debe tener al menos 1 ID (el creador por defecto)
- El creador (`userId`) siempre está incluido implícitamente

---

## T35 - Copiar y pegar eventos en el calendario
**Estado:** Pendiente  
**Descripción:** Permitir copiar y pegar eventos en el calendario. Definir la mejor forma de implementarlo.  
**Criterios de aceptación:** 
- Definir método de selección de eventos (Ctrl+C, menú contextual, etc.)
- Implementar funcionalidad de copiar evento
- Implementar funcionalidad de pegar evento
- Mantener propiedades del evento original (descripción, duración, tipo, color)
- Permitir modificar fecha/hora al pegar
- Feedback visual del proceso de copiado/pegado
- Documentar funcionalidad

---

## T37 - Gestión de eventos en borrador
**Estado:** Pendiente  
**Descripción:** Definir cómo seleccionar y mostrar eventos en borrador en el calendario.  
**Criterios de aceptación:** 
- Mostrar visualmente eventos en borrador (borde punteado, opacidad, etc.)
- Filtro para mostrar/ocultar eventos en borrador
- Mantener funcionalidad de cambiar estado de borrador
- Diferenciación clara entre eventos confirmados y borradores
- Consistencia visual con el diseño del calendario
- Documentar comportamiento

---

## T38 - Eliminar 'Alojamiento' del diálogo de eventos
**Estado:** Pendiente  
**Descripción:** Eliminar la opción 'Alojamiento' del tipo de familia de eventos en el diálogo de eventos. Los alojamientos tendrán su propio diálogo separado y específico.  
**Criterios de aceptación:** 
- Remover 'Alojamiento' de la lista de tipos de familia en EventDialog
- Verificar que no rompa eventos existentes de tipo alojamiento en Firestore
- Documentar la separación de conceptos
- Los alojamientos seguirán existiendo pero se gestionarán desde su propio diálogo

---

## T31 - Aumentar tamaño de letra de widgets W...
**Estado:** Pendiente  
**Descripción:** Aumentar el tamaño de la letra de los widgets W... para mejorar la legibilidad.  
**Criterios de aceptación:** 
- Identificar todos los widgets W... que necesitan ajuste de tipografía
- Aumentar tamaño de fuente de manera consistente
- Mantener proporciones y diseño visual
- Verificar legibilidad en diferentes tamaños de pantalla
- Documentar cambios realizados

---

## T18 - Página de administración de Firebase
**Estado:** Pendiente  
**Descripción:** Página de administración de Firebase: Quiero crear una página para poder administrar los datos que tenemos en firebase. El acceso será...  
**Criterios de aceptación:** 
- Página de administración de Firebase
- Acceso a datos de Firebase
- Funcionalidades de administración

---

## T19 - Valorar mouse hover en widgets W14-W25
**Estado:** Pendiente  
**Descripción:** Valorar si activamos el mouse hover en los widgets W14 a W25. Evaluar si añadir efectos visuales cuando el usuario pasa el mouse por encima de estos widgets mejoraría la experiencia de usuario.  
**Criterios de aceptación:** 
- Evaluar la experiencia actual sin hover
- Probar efectos de hover (cambio de color, escala, sombra, etc.)
- Considerar consistencia con el resto de la aplicación
- Decidir si implementar hover basado en pruebas de usabilidad
- Implementar hover si se decide que mejora la UX

---

## T20 - Página de miembros del plan
**Estado:** Pendiente  
**Descripción:** Crear la página de miembros del plan. Es una página que ha de mostrar los miembros del plan actuales, permitir eliminar y añadir miembros. Hay que definir las acciones de añadir, editar, eliminar participantes. Hemos de actualizar toda la documentación relacionada con la página.  
**Criterios de aceptación:** 
- Página completa de gestión de miembros del plan
- Mostrar lista de miembros actuales del plan
- Funcionalidad para añadir nuevos miembros
- Funcionalidad para eliminar miembros existentes
- Funcionalidad para editar información de miembros
- Interfaz de usuario intuitiva y consistente
- Integración con el sistema de participación existente
- Documentación completa actualizada
- Pruebas de funcionalidad

---

## T22 - Definir sistema de IDs de planes
**Estado:** Pendiente  
**Descripción:** Definir cómo se generan los IDs de cada plan. Hay que tener en cuenta que en un momento dado, muchos usuarios pueden crear planes casi simultáneamente. Analizar problemas y riesgos, y proponer una solución robusta.  
**Criterios de aceptación:** 
- Analizar problemas de concurrencia en generación de IDs
- Identificar riesgos de colisiones de IDs
- Proponer sistema robusto de generación de IDs
- Implementar la solución elegida
- Documentar el sistema de IDs

---

## T23 - Mejorar modal para crear plan
**Estado:** Pendiente  
**Descripción:** Mejorar el modal para crear plan. El título ha de ser "nuevo plan". El campo ID ha de obtener el valor del sistema definido. La lista de participantes hay que mejorarla.  
**Criterios de aceptación:** 
- Cambiar título del modal a "nuevo plan"
- Integrar sistema de IDs automático
- Mejorar interfaz de selección de participantes
- Optimizar experiencia de usuario del modal
- Documentar mejoras implementadas

---

## T24 - Discutir mobile first para iOS y Android
**Estado:** Pendiente  
**Descripción:** Discutir cómo pasar la app a mobile first en iOS y Android. Hay que modificar la app para que trabaje en modo mobile first en las versiones para iOS y Android.  
**Criterios de aceptación:** 
- Analizar requerimientos para mobile first
- Discutir estrategia de adaptación
- Planificar modificaciones necesarias
- Implementar cambios para mobile first
- Documentar proceso de migración


## 📝 Notas
- Las tareas están ordenadas por prioridad (posición en el documento)
- Los códigos de tarea no se reutilizan al eliminar tareas
- Cada tarea completada debe marcarse como "Completada" y actualizarse la fecha
- Las tareas completadas se han movido a `docs/COMPLETED_TASKS.md`

---

## 🔧 Mejoras de Eventos - Alta Prioridad

### T27: Mejorar área clickeable en eventos pequeños
**Estado:** ⏳ Pendiente  
**Descripción:** Optimizar la selección de eventos pequeños para mejorar la experiencia de usuario.  
**Criterios de aceptación:**
- Área clickeable optimizada para eventos de altura mínima
- Feedback visual claro al hacer hover
- Prevención de clicks accidentales
- Consistencia con eventos de tamaño normal

### T28: Mejorar algoritmo de solapamientos
**Estado:** ⏳ Pendiente  
**Descripción:** Optimizar la detección y visualización de eventos que se solapan.  
**Criterios de aceptación:**
- Detección precisa de conflictos con minutos exactos
- Visualización clara de eventos solapados
- Manejo correcto de múltiples eventos en la misma hora
- Colores y posicionamiento optimizados

### T29: Mostrar duración exacta en eventos
**Estado:** ⏳ Pendiente  
**Descripción:** Añadir información de duración exacta en la visualización de eventos.  
**Criterios de aceptación:**
- Mostrar hora de inicio y fin (ej: "13:15 - 15:30")
- Duración en formato legible (ej: "2h 15min")
- Texto legible en eventos pequeños
- Consistencia visual con el diseño

---

## 🎨 MEJORAS VISUALES - Serie de Tareas (T91-T92)

### T91 - Mejorar colores de eventos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Baja (Aplicar cuando el calendario esté definitivo)  
**Descripción:** Mejorar la paleta de colores de eventos para una mejor experiencia visual y legibilidad.

**Criterios de aceptación:**
- Revisar y optimizar colores de eventos existentes
- Crear paleta de colores consistente y accesible
- Mejorar contraste para mejor legibilidad
- Aplicar colores diferenciados por tipo de evento
- Mantener coherencia visual con el diseño general
- Testing de accesibilidad de colores
- Documentar nueva paleta de colores

**Archivos a modificar:**
- `lib/app/theme/color_scheme.dart`
- `lib/widgets/screens/wd_calendar_screen.dart`
- `lib/widgets/wd_event_dialog.dart`

---

### T92 - Mejorar tipografía de eventos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Baja (Aplicar cuando el calendario esté definitivo)  
**Descripción:** Optimizar la tipografía de eventos para mejorar la legibilidad y experiencia de usuario.

**Criterios de aceptación:**
- Revisar tamaños de fuente en eventos
- Optimizar jerarquía tipográfica
- Mejorar legibilidad en eventos pequeños
- Aplicar tipografía consistente en toda la app
- Optimizar para diferentes tamaños de pantalla
- Testing de legibilidad en diferentes dispositivos
- Documentar guía de tipografía

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart`
- `lib/widgets/wd_event_dialog.dart`
- `lib/app/theme/text_theme.dart` (si existe)

---

## ✅ TAREAS COMPLETADAS RECIENTEMENTE

### T93 - Implementar iconos de check-in/check-out en alojamientos
**Estado:** ✅ Completado  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Mejorar la visualización de alojamientos multi-día con iconos que indican check-in y check-out.

**Criterios de aceptación:**
- ✅ Agregar iconos ➡️ para check-in (primer día)
- ✅ Agregar iconos ⬅️ para check-out (último día)
- ✅ Mantener texto normal para días intermedios
- ✅ Mejorar claridad visual de alojamientos multi-día
- ✅ Funcionalidad de tap para crear/editar alojamientos

**Archivos modificados:**
- `lib/widgets/screens/wd_calendar_screen.dart`

---

### T94 - Optimización y limpieza de código en CalendarScreen
**Estado:** ✅ Completado  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Refactorización y optimización del código en el archivo principal del calendario.

**Criterios de aceptación:**
- ✅ Crear constantes para valores repetidos (alturas, opacidades)
- ✅ Consolidar funciones helper para bordes y decoraciones
- ✅ Limpiar debug logs temporales
- ✅ Optimizar imports y estructura del código
- ✅ Mejorar legibilidad y mantenibilidad

**Archivos modificados:**
- `lib/widgets/screens/wd_calendar_screen.dart`

---

### T95 - Arreglar interacción de tap en fila de alojamientos
**Estado:** ✅ Completado  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Alta  
**Descripción:** Solucionar problema de detección de tap en la fila de alojamientos.

**Criterios de aceptación:**
- ✅ GestureDetector funcional en fila de alojamientos
- ✅ Modal de crear alojamiento se abre correctamente
- ✅ Modal de editar alojamiento funciona
- ✅ Interacción intuitiva y responsiva

**Archivos modificados:**
- `lib/widgets/screens/wd_calendar_screen.dart`