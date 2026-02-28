# 🔧 Desplegar Reglas de Firestore

## 📋 Comando

Para desplegar las reglas de Firestore, ejecuta desde la **raíz del proyecto**:

```bash
npx firebase deploy --only firestore:rules
```

Alternativa (si usas el paquete global con otro nombre):

```bash
npx firebase-tools deploy --only firestore:rules
```

## ✅ Verificar

Después de desplegar:

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Firestore Database** → **Rules**
4. Verifica que las reglas desplegadas coinciden con `firestore.rules`

## 📝 Notas

- Las reglas se validan automáticamente antes de desplegar
- Si hay errores de sintaxis, el despliegue fallará
- Los cambios se aplican inmediatamente después del despliegue

## 🔄 Reglas Importantes

Las reglas actuales incluyen:

- **Autenticación:** Usuarios autenticados pueden leer/escribir sus datos
- **Invitaciones:** Lectura pública de invitaciones pendientes (para links de email)
- **Planes:** Lectura pública de planes asociados a invitaciones pendientes
- **Mensajes:** Usuarios autenticados pueden leer/escribir mensajes del plan
- **Notificaciones:** Usuarios solo pueden acceder a sus propias notificaciones
- **pending_email_events:** Solo el propio usuario (request.auth.uid == userId) puede leer/escribir en users/{userId}/pending_email_events
- **Administradores:** Permisos especiales para usuarios con `isAdmin: true`

---

*Última actualización: Febrero 2026*
