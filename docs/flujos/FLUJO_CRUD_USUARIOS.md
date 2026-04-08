# 👤 FLUJO_CRUD_USUARIOS

Estado: ✅ Alineado  
Versión: 1.5  
Fecha: Abril 2026 (snapshot de perfil en Hive `current_user` para arranque offline). Base original Noviembre 2025; v1.4: coherencia documental; Febrero 2026: UserModel.isAdmin (T188), AccountSettingsPage eliminado.

---

## 🎯 Objetivo
Definir y alinear el flujo completo de gestión de usuarios (registro, login, lectura, actualización, eliminación, recuperación) con la implementación actual del código y las reglas de seguridad. El documento se actualiza dinámicamente conforme implementamos mejoras.

Relacionado con: `lib/features/auth/presentation/notifiers/auth_notifier.dart`, `lib/features/auth/domain/services/user_service.dart`, `lib/features/auth/domain/models/user_model.dart`, `lib/features/offline/domain/services/user_local_service.dart`, `firestore.rules`, `GUIA_SEGURIDAD.md`, `docs/testing/TESTING_OFFLINE_FIRST.md`.

---

## 📱 Snapshot de perfil en Hive (móvil, offline-first)

Solo **iOS/Android** (no web). Complementa Firestore para que el arranque con sesión Firebase Auth no dependa de red.

| Aspecto | Comportamiento |
|---------|----------------|
| **Almacén** | Hive box `current_user`, documento único con clave `current` |
| **Servicio** | `UserLocalService` (`toMap` / `fromMap` a partir de `UserModel`) |
| **Escritura** | Tras obtener el usuario desde Firestore en el listener de `AuthNotifier` y establecer `AuthStatus.authenticated` |
| **Lectura** | Si `getUser` hace timeout, falla o devuelve `null` pero Auth sigue activo, se usa el snapshot **solo si** `cached.id == firebaseUser.uid` |
| **Borrado** | Al cerrar sesión (`firebaseUser == null`): `clearCurrentUser()` |
| **Fallback** | Si no hay snapshot válido, `UserModel.fromFirebaseAuth()` (datos mínimos) |

Inventario completo de boxes offline: `docs/testing/TESTING_OFFLINE_FIRST.md`.

---

## 🔐 Modelo de Datos

- Clase: `UserModel`
  - Campos: `id`, `email`, `username?`, `displayName?`, `photoURL?`, `createdAt`, `lastLoginAt?`, `isActive`, `defaultTimezone?`, `isAdmin` (T188, administradores de la plataforma)
  - `AuthState`: añade `deviceTimezone` y `timezoneSuggestion?` para mostrar banners contextuales
  - Serialización: `toFirestore()` usa `Timestamp` para fechas
  - Creación desde Auth: `UserModel.fromFirebaseAuth()`

Estado actual:
- ✅ Username único implementado con índice `usernameLower` y validación
- ✅ Sanitización de `displayName` y `username` aplicada
- ✅ **T163:** Username es **OBLIGATORIO** en el registro (nuevos usuarios)
- ✅ **T163:** Login acepta email o username (con o sin @)
- ✅ **T163:** Usuarios existentes sin username reciben uno automático en el login
- ⚠️ Pendiente de pruebas completas antes de cerrar T137 y T163
- ✅ **Abr 2026:** Perfil cacheado en Hive (`current_user`) para arranque offline coherente con `UserModel`

---

## 🧭 Flujo: Registro

1) Usuario envía email, password, **username** (obligatorio) y displayName (opcional)
2) **Validación de username:**
   - Formato: 3-30 caracteres, [a-z0-9_], minúsculas
   - Disponibilidad: verificación en Firestore usando `usernameLower`
   - Si está ocupado: se muestran sugerencias automáticas (ej: `usuario1`, `usuario2`, `usuario_2025`)
3) Se crea el usuario en Firebase Auth
4) Se crea documento en `/users/{uid}` con `UserModel.fromFirebaseAuth` + username
5) Se guarda `username` y `usernameLower` en Firestore
6) Se envía email de verificación y se fuerza logout hasta verificar

