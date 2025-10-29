# 📋 Lista de Tareas - Planazoo

> Consulta las normas y flujo de trabajo en `docs/CONTEXT.md`.

**Siguiente código de tarea: T137**

**📊 Resumen de tareas por grupos:**
- **GRUPO 1:** T68, T69, T70, T72: Fundamentos de Tracks (4 completadas)
- **GRUPO 2:** T71, T73: Filtros y Control (2 completadas)
- **GRUPO 3:** T46, T74, T75, T76: Parte Común + Personal (4 completadas, 0 pendientes)
- **GRUPO 4:** T56-T60, T63, T64: Infraestructura Offline (7 pendientes)
- **GRUPO 5:** T40-T45: Timezones (6 completadas, 0 pendientes) - T81, T82: No existen
- **GRUPO 6:** T77-T79, T83-T90: Funcionalidades Avanzadas (4 completadas, 11 pendientes)
- **Seguridad:** T51-T53: Validación (3 pendientes)
- **Participantes:** T47, T49-T50: Sistema básico (3 pendientes)
- **Permisos:** T65-T67: Gestión de permisos (1 completada, 2 pendientes)
- **Mejoras Visuales:** T91-T92: Colores y tipografía (2 pendientes)
- **Testing y Mantenimiento:** T96-T99: Refactoring, testing y documentación (4 pendientes)
- **UX:** T100: Visualización de Timezones (1 pendiente)
- **Integración:** T131: Sincronización con Calendarios Externos (1 pendiente)
- **Agencias:** T132: Definición Sistema Agencias de Viajes (1 pendiente)
- **Exportación:** T133: Exportación Profesional de Planes PDF/Email (1 pendiente)
- **Importación:** T134: Importar desde Email (1 pendiente)
- **Privacidad:** T135-T136: Gestión de Cookies y App Tracking Transparency (2 pendientes)

**Total: 110 tareas documentadas (57 completadas, 53 pendientes)**

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
- `docs/especificaciones/FRANKENSTEIN_PLAN_SPEC.md`

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
- `docs/arquitectura/ARCHITECTURE_DECISIONS.md`
- `docs/CONTRIBUTING.md`
- `docs/SERVICE_EXAMPLES.md`

---

### T100 - Visualización de Timezones en el Calendario
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Depende de:** T40-T45 (Timezones implementadas)  
**Descripción:** Decidir y implementar la mejor forma de visualizar las timezones en el calendario para que los usuarios entiendan en qué timezone está cada participante.

**Opciones de visualización consideradas:**

#### **Opción 1: Indicador en el AppBar**
- Mostrar la timezone actual del usuario seleccionado
- Icono de reloj + texto (ej: "London (UTC+0)")
- Ubicación: AppBar, junto al selector de usuario

#### **Opción 2: Color de fondo en tracks**
- Cambiar el color de fondo de cada track según la timezone del participante
- Pros: Visualización clara de diferencias de timezone
- Contras: Cambios frecuentes en viajes, posible confusión si colores se superponen

#### **Opción 3: Barra lateral de color en tracks**
- Indicador sutil de color en el lado del track
- Tooltip al hover con información de timezone
- Cambios graduales suaves para evitar distracción

#### **Opción 4: Tooltip en eventos**
- Mostrar horas en origen y destino al pasar el mouse
- Badge "✈" en eventos de desplazamiento
- Información contextual sin ocupar espacio

**Criterios de decisión:**
- Claridad para usuarios
- Prevención de confusión horaria
- Contexto para eventos internacionales
- No sobrecargar la interfaz

**Tareas a realizar:**
- Evaluar cada opción con prototipo o mockup
- Decidir opción o combinación de opciones
- Implementar solución elegida
- Documentar decisión

**Archivos a crear/modificar:**
- Mockups o prototipos de cada opción
- Documentación de decisión final
- Implementación en UI del calendario

---

## 📋 NUEVAS FUNCIONALIDADES (T101-T118, T105 revisado)

**Nota:** Las tareas T105 ha sido actualizada según la decisión de usar sistema de avisos unidireccionales en lugar de chat.

### T105 - Sistema de Avisos y Notificaciones del Plan
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Sistema de avisos unidireccionales y notificaciones para el plan, no un chat bidireccional.

**Funcionalidades:**
1. Modelo `PlanAnnouncement` con usuario, mensaje, timestamp
2. Publicar avisos que todos los participantes pueden ver
3. Notificaciones push a todos los participantes cuando hay un nuevo aviso
4. Lista de avisos en orden cronológico
5. Avisos visibles para todos los participantes

**Concepto:**
- No es un chat (no conversación)
- Sistema de avisos unidireccionales (como WhatsApp a todo el grupo)
- Cada participante puede publicar avisos
- Todos reciben notificación cuando hay un aviso nuevo
- Ver lista de avisos del plan

