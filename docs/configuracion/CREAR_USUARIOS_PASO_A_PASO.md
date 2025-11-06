# 📝 Crear Usuarios de Prueba - Paso a Paso

> Guía detallada para crear usuarios de prueba usando Gmail con alias.

**Email base:** `unplanazoo@gmail.com`

---

## 🎯 Concepto Clave

**NO necesitas crear cuentas secundarias en Gmail.**

Gmail automáticamente acepta emails con el formato `unplanazoo+cualquiercosa@gmail.com` y los envía a tu bandeja `unplanazoo@gmail.com`.

---

## 📋 Método 1: Crear en Firebase Console (Recomendado)

### Paso 1: Abrir Firebase Console

1. Ve a https://console.firebase.google.com
2. Selecciona tu proyecto "Planazoo" (o como se llame)
3. En el menú lateral, ve a **Authentication**
4. Click en la pestaña **Users**

### Paso 2: Crear Usuario Admin

1. Click en el botón **"Add user"** (o "Añadir usuario")
2. En el campo **Email**, escribe: `unplanazoo+admin@gmail.com`
3. En el campo **Password**, escribe: `test123456` (o la contraseña que prefieras)
4. **Deselecciona** "Send email verification" (no es necesario para testing)
5. Click en **"Add user"**

✅ Usuario creado: `unplanazoo+admin@gmail.com`

### Paso 3: Crear Resto de Usuarios

Repite el proceso para cada usuario:

| Email | Contraseña | Rol |
|-------|-----------|-----|
| `unplanazoo+admin@gmail.com` | `test123456` | Organizador |
| `unplanazoo+coorg@gmail.com` | `test123456` | Coorganizador |
| `unplanazoo+part1@gmail.com` | `test123456` | Participante 1 |
| `unplanazoo+part2@gmail.com` | `test123456` | Participante 2 |
| `unplanazoo+part3@gmail.com` | `test123456` | Participante 3 |
| `unplanazoo+obs@gmail.com` | `test123456` | Observador |
| `unplanazoo+reject@gmail.com` | `test123456` | Para rechazar invitaciones |
| `unplanazoo+expired@gmail.com` | `test123456` | Para invitaciones expiradas |
| `unplanazoo+valid@gmail.com` | `test123456` | Para validaciones |

### Paso 4: Verificar Usuarios Creados

En Firebase Console → Authentication → Users, deberías ver:

```
unplanazoo+admin@gmail.com
unplanazoo+coorg@gmail.com
unplanazoo+part1@gmail.com
unplanazoo+part2@gmail.com
unplanazoo+part3@gmail.com
unplanazoo+obs@gmail.com
unplanazoo+reject@gmail.com
unplanazoo+expired@gmail.com
unplanazoo+valid@gmail.com
```

---

## 📋 Método 2: Registrarse desde la App

### Paso 1: Abrir App en Modo Incógnito

1. Abre Chrome/Edge en modo incógnito (Ctrl+Shift+N)
2. Ve a tu app (localhost o URL de producción)
3. Ve a la página de registro

### Paso 2: Registrar Usuario Admin

1. En el campo **Email**, escribe: `unplanazoo+admin@gmail.com`
2. En el campo **Password**, escribe: `test123456`
3. Completa el formulario de registro
4. Click en **"Registrar"** o **"Crear cuenta"**

✅ Usuario creado y autenticado

### Paso 3: Cerrar Sesión y Repetir

1. Cierra sesión del usuario actual
2. Repite el proceso para cada usuario:
   - `unplanazoo+coorg@gmail.com`
   - `unplanazoo+part1@gmail.com`
   - etc.

**Tip:** Puedes usar múltiples ventanas incógnito o navegadores diferentes para registrar varios usuarios rápidamente.

---

## ✅ Verificar que Funciona

### Verificar en Firebase Console

1. Firebase Console → Authentication → Users
2. Verifica que todos los usuarios aparecen con sus emails:
   - `unplanazoo+admin@gmail.com`
   - `unplanazoo+part1@gmail.com`
   - etc.

### Verificar en Gmail

1. Abre tu Gmail: `unplanazoo@gmail.com`
2. Si recibes algún email de la app (invitaciones, etc.):
   - Verás que llegan a tu bandeja principal
   - En el "Para:" verás el alias: `unplanazoo+part1@gmail.com`
   - Puedes buscar por alias para filtrar

### Verificar Login en la App

1. Abre la app
2. Intenta hacer login con: `unplanazoo+admin@gmail.com` / `test123456`
3. Debería funcionar correctamente

---

## 🎯 Usuarios Mínimos (Para Empezar Rápido)

Si solo quieres empezar rápido, crea estos 3 usuarios:

1. `unplanazoo+admin@gmail.com` - Organizador
2. `unplanazoo+part1@gmail.com` - Participante
3. `unplanazoo+coorg@gmail.com` - Coorganizador

Con estos 3 puedes probar la mayoría de funcionalidades básicas.

---

## 🔍 Troubleshooting

### "Email already exists"

**Problema:** Intentas crear un usuario que ya existe

**Solución:** 
- Si ya existe en Firebase, simplemente úsalo para login
- Si quieres recrearlo, elimínalo primero desde Firebase Console

### "Invalid email format"

**Problema:** Firebase no acepta el formato con `+`

**Solución:** 
- Verifica que estás escribiendo correctamente: `unplanazoo+admin@gmail.com`
- Asegúrate de que no hay espacios antes o después
- El formato debe ser exactamente: `usuario+alias@gmail.com`

### "Email verification required"

**Problema:** Firebase requiere verificación de email

**Solución:**
- En Firebase Console → Authentication → Settings → Email/Password
- Desactiva "Email verification" temporalmente para testing
- O verifica manualmente desde Firebase Console (marcar usuario como verificado)

---

## 📝 Notas Importantes

1. **Todos los emails llegan a `unplanazoo@gmail.com`**
   - No necesitas configurar nada en Gmail
   - Gmail automáticamente acepta emails con `+`

2. **Firebase Auth los trata como usuarios diferentes**
   - `unplanazoo+admin@gmail.com` ≠ `unplanazoo+part1@gmail.com`
   - Cada uno tiene su propia sesión y datos

3. **Contraseña de prueba**
   - Usa la misma para todos: `test123456`
   - O usa diferentes si prefieres
   - No uses contraseñas reales

4. **No commitear contraseñas**
   - No subas contraseñas de prueba al repositorio
   - Mantén este documento actualizado pero sin contraseñas reales

---

**Última actualización:** Enero 2025

