# Gestión de Timezones en UNP Calendario

## 📋 Índice
1. [Introducción](#introducción)
2. [Arquitectura de Timezones](#arquitectura-de-timezones)
3. [TimezoneService](#timezoneservice)
4. [PerspectiveService](#perspectiveservice)
5. [EventSegment y Multi-día](#eventsegment-y-multi-día)
6. [Visualización Adaptativa](#visualización-adaptativa)
7. [Casos de Uso](#casos-de-uso)
8. [Troubleshooting](#troubleshooting)
9. [Mejores Prácticas](#mejores-prácticas)

## 🎯 Introducción

La aplicación maneja eventos que pueden cruzar múltiples timezones, especialmente vuelos y desplazamientos. El sistema debe mostrar correctamente:
- Horas de salida y llegada en sus respectivas timezones locales
- Duración visual correcta de eventos multi-día
- **Perspectivas diferentes según el rol del usuario y su timezone personal**
- **Visualización adaptativa que cambia dinámicamente al cambiar de usuario**

## 🏗️ Arquitectura de Timezones

### Componentes Principales

1. **TimezoneService**: Conversiones básicas UTC ↔ Timezone local
2. **PerspectiveService**: Cálculo de perspectivas según rol del usuario y su timezone personal
3. **EventSegment**: Segmentación de eventos multi-día con perspectiva del usuario
4. **Event Model**: Campos `timezone` y `arrivalTimezone`
5. **PlanParticipation**: Campo `personalTimezone` para timezone personal del usuario

### Flujo de Datos Actualizado

```
Evento (timezone + arrivalTimezone)
    ↓
TimezoneService.localToUtc() → UTC
    ↓
Cálculo de duración → UTC + duration
    ↓
TimezoneService.utcToLocal() → arrivalTimezone
    ↓
PerspectiveService (con personalTimezone) → Perspectiva del usuario
    ↓
EventSegment (con perspectiva) → Segmentos visuales adaptativos
    ↓
CalendarScreen (con métodos adaptativos) → Renderizado final
```

## 🔧 TimezoneService

### Métodos Principales

#### `localToUtc(DateTime localDateTime, String timezone)`

**Propósito**: Convierte una hora local a UTC.

**Implementación Correcta**:
```dart
static DateTime localToUtc(DateTime localDateTime, String timezone) {
  initialize();
  
  final location = tz.getLocation(timezone);
  // ✅ Usar constructor TZDateTime, NO TZDateTime.from()
  final tzDateTime = tz.TZDateTime(
    location,
    localDateTime.year,
    localDateTime.month,
    localDateTime.day,
    localDateTime.hour,
    localDateTime.minute,
    localDateTime.second,
    localDateTime.millisecond,
  );
  return tzDateTime.toUtc();
}
```

**❌ Error Común**: Usar `TZDateTime.from()` que interpreta el DateTime como UTC.

#### `utcToLocal(DateTime utcDateTime, String timezone)`

**Propósito**: Convierte UTC a hora local.

**Implementación Correcta**:
```dart
static DateTime utcToLocal(DateTime utcDateTime, String timezone) {
  initialize();
  
  final location = tz.getLocation(timezone);
  // ✅ Crear TZDateTime en UTC y convertir a timezone específica
  final utcTzDateTime = tz.TZDateTime.utc(
    utcDateTime.year,
    utcDateTime.month,
    utcDateTime.day,
    utcDateTime.hour,
    utcDateTime.minute,
    utcDateTime.second,
    utcDateTime.millisecond,
  );
  
  final localTzDateTime = tz.TZDateTime.from(utcTzDateTime, location);
  return localTzDateTime;
}
```

### Ejemplo Práctico

**Vuelo Londres → Barcelona (Nov 2025)**:
```dart
// Salida: 22:00h Londres
final departure = DateTime(2025, 11, 5, 22, 0, 0);
final departureUtc = TimezoneService.localToUtc(departure, 'Europe/London');
// Resultado: 2025-11-05 22:00:00.000Z ✅

// Duración: 3 horas
final arrivalUtc = departureUtc.add(Duration(minutes: 180));
// Resultado: 2025-11-06 01:00:00.000Z ✅

// Llegada: Barcelona
final arrival = TimezoneService.utcToLocal(arrivalUtc, 'Europe/Madrid');
// Resultado: 2025-11-06 02:00:00.000+0100 ✅
```

## 🎭 PerspectiveService

### Tipos de Perspectiva

1. **Participant**: Ve el evento desde su **timezone personal** (`personalTimezone`)
2. **Observer**: Ve el evento desde su **timezone personal** (`personalTimezone`)

### Método Principal

#### `getEventPerspective(Event event, PlanParticipation userParticipation, String? userCurrentTimezone)`

**Para Participantes**:
- **Salida**: Hora en timezone de salida, convertida a su `personalTimezone`
- **Llegada**: Hora en timezone de llegada, convertida a su `personalTimezone`

**Para Observadores**:
- **Salida**: Hora convertida a su `personalTimezone`
- **Llegada**: Hora convertida a su `personalTimezone`

### Implementación Clave

```dart
static EventPerspective _getDisplacementPerspective({
  required Event event,
  required PlanParticipation userParticipation,
  required String userTimezone,
  required bool isParticipant,
  required bool isObserver,
}) {
  if (isParticipant) {
    // ✅ Participante: ve desde su timezone personal
    final participantTimezone = userParticipation.personalTimezone ?? userTimezone;
    
    final departureTime = _getLocalTime(event, event.timezone ?? participantTimezone);
    final arrivalTime = _calculateArrivalTime(event, participantTimezone);
    
    return EventPerspective(
      displayStartTime: departureTime,
      displayEndTime: arrivalTime,
      displayTimezone: participantTimezone,
      // ...
    );
  }
  // ...
}
```

### Ejemplo

```dart
// Vuelo Londres → Barcelona
// - Participante en Londres (personalTimezone: Europe/London)
// - Observador en Madrid (personalTimezone: Europe/Madrid)

final perspective = PerspectiveService.getEventPerspective(
  event, 
  userParticipation, 
  userCurrentTimezone
);

// Para participante en Londres:
// - displayStartTime: 22:00h Londres
// - displayEndTime: 01:00h Londres

// Para observador en Madrid:
// - displayStartTime: 23:00h Madrid
// - displayEndTime: 02:00h Madrid
```

## 📅 EventSegment y Multi-día

### Segmentación Adaptativa

Los eventos multi-día se dividen en segmentos **considerando la perspectiva del usuario**:

1. **Segmento de Salida**: Desde hora de salida hasta medianoche
2. **Segmentos Intermedios**: Días completos (00:00 - 23:59)
3. **Segmento de Llegada**: Desde medianoche hasta hora de llegada

### Método Principal

#### `_createEventSegmentsWithPerspective(Event event)`

**Nueva implementación que considera la perspectiva**:
```dart
List<EventSegment> _createEventSegmentsWithPerspective(Event event) {
  if (!_hasDifferentTimezones(event)) {
    return EventSegment.createSegmentsForEvent(event);
  }
  
  // Para eventos con timezones diferentes, usar PerspectiveService
  final userParticipation = _getCurrentUserParticipation();
  if (userParticipation == null) {
    return EventSegment.createSegmentsForEvent(event);
  }
  
  final perspective = PerspectiveService.getEventPerspective(
    event: event,
    userParticipation: userParticipation,
    userCurrentTimezone: _getCurrentUserTimezone(),
  );
  
  // Crear segmentos basados en la perspectiva del usuario
  return _createSegmentsFromPerspective(event, perspective);
}
```

## 🎨 Visualización Adaptativa

### Métodos Adaptativos

La visualización cambia dinámicamente según la perspectiva del usuario:

#### `_getPerspectiveStartMinutes(Event event)`
```dart
int _getPerspectiveStartMinutes(Event event) {
  if (_hasDifferentTimezones(event)) {
    final userParticipation = _getCurrentUserParticipation();
    if (userParticipation != null) {
      final perspective = PerspectiveService.getEventPerspective(/*...*/);
      return perspective.displayStartTime.hour * 60 + perspective.displayStartTime.minute;
    }
  }
  return event.totalStartMinutes;
}
```

#### `_getPerspectiveEndMinutes(Event event)`
```dart
int _getPerspectiveEndMinutes(Event event) {
  if (_hasDifferentTimezones(event)) {
    final userParticipation = _getCurrentUserParticipation();
    if (userParticipation != null) {
      final perspective = PerspectiveService.getEventPerspective(/*...*/);
      return perspective.displayEndTime.hour * 60 + perspective.displayEndTime.minute;
    }
  }
  return event.totalEndMinutes;
}
```

### Aplicación en Visualización

**Todos los aspectos de la visualización usan estos métodos adaptativos**:
- **Posicionamiento**: `_getPerspectiveStartMinutes()`
- **Altura**: `_getPerspectiveEndMinutes()`
- **Formateo de tiempo**: `_getPerspectiveEndMinutes()`
- **Drag & Drop**: `_getPerspectiveStartMinutes()`

## 🎯 Casos de Uso

### Caso 1: Vuelo Londres → Barcelona

**Configuración**:
- Salida: 22:00h Londres (UTC+0)
- Duración: 3 horas
- Llegada: Barcelona (UTC+1)

**Cálculo**:
1. **Salida UTC**: 22:00h UTC
2. **Llegada UTC**: 01:00h UTC
3. **Llegada Barcelona**: 02:00h Barcelona

**Visualización por Usuario**:

**Organizador en Madrid**:
- **Día 1**: 23:00h - 23:59h (Madrid)
- **Día 2**: 00:00h - 02:00h (Madrid)

**Participante en Londres**:
- **Día 1**: 22:00h - 23:59h (Londres)
- **Día 2**: 00:00h - 01:00h (Londres)

### Caso 2: Vuelo Madrid → Sydney

**Configuración**:
- Salida: 20:00h Madrid (UTC+1)
- Duración: 23 horas
- Llegada: Sydney (UTC+11)

**Cálculo**:
1. **Salida UTC**: 19:00h UTC
2. **Llegada UTC**: 18:00h UTC (día siguiente)
3. **Llegada Sydney**: 05:00h Sydney (día siguiente)

**Visualización por Usuario**:

**Organizador en Madrid**:
- **Día 1**: 20:00h - 23:59h (Madrid)
- **Día 2**: 00:00h - 23:59h (Madrid)
- **Día 3**: 00:00h - 04:00h (Madrid)

**Participante en Sydney**:
- **Día 1**: 05:00h - 23:59h (Sydney)
- **Día 2**: 00:00h - 23:59h (Sydney)
- **Día 3**: 00:00h - 05:00h (Sydney)

## 🔍 Troubleshooting

### Problema: Visualización no cambia al cambiar de usuario

**Síntomas**:
- El texto cambia pero la posición/altura no
- Los eventos se ven iguales para todos los usuarios

**Causa**: Los métodos de visualización no usan la perspectiva del usuario

**Solución**: Usar `_getPerspectiveStartMinutes()` y `_getPerspectiveEndMinutes()` en lugar de `event.totalStartMinutes`

### Problema: Segmentos incorrectos

**Síntomas**:
- Eventos multi-día no se segmentan correctamente
- Faltan días intermedios o de llegada

**Causa**: `EventSegment.createSegmentsForEvent()` no considera la perspectiva

**Solución**: Usar `_createEventSegmentsWithPerspective()` que considera la perspectiva del usuario

### Problema: Hora de llegada incorrecta

**Síntomas**:
- El evento muestra 01:00h en lugar de 02:00h
- Los logs muestran `DepartureUtc: 21:00h` en lugar de `22:00h`

**Causa**: Uso incorrecto de `TZDateTime.from()` en `localToUtc()`

**Solución**: Usar constructor `TZDateTime()` directamente

## ✅ Mejores Prácticas

### 1. Siempre usar métodos adaptativos

```dart
// ✅ Correcto - considera perspectiva del usuario
final startMinutes = _getPerspectiveStartMinutes(event);
final endMinutes = _getPerspectiveEndMinutes(event);

// ❌ Incorrecto - no considera perspectiva
final startMinutes = event.totalStartMinutes;
final endMinutes = event.totalEndMinutes;
```

### 2. Crear segmentos con perspectiva

```dart
// ✅ Correcto - considera perspectiva del usuario
final segments = _createEventSegmentsWithPerspective(event);

// ❌ Incorrecto - no considera perspectiva
final segments = EventSegment.createSegmentsForEvent(event);
```

### 3. Verificar timezones antes de cálculos

```dart
// ✅ Correcto
if (event.timezone != null && event.arrivalTimezone != null) {
  // Usar lógica de timezones diferentes con perspectiva
} else {
  // Usar lógica normal
}
```

### 4. Usar personalTimezone del usuario

```dart
// ✅ Correcto - usar timezone personal del usuario
final participantTimezone = userParticipation.personalTimezone ?? userTimezone;

// ❌ Incorrecto - usar solo userTimezone
final participantTimezone = userTimezone;
```

### 5. Inicializar TimezoneService

```dart
// ✅ Siempre inicializar antes de usar
TimezoneService.initialize();
```

### 6. Manejar DST correctamente

El paquete `timezone` maneja automáticamente el horario de verano, pero es importante usar las timezones IANA correctas:
- `Europe/Madrid` (no `Europe/Barcelona`)
- `Europe/London` (no `GMT`)
- `America/New_York` (no `EST`)

#### 5.1 - Configuración Inicial de Timezone

**Cuándo:** Al añadir participante  
**Valor por defecto:** Timezone del plan o timezone del usuario

**UI actual:** Perfil → Seguridad y acceso → **Configurar zona horaria** (aplica a todas las participaciones activas del usuario).

**Flujo:**
```
Añadir participante
  ↓
Seleccionar timezone inicial
```

#### 5.2 - Actualizar Timezone durante Ejecución

**Escenario:** Participante viaja y cambia de timezone

**UI soporte:** Desde el perfil del usuario → Seguridad y acceso → **Configurar zona horaria** (actualiza `plan_participations.personalTimezone` para todas las participaciones activas).

**Flujo:**
```
Participante llega a Sydney (antes estaba en Madrid)
  ↓
Sistema detecta cambio de timezone
  ↓
Actualizar `personalTimezone` del participante
  ↓
Recalcular eventos del participante
  ↓
Actualizar visualización en calendario
  ↓
Notificar a otros participantes (opcional)
```

**Implementación actual:** ✅ Ya implementado

#### 5.3 - Aviso Automático al Abrir la App (T178)
- Comparación entre `users.defaultTimezone` y `TimezoneService.getSystemTimezone()` tras la autenticación.
- Si difieren, se muestra un banner amigable en el dashboard con copy de soporte:
  - Botón "Actualizar zona" → `AuthNotifier.updateDefaultTimezone()` + snackbar verde.
  - Botón "Mantener" → `AuthNotifier.dismissTimezoneSuggestion()` + snackbar informativo.
- El banner destaca que los horarios pueden quedar desfasados si no se actualiza.
- Se reutiliza la misma lógica de persistencia que el modal manual del perfil.

**Casos de uso:**
- Viajes internacionales.
- Cambios de timezone del dispositivo (manualmente o por GPS).
- Movilidad frecuente entre sedes.

## 📚 Referencias

- [Paquete timezone de Dart](https://pub.dev/packages/timezone)
- [IANA Time Zone Database](https://www.iana.org/time-zones)
- [Flutter Timezone Tutorial](https://fluttercurious.com/tutorial-on-the-flutter-timezone-package/)

## 🧪 Testing recomendado

Para garantizar que la arquitectura funciona en escenarios reales, cubrir al menos los siguientes casos (ver detalle en `docs/configuracion/TESTING_CHECKLIST.md`, sección 13):

1. **Plan multi-timezone (TZ-001)** – Crear plan en `Europe/Madrid` y revisarlo desde un usuario configurado en `America/New_York`.
2. **Cambio de timezone del plan (TZ-002)** – Editar el plan anterior y comprobar que los eventos existentes se reajustan sin duplicados.
3. **Evento local vs. preferencia de usuario (TZ-EVENT-001 / 003)** – Crear un evento desde un usuario con timezone distinto y verificar la conversión.
4. **Eventos de viaje (TZ-EVENT-002)** – Vuelos con timezone de salida y llegada distintas; revisar cómo lo ven participantes y observadores.
5. **Vistas derivadas (TZ-EVENT-004)** – Confirmar que `CalendarScreen`, estadísticas y exportaciones muestran la misma hora convertida.
6. **Fallback cuando no hay preferencia guardada (TZ-003)** – Usuario nuevo sin `personalTimezone` debería ver la zona del plan hasta configurarla.

> ⚠️ **Nota:** La UI para configurar la preferencia personal de timezone está pendiente. Mientras tanto, puede definirse manualmente en Firestore (`planParticipations.personalTimezone`) para escenarios multiusuario.

---

**Última actualización**: Febrero 2026  
**Versión**: 2.0 - Perspectivas Adaptativas  
**Autor**: UNP Calendario Team