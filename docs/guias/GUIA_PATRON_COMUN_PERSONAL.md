# 🎯 Guía del Patrón Parte Común / Parte Personal

> Patrón arquitectónico para manejar información compartida e individual en eventos y alojamientos

**Versión:** 1.0  
**Fecha:** Enero 2025  
**Relacionado con:** T75, T76 (Parte Común + Personal)

---

## 🎯 Objetivo

Este documento describe el patrón **Parte Común / Parte Personal** que permite que múltiples participantes compartan información base (parte común) mientras cada uno tiene datos específicos e individuales (parte personal).

---

## 🏗️ Arquitectura del Patrón

### Concepto General

En eventos y alojamientos con múltiples participantes, necesitamos:

1. **Parte Común**: Información compartida por todos (descripción, fecha, ubicación para eventos; nombre hotel, check-in/check-out para alojamientos)
2. **Parte Personal**: Información específica por participante (asiento en vuelo, menú especial en evento; número de habitación, tipo de cama en alojamiento)

### Casos de Uso

#### Eventos
- **Parte Común:** "Vuelo Madrid-Sydney el 22/10 a las 20:00h"
- **Parte Personal:** Juan tiene asiento 12A, menú vegetariano; María tiene asiento 12B, menú estándar

#### Alojamientos
- **Parte Común:** "Hotel Hilton Paris del 15/11 al 21/11"
- **Parte Personal:** Juan en habitación 203 (matrimonio, vista mar); María en habitación 204 (individual, vista jardín)

---

## 📊 Estructura de Datos

### Eventos

```dart
class Event {
  // ... campos base ...
  
  final EventCommonPart? commonPart; // Información compartida
  final Map<String, EventPersonalPart>? personalParts; // key: participantId
}

class EventCommonPart {
  final String description;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int durationMinutes;
  final String? location;
  final String? notes;
  final String? family;
  final String? subtype;
  final String? customColor;
  final List<String> participantIds; // Participantes incluidos
  final bool isForAllParticipants;
  final bool isDraft;
  final Map<String, dynamic>? extraData;
}

class EventPersonalPart {
  final String participantId;
  final Map<String, dynamic>? fields; // Campos específicos
  // Ejemplos de fields:
  // - "seat": "12A"
  // - "menu": "vegetarian"
  // - "notes": "Dieta especial"
  // - "specialRequest": "Wheelchair assistance"
}
```

### Alojamientos

```dart
class Accommodation {
  // ... campos base ...
  
  final AccommodationCommonPart? commonPart; // Información compartida
  final Map<String, AccommodationPersonalPart>? personalParts; // key: participantId
}

class AccommodationCommonPart {
  final String hotelName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String? description;
  final String? notes;
  final String? typeFamily;
  final String? typeSubtype;
  final String? customColor;
  final String? address;
  final String? contactInfo;
  final Map<String, dynamic>? amenities;
  final int? maxCapacity;
  final List<String> participantIds; // Participantes incluidos
  final bool isForAllParticipants;
  final Map<String, dynamic>? extraData;
}

class AccommodationPersonalPart {
  final String participantId;
  final String? roomNumber; // Ej: "203", "Suite 501"
  final String? bedType; // "individual", "matrimonio", "litera"
  final Map<String, dynamic>? preferences; // "floor": "alto", "view": "mar", "quiet": true
  final Map<String, dynamic>? notes; // Notas personales
  final Map<String, dynamic>? fields; // Campos adicionales
  // Ejemplos de fields:
  // - "earlyCheckIn": true
  // - "lateCheckOut": false
  // - "extraBed": true
  // - "pet": "dog"
}
```

---

## 🔄 Flujos de Uso

### Crear con Parte Común/Personal

1. **Crear parte común:**
   - Completar información compartida (descripción, fechas, ubicación para eventos; hotel, check-in/check-out para alojamientos)
   - Seleccionar participantes incluidos
   - Guardar como EventCommonPart o AccommodationCommonPart

2. **Añadir parte personal (opcional):**
   - Para cada participante, completar información específica
   - Ejemplos:
     - Event: asiento, menú, notas personales
     - Alojamiento: habitación, tipo de cama, preferencias
   - Guardar como EventPersonalPart o AccommodationPersonalPart

### Leer/Virtualizar

1. **Mostrar parte común:** Información compartida visible para todos
2. **Mostrar parte personal:** Solo visible para el participante propietario
3. **Listar participantes:** Con sus datos personales (si aplica)

