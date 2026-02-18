# 👥 Usuarios de Prueba - Planazoo

> Documento completo para testing y desarrollo. Usa Gmail con alias para crear múltiples usuarios desde una sola cuenta.

**Última actualización:** Febrero 2026

---

## 📚 Tabla de Contenidos

1. [Configuración Base](#-configuración-base)
2. [Usuarios Recomendados por Rol](#-usuarios-recomendados-por-rol)
3. [Matriz de Usuarios por Caso de Prueba](#-matriz-de-usuarios-por-caso-de-prueba)
4. [Crear Usuarios de Prueba](#-crear-usuarios-de-prueba)
5. [Estrategia de Usuarios para Pruebas](#-estrategia-de-usuarios-para-pruebas)
6. [Flujo de Testing Recomendado](#-flujo-de-testing-recomendado)
7. [Datos Semilla Formales](#-datos-semilla-formales)

---

## 📋 Configuración Base

### Email Base
```
unplanazoo@gmail.com
```

**Nota:** Esta es tu cuenta principal de Gmail.

### Cómo Funciona Gmail con Alias

**IMPORTANTE:** NO necesitas crear cuentas secundarias en Gmail. Gmail automáticamente acepta emails con `+` y los envía a tu cuenta principal.

**Funcionamiento:**
- Tu cuenta principal: `unplanazoo@gmail.com`
- Emails con alias: `unplanazoo+admin@gmail.com`, `unplanazoo+part1@gmail.com`, etc.
- Todos los emails llegan a: `unplanazoo@gmail.com` (tu bandeja principal)
- Firebase Auth los trata como usuarios diferentes
- Fácil identificación en Firebase Console

**Ejemplo:**
- `unplanazoo+admin@gmail.com` → llega a `unplanazoo@gmail.com`
- `unplanazoo+part1@gmail.com` → llega a `unplanazoo@gmail.com`
- `unplanazoo+coorg@gmail.com` → llega a `unplanazoo@gmail.com`

**No necesitas:**
- ❌ Crear cuentas secundarias en Gmail
- ❌ Verificar cada alias por separado
- ❌ Configurar nada en Gmail

**Solo necesitas:**
- ✅ Usar el email con alias al registrarte en la app
- ✅ O crear usuarios manualmente en Firebase Console con esos emails

---

## 👤 Usuarios Recomendados por Rol

### 🔴 Organizador (Admin Principal)

**Email:** `unplanazoo+admin@gmail.com`  
**Rol:** Organizador  
**Contraseña:** [Tu contraseña de prueba]  
**Uso:**
- Crear planes
- Invitar participantes
- Configurar presupuesto
- Gestionar todos los permisos

**Casos de Prueba:**
- REG-001, REG-002, REG-003 (Registro)
- PLAN-001, PLAN-002, PLAN-003 (Crear Plan)
- INV-001, INV-002 (Enviar Invitaciones)
- BUD-001, BUD-002 (Configurar Presupuesto)

---

### 🟠 Coorganizador

**Email:** `unplanazoo+coorg@gmail.com`  
**Rol:** Coorganizador  
**Contraseña:** [Tu contraseña de prueba]  
**Uso:**
- Invitado como coorganizador
- Crear/editar eventos
- Invitar participantes
- Ver presupuesto (solo lectura)

**Casos de Prueba:**
- INV-003 (Aceptar Invitación como Coorganizador)
- EVT-001, EVT-002 (Crear/Editar Eventos)
- PERM-001, PERM-002 (Permisos de Coorganizador)

---

### 🟢 Participantes

#### Participante 1 (Activo)
**Email:** `unplanazoo+part1@gmail.com`  
**Rol:** Participante  
**Contraseña:** [Tu contraseña de prueba]  
**Uso:**
- Participante activo con eventos
- Probar gestión de parte personal de eventos
- Probar pagos individuales

**Casos de Prueba:**
- INV-003 (Aceptar Invitación)
- EVT-005 (Añadir Información Personal a Evento)
- PAY-003 (Registrar Pago Personal)

#### Participante 2 (Menos Activo)
**Email:** `unplanazoo+part2@gmail.com`  
**Rol:** Participante  
**Contraseña:** [Tu contraseña de prueba]  
**Uso:**
- Participante con menos eventos
- Probar validaciones de participantes sin eventos
- Probar estadísticas

**Casos de Prueba:**
- VAL-003 (Validar Participante sin Eventos)
- STAT-005 (Estadísticas por Participante)

#### Participante 3 (Para Grupos)
**Email:** `unplanazoo+part3@gmail.com`  
**Rol:** Participante  
**Contraseña:** [Tu contraseña de prueba]  
**Uso:**
- Miembro de grupos de participantes
- Probar invitación de grupos

**Casos de Prueba:**
- GRP-004 (Invitar Grupo Completo)

---

### 🔵 Observador

**Email:** `unplanazoo+obs@gmail.com`  
**Rol:** Observador  
**Contraseña:** [Tu contraseña de prueba]  
**Uso:**
- Solo lectura
- Ver planes y eventos
- No puede crear/editar

**Casos de Prueba:**
- PERM-003 (Permisos de Solo Lectura)
- PERM-004 (UI Bloqueada para Observador)

---

### 🟡 Usuarios para Casos Especiales

#### Escenario E2E – Tres usuarios (UA, UB, UC)
Usados en el [Plan de pruebas E2E exhaustivo](../testing/PLAN_PRUEBAS_E2E_TRES_USUARIOS.md) (flujo completo: crear plan → invitaciones → eventos → chat → aprobar → cerrar).

| Id | Email | Rol en el escenario | Timezone ejemplo |
|----|--------|----------------------|-------------------|
| **UA** | `Unplanazoo+cricla@gmail.com` | Organizador (único registrado al inicio) | Europe/Madrid |
| **UB** | `Unplanazoo+marbat@gmail.com` | Participante (acepta invitación) | Europe/Madrid |
| **UC** | `Unplanazoo+emmcla@gmail.com` | Participante (rechaza primero, acepta después; deja y vuelve al plan) | America/New_York |

**Contraseña:** la misma para todos (ej. `test123456` o la que uses en tu entorno).

---

#### Usuario para Rechazar Invitación
**Email:** `unplanazoo+reject@gmail.com`  
**Rol:** N/A  
**Contraseña:** [Tu contraseña de prueba]  
**Uso:**
- Probar rechazo de invitaciones
- Ver estados de invitaciones rechazadas

**Casos de Prueba:**
- INV-003 (Rechazar Invitación)

#### Usuario para Invitación Expirada
**Email:** `unplanazoo+expired@gmail.com`  
**Rol:** N/A  
**Contraseña:** [Tu contraseña de prueba]  
**Uso:**
- Probar invitaciones expiradas
- Ver mensajes de error

**Casos de Prueba:**
- INV-004 (Invitación Expirada)

#### Usuario para Validaciones
**Email:** `unplanazoo+valid@gmail.com`  
**Rol:** Participante  
**Contraseña:** [Tu contraseña de prueba]  
**Uso:**
- Probar validaciones de datos
- Casos edge (email inválido, etc.)

**Casos de Prueba:**
- REG-004 (Email Inválido)
- VAL-001, VAL-002 (Validaciones)

---

## 📊 Matriz de Usuarios por Caso de Prueba

| Caso de Prueba | Usuario Principal | Usuario Secundario |
|---------------|-------------------|-------------------|
| **Registro** | admin | part1, part2 |
| **Login** | admin | part1, coorg |
| **Crear Plan** | admin | coorg |
| **Editar Plan** | admin | coorg |
| **Eliminar Plan** | admin | - |
| **Crear Evento** | admin, coorg | part1 |
| **Editar Evento** | admin, coorg | part1 (parte personal) |
| **Eliminar Evento** | admin, coorg | - |
| **Añadir Participante** | admin, coorg | part1, part2 |
| **Eliminar Participante** | admin | part1 |
| **Enviar Invitación** | admin | part1, part2, coorg |
| **Aceptar Invitación** | part1, part2, coorg | - |
| **Rechazar Invitación** | reject | - |
| **Configurar Presupuesto** | admin | - |
| **Registrar Pago** | admin, part1 | part2 |
| **Ver Estadísticas** | admin, coorg | part1 |
| **Cambiar Estado Plan** | admin | - |
| **Validaciones** | valid | - |

---

## 🔄 Flujo de Testing Recomendado

### Fase 1: Registro y Autenticación
1. Crear usuario: `admin`
2. Crear usuario: `part1`
3. Crear usuario: `coorg`
4. Probar login/logout con cada uno

### Fase 2: Gestión de Planes
1. Login como `admin`
2. Crear plan
3. Invitar `coorg` como coorganizador
4. Invitar `part1`, `part2` como participantes
5. Invitar `obs` como observador

### Fase 3: Eventos y Participantes
1. Login como `admin` o `coorg`
2. Crear eventos
3. Añadir participantes a eventos
4. Login como `part1` para ver eventos
5. Editar información personal de eventos

### Fase 4: Presupuesto y Pagos
1. Login como `admin`
2. Configurar presupuesto
3. Añadir costes a eventos
4. Registrar pagos de participantes

### Fase 5: Validaciones y Estados
1. Probar estados del plan
2. Probar validaciones (días vacíos, participantes sin eventos)
3. Probar permisos (observador, participante, coorganizador)

---

## 📝 Crear Usuarios de Prueba

### Método 1: Crear en Firebase Console (Recomendado)

**Paso 1: Abrir Firebase Console**

1. Ve a https://console.firebase.google.com
2. Selecciona tu proyecto "Planazoo"
3. En el menú lateral, ve a **Authentication**
4. Click en la pestaña **Users**

**Paso 2: Crear Usuario Admin**

1. Click en el botón **"Add user"** (o "Añadir usuario")
2. En el campo **Email**, escribe: `unplanazoo+admin@gmail.com`
3. En el campo **Password**, escribe: `test123456` (o la contraseña que prefieras)
4. **Deselecciona** "Send email verification" (no es necesario para testing)
5. Click en **"Add user"**

✅ Usuario creado: `unplanazoo+admin@gmail.com`

**Paso 3: Crear Resto de Usuarios**

Repite el proceso para cada usuario de la lista de arriba.

**Paso 4: Verificar Usuarios Creados**

En Firebase Console → Authentication → Users, deberías ver todos los usuarios creados.

### Método 2: Registrarse desde la App

**Paso 1: Abrir App en Modo Incógnito**

1. Abre Chrome/Edge en modo incógnito (Ctrl+Shift+N / Cmd+Shift+N)
2. Ve a tu app (localhost o URL de producción)
3. Ve a la página de registro

**Paso 2: Registrar Usuario**

1. En el campo **Email**, escribe: `unplanazoo+admin@gmail.com`
2. En el campo **Password**, escribe: `test123456`
3. Completa el formulario de registro
4. Click en **"Registrar"** o **"Crear cuenta"**

✅ Usuario creado y autenticado

**Paso 3: Cerrar Sesión y Repetir**

1. Cierra sesión del usuario actual
2. Repite el proceso para cada usuario

**Tip:** Puedes usar múltiples ventanas incógnito o navegadores diferentes para registrar varios usuarios rápidamente.

### Verificar que Funciona

**En Firebase Console:**
1. Firebase Console → Authentication → Users
2. Verifica que todos los usuarios aparecen con sus emails

**En Gmail:**
1. Abre tu Gmail: `unplanazoo@gmail.com`
2. Si recibes algún email de la app (invitaciones, etc.):
   - Verás que llegan a tu bandeja principal
   - En el "Para:" verás el alias: `unplanazoo+part1@gmail.com`
   - Puedes buscar por alias para filtrar

**En la App:**
1. Abre la app
2. Intenta hacer login con: `unplanazoo+admin@gmail.com` / `test123456`
3. Debería funcionar correctamente

### 🔍 Troubleshooting

**"Email already exists"**
- Si ya existe en Firebase, simplemente úsalo para login
- Si quieres recrearlo, elimínalo primero desde Firebase Console

**"Invalid email format"**
- Verifica que estás escribiendo correctamente: `unplanazoo+admin@gmail.com`
- Asegúrate de que no hay espacios antes o después
- El formato debe ser exactamente: `usuario+alias@gmail.com`

**"Email verification required"**
- En Firebase Console → Authentication → Settings → Email/Password
- Desactiva "Email verification" temporalmente para testing
- O verifica manualmente desde Firebase Console (marcar usuario como verificado)

### Verificar Emails de Invitación

Cuando pruebes invitaciones:
- Todos los emails llegarán a `unplanazoo@gmail.com` (tu bandeja principal)
- Podrás ver el alias en el "Para:" del email (ej: "Para: unplanazoo+part1@gmail.com")
- Útil para verificar que las invitaciones se envían correctamente
- Puedes buscar en Gmail por el alias para filtrar emails de prueba

### Limpiar Usuarios de Prueba

Si necesitas limpiar usuarios de prueba:
1. Firebase Console → Authentication
2. Seleccionar usuarios con alias `+admin`, `+part1`, etc.
3. Eliminar usuarios de prueba

**⚠️ Cuidado:** No eliminar usuarios de producción.

---

## 🎯 Estrategia de Usuarios para Pruebas

### Usuarios que DEBEN existir (Base)

Estos usuarios deben estar siempre creados para la mayoría de pruebas:

- ✅ `unplanazoo+admin@gmail.com` - Para login, gestión de planes, etc.
- ✅ `unplanazoo+coorg@gmail.com` - Para pruebas de coorganizador
- ✅ `unplanazoo+part1@gmail.com` - Para pruebas de participante
- ✅ `unplanazoo+part2@gmail.com` - Para pruebas de participante
- ✅ `unplanazoo+part3@gmail.com` - Para pruebas de participante
- ✅ `unplanazoo+obs@gmail.com` - Para pruebas de observador

**Casos de prueba que los necesitan:**
- LOGIN-001 (Login válido)
- PLAN-C-* (Crear/editar planes)
- EVENT-C-* (Crear eventos)
- PART-ADD-* (Gestionar participantes)
- Y la mayoría de casos funcionales

### Usuarios que NO deben existir (Para pruebas específicas)

Para ciertas pruebas, algunos usuarios NO deben existir:

#### Para REG-001 (Registrar nuevo usuario)
- ❌ El usuario de prueba NO debe existir en Firebase Auth
- ❌ El usuario NO debe existir en Firestore collection `users`
- **Solución:** Usar un email nuevo o eliminar el usuario antes de probar

#### Para LOGIN-002 (Login con email incorrecto)
- ❌ El usuario NO debe existir
- **Solución:** Usar un email que no esté registrado

#### Para INV-001 (Invitar usuario no registrado)
- ❌ El usuario invitado NO debe existir
- **Solución:** Usar un email que no esté registrado

#### Para INV-002 (Aceptar invitación - usuario nuevo)
- ❌ El usuario NO debe existir (para probar flujo de registro desde invitación)
- **Solución:** Usar un email que no esté registrado

### 🔄 Flujo Recomendado para Pruebas

**Opción 1: Usuarios Adicionales (Recomendado)**
- Mantener usuarios base siempre creados
- Usar emails adicionales para pruebas de registro:
  - `unplanazoo+test1@gmail.com`
  - `unplanazoo+test2@gmail.com`
  - `unplanazoo+newuser@gmail.com`
- Eliminar estos usuarios después de cada prueba de registro

**Opción 2: Limpieza Selectiva**
- Antes de REG-001: Eliminar `unplanazoo+test1@gmail.com` (si existe)
- Ejecutar REG-001 con `unplanazoo+test1@gmail.com`
- Después: Decidir si mantener o eliminar según necesidad

**Opción 3: Usuarios por Fase de Testing**
- Fase 1 (Registro): No crear usuarios, probar registro
- Fase 2 (Login): Crear usuarios base
- Fase 3 (Funcionalidad): Usar usuarios base existentes

### 📝 Recomendación Final

**Para facilitar el testing, recomiendo:**

1. **Mantener siempre creados:** admin, coorg, part1, part2, part3, obs
2. **Usar usuarios temporales:** Crear usuarios adicionales para pruebas de registro
3. **Limpiar después:** Eliminar usuarios temporales después de pruebas de registro
4. **Botón de limpieza:** Crear un botón temporal en dashboard para limpiar usuarios de prueba específicos

**Ejemplo de usuarios temporales:**
- `unplanazoo+temp1@gmail.com` - Para REG-001
- `unplanazoo+temp2@gmail.com` - Para REG-001 (segunda vez)
- `unplanazoo+invite1@gmail.com` - Para INV-001, INV-002

Estos usuarios se pueden eliminar después de cada prueba sin afectar las pruebas funcionales.

---

## 🎯 Usuarios Mínimos para Testing Básico

Si solo necesitas lo esencial:

1. **admin** - `unplanazoo+admin@gmail.com` (Organizador)
2. **part1** - `unplanazoo+part1@gmail.com` (Participante)
3. **coorg** - `unplanazoo+coorg@gmail.com` (Coorganizador)

Con estos 3 usuarios puedes probar la mayoría de funcionalidades básicas.

---

## 📋 Checklist de Creación

- [ ] Crear usuario `admin`
- [ ] Crear usuario `coorg`
- [ ] Crear usuario `part1`
- [ ] Crear usuario `part2`
- [ ] Crear usuario `part3`
- [ ] Crear usuario `obs`
- [ ] Crear usuario `reject`
- [ ] Crear usuario `expired`
- [ ] Crear usuario `valid`
- [ ] Verificar que todos los emails llegan a bandeja principal
- [ ] Probar login con cada usuario
- [ ] Documentar contraseña de prueba (no commitear)

---

## 📊 Datos Semilla Formales

> **Nota:** Las contraseñas propuestas (`Test1234!` o `test123456`) cumplen las reglas vigentes: mínimo 8 caracteres con mayúsculas, minúsculas, números y carácter especial (si aplica).

### Administradores de la Plataforma

| Username sugerido | Email | Contraseña testing | Rol | isAdmin | Notas |
|-------------------|-------|--------------------|-----|---------|-------|
| `user_admin` | `unplanazoo+admin@gmail.com` | `Test1234!` o `test123456` | Organizador principal (admin plataforma) | ✅ `true` | Cuenta base para crear planes, gestionar roles, ejecutar pruebas completas. **Usuario administrador de la plataforma.** |

### Usuarios por Rol

| Username sugerido | Email | Contraseña | Rol en pruebas | isAdmin | Notas |
|-------------------|-------|------------|----------------|---------|-------|
| `user_admin` | `unplanazoo+admin@gmail.com` | `Test1234!` o `test123456` | Organizador dueño | ✅ `true` | Crea/gestiona planes; referencia principal. |
| `user_coorg` | `unplanazoo+coorg@gmail.com` | `Test1234!` o `test123456` | Coorganizador | ❌ `false` | Valida permisos de coorganizador, creación de eventos, invitaciones. |
| `user_part1` | `unplanazoo+part1@gmail.com` | `Test1234!` o `test123456` | Participante activo | ❌ `false` | Para eventos personales, pagos, confirmaciones. |
| `user_part2` | `unplanazoo+part2@gmail.com` | `Test1234!` o `test123456` | Participante ocasional | ❌ `false` | Pruebas de usuarios con pocos eventos. |
| `user_part3` | `unplanazoo+part3@gmail.com` | `Test1234!` o `test123456` | Participante en grupos | ❌ `false` | Invitaciones masivas, pruebas de grupos. |
| `user_obs` | `unplanazoo+obs@gmail.com` | `Test1234!` o `test123456` | Observador | ❌ `false` | Valida UI/permiso solo lectura. |

### Usuarios para Flujos Especiales

| Username sugerido | Email | Contraseña | Caso de uso | isAdmin | Notas |
|-------------------|-------|------------|-------------|---------|-------|
| `user_reject` | `unplanazoo+reject@gmail.com` | `Test1234!` o `test123456` | Rechazar invitaciones | ❌ `false` | Pruebas INV-003, estados de invitaciones rechazadas. |
| `user_expired` | `unplanazoo+expired@gmail.com` | `Test1234!` o `test123456` | Invitación caducada | ❌ `false` | Pruebas INV-004. |
| `user_valid` | `unplanazoo+valid@gmail.com` | `Test1234!` o `test123456` | Validaciones y edge cases | ❌ `false` | Emails inválidos, validaciones de datos. |
| `user_temp1` | `unplanazoo+temp1@gmail.com` | `Test1234!` o `test123456` | Registro nuevo | ❌ `false` | Usar en REG-001. Eliminar tras prueba. |
| `user_temp2` | `unplanazoo+temp2@gmail.com` | `Test1234!` o `test123456` | Registro nuevo | ❌ `false` | Uso alternativo para REG-001. |
| `user_invite1` | `unplanazoo+invite1@gmail.com` | `Test1234!` o `test123456` | Invitaciones nuevas | ❌ `false` | Pruebas INV-001, INV-002. |
| `user_newuser` | `unplanazoo+newuser@gmail.com` | `Test1234!` o `test123456` | Usuario inexistente | ❌ `false` | Para flujos que requieren usuario libre. |

### Usuarios Especiales para Escenarios Ampliados

| Username sugerido | Email | Contraseña | Caso | isAdmin | Notas |
|-------------------|-------|------------|------|---------|-------|
| `user_argentina` | `unplanazoo+tzargentina@gmail.com` | `Test1234!` o `test123456` | Usuario con timezone América/Argentina | ❌ `false` | Configurar `defaultTimezone`: `America/Argentina/Buenos_Aires`. |
| `user_japan` | `unplanazoo+tzjapan@gmail.com` | `Test1234!` o `test123456` | Usuario con timezone Asia/Tokyo | ❌ `false` | Configurar `defaultTimezone`: `Asia/Tokyo`. |
| `user_aiassistant` | `unplanazoo+aiassistant@gmail.com` | `Test1234!` o `test123456` | Usuario IA / integraciones | ❌ `false` | Cuenta dummy para pruebas de IA (asignar permisos según necesidad). |

### Procedimiento de Recreación

**Firebase Auth:**
- Seguir sección [Crear Usuarios de Prueba](#-crear-usuarios-de-prueba) arriba

**Firestore:**
- Al crear usuario, confirmar documento en colección `users` con campos básicos (`displayName`, `email`, `username`, `defaultTimezone`, etc.)
- Usar los usernames sugeridos (o variantes únicas) para cumplir la regla T163

**Checklist tras recrear:**
1. Visualizar usuario en Firebase Auth
2. Confirmar documento en Firestore (`users/{id}`)
3. Asignar `username` (en minúsculas, único) y `defaultTimezone` si aplica
4. **Asignar `isAdmin: true` o `isAdmin: false` según la columna `isAdmin` de las tablas arriba**
5. Registrar fecha de recreación si es necesario

---

## 🔐 Seguridad

**⚠️ IMPORTANTE:**
- No usar contraseñas reales para usuarios de prueba
- Usar contraseña simple para testing: `test123456` (o similar)
- No commitear contraseñas en el código
- Limpiar usuarios de prueba periódicamente
- No usar estos usuarios en producción

---

**Última actualización:** Enero 2025  
**Mantenedor:** Equipo de desarrollo

