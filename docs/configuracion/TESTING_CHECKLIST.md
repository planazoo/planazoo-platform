# 🧪 Checklist Exhaustivo de Pruebas - Planazoo

> Documento vivo que debe actualizarse cada vez que se completa una tarea o se añade nueva funcionalidad.

**Versión:** 1.6  
**Última actualización:** Abril 2026  
**Mantenedor:** Equipo de desarrollo

---

## 🚀 ANTES DE EMPEZAR ESTA SERIE DE PRUEBAS

1. **Normas y entorno:** Lee `docs/configuracion/CONTEXT.md` (idioma, estilo, no push sin confirmación).
2. **Usuarios:** Ten a mano `docs/configuracion/USUARIOS_PRUEBA.md` (emails con alias, roles, contraseñas). Opción: botón "⚙️ Init Firestore" en dashboard para crear usuarios de prueba.
3. **Ámbito:** Usa la tabla de contenidos de abajo y marca cada bloque (✅/❌/⚠️) según vayas probando.
4. **Comportamiento esperado:** Los flujos en `docs/flujos/` (CRUD planes, eventos, participantes, etc.) describen el comportamiento esperado; úsalos como referencia si un caso falla o es ambiguo.
5. **Pruebas lógicas (JSON):** Para casos automatizados por datos (login, contraseñas, eventos, etc.) y reportes para IA, ver [docs/testing/SISTEMA_PRUEBAS_LOGICAS.md](../testing/SISTEMA_PRUEBAS_LOGICAS.md).
6. **Pruebas E2E tres usuarios (flujo completo):** Para simular un ciclo real con UA/UB/UC (crear plan → invitaciones → eventos → chat → aprobar → durante plan → cerrar), ver [docs/testing/PLAN_PRUEBAS_E2E_TRES_USUARIOS.md](../testing/PLAN_PRUEBAS_E2E_TRES_USUARIOS.md). Incluye tabla de huecos/situaciones no contempladas para derivar tareas.
7. **QA nocturno (futuro):** Para el diseño del sistema de E2E automatizado nocturno (Playwright, multiusuario, RPi/Mac, alertas), ver [docs/testing/SISTEMA_QA_NOCTURNO_DISTRIBUIDO.md](../testing/SISTEMA_QA_NOCTURNO_DISTRIBUIDO.md).
8. **Offline-first (solo iOS/Android):** Inventario de boxes Hive, cold start sin red y perfil `current_user` en [docs/testing/TESTING_OFFLINE_FIRST.md](../testing/TESTING_OFFLINE_FIRST.md); flujo de usuario en [docs/flujos/FLUJO_CRUD_USUARIOS.md](../flujos/FLUJO_CRUD_USUARIOS.md) (sección *Snapshot de perfil en Hive*).

---

## 📋 INSTRUCCIONES DE MANTENIMIENTO

> ⚠️ **Recordatorio:** Antes de marcar cualquier caso como completado, verifica que la documentación afectada (UX, flujos, tareas) esté actualizada y coherente con los cambios realizados.

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
   - ✅ **Pruebas lógicas:** Si la tarea incluye lógica probable por datos (validaciones, auth, reglas), actualizar el [sistema de pruebas lógicas](../testing/SISTEMA_PRUEBAS_LOGICAS.md): casos JSON, evaluador y test Dart.

2. **Cuando se añade nueva funcionalidad:**
   - ✅ Crear nueva sección de pruebas
   - ✅ Documentar casos normales y edge cases
   - ✅ Actualizar tabla de contenidos
   - ✅ **Pruebas lógicas:** Valorar si añadir/actualizar casos en `tests/*_cases.json` y evaluadores en `lib/testing/*_logic.dart` (ver [SISTEMA_PRUEBAS_LOGICAS.md](../testing/SISTEMA_PRUEBAS_LOGICAS.md)).

