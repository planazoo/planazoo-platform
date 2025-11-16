# 👥 Lista Blanca de Administradores - Planazoo

> **Documento de seguridad:** Lista oficial de usuarios administradores de la plataforma con permisos para realizar tareas de mantenimiento y gestión administrativa en Firestore.

**Última actualización:** Enero 2025  
**Mantenedor:** Equipo de desarrollo

---

## 📋 Usuarios Administradores

| Username | Email | UserId (Firebase Auth) | Fecha de asignación | Notas |
|----------|-------|------------------------|---------------------|-------|
| `user_admin` | `unplanazoo+admin@gmail.com` | *Se completará al crear el usuario* | *Pendiente* | Administrador principal de la plataforma. Acceso completo a herramientas administrativas. |

---

## 🔐 Verificación de Administradores

### En Firestore
Los usuarios administradores deben tener el campo `isAdmin: true` en su documento en la colección `users`:
```
users/{userId}
  - isAdmin: true
```

### En las Reglas de Firestore
Las reglas verifican si un usuario es administrador usando la función `isAdmin(userId)`:
```javascript
function isAdmin(userId) {
  return get(/databases/$(database)/documents/users/$(userId)).data.isAdmin == true;
}
```

---

## ⚠️ Procedimientos de Seguridad

### Añadir un nuevo administrador
1. **Verificar necesidad:** Confirmar que el usuario realmente necesita permisos de administrador.
2. **Actualizar Firestore:** Añadir `isAdmin: true` al documento del usuario en `users/{userId}`.
3. **Actualizar esta lista:** Añadir el usuario a esta tabla con fecha de asignación.
4. **Documentar motivo:** Añadir nota explicando por qué se otorgaron permisos de admin.

### Remover permisos de administrador
1. **Actualizar Firestore:** Cambiar `isAdmin: false` en el documento del usuario.
2. **Actualizar esta lista:** Marcar como removido con fecha.
3. **Documentar motivo:** Añadir nota explicando por qué se removieron los permisos.

### Verificación periódica
- Revisar esta lista trimestralmente.
- Verificar que todos los usuarios listados tienen `isAdmin: true` en Firestore.
- Remover usuarios que ya no necesiten permisos de administrador.

---

## 🛠️ Permisos de Administrador

Los usuarios con `isAdmin: true` pueden:

### Desde la App (cuando se implemente la pantalla administrativa)
- Ver todos los usuarios de la plataforma
- Eliminar datos de cualquier usuario
- Auditar y limpiar registros huérfanos
- Modificar registros problemáticos
- Ver logs de acciones administrativas

### Desde Scripts Administrativos
- Ejecutar scripts de limpieza de datos huérfanos
- Eliminar datos de usuarios específicos
- Realizar auditorías completas de la base de datos
- Corregir datos corruptos

### En las Reglas de Firestore
- Leer/escribir/eliminar en todas las colecciones (según reglas definidas)
- Acceder a campos administrativos (`_adminCreatedBy`, etc.)

---

## 📝 Notas Importantes

- **Lista blanca:** Solo los usuarios listados aquí deben tener `isAdmin: true`.
- **Auditoría:** Todas las acciones administrativas deben ser registradas (futuro: sistema de logs).
- **Principio de menor privilegio:** Solo otorgar permisos de admin cuando sea absolutamente necesario.
- **Revisión periódica:** Revisar y actualizar esta lista regularmente.

---

## 🔗 Referencias

- `docs/configuracion/DATOS_SEMILLA.md` - Usuarios de prueba y sus roles
- `docs/tareas/TASKS.md` - T188: Sistema de gestión administrativa
- `firestore.rules` - Reglas de seguridad con función `isAdmin()`

