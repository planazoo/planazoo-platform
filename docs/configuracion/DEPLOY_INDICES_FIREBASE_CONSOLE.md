# 🚀 Guía: Desplegar Índices desde Firebase Console

> **Método:** Manual desde Firebase Console (Web UI)  
> **Objetivo:** Desplegar los 25 índices nuevos y eliminar obsoletos

---

## 📋 Índices a Crear (25 totales)

### **PASO 1: Abrir Firebase Console**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral, ve a **Firestore Database**
4. Haz clic en la pestaña **Indexes**

---

## 📝 PASO 2: Crear Índices (Uno por Uno)

**Nota:** Firebase puede crear algunos índices automáticamente cuando uses las queries. Si un índice ya existe, Firebase lo mostrará. Si falta, puedes crearlo manualmente.

### **COLLECTION: `plans`** (2 índices)

#### Índice 1: `createdAt` (DESC)
1. Haz clic en **"Add Index"** o **"Crear índice"**
2. **Collection ID:** `plans`
3. **Fields:**
   - Campo 1: `createdAt` → Orden: **Descending** ⬇️
4. Haz clic en **"Create"**

#### Índice 2: `userId` + `createdAt`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `plans`
3. **Fields:**
   - Campo 1: `userId` → Tipo: **Ascending** ⬆️
   - Campo 2: `createdAt` → Tipo: **Descending** ⬇️
4. Haz clic en **"Create"**

---

### **COLLECTION: `events`** (3 índices)

#### Índice 3: `planId` + `date` + `hour`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `events`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `date` → **Ascending** ⬆️
   - Campo 3: `hour` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 4: `planId` + `isDraft` + `date` + `hour`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `events`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `isDraft` → **Ascending** ⬆️
   - Campo 3: `date` → **Ascending** ⬆️
   - Campo 4: `hour` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 5: `planId` + `typeFamily` + `checkIn`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `events`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `typeFamily` → **Ascending** ⬆️
   - Campo 3: `checkIn` → **Ascending** ⬆️
4. Haz clic en **"Create"**

---

### **COLLECTION: `plan_participations`** (5 índices)

#### Índice 6: `planId` + `isActive`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `plan_participations`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `isActive` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 7: `userId` + `isActive` + `joinedAt`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `plan_participations`
3. **Fields:**
   - Campo 1: `userId` → **Ascending** ⬆️
   - Campo 2: `isActive` → **Ascending** ⬆️
   - Campo 3: `joinedAt` → **Descending** ⬇️
4. Haz clic en **"Create"**

#### Índice 8: `planId` + `userId` + `isActive`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `plan_participations`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `userId` → **Ascending** ⬆️
   - Campo 3: `isActive` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 9: `planId` + `role` + `isActive`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `plan_participations`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `role` → **Ascending** ⬆️
   - Campo 3: `isActive` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 10: `planId` + `role` + `isActive` + `joinedAt`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `plan_participations`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `role` → **Ascending** ⬆️
   - Campo 3: `isActive` → **Ascending** ⬆️
   - Campo 4: `joinedAt` → **Ascending** ⬆️
4. Haz clic en **"Create"**

---

### **COLLECTION: `planInvitations`** (4 índices)

#### Índice 11: `planId` + `status` + `createdAt`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `planInvitations`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `status` → **Ascending** ⬆️
   - Campo 3: `createdAt` → **Descending** ⬇️
4. Haz clic en **"Create"**

#### Índice 12: `token`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `planInvitations`
3. **Fields:**
   - Campo 1: `token` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 13: `planId` + `email` + `status`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `planInvitations`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `email` → **Ascending** ⬆️
   - Campo 3: `status` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 14: `status` + `expiresAt`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `planInvitations`
3. **Fields:**
   - Campo 1: `status` → **Ascending** ⬆️
   - Campo 2: `expiresAt` → **Ascending** ⬆️
4. Haz clic en **"Create"**

---

### **COLLECTION: `event_participants`** (5 índices)

#### Índice 15: `eventId` + `status` + `registeredAt`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `event_participants`
3. **Fields:**
   - Campo 1: `eventId` → **Ascending** ⬆️
   - Campo 2: `status` → **Ascending** ⬆️
   - Campo 3: `registeredAt` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 16: `eventId` + `confirmationStatus`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `event_participants`
3. **Fields:**
   - Campo 1: `eventId` → **Ascending** ⬆️
   - Campo 2: `confirmationStatus` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 17: `eventId` + `registeredAt`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `event_participants`
3. **Fields:**
   - Campo 1: `eventId` → **Ascending** ⬆️
   - Campo 2: `registeredAt` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 18: `eventId` + `userId` + `status`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `event_participants`
3. **Fields:**
   - Campo 1: `eventId` → **Ascending** ⬆️
   - Campo 2: `userId` → **Ascending** ⬆️
   - Campo 3: `status` → **Ascending** ⬆️
4. Haz clic en **"Create"**

#### Índice 19: `eventId` + `userId`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `event_participants`
3. **Fields:**
   - Campo 1: `eventId` → **Ascending** ⬆️
   - Campo 2: `userId` → **Ascending** ⬆️
4. Haz clic en **"Create"**

---

### **COLLECTION: `personal_payments`** (3 índices)

