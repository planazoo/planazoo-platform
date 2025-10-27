# 🔒 Guía de Seguridad

> Guía de referencia de medidas de seguridad para proteger datos sensibles y la plataforma

**Relacionado con:** T51, T52, T53, T65, T66, T67, T125-T129  
**Versión:** 1.0  
**Fecha:** Enero 2025

---

## 🎯 Objetivo

Esta guía de referencia documenta todas las medidas de seguridad necesarias para proteger datos sensibles de usuarios, planes, eventos y comunicaciones. Debe ser consultada **antes de implementar cualquier funcionalidad nueva**.

---

## 📋 ÁREAS DE SEGURIDAD

### 1. AUTENTICACIÓN Y AUTORIZACIÓN

#### 1.1 - Autenticación

**Medidas implementadas/requeridas:**
- ✅ Firebase Auth para login/registro
- ✅ Requerir contraseña mínima 8 caracteres
- ✅ Validación de email único
- ❌ Rate limiting en intentos de login
- ❌ CAPTCHA después de X intentos fallidos
- ❌ Token refresh automático
- ❌ Detección de dispositivos sospechosos
- ❌ 2FA (Two Factor Authentication) - Futuro

**Implementaciones críticas:**
```dart
// Rate limiting en login
- Máximo 5 intentos por email en 15 minutos
- Bloquear cuenta temporalmente después de 5 fallos
- Requerir CAPTCHA después de 3 intentos fallidos
- Enviar notificación email si acceso desde dispositivo nuevo
```

#### 1.2 - Autorización

**Sistema de permisos:**
- Organizador: Control total del plan
- Coorganizador: Casi todo excepto eliminar plan/organizador
- Participante: Solo editar su parte personal
- Observador: Solo lectura
- Invitado: Sin permisos hasta aceptar

**Firestore Rules críticas:**
```javascript
// Solo usuarios autenticados pueden crear planes
match /plans/{planId} {
  allow create: if request.auth != null;
  allow read: if request.auth != null && 
    (resource.data.organizerId == request.auth.uid ||
     request.auth.uid in resource.data.participants);
  allow update: if request.auth != null && 
    (resource.data.organizerId == request.auth.uid ||
     resource.data.coorganizers[request.auth.uid] != null);
  allow delete: if request.auth != null && 
    resource.data.organizerId == request.auth.uid;
}

// Solo el propietario puede editar su perfil
match /users/{userId} {
  allow read: if request.auth != null;
  allow update, delete: if request.auth != null && 
    request.auth.uid == userId;
}
```

---

### 2. PROTECCIÓN DE DATOS SENSIBLES

#### 2.1 - Datos Personales

**Campos sensibles:**
- Email (visibilidad controlada)
- Teléfono (si se añade)
- Ubicación en tiempo real
- Foto de perfil
- Biografía

**Medidas:**
- ✅ Email no público por defecto
- ✅ Privacidad configurable por usuario
- ❌ Encriptación de datos sensibles en Firestore
- ❌ Logging sin datos sensibles
- ❌ No exponer emails en logs/errores

**Consideraciones:**
```dart
// NO hacer esto:
print('Email: ${user.email}'); // ❌
Logger.error('Error en ${user.email}'); // ❌

// Hacer esto:
print('User ID: ${user.userId}'); // ✅
Logger.error('Error en user ${user.userId.substring(0, 8)}...'); // ✅
```

#### 2.2 - Ubicaciones y Ubicación en Tiempo Real

**Riesgos:**
- Planes revelan ubicaciones futuras (riesgo seguridad física)
- Participantes expuestos a extraños
- Patrones de movimiento

**Medidas:**
- Visibilidad de planes configurable (público/privado)
- No compartir ubicación en tiempo real por defecto
- Opción de ocultar planes muy sensibles
- Advertencia al hacer plan público

#### 2.3 - Información Financiera (T101, T102)

**Datos sensibles:**
- Presupuestos de planes
- Pagos individuales
- Cuentas bancarias (si se añaden)
- Balance de usuario

**Medidas:**
- Solo visible para participantes del plan
- No compartir fuera del grupo
- Encriptación adicional de datos financieros
- Auditoría de cambios en presupuestos

---

### 3. SEGURIDAD EN COMUNICACIONES

