# 📋 Lista de Tareas - Planazoo

> Consulta las normas y flujo de trabajo en `docs/CONTEXT.md`.

**Siguiente código de tarea: T160**

**📊 Resumen de tareas por grupos:**
- **GRUPO 1:** T68, T69, T70, T72: Fundamentos de Tracks (4 completadas)
- **GRUPO 2:** T71, T73: Filtros y Control (2 completadas)
- **GRUPO 3:** T46, T74, T75, T76: Parte Común + Personal (4 completadas, 0 pendientes)
- **GRUPO 4:** T56-T60, T63, T64: Infraestructura Offline (7 pendientes)
- **GRUPO 5:** T40-T45: Timezones (6 completadas, 0 pendientes) - T81, T82: No existen
- **GRUPO 6:** T77-T79, T83-T90: Funcionalidades Avanzadas (4 completadas, 11 pendientes)
- **Seguridad:** T51-T53: Validación (3 completadas, 0 pendientes)
- **Participantes:** T47, T49-T50: Sistema básico (3 pendientes)
- **Permisos:** T65-T67: Gestión de permisos (1 completada, 2 pendientes)
- **Mejoras Visuales:** T91-T92: Colores y tipografía (2 pendientes)
- **Testing y Mantenimiento:** T96-T99, T152: Refactoring (en progreso), testing, documentación y optimización Firestore (5 pendientes)
- **Mejoras Funcionales:** T153: Sistema multi-moneda (1 completada)
- **UX:** T100: Visualización de Timezones (1 completada)
- **Ayuda y Documentación:** T157: Sistema de Ayuda Contextual (1 pendiente)
- **Multi-idioma:** T158: Completar Sistema Multi-idioma (1 pendiente)
- **Integración:** T131: Sincronización con Calendarios Externos (1 pendiente)
- **Agencias:** T132: Definición Sistema Agencias de Viajes (1 pendiente)
- **Exportación:** T133: Exportación Profesional de Planes PDF/Email (1 pendiente)
- **Importación:** T134: Importar desde Email (1 pendiente)
- **Privacidad:** T135-T136: Gestión de Cookies y App Tracking Transparency (2 pendientes)

**Migración:** T154-T156: Migración a Mac/iOS (3 pendientes)

**Total: 132 tareas documentadas (68 completadas, 64 pendientes)**

## 📋 Reglas del Sistema de Tareas

### **🔢 Identificación y Códigos**
1. **Códigos únicos**: Cada tarea tiene un código único (T1, T2, T3...)
2. **Códigos no reutilizables**: Al eliminar una tarea, su código no se reutiliza para evitar confusiones
3. **Seguimiento de códigos**: La primera fila indica el siguiente código a asignar
4. **⚠️ IMPORTANTE**: El contador total solo se actualiza cuando se CREA una nueva tarea, no cuando se completa o elimina

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

**Ver decisiones completas en:** `docs/arquitectura/ARCHITECTURE_DECISIONS.md`

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
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Baja  
**Depende de:** T70  
**Descripción:** Mejorar indicadores visuales para eventos que abarcan múltiples participantes.

**Indicadores implementados:**
- ✅ Gradiente en evento multi-track (gradiente horizontal con opacidad decreciente)
- ✅ Iconos de participantes mejorados (más prominentes para eventos multi-track)
- ⚠️ Línea conectora entre tracks (cancelada - demasiado compleja con la arquitectura actual)
- ✅ Tooltip con lista de participantes (muestra nombres de todos los participantes al hacer hover)

---

### T90 - Resaltado de Track Activo/Seleccionado
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Baja  
**Depende de:** T69  
**Descripción:** Resaltar visualmente el track del usuario actual o el track seleccionado para facilitar navegación.

**Visual implementado:**
- ✅ Fondo levemente diferente en track activo (opacidad 0.05 para celdas, 0.2 para header)
- ✅ Borde más grueso en track seleccionado (1.5px vs 0.5px)
- ✅ Nombre en negrita más prominente (FontWeight.w900 en header)
- ✅ Animación suave al cambiar selección (AnimatedContainer con 200ms)

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
**Estado:** ✅ Completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Alta  
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

#### **3. Formularios implementados:**
- ✅ `wd_event_dialog.dart` - Validación de descripción obligatoria (3-1000 chars), campos personales con límites
- ✅ `wd_accommodation_dialog.dart` - Validación de nombre obligatorio (2-100 chars), descripción opcional (máx 1000 chars)
- ✅ `pg_plan_participants_page.dart` - Validación de email con regex

**Criterios de aceptación:**
- ✅ Todos los `TextFormField` críticos tienen `validator` apropiado
- ✅ Mensajes de error claros y en español
- ✅ Validación en cliente antes de enviar a Firestore
- ✅ `_formKey.currentState!.validate()` antes de guardar
- ✅ Sanitización aplicada después de validación (integrada con T127)
- ⚠️ Testing manual de cada formulario con datos inválidos (pendiente)

**Archivos modificados:**
- ✅ `lib/widgets/wd_event_dialog.dart` - Validación completa
- ✅ `lib/widgets/wd_accommodation_dialog.dart` - Validación completa
- ✅ `lib/pages/pg_plan_participants_page.dart` - Validación de email
- ✅ `lib/widgets/permission_field.dart` - Añadido soporte para validators

**Relacionado con:** T127 (Sanitización)

---

### T52 - Añadir Checks `mounted` antes de usar Context
**Estado:** ✅ Completada  
**Complejidad:** ⚠️ Baja-Media  
**Prioridad:** 🟠 Media - Prevenir crashes  
**Descripción:** Añadir verificaciones `mounted` antes de usar `context` en callbacks asíncronos para prevenir errores cuando el widget ya está disposed.

**Problema resuelto:** Uso de `context` después de operaciones asíncronas sin verificar si el widget sigue montado → puede causar crashes.

**Patrón implementado:**
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

**Implementación completada:**

1. ✅ **lib/widgets/wd_event_dialog.dart** (3 métodos)
   - `_selectDate()` - check después de `showDatePicker`
   - `_selectStartTime()` - check después de `showTimePicker`
   - `_selectDuration()` - check después de `showDialog`
   
2. ✅ **lib/pages/pg_dashboard_page.dart** (7 métodos)
   - `_generateMiniFrankPlan()` - check después de `await`
   - `_createPlan()` - checks múltiples después de operaciones async
   - `_loadUsers()` - check después de `await`
   - `_pickImage()` - checks después de `await`
   - `_selectStartDate()` - check después de `showDatePicker`
   - `_selectEndDate()` - check después de `showDatePicker`
   - Subida de imágenes - checks después de operaciones async
   
3. ✅ **lib/widgets/wd_accommodation_dialog.dart** (2 métodos)
   - `_selectCheckInDate()` - check después de `showDatePicker`
   - `_selectCheckOutDate()` - check después de `showDatePicker`

**Criterios de aceptación cumplidos:**
- ✅ Añadir `if (!mounted) return;` después de operaciones async
- ✅ Verificar `mounted` antes de cada uso de `context`
- ✅ Verificar `mounted` antes de `setState()`
- ✅ Protección contra crashes al cerrar diálogos rápidamente

**Archivos modificados:**
- ✅ `lib/widgets/wd_event_dialog.dart`
- ✅ `lib/widgets/wd_accommodation_dialog.dart`
- ✅ `lib/pages/pg_dashboard_page.dart`

**Resultado:** Todos los métodos async ahora verifican `mounted` antes de usar `context`, `Navigator`, `ScaffoldMessenger` o `setState`, evitando crashes cuando el widget está disposed.

---

### T53 - Reemplazar print() por LoggerService
**Estado:** ✅ Completada  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Baja - Mejora de debugging  
**Descripción:** Reemplazar todos los `print()` statements por `LoggerService` para mejor control de logs y performance en producción.

**Problema resuelto:** 33 `print()` statements que:
- Se ejecutaban en producción (impacto en performance)
- No tenían control de nivel de log
- Dificultaban debugging al mezclar con logs del sistema

**Patrón implementado:**
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

**Implementación completada:**

#### **Errores (usando LoggerService.error):**
- ✅ `lib/features/calendar/domain/services/image_service.dart` - 5 casos de error
  - Error picking image
  - Error validating image
  - Error uploading plan image
  - Error deleting plan image
  - Error compressing image
- ✅ `lib/features/calendar/domain/services/event_service.dart` - 5 casos de error
  - Error getting event by id
  - Error updating event
  - Error deleting event
  - Error toggling draft status
  - Error deleting events by planId
- ✅ `lib/features/calendar/presentation/providers/database_overview_providers.dart` - 2 casos de error
  - Error getting events for plan
  - Error getting accommodations for plan

**Nota:** Los únicos `print()` que quedan están en `LoggerService` mismo (implementación interna), lo cual es correcto.

**Criterios de aceptación cumplidos:**
- ✅ 0 `print()` statements en código de producción (fuera de LoggerService)
- ✅ Usar `LoggerService.error()` para errores
- ✅ Todos los errores ahora tienen logging estructurado con contexto
- ✅ `LoggerService.debug()` solo imprime en modo debug (kDebugMode)
- ✅ Mejor debugging con contexto y estructura de logs

**Archivos modificados:**
- ✅ `lib/features/calendar/domain/services/image_service.dart` - 5 logs añadidos
- ✅ `lib/features/calendar/domain/services/event_service.dart` - 5 logs añadidos
- ✅ `lib/features/calendar/presentation/providers/database_overview_providers.dart` - 2 logs añadidos

**Resultado:** Todos los errores críticos ahora están logueados usando `LoggerService`, proporcionando mejor debugging y control de logs en producción. Los logs incluyen contexto para facilitar la identificación de problemas.

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
- `docs/especificaciones/FRANKENSTEIN_PLAN_SPEC.md`

---

### T47 - EventDialog: Selector de participantes
**Estado:** ✅ Base completada  
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
**Estado:** ✅ Base completada  
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

## 🎨 MEJORAS VISUALES - Serie de Tareas (T91-T92)

### T91 - Mejorar colores de eventos
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Baja (Aplicar cuando el calendario esté definitivo)  
**Descripción:** Mejorar la paleta de colores de eventos para una mejor experiencia visual y legibilidad.

**Criterios de aceptación:**
- ✅ Revisar y optimizar colores de eventos existentes
- ✅ Crear paleta de colores consistente y accesible
- ✅ Mejorar contraste para mejor legibilidad (WCAG AA cumplido)
- ✅ Aplicar colores diferenciados por tipo de evento
- ✅ Mantener coherencia visual con el diseño general
- ✅ Sistema automático de selección de color de texto basado en luminosidad
- ✅ Documentar nueva paleta de colores

