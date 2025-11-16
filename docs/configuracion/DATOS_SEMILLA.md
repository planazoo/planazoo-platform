# 📚 Datos Semilla para Testing

> Incidencia `seed-doc`: consolidar inventario de usuarios de prueba (admins, roles, aliases, credenciales).
>
> **Nota:** Las contraseñas propuestas (`Test1234!`) cumplen las reglas vigentes: mínimo 8 caracteres con mayúsculas, minúsculas, números y carácter especial. Ajusta si necesitas variantes, respetando dichos requisitos.

## 1. Administradores de la plataforma

| Username sugerido | Email | Contraseña testing | Rol | isAdmin | Notas |
|-------------------|-------|--------------------|-----|---------|-------|
| `user_admin` | `unplanazoo+admin@gmail.com` | `Test1234!` | Organizador principal (admin plataforma) | ✅ `true` | Cuenta base para crear planes, gestionar roles, ejecutar pruebas completas. **Usuario administrador de la plataforma.** |
| -*por definir*- | *Pendiente (segundo admin)* | -*por definir*- | Admin plataforma secundario | ✅ `true` (cuando se cree) | Propuesto para reforzar pruebas multi-admin. *(Definir si se crea)* |

## 2. Usuarios de prueba por rol

### 2.1 Organizadores y coorganizadores

| Username sugerido | Email | Contraseña | Rol en pruebas | isAdmin | Notas |
|-------------------|-------|------------|----------------|---------|-------|
| `user_admin` | `unplanazoo+admin@gmail.com` | `Test1234!` | Organizador dueño | ✅ `true` | Crea/gestiona planes; referencia principal. **Usuario administrador de la plataforma.** |
| `user_coorg` | `unplanazoo+coorg@gmail.com` | `Test1234!` | Coorganizador | ❌ `false` | Valida permisos de coorganizador, creación de eventos, invitaciones. |

### 2.2 Participantes activos

| Username sugerido | Email | Contraseña | Perfil de uso | isAdmin | Notas |
|-------------------|-------|------------|---------------|---------|-------|
| `user_part1` | `unplanazoo+part1@gmail.com` | `Test1234!` | Participante activo | ❌ `false` | Para eventos personales, pagos, confirmaciones. |
| `user_part2` | `unplanazoo+part2@gmail.com` | `Test1234!` | Participante ocasional | ❌ `false` | Pruebas de usuarios con pocos eventos. |
| `user_part3` | `unplanazoo+part3@gmail.com` | `Test1234!` | Participante en grupos | ❌ `false` | Invitaciones masivas, pruebas de grupos. |

### 2.3 Observadores

| Username sugerido | Email | Contraseña | Rol | isAdmin | Notas |
|-------------------|-------|------------|-----|---------|-------|
| `user_obs` | `unplanazoo+obs@gmail.com` | `Test1234!` | Observador | ❌ `false` | Valida UI/permiso solo lectura. |

### 2.4 Usuarios para flujos de invitaciones / edge

| Username sugerido | Email | Contraseña | Caso de uso | isAdmin | Notas |
|-------------------|-------|------------|-------------|---------|-------|
| `user_reject` | `unplanazoo+reject@gmail.com` | `Test1234!` | Rechazar invitaciones | ❌ `false` | Pruebas INV-003, estados de invitaciones rechazadas. |
| `user_expired` | `unplanazoo+expired@gmail.com` | `Test1234!` | Invitación caducada | ❌ `false` | Pruebas INV-004. |
| `user_valid` | `unplanazoo+valid@gmail.com` | `Test1234!` | Validaciones y edge cases | ❌ `false` | Emails inválidos, validaciones de datos. |
| `user_temp1` | `unplanazoo+temp1@gmail.com` | `Test1234!` | Registro nuevo | ❌ `false` | Usar en REG-001. Eliminar tras prueba. |
| `user_temp2` | `unplanazoo+temp2@gmail.com` | `Test1234!` | Registro nuevo | ❌ `false` | Uso alternativo para REG-001. |
| `user_invite1` | `unplanazoo+invite1@gmail.com` | `Test1234!` | Invitaciones nuevas | ❌ `false` | Pruebas INV-001, INV-002. |
| `user_newuser` | `unplanazoo+newuser@gmail.com` | `Test1234!` | Usuario inexistente | ❌ `false` | Para flujos que requieren usuario libre. |

## 3. Usuarios especiales para escenarios ampliados

| Username sugerido | Email | Contraseña | Caso | isAdmin | Notas |
|-------------------|-------|------------|------|---------|-------|
| `user_argentina` | `unplanazoo+tzargentina@gmail.com` | `Test1234!` | Usuario con timezone América/Argentina | ❌ `false` | Configurar `defaultTimezone`: `America/Argentina/Buenos_Aires`. |
| `user_japan` | `unplanazoo+tzjapan@gmail.com` | `Test1234!` | Usuario con timezone Asia/Tokyo | ❌ `false` | Configurar `defaultTimezone`: `Asia/Tokyo`. |
| `user_aiassistant` | `unplanazoo+aiassistant@gmail.com` | `Test1234!` | Usuario IA / integraciones | ❌ `false` | Cuenta dummy para pruebas de IA (asignar permisos según necesidad). |

> **Nota:** Los usuarios marcados como *pendiente* deben confirmarse antes de crearse. Cuando se definan, añadir datos completos y, si procede, scripts de seed asociados.

## 4. Procedimiento de recreación

- **Firebase Auth**: seguir `docs/configuracion/CREAR_USUARIOS_PASO_A_PASO.md`.
- **Firestore**: al crear usuario, confirmar documento en colección `users` con campos básicos (`displayName`, `email`, `username`, `defaultTimezone`, etc.). Usar los usernames sugeridos (o variantes únicas) para cumplir la regla T163.
- **Checklist tras recrear**:
  1. Visualizar usuario en Firebase Auth.
  2. Confirmar documento en Firestore (`users/{id}`).
  3. Asignar `username` (en minúsculas, único) y `defaultTimezone` si aplica.
  4. **Asignar `isAdmin: true` o `isAdmin: false` según la columna `isAdmin` de esta tabla.**
  5. Registrar en esta tabla la fecha de recreación (columna adicional si hace falta).

## 5. Próximos pasos

- Validar si necesitamos usuarios adicionales (segundo admin, testers con múltiples timezones, cuentas bloqueadas, etc.).
- Mantener alineados `TESTING_CHECKLIST.md`, `USUARIOS_PRUEBA.md` y este inventario.
- Una vez definidos scripts de seed, documentar cómo vincular los usuarios a planes/eventos iniciales.