#### 3.1 - Notificaciones (T105)

**Información sensible en notificaciones:**
- Datos del plan
- Ubicaciones de eventos
- Fechas exactas
- Nombres de participantes

**Medidas:**
- No incluir información sensible en título de notificación
- Contenido oculto hasta desbloquear
- Limitar información visible en notificaciones push

**Ejemplo:**
```
Buen (seguro):
"Tienes un nuevo evento mañana"
"Se ha añadido un participante al plan"

Mal (inseguro):
"Evento: Vuelo Madrid-Barcelona 15/11 a las 08:00"
"Juan se ha unido al plan 'Vacaciones'"
```

#### 3.2 - Invitaciones (T104)

**Riesgos:**
- Links de invitación comprometidos
- Acceso no autorizado si link divulgado
- Tokens sin expiración

**Medidas:**
- Expiración de links (máximo 7 días)
- Links únicos por invitación
- Verificar permisos del usuario antes de añadir
- Notificar al organizador si se añade usuario no invitado

#### 3.3 - Mensajes y Avisos

**Flujo FLUJO_INVITACIONES_NOTIFICACIONES:**
- No incluir datos sensibles en avisos públicos
- Validar que el remitente es participante
- Moderación de avisos (opcional)

---

### 4. SEGURIDAD EN PERSISTENCIA (Firestore)

#### 4.1 - Firestore Security Rules

**Reglas críticas ya implementadas:**
- Solo usuarios autenticados pueden crear/leer planes
- Solo organizador puede modificar/eliminar plan
- Solo el propio usuario puede editar su perfil

**Reglas adicionales necesarias:**
```javascript
// Evitar acceso no autorizado a eventos
match /plans/{planId}/events/{eventId} {
  allow read: if request.auth != null && 
    request.auth.uid in get(/databases/$(database)/documents/plans/$(planId)).data.participants;
  allow write: if request.auth != null && 
    (get(/databases/$(database)/documents/plans/$(planId)).data.organizerId == request.auth.uid ||
     get(/databases/$(database)/documents/plans/$(planId)).data.coorganizers[request.auth.uid] != null);
}

// Proteger datos de pagos
match /plans/{planId}/payments/{paymentId} {
  allow read: if request.auth != null && 
    (request.auth.uid == resource.data.userId ||
     request.auth.uid in get(/databases/$(database)/documents/plans/$(planId)).data.participants);
  allow write: if request.auth != null && 
    request.auth.uid == resource.data.userId;
}
```

#### 4.2 - Validación de Datos

**En el cliente (validaciones críticas):**
- Verificar permisos antes de mostrar UI
- Validar en cliente que acción está permitida
- Confirmación crítica para acciones destructivas

**En el servidor (Firestore Rules):**
- Validación de estructura de datos
- Validación de tipos
- Validación de permisos

---

### 5. PROTECCIÓN CONTRA ATAQUES

#### 5.1 - SQL Injection / NoSQL Injection

**Riesgo:** Firestore es NoSQL, pero igual de vulnerable

**Medidas:**
- ✅ No construir queries dinámicamente con strings de usuario
- ✅ Usar parámetros de Firestore siempre
- ✅ Validar inputs antes de queries

```dart
// Mal:
final query = Firestore.instance
  .collection('users')
  .where('name', isEqualTo: userInput); // ❌ Si userInput es malicioso

// Bien:
final query = Firestore.instance
  .collection('users')
  .where('name', isEqualTo: sanitize(userInput)); // ✅ Sanitizado
```

#### 5.2 - XSS (Cross-Site Scripting)

**Riesgo:** User input en avisos, biografías, nombres

**Medidas:**
- ✅ Sanitizar HTML en biografías/avisos
- ✅ Escapar HTML en display
- ❌ No permitir JavaScript en user input
- ❌ Validar formato de URL si se permite

```dart
// Sanitizar HTML de avisos
final sanitizedHtml = HtmlUnescape.convert(htmlText);
```

#### 5.3 - CSRF (Cross-Site Request Forgery)

**Riesgo:** Ataques desde sitios externos

**Medidas:**
- Firebase Auth incluye protección CSRF
- Verificar origin en requests (si aplica)
- Validar tokens de sesión

#### 5.4 - DoS (Denial of Service)

