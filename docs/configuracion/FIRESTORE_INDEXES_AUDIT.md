# 🔍 Auditoría de Índices de Firestore - T152

> **Última revisión:** Enero 2025  
> **Objetivo:** Mantener índices optimizados, eliminar redundantes, añadir faltantes

---

## 📋 Índices Actuales en firestore.indexes.json

**Total de índices:** 25 (actualizado Enero 2025)

### **COLLECTION: `plans`** (2 índices)
- **Índice 1:** `createdAt` (DESC)
- **Índice 2:** `userId` (ASC) + `createdAt` (DESC)

### **COLLECTION: `events`** (3 índices)
- **Índice 1:** `planId` (ASC) + `date` (ASC) + `hour` (ASC)
- **Índice 2:** `planId` (ASC) + `isDraft` (ASC) + `date` (ASC) + `hour` (ASC)
- **Índice 3:** `planId` (ASC) + `typeFamily` (ASC) + `checkIn` (ASC)

### **COLLECTION: `plan_participations`** (5 índices)
- **Índice 1:** `planId` (ASC) + `isActive` (ASC)
- **Índice 2:** `userId` (ASC) + `isActive` (ASC) + `joinedAt` (DESC)
- **Índice 3:** `planId` (ASC) + `userId` (ASC) + `isActive` (ASC)
- **Índice 4:** `planId` (ASC) + `role` (ASC) + `isActive` (ASC)
- **Índice 5:** `planId` (ASC) + `role` (ASC) + `isActive` (ASC) + `joinedAt` (ASC)

### **COLLECTION: `planInvitations`** (4 índices)
- **Índice 1:** `planId` (ASC) + `status` (ASC) + `createdAt` (DESC)
- **Índice 2:** `token` (ASC)
- **Índice 3:** `planId` (ASC) + `email` (ASC) + `status` (ASC)
- **Índice 4:** `status` (ASC) + `expiresAt` (ASC)

### **COLLECTION: `event_participants`** (5 índices)
- **Índice 1:** `eventId` (ASC) + `status` (ASC) + `registeredAt` (ASC)
- **Índice 2:** `eventId` (ASC) + `confirmationStatus` (ASC)
- **Índice 3:** `eventId` (ASC) + `registeredAt` (ASC)
- **Índice 4:** `eventId` (ASC) + `userId` (ASC) + `status` (ASC)
- **Índice 5:** `eventId` (ASC) + `userId` (ASC)

### **COLLECTION: `personal_payments`** (3 índices)
- **Índice 1:** `planId` (ASC) + `paymentDate` (DESC)
- **Índice 2:** `planId` (ASC) + `participantId` (ASC) + `paymentDate` (DESC)
- **Índice 3:** `eventId` (ASC) + `paymentDate` (DESC)

### **COLLECTION: `participant_groups`** (1 índice)
- **Índice 1:** `userId` (ASC) + `updatedAt` (DESC)

### **COLLECTION: `users`** (2 índices)
- **Índice 1:** `isActive` (ASC) + `createdAt` (DESC)
- **Índice 2:** `displayName` (ASC) + `isActive` (ASC)

---

## 🔎 Queries Encontradas en el Código

### **COLLECTION: `plans`**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.orderBy('createdAt', descending: true)` | `plan_service.dart:19` | 19 | ✅ **Índice 1** | Implementado |
| `.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true)` | `plan_service.dart:30-31` | 30-31 | ✅ **Índice 2** | Implementado |
| `.where('unpId', isEqualTo: unpId)` | `plan_service.dart:71` | 71 | ✅ No necesita índice | Solo `where` con igualdad en un campo |
| `.where('userId', isEqualTo: userId)` | `plan_service.dart:103` | 103 | ✅ No necesita índice | Solo `where` con igualdad |

**✅ Índice automático:** Firestore crea índices automáticos para `where` simples con `isEqualTo` en un solo campo.

