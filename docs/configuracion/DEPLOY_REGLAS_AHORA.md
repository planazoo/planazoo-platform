# 🚀 Desplegar Reglas de Firestore - Ahora

> Guía rápida para desplegar las reglas actualizadas

**Fecha:** Enero 2025

---

## 📋 Pasos Rápidos

### 1. Abrir Firebase Console

1. Ve a: https://console.firebase.google.com/
2. Selecciona proyecto: **planazoo**

### 2. Ir a Firestore Rules

1. Menú lateral → **Firestore Database**
2. Click en pestaña **"Rules"**

### 3. Copiar Reglas Nuevas

1. Abre el archivo `firestore.rules` en tu editor
2. **Selecciona TODO** (Ctrl+A)
3. **Copia** (Ctrl+C)

### 4. Pegar y Publicar

1. En Firebase Console, en el editor de reglas:
   - **Selecciona TODO** el contenido actual
   - **Pega** las nuevas reglas (Ctrl+V)
2. Firebase validará la sintaxis automáticamente
3. Si no hay errores, click en **"Publicar"**

### 5. Verificar

1. Después de publicar, verás un mensaje de confirmación
2. Las reglas mostrarán fecha/hora de publicación actualizada

---

## ✅ Verificación Post-Despliegue

### Pruebas Inmediatas:

1. **Abrir la app**
2. **Verificar login** - Debe funcionar
3. **Abrir un plan** - Debe cargar correctamente
4. **Crear un evento** - Debe funcionar
5. **Verificar permisos** - Debe funcionar

### Si algo falla:

1. **Rollback inmediato:**
   - Copiar reglas anteriores (backup)
   - Pegar en Firebase Console
   - Publicar

---

## 📝 Notas

- Las nuevas reglas son **más seguras** que las actuales
- Requieren **autenticación** (la app ya lo hace)
- **Backup automático:** Firebase mantiene historial de reglas

---

**¡Listo para desplegar!** 🚀

