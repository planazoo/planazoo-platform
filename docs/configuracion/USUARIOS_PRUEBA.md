# 👥 Usuarios de Prueba - Planazoo

> Documento para testing y desarrollo. Usa Gmail con alias para crear múltiples usuarios desde una sola cuenta.

**Última actualización:** Enero 2025

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

## 📝 Notas de Uso

### Crear Usuarios en Firebase

**Opción A: Crear Manualmente en Firebase Console (Recomendado para Testing)**

1. Ir a Firebase Console → Authentication → Users
2. Click en "Add user"
3. Usar email con alias: `unplanazoo+admin@gmail.com`
4. Contraseña: `test123456` (o la que prefieras)
5. Click en "Add user"
6. Repetir para cada usuario:
   - `unplanazoo+admin@gmail.com`
   - `unplanazoo+coorg@gmail.com`
   - `unplanazoo+part1@gmail.com`
   - `unplanazoo+part2@gmail.com`
   - `unplanazoo+part3@gmail.com`
   - `unplanazoo+obs@gmail.com`
   - etc.

**Opción B: Registrarse desde la App**

1. Abre la app en modo incógnito o navegador diferente
2. Ve a la página de registro
3. Usa email: `unplanazoo+admin@gmail.com`
4. Contraseña: `test123456`
5. Completa el registro
6. Repite para cada usuario

**Nota:** No necesitas verificar emails para usuarios de prueba.

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