**✅ Índices implementados:**
- ✅ `plans`: `createdAt` (DESC) - para query sin `where`
- ✅ `plans`: `userId` (ASC) + `createdAt` (DESC) - para query con `where` + `orderBy`

---

### **COLLECTION: `events`**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.where('planId', isEqualTo: planId).orderBy('date').orderBy('hour')` | `event_service.dart:22-24` | 22-24 | ✅ **Índice 1** | Implementado |
| `.where('planId', isEqualTo: planId).where('date', isGreaterThanOrEqualTo: startOfDay).where('date', isLessThan: endOfDay).orderBy('hour')` | `event_service.dart:63-65, 86` | 63-65, 86 | ✅ **Índice 1** | Implementado (usa mismo índice) |
| `.where('planId', isEqualTo: planId).where('isDraft', isEqualTo: false).orderBy('date').orderBy('hour')` | `event_service.dart:262-265` | 262-265 | ✅ **Índice 2** | Implementado |
| `.where('planId', isEqualTo: planId).where('typeFamily', isEqualTo: 'alojamiento')` | `plan_service.dart:315-316` | 315-316 | ✅ No necesita índice | Solo `where` con igualdad |
| `.where('planId', isEqualTo: planId)` | `plan_service.dart:330` | 330 | ✅ No necesita índice | Solo `where` con igualdad |

**✅ Índices implementados:**
- ✅ `events`: `planId` (ASC) + `date` (ASC) + `hour` (ASC) - para queries principales y de rango de fecha
- ✅ `events`: `planId` (ASC) + `isDraft` (ASC) + `date` (ASC) + `hour` (ASC)

---

### **COLLECTION: `plan_participations`**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.where('planId', isEqualTo: planId).where('isActive', isEqualTo: true)` | `plan_participation_service.dart:15-16` | 15-16 | ✅ **Índice 1** | Implementado |
| `.where('userId', isEqualTo: userId).where('isActive', isEqualTo: true).orderBy('joinedAt', descending: true)` | `plan_participation_service.dart:39-41` | 39-41 | ✅ **Índice 2** | Implementado |
| `.where('userId', isEqualTo: userId).where('isActive', isEqualTo: true)` | `plan_participation_service.dart:52-53` | 52-53 | ✅ **Índice 2** | Implementado (cubre where) |
| `.where('planId', isEqualTo: planId).where('userId', isEqualTo: userId).where('isActive', isEqualTo: true)` | `plan_participation_service.dart:65-67` | 65-67 | ✅ **Índice 3** | Implementado |
| `.where('planId', isEqualTo: planId).where('role', isEqualTo: 'organizer').where('isActive', isEqualTo: true)` | `plan_participation_service.dart:244-246` | 244-246 | ✅ **Índice 4** | Implementado |
| `.where('planId', isEqualTo: planId).where('role', isEqualTo: 'participant').where('isActive', isEqualTo: true).orderBy('joinedAt', descending: false)` | `plan_participation_service.dart:264-267` | 264-267 | ✅ **Índice 5** | Implementado |
| `.where('planId', isEqualTo: planId).where('isActive', isEqualTo: true)` | `plan_participation_service.dart:285-286` | 285-286 | ✅ **Índice 1** | Implementado |

**✅ Índices implementados:**
- ✅ `plan_participations`: `planId` (ASC) + `isActive` (ASC)
- ✅ `plan_participations`: `userId` (ASC) + `isActive` (ASC) + `joinedAt` (DESC)
- ✅ `plan_participations`: `planId` (ASC) + `userId` (ASC) + `isActive` (ASC)
- ✅ `plan_participations`: `planId` (ASC) + `role` (ASC) + `isActive` (ASC)
- ✅ `plan_participations`: `planId` (ASC) + `role` (ASC) + `isActive` (ASC) + `joinedAt` (ASC)

**📝 Nota:** Firestore crea índices automáticos para queries con solo `where` usando `isEqualTo` en múltiples campos, PERO si se usa `orderBy` o rangos, se requiere índice compuesto.

