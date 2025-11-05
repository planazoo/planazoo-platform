# 🗑️ Guía para Identificar y Eliminar Índices Obsoletos

> **Objetivo:** Identificar índices en Firebase que no están en `firestore.indexes.json` y eliminarlos

---

## 📋 Índices Válidos (25 totales - Definidos en firestore.indexes.json)

Después de desplegar, estos son los **ÚNICOS** índices que deberían existir en Firebase:

### **COLLECTION: `plans`** (2 índices)
1. `createdAt` (DESC)
2. `userId` (ASC) + `createdAt` (DESC)

### **COLLECTION: `events`** (3 índices)
3. `planId` (ASC) + `date` (ASC) + `hour` (ASC)
4. `planId` (ASC) + `isDraft` (ASC) + `date` (ASC) + `hour` (ASC)
5. `planId` (ASC) + `typeFamily` (ASC) + `checkIn` (ASC)

### **COLLECTION: `plan_participations`** (5 índices)
6. `planId` (ASC) + `isActive` (ASC)
7. `userId` (ASC) + `isActive` (ASC) + `joinedAt` (DESC)
8. `planId` (ASC) + `userId` (ASC) + `isActive` (ASC)
9. `planId` (ASC) + `role` (ASC) + `isActive` (ASC)
10. `planId` (ASC) + `role` (ASC) + `isActive` (ASC) + `joinedAt` (ASC)

### **COLLECTION: `planInvitations`** (4 índices)
11. `planId` (ASC) + `status` (ASC) + `createdAt` (DESC)
12. `token` (ASC)
13. `planId` (ASC) + `email` (ASC) + `status` (ASC)
14. `status` (ASC) + `expiresAt` (ASC)

### **COLLECTION: `event_participants`** (5 índices)
15. `eventId` (ASC) + `status` (ASC) + `registeredAt` (ASC)
16. `eventId` (ASC) + `confirmationStatus` (ASC)
17. `eventId` (ASC) + `registeredAt` (ASC)
18. `eventId` (ASC) + `userId` (ASC) + `status` (ASC)
19. `eventId` (ASC) + `userId` (ASC)

### **COLLECTION: `personal_payments`** (3 índices)
20. `planId` (ASC) + `paymentDate` (DESC)
21. `planId` (ASC) + `participantId` (ASC) + `paymentDate` (DESC)
22. `eventId` (ASC) + `paymentDate` (DESC)

### **COLLECTION: `participant_groups`** (1 índice)
23. `userId` (ASC) + `updatedAt` (DESC)

### **COLLECTION: `users`** (2 índices)
24. `isActive` (ASC) + `createdAt` (DESC)
25. `displayName` (ASC) + `isActive` (ASC)

---

## 🔍 Cómo Identificar Índices Obsoletos

### Paso 1: Ver Índices Actuales en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Firestore Database** → **Indexes**
4. Verás una lista de todos los índices actuales

### Paso 2: Comparar con la Lista de Arriba

Para cada índice en Firebase Console, verifica:
- ✅ **Está en la lista de arriba** → Mantener
- ❌ **NO está en la lista de arriba** → Probablemente obsoleto

### Paso 3: Verificar antes de Eliminar

Antes de eliminar un índice, verifica:

1. **¿Es de una colección que todavía existe?**
   - Si la colección no existe, el índice es seguro eliminarlo
   - Si la colección existe, revisa el paso 2

2. **¿Hay queries en el código que lo usen?**
   - Busca en el código si hay queries que coincidan con los campos del índice
   - Si no encuentras ninguna query que lo use → Probablemente obsoleto

3. **¿Cuándo fue creado?**
   - Si es muy antiguo y no está en la lista → Probablemente obsoleto

---

## 🗑️ Cómo Eliminar Índices Obsoletos

### Desde Firebase Console

1. Ve a **Firestore Database** → **Indexes**
2. Para cada índice obsoleto:
   - Haz clic en el índice para ver sus detalles
   - Haz clic en **"Delete"** o **"Eliminar"** (ícono de papelera)
   - Confirma la eliminación

**⚠️ PRECAUCIÓN:**
- **NO elimines** un índice si no estás 100% seguro de que no se usa
- Si tienes dudas, déjalo (los índices no usados no consumen recursos activos)
- Puedes recrear un índice eliminado por error, pero requiere tiempo

---

## 📝 Ejemplos de Índices que PODRÍAN ser Obsoletos

### Índices de Colecciones que ya no Existen
- Si en algún momento tuviste una colección que ya no usas, sus índices pueden estar obsoletos

### Índices con Campos que ya no se Usan
- Si cambiaste la estructura de datos y eliminaste campos, los índices que usan esos campos son obsoletos

### Índices Antiguos de Versiones Previas
- Índices creados para funcionalidades que luego refactorizaste o eliminaste

---

## ✅ Checklist de Limpieza

- [ ] Desplegar los 25 índices nuevos a Firebase
- [ ] Esperar a que todos estén en estado "Enabled" (puede tardar varios minutos)
- [ ] Listar todos los índices actuales en Firebase Console
- [ ] Comparar con la lista de 25 índices válidos
- [ ] Identificar índices obsoletos (los que no están en la lista)
- [ ] Verificar que los índices obsoletos realmente no se usan
- [ ] Eliminar índices obsoletos (solo si estás seguro)
- [ ] Probar la app para verificar que todo funciona correctamente

---

## 🎯 Resultado Esperado

Después de completar la limpieza, deberías tener:
- ✅ Exactamente **25 índices** en Firebase
- ✅ Todos los índices en estado **"Enabled"**
- ✅ Sin índices obsoletos
- ✅ Todas las queries de la app funcionando correctamente

---

**Nota:** Si encuentras índices que no estás seguro si eliminar, déjalos. Es mejor tener índices extra que eliminar uno que se está usando.

**Fecha:** Enero 2025  
**Relacionado con:** T152

