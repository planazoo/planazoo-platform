# 📋 Lista de Tareas - Planazoo

> Consulta las normas y flujo de trabajo en `docs/CONTEXT.md`.

**Siguiente código de tarea: T100**

**📊 Resumen de tareas por grupos:**
- **GRUPO 1:** T68, T69, T70, T72: Fundamentos de Tracks (4 completadas)
- **GRUPO 2:** T71, T73: Filtros y Control (2 completadas)
- **GRUPO 3:** T46, T74, T75, T76: Parte Común + Personal (4 completadas, 0 pendientes)
- **GRUPO 4:** T56-T60, T63, T64: Infraestructura Offline (7 pendientes)
- **GRUPO 5:** T40-T45, T81, T82: Timezones (8 pendientes)
- **GRUPO 6:** T77-T79, T83-T90: Funcionalidades Avanzadas (4 completadas, 8 pendientes)
- **Tareas Antiguas:** T18-T38: Varias pendientes (15 tareas)
- **Seguridad:** T51-T53: Validación (3 pendientes)
- **Participantes:** T47, T49-T50: Sistema básico (3 pendientes)
- **Permisos:** T65-T67: Gestión de permisos (1 completada, 2 pendientes)
- **Mejoras Visuales:** T91-T92: Colores y tipografía (2 pendientes)
- **Testing y Mantenimiento:** T96-T99: Refactoring, testing y documentación (4 pendientes)

**Total: 68 tareas documentadas (57 completadas, 11 pendientes)**

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
11. **Limpieza al cerrar**: Al completar una tarea, eliminar `print()`, debugs y código temporal que ya no sea necesario

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











## 🌐 VISTAS FILTRADAS Y TIMEZONE POR PARTICIPANTE - Serie de Tareas (T78-T82)




## 🎯 FUNCIONALIDADES AVANZADAS - Serie de Tareas (T83-T90)






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


### T49 - UI Calendario: Filtro de participantes
**Estado:** ❌ Obsoleta  
**Complejidad:** ⚠️ Media  
**Depende de:** T46  
**Descripción:** Añadir filtro visual en el calendario para ver eventos de participantes específicos o de todos.

**⚠️ OBSOLETA:** Esta funcionalidad ha sido reemplazada por el sistema de tracks avanzado (T71, T78, T79, T80). T80 proporciona funcionalidad superior con selección de participantes, drag & drop, y persistencia.

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

## 🧪 TESTING Y MANTENIMIENTO - Serie de Tareas (T96-T99)

### T96 - Refactoring de CalendarScreen
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🔴 Alta  
**Depende de:** T80  
**Descripción:** Dividir `wd_calendar_screen.dart` (3000+ líneas) en componentes más pequeños y mantenibles.

**Problema actual:**
- Archivo monolítico de 3000+ líneas
- Difícil mantenimiento y debugging
- Violación de principios SOLID
- Testing complejo

**Componentes propuestos:**
```
CalendarScreen (orchestrator)
├── CalendarHeader (AppBar + navegación)
├── CalendarGrid (estructura base)
├── CalendarTracks (columnas de participantes)
├── CalendarEvents (eventos y overlays)
├── CalendarInteractions (drag & drop, clicks)
└── CalendarUtils (helpers y cálculos)
```

**Criterios de aceptación:**
- Dividir en al menos 6 componentes independientes
- Mantener funcionalidad exacta actual
- Mejorar legibilidad y mantenibilidad
- Facilitar testing individual
- Reducir complejidad ciclomática

**Archivos a crear:**
- `lib/widgets/screens/calendar/components/calendar_header.dart`
- `lib/widgets/screens/calendar/components/calendar_grid.dart`
- `lib/widgets/screens/calendar/components/calendar_tracks.dart`
- `lib/widgets/screens/calendar/components/calendar_events.dart`
- `lib/widgets/screens/calendar/components/calendar_interactions.dart`

**Archivos a modificar:**
- `lib/widgets/screens/wd_calendar_screen.dart` (refactorizar)

---

### T97 - Testing de Integración
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Alta  
**Depende de:** T96  
**Descripción:** Implementar tests de integración para funcionalidades críticas del calendario.

