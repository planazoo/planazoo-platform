# 🏗️ Decisiones Arquitectónicas - Planazoo

**Fecha de creación:** Diciembre 2024  
**Versión:** 1.0  
**Estado:** Finalizado

---

## 📋 Índice

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Filosofía General](#filosofía-general)
3. [Decisiones Arquitectónicas](#decisiones-arquitectónicas)
4. [Implementación](#implementación)
5. [Ejemplos Prácticos](#ejemplos-prácticos)
6. [Consideraciones Futuras](#consideraciones-futuras)
7. [Referencias](#referencias)

---

## 🎯 Resumen Ejecutivo

### Filosofía Principal
**"Offline First + Sincronización Inteligente + Permisos Granulares"**

La aplicación está diseñada para funcionar completamente sin conexión, con sincronización automática cuando es posible, y un sistema de permisos que permite colaboración flexible pero controlada.

### Beneficios Clave
- ✅ **Funciona siempre** (offline first)
- ✅ **Colabora inteligentemente** (permisos granulares)
- ✅ **Sincroniza automáticamente** (tiempo real + conflictos)
- ✅ **Escala eficientemente** (optimización automática)
- ✅ **Desarrolla rápidamente** (simplicidad inicial)

---

## 🧠 Filosofía General

### Principios de Diseño

#### 0. **Fundamentos del proyecto** (detalle en `docs/configuracion/CONTEXT.md`)
- **Máxima participación de IA y herramientas:** Priorizar opciones que permitan a la IA y al software hacer más y a las personas menos.
- **Valor incremental antes que big-bang:** Entregar valor verificable en cada paso; preferir feedback pronto frente a soluciones “todo o nada”.
- **Reutilizar y comprobar antes de crear:** Comprobar si ya existe algo equivalente; priorizar reutilizar, adaptar o extender sobre duplicar o crear de cero.
- **Documentación viva:** La documentación evoluciona con el producto; los cambios relevantes se reflejan en los documentos; la doc obsoleta es deuda.

#### 1. **Offline First**
La aplicación debe funcionar perfectamente sin conexión a internet. La sincronización es un bonus, no un requisito.

#### 2. **Simplicidad Inicial**
Complejidad arquitectónica mínima en el MVP para permitir desarrollo rápido e iteración.

#### 3. **Escalabilidad Futura**
Arquitectura preparada para optimizaciones automáticas cuando sea necesario.

#### 4. **Colaboración Controlada**
Sistema de permisos que permite flexibilidad sin perder control.

#### 5. **Experiencia Consistente**
UI y UX coherentes independientemente del estado de conexión.

---

## 🏗️ Decisiones Arquitectónicas

### 1. 🗃️ Gestión de Datos: Duplicación Total + Optimización Futura

#### **Decisión**
Todos los eventos duplicados por participante en el MVP, con optimización automática al cerrar el plan.

#### **Justificación**
- **Simplicidad:** Evita complejidad de sincronización de referencias
- **Desarrollo rápido:** Menos bugs y más iteración
- **Flexibilidad:** Cada participante puede personalizar su información
- **Optimización futura:** Conversión automática a referencias cuando sea beneficioso

#### **Implementación (alineado con el código actual)**
En el código se usa un único evento por plan con **parte común** y **partes personales** por participante (no copias por participante). Ver decisión 4 y `docs/.../GUIA_PATRON_COMUN_PERSONAL.md` si existe.

```dart
// Un solo evento con parte común + mapa de partes personales por participantId
Event vuelo = Event(
  id: "vuelo_123",
  planId: "plan_abc",
  userId: "padre",           // creador / quien edita la parte común
  description: "Vuelo Barcelona-Londres",
  hour: 7,
  commonPart: EventCommonPart(...),  // datos compartidos
  personalParts: {
    "padre": EventPersonalPart(asiento: "12A", gate: "B15"),
    "madre": EventPersonalPart(asiento: "12B", gate: "B15"),
  },
  participantTrackIds: ["track_padre", "track_madre"],
  // ...
);
```

#### **Optimización Futura**
Al cerrar el plan, eventos idénticos podrían convertirse a referencias para ahorrar espacio (no implementado aún).

---

### 2. 🔄 Sincronización: Estrategia Híbrida

#### **Decisión**
Combinación de Firestore Transactions + Optimistic Updates según el tipo de operación.

#### **Justificación**
- **Consistencia:** Transactions garantizan operaciones críticas
- **UX rápida:** Optimistic updates para cambios cosméticos
- **Balance:** Lo mejor de ambos mundos

#### **Criterios de Aplicación**

| Operación | Estrategia | Razón |
|-----------|------------|-------|
| **Cambiar hora/duración** | Transaction | Crítico para múltiples participantes |
| **Añadir/quitar participante** | Transaction | Cambia referencias de múltiples lugares |
| **Cambiar descripción** | Optimistic | Solo afecta texto, no lógica |
| **Cambiar color** | Optimistic | Cosmético, no crítico |
| **Crear evento nuevo** | Optimistic | No hay referencias existentes que romper |
| **Borrar evento** | Transaction | Elimina referencias de múltiples participantes |

---

### 3. 🌍 Timezones: Sistema UTC del Plan

#### **Decisión**
Todos los eventos se guardan en timezone base del plan, con conversión automática por participante.

#### **Justificación**
- **Simplicidad máxima:** Como sistema de vuelos (no hay decisiones difíciles)
- **Consistencia:** Todos los eventos en la misma "moneda temporal"
- **Escalabilidad:** Funciona automáticamente para cualquier timezone

#### **Implementación (alineado con el código actual)**
```dart
class Plan {
  String id;
  String name;
  String? timezone;     // IANA, ej: "Europe/Madrid" — "UTC" del plan
  DateTime baseDate;   // primer día del plan
  int columnCount;     // número de días (startDate/endDate se derivan)
  // ...
}

class Event {
  String id;
  String planId;
  String description;
  DateTime date;       // en timezone del plan (o del evento si se especifica)
  int hour;
  String? timezone;         // opcional: IANA de salida (ej. vuelos)
  String? arrivalTimezone; // opcional: IANA de llegada (ej. vuelos)
  // ...
}

// Conversión automática al mostrar: usar timezone del evento o del plan
String formatTimeForParticipant(Event event, Participant participant) {
  final tz = event.timezone ?? plan.timezone ?? participant.timezone;
  // ... formatear en tz
}
```

---

### 4. 📱 Arquitectura de Eventos: Parte Común + Parte Personal

#### **Decisión**
Separación clara entre información compartida (parte común) e información individual (parte personal).

#### **Justificación**
- **Separación de responsabilidades:** Creador controla lo común, participante controla lo personal
- **Flexibilidad total:** Cualquier nivel de personalización
- **Colaboración natural:** Admins pueden gestionar información de otros cuando es necesario

#### **Estructura (alineada con el código: `Event`, `EventCommonPart`, `EventPersonalPart`)**
```dart
class Event {
  String id;
  String planId;
  String userId;  // creador — quien puede editar parte común
  
  // Campos de nivel evento (compatibilidad / parte común implícita)
  String description;
  DateTime date;
  int hour;
  int startMinute;
  int durationMinutes;
  List<String> participantTrackIds;  // tracks que participan
  
  // Parte común explícita (editada por creador)
  EventCommonPart? commonPart;
  
  // Partes personales por participantId (editada por participante + admins)
  Map<String, EventPersonalPart>? personalParts;
  // Ejemplo: {"participantId1": EventPersonalPart(asiento: "12A", ...)}
}
```

#### **Permisos**
- **Creador (userId):** Edita parte común + su parte personal
- **Participante:** Edita solo su parte personal
- **Admin:** Edita parte común + cualquier parte personal

---

### 5. 🔔 Notificaciones: Sistema Push Completo

#### **Decisión**
Notificaciones push para todos los cambios importantes con configuración personalizable.

#### **Justificación**
- **Transparencia:** Usuarios siempre informados de cambios relevantes
- **Colaboración:** Facilita trabajo en equipo
- **Flexibilidad:** Cada usuario puede configurar sus preferencias

#### **Tipos de Notificaciones**
- **Cambios en eventos existentes:** Hora, duración, descripción
- **Nuevos eventos:** Cuando se crea un evento
- **Eventos eliminados:** Cuando se borra un evento
- **Cambios de participantes:** Añadir/quitar participantes

#### **Configuración**
```dart
class NotificationSettings {
  String userId;
  bool eventCreated;
  bool eventUpdated;
  bool eventDeleted;
  bool participantChanges;
  bool onlyMyEvents; // Solo eventos en los que participo
  bool onlyImportantChanges; // Solo cambios críticos (hora, fecha)
}
```

---

### 6. ⚡ Sincronización en Tiempo Real: Firestore + Riverpod

#### **Decisión**
Firestore real-time listeners + Riverpod state management para actualizaciones automáticas.

#### **Justificación**
- **Tiempo real:** Cambios instantáneos entre usuarios
- **Reactivo:** UI se actualiza automáticamente
- **Eficiente:** Solo escucha cambios relevantes

#### **Implementación (estructura real: colección raíz `events` con `planId`)**
```dart
class EventSyncService {
  void startListening(String planId, String userId) {
    FirebaseFirestore.instance
        .collection('events')  // colección raíz, no subcolección de plans
        .where('planId', isEqualTo: planId)
        .snapshots()
        .listen((snapshot) {
          _handleEventChanges(snapshot);
        });
  }
  
  void _handleEventChanges(QuerySnapshot snapshot) {
    for (final change in snapshot.docChanges) {
      switch (change.type) {
        case DocumentChangeType.added:
          eventNotifier.addEvent(Event.fromFirestore(change.doc));
          break;
        case DocumentChangeType.modified:
          eventNotifier.updateEvent(Event.fromFirestore(change.doc));
          break;
        case DocumentChangeType.removed:
          eventNotifier.removeEvent(change.doc.id);
          break;
      }
    }
  }
}
```

---

### 7. 📱 Offline First: Funcionamiento Completo Sin Conexión

#### **Decisión**
Almacenamiento local completo + sincronización automática cuando hay conexión.

#### **Justificación**
- **Confiabilidad:** App siempre funcional
- **Experiencia consistente:** Sin interrupciones por problemas de red
- **Productividad:** Usuarios pueden trabajar sin limitaciones

#### **Componentes**
```dart
// Base de datos local
class LocalDatabase {
  Future<void> saveEvent(Event event) async {
    await localDB.insert('events', event.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<Event>> getEventsForParticipant(String participantId) async {
    return await localDB.query('events', 
        where: 'participant_id = ?', whereArgs: [participantId]);
  }
}

// Cola de sincronización
class SyncQueue {
  List<SyncOperation> pendingOperations = [];
  
  void addOperation(SyncOperation operation) {
    pendingOperations.add(operation);
    _processQueue();
  }
  
  Future<void> _processQueue() async {
    if (!_isOnline()) return;
    
    for (final operation in pendingOperations) {
      try {
        await _executeOperation(operation);
        pendingOperations.remove(operation);
      } catch (e) {
        _scheduleRetry(operation);
      }
    }
  }
}
```

#### **Resolución de Conflictos**
- **Estrategia:** Último cambio gana (basado en timestamp)
- **Notificación:** Usuario informado de conflictos resueltos
- **Log:** Historial de conflictos para debugging

---

### 8. 🔐 Permisos: Sistema Híbrido de Roles

#### **Decisión**
3 roles base + permisos específicos por evento para máxima flexibilidad.

#### **Justificación**
- **Simplicidad:** Roles claros y comprensibles
- **Flexibilidad:** Permisos específicos para casos especiales
- **Escalabilidad:** Fácil añadir nuevos permisos si es necesario

#### **Roles Base**
```dart
enum UserRole {
  admin,        // 👑 Admin del plan - todos los permisos
  participant,  // 👥 Participante normal - permisos básicos
  observer,     // 👁️ Solo lectura - sin permisos de edición
}
```

#### **Matriz de Permisos**

| Acción | Admin | Creador | Participante | Observador |
|--------|-------|---------|--------------|------------|
| **Ver parte común** | ✅ | ✅ | ✅ | ✅ |
| **Editar parte común** | ✅ | ✅ | ❌ | ❌ |
| **Ver parte personal** | ✅ | ✅ | ✅ | ✅ |
| **Editar propia parte personal** | ✅ | ✅ | ✅ | ❌ |
| **Editar otras partes personales** | ✅ | ❌ | ❌ | ❌ |
| **Crear eventos** | ✅ | ✅ | ✅ | ❌ |
| **Eliminar eventos** | ✅ | ✅ | ❌ | ❌ |

#### **Implementación**
```dart
class PermissionService {
  Future<bool> canEditEventCommon(String userId, String eventId) async {
    final event = await eventService.getEvent(eventId);
    final userRole = await getUserRole(userId, event.planId);
    
    // Admin puede editar cualquier parte común
    if (userRole == UserRole.admin) return true;
    
    // Creador puede editar su evento
    if (event.userId == userId) return true;
    
    return false;
  }
}
```

---

## 🛠️ Implementación

### Tareas Creadas

#### **Sistema de Tracks y Multi-Participante (T68-T77)** ⭐ CORE
- **T68:** Modelo ParticipantTrack
- **T69:** CalendarScreen modo multi-track
- **T70:** Eventos multi-track (span horizontal)
- **T71:** Filtros de vista (Todos/Individual/Personalizado)
- **T72:** Control de días visibles
- **T73:** Gestión de orden de tracks
- **T74:** Modelo Event - Parte común + personal
- **T75:** EventDialog - UI parte común vs personal
- **T76:** Sincronización parte común
- **T77:** Indicadores visuales de permisos

#### **Vistas Filtradas y Timezone (T78-T82)**
- **T78:** Vista "Mi Agenda"
- **T79:** Vista "Plan Completo"
- **T80:** Vista "Personalizada"
- **T81:** Conversión timezone por participante
- **T82:** Indicador visual timezone

#### **Funcionalidades Avanzadas (T83-T90)**
- **T83:** Sistema de grupos de participantes
- **T84:** Propagación automática de cambios
- **T85:** Notificaciones cambios compartidos
- **T86:** Sistema adaptativo días visibles
- **T87:** Scroll horizontal condicional
- **T88:** Rediseño capas calendario
- **T89:** Indicadores eventos multi-participante
- **T90:** Resaltado track activo

#### **Offline First (T56-T62)**
- **T56:** Implementar Base de Datos Local
- **T57:** Implementar Cola de Sincronización
- **T58:** Implementar Resolución de Conflictos
- **T59:** Implementar Indicadores de Estado Offline
- **T60:** Implementar Sincronización en Tiempo Real
- **T61:** Implementar Notificaciones Push Offline
- **T62:** Testing Exhaustivo Offline First

#### **Permisos Granulares (T63-T67)**
- **T63:** Implementar Modelo de Permisos y Roles
- **T64:** Implementar UI Condicional Basada en Permisos
- **T65:** Implementar Gestión de Admins del Plan
- **T66:** Implementar Transferencia de Propiedad de Eventos
- **T67:** Implementar Sistema de Observadores

### Orden de Implementación

#### **Fase 1: Sistema de Tracks (CORE - Visual)**
1. **T68:** Modelo ParticipantTrack
2. **T69:** CalendarScreen modo multi-track
3. **T70:** Eventos multi-track (span)
4. **T71:** Filtros de vista
5. **T72:** Control de días visibles
6. **T74:** Modelo Event - Parte común + personal
7. **T75:** EventDialog - UI separada

#### **Fase 2: Sincronización y Permisos (Funcionalidad)**
8. **T76:** Sincronización parte común
9. **T77:** Indicadores visuales permisos
10. **T63:** Modelo de Permisos y Roles
11. **T64:** UI Condicional Basada en Permisos

#### **Fase 3: Offline First (Infraestructura)**
12. **T56:** Base de Datos Local
13. **T57:** Cola de Sincronización
14. **T60:** Sincronización en Tiempo Real
15. **T58:** Resolución de Conflictos
16. **T59:** Indicadores de Estado Offline

#### **Fase 4: Vistas y Timezone (Refinamiento)**
17. **T78:** Vista "Mi Agenda"
18. **T79:** Vista "Plan Completo"
19. **T80:** Vista "Personalizada"
20. **T81:** Conversión timezone por participante
21. **T82:** Indicador visual timezone

#### **Fase 5: Funcionalidades Avanzadas (Optimización)**
22. **T73:** Gestión de orden de tracks
23. **T84:** Propagación automática optimizada
24. **T85:** Notificaciones cambios compartidos
25. **T65:** Gestión de Admins del Plan
26. **T66:** Transferencia de Propiedad
27. **T67:** Sistema de Observadores
28. **T61:** Notificaciones Push Offline
29. **T62:** Testing Exhaustivo

#### **Fase 6: Funcionalidades Futuras (Opcional)**
30. **T83:** Sistema de grupos de participantes
31. **T86:** Sistema adaptativo días visibles
32. **T87:** Scroll horizontal condicional
33. **T88:** Rediseño capas calendario
34. **T89:** Indicadores eventos multi-participante
35. **T90:** Resaltado track activo

---

## 💡 Ejemplos Prácticos

### Escenario 1: Familia Viajando

#### **Contexto**
Plan "Vacaciones Europa" con 4 participantes: Padre (Admin), Madre, Hijo1, Hijo2

#### **Evento: Vuelo Barcelona-Londres**
```
📋 PARTE COMÚN (Editada por Padre - Admin):
├── Descripción: "Vuelo Barcelona-Londres"
├── Hora: 07:00 (timezone base del plan)
├── Duración: 2h 30m
├── Aerolínea: "Iberia"
└── Participantes: Padre, Madre, Hijo1

👤 PARTE PERSONAL (Editada por cada uno):
├── Padre: Asiento 12A, Gate B15, ✅ Tarjeta obtenida
├── Madre: Asiento 12B, Gate B15, ❌ Tarjeta pendiente
├── Hijo1: Asiento 12C, Gate B15, ❌ Tarjeta pendiente
└── Hijo2: No participa (va en tren)
```

#### **Permisos en Acción**
- **Padre (Admin):** Puede editar todo (parte común + todas las partes personales)
- **Madre:** Puede editar solo su parte personal (asiento, gate, tarjeta)
- **Hijo1:** Puede editar solo su parte personal
- **Hijo2:** Solo ve el evento (no participa)

### Escenario 2: Equipo Remoto

#### **Contexto**
Plan "Proyecto Internacional" con 3 participantes: Dev (Madrid), PM (Nueva York), QA (Tokio)

#### **Evento: Daily Standup**
```
📋 PARTE COMÚN (Editada por Dev - Creador):
├── Descripción: "Daily Standup"
├── Hora: 09:00 (timezone base del plan - Madrid)
├── Duración: 30m
├── Plataforma: "Zoom"
└── Participantes: Dev, PM, QA

👤 CONVERSIÓN AUTOMÁTICA POR TIMEZONE:
├── Dev (Madrid): 09:00
├── PM (Nueva York): 03:00 (conversión automática)
└── QA (Tokio): 17:00 (conversión automática)
```

### Escenario 3: Sistema de Tracks Multi-Participante

#### **Contexto**
Plan "Vacaciones Familia" con 4 participantes: Padre (Admin), Madre, Hijo, Hija

#### **Vista Plan Completo (Organizador)**
```
┌─────┬─────────┬─────────┬─────────┬─────────┐
│Horas│  Padre  │  Madre  │  Hijo   │  Hija   │
├─────┼─────────┼─────────┼─────────┼─────────┤
│07:00│ ✈️ Vuelo Barcelona - Londres (todos)──┤
│     │ Asiento │ Asiento │ Asiento │ Asiento │
│     │   12A   │   12B   │   12C   │   12D   │
├─────┼─────────┼─────────┼─────────┼─────────┤
│10:00│         │ 🛍️ Compr│         │ 🛍️ Compr│
│     │         │ (Madre + Hija)    │         │
├─────┼─────────┼─────────┼─────────┼─────────┤
│14:00│ ⚽ Fútbol────────┤│         │         │
│     │ (Padre + Hijo)  │         │         │
└─────┴─────────┴─────────┴─────────┴─────────┘
```

#### **Vista "Mi Agenda" (Madre)**
```
┌─────┬───────────────────────────┐
│Horas│  Mi Agenda - Madre        │
├─────┼───────────────────────────┤
│07:00│ ✈️ Vuelo BCN-LON          │
│     │ Asiento: 12B              │
│     │ Gate: B15                 │
│     │ ✅ Tarjeta obtenida       │
├─────┼───────────────────────────┤
│10:00│ 🛍️ Compras con Hija       │
│     │ Notas: Zara, H&M          │
└─────┴───────────────────────────┘
```

#### **Permisos en Acción (Vuelo)**
- **Padre (Admin):** Edita hora del vuelo (parte común) + su asiento (parte personal) + puede editar asientos de todos
- **Madre:** Solo edita su asiento y preferencias (parte personal), ve hora del vuelo en readonly
- **Hijo/Hija:** Solo editan sus partes personales

### Escenario 4: Offline First en Acción

#### **Contexto**
Usuario en avión sin conexión a internet

#### **Flujo de Trabajo**
```
1. Usuario abre app → Carga datos desde base de datos local
2. Usuario crea evento → Se guarda localmente inmediatamente
3. Usuario edita evento → Cambios locales instantáneos
4. Usuario elimina evento → Eliminación local inmediata
5. Usuario aterriza → Sincronización automática al reconectar
6. Cambios se propagan → Otros usuarios reciben notificaciones
```

---

## 🚀 Consideraciones Futuras

### Optimizaciones Planificadas

#### **1. Optimización Automática de Datos**
- **Cuándo:** Al cerrar un plan
- **Qué:** Convertir eventos idénticos a referencias
- **Beneficio:** Reducción de 40-60% en espacio de almacenamiento

#### **2. Sincronización Inteligente**
- **Debouncing:** Agrupar cambios rápidos
- **Compresión:** Comprimir datos para sincronización
- **Incremental:** Solo sincronizar cambios desde última conexión

#### **3. Permisos Avanzados**
- **Permisos temporales:** Admin por tiempo limitado
- **Permisos por tipo de evento:** Diferentes reglas para vuelos vs reuniones
- **Permisos delegados:** Transferir permisos temporalmente

### Escalabilidad

#### **Planes Grandes**
- **Lazy loading:** Cargar eventos por chunks
- **Índices optimizados:** Para búsquedas rápidas
- **Cache inteligente:** Mantener eventos frecuentes en memoria

#### **Muchos Participantes**
- **Filtrado eficiente:** Solo mostrar eventos relevantes
- **Agrupación:** Agrupar participantes similares
- **Vistas personalizadas:** Cada usuario ve solo lo relevante

### Nuevas Funcionalidades

#### **1. Eventos Recurrentes**
- **Base:** Eventos que se repiten automáticamente
- **Personalización:** Cada instancia puede tener información personal diferente
- **Gestión:** Editar serie completa vs instancia individual

#### **2. Integración con Calendarios Externos**
- **Sincronización:** Con Google Calendar, Outlook, etc.
- **Bidireccional:** Cambios en ambos sentidos
- **Filtros:** Solo sincronizar ciertos tipos de eventos

#### **3. Analytics y Reportes**
- **Estadísticas:** Tiempo dedicado a diferentes actividades
- **Reportes:** Resúmenes de planes y gastos
- **Insights:** Sugerencias basadas en patrones

---

## 📚 Referencias

### Documentos Relacionados
- `docs/tareas/TASKS.md` - Lista completa de tareas de implementación
- `docs/tareas/COMPLETED_TASKS.md` - Historial de tareas completadas
- `docs/especificaciones/CALENDAR_CAPABILITIES.md` - Capacidades funcionales del calendario
- `docs/especificaciones/FRANKENSTEIN_PLAN_SPEC.md` - Especificación del plan de testing

### Decisiones Técnicas
- **Riverpod:** State management elegido para la aplicación
- **Firestore:** Base de datos en la nube para sincronización
- **Hive (móvil):** persistencia local offline-first (`plans`, `events`, `participations`, `sync_queue`, `current_user` para perfil); inventario y QA en `docs/testing/TESTING_OFFLINE_FIRST.md`, perfil de usuario en `docs/flujos/FLUJO_CRUD_USUARIOS.md`
- **Flutter:** Framework de desarrollo principal

### Patrones de Diseño
- **Offline First:** Patrón de diseño principal
- **Repository Pattern:** Para abstracción de datos
- **Observer Pattern:** Para notificaciones y sincronización
- **Strategy Pattern:** Para diferentes tipos de sincronización

---

## 📝 Historial de Cambios

| Fecha | Versión | Cambios |
|-------|---------|---------|
| Dic 2024 | 1.0 | Documento inicial con todas las decisiones arquitectónicas |
| Feb 2026 | 1.1 | Sincronización con código: Event (commonPart, personalParts, userId, timezone/arrivalTimezone), Plan (timezone, baseDate, columnCount), Firestore colección raíz `events` con planId |

---

**Documento creado:** Diciembre 2024  
**Última actualización:** 6 de febrero de 2026  
**Próxima revisión:** Al completar implementación de T56-T67

---

## 🆕 **Actualizaciones Recientes (Febrero 2026)**

### **T93-T95: Mejoras de Alojamientos y Optimización**
- **T93:** Iconos visuales de check-in/check-out en alojamientos multi-día
- **T94:** Optimización y limpieza de código en CalendarScreen
- **T95:** Arreglo de interacción de tap en fila de alojamientos

### **Estado Actual del Sistema**
- ✅ **Alojamientos:** Sistema completo con iconos visuales y interacciones funcionales
- ✅ **Eventos:** Drag & drop, edición y creación completamente operativos
- ✅ **Código:** Optimizado con constantes y funciones helper
- ✅ **UI/UX:** Interacciones intuitivas y responsivas

### **Próximos Pasos**
- Implementar sistema de tracks multi-participante (T68-T77)
- Añadir funcionalidades de timezone (T40-T45)
- Desarrollar sistema offline first (T56-T62)