Implementación actual:
- `AuthNotifier.registerWithEmailAndPassword(email, password, displayName, username)`
- Validación de formato con `Validator.isValidUsername()`
- Verificación de disponibilidad con `UserService.isUsernameAvailable()`
- Generación de sugerencias si username está ocupado
- Sanitización de `displayName` aplicada (T127)
- `UserService.createUser()` guarda username y usernameLower
- Email de verificación y logout posterior

Reglas Firestore (users):
- create/update/delete solo por el propio usuario (`request.auth.uid == userId`)

**Cambios T163 / T177 / T178:**
- ✅ Username es obligatorio en el formulario de registro
- ✅ Validación de disponibilidad antes de crear usuario
- ✅ Sugerencias automáticas si username está ocupado
- ✅ Campo de username posicionado después del email en el formulario
- ✅ Preferencia de timezone por usuario (`defaultTimezone`) inicializada con timezone del dispositivo si no existe
- ✅ Banner de sugerencia de timezone (`timezoneSuggestion`) cuando el dispositivo y la preferencia difieren

Gaps/Mejoras:
- Rate limiting de registro (no crítico ahora) [Tarea futura]
- Captcha opcional en web (T135) [Tarea futura]

---

## 🔑 Flujo: Login

### Login con Email/Username y Contraseña

1) Usuario envía credenciales (email **o username**)
2) **Detección de tipo de credencial:**
   - Si contiene `@`: se trata como email
   - Si no contiene `@`: se trata como username
   - Si username empieza con `@`: se quita el `@` antes de buscar
3) **Si es username:**
   - Buscar usuario en Firestore usando `UserService.getUserByUsername()`
   - Obtener el email asociado al username
   - Si no existe: error "No se encontró un usuario con ese nombre de usuario"
4) Rate limiting (5/15min; CAPTCHA tras 3 fallos) — implementado (usando email para rate limiting)
5) Verificación de email antes de establecer estado autenticado
6) **Generación automática de username (T163):**
   - Si el usuario no tiene username, se genera automáticamente
   - Se intenta generar desde `displayName`, luego desde `email`, finalmente aleatorio
   - Se guarda en Firestore con `updateUsername()`
7) Actualizar `lastLoginAt`

### Login con Google (T164)

1) Usuario hace clic en "Continuar con Google"
2) Se abre el selector de cuenta de Google
3) Usuario selecciona su cuenta de Google
4) Firebase Auth autentica con Google
5) **Si el usuario no existe en Firestore:**
   - Se crea automáticamente un `UserModel` desde los datos de Google
   - Se genera automáticamente un username
   - Se guarda en Firestore con `createUser()`
6) **Si el usuario ya existe:**
   - Se actualiza `lastLoginAt`
   - Si no tiene username, se genera automáticamente
7) **Datos de Google:**
   - Email: se usa el email de Google
   - DisplayName: se usa el nombre de Google
   - PhotoURL: se usa la foto de perfil de Google
   - Email verificado: automáticamente verificado (Google ya verifica)

Implementación actual:
- `AuthNotifier.signInWithEmailAndPassword(emailOrUsername, password)` - Login tradicional
- `AuthNotifier.signInWithGoogle()` - Login con Google (T164)
- `AuthService.signInWithGoogle()` - Integración con Google Sign-In
- Detección automática de email vs username
- `UserService.getUserByUsername()` para buscar por username
- `AuthNotifier._generateAutomaticUsername()` para usuarios sin username
- Creación automática de usuario en Firestore si no existe (para Google)
- `RateLimiterService` (usando email para rate limiting, solo para login tradicional)
- Verificación de `emailVerified` en `_init()` y logout si no verificado (solo para login tradicional)
- `lastLoginAt` se actualiza automáticamente en el stream de autenticación

**Cambios T163:**
- ✅ Login acepta email o username (con o sin @)
- ✅ Validación de campo acepta ambos formatos
- ✅ Icono dinámico en el campo (email icon o @ icon)
- ✅ Generación automática de username para usuarios existentes sin username

**Cambios T164:**
- ✅ Login con Google implementado
- ✅ Botón "Continuar con Google" en la página de login
- ✅ Creación automática de usuario en Firestore para usuarios de Google
- ✅ Generación automática de username para usuarios de Google
- ✅ Manejo de errores y cancelación

