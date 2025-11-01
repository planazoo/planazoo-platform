# 👤 FLUJO_CRUD_USUARIOS

Estado: En curso  
Versión: 1.0  
Fecha: Enero 2025

---

## 🎯 Objetivo
Definir y alinear el flujo completo de gestión de usuarios (registro, login, lectura, actualización, eliminación, recuperación) con la implementación actual del código y las reglas de seguridad. El documento se actualiza dinámicamente conforme implementamos mejoras.

Relacionado con: `lib/features/auth/presentation/notifiers/auth_notifier.dart`, `lib/features/auth/domain/services/user_service.dart`, `lib/features/auth/domain/models/user_model.dart`, `firestore.rules`, `GUIA_SEGURIDAD.md`.

---

## 🔐 Modelo de Datos

- Clase: `UserModel`
  - Campos: `id`, `email`, `username?`, `displayName?`, `photoURL?`, `createdAt`, `lastLoginAt?`, `isActive`
  - Serialización: `toFirestore()` usa `Timestamp` para fechas
  - Creación desde Auth: `UserModel.fromFirebaseAuth()`

Estado actual:
- ✅ Username único implementado con índice `usernameLower` y validación
- ✅ Sanitización de `displayName` y `username` aplicada
- ⚠️ Pendiente de pruebas completas antes de cerrar T137

---

## 🧭 Flujo: Registro

1) Usuario envía email y password
2) Se crea el usuario en Firebase Auth
3) Se crea documento en `/users/{uid}` con `UserModel.fromFirebaseAuth`
4) Se envía email de verificación y se fuerza logout hasta verificar

Implementación actual:
- `AuthNotifier.registerWithEmailAndPassword()`
- Sanitización de `displayName` aplicada (T127)
- `UserService.createUser()`
- Email de verificación y logout posterior

Reglas Firestore (users):
- create/update/delete solo por el propio usuario (`request.auth.uid == userId`)

Gaps/Mejoras:
- Rate limiting de registro (no crítico ahora) [Tarea futura]
- Captcha opcional en web (T135) [Tarea futura]

---

## 🔑 Flujo: Login

1) Usuario envía credenciales
2) Rate limiting (5/15min; CAPTCHA tras 3 fallos) — implementado
3) Verificación de email antes de establecer estado autenticado
4) Actualizar `lastLoginAt`

Implementación actual:
- `AuthNotifier.signInWithEmailAndPassword()` + `RateLimiterService`
- Verificación de `emailVerified` en `_init()` y logout si no verificado
- `lastLoginAt` se actualiza automáticamente en el stream de autenticación (`_init()` línea 52)

Gaps/Mejoras:
- Mensajes i18n centralizados (cubierto en UI, ok)

---

## 👁️ Lectura de Perfil

- `UserService.getUser()` / `getUserStream()`
- Reglas: lectura permitida a autenticados (perfil público básico)

Gaps:
- Campos de visibilidad granular (público/privado) para `email`, `photoURL` (futuro) [Tarea futura]

---

## ✏️ Actualización de Perfil

- `AuthNotifier.updateProfile()` y `UserService.updateUserProfile()`
- `AuthNotifier.updateUsername()` + `UserService.updateUsername()` (nuevo)
- Reglas: solo el propio usuario; email no mutable

Validaciones y seguridad:
- Sanitizar `displayName` (T127 base disponible: `Sanitizer.sanitizePlainText`) — aplicado
- Validar `photoURL` (opcional: `Validator.isSafeUrl`) — aplicado
- Validar `username` con `Validator.isValidUsername` (minúsculas, [a-z0-9_], 3–30) — aplicado
- Persistir índice `usernameLower` para búsquedas unicidad — aplicado

Acciones:
- [Hecho] Sanitización en `updateProfile`
- [Hecho] Validación/normalización de `username` y control de colisiones

---

## 🗑️ Eliminación de Cuenta

- `AuthNotifier.deleteAccount(password)`
  - Reautenticación
  - Borrado en `/users/{uid}`
  - Borrado en Firebase Auth
- Reglas: solo el propio usuario puede eliminar

Gaps:
- Soft-delete opcional (`isActive=false`) ya soportado en `UserService.deactivateUser()`
- Export de datos personales antes de eliminar (GDPR) [T129]

---

## 🔁 Recuperación de Contraseña

- `AuthNotifier.sendPasswordResetEmail()`
- Rate limiting: 3 emails/hora

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
- ✅ Corregido `account_settings_page.dart` para usar `AuthNotifier` en lugar de `UserNotifier` para `deleteAccount` y `changePassword`