**Funcionalidades a testear:**
- Creación y gestión de planes
- Sistema de tracks y participantes
- Eventos con parte común/personal
- Filtros y vistas (T80)
- Sincronización de eventos
- Permisos y roles

**Criterios de aceptación:**
- Tests de integración para flujos completos
- Tests de regresión para funcionalidades existentes
- Cobertura mínima del 80% en funcionalidades críticas
- Tests automatizados en CI/CD
- Documentación de casos de prueba

**Archivos a crear:**
- `test/integration/plan_management_test.dart`
- `test/integration/event_management_test.dart`
- `test/integration/track_system_test.dart`
- `test/integration/permissions_test.dart`

---

### T98 - Plan de Pruebas Detallado
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Alta  
**Depende de:** T97  
**Descripción:** Crear un plan de pruebas exhaustivo que cubra todos los casos edge y posibles fallos de la aplicación.

**Plan de pruebas propuesto:**

#### **1. GESTIÓN DE PLANES**
**1.1 Crear Plan**
- ✅ Nombre válido (texto normal)
- ❌ Nombre vacío (debe mostrar error)
- ❌ Nombre solo espacios (debe mostrar error)
- ❌ Nombre muy largo (>100 caracteres)
- ❌ Caracteres especiales peligrosos (<>'"&)
- ✅ Fechas válidas (inicio < fin)
- ❌ Fecha inicio > fecha fin
- ❌ Fechas en el pasado
- ❌ Fechas muy futuras (>2 años)
- ✅ Número de participantes válido (1-20)
- ❌ Número de participantes inválido (0, negativo, >20)

**1.2 Editar Plan**
- ✅ Cambiar nombre del plan
- ✅ Cambiar fechas del plan
- ✅ Añadir participantes
- ✅ Eliminar participantes
- ❌ Eliminar todos los participantes
- ❌ Eliminar el creador del plan
- ✅ Cambiar descripción
- ❌ Cambiar fechas a fechas inválidas

**1.3 Eliminar Plan**
- ✅ Eliminar plan como creador
- ❌ Eliminar plan como participante (sin permisos)
- ❌ Eliminar plan como observador
- ✅ Confirmar eliminación
- ❌ Cancelar eliminación
- ✅ Verificar que se eliminan todos los eventos asociados

#### **2. GESTIÓN DE PARTICIPANTES**
**2.1 Añadir Participantes**
- ✅ Añadir participante válido
- ❌ Añadir participante duplicado
- ❌ Añadir participante con email inválido
- ❌ Añadir más de 20 participantes
- ✅ Añadir participante como admin
- ✅ Añadir participante como observador

**2.2 Cambiar Roles**
- ✅ Promover a admin (máximo 3)
- ❌ Promover a admin cuando ya hay 3
- ✅ Degradar de admin a participante
- ✅ Cambiar a observador
- ❌ Degradar al creador del plan
- ✅ Verificar permisos después del cambio

**2.3 Eliminar Participantes**
- ✅ Eliminar participante normal
- ❌ Eliminar último admin
- ❌ Eliminar creador del plan
- ✅ Verificar que se eliminan sus eventos personales

#### **3. GESTIÓN DE EVENTOS**
**3.1 Crear Evento**
- ✅ Evento básico válido
- ❌ Evento sin descripción
- ❌ Evento sin fecha
- ❌ Evento con fecha inválida
- ❌ Evento con hora inválida
- ❌ Evento con duración negativa
- ❌ Evento con duración muy larga (>24h)
- ✅ Evento para todos los participantes
- ✅ Evento para participantes específicos
- ❌ Evento sin participantes seleccionados

**3.2 Editar Evento**
- ✅ Editar descripción
- ✅ Editar fecha y hora
- ✅ Cambiar participantes
- ❌ Editar evento de otro usuario (sin permisos)
- ✅ Editar evento como admin
- ✅ Editar parte personal del evento
- ❌ Editar parte común sin permisos

**3.3 Eliminar Evento**
- ✅ Eliminar evento propio
- ❌ Eliminar evento de otro usuario (sin permisos)
- ✅ Eliminar evento como admin
- ✅ Eliminar evento base (debe eliminar copias)
- ✅ Verificar eliminación de copias

#### **4. SISTEMA DE TRACKS**
**4.1 Reordenar Tracks**
- ✅ Arrastrar y soltar tracks
- ✅ Mantener orden después de recargar
- ✅ Verificar que eventos se mueven con tracks
- ❌ Reordenar con tracks ocultos

**4.2 Seleccionar Tracks**
- ✅ Seleccionar todos los tracks
- ✅ Seleccionar tracks específicos
- ❌ Deseleccionar todos los tracks
- ❌ Deseleccionar track del usuario actual
- ✅ Mantener selección después de recargar
- ✅ Aplicar filtro correctamente

#### **5. VISTAS Y FILTROS**
**5.1 Vista "Todos"**
- ✅ Mostrar todos los eventos
- ✅ Mostrar todos los tracks
- ✅ Navegación entre días

**5.2 Vista "Personal"**
- ✅ Mostrar solo eventos del usuario
- ✅ Ocultar eventos de otros usuarios
- ✅ Mantener filtro al navegar

**5.3 Vista "Personalizada"**
- ✅ Seleccionar tracks específicos
- ✅ Aplicar filtro correctamente
- ✅ Mantener selección
- ❌ Deseleccionar todos los tracks

#### **6. CASOS EDGE Y ERRORES**
**6.1 Conexión de Red**
- ❌ Crear evento sin conexión
- ❌ Editar evento sin conexión
- ❌ Eliminar evento sin conexión
- ✅ Mostrar mensaje de error apropiado
- ✅ Reintentar cuando se recupere conexión

**6.2 Datos Corruptos**
- ❌ Evento con datos inválidos en Firestore
- ❌ Plan con datos inválidos
- ❌ Participante con datos inválidos
- ✅ Manejar errores gracefully
- ✅ Mostrar mensaje de error claro

**6.3 Límites del Sistema**
- ❌ Crear más de 100 eventos por día
- ❌ Crear evento con descripción muy larga (>1000 caracteres)
- ❌ Crear evento con muchos participantes (>50)
- ✅ Mostrar límites apropiados

**6.4 Concurrencia**
- ✅ Dos usuarios editando el mismo evento
- ✅ Dos usuarios añadiendo participantes simultáneamente
- ✅ Dos usuarios cambiando roles simultáneamente
- ✅ Resolver conflictos correctamente

#### **7. PERFORMANCE**
**7.1 Carga de Datos**
- ✅ Plan con muchos eventos (100+)
- ✅ Plan con muchos participantes (20)
- ✅ Navegación rápida entre días
- ✅ Carga inicial del calendario

**7.2 Interacciones**
- ✅ Scroll suave en calendario
- ✅ Drag & drop fluido
- ✅ Apertura rápida de modales
- ✅ Respuesta rápida a clicks

**Criterios de aceptación:**
- Documentar cada caso de prueba
- Crear tests automatizados para casos críticos
- Documentar casos de fallo esperados
- Crear guía de testing manual
- Establecer métricas de performance

**Archivos a crear:**
- `docs/TESTING_PLAN.md` - Plan detallado de pruebas
- `test/manual_testing_guide.md` - Guía de testing manual
- `test/performance_benchmarks.md` - Benchmarks de performance

---

### T99 - Documentación de API
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Baja  
**Depende de:** T98  
**Descripción:** Documentar APIs, servicios y modelos para facilitar mantenimiento y onboarding.

**Documentación a crear:**
- EventService API
- TrackService API
- PermissionService API
- EventSyncService API
- Modelos de datos (Event, ParticipantTrack, etc.)
- Guía de arquitectura
- Guía de contribución

**Criterios de aceptación:**
- Documentar todos los servicios públicos
- Incluir ejemplos de uso
- Documentar parámetros y retornos
- Crear diagramas de arquitectura
- Guía de contribución clara

**Archivos a crear:**
- `docs/API_DOCUMENTATION.md`
- `docs/ARCHITECTURE.md`
- `docs/CONTRIBUTING.md`
- `docs/SERVICE_EXAMPLES.md`

---
