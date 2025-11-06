# 🧪 Checklist Exhaustivo de Pruebas - Planazoo

> Documento vivo que debe actualizarse cada vez que se completa una tarea o se añade nueva funcionalidad.

**Versión:** 1.3  
**Última actualización:** Enero 2025 (Actualizado - T163 username obligatorio, login con username, T164 Google login, validación de contraseñas mejorada)  
**Mantenedor:** Equipo de desarrollo

---

## 📋 INSTRUCCIONES DE MANTENIMIENTO

### 👥 USUARIOS DE PRUEBA

Para testing, consulta `docs/configuracion/USUARIOS_PRUEBA.md` para:
- Lista de usuarios recomendados por rol
- Emails con alias Gmail (unplanazoo+admin@gmail.com, unplanazoo+part1@gmail.com, etc.)
- Matriz de usuarios por caso de prueba
- Flujo de testing recomendado

**Nota:** Usa Gmail con alias (`+`) para crear múltiples usuarios desde una sola cuenta. Todos los emails llegan a `unplanazoo@gmail.com`.

**Usuarios de prueba disponibles:**
- `unplanazoo+admin@gmail.com` - Organizador (contraseña: `test123456`)
- `unplanazoo+coorg@gmail.com` - Coorganizador (contraseña: `test123456`)
- `unplanazoo+part1@gmail.com` - Participante 1 (contraseña: `test123456`)
- `unplanazoo+part2@gmail.com` - Participante 2 (contraseña: `test123456`)
- `unplanazoo+part3@gmail.com` - Participante 3 (contraseña: `test123456`)
- `unplanazoo+obs@gmail.com` - Observador (contraseña: `test123456`)
- Y más... (ver `USUARIOS_PRUEBA.md` para lista completa)

**💡 Crear usuarios automáticamente:** Usa el botón "⚙️ Init Firestore" en el dashboard para crear todos los usuarios de prueba en Firebase Auth y Firestore.

**📋 Estrategia de Usuarios:** Ver sección "Estrategia de Usuarios para Pruebas" en `USUARIOS_PRUEBA.md` para entender qué usuarios deben existir y cuáles no para cada tipo de prueba.

---

### ⚠️ CUANDO ACTUALIZAR ESTE DOCUMENTO

1. **Después de completar una tarea:**
   - ✅ Marcar como probada la funcionalidad nueva
   - ✅ Añadir nuevos casos de prueba si aplica
   - ✅ Actualizar casos relacionados que puedan afectarse

2. **Cuando se añade nueva funcionalidad:**
   - ✅ Crear nueva sección de pruebas
   - ✅ Documentar casos normales y edge cases
   - ✅ Actualizar tabla de contenidos

3. **Cuando se corrige un bug:**
   - ✅ Añadir el bug como caso de prueba
   - ✅ Verificar que no se reproduce
   - ✅ Documentar solución si es relevante

4. **Antes de cada release:**
   - ✅ Ejecutar checklist completo
   - ✅ Marcar estado de cada sección
   - ✅ Documentar issues encontrados

### 📝 FORMATO DE PRUEBAS

Cada caso de prueba debe incluir:
- **Descripción:** Qué se está probando
- **Pasos:** Pasos exactos a seguir
- **Resultado esperado:** Qué debe suceder
- **Estado:** ✅ Pasado | ❌ Fallido | ⚠️ Parcial | 🔄 Pendiente

---

## 📑 TABLA DE CONTENIDOS