**Criterios de aceptación:**
- Modelo PlanAnnouncement con validación
- UI para publicar avisos
- Notificaciones push a todos los participantes
- Lista de avisos visible para todos
- Persistencia en Firestore
- Testing básico

---

### T101 - Sistema de Presupuesto del Plan
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja  
**Descripción:** Implementar un sistema de presupuesto que permita registrar costes en eventos y alojamientos y visualizar análisis agrupados.

**Funcionalidades:**
1. Campo de coste en el modelo Event y Accommodation
2. Suma automática de presupuesto total del plan
3. Página de análisis de presupuesto con:
   - Presupuesto total
   - Desglose por tipo de evento
   - Desglose por participante
   - Desglose por tipo (eventos vs alojamientos)
   - Gráfico de distribución

**Criterios de aceptación:**
- Modelos Event y Accommodation incluyen campo `cost` (opcional)
- Servicio de cálculo de presupuesto
- UI para introducir coste en eventos y alojamientos
- Página de análisis con gráficos
- Persistencia en Firestore
- Testing básico

---

### T102 - Sistema de Control de Pagos y Bote Común
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟢 Baja  
**Descripción:** Implementar un sistema de control de pagos donde cada participante registra lo que ha pagado en cada evento, con cálculo automático de balances y saldos.

**Funcionalidades:**
1. Modelo `PersonalPayment` con campos: `amount`, `description`, `date`
2. Cada participante puede registrar pagos en la parte personal de eventos
3. Página de resumen de pagos con:
   - Total pagado por participante
   - Total gastado en el plan
   - Coste por persona (total gastado / número participantes)
   - Balance de cada participante (lo que debe pagar o cobrar)
   - Indicador visual de estado (pendiente/parcial/saldado)

**Criterios de aceptación:**
- Modelo PersonalPayment con validación
- UI para registrar pagos en eventos
- Cálculo automático de balances
- Página de resumen con gráficos
- Persistencia en Firestore
- Testing básico

---

### T117 - Sistema de Registro de Participantes por Evento
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Permitir que los participantes se apunten a eventos individuales dentro de un plan, no solo al plan completo.

**Concepto:**
- Los usuarios se apuntan al PLAN (participan en el plan)
- Además, los usuarios pueden APUNTARSE A EVENTOS ESPECÍFICOS dentro del plan
- Ejemplo: Plan "Partidas de Padel 2024" → Evento "Partido domingo 15" → Participantes se apuntan a ese evento específico

**Casos de uso:**
- Partidas de padel: plan anual, eventos semanales donde la gente se apunta
- Actividades regulares: plan maestro con eventos específicos que requieren confirmación
- Eventos opcionales dentro de un plan

**Funcionalidades:**
1. Sistema de registro de participantes por evento
2. Botón "Apuntarse al evento" en cada evento
3. Lista de participantes confirmados por evento
4. Indicadores visuales de eventos con espacios disponibles
5. Gestión de límites de participantes por evento

**Criterios de aceptación:**
- Registro de participantes por evento individual
- Visualización de participantes confirmados
- Gestión de límites de participantes
- Integración con sistema de notificaciones
- Testing con diferentes escenarios

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
**Estado:** Pendiente  
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

#### **Fase 1: Invitaciones al Plan**
1. UI para invitar participantes por email/usuario
2. Notificaciones push de invitaciones
3. Botones aceptar/rechazar para el invitado
4. Actualización del estado en tiempo real
5. Lista de participantes invitados vs confirmados

#### **Fase 2: Confirmación de Eventos**
1. Organizador marca eventos como "requiere confirmación"
2. Participantes reciben notificación para confirmar asistencia
3. Botones confirmar/no asistir en cada evento
4. Indicadores visuales de quién ha confirmado
5. Gestión de límites (ej: máximo 10 personas)

**Integración:**
- Con T117 (Registro de Participantes por Evento)
- Con T105 (Sistema de Avisos y Notificaciones)
- Con T104 (Sistema de Invitaciones a Planes - revisar si es redundante)

**Criterios de aceptación:**
- Flujo completo de invitaciones al plan
- Sistema de confirmación de eventos
- Notificaciones push en cada paso
- UI clara para organizador y participantes
- Persistencia en Firestore
- Testing completo del flujo

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
**Estado:** Pendiente  
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
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Sistema para actualizar automáticamente la duración del plan cuando se añaden eventos que se extienden fuera del rango original.

**Funcionalidades:**
1. Detectar cuando un evento nuevo sale fuera del rango del plan
2. Ofertar expandir el plan automáticamente
3. Actualizar fecha inicio/fin del plan dinámicamente
4. Recalcular `columnCount` del calendario
5. Notificar a todos los participantes del cambio
6. Mantener histórico de cambios de duración