### Actualizar

1. **Parte común:** Solo organizador/coorganizadores pueden editar
2. **Parte personal:** Cada participante edita su propia parte (dentro de límites de estado)
3. **Validaciones:** Verificar permisos y estado del evento/alojamiento

### Estados y Editabilidad

| Estado | Parte Común Editable | Parte Personal Editable |
|--------|----------------------|------------------------|
| Planificando | ✅ Sí | ✅ Sí |
| Confirmado/Reservado | ⚠️ Limitado | ✅ Sí |
| En Curso/Check-in | ❌ No (solo urgente) | ⚠️ Solo actualizaciones |
| Completado/Check-out | ❌ No | ❌ No |
| Cancelado | ❌ No | ❌ No |

---

## 📋 Reglas de Negocio

### Parte Común

- **Auto-sincronización:** Cambios en parte común afectan a todos los participantes
- **Estados:** Gestión de estados (Planificando, Confirmado, etc.) en parte común
- **Notificaciones:** Cambios en parte común notifican a todos los participantes
- **Permisos:** Solo organizador/coorganizadores pueden editar

### Parte Personal

- **Individualidad:** Cada participante solo ve/edita su propia parte personal
- **Editable:** Parte personal editable hasta que el evento/alojamiento esté "En Curso" o "Check-in"
- **Campos dinámicos:** Usar `fields` Map para datos flexibles específicos del contexto
- **Validación:** Validar que parte personal corresponde a participante incluido en parte común

---

## 🛠️ Implementación Técnica

### Persistencia en Firestore

```dart
// Event
{
  "planId": "plan123",
  "commonPart": {
    "description": "Vuelo Madrid-Sydney",
    "date": "2025-10-22",
    "location": "Aeropuerto",
    "participantIds": ["user1", "user2", "user3"]
  },
  "personalParts": {
    "user1": {
      "participantId": "user1",
      "fields": {
        "seat": "12A",
        "menu": "vegetarian"
      }
    },
    "user2": {
      "participantId": "user2",
      "fields": {
        "seat": "12B",
        "menu": "standard"
      }
    }
  }
}

// Accommodation
{
  "planId": "plan123",
  "commonPart": {
    "hotelName": "Hotel Hilton Paris",
    "checkIn": "2025-11-15",
    "checkOut": "2025-11-21",
    "address": "123 Calle Principal",
    "participantIds": ["user1", "user2"]
  },
  "personalParts": {
    "user1": {
      "participantId": "user1",
      "roomNumber": "203",
      "bedType": "matrimonio",
      "preferences": {
        "floor": "alto",
        "view": "mar"
      }
    },
    "user2": {
      "participantId": "user2",
      "roomNumber": "204",
      "bedType": "individual",
      "preferences": {
        "view": "jardin"
      }
    }
  }
}
```

### Migración y Compatibilidad

- Modelos soportan **compatibilidad hacia atrás** (backward compatibility)
- Si no existe `commonPart` o `personalParts`, usar campos legacy directos
- Al actualizar a nueva estructura: migrar campos antiguos a nueva estructura

---

## 📚 Referencias Cruzadas

**Flujos relacionados:**
- `FLUJO_CRUD_EVENTOS.md` - Ciclo completo de eventos con parte común/personal
- `FLUJO_CRUD_ALOJAMIENTOS.md` - Ciclo completo de alojamientos con parte común/personal

**Tareas relacionadas:**
- T75: Parte común de eventos
- T76: Parte personal de eventos

**Implementación en código:**
- `lib/features/calendar/domain/models/event.dart` - EventCommonPart, EventPersonalPart
- `lib/features/calendar/domain/models/accommodation.dart` - AccommodationCommonPart, AccommodationPersonalPart

---

## ✅ Checklist de Implementación

Al implementar funcionalidad con parte común/personal:

- [ ] Identificar campos compartidos (ir a parte común)
- [ ] Identificar campos individuales por participante (ir a parte personal)
- [ ] Crear modelos CommonPart y PersonalPart
- [ ] Implementar migración de campos legacy
- [ ] Implementar validaciones de permisos
- [ ] Implementar notificaciones según tipos de cambios
- [ ] Documentar en flujos correspondientes
- [ ] Probar con múltiples participantes

---

*Guía del patrón arquitectónico Parte Común/Parte Personal*  
*Última actualización: Febrero 2026*