**Riesgo:** Usuario malicioso crea muchos planes

**Medidas:**
- Rate limiting (máximo N planes por usuario)
- Rate limiting en creación de eventos
- Detección de patrones sospechosos

**Implementación:**
```dart
// Rate limiting en creación de planes
- Máximo 50 planes por usuario
- Máximo 200 eventos por plan
- Alertar si se detecta creación masiva
```

---

### 6. PRIVACIDAD Y CUMPLIMIENTO

#### 6.1 - GDPR (si aplica)

**Requisitos:**
- Derecho al olvido (eliminar cuenta)
- Exportar datos personales
- Consentimiento explícito de términos
- Opción de opt-out de notificaciones

**Implementaciones:**
- ✅ Eliminación de cuenta (documentado en FLUJO_GESTION_USUARIOS)
- ❌ Export de datos (a implementar)
- ✅ Aceptación de términos al registro
- ✅ Opción de desactivar notificaciones

#### 6.2 - Logging y Auditoría

**Qué NO loguear:**
- ❌ Emails
- ❌ Contraseñas (nunca)
- ❌ Tokens completos
- ❌ Ubicaciones exactas

**Qué SÍ loguear:**
- ✅ User ID (hasheado)
- ✅ Timestamp de acciones críticas
- ✅ IP address (con máscara parcial)
- ✅ Dispositivo/browser
- ✅ Acciones de admin

**Ejemplo:**
```dart
// Mal:
Logger.info('User ${user.email} ha creado plan ${planId}');

// Bien:
Logger.info('User ${userId.substring(0, 8)}... ha creado plan ${planId}');
```

---

### 7. SEGURIDAD EN DESARROLLO

#### 7.1 - Secrets y Credenciales

**Nunca hardcodear:**
- ❌ API keys en código
- ❌ Passwords en código
- ❌ Tokens en código

**Usar:**
- ✅ Firebase config (automático)
- ✅ Environment variables
- ✅ `.env` files (gitignored)

#### 7.2 - Dependencias

**Medidas:**
- ✅ Usar solo packages verificados de pub.dev
- ✅ Mantener dependencias actualizadas
- ✅ Auditar dependencias regularmente (`flutter pub audit`)

**Implementación:**
```bash
# Verificar vulnerabilidades
flutter pub audit
```

#### 7.3 - Code Review

**Requisitos:**
- Revisar cambios relacionados con auth
- Revisar cambios en Firestore Rules
- Revisar cambios en validaciones de input
- Verificar que no se exponen datos sensibles

---

## 🛡️ CHECKLIST DE SEGURIDAD

**Por cada feature nueva, verificar:**

- [ ] ¿Se valida input del usuario?
- [ ] ¿Se verifican permisos antes de operaciones?
- [ ] ¿Se sanitizan datos antes de mostrar?
- [ ] ¿Hay logs sin datos sensibles?
- [ ] ¿Está protegido por Firestore Rules?
- [ ] ¿Se maneja errores sin exponer info sensible?
- [ ] ¿Se puede hacer rate limiting si aplica?
- [ ] ¿Multi-idioma aplica (evitar exposición)?
- [ ] ¿Multi-plataforma mantiene seguridad?

---

## 📋 TAREAS RELACIONADAS

**Pendientes:**
- T51: Validación de formularios
- T52: Gestión de permisos
- T53: Sistema de seguridad avanzado
- T65-T67: Permisos por rol
- Implementar rate limiting
- Implementar CAPTCHA
- Export de datos (GDPR)
- Implementar 2FA (futuro)

**Completas ✅:**
- Firebase Auth básico
- Firestore Security Rules básicas
- Validación de input básica

---

## ✅ IMPLEMENTACIÓN SUGERIDA

**Prioridad CRÍTICA:**
1. Completar Firestore Security Rules
2. Implementar rate limiting
3. Sanitizar HTML en user input
4. Export de datos personales
5. Auditoría de cambios críticos

**Archivos a crear/modificar:**
- `firestore.rules` - Completar reglas de seguridad
- `lib/features/security/services/rate_limiter.dart`
- `lib/features/security/services/data_export_service.dart`
- `lib/features/security/services/audit_log_service.dart`

---

*Documento de flujo de seguridad*  
*Última actualización: Enero 2025*