3. **Cuando se corrige un bug:**
   - ✅ Añadir el bug como caso de prueba
   - ✅ Verificar que no se reproduce
   - ✅ Documentar solución si es relevante
   - ✅ Si el bug es de lógica (validación, mensajes de error, reglas): añadir caso en el JSON correspondiente y en el evaluador de [pruebas lógicas](../testing/SISTEMA_PRUEBAS_LOGICAS.md) para que no regrese.

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
   - 3.6 [Resumen del plan (T193)](#36-resumen-del-plan-t193)
4. [CRUD de Eventos](#4-crud-de-eventos)
5. [CRUD de Alojamientos](#5-crud-de-alojamientos)
   - 5.5 [Búsqueda de lugar en alojamientos (T225)](#55-búsqueda-de-lugar-en-alojamientos-google-places---t225)
6. [Gestión de Participantes](#6-gestión-de-participantes)
7. [Invitaciones y Notificaciones](#7-invitaciones-y-notificaciones)
   - 7.4 [Sistema de notificaciones (lista global y W20)](#74-sistema-de-notificaciones-lista-global-y-w20)
   - 7.5 [Avisos del plan (Info del plan)](#75-avisos-del-plan-info-del-plan)
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
   - 15.2 [Perfil local Hive (current_user)](#152-perfil-local-hive-current_user-solo-móvil)
16. [Casos Edge y Errores](#16-casos-edge-y-errores)
17. [Rendimiento](#17-rendimiento)
18. [UX y Accesibilidad](#18-ux-y-accesibilidad)

---

## 1. AUTENTICACIÓN Y REGISTRO

### 1.1 Registro de Usuario

**⚠️ IMPORTANTE (T163):** A partir de T163, el campo `username` es **OBLIGATORIO** en el registro. Todos los nuevos usuarios deben tener un username único.

- [x] **REG-001:** Registrar nuevo usuario con email válido y username válido
  - Pasos: 
    1. En la pantalla de login, pulsar "Registrarse" (o enlace equivalente)
    2. Completar campo de nombre
    3. Completar campo de email (ej: `unplanazoo+temp1@gmail.com`)
    4. Completar campo de **username** (ej: `usuario_prueba1`)
    5. Contraseña segura (mínimo 8 caracteres con mayúsculas, minúsculas, números y caracteres especiales)
    6. Confirmar contraseña
    7. Aceptar términos y condiciones y enviar
  - Esperado: 
    - Usuario creado exitosamente
    - Username guardado en Firestore con `usernameLower`
    - Redirección a login
    - Email de verificación enviado
  - **⚠️ IMPORTANTE:** El usuario NO debe existir previamente en Firebase Auth ni Firestore. Usar `unplanazoo+temp1@gmail.com` o eliminar usuario antes de probar.
  - Estado: ✅

- [x] **REG-002:** Registrar usuario con email ya existente
  - Pasos: Intentar registrar email ya registrado (con username válido)
  - Esperado: Error claro "Email ya registrado" (traducido)
  - Estado: ✅

- [x] **REG-003:** Registrar con username ya existente
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Completar todos los demás campos correctamente
  - Esperado: 
    - Error "Este nombre de usuario ya está en uso"
    - Se muestran sugerencias de username alternativos (chips clicables)
    - Al hacer clic en una sugerencia, se rellena el campo automáticamente
  - Estado: ✅

- [x] **REG-004:** Registrar con username inválido (formato incorrecto)
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
       - Menos de 3 caracteres (ej: `ab`)
       - Más de 30 caracteres (ej: `usuario_muy_largo_que_excede_el_limite`)
       - Caracteres especiales no permitidos (ej: `usuario@123`, `usuario-123`, `usuario.123`)
       - Mayúsculas (ej: `Usuario123`)
  - Esperado: 
    - Error de validación claro explicando el formato requerido
    - Mensaje: "El nombre de usuario debe tener 3-30 caracteres y solo puede contener letras minúsculas, números y guiones bajos (a-z, 0-9, _)"
  - Estado: ✅

- [ ] **REG-005:** Registrar con contraseña débil (validación mejorada)
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
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

- [x] **REG-006:** Registrar con email inválido
  - Pasos: Email sin @ o formato incorrecto
  - Esperado: Error de validación de email
  - Estado: ✅

- [x] **REG-007:** Registro con campos vacíos
  - Pasos: Dejar campos requeridos vacíos (nombre, email, username, contraseña)
  - Esperado: Validaciones que marquen campos obligatorios
  - Estado: ✅

- [x] **REG-008:** Validación de sugerencias de username
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Verificar que aparecen sugerencias (ej: `admin1`, `admin2`, `admin_2025`)
    3. Hacer clic en una sugerencia
  - Esperado: 
    - El campo de username se rellena automáticamente con la sugerencia seleccionada
    - El error desaparece
    - Se puede proceder con el registro
  - Estado: ✅

- [x] **REG-009:** Username con @ al inicio (opcional)
  - Pasos: Intentar registrar con `@usuario` (con @ al inicio)
  - Esperado: 
    - El sistema debe aceptar el username con o sin @
    - Se guarda sin el @ en Firestore
  - Estado: ✅

- [ ] **REG-010:** Validación de contraseña en tiempo real
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
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
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
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
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Escribir confirmación diferente (ej: `Password456!`)
    3. Salir del campo de confirmar contraseña
    4. Escribir la misma contraseña
    5. Salir del campo
  - Esperado: 
    - Error "Las contraseñas no coinciden" al salir si no coinciden
    - El error desaparece cuando coinciden
    - El botón "Crear Cuenta" se habilita solo cuando las contraseñas coinciden
  - Estado: ✅

- [x] **REG-013:** Botón "Crear Cuenta" deshabilitado hasta que todo sea válido
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
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

- [x] **LOGIN-001:** Iniciar sesión con email válido
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Ingresar contraseña correcta
  - Esperado: 
    - Login exitoso
    - Sesión activa
    - Redirección a dashboard
  - Estado: ✅

- [x] **LOGIN-002:** Iniciar sesión con username (con @)
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Ingresar contraseña correcta
  - Esperado: 
    - Login exitoso
    - El sistema detecta que es username y busca el email asociado
    - Sesión activa
  - Estado: ✅

- [x] **LOGIN-003:** Iniciar sesión con username (sin @)
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Ingresar contraseña correcta
  - Esperado: 
    - Login exitoso
    - El sistema detecta que es username (no contiene @) y busca el email asociado
    - Sesión activa
  - Estado: ✅

- [x] **LOGIN-004:** Iniciar sesión con email incorrecto
  - Pasos: Email no registrado (usar email que NO exista)
  - Esperado: Error "No se encontró una cuenta con este email"
  - **⚠️ IMPORTANTE:** El usuario NO debe existir. Usar email que no esté registrado.
  - Estado: ✅

- [x] **LOGIN-005:** Iniciar sesión con username incorrecto/no existente
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Ingresar cualquier contraseña
  - Esperado: Error "No se encontró un usuario con ese nombre de usuario"
  - Estado: ✅

- [ ] **LOGIN-006:** Iniciar sesión con contraseña incorrecta (usando email)
  - Pasos: Email correcto, contraseña incorrecta
  - Esperado: Error "Contraseña incorrecta"
  - Estado: ✅

- [ ] **LOGIN-007:** Iniciar sesión con contraseña incorrecta (usando username)
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Contraseña incorrecta
  - Esperado: Error "Contraseña incorrecta"
  - Estado: ✅

- [ ] **LOGIN-008:** Validación de campo email/username en login
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Intentar login con formato inválido (ni email ni username válido)
  - Esperado: 
    - Error de validación: "Ingresa un email válido o un nombre de usuario"
    - El campo muestra el error claramente
  - Estado: ✅

- [ ] **LOGIN-009:** Icono dinámico en campo de login
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Borrar y escribir un username (ej: `@usuario`)
  - Esperado: 
    - El icono cambia dinámicamente: email icon cuando es email, @ icon cuando es username
  - Estado: ✅

- [x] **LOGIN-015:** Recuperar contraseña
  - Pasos: Click "Olvidé mi contraseña", ingresar email
  - Esperado: Email de recuperación enviado
  - Estado: ✅

- [x] **LOGIN-016:** Cerrar sesión
  - Pasos: Click en logout
  - Esperado: Sesión cerrada, redirección a login
  - Estado: ✅

- [ ] **LOGIN-010:** Iniciar sesión con Google (nuevo usuario)
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Seleccionar una cuenta de Google que NO esté registrada en la app
    3. Aceptar permisos
  - Esperado: 
    - Login exitoso
    - Se crea automáticamente un usuario en Firestore
    - Se genera automáticamente un username
    - Se guardan los datos de Google (email, nombre, foto)
    - Redirección a dashboard
  - Estado: ✅

- [ ] **LOGIN-011:** Iniciar sesión con Google (usuario existente)
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Seleccionar una cuenta de Google que YA esté registrada en la app
    3. Aceptar permisos
  - Esperado: 
    - Login exitoso
    - Se actualiza `lastLoginAt`
    - Si no tiene username, se genera automáticamente
    - Redirección a dashboard
  - Estado: ✅

- [x] **LOGIN-012:** Cancelar login con Google
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Cancelar la selección de cuenta
  - Esperado: 
    - No se muestra error
    - El usuario permanece en la pantalla de login
    - No se crea ningún usuario
  - Estado: ✅

- [x] **LOGIN-013:** Verificar datos de Google en Firestore
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Verificar en Firestore que el usuario tiene:
       - `email` (del Google)
       - `displayName` (del Google)
       - `photoURL` (del Google)
       - `username` (generado automáticamente)
       - `usernameLower` (en minúsculas)
  - Esperado: 
    - Todos los campos están presentes y correctos
    - El username es único y válido
  - Estado: ✅

- [x] **LOGIN-014:** Ciclo completo logout/login sin errores de permisos (T159)
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Navegar a un plan y verificar que eventos/alojamientos se cargan correctamente
    3. Hacer logout
    4. Hacer login nuevamente con el mismo usuario
    5. Navegar al mismo plan y verificar que eventos/alojamientos se cargan correctamente
  - Esperado: 
    - No aparecen errores de permisos (`permission-denied`) después del segundo login
    - Las consultas a `event_participants` y otras colecciones funcionan correctamente
    - El comportamiento es idéntico al primer login
  - **⚠️ IMPORTANTE:** Esta prueba verifica que el token de autenticación se sincroniza correctamente después de logout/login. Relacionado con T159.
  - Estado: ✅

🔎 **Resumen de autenticación (T163/T164/T159):** Todos los casos `LOGIN-001` a `LOGIN-016` verificados. Se confirmaron validaciones reforzadas de email/contraseña, manejo correcto de errores duplicados, flujo de Google cancelado sin bloqueos y recarga íntegra de datos tras logout/login.

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

- [x] **PROF-001:** Ver perfil propio (pantalla completa)
  - Pasos:
    1. Abrir perfil desde el icono lateral del dashboard
    2. Confirmar que la vista cubre el grid principal dejando visible solo la barra lateral W1
    3. Intentar interactuar con listado de planes/menús laterales mientras el perfil está abierto (no deben responder)
    4. Verificar cabecera: flecha hacia la izquierda en la parte izquierda, `@username` alineado a la derecha, bloque superior con nombre completo, email y fecha de alta
  - Esperado:
    - El perfil bloquea la interacción con el resto del dashboard
    - Se muestra toda la información de cabecera y tarjetas (`Datos personales`, `Seguridad y acceso`, `Acciones avanzadas`)
  - Estado: 🔄

- [x] **PROF-002:** Editar información personal (modal)
  - Pasos:
    1. Perfil → tarjeta "Datos personales" → "Editar información personal"
    2. Verificar que se abre modal centrado (480px máx) con overlay y sin navegación detrás
    3. Editar nombre completo, pulsar "Guardar" y confirmar snackbar verde + datos actualizados en cabecera
    4. Repetir apertura y cancelar con el botón "Cancelar" y con el icono `X` (no debe persistir cambios)
  - Esperado:
    - El modal bloquea interacción externa mientras está abierto
    - Guardar actualiza `displayName` y foto (cuando corresponda)
    - Cancelar cierra sin cambios
  - Estado: 🔄

- [x] **PROF-003:** Cambiar email
  - Pasos:
    1. Abrir perfil → tarjeta "Datos personales" → "Editar información personal"
    2. Verificar que el campo email aparece bloqueado y muestra la nota de soporte
  - Esperado:
    - El email es de solo lectura; no permite edición ni guardado
    - Se mantiene el mensaje de "El email no se puede cambiar. Contacta con soporte si necesitas cambiarlo."
  - Estado: 🔄

- [x] **PROF-004:** Cambiar contraseña (modal UX actualizado)
  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Intentar guardar con nueva contraseña que no cumple requisitos (cada regla)
    3. Completar confirmación con contraseña diferente
    4. Introducir contraseña válida que cumpla todos los requisitos y coincida en ambos campos
  - Esperado: 
    - Validación de contraseña actual requerida
    - Errores específicos según requisito faltante (mayúscula, minúscula, longitud, número, carácter especial)
    - Mensaje si la confirmación no coincide
    - Cambio exitoso solo con contraseña válida; snackbar verde de confirmación
  - Estado: 🔄

  - Pasos:
    1. Perfil → "Editar información personal" → pulsar icono de cámara
    2. Probar opciones "Tomar foto" y "Elegir de galería" (muestran snackbar informando que estará disponible)
    3. Usar "Usar URL" con imagen válida; guardar y verificar actualización en cabecera
    4. Repetir flujo eliminando foto desde la opción correspondiente
  - Esperado:
    - Se muestran avisos amigables para cámara/galería (pendiente)
    - Subir mediante URL actualiza avatar en cabecera y Firestore
    - Eliminar foto revierte al icono por defecto
  - Estado: 🔄

  - Pasos: 
    1. Abrir perfil → tarjeta "Seguridad y acceso" → "Cambiar contraseña"
    2. Perfil → tarjeta "Acciones avanzadas" → "Eliminar cuenta"
    3. Introducir contraseña y confirmar
  - Esperado:
    - Se cierra sesión y se vuelve a la pantalla de login
    - Documento `/users/{uid}` eliminado (o marcado `isActive=false` según implementación)
    - No es posible volver a iniciar sesión con ese email/username sin registrar de nuevo
  - Estado: 🔄

- [x] **PROF-007:** Acciones de "Seguridad y acceso"
  - Pasos:
    1. Abrir perfil → tarjeta "Seguridad y acceso"
    2. Abrir y cerrar modal de "Privacidad y seguridad" (solo lectura)
    3. Abrir "Idioma", cambiar a EN, confirmar traducciones en perfil y revertir a ES
    4. Pulsar "Cerrar sesión" y validar que retorna a login; repetir login para continuar pruebas
  - Esperado:
    - Cada opción abre modal/dialog dedicado y bloquea el fondo
    - Cambio de idioma persiste tras cerrar el perfil
    - Logout funciona sin dejar overlays residuales
  - Estado: 🔄

- [x] **PROF-008:** Cerrar pantalla de perfil
  - Pasos:
    1. Abrir perfil (pantalla completa)
    2. Pulsar la flecha hacia la izquierda de la barra superior
    3. Verificar que se regresa al último panel abierto (calendar/plan/etc.) sin elementos superpuestos
  - Esperado:
    - El cierre limpia el overlay y restituye interacción con el dashboard
    - No se pierden selecciones previas (plan activo, filtros)
  - Estado: 🔄

### 2.2 Configuración de Usuario

- [ ] **CONF-001:** Configurar preferencias de notificaciones *(pendiente de implementación en UI)*
  - Pasos: Ajustar preferencias en configuración
  - Esperado: Preferencias guardadas y aplicadas
  - Estado: 🔄

- [x] **CONF-002:** Seleccionar idioma de la app
  - Pasos: Cambiar idioma (ES/EN)
  - Esperado: UI actualizada al idioma seleccionado
  - Estado: 🔄

- [ ] **CONF-003:** Configurar timezone por defecto *(⚠️ pendiente: falta UI para preferencia personal; ver tareas T177/T178)*
  - Pasos: Establecer timezone preferido
  - Esperado: Nuevos eventos usan timezone por defecto
  - Estado: 🔄

---

## 3. CRUD DE PLANES

### 3.1 Crear Plan

- [x] **PLAN-C-001:** Crear plan básico
  - Pasos: Nombre, fechas, descripción, crear
  - Esperado: Plan creado en estado "planificando"
  - Estado: 🔄

- [x] **PLAN-C-002:** Crear plan sin nombre
  - Pasos: Intentar crear sin nombre obligatorio
  - Esperado: Validación que requiera nombre
  - Estado: ✅

- [x] **PLAN-C-003:** Crear plan con fechas inválidas
  - Pasos: Intentar definir fecha fin anterior a inicio
  - Esperado: Datepickers bloquean la selección (no permite fin < inicio)
  - Estado: ✅

- [ ] **PLAN-C-004:** Crear plan con imagen
  - Pasos: Añadir imagen al crear plan
  - Esperado: Imagen subida y visible en plan
  - Estado: 🔄

- [x] **PLAN-C-005:** Crear plan con participantes iniciales
  - Pasos:
    1. Crear plan desde dashboard (modal inicial solo nombre).
    2. En la página del plan, abrir "Participantes" → "Añadir participantes" y seleccionar usuarios adicionales.
    3. Guardar cambios.
    4. Volver al dashboard y comprobar que W28 muestra el contador actualizado.
  - Esperado: El organizador se registra automáticamente como participante; los usuarios añadidos aparecen en el recuadro del plan y el contador de la lista refleja el total en tiempo real.
  - Estado: ✅

- [x] **PLAN-C-006:** Crear plan con presupuesto inicial
  - Pasos: Establecer presupuesto estimado
  - Esperado: Presupuesto guardado y visible
  - Estado: ✅

- [x] **PLAN-C-007:** Crear plan con timezone específico
  - Pasos:
    1. Crear un plan desde el dashboard.
    2. En la página del plan, cambiar la zona horaria en "Información detallada".
    3. Guardar y volver a abrir el plan para comprobar que la zona se conserva.
  - Esperado: La zona horaria elegida se persiste en el plan y se aplica por defecto al crear eventos.
  - Estado: ✅

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

- [x] **PLAN-R-006:** Alternar vista listado ↔ calendario (W27)
  - Pasos:
    1. En el dashboard, usar el toggle de W27 para pasar de lista a calendario y viceversa.
    2. Confirmar que el mes actual aparece centrado al abrir la vista calendario.
    3. Volver a la vista lista y verificar que la selección del plan se mantiene.
  - Esperado: El cambio de vista no pierde la selección del plan ni produce errores visuales.
  - Estado: ✅

- [x] **PLAN-R-007:** Comprobación de calendario W28 (tooltips y selección)
  - Pasos:
    1. Con planes distribuidos en distintos días, pasar a la vista calendario.
    2. Hover sobre un día con planes y comprobar que el tooltip muestra los nombres.
    3. Hacer clic en un día con varios planes y verificar que el modal lista todas las opciones y permite abrir cada plan.
  - Esperado: Tooltip visible sin cortar texto; modal muestra la lista completa y navega al plan al seleccionarlo.
  - Estado: ✅

### 3.3 Actualizar Plan

- [x] **PLAN-U-001:** Modificar nombre del plan
  - Pasos: Editar nombre en plan existente
  - Esperado: Cambio guardado correctamente
  - Estado: ✅

- [x] **PLAN-U-002:** Modificar fechas del plan
  - Pasos: Cambiar fechas de inicio/fin
  - Esperado: Fechas actualizadas, calendario ajustado
  - Estado: ✅

- [ ] **PLAN-U-003:** Expandir rango del plan (T107)
  - Pasos: Crear evento fuera del rango actual
  - Esperado: Diálogo de confirmación, expansión automática
  - Estado: ✅

- [ ] **PLAN-U-004:** Cambiar imagen del plan
  - Pasos: Reemplazar imagen existente
  - Esperado: Nueva imagen visible en plan
  - Estado: ⏳ (bloqueado: falta almacenamiento configurado)

- [x] **PLAN-U-005:** Actualizar descripción
  - Pasos: Modificar descripción del plan
  - Esperado: Descripción actualizada
  - Estado: ✅

- [x] **PLAN-U-006:** Cambiar timezone del plan
  - Pasos: Modificar timezone en plan existente
  - Esperado: Eventos ajustados al nuevo timezone
  - Estado: ✅

- [x] **PLAN-U-007:** Actualizar presupuesto del plan
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

- [ ] **PLAN-D-005:** Verificar eliminación en cascada completa
  - Pasos: 
    1. Crear plan con eventos, participantes, permisos y event_participants
    2. Eliminar el plan como organizador
    3. Verificar en Firestore que se eliminaron físicamente:
       - `plan_invitations` del plan (cualquier estado)
       - `event_participants` (eliminación física)
       - `plan_permissions` (eliminación física)
       - `plan_participations` (eliminación física)
       - `events` (eliminación física, desde `event_service`)
       - `plan` (eliminación física)
  - Esperado: No quedan documentos huérfanos relacionados con el plan eliminado. Todas las colecciones relacionadas deben estar completamente vacías para ese plan.
  - Estado: 🔄

- [ ] **PLAN-D-006 (Reglas):** Borrado de participaciones huérfanas permitido
  - Pasos:
    1. Simular `plan_participations` con `planId` inexistente (eliminar plan previamente)
    2. Intentar eliminar la participación como el propio `userId`
  - Esperado: Permitido por reglas (`!planExists && resource.data.userId == request.auth.uid`)
  - Estado: 🔄

- [ ] **PLAN-D-007 (Reglas):** Borrado de participaciones por owner del plan
  - Pasos:
    1. Con plan existente, intentar eliminar `plan_participations` de cualquier `userId` siendo owner
  - Esperado: Permitido por reglas (`isPlanOwner(resource.data.planId)`)
  - Estado: 🔄

**⚠️ RECORDATORIO IMPORTANTE:**
- **Si se crea una nueva colección relacionada con un plan** (ej: `plan_comments`, `plan_attachments`, `plan_notes`, etc.), **DEBE**:
  1. Añadirse la lógica de eliminación en cascada en `PlanService.deletePlan()`
  2. Verificar que las reglas de Firestore permitan la eliminación cuando el plan ya no existe
  3. Añadir un caso de prueba en esta sección para verificar la eliminación
  4. Actualizar la documentación en `FLUJO_CRUD_PLANES.md` con el nuevo orden de eliminación

- **Si se crea una nueva colección relacionada con un evento** (ej: `event_comments`, `event_attachments`, etc.), **DEBE**:
  1. Añadirse la lógica de eliminación en cascada en `EventService.deleteEvent()`
  2. Verificar que las reglas de Firestore permitan la eliminación cuando el evento ya no existe
  3. Añadir un caso de prueba en la sección 4.4 (Eliminar Evento) para verificar la eliminación

Ver sección 4.3 de `FLUJO_CRUD_PLANES.md` para el orden actual de eliminación de planes y eventos.

### 3.5 Eliminación de Usuario (cobertura de invitaciones)

- [ ] **USER-D-006:** Eliminar cuenta borra todas sus invitaciones
  - Pasos:
    1. Con el Usuario A, crear invitaciones para varios planes (siendo owner y también como coorganizador en plan ajeno).
    2. Enviar invitaciones a su propio email (para simular invitaciones recibidas) y a otros emails.
    3. Eliminar completamente la cuenta del Usuario A desde "Eliminar cuenta" (flujo con reautenticación).
    4. Verificar en Firestore que se eliminaron:
       - `plan_invitations` donde `email == usuarioA.email` (recibidas)
       - `plan_invitations` donde `invitedBy == usuarioA.userId` (enviadas)
  - Esperado: No quedan invitaciones asociadas al email ni al `invitedBy` del usuario eliminado.
  - Estado: 🔄

### 3.5.1 Borrado total de usuario (eliminar cuenta)

**Objetivo:** Asegurarse de que "Eliminar cuenta" borra **todos** los datos del usuario en Firestore y en Auth, sin dejar huérfanos ni fallos por permisos.

> **Acción pendiente:** Revisar borrado de cuenta (falla `permission-denied` en pruebas). Ver `docs/testing/REGISTRO_OBSERVACIONES_PRUEBAS.md` § Acciones pendientes.

- [ ] **USER-D-007:** Borrado total de usuario (flujo completo)
  - Pasos:
    1. Crear un usuario de prueba con datos variados: al menos 1 plan donde es owner, 1 participación en plan ajeno, 1 invitación pendiente recibida (o enviada), preferencias si existen.
    2. En la app: Perfil → Acciones avanzadas → "Eliminar cuenta" → reautenticar con contraseña.
    3. Comprobar que el flujo termina sin error (no `permission-denied`) y que se cierra sesión.
    4. En Firestore (y Auth), comprobar que **no queda** ningún dato del usuario: `users/{uid}` eliminado, participaciones, permisos, invitaciones (recibidas y enviadas), eventos creados por él, pagos personales, grupos, preferencias, etc. Ver lista en `UserService.deleteAllUserData()` y en `FLUJO_CRUD_USUARIOS.md` § Eliminación de cuenta.
    5. **Solo iOS/Android:** Tras el cierre de sesión por eliminación de cuenta, el snapshot local del perfil debe quedar limpio: al reiniciar la app en frío no debe mostrarse el usuario eliminado ni datos de su `UserModel` desde cache (Hive box `current_user`, clave `current`; se llama `clearCurrentUser` cuando `firebaseUser == null`). Referencia: [TESTING_OFFLINE_FIRST.md](../testing/TESTING_OFFLINE_FIRST.md), checklist **OFF-PROF-002** (misma limpieza en logout manual).
  - Esperado: Cuenta y todos los datos asociados eliminados; no es posible volver a iniciar sesión con ese email sin registrarse de nuevo.
  - Estado: 🔄

**Mantenimiento:** Cada vez que se añadan **nuevas colecciones o estructuras en Firestore relacionadas con un usuario**, hay que:
  1. Actualizar `UserService.deleteAllUserData()` en `lib/features/auth/domain/services/user_service.dart` para borrar también esas estructuras.
  2. Revisar/actualizar las reglas en `firestore.rules` para que el usuario (o admin) pueda borrar esos documentos en el contexto de eliminación de cuenta.
  3. Volver a ejecutar esta prueba (USER-D-007) y la de invitaciones (USER-D-006) para validar que el borrado sigue siendo completo.

### 3.6 Resumen del plan (T193)

**Contexto:** La funcionalidad "Resumen del plan" genera un texto resumido del plan (eventos, alojamientos, fechas) y permite copiarlo al portapapeles.

- **Desde card e Info del plan:** el icono/botón abre siempre el **diálogo** (PlanSummaryDialog). No hay pestaña "Resumen" ni vista de resumen embebida en la página de info.
- **Vista resumen en W31:** solo desde la **pestaña Calendario**. En la barra del calendario hay un botón "Ver resumen" que cambia W31 a la vista de resumen (WdPlanSummaryScreen). En esa vista, el botón "Calendario" vuelve a la cuadrícula del calendario.

- [ ] **PLAN-SUM-001:** Ver icono de resumen en la card del plan (dashboard)
  - Pasos: Iniciar sesión, abrir el dashboard, localizar una card de plan.
  - Esperado: Se muestra el icono "Ver resumen" (summarize) en la card del plan.
  - Estado: 🔄

- [ ] **PLAN-SUM-002:** Abrir diálogo de resumen desde la card del plan
  - Pasos: En el dashboard, en una card de plan, hacer clic en el icono de resumen.
  - Esperado: Se abre un diálogo con el resumen (carga "Generando resumen...", luego texto formateado). No se cambia de pestaña ni de contenido en W31.
  - Estado: 🔄

- [ ] **PLAN-SUM-003:** Abrir diálogo de resumen desde la pantalla Info del plan (PlanDataScreen)
  - Pasos: Abrir un plan (pestaña planazoo / PlanDataScreen), localizar y hacer clic en el botón "Resumen" (icono + texto).
  - Esperado: Mismo comportamiento que PLAN-SUM-002: se abre el diálogo de resumen.
  - Estado: 🔄

- [ ] **PLAN-SUM-004:** Vista resumen en W31 desde la pestaña Calendario
  - Pasos: Seleccionar un plan, ir a la pestaña Calendario (W15), en la barra del calendario hacer clic en el botón "Ver resumen".
  - Esperado: W31 muestra la vista de resumen (WdPlanSummaryScreen): barra con botón "Calendario" y "Copiar", y el texto del resumen. La pestaña activa sigue siendo Calendario.
  - Estado: 🔄

- [ ] **PLAN-SUM-005:** Volver al calendario desde la vista resumen en W31
  - Pasos: Estar en la vista resumen dentro de la pestaña Calendario, hacer clic en el botón "Calendario" de la barra.
  - Esperado: W31 vuelve a mostrar la cuadrícula del calendario (CalendarScreen).
  - Estado: 🔄

- [ ] **PLAN-SUM-006:** Copiar resumen al portapapeles (diálogo o vista W31)
  - Pasos: Abrir el resumen (diálogo desde card/detalle, o vista W31 desde calendario); cuando esté cargado, hacer clic en "Copiar".
  - Esperado: El texto se copia al portapapeles y se muestra SnackBar de confirmación.
  - Estado: 🔄

- [ ] **PLAN-SUM-007:** Cerrar diálogo de resumen
  - Pasos: En el diálogo de resumen, hacer clic en "Cerrar" o fuera del diálogo.
  - Esperado: El diálogo se cierra sin errores.
  - Estado: 🔄

- [ ] **PLAN-SUM-008:** Resumen cuando el plan no tiene eventos ni alojamientos
  - Pasos: Abrir resumen (diálogo o vista W31) de un plan recién creado sin eventos ni alojamientos.
  - Esperado: Resumen mínimo (nombre, fechas) o mensaje adecuado; sin error.
  - Estado: 🔄

- [ ] **PLAN-SUM-009:** Error al generar resumen (simulado)
  - Pasos: Simular fallo de red o de servicio al abrir el resumen.
  - Esperado: Mensaje de error claro ("No se pudo generar el resumen" o similar), sin crash.
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

- [ ] **EVENT-C-018:** Crear evento con lugar (Google Places - T225)
  - Pasos: En el diálogo de evento, usar el campo "Lugar": escribir en el autocompletado, elegir una sugerencia; comprobar que se rellena el campo y aparece la tarjeta de ubicación con dirección y botón "Abrir en Google Maps"; guardar evento.
  - Esperado: Lugar guardado en `location` y coordenadas/dirección en `extraData` (placeLat, placeLng, placeAddress, placeName); al reabrir el evento se muestran lugar y tarjeta; enlace abre Google Maps correctamente.
  - Estado: 🔄

- [ ] **EVENT-C-019:** Editar evento cambiando el lugar (T225)
  - Pasos: Editar un evento que ya tiene lugar; cambiar eligiendo otro resultado de Places o borrar el lugar.
  - Esperado: Nuevo lugar actualizado o eliminado; tarjeta y enlace coherentes con el lugar actual.
  - Estado: 🔄

- [ ] **EVENT-C-020:** Crear evento desplazamiento con número de vuelo (T246)
  - Pasos: Crear evento → Tipo Desplazamiento, Subtipo Avión. Introducir número de vuelo (ej. IB6842) y pulsar "Obtener datos del vuelo". Comprobar que se rellenan descripción, fecha, hora de inicio y duración; guardar.
  - Esperado: Evento guardado con descripción tipo "IB6842 MAD → FCO"; fecha/hora y duración coherentes con el vuelo; extraData con flightNumber, originIata, destinationIata, departureScheduled, arrivalScheduled, durationMinutes, airlineName. Requiere Amadeus configurado en Cloud Functions.
  - Estado: 🔄

- [ ] **EVENT-C-021:** Editar evento de vuelo y volver a obtener datos (T246)
  - Pasos: Editar un evento que ya tiene datos de vuelo; cambiar número de vuelo o fecha del evento y pulsar de nuevo "Obtener datos del vuelo".
  - Esperado: Se actualizan descripción, hora y duración; al guardar, extraData refleja el nuevo vuelo.
  - Estado: 🔄

- [ ] **EVENT-C-022:** Shuttle/Transfer: terminal, aerolínea y presentación (lista §3.2 ítem 90)
  - Pasos: Crear o editar evento → Desplazamiento → subtipo Shuttle o Transfer. Rellenar origen/destino si aplica; rellenar terminal, aerolínea y presentación en aeropuerto; guardar y reabrir.
  - Esperado: `extraData` contiene `transferTerminal`, `transferAirline`, `transferAirportMeet` cuando hay texto; al cambiar subtipo a otro desplazamiento y guardar, esas claves desaparecen.
  - Estado: 🔄

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

- [ ] **EVENT-D-005:** Verificar eliminación en cascada de evento
  - Pasos: 
    1. Crear un evento con participantes registrados (event_participants)
    2. Si el evento es base, crear copias del evento
    3. Eliminar el evento
    4. Verificar en Firestore que se eliminaron:
       - `event_participants` del evento (eliminación física)
       - Copias del evento (si era evento base, eliminación física)
       - `event` (eliminación física)
  - Esperado: No quedan documentos huérfanos relacionados con el evento eliminado
  - Estado: 🔄

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

### 5.5 Búsqueda de lugar en alojamientos (Google Places - T225)

- [ ] **ACC-PLACES-001:** Búsqueda y selección de lugar al crear alojamiento
  - Pasos: Crear alojamiento → en el primer campo (búsqueda), escribir nombre o dirección (ej. hotel o ciudad); elegir una sugerencia de la lista.
  - Esperado: Se rellenan automáticamente nombre y dirección; no aparece un segundo listado de sugerencias; campo Dirección visible y editable.
  - Estado: 🔄

- [ ] **ACC-PLACES-002:** Tarjeta de ubicación y enlace a Google Maps (alojamiento)
  - Pasos: Tras seleccionar un lugar en el formulario de alojamiento, comprobar la tarjeta de ubicación y el botón "Abrir en Google Maps".
  - Esperado: Tarjeta muestra la dirección formateada; el botón abre Google Maps con la ubicación correcta.
  - Estado: 🔄

- [ ] **ACC-PLACES-003:** Guardado de coordenadas y dirección (alojamiento)
  - Pasos: Crear/editar alojamiento con un lugar seleccionado por Places; guardar.
  - Esperado: En Firestore, commonPart incluye en extraData placeLat, placeLng, placeAddress, placeName; al reabrir el diálogo se muestran nombre, dirección y tarjeta.
  - Estado: 🔄

- [ ] **ACC-PLACES-004:** Alojamiento sin lugar (solo texto manual)
  - Pasos: Crear alojamiento rellenando nombre y dirección a mano, sin usar el autocompletado de Places.
  - Esperado: Se guarda correctamente; no se exige selección de Places.
  - Estado: 🔄

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

- [ ] **PART-D-002:** Participante se auto-elimina ("Salir del plan")
  - Pasos: Como participante (no organizador), desde Info del plan o desde pestaña Participantes → "Salir del plan" → confirmar.
  - Esperado: Confirmación mostrada; al confirmar se elimina su participación, se cierra/redirige la vista del plan y el plan deja de aparecer en su lista.
  - Referencia: `FLUJO_GESTION_PARTICIPANTES.md` § 2.5.
  - Estado: 🔄

- [ ] **PART-LEAVE-001:** Salir del plan desde Info del plan y desde Participantes
  - Pasos:
    1. Usuario B es participante (no owner) de un plan de Usuario A.
    2. Desde la pantalla del plan → pestaña "Info" → botón "Salir del plan" → confirmar.
    3. En otro plan donde B sea participante: pestaña "Participantes" → sección "Salir del plan" → confirmar.
  - Esperado: En ambos casos se muestra diálogo de confirmación; al aceptar, la participación se elimina y B vuelve al dashboard o deja de ver el plan.
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

### 7.1 Invitaciones a Planes (T104)

#### 7.1.0 Flujo E2E: Organizador crea plan e invita a usuario no registrado

- [ ] **INV-E2E-001:** Usuario registrado crea un plan e invita a un usuario no registrado; el invitado recibe el link y acepta
  - Pasos:
    1. **Organizador (registrado):** Login con un usuario existente (ej. `unplanazoo+admin@gmail.com`).
    2. Crear un plan nuevo (nombre, fechas; ver PLAN-C-001). Guardar/abrir el plan.
    3. Ir a **Participantes** → "Invitar por email".
    4. Completar:
       - Email: uno que **no** esté registrado (ej. `unplanazoo+invite1@gmail.com`).
       - Rol: Participante (u otro).
       - Mensaje opcional.
    5. Enviar invitación. Anotar o copiar el link de invitación si se muestra.
    6. **Invitado (no registrado):** Abrir el link de invitación (en otro navegador/incógnito o dispositivo).
    7. En la página de invitación: ver detalles del plan, luego "Aceptar" (o "Aceptar y registrarme" si aplica).
    8. Si el sistema pide registro: completar registro con ese email; luego confirmar aceptación.
  - Esperado:
    - Invitación creada en `plan_invitations` con `status: 'pending'` (paso 5).
    - Invitado ve la página de invitación y puede aceptar (pasos 6–7).
    - Tras aceptar: `plan_invitations.status` → `'accepted'`, se crea `plan_participations` para el invitado, y si no tenía cuenta se crea usuario y participación.
    - Organizador puede ver al nuevo participante en el plan.
  - Casos relacionados: **INV-001** (enviar invitación a no registrado), **INV-008** (aceptar desde link como no registrado). **PLAN-C-001** (crear plan).
  - Estado: 🔄

#### 7.1.1 Invitar por Email

- [x] **INV-001:** Enviar invitación por email (usuario no registrado)
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitar por email"
    2. Completar formulario:
       - Email: `unplanazoo+invite1@gmail.com` (usuario que NO existe)
       - Rol: Participante
       - Mensaje personalizado: (opcional, ej: "¡Espero verte!")
    3. Enviar invitación
  - Esperado: 
    - Se crea documento en `plan_invitations` con `status: 'pending'`
    - Se genera token único y link de invitación
    - Email enviado con link (si Cloud Function configurada) o se muestra link para copiar
    - Link válido por 7 días
  - **⚠️ IMPORTANTE:** El usuario invitado NO debe existir. Usar `unplanazoo+invite1@gmail.com` o similar.
  - Estado: ✅

- [x] **INV-002:** Enviar invitación por email (usuario ya registrado)
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitar por email"
    2. Email: `unplanazoo+part1@gmail.com` (usuario que YA existe)
    3. Rol: Observador
    4. Enviar invitación
  - Esperado: 
    - Se crea invitación en `plan_invitations`
    - Si el usuario tiene app, recibe notificación push
    - Si no tiene app, recibe email
  - Estado: ✅

- [x] **INV-003:** Enviar invitación con rol Observador
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitar por email"
    2. Email: `unplanazoo+obs1@gmail.com`
    3. Rol: Observador
    4. Enviar invitación
  - Esperado: 
    - Invitación creada con `role: 'observer'`
    - Al aceptar, se crea participación con rol Observador
  - Estado: ✅

- [x] **INV-004:** Enviar invitación con mensaje personalizado
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitar por email"
    2. Completar email y rol
    3. Añadir mensaje personalizado: "¡Espero verte en Londres!"
    4. Enviar invitación
  - Esperado: 
    - El mensaje se guarda en `plan_invitations.message`
    - El mensaje aparece en el email (si Cloud Function configurada)
  - Estado: ✅

- [x] **INV-005:** Validación de email inválido
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitar por email"
    2. Email: `email-invalido` (sin @, formato incorrecto)
    3. Intentar enviar
  - Esperado: 
    - Error de validación: "El formato del email no es válido"
    - No se crea invitación
  - Estado: ✅

- [x] **INV-006:** Invitar email ya invitado (pendiente)
  - Pasos: 
    1. Organizador envía invitación a `unplanazoo+invite2@gmail.com`
    2. Sin aceptar/rechazar, intentar invitar de nuevo al mismo email
  - Esperado: 
    - Validación: "Ya existe una invitación pendiente para este email"
    - Opción de re-enviar invitación o cancelar la anterior
  - Estado: ✅

- [x] **INV-007:** Invitar email que ya es participante
  - Pasos: 
    1. Usuario `unplanazoo+part1@gmail.com` ya es participante del plan
    2. Organizador intenta invitar al mismo email
  - Esperado: 
    - Validación: "Este usuario ya es participante del plan"
    - No se crea invitación
  - Estado: ✅

#### 7.1.2 Aceptar/Rechazar Invitaciones

**Nota técnica:** La actualización del estado de la invitación a `accepted` se realiza mediante la **Cloud Function `markInvitationAccepted`** (además de la lógica en cliente) para garantizar permisos y consistencia en Firestore. El link de invitación puede incluir el query param **`?action=accept`**; la app puede hacer strip de este param tras usarlo para evitar reenvíos.

- [ ] **INV-008:** Aceptar invitación desde link (usuario no registrado)
  - Pasos: 
    1. Usuario no registrado hace clic en link de invitación
    2. Si no tiene app: ver web con detalles del plan
    3. Click en "Aceptar" o "Aceptar sin app"
    4. Si no tiene cuenta: completar registro
    5. Confirmar aceptación
  - Esperado: 
    - Si no tiene cuenta: se crea cuenta automática
    - Se crea `plan_participations` con `status: 'accepted'` y `role` asignado
    - Se actualiza `plan_invitations.status` a `'accepted'` y `respondedAt`
    - Se crea track del participante
    - Contador de participantes se actualiza
    - Notificación al organizador (email/push): "[Nombre] ha aceptado tu invitación"
  - **⚠️ IMPORTANTE:** Para probar flujo completo, usar invitación a usuario que NO existe para probar registro desde invitación.
  - Estado: ✅

- [ ] **INV-008b:** Aceptar invitación desde link con `?action=accept` y comprobar que el banner desaparece
  - Pasos: 
    1. Organizador envía invitación y copia el link (puede incluir `?action=accept` o añadirse manualmente)
    2. Invitado (registrado o no) abre el link en la app/web
    3. Si hace falta, iniciar sesión; luego hacer clic en "Aceptar"
  - Esperado: 
    - La invitación pasa a `status: 'accepted'` (vía Cloud Function o cliente)
    - Se crea `plan_participations` y el usuario puede acceder al plan
    - Si la página de invitación mostraba un banner de "Tienes una invitación pendiente", tras aceptar el banner desaparece o se actualiza la vista
  - Estado: 🔄

- [ ] **INV-009:** Aceptar invitación desde link (usuario ya registrado)
  - Pasos: 
    1. Usuario registrado hace clic en link de invitación
    2. Si no está logueado: login
    3. Ver detalles del plan en app
    4. Click en "Aceptar"
  - Esperado: 
    - Se crea `plan_participations` con `status: 'accepted'`
    - Se actualiza `plan_invitations.status` a `'accepted'` y `respondedAt`
    - Usuario puede acceder al plan inmediatamente
    - Notificación al organizador
  - Estado: ✅

- [ ] **INV-010:** Aceptar invitación desde app (por token)
  - Pasos: 
    1. Organizador envía invitación y copia el link
    2. Invitado (usuario registrado) abre app
    3. Ir a Participantes → "Aceptar invitación por token"
    4. Pegar token del link
    5. Click en "Aceptar"
  - Esperado: 
    - Se valida el token
    - Se crea participación con estado "Aceptada"
    - Se actualiza invitación
    - Usuario puede acceder al plan
  - Estado: ✅

- [ ] **INV-011:** Rechazar invitación desde link
  - Pasos: 
    1. Usuario hace clic en link de invitación
    2. Click en "Rechazar"
    3. Confirmar rechazo
  - Esperado: 
    - Se actualiza `plan_invitations.status` a `'rejected'` y `respondedAt`
    - NO se crea `plan_participations`
    - Notificación al organizador: "[Nombre] ha rechazado tu invitación"
    - Usuario no puede acceder al plan
  - Estado: ✅

- [ ] **INV-012:** Rechazar invitación desde app (por token)
  - Pasos: 
    1. Invitado (usuario registrado) abre app
    2. Ir a Participantes → "Aceptar invitación por token"
    3. Pegar token del link
    4. Click en "Rechazar"
  - Esperado: 
    - Se valida el token
    - Se actualiza `plan_invitations.status` a `'rejected'` y `respondedAt`
    - NO se crea participación
    - Notificación al organizador
  - Estado: ✅

#### 7.1.3 Estados y Validaciones de Invitaciones

- [ ] **INV-013:** Invitación expirada (7 días)
  - Pasos: 
    1. Crear invitación
    2. Modificar manualmente `plan_invitations.expiresAt` en Firestore a fecha pasada (o esperar 7 días)
    3. Usuario intenta usar el link
  - Esperado: 
    - Mensaje: "Esta invitación ha expirado. Contacta al organizador para una nueva invitación."
    - No se puede aceptar/rechazar
    - El sistema puede marcar automáticamente `status: 'expired'`
  - Estado: 🔄

- [ ] **INV-014:** Invitación ya aceptada
  - Pasos: 
    1. Usuario acepta invitación
    2. Intentar usar el mismo link de nuevo
  - Esperado: 
    - Mensaje: "Ya eres participante de este plan" o "Esta invitación ya fue aceptada"
    - Redirección al plan si está logueado
  - Estado: 🔄

- [ ] **INV-015:** Invitación ya rechazada
  - Pasos: 
    1. Usuario rechaza invitación
    2. Intentar usar el mismo link de nuevo
  - Esperado: 
    - Mensaje: "Esta invitación fue rechazada. Contacta al organizador si deseas unirte al plan."
    - No se puede aceptar
  - Estado: 🔄

- [ ] **INV-016:** Invitación con token inválido
  - Pasos: 
    1. Modificar token en link (ej: cambiar caracteres)
    2. Intentar usar link modificado
  - Esperado: 
    - Error de seguridad: "Token de invitación inválido"
    - No se puede acceder al plan
    - No se crea participación
  - Estado: ✅

- [ ] **INV-017:** Invitación cancelada (intentar usar link)
  - Pasos: 
    1. Organizador cancela invitación pendiente
    2. Invitado intenta usar el link original
  - Esperado: 
    - Mensaje: "Esta invitación ha sido cancelada por el organizador"
    - No se puede aceptar/rechazar
  - Estado: 🔄

#### 7.1.4 Cancelación de Invitaciones (Owner/Admin)

- [ ] **INV-018:** Cancelar invitación pendiente (owner)
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitaciones pendientes"
    2. Ver lista de invitaciones con `status: 'pending'`
    3. Click en "Cancelar" en una invitación
    4. Confirmar cancelación: "¿Seguro que deseas cancelar esta invitación para [email]?"
  - Esperado: 
    - Se actualiza `plan_invitations.status` a `'cancelled'`
    - Se estampa `respondedAt` con fecha actual
    - La invitación desaparece de la lista de pendientes
    - El contador de invitaciones pendientes se actualiza
    - Email al invitado: "Se ha cancelado tu invitación al plan [Nombre]" (si Cloud Function configurada)
    - Push al invitado (si tiene cuenta/app): "Tu invitación a [Nombre] ha sido cancelada"
    - Snackbar de confirmación al organizador
  - Estado: ✅

- [ ] **INV-019:** Intentar cancelar invitación como participante (no owner)
  - Pasos: 
    1. Participante (no organizador) intenta acceder a "Invitaciones pendientes"
    2. Intentar cancelar una invitación
  - Esperado: 
    - No se muestra opción de cancelar invitaciones (solo owner/admin)
    - Si intenta por API: error de permisos
  - Estado: ✅

- [ ] **INV-020:** Cancelar múltiples invitaciones
  - Pasos: 
    1. Organizador tiene 3 invitaciones pendientes
    2. Cancelar una por una
  - Esperado: 
    - Cada cancelación funciona independientemente
    - El contador se actualiza correctamente después de cada cancelación
    - Todas las notificaciones se envían correctamente
  - Estado: 🔄

#### 7.1.5 Visualización de Invitaciones

- [ ] **INV-021:** Ver invitaciones pendientes (organizador)
  - Pasos: 
    1. Organizador → Plan → Participantes
    2. Ver sección "Invitaciones pendientes"
  - Esperado: 
    - Lista muestra todas las invitaciones con `status: 'pending'`
    - Para cada invitación: email, rol, fecha de envío, opción "Cancelar"
    - Contador: "Invitaciones: N pendientes"
  - Estado: ✅

- [ ] **INV-022:** Ver mis invitaciones pendientes (invitado)
  - Pasos: 
    1. Usuario invitado (logueado) → Plan → Participantes
    2. Ver sección "Mis invitaciones"
  - Esperado: 
    - Lista muestra invitaciones donde `email` coincide con el email del usuario
    - Para cada invitación: nombre del plan, organizador, fecha, botones "Aceptar" / "Rechazar"
    - Estado actual visible (pending, accepted, rejected, cancelled, expired)
  - Estado: ✅

- [ ] **INV-023:** Copiar link de invitación
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitar por email"
    2. Enviar invitación
    3. Click en "Copiar link" o icono de copiar
  - Esperado: 
    - Link copiado al portapapeles
    - Snackbar: "Link copiado al portapapeles"
    - El link es válido y funcional
  - Estado: ✅

#### 7.1.6 Invitar desde lista de usuarios (T104)

- [ ] **INV-024:** Invitar desde lista de usuarios (búsqueda)
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitar usuarios" / lista de usuarios
    2. Buscar usuario por nombre o email
    3. Pulsar "Invitar" en el usuario deseado
  - Esperado: 
    - Se crea invitación en `plan_invitations` (status pending), no se añade al plan directamente
    - Invitado recibe notificación in-app
    - En Participantes, en la sección "Invitaciones", aparece la invitación con estado Pendiente
  - Referencia: `FLUJO_INVITACIONES_NOTIFICACIONES.md` § 1.2.
  - Estado: 🔄 (Implementado Feb 2026)

- [ ] **INV-024b:** Organizador recibe notificación al aceptar/rechazar
  - Pasos: 
    1. Organizador invita a un usuario (por email o desde lista)
    2. Invitado acepta la invitación (o rechaza, en otra ejecución)
  - Esperado: Organizador recibe notificación push/in-app del tipo " [Nombre] ha aceptado tu invitación" o " [Nombre] ha rechazado tu invitación".
  - Estado: 🔄

- [ ] **INV-024c:** Ver estado de invitaciones en Participantes (organizador)
  - Pasos: 
    1. Organizador → Plan → Participantes
    2. Revisar sección "Invitaciones"
  - Esperado: Se listan todas las invitaciones del plan con su estado: Pendiente, Aceptada, Rechazada, Cancelada, Expirada.
  - Estado: 🔄

- [ ] **INV-025:** Invitar usuario que no existe por búsqueda (lista)
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitar usuarios"
    2. Buscar texto que no coincida con ningún usuario
  - Esperado: 
    - Mensaje tipo "No se encontró ningún usuario" o lista vacía
    - Opción de invitar por email si aplica
  - Estado: 🔄

#### 7.1.7 Invitar Grupo (T123)

- [ ] **INV-026:** Invitar grupo completo
  - Pasos: 
    1. Organizador → Plan → Participantes → "Invitar grupo"
    2. Seleccionar grupo: "Familia Ramos"
    3. Ver lista de miembros con estados (activo ✅, inactivo ❓, sin app ❓)
    4. Seleccionar todos o subconjunto
    5. Enviar invitaciones
  - Esperado: 
    - Se crean invitaciones individuales para cada miembro seleccionado
    - A usuarios activos: notificación push
    - A usuarios inactivos/sin app: email
    - Cada miembro gestiona su invitación independientemente
  - Estado: 🔄 (Pendiente implementación T123)

- [ ] **INV-027:** Invitar grupo con miembros ya participantes
  - Pasos: 
    1. Grupo "Familia Ramos" tiene 5 miembros
    2. 2 miembros ya son participantes del plan
    3. Invitar grupo completo
  - Esperado: 
    - Se muestran advertencias: "X miembros ya son participantes"
    - Solo se envían invitaciones a miembros que no son participantes
  - Estado: 🔄 (Pendiente implementación T123)

#### 7.1.8 Recordatorios de Invitaciones Pendientes (Futuro)

- [ ] **INV-028:** Recordatorio automático después de 2 días
  - Pasos: 
    1. Crear invitación pendiente
    2. Esperar 2 días sin respuesta (o simular fecha)
  - Esperado: 
    - Sistema envía recordatorio 1 (suave): "Te enviamos una invitación hace 2 días. ¿Puedes responder?"
    - Email/push al invitado
  - Estado: 🔄 (Pendiente implementación Cloud Function)

- [ ] **INV-029:** Recordatorio automático después de 5 días
  - Pasos: 
    1. Invitación pendiente sin respuesta
    2. Esperar 5 días totales (o simular)
  - Esperado: 
    - Sistema envía recordatorio 2 (más insistente): "[Nombre], te invitamos hace 5 días. Por favor, confirma tu asistencia para poder organizar el plan."
    - Email/push al invitado
  - Estado: 🔄 (Pendiente implementación Cloud Function)

- [ ] **INV-030:** Marcar invitación como expirada después de 7 días
  - Pasos: 
    1. Invitación pendiente sin respuesta
    2. Esperar 7 días totales (o simular)
  - Esperado: 
    - Sistema marca automáticamente `status: 'expired'`
    - Notificación al organizador: "[Nombre] no ha respondido a tu invitación. Puedes re-enviar la invitación o eliminarla."
  - Estado: 🔄 (Pendiente implementación Cloud Function)

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

### 7.4 Sistema de notificaciones (lista global y W20)

**Referencia:** `docs/producto/NOTIFICACIONES_ESPECIFICACION.md`, `docs/flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md` (sección "Acceso a notificaciones en la app").

- [ ] **NOTIF-001:** Campana abre lista global
  - Pasos: Clic en icono campana (notificaciones) en header/sidebar.
  - Esperado: Se abre pantalla/diálogo con **todas** las notificaciones (invitaciones, avisos, eventos desde correo, cambios en eventos, etc.) en una sola lista cronológica (más reciente primero).
  - Estado: 🔄

- [ ] **NOTIF-002:** Filtro por acción en lista global
  - Pasos: En la lista global, activar filtro "Pendientes de acción" o "Solo informativas".
  - Esperado: La lista se filtra: "Pendientes de acción" muestra invitaciones y eventos desde correo pendientes; "Solo informativas" muestra avisos, cambios en eventos, etc.
  - Estado: 🔄

- [ ] **NOTIF-003:** Badge en campana con total no leídas
  - Pasos: Tener notificaciones no leídas; observar el icono de la campana.
  - Esperado: Badge numérico con el total de notificaciones no leídas. Al marcar como leídas, el número disminuye o desaparece.
  - Estado: 🔄

- [ ] **NOTIF-004:** W20 muestra notificaciones del plan seleccionado
  - Pasos: Seleccionar un plan en el dashboard; clic en pestaña W20 "Notificaciones".
  - Esperado: Se muestran solo notificaciones con `planId` = plan seleccionado (invitaciones a ese plan, avisos del plan, cambios en eventos de ese plan). No se muestran notificaciones de otros planes.
  - Estado: 🔄

- [ ] **NOTIF-005:** W20 incluye sección "Eventos desde correo pendientes"
  - Pasos: Con un plan seleccionado, abrir W20; tener al menos un evento pendiente desde correo (en `pending_email_events`).
  - Esperado: Además de las notificaciones del plan, se muestra una sección "Eventos desde correo pendientes" con opciones "Asignar a plan" (a este plan) y "Descartar".
  - Estado: 🔄

- [ ] **NOTIF-006:** Marcar notificaciones como leídas (lista global)
  - Pasos: En lista global, marcar una notificación como leída (o "Marcar todas como leídas").
  - Esperado: El estado se actualiza en Firestore; el badge de la campana se actualiza; la notificación puede seguir visible pero indicada como leída.
  - Estado: 🔄

- [ ] **NOTIF-007:** Acciones desde lista global (aceptar/rechazar invitación, asignar evento)
  - Pasos: Desde la lista global, aceptar una invitación, rechazar otra, asignar un evento desde correo a un plan.
  - Esperado: Las acciones se ejecutan correctamente; la lista se actualiza; los contadores (badge, invitaciones pendientes) se actualizan.
  - Estado: 🔄

### 7.5 Avisos del plan (Info del plan)

**Referencia:** `docs/ux/plan_info_aviso_t231.md`, `docs/flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md` § 2.1. Avisos en `plans/{planId}/announcements`; notificaciones in-app creadas por Cloud Function `onCreateAnnouncementNotifyParticipants`.

- [ ] **AVISO-001:** Publicar aviso desde Info del plan
  - Pasos: Abrir un plan → pestaña Info → sección Avisos → "Publicar" → escribir mensaje, elegir tipo (info / urgente / importante) → confirmar.
  - Esperado: Aviso guardado en Firestore; aparece en el timeline de la sección Avisos; SnackBar de confirmación.
  - Estado: 🔄

- [ ] **AVISO-002:** Ver timeline de avisos (todos los participantes)
  - Pasos: Como cualquier participante del plan, abrir Info del plan → sección Avisos.
  - Esperado: Se muestran todos los avisos del plan en orden cronológico (más reciente primero o último según diseño); autor, tipo, mensaje y fecha visibles.
  - Estado: 🔄

- [ ] **AVISO-003:** Otro participante recibe notificación al publicar un aviso
  - Pasos: Usuario A publica un aviso en el plan. Usuario B (otro participante, misma sesión o otra) abre la app y revisa el icono de notificaciones (campana).
  - Esperado: Usuario B tiene una notificación nueva del tipo "Nuevo aviso en [nombre del plan]" (o "Aviso urgente/importante" según tipo); al abrirla puede navegar al plan y ver el aviso en Info.
  - Estado: 🔄

- [ ] **AVISO-004:** Eliminar aviso (autor u organizador)
  - Pasos: Como autor del aviso o como organizador del plan, en el timeline de Avisos usar la opción de eliminar en un aviso.
  - Esperado: Confirmación si aplica; aviso eliminado de Firestore y del timeline; participantes no pueden eliminar avisos de otros (solo autor u organizador).
  - Estado: 🔄

- [ ] **AVISO-005:** Tipos de aviso (info, urgente, importante)
  - Pasos: Publicar tres avisos con tipo distinto (info, urgente, importante).
  - Esperado: En el timeline se distingue visualmente el tipo (icono, color o etiqueta); en la notificación in-app el título refleja el tipo (ej. "Aviso urgente en [plan]").
  - Estado: 🔄

---

## 8. ESTADOS DEL PLAN

### 8.1 Transiciones de Estado (T109)

- [ ] **STATE-001:** Plan nuevo en Planificando
  - Pasos: Crear y guardar plan
  - Esperado: Plan en estado "planificando" desde el inicio
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

- [ ] **PERM-STATE-001:** Editar plan en estado planificando
  - Pasos: Modificar plan en planificando
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

**Distinción en la UI (ver `docs/producto/PAGOS_MVP.md`, `docs/flujos/FLUJO_PRESUPUESTO_PAGOS.md`):**
- **Presupuesto (T101):** costes del plan, total, desglose. Se ve en la pestaña **Estadísticas (W17)** → `PlanStatsPage`.
- **Pagos (T102):** quién ha pagado qué, balances, sugerencias de transferencias. Se ve en la pestaña **Pagos (W18)** → `PaymentSummaryPage`. *(Bote común retirado de esta pantalla y del cálculo de resumen en mar 2026 — ítem lista 106.)*

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
  - Pasos: Abrir plan → pestaña **Estadísticas (W17)**; ver sección Presupuesto en `PlanStatsPage`
  - Esperado: Total calculado correctamente; desglose por tipo de evento y alojamientos si hay costes
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

**Alcance MVP:** Ver [docs/producto/PAGOS_MVP.md](../producto/PAGOS_MVP.md). Permisos: organizador registra cualquier pago; participante solo "yo pagué X". Bote común: aportaciones y gastos (reparto en balances). Aviso en UI: "La app no procesa cobros…". Flujo E2E: [docs/testing/PLAN_PRUEBAS_E2E_TRES_USUARIOS.md](../testing/PLAN_PRUEBAS_E2E_TRES_USUARIOS.md) — Fase 11.5 Pagos.

**Ítem lista §3.2 — 101 (mar 2026):** La entrada principal de pagos es **solo «Añadir gasto»** (`AddExpenseDialog`). No hay menú «Registrar pago» en el AppBar del resumen ni acceso equivalente en el FAB del plan móvil.

**Ítem 102 (mar 2026):** `PlanExpense.eventId` opcional; selector en `AddExpenseDialog`; icono en barra del `EventDialog`; línea de evento en actividad del resumen.

**Ítems 104–107 (mar 2026):** Editar/eliminar gastos Tricount desde el menú de cada fila en Actividad (organizador, pagador o quien registró); aviso «quién pagó» al abrir gasto con evento preseleccionado; copy balances estilo Tricount + textos aclaratorios; sin sección bote en resumen.

- [ ] **PAY-001:** Añadir gasto individual (flujo principal)
  - Pasos: Abrir plan → pestaña Pagos → botón **+** en la barra (o «Añadir gasto» en actividad, o icono recibo en la barra rápida del plan móvil). Rellenar pagador, importe, concepto, reparto y fecha en `AddExpenseDialog`; guardar.
  - Esperado: Gasto guardado como `PlanExpense`; resumen y balances actualizados.
  - Estado: 🔄

- [ ] **PAY-002:** Ver balance de participante
  - Pasos: En PaymentSummaryPage ver tarjetas por participante (coste asignado, total pagado, balance)
  - Esperado: Balances coherentes (total pagado − coste; gastos Tricount y pagos del plan; sin bote en resumen desde mar 2026)
  - Estado: ✅

- [ ] **PAY-003:** Cálculo de deudas (sugerencias de transferencias)
  - Pasos: Con varios participantes y pagos/costes desiguales, ver sección "Sugerencias de transferencias"
  - Esperado: Texto tipo "X debe Y € a Z"; coherente con balances
  - Estado: ✅

- [ ] **PAY-004:** Permisos en «Añadir gasto» (participante vs organizador)
  - Pasos: Entrar como participante (no organizador) → Pagos → **Añadir gasto**. Comprobar si el selector de pagador permite solo a sí mismo o a cualquiera según reglas actuales del diálogo.
  - Esperado: Coherente con política implementada en `AddExpenseDialog` (revisar tras cambios de permisos).
  - Estado: 🔄

- [ ] **PAY-005:** ~~Bote común — aportación~~ (obsoleto en UI mar 2026)
  - La sección bote **no** está en `PaymentSummaryPage`. Si se mantiene backend T219, probar solo vía datos/Firestore o pantalla alternativa si se reintroduce.
  - Estado: ⏸️ (retirado UI — lista §3.2 ítem 106)

- [ ] **PAY-006:** ~~Bote común — gasto~~ (obsoleto en UI mar 2026)
  - Mismo criterio que PAY-005.
  - Estado: ⏸️

- [ ] **PAY-007:** Aviso legal en pantalla de pagos
  - Pasos: Abrir plan → Pagos (W18)
  - Esperado: Aviso visible tipo "La app no procesa cobros; solo sirve para anotar pagos y cuadrar entre el grupo"
  - Estado: 🔄

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

- [ ] **CURR-005:** Pago/gasto con moneda local diferente (si aplica en UI)
  - Pasos: Tras ítem 101, el flujo «Registrar pago» multi-moneda no está en la UI principal. Probar conversión en el flujo que exista (p. ej. coste en evento T153) o reabrir cuando `AddExpenseDialog` soporte moneda local.
  - Esperado: Conversión automática cuando el formulario lo permita; guardado en moneda del plan.
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
  - Pasos: Abrir plan → pestaña Estadísticas (W17); ver sección Presupuesto en PlanStatsPage
  - Esperado: Si hay costes, muestra sección completa (total, desglose por tipo, eventos vs alojamientos)
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

- [ ] **CAL-EMPTY-001:** W28 vacío sin planes
  - Pasos: Entrar con usuario sin planes
  - Esperado: W28 muestra contenedor vacío (sin spinner ni mensajes)
  - Estado: 🔄

- [ ] **CAL-EMPTY-002:** W31 mensaje sin planes
  - Pasos: Entrar con usuario sin planes
  - Esperado: W31 muestra mensaje "Aún no tienes planes • Crea tu primer plan con el botón +"
  - Estado: 🔄

### 12.3 Regresión funcional (puntos cerrados 2026-03)

> Cobertura de regresión para ítems marcados como hechos en `LISTA_PUNTOS_CORREGIR_APP.md` y `ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_03.md`. Comportamiento de alta rápida y formulario de evento: ver también `docs/flujos/FLUJO_CRUD_EVENTOS.md` § 1.1a; Mi resumen: `docs/flujos/FLUJO_CRUD_PLANES.md` § 2.4.

- [ ] **REG-2026-001:** Info del plan — secciones plegadas y bloque eliminar
  - Pasos: Abrir Info del plan en iOS/web; verificar estado inicial de secciones Participantes/Avisos/Eliminar plan; abrir/cerrar cada una.
  - Esperado: Secciones indicadas cerradas por defecto; iconografía visible en Avisos y Eliminar plan; copy coherente.
  - Estado: 🔄

- [ ] **REG-2026-002:** Info del plan — guardar/cancelar y confirmación al salir con cambios
  - Pasos: Modificar campos en Info del plan y salir por back/navegación.
  - Esperado: Botones Guardar/Cancelar visibles; aparece diálogo para guardar o descartar antes de salir.
  - Estado: 🔄

- [ ] **REG-2026-003:** Info del plan — descripción ampliada y notas de referencia
  - Pasos: Abrir acción de ampliar descripción; editar texto largo; validar sección de notas/referencias del plan.
  - Esperado: Modal de edición larga operativo; datos persistidos tras guardar y recarga.
  - Estado: 🔄

- [ ] **REG-2026-004:** Login — snackbar de error autocierra
  - Pasos: Forzar error de login y no cerrar manualmente el snackbar.
  - Esperado: El mensaje desaparece automáticamente tras unos segundos.
  - Estado: 🔄

- [ ] **REG-2026-005:** Perfil iOS — cabecera con userId legible
  - Pasos: Abrir perfil con userId largo en iPhone pequeño.
  - Esperado: Texto de cabecera no rompe layout (ellipsis/flexible), tamaño de fuente consistente.
  - Estado: 🔄

- [ ] **REG-2026-006:** Admin — auditoría de registros huérfanos
  - Pasos: Abrir pantalla de administración y ejecutar tarjeta/botón de auditoría.
  - Esperado: Se muestra resultado de auditoría sin borrar datos por defecto.
  - Estado: 🔄

- [ ] **REG-2026-007:** Lista de planes móvil — toggle lista/calendario
  - Pasos: En móvil, alternar vista lista/calendario y abrir un plan desde ambas vistas.
  - Esperado: Cambio de vista estable; navegación a detalle correcta.
  - Estado: 🔄

- [ ] **REG-2026-008:** Calendario web/móvil y resumen — FAB de alta rápida de evento
  - Pasos: Con plan **no** en_curso, pulsar FAB "+" en calendario web, en calendario móvil y en pestaña **Mi resumen**. Repetir con plan **en_curso**.
  - Esperado: Se abre el formulario con fecha/hora coherentes con `NewEventFromButtonDefaults.forPlan` (en_curso ≈ ahora acotado al plan; resto ≈ día en rango + 10:00). Sin errores de validación al abrir.
  - Estado: 🔄

- [ ] **REG-2026-009:** Modal de evento web — no cerrar al clic fuera
  - Pasos: Abrir alta/edición de evento, introducir datos y hacer clic fuera del modal.
  - Esperado: El modal no se cierra por clic externo; no se pierden datos.
  - Estado: 🔄

- [ ] **REG-2026-010:** Evento vuelo — timezone por ciudad en menú y GMT en seleccionado
  - Pasos: En Desplazamiento/Avión, abrir dropdown de timezone en salida/llegada.
  - Esperado: El menú muestra ciudades; el valor seleccionado muestra GMT±N.
  - Estado: 🔄

- [ ] **REG-2026-011:** Evento vuelo — autocalcular timezone por localización
  - Pasos: Seleccionar aeropuerto origen/destino por Places y revisar timezone aplicada.
  - Esperado: Se propone timezone según coordenadas (normalizada a lista soportada), tanto en salida como llegada.
  - Estado: 🔄

- [ ] **REG-2026-012:** Formulario de evento — catálogo actualizado
  - Pasos: Revisar tipos/subtipos: Acción (Embarque/Recogida/Entrega/Otro), Actividad→Tour, Desplazamiento→Shuttle/Transfer; en alojamiento, tipo Crucero.
  - Esperado: Opciones visibles y guardables; persistencia correcta al reabrir.
  - Estado: 🔄

- [ ] **REG-2026-013:** Resumen del plan — separador por día y estado no confirmado
  - Pasos: Abrir resumen con eventos en días distintos y eventos no confirmados.
  - Esperado: Línea separadora entre días; indicación visual de estado no confirmado coherente con flujo actual (sin dependencia de "borrador").
  - Estado: 🔄

- [ ] **REG-2026-014:** Calendario — opción "Todos los días del plan"
  - Pasos: En menú de opciones del calendario, activar "Todos los días del plan".
  - Esperado: Se muestran los días hasta el límite configurado (`maxVisibleDays`) sin degradación grave de UX.
  - Estado: 🔄

- [ ] **REG-2026-015:** Calendario/resumen refrescan tras CRUD de evento
  - Pasos: Crear, editar y eliminar evento; volver a calendario y resumen.
  - Esperado: Los cambios se reflejan de inmediato sin recargar manualmente.
  - Estado: 🔄

- [ ] **REG-2026-016:** Evento — un solo guardado con red lenta (ítem 89)
  - Pasos: Simular red lenta o repetir tap rápido sobre **Crear/Guardar** en el diálogo de evento.
  - Esperado: El botón queda deshabilitado y no se crean eventos duplicados.
  - Estado: 🔄

- [ ] **REG-2026-017:** Evento — tipo/subtipo en rejilla 3 columnas A–Z (ítem 96)
  - Pasos: Abrir alta de evento y revisar selectores de tipo y subtipo.
  - Esperado: Tres opciones por fila (donde aplique el layout) y orden alfabético estable.
  - Estado: 🔄

- [ ] **REG-2026-018:** Calendario — separadores verticales entre días (ítem 100)
  - Pasos: Vista multi-día web y móvil con varias columnas.
  - Esperado: Línea entre columnas claramente visible (constantes `calendarVerticalSeparator*`).
  - Estado: 🔄

- [ ] **REG-2026-019:** Info del plan — nombre encima de foto (ítem 68)
  - Pasos: Abrir edición de información del plan.
  - Esperado: El campo nombre aparece por encima de la tarjeta de imagen/estado.
  - Estado: 🔄

- [ ] **REG-2026-020:** Mi resumen — locale en plan completo, web/mapa, "Todos", alojamientos (ítems 78, 82, 83, 86, 88)
  - Pasos: En **Resumen todos**, abrir **Plan completo** con el dispositivo en ES y en EN; revisar filas con evento "para todos", fila con URL web, fila de alojamiento con dirección; comprobar orden de dos eventos el mismo día a distinta hora.
  - Esperado: Encabezados de día en idioma del usuario con día completo y año; chip web con icono (no texto "www"), tamaño similar al marcador; sin dirección en subtítulo de alojamiento (Maps sigue funcionando); etiqueta de todos los participantes en naranja; orden por hora (no por orden de creación arbitrario).
  - Estado: 🔄

- [ ] **REG-2026-021:** Notas del plan / workspace — permisos Firestore
  - Pasos: Guardar notas de referencia como organizador/admin tras `firebase deploy --only firestore:rules` si hubo cambios recientes.
  - Esperado: Sin `permission-denied`; si falla, verificar despliegue de reglas y mensaje de ayuda en cliente.
  - Estado: 🔄

---

## 13. TIMEZONES
- [ ] **⚠️ IMPORTANTE:** Esta sección es crítica para la funcionalidad de la app.

+### 13.0 Pruebas genéricas de timezones
+- [x] **TZ-GEN-001:** Verificar preferencia personal
+  - Pasos:
+    1. Abrir perfil → Seguridad y acceso → Configurar zona horaria.
+    2. Seleccionar timezone distinta a la del dispositivo y guardar.
+    3. Reabrir perfil y comprobar que la preferencia se mantiene.
+  - Esperado: `users.defaultTimezone` actualizado y visible en cabecera del perfil.
+- [ ] **TZ-GEN-002:** Comprobar propagación a participaciones
+  - Pasos:
+    1. Tras cambiar la preferencia, abrir un plan donde el usuario participe.
+    2. Inspeccionar Firestore (`plan_participations.personalTimezone`) o revisar eventos en calendario.
+  - Esperado: Todas las participaciones activas usan la nueva zona; eventos muestran horarios convertidos.
+  - Nota: Se completará en conjunto con las pruebas de planes y eventos (sección 3 y 4).
+- [x] **TZ-GEN-003:** Banner de detección automática (si aplica)
+  - Pasos:
+    1. Cambiar `users.defaultTimezone` manualmente en Firestore a un valor diferente al timezone del dispositivo.
+    2. Volver a iniciar sesión.
+  - Esperado: Banner con copy de soporte, opciones "Actualizar zona" y "Mantener". Al elegir cada opción se muestra snackbar correspondiente.
+- [ ] **TZ-GEN-004:** Consistencia tras recargar sesión
+  - Pasos:
+    1. Cambiar preferencia de timezone.
+    2. Hacer logout/login y abrir el mismo plan.
+  - Esperado: La preferencia persiste y el calendario respeta la zona configurada.
+  - Nota: Persistencia confirmada. Verificación visual del calendario se realizará junto con eventos multi-timezone.
+- [ ] **TZ-GEN-005:** Fallback sin preferencia
+  - Pasos:
+    1. Crear usuario nuevo (sin `defaultTimezone`).
+    2. Abrir plan existente con timezone definida.
+  - Esperado: El usuario ve los horarios en la zona del plan hasta que configure su preferencia.
+
### 13.1 Timezones en Planes (T40)

#### TZ-001 — Creación de plan

- Usuarios:  
  - Usuario A (preferencia timezone `Europe/Madrid` – UTC+01)  
  - Usuario B (preferencia timezone `America/New_York` – UTC−05)
- Pasos: 
  1. Usuario A crea plan nuevo → selecciona timezone `Europe/Madrid`. 
  2. Usuario B abre el plan sin refrescar el navegador.
  3. Ambos revisan la cabecera del plan y la franja horaria de los días.
- Esperado: 
  - El plan queda persistido con timezone Madrid.
  - Usuario B visualiza fechas convertidas a UTC−05 (mismas horas absolutas, hora local distinta).
- Estado: ✅

- [ ] **TZ-002:** Cambio de timezone del plan existente
  - Pasos:
    1. Usuario A edita plan creado en `TZ-001` → cambia timezone a `America/New_York`.
    2. Usuario B vuelve a abrir el plan.
    3. Verificar que los eventos existentes (creados en la zona anterior) se reajustan correctamente.
  - Esperado:
    - La UI refleja inmediatamente el nuevo timezone del plan.
    - No hay duplicados/solapamientos inesperados.
  - Estado: 🔄

- [ ] **TZ-003:** Plan sin preferencia de usuario definida
  - Pasos:
    1. Usuario C (sin preferencia guardada) inicia sesión.
    2. Abre un plan con timezone UTC-03 (creado por otro usuario).
  - Esperado: Se utiliza la zona del plan como fallback hasta que configure su preferencia personal. *(UI para preferencia pendiente — ver tareas T40/T176)* 
  - Estado: 🔄

### 13.2 Timezones en Eventos

- [ ] **TZ-EVENT-001:** Evento local al timezone del plan
  - Pasos:
    1. Usuario A crea evento en plan (hora 10:00 Madrid).
    2. Usuario B revisa la agenda.
  - Esperado: Usuario B visualiza el evento convertido (por ejemplo 04:00 New York) sin desplazar el día.
  - Estado: 🔄

- [ ] **TZ-EVENT-002:** Evento "viaje" con timezone de llegada
  - Pasos:
    1. Crear evento de tipo viaje con salida Madrid 09:00 y llegada New York 13:00 local.
    2. Indicar explicitly `departureTimezone` y `arrivalTimezone` si el diálogo lo soporta.
    3. Visualizar como Usuario A y Usuario B.
  - Esperado: El rango visible respeta ambos husos (span correcto, tooltips con hora local y convertida).
  - Estado: 🔄

- [ ] **TZ-EVENT-003:** Evento creado por usuario con preferencia distinta
  - Pasos: Usuario B (timezone NY) crea evento en plan configurado en Madrid.
  - Esperado: El evento se guarda en UTC del plan y ambos usuarios ven hora coherente.
  - Estado: 🔄

- [ ] **TZ-EVENT-004:** Conversión en vistas derivadas
  - Pasos: Comprobar `CalendarScreen`, `PlanStats` y exportaciones (si aplica) después de crear eventos multi-timezone.
  - Esperado: Mismas franjas horarias en todas las vistas; estadísticas no duplicadas.
  - Estado: 🔄

#### TZ-EVENT-004 — Alertas automáticas por cambio de timezone (T178)
- Pasos:
  1. Iniciar sesión con usuario cuya `defaultTimezone` sea distinta a la del dispositivo.
  2. Verificar aparición del banner en el dashboard.
  3. Pulsar "Actualizar zona" → comprobar que se actualiza `users.defaultTimezone` y todas las participaciones.
  4. Repetir escenario pero pulsando "Mantener" → el banner desaparece y se registra el snackbar informativo.
- Esperado:
  - Banner con copy amigable, botones "Actualizar zona" / "Mantener".
  - Mensajes localizados y sin bloqueos en la navegación.
  - Tras actualizar, los eventos recalculan su horario según la nueva preferencia.

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

### 14.4 Reglas Firestore (borrados especiales)

- [ ] **SEC-RULES-001:** `plan_participations` delete por owner de plan
  - Pasos: Owner elimina participaciones de otro usuario
  - Esperado: Permitido
  - Estado: 🔄

- [ ] **SEC-RULES-002:** `plan_participations` delete huérfana por su propio usuario
  - Pasos: Usuario elimina su propia participación cuyo `planId` ya no existe
  - Esperado: Permitido
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

### 15.2 Perfil local Hive (current_user, solo móvil)

**Contexto:** En iOS/Android el perfil autenticado tiene copia en Hive para arranque cuando Firestore no responde. No aplica a web. Detalle: [TESTING_OFFLINE_FIRST.md](../testing/TESTING_OFFLINE_FIRST.md), [FLUJO_CRUD_USUARIOS.md](../flujos/FLUJO_CRUD_USUARIOS.md).

- [ ] **OFF-PROF-001:** Reinicio en frío con sesión y sin red — perfil coherente
  - Pasos:
    1. Iniciar sesión online y esperar carga normal del perfil desde Firestore.
    2. Forzar cierre de la app (no solo background).
    3. Activar modo avión o desactivar datos/Wi‑Fi.
    4. Abrir la app de nuevo.
  - Esperado: No bloqueo indefinido en carga de auth; se muestra usuario coherente con el último snapshot (displayName, etc.) o fallback mínimo desde Auth según implementación. Log opcional: `Item guardado localmente: current [current_user]` tras sesión online previa.
  - Estado: 🔄

- [ ] **OFF-PROF-002:** Cerrar sesión borra snapshot local del perfil
  - Pasos:
    1. Con sesión iniciada (tras haber cargado perfil al menos una vez en online), usar **Cerrar sesión**.
    2. Cerrar app por completo y volver a abrir (opcional: sin red).
  - Esperado: Pantalla de login; no se reutiliza el `UserModel` de la cuenta cerrada desde Hive. Implementación: `AuthNotifier` → `clearCurrentUser()` cuando no hay `firebaseUser`.
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

**Total de pruebas:** ~280+  
**Implementadas y probadas:** ~30  
**Pendientes:** ~250  

**Por sección:**
- Autenticación: 🔄 Pendiente
- CRUD Planes: 🔄 Pendiente
- CRUD Eventos: 🔄 Parcial (T47, T117, T120, T101 ✅)
- CRUD Alojamientos: 🔄 Parcial (T101 ✅)
- Participantes: 🔄 Parcial (T123 ✅)
- Invitaciones: ✅ Base completada (30 casos detallados: email, aceptar/rechazar, cancelación, visualización; pendientes: username, grupos, recordatorios)
- Estados: ✅ Base completada
- Presupuesto: ✅ Base completada (T101)
- Estadísticas: ✅ Base completada (T113)
- Validaciones: ✅ Base completada (VALID-1, VALID-2)
- Calendario: ✅ Visualizaciones completadas (T50, T89, T90, T91, T112)
- Seguridad: ✅ Base completada (T126, T127)

---

**Última actualización:** Enero 2025  
**Próxima revisión:** Tras completar T102