**Criterios de aceptación:**
- Detectar eventos fuera de rango
- Modal de confirmación para expandir plan
- Actualización automática de fechas
- Recalcular calendario automáticamente
- Notificar a participantes
- Testing con eventos multi-día

**Archivos a modificar:**
- `lib/features/calendar/domain/services/plan_service.dart`
- `lib/widgets/screens/wd_calendar_screen.dart`

**Relacionado con:** T109 (Estados del plan)

---

### T109 - Estados del Plan
**Estado:** Pendiente  
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
- Transiciones controladas entre estados
- Validaciones antes de cambiar estado
- Permisos diferentes según estado
- Badges visuales en UI
- Notificaciones al cambiar estado
- Estados bloquean/desbloquean funcionalidades

**Criterios de aceptación:**
- Campo `status` en modelo Plan
- Validaciones de transiciones
- Permisos por estado implementados
- UI con badges de estado
- Notificaciones de cambio de estado
- Reembolsos al cancelar

**Archivos a crear:**
- `lib/features/calendar/domain/models/plan_status.dart`
- `lib/features/calendar/domain/services/plan_status_service.dart`

**Relacionado con:** T107, T105, T113

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
**Estado:** Pendiente  
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
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🟡 Media  
**Descripción:** Dashboard de estadísticas del plan: resumen de eventos, participantes, presupuesto, distribución temporal, etc.

**Funcionalidades:**
1. Resumen de eventos por tipo
2. Distribución temporal de actividades
3. Resumen de participantes
4. Comparativa presupuesto estimado vs real
5. Análisis de presupuesto por tipo
6. Exportar estadísticas (PDF, Excel)

**Criterios de aceptación:**
- Vista de estadísticas completa
- Gráficos de distribución
- Comparación presupuesto
- Exportar a PDF/Excel
- UI responsive

**Archivos a crear:**
- `lib/features/stats/domain/services/plan_stats_service.dart`
- `lib/features/stats/presentation/pages/plan_stats_page.dart`

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
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Alta  
**Descripción:** Completar y refinar las reglas de seguridad de Firestore para proteger todos los datos sensibles.

**Funcionalidades:**
1. Reglas para planes (crear, leer, actualizar, eliminar)
2. Reglas para eventos dentro de planes
3. Reglas para participantes y participaciones
4. Reglas para datos de pagos y presupuesto (T101, T102)
5. Reglas para preferencias de usuario
6. Reglas para avisos y notificaciones (T105)
7. Reglas para grupos de contactos (T123)

**Criterios de aceptación:**
- Todas las operaciones protegidas por reglas
- Solo usuarios autenticados pueden hacer operaciones
- Permisos verificados en servidor (Firestore)
- Testing de reglas con casos límite
- Documentar reglas críticas

**Archivos a modificar:**
- `firestore.rules`
- Testing de reglas de seguridad

**Relacionado con:** T51, T52, T53, docs/flujos/FLUJO_SEGURIDAD.md

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
**Estado:** Pendiente  
**Complejidad:** ⚠️ Media  
**Prioridad:** 🔴 Alta  
**Descripción:** Sanitizar y validar todo el input del usuario para prevenir XSS, SQL injection y otros ataques.

**Funcionalidades:**
1. Sanitizar HTML (whitelist) en avisos/biografías/notas
2. Tags permitidos: `b,strong,i,em,u,br,p,ul,ol,li,a`
3. Atributos permitidos en `a`: `href`, `title` (http/https) con `rel="noopener noreferrer"`
4. Eliminar `script`, `style`, `iframe`, `on*`, `img` (por ahora)
5. Validar y escapar HTML al mostrar
6. Validar emails, URLs seguras

**Criterios de aceptación:**
- HTML sanitizado antes de guardar (sin scripts)
- HTML escapado al mostrar
- Validación de inputs en todos los formularios
- Testing de inputs maliciosos
- No permitir JavaScript en user input

**Archivos a crear:**
- `lib/features/security/utils/sanitizer.dart`
- `lib/features/security/utils/validator.dart`

**Relacionado con:** T51, T105, docs/flujos/FLUJO_SEGURIDAD.md

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

**Relacionado con:** docs/arquitectura/ARCHITECTURE_DECISIONS.md (Integración con Calendarios Externos), docs/flujos/FLUJO_CRUD_EVENTOS.md (Importación de eventos)

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
- [ ] **Pago:** ¿Suscripción agencia? ¿Pay-per-plan? ¿Gratis inicial?
- [ ] **Monetización:** ¿Quién paga? ¿Agencia, cliente o ambos?
- [ ] **Límites:** ¿Número de planes/participantes por agencia?
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