---

### **COLLECTION: `planInvitations`**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.where('token', isEqualTo: token).where('status', isEqualTo: 'pending')` | `invitation_service.dart:127-128` | 127-128 | ✅ Índice 2 (token) | Usa índice existente (token) |
| `.where('planId', isEqualTo: planId).where('email', isEqualTo: normalizedEmail).where('status', isEqualTo: 'pending')` | `invitation_service.dart:165-167` | 165-167 | ✅ **Índice 3** | Implementado |
| `.where('planId', isEqualTo: planId).where('status', isEqualTo: 'pending').orderBy('createdAt', descending: true)` | `invitation_service.dart:280-282` | 280-282 | ✅ **Índice 1** | Implementado |
| `.where('status', isEqualTo: 'pending').where('expiresAt', isLessThan: Timestamp)` | `invitation_service.dart:304-305` | 304-305 | ✅ **Índice 4** | Implementado |

**✅ Índices implementados:**
- ✅ `planInvitations`: `planId` (ASC) + `email` (ASC) + `status` (ASC)
- ✅ `planInvitations`: `status` (ASC) + `expiresAt` (ASC) - para limpieza de expiradas

---

### **COLLECTION: `event_participants`**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.where('eventId', isEqualTo: eventId).where('status', isEqualTo: 'registered').orderBy('registeredAt', descending: false)` | `event_participant_service.dart:107-108` | 107-108 | ✅ Índice 1 | Usa índice existente |
| `.where('eventId', isEqualTo: eventId).orderBy('registeredAt', descending: false)` | `event_participant_service.dart:129-130` | 129-130 | ✅ **Índice 3** | Implementado |
| `.where('eventId', isEqualTo: eventId).where('userId', isEqualTo: userId).where('status', isEqualTo: 'registered')` | `event_participant_service.dart:174-176` | 174-176 | ✅ **Índice 4** | Implementado |
| `.where('eventId', isEqualTo: eventId).where('confirmationStatus', isEqualTo: 'pending')` | `event_participant_service.dart:363-364` | 363-364 | ✅ **Índice 2** | Implementado |
| `.where('eventId', isEqualTo: eventId).where('confirmationStatus', isEqualTo: 'confirmed')` | `event_participant_service.dart:385-386` | 385-386 | ✅ **Índice 2** | Implementado |
| `.where('eventId', isEqualTo: eventId).where('userId', isEqualTo: userId)` | `event_participant_service.dart:73-74, 222-223, 260-261, 407-408` | Múltiples | ✅ **Índice 5** | Implementado |

**✅ Índices implementados:**
- ✅ `event_participants`: `eventId` (ASC) + `registeredAt` (ASC)
- ✅ `event_participants`: `eventId` (ASC) + `userId` (ASC) + `status` (ASC)
- ✅ `event_participants`: `eventId` (ASC) + `userId` (ASC)

---

### **COLLECTION: `accommodations` (en `events`)**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.where('planId', isEqualTo: planId).where('typeFamily', isEqualTo: 'alojamiento').orderBy('checkIn')` | `accommodation_service.dart:12-14` | 12-14 | ✅ **Índice 3** | Implementado |
| `.where('planId', isEqualTo: planId).where('typeFamily', isEqualTo: 'alojamiento')` | `accommodation_service.dart:114-115` | 114-115 | ✅ No necesita índice | Solo `where` con igualdad |

**✅ Índices implementados:**
- ✅ `events`: `planId` (ASC) + `typeFamily` (ASC) + `checkIn` (ASC) - para alojamientos

---

### **COLLECTION: `personal_payments`**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.where('planId', isEqualTo: planId).orderBy('paymentDate', descending: true)` | `payment_service.dart:14-15` | 14-15 | ✅ Índice 1 | Usa índice existente |
| `.where('planId', isEqualTo: planId).where('participantId', isEqualTo: participantId).orderBy('paymentDate', descending: true)` | `payment_service.dart:31-33` | 31-33 | ✅ Índice 2 | Usa índice existente |
| `.where('eventId', isEqualTo: eventId).orderBy('paymentDate', descending: true)` | `payment_service.dart:46-47` | 46-47 | ✅ Índice 3 | Usa índice existente |

