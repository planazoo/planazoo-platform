# 📋 Lista de Tareas - Planazoo

**Siguiente código de tarea: T68**

## 📋 Reglas del Sistema de Tareas

1. **Códigos únicos**: Cada tarea tiene un código único (T1, T2, T3...)
2. **Orden de prioridad**: La posición en el documento indica el orden de trabajo (no el código)
3. **Códigos no reutilizables**: Al eliminar una tarea, su código no se reutiliza para evitar confusiones
4. **Trabajo iterativo**: Cada vez que acabemos una tarea, vemos cuál es la siguiente y decidimos si continuar
5. **Gestión dinámica**: Añadir y eliminar tareas según aparezcan nuevas o se finalicen
6. **Seguimiento de códigos**: La primera fila indica el siguiente código a asignar
7. **Estados de tarea**: Pendiente → En progreso → Completada
8. **Criterios claros**: Cada tarea debe tener criterios de aceptación definidos
9. **Aprobación requerida**: Antes de marcar una tarea como completada, se debe pedir aprobación explícita del usuario. Solo se marca como completada después de recibir confirmación.
10. **Archivo de completadas**: Las tareas completadas se mueven a `docs/COMPLETED_TASKS.md` para mantener este archivo limpio
11. **Plan Frankenstein:** Al completar una tarea que añade nueva funcionalidad al calendario (eventos, alojamientos, etc.), revisar si es necesario añadir casos de prueba al Plan Frankenstein (`lib/features/testing/demo_data_generator.dart`) para que la nueva funcionalidad esté cubierta en testing
12. **Arquitectura Offline First:** Todas las nuevas funcionalidades deben implementarse siguiendo el principio "Offline First" - la app debe funcionar completamente sin conexión y sincronizar cuando sea posible.

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