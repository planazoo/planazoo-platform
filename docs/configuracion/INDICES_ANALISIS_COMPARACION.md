# 📊 Análisis: Índices Existentes vs. Requeridos

> **Fecha de análisis:** Enero 2025  
> **Índices existentes en Firebase:** 9  
> **Índices requeridos:** 25

---

## 📋 Índices Existentes en Firebase (9 totales)

### ✅ Índices Válidos (Correctos y Necesarios)

#### 1. ✅ `events` - `planId` + `typeFamily` + `checkIn`
- **Status:** Enabled
- **Corresponde a:** Índice Requerido #5
- **Acción:** ✅ Mantener

#### 2. ✅ `events` - `planId` + `date` + `hour`
- **Status:** Enabled
- **Corresponde a:** Índice Requerido #3
- **Acción:** ✅ Mantener

#### 3. ✅ `event_participants` - `eventId` + `status` + `registeredAt`
- **Status:** Enabled
- **Corresponde a:** Índice Requerido #15
- **Acción:** ✅ Mantener

#### 4. ⚠️ `users` - `displayName` + `IsActive`
- **Status:** Enabled
- **Problema:** Campo `IsActive` (con mayúscula) → debería ser `isActive` (minúscula)
- **Corresponde a:** Índice Requerido #25 (pero con nombre de campo incorrecto)
- **Acción:** ⚠️ Verificar si funciona. Si no, crear nuevo con `isActive` correcto.

#### 5. ⚠️ `users` - `createdAt` + `IsActive`
- **Status:** Enabled
- **Problema:** Campo `IsActive` (con mayúscula) → debería ser `isActive` (minúscula)
- **Corresponde a:** Índice Requerido #24 (pero con nombre de campo incorrecto)
- **Acción:** ⚠️ Verificar si funciona. Si no, crear nuevo con `isActive` correcto.

#### 6. ⚠️ `plan_participations` - `isActive` + `planID` + `joinedAt`
- **Status:** Enabled
- **Problema:** Campo `planID` (con mayúscula) → debería ser `planId` (camelCase)
- **Query Scope:** Collection group (esto es correcto)
- **Corresponde a:** Similar a Índice Requerido #7, pero con nombre de campo incorrecto
- **Acción:** ⚠️ Verificar si funciona. Probablemente necesita recrearse con `planId` correcto.

---

### ❌ Índices Obsoletos o Incorrectos (Eliminar)

#### 7. ❌ `Hours` - `horaFecha` + `horaNum`
- **Status:** Enabled
- **Problema:** La colección `Hours` NO existe en el código actual
- **Acción:** 🗑️ **ELIMINAR** (colección obsoleta)

#### 8. ❌ `users` - `email` + `isActive`
- **Status:** Enabled
- **Problema:** Este índice NO está en la lista de 25 requeridos. No hay queries en el código que usen `email` + `isActive`.
- **Acción:** 🗑️ **ELIMINAR** (no se usa en el código)

#### 9. ❌ `users` - `planId` + `date` + `hour`
- **Status:** Enabled
- **Problema:** 
  - La colección `users` NO tiene campos `planId`, `date`, `hour`
  - Estos campos pertenecen a `events`, no a `users`
  - Este índice parece ser un error o índice creado incorrectamente
- **Acción:** 🗑️ **ELIMINAR** (índice incorrecto/error)

---

## 📊 Resumen de Comparación

### Índices Existentes: 9
- ✅ **Válidos y correctos:** 3
- ⚠️ **Válidos pero con problemas de nomenclatura:** 3
- ❌ **Obsoletos/Incorrectos:** 3

### Índices Requeridos: 25
- ✅ **Ya existen y correctos:** 3
- ⚠️ **Existen pero con problemas:** 3 (pueden funcionar o no dependiendo de si Firebase es case-sensitive)
- ❌ **Faltan crear:** 22

---

## 🗑️ Índices a Eliminar (3 totales)

1. **`Hours` - `horaFecha` + `horaNum`**
   - Razón: Colección obsoleta que no existe en el código

2. **`users` - `email` + `isActive`**
   - Razón: No se usa en ninguna query del código

3. **`users` - `planId` + `date` + `hour`**
   - Razón: Índice incorrecto - estos campos no existen en la colección `users`

---

## ✅ Índices a Crear (22 faltantes)

### **COLLECTION: `plans`** (2 índices - FALTAN AMBOS)

1. ❌ `plans` - `createdAt` (DESC)
2. ❌ `plans` - `userId` + `createdAt` (DESC)

### **COLLECTION: `events`** (3 índices - 2 EXISTEN, 1 FALTA)

3. ✅ `events` - `planId` + `date` + `hour` (YA EXISTE)
4. ❌ `events` - `planId` + `isDraft` + `date` + `hour` (FALTA)
5. ✅ `events` - `planId` + `typeFamily` + `checkIn` (YA EXISTE)