**✅ Todos los índices de `personal_payments` están correctos.**

---

### **COLLECTION: `participant_groups`**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.where('userId', isEqualTo: userId).orderBy('updatedAt', descending: true)` | `participant_group_service.dart:14-15` | 14-15 | ✅ **Índice 1** | Implementado |

**✅ Índices implementados:**
- ✅ `participant_groups`: `userId` (ASC) + `updatedAt` (DESC)

---

### **COLLECTION: `users`**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.where('isActive', isEqualTo: true).orderBy('createdAt', descending: true)` | `user_service.dart:223-224` | 223-224 | ✅ **Índice 1** | Implementado |
| `.where('displayName', isGreaterThanOrEqualTo: query).where('displayName', isLessThan: query + 'z').where('isActive', isEqualTo: true)` | `user_service.dart:240-242` | 240-242 | ✅ **Índice 2** | Implementado |
| `.where('userId', isEqualTo: userId)` | `user_service.dart:265, 271` | 265, 271 | ✅ No necesita índice | Solo `where` con igualdad |

**✅ Índices implementados:**
- ✅ `users`: `isActive` (ASC) + `createdAt` (DESC)
- ✅ `users`: `displayName` (ASC) + `isActive` (ASC) - para búsqueda por nombre

---

### **COLLECTION: `exchange_rates`**

| Query | Archivo | Línea | Índice Necesario | Estado |
|-------|---------|-------|------------------|--------|
| `.doc('latest').get()` | `exchange_rate_service.dart:20` | 20 | ✅ No necesita índice | Lectura directa por ID |

**✅ No necesita índices.**

---

## 📊 Resumen de Análisis

### ✅ Índices Correctos y Utilizados
- `plans`: 2/2 queries con índices ✅
- `events`: 3/3 queries con índices ✅
- `plan_participations`: 5/5 queries con índices ✅
- `planInvitations`: 4/4 queries con índices ✅
- `event_participants`: 5/5 queries con índices ✅
- `personal_payments`: 3/3 queries con índices ✅
- `participant_groups`: 1/1 query con índice ✅
- `users`: 2/2 queries con índices ✅

### ✅ Estado Actual de los Índices

**✅ TODOS LOS ÍNDICES HAN SIDO AÑADIDOS (25 índices totales)**

Todos los índices identificados como necesarios han sido añadidos al `firestore.indexes.json`:

**✅ Alta Prioridad (implementados):**
1. ✅ `events`: `planId` + `date` + `hour` - **CRÍTICO** (query principal de eventos)
2. ✅ `events`: `planId` + `isDraft` + `date` + `hour` - **CRÍTICO** (eventos confirmados)
3. ✅ `plan_participations`: `userId` + `isActive` + `joinedAt` (DESC) - **ALTA** (participaciones de usuario)
4. ✅ `events`: `planId` + `typeFamily` + `checkIn` - **ALTA** (alojamientos)

**✅ Media Prioridad (implementados):**
5. ✅ `plans`: `createdAt` (DESC) - para listado sin filtro
6. ✅ `plans`: `userId` + `createdAt` (DESC) - para planes de usuario
7. ✅ `plan_participations`: `planId` + `role` + `isActive` + `joinedAt` (ASC) - para participantes
8. ✅ `participant_groups`: `userId` + `updatedAt` (DESC)
9. ✅ `users`: `isActive` + `createdAt` (DESC)
10. ✅ `event_participants`: `eventId` + `registeredAt` (ASC) - para queries sin status

**✅ Baja Prioridad (implementados):**
11. ✅ `planInvitations`: `planId` + `email` + `status` - para verificar invitaciones duplicadas
12. ✅ `planInvitations`: `status` + `expiresAt` (ASC) - para limpieza de expiradas
13. ✅ `users`: `displayName` + `isActive` - para búsqueda de usuarios

