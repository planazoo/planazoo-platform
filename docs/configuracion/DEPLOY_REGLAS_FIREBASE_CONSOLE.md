# 📝 Desplegar Reglas de Firestore Manualmente desde Firebase Console

> Guía para desplegar las reglas actualizadas sin usar Firebase CLI

**Fecha:** Enero 2025  
**Motivo:** Firebase CLI no está instalado en Windows (se instalará durante migración a Mac - T155)

---

## 🎯 Objetivo

Desplegar las reglas actualizadas de Firestore que incluyen:
- ✅ Reglas para `plan_permissions` (nuevas)
- ✅ Corrección de nombre de colección `plan_participations`

---

## 📋 Pasos para Desplegar Reglas

### Paso 1: Abrir Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto: **planazoo**

### Paso 2: Navegar a Firestore Rules

1. En el menú lateral izquierdo, busca **"Firestore Database"**
2. Click en **"Firestore Database"**
3. Click en la pestaña **"Rules"** (Reglas)

### Paso 3: Copiar Reglas Actualizadas

1. Abre el archivo `firestore.rules` del proyecto en tu editor
2. Selecciona **TODO** el contenido (Ctrl+A)
3. Copia el contenido (Ctrl+C)

### Paso 4: Pegar y Publicar

1. En Firebase Console, en el editor de reglas:
   - Selecciona todo el contenido existente
   - Pega las nuevas reglas (Ctrl+V)
2. Verifica que las reglas incluyen:
   - Sección para `plan_permissions` (líneas 469-516)
   - `match /plan_participations/` (no `planParticipations`)
3. Click en **"Publicar"** (o "Publish")

### Paso 5: Verificar

1. Después de publicar, Firebase mostrará un mensaje de confirmación
2. Las reglas deberían aparecer como "Publicadas" con la fecha/hora actual

---

## ✅ Verificación de Reglas Añadidas

### Reglas que deberían estar presentes:

1. **Reglas para `plan_permissions`** (nuevas):
   ```
   match /plan_permissions/{permissionId} {
     // Validar estructura de datos
     function isValidPlanPermissionData() {
       ...
     }
     ...
   }
   ```

2. **Reglas para `plan_participations`** (corregidas):
   ```
   match /plan_participations/{participationId} {
     // (no debe ser planParticipations)
     ...
   }
   ```

---

## 🔍 Verificar que Funciona

### Después de desplegar:

1. **Probar lectura de permisos:**
   - Abre la app
   - Intenta acceder a un plan donde tienes permisos
   - Debería funcionar sin errores de permisos

2. **Verificar en consola de Firebase:**
   - Ve a Firestore Database → Rules
   - Verifica que las reglas muestran la fecha de publicación reciente

---

## ⚠️ Notas Importantes

1. **Firebase CLI:** Se instalará durante la migración a Mac (T155)
2. **Despliegues futuros:** Por ahora, todos los cambios de reglas deben hacerse manualmente
3. **Backup:** Firebase mantiene un historial de reglas, pero puedes copiar las reglas actuales antes de cambiar si prefieres

---

## 📚 Referencias

- **Archivo de reglas:** `firestore.rules` (raíz del proyecto)
- **Auditoría de colecciones:** `docs/configuracion/FIRESTORE_COLLECTIONS_AUDIT.md`
- **Tareas relacionadas:** T155 (Instalación Firebase CLI en Mac)

---

## 🐛 Solución de Problemas

### Error: "Las reglas no se pueden publicar"

**Causa común:** Error de sintaxis en las reglas

**Solución:**
1. Verifica que el archivo `firestore.rules` no tenga errores de sintaxis
2. Firebase Console mostrará errores de sintaxis en rojo
3. Corrige los errores antes de publicar

### Error: "Permiso denegado"

**Causa común:** No tienes permisos de administrador en el proyecto

**Solución:**
- Verifica que estás logueado con una cuenta que tiene permisos de administrador
- Contacta al administrador del proyecto si es necesario

---

**Última actualización:** Enero 2025

