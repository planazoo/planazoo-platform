# 🔄 Migración de Reglas de Firestore

> Análisis de reglas actuales vs nuevas y plan de migración

**Fecha:** Enero 2025

---

## 📊 Comparación: Reglas Actuales vs Nuevas

### Reglas Actuales en Firebase (Producción)

**Estado:** ⚠️ MUY PERMISIVAS - Reglas de desarrollo/test

**Características:**
- Permiten **todo** (`allow read, write: if true`)
- Colecciones obsoletas: `event_hours`, `test`, `planazoos`
- No hay validaciones de seguridad
- No hay restricciones de acceso

**Problemas:**
- ❌ Cualquier usuario puede leer/escribir cualquier dato
- ❌ No hay validación de ownership
- ❌ No hay validación de estructura de datos
- ❌ Colecciones obsoletas sin uso

### Reglas Nuevas (firestore.rules)

**Estado:** ✅ SEGURAS - Reglas de producción

**Características:**
- Autenticación requerida
- Validación de ownership (solo owner puede modificar)
- Validación de estructura de datos
- Reglas específicas por colección
- Restricciones de acceso según roles

**Ventajas:**
- ✅ Seguridad adecuada
- ✅ Validaciones de datos
- ✅ Control de acceso granular
- ✅ Reglas para todas las colecciones en uso

---

## ⚠️ ADVERTENCIA: Cambio de Reglas Permisivas a Restrictivas

### Impacto del Cambio

**Reglas actuales:** `allow read, write: if true` (TODO permitido)  
**Reglas nuevas:** Restricciones estrictas de acceso

**Riesgo:** Si alguna funcionalidad de la app depende de las reglas permisivas, podría dejar de funcionar.

### Verificación Necesaria ANTES de Desplegar

1. ✅ **Verificar que la app funciona con autenticación:**
   - Todos los usuarios deben estar autenticados
   - No hay operaciones anónimas

2. ✅ **Verificar estructura de datos:**
   - Los documentos tienen la estructura esperada
   - Los campos requeridos existen

3. ✅ **Verificar ownership:**
   - Los planes tienen `userId` correcto
   - Las participaciones tienen `planId` y `userId` correctos

---

## 📋 Plan de Migración Seguro

### Opción 1: Migración Gradual (Recomendado)

**Paso 1: Desplegar reglas nuevas con modo de prueba**
- Desplegar reglas nuevas
- Probar en desarrollo/staging
- Verificar que todo funciona

**Paso 2: Verificar en producción**
- Desplegar reglas
- Monitorear errores
- Rollback si es necesario

### Opción 2: Migración Directa (Rápido, más riesgo)

**Paso único:**
- Desplegar reglas nuevas directamente
- Verificar funcionamiento inmediatamente

---

## 🔍 Reglas a Eliminar (Obsoletas)

### Colecciones que NO existen en el código:

1. **`event_hours`** - ❌ No se usa
2. **`test`** - ❌ No se usa
3. **`planazoos`** - ❌ No se usa (la correcta es `plans`)

**Acción:** Estas reglas pueden eliminarse de forma segura.

---

## 🔧 Reglas Nuevas a Añadir

### 1. Reglas para `plan_permissions` (NUEVAS)

```javascript
match /plan_permissions/{permissionId} {
  // Solo owner del plan puede asignar permisos
  allow create: if isAuthenticated() && 
                   isValidPlanPermissionData() &&
                   isPlanOwner(request.resource.data.planId);
  
  // Usuario puede leer sus permisos, owner puede leer todos
  allow read: if isAuthenticated() && (
                   resource.data.userId == request.auth.uid ||
                   isPlanOwner(resource.data.planId)
                 );
  
  // Solo owner puede actualizar
  allow update: if isAuthenticated() && 
                   isPlanOwner(resource.data.planId);
  
  // Solo owner puede eliminar
  allow delete: if isAuthenticated() && 
                   isPlanOwner(resource.data.planId);
}
```

### 2. Corrección de nombre: `plan_participations`

**Cambio:** `planParticipations` → `plan_participations` (para coincidir con el código)

---

## ✅ Checklist Pre-Migración

Antes de desplegar las nuevas reglas, verificar:

- [ ] Todos los usuarios de la app están autenticados
- [ ] No hay operaciones de lectura/escritura anónimas
- [ ] Los planes tienen campo `userId` correcto
- [ ] Las participaciones tienen `planId` y `userId` correctos
- [ ] Los eventos tienen `planId` y `userId` correctos
- [ ] Se ha probado la app en modo desarrollo con las nuevas reglas

---

## 🚀 Pasos para Desplegar

1. **Backup de reglas actuales:**
   - Copiar reglas actuales de Firebase Console
   - Guardar en un archivo de backup

2. **Desplegar nuevas reglas:**
   - Copiar contenido completo de `firestore.rules`
   - Pegar en Firebase Console → Firestore → Rules
   - **NO publicar aún** - solo verificar sintaxis

3. **Verificar sintaxis:**
   - Firebase Console mostrará errores si los hay
   - Corregir cualquier error antes de publicar

4. **Publicar:**
   - Click en "Publicar"
   - Monitorear errores en la app inmediatamente

5. **Rollback si es necesario:**
   - Si hay problemas, restaurar reglas anteriores desde el backup

---

## 📝 Notas de Seguridad

### Reglas Actuales (Producción):
- ⚠️ **MUY PELIGROSAS** - Permiten acceso total sin autenticación
- ⚠️ **NO SEGURAS** - Cualquiera puede leer/escribir datos
- ⚠️ **DE DESARROLLO** - Parecen reglas de test

### Reglas Nuevas:
- ✅ **SEGURAS** - Requieren autenticación
- ✅ **VALIDADAS** - Verifican estructura de datos
- ✅ **RESTRICTIVAS** - Control de acceso por ownership
- ✅ **PRODUCCIÓN** - Listas para producción

---

## ⚠️ Recomendación Final

**ANTES de desplegar:**

1. **Probar en un entorno de desarrollo** si es posible
2. **Verificar que la app funciona** con usuarios autenticados
3. **Tener un plan de rollback** listo
4. **Desplegar en horario de bajo tráfico** si es posible

**Las nuevas reglas son MUCHO más seguras que las actuales**, pero el cambio de reglas tan permisivas a restrictivas puede requerir verificación.

---

**Última actualización:** Enero 2025