Gaps/Mejoras:
- Mensajes i18n centralizados (cubierto en UI, ok)

---

## 👁️ Lectura de Perfil

- `UserService.getUser()` / `getUserStream()`
- Reglas: lectura permitida a autenticados (perfil público básico)

Gaps:
- Campos de visibilidad granular (público/privado) para `email`, `photoURL` (futuro) [Tarea futura]

---

## ✏️ Actualización de Perfil y Cambio de Contraseña

- `AuthNotifier.updateProfile()` y `UserService.updateUserProfile()`
- `AuthNotifier.updateUsername()` + `UserService.updateUsername()` (nuevo)
- `AuthNotifier.changePassword()` + diálogo UX (Noviembre 2025)
- Reglas: solo el propio usuario; email no mutable

Validaciones y seguridad:
- Sanitizar `displayName` (T127 base disponible: `Sanitizer.sanitizePlainText`) — aplicado
- Validar `photoURL` (opcional: `Validator.isSafeUrl`) — aplicado
- Validar `username` con `Validator.isValidUsername` (minúsculas, [a-z0-9_], 3–30) — aplicado
- Persistir índice `usernameLower` para búsquedas unicidad — aplicado
- Cambio de contraseña:
  - Modal dedicado desde `ProfilePage` (`_showChangePasswordDialog`) con checklist de requisitos y estilo Planazoo
  - Validaciones `Validator.validatePassword` (8+ caracteres, mayúscula, minúscula, número, símbolo)
  - Campo de confirmación y mensajes i18n (ES/EN) alineados con `app_es/en.arb`
  - Snackbars de éxito/error coherentes con el resto de la app

Acciones:
- [Hecho] Sanitización en `updateProfile`
- [Hecho] Validación/normalización de `username` y control de colisiones
- [Hecho] Pantalla de perfil reorganizada en tres tarjetas (Datos personales, Seguridad, Acciones avanzadas)
- [Hecho] Vista de perfil ocupa el grid principal (W2-W17) dejando visible la barra lateral W1 para mantener contexto
- [Hecho] Top bar con flecha de retorno a la izquierda y `@username` alineado a la derecha
- [Hecho] Modal de edición centrado (480px máx) sin flecha redundante
- [Hecho] Botones “Migrar eventos” y “Participar en todos los planes” eliminados (solo quedan acciones relevantes)
- [Hecho] `AccountSettingsPage` eliminado; sustituido por modales específicos desde perfil (cambiar contraseña, privacidad, idioma). `deleteAccount` y `changePassword` se usan vía `AuthNotifier`.
- [Hecho] Opción “Configurar zona horaria” en tarjeta de Seguridad: selector de timezone con búsqueda, preferencia guardada en `defaultTimezone`
- [Hecho] Banner de recomendación de timezone si `deviceTimezone` ≠ `defaultTimezone`, con acciones “Actualizar zona” / “Mantener”

---

## 🗑️ Eliminación de Cuenta

- `AuthNotifier.deleteAccount(password)`
  - Reautenticación del usuario
  - Llamada a `UserService.deleteAllUserData(userId)` que elimina:
    1. Planes creados por el usuario (y todos sus datos relacionados en cascada)
    2. Participaciones en planes (`plan_participations`)
    3. Eventos creados por el usuario (y sus `event_participants`)
    4. Participaciones en eventos (`event_participants`)
    5. Permisos del usuario (`plan_permissions`)
    6. Invitaciones por email (`plan_invitations`)
    7. Pagos personales (`personal_payments`)
    8. Grupos de participantes (`participant_groups`)
    9. Preferencias del usuario (`userPreferences`)
    10. Preferencias por plan (`plans/{planId}/userPreferences/{userId}`)
    11. El usuario mismo (`users/{userId}`)
  - Borrado en Firebase Auth (último paso)

**⚠️ IMPORTANTE:** La eliminación es **completa e irreversible**. Todos los datos del usuario se eliminan físicamente de Firestore.