---

## 🔄 Estado Actual y Próximos Pasos

### ✅ Completado
1. ✅ **Índices añadidos** al `firestore.indexes.json` (25 índices totales)
2. ✅ **Índices reorganizados** por colección para mejor legibilidad
3. ✅ **Documentación completa** de cada índice con su propósito (qué query lo utiliza)
4. ✅ **Proceso de revisión periódica** documentado

### ⚠️ Pendiente
1. ⚠️ **Desplegar índices a Firestore:**
   ```bash
   # Opción 1: Con Firebase CLI instalado
   firebase deploy --only firestore:indexes
   
   # Opción 2: Con npx (sin instalar globalmente)
   npx firebase-tools deploy --only firestore:indexes
   ```
   O desde Firebase Console → Firestore → Indexes

2. ⚠️ **Identificar y eliminar índices obsoletos en Firebase:**
   - Comparar índices en Firebase Console con los 25 definidos aquí
   - Eliminar índices que no estén en la lista de arriba
   - Ver instrucciones detalladas en `DEPLOY_INDICES_INSTRUCCIONES.md`

3. ⚠️ **Validar** que todas las queries funcionan correctamente después del despliegue
4. ⚠️ **Corregir discrepancia** de nombres de colecciones en Firestore Rules
   - `planParticipations` → `plan_participations`
   - `eventParticipants` → `event_participants`

---

## 📝 Notas Importantes

### Índices Automáticos de Firestore
Firestore crea automáticamente índices para:
- Queries con un solo `where` usando `isEqualTo` en un campo
- Campos simples sin `orderBy` o rangos

### Cuándo se Requiere Índice Compuesto
- Query con múltiples `where` + `orderBy`
- Query con `where` usando rangos (`isGreaterThan`, `isLessThan`) + `orderBy`
- Query con `orderBy` en múltiples campos

### Estrategia de Optimización
- **Priorizar índices de queries frecuentes** (eventos, participaciones)
- **Combinar índices cuando sea posible** (mismo patrón de query con variaciones)
- **Revisar periódicamente** después de nuevas funcionalidades

---

## ⚠️ DISCREPANCIAS ENCONTRADAS

### 1. Nombres de Colecciones

**Discrepancia entre Firestore Rules y Código:**

| Colección | En Código | En Firestore Rules | Estado |
|-----------|-----------|-------------------|--------|
| Participaciones | `plan_participations` | `planParticipations` | ⚠️ **DISCREPANCIA** |
| Participantes de eventos | `event_participants` | `eventParticipants` | ⚠️ **DISCREPANCIA** |

**Impacto:** Las reglas de Firestore para estas colecciones NO se aplicarán correctamente porque los nombres no coinciden.

**Acción requerida:** Actualizar Firestore Rules para usar `plan_participations` y `event_participants` (con guiones bajos) o actualizar el código para usar camelCase. **Recomendación:** Actualizar las reglas para coincidir con el código (usar guiones bajos).

---

## 📚 Colecciones Utilizadas en el Código

**Colecciones principales:**
1. `plans` - Planes de viaje
2. `events` - Eventos (colección principal, no subcolección)
3. `users` - Usuarios
4. `plan_participations` - Participaciones en planes
5. `event_participants` - Participantes por evento
6. `planInvitations` - Invitaciones por email
7. `personal_payments` - Pagos individuales
8. `participant_groups` - Grupos de participantes
9. `exchange_rates` - Tipos de cambio
10. `userPreferences` - Preferencias de usuario (subcolección de `users`)

**Subcolecciones (definidas en Rules pero no usadas como subcolecciones en código):**
- `plans/{planId}/events` - Definida en Rules pero el código usa `events` como colección principal
- `plans/{planId}/accommodations` - Definida en Rules pero no se usa
- `plans/{planId}/payments` - Definida en Rules pero no se usa
- `plans/{planId}/announcements` - Definida en Rules pero no se usa