### **COLLECTION: `plan_participations`** (5 índices - 0 CORRECTOS, 1 CON PROBLEMA)

6. ❌ `plan_participations` - `planId` + `isActive` (FALTA)
7. ⚠️ `plan_participations` - `userId` + `isActive` + `joinedAt` (EXISTE PERO CON `planID` en lugar de `planId`)
8. ❌ `plan_participations` - `planId` + `userId` + `isActive` (FALTA)
9. ❌ `plan_participations` - `planId` + `role` + `isActive` (FALTA)
10. ❌ `plan_participations` - `planId` + `role` + `isActive` + `joinedAt` (FALTA)

### **COLLECTION: `planInvitations`** (4 índices - FALTAN TODOS)

11. ❌ `planInvitations` - `planId` + `status` + `createdAt` (DESC)
12. ❌ `planInvitations` - `token`
13. ❌ `planInvitations` - `planId` + `email` + `status`
14. ❌ `planInvitations` - `status` + `expiresAt`

### **COLLECTION: `event_participants`** (5 índices - 1 EXISTE, 4 FALTAN)

15. ✅ `event_participants` - `eventId` + `status` + `registeredAt` (YA EXISTE)
16. ❌ `event_participants` - `eventId` + `confirmationStatus` (FALTA)
17. ❌ `event_participants` - `eventId` + `registeredAt` (FALTA)
18. ❌ `event_participants` - `eventId` + `userId` + `status` (FALTA)
19. ❌ `event_participants` - `eventId` + `userId` (FALTA)

### **COLLECTION: `personal_payments`** (3 índices - FALTAN TODOS)

20. ❌ `personal_payments` - `planId` + `paymentDate` (DESC)
21. ❌ `personal_payments` - `planId` + `participantId` + `paymentDate` (DESC)
22. ❌ `personal_payments` - `eventId` + `paymentDate` (DESC)

### **COLLECTION: `participant_groups`** (1 índice - FALTA)

23. ❌ `participant_groups` - `userId` + `updatedAt` (DESC)

### **COLLECTION: `users`** (2 índices - 2 EXISTEN PERO CON PROBLEMAS)

24. ⚠️ `users` - `isActive` + `createdAt` (DESC) (EXISTE PERO CON `IsActive` en lugar de `isActive`)
25. ⚠️ `users` - `displayName` + `isActive` (EXISTE PERO CON `IsActive` en lugar de `isActive`)

---

## ⚠️ Notas Importantes

### Problemas de Nomenclatura

1. **`IsActive` vs `isActive`:** 
   - Firebase es case-sensitive en nombres de campos
   - Si el código usa `isActive` (minúscula) pero el índice tiene `IsActive` (mayúscula), el índice puede no funcionar
   - **Recomendación:** Verificar si estos índices funcionan. Si dan errores, recrearlos con la nomenclatura correcta.

2. **`planID` vs `planId`:**
   - Similar al caso anterior. El código usa `planId` (camelCase estándar)
   - **Recomendación:** Verificar si el índice funciona. Probablemente necesita recrearse con `planId`.

### Verificación de Índices con Problemas

Antes de eliminar los índices con problemas de nomenclatura, verifica:
1. ¿Funcionan las queries que los usan?
2. Si funcionan, déjalos (Firebase puede ser flexible en algunos casos)
3. Si no funcionan o dan errores, elimínalos y créalos con la nomenclatura correcta

---

## ✅ Plan de Acción Recomendado

### Paso 1: Eliminar Índices Obsoletos (3)
1. Eliminar `Hours` - `horaFecha` + `horaNum`
2. Eliminar `users` - `email` + `isActive`
3. Eliminar `users` - `planId` + `date` + `hour`

### Paso 2: Verificar Índices con Problemas (3)
1. Probar si `users` - `IsActive` + `createdAt` funciona
2. Probar si `users` - `displayName` + `IsActive` funciona
3. Probar si `plan_participations` - `planID` + `isActive` + `joinedAt` funciona

**Si no funcionan:**
- Eliminarlos y recrearlos con la nomenclatura correcta

**Si funcionan:**
- Dejarlos (aunque es mejor mantener consistencia con el código)

### Paso 3: Crear Índices Faltantes (22)
- Seguir la guía en `DEPLOY_INDICES_FIREBASE_CONSOLE.md`
- Crear los 22 índices que faltan

### Resultado Final Esperado
- **25 índices** en total
- Todos con nomenclatura correcta
- Todos en estado "Enabled"

---

**Nota:** La actualización de índices se realizará durante la migración a Mac/iOS (T156). Ver TASKS.md para más detalles.

**Última actualización:** Enero 2025