1. [Autenticación y Registro](#1-autenticación-y-registro)
2. [Gestión de Usuarios](#2-gestión-de-usuarios)
3. [CRUD de Planes](#3-crud-de-planes)
4. [CRUD de Eventos](#4-crud-de-eventos)
5. [CRUD de Alojamientos](#5-crud-de-alojamientos)
6. [Gestión de Participantes](#6-gestión-de-participantes)
7. [Invitaciones y Notificaciones](#7-invitaciones-y-notificaciones)
8. [Estados del Plan](#8-estados-del-plan)
9. [Presupuesto y Pagos](#9-presupuesto-y-pagos)
   - 9.1 [Gestión de Presupuesto (T101)](#91-gestión-de-presupuesto-t101)
   - 9.2 [Sistema de Pagos (T102)](#92-sistema-de-pagos-t102)
   - 9.3 [Sistema Multi-moneda (T153)](#93-sistema-multi-moneda-t153)
10. [Estadísticas del Plan](#10-estadísticas-del-plan)
11. [Validaciones y Verificaciones](#11-validaciones-y-verificaciones)
12. [Calendario y Visualización](#12-calendario-y-visualización)
13. [Timezones](#13-timezones)
14. [Seguridad y Permisos](#14-seguridad-y-permisos)
15. [Sincronización y Offline](#15-sincronización-y-offline)
16. [Casos Edge y Errores](#16-casos-edge-y-errores)
17. [Rendimiento](#17-rendimiento)
18. [UX y Accesibilidad](#18-ux-y-accesibilidad)

---

## 1. AUTENTICACIÓN Y REGISTRO

### 1.1 Registro de Usuario

**⚠️ IMPORTANTE (T163):** A partir de T163, el campo `username` es **OBLIGATORIO** en el registro. Todos los nuevos usuarios deben tener un username único.

- [ ] **REG-001:** Registrar nuevo usuario con email válido y username válido
  - Pasos: 
    1. Crear cuenta con email válido (ej: `unplanazoo+temp1@gmail.com`)
    2. Completar campo de nombre
    3. Completar campo de **username** (ej: `usuario_prueba1`)
    4. Contraseña segura (mínimo 8 caracteres con mayúsculas, minúsculas, números y caracteres especiales)
    5. Confirmar contraseña
    6. Aceptar términos y condiciones
  - Esperado: 
    - Usuario creado exitosamente
    - Username guardado en Firestore con `usernameLower`
    - Redirección a login
    - Email de verificación enviado
  - **⚠️ IMPORTANTE:** El usuario NO debe existir previamente en Firebase Auth ni Firestore. Usar `unplanazoo+temp1@gmail.com` o eliminar usuario antes de probar.
  - Estado: 🔄

- [ ] **REG-002:** Registrar usuario con email ya existente
  - Pasos: Intentar registrar email ya registrado (con username válido)
  - Esperado: Error claro "Email ya registrado" (traducido)
  - Estado: 🔄

- [ ] **REG-003:** Registrar con username ya existente
  - Pasos: 
    1. Intentar registrar con un username que ya existe (ej: usar `admin` si ya existe)
    2. Completar todos los demás campos correctamente
  - Esperado: 
    - Error "Este nombre de usuario ya está en uso"
    - Se muestran sugerencias de username alternativos (chips clicables)
    - Al hacer clic en una sugerencia, se rellena el campo automáticamente
  - Estado: 🔄

- [ ] **REG-004:** Registrar con username inválido (formato incorrecto)
  - Pasos: 
    1. Intentar registrar con username que no cumple el formato:
       - Menos de 3 caracteres (ej: `ab`)
       - Más de 30 caracteres (ej: `usuario_muy_largo_que_excede_el_limite`)
       - Caracteres especiales no permitidos (ej: `usuario@123`, `usuario-123`, `usuario.123`)
       - Mayúsculas (ej: `Usuario123`)
  - Esperado: 
    - Error de validación claro explicando el formato requerido
    - Mensaje: "El nombre de usuario debe tener 3-30 caracteres y solo puede contener letras minúsculas, números y guiones bajos (a-z, 0-9, _)"
  - Estado: 🔄

- [ ] **REG-005:** Registrar con contraseña débil (validación mejorada)
  - Pasos: 
    1. Intentar registrar con contraseñas que no cumplan los requisitos:
       - Menos de 8 caracteres (ej: `12345`)
       - Sin letra mayúscula (ej: `password123!`)
       - Sin letra minúscula (ej: `PASSWORD123!`)
       - Sin número (ej: `Password!`)
       - Sin carácter especial (ej: `Password123`)
  - Esperado: 
    - Error específico según el requisito faltante:
      - "La contraseña debe tener al menos 8 caracteres"
      - "La contraseña debe contener al menos una letra mayúscula"
      - "La contraseña debe contener al menos una letra minúscula"
      - "La contraseña debe contener al menos un número"
      - "La contraseña debe contener al menos un carácter especial (!@#$%^&*)"
    - El error se muestra al salir del campo de contraseña
    - El botón "Crear Cuenta" está deshabilitado si la contraseña no es válida
  - Estado: ✅

- [ ] **REG-006:** Registrar con email inválido
  - Pasos: Email sin @ o formato incorrecto
  - Esperado: Error de validación de email
  - Estado: 🔄

- [ ] **REG-007:** Registro con campos vacíos
  - Pasos: Dejar campos requeridos vacíos (nombre, email, username, contraseña)
  - Esperado: Validaciones que marquen campos obligatorios
  - Estado: 🔄

- [ ] **REG-008:** Validación de sugerencias de username
  - Pasos: 
    1. Intentar registrar con username ocupado (ej: `admin`)
    2. Verificar que aparecen sugerencias (ej: `admin1`, `admin2`, `admin_2025`)
    3. Hacer clic en una sugerencia
  - Esperado: 
    - El campo de username se rellena automáticamente con la sugerencia seleccionada
    - El error desaparece
    - Se puede proceder con el registro
  - Estado: 🔄

- [ ] **REG-009:** Username con @ al inicio (opcional)
  - Pasos: Intentar registrar con `@usuario` (con @ al inicio)
  - Esperado: 
    - El sistema debe aceptar el username con o sin @
    - Se guarda sin el @ en Firestore
  - Estado: 🔄

- [ ] **REG-010:** Validación de contraseña en tiempo real
  - Pasos: 
    1. Escribir contraseña débil (ej: `12345`)
    2. Salir del campo de contraseña
    3. Escribir contraseña mejor (ej: `12345678`)
    4. Salir del campo
    5. Añadir mayúscula (ej: `Password123!`)
    6. Salir del campo
  - Esperado: 
    - Los errores se muestran al salir del campo
    - Los errores desaparecen cuando se cumplen los requisitos
    - El botón "Crear Cuenta" se habilita solo cuando la contraseña es válida
  - Estado: ✅

- [ ] **REG-011:** Validación de email en tiempo real
  - Pasos: 
    1. Escribir email inválido (ej: `usuario@`)
    2. Salir del campo de email
    3. Escribir email válido (ej: `usuario@email.com`)
    4. Salir del campo
  - Esperado: 
    - Error "El formato del email no es válido" al salir con email inválido
    - El error desaparece cuando el email es válido
    - El botón "Crear Cuenta" se habilita solo cuando el email es válido
  - Estado: ✅

- [ ] **REG-012:** Validación de confirmar contraseña en tiempo real
  - Pasos: 
    1. Escribir contraseña válida (ej: `Password123!`)
    2. Escribir confirmación diferente (ej: `Password456!`)
    3. Salir del campo de confirmar contraseña
    4. Escribir la misma contraseña
    5. Salir del campo
  - Esperado: 
    - Error "Las contraseñas no coinciden" al salir si no coinciden
    - El error desaparece cuando coinciden
    - El botón "Crear Cuenta" se habilita solo cuando las contraseñas coinciden
  - Estado: ✅

- [ ] **REG-013:** Botón "Crear Cuenta" deshabilitado hasta que todo sea válido
  - Pasos: 
    1. Abrir formulario de registro
    2. Verificar que el botón está deshabilitado
    3. Seleccionar checkbox de términos (sin llenar campos)
    4. Completar todos los campos correctamente uno por uno
  - Esperado: 
    - El botón está deshabilitado inicialmente
    - El botón sigue deshabilitado si solo se selecciona el checkbox
    - El botón se habilita solo cuando todos los campos son válidos Y el checkbox está seleccionado
  - Estado: ✅

### 1.2 Inicio de Sesión

**⚠️ IMPORTANTE (T163):** A partir de T163, el login acepta tanto **email** como **username** (con o sin @).

- [ ] **LOGIN-001:** Iniciar sesión con email válido
  - Pasos: 
    1. Ingresar email válido (ej: `unplanazoo+admin@gmail.com`)
    2. Ingresar contraseña correcta
  - Esperado: 
    - Login exitoso
    - Sesión activa
    - Redirección a dashboard
  - Estado: ✅

- [ ] **LOGIN-002:** Iniciar sesión con username (con @)
  - Pasos: 
    1. Ingresar username con @ (ej: `@admin`)
    2. Ingresar contraseña correcta
  - Esperado: 
    - Login exitoso
    - El sistema detecta que es username y busca el email asociado
    - Sesión activa
  - Estado: ✅

- [ ] **LOGIN-003:** Iniciar sesión con username (sin @)
  - Pasos: 
    1. Ingresar username sin @ (ej: `admin`)
    2. Ingresar contraseña correcta
  - Esperado: 
    - Login exitoso
    - El sistema detecta que es username (no contiene @) y busca el email asociado
    - Sesión activa
  - Estado: ✅

- [ ] **LOGIN-004:** Iniciar sesión con email incorrecto
  - Pasos: Email no registrado (usar email que NO exista)
  - Esperado: Error "No se encontró una cuenta con este email"
  - **⚠️ IMPORTANTE:** El usuario NO debe existir. Usar email que no esté registrado.
  - Estado: 🔄

- [ ] **LOGIN-005:** Iniciar sesión con username incorrecto/no existente
  - Pasos: 
    1. Ingresar username que no existe (ej: `usuario_inexistente`)
    2. Ingresar cualquier contraseña
  - Esperado: Error "No se encontró un usuario con ese nombre de usuario"
  - Estado: ✅

- [ ] **LOGIN-006:** Iniciar sesión con contraseña incorrecta (usando email)
  - Pasos: Email correcto, contraseña incorrecta
  - Esperado: Error "Contraseña incorrecta"
  - Estado: 🔄

- [ ] **LOGIN-007:** Iniciar sesión con contraseña incorrecta (usando username)
  - Pasos: 
    1. Username correcto (ej: `@admin`)
    2. Contraseña incorrecta
  - Esperado: Error "Contraseña incorrecta"
  - Estado: 🔄

- [ ] **LOGIN-008:** Validación de campo email/username en login
  - Pasos: 
    1. Intentar login con campo vacío
    2. Intentar login con formato inválido (ni email ni username válido)
  - Esperado: 
    - Error de validación: "Ingresa un email válido o un nombre de usuario"
    - El campo muestra el error claramente
  - Estado: 🔄

- [ ] **LOGIN-009:** Icono dinámico en campo de login
  - Pasos: 
    1. Escribir un email (ej: `usuario@email.com`)
    2. Borrar y escribir un username (ej: `@usuario`)
  - Esperado: 
    - El icono cambia dinámicamente: email icon cuando es email, @ icon cuando es username
  - Estado: 🔄

- [ ] **LOGIN-015:** Recuperar contraseña
  - Pasos: Click "Olvidé mi contraseña", ingresar email
  - Esperado: Email de recuperación enviado
  - Estado: 🔄

- [ ] **LOGIN-016:** Cerrar sesión
  - Pasos: Click en logout
  - Esperado: Sesión cerrada, redirección a login
  - Estado: 🔄

- [ ] **LOGIN-010:** Iniciar sesión con Google (nuevo usuario)
  - Pasos: 
    1. Hacer clic en "Continuar con Google"
    2. Seleccionar una cuenta de Google que NO esté registrada en la app
    3. Aceptar permisos
  - Esperado: 
    - Login exitoso
    - Se crea automáticamente un usuario en Firestore
    - Se genera automáticamente un username
    - Se guardan los datos de Google (email, nombre, foto)
    - Redirección a dashboard
  - Estado: 🔄

- [ ] **LOGIN-011:** Iniciar sesión con Google (usuario existente)
  - Pasos: 
    1. Hacer clic en "Continuar con Google"
    2. Seleccionar una cuenta de Google que YA esté registrada en la app
    3. Aceptar permisos
  - Esperado: 
    - Login exitoso
    - Se actualiza `lastLoginAt`
    - Si no tiene username, se genera automáticamente
    - Redirección a dashboard
  - Estado: 🔄

- [ ] **LOGIN-012:** Cancelar login con Google
  - Pasos: 
    1. Hacer clic en "Continuar con Google"
    2. Cancelar la selección de cuenta
  - Esperado: 
    - No se muestra error
    - El usuario permanece en la pantalla de login
    - No se crea ningún usuario
  - Estado: 🔄

- [ ] **LOGIN-013:** Verificar datos de Google en Firestore
  - Pasos: 
    1. Hacer login con Google
    2. Verificar en Firestore que el usuario tiene:
       - `email` (del Google)
       - `displayName` (del Google)
       - `photoURL` (del Google)
       - `username` (generado automáticamente)
       - `usernameLower` (en minúsculas)
  - Esperado: 
    - Todos los campos están presentes y correctos
    - El username es único y válido
  - Estado: 🔄

- [ ] **LOGIN-014:** Ciclo completo logout/login sin errores de permisos (T159)
  - Pasos: 
    1. Hacer login con usuario válido
    2. Navegar a un plan y verificar que eventos/alojamientos se cargan correctamente
    3. Hacer logout
    4. Hacer login nuevamente con el mismo usuario
    5. Navegar al mismo plan y verificar que eventos/alojamientos se cargan correctamente
  - Esperado: 
    - No aparecen errores de permisos (`permission-denied`) después del segundo login
    - Las consultas a `event_participants` y otras colecciones funcionan correctamente
    - El comportamiento es idéntico al primer login
  - **⚠️ IMPORTANTE:** Esta prueba verifica que el token de autenticación se sincroniza correctamente después de logout/login. Relacionado con T159.
  - Estado: 🔄

### 1.3 Sesión Persistente

- [ ] **SESSION-001:** Persistencia de sesión tras cerrar app
  - Pasos: Login, cerrar app completamente, reabrir
  - Esperado: Usuario sigue logueado
  - Estado: 🔄

- [ ] **SESSION-002:** Expiración de sesión
  - Pasos: Dejar app inactiva por tiempo prolongado
  - Esperado: Logout automático o renovación de sesión
  - Estado: 🔄

---

## 2. GESTIÓN DE USUARIOS

### 2.1 Perfil de Usuario

- [ ] **PROF-001:** Ver perfil propio
  - Pasos: Acceder a página de perfil
  - Esperado: Muestra información del usuario actual
  - Estado: 🔄

- [ ] **PROF-002:** Editar nombre de usuario
  - Pasos: Modificar nombre en perfil
  - Esperado: Cambios guardados correctamente
  - Estado: 🔄

- [ ] **PROF-003:** Cambiar email
  - Pasos: Modificar email
  - Esperado: Validación y confirmación requerida
  - Estado: 🔄

- [ ] **PROF-004:** Cambiar contraseña (validación mejorada)
  - Pasos: 
    1. Ir a configuración de cuenta
    2. Intentar cambiar contraseña con nueva contraseña que no cumple requisitos:
       - Menos de 8 caracteres
       - Sin mayúscula
       - Sin minúscula
       - Sin número
       - Sin carácter especial
    3. Cambiar a contraseña válida (ej: `NuevaPass123!`)
  - Esperado: 
    - Validación de contraseña actual requerida
    - Errores específicos para cada requisito faltante en la nueva contraseña
    - Cambio exitoso solo con contraseña que cumple todos los requisitos
  - Estado: 🔄

- [ ] **PROF-005:** Subir foto de perfil
  - Pasos: Seleccionar imagen desde dispositivo
  - Esperado: Imagen subida y visible en perfil
  - Estado: 🔄

### 2.2 Configuración de Usuario

- [ ] **CONF-001:** Configurar preferencias de notificaciones
  - Pasos: Ajustar preferencias en configuración
  - Esperado: Preferencias guardadas y aplicadas
  - Estado: 🔄

- [ ] **CONF-002:** Seleccionar idioma de la app
  - Pasos: Cambiar idioma (ES/EN)
  - Esperado: UI actualizada al idioma seleccionado
  - Estado: 🔄

- [ ] **CONF-003:** Configurar timezone por defecto
  - Pasos: Establecer timezone preferido
  - Esperado: Nuevos eventos usan timezone por defecto
  - Estado: 🔄

---

## 3. CRUD DE PLANES

### 3.1 Crear Plan

- [ ] **PLAN-C-001:** Crear plan básico
  - Pasos: Nombre, fechas, descripción, crear
  - Esperado: Plan creado en estado "borrador"
  - Estado: 🔄

- [ ] **PLAN-C-002:** Crear plan sin nombre
  - Pasos: Intentar crear sin nombre obligatorio
  - Esperado: Validación que requiera nombre
  - Estado: 🔄

- [ ] **PLAN-C-003:** Crear plan con fechas inválidas
  - Pasos: Fecha fin anterior a fecha inicio
  - Esperado: Validación de rango de fechas
  - Estado: 🔄

- [ ] **PLAN-C-004:** Crear plan con imagen
  - Pasos: Añadir imagen al crear plan
  - Esperado: Imagen subida y visible en plan
  - Estado: 🔄

- [ ] **PLAN-C-005:** Crear plan con participantes iniciales
  - Pasos: Invitar usuarios al crear plan
  - Esperado: Participantes añadidos al plan
  - Estado: 🔄

- [ ] **PLAN-C-006:** Crear plan con presupuesto inicial
  - Pasos: Establecer presupuesto estimado
  - Esperado: Presupuesto guardado y visible
  - Estado: 🔄

- [ ] **PLAN-C-007:** Crear plan con timezone específico
  - Pasos: Seleccionar timezone diferente al por defecto
  - Esperado: Plan usa timezone seleccionado
  - Estado: 🔄

### 3.2 Leer/Ver Plan

- [ ] **PLAN-R-001:** Ver lista de planes propios
  - Pasos: Acceder a dashboard
  - Esperado: Lista de planes del usuario
  - Estado: 🔄

- [ ] **PLAN-R-002:** Ver planes como participante
  - Pasos: Acceder a planes donde soy participante
  - Esperado: Planes visibles con permisos correctos
  - Estado: 🔄

- [ ] **PLAN-R-003:** Ver detalles completos de plan
  - Pasos: Abrir plan específico
  - Esperado: Muestra toda la información del plan
  - Estado: 🔄

- [ ] **PLAN-R-004:** Ver planes filtrados por estado
  - Pasos: Filtrar por "Confirmados", "Borradores", etc.
  - Esperado: Filtrado correcto según estado
  - Estado: 🔄

- [ ] **PLAN-R-005:** Buscar plan por nombre
  - Pasos: Usar búsqueda en lista de planes
  - Esperado: Resultados coincidentes con búsqueda
  - Estado: 🔄

### 3.3 Actualizar Plan

- [ ] **PLAN-U-001:** Modificar nombre del plan
  - Pasos: Editar nombre en plan existente
  - Esperado: Cambio guardado correctamente
  - Estado: 🔄

- [ ] **PLAN-U-002:** Modificar fechas del plan
  - Pasos: Cambiar fechas de inicio/fin
  - Esperado: Fechas actualizadas, calendario ajustado
  - Estado: 🔄

- [ ] **PLAN-U-003:** Expandir rango del plan (T107)
  - Pasos: Crear evento fuera del rango actual
  - Esperado: Diálogo de confirmación, expansión automática
  - Estado: ✅

- [ ] **PLAN-U-004:** Cambiar imagen del plan
  - Pasos: Reemplazar imagen existente
  - Esperado: Nueva imagen visible en plan
  - Estado: 🔄

- [ ] **PLAN-U-005:** Actualizar descripción
  - Pasos: Modificar descripción del plan
  - Esperado: Descripción actualizada
  - Estado: 🔄

- [ ] **PLAN-U-006:** Cambiar timezone del plan
  - Pasos: Modificar timezone en plan existente
  - Esperado: Eventos ajustados al nuevo timezone
  - Estado: 🔄

- [ ] **PLAN-U-007:** Actualizar presupuesto del plan
  - Pasos: Modificar presupuesto estimado
  - Esperado: Presupuesto actualizado
  - Estado: 🔄

### 3.4 Eliminar Plan

- [ ] **PLAN-D-001:** Eliminar plan propio
  - Pasos: Eliminar plan como organizador
  - Esperado: Plan eliminado, no visible en lista
  - Estado: 🔄

- [ ] **PLAN-D-002:** Intentar eliminar plan como participante
  - Pasos: Intentar eliminar plan donde soy participante
  - Esperado: No se puede eliminar, solo organizador
  - Estado: 🔄

- [ ] **PLAN-D-003:** Confirmación antes de eliminar
  - Pasos: Click eliminar plan
  - Esperado: Diálogo de confirmación
  - Estado: 🔄

- [ ] **PLAN-D-004:** Eliminar plan con eventos asociados
  - Pasos: Eliminar plan que tiene eventos
  - Esperado: Eliminación en cascada o aviso de eventos asociados
  - Estado: 🔄

---

## 4. CRUD DE EVENTOS

### 4.1 Crear Evento

- [ ] **EVENT-C-001:** Crear evento básico
  - Pasos: Nombre, fecha, hora, descripción, guardar
  - Esperado: Evento creado en calendario
  - Estado: 🔄

- [ ] **EVENT-C-002:** Crear evento sin descripción
  - Pasos: Intentar crear sin descripción obligatoria
  - Esperado: Validación que requiera descripción
  - Estado: ✅

- [ ] **EVENT-C-003:** Crear evento multi-participante (T47)
  - Pasos: Seleccionar múltiples participantes
  - Esperado: Evento visible para todos los participantes
  - Estado: ✅

- [ ] **EVENT-C-004:** Crear evento "para todos" (T47)
  - Pasos: Marcar checkbox "Para todos los participantes"
  - Esperado: Evento aplica a todos automáticamente
  - Estado: ✅

- [ ] **EVENT-C-005:** Crear evento con duración personalizada
  - Pasos: Seleccionar duración específica (ej: 45 min, 3h)
  - Esperado: Duración correcta en calendario
  - Estado: 🔄

- [ ] **EVENT-C-006:** Crear evento que dura más de 24h
  - Pasos: Intentar evento > 24h
  - Esperado: Validación que sugiera usar Alojamiento
  - Estado: ✅

- [ ] **EVENT-C-007:** Crear evento con timezone específico
  - Pasos: Seleccionar timezone diferente al del plan
  - Esperado: Hora correcta según timezone
  - Estado: 🔄

- [ ] **EVENT-C-008:** Crear evento con timezone de llegada (T40)
  - Pasos: Evento con timezone salida y llegada diferentes
  - Esperado: Conversión correcta de horarios
  - Estado: 🔄

- [ ] **EVENT-C-009:** Crear evento con límite de participantes (T117)
  - Pasos: Establecer máximo de participantes
  - Esperado: Límite aplicado, contador visible
  - Estado: ✅

- [ ] **EVENT-C-010:** Crear evento que requiere confirmación (T120)
  - Pasos: Marcar "Requiere confirmación"
  - Esperado: Confirmaciones pendientes creadas
  - Estado: ✅

- [ ] **EVENT-C-011:** Crear evento con coste (T101)
  - Pasos: Añadir coste al crear evento
  - Esperado: Coste guardado, incluido en presupuesto
  - Estado: ✅

- [ ] **EVENT-C-012:** Crear evento como borrador
  - Pasos: Marcar como borrador
  - Esperado: Evento no aparece en vista normal, solo en borradores
  - Estado: 🔄

- [ ] **EVENT-C-013:** Crear evento con color personalizado
  - Pasos: Seleccionar color específico
  - Esperado: Color aplicado en calendario
  - Estado: 🔄

- [ ] **EVENT-C-014:** Crear evento con tipo y subtipo
  - Pasos: Seleccionar familia (ej: Desplazamiento) y subtipo (ej: Avión)
  - Esperado: Tipo aplicado, colores correspondientes
  - Estado: 🔄

- [ ] **EVENT-C-015:** Crear evento con documentos adjuntos
  - Pasos: Adjuntar archivos (reservas, tickets)
  - Esperado: Documentos guardados y accesibles
  - Estado: 🔄

- [ ] **EVENT-C-016:** Crear evento solapado con otro
  - Pasos: Crear evento que solapa horario existente
  - Esperado: Validación de solapamiento o ajuste automático
  - Estado: 🔄

- [ ] **EVENT-C-017:** Crear evento fuera del rango del plan (T107)
  - Pasos: Crear evento antes de inicio o después de fin
  - Esperado: Diálogo de expansión, actualización automática
  - Estado: ✅

### 4.2 Leer/Ver Eventos

- [ ] **EVENT-R-001:** Ver eventos del plan en calendario
  - Pasos: Abrir calendario del plan
  - Esperado: Todos los eventos visibles en fechas correctas
  - Estado: 🔄

- [ ] **EVENT-R-002:** Ver detalles completos de evento
  - Pasos: Click en evento
  - Esperado: Modal/diálogo con toda la información
  - Estado: 🔄

- [ ] **EVENT-R-003:** Ver eventos filtrados por participante
  - Pasos: Filtrar calendario por participante específico
  - Esperado: Solo eventos de ese participante visibles
  - Estado: 🔄

- [ ] **EVENT-R-004:** Ver eventos filtrados por tipo
  - Pasos: Filtrar por tipo (ej: solo Desplazamiento)
  - Esperado: Solo eventos del tipo seleccionado
  - Estado: 🔄

- [ ] **EVENT-R-005:** Ver eventos borradores
  - Pasos: Acceder a vista de borradores
  - Esperado: Solo eventos en estado borrador
  - Estado: 🔄

- [ ] **EVENT-R-006:** Ver eventos con indicadores de participantes (T50)
  - Pasos: Ver calendario con eventos multi-participante
  - Esperado: Badges/iconos indicando cantidad participantes
  - Estado: ✅

- [ ] **EVENT-R-007:** Ver track activo resaltado (T90)
  - Pasos: Seleccionar participante
  - Esperado: Track del participante resaltado visualmente
  - Estado: ✅

### 4.3 Actualizar Evento

- [ ] **EVENT-U-001:** Modificar descripción de evento
  - Pasos: Editar descripción
  - Esperado: Cambio guardado
  - Estado: 🔄

- [ ] **EVENT-U-002:** Modificar fecha/hora de evento
  - Pasos: Cambiar fecha y hora
  - Esperado: Evento movido en calendario
  - Estado: 🔄

- [ ] **EVENT-U-003:** Mover evento por drag & drop
  - Pasos: Arrastrar evento a otra fecha/hora (plan en estado permitido)
  - Esperado: Evento movido, cambios guardados
  - Estado: ✅
  
- [ ] **EVENT-U-003a:** Bloqueo de drag & drop según estado del plan
  - Pasos: Intentar arrastrar evento en plan finalizado/en_curso sin permisos
  - Esperado: Mensaje de bloqueo, evento no se mueve
  - Estado: ✅

- [ ] **EVENT-U-004:** Modificar participantes de evento
  - Pasos: Añadir/eliminar participantes
  - Esperado: Lista de participantes actualizada
  - Estado: 🔄

- [ ] **EVENT-U-005:** Cambiar de evento específico a "para todos"
  - Pasos: Marcar checkbox "Para todos"
  - Esperado: Evento aplica a todos automáticamente
  - Estado: 🔄

- [ ] **EVENT-U-006:** Actualizar coste de evento (T101)
  - Pasos: Modificar coste
  - Esperado: Presupuesto recalculado
  - Estado: ✅

- [ ] **EVENT-U-007:** Cambiar estado de borrador a confirmado
  - Pasos: Desmarcar como borrador
  - Esperado: Evento visible en calendario normal
  - Estado: 🔄

- [ ] **EVENT-U-008:** Actualizar información personal del evento
  - Pasos: Modificar campos personales (asiento, notas)
  - Esperado: Información personal guardada
  - Estado: 🔄

### 4.4 Eliminar Evento

- [ ] **EVENT-D-001:** Eliminar evento propio
  - Pasos: Eliminar evento que creé (plan en estado permitido)
  - Esperado: Evento eliminado del calendario
  - Estado: ✅

- [ ] **EVENT-D-002:** Intentar eliminar evento de otro usuario
  - Pasos: Intentar eliminar evento creado por otro
  - Esperado: No permitido o solo organizador puede
  - Estado: 🔄

- [ ] **EVENT-D-003:** Confirmación antes de eliminar
  - Pasos: Click eliminar evento
  - Esperado: Diálogo de confirmación
  - Estado: ✅
  
- [ ] **EVENT-D-004:** Bloqueo de eliminar según estado del plan
  - Pasos: Intentar eliminar evento en plan finalizado/cancelado
  - Esperado: Botón "Eliminar" deshabilitado, mensaje informativo
  - Estado: ✅

---

## 5. CRUD DE ALOJAMIENTOS

### 5.1 Crear Alojamiento

- [ ] **ACC-C-001:** Crear alojamiento básico
  - Pasos: Nombre, check-in, check-out, crear
  - Esperado: Alojamiento creado en fila de alojamientos
  - Estado: 🔄

- [ ] **ACC-C-002:** Crear alojamiento sin nombre
  - Pasos: Intentar crear sin nombre obligatorio
  - Esperado: Validación que requiera nombre
  - Estado: ✅

- [ ] **ACC-C-003:** Crear con check-out anterior a check-in
  - Pasos: Fechas inválidas
  - Esperado: Validación de rango de fechas
  - Estado: ✅

- [ ] **ACC-C-004:** Crear alojamiento con participantes específicos
  - Pasos: Seleccionar participantes para alojamiento
  - Esperado: Alojamiento visible solo para participantes seleccionados
  - Estado: 🔄

- [ ] **ACC-C-005:** Crear alojamiento con coste (T101)
  - Pasos: Añadir coste total
  - Esperado: Coste guardado, incluido en presupuesto
  - Estado: ✅

- [ ] **ACC-C-006:** Crear alojamiento solapado con otro
  - Pasos: Fechas que solapan alojamiento existente
  - Esperado: Validación o advertencia de conflicto
  - Estado: 🔄

- [ ] **ACC-C-007:** Crear alojamiento con tipo específico
  - Pasos: Seleccionar tipo (Hotel, Apartamento, etc.)
  - Esperado: Tipo guardado y visible
  - Estado: 🔄

### 5.2 Ver Alojamientos

- [ ] **ACC-R-001:** Ver alojamientos en fila dedicada
  - Pasos: Ver calendario con alojamientos
  - Esperado: Fila de alojamientos visible
  - Estado: 🔄

- [ ] **ACC-R-002:** Ver detalles de alojamiento
  - Pasos: Click en alojamiento
  - Esperado: Modal con información completa
  - Estado: 🔄

- [ ] **ACC-R-003:** Ver alojamientos filtrados por participante
  - Pasos: Filtrar calendario por participante
  - Esperado: Solo alojamientos del participante
  - Estado: 🔄

### 5.3 Actualizar Alojamiento

- [ ] **ACC-U-001:** Modificar fechas de alojamiento
  - Pasos: Cambiar check-in/check-out
  - Esperado: Alojamiento ajustado en calendario
  - Estado: 🔄

- [ ] **ACC-U-002:** Mover alojamiento por drag & drop
  - Pasos: Arrastrar a nuevas fechas (plan en estado permitido)
  - Esperado: Fechas actualizadas automáticamente
  - Estado: 🔄
  
- [ ] **ACC-U-002a:** Bloqueo de editar alojamiento según estado del plan
  - Pasos: Intentar editar alojamiento en plan finalizado/en_curso sin permisos
  - Esperado: Botón "Guardar" deshabilitado o mensaje de bloqueo
  - Estado: ✅

- [ ] **ACC-U-003:** Actualizar coste (T101)
  - Pasos: Modificar coste
  - Esperado: Presupuesto recalculado
  - Estado: ✅

### 5.4 Eliminar Alojamiento

- [ ] **ACC-D-001:** Eliminar alojamiento
  - Pasos: Eliminar alojamiento (plan en estado permitido)
  - Esperado: Eliminado del calendario
  - Estado: ✅
  
- [ ] **ACC-D-001a:** Bloqueo de eliminar alojamiento según estado del plan
  - Pasos: Intentar eliminar alojamiento en plan finalizado/cancelado
  - Esperado: Botón "Eliminar" deshabilitado, mensaje informativo
  - Estado: ✅

---

## 6. GESTIÓN DE PARTICIPANTES

### 6.1 Añadir Participantes

- [ ] **PART-ADD-001:** Invitar participante por email
  - Pasos: Invitar con email válido
  - Esperado: Invitación enviada, participante añadido tras aceptar
  - Estado: ✅

- [ ] **PART-ADD-002:** Invitar participante por ID de usuario
  - Pasos: Invitar usuario existente por ID
  - Esperado: Participante añadido directamente
  - Estado: 🔄

- [ ] **PART-ADD-003:** Invitar grupo de participantes (T123)
  - Pasos: Seleccionar grupo guardado
  - Esperado: Todos los miembros del grupo invitados
  - Estado: ✅

- [ ] **PART-ADD-004:** Invitar email ya invitado
  - Pasos: Re-invitar mismo email
  - Esperado: Validación o actualización de invitación
  - Estado: 🔄

- [ ] **PART-ADD-005:** Invitar email inválido
  - Pasos: Email con formato incorrecto
  - Esperado: Validación de formato de email
  - Estado: ✅

### 6.2 Ver Participantes

- [ ] **PART-R-001:** Ver lista de participantes del plan
  - Pasos: Acceder a página de participantes
  - Esperado: Lista completa con roles
  - Estado: 🔄

- [ ] **PART-R-002:** Ver rol de cada participante
  - Pasos: Ver lista de participantes
  - Esperado: Roles visibles (Organizador, Participante, Observador)
  - Estado: 🔄

- [ ] **PART-R-003:** Ver eventos de un participante
  - Pasos: Filtrar calendario por participante
  - Esperado: Solo eventos del participante visibles
  - Estado: 🔄

### 6.3 Modificar Participantes

- [ ] **PART-U-001:** Cambiar rol de participante
  - Pasos: Modificar rol (solo organizador puede)
  - Esperado: Rol actualizado, permisos aplicados
  - Estado: 🔄

- [ ] **PART-U-002:** Editar información de participación
  - Pasos: Modificar campos personales
  - Esperado: Cambios guardados
  - Estado: 🔄

### 6.4 Eliminar Participantes

- [ ] **PART-D-001:** Eliminar participante del plan
  - Pasos: Remover participante (solo organizador)
  - Esperado: Participante eliminado, eventos ajustados
  - Estado: 🔄

- [ ] **PART-D-002:** Participante se auto-elimina
  - Pasos: Participante abandona plan
  - Esperado: Removido del plan
  - Estado: 🔄

- [ ] **PART-D-003:** Intentar eliminar organizador
  - Pasos: Intentar remover organizador
  - Esperado: No permitido, aviso claro
  - Estado: 🔄

### 6.5 Grupos de Participantes (T123)

- [ ] **GRP-001:** Crear grupo de participantes
  - Pasos: Crear nuevo grupo con nombre y miembros
  - Esperado: Grupo guardado y reutilizable
  - Estado: ✅

- [ ] **GRP-002:** Editar grupo existente
  - Pasos: Modificar miembros o nombre
  - Esperado: Cambios guardados
  - Estado: ✅

- [ ] **GRP-003:** Eliminar grupo
  - Pasos: Eliminar grupo
  - Esperado: Grupo eliminado
  - Estado: ✅

- [ ] **GRP-004:** Invitar grupo completo a plan
  - Pasos: Usar grupo en invitación
  - Esperado: Todos los miembros invitados
  - Estado: ✅

---

## 7. INVITACIONES Y NOTIFICACIONES

### 7.1 Invitaciones por Email (T104)

- [ ] **INV-001:** Enviar invitación por email
  - Pasos: Invitar usuario no registrado
  - Esperado: Email enviado con link de invitación
  - **⚠️ IMPORTANTE:** El usuario invitado NO debe existir. Usar `unplanazoo+invite1@gmail.com` o similar.
  - Estado: ✅

- [ ] **INV-002:** Aceptar invitación desde link
  - Pasos: Click en link de invitación
  - Esperado: Si no logueado: login, luego aceptar (o registro si usuario no existe)
  - **⚠️ IMPORTANTE:** Para probar flujo completo, usar invitación a usuario que NO existe para probar registro desde invitación.
  - Estado: ✅

- [ ] **INV-003:** Rechazar invitación
  - Pasos: Rechazar desde link
  - Esperado: Invitación marcada como rechazada
  - Estado: ✅

- [ ] **INV-004:** Invitación expirada
  - Pasos: Usar link después de expiración
  - Esperado: Mensaje de invitación expirada
  - Estado: 🔄

- [ ] **INV-005:** Invitación ya aceptada
  - Pasos: Usar link de invitación ya aceptada
  - Esperado: Mensaje de ya participante
  - Estado: 🔄

- [ ] **INV-006:** Invitación con token inválido
  - Pasos: Usar token modificado o falso
  - Esperado: Error de seguridad, no acceso
  - Estado: ✅

### 7.2 Registro de Participantes en Eventos (T117)

- [ ] **REG-EVENT-001:** Apuntarse a evento
  - Pasos: Click "Apuntarse" en evento
  - Esperado: Usuario registrado en evento
  - Estado: ✅

- [ ] **REG-EVENT-002:** Cancelar participación en evento
  - Pasos: Click "Cancelar" en evento al que estoy apuntado
  - Esperado: Registro cancelado
  - Estado: ✅

- [ ] **REG-EVENT-003:** Apuntarse a evento con límite (T117)
  - Pasos: Apuntarse cuando quedan plazas
  - Esperado: Registro exitoso, contador actualizado
  - Estado: ✅

- [ ] **REG-EVENT-004:** Apuntarse a evento completo
  - Pasos: Intentar apuntarse cuando no hay plazas
  - Esperado: Error "Evento completo" o lista de espera
  - Estado: 🔄

- [ ] **REG-EVENT-005:** Ver participantes de evento
  - Pasos: Ver lista de participantes registrados
  - Esperado: Lista completa con nombres
  - Estado: ✅

### 7.3 Confirmaciones de Eventos (T120)

- [ ] **CONF-001:** Confirmar asistencia a evento
  - Pasos: Click "Confirmar" en evento que requiere confirmación
  - Esperado: Estado cambiado a "confirmed"
  - Estado: ✅

- [ ] **CONF-002:** Rechazar asistencia a evento
  - Pasos: Click "Rechazar"
  - Esperado: Estado "declined"
  - Estado: ✅

- [ ] **CONF-003:** Ver estadísticas de confirmaciones
  - Pasos: Ver resumen de confirmados/pendientes/rechazados
  - Esperado: Contadores correctos
  - Estado: ✅

- [ ] **CONF-004:** Cambiar confirmación
  - Pasos: Cambiar de confirmado a rechazado o viceversa
  - Esperado: Estado actualizado
  - Estado: ✅

---

## 8. ESTADOS DEL PLAN

### 8.1 Transiciones de Estado (T109)

- [ ] **STATE-001:** Borrador → Planificando (automático)
  - Pasos: Guardar plan en estado borrador
  - Esperado: Transición automática a "planificando"
  - Estado: ✅

- [ ] **STATE-002:** Planificando → Confirmado (manual)
  - Pasos: Cambiar estado manualmente
  - Esperado: Validaciones ejecutadas, estado actualizado
  - Estado: ✅

- [ ] **STATE-003:** Confirmado → En Curso (automático)
  - Pasos: Fecha de inicio alcanzada
  - Esperado: Transición automática
  - Estado: ✅

- [ ] **STATE-004:** En Curso → Finalizado (automático)
  - Pasos: Fecha de fin alcanzada
  - Esperado: Transición automática
  - Estado: ✅

- [ ] **STATE-005:** Cancelar plan
  - Pasos: Cambiar estado a "cancelado"
  - Esperado: Plan cancelado, acciones bloqueadas
  - Estado: 🔄

- [ ] **STATE-006:** Badges de estado visibles
  - Pasos: Ver plan en lista o detalle
  - Esperado: Badge muestra estado actual
  - Estado: ✅

- [ ] **STATE-007:** Validaciones antes de confirmar
  - Pasos: Intentar confirmar plan
  - Esperado: Validaciones de días vacíos y participantes sin eventos
  - Estado: ✅

### 8.2 Permisos por Estado

- [ ] **PERM-STATE-001:** Editar plan en estado borrador
  - Pasos: Modificar plan borrador
  - Esperado: Permitido
  - Estado: ✅

- [ ] **PERM-STATE-002:** Editar plan confirmado
  - Pasos: Intentar modificar plan confirmado
  - Esperado: Restricciones según permisos
  - Estado: ✅

- [ ] **PERM-STATE-003:** Añadir eventos en plan finalizado
  - Pasos: Intentar crear evento en plan finalizado
  - Esperado: No permitido, botón deshabilitado y mensaje informativo
  - Estado: ✅

### 8.3 Bloqueos Funcionales por Estado (T109)

- [ ] **BLOCK-001:** Crear evento en plan "Finalizado"
  - Pasos: Plan en estado "finalizado", intentar doble click en calendario
  - Esperado: Mensaje de bloqueo, no se abre diálogo
  - Estado: ✅

- [ ] **BLOCK-002:** Crear evento en plan "Cancelado"
  - Pasos: Plan en estado "cancelado", intentar doble click
  - Esperado: Mensaje de bloqueo, no se abre diálogo
  - Estado: ✅

- [ ] **BLOCK-003:** Crear evento en plan "En Curso"
  - Pasos: Plan en estado "en_curso", intentar doble click
  - Esperado: Mensaje de bloqueo (solo organizador puede crear eventos urgentes)
  - Estado: ✅

- [ ] **BLOCK-004:** Mover evento por drag & drop en plan "Finalizado"
  - Pasos: Plan finalizado, intentar arrastrar evento
  - Esperado: Mensaje de bloqueo, evento no se mueve
  - Estado: ✅

- [ ] **BLOCK-005:** Mover evento por drag & drop en plan "En Curso"
  - Pasos: Plan en_curso, intentar arrastrar evento
  - Esperado: Mensaje de bloqueo (solo cambios urgentes)
  - Estado: ✅

- [ ] **BLOCK-006:** Editar evento en plan "Finalizado"
  - Pasos: Plan finalizado, abrir diálogo de evento
  - Esperado: Botón "Guardar" deshabilitado
  - Estado: ✅

- [ ] **BLOCK-007:** Eliminar evento en plan "Finalizado"
  - Pasos: Plan finalizado, abrir diálogo de evento
  - Esperado: Botón "Eliminar" deshabilitado
  - Estado: ✅

- [ ] **BLOCK-008:** Crear alojamiento en plan "Finalizado"
  - Pasos: Plan finalizado, intentar doble click en fila de alojamientos
  - Esperado: Mensaje de bloqueo, no se abre diálogo
  - Estado: ✅

- [ ] **BLOCK-009:** Editar alojamiento en plan "En Curso"
  - Pasos: Plan en_curso, abrir diálogo de alojamiento
  - Esperado: Botón "Guardar" deshabilitado o mensaje de bloqueo
  - Estado: ✅

- [ ] **BLOCK-010:** Añadir participante en plan "En Curso"
  - Pasos: Plan en_curso, intentar invitar participante
  - Esperado: Botón de invitar deshabilitado, mensaje informativo
  - Estado: ✅

- [ ] **BLOCK-011:** Remover participante en plan "En Curso"
  - Pasos: Plan en_curso, intentar remover participante
  - Esperado: Opción "Remover" no visible en menú
  - Estado: ✅

- [ ] **BLOCK-012:** Crear evento en plan "Confirmado"
  - Pasos: Plan confirmado, intentar crear evento
  - Esperado: Permitido (se puede crear eventos nuevos)
  - Estado: ✅

- [ ] **BLOCK-013:** Modificar evento en plan "Confirmado"
  - Pasos: Plan confirmado, intentar editar evento
  - Esperado: Permitido (con restricciones menores)
  - Estado: ✅

- [ ] **BLOCK-014:** Eliminar evento en plan "Confirmado"
  - Pasos: Plan confirmado, intentar eliminar evento futuro
  - Esperado: Permitido (eventos futuros)
  - Estado: ✅

---

## 9. PRESUPUESTO Y PAGOS

### 9.1 Gestión de Presupuesto (T101)

- [ ] **BUD-001:** Añadir coste a evento
  - Pasos: Crear/editar evento con coste
  - Esperado: Coste guardado
  - Estado: ✅

- [ ] **BUD-002:** Añadir coste a alojamiento
  - Pasos: Crear/editar alojamiento con coste
  - Esperado: Coste guardado
  - Estado: ✅

- [ ] **BUD-003:** Ver presupuesto total del plan
  - Pasos: Acceder a estadísticas
  - Esperado: Total calculado correctamente
  - Estado: ✅

- [ ] **BUD-004:** Ver desglose por tipo de evento
  - Pasos: Ver sección presupuesto en estadísticas
  - Esperado: Desglose por familia de eventos
  - Estado: ✅

- [ ] **BUD-005:** Ver desglose eventos vs alojamientos
  - Pasos: Ver estadísticas de presupuesto
  - Esperado: Separación correcta
  - Estado: ✅

- [ ] **BUD-006:** Coste con decimales
  - Pasos: Introducir coste con decimales (ej: 150.50)
  - Esperado: Guardado correctamente
  - Estado: ✅

- [ ] **BUD-007:** Coste negativo
  - Pasos: Intentar coste negativo
  - Esperado: Validación que rechace valores negativos
  - Estado: ✅

- [ ] **BUD-008:** Coste muy alto
  - Pasos: Coste > 1.000.000€
  - Esperado: Validación de límite máximo
  - Estado: ✅

### 9.2 Sistema de Pagos (T102)

- [ ] **PAY-001:** Registrar pago individual
  - Estado: ✅

- [ ] **PAY-002:** Ver balance de participante
  - Estado: ✅

- [ ] **PAY-003:** Cálculo de deudas (sugerencias de transferencias)
  - Estado: ✅

### 9.3 Sistema Multi-moneda (T153)

- [ ] **CURR-001:** Crear plan con moneda diferente a EUR
  - Pasos: Crear plan y seleccionar moneda (USD, GBP, JPY)
  - Esperado: Plan creado con moneda seleccionada
  - Estado: 🔄

- [ ] **CURR-002:** Añadir coste a evento con moneda local diferente
  - Pasos: Crear evento con coste, seleccionar moneda diferente a la del plan (ej: USD en plan EUR)
  - Esperado: Conversión automática mostrada, coste guardado en moneda del plan
  - Estado: 🔄

- [ ] **CURR-003:** Ver conversión automática en EventDialog
  - Pasos: Introducir monto en moneda diferente, ver conversión
  - Esperado: Muestra conversión a moneda del plan con disclaimer
  - Estado: 🔄

- [ ] **CURR-004:** Añadir coste a alojamiento con moneda local diferente
  - Pasos: Crear alojamiento con coste en moneda diferente
  - Esperado: Conversión automática, coste guardado en moneda del plan
  - Estado: 🔄

- [ ] **CURR-005:** Registrar pago con moneda local diferente
  - Pasos: Registrar pago seleccionando moneda diferente a la del plan
  - Esperado: Conversión automática mostrada, pago guardado en moneda del plan
  - Estado: 🔄

- [ ] **CURR-006:** Ver formateo de moneda en estadísticas
  - Pasos: Ver PlanStatsPage con plan en USD/GBP/JPY
  - Esperado: Todos los montos formateados con símbolo correcto
  - Estado: 🔄

- [ ] **CURR-007:** Ver formateo de moneda en resumen de pagos
  - Pasos: Ver PaymentSummaryPage con plan en moneda diferente
  - Esperado: Montos, balances y sugerencias formateados correctamente
  - Estado: 🔄

- [ ] **CURR-008:** Inicializar tipos de cambio con botón temporal
  - Pasos: Usar botón "Init Exchange Rates" en dashboard (modo debug)
  - Esperado: Tipos de cambio creados en Firestore
  - Estado: 🔄

- [ ] **CURR-009:** Conversión con mismo par de moneda
  - Pasos: Seleccionar moneda local igual a la del plan
  - Esperado: No muestra conversión (1:1)
  - Estado: 🔄

- [ ] **CURR-010:** Manejo de error si no hay tipo de cambio
  - Pasos: Intentar conversión con tipo de cambio no disponible
  - Esperado: Manejo elegante, muestra monto original o error claro
  - Estado: 🔄

- [ ] **CURR-011:** Disclaimer visible en conversiones
  - Pasos: Ver conversión en cualquier campo de monto
  - Esperado: Disclaimer sobre tipos de cambio orientativos visible
  - Estado: 🔄

- [ ] **CURR-012:** Formateo correcto según decimales (JPY vs EUR)
  - Pasos: Plan en JPY (0 decimales) vs EUR/USD (2 decimales)
  - Esperado: Formateo correcto según moneda
  - Estado: 🔄

- [ ] **CURR-013:** Migración de planes existentes sin moneda
  - Pasos: Cargar plan antiguo sin campo currency
  - Esperado: Usa EUR por defecto automáticamente
  - Estado: 🔄

---

## 10. ESTADÍSTICAS DEL PLAN

### 10.1 Vista de Estadísticas (T113)

- [ ] **STAT-001:** Acceder a estadísticas del plan
  - Pasos: Click en botón "stats" (W17)
  - Esperado: Página de estadísticas cargada
  - Estado: ✅

- [ ] **STAT-002:** Ver resumen general
  - Pasos: Ver sección resumen
  - Esperado: Total eventos, confirmados, borradores, duración
  - Estado: ✅

- [ ] **STAT-003:** Ver eventos por tipo
  - Pasos: Ver sección de tipos
  - Esperado: Gráficos por familia de eventos
  - Estado: ✅

- [ ] **STAT-004:** Ver distribución temporal
  - Pasos: Ver sección temporal
  - Esperado: Eventos agrupados por día
  - Estado: ✅

- [ ] **STAT-005:** Ver estadísticas de participantes
  - Pasos: Ver sección participantes
  - Esperado: Total, activos, porcentaje actividad
  - Estado: ✅

- [ ] **STAT-006:** Ver presupuesto en estadísticas (T101)
  - Pasos: Ver sección presupuesto
  - Esperado: Si hay costes, muestra sección completa
  - Estado: ✅

- [ ] **STAT-007:** Estadísticas con plan vacío
  - Pasos: Plan sin eventos
  - Esperado: Estadísticas muestran ceros correctamente
  - Estado: 🔄

- [ ] **STAT-008:** Actualización en tiempo real
  - Pasos: Añadir evento mientras se ven estadísticas
  - Esperado: Estadísticas se actualizan automáticamente
  - Estado: 🔄

---

## 11. VALIDACIONES Y VERIFICACIONES

### 11.1 Validaciones de Plan

- [ ] **VAL-PLAN-001:** Validación días vacíos (VALID-1)
  - Pasos: Confirmar plan con días sin eventos
  - Esperado: Warning mostrado antes de confirmar
  - Estado: ✅

- [ ] **VAL-PLAN-002:** Validación participantes sin eventos (VALID-2)
  - Pasos: Confirmar con participantes sin eventos asignados
  - Esperado: Warning mostrado
  - Estado: ✅

- [ ] **VAL-PLAN-003:** Validaciones no bloquean confirmación
  - Pasos: Confirmar plan con warnings
  - Esperado: Permite continuar (solo warnings, no errores)
  - Estado: ✅

### 11.2 Validaciones de Eventos

- [ ] **VAL-EVENT-001:** Validación de solapamientos
  - Pasos: Crear evento que solapa otro del mismo participante
  - Esperado: Advertencia o bloqueo según configuración
  - Estado: 🔄

- [ ] **VAL-EVENT-002:** Validación de límite de participantes
  - Pasos: Superar límite máximo
  - Esperado: Bloqueo al intentar apuntarse
  - Estado: ✅

- [ ] **VAL-EVENT-003:** Validación de duración máxima
  - Pasos: Evento > 24h
  - Esperado: Sugerencia de usar Alojamiento
  - Estado: ✅

### 11.3 Validaciones de Alojamientos

- [ ] **VAL-ACC-001:** Validación check-out > check-in
  - Pasos: Fechas inválidas
  - Esperado: Error de validación
  - Estado: ✅

- [ ] **VAL-ACC-002:** Validación de solapamientos
  - Pasos: Alojamiento que solapa otro
  - Esperado: Advertencia o validación
  - Estado: 🔄

---

## 12. CALENDARIO Y VISUALIZACIÓN

### 12.1 Visualización del Calendario

- [ ] **CAL-001:** Calendario carga correctamente
  - Pasos: Abrir plan con eventos
  - Esperado: Calendario renderizado con eventos
  - Estado: 🔄

- [ ] **CAL-002:** Navegación entre días
  - Pasos: Cambiar número de días visibles (1-7)
  - Esperado: Vista ajustada correctamente
  - Estado: 🔄

- [ ] **CAL-003:** Scroll horizontal en calendario
  - Pasos: Desplazar calendario horizontalmente
  - Esperado: Scroll fluido
  - Estado: 🔄

- [ ] **CAL-004:** Eventos visibles en fechas correctas
  - Pasos: Ver calendario con múltiples eventos
  - Esperado: Eventos en días/horas correctos
  - Estado: 🔄

- [ ] **CAL-005:** Indicadores visuales de participantes (T50)
  - Pasos: Ver eventos multi-participante
  - Esperado: Badges/iconos visibles
  - Estado: ✅

- [ ] **CAL-006:** Resaltado de track activo (T90)
  - Pasos: Seleccionar participante
  - Esperado: Track resaltado visualmente
  - Estado: ✅

- [ ] **CAL-007:** Indicadores de eventos multi-track (T89)
  - Pasos: Eventos que cruzan múltiples tracks
  - Esperado: Gradiente y iconos visibles
  - Estado: ✅

- [ ] **CAL-008:** Colores de eventos optimizados (T91)
  - Pasos: Ver eventos con diferentes tipos
  - Esperado: Colores WCAG AA, contraste adecuado
  - Estado: ✅

- [ ] **CAL-009:** Días restantes del plan (T112)
  - Pasos: Ver plan en estado "confirmado"
  - Esperado: Contador de días restantes visible
  - Estado: ✅

### 12.2 Interacciones en Calendario

- [ ] **CAL-INT-001:** Drag & drop de eventos
  - Pasos: Arrastrar evento a nueva fecha/hora
  - Esperado: Evento movido, cambios guardados
  - Estado: 🔄

- [ ] **CAL-INT-002:** Click en evento abre detalles
  - Pasos: Click en evento del calendario
  - Esperado: Modal/diálogo con información
  - Estado: 🔄

- [ ] **CAL-INT-003:** Click en celda vacía crea evento
  - Pasos: Click en hora/día sin evento
  - Esperado: Dialog de creación de evento
  - Estado: 🔄

- [ ] **CAL-INT-004:** Redimensionar evento (futuro)
  - Estado: 🔄 Pendiente implementación

---

## 13. TIMEZONES

### 13.1 Timezones en Planes (T40)

- [ ] **TZ-001:** Crear plan con timezone específico
  - Pasos: Seleccionar timezone al crear plan
  - Esperado: Plan usa timezone seleccionado
  - Estado: 🔄

- [ ] **TZ-002:** Ver eventos con timezone correcta
  - Pasos: Plan con timezone diferente
  - Esperado: Horas mostradas en timezone del plan
  - Estado: 🔄

### 13.2 Timezones en Eventos

- [ ] **TZ-EVENT-001:** Evento con timezone de salida
  - Pasos: Crear evento con timezone específica
  - Esperado: Hora correcta según timezone
  - Estado: 🔄

- [ ] **TZ-EVENT-002:** Evento con timezone de llegada (T40)
  - Pasos: Vuelo con timezones diferentes
  - Esperado: Conversión correcta de horarios
  - Estado: 🔄

- [ ] **TZ-EVENT-003:** Conversión automática entre timezones
  - Pasos: Evento con timezone diferente al plan
  - Esperado: Conversión y visualización correcta
  - Estado: 🔄

---

## 14. SEGURIDAD Y PERMISOS

### 14.1 Permisos de Plan

- [ ] **SEC-PERM-001:** Solo organizador puede eliminar plan
  - Pasos: Intentar eliminar como participante
  - Esperado: No permitido
  - Estado: 🔄

- [ ] **SEC-PERM-002:** Solo organizador puede cambiar estado
  - Pasos: Intentar cambiar estado como participante
  - Esperado: No permitido
  - Estado: 🔄

- [ ] **SEC-PERM-003:** Participantes pueden crear eventos
  - Pasos: Crear evento como participante
  - Esperado: Permitido
  - Estado: 🔄

- [ ] **SEC-PERM-004:** Solo creador puede editar evento propio
  - Pasos: Intentar editar evento de otro
  - Esperado: No permitido o solo organizador
  - Estado: 🔄

### 14.2 Validaciones de Seguridad

- [ ] **SEC-VAL-001:** Sanitización de inputs (T127)
  - Pasos: Input con caracteres especiales/scripts
  - Esperado: Sanitizado correctamente
  - Estado: ✅

- [ ] **SEC-VAL-002:** Rate limiting (T126)
  - Pasos: Crear múltiples eventos rápidamente
  - Esperado: Límite aplicado, mensaje de espera
  - Estado: ✅

- [ ] **SEC-VAL-003:** Validación de longitud de campos
  - Pasos: Campos muy largos
  - Esperado: Validación de máximo permitido
  - Estado: ✅

### 14.3 Acceso a Datos

- [ ] **SEC-ACC-001:** No ver planes de otros usuarios
  - Pasos: Intentar acceder a plan de otro
  - Esperado: Acceso denegado
  - Estado: 🔄

- [ ] **SEC-ACC-002:** Solo participantes ven eventos privados
  - Pasos: Evento solo para participantes específicos
  - Esperado: No visible para otros
  - Estado: 🔄

---

## 15. SINCRONIZACIÓN Y OFFLINE

### 15.1 Modo Offline

- [ ] **OFF-001:** App funciona sin conexión
  - Pasos: Desactivar conexión, usar app
  - Esperado: Funcionalidad básica disponible
  - Estado: 🔄

- [ ] **OFF-002:** Crear evento offline
  - Pasos: Crear evento sin conexión
  - Esperado: Guardado localmente, sincronizado después
  - Estado: 🔄

- [ ] **OFF-003:** Sincronización al recuperar conexión
  - Pasos: Cambios offline, reconectar
  - Esperado: Sincronización automática
  - Estado: 🔄

- [ ] **OFF-004:** Resolución de conflictos
  - Pasos: Cambios offline que entran en conflicto
  - Esperado: Resolución o notificación de conflicto
  - Estado: 🔄

---

## 16. CASOS EDGE Y ERRORES

### 16.1 Casos Límite

- [ ] **EDGE-001:** Plan con 0 eventos
  - Pasos: Plan sin eventos
  - Esperado: Calendario vacío, sin errores
  - Estado: 🔄

- [ ] **EDGE-002:** Plan con 1 día
  - Pasos: Plan de duración mínima
  - Esperado: Funciona correctamente
  - Estado: 🔄

- [ ] **EDGE-003:** Plan con 365 días
  - Pasos: Plan de máxima duración
  - Esperado: Rendimiento aceptable
  - Estado: 🔄

- [ ] **EDGE-004:** Evento de 1 minuto
  - Pasos: Duración mínima
  - Esperado: Renderizado correcto
  - Estado: 🔄

- [ ] **EDGE-005:** Evento de 24 horas exactas
  - Pasos: Duración máxima permitida
  - Esperado: Renderizado correcto
  - Estado: 🔄

- [ ] **EDGE-006:** Plan con 100+ participantes
  - Pasos: Plan masivo
  - Esperado: Rendimiento aceptable
  - Estado: 🔄

- [ ] **EDGE-007:** Plan con 1000+ eventos
  - Pasos: Plan muy complejo
  - Esperado: Rendimiento aceptable o paginación
  - Estado: 🔄

- [ ] **EDGE-008:** Evento con nombre muy largo
  - Pasos: Nombre de 500+ caracteres
  - Esperado: Truncado o scroll en UI
  - Estado: 🔄

- [ ] **EDGE-009:** Múltiples eventos en misma hora
  - Pasos: 5+ eventos solapados
  - Esperado: Renderizado correcto, scroll horizontal
  - Estado: 🔄

- [ ] **EDGE-010:** Eventos que cruzan medianoche
  - Pasos: Evento 23:00 - 02:00
  - Esperado: Renderizado correcto en múltiples días
  - Estado: 🔄

### 16.2 Manejo de Errores

- [ ] **ERR-001:** Error de conexión a Firestore
  - Pasos: Simular error de red
  - Esperado: Mensaje claro, modo offline activado
  - Estado: 🔄

- [ ] **ERR-002:** Error al guardar evento
  - Pasos: Simular fallo en guardado
  - Esperado: Mensaje de error, datos no perdidos
  - Estado: 🔄

- [ ] **ERR-003:** Timeout en operaciones largas
  - Pasos: Operación que tarda mucho
  - Esperado: Timeout manejado, mensaje al usuario
  - Estado: 🔄

- [ ] **ERR-004:** Error de permisos de Firestore
  - Pasos: Intentar operación sin permisos
  - Esperado: Mensaje claro de permisos insuficientes
  - Estado: 🔄

- [ ] **ERR-005:** Datos corruptos en Firestore
  - Pasos: Documento con estructura inválida
  - Esperado: Manejo graceful, no crashea app
  - Estado: 🔄

### 16.3 Casos Raros

- [ ] **RARE-001:** Cambiar timezone de plan con eventos existentes
  - Pasos: Modificar timezone después de crear eventos
  - Esperado: Eventos ajustados o advertencia
  - Estado: 🔄

- [ ] **RARE-002:** Eliminar participante con eventos asignados
  - Pasos: Remover participante que tiene eventos
  - Esperado: Eventos ajustados o reasignados
  - Estado: 🔄

- [ ] **RARE-003:** Invitación con email de usuario ya participante
  - Pasos: Invitar email que ya está en plan
  - Esperado: Validación o actualización
  - Estado: 🔄

- [ ] **RARE-004:** Evento con participantes que ya no están en plan
  - Pasos: Participante eliminado pero evento sigue referenciándolo
  - Esperado: Limpieza automática o manejo graceful
  - Estado: 🔄

- [ ] **RARE-005:** Plan con eventos en fechas fuera de rango
  - Pasos: Eventos creados antes de expansión (T107)
  - Esperado: Manejado correctamente
  - Estado: ✅

---

## 17. RENDIMIENTO

### 17.1 Carga Inicial

- [ ] **PERF-001:** Tiempo de carga de dashboard
  - Pasos: Medir tiempo de carga inicial
  - Esperado: < 2 segundos en conexión buena
  - Estado: 🔄

- [ ] **PERF-002:** Tiempo de carga de calendario
  - Pasos: Medir carga de calendario con muchos eventos
  - Esperado: < 3 segundos
  - Estado: 🔄

- [ ] **PERF-003:** Memoria usada con plan grande
  - Pasos: Plan con 500+ eventos
  - Esperado: Memoria razonable (< 200MB)
  - Estado: 🔄

### 17.2 Operaciones

- [ ] **PERF-004:** Tiempo de guardado de evento
  - Pasos: Medir tiempo de creación
  - Esperado: < 1 segundo
  - Estado: 🔄

- [ ] **PERF-005:** Scroll fluido en calendario
  - Pasos: Scroll rápido con muchos eventos
  - Esperado: 60 FPS, sin lag
  - Estado: 🔄

- [ ] **PERF-006:** Cálculo de estadísticas
  - Pasos: Plan grande, calcular stats
  - Esperado: < 2 segundos
  - Estado: 🔄

---

## 18. UX Y ACCESIBILIDAD

### 18.1 Navegación

- [ ] **UX-NAV-001:** Navegación intuitiva
  - Pasos: Usuario nuevo navega por app
  - Esperado: Puede encontrar funcionalidades fácilmente
  - Estado: 🔄

- [ ] **UX-NAV-002:** Breadcrumbs o indicadores de ubicación
  - Pasos: Navegar a páginas profundas
  - Esperado: Usuario sabe dónde está
  - Estado: 🔄

### 18.2 Feedback Visual

- [ ] **UX-FB-001:** Loading states visibles
  - Pasos: Operaciones que tardan
  - Esperado: Indicadores de carga claros
  - Estado: 🔄

- [ ] **UX-FB-002:** Mensajes de éxito
  - Pasos: Guardar evento exitosamente
  - Esperado: Confirmación visual clara
  - Estado: 🔄

- [ ] **UX-FB-003:** Mensajes de error claros
  - Pasos: Errores de validación
  - Esperado: Mensajes específicos y útiles
  - Estado: 🔄

### 18.3 Accesibilidad

- [ ] **A11Y-001:** Contraste de colores WCAG AA
  - Pasos: Verificar contraste en todos los elementos
  - Esperado: Mínimo 4.5:1
  - Estado: ✅

- [ ] **A11Y-002:** Textos legibles
  - Pasos: Verificar tamaños de fuente
  - Esperado: Mínimo 14px
  - Estado: 🔄

- [ ] **A11Y-003:** Navegación por teclado
  - Pasos: Navegar sin mouse
  - Esperado: Todas las funciones accesibles
  - Estado: 🔄

---

## 📊 RESUMEN DE ESTADO

**Total de pruebas:** ~250+  
**Implementadas y probadas:** ~30  
**Pendientes:** ~220  

**Por sección:**
- Autenticación: 🔄 Pendiente
- CRUD Planes: 🔄 Pendiente
- CRUD Eventos: 🔄 Parcial (T47, T117, T120, T101 ✅)
- CRUD Alojamientos: 🔄 Parcial (T101 ✅)
- Participantes: 🔄 Parcial (T123 ✅)
- Invitaciones: ✅ Base completada
- Estados: ✅ Base completada
- Presupuesto: ✅ Base completada (T101)
- Estadísticas: ✅ Base completada (T113)
- Validaciones: ✅ Base completada (VALID-1, VALID-2)
- Calendario: ✅ Visualizaciones completadas (T50, T89, T90, T91, T112)
- Seguridad: ✅ Base completada (T126, T127)

---

**Última actualización:** Enero 2025  
**Próxima revisión:** Tras completar T102