**Nota importante:** El código usa `events` como colección principal (no como subcolección), pero las reglas de Firestore la definen como subcolección de `plans`. Esto podría ser un problema de seguridad.

---

## 📝 DOCUMENTACIÓN DE ÍNDICES

### Índices por Colección

#### **COLLECTION: `plans`**

| Índice | Campos | Propósito | Query que lo usa |
|--------|--------|-----------|------------------|
| 1 | `createdAt` (DESC) | Listar todos los planes ordenados por fecha | `plan_service.dart:19` |
| 2 | `userId` (ASC) + `createdAt` (DESC) | Listar planes de un usuario ordenados por fecha | `plan_service.dart:30-31` |

#### **COLLECTION: `events`**

| Índice | Campos | Propósito | Query que lo usa |
|--------|--------|-----------|------------------|
| 1 | `planId` (ASC) + `date` (ASC) + `hour` (ASC) | Eventos de un plan ordenados por fecha y hora | `event_service.dart:22-24, 45-46` |
| 2 | `planId` (ASC) + `isDraft` (ASC) + `date` (ASC) + `hour` (ASC) | Eventos confirmados de un plan ordenados | `event_service.dart:262-265, 283-285` |
| 3 | `planId` (ASC) + `typeFamily` (ASC) + `checkIn` (ASC) | Alojamientos de un plan ordenados por check-in | `accommodation_service.dart:12-14` |

#### **COLLECTION: `plan_participations`**

| Índice | Campos | Propósito | Query que lo usa |
|--------|--------|-----------|------------------|
| 1 | `planId` (ASC) + `isActive` (ASC) | Participaciones activas de un plan | `plan_participation_service.dart:15-16` |
| 2 | `userId` (ASC) + `isActive` (ASC) + `joinedAt` (DESC) | Participaciones de un usuario ordenadas | `plan_participation_service.dart:39-41` |
| 3 | `planId` (ASC) + `userId` (ASC) + `isActive` (ASC) | Verificar participación específica | `plan_participation_service.dart:65-67, 84-87` |
| 4 | `planId` (ASC) + `role` (ASC) + `isActive` (ASC) | Organizadores/participantes de un plan | `plan_participation_service.dart:244-246` |
| 5 | `planId` (ASC) + `role` (ASC) + `isActive` (ASC) + `joinedAt` (ASC) | Participantes ordenados por fecha | `plan_participation_service.dart:264-267` |

#### **COLLECTION: `planInvitations`**

| Índice | Campos | Propósito | Query que lo usa |
|--------|--------|-----------|------------------|
| 1 | `planId` (ASC) + `status` (ASC) + `createdAt` (DESC) | Invitaciones pendientes de un plan | `invitation_service.dart:280-282` |
| 2 | `token` (ASC) | Buscar invitación por token | `invitation_service.dart:127-128` |
| 3 | `planId` (ASC) + `email` (ASC) + `status` (ASC) | Verificar invitación duplicada | `invitation_service.dart:165-167` |
| 4 | `status` (ASC) + `expiresAt` (ASC) | Limpiar invitaciones expiradas | `invitation_service.dart:304-305` |

#### **COLLECTION: `event_participants`**

| Índice | Campos | Propósito | Query que lo usa |
|--------|--------|-----------|------------------|
| 1 | `eventId` (ASC) + `status` (ASC) + `registeredAt` (ASC) | Participantes registrados ordenados | `event_participant_service.dart:107-108, 152-153` |
| 2 | `eventId` (ASC) + `confirmationStatus` (ASC) | Confirmaciones pendientes/confirmadas | `event_participant_service.dart:363-364, 385-386` |
| 3 | `eventId` (ASC) + `registeredAt` (ASC) | Todos los participantes ordenados | `event_participant_service.dart:129-130` |
| 4 | `eventId` (ASC) + `userId` (ASC) + `status` (ASC) | Verificar registro de usuario | `event_participant_service.dart:174-176` |
| 5 | `eventId` (ASC) + `userId` (ASC) | Verificar participación/estado | `event_participant_service.dart:73-74, 222-223, 260-261, 407-408` |