**Mantenimiento:** Al añadir **nuevas colecciones o estructuras en Firestore** relacionadas con un usuario (subcolecciones, documentos por userId, etc.), hay que:
1. Actualizar `UserService.deleteAllUserData()` en `lib/features/auth/domain/services/user_service.dart` para incluir el borrado de esas estructuras.
2. Revisar `firestore.rules` para que el usuario (o admin) pueda borrar esos documentos en el flujo de eliminación de cuenta.
3. Volver a probar el borrado total (ver `TESTING_CHECKLIST.md` § 3.5.1 Borrado total de usuario).

**Para administradores:** Si necesitas eliminar los datos de un usuario desde código o consola, puedes llamar directamente a `UserService.deleteAllUserData(userId)`. Esto es útil para limpieza administrativa o cumplimiento de solicitudes de eliminación de datos (GDPR).

Gaps:
- Soft-delete opcional (`isActive=false`) ya soportado en `UserService.deactivateUser()`
- Export de datos personales antes de eliminar (GDPR) [T129]

---

## 🔁 Recuperación de Contraseña

- `AuthNotifier.sendPasswordResetEmail()`
- Rate limiting: 3 emails/hora
- Formulario admite alias con `+`
- Snackbar de confirmación y retorno inmediato al login tras enviar
- La pantalla web de Firebase mantiene la plantilla por defecto; ver T172 para personalización futura

Ok y alineado con `RateLimiterService`.

---

## 🧱 Reglas de Seguridad (Firestore)

Resumen:
- `match /users/{userId}`: read autenticados; create/update/delete solo el propio usuario; email inmutable
- Validaciones en cliente complementan las reglas

Ref: ver `firestore.rules` sección `REGLAS PARA USUARIOS`.

---

## 📋 Checklist de Validaciones (T51/T127)

- ✅ Email formato válido (Validator)
- ✅ `displayName` 2–100 chars, texto plano (sanitizado)
- ✅ `username` 3–30 chars, [a-z0-9_], único (implementado con índice `usernameLower`, pendiente pruebas) [T137]
- ✅ `photoURL` http/https seguro (opcional, validado con `Validator.isSafeUrl`)

---

## 📌 Tareas Derivadas

- **T137 - Username único y sanitización** (✅ Implementado, ⚠️ Pendiente pruebas)
  - ✅ En `UserService`: comprobar disponibilidad (query case-insensitive con `usernameLower`)
  - ✅ Validar patrón: `^[a-z0-9_]{3,30}$` (Validator.isValidUsername)
  - ✅ UI: campo opcional en perfil (`pg_profile_page.dart`)
  - ✅ Normalización a minúsculas y persistencia de `usernameLower`
  - ⚠️ Ver `TASKS.md` para lista de pruebas pendientes
- **T129 - Export de Datos (GDPR)** (Pendiente)
  - Exportar `/users/{uid}`, participaciones, planes creados, eventos creados
- **T135 - Cookies/Consent (web): Captcha opcional** (Pendiente)
  - Captcha opcional para registro/login (mejora de seguridad)
- **T172 - Personalizar flujo web de restablecimiento de contraseña** (Pendiente)
  - Diseñar UI propia hospedada en Firebase Hosting para enlaces de reset
  - Aplicar mismas validaciones y estilo que en la app + mensajes localizados

---

## ✅ Estado de Alineación

- Registro/Login/Recuperación: ✅ Alineado
- Lectura/Actualización/Eliminación: ✅ Alineado
- Reglas de Seguridad: ✅ Alineado
- UI (W6 - Perfil): ✅ Actualizado para mostrar `displayIdentifier` (username o displayName, no email)
- Gaps pendientes: Export GDPR (T129), visibilidad granular (futuro), captcha web (T135)

---

## ➕ Acciones Completadas

- ✅ Sanitizar `displayName` en `AuthNotifier.updateProfile` (T127)
- ✅ Sanitizar `displayName` en `AuthNotifier.registerWithEmailAndPassword` (T127)
- ✅ Validar `photoURL` segura antes de guardar (Validator.isSafeUrl)
- ✅ Username único con validación y normalización (T137 - implementado, pendiente pruebas)
- ✅ UI actualizada para usar `displayIdentifier` en W6 (no mostrar email directamente)
- ✅ Eliminado `account_settings_page.dart`; `deleteAccount` y `changePassword` se invocan desde `ProfilePage` vía `AuthNotifier` (modales dedicados)

*Última actualización: Abril 2026*