#### Índice 20: `planId` + `paymentDate`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `personal_payments`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `paymentDate` → **Descending** ⬇️
4. Haz clic en **"Create"**

#### Índice 21: `planId` + `participantId` + `paymentDate`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `personal_payments`
3. **Fields:**
   - Campo 1: `planId` → **Ascending** ⬆️
   - Campo 2: `participantId` → **Ascending** ⬆️
   - Campo 3: `paymentDate` → **Descending** ⬇️
4. Haz clic en **"Create"**

#### Índice 22: `eventId` + `paymentDate`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `personal_payments`
3. **Fields:**
   - Campo 1: `eventId` → **Ascending** ⬆️
   - Campo 2: `paymentDate` → **Descending** ⬇️
4. Haz clic en **"Create"**

---

### **COLLECTION: `participant_groups`** (1 índice)

#### Índice 23: `userId` + `updatedAt`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `participant_groups`
3. **Fields:**
   - Campo 1: `userId` → **Ascending** ⬆️
   - Campo 2: `updatedAt` → **Descending** ⬇️
4. Haz clic en **"Create"**

---

### **COLLECTION: `users`** (2 índices)

#### Índice 24: `isActive` + `createdAt`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `users`
3. **Fields:**
   - Campo 1: `isActive` → **Ascending** ⬆️
   - Campo 2: `createdAt` → **Descending** ⬇️
4. Haz clic en **"Create"**

#### Índice 25: `displayName` + `isActive`
1. Haz clic en **"Add Index"**
2. **Collection ID:** `users`
3. **Fields:**
   - Campo 1: `displayName` → **Ascending** ⬆️
   - Campo 2: `isActive` → **Ascending** ⬆️
4. Haz clic en **"Create"**

---

## ✅ PASO 3: Verificar Estado de los Índices

Después de crear los índices:

1. En la lista de índices, verifica el **estado** de cada uno:
   - 🟡 **Building** → Se está creando, espera unos minutos
   - 🟢 **Enabled** → Listo para usar ✅
   - 🔴 **Error** → Hay un problema, revisa la configuración

2. **Espera** a que todos los índices estén en estado **"Enabled"** antes de usar la app (puede tardar 5-15 minutos dependiendo de la cantidad de datos)

---

## 🗑️ PASO 4: Identificar y Eliminar Índices Obsoletos

### ¿Qué índices son obsoletos?

**Índices obsoletos = Índices que están en Firebase pero NO están en la lista de arriba**

### Proceso:

1. **En Firebase Console** → Firestore Database → Indexes
2. **Revisa la lista completa** de índices actuales
3. **Para cada índice:**
   - ¿Está en la lista de 25 índices de arriba? → ✅ **Mantener**
   - ¿NO está en la lista? → ❌ **Probablemente obsoleto**

### Antes de Eliminar un Índice Obsoleto:

**⚠️ PRECAUCIÓN:** Verifica que realmente no se usa:

1. **Abre el índice** para ver sus campos
2. **Busca en el código** si hay alguna query que use esos campos exactos
3. **Si no encuentras ninguna query** que lo use → Probablemente obsoleto
4. **Si encuentras una query** que lo usa → NO eliminar, dejarlo

### Eliminar Índice Obsoleto:

1. Haz clic en el índice obsoleto
2. Haz clic en el botón **"Delete"** o **"Eliminar"** (ícono de papelera 🗑️)
3. Confirma la eliminación

**⚠️ IMPORTANTE:**
- Los índices no usados NO consumen recursos activos
- Si eliminas un índice por error, puedes recrearlo fácilmente
- Si tienes dudas, es mejor dejarlo que eliminarlo

---

## 📊 Resumen Final

Después de completar todos los pasos, deberías tener:

- ✅ **Exactamente 25 índices** en Firebase
- ✅ Todos los índices en estado **"Enabled"**
- ✅ Sin índices obsoletos (o solo los que no estás seguro)
- ✅ Todos los índices coinciden con `firestore.indexes.json`

---

## 💡 Consejos

1. **Tiempo:** Los índices pueden tardar varios minutos en crearse. No te preocupes si ves "Building".

2. **Orden:** Puedes crear los índices en cualquier orden. Firebase los procesa en paralelo.

3. **Duplicados:** Si intentas crear un índice que ya existe, Firebase te avisará.

4. **Autocreación:** Algunos índices se crearán automáticamente cuando uses la app y Firebase detecte que falta uno. Esto es normal.

5. **Verificación:** Después de crear todos, cuenta los índices para asegurarte de que tienes exactamente 25.

---

## 📝 Checklist

- [ ] Crear 2 índices de `plans`
- [ ] Crear 3 índices de `events`
- [ ] Crear 5 índices de `plan_participations`
- [ ] Crear 4 índices de `planInvitations`
- [ ] Crear 5 índices de `event_participants`
- [ ] Crear 3 índices de `personal_payments`
- [ ] Crear 1 índice de `participant_groups`
- [ ] Crear 2 índices de `users`
- [ ] Verificar que hay exactamente 25 índices en total
- [ ] Esperar a que todos estén en estado "Enabled"
- [ ] Revisar índices obsoletos
- [ ] Eliminar índices obsoletos (solo si estás seguro)
- [ ] Probar la app para verificar que funciona correctamente

---

**Fecha:** Enero 2025  
**Relacionado con:** T152