#### **COLLECTION: `personal_payments`**

| Índice | Campos | Propósito | Query que lo usa |
|--------|--------|-----------|------------------|
| 1 | `planId` (ASC) + `paymentDate` (DESC) | Pagos de un plan ordenados por fecha | `payment_service.dart:14-15` |
| 2 | `planId` (ASC) + `participantId` (ASC) + `paymentDate` (DESC) | Pagos de un participante ordenados | `payment_service.dart:31-33` |
| 3 | `eventId` (ASC) + `paymentDate` (DESC) | Pagos de un evento ordenados | `payment_service.dart:46-47` |

#### **COLLECTION: `participant_groups`**

| Índice | Campos | Propósito | Query que lo usa |
|--------|--------|-----------|------------------|
| 1 | `userId` (ASC) + `updatedAt` (DESC) | Grupos de un usuario ordenados | `participant_group_service.dart:14-15` |

#### **COLLECTION: `users`**

| Índice | Campos | Propósito | Query que lo usa |
|--------|--------|-----------|------------------|
| 1 | `isActive` (ASC) + `createdAt` (DESC) | Usuarios activos ordenados | `user_service.dart:223-224` |
| 2 | `displayName` (ASC) + `isActive` (ASC) | Búsqueda de usuarios por nombre | `user_service.dart:240-242` |

---

## 🔄 PROCESO DE REVISIÓN PERIÓDICA

### Cuándo Revisar

1. **Después de añadir nueva funcionalidad** que incluya nuevas queries a Firestore
2. **Cada 3-6 meses** como mantenimiento preventivo
3. **Si se reciben errores** de "missing index" de Firestore
4. **Antes de releases importantes** para optimizar costes

### Pasos de Revisión

1. **Buscar nuevas queries:**
   ```bash
   grep -r "\.where\|\.orderBy" lib/ --include="*.dart"
   ```

2. **Verificar índices existentes:**
   - Revisar `firestore.indexes.json`
   - Comparar con queries en el código

3. **Identificar faltantes:**
   - Queries con `where` + `orderBy` necesitan índice compuesto
   - Queries con rangos (`isGreaterThan`, `isLessThan`) + `orderBy` necesitan índice

4. **Añadir índices faltantes:**
   - Actualizar `firestore.indexes.json`
   - Documentar en este archivo
   - Desplegar índices a Firestore (automático con Firebase CLI)

5. **Validar funcionamiento:**
   - Ejecutar queries del código
   - Verificar que no hay errores de "missing index"

6. **Actualizar documentación:**
   - Actualizar este archivo con nuevos índices
   - Documentar propósito de cada índice

### Checklist de Revisión

- [ ] Todas las queries con `where` + `orderBy` tienen índice
- [ ] Todas las queries con rangos tienen índice
- [ ] No hay índices redundantes sin queries asociadas
- [ ] Documentación actualizada
- [ ] Índices desplegados correctamente
- [ ] No hay errores de "missing index" en logs

---

---

## 🗑️ Identificación de Índices Obsoletos

### Índices Válidos (Únicos Permitidos)

Después del despliegue, **SOLO** deberían existir estos 25 índices en Firebase:

- Ver lista completa en: `docs/configuracion/INDICES_OBSOLETOS_VERIFICACION.md`

### Cómo Verificar Índices Obsoletos

1. **Ir a Firebase Console** → Firestore Database → Indexes
2. **Comparar** índices en Firebase con los 25 definidos en `firestore.indexes.json`
3. **Eliminar** cualquier índice que NO esté en la lista de 25 válidos

**⚠️ PRECAUCIÓN:** Antes de eliminar, verifica que realmente no se usa buscando en el código.

---

**Última actualización:** Enero 2025 (T152)