**Mejoras implementadas:**
- ✅ Paleta de colores optimizada con mejor contraste (mínimo 4.5:1)
- ✅ Colores por tipo mejorados: Desplazamiento (#1976D2), Alojamiento (#388E3C), Actividad (#F57C00), Restauración (#D32F2F)
- ✅ Colores de borrador más distinguibles pero mantienen matiz original
- ✅ Selección automática de color de texto (blanco/negro) según luminosidad del fondo
- ✅ Colores personalizados mejorados con mejor contraste
- ✅ Método `getEventTextColor()` con cálculo automático de contraste

**Archivos modificados:**
- ✅ `lib/shared/utils/color_utils.dart` - Paleta de colores mejorada y sistema de contraste automático
- ✅ `docs/design/EVENT_COLOR_PALETTE.md` - Documentación completa de la paleta

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
**Estado:** 🔄 En progreso (Parcialmente completado)  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🔴 Alta  
**Depende de:** T80  
**Descripción:** Dividir `wd_calendar_screen.dart` (4424 líneas) en componentes más pequeños y mantenibles.

**Problema actual:**
- Archivo monolítico de 4424 líneas (reducido a ~4084 líneas)
- Difícil mantenimiento y debugging
- Violación de principios SOLID
- Testing complejo

**Progreso actual:**
- ✅ **CalendarGrid** - Completado (~90 líneas extraídas)
  - Estructura base del grid
  - Columna de horas fija
  - Área de datos con scroll sincronizado
- ✅ **CalendarTracks** - Completado (~250 líneas extraídas)
  - Headers de días
  - Mini headers de participantes
  - Tracks de alojamientos
  - Agrupación de tracks consecutivos
- ⏳ **CalendarEvents** - Pendiente (complejo, requiere análisis más profundo)
- ⏳ **CalendarInteractions** - Pendiente (muy acoplado al estado interno)

**Métricas:**
- Líneas extraídas: ~340 líneas
- Reducción: ~7.7%
- Sin errores de compilación
- Funcionalidad preservada

**Componentes propuestos:**
```
CalendarScreen (orchestrator)
├── CalendarHeader (AppBar + navegación) - ✅ Ya existe (calendar_app_bar.dart)
├── CalendarGrid (estructura base) - ✅ COMPLETADO
├── CalendarTracks (columnas de participantes) - ✅ COMPLETADO
├── CalendarEvents (eventos y overlays) - ⏳ PENDIENTE
├── CalendarInteractions (drag & drop, clicks) - ⏳ PENDIENTE
└── CalendarUtils (helpers y cálculos)
```

**Criterios de aceptación:**
- Dividir en al menos 6 componentes independientes
- Mantener funcionalidad exacta actual
- Mejorar legibilidad y mantenibilidad
- Facilitar testing individual
- Reducir complejidad ciclomática

**Archivos creados:**
- ✅ `lib/widgets/screens/calendar/components/calendar_grid.dart` (~160 líneas)
- ✅ `lib/widgets/screens/calendar/components/calendar_tracks.dart` (~490 líneas)

**Archivos pendientes:**
- ⏳ `lib/widgets/screens/calendar/components/calendar_events.dart`
- ⏳ `lib/widgets/screens/calendar/components/calendar_interactions.dart`

**Archivos modificados:**
- ✅ `lib/widgets/screens/wd_calendar_screen.dart` (refactorizado parcialmente)

**Documentación:**
- ✅ `docs/configuracion/T96_REFACTORING_PLAN.md` - Plan detallado del refactoring

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
- `docs/arquitectura/ARCHITECTURE_DECISIONS.md`
- `docs/CONTRIBUTING.md`
- `docs/SERVICE_EXAMPLES.md`

---

### T100 - Visualización de Timezones en el Calendario
**Estado:** ✅ Completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Depende de:** T40-T45 (Timezones implementadas)  
**Descripción:** Decidir y implementar la mejor forma de visualizar las timezones en el calendario para que los usuarios entiendan en qué timezone está cada participante.

**Solución implementada:**
Se implementó una **combinación de opciones 1, 3 y 4** para maximizar la claridad sin sobrecargar la interfaz:

#### ✅ **Opción 1: Indicador mejorado en el AppBar** - IMPLEMENTADO
- Icono de reloj (⏰) más prominente junto al selector de usuario
- Texto con formato: "Madrid (GMT+1)"
- Ubicación: AppBar, en el `UserPerspectiveSelector`
- Mejora: Icono visible y tamaño de fuente aumentado

#### ✅ **Opción 3: Barra lateral de color en tracks** - IMPLEMENTADO
- Barra lateral de 3px de ancho en el lado izquierdo de cada track
- Colores basados en offset UTC (paleta visual):
  - América del Oeste: Azul oscuro
  - América Central/Este: Azul medio
  - GMT: Verde
  - Europa: Naranja
  - Asia/Oceanía: Rosa/Morado
- Tooltip al hover en headers de tracks con información completa
- Ubicación: Headers mini, celdas de datos, y fila de alojamientos

#### ✅ **Opción 4: Tooltip en eventos** - IMPLEMENTADO
- Tooltip con información de timezone al pasar el mouse sobre eventos
- Para eventos con timezone única: "Salida: Madrid (GMT+1)"
- Para eventos con timezones diferentes: "✈️ Vuelo/Desplazamiento\nSalida: Madrid (GMT+1)\nLlegada: Tokio (GMT+9)"
- Información contextual sin ocupar espacio visual

**Archivos modificados:**
- ✅ `lib/widgets/screens/calendar/user_perspective_selector.dart` - Indicador mejorado en AppBar
- ✅ `lib/widgets/screens/calendar/components/calendar_tracks.dart` - Barra lateral en tracks
- ✅ `lib/widgets/screens/wd_calendar_screen.dart` - Barra lateral en celdas de datos y tooltips en eventos
- ✅ `lib/features/calendar/domain/services/timezone_service.dart` - Métodos `getTimezoneColor()` y `getTimezoneBarColor()`

**Funcionalidades implementadas:**
- ✅ Sistema de colores para timezones basado en offset UTC
- ✅ Barra lateral de color en todos los tracks (headers, celdas, alojamientos)
- ✅ Tooltips informativos en headers de tracks
- ✅ Tooltips informativos en eventos con timezone
- ✅ Indicador mejorado en AppBar con icono de reloj

---

## 📋 NUEVAS FUNCIONALIDADES (T101-T118, T105 completado)

**Nota:** T105 completado - Sistema base de avisos implementado. Pendiente notificaciones push con FCM.

### T105 - Sistema de Avisos del Plan (Base)
**Estado:** ✅ Completado  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Sistema de avisos unidireccionales para el plan (base funcional), no un chat bidireccional.

**Funcionalidades:**
1. ✅ Modelo `PlanAnnouncement` con usuario, mensaje, timestamp, tipo
2. ✅ Publicar avisos que todos los participantes pueden ver
3. ⚠️ Notificaciones push a todos los participantes cuando hay un nuevo aviso (pendiente)
4. ✅ Lista de avisos en orden cronológico
5. ✅ Avisos visibles para todos los participantes

**Concepto:**
- No es un chat (no conversación)
- Sistema de avisos unidireccionales (como WhatsApp a todo el grupo)
- Cada participante puede publicar avisos
- Ver lista de avisos del plan

**Criterios de aceptación:**
- ✅ Modelo PlanAnnouncement con validación y tipos (info, urgent, important)
- ✅ UI para publicar avisos (AnnouncementDialog)
- ⚠️ Notificaciones push a todos los participantes (pendiente FCM)
- ✅ Lista de avisos visible para todos (AnnouncementTimeline)
- ✅ Persistencia en Firestore con reglas de seguridad
- ✅ Sanitización de mensajes
- ✅ Integrado en pantalla de datos del plan

**Archivos creados:**
- `lib/features/calendar/domain/models/plan_announcement.dart`
- `lib/features/calendar/domain/services/announcement_service.dart`
- `lib/features/calendar/presentation/providers/announcement_providers.dart`
- `lib/widgets/dialogs/announcement_dialog.dart`
- `lib/widgets/screens/announcement_timeline.dart`

**Archivos modificados:**
- `firestore.rules` - Reglas de seguridad para announcements
- `lib/widgets/screens/wd_plan_data_screen.dart` - Integración de sección de avisos

**Nota:** La funcionalidad de notificaciones push está pendiente para una tarea futura específica de FCM.

---

### T101 - Sistema de Presupuesto del Plan
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja  
**Descripción:** Sistema de presupuesto para registrar costes en eventos y alojamientos y visualizar análisis agrupados.

**Criterios de aceptación:**
- ✅ Modelos Event y Accommodation incluyen campo `cost` (opcional)
- ✅ Servicio de cálculo de presupuesto (`BudgetService`)
- ✅ UI para introducir coste en eventos y alojamientos
- ✅ Integración de presupuesto en estadísticas del plan
- ✅ Desglose por tipo de evento y alojamientos
- ✅ Persistencia en Firestore
- ⚠️ Desglose por participante (implementado pero no visible en UI)
- ⚠️ Gráficos avanzados (mejora futura)

**Archivos creados:**
- `lib/features/budget/domain/models/budget_summary.dart`
- `lib/features/budget/domain/services/budget_service.dart`

**Archivos modificados:**
- `lib/features/calendar/domain/models/event.dart`
- `lib/features/calendar/domain/models/accommodation.dart`
- `lib/features/stats/domain/models/plan_stats.dart`
- `lib/features/stats/domain/services/plan_stats_service.dart`
- `lib/features/stats/presentation/pages/plan_stats_page.dart`
- `lib/widgets/wd_event_dialog.dart`
- `lib/widgets/wd_accommodation_dialog.dart`

---

### T102 - Sistema de Control de Pagos y Bote Común
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja  
**Descripción:** Implementar un sistema de control de pagos donde cada participante registra lo que ha pagado en cada evento, con cálculo automático de balances y saldos.

**Funcionalidades:**
1. ✅ Modelo `PersonalPayment` con campos: `amount`, `description`, `date`
2. ✅ Cada participante puede registrar pagos en la parte personal de eventos
3. ✅ Página de resumen de pagos con:
   - Total pagado por participante
   - Total gastado en el plan
   - Coste por persona (total gastado / número participantes)
   - Balance de cada participante (lo que debe pagar o cobrar)
   - Indicador visual de estado (pendiente/parcial/saldado)

**Criterios de aceptación:**
- ✅ Modelo PersonalPayment con validación
- ✅ UI para registrar pagos en eventos
- ✅ Cálculo automático de balances
- ✅ Página de resumen con gráficos
- ✅ Persistencia en Firestore
- ⚠️ Testing básico (pendiente)
- ⚠️ Sistema de bote común (opcional, pendiente)

---

### T152 - Revisión y Optimización de Índices de Firestore
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Revisar, validar y optimizar los índices de Firestore para mantener solo los necesarios, eliminar redundancias y asegurar coherencia con el código actual.

**Objetivos:**
1. Revisar todos los índices definidos en `firestore.indexes.json`
2. Validar que cada índice corresponde a una query real en el código
3. Eliminar índices no utilizados o redundantes
4. Añadir índices faltantes si se detectan queries sin soporte
5. Revisar coherencia entre reglas de seguridad y colecciones utilizadas
6. Eliminar campos y colecciones obsoletas o no utilizadas

**Pasos a seguir:**

#### 1. Auditoría de Índices
- [x] Listar todos los índices actuales en `firestore.indexes.json`
- [x] Buscar en el código todas las queries a Firestore que usan `where()` y `orderBy()`
- [x] Mapear cada query con su índice correspondiente
- [x] Identificar índices sin queries asociadas (redundantes)
- [x] Identificar queries sin índices (necesitan índices nuevos)

#### 2. Revisión de Colecciones
- [x] Revisar todas las colecciones referenciadas en el código
- [x] Comparar con las colecciones definidas en Firestore Rules
- [x] Identificar colecciones obsoletas o no utilizadas
- [x] Verificar que todas las colecciones activas tengan reglas de seguridad

#### 3. Revisión de Campos
- [x] Revisar campos de modelos vs campos en Firestore
- [x] Identificar campos obsoletos en modelos que ya no se usan
- [x] Verificar que campos requeridos en queries tienen índices

#### 4. Optimización
- [x] Eliminar índices redundantes
- [x] Añadir índices faltantes si son necesarios
- [x] Reorganizar índices por colección para mejor legibilidad
- [x] Documentar la razón de cada índice (qué query lo utiliza)

#### 5. Validación
- [ ] Ejecutar queries del código para verificar que todos los índices funcionan
- [ ] Verificar que no hay errores de "missing index" en consola
- [ ] Validar que las reglas de seguridad permiten las operaciones necesarias

**Criterios de aceptación:**
- ✅ Todos los índices tienen al menos una query que los utiliza
- ✅ Todas las queries del código tienen su índice correspondiente
- ✅ No hay índices redundantes o duplicados
- ✅ Documentación de cada índice con su propósito
- ✅ Colecciones obsoletas eliminadas o marcadas para migración
- ✅ Campos obsoletos identificados y documentados

**Archivos modificados:**
- ✅ `firestore.indexes.json` - Añadidos 25 índices (de 7 a 25 totales)
- ✅ `docs/configuracion/FIRESTORE_INDEXES_AUDIT.md` - Documentación completa creada

**Resultados de la auditoría:**
- ✅ **7 índices existentes** revisados y validados
- ✅ **18 índices nuevos** añadidos para cubrir todas las queries
- ✅ **Discrepancia encontrada:** Nombres de colecciones entre Rules y código (`plan_participations` vs `planParticipations`, `event_participants` vs `eventParticipants`)
- ✅ **Documentación completa** de cada índice con su propósito y queries asociadas
- ✅ **Proceso de revisión periódica** documentado para futuras revisiones

**Índices añadidos por colección:**
- `plans`: 2 nuevos índices
- `events`: 3 nuevos índices
- `plan_participations`: 5 nuevos índices
- `planInvitations`: 2 nuevos índices
- `event_participants`: 3 nuevos índices
- `participant_groups`: 1 nuevo índice
- `users`: 2 nuevos índices

**⚠️ Pendiente:** Validación práctica ejecutando las queries (se realizará cuando se desplieguen los índices a Firestore).

---

### T153 - Sistema Multi-moneda para Planes
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar soporte para múltiples monedas en planes, con formateo automático y calculadora de tipos de cambio.

**Objetivo:**
Permitir que cada plan tenga su moneda base (EUR, USD, GBP, JPY, etc.) y facilitar el cálculo de tipos de cambio para usuarios que trabajan con diferentes monedas.

**Fase 1: Soporte Básico Multi-moneda**

#### 1.1 - Modelo de Moneda
- [x] Crear modelo `Currency` con:
  - Código ISO (EUR, USD, GBP, JPY, etc.)
  - Símbolo (€, $, £, ¥)
  - Nombre completo
  - Decimales (2 para EUR/USD, 0 para JPY)
  - Locale para formateo
- [x] Lista de monedas soportadas (EUR, USD, GBP, JPY como mínimo)
- [x] Método para obtener moneda por código ISO

#### 1.2 - Integración en Plan
- [x] Añadir campo `currency` al modelo `Plan` (String, código ISO)
- [x] Default: 'EUR' para planes existentes y nuevos
- [x] Actualizar `fromFirestore` y `toFirestore`
- [x] Migración de datos existentes (asignar 'EUR' a planes sin moneda)

#### 1.3 - Servicio de Formateo
- [x] Crear `CurrencyFormatterService`:
  - `formatAmount(amount, currencyCode)` - Formatear con símbolo
  - `formatAmountWithoutSymbol(amount, currencyCode)` - Solo número
  - `getSymbol(currencyCode)` - Obtener símbolo
- [x] Usar `NumberFormat.currency` con locale y decimales correctos

#### 1.4 - Actualizar UI
- [x] Reemplazar todos los `'€'` hardcodeados por formateador
- [x] Actualizar `EventDialog` (campo coste con conversión automática)
- [x] Actualizar `AccommodationDialog` (campo coste con conversión automática)
- [x] Actualizar `PaymentDialog` (campo monto con conversión automática)
- [x] Actualizar `PlanStatsPage` (presupuesto)
- [x] Actualizar `PaymentSummaryPage` (balances y pagos)

#### 1.5 - Selector de Moneda
- [x] Añadir selector de moneda al crear plan
- [x] Dropdown con monedas soportadas
- [x] Default EUR

**Fase 2: Calculadora de Tipos de Cambio**

#### 2.1 - Estructura de Datos en Firestore
- [x] Crear colección `exchange_rates` con estructura:
  ```json
  {
    "baseCurrency": "EUR",
    "rates": {
      "USD": 1.08,
      "GBP": 0.85,
      "JPY": 160.0
    },
    "updatedAt": timestamp
  }
  ```
- [x] Documentación para inicializar tipos de cambio (script en `scripts/init_exchange_rates.md`)
- [x] Botón temporal para inicializar desde dashboard (modo debug)
- [x] Nota: Expansión a más monedas en tarea futura

#### 2.2 - Servicio de Tipos de Cambio
- [x] Crear `ExchangeRateService`:
  - Leer tipos de cambio desde Firestore
  - `getExchangeRate(fromCurrency, toCurrency)` - Obtener tasa (calcular conversión si necesario)
  - `convertAmount(amount, fromCurrency, toCurrency)` - Convertir monto
  - Manejo de casos: misma moneda, conversión directa, conversión inversa
- [x] Cache local en memoria (válido hasta cierre de app)
- [x] Manejo de errores si tipo de cambio no disponible

#### 2.3 - UI Calculadora Automática
- [x] Calculadora automática integrada en campos de monto:
  - Selector "Moneda del coste/pago" (default: moneda del plan)
  - Campo de monto con icono según moneda
  - Conversión automática cuando moneda local ≠ moneda del plan
  - Resultado: monto convertido + tipo de cambio aplicado
  - Disclaimer visible en conversiones
- [x] Integrado en:
  - EventDialog (campo coste)
  - AccommodationDialog (campo coste)
  - PaymentDialog (campo monto)
- [x] Disclaimer mostrado en todos los lugares donde se muestran conversiones

#### 2.4 - Información de Tipos de Cambio (Futuro)
- [ ] ⚠️ Actualización automática diaria (tarea futura - Firebase Function/cron)
- [ ] ⚠️ UI administrativa para actualizar tipos de cambio manualmente (tarea futura)
- [ ] ⚠️ Indicador "Última actualización: [fecha/hora]" (cuando se implemente actualización)

**Criterios de aceptación:**
- [x] Plan puede tener moneda configurada (EUR, USD, GBP, JPY como mínimo)
- [x] Todos los montos se formatean correctamente según la moneda del plan
- [x] UI muestra símbolo y formato correcto de moneda
- [x] Calculadora automática funciona con tipos de cambio desde Firestore
- [x] Cache de tipos de cambio funciona correctamente
- [x] Migración de datos existentes no rompe funcionalidad (default EUR)
- [x] Disclaimer visible en todas las conversiones

**Notas de Implementación:**
- Monedas iniciales: EUR, USD, GBP, JPY (expandir a más monedas en tarea futura)
- Tipos de cambio almacenados en Firestore (estructura: baseCurrency + rates)
- Por ahora: Lista estática, actualización manual en Firestore
- Futuro: Actualización automática diaria mediante Firebase Function o proceso backend
- Disclaimer obligatorio: "Los tipos de cambio son orientativos. El valor real será el aplicado por tu banco o tarjeta de crédito al momento del pago."

**Archivos a crear/modificar:**
- `lib/shared/models/currency.dart` - NUEVO
- `lib/shared/services/currency_formatter_service.dart` - NUEVO
- `lib/shared/services/exchange_rate_service.dart` - NUEVO (Fase 2)
- `lib/widgets/currency/currency_calculator_widget.dart` - NUEVO (Fase 2)
- `lib/features/calendar/domain/models/plan.dart` - MODIFICAR
- `lib/widgets/wd_event_dialog.dart` - MODIFICAR
- `lib/widgets/wd_accommodation_dialog.dart` - MODIFICAR
- `lib/widgets/dialogs/payment_dialog.dart` - MODIFICAR
- `lib/features/stats/presentation/pages/plan_stats_page.dart` - MODIFICAR
- `lib/features/payments/presentation/pages/payment_summary_page.dart` - MODIFICAR

**Relacionado con:** T101 (Presupuesto), T102 (Pagos)

**Documentación:** Ver `docs/tareas/CURRENCY_SYSTEM_PROPOSAL.md` para detalles técnicos

---

### T117 - Sistema de Registro de Participantes por Evento
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Permitir que los participantes se apunten a eventos individuales dentro de un plan, no solo al plan completo.

**Concepto:**
- Los usuarios se apuntan al PLAN (participan en el plan)
- Además, los usuarios pueden APUNTARSE A EVENTOS ESPECÍFICOS dentro del plan
- Ejemplo: Plan "Partidas de Padel 2024" → Evento "Partido domingo 15" → Participantes se apuntan a ese evento específico

**Funcionalidades:**

#### ✅ Base completada:
1. ✅ Sistema de registro de participantes por evento
   - Modelo `EventParticipant` con estado (registered, cancelled)
   - `EventParticipantService` con métodos CRUD
   - Providers Riverpod para Stream y contadores
2. ✅ Botón "Apuntarse al evento" en EventDialog
   - Widget `EventParticipantRegistrationWidget` integrado
   - Botón "Apuntarse" / "Cancelar participación"
   - Validación: solo participantes del plan pueden apuntarse
3. ✅ Lista de participantes confirmados por evento
   - Lista con avatares y nombres
   - Carga asíncrona de nombres de usuario
4. ✅ Indicadores visuales de eventos con espacios disponibles
   - Indicador "Evento completo (X/Y participantes)"
   - Contador visible de participantes
5. ✅ Gestión de límites de participantes por evento
   - Campo `maxParticipants` en modelo Event
   - Campo opcional en EventDialog con validación (1-1000)
   - Validación automática cuando se alcanza el límite

**Criterios de aceptación:**
- ✅ Registro de participantes por evento individual
- ✅ Visualización de participantes confirmados
- ✅ Gestión de límites de participantes
- ⚠️ Integración con sistema de notificaciones (pendiente - mejora futura)
- ⚠️ Testing con diferentes escenarios (pendiente)

**Pendiente (mejoras futuras):**
- ⚠️ Notificaciones cuando alguien se apunta o cuando el evento se completa
- ⚠️ Testing exhaustivo con diferentes escenarios

---

### T119 - Sistema de Eventos Recurrentes
**Estado:** Pendiente  
**Complejidad:** 🔴 Alta  
**Prioridad:** 🟡 Media  
**Descripción:** Crear eventos recurrentes automáticamente (ej: todos los domingos durante un año para un plan de padel).

**Concepto:**
- Relacionado con T117 - Los usuarios se apuntan al plan, no al evento
- Un plan puede tener muchos eventos recurrentes que se crean automáticamente
- Cada evento recurrente permite que la gente se apunte individualmente (T117)

**Casos de uso:**
- Partidas de padel semanales: crear plan anual y automáticamente generar evento para cada domingo
- Eventos regulares dentro de un plan maestro
- Actividades programadas repetitivas

**Funcionalidades:**
1. Plantilla de eventos recurrentes (semanal, quincenal, mensual)
2. Crear múltiples eventos automáticamente según plantilla
3. Gestión de cancelaciones de ocurrencias específicas
4. Editar ocurrencias individuales sin afectar la serie completa
5. Vista de calendario con eventos recurrentes

**Preguntas a resolver:**
1. ¿Formato de plan? (plan anual con eventos recurrentes vs. plan mensual)
2. ¿Gestión de cancelaciones? (cancelar ocurrencias específicas de la serie)
3. ¿Modificaciones? (editar ocurrencias específicas sin romper la serie)
4. ¿Integración con T117? (participantes se apuntan a cada ocurrencia)

**Nota:** Integrado con T117 - Los usuarios se apuntan al plan, no a cada evento individual de la serie.

---

### T118 - Sistema de Copiar y Pegar Planes Completos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja  
**Descripción:** Permite duplicar un plan completo incluyendo todos sus eventos, participantes y configuraciones.

**Casos de uso:**
- Reutilizar planes base (ej: estructura de viaje que se repite)
- Plantillas de planes populares
- Modificar fechas/participantes de un plan existente

**Funcionalidades:**
1. Botón "Duplicar plan" en página de detalles
2. Copiar todo el contenido: eventos, alojamientos, participantes, configuraciones
3. Opción de modificar nombre, fechas y participantes durante la duplicación
4. Generar nuevo plan con nuevo ID
5. Mantener estructura y eventos del plan original

**Criterios de aceptación:**
- Duplicación completa de planes
- Opción de modificar datos durante la duplicación
- Nuevo plan con nuevo ID
- Testing con planes complejos
- Persistencia correcta

---

### T120 - Sistema de Invitaciones y Confirmación de Eventos
**Estado:** Pendiente - Base funcional implementada  
**Complejidad:** 🔴 Alta  
**Prioridad:** 🔴 Alta  
**Descripción:** Sistema completo de invitaciones a planes y confirmación de asistencia a eventos específicos.

**Flujo de trabajo:**
1. **Organizador crea plan** y envía invitaciones a participantes
2. **Participantes reciben invitación** y deben responder (aceptar/rechazar)
3. **Al aceptar, se apuntan al plan**
4. **Organizador crea eventos** dentro del plan
5. **Algunos eventos requieren confirmación explícita** del participante para asistir

**Funcionalidades por fase:**

#### **Fase 1: Invitaciones al Plan - ✅ Base completada**
1. ✅ Campo `status` en PlanParticipation (pending, accepted, rejected, expired)
2. ✅ Métodos `acceptInvitation` y `rejectInvitation` en PlanParticipationService
3. ✅ UI diálogo InvitationResponseDialog para aceptar/rechazar invitaciones
4. ✅ Integración en CalendarScreen para mostrar diálogo automáticamente cuando hay invitación pendiente
5. ✅ Firestore rules para validar campo status
6. ✅ Parámetro `autoAccept` en `createParticipation` para compatibilidad hacia atrás
7. ❌ Notificaciones push de invitaciones (pendiente FCM)
8. ❌ Generación de links de invitación con token
9. ❌ Email HTML con botones "Aceptar" / "Rechazar"
10. ❌ Lista de participantes invitados vs confirmados (UI)

#### **Fase 2: Confirmación de Eventos - ✅ Base completada**
1. ✅ Organizador marca eventos como "requiere confirmación"
   - Campo `requiresConfirmation` en Event
   - Checkbox en EventDialog para organizador
   - Creación automática de confirmaciones pendientes al marcar
2. ✅ Botones confirmar/no asistir en cada evento
   - UI completa con botones "Confirmar asistencia" / "No asistir"
   - Estados visuales: confirmado, pendiente, declinado
3. ✅ Indicadores visuales de quién ha confirmado
   - Estadísticas: Confirmados, Pendientes, Declinados
   - Listas separadas por estado con colores distintivos
   - Indicadores visuales en cada participante
4. ✅ Gestión de límites integrada con confirmaciones
   - Límite basado en confirmados (no pendientes)
   - Indicador "Evento completo" cuando se alcanza el límite
5. ⚠️ Notificaciones para confirmar asistencia (pendiente - requiere FCM)

**Integración:**
- Con T117 (Registro de Participantes por Evento) - ✅ Completada (base)
- Con T105 (Sistema de Avisos y Notificaciones) - ✅ Base implementada
- Con T104 (Sistema de Invitaciones a Planes - revisar si es redundante)

**Criterios de aceptación:**
- ⚠️ Flujo completo de invitaciones al plan (Base implementada, faltan notificaciones)
- ✅ Sistema de confirmación de eventos (Base completada)
- ⚠️ Notificaciones push en cada paso (pendiente - requiere FCM)
- ✅ UI clara para organizador y participantes (Completada)
- ✅ Persistencia en Firestore
- ⚠️ Testing básico del flujo (pendiente testing completo)

---

### T121 - Revisión y Enriquecimiento de Formularios de Eventos y Alojamientos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🟡 Media  
**Descripción:** Analizar y enriquecer los formularios de EventDialog y AccommodationDialog para que puedan gestionar la mayoría de la información relevante de diferentes tipos de eventos y alojamientos.

**Motivación:**
- Los formularios actuales son básicos
- Necesitan gestionar información detallada de reservas, confirmaciones, etc.
- Existen muchos ejemplos en la web que podemos utilizar como referencia
- El usuario tiene ejemplos propios que compartirá

**Objetivos:**
1. Analizar ejemplos existentes (web y ejemplos del usuario)
2. Identificar campos comunes a todos los eventos (título, fecha, participantes, timezone, ubicación)
3. Identificar campos específicos por tipo de evento:
   - **Vuelos**: Aeropuerto salida/llegada, código de vuelo, terminal, número de asiento, aerolínea, clase
   - **Hoteles**: Check-in/check-out, habitación, número de reserva
   - **Restaurantes**: Mesa, confirmación, código de reserva
   - **Actividades**: Punto de encuentro, guía, material necesario
   - **Transporte**: Estación salida/llegada, número de tren/autobús, vagón
   - **Eventos sociales**: Localización exacta, punto de encuentro
4. Diseñar estructura de campos genéricos y específicos
5. Implementar formulario adaptable según tipo de evento
6. Aplicar mismo concepto a alojamientos

**Criterios de aceptación:**
- Documento de análisis con ejemplos recopilados
- Lista de campos comunes identificados
- Lista de campos específicos por tipo de evento
- Diseño de estructura de datos flexible
- Formulario adaptable según tipo de evento
- Integración con modelo actual de Event
- Testing con diferentes tipos de eventos
- Documentación actualizada

**Archivos a modificar:**
- `lib/widgets/wd_event_dialog.dart`
- `lib/widgets/wd_accommodation_dialog.dart`
- `lib/features/calendar/domain/models/event.dart`
- `lib/features/calendar/domain/models/accommodation.dart`

**Notas:**
- Revisar T51 (Validación de Formularios) para integrar validaciones
- Considerar campos opcionales vs obligatorios según tipo
- Mantener retrocompatibilidad con eventos existentes
- Propuesta de campos personalizados para casos no cubiertos

---

### T122 - Guardar Plan como Plantilla
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja (Para versiones futuras)  
**Descripción:** Sistema para guardar planes completos como plantillas que puedan ser reutilizadas por el mismo usuario o compartidas con otros usuarios en una plataforma de plantillas.

**Motivación:**
- Permite reutilizar planes exitosos para eventos similares
- Crea una biblioteca de "mejores prácticas" de planificación
- Genera valor comunitario si las plantillas son compartidas

**Funcionalidades:**
1. **Guardar como plantilla local:** Guardar un plan completo como plantilla personal
2. **Editar plantilla:** Modificar plantillas guardadas
3. **Usar plantilla:** Crear nuevo plan basado en plantilla
4. **Compartir plantilla:** Opcional - compartir con comunidad (futuro)
5. **Búsqueda de plantillas:** Por categoría, duración, número de participantes

**Categorías de plantillas:**
- Vacaciones familiares
- Viajes de negocios
- Bodas
- Eventos corporativos
- Escapadas de fin de semana
- Aventuras/reto
- Cultural/Éducativo
- Ocio/Entretenimiento

**Campos de plantilla:**
- **Categoría** (dropdown)
- **Nombre plantilla** (texto)
- **Descripción** (texto)
- **Duración típica** (número días)
- **Número participantes típico** (número)
- **Destino típico** (texto)
- **Precio estimado rango** (currency)
- **Nivel complejidad** (dropdown): "Simple", "Moderado", "Complejo"
- **Tags/Etiquetas** (multi-select)
- **Imagen representativa**
- **Plantilla incluye** (checklist): "Vuelos", "Hoteles", "Restaurantes", "Actividades", etc.

**Flujo:**
1. Usuario marca plan como "Plantilla"
2. Sistema pregunta: "¿Qué quieres guardar?"
   - Todo (eventos, alojamientos, participantes)
   - Solo estructura de eventos
   - Solo configuración (fechas flexibles)
3. Permitir editar plantilla antes de guardar
4. Opción: "Hacer pública" (futuro)

**Criterios de aceptación:**
- Guardar plan completo como plantilla
- Editar plantilla guardada
- Crear nuevo plan desde plantilla
- Búsqueda y filtrado de plantillas
- Sistema de categorías
- Persistencia en Firestore
- Testing con varios tipos de plantillas

**Archivos a crear:**
- `lib/features/templates/domain/models/plan_template.dart`
- `lib/features/templates/domain/services/template_service.dart`
- `lib/features/templates/presentation/providers/template_providers.dart`
- `lib/features/templates/presentation/widgets/template_card.dart`
- `lib/features/templates/presentation/widgets/template_list.dart`
- `lib/features/templates/presentation/pages/template_page.dart`

**Archivos a modificar:**
- `lib/pages/pg_dashboard_page.dart` - Añadir opción "Guardar como plantilla"
- `_CreatePlanModal` - Añadir opción "Usar plantilla"
- `lib/features/calendar/domain/models/plan.dart` - Añadir `isTemplate`, `templateId`, etc.

**Notas:**
- Sistema actual prioriza funcionalidad básica
- Plantillas es mejora para versiones futuras
- Antes de implementar: definir política de plantillas públicas vs privadas
- Considerar marketplace de plantillas como monetización futura

---

### T123 - Sistema de Grupos de Participantes
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Sistema para crear grupos reutilizables de participantes (Familia, Amigos, Compañeros) que puedan ser invitados colectivamente a planes.

**Motivación:**
- Facilita invitar a múltiples personas comunes de una vez
- Ahorra tiempo en creación repetida de planes
- Mejora la experiencia de usuario en gestión de participantes

**Funcionalidades:**
1. **Crear grupos de contactos:** Familia, Amigos, Compañeros trabajo, etc.
2. **Gestionar miembros del grupo:** Añadir/eliminar participantes
3. **Invitar grupo completo:** Invitar todo un grupo de una vez a un plan
4. **Reutilizar grupos:** Grupos guardados disponibles para todos los planes
5. **Importar desde contactos:** Sugerir contactos frecuentes
6. **Auto-sugerir:** Sugerir grupos según historial de planes anteriores

**Modelo de datos:**
```dart
class ContactGroup {
  String id;
  String userId; // Propietario del grupo
  String name; // "Familia Ramos", "Amigos Universidad"
  String? description;
  String? icon; // emoji o icono
  String? color; // Color identificador
  List<String> memberUserIds; // IDs de usuarios en el grupo
  List<String> memberEmails; // Emails para no usuarios
  DateTime createdAt;
  DateTime updatedAt;
}
```

**Criterios de aceptación:**
- Crear, editar y eliminar grupos
- Añadir/eliminar miembros de grupos
- Invitar grupo completo a un plan
- Ver grupos guardados del usuario
- Autocompletar/invitar contactos frecuentes
- Persistencia en Firestore
- Testing con varios grupos y planes

**Archivos a crear:**
- `lib/features/groups/domain/models/contact_group.dart`
- `lib/features/groups/domain/services/contact_group_service.dart`
- `lib/features/groups/presentation/providers/contact_group_providers.dart`
- `lib/features/groups/presentation/widgets/group_card.dart`
- `lib/features/groups/presentation/widgets/group_list.dart`
- `lib/features/groups/presentation/pages/group_management_page.dart`

**Archivos a modificar:**
- `_CreatePlanModal` en `lib/pages/pg_dashboard_page.dart` - Añadir opción "Invitar grupo"
- Sistema de invitaciones (T104) - Soporte para invitar grupos
- UI de participantes - Mostrar grupos disponibles

**Notas:**
- Revisar modelo User actual para asegurar identificación única (email vs username)
- Considerar privacidad: ¿grupos visibles solo para el propietario?
- Integrar con sistema de notificaciones (T105)

---

### T107 - Actualización Dinámica de Duración del Plan
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Sistema para actualizar automáticamente la duración del plan cuando se añaden eventos que se extienden fuera del rango original.

**Funcionalidades:**
1. ✅ Detectar cuando un evento nuevo sale fuera del rango del plan
2. ✅ Ofertar expandir el plan automáticamente
3. ✅ Actualizar fecha inicio/fin del plan dinámicamente
4. ✅ Recalcular `columnCount` del calendario automáticamente
5. ⚠️ Notificar a todos los participantes del cambio (pendiente - requiere T105)
6. ⚠️ Mantener histórico de cambios de duración (pendiente - mejora futura)

**Criterios de aceptación:**
- ✅ Detectar eventos fuera de rango
- ✅ Modal de confirmación para expandir plan
- ✅ Actualización automática de fechas
- ✅ Recalcular calendario automáticamente
- ⚠️ Notificar a participantes (pendiente - requiere T105)
- ✅ Testing con eventos multi-día (funciona en pruebas básicas)

**Archivos creados/modificados:**
- ✅ `lib/shared/utils/plan_range_utils.dart` - Utilidades para detectar eventos fuera del rango
- ✅ `lib/widgets/dialogs/expand_plan_dialog.dart` - Diálogo de confirmación de expansión
- ✅ `lib/features/calendar/domain/services/plan_service.dart` - Método `expandPlan()`
- ✅ `lib/widgets/wd_event_dialog.dart` - Integración de detección y diálogo
- ✅ `lib/features/calendar/presentation/providers/calendar_providers.dart` - Provider para stream de plan

**Mejoras futuras:**
- Notificaciones automáticas a participantes cuando el plan se expande (requiere T105)
- Historial de cambios de duración del plan
- Opción para contraer el plan si ya no hay eventos en las fechas extremas

**Relacionado con:** T109 (Estados del plan), T105 (Notificaciones)

---

### T109 - Estados del Plan
**Estado:** ✅ Completado  
**Complejidad:** ⚠️ Media-Alta  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar sistema completo de estados del plan (Borrador, Planificando, Confirmado, En Curso, Finalizado, Cancelado) con transiciones controladas y permisos por estado.

**Estados disponibles:**
1. **Borrador:** Plan en creación, solo visible para creador
2. **Planificando:** Añadiendo contenido, visible para participantes
3. **Confirmado:** Plan listo, esperando inicio (bloqueos parciales)
4. **En Curso:** Plan activo, ejecutándose (solo cambios urgentes)
5. **Finalizado:** Plan completado (solo lectura)
6. **Cancelado:** Plan cancelado (reembolsos aplican)

**Funcionalidades por estado:**
- ✅ Transiciones controladas entre estados
- ✅ Validaciones antes de cambiar estado
- ✅ Permisos diferentes según estado con indicadores visuales
- ✅ Badges visuales en UI
- ⚠️ Notificaciones al cambiar estado (T105 pendiente)
- ✅ Estados bloquean/desbloquean funcionalidades (indicadores visuales implementados)

**Criterios de aceptación:**
- ✅ Campo `state` en modelo Plan
- ✅ Validaciones de transiciones
- ✅ Permisos por estado implementados con servicio y UI
- ✅ UI con badges de estado
- ⚠️ Notificaciones de cambio de estado (T105)
- ⚠️ Reembolsos al cancelar (T102)

**Archivos creados:**
- ✅ `lib/features/calendar/domain/services/plan_state_service.dart` - Servicio de gestión de transiciones
- ✅ `lib/features/calendar/presentation/widgets/plan_state_badge.dart` - Widget badge de estado
- ✅ `lib/features/calendar/presentation/widgets/state_transition_dialog.dart` - Diálogo de confirmación
- ✅ `lib/features/calendar/domain/services/plan_state_permissions.dart` - Servicio de permisos

**Implementado:**
- ✅ Servicio completo de transiciones con validaciones
- ✅ Transición automática Borrador → Planificando al guardar plan
- ✅ Transiciones automáticas basadas en fechas (Confirmado → En Curso, En Curso → Finalizado)
- ✅ Badges en dashboard, tarjetas de plan, y pantalla de datos
- ✅ Controles manuales para cambiar estados (solo organizador)
- ✅ Diálogos de confirmación para transiciones críticas
- ✅ Indicadores visuales de bloqueos según estado
- ✅ Servicio de permisos con mensajes explicativos

**Implementación completada:**
- ✅ Servicio completo de transiciones con validaciones
- ✅ Transición automática Borrador → Planificando al guardar plan
- ✅ Transiciones automáticas basadas en fechas (Confirmado → En Curso, En Curso → Finalizado)
- ✅ Badges en dashboard, tarjetas de plan, y pantalla de datos
- ✅ Controles manuales para cambiar estados (solo organizador)
- ✅ Diálogos de confirmación para transiciones críticas
- ✅ Indicadores visuales de bloqueos según estado
- ✅ Servicio de permisos con mensajes explicativos
- ✅ **Bloqueos funcionales implementados:**
  - ✅ Bloqueos en CalendarScreen (doble click, drag & drop bloqueados según estado)
  - ✅ Bloqueos en EventDialog (botones crear/editar/eliminar deshabilitados según estado)
  - ✅ Bloqueos en AccommodationDialog (botones crear/editar/eliminar deshabilitados según estado)
  - ✅ Bloqueos en gestión de participantes (añadir/remover según estado)
  - ✅ Mensajes informativos de bloqueo mostrados al usuario

**Mejoras futuras (no críticas):**
- ⚠️ Notificaciones automáticas de cambio de estado (T105)
- ⚠️ Reembolsos al cancelar (T102)

**Relacionado con:** T107, T105, T113, T102

---

### T110 - Sistema de Alarmas en el Plan
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Sistema de notificaciones automáticas antes de eventos (push, email, SMS) con configuración por evento y por usuario.

**Funcionalidades:**
1. Configurar alarmas al crear/editar evento
2. Recordatorios configurables (24h, 2h, 30min antes)
3. Notificaciones push automáticas
4. Notificaciones email (opcional)
5. Notificaciones SMS (opcional, solo críticas)
6. Preferencias de usuario para notificaciones
7. Silenciar notificaciones temporalmente

**Criterios de aceptación:**
- Configurar alarmas por evento
- Múltiples alarmas por evento
- Notificaciones push funcionando
- Preferencias de usuario
- Silenciar notificaciones
- Testing con varios eventos y alarmas

**Archivos a crear:**
- `lib/features/alarms/domain/models/alarm_config.dart`
- `lib/features/alarms/domain/services/alarm_service.dart`
- `lib/features/alarms/presentation/providers/alarm_providers.dart`

**Relacionado con:** T105 (Notificaciones), T104 (Invitaciones)

---

### T112 - Indicador de Días Restantes del Plan
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Media  
**Descripción:** Contador que muestra cuántos días faltan para el inicio del plan (mientras está en estado "Confirmado").

**Funcionalidades:**
1. Contador "Quedan X días" en UI del plan
2. Actualización diaria automática
3. Días pasados después de inicio (opcional)
4. Badge visual "Inicia pronto" cuando <7 días
5. Notificación cuando quedan 1 día

**Criterios de aceptación:**
- Cálculo correcto de días restantes
- Actualización automática
- Badge visual en UI
- Notificación en 1 día
- UI clara y visible

**Archivos a modificar:**
- `lib/widgets/screens/wd_plan_screen.dart`
- `lib/widgets/screens/wd_calendar_screen.dart`

**Relacionado con:** T109 (Estados del plan), T105 (Notificaciones)

---

### T113 - Estadísticas del Plan
**Estado:** ✅ Base completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Dashboard de estadísticas del plan: resumen de eventos, participantes, presupuesto, distribución temporal, etc.

**Funcionalidades:**
1. ✅ Resumen de eventos por tipo
2. ✅ Distribución temporal de actividades
3. ✅ Resumen de participantes
4. ⚠️ Comparativa presupuesto estimado vs real (pendiente - requiere T101)
5. ⚠️ Análisis de presupuesto por tipo (pendiente - requiere T101)
6. ⚠️ Exportar estadísticas (PDF, Excel) (pendiente - mejora futura)

**Criterios de aceptación:**
- ✅ Vista de estadísticas completa
- ✅ Gráficos de distribución (barras horizontales y porcentajes)
- ⚠️ Comparación presupuesto (pendiente - requiere T101)
- ⚠️ Exportar a PDF/Excel (pendiente - mejora futura)
- ✅ UI responsive

**Archivos creados:**
- ✅ `lib/features/stats/domain/models/plan_stats.dart` - Modelo de estadísticas
- ✅ `lib/features/stats/domain/services/plan_stats_service.dart` - Servicio de cálculo
- ✅ `lib/features/stats/presentation/providers/plan_stats_providers.dart` - Providers Riverpod
- ✅ `lib/features/stats/presentation/pages/plan_stats_page.dart` - Página UI completa

**Archivos modificados:**
- ✅ `lib/pages/pg_dashboard_page.dart` - Integración navegación y botón W17
- ✅ `lib/features/calendar/presentation/providers/calendar_providers.dart` - Provider planByIdStream

**Implementación:**
- ✅ Modelo `PlanStats` con métricas completas
- ✅ Servicio `PlanStatsService` calcula estadísticas:
  - Total, confirmados, borradores
  - Por tipo (family) y subtipo
  - Distribución temporal (eventos por día)
  - Por participante
  - Eventos "para todos" vs específicos
  - Actividad de participantes
- ✅ UI `PlanStatsPage` con cards y gráficos:
  - Resumen general con iconos
  - Barras horizontales por tipo
  - Distribución temporal (top 10 días)
  - Participantes activos
  - Eventos por subtipo
- ✅ Navegación: Botón W17 en dashboard navegación superior

**Mejoras futuras:**
- Integración con presupuesto (requiere T101)
- Exportación PDF/Excel
- Gráficos circulares para mejor visualización
- Comparativas de planes

**Relacionado con:** T101 (Presupuesto), T102 (Pagos), T109 (Estados)

---

### T114 - Mapa del Plan con Rutas
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media-Alta  
**Prioridad:** 🟢 Baja  
**Descripción:** Visualización de eventos con ubicación en mapa, con rutas entre eventos y optimización de rutas sugerida.

**Funcionalidades:**
1. Mostrar eventos en mapa
2. Pines en ubicaciones de eventos
3. Líneas entre eventos consecutivos
4. Popup con info de evento al clic
5. Vista satélite y mapa
6. Optimización de ruta (futuro)
7. Detectar eventos muy distantes

**Consideraciones:**
- Integración con Google Maps API
- Coste vs beneficio
- Alternativa: Mapbox, OpenStreetMap

**Criterios de aceptación:**
- Mapa visible con eventos
- Pines en ubicaciones correctas
- Rutas entre eventos
- Popup con información
- Alternativa gratuita si Google Maps es caro

**Archivos a crear:**
- `lib/features/map/presentation/pages/plan_map_page.dart`
- `lib/features/map/presentation/widgets/event_pin.dart`

**Relacionado con:** T121 (Formularios con ubicación)

---

### T124 - Dashboard Administrativo de Plataforma
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja (Para cuando tengamos usuarios reales)  
**Descripción:** Crear un dashboard administrativo completo para supervisar y gestionar la plataforma, con estadísticas de usuarios, planes y eventos.

**Motivación:**
- Supervisar salud de la plataforma
- Detectar patrones de uso
- Identificar problemas técnicos
- Tomar decisiones basadas en datos
- Gestionar contenido problemático si es necesario

**Funcionalidades:**

#### 1. Estadísticas Generales
- **Usuarios totales** (activos vs inactivos)
- **Planes totales** (activos vs completados)
- **Eventos totales** (por tipo)
- **Alojamientos totales**
- **Registros en últimos 7 días, 30 días, 365 días**
- **Tasa de crecimiento**

#### 2. Estadísticas de Usuarios
- Usuarios registrados por mes
- Usuarios activos (últimos 7 días)
- Usuarios por país (si tenemos geolocalización)
- Usuarios que más planes crean (top 10)
- Usuarios que más participan (top 10)
- Usuarios sin planes todavía

#### 3. Estadísticas de Planes
- Planes por categoría/etiqueta
- Planes por número de participantes (rango: 1-5, 6-10, 11-20, 20+)
- Planes más activos (eventos creados)
- Días promedio de duración de planes
- Planes públicos vs privados (si implementamos visibilidad)
- Planes creados vs completados

#### 4. Estadísticas de Eventos
- Eventos por tipo (Desplazamiento, Restauración, Actividad, Alojamiento)
- Eventos más populares por subtipo (Avión, Hotel, Museo, etc.)
- Eventos recurrentes (si T119 implementado)
- Eventos borradores vs confirmados
- Eventos por día de la semana
- Eventos por hora del día

#### 5. Estadísticas de Participación
- Participantes promedio por plan
- Planes con más participantes
- Usuarios observadores vs participantes activos
- Confirmaciones de asistencia (si T120 implementado)
- Tasa de participación

#### 6. Estadísticas Técnicas
- Tamaño medio de planes (número de eventos)
- Eventos por plan (distribución)
- Uso de timezones (planes multi-timezone)
- Eventos con documentos adjuntos
- Participantes con tracks múltiples

#### 7. Alertas y Monitoreo
- Usuarios con planes > 30 días sin actividad
- Planes sin eventos (posibles borradores)
- Usuarios con múltiples cuentas (email duplicate check)
- Planes con muchos eventos (posible spam)
- Eventos sin participantes asignados

#### 8. Gestión de Contenido (Opcional)
- Filtrar planes por palabra clave
- Ver planes sospechosos
- Modificar/quitar permisos a usuarios
- Resetear planes si necesario
- Exportar datos para análisis

**Criterios de aceptación:**
- Dashboard completo con todas las estadísticas
- Visualización clara con gráficos (usar chart library)
- Filtros de fecha (rango temporal)
- Exportar estadísticas a CSV/Excel
- Acceso restringido solo a administradores
- Actualización en tiempo real (opcional)
- Responsive (mobile y desktop)

**Archivos a crear:**
- `lib/features/admin/domain/services/admin_stats_service.dart`
- `lib/features/admin/presentation/providers/admin_stats_providers.dart`
- `lib/features/admin/presentation/pages/admin_dashboard_page.dart`
- `lib/features/admin/presentation/widgets/stats_card.dart`
- `lib/features/admin/presentation/widgets/stats_chart.dart`
- `lib/features/admin/presentation/widgets/user_list.dart`
- `lib/features/admin/presentation/widgets/plan_list_admin.dart`
- `lib/features/admin/presentation/widgets/alerts_panel.dart`

**Archivos a modificar:**
- Sistema de autenticación - Añadir rol "admin"
- `lib/pages/pg_dashboard_page.dart` - Añadir botón "Admin" para admins
- Modelos User, Plan, Event - Añadir flags admin si necesario

**Modelo de estadísticas:**
```dart
class PlatformStats {
  // Usuarios
  final int totalUsers;
  final int activeUsers;
  final int newUsersLast30Days;
  
  // Planes
  final int totalPlans;
  final int activePlans;
  final int completedPlans;
  final Map<String, int> plansByCategory;
  
  // Eventos
  final int totalEvents;
  final Map<String, int> eventsByType;
  final Map<String, int> eventsBySubtype;
  
  // Participación
  final double averageParticipantsPerPlan;
  final int topActivePlanId;
  final int topActiveUserId;
  
  DateTime lastUpdated;
}
```

**Notas:**
- Usar librería de gráficos como `fl_chart` o `syncfusion_flutter_charts`
- Considerar caché para estadísticas computacionalmente pesadas
- Actualización diaria vs tiempo real
- Protección de datos: no exponer información sensible de usuarios
- Integrar con sistema de alertas para administradores

---

### T125 - Completar Firestore Security Rules
**Estado:** ✅ Completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Alta  
**Descripción:** Completar y refinar las reglas de seguridad de Firestore para proteger todos los datos sensibles.

**Funcionalidades implementadas:**
1. ✅ Reglas para planes (crear, leer, actualizar, eliminar)
2. ✅ Reglas para eventos dentro de planes
3. ✅ Reglas para participantes y participaciones
4. ✅ Reglas para datos de pagos y presupuesto
5. ✅ Reglas para preferencias de usuario
6. ✅ Reglas para avisos y notificaciones
7. ✅ Reglas para grupos de contactos
8. ✅ Funciones auxiliares: isAuthenticated, isPlanOwner, canEditPlanContent, etc.
9. ✅ Validación de estructura de datos en servidor

**Criterios de aceptación:**
- ✅ Todas las operaciones protegidas por reglas
- ✅ Solo usuarios autenticados pueden hacer operaciones
- ✅ Permisos verificados en servidor (Firestore)
- ✅ Validación de estructura de datos
- ⚠️ Testing de reglas con casos límite (pendiente testing manual)

**Archivos creados:**
- ✅ `firestore.rules` - Reglas completas de seguridad

**Notas importantes:**
- Las reglas asumen owner=admin para simplificar verificación de roles
- Verificación completa de participación requiere checks en cliente (limitación de Firestore rules)
- Validación de estructura asegura integridad de datos

**Relacionado con:** T51, T52, T53, docs/flujos/FLUJO_SEGURIDAD.md, docs/guias/GUIA_SEGURIDAD.md

---

### T126 - Rate Limiting y Protección contra Ataques
**Estado:** ✅ Completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar rate limiting para prevenir ataques DoS y uso malicioso de la plataforma.

**Funcionalidades implementadas:**
1. ✅ Login: máx 5 intentos en 15 min (CAPTCHA tras 3 fallos)
2. ✅ Recuperación de contraseña: máx 3 emails/hora/cuenta
3. ✅ Invitaciones: máx 50/día/usuario
4. ✅ Creación de planes: máx 50/día/usuario
5. ✅ Creación de eventos: máx 200/día/plan
6. ⚠️ Detección de patrones sospechosos (futuro con Cloud Functions)
7. ⚠️ Bloqueo temporal de cuentas (futuro)

**Criterios de aceptación:**
- ✅ Rate limiting en login con CAPTCHA tras 3 fallos
- ✅ Límites aplicados en invites, creación de planes y eventos
- ✅ Mensajes claros sin filtrar información sensible
- ✅ Persistencia de contadores en SharedPreferences
- ✅ Limpieza automática de contadores fuera de ventana de tiempo
- ⚠️ Alertas automáticas para admins en casos sospechosos (futuro)
- ⚠️ Testing de límites (pendiente testing manual/integrado)

**Archivos creados:**
- ✅ `lib/features/security/services/rate_limiter_service.dart`

**Archivos modificados:**
- ✅ `lib/features/auth/presentation/notifiers/auth_notifier.dart` - Login y password reset
- ✅ `lib/features/calendar/presentation/notifiers/plan_participation_notifier.dart` - Invitaciones
- ✅ `lib/features/calendar/domain/services/plan_service.dart` - Creación de planes
- ✅ `lib/features/calendar/domain/services/event_service.dart` - Creación de eventos
- ✅ `lib/pages/pg_dashboard_page.dart` - Manejo de errores en UI
- ✅ `lib/pages/pg_plan_participants_page.dart` - Manejo de errores en UI

**Relacionado con:** T51, docs/flujos/FLUJO_SEGURIDAD.md, docs/guias/GUIA_SEGURIDAD.md

---

### T127 - Sanitización y Validación de User Input
**Estado:** ✅ Completada  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Alta  
**Descripción:** Sanitizar y validar todo el input del usuario para prevenir XSS, SQL injection y otros ataques.

**Funcionalidades implementadas:**
1. ✅ Sanitizar texto plano (eliminar caracteres peligrosos, normalizar espacios, límites de longitud)
2. ✅ Sanitizar HTML (whitelist) - función disponible para uso futuro en avisos/biografías
3. ✅ Tags permitidos: `b,strong,i,em,u,br,p,ul,ol,li,a`
4. ✅ Atributos permitidos en `a`: `href`, `title` (http/https) con `rel="noopener noreferrer"`
5. ✅ Eliminar `script`, `style`, `iframe`, `on*`, `img` (por ahora)
6. ✅ Flutter Text escapa HTML automáticamente al mostrar (comportamiento nativo)
7. ✅ Validar emails, URLs seguras
8. ✅ Widget SafeText para mostrar texto seguro explícitamente

**Criterios de aceptación:**
- ✅ HTML/texto sanitizado antes de guardar (sin scripts) - aplicado en eventos, alojamientos, planes
- ✅ HTML escapado al mostrar - Flutter Text escapa automáticamente
- ✅ Validación de inputs en todos los formularios - T51 completada
- ✅ No permitir JavaScript en user input - sanitización previene esto
- ⚠️ Testing de inputs maliciosos (pendiente testing manual/integrado)

**Archivos creados:**
- ✅ `lib/features/security/utils/sanitizer.dart` - sanitizePlainText() y sanitizeHtml()
- ✅ `lib/features/security/utils/validator.dart` - isValidEmail() y isSafeUrl()
- ✅ `lib/shared/widgets/safe_text.dart` - Widget SafeText para uso explícito

**Archivos modificados:**
- ✅ `lib/widgets/wd_event_dialog.dart` - Sanitización de descripción y campos personales
- ✅ `lib/widgets/wd_accommodation_dialog.dart` - Sanitización de nombre y descripción
- ✅ `lib/pages/pg_dashboard_page.dart` - Sanitización de nombre y unpId de planes
- ✅ `lib/pages/pg_plan_participants_page.dart` - Validación de email

**Nota importante:**
- Todos los campos actuales usan texto plano (no HTML rico)
- La sanitización HTML está disponible para uso futuro cuando se implementen avisos/biografías con formato
- Flutter Text widget escapa HTML automáticamente, proporcionando protección adicional

**Relacionado con:** T51, T105, docs/flujos/FLUJO_SEGURIDAD.md, docs/guias/GUIA_SEGURIDAD.md

---

### T128 - Logging Seguro y Auditoría
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja-Media  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar logging seguro sin datos sensibles y sistema de auditoría para acciones críticas.

**Funcionalidades:**
1. Logger que evita datos sensibles (emails, passwords, tokens completos)
2. Logging de acciones críticas (crear plan, eliminar plan, cambiar permisos)
3. Auditoría de cambios en datos financieros (T101, T102)
4. Auditoría de cambios de roles (T49)
5. Historial de cambios en planes (eliminación de eventos, etc.)
6. Timestamp y usuario de cada acción crítica

**Criterios de aceptación:**
- Logger que NO expone datos sensibles
- Logging de acciones críticas funcional
- Auditoría visible para admins
- Testing de logging sin datos sensibles

**Archivos a crear:**
- `lib/features/security/services/audit_log_service.dart`
- Actualizar `lib/shared/services/logger_service.dart`

**Relacionado con:** T109, T124, docs/flujos/FLUJO_SEGURIDAD.md

---

### T129 - Export de Datos Personales (GDPR)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja  
**Descripción:** Permitir a usuarios exportar todos sus datos personales (GDPR compliance).

**Funcionalidades:**
1. Botón "Exportar mis datos" en configuración
2. Generar archivo JSON/ZIP con todos los datos del usuario:
   - Perfil completo
   - Todos sus planes (como organizador)
   - Todas sus participaciones
   - Todos sus eventos creados
   - Preferencias de configuración
   - Historial de acciones (si implementado)
3. Descargar archivo o enviar por email
4. Formato legible y estructurado

**Criterios de aceptación:**
- Export completo de datos personales
- Formato JSON estructurado
- Descarga funcionando
- Testing con usuario completo

**Archivos a crear:**
- `lib/features/security/services/data_export_service.dart`
- UI para solicitar export

**Relacionado con:** T50, docs/flujos/FLUJO_SEGURIDAD.md, GDPR compliance

---

### T137 - Username único y sanitización de perfil
**Estado:** Pendiente - Implementado, pendiente de pruebas  
**Complejidad:** ⚠️ Baja-Media  
**Prioridad:** 🟠 Media  
**Descripción:** Garantizar `username` único y sanitización de campos de perfil (`displayName`, `username`) para coherencia e integridad de datos.

**Funcionalidades:**
1. Comprobación de disponibilidad de `username` (query case-insensitive)
2. Normalización de `username` a minúsculas y patrón `^[a-z0-9_]{3-30}$`
3. Sanitización de `displayName` (2-100 chars, texto plano)
4. Feedback de error en UI ante colisiones/validación

**Implementación completada:**
- ✅ `Validator.isValidUsername()` - Validación con regex `^[a-z0-9_]{3,30}$`
- ✅ `UserModel.toFirestore()` - Persiste `usernameLower` para búsquedas
- ✅ `UserService.isUsernameAvailable()` - Query case-insensitive con `usernameLower`
- ✅ `UserService.updateUsername()` - Actualización normalizada
- ✅ `AuthNotifier.updateUsername()` - Validación, normalización, control de colisiones
- ✅ UI en `pg_profile_page.dart` - Campo de edición con validación en tiempo real

**⚠️ PRUEBAS PENDIENTES (NO MARCAR COMO COMPLETADA HASTA VERIFICAR):**
- [ ] Validación: Intentar guardar "Ab", "A!", "usuario_valido_123" → Verificar mensajes de error correctos
- [ ] Normalización: Guardar "USUARIO_MAYUS" → Verificar que se guarda en minúsculas
- [ ] Unicidad: Intentar usar username de otro usuario → Verificar mensaje "ya está en uso"
- [ ] Persistencia: Guardar username, recargar app → Verificar que se mantiene el valor
- [ ] Firestore: Verificar que `username` y `usernameLower` están en el documento (ambos en minúsculas)
- [ ] Edge cases: Campo vacío (debe permitir, es opcional), desconexión de internet (debe mostrar error)
- [ ] Reglas de seguridad: Verificar que no se puede editar username de otro usuario

**Criterios de aceptación:**
- No se puede guardar un `username` duplicado
- `username` se guarda normalizado y validado
- `displayName` sanitizado y con límites
- Mensajes de error claros

**Archivos modificados:**
- ✅ `lib/features/security/utils/validator.dart` - Añadido `isValidUsername()`
- ✅ `lib/features/auth/domain/models/user_model.dart` - `usernameLower` en `toFirestore()`
- ✅ `lib/features/auth/domain/services/user_service.dart` - `isUsernameAvailable()`, `updateUsername()`
- ✅ `lib/features/auth/presentation/notifiers/auth_notifier.dart` - `updateUsername()`
- ✅ `lib/pages/pg_profile_page.dart` - UI de edición

**Relacionado con:** `docs/flujos/FLUJO_CRUD_USUARIOS.md`, T129, T51, T127

---

### T138 - Botón de Configuración en W1 sobre icono de perfil
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟠 Media  
**Descripción:** Colocar el botón de acceso a la configuración de la app en la posición W1 del layout (encima del icono de acceso al perfil), conforme a la guía de grid 17×13.

**Detalles:**
- Ubicación: W1 (parte superior izquierda del header, antes del acceso a perfil)
- Acción: abrir pantalla/panel de configuración de la app (acción existente si está implementada)
- Icono sugerido: `Icons.settings`
- Accesibilidad: tooltip “Configuración”

**Criterios de aceptación:**
- Botón visible en W1 por encima/delante del icono de perfil
- Al pulsar, navega a la configuración de la app
- No interfiere con navegación actual del header

**Archivos a modificar (estimado):**
- `lib/widgets/...` o `lib/pages/...` del header principal (donde resida W1)
- Actualizar `docs/guias/GUIA_UI.md` si fuera necesario para reflejar la posición

**Relacionado con:** `docs/guias/GUIA_UI.md` (Grid 17×13), Perfil (W6)

---

### T139 - Encuestas de disponibilidad estilo Doodle para planes
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟠 Media  
**Descripción:** Permitir al organizador lanzar una encuesta de fechas/horas (estilo Doodle) asociada a un plan, para que invitados/participantes voten su disponibilidad antes de fijar fechas.

**Alcance MVP:**
1. Crear encuesta vinculada a `planId` con título/opcional descripción
2. Añadir opciones de fecha/hora (bloques de tiempo) por el organizador
3. Compartir encuesta a invitados/participantes del plan
4. Votación simple por usuario: Disponible / Si es necesario / No puedo
5. Visualización de resultados (conteos por opción y quién votó)
6. Cerrar encuesta y convertir la opción ganadora en fechas del plan (con confirmación)

**V2 (posterior):**
- Disponibilidad granular (preferencia ponderada), comentarios por opción, límites de fecha, expiración automática, recordatorios, enlace público con token, edición de votos.

**Criterios de aceptación (MVP):**
- Crear encuesta con ≥1 opción de fecha/hora
- Los invitados pueden votar (autenticados o por enlace con token si se habilita)
- Resultados visibles al organizador (y a votantes si se habilita)
- Botón “Aplicar opción ganadora” que actualiza fechas del plan (previa confirmación)
- Registro de quién votó y cuándo

**Datos (borrador):**
- `polls/{pollId}`: `{ planId, title, description?, createdBy, createdAt, status: open|closed }`
- `pollOptions/{optionId}` (subcol.): `{ date, startHour, endHour }`
- `pollVotes/{voteId}` (subcol.): `{ optionId, userId, value: yes|maybe|no, votedAt }`

**Seguridad:**
- Solo organizador crea/cierra encuestas; votan invitados/participantes
- Reglas: lectura para invitados del plan; escritura de votos por el propio usuario

**UX/Entradas:**
- UI en plan: “Proponer fechas” → editor de opciones
- Vista de resultados con barras/tabla
- Avisos/notificaciones opcionales (T105) y enlaces compartibles

**Relacionado con:** T104 (invitaciones), T105 (notificaciones), `FLUJO_CRUD_PLANES.md`, `FLUJO_GESTION_PARTICIPANTES.md`

---

### T140 - Juegos multijugador para participantes durante desplazamientos
**Estado:** Pendiente (Muy a largo plazo)  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🟢 Baja - Feature de engagement, no crítica  
**Descripción:** Implementar un espacio de juegos multijugador para que los participantes puedan entretenerse durante desplazamientos o tiempo libre en el plan, especialmente útil para grupos familiares o de amigos.

**Contexto:**
Los desplazamientos largos (vuelos, trenes, autobuses) pueden ser momentos de espera aburridos. Este feature añade valor de entretenimiento y engagement durante el plan, especialmente para grupos que viajan juntos.

**Propuesta de Alcance (MVP para futuro):**
1. **Vista "Juegos"** asociada a un plan o evento de tipo desplazamiento
2. **Juegos simples multijugador:**
   - Trivia (preguntas y respuestas por categorías)
   - ¿Quién es quién? (adivinar personaje/participante)
   - Verdad o reto (preguntas personales o desafíos)
   - Palabras encadenadas (por turnos)
   - Ahorcado colaborativo
   - Quiz del plan (preguntas sobre el destino/itinerario)
3. **Mecánicas básicas:**
   - Partidas entre participantes del plan (2-6 jugadores)
   - Sincronización en tiempo real (Firestore listeners)
   - Puntuaciones simples y ranking del plan
   - Turnos automáticos con timeout
4. **Integración:**
   - Acceso desde vista de plan o evento de desplazamiento
   - Habilitable por organizador como "entretenimiento"
   - Opcional: activación automática en desplazamientos >1h
   - No bloquea funcionalidades principales del plan

**Consideraciones técnicas (futuras):**
- Sincronización tiempo real con Firestore
- Gestión de estado offline (modo local durante trayectos sin conexión)
- Timeouts y gestión de desconexiones
- Moderación básica de contenido generado por usuarios
- Performance: juegos ligeros, sin carga pesada de assets

**Expansión futura (V2+):**
- Más juegos (búsqueda del tesoro geográfica, quizzes personalizados)
- Logros y badges
- Estadísticas y historial de partidas
- Juegos colaborativos vs competitivos
- Personalización: crear preguntas personalizadas del grupo

**Criterios de aceptación (futuros):**
- Al menos 3 juegos funcionando en multijugador
- Sincronización en tiempo real entre 2+ participantes
- Puntuaciones y resultados visibles
- No afecta rendimiento del calendario/plan
- Funciona offline básico (al menos modo local)

**Archivos a crear (futuro):**
- `lib/features/games/` - Estructura completa de feature
- `lib/features/games/domain/models/` - Modelos de juegos, partidas, puntuaciones
- `lib/features/games/presentation/` - UI de juegos
- `lib/features/games/domain/services/` - Lógica de sincronización y reglas

**Relacionado con:** `FLUJO_CRUD_PLANES.md`, Eventos tipo desplazamiento, Participantes, T105 (notificaciones para turnos)

**Nota:** Esta tarea está documentada para referencia futura. No está planificada para implementación a corto/medio plazo.

---

### T141 - Ubicación de acceso a Notificaciones y Chat del plan (Web/App)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟠 Media  
**Descripción:** Decidir e implementar la ubicación de acceso a notificaciones del plan y chat/mensajería en ambas plataformas (web y móvil iOS/Android), manteniendo consistencia UX y accesibilidad.

**Propuesta para Web:**
- **Ubicación:** W28 (zona derecha del grid 17×13), a la derecha de cada tarjeta de plan en el dashboard
- **Diseño:** Iconos pequeños apilados verticalmente (uno encima del otro)
  - Icono de notificaciones arriba (ej: `Icons.notifications_outlined`)
  - Icono de chat abajo (ej: `Icons.chat_bubble_outline`)
- **Características:**
  - Badges de contadores para notificaciones no leídas y mensajes no leídos
  - **Estados visuales dinámicos:** Iconos cambian de color según estado de lectura
    - Sin no leídos: Color neutro/gris (`Icons.notifications_outlined`, color: `Colors.grey[400]`)
    - Con no leídos: Color primario/accent (`Icons.notifications`, color: `AppColorScheme.color2`)
    - Transición suave entre estados para feedback visual
  - Tooltip al hover indicando "Notificaciones del plan" / "Chat del plan"
  - Tamaño compacto para no interferir con contenido principal
  - Posicionamiento absoluto o relativo dentro de la tarjeta del plan

**Propuesta para App Móvil (iOS/Android):**
- **Opción A (Recomendada):** En el AppBar de la vista de **detalle del plan** (no en dashboard principal)
  - Iconos de notificaciones y chat en el AppBar superior
  - **Estados visuales dinámicos:** Mismo sistema de cambio de color que en web
    - Sin no leídos: Color neutro/gris (outlined)
    - Con no leídos: Color primario/accent (filled o coloreado)
    - Transición suave entre estados
  - Evita saturar el dashboard principal
  - Acceso inmediato cuando estás dentro del plan
  - Badges de contadores no leídos
- **Opción B (Alternativa):** Icono combinado "Comunicación" que abre un panel/bottom sheet con pestañas
  - Notificaciones / Chat en pestañas separadas
  - Menos saturación del AppBar
  - Más contenido visible de una vez
- **Dashboard principal de app:**
  - Indicador global de notificaciones no leídas (si aplica a nivel de usuario)
  - No duplicar acceso a chat/notificaciones por plan en el listado principal

**Consideraciones:**
- Consistencia: mismo concepto de acceso en ambas plataformas (iconos + badges + cambio de color)
- **Estados visuales:** Sistema de color dual para feedback inmediato
  - Color neutro (gris) cuando no hay no leídos → menos distracción
  - Color destacado (primario/accent) cuando hay no leídos → atención inmediata
  - Combinación con badges: color + contador para doble indicador
  - Transiciones suaves (200-300ms) para mejor UX
- Accesibilidad: 
  - Tamaños táctiles adecuados en móvil (mín. 44x44 pt)
  - No depender solo del color (usar badges + color juntos)
  - Tooltips en web con información de estado
  - Contraste adecuado en ambos estados (WCAG AA)
- Performance: badges y estados de color actualizados en tiempo real sin recargar toda la vista
- Visual: iconos no intrusivos cuando está todo leído, pero destacados cuando hay actividad

**Criterios de aceptación:**
- Acceso claro y visible a notificaciones del plan (web y móvil)
- Acceso claro y visible a chat del plan (web y móvil)
- Badges de contadores funcionando y actualizándose
- **Estados visuales dinámicos:** Iconos cambian de color según hay no leídos o no
  - Sin no leídos: Color neutro/gris (no intrusivo)
  - Con no leídos: Color primario/accent (destacado)
  - Transición suave entre estados
  - Mismo comportamiento en web y app móvil
- No interfiere con navegación principal
- Consistencia visual entre plataformas
- Accesibilidad verificada (tamaños táctiles, tooltips, no depender solo del color)

**Archivos a modificar (estimado):**
- Web: Componente de tarjeta de plan en dashboard (añadir iconos en W28)
- App: AppBar de vista de detalle del plan
- Componentes compartidos de badges/contadores (si se reutilizan)

**Relacionado con:** T105 (Notificaciones), Chat/Mensajería (futuro), `docs/guias/GUIA_UI.md` (Grid 17×13, W28), `FLUJO_INVITACIONES_NOTIFICACIONES.md`

**Nota:** Esta tarea requiere decisión de diseño antes de implementación. Validar propuesta con usuario y ajustar según feedback antes de codificar.

---

### T142 - Menú contextual tipo "launcher" para acceso rápido a opciones del plan
**Estado:** Pendiente (Futuro - Feature de UX avanzada)  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja - Mejora de UX, no crítica  
**Descripción:** Implementar un menú contextual tipo "launcher" para acceso rápido a todas las opciones del plan, creación de eventos/alojamientos y funcionalidades del plan desde un único punto de entrada.

**Concepto:**
Icono cuadrado formado por 9 círculos iguales (3×3 grid) con espacio entre ellos. Al pulsar, se expande un panel de 5×5 iconos redondos que actúan como atajos a funcionalidades y creación de elementos.

**Propuesta de Diseño:**

**Icono principal (estado colapsado):**
- **Diseño:** Cuadrado formado por 9 círculos iguales (3×3) con espacio entre ellos
- **Ubicación:** Vista de detalle del plan
  - Opción A: FAB (Floating Action Button) flotante en esquina inferior derecha
  - Opción B: Integrado en header/appbar del plan (preferible si hay espacio)
  - Opción C: Botón fijo en zona W específica del grid (si aplica)
- **Estado visual:** Color neutro/gris, con ligera animación al hover/touch
- **Tamaño:** Compacto pero táctil (mín. 48×48 pt en móvil)

**Panel expandido (estado abierto):**
- **Grid:** 5×5 iconos redondos = 25 slots disponibles
- **Distribución sugerida:**
  - **Fila 1 (Acciones principales):** Crear Evento, Crear Alojamiento, Añadir Participante, Proponer Fechas (T139), Ver Estadísticas
  - **Fila 2 (Comunicación):** Notificaciones, Chat del Plan, Avisos/Anuncios, Configuración Plan, Invitar
  - **Fila 3 (Herramientas):** Exportar Plan (T133), Ver Mapa, Lista del Plan, Presupuesto, Pagos
  - **Fila 4-5:** Accesos secundarios, herramientas avanzadas, atajos personalizables
- **Diseño:** 
  - Fondo semitransparente con overlay oscuro detrás
  - Iconos redondos con etiquetas de texto debajo o tooltips
  - Animación de expansión suave (scale + fade)
  - Botón de cierre (X) o cerrar tocando fuera del panel
  - Responsive: ajustar grid en pantallas pequeñas (3×4 o scroll)

**Funcionalidades:**
1. **Acceso rápido** a creación de eventos y alojamientos (reduciendo pasos)
2. **Punto centralizado** para todas las opciones del plan
3. **Visualización clara** de funcionalidades disponibles sin saturar la UI principal
4. **Personalización futura:** Organizador puede reorganizar iconos (V2)

**Consideraciones UX:**
- **Animaciones:** Expansión suave del icono 3×3 → panel 5×5, feedback táctil claro
- **Cierre:** Tocar fuera del panel, botón X, o después de seleccionar acción
- **Estados:** Loading states si alguna acción tarda, disabled states para funciones no disponibles
- **Navegación:** Mantener contexto del plan al abrir modales/diálogos desde el menú

**Consideraciones técnicas:**
- Componente reutilizable para diferentes contextos (plan, dashboard global, etc.)
- Gestión de estados: abierto/cerrado, animaciones, posición
- Accesibilidad: tamaños táctiles adecuados, soporte de teclado, lectores de pantalla
- Performance: carga lazy de iconos, animaciones optimizadas (no bloquean UI)
- Offline: Indicar qué acciones requieren conexión

**Criterios de aceptación (futuros):**
- Icono 3×3 visible y accesible en vista de detalle del plan
- Panel 5×5 se expande correctamente con animación suave
- Al menos 10-15 acciones funcionales disponibles (crear evento, alojamiento, etc.)
- Cierre intuitivo (tocar fuera, botón X, o después de acción)
- Funciona en web y app móvil con adaptación responsive
- Accesibilidad verificada (tamaños táctiles, contraste, teclado)

**Archivos a crear (futuro):**
- `lib/widgets/plan/plan_launcher_menu.dart` - Componente principal del menú
- `lib/widgets/plan/launcher_icon.dart` - Icono 3×3 colapsado
- `lib/widgets/plan/launcher_panel.dart` - Panel expandido 5×5
- Configuración de acciones/iconos disponibles

**Relacionado con:** `docs/guias/GUIA_UI.md`, `FLUJO_CRUD_PLANES.md`, T139 (Encuestas Doodle), T133 (Exportar Plan), Creación de eventos/alojamientos

**Nota:** Esta es una feature de UX avanzada planificada para el futuro. Requiere validación visual con mockups/imágenes antes de implementación. El diseño puede ajustarse según feedback del usuario y pruebas de usabilidad.

---

### T143 - Sistema de Patrocinios y Monetización (Publicidad Contextual)
**Estado:** Pendiente (Futuro - Monetización)  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🟢 Baja - Monetización, no crítica para funcionalidad  
**Descripción:** Implementar sistema de patrocinios contextuales y publicidad integrada en la app para monetización, permitiendo que empresas patrocinen categorías/subcategorías de eventos, alojamientos y funcionalidades del plan.

**Estrategia de Monetización:**
1. **Principal:** Venta de datos anónimos agregados (sin información personal identificable)
2. **Secundaria:** Patrocinios contextuales por categoría/subcategoría
3. **Comisión:** Marketing de afiliados (tracking de clicks y conversiones)
4. **Valor añadido:** Ofertas exclusivas de patrocinadores para usuarios de la app

**Sistema de Patrocinios Contextuales:**

**Funcionamiento:**
- Patrocinios asociados a categorías/subcategorías de eventos y alojamientos
- Ejemplo: Crear evento tipo "Desplazamiento > Vuelos" → Muestra logo de Edreams
- Ejemplo: Ver alojamiento tipo "Hoteles" → Muestra logo de Booking
- Múltiples patrocinadores posibles por categoría (rotación o selección por relevancia)

**Factores de Selección del Patrocinador:**
- Tipo de evento/alojamiento (categoría/subcategoría)
- Localización geográfica del plan/evento
- Preferencias del usuario (si ha usado antes)
- Disponibilidad de patrocinador (contratos activos)
- Prioridad/ranking del patrocinador

**Integración Visual (Propuesta):**

1. **Creación de Evento/Alojamiento:**
   - Banner sutil en parte inferior del modal con logo del patrocinador
   - Mensaje: "Patrocinado por [Logo] - Ofertas exclusivas"
   - Clic abre web del patrocinador con enlace de afiliado + tracking

2. **Visualización de Evento/Alojamiento:**
   - Badge pequeño con logo del patrocinador (si está patrocinado)
   - Opcional: banner expandible con ofertas del patrocinador
   - No intrusivo, claramente marcado como "Patrocinado"

3. **Listados/Búsquedas:**
   - Cards de patrocinadores destacados (máx. 1-2 por vista)
   - Claramente marcado como "Patrocinado"
   - Separado visualmente del contenido orgánico

**Tabla de Categorías y Patrocinadores:**
Ver documento completo en `docs/especificaciones/PATROCINIOS_Y_MONETIZACION.md`

Incluye patrocinadores para:
- Desplazamientos: Vuelos (Edreams), Coches (Avis), Taxi (FreeNow, Uber)
- Alojamientos: Hoteles (Booking), Casas (Airbnb)
- Restauración: Takeaway (Glovo), Restaurantes (TripAdvisor)
- Actividades: Tours (Free tours), Escape Rooms (Civitatis)
- Y más categorías (ver documento)

**Componentes Técnicos:**

1. **Sistema de Gestión de Patrocinadores:**
   - Panel admin para añadir/editar patrocinadores
   - Configuración por categoría/subcategoría
   - Enlaces de afiliado y tracking
   - Logos/assets de patrocinadores

2. **Motor de Selección:**
   - Lógica para seleccionar patrocinador relevante según contexto
   - Rotación de patrocinadores si hay múltiples opciones
   - Cache de selecciones para performance

3. **Tracking y Analytics:**
   - Clicks en patrocinadores (para comisiones afiliados)
   - Impresiones de banners/logos
   - Conversiones (si es posible trackear)
   - Datos agregados anónimos para venta

4. **Consentimiento y Privacidad:**
   - Aceptación explícita de publicidad/patrocinios
   - Aceptación de uso de datos anónimos
   - Cumplimiento GDPR
   - Transparencia sobre qué datos se comparten

**Criterios de aceptación (futuros):**
- Sistema de patrocinios funcional por categoría/subcategoría
- Integración visual no intrusiva en creación/visualización
- Tracking de clicks y conversiones para afiliados
- Panel admin para gestionar patrocinadores
- Consentimiento y privacidad compliant (GDPR)
- Sistema de datos anónimos funcionando

**Archivos a crear (futuro):**
- `docs/especificaciones/PATROCINIOS_Y_MONETIZACION.md` - Documentación completa
- `lib/features/sponsors/` - Estructura del feature
- `lib/features/sponsors/domain/models/` - Modelos de patrocinadores
- `lib/features/sponsors/presentation/widgets/` - Banners y badges
- `lib/features/sponsors/domain/services/` - Lógica de selección y tracking
- Panel admin para gestión

**Relacionado con:** `FLUJO_CRUD_PLANES.md`, `FLUJO_CRUD_EVENTOS.md`, `FLUJO_CRUD_ALOJAMIENTOS.md`, T135 (GDPR/Cookies), Monetización

**Nota:** Esta es una feature de monetización planificada para el futuro. Requiere definición detallada de contratos con patrocinadores, sistema de afiliados, y cumplimiento legal de privacidad antes de implementación.

---

### T144 - Gestión del ciclo de vida al finalizar un plan
**Estado:** Pendiente (Definición)  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media - Gestión de datos y costes  
**Descripción:** Definir e implementar las opciones disponibles al finalizar un plan, incluyendo eliminación, exportación, y mantenimiento (con posible monetización), optimizando costes de almacenamiento y ofreciendo valor al usuario.

**Problema:**
Los planes finalizados ocupan espacio en el servidor (Firestore) generando costes continuos. Necesitamos estrategias para:
- Dar control al usuario sobre sus datos históricos
- Reducir costes de almacenamiento en servidor
- Ofrecer opciones de valor (mantener con coste, exportar gratis)

**Opciones al finalizar un plan:**

1. **Eliminar el plan:**
   - Eliminación completa del servidor (Firestore)
   - Eliminación local (opcional, usuario decide)
   - Confirmación obligatoria con advertencia de pérdida permanente
   - Opcional: Período de gracia (ej: 30 días) antes de eliminación definitiva

2. **Exportar el plan:**
   - Exportación a PDF/Email profesional (T133 - ya documentado)
   - Exportación a formato JSON/ZIP (para respaldo)
   - Incluir todos los datos: eventos, alojamientos, participantes, fotos, presupuesto
   - Opcional: Exportación simplificada vs completa

3. **Mantener el plan (con posibles opciones):**
   - **Opción A (Gratis):** Mantener solo en local (sin coste servidor)
     - Datos se eliminan/reducen en Firestore
     - Backup local completo (SQLite/Hive)
     - Sincronización deshabilitada
     - Usuario puede ver/editar offline, pero no compartir
   - **Opción B (Monetización):** Mantener en servidor con cuota
     - Plan archivado en servidor (accesible pero no editable)
     - Cuota mensual/anual para mantener acceso online
     - Beneficios: acceso desde múltiples dispositivos, compartición, respaldo en la nube
     - Opcional: Planes premium con almacenamiento ilimitado

4. **Archivar (reducción de costes):**
   - Mantener metadata básica en servidor (nombre, fechas, resumen)
   - Eliminar datos detallados (eventos, alojamientos, etc.) del servidor
   - Guardar datos completos solo en local
   - Plan visible en listado pero marcado como "archivado"
   - Usuario puede restaurar/desarchivar si quiere acceso completo

**Propuesta de Estrategia:**

**Fase 1 (Post-finalización):**
- Mostrar diálogo con opciones al marcar plan como "Finalizado"
- Por defecto: "Archivar" (reducción de costes automática)
- Opciones claras: Exportar, Mantener (con coste), Eliminar

**Fase 2 (Reducción de costes automática):**
- Después de X meses finalizado (ej: 6 meses)
- Auto-archivado: metadata básica en servidor, datos detallados solo en local
- Notificar al usuario antes del auto-archivado

**Fase 3 (Monetización opcional):**
- Opción de "Mantenimiento Premium" con cuota
- Planes finalizados accesibles desde cualquier dispositivo
- Historial completo preservado en servidor

**Consideraciones técnicas:**

**Datos locales:**
- Backup completo en SQLite/Hive al archivar
- Datos comprimidos para optimizar espacio
- Sincronización deshabilitada para planes archivados

**Reducción en servidor:**
- Eliminar subcolecciones grandes (eventos, alojamientos, participaciones)
- Mantener solo: nombre, fechas, imagen, estadísticas básicas
- Campo `archived: true` y `archivedAt: timestamp`

**Exportación:**
- Integrar con T133 (Exportación profesional PDF/Email)
- Exportación JSON/ZIP para respaldo técnico
- Incluir todos los datos: eventos, alojamientos, fotos, participantes

**UI/UX:**
- Diálogo claro con explicación de cada opción
- Mostrar costes/beneficios de cada opción
- Confirmación obligatoria para eliminación
- Opción de cambiar de decisión después (desarchivar, re-archivar)

**Criterios de aceptación (futuros):**
- Diálogo de opciones al finalizar plan
- Exportación funcional (PDF/JSON/ZIP)
- Archivado automático con reducción de datos en servidor
- Backup local completo antes de eliminar del servidor
- Opcional: Sistema de cuotas para mantener en servidor
- Usuario puede restaurar plan archivado si lo desea

**Archivos a crear/modificar (futuro):**
- `lib/features/calendar/domain/services/plan_archive_service.dart`
- `lib/features/calendar/domain/services/plan_export_service.dart` (integrar con T133)
- UI: Diálogo de opciones al finalizar
- Lógica de reducción/eliminación de datos en servidor
- Sistema de backup local automático

**Relacionado con:** T133 (Exportación profesional), T129 (Export GDPR), `FLUJO_CRUD_PLANES.md`, Estados del plan (T109), Monetización

**Nota:** Esta tarea requiere definición detallada de estrategia de costes y monetización antes de implementación. Validar con usuario las preferencias de gestión de datos históricos.

---

### T145 - Generación de álbum digital al finalizar un plan
**Estado:** Pendiente (Futuro)  
**Complejidad:** ⚠️ Media-Alta  
**Prioridad:** 🟢 Baja - Feature de valor añadido  
**Descripción:** Permitir a los usuarios generar un álbum digital (PDF o integración con servicio externo) como recuerdo del plan finalizado, incluyendo fotos, eventos, estadísticas y momentos destacados.

**Contexto:**
Al finalizar un plan, los usuarios quieren conservar los recuerdos. Un álbum digital profesional añade valor emocional y puede ser una fuente adicional de monetización.

**Propuesta de Alcance (Híbrida):**

**Fase 1 - Generación PDF desde la app (MVP):**
1. **Diseño tipo álbum:**
   - Portada con nombre del plan, fechas, imagen destacada
   - Resumen ejecutivo: estadísticas del viaje, presupuesto, participantes
   - Día a día: sección por cada día con:
     - Fecha destacada
     - Eventos del día con descripciones
     - Fotos asociadas a eventos (si existen)
     - Alojamientos activos ese día
   - Galería de fotos: todas las fotos del plan (si se implementa T115)
   - Estadísticas finales: presupuesto real vs estimado, km recorridos, eventos totales
   - Mensajes/avisos destacados (opcional)
   - Participantes: lista con fotos de perfil (opcional)

2. **Plantilla profesional:**
   - Diseño limpio y moderno
   - Tipografía legible
   - Espaciado adecuado para fotos
   - Paleta de colores coherente con AppColorScheme
   - Optimizado para impresión y visualización digital

3. **Integración con T133:**
   - Reutilizar lógica de exportación profesional
   - Compartir infraestructura de generación PDF
   - Opción "Exportar plan" vs "Generar álbum digital" (mismo proceso, diferente formato)

**Fase 2 - Integración con servicio externo (Expansión):**
1. **Integración con APIs de álbumes digitales:**
   - Opciones: Mixbook, Shutterfly, CEWE (Europe), o proveedores locales
   - Proceso: Usuario genera álbum digital → Clic "Crear álbum físico" → Redirige a servicio externo con datos pre-rellenados
   - Datos enviados: Fotos, textos, estructura del plan
   - Monetización: Comisión por cada álbum vendido a través de la app

2. **Funcionalidades:**
   - Selección automática de mejores fotos del plan
   - Plantillas de diseño del servicio externo
   - Previsualización antes de enviar
   - Tracking de pedidos y estado

**Consideraciones técnicas:**

**Generación PDF (Fase 1):**
- Usar paquete `pdf` (ya considerado en T133)
- Componente reutilizable para diseño de páginas
- Gestión de imágenes: compresión, redimensionado, optimización
- Paginación automática
- Opcional: Vista previa antes de generar

**Integración externa (Fase 2):**
- APIs REST de servicios de álbumes
- Autenticación OAuth si es necesario
- Envío de datos formateados (JSON, XML según API)
- Webhooks para tracking de pedidos
- Manejo de errores y fallbacks

**Fuentes de datos:**
- Eventos del plan (descripciones, fechas, horarios)
- Alojamientos (fotos, fechas, nombres)
- Fotos asociadas a eventos/plan (si T115 implementado)
- Estadísticas del plan (presupuesto, participantes)
- Participantes (nombres, fotos de perfil opcionales)

**UX/UI:**
- Botón "Generar álbum digital" en vista de plan finalizado
- Proceso guiado: Seleccionar opciones (PDF vs Físico, qué incluir)
- Progreso de generación con indicador
- Vista previa antes de descargar/compartir
- Opciones: Descargar, Compartir, Guardar en galería, Enviar por email

**Monetización (Fase 2):**
- Comisión por álbum físico vendido a través de la app
- Opcional: Cuota premium para desbloquear plantillas exclusivas
- Opcional: Servicio "Álbum Premium" con diseño personalizado

**Criterios de aceptación (futuros):**
- Generación de PDF álbum funcional con diseño profesional
- Incluye fotos, eventos, estadísticas del plan
- Opcional: Integración con servicio externo para álbumes físicos
- Vista previa antes de generar
- Opciones de descarga y compartición
- Performance: Generación en <30 segundos para planes normales

**Archivos a crear (futuro):**
- `lib/features/calendar/services/album_generator_service.dart` - Generación PDF
- `lib/features/calendar/services/physical_album_service.dart` - Integración externa (Fase 2)
- Componentes de diseño de páginas del álbum
- UI: Flujo de generación y preview

**Relacionado con:** T133 (Exportación profesional PDF/Email), T144 (Ciclo de vida al finalizar plan), T115 (Sistema de fotos), `FLUJO_CRUD_PLANES.md`

**Nota:** Esta feature está planificada para el futuro. Requiere definir prioridad de Fase 1 (PDF) vs Fase 2 (Integración externa) y posibles proveedores de álbumes físicos. La generación PDF puede integrarse con T133 para reutilizar infraestructura.

---

### T146 - Sistema "Oráculo de Delfos" (Recomendaciones Inteligentes)
**Estado:** Pendiente (Futuro - Feature avanzada)  
**Complejidad:** 🔴 Muy Alta  
**Prioridad:** 🟡 Media - Diferenciador competitivo  
**Descripción:** Implementar un sistema inteligente de recomendaciones contextuales que sugiera eventos, alojamientos, restaurantes, actividades y servicios basándose en el contexto del plan, historial del usuario, preferencias, y tendencias agregadas de la comunidad. Las recomendaciones NO deben estar patrocinadas, manteniendo la confianza del usuario como prioridad.

**Contexto y Filosofía:**
El "Oráculo de Delfos" es un diferenciador clave que hace la app moderna e inteligente. A diferencia de otros sistemas de recomendación, este sistema genera propuestas genuinamente útiles basadas en datos, no en pagos. Esto genera confianza y hace que los patrocinadores quieran ser elegidos naturalmente, incentivando inversión en calidad y relevancia en lugar de pujas.

**Principios fundamentales:**
1. **Recomendaciones NO patrocinadas:** El algoritmo decide basándose en relevancia, no en pagos
2. **Transparencia:** Los usuarios entienden por qué se sugiere algo (opcional: mostrar razones)
3. **Contextual:** Sugerencias adaptadas al momento, lugar, tipo de plan, participantes
4. **Evolutivo:** Mejora con el uso, aprendiendo de preferencias del usuario y tendencias globales
5. **Separación clara:** Recomendaciones "limpias" vs patrocinios visibles pero diferenciados

**Fuentes de datos para recomendaciones:**

1. **Contexto del plan actual:**
   - Tipo de plan (viaje, evento, corporativo, etc.)
   - Ubicación geográfica (ciudad, país, región)
   - Fechas y duración
   - Número y tipo de participantes
   - Presupuesto estimado
   - Tiempo disponible por día

2. **Historial del usuario:**
   - Planes anteriores y sus eventos/alojamientos favoritos
   - Categorías de eventos más utilizadas
   - Patrones de comportamiento (horarios preferidos, tipos de actividades)
   - Calificaciones/feedback implícito (uso repetido, tiempo en eventos)
   - Lugares visitados anteriormente

3. **Tendencias agregadas de la comunidad:**
   - Eventos populares en la misma ubicación/fechas
   - Alojamientos mejor valorados por usuarios similares
   - Actividades trending en la zona
   - Patrones de éxito (planes similares exitosos)
   - Preferencias de grupos similares

4. **Datos externos (opcionales):**
   - Información de tiempo (OpenWeatherMap)
   - Eventos locales en la zona (APIs de turismo)
   - Valoraciones de servicios externos (TripAdvisor, Google Places - sin sesgo de pago)

**Puntos de integración en la app:**

1. **Al crear un plan:**
   - Sugerencias de "primer evento" según tipo de plan
   - Recomendaciones de alojamientos en la zona
   - Ideas de actividades iniciales

2. **Al crear un evento:**
   - Sugerencias de restaurantes cercanos si es hora de comer
   - Actividades similares que otros usuarios han añadido
   - Complementos naturales (ej: si añades "Museo", sugiere "Café cercano para después")

3. **En vista del calendario:**
   - Detectar espacios libres y sugerir actividades que encajen
   - Sugerencias de restaurantes para horas de comida vacías
   - Recomendaciones de transporte entre eventos distantes

4. **En vista del plan:**
   - Resumen de recomendaciones pendientes
   - "Completa tu plan" con sugerencias basadas en lo que falta
   - Alertas de oportunidades perdidas ("Otros usuarios suelen añadir X en esta zona")

5. **Panel de descubrimiento:**
   - Nueva sección dedicada a explorar recomendaciones
   - Filtros por categoría, ubicación, presupuesto
   - "Inspiración" basada en planes similares exitosos

**Algoritmo de recomendación (propuesta):**

**Fase 1 - Sistema basado en reglas (MVP):**
- Reglas simples basadas en contexto: ubicación, tipo de evento, hora del día
- Historial básico: categorías más usadas por el usuario
- Agregaciones simples: eventos populares en la zona

**Fase 2 - Machine Learning básico:**
- Collaborative filtering: usuarios similares → recomendaciones similares
- Content-based filtering: eventos similares a los que el usuario ha usado
- Hybrid approach: combinación de ambos

**Fase 3 - ML avanzado (futuro):**
- Modelos de deep learning para patrones complejos
- Aprendizaje continuo de feedback implícito y explícito
- Personalización a nivel de usuario y grupo

**Separación con Patrocinios:**

**Recomendaciones "Oráculo" (no patrocinadas):**
- Sección dedicada: "💡 Sugerencias inteligentes" o "🔮 Oráculo de Delfos"
- Badge: "Recomendado para ti" o "Basado en tu historial"
- Explicación opcional: "Sugerido porque usuarios similares lo valoraron" o "Popular en esta zona"

**Patrocinios (visibles pero diferenciados):**
- Sección separada: "✨ Ofertas de nuestros partners"
- Badge claro: "Patrocinado" o "Partner"
- Visualmente distinto: diseño diferente, colores distintos
- Opcional: Filtro para ocultar patrocinios

**Efecto en patrocinadores:**
- Los patrocinadores querrán aparecer en recomendaciones genuinas
- Incentiva: mejor servicio, mejor alineación con usuarios, más inversión en calidad
- Patrocinios visibles complementan pero no reemplazan recomendaciones

**Consideraciones técnicas:**

**Infraestructura:**
- Sistema de procesamiento de datos (batch y real-time)
- Almacenamiento de preferencias y historial
- API de recomendaciones con cache para performance
- Tracking de interacciones (clicks, uso, feedback)

**Privacidad:**
- Datos agregados y anónimos para tendencias globales
- Consentimiento explícito para uso de historial personal
- Opción de desactivar recomendaciones basadas en historial
- Cumplimiento GDPR para datos de usuario

**Performance:**
- Recomendaciones en tiempo real (<1s respuesta)
- Cache inteligente de recomendaciones frecuentes
- Precomputación para contextos comunes
- Degradación elegante si el sistema está sobrecargado

**UX/UI:**
- Diseño no intrusivo (sugerencias como opciones, no forzadas)
- Fácil de descartar o aceptar recomendaciones
- Opción de proporcionar feedback ("No es relevante", "Me gusta")
- Explicación transparente de por qué se sugiere (opcional)

**Criterios de aceptación (futuros):**
- Sistema genera recomendaciones relevantes en contextos clave
- Recomendaciones NO están influenciadas por pagos
- Separación clara visual entre recomendaciones y patrocinios
- Performance: <1s para generar recomendaciones
- Usuario puede desactivar recomendaciones basadas en historial
- Feedback loop funcional (mejora con el uso)

**Archivos a crear (futuro):**
- `lib/features/recommendations/domain/services/oracle_service.dart` - Lógica de recomendaciones
- `lib/features/recommendations/domain/models/recommendation.dart` - Modelo de recomendación
- `lib/features/recommendations/data/repositories/preference_repository.dart` - Historial y preferencias
- `lib/features/recommendations/presentation/widgets/recommendation_card.dart` - UI de recomendaciones
- `lib/features/recommendations/presentation/widgets/oracle_panel.dart` - Panel de descubrimiento
- `lib/features/recommendations/domain/services/ml_service.dart` - ML models (Fase 2+)

**Monetización indirecta:**
- Patrocinadores invierten más para ser elegidos naturalmente
- Datos anónimos agregados valiosos para análisis de tendencias
- Opcional: Feature premium con recomendaciones más avanzadas

**Relacionado con:** T143 (Patrocinios), T133 (Exportación), T147 (Sistema de Valoraciones), `FLUJO_CRUD_EVENTOS.md`, `FLUJO_CRUD_PLANES.md`, Datos agregados para monetización

**Dependencia:** **MUST IMPLEMENTAR T147 (Sistema de Valoraciones) ANTES de T146** según los flujos definidos. El Oráculo de Delfos necesita datos de valoraciones como input principal para generar recomendaciones relevantes.

**Nota:** Esta es una feature compleja que requiere definición detallada de algoritmos, infraestructura de datos, y UI/UX antes de implementación. Recomendado implementar por fases, empezando con reglas simples (Fase 1) y evolucionando a ML (Fase 2+). La integridad del sistema (NO patrocinado) es crítica para mantener la confianza del usuario.

---

### T147 - Sistema de Valoraciones (Planes, Eventos, Alojamientos)
**Estado:** Pendiente (Futuro)  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media - Base para recomendaciones y análisis  
**Descripción:** Implementar un sistema completo de valoraciones que permita a los usuarios valorar planes, eventos, alojamientos y otros elementos de la app. Las valoraciones servirán como base de datos para el "Oráculo de Delfos" (T146), análisis de tendencias, y mejoras en la experiencia del usuario.

**Contexto:**
Un sistema de valoraciones robusto es fundamental para múltiples funcionalidades futuras:
- **Oráculo de Delfos (T146):** Las valoraciones son input clave para recomendaciones
- **Análisis de tendencias:** Identificar qué funciona mejor en diferentes contextos
- **Feedback del usuario:** Entender qué elementos del plan fueron más valorados
- **Monetización indirecta:** Datos agregados valiosos para análisis y patrocinadores

**Elementos valorables:**

1. **Planes completos:**
   - Valoración global del plan (1-5 estrellas)
   - Opcional: Comentarios generales
   - Valoración por aspectos: organización, variedad, ejecución

2. **Eventos:**
   - Valoración del evento (1-5 estrellas)
   - Opcional: Comentarios específicos
   - Valoración implícita: uso repetido, tiempo dedicado, interacción

3. **Alojamientos:**
   - Valoración del alojamiento (1-5 estrellas)
   - Opcional: Comentarios (ubicación, comodidad, precio)
   - Valoración por aspectos: calidad/precio, ubicación, servicios

4. **Servicios/Transporte (futuro):**
   - Valoración de opciones de transporte usadas
   - Valoración de servicios externos integrados

**Modelo de valoración (propuesta):**

**Estructura de datos:**
```dart
Rating {
  id: String
  userId: String
  targetType: String // 'plan', 'event', 'accommodation'
  targetId: String // ID del plan/evento/alojamiento
  rating: int // 1-5 estrellas
  comment: String? // Opcional
  aspects: Map<String, int>? // Valoraciones por aspectos específicos
  createdAt: DateTime
  updatedAt: DateTime
}
```

**Aspectos específicos (opcional):**
- **Planes:** organización, variedad, ejecución, relación calidad-precio
- **Eventos:** disfrute, utilidad, duración adecuada, relación calidad-precio
- **Alojamientos:** comodidad, ubicación, servicios, relación calidad-precio

**Tipos de valoración:**

1. **Valoración explícita:**
   - Sistema de estrellas (1-5)
   - Comentarios opcionales
   - Valoración por aspectos (opcional)

2. **Valoración implícita (futuro):**
   - Uso repetido de eventos similares
   - Tiempo dedicado a eventos
   - Interacciones (compartir, exportar)
   - Completitud del plan (planes completados vs abandonados)

**Reglas de valoración:**

**¿Quién puede valorar?**
- **Planes:** Solo participantes activos (no observadores)
- **Eventos:** Participantes que asistieron (o estaban invitados)
- **Alojamientos:** Usuarios que se alojaron (o estaban en el plan durante esas fechas)

**Cuándo valorar:**
- **Al finalizar un plan:** Prompt para valorar el plan completo
- **Después de un evento:** Opción de valorar inmediatamente o más tarde
- **En cualquier momento:** Acceso a valorar elementos pasados desde el historial

**Privacidad y visibilidad:**
- **Valoraciones agregadas:** Visibles públicamente (promedio, número de valoraciones)
- **Valoraciones individuales:** Privadas por defecto (solo el usuario)
- **Opcional:** Usuario puede hacer pública su valoración (con nombre o anónima)
- **Análisis agregados:** Datos anónimos agregados para tendencias (GDPR compliant)

**UI/UX:**

1. **Sistema de estrellas:**
   - 5 estrellas interactivas
   - Media estelar visible en listados
   - Número total de valoraciones

2. **Prompt de valoración:**
   - No intrusivo
   - Aparece después de finalizar plan/evento
   - Opción de "Recordar más tarde" o "No valorar"
   - No mostrar más de 1 vez por elemento

3. **Historial de valoraciones:**
   - Sección en perfil: "Mis valoraciones"
   - Editar/eliminar valoraciones propias
   - Ver valoraciones agregadas de otros usuarios

4. **Visualización de valoraciones:**
   - En vista de plan: Valoración promedio del plan
   - En vista de evento: Valoración promedio del evento
   - En vista de alojamiento: Valoración promedio del alojamiento
   - Opcional: Ver comentarios públicos de otros usuarios

**Uso futuro de las valoraciones:**

1. **Oráculo de Delfos (T146):**
   - Input clave para algoritmos de recomendación
   - Eventos/alojamientos mejor valorados → más probabilidad de recomendación
   - Usuarios con gustos similares (collaborative filtering)

2. **Análisis de tendencias:**
   - Qué tipos de eventos son más valorados
   - Qué alojamientos funcionan mejor por ubicación
   - Patrones de éxito en planes similares

3. **Insights para usuarios:**
   - "Eventos similares a los que valoraste positivamente"
   - "Alojamientos mejor valorados en esta zona"
   - "Este tipo de plan tiene X estrellas de media"

4. **Monetización (datos agregados):**
   - Tendencias anónimas valiosas para análisis de mercado
   - Patrocinadores pueden entender qué es popular

**Consideraciones técnicas:**

**Almacenamiento:**
- Collection `ratings` en Firestore
- Índices: `targetType + targetId`, `userId`
- Agregaciones: Calcular promedio y contadores en tiempo real o batch

**Performance:**
- Cache de valoraciones agregadas (promedio, contador)
- Actualizar agregaciones en background
- Mostrar valoraciones agregadas sin cargar todas las individuales

**Validación:**
- Un usuario solo puede valorar una vez cada elemento (o permitir actualización)
- Validar que el usuario tiene permisos para valorar (participante, asistió, etc.)
- Sanitización de comentarios

**Consideraciones de privacidad:**
- Datos agregados anónimos para análisis (GDPR compliant)
- Usuario puede eliminar sus valoraciones
- Usuario puede optar por no participar en análisis agregados

**Criterios de aceptación (futuros):**
- Sistema de estrellas funcional (1-5) para planes, eventos, alojamientos
- Comentarios opcionales con sanitización
- Valoraciones agregadas (promedio, contador) visibles en UI
- Un usuario puede valorar cada elemento una vez (con opción de editar)
- Validación de permisos (solo participantes pueden valorar)
- Historial de valoraciones propias en perfil
- Opción de editar/eliminar valoraciones propias
- Datos agregados disponibles para Oráculo de Delfos (T146)

**Archivos a crear (futuro):**
- `lib/features/ratings/domain/models/rating.dart` - Modelo de valoración
- `lib/features/ratings/domain/services/rating_service.dart` - Lógica de valoraciones
- `lib/features/ratings/data/repositories/rating_repository.dart` - Repositorio Firestore
- `lib/features/ratings/presentation/widgets/star_rating_widget.dart` - Widget de estrellas
- `lib/features/ratings/presentation/widgets/rating_dialog.dart` - Diálogo de valoración
- `lib/features/ratings/presentation/widgets/rating_summary.dart` - Resumen de valoraciones
- `lib/features/ratings/domain/services/rating_aggregation_service.dart` - Cálculo de agregaciones

**Fases de implementación:**

**Fase 1 (MVP):**
- Sistema de estrellas básico (1-5)
- Valoración de planes, eventos, alojamientos
- Almacenamiento en Firestore
- Valoraciones agregadas (promedio, contador)

**Fase 2:**
- Comentarios opcionales
- Valoración por aspectos específicos
- Historial de valoraciones en perfil
- Editar/eliminar valoraciones

**Fase 3:**
- Valoración implícita (tracking de uso)
- Comentarios públicos (opcional)
- Integración con Oráculo de Delfos (T146)
- Análisis avanzados de tendencias

**Relacionado con:** T146 (Oráculo de Delfos), T143 (Patrocinios), `FLUJO_CRUD_PLANES.md`, `FLUJO_CRUD_EVENTOS.md`, `FLUJO_CRUD_ALOJAMIENTOS.md`, `FLUJO_ESTADOS_PLAN.md`, Monetización (datos agregados)

**Integración en flujos:**
- **FLUJO_ESTADOS_PLAN.md:** Valoración al finalizar plan (EN CURSO → FINALIZADO)
- **FLUJO_CRUD_PLANES.md:** Prompt de valoración al archivar plan finalizado
- **FLUJO_CRUD_EVENTOS.md:** Valoración después de completar evento (sección 4.5)
- **FLUJO_CRUD_ALOJAMIENTOS.md:** Valoración después de check-out (sección 4.5)

**Nota:** Este sistema es fundamental para el Oráculo de Delfos (T146) y otras funcionalidades futuras. **MUST IMPLEMENTAR T147 (Fase 1) ANTES de T146** según los flujos definidos. Las valoraciones deben ser simples y no intrusivas para maximizar participación. Los pasos de valoración están integrados en los flujos para asegurar implementación en el orden correcto.

---

### T148 - Análisis de Diferenciación Competitiva y Barreras de Entrada
**Estado:** Pendiente (Estratégico)  
**Complejidad:** 🔴 Alta  
**Prioridad:** 🔴 Alta - Crítico para supervivencia  
**Descripción:** Analizar y definir los diferenciadores competitivos únicos que hagan la app difícil de copiar, con enfoque en integraciones sin fricción, acceso directo a información de reservas, y características que creen barreras de entrada naturales. La app debe ser gratuita y ofrecer valor real a través de integraciones que reduzcan el esfuerzo del usuario al mínimo.

**Contexto y Problema:**
Una app en sí misma es fácil de copiar. Necesitamos identificar y desarrollar características que:
1. Sean difíciles de replicar (barreras técnicas, de datos, o de red)
2. Crean valor real para el usuario que la competencia no puede igualar fácilmente
3. Generan efectos de red (más usuarios = más valor)
4. Requieren integraciones complejas que la competencia no tiene
5. Establecen relaciones con proveedores que son costosas de replicar

**Principio fundamental:**
- **La app debe ser gratuita para el usuario final**
- **Clave: Integración sin fricción para añadir información de eventos y alojamientos**
- **Reducir esfuerzo del usuario al mínimo absoluto**

**Análisis del mercado y posicionamiento:**

**¿Qué existe en el mercado?**
- Calendarios genéricos (Google Calendar, Outlook)
- Apps de viaje (TripIt, TripCase)
- Apps de planificación de eventos (Eventbrite, Calendly)
- Apps de presupuesto de viaje (Trail Wallet, TravelSpend)

**¿Qué falta?**
- Integración real con proveedores de servicios (vuelos, hoteles, restaurantes)
- Acceso directo a información de reservas sin introducción manual
- Planificación colaborativa real-time con datos automáticos
- Recomendaciones inteligentes basadas en historial real
- Gestión completa del ciclo de vida de un viaje (planificación → ejecución → recuerdo)

**Propuestas de diferenciadores competitivos:**

### 1. **Acceso Directo a Información de Reservas (CRÍTICO)**

**Concepto:** Integración directa con APIs de proveedores para importar automáticamente información de reservas confirmadas.

**Ventajas:**
- Usuario recibe confirmación de reserva → Automáticamente aparece en la app
- Sin introducción manual de datos
- Información siempre actualizada (cambios de horario, cancelaciones, etc.)
- Diferencia clave: La competencia requiere entrada manual

**Integraciones prioritarias:**
1. **Aerolíneas:**
   - Iberia, Vueling, Ryanair, Lufthansa, Air Europa
   - Importación automática desde emails de confirmación (T134)
   - Integración API directa (futuro)
   - Actualizaciones automáticas: cambios de puerta, retrasos, cancelaciones

2. **Alojamientos:**
   - Booking.com, Airbnb, Expedia, Hotels.com
   - Importación desde confirmaciones de email
   - API directa para check-in/check-out automático
   - Actualizaciones de políticas de cancelación

3. **Alquiler de coches:**
   - Avis, Hertz, Enterprise, Sixt
   - Importación de reservas y detalles

4. **Restaurantes (futuro):**
   - OpenTable, Resy, TheFork
   - Reservas automáticas sincronizadas

5. **Actividades y Tours:**
   - Viator, GetYourGuide, Civitatis
   - Importación de reservas de tours

**Barrera de entrada:** Acuerdos con proveedores, desarrollo de APIs, coste de integración

**Implementación:**
- Fase 1: Importación desde emails (T134) - No requiere acuerdos, solo parsing inteligente
- Fase 2: APIs directas - Requiere acuerdos comerciales y técnicos con proveedores

### 2. **Importación Inteligente desde Email (T134)**

**Concepto:** Parsear automáticamente emails de confirmación de reservas para crear eventos/alojamientos sin intervención del usuario.

**Ventajas:**
- Usuario solo reenvía email o conecta cuenta
- Sistema extrae: fechas, horarios, ubicaciones, números de reserva, etc.
- Cero fricción para el usuario
- Funciona con cualquier proveedor (no requiere API)

**Tecnología:**
- Machine Learning para reconocer emails de confirmación
- OCR para extraer información de PDFs adjuntos
- NLP para parsear texto de emails
- Validación y confirmación con usuario antes de crear

**Barrera de entrada:** Modelos ML entrenados, algoritmo de parsing robusto

### 3. **Red de Efectos de Red (Red de Participantes)**

**Concepto:** Cuantos más usuarios usen la app, más valiosa se vuelve para todos.

**Factores:**
- Usuarios pueden compartir planes fácilmente
- Historial agregado de viajes mejora recomendaciones para todos
- Datos agregados anónimos mejoran "Oráculo de Delfos" (T146)
- La competencia no puede copiar la red de usuarios existente

**Implementación:**
- Sistema de invitaciones fluido
- Compartir planes con un clic
- Red social de viajes (futuro)

### 4. **Oráculo de Delfos + Valoraciones (T146 + T147)**

**Concepto:** Sistema de recomendaciones inteligentes basado en datos reales de usuarios, no en marketing.

**Ventajas:**
- Recomendaciones genuinamente útiles (no patrocinadas)
- Aprende de comportamiento real de usuarios
- Mejora con más usuarios
- La competencia no tiene acceso a estos datos agregados

**Barrera de entrada:** Necesita masa crítica de usuarios y datos históricos

### 5. **Sincronización Bidireccional con Proveedores**

**Concepto:** No solo importar, sino actualizar automáticamente cuando hay cambios.

**Ventajas:**
- Usuario siempre tiene información actualizada
- Notificaciones automáticas de cambios críticos
- La competencia que requiere entrada manual no puede igualar esto

**Ejemplos:**
- Vuelo cambia de puerta → Actualización automática en app
- Hotel cambia check-in → Notificación + actualización automática
- Cancelación de vuelo → Notificación crítica + opciones alternativas

**Barrera de entrada:** APIs de proveedores, webhooks, acuerdos técnicos

### 6. **Integración con Sistemas de Pago y Facturación**

**Concepto:** No solo planificar, sino gestionar pagos reales entre participantes.

**Ventajas:**
- Usuario puede pagar directamente desde la app
- División automática de costes
- Integración con servicios de pago (Stripe, PayPal)
- La competencia suele ser solo "planificación", no ejecución real

**Implementación futura:**
- T101: Sistema de presupuesto
- T102: Sistema de pagos

### 7. **Historial y Análisis Longitudinal**

**Concepto:** La app aprende de todos los viajes del usuario a lo largo del tiempo.

**Ventajas:**
- Recomendaciones personalizadas basadas en historial completo
- Análisis de gastos a lo largo del tiempo
- Identificación de patrones (ej: "Siempre vuelas con Iberia a Madrid")
- La competencia no tiene acceso a este historial si el usuario empieza en cero

**Barrera de entrada:** Usuario que migra pierde historial, ventaja para primeros usuarios

### 8. **Comunidad y Datos Agregados**

**Concepto:** Datos agregados anónimos crean valor que ningún competidor puede replicar.

**Ventajas:**
- "Hoteles mejor valorados en París según usuarios de la app"
- "Eventos más populares en Barcelona"
- Datos reales de la comunidad, no de marketing
- La competencia necesita construir su propia comunidad desde cero

**Barrera de entrada:** Necesita masa crítica y tiempo

### 9. **Plantillas y Planes Compartidos**

**Concepto:** Biblioteca de planes compartidos por la comunidad.

**Ventajas:**
- Usuario puede empezar con plan pre-hecho
- Planes exitosos se vuelven plantillas populares
- La competencia no tiene esta biblioteca

### 10. **Integración con Calendarios Externos (T131)**

**Concepto:** Funciona con ecosistema existente del usuario, no lo reemplaza.

**Ventajas:**
- Exportación a Google Calendar, Outlook
- Usuario no tiene que elegir entre apps
- Reduce fricción de adopción

**Barrera de entrada:** Es fácil de copiar, pero es necesario para adopción

**Estrategia de barreras de entrada (orden de prioridad):**

**Barreras técnicas (difíciles de copiar):**
1. **Importación inteligente desde email (T134)** - Requiere ML avanzado
2. **APIs de proveedores** - Requiere acuerdos comerciales
3. **Oráculo de Delfos con ML (T146)** - Requiere datos y algoritmos
4. **Sincronización bidireccional** - Requiere infraestructura compleja

**Barreras de red (efectos de red):**
1. **Masa crítica de usuarios** - Cuanto más usuarios, más valioso
2. **Datos agregados históricos** - La competencia no tiene estos datos
3. **Planes compartidos** - Biblioteca crece con el tiempo
4. **Valoraciones y recomendaciones** - Mejoran con más usuarios

**Barreras comerciales (relaciones exclusivas):**
1. **Acuerdos con proveedores** - Difícil de replicar
2. **Integración preferencial** - Primeros en tener acceso
3. **Monetización indirecta** - Modelo de negocio único

**Plan de implementación (priorizado por diferenciación):**

**Fase 1 - Diferenciadores inmediatos (MVP):**
- ✅ Importación desde email (T134) - **CRÍTICO**
- ✅ Oráculo de Delfos básico (T146 Fase 1) - Recomendaciones simples
- ✅ Sistema de valoraciones (T147) - Base de datos

**Fase 2 - Barreras técnicas (6-12 meses):**
- APIs directas con proveedores prioritarios (Iberia, Booking.com)
- Sincronización bidireccional básica
- Oráculo de Delfos con ML (T146 Fase 2)

**Fase 3 - Efectos de red (12-24 meses):**
- Comunidad y planes compartidos
- Datos agregados valiosos
- Integraciones con más proveedores

**Factores críticos de éxito:**
1. **Gratis para usuarios** - Sin barreras de adopción
2. **Cero fricción** - Importación automática es clave
3. **Primeros en el mercado** - Ventaja temporal
4. **Acuerdos con proveedores** - Difícil de replicar
5. **Calidad de recomendaciones** - Oráculo de Delfos único

**Análisis competitivo:**

**¿Qué puede copiar fácilmente la competencia?**
- Interfaz de usuario
- Funcionalidades básicas (crear eventos, calendario)
- Exportación a calendarios externos
- Sistema de invitaciones básico

**¿Qué NO puede copiar fácilmente?**
- Base de datos de usuarios y historial
- Acuerdos con proveedores establecidos
- Algoritmos ML entrenados con nuestros datos
- Red de usuarios existente
- Datos agregados históricos
- Reputación y confianza construida

**Recomendaciones estratégicas:**
1. **Priorizar T134 (Importación desde Email)** - Diferenciador inmediato y sin coste de APIs
2. **Iniciar conversaciones con proveedores** - Iberia, Booking.com, Vueling (acuerdos API)
3. **Construir red de usuarios rápidamente** - Efectos de red son críticos
4. **Proteger datos agregados** - Asset valioso que la competencia no puede replicar
5. **Mantener app gratuita** - Sin barreras de adopción

**Criterios de aceptación (futuros):**
- Importación automática desde email funcional (T134)
- Al menos 3 integraciones API con proveedores principales
- Oráculo de Delfos genera recomendaciones útiles
- Sistema de valoraciones activo con datos suficientes
- Usuarios pueden crear plan completo en <5 minutos (incluyendo importaciones)

**Archivos a crear (futuro):**
- `docs/estrategia/DIFERENCIACION_COMPETITIVA.md` - Documento estratégico detallado
- `docs/estrategia/INTEGRACIONES_PROVEEDORES.md` - Roadmap de integraciones
- `docs/estrategia/BARRERAS_ENTRADA.md` - Análisis de barreras

**Relacionado con:** T134 (Importación desde Email), T146 (Oráculo de Delfos), T147 (Valoraciones), T131 (Calendarios externos), T101 (Presupuesto), T102 (Pagos), Estrategia de monetización

**Nota:** Esta es una tarea estratégica crítica. Requiere análisis continuo del mercado, competencia, y validación de diferenciadores. Debe actualizarse periódicamente según feedback de usuarios y cambios en el mercado. La implementación de T134 (Importación desde Email) es el diferenciador más inmediato y debe ser prioridad máxima.

---

### T149 - Análisis de Riesgos ante el Éxito y Estrategias de Mitigación
**Estado:** Pendiente (Estratégico)  
**Complejidad:** 🔴 Alta  
**Prioridad:** 🔴 Alta - Crítico para sostenibilidad  
**Descripción:** Identificar y analizar los riesgos que surgen cuando la app tiene éxito (escalabilidad, costes, competencia, legales, operativos, seguridad) y definir estrategias proactivas para mitigarlos antes de que se conviertan en problemas críticos.

**Contexto:**
El éxito trae nuevos desafíos. Una app que crece rápidamente enfrenta riesgos que no existen en etapas tempranas:
- Costes de infraestructura crecientes
- Ataques y abusos a mayor escala
- Presión competitiva de grandes jugadores
- Responsabilidades legales y regulatorias
- Desafíos operativos y de soporte
- Problemas de escalabilidad técnica

Es crítico anticipar estos riesgos y tener planes de mitigación listos antes de que ocurran.

**Categorías de riesgos:**

## 1. RIESGOS TÉCNICOS Y DE INFRAESTRUCTURA

### 1.1 - Escalabilidad de Infraestructura

**Riesgo:**
- Crecimiento exponencial de usuarios sobrecarga servidores
- Firestore costes crecen exponencialmente con volumen de datos
- Firebase Storage costes por almacenamiento de imágenes
- Límites de rate limiting de APIs externas

**Impacto:** Alto - App se vuelve lenta o inaccesible, costes insostenibles

**Mitigación:**
- **Arquitectura escalable desde el inicio:**
  - Firestore: Índices optimizados, estructura de datos eficiente
  - Paginación obligatoria en queries grandes
  - Cache agresivo de datos frecuentes
  - Batch operations para escrituras masivas
  
- **Monitoreo proactivo:**
  - Alertas de costes (Firebase Billing Alerts)
  - Alertas de performance (latencia, errores)
  - Dashboards de métricas clave (usuarios activos, requests/seg)
  
- **Optimización continua:**
  - Archivar datos antiguos (T144)
  - Compresión de imágenes automática
  - CDN para assets estáticos
  - Rate limiting inteligente (T126)
  
- **Plan de escalado:**
  - Definir umbrales de escalado (ej: >10K usuarios → optimizar queries)
  - Preparar migración a arquitectura más robusta si necesario
  - Considerar Firebase Blaze plan con costes controlados

### 1.2 - Costes Crecientes de Infraestructura

**Riesgo:**
- Firestore: Coste por lectura/escritura crece linealmente con uso
- Storage: Coste por GB almacenado
- Funciones Cloud: Coste por invocación
- APIs externas: Costes de integraciones

**Impacto:** Alto - Costes pueden superar ingresos, app se vuelve insostenible

**Mitigación:**
- **Modelo de datos eficiente:**
  - Minimizar lecturas redundantes (cache, listeners optimizados)
  - Batch writes siempre que sea posible
  - Estructura de datos que minimice documentos necesarios
  
- **Estrategias de reducción de costes:**
  - Archivar planes antiguos (reducir datos activos) - T144
  - Compresión de imágenes antes de subir
  - Límites de almacenamiento por usuario (planes premium para más)
  - Offline-first reduce lecturas (T57, T60)
  
- **Monetización para cubrir costes:**
  - T143: Patrocinios contextuales
  - T132: Cuotas de agencias de viajes
  - Venta de datos anónimos agregados
  - Plan premium (almacenamiento ilimitado, features avanzadas)
  
- **Monitoreo y alertas:**
  - Billing alerts de Firebase
  - Dashboard de costes por servicio
  - Proyecciones de costes según crecimiento
  
- **Contingencia:**
  - Plan de migración a infraestructura propia si Firebase se vuelve costoso
  - Evaluar alternativas (Supabase, MongoDB Atlas) como backup

### 1.3 - Rendimiento y Latencia

**Riesgo:**
- App se vuelve lenta con muchos usuarios
- Queries complejas tardan mucho tiempo
- Sincronización en tiempo real se degrada
- APIs externas lentas afectan experiencia

**Impacto:** Medio-Alto - Usuarios abandonan si app es lenta

**Mitigación:**
- **Optimización de queries:**
  - Índices compuestos en Firestore
  - Limitar resultados (paginación)
  - Evitar queries complejas en tiempo real
  
- **Cache agresivo:**
  - Cache local en cliente (SharedPreferences, Hive)
  - Cache en servidor para datos frecuentes
  - TTL inteligente según tipo de dato
  
- **Arquitectura offline-first:**
  - Funcionalidad completa offline (T57)
  - Sincronización en background
  - UI responsiva sin esperar red
  
- **Monitoreo de performance:**
  - Firebase Performance Monitoring
  - Alertas de latencia >X ms
  - Profiling periódico de queries lentas

## 2. RIESGOS DE SEGURIDAD

### 2.1 - Ataques y Abusos

**Riesgo:**
- Ataques DDoS sobrecargan infraestructura
- Bots crean cuentas falsas
- Scraping de datos
- Abuso de APIs públicas

**Impacto:** Alto - Servicio inaccesible, datos comprometidos, costes elevados

**Mitigación:**
- **Rate Limiting (T126 - ✅ Implementado):**
  - Login: 5 intentos/15min
  - Invitaciones: 50/día
  - Plan/event creation: Límites diarios
  - Validar que límites son suficientes para escala
  
- **Protección anti-bot:**
  - CAPTCHA en registro y acciones sensibles (T135)
  - Validación de email obligatoria
  - Detección de patrones sospechosos
  
- **Firestore Security Rules (T125 - ✅ Implementado):**
  - Validación server-side de todos los accesos
  - Reglas estrictas por rol
  - Validación de estructura de datos
  
- **Monitoreo de seguridad:**
  - Alertas de actividad sospechosa
  - Logging de accesos fallidos
  - Detección de patrones de abuso
  
- **Plan de respuesta a incidentes:**
  - Procedimiento para detectar y bloquear atacantes
  - Comunicación con usuarios si hay brecha
  - Backup y recuperación de datos

### 2.2 - Violaciones de Datos

**Riesgo:**
- Acceso no autorizado a datos de usuarios
- Filtración de información sensible
- Ataques de inyección (SQL, XSS)

**Impacto:** Crítico - Pérdida de confianza, responsabilidad legal, multas GDPR

**Mitigación:**
- **Sanitización de input (T127 - ✅ Implementado):**
  - Sanitización de texto plano y HTML
  - Validación de todos los inputs
  - Prevención de XSS
  
- **Cifrado:**
  - Datos sensibles cifrados en tránsito (HTTPS)
  - Considerar cifrado en reposo para datos muy sensibles
  - API keys y secrets en Firebase Functions (no en cliente)
  
- **Firestore Security Rules:**
  - Reglas estrictas que validan acceso
  - No exponer datos sensibles en cliente
  
- **Auditoría de seguridad:**
  - Revisiones periódicas de código
  - Penetration testing
  - Análisis de dependencias vulnerables
  
- **Cumplimiento GDPR (T129, T135):**
  - Derecho al olvido implementado
  - Exportación de datos personales
  - Consentimiento explícito para datos
  - Política de privacidad clara

### 2.3 - Vulnerabilidades de Dependencias

**Riesgo:**
- Paquetes de terceros con vulnerabilidades
- Dependencias desactualizadas

**Impacto:** Medio-Alto - Explotación de vulnerabilidades conocidas

**Mitigación:**
- **Gestión de dependencias:**
  - Auditoría regular (`flutter pub outdated`, `dart pub outdated`)
  - Actualizar dependencias críticas inmediatamente
  - Usar versiones estables, evitar pre-releases en producción
  
- **Monitoreo:**
  - Alertas de vulnerabilidades (GitHub Dependabot, Snyk)
  - Revisar changelogs antes de actualizar
  - Testing exhaustivo después de actualizaciones

## 3. RIESGOS LEGALES Y REGULATORIOS

### 3.1 - Cumplimiento GDPR/COPPA

**Riesgo:**
- Multas por incumplimiento GDPR (hasta 4% facturación o €20M)
- Problemas con usuarios menores de edad (COPPA)
- Demandas por uso indebido de datos

**Impacto:** Crítico - Multas masivas, cierre de operaciones en UE

**Mitigación:**
- **Implementación completa (T135, T136):**
  - Gestión de cookies en web (T135)
  - App Tracking Transparency en iOS (T136)
  - Consentimiento explícito para datos personales
  - Política de privacidad completa
  
- **Cumplimiento GDPR:**
  - Derecho al olvido (T129)
  - Exportación de datos personales (T129)
  - Minimización de datos (solo lo necesario)
  - Retención de datos limitada
  
- **Protección de menores:**
  - Verificación de edad
  - Consentimiento parental si <16 años
  - Restricciones de features para menores
  
- **Documentación legal:**
  - Terms of Service actualizados
  - Privacy Policy completa
  - Cookie Policy (T135)
  - Documentos legales revisados por abogado

### 3.2 - Responsabilidad por Contenido

**Riesgo:**
- Usuarios publican contenido ofensivo/ilegal
- Información incorrecta causa problemas a usuarios
- Responsabilidad por recomendaciones del Oráculo de Delfos

**Impacto:** Medio - Demandas, pérdida de reputación

**Mitigación:**
- **Terms of Service claros:**
  - Exención de responsabilidad por contenido de usuarios
  - Usuario responsable de verificar información
  - Política de contenido prohibido
  
- **Moderación (futuro):**
  - Sistema de reporte de contenido
  - Revisión de contenido reportado
  - Bloqueo de usuarios que violen términos
  
- **Deslinde de responsabilidad:**
  - Recomendaciones del Oráculo son "sugerencias", no garantías
  - Usuario verifica reservas y detalles
  - No somos responsables de cambios de proveedores externos

### 3.3 - Propiedad Intelectual

**Riesgo:**
- Infracción de patentes de competidores
- Uso no autorizado de marcas/logos de proveedores
- Acusaciones de robo de ideas/features

**Impacto:** Medio - Demandas, cambios forzados

**Mitigación:**
- **Revisión legal:**
  - Consultar con abogado sobre uso de marcas/logos
  - Verificar patentes relevantes antes de implementar features
  - Documentar desarrollo original de features
  
- **Uso de marcas:**
  - Usar logos solo con permiso de proveedores
  - Atribución adecuada cuando sea necesario
  - Nombres genéricos en lugar de marcas cuando sea posible

## 4. RIESGOS COMPETITIVOS

### 4.1 - Copia por Grandes Jugadores

**Riesgo:**
- Google, Microsoft, o grandes empresas copian features
- Competidores con más recursos lanzan producto similar
- Pérdida de usuarios a competencia

**Impacto:** Alto - Pérdida masiva de usuarios, reducción de market share

**Mitigación:**
- **Diferenciadores únicos (T148):**
  - Importación automática desde email (T134) - Difícil de copiar
  - Acuerdos exclusivos con proveedores
  - Red de usuarios y datos históricos (efecto de red)
  - Oráculo de Delfos con nuestros datos únicos
  
- **Velocidad de innovación:**
  - Mantener ventaja con features nuevas
  - Escuchar feedback de usuarios constantemente
  - Iterar rápido y mejorar continuamente
  
- **Fidelización:**
  - Historial de usuario crea switching cost
  - Funcionalidades que se mejoran con uso
  - Comunidad activa que retiene usuarios

### 4.2 - Acquisición Hostil

**Riesgo:**
- Competidor intenta comprar usuarios/marca
- Presión para vender o cerrar

**Impacto:** Medio - Pérdida de control, cierre del producto

**Mitigación:**
- **Independencia financiera:**
  - Monetización suficiente para sostenibilidad
  - No depender de inversores que puedan forzar venta
  
- **Valor único:**
  - Diferenciadores que no se pueden comprar fácilmente
  - Relaciones con proveedores exclusivas
  - Datos y comunidad únicos

## 5. RIESGOS OPERATIVOS

### 5.1 - Escala de Soporte

**Riesgo:**
- Más usuarios = más tickets de soporte
- Equipo pequeño no puede manejar volumen
- Usuarios frustrados abandonan

**Impacto:** Medio - Pérdida de usuarios, reputación dañada

**Mitigación:**
- **Documentación exhaustiva:**
  - FAQs completos
  - Guías paso a paso
  - Videos tutoriales
  
- **Auto-servicio:**
  - Help center en la app
  - Búsqueda inteligente de respuestas
  - Chatbot básico para preguntas comunes
  
- **Priorización:**
  - Sistema de tickets por prioridad
  - Respuesta rápida a issues críticos
  - Automatización de respuestas comunes
  
- **Escalado de equipo:**
  - Plan de contratación según crecimiento
  - Community managers para ayudar usuarios
  - Sistema de escalado gradual

### 5.2 - Dependencia de Personas Clave

**Riesgo:**
- Desarrollador clave deja el proyecto
- Conocimiento crítico no documentado
- Desarrollo se detiene o se ralentiza

**Impacto:** Alto - Desarrollo paralizado, bugs no resueltos

**Mitigación:**
- **Documentación completa:**
  - Arquitectura documentada
  - Procesos documentados
  - Decisiones técnicas documentadas (ARCHITECTURE_DECISIONS.md)
  
- **Código mantenible:**
  - Código limpio y comentado
  - Tests para validar funcionalidad
  - Estándares de código consistentes
  
- **Distribución de conocimiento:**
  - No depender de una sola persona
  - Code reviews para compartir conocimiento
  - Pair programming cuando sea posible

## 6. RIESGOS DE DATOS Y PRIVACIDAD

### 6.1 - Pérdida de Datos

**Riesgo:**
- Corrupción de datos en Firestore
- Eliminación accidental masiva
- Desastre natural/fallo de Firebase

**Impacto:** Crítico - Pérdida de datos de usuarios, app inutilizable

**Mitigación:**
- **Backups automáticos:**
  - Firebase export automático diario
  - Backups off-site (Google Cloud Storage)
  - Retención de backups por X días
  
- **Recuperación:**
  - Plan de recuperación documentado
  - Testing periódico de restauración
  - Procedimiento de rollback
  
- **Redundancia:**
  - Firestore tiene redundancia automática
  - Considerar backup manual adicional si crítico

### 6.2 - Privacidad de Usuarios

**Riesgo:**
- Filtración accidental de datos privados
- Uso indebido de datos para otros fines
- Acusaciones de invasión de privacidad

**Impacto:** Crítico - Pérdida de confianza, demandas, multas

**Mitigación:**
- **Minimización de datos:**
  - Solo recolectar datos necesarios
  - Eliminar datos antiguos innecesarios
  - Anonimizar datos agregados
  
- **Transparencia:**
  - Privacy Policy clara sobre uso de datos
  - Usuario puede ver/exportar sus datos
  - Consentimiento explícito para uso de datos
  
- **Seguridad:**
  - Datos sensibles cifrados
  - Acceso restringido solo a quien necesite
  - Audit logs de acceso a datos sensibles

## 7. RIESGOS FINANCIEROS

### 7.1 - Modelo de Monetización Insuficiente

**Riesgo:**
- Costes superan ingresos
- Monetización no escala con usuarios
- Competidores ofrecen gratis

**Impacto:** Crítico - App insostenible, cierre

**Mitigación:**
- **Monetización diversificada (T143, T132):**
  - Múltiples fuentes de ingresos
  - Venta de datos anónimos agregados
  - Patrocinios contextuales
  - Cuotas de agencias
  
- **Optimización de costes:**
  - Reducir costes de infraestructura
  - Archivar datos antiguos
  - Optimizar queries y storage
  
- **Plan de contingencia:**
  - Modelo freemium si necesario
  - Límites en versión gratuita
  - Features premium para usuarios avanzados

### 7.2 - Cambios en Términos de Proveedores

**Riesgo:**
- Firebase aumenta precios drásticamente
- Proveedores de APIs cambian términos
- Integraciones se vuelven costosas

**Impacto:** Medio-Alto - Costes inesperados, necesidad de migración

**Mitigación:**
- **Abstraction layers:**
  - No depender completamente de un proveedor
  - Interfaces que permitan cambiar backend
  - Evaluar alternativas periódicamente
  
- **Contratos:**
  - Si posible, contratos a largo plazo con proveedores
  - Cláusulas de protección ante cambios de precios
  
- **Plan de migración:**
  - Documentar cómo migrar a alternativas
  - Evaluar alternativas periódicamente
  - No vendor lock-in si es posible

## 8. PLAN DE ACCIÓN PRIORIZADO

### Fase 1 - Crítico (Inmediato):
- ✅ Rate Limiting (T126)
- ✅ Firestore Security Rules (T125)
- ✅ Sanitización (T127)
- ⚠️ GDPR Compliance (T135, T136, T129)
- ⚠️ Monitoreo de costes y alertas
- ⚠️ Backups automáticos

### Fase 2 - Alto (6 meses):
- ⚠️ Optimización de costes de infraestructura
- ⚠️ Arquitectura escalable completa
- ⚠️ Documentación legal completa
- ⚠️ Plan de respuesta a incidentes
- ⚠️ Sistema de soporte escalable

### Fase 3 - Medio (12 meses):
- ⚠️ Auditorías de seguridad periódicas
- ⚠️ Plan de migración a alternativas
- ⚠️ Moderación de contenido
- ⚠️ Diversificación de monetización

**Criterios de aceptación (futuros):**
- Todos los riesgos críticos tienen mitigación implementada
- Monitoreo y alertas configurados para métricas clave
- Plan de respuesta a incidentes documentado
- Backups automáticos funcionando
- GDPR compliance completo
- Documentación legal completa y actualizada
- Sistema de escalado definido para cada umbral de crecimiento

**Archivos a crear (futuro):**
- `docs/riesgos/ANALISIS_RIESGOS.md` - Documento detallado de riesgos
- `docs/riesgos/PLAN_RESPUESTA_INCIDENTES.md` - Procedimientos de emergencia
- `docs/riesgos/MONITOREO_ALERTAS.md` - Configuración de alertas
- `docs/riesgos/BACKUP_RECOVERY.md` - Plan de backups y recuperación

**Relacionado con:** T125 (Security Rules), T126 (Rate Limiting), T127 (Sanitization), T135 (Cookies/GDPR), T136 (ATT iOS), T129 (Export GDPR), T148 (Diferenciación), T134 (Importación Email), T144 (Ciclo de vida planes)

**Nota:** Este análisis debe actualizarse periódicamente (trimestralmente) según el crecimiento de la app y la aparición de nuevos riesgos. Los riesgos críticos deben tener mitigaciones implementadas antes de alcanzar escala masiva.

---

### T150 - Definición de MVP y Roadmap de Lanzamiento
**Estado:** Pendiente (Estratégico)  
**Complejidad:** 🔴 Alta  
**Prioridad:** 🔴 Alta - Crítico para lanzamiento  
**Descripción:** Definir los elementos mínimos necesarios para la primera versión de la app (MVP) y establecer qué funcionalidades pueden esperar a versiones posteriores. Priorizar según valor para el usuario, esfuerzo de implementación, y diferenciadores competitivos.

**Contexto:**
Un MVP exitoso debe:
1. **Resolver el problema core** - Permitir planificar y gestionar viajes colaborativos
2. **Ser viable** - Funcional sin bugs críticos
3. **Ser lanzable** - Cumplir requisitos legales básicos (GDPR mínimo)
4. **Tener diferenciadores** - Al menos 1-2 features únicas
5. **Ser escalable** - Arquitectura que soporte crecimiento

No todo puede estar en la v1.0. Necesitamos ser selectivos y enfocarnos en lo esencial.

**Criterios de priorización:**

**Incluir en MVP si:**
- ✅ Es funcionalidad core del producto (sin esto, la app no tiene sentido)
- ✅ Es crítico para experiencia básica del usuario
- ✅ Es diferenciador competitivo inmediato
- ✅ Es requerimiento legal mínimo (GDPR básico)
- ✅ Es necesario para evitar bugs críticos o problemas de seguridad

**Postponer si:**
- ❌ Es "nice to have" pero no bloquea uso básico
- ❌ Requiere mucho esfuerzo vs valor aportado
- ❌ Depende de features que están en MVP pero puede mejorarse después
- ❌ Es optimización o refinamiento de features core
- ❌ Requiere integraciones complejas que pueden esperar

## MVP - VERSIÓN 1.0 (LANZAMIENTO INICIAL)

### CORE - Gestión Básica de Planes ✅

**1.1 - Crear y gestionar planes:**
- ✅ Crear plan (nombre, fechas, descripción, imagen) - **IMPLEMENTADO**
- ✅ Ver plan en dashboard
- ✅ Editar información básica del plan
- ✅ Eliminar plan (con confirmación)
- ✅ Sistema de participantes básico - **IMPLEMENTADO**

**1.2 - Estados básicos de plan:**
- ✅ Estados: Borrador, Planificando, Finalizado (básico) - **IMPLEMENTADO PARCIALMENTE**
- ⚠️ Estados avanzados (Confirmado, En Curso, Cancelado) - **POSTPONER a v1.1**

**1.3 - Invitaciones:**
- ✅ Invitar participantes por email - **IMPLEMENTADO**
- ⚠️ Sistema de notificaciones completo - **POSTPONER a v1.1** (email básico suficiente)

### CORE - Gestión de Eventos ✅

**2.1 - Crear y gestionar eventos:**
- ✅ Crear evento (título, fecha, hora, tipo, participantes) - **IMPLEMENTADO**
- ✅ Editar evento
- ✅ Eliminar evento
- ✅ Visualizar eventos en calendario - **IMPLEMENTADO**
- ✅ Sistema de tracks (participantes como columnas) - **IMPLEMENTADO**
- ✅ Validaciones básicas (T51) - **IMPLEMENTADO**

**2.2 - Campos de eventos:**
- ✅ Parte común/personal básica - **IMPLEMENTADO**
- ✅ Descripción, ubicación básica
- ⚠️ Formularios enriquecidos por tipo (T121) - **POSTPONER a v1.1**
- ⚠️ Conexión con proveedores - **POSTPONER a v1.2**

### CORE - Gestión de Alojamientos ✅

**3.1 - Crear y gestionar alojamientos:**
- ✅ Crear alojamiento (nombre, check-in, check-out, tipo) - **IMPLEMENTADO**
- ✅ Editar alojamiento
- ✅ Eliminar alojamiento
- ✅ Visualizar en calendario - **IMPLEMENTADO**
- ✅ Validaciones básicas (T51) - **IMPLEMENTADO**

**3.2 - Campos de alojamientos:**
- ✅ Parte común/personal básica - **IMPLEMENTADO**
- ⚠️ Habitaciones individuales (T130) - **POSTPONER a v1.1**
- ⚠️ Conexión con proveedores - **POSTPONER a v1.2**

### CORE - Autenticación y Usuarios ✅

**4.1 - Sistema de autenticación:**
- ✅ Registro con email/password - **IMPLEMENTADO**
- ✅ Login/logout - **IMPLEMENTADO**
- ✅ Recuperación de contraseña - **IMPLEMENTADO**
- ✅ Perfil básico de usuario - **IMPLEMENTADO**
- ✅ Username único (T137) - **IMPLEMENTADO**

**4.2 - Gestión de perfil:**
- ✅ Editar perfil básico
- ✅ Foto de perfil
- ⚠️ Export de datos GDPR (T129) - **POSTPONER a v1.1** (crítico para UE pero puede ser post-lanzamiento inmediato)

### SEGURIDAD Y ESTABILIDAD (Crítico) ✅

**5.1 - Seguridad básica:**
- ✅ Firestore Security Rules (T125) - **IMPLEMENTADO**
- ✅ Rate Limiting básico (T126) - **IMPLEMENTADO**
- ✅ Sanitización de inputs (T127) - **IMPLEMENTADO**
- ✅ Validación de formularios (T51) - **IMPLEMENTADO**
- ✅ `mounted` checks (T52) - **IMPLEMENTADO**
- ✅ LoggerService (T53) - **IMPLEMENTADO**

**5.2 - Cumplimiento legal mínimo:**
- ⚠️ Privacy Policy básica - **REQUERIDO para MVP**
- ⚠️ Terms of Service básicos - **REQUERIDO para MVP**
- ⚠️ Gestión de cookies web básica (T135) - **REQUERIDO para MVP si hay web**
- ⚠️ ATT iOS básico (T136) - **REQUERIDO para MVP iOS**
- ⚠️ Consentimiento GDPR básico - **REQUERIDO para MVP**

### DIFERENCIADORES COMPETITIVOS (MVP)

**6.1 - Importación desde Email (T134) - PRIORIDAD ALTA:**
- ⚠️ Parsing básico de emails de confirmación
- ⚠️ Crear eventos/alojamientos automáticamente
- **¿Incluir en MVP?** **SÍ** - Es diferenciador clave según T148

**6.2 - Exportación básica:**
- ⚠️ Exportar plan a PDF simple (T133 básico)
- ⚠️ Exportar a calendario externo .ics (T131 básico)
- **¿Incluir en MVP?** **SÍ** - Valor alto, esfuerzo medio

### UI/UX BÁSICO ✅

**7.1 - Interfaz básica:**
- ✅ Dashboard con planes - **IMPLEMENTADO**
- ✅ Calendario con eventos - **IMPLEMENTADO**
- ✅ Grid 17x13 (GUIA_UI.md) - **IMPLEMENTADO**
- ✅ Navegación básica
- ⚠️ Responsive design básico - **REQUERIDO**

**7.2 - Política de UI:**
- ✅ Usar Material Design directamente (sin wrappers innecesarios)
- ✅ AppColorScheme y AppTypography
- ⚠️ Temas claro/oscuro básico - **NICE TO HAVE, puede esperar**

### OFFLINE-FIRST (Básico) ✅

**8.1 - Funcionalidad offline:**
- ✅ Lectura offline básica (Firestore cache)
- ⚠️ Sincronización automática (T57, T60) - **POSTPONER a v1.1**
- ⚠️ Cola de sincronización - **POSTPONER a v1.1**

---

### T151 - Mejoras de Documentación Post-Release v1.0
**Estado:** Pendiente (Post-Lanzamiento)  
**Complejidad:** 🟡 Media  
**Prioridad:** 🟢 Baja - Post-release v1.0  
**Descripción:** Mejorar y ampliar la documentación del proyecto después del lanzamiento de la primera versión, añadiendo herramientas y guías que faciliten el mantenimiento, debugging y onboarding de nuevos desarrolladores.

**Contexto:**
Una vez completado el MVP y lanzada la v1.0, es el momento adecuado para documentar lo aprendido durante el desarrollo y añadir herramientas que faciliten el mantenimiento y crecimiento del proyecto.

**Mejoras propuestas:**

#### 1. CHANGELOG.md / Release Notes
- Historial centralizado de cambios por versión
- Agrupación por categorías (Features, Fixes, Breaking Changes)
- Links a commits y tareas relacionadas
- Formato estándar para releases

#### 2. TROUBLESHOOTING.md o FAQ
- Problemas comunes y sus soluciones
- Errores frecuentes durante desarrollo
- Problemas de sincronización Firestore
- Debugging de issues conocidos
- Preguntas frecuentes del equipo

#### 3. GLOSARIO.md
- Definición de términos técnicos del proyecto
- Conceptos del dominio: Plan, Evento, Track, Participation, etc.
- Abreviaciones y acrónimos
- Convenciones de nomenclatura

#### 4. Checklist de Sincronización Docs-Código
- Proceso para mantener documentación actualizada
- Checklist antes de marcar tareas como completadas
- Verificación de consistencia entre código y docs
- Herramientas o scripts de verificación (opcional)

**Opcional (si se considera necesario):**
- Diagramas visuales de arquitectura usando Mermaid
- Mejoras en la guía de onboarding rápida
- Documentación de APIs internas

**Criterios de aceptación:**
- ✅ CHANGELOG.md creado con formato estándar
- ✅ TROUBLESHOOTING.md con al menos 10 problemas comunes documentados
- ✅ GLOSARIO.md con términos principales definidos
- ✅ Checklist de sincronización añadido a CONTEXT.md o documento separado
- ✅ Documentación accesible desde README.md principal

**Cuándo implementar:**
- ⏸️ **Post-release v1.0** - Después de tener la primera versión estable en producción
- Permite documentar lecciones aprendidas durante el desarrollo inicial
- Facilita el mantenimiento y onboarding post-lanzamiento

---

## POSTPONER A v1.1 (Primera actualización - 2-3 meses)

### Mejoras Core

**9.1 - Estados completos de plan:**
- T109: Sistema completo de estados (Confirmado, En Curso, Cancelado)
- T120: Sistema de reconfirmación
- FLUJO_ESTADOS_PLAN.md completo

**9.2 - Notificaciones completas:**
- T105: Sistema completo de notificaciones (email, push, SMS)
- T110: Sistema de alarmas
- Notificaciones en tiempo real

**9.3 - Sincronización avanzada:**
- T57: Cola de sincronización
- T60: Sincronización en tiempo real
- T58: Resolución de conflictos

**9.4 - Formularios enriquecidos:**
- T121: Formularios específicos por tipo de evento
- Campos dinámicos según tipo
- Validaciones avanzadas

**9.5 - Alojamientos avanzados:**
- T130: Habitaciones individuales
- Gestión completa de check-in/check-out

**9.6 - GDPR completo:**
- T129: Export de datos personales completo
- Derecho al olvido completo
- Dashboard de privacidad para usuarios

---

## POSTPONER A v1.2 (Segunda actualización - 4-6 meses)

### Integraciones Externas

**10.1 - APIs de proveedores:**
- Integración con Iberia, Vueling (vuelos)
- Integración con Booking.com, Airbnb (alojamientos)
- Sincronización bidireccional
- Actualizaciones automáticas

**10.2 - Calendarios externos:**
- T131: Sincronización completa con Google Calendar, Outlook
- Importación/exportación .ics mejorada
- Sincronización bidireccional

**10.3 - Importación avanzada:**
- T134: Importación desde email mejorada (ML avanzado)
- OCR para PDFs adjuntos
- Reconocimiento de más proveedores

### Features Avanzadas

**10.4 - Presupuesto y pagos:**
- T101: Sistema de presupuesto completo
- T102: Sistema de pagos entre participantes
- División automática de costes
- Integración con Stripe/PayPal

**10.5 - Estadísticas y análisis:**
- T113: Estadísticas del plan
- Resúmenes finales
- Análisis de gastos
- Comparativas

---

## POSTPONER A v2.0+ (Futuro - 6-12 meses)

### Features de Valor Añadido

**11.1 - Recomendaciones inteligentes:**
- T146: Oráculo de Delfos (requiere T147 primero)
- T147: Sistema de valoraciones completo
- ML avanzado para recomendaciones

**11.2 - Social y comunidad:**
- Planes compartidos públicos
- T122: Sistema de plantillas completo
- Biblioteca de planes de la comunidad
- Perfiles públicos de usuarios

**11.3 - Exportación avanzada:**
- T133: Exportación profesional PDF/Email
- T145: Generación de álbum digital
- Múltiples formatos de exportación

**11.4 - Ciclo de vida completo:**
- T144: Gestión del ciclo de vida al finalizar plan
- Archivado automático
- Reducción de costes

**11.5 - Monetización:**
- T143: Sistema de patrocinios
- T132: Sistema de agencias de viajes
- Features premium

**11.6 - Features avanzadas:**
- T139: Encuestas estilo Doodle
- T140: Juegos multijugador
- T141: Notificaciones y Chat avanzado
- T142: Menú launcher
- T115: Sistema de fotos completo
- T114: Mapa completo del recorrido

---

## RESUMEN MVP v1.0

### ✅ INCLUIR (Must Have):

**Core:**
- ✅ Crear/gestionar planes, eventos, alojamientos (IMPLEMENTADO)
- ✅ Calendario con tracks (IMPLEMENTADO)
- ✅ Autenticación y usuarios (IMPLEMENTADO)
- ✅ Invitaciones básicas (IMPLEMENTADO)

**Seguridad:**
- ✅ Security Rules, Rate Limiting, Sanitización (IMPLEMENTADO)
- ✅ Validaciones de formularios (IMPLEMENTADO)

**Legal mínimo:**
- ⚠️ Privacy Policy básica
- ⚠️ Terms of Service básicos
- ⚠️ GDPR consent básico
- ⚠️ Cookies web (si hay web)
- ⚠️ ATT iOS (si hay iOS)

**Diferenciadores:**
- ⚠️ T134: Importación desde email (BÁSICA)
- ⚠️ T131: Exportación .ics básica
- ⚠️ T133: Exportación PDF básica

**UI/UX:**
- ✅ Interfaz básica funcional (IMPLEMENTADO)
- ⚠️ Responsive design

**Total estimado para MVP:** ~80% ya implementado, faltan principalmente:
- Legal (Privacy Policy, Terms, GDPR básico)
- Diferenciadores (T134, T131 básico, T133 básico)
- Polish final y testing

### ❌ POSTPONER (Can Wait):

**v1.1:**
- Estados completos de plan
- Notificaciones avanzadas
- Sincronización avanzada
- Formularios enriquecidos
- GDPR completo

**v1.2:**
- APIs de proveedores
- Presupuesto/pagos
- Integraciones avanzadas

**v2.0+:**
- Oráculo de Delfos
- Valoraciones
- Monetización
- Features sociales
- Features avanzadas

---

## CRITERIOS DE LANZAMIENTO v1.0

**Debe cumplir:**
1. ✅ Funcionalidad core completa y estable
2. ✅ Seguridad básica implementada
3. ✅ Sin bugs críticos conocidos
4. ✅ Legal mínimo (Privacy Policy, Terms, GDPR básico)
5. ⚠️ Al menos 1 diferenciador funcionando (T134 básico)
6. ⚠️ Testing básico de flujos principales
7. ⚠️ Documentación de usuario básica

**Puede lanzar sin:**
- ❌ Notificaciones push avanzadas
- ❌ Estados completos de plan
- ❌ Sincronización en tiempo real
- ❌ APIs de proveedores
- ❌ Presupuesto/pagos
- ❌ Oráculo de Delfos
- ❌ Monetización
- ❌ Features sociales

---

## ROADMAP SUGERIDO

**Fase 1 - MVP (v1.0) - 1-2 meses:**
1. Completar legal básico (Privacy Policy, Terms, GDPR consent)
2. Implementar T134 básico (importación email)
3. Implementar T131 básico (export .ics)
4. Implementar T133 básico (export PDF)
5. Testing exhaustivo de flujos core
6. Polish de UI/UX
7. Documentación básica
8. **LANZAMIENTO v1.0**

**Fase 2 - v1.1 (2-3 meses post-lanzamiento):**
1. T109: Estados completos
2. T105: Notificaciones avanzadas
3. T57, T60: Sincronización
4. T121: Formularios enriquecidos
5. T130: Habitaciones individuales
6. T129: GDPR completo
7. **LANZAMIENTO v1.1**

**Fase 3 - v1.2 (4-6 meses post-lanzamiento):**
1. APIs de proveedores (Iberia, Booking.com)
2. T101, T102: Presupuesto y pagos
3. T131: Calendarios externos completos
4. T134: Importación avanzada (ML)
5. **LANZAMIENTO v1.2**

**Fase 4 - v2.0 (6-12 meses post-lanzamiento):**
1. T147: Valoraciones
2. T146: Oráculo de Delfos
3. T143: Patrocinios
4. T132: Agencias de viajes
5. Features sociales y comunidad
6. **LANZAMIENTO v2.0**

---

**Criterios de aceptación para MVP:**
- ✅ Todas las funcionalidades core implementadas y estables
- ✅ Seguridad básica completa
- ✅ Legal mínimo implementado
- ⚠️ Al menos 1 diferenciador funcionando (T134 básico)
- ⚠️ Testing de flujos principales completado
- ⚠️ Sin bugs críticos conocidos
- ⚠️ Documentación básica disponible

**Archivos a crear (futuro):**
- `docs/roadmap/MVP_DEFINITION.md` - Definición detallada del MVP
- `docs/roadmap/ROADMAP_v1.0.md` - Roadmap de v1.0
- `docs/roadmap/ROADMAP_v1.1.md` - Roadmap de v1.1
- `docs/roadmap/ROADMAP_v2.0.md` - Roadmap de v2.0

**Relacionado con:** Todas las tareas del proyecto, T148 (Diferenciación), T149 (Riesgos), Estrategia de lanzamiento

**Nota:** Esta definición debe validarse con usuarios beta antes del lanzamiento final. El MVP debe ser "Minimum Lovable Product" - no solo viable, sino que los usuarios lo amen lo suficiente para seguir usándolo y recomendarlo.

---

### T130 - Habitaciones Individuales en Modal de Alojamientos
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar la funcionalidad para gestionar habitaciones individuales por participante en el modal de alojamientos, siguiendo el patrón Parte Común/Parte Personal.

**Funcionalidades:**
1. Checkbox "Configurar habitaciones individuales"
2. Formulario por participante que incluye:
   - Número de habitación (ej: "203", "Suite 501")
   - Tipo de cama (individual, matrimonio, litera)
   - Preferencias personales (piso alto, vista al mar, sin ruido, etc.)
   - Notas personales del alojamiento
3. Cargar habitaciones existentes al editar alojamiento
4. Validar que cada participante tenga habitación asignada (si se habilita la opción)
5. Persistencia en `AccommodationPersonalPart`

**Criterios de aceptación:**
- Checkbox para habilitar habitaciones individuales
- Formulario visible cuando hay múltiples participantes seleccionados
- Campos por participante funcionando
- Guardar en estructura `personalParts` de Accommodation
- Cargar datos existentes al editar
- Validar que todas las habitaciones estén asignadas
- Testing con varios participantes

**Archivos a modificar:**
- `lib/widgets/wd_accommodation_dialog.dart`
- `lib/features/calendar/domain/models/accommodation.dart` (ya soporta estructura)

**Relacionado con:** T121 (Formularios enriquecidos), docs/flujos/FLUJO_CRUD_ALOJAMIENTOS.md, docs/guias/GUIA_PATRON_COMUN_PERSONAL.md

---

### T131 - Sincronización con Calendarios Externos
**Estado:** Pendiente  
**Complejidad:** 🔴 Alta  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar funcionalidad para sincronizar eventos del plan con calendarios externos (Google Calendar, Outlook, iCloud, etc.) mediante exportación/importación de archivos .ics (iCalendar).

**Funcionalidades:**
1. **Exportación de eventos:**
   - Botón "Exportar calendario" en vista del plan
   - Generar archivo .ics con eventos del plan
   - Incluir información: título, descripción, fechas, ubicación, participantes
   - Guardar como archivo descargable o compartir

2. **Importación de eventos:**
   - Botón "Importar desde calendario" 
   - Seleccionar archivo .ics local
   - Parsear eventos del archivo
   - Mapear a estructura de Event del plan
   - Preview antes de importar

3. **Sincronización bidireccional (futura):**
   - Conectar con APIs de Google Calendar, Outlook
   - Sincronización automática periódica
   - Resolución de conflictos (última modificación gana)
   - Filtros configurable por usuario (qué eventos sincronizar)

**Criterios de aceptación:**
- Exportar eventos del plan a archivo .ics funcional
- Archivo .ics se puede abrir en Google Calendar, Outlook, Apple Calendar
- Importar eventos desde archivo .ics básico funciona
- Preview de eventos antes de importar
- Manejo de errores en archivos .ics inválidos
- Información completa de eventos en exportación

**Archivos a modificar/crear:**
- `lib/features/calendar/domain/services/ical_export_service.dart` (nuevo)
- `lib/features/calendar/domain/services/ical_import_service.dart` (nuevo)
- `lib/features/calendar/presentation/widgets/export_calendar_button.dart` (nuevo)
- `lib/features/calendar/presentation/widgets/import_calendar_dialog.dart` (nuevo)
- Añadir paquete `icalendar` a `pubspec.yaml`

**Notas técnicas:**
- Usar paquete `icalendar: ^3.0.0` para parser/generator .ics
- Formato estándar RFC 5545 (iCalendar)
- Exportar solo eventos de la perspectiva del usuario actual
- Filtrar eventos personales vs comunes según configuración
- Integrar con selector de archivos: `file_picker` package

**Relacionado con:** docs/arquitectura/ARCHITECTURE_DECISIONS.md (Integración con Calendarios Externos), docs/flujos/FLUJO_CRUD_EVENTOS.md (Importación de eventos), T147 (Sistema de Valoraciones)

**Dependencia:** T147 (Sistema de Valoraciones) debe implementarse antes de T146 (Oráculo de Delfos), según los flujos definidos.

**Análisis de estrategia:**
- **Ventajas:** Aumenta valor para el usuario, permite ver planes en calendario principal, estándar esperado por usuarios, no necesariamente reduce engagement con la app
- **Riesgos:** Posible reducción de frecuencia de uso de la app si todo está en calendario externo
- **Recomendación:** Implementar exportación .ics primero (bajo riesgo, alto valor). Evaluar sincronización bidireccional según feedback de usuarios y métricas de uso

**Nota:** Al implementar, actualizar los flujos necesarios (`FLUJO_CRUD_EVENTOS.md`, `FLUJO_CRUD_PLANES.md`) para incluir pasos de exportación/importación de calendarios externos.

---

### T132 - Definición: Sistema de Agencias de Viajes
**Estado:** Pendiente  
**Complejidad:** 🔴 Alta  
**Prioridad:** 🟡 Media-Baja  
**Descripción:** Definir y diseñar el sistema completo para que agencias de viajes puedan crear, gestionar y vender planes organizados a sus clientes (ejemplo: Viajes El Corte Inglés).

**Objetivo:** Habilitar agencias de viajes para:
- Crear planes base (plantillas reutilizables o planes específicos)
- Gestionar múltiples planes simultáneamente
- Asignar clientes a planes
- Personalizar planes por cliente
- Ofrecer planes en un catálogo/marketplace

**Aspectos a Definir:**

#### 1. Modelo de Negocio
- [ ] **Monetización (Fuente de ingresos):** 
  - ✅ **Cuota por cargar planes:** Agencias pagan una cuota (mensual/anual o pay-per-plan) para poder cargar planes directamente en la app para sus clientes
  - [ ] Modelo de pago: ¿Suscripción agencia? ¿Pay-per-plan? ¿Gratis inicial con límites?
  - [ ] Estructura de precios: ¿Cuota fija? ¿Por número de planes? ¿Por número de clientes?
- [ ] **Límites:** ¿Número de planes/participantes por agencia según plan de pago?
- [ ] **Facturación:** ¿Integración con sistemas de facturación?

#### 2. Roles y Permisos
- [ ] **Nuevo rol:** `Agency` (Agencia de Viajes) - usuario propietario de la agencia
- [ ] **Nuevo rol:** `AgencyStaff` (Empleado de Agencia) - empleados que gestionan planes
- [ ] **Rol cliente:** ¿Customer vs Participant? ¿Diferente configuración?
- [ ] **Permisos agencia:** ¿Pueden editar eventos después de confirmar clientes?
- [ ] **Permisos personalización:** ¿Qué puede personalizar el cliente?

#### 3. Gestión de Planes
- [ ] **Tipo de planes:**
  - ¿Plantillas reutilizables (ej: "Roma 5 días")?
  - ¿Planes únicos por cada viaje?
  - ¿Combinación de ambos?
- [ ] **Visibilidad:** ¿Públicos en marketplace? ¿Solo por código? ¿Privados por invitación?
- [ ] **Capacidad:** ¿Límite de participantes por plan?
- [ ] **Duración:** ¿Planes de días fijos o flexibles?

#### 4. Marketplace/Catálogo
- [ ] **Catálogo:** ¿Lista de planes disponibles para clientes?
- [ ] **Filtros:** Destino, precio, fechas, duración, tipo
- [ ] **Búsqueda:** Por palabras clave, tags, categorías
- [ ] **Perfil agencia:** Logo, descripción, reseñas, calificaciones
- [ ] **Proceso unión:** ¿Cómo se unen clientes a un plan?

#### 5. Personalización por Cliente
- [ ] **Habitaciones:** ¿Asignación individual automática?
- [ ] **Menús:** ¿Preferencias alimentarias por cliente?
- [ ] **Documentos:** ¿Pasaportes, visas, documentos de viaje?
- [ ] **Pagos:** ¿Integración con sistema de pagos?
- [ ] **Checklist:** ¿Lista de tareas previas al viaje?

#### 6. Funcionalidades Técnicas
- [ ] **Multi-plan management:** Dashboard para agencias con todos sus planes
- [ ] **Clonación:** ¿Copiar plantilla y personalizar?
- [ ] **Asignación masiva:** ¿Invitar múltiples clientes a la vez?
- [ ] **Notificaciones:** ¿Al cliente cuando se le asigna habitación, se modifica evento, etc.?
- [ ] **Reportes:** ¿Estadísticas de planes, clientes, popularidad?

#### 7. Modelo de Datos
- [ ] **PlanAgency:** Tabla de relación agencia-plan
- [ ] **AgencyTemplate:** Plantillas de planes reutilizables
- [ ] **AgencyMetadata:** Información de la agencia (logo, descripción, contacto)
- [ ] **CustomerAssignment:** Relación cliente-plan (con datos personalizados)

**Preguntas Clave a Resolver:**

1. **¿Las agencias necesitan una cuenta "Agencia" o pueden ser usuarios normales con planes especiales?**
2. **¿Un plan puede ser "base" de agencia y luego copiarse para clientes individuales?**
3. **¿Los clientes ven todos los participantes del viaje o solo los de su grupo?**
4. **¿Los clientes pueden modificar eventos después de unirse al plan?**
5. **¿Cómo se maneja la facturación? ¿Integración con sistemas externos?**
6. **¿Necesitamos marketplace público o solo listado privado por agencia?**
7. **¿Qué información de clientes ve la agencia? (RGPD/GDPR)**
8. **¿Los clientes pueden "compartir" el plan con familiares sin ser parte oficial?**

**Documentación a Crear:**
- `docs/flujos/FLUJO_GESTION_AGENCIAS.md` - Proceso completo de agencias
- `docs/flujos/FLUJO_CRUD_TEMPLATES_PLANES.md` - Gestión de plantillas
- `docs/guias/GUIA_MODELO_NEGOCIO_AGENCIAS.md` - Modelo de negocio
- Actualizar `lib/shared/models/user_role.dart` con nuevos roles
- Actualizar `lib/features/calendar/domain/models/plan.dart` con campos de agencia

**Criterios de Aceptación (Definición):**
- Documento completo con todas las decisiones tomadas
- Diagramas de flujo para cada proceso
- Modelo de datos definido
- Casos de uso detallados
- Prototipo de UI/Wireframes
- Plan de implementación por fases

**Fases Sugeridas (para implementación futura):**

**Fase 1 - Fundamentos:**
- Roles Agency y AgencyStaff
- Tipos de planes (templates vs individuales)
- Asignación básica cliente-plan

**Fase 2 - Gestión:**
- Dashboard de agencia
- Catálogo/Listado de planes
- Proceso de unión cliente-plan

**Fase 3 - Personalización:**
- Habitaciones individuales por cliente
- Preferencias personalizadas
- Documentos de viaje

**Fase 4 - Marketplace (si aplica):**
- Catálogo público
- Búsqueda y filtros
- Perfil de agencia

**Relacionado con:** 
- T130 (Habitaciones individuales)
- T131 (Sincronización calendarios externos)
- docs/flujos/FLUJO_CRUD_PLANES.md (gestión de planes)
- docs/flujos/FLUJO_CRUD_USUARIOS.md (gestión de usuarios)

---

### T134 - Importar desde Email: crear eventos/alojamientos desde correos de confirmación
**Estado:** Pendiente  
**Complejidad:** 🟡 Media-Alta  
**Prioridad:** 🟡 Media  
**Descripción:** Permitir utilizar la información de correos electrónicos de confirmación de proveedores (p. ej., aerolíneas, trenes, hoteles, restaurantes) para pre-crear eventos o alojamientos dentro de un plan.

**Alcance MVP:**
1. Detección de proveedor a partir del contenido del email (texto/HTML copiado o .eml básico)
2. Parsers por plantilla para 3 proveedores iniciales:
   - Iberia (vuelos): fecha/hora salida y llegada, origen/destino, gate, localizadores, asiento si existe
   - Renfe (trenes): fecha/hora, origen/destino, coche/asiento, localizador
   - Booking.com (alojamientos): nombre hotel, dirección, check-in/check-out, número de reserva
3. Mapeo a modelos:
   - Evento (Desplazamiento → Avión/Tren) con Parte Común rellenada y campos personales básicos
   - Alojamiento con `AccommodationCommonPart` (nombre, fechas, dirección) y notas
4. UI de previsualización/edición antes de crear registros

**Flujo de Usuario:**
```
Plan → "Importar desde Email" → Pegar contenido del correo o adjuntar .eml
  ↓
Detectar proveedor y plantilla
  ↓
Extraer campos → Mostrar Previsualización (evento/alojamiento sugerido)
  ↓
Editar/CORREGIR campos si es necesario
  ↓
Crear Evento/Alojamiento en el plan
```

**Criterios de Aceptación:**
- Detección automática de al menos 3 proveedores (Iberia, Renfe, Booking) en casos reales de prueba
- Extracción correcta de fechas, horas, lugares/direcciones y localizadores
- Mapeo correcto a `Event` (tipo/subtipo) o `Accommodation` (parte común)
- Previsualización con posibilidad de edición antes de guardar
- Manejo de errores y feedback claro cuando el email no se reconoce
- Logs sin datos sensibles; no almacenar el cuerpo completo del email

**Entradas Soportadas (MVP):**
- Pegar texto/HTML del email en un campo
- Subir archivo `.eml` simple (si es viable con web); en caso contrario, solo pegar contenido

**Archivos a crear:**
- `lib/features/import/services/email_parse_service.dart`
- `lib/features/import/providers/email_import_provider.dart`
- `lib/widgets/import/wd_email_import_dialog.dart`
- `docs/flujos/FLUJO_IMPORTACION_DESDE_EMAIL.md`

**Notas Técnicas:**
- Parsers deterministas por patrones (regex/plantillas) en MVP; evaluar NLP más adelante
- Normalizar timezones a IANA; convertir a UTC en almacenamiento si aplica
- Sanitizar HTML; evitar ejecutar contenido incrustado
- Internacionalización: plantillas EN/ES comunes de proveedores

**Relacionado con:** T121 (Form fields), T131 (.ics externo), `FLUJO_CRUD_EVENTOS`, `FLUJO_CRUD_ALOJAMIENTOS`, `GUIA_PATRON_COMUN_PERSONAL`

---

### T135 - Gestión de Cookies en Web (GDPR Compliance)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar sistema completo de gestión de cookies para cumplimiento GDPR y normativas de cookies en la versión web de la aplicación.

**Funcionalidades:**
1. **Modal de consentimiento de cookies:**
   - Aparece en primera visita a la web
   - Información clara sobre tipos de cookies usadas
   - Botones: "Rechazar", "Aceptar", "Personalizar"
   - Link a política de cookies completa
   
2. **Panel de gestión de cookies:**
   - Ver todas las cookies activas
   - Categorías: Necesarias, Analytics, Marketing (si se usan)
   - Activar/desactivar por categoría
   - Guardar preferencias del usuario
   
3. **Persistencia de preferencias:**
   - Guardar consentimiento en localStorage (web)
   - Respetar preferencias en futuras visitas
   - Permitir cambiar preferencias en cualquier momento
   
4. **Respeto de preferencias:**
   - No cargar cookies de analytics si se rechazan
   - Deshabilitar tracking si usuario rechaza
   - Mantener solo cookies estrictamente necesarias

**Criterios de aceptación:**
- Modal aparece en primera visita
- Usuario puede aceptar/rechazar cookies
- Preferencias se guardan y respetan
- Panel de gestión accesible desde configuración
- Solo cookies necesarias si usuario rechaza
- Documentación de cookies usadas

**Archivos a crear:**
- `lib/features/consent/services/cookie_consent_service.dart`
- `lib/features/consent/widgets/wd_cookie_consent_modal.dart`
- `lib/features/consent/widgets/wd_cookie_settings_panel.dart`
- `docs/legal/cookie_policy.md` (contenido completo)

**Cookies a gestionar:**
- **Necesarias (siempre activas):**
  - Sesión de usuario (Firebase Auth)
  - Preferencias de idioma
  - Estado de consentimiento
  
- **Analytics (opcionales):**
  - Firebase Analytics
  - Google Analytics (si se usa)
  
- **Marketing (opcionales - futuro):**
  - Tracking de conversiones (si se implementa)
  - Cookies de terceros (si se usan)

**Relacionado con:** T50 (Configuración), `GUIA_ASPECTOS_LEGALES.md` (sección 4), GDPR compliance

---

### T136 - App Tracking Transparency en iOS (Privacy Compliance)
**Estado:** Pendiente  
**Complejidad:** ⚠️ Baja  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar App Tracking Transparency (ATT) en iOS para cumplir con requisitos de privacidad de Apple iOS 14.5+ y respetar la preferencia "Ask App Not to Track".

**Funcionalidades:**
1. **Solicitud de permisos de tracking:**
   - Mostrar diálogo nativo de iOS al iniciar app (si es necesario)
   - Mensaje explicativo en `Info.plist`
   - Solicitud solo si la app necesita tracking (IDFA o tracking de terceros)
   
2. **Respeto de preferencia "No rastrear":**
   - Detectar si usuario tiene "No rastrear" activado en iOS
   - No solicitar permisos si está activado
   - Deshabilitar cualquier tracking de terceros si se rechaza
   
3. **Gestión de tracking opcional:**
   - Si no se necesita tracking, no solicitar permisos
   - Solo solicitar si realmente se usa tracking para analytics/ads
   - Respetar siempre la decisión del usuario

**Criterios de aceptación:**
- `NSUserTrackingUsageDescription` añadido en `Info.plist`
- Diálogo nativo de ATT funcional (si se necesita tracking)
- Respeto de "Ask App Not to Track" del sistema
- No tracking si usuario rechaza
- Testing en iOS real con diferentes estados

**Archivos a modificar:**
- `ios/Runner/Info.plist` - Añadir `NSUserTrackingUsageDescription`
- `lib/features/consent/services/tracking_consent_service.dart` (nuevo) - Lógica de tracking
- Verificar si se necesita paquete específico para ATT

**Configuración Info.plist:**
```xml
<key>NSUserTrackingUsageDescription</key>
<string>Esta app usa información para mejorar tu experiencia y personalizar el contenido. Tu privacidad es importante para nosotros.</string>
```

**Nota importante:**
- Solo solicitar tracking si realmente es necesario (analytics, ads personalizados)
- Si Firebase Analytics funciona sin IDFA, puede no ser necesario
- Respetar siempre la preferencia del usuario
- No penalizar funcionalidad si se rechaza tracking

**Relacionado con:** T135 (Gestión de cookies), `GUIA_ASPECTOS_LEGALES.md`, Apple Privacy Guidelines

---

### T133 - Exportación Profesional de Planes (PDF/Email)
**Estado:** Pendiente  
**Complejidad:** 🟡 Media  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar funcionalidad para exportar un plan completo a PDF o enviarlo por email con formato profesional, estético e informativo, incluyendo fotos, itinerario, información de sitios y datos de participantes.

**Objetivo:** Permitir a usuarios exportar/enviar planes de forma profesional a:
- Participantes del plan
- Clientes (cuando esté implementado sistema de agencias)
- Observadores
- Contactos externos

**Aspectos a Definir/Implementar:**

#### 1. Formato de Exportación
- [ ] **PDF:** Generar PDF descargable con diseño profesional
- [ ] **Email HTML:** Enviar por email con HTML responsive
- [ ] **Ambas:** ¿Permitir elegir formato?
- [ ] **Multi-idioma:** PDF/Email en idioma del destinatario

#### 2. Contenido Incluido
- [ ] **Portada:**
  - Foto del plan (si existe)
  - Nombre del plan
  - Fechas (inicio-fin)
  - Organizador
  - Logo de la app
- [ ] **Itinerario:**
  - Lista cronológica de eventos
  - Fechas y horas (en timezone del plan)
  - Descripciones
  - Ubicaciones (mapas opcionales)
- [ ] **Alojamientos:**
  - Hoteles/Apartamentos reservados
  - Fechas check-in/check-out
  - Información de reserva
  - Fotos (si disponibles)
- [ ] **Participantes:**
  - Lista de participantes confirmados
  - Rol de cada uno (Admin, Participante, Observador)
  - Info de contacto (configurable por privacidad)
- [ ] **Información Adicional:**
  - Presupuesto (total y por categoría)
  - Timezone del plan
  - Estado del plan (Confirmado, En curso, etc.)
  - Notas generales
- [ ] **Mapa/Itinerario Visual:**
  - Timeline visual de días
  - Indicadores de ubicaciones importantes
  - Conexiones entre eventos

#### 3. Información Externa de Sitios
- [ ] **Integración APIs:**
  - Google Places API (fotos, descripciones, ratings)
  - Wikipedia/Wikimedia (descripciones culturales/históricas)
  - OpenWeatherMap (clima estimado)
- [ ] **Contenido añadido:**
  - Fotos de ubicaciones visitadas
  - Descripciones breves de lugares
  - Información útil (horarios museos, precio entradas, etc.)
  - Datos culturales, históricos, curiosidades
- [ ] **Configuración:**
  - ¿Qué información mostrar?
  - Lenguaje del contenido
  - Profundidad de detalles

#### 4. Diseño y Personalización
- [ ] **Plantillas:**
  - Plantilla "Clásica" (elegante, formal)
  - Plantilla "Moderno" (colorida, casual)
  - Plantilla "Minimalista" (limpia, profesional)
- [ ] **Elementos de marca:**
  - Logo del usuario/organizador (opcional)
  - Colores personalizados del plan
  - Fuentes elegantes
- [ ] **QR Code:**
  - Generar QR para acceder al plan en la app
  - Link compartible (con/sin login)
- [ ] **Watermark (opcional):**
  - Marca de agua de la app
  - "Generado con UNP Calendario"

#### 5. Privacidad y Configuración
- [ ] **Qué incluir:**
  - Checkboxes para seleccionar secciones
  - ¿Incluir contactos de participantes?
  - ¿Incluir información personal de eventos?
  - ¿Incluir presupuesto detallado?
- [ ] **Destinatarios:**
  - Email individual
  - Múltiples emails
  - Solo generar PDF sin enviar
- [ ] **Seguridad:**
  - ¿Expiracion temporal del PDF compartido?
  - ¿Proteger PDF con contraseña?
  - ¿Tracking de descargas?

#### 6. Funcionalidades Técnicas
- [ ] **Generación PDF:**
  - Usar paquete `pdf: ^3.10.0` o similar
  - Layout responsivo en PDF
  - Soporte para imágenes
  - Hipervínculos en PDF
- [ ] **Envío Email:**
  - Integrar con backend de email (SMTP/API)
  - Asunto personalizable
  - Email template HTML
  - Tracking de envío/lectura
- [ ] **Caché:**
  - Caché de información externa (Places, Wikipedia)
  - Re-generar solo si plan ha cambiado
  - Expiración de caché (ej: 24h)

**Casos de Uso:**

**Caso 1 - Organizador → Participantes:**
```
Organizador crea plan "Vacaciones Roma 2025"
→ Exporta a PDF
→ Comparte PDF con participantes antes del viaje
→ Incluye: itinerario, alojamientos, información de sitios
```

**Caso 2 - Agencia de Viajes → Cliente:**
```
Agencia crea plan "Tour Bali Premium"
→ Exporta a PDF profesional
→ Envía por email al cliente con propuesta
→ Incluye: itinerario completo, fotos, precio total
```

**Caso 3 - Invitación Formal:**
```
Organizador quiere invitar a alguien a unirse al plan
→ Genera PDF con información del plan
→ Envía por email como "invitación"
→ El destinatario puede unirse desde el PDF
```

**Criterios de Aceptación:**
- Botón "Exportar Plan" en página de detalles del plan
- Opciones: PDF o Email
- Configuración de qué incluir
- Preview antes de enviar
- PDF generado visualmente atractivo y profesional
- Email HTML responsive para todos los clientes de email
- Información completa y sin errores
- Funciona offline (sin APIs externas si no hay conexión)

**Archivos a Crear/Modificar:**
- `lib/features/calendar/domain/services/plan_export_service.dart` (nuevo)
- `lib/features/calendar/presentation/widgets/export_plan_button.dart` (nuevo)
- `lib/features/calendar/presentation/widgets/export_plan_dialog.dart` (nuevo)
- `lib/features/calendar/presentation/widgets/export_preview_dialog.dart` (nuevo)
- Añadir paquetes: `pdf: ^3.10.0`, `image_picker` (ya existe), `google_maps_flutter` (opcional)

**Secciones del PDF/Email Sugeridas:**

1. **Portada** (1 página)
   - Foto plan + nombre + fechas
   
2. **Itinerario Día a Día** (N páginas)
   - Día 1: Eventos del día con fotos y descripciones
   - Día 2: ...
   
3. **Información de Alojamientos** (1-2 páginas)
   - Lista de hoteles con fotos y detalles
   
4. **Participantes** (1 página)
   - Lista de participantes confirmados
   
5. **Información Adicional** (1 página)
   - Presupuesto, timezones, notas

**Preguntas Clave:**
1. ¿Qué tipos de información externa debemos incluir? ¿Solo básico (fotos, descripciones) o también datos en tiempo real (clima)?
2. ¿El PDF debe incluir mapa visual del itinerario o solo texto?
3. ¿Permitir personalizar colores/fuentes o usar plantillas fijas?
4. ¿Necesitamos integración con APIs externas (Places, Wikipedia) o usar solo datos del plan?
5. ¿El email es solo para invitación o también para share del PDF generado?
6. ¿Límite de tamaño del PDF? ¿Comprimir imágenes?
7. ¿Tracking de quién descargó/abrió el PDF?

**Relacionado con:**
- T131 (Sincronización calendarios externos)
- T132 (Sistema de agencias)
- docs/flujos/FLUJO_CRUD_PLANES.md (vista del plan)
- docs/guias/GUIA_UI.md (diseño visual)

---

## 📦 GRUPO MIGRACIÓN: MAC/IOS

### **GRUPO MIGRACIÓN: MIGRACIÓN A MAC/IOS** 🍎
**Objetivo:** Migrar el proyecto completo a Mac con iOS y configurar entorno de desarrollo  
**Tareas:** T154 → T155 → T156  
**Duración estimada:** 1-2 días  
**Resultado:** Proyecto funcionando en Mac, Firebase CLI instalado, índices actualizados

**Testing del Grupo:**
- ✅ Proyecto compila en Mac
- ✅ App funciona en iOS Simulator
- ✅ Firebase CLI instalado y funcionando
- ✅ Índices de Firestore actualizados
- ✅ Todas las funcionalidades probadas

---

### T154 - Migración del Proyecto a Mac/iOS
**Estado:** Pendiente  
**Complejidad:** ⚠️ Alta  
**Prioridad:** 🟡 Media (Programada para ~2 meses)  
**Descripción:** Migrar todo el proyecto Planazoo desde Windows a Mac, configurar entorno de desarrollo completo (Cursor, Flutter, Firebase, GitHub), habilitar compilación para Web/Android/iOS, y verificar que todo funciona correctamente.

**Contexto:**
- Actualmente el proyecto está en Windows
- Se migrará a Mac para desarrollo iOS y mejor integración con Flutter
- Esta migración está programada para realizarse en aproximadamente 2 meses
- Durante la migración se aprovechará para instalar Firebase CLI y actualizar índices (T155, T156)
- Se quiere mantener toda la configuración de Cursor y chats de IA si es posible
- **IMPORTANTE:** Después de completar la migración, el usuario quiere empezar a trabajar en la implementación de Offline First (Tareas T56-T62). El entorno debe estar preparado para este desarrollo.

**Funcionalidades:**
1. Instalar y configurar Cursor IDE
2. Conectar proyecto con GitHub
3. Configurar IA de Cursor y mantener chats
4. Instalar Flutter SDK y configurar para Web/Android/iOS
5. Configurar Xcode para iOS
6. Configurar Android Studio/SDK para Android
7. Migrar código fuente del proyecto
8. Instalar dependencias y actualizaciones
9. Configurar Firebase
10. Verificar compilación en todas las plataformas
11. Optimizar configuración de Cursor
12. **Configurar acceso remoto al Mac desde Windows** (para desarrollo remoto)
13. **Preparar entorno para desarrollo Offline First (T56-T62)**

**Criterios de aceptación:**
- ✅ Cursor IDE instalado (última versión) y configurado
- ✅ Proyecto conectado a GitHub
- ✅ IA de Cursor configurada y funcionando
- ✅ Chats de IA migrados/mantenidos (si es posible)
- ✅ Flutter SDK instalado y configurado
- ✅ Compilación para Web funcionando
- ✅ Compilación para Android funcionando
- ✅ Compilación para iOS funcionando
- ✅ Xcode instalado y configurado
- ✅ Android Studio/SDK instalado y configurado
- ✅ Proyecto compila sin errores en todas las plataformas
- ✅ App funciona en iOS Simulator
- ✅ App funciona en Android Emulator
- ✅ App funciona en navegador web
- ✅ Todas las funcionalidades principales probadas
- ✅ Firebase configurado correctamente
- ✅ Cursor optimizado para el proyecto
- ✅ **Acceso remoto al Mac configurado desde Windows**
- ✅ **Conexión remota verificada y funcionando**
- ✅ **Entorno preparado para desarrollo Offline First (T56-T62)**
- ✅ **Métodos de simulación offline documentados**
- ✅ **Dependencias para offline verificadas (SQLite/Hive)**
- ✅ Documentación actualizada si hubo cambios

---

## 📋 Checklist Completo de Migración

### **FASE 1: Instalación de Cursor IDE y Configuración**

- [ ] Descargar Cursor IDE desde [cursor.sh](https://cursor.sh/) (última versión disponible)
- [ ] Instalar Cursor en Mac
- [ ] Abrir Cursor y completar configuración inicial
- [ ] Instalar extensiones recomendadas para Flutter/Dart:
  - [ ] Dart (Dart Code)
  - [ ] Flutter (Flutter extension)
  - [ ] Firebase (Firebase extension si existe)
  - [ ] GitLens (para mejor integración con GitHub)
  - [ ] Error Lens (para ver errores en línea)
  - [ ] Bracket Pair Colorizer (mejor visualización)
  - [ ] Material Icon Theme (iconos)
- [ ] Configurar preferencias de Cursor:
  - [ ] Configurar tema (light/dark según preferencia)
  - [ ] Configurar fuente y tamaño
  - [ ] Configurar atajos de teclado
  - [ ] Configurar autocompletado
  - [ ] Configurar formato automático
  - [ ] Configurar linting
- [ ] Intentar migrar/restaurar chats de IA:
  - [ ] Verificar si Cursor guarda chats en archivos locales
  - [ ] Copiar archivos de configuración de Cursor desde Windows si es posible
  - [ ] Si no es posible, documentar conversaciones importantes antes de migrar
- [ ] Configurar cuenta de Cursor (si aplica)
- [ ] Verificar que la IA de Cursor funciona correctamente

---

### **FASE 2: Configuración de Git y GitHub**

- [ ] Instalar Git (si no está instalado): `git --version`
- [ ] Configurar Git con tu nombre y email:
  ```bash
  git config --global user.name "Tu Nombre"
  git config --global user.email "tu@email.com"
  ```
- [ ] Configurar SSH keys para GitHub (si no tienes):
  ```bash
  ssh-keygen -t ed25519 -C "tu@email.com"
  ```
- [ ] Agregar SSH key a GitHub (copiar desde `~/.ssh/id_ed25519.pub`)
- [ ] Verificar conexión: `ssh -T git@github.com`
- [ ] Clonar repositorio del proyecto:
  ```bash
  cd ~/Documents  # o donde prefieras
  git clone git@github.com:tu-usuario/unp_calendario.git
  cd unp_calendario
  ```
- [ ] Verificar que el repositorio está conectado correctamente
- [ ] Abrir proyecto en Cursor: `cursor .` (desde el directorio del proyecto)
- [ ] Verificar que Cursor detecta el repositorio Git
- [ ] Configurar Git en Cursor (integración de GitLens)

---

### **FASE 3: Instalación de Flutter SDK**

- [ ] Descargar Flutter SDK desde [flutter.dev](https://flutter.dev/docs/get-started/install/macos)
- [ ] Extraer Flutter a una ubicación permanente (ej: `~/development/flutter`)
- [ ] Agregar Flutter al PATH:
  ```bash
  # Agregar a ~/.zshrc o ~/.bash_profile
  export PATH="$PATH:$HOME/development/flutter/bin"
  ```
- [ ] Recargar terminal: `source ~/.zshrc` (o reiniciar terminal)
- [ ] Verificar instalación: `flutter --version`
- [ ] Ejecutar `flutter doctor` y revisar estado
- [ ] Instalar dependencias faltantes según `flutter doctor`:
  - [ ] Xcode (se instala en FASE 4)
  - [ ] Android Studio (se instala en FASE 5)
  - [ ] CocoaPods (para iOS): `sudo gem install cocoapods`
  - [ ] Cualquier otra dependencia que indique `flutter doctor`

---

### **FASE 4: Configuración de iOS (Xcode)**

- [ ] Descargar Xcode desde App Store (última versión)
- [ ] Instalar Xcode (puede tardar bastante tiempo)
- [ ] Abrir Xcode y aceptar términos de licencia
- [ ] Instalar componentes adicionales de Xcode:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```
- [ ] Instalar CocoaPods (si no se instaló antes):
  ```bash
  sudo gem install cocoapods
  ```
- [ ] Verificar que Xcode está configurado: `flutter doctor`
- [ ] Crear cuenta de desarrollador Apple (si no la tienes):
  - [ ] Ir a [developer.apple.com](https://developer.apple.com)
  - [ ] Crear cuenta (gratuita para desarrollo básico)
- [ ] Configurar certificados y perfiles (si es necesario para dispositivo físico)

---

### **FASE 5: Configuración de Android**

- [ ] Descargar Android Studio desde [developer.android.com](https://developer.android.com/studio)
- [ ] Instalar Android Studio
- [ ] Abrir Android Studio y completar setup wizard
- [ ] Instalar Android SDK:
  - [ ] SDK Platform (última versión estable)
  - [ ] Android SDK Build-Tools
  - [ ] Android SDK Command-line Tools
  - [ ] Android Emulator
- [ ] Configurar variables de entorno Android:
  ```bash
  # Agregar a ~/.zshrc
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/platform-tools
  export PATH=$PATH:$ANDROID_HOME/tools
  export PATH=$PATH:$ANDROID_HOME/tools/bin
  ```
- [ ] Recargar terminal: `source ~/.zshrc`
- [ ] Crear un AVD (Android Virtual Device) para testing
- [ ] Verificar que Android está configurado: `flutter doctor`
- [ ] Aceptar licencias de Android:
  ```bash
  flutter doctor --android-licenses
  ```

---

### **FASE 6: Configuración de Flutter para Web**

- [ ] Habilitar soporte web en Flutter:
  ```bash
  flutter config --enable-web
  ```
- [ ] Verificar que web está habilitado: `flutter devices`
- [ ] Instalar Chrome/Chromium (si no está instalado) para testing
- [ ] Verificar que Flutter puede compilar para web: `flutter doctor`

---

### **FASE 7: Configuración del Proyecto**

- [ ] Navegar al directorio del proyecto: `cd ~/ruta/al/proyecto/unp_calendario`
- [ ] Verificar que estás en la rama correcta: `git branch`
- [ ] Actualizar dependencias: `flutter pub get`
- [ ] Verificar que no hay errores: `flutter analyze`
- [ ] Revisar `pubspec.yaml` para verificar dependencias
- [ ] Configurar Firebase:
  - [ ] Descargar `google-services.json` (Android) desde Firebase Console si no está
  - [ ] Descargar `GoogleService-Info.plist` (iOS) desde Firebase Console si no está
  - [ ] Verificar que los archivos están en las ubicaciones correctas:
    - Android: `android/app/google-services.json`
    - iOS: `ios/Runner/GoogleService-Info.plist`
- [ ] Verificar configuración de Firebase en el proyecto
- [ ] Revisar `firebase.json` y `firestore.rules`
- [ ] Verificar `.gitignore` para asegurar que no se suben archivos de Mac

---

### **FASE 8: Compilación y Pruebas**

#### **Compilación para iOS:**
- [ ] Navegar al directorio del proyecto
- [ ] Ejecutar: `flutter clean`
- [ ] Ejecutar: `flutter pub get`
- [ ] Para iOS Simulator:
  ```bash
  flutter run -d ios
  ```
- [ ] Verificar que la app se abre en iOS Simulator
- [ ] Probar funcionalidades principales en iOS

#### **Compilación para Android:**
- [ ] Asegurar que Android Emulator está corriendo o dispositivo conectado
- [ ] Ejecutar: `flutter run -d android`
- [ ] Verificar que la app se abre en Android
- [ ] Probar funcionalidades principales en Android

#### **Compilación para Web:**
- [ ] Ejecutar: `flutter run -d chrome` (o `-d web-server`)
- [ ] Verificar que la app se abre en el navegador
- [ ] Probar funcionalidades principales en Web
- [ ] Verificar que Firebase funciona correctamente en web

---

### **FASE 9: Verificación de Funcionalidades**

- [ ] Login/Registro funciona en todas las plataformas
- [ ] Crear/editar planes funciona
- [ ] Crear/editar eventos funciona
- [ ] Calendario y visualización funcionan correctamente
- [ ] Participantes e invitaciones funcionan
- [ ] Presupuesto y pagos funcionan
- [ ] Estadísticas funcionan
- [ ] Sincronización con Firestore funciona
- [ ] Modo offline funciona (si está implementado)
- [ ] Notificaciones funcionan (si están implementadas)

---

### **FASE 10: Configuración de Acceso Remoto al Mac**

**Objetivo:** Permitir acceso remoto al Mac desde Windows para desarrollo a distancia.

**Opciones de acceso remoto:**
1. **Microsoft Remote Desktop (Recomendado para desarrollo)** - Gratis, oficial de Microsoft, optimizado para Windows
2. **Chrome Remote Desktop** - Sencillo, multiplataforma, gratuito
3. **VNC Server (nativo macOS)** - Integrado, pero requiere configuración adicional
4. **TeamViewer** - Comercial pero robusto (gratis para uso personal)
5. **AnyDesk** - Gratis para uso personal, ligero

**Recomendación:** Microsoft Remote Desktop para mejor experiencia de desarrollo desde Windows.

#### **Opción A: Microsoft Remote Desktop (Recomendado)**

**En el Mac:**
- [ ] Instalar Microsoft Remote Desktop desde App Store:
  - [ ] Buscar "Microsoft Remote Desktop" en App Store
  - [ ] Instalar la aplicación
- [ ] Configurar Compartir Pantalla en macOS:
  - [ ] Ir a Preferencias del Sistema → Compartir
  - [ ] Activar "Compartir Pantalla"
  - [ ] Configurar opciones de acceso (usuario y contraseña)
  - [ ] Anotar la dirección IP del Mac (ver en Preferencias del Sistema → Red)
- [ ] Verificar que el Mac está conectado a Internet y siempre encendido/despierto
- [ ] Configurar para que el Mac no se duerma (si es necesario):
  - [ ] Ir a Preferencias del Sistema → Ahorro de Energía
  - [ ] Configurar para que no se duerma cuando está conectado a la corriente

**En Windows:**
- [ ] Instalar Microsoft Remote Desktop desde Microsoft Store (ya viene preinstalado en Windows 10/11 Pro)
- [ ] Abrir Microsoft Remote Desktop
- [ ] Añadir nueva conexión:
  - [ ] Nombre: "Mac Desarrollo"
  - [ ] PC: [IP del Mac]
  - [ ] Usuario: [usuario del Mac]
  - [ ] Guardar credenciales
- [ ] Probar conexión remota
- [ ] Verificar que funciona el desarrollo (Cursor, Flutter, terminal, etc.)

#### **Opción B: Chrome Remote Desktop**

**En el Mac:**
- [ ] Instalar Chrome Remote Desktop desde [remotedesktop.google.com](https://remotedesktop.google.com)
- [ ] Iniciar sesión con cuenta de Google
- [ ] Configurar acceso remoto:
  - [ ] Ir a "Remoto de asistencia" o "Mi equipo"
  - [ ] Hacer clic en "Activar acceso remoto"
  - [ ] Seguir las instrucciones para configurar PIN
  - [ ] Anotar el PIN de acceso
- [ ] Verificar que el Mac está conectado a Internet

**En Windows:**
- [ ] Instalar Chrome Remote Desktop desde [remotedesktop.google.com](https://remotedesktop.google.com)
- [ ] Iniciar sesión con la misma cuenta de Google
- [ ] En "Mi equipo", debería aparecer el Mac
- [ ] Hacer clic en el Mac y usar el PIN para conectar
- [ ] Probar conexión remota
- [ ] Verificar que funciona el desarrollo

#### **Opción C: VNC Server (Nativo macOS)**

**En el Mac:**
- [ ] Activar Compartir Pantalla:
  - [ ] Ir a Preferencias del Sistema → Compartir
  - [ ] Activar "Compartir Pantalla"
  - [ ] Configurar usuarios permitidos
  - [ ] Anotar la dirección IP del Mac
- [ ] (Opcional) Instalar servidor VNC más robusto si es necesario
- [ ] Verificar configuración de firewall si hay problemas

**En Windows:**
- [ ] Instalar cliente VNC (ej: TightVNC, RealVNC Viewer)
- [ ] Conectar usando la IP del Mac y credenciales
- [ ] Probar conexión remota

**Verificación:**
- [ ] Conexión remota funciona correctamente
- [ ] Cursor IDE funciona a través de conexión remota
- [ ] Terminal funciona correctamente
- [ ] Flutter commands funcionan
- [ ] Compilación funciona (puede ser más lento que local)
- [ ] Performance es aceptable para desarrollo

**Notas importantes:**
- El Mac debe estar conectado a Internet y encendido para acceso remoto
- Considerar usar un router con IP fija o servicio de DNS dinámico si la IP cambia
- Para mejor performance, usar conexión Ethernet si es posible
- La compilación puede ser más lenta a través de conexión remota
- Considerar dejar el Mac conectado a la corriente para evitar que se duerma

---

### **FASE 11: Optimización de Cursor**

- [ ] Configurar settings de Cursor para Flutter:
  - [ ] Configurar formato automático al guardar
  - [ ] Configurar linting automático
  - [ ] Configurar snippets personalizados (si los tienes)
- [ ] Configurar workspace settings en `.vscode/settings.json`:
  ```json
  {
    "dart.flutterSdkPath": "/ruta/a/flutter",
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "dart.enableSdkFormatter": true,
    "dart.lineLength": 80
  }
  ```
- [ ] Configurar extensiones recomendadas (crear `.vscode/extensions.json` si no existe)
- [ ] Probar autocompletado y sugerencias de IA
- [ ] Verificar que la integración con Git funciona correctamente
- [ ] Configurar atajos de teclado personalizados si es necesario

---

### **FASE 12: Actualizaciones y Paquetes**

- [ ] Actualizar Flutter a la última versión estable:
  ```bash
  flutter upgrade
  ```
- [ ] Actualizar dependencias del proyecto:
  ```bash
  flutter pub upgrade
  ```
- [ ] Verificar que no hay conflictos de dependencias
- [ ] Actualizar CocoaPods (iOS):
  ```bash
  cd ios
  pod repo update
  pod install
  cd ..
  ```
- [ ] Actualizar Android SDK (desde Android Studio)
- [ ] Actualizar Xcode (desde App Store)
- [ ] Verificar que todo funciona después de actualizaciones

---

### **FASE 13: Documentación y Finalización**

- [ ] Documentar cualquier problema encontrado durante la migración
- [ ] Actualizar documentación del proyecto si hubo cambios
- [ ] Crear nota de migración con pasos específicos seguidos
- [ ] Verificar que `.gitignore` incluye archivos de Mac
- [ ] Hacer commit inicial de configuración (si hay cambios):
  ```bash
  git status
  git add .
  git commit -m "chore: configuración inicial en Mac"
  ```
- [ ] Completar T155 (Instalación Firebase CLI)
- [ ] Completar T156 (Actualización de índices)
- [ ] **Preparar entorno para Offline First:**
  - [ ] Documentar métodos de simulación offline (iOS/Android/Web)
  - [ ] Verificar dependencias para offline (SQLite/Hive) en `pubspec.yaml`
  - [ ] Revisar documentación de T56-T62 (Infraestructura Offline)
  - [ ] Crear documento de preparación para desarrollo offline (opcional)

---

## ⚠️ Consideraciones Importantes

### **Compatibilidad:**
- Verificar compatibilidad de versiones de Flutter con macOS
- Asegurar que las rutas de archivos sean compatibles (no usar rutas absolutas de Windows)
- Verificar que las dependencias funcionan en macOS

### **Firebase:**
- Revisar configuración de Firebase (puede necesitar regenerar archivos de configuración)
- Verificar que los archivos de configuración de Firebase están en las ubicaciones correctas
- Asegurar que las reglas de Firestore funcionan correctamente

### **Archivos a Revisar:**
- `pubspec.yaml` - Dependencias
- `firebase.json` - Configuración Firebase
- `firestore.rules` - Reglas de seguridad
- `firestore.indexes.json` - Índices (se actualizarán en T156)
- `android/app/google-services.json` - Configuración Android
- `ios/Runner/GoogleService-Info.plist` - Configuración iOS
- `.gitignore` - Asegurar que no se suben archivos de Mac
- `.vscode/settings.json` - Configuración de Cursor/VS Code

### **Backup y Seguridad:**
- Hacer backup de chats de Cursor antes de migrar (si es posible)
- Documentar conversaciones importantes de IA antes de migrar
- Hacer backup de configuraciones importantes
- Verificar que las SSH keys están configuradas correctamente

---

## 📝 Notas Importantes

- Esta tarea debe completarse ANTES de T155 y T156
- Durante la migración, aprovechar para instalar Firebase CLI (T155)
- Una vez migrado, actualizar índices de Firestore (T156)
- **Después de completar la migración, el usuario quiere empezar con el desarrollo de Offline First (T56-T62)**
- **Asegurar que el entorno está preparado para desarrollo offline:**
  - Métodos de simulación offline documentados
  - Dependencias verificadas (SQLite/Hive)
  - Documentación de T56-T62 revisada
- Documentar cualquier problema encontrado durante la migración
- Si hay problemas con la migración de chats de Cursor, documentar las conversaciones importantes antes de migrar
- Tener en cuenta que la primera compilación puede tardar más tiempo (descarga de dependencias)

**Documento ejecutable:**
- 📘 **`docs/configuracion/MIGRACION_MAC_PLAYBOOK.md`** - Playbook completo para la IA que gestiona toda la migración paso a paso

**Relacionado con:**
- T155 (Instalación Firebase CLI)
- T156 (Actualización índices Firestore)
- T152 (Revisión y Optimización de Índices de Firestore)
- docs/configuracion/MIGRACION_MAC_PLAYBOOK.md
- docs/configuracion/DEPLOY_INDICES_FIREBASE_CONSOLE.md
- docs/configuracion/INDICES_ANALISIS_COMPARACION.md

---

### T155 - Instalación de Firebase CLI en Mac
**Estado:** Pendiente  
**Complejidad:** 🟢 Baja  
**Prioridad:** 🟡 Media (Programada para ~2 meses, durante migración)  
**Descripción:** Instalar Firebase CLI en el Mac durante la migración del proyecto (T154) para poder gestionar índices de Firestore desde la terminal.

**Contexto:**
- Actualmente no se tiene Firebase CLI instalado (se está trabajando manualmente desde Firebase Console)
- Durante la migración a Mac (T154) se instalará Firebase CLI
- Una vez instalado, se usará para actualizar índices (T156)

**Funcionalidades:**
1. Instalar Node.js (si no está instalado)
2. Instalar Firebase CLI globalmente
3. Hacer login en Firebase
4. Verificar instalación
5. Configurar proyecto Firebase

**Criterios de aceptación:**
- ✅ Node.js instalado (versión LTS recomendada)
- ✅ Firebase CLI instalado globalmente
- ✅ Login exitoso en Firebase
- ✅ Proyecto Firebase vinculado correctamente
- ✅ Comando `firebase deploy --only firestore:indexes` funciona

**Checklist de instalación:**
- [ ] Verificar si Node.js está instalado: `node --version`
- [ ] Si no está instalado, instalar Node.js desde [nodejs.org](https://nodejs.org/) (versión LTS)
- [ ] Verificar npm: `npm --version`
- [ ] Instalar Firebase CLI globalmente: `npm install -g firebase-tools`
- [ ] Verificar instalación: `firebase --version`
- [ ] Hacer login: `firebase login`
- [ ] Verificar login: `firebase projects:list`
- [ ] Navegar al directorio del proyecto: `cd /ruta/al/proyecto`
- [ ] Inicializar Firebase (si es necesario): `firebase init`
- [ ] Seleccionar proyecto Firebase correcto
- [ ] Verificar configuración: `firebase use`
- [ ] Probar comando de índices: `firebase deploy --only firestore:indexes --dry-run` (o similar)

**Comandos de instalación:**
```bash
# 1. Verificar Node.js (si no está instalado, descargar desde nodejs.org)
node --version

# 2. Instalar Firebase CLI
npm install -g firebase-tools

# 3. Login
firebase login

# 4. Verificar
firebase --version

# 5. Navegar al proyecto
cd /ruta/al/proyecto/unp_calendario

# 6. Seleccionar proyecto (si es necesario)
firebase use --add

# 7. Verificar configuración
firebase projects:list
```

**Notas importantes:**
- Esta tarea se completa DURANTE la migración (T154)
- Una vez instalado, se usará inmediatamente para T156
- Si hay problemas de permisos en macOS, puede ser necesario usar `sudo` (aunque no es recomendado)
- Alternativa sin `sudo`: usar `npx firebase-tools` en lugar de instalación global

**Documentación relacionada:**
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)
- docs/configuracion/DEPLOY_INDICES_INSTRUCCIONES.md
- docs/configuracion/DEPLOY_INDICES_FIREBASE_CONSOLE.md

**Relacionado con:**
- T154 (Migración del Proyecto a Mac/iOS)
- T156 (Actualización de Índices de Firestore)
- T152 (Revisión y Optimización de Índices de Firestore)

---

### T156 - Actualización de Índices de Firestore Durante Migración
**Estado:** Pendiente  
**Complejidad:** 🟢 Baja  
**Prioridad:** 🟡 Media (Programada para ~2 meses, después de migración)  
**Descripción:** Actualizar todos los índices de Firestore a los 25 índices requeridos usando Firebase CLI después de la migración a Mac (T154) y la instalación de Firebase CLI (T155).

**Contexto:**
- Actualmente hay 9 índices en Firebase, de los cuales 3 son obsoletos
- Se necesitan 25 índices en total (según T152)
- Durante la migración a Mac, se instalará Firebase CLI (T155)
- Una vez instalado, se aprovechará para actualizar todos los índices desde la terminal

**Funcionalidades:**
1. Verificar índices actuales en Firebase
2. Desplegar los 25 índices requeridos desde `firestore.indexes.json`
3. Eliminar índices obsoletos
4. Verificar que todos los índices están "Enabled"
5. Probar que las queries funcionan correctamente

**Criterios de aceptación:**
- ✅ Firebase CLI instalado y funcionando (T155 completada)
- ✅ 25 índices desplegados correctamente
- ✅ Todos los índices en estado "Enabled"
- ✅ Índices obsoletos eliminados
- ✅ Queries de la app funcionan sin errores de "missing index"
- ✅ Verificación exhaustiva de funcionalidades

**Checklist de actualización:**
- [ ] Completar T154 (Migración a Mac)
- [ ] Completar T155 (Instalación Firebase CLI)
- [ ] Navegar al directorio del proyecto: `cd /ruta/al/proyecto/unp_calendario`
- [ ] Verificar que `firestore.indexes.json` tiene los 25 índices correctos
- [ ] Verificar índices actuales en Firebase Console (opcional, para comparar)
- [ ] Desplegar índices: `firebase deploy --only firestore:indexes`
- [ ] Esperar a que todos los índices estén "Enabled" (puede tardar 5-30 minutos)
- [ ] Verificar en Firebase Console que hay 25 índices
- [ ] Identificar y eliminar índices obsoletos (ver `INDICES_ANALISIS_COMPARACION.md`):
  - [ ] Eliminar `Hours` - `horaFecha` + `horaNum` (colección obsoleta)
  - [ ] Eliminar `users` - `email` + `isActive` (no se usa)
  - [ ] Eliminar `users` - `planId` + `date` + `hour` (índice incorrecto)
- [ ] Verificar índices con problemas de nomenclatura (opcional):
  - [ ] Verificar si `users` - `IsActive` funciona (si no, recrear con `isActive`)
  - [ ] Verificar si `plan_participations` - `planID` funciona (si no, recrear con `planId`)
- [ ] Probar funcionalidades de la app:
  - [ ] Calendario carga eventos correctamente
  - [ ] Dashboard lista planes
  - [ ] Participantes se cargan correctamente
  - [ ] Eventos participantes funcionan
  - [ ] Pagos se cargan correctamente
  - [ ] Estadísticas funcionan
  - [ ] Búsquedas y filtros funcionan
- [ ] Verificar logs de la app para errores de "missing index"
- [ ] Actualizar documentación si es necesario

**Comandos principales:**
```bash
# 1. Verificar configuración de Firebase
firebase use

# 2. Ver índices actuales (opcional, desde Firebase Console)
# O listar desde CLI si está disponible

# 3. Desplegar todos los índices
firebase deploy --only firestore:indexes

# 4. Verificar estado (desde Firebase Console)
# Esperar a que todos estén "Enabled"
```

**Índices obsoletos a eliminar:**
1. `Hours` - `horaFecha` + `horaNum` (colección obsoleta)
2. `users` - `email` + `isActive` (no se usa en el código)
3. `users` - `planId` + `date` + `hour` (índice incorrecto - estos campos no existen en `users`)

**Índices con problemas de nomenclatura (verificar antes de eliminar):**
- `users` - `displayName` + `IsActive` (debería ser `isActive`)
- `users` - `createdAt` + `IsActive` (debería ser `isActive`)
- `plan_participations` - `isActive` + `planID` + `joinedAt` (debería ser `planId`)

**Notas importantes:**
- Esta tarea se completa DESPUÉS de T154 y T155
- El despliegue de índices puede tardar varios minutos (Firebase los crea en background)
- No eliminar índices obsoletos hasta que los nuevos estén "Enabled"
- Si hay errores, revisar `INDICES_ANALISIS_COMPARACION.md` para detalles
- Los índices con problemas de nomenclatura pueden funcionar (Firebase puede ser flexible), verificar antes de eliminar

**Documentación relacionada:**
- docs/configuracion/FIRESTORE_INDEXES_AUDIT.md
- docs/configuracion/INDICES_ANALISIS_COMPARACION.md
- docs/configuracion/INDICES_OBSOLETOS_VERIFICACION.md
- docs/configuracion/DEPLOY_INDICES_INSTRUCCIONES.md
- docs/configuracion/ESTRATEGIA_INDICES_ELIMINAR_TODOS.md
- firestore.indexes.json

**Relacionado con:**
- T154 (Migración del Proyecto a Mac/iOS)
- T155 (Instalación Firebase CLI)
- T152 (Revisión y Optimización de Índices de Firestore)

---

### T157 - Sistema de Ayuda Contextual
**Estado:** Pendiente  
**Complejidad:** 🟡 Media  
**Prioridad:** 🟡 Media  
**Descripción:** Implementar sistema de ayuda contextual con iconos interactivos que muestran textos de ayuda desde Firebase en múltiples idiomas según el idioma del usuario.

**Contexto:**
- Los usuarios necesitan ayuda contextual en diferentes partes de la aplicación
- Los textos de ayuda deben estar en Firebase para poder actualizarlos sin deployar la app
- El sistema debe soportar múltiples idiomas
- La ayuda debe mostrarse según el idioma configurado del usuario

**Funcionalidades:**
1. Sistema de identificación de campos/zonas de ayuda
2. Widget de icono de ayuda reutilizable
3. Servicio para cargar textos de ayuda desde Firestore
4. Modelo de datos para textos de ayuda (multi-idioma)
5. UI para mostrar ayuda contextual (tooltip, diálogo, o ambos)
6. Integración con sistema de i18n existente
7. Caché local de textos de ayuda para funcionar offline
8. Admin UI para gestionar textos de ayuda (opcional, futura mejora)

**Sistema de Identificación de Campos/Zonas:**

Propuesta de sistema jerárquico usando keys únicas:

**Formato:** `help.{section}.{component}.{field}`

**Ejemplos:**
- `help.plan.title` - Ayuda para el título del plan
- `help.plan.dates` - Ayuda para las fechas del plan
- `help.plan.budget` - Ayuda para el presupuesto del plan
- `help.event.title` - Ayuda para el título del evento
- `help.event.description` - Ayuda para la descripción del evento
- `help.event.participants` - Ayuda para seleccionar participantes
- `help.event.cost` - Ayuda para el coste del evento
- `help.participant.add` - Ayuda para añadir participantes
- `help.participant.role` - Ayuda para los roles de participantes
- `help.calendar.drag` - Ayuda para arrastrar eventos
- `help.calendar.filter` - Ayuda para los filtros del calendario
- `help.budget.total` - Ayuda para el presupuesto total
- `help.payment.add` - Ayuda para añadir pagos
- `help.stats.overview` - Ayuda para la vista general de estadísticas

**Estructura de secciones:**
- `help.plan.*` - Ayuda relacionada con planes
- `help.event.*` - Ayuda relacionada con eventos
- `help.accommodation.*` - Ayuda relacionada con alojamientos
- `help.participant.*` - Ayuda relacionada con participantes
- `help.calendar.*` - Ayuda relacionada con el calendario
- `help.budget.*` - Ayuda relacionada con presupuesto
- `help.payment.*` - Ayuda relacionada con pagos
- `help.stats.*` - Ayuda relacionada con estadísticas
- `help.auth.*` - Ayuda relacionada con autenticación
- `help.settings.*` - Ayuda relacionada con configuración

**Criterios de aceptación:**
- ✅ Modelo `HelpText` con soporte multi-idioma
- ✅ Colección `help_texts` en Firestore con estructura:
  - `helpId` (string): ID único de la ayuda (ej: "help.plan.title")
  - `texts` (map): Mapa de idioma -> texto
    - `es` (string): Texto en español
    - `en` (string): Texto en inglés
    - `fr` (string): Texto en francés (si se añade)
    - etc.
  - `lastUpdated` (timestamp): Última actualización
- ✅ Servicio `HelpService` para cargar textos desde Firestore
- ✅ Caché local de textos de ayuda (usar Hive o similar si está disponible)
- ✅ Widget `HelpIcon` reutilizable:
  - Icono de ayuda (ícono de información)
  - Soporte para hover (tooltip) y click (diálogo)
  - Configurable: solo tooltip, solo diálogo, o ambos
- ✅ Integración con sistema de i18n existente para detectar idioma del usuario
- ✅ Fallback a español si el texto no está disponible en el idioma del usuario
- ✅ Fallback a texto genérico si no existe la ayuda en ningún idioma
- ✅ UI responsiva (tooltip en móvil puede ser diálogo)
- ✅ Textos de ayuda iniciales documentados y cargados en Firestore
- ✅ Firestore Rules para permitir lectura pública de help_texts

**Implementación técnica:**

**Modelo de datos:**
```dart
class HelpText {
  final String helpId;
  final Map<String, String> texts; // language -> text
  final DateTime lastUpdated;
  
  String getText(String language) {
    return texts[language] ?? texts['es'] ?? 'Ayuda no disponible';
  }
}
```

**Servicio:**
```dart
class HelpService {
  Future<HelpText?> getHelpText(String helpId);
  Future<Map<String, HelpText>> getAllHelpTexts();
  Stream<HelpText> watchHelpText(String helpId);
}
```

**Widget:**
```dart
class HelpIcon extends StatelessWidget {
  final String helpId;
  final bool showOnHover; // Tooltip
  final bool showOnClick; // Diálogo
  final IconData icon;
  final Color? color;
}
```

**Estructura en Firestore:**
```
help_texts/
  help.plan.title/
    helpId: "help.plan.title"
    texts: {
      es: "El título del plan...",
      en: "The plan title..."
    }
    lastUpdated: timestamp
```

**Archivos a crear:**
- `lib/features/help/domain/models/help_text.dart`
- `lib/features/help/domain/services/help_service.dart`
- `lib/features/help/presentation/widgets/help_icon.dart`
- `lib/features/help/presentation/widgets/help_dialog.dart`
- `lib/features/help/presentation/providers/help_providers.dart`
- `lib/features/help/data/repositories/help_repository.dart`

**Archivos a modificar:**
- `firestore.rules` - Añadir reglas para `help_texts` (lectura pública)
- Archivos de UI existentes - Añadir `HelpIcon` donde sea necesario
- `lib/l10n/app_es.arb` y `app_en.arb` - Añadir textos de UI del sistema de ayuda (botones, etc.)

**Ejemplo de uso:**
```dart
Row(
  children: [
    Text('Título del Plan'),
    HelpIcon(
      helpId: 'help.plan.title',
      showOnHover: true,
      showOnClick: true,
    ),
  ],
)
```

**Fase 1 (Base):**
- Modelo de datos
- Servicio básico
- Widget HelpIcon con tooltip
- Integración con i18n
- Caché local básica
- Firestore Rules

**Fase 2 (Mejoras futuras):**
- Diálogo de ayuda al hacer click
- Admin UI para gestionar textos (T158 - futura tarea)
- Analytics de qué ayudas se consultan más
- Búsqueda de ayudas
- Tutoriales guiados (futuro)

**Notas importantes:**
- Los textos de ayuda deben ser claros y concisos
- Usar formato Markdown para textos largos (opcional)
- Considerar límite de caracteres para tooltips vs diálogos
- Los textos deben actualizarse periódicamente según feedback de usuarios
- Considerar añadir imágenes o videos en el futuro

**Testing:**
- [ ] Cargar ayuda desde Firestore
- [ ] Mostrar ayuda en idioma correcto
- [ ] Fallback a español si no existe idioma
- [ ] Fallback a texto genérico si no existe ayuda
- [ ] Tooltip funciona en hover
- [ ] Diálogo funciona en click
- [ ] Caché local funciona
- [ ] Funciona offline (con caché)
- [ ] Performance: no bloquea UI al cargar ayudas

**Relacionado con:**
- Sistema de i18n existente (lib/l10n/)
- T158 (Completar Sistema Multi-idioma) - **⚠️ RECOMENDADO: Completar T158 antes de T157**
- T159 (Admin UI para gestionar textos de ayuda - futura mejora opcional)
- Sistema de caché offline (cuando se implemente T56-T62)

**Nota importante:** Se recomienda completar T158 (Completar Sistema Multi-idioma) antes de implementar T157 para tener el sistema de idiomas completo y que los textos de ayuda contextual se integren directamente con soporte multi-idioma.

---

### T158 - Completar Sistema Multi-idioma
**Estado:** Pendiente  
**Complejidad:** 🟡 Media  
**Prioridad:** 🟡 Media  
**Descripción:** Completar el sistema multi-idioma migrando todos los textos hardcodeados a archivos .arb, añadiendo persistencia de idioma, y mejorando el selector de idioma existente.

**Contexto:**
- La infraestructura de i18n está implementada (archivos .arb, AppLocalizations, providers)
- Existe un selector de idioma en la página de login (`LanguageSelector`)
- Sin embargo, muchos textos están hardcodeados en español en el código
- El idioma no se persiste entre sesiones
- La cobertura de i18n es parcial (~30-40% estimado)

**Estado actual:**
- ✅ Infraestructura base: archivos .arb (español e inglés), ~234 líneas cada uno
- ✅ Configuración en MaterialApp con localizationsDelegates y supportedLocales
- ✅ Provider `currentLanguageProvider` para cambiar idioma
- ✅ Widget `LanguageSelector` existente en login_page
- ⚠️ Uso parcial: solo en login_page (39 usos) y register_page (31 usos)
- ❌ Muchos textos hardcodeados en español en el resto de la app
- ❌ Idioma no se persiste (se resetea al reiniciar)
- ❌ Selector de idioma solo visible en login (no accesible desde otras páginas)

**Funcionalidades:**
1. Verificar y mejorar selector de idioma existente en login
2. Añadir persistencia del idioma (SharedPreferences o Firestore)
3. Auditoría completa de textos hardcodeados en el código
4. Migrar todos los textos hardcodeados a archivos .arb
5. Añadir selector de idioma accesible desde otras páginas (Settings/Perfil)
6. Verificar cobertura completa de traducciones
7. Testing de ambos idiomas en toda la app

**Criterios de aceptación:**
- ✅ Selector de idioma en login verificado y funcionando correctamente
- ✅ Decisión sobre mantener/mejorar selector existente
- ✅ Persistencia del idioma implementada:
  - Idioma se guarda al cambiar
  - Idioma se restaura al iniciar la app
  - Opción: SharedPreferences (local) o Firestore (sincronizado entre dispositivos)
- ✅ Auditoría completa de textos hardcodeados:
  - Lista de todos los archivos con textos hardcodeados
  - Identificación de textos que necesitan traducción
- ✅ Migración completa de textos:
  - Todos los textos hardcodeados migrados a .arb
  - Todas las páginas/widgets usan `AppLocalizations.of(context)`
  - Mensajes de error traducidos
  - Tooltips traducidos
  - Diálogos traducidos
  - SnackBars traducidos
- ✅ Archivos .arb actualizados:
  - `app_es.arb` con todas las traducciones en español
  - `app_en.arb` con todas las traducciones en inglés
  - Sin textos faltantes
- ✅ Selector de idioma accesible desde otras páginas:
  - Añadido en página de Settings/Perfil
  - O en AppBar/Header principal
  - Visible y funcional en toda la app
- ✅ Testing completo:
  - App funciona correctamente en español
  - App funciona correctamente en inglés
  - Cambio de idioma funciona sin errores
  - No hay textos sin traducir visibles

**Sistema de persistencia:**

**Opción A: SharedPreferences (Recomendado para inicio)**
- Rápido de implementar
- Funciona offline
- No requiere Firestore
- Solo local (no sincroniza entre dispositivos)

**Opción B: Firestore**
- Sincroniza entre dispositivos
- Requiere conexión a internet
- Integrado con el resto de datos del usuario

**Recomendación:** Empezar con SharedPreferences, luego migrar a Firestore si se necesita sincronización.

**Archivos a crear/modificar:**
- `lib/features/language/domain/services/language_storage_service.dart` - Servicio de persistencia
- `lib/features/language/presentation/providers/language_providers.dart` - Modificar para cargar idioma guardado al iniciar
- `lib/l10n/app_es.arb` - Añadir todas las traducciones faltantes
- `lib/l10n/app_en.arb` - Añadir todas las traducciones faltantes
- Todos los archivos de UI - Migrar textos hardcodeados a `AppLocalizations.of(context)`
- Página de Settings/Perfil - Añadir selector de idioma

**Proceso de auditoría:**
1. Buscar todos los archivos con `Text('...')` o `Text("...")` hardcodeados
2. Buscar todos los `SnackBar` con textos hardcodeados
3. Buscar todos los `AlertDialog` con textos hardcodeados
4. Buscar todos los tooltips con textos hardcodeados
5. Buscar todos los mensajes de error hardcodeados
6. Crear lista priorizada de textos a migrar

**Proceso de migración:**
1. Añadir nuevas keys a `app_es.arb` y `app_en.arb`
2. Reemplazar textos hardcodeados por `AppLocalizations.of(context)!.key`
3. Verificar que no hay textos faltantes
4. Regenerar archivos de localización: `flutter gen-l10n`
5. Probar en ambos idiomas

**Ejemplo de migración:**
```dart
// Antes:
Text('Crear Plan')
SnackBar(content: Text('Plan creado exitosamente'))

// Después:
Text(AppLocalizations.of(context)!.createPlan)
SnackBar(content: Text(AppLocalizations.of(context)!.planCreatedSuccessfully))
```

**Fase 1 (Base):**
- Verificar selector de idioma existente
- Implementar persistencia con SharedPreferences
- Cargar idioma guardado al iniciar app
- Auditoría inicial de textos hardcodeados

**Fase 2 (Migración):**
- Migrar textos de páginas principales (Dashboard, Calendar, etc.)
- Migrar diálogos y mensajes
- Actualizar archivos .arb

**Fase 3 (Finalización):**
- Añadir selector de idioma en Settings/Perfil
- Migrar textos restantes
- Testing completo en ambos idiomas
- Verificar cobertura 100%

**Notas importantes:**
- El selector existente en login parece funcional, pero debe verificarse
- Considerar mantener el selector en login para usuarios no logueados
- Añadir selector también en Settings para usuarios logueados
- Los textos de ayuda contextual (T157) seguirán el mismo sistema de idiomas

**Testing:**
- [ ] Selector de idioma en login funciona correctamente
- [ ] Cambio de idioma se refleja inmediatamente en la UI
- [ ] Idioma se guarda correctamente
- [ ] Idioma se restaura al reiniciar la app
- [ ] Todos los textos están traducidos en español
- [ ] Todos los textos están traducidos en inglés
- [ ] No hay textos hardcodeados visibles
- [ ] App funciona correctamente en ambos idiomas
- [ ] Selector de idioma accesible desde Settings/Perfil

**Relacionado con:**
- T157 (Sistema de Ayuda Contextual) - **⚠️ IMPORTANTE: Completar T158 antes de T157**
- Los textos de ayuda contextual (T157) usarán el mismo sistema de idiomas
- Sistema de i18n existente (lib/l10n/)
- Login page con selector existente

**Nota importante:** Esta tarea debe completarse antes de T157 (Sistema de Ayuda Contextual) para que los textos de ayuda se integren directamente con soporte multi-idioma completo.

---

## T159 - Corregir Permisos de Firestore para event_participants después de Logout/Login

**Estado:** 🔴 Pendiente  
**Prioridad:** Media  
**Grupo:** Seguridad y Firestore  
**Dependencias:** T152 (Firestore Index Optimization)

### Descripción
Después de hacer logout y volver a hacer login, aparecen errores de permisos (`permission-denied`) al consultar la colección `event_participants`. El problema ocurre específicamente después de un nuevo login, mientras que funciona correctamente después de un restart completo de la app.

### Problema Identificado
- Las consultas a `event_participants` usan múltiples `where()` y `orderBy()`
- En Firestore Rules, estas consultas requieren explícitamente `allow list:` además de `allow read:`
- Puede haber un problema de sincronización del token de autenticación después del login

### Cambios Realizados (Pendientes de Verificar)
- ✅ Añadido `allow list:` explícitamente en `firestore.rules` para `event_participants`
- ✅ Verificado que los índices compuestos necesarios existen en `firestore.indexes.json`

### Tareas Pendientes
- [ ] Desplegar las reglas actualizadas en Firebase Console
- [ ] Verificar que los índices compuestos estén desplegados
- [ ] Probar el flujo completo: logout → login → verificar que no aparezcan errores
- [ ] Si persiste el problema, investigar si hay un problema de timing/sincronización del token
- [ ] Verificar si hay otros servicios con el mismo problema (plan_participations, etc.)
- [ ] Documentar la solución si requiere cambios adicionales

### Archivos Afectados
- `firestore.rules` - Reglas de seguridad actualizadas
- `firestore.indexes.json` - Índices compuestos (ya verificados)
- `lib/features/calendar/domain/services/event_participant_service.dart` - Servicio que hace las consultas

### Criterios de Aceptación
- ✅ No aparecen errores de permisos después de logout/login
- ✅ Las consultas a `event_participants` funcionan correctamente en todos los escenarios
- ✅ Las reglas de Firestore están correctamente desplegadas
- ✅ Todos los índices necesarios están desplegados

### Notas Técnicas
- En Firestore Rules, `allow read:` permite leer documentos individuales
- `allow list:` es necesario para consultas que devuelven múltiples documentos con `where()` y `orderBy()`
- Las consultas actuales usan: `.where('eventId', isEqualTo: eventId).where('status', isEqualTo: 'registered').orderBy('registeredAt')`

### Relacionado con
- T152 (Firestore Index Optimization)
- Sistema de autenticación
- EventParticipantService

---

