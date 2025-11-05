# 📊 Comparación: Índices Existentes vs. Necesarios

> **Objetivo:** Comparar los índices actuales en Firebase con los 25 índices requeridos

---

## 📋 Instrucciones

1. **Ve a Firebase Console:**
   - [Firebase Console](https://console.firebase.google.com/) → Tu proyecto → Firestore Database → Indexes

2. **Copia la información de cada índice existente:**
   - Collection ID
   - Campos (fields) y su orden (Ascending/Descending)
   - Estado (Enabled, Building, Error)

3. **Rellena la tabla de abajo** con los índices que veas en Firebase

4. **Compara** con la lista de 25 índices requeridos para identificar:
   - ✅ Índices que ya existen
   - ❌ Índices que faltan crear
   - 🗑️ Índices obsoletos (existen en Firebase pero NO están en la lista de requeridos)

---

## 📝 Índices Actuales en Firebase

**Rellena esta sección con los índices que veas en Firebase Console:**

### Índice 1
- **Collection:** _______________
- **Campos:** _______________
- **Estado:** _______________

### Índice 2
- **Collection:** _______________
- **Campos:** _______________
- **Estado:** _______________

### Índice 3
- **Collection:** _______________
- **Campos:** _______________
- **Estado:** _______________

_(Continúa añadiendo más índices según veas en Firebase Console)_

---

## ✅ Índices Requeridos (25 totales)

### **COLLECTION: `plans`** (2 índices)

#### ✅ Índice Requerido 1: `plans` - `createdAt` (DESC)
- **Campos:** `createdAt` (Descending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 2: `plans` - `userId` + `createdAt`
- **Campos:** `userId` (Ascending) + `createdAt` (Descending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

---

### **COLLECTION: `events`** (3 índices)

#### ✅ Índice Requerido 3: `events` - `planId` + `date` + `hour`
- **Campos:** `planId` (Ascending) + `date` (Ascending) + `hour` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 4: `events` - `planId` + `isDraft` + `date` + `hour`
- **Campos:** `planId` (Ascending) + `isDraft` (Ascending) + `date` (Ascending) + `hour` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 5: `events` - `planId` + `typeFamily` + `checkIn`
- **Campos:** `planId` (Ascending) + `typeFamily` (Ascending) + `checkIn` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

---

### **COLLECTION: `plan_participations`** (5 índices)

#### ✅ Índice Requerido 6: `plan_participations` - `planId` + `isActive`
- **Campos:** `planId` (Ascending) + `isActive` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 7: `plan_participations` - `userId` + `isActive` + `joinedAt`
- **Campos:** `userId` (Ascending) + `isActive` (Ascending) + `joinedAt` (Descending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 8: `plan_participations` - `planId` + `userId` + `isActive`
- **Campos:** `planId` (Ascending) + `userId` (Ascending) + `isActive` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 9: `plan_participations` - `planId` + `role` + `isActive`
- **Campos:** `planId` (Ascending) + `role` (Ascending) + `isActive` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 10: `plan_participations` - `planId` + `role` + `isActive` + `joinedAt`
- **Campos:** `planId` (Ascending) + `role` (Ascending) + `isActive` (Ascending) + `joinedAt` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

---

### **COLLECTION: `planInvitations`** (4 índices)

#### ✅ Índice Requerido 11: `planInvitations` - `planId` + `status` + `createdAt`
- **Campos:** `planId` (Ascending) + `status` (Ascending) + `createdAt` (Descending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 12: `planInvitations` - `token`
- **Campos:** `token` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 13: `planInvitations` - `planId` + `email` + `status`
- **Campos:** `planId` (Ascending) + `email` (Ascending) + `status` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 14: `planInvitations` - `status` + `expiresAt`
- **Campos:** `status` (Ascending) + `expiresAt` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

---

### **COLLECTION: `event_participants`** (5 índices)

#### ✅ Índice Requerido 15: `event_participants` - `eventId` + `status` + `registeredAt`
- **Campos:** `eventId` (Ascending) + `status` (Ascending) + `registeredAt` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 16: `event_participants` - `eventId` + `confirmationStatus`
- **Campos:** `eventId` (Ascending) + `confirmationStatus` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 17: `event_participants` - `eventId` + `registeredAt`
- **Campos:** `eventId` (Ascending) + `registeredAt` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 18: `event_participants` - `eventId` + `userId` + `status`
- **Campos:** `eventId` (Ascending) + `userId` (Ascending) + `status` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 19: `event_participants` - `eventId` + `userId`
- **Campos:** `eventId` (Ascending) + `userId` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

---

### **COLLECTION: `personal_payments`** (3 índices)

#### ✅ Índice Requerido 20: `personal_payments` - `planId` + `paymentDate`
- **Campos:** `planId` (Ascending) + `paymentDate` (Descending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 21: `personal_payments` - `planId` + `participantId` + `paymentDate`
- **Campos:** `planId` (Ascending) + `participantId` (Ascending) + `paymentDate` (Descending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 22: `personal_payments` - `eventId` + `paymentDate`
- **Campos:** `eventId` (Ascending) + `paymentDate` (Descending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

---

### **COLLECTION: `participant_groups`** (1 índice)

#### ✅ Índice Requerido 23: `participant_groups` - `userId` + `updatedAt`
- **Campos:** `userId` (Ascending) + `updatedAt` (Descending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

---

### **COLLECTION: `users`** (2 índices)

#### ✅ Índice Requerido 24: `users` - `isActive` + `createdAt`
- **Campos:** `isActive` (Ascending) + `createdAt` (Descending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

#### ✅ Índice Requerido 25: `users` - `displayName` + `isActive`
- **Campos:** `displayName` (Ascending) + `isActive` (Ascending)
- **¿Existe en Firebase?** ⬜ Sí ⬜ No

---

## 📊 Resumen de Comparación

**Rellena después de comparar:**

- **Total de índices en Firebase:** _______
- **Índices que ya existen (✅):** _______
- **Índices que faltan crear (❌):** _______
- **Índices obsoletos a eliminar (🗑️):** _______

---

## 📝 Notas

- Si un índice tiene los mismos campos pero en diferente orden, Firebase lo considerará diferente. Verifica el orden exacto.
- Los índices con estado "Building" están en proceso de creación. Espera a que estén "Enabled".
- Los índices con estado "Error" tienen un problema y deben revisarse.

---

**Fecha:** _______________

