# ⚖️ Guía de Aspectos Legales

> Guía de referencia de aspectos legales y cumplimiento normativo de la plataforma

**Relacionado con:** T50, GDPR, Terms of Service, Privacy Policy  
**Versión:** 1.0  
**Fecha:** Enero 2025

---

## 🎯 Objetivo

Esta guía de referencia documenta todos los aspectos legales que deben tenerse en cuenta durante el desarrollo y funcionamiento de la plataforma. Debe ser consultada **antes del lanzamiento de la versión pública**.

---

## 📋 ÁREAS LEGALES

### 1. TÉRMINOS Y CONDICIONES

#### 1.1 - Contenido Requerido

**Elementos obligatorios:**
- Descripción del servicio
- Edad mínima (13+ recomendado por COPPA)
- Responsabilidades del usuario
- Uso aceptable y restricciones
- Terminación de cuenta
- Limitación de responsabilidad
- Cambios en términos
- Jurisdicción aplicable

**Flujo de aceptación:**
- Usuario DEBE aceptar términos al registrarse
- Checkbox obligatorio "He leído y acepto los Términos y Condiciones"
- Guardar timestamp de aceptación
- Permitir re-ver los términos en cualquier momento
- Notificar cambios importantes en términos

**Persistencia:**
```dart
// En User model
final Map<String, dynamic>? termsAcceptance = {
  'acceptedAt': DateTime.now(),
  'version': '1.0',
  'hash': 'unique_hash',
  'accepted': true
}
```

#### 1.2 - Actualización de Términos

**Cuando actualizar:**
- Cambios significativos en el servicio
- Cambios en políticas de privacidad
- Cambios legales o normativos

**Proceso:**
```
Actualizar términos
  ↓
Incrementar versión (1.0 → 1.1)
  ↓
Notificar a todos los usuarios por email:
"Actualizamos nuestros Términos y Condiciones

Por favor, revisa y acepta la nueva versión al iniciar sesión.

Link: [Ver nuevos términos]"
  ↓
Requiere aceptar nueva versión antes de usar app
  ↓
Mostrar diferencias entre versiones (opcional)
```

---

### 2. POLÍTICA DE PRIVACIDAD

#### 2.1 - Datos Recopilados

**Datos personales:**
- Email, nombre, username
- Foto de perfil (opcional)
- Ubicación (si se usa GPS)
- Información de planes (fechas, participantes, eventos)

**Datos de uso:**
- Dispositivo, browser, IP (máscara parcial)
- Acciones en la app (logs)
- Preferencias de configuración

#### 2.2 - Uso de Datos

**Declarar:**
- Para qué se usan los datos
- Con quién se comparten (solo entre participantes del plan)
- Por cuánto tiempo se guardan
- Cómo ejercer derechos (acceso, rectificación, eliminación, portabilidad)

#### 2.3 - Derechos del Usuario

**GDPR (si aplica en UE):**
- ✅ Derecho de acceso
- ✅ Derecho de rectificación
- ✅ Derecho de supresión ("derecho al olvido")
- ✅ Derecho a la portabilidad de datos (T129)
- ✅ Derecho de oposición
- ✅ Derecho a limitar el tratamiento

**Implementación:**
```dart
// T129 - Export de datos
Usuario → Configuración → "Exportar mis datos"
  ↓
Generar archivo JSON con todos los datos del usuario
  ↓
Descargar o enviar por email
```

---

### 3. POLÍTICA DE SEGURIDAD

#### 3.1 - Medidas de Seguridad

**Declarar:**
- Encriptación de datos en tránsito (HTTPS)
- Encriptación de datos en reposo (Firebase)
- Autenticación de usuarios (Firebase Auth)
- Permisos y roles
- Backups regulares

#### 3.2 - Gestión de Incidentes

**Procedimiento:**
- Detectar brecha de seguridad
- Evaluar impacto
- Notificar a usuarios afectados (dentro de 72h si GDPR)
- Rectificar vulnerabilidad
- Documentar incidente

**Documento a crear:** `SECURITY_BREACH_PROCEDURE.md`

---

### 4. POLÍTICA DE COOKIES

#### 4.1 - Tipos de Cookies (si aplica)

**Cookies estrictamente necesarias:**
- Sesión de usuario
- Preferencias de idioma
- Estado de login

**Cookies de terceros (si se usan):**
- Analytics (Google Analytics, Firebase Analytics)
- Maps (Google Maps)

**Implementación:**
```
Usuario visita app por primera vez
  ↓
Modal: "Uso de Cookies

Esta app usa cookies necesarias para funcionar.
¿Aceptas el uso de cookies?

Ver política de cookies
[Rechazar] [Aceptar]"
  ↓
Guardar preferencia
```

#### 4.2 - Gestión de Cookies

**Panel de gestión:**
- Ver qué cookies se usan
- Activar/desactivar por categoría
- Opt-out completo (funcionalidad limitada)

---

### 5. POLÍTICA DE USO ACEPTABLE

#### 5.1 - Conducta Permitida

**Usuarios pueden:**
- Crear planes personales o grupales
- Invitar a otros usuarios
- Compartir planes con participantes
- Participar en eventos

#### 5.2 - Conducta Prohibida

**Prohibido:**
- Spam o mensajes no solicitados
- Contenido ilegal o ofensivo
- Acoso o bullying a otros usuarios
- Suplantación de identidad
- Usar datos de otros usuarios sin permiso
- Intentar acceder no autorizado a datos
- Actividades que dañen la plataforma

#### 5.3 - Consecuencias

**Acciones del administrador:**
- Advertencia
- Suspensión temporal (T125-T129)
- Eliminación permanente de cuenta
- Reporte a autoridades (si aplica)

---

### 6. CUMPLIMIENTO NORMATIVO

#### 6.1 - GDPR (General Data Protection Regulation)

**Aplicable si:**
- Usuarios en UE/EEA
- Empresa con presencia en UE

**Requisitos:**
- ✅ Consentimiento explícito para cookies
- ✅ Aviso de privacidad claro
- ✅ Export de datos (T129)
- ✅ Derecho al olvido (eliminación de cuenta)
- ✅ Notificación de brechas de seguridad (<72h)
- ⚠️ Data Protection Officer (DPO) - solo si procesamiento a gran escala

#### 6.2 - COPPA (Children's Online Privacy Protection Act)

**Aplicable si:**
- Usuarios menores de 13 años en EE.UU.

**Requisitos:**
- Verificación de edad mínima
- Consentimiento parental para menores de 13
- Política de privacidad específica
- No recopilar datos innecesarios de menores

**Implementación actual:**
```
Registro requiere edad mínima 13 años
No verificación activa (trust-based)
```

#### 6.3 - DMCA (Digital Millennium Copyright Act)

**Aplicable si:**
- Usuarios suben contenido con derechos de autor
- Contenido de terceros (fotos, videos)

**Requisitos:**
- Processo de reporte de contenido protegido
- Contacto para reportes DMCA
- Remoción de contenido tras verificación

---

## 📄 DOCUMENTOS A CREAR

### 1. Terms of Service (Términos y Condiciones)

**Ubicación:** `docs/legal/terms_of_service.md`  
**Versión:** 1.0  
**Fecha:** Enero 2025

**Contenido:**
- Sección 1: Definiciones
- Sección 2: Servicio ofrecido
- Sección 3: Uso aceptable
- Sección 4: Cuenta de usuario
- Sección 5: Propiedad intelectual
- Sección 6: Limitación de responsabilidad
- Sección 7: Terminación
- Sección 8: Cambios en términos
- Sección 9: Jurisdicción

### 2. Privacy Policy (Política de Privacidad)

**Ubicación:** `docs/legal/privacy_policy.md`  
**Versión:** 1.0  
**Fecha:** Enero 2025

**Contenido:**
- Qué datos recopilamos
- Cómo usamos los datos
- Con quién compartimos datos
- Retención de datos
- Seguridad de datos
- Derechos del usuario (GDPR)
- Cookies
- Cambios en política
- Contacto

### 3. Security Policy (Política de Seguridad)

**Ubicación:** `docs/legal/security_policy.md`  
**Versión:** 1.0  
**Fecha:** Enero 2025

**Contenido:**
- Medidas de seguridad implementadas
- Encriptación de datos
- Gestión de accesos
- Gestión de incidentes
- Reporte de vulnerabilidades
- Contacto de seguridad

### 4. Cookie Policy (Política de Cookies)

**Ubicación:** `docs/legal/cookie_policy.md`  
**Versión:** 1.0  
**Fecha:** Enero 2025

**Contenido:**
- Qué son las cookies
- Qué cookies usamos
- Gestión de cookies
- Enlaces de terceros

---

## 🔗 IMPLEMENTACIÓN EN LA APP

### Links en Footer

```
[Inicio] [Planes] [Perfil] [Configuración]

Copyright © 2025 Planazoo

[Terms of Service] [Privacy Policy] [Security Policy] [Cookie Policy]
```

### Páginas Legales

**Crear páginas:**
- `/legal/terms` - Términos y Condiciones
- `/legal/privacy` - Política de Privacidad
- `/legal/security` - Política de Seguridad
- `/legal/cookies` - Política de Cookies

**Características:**
- Versión del documento visible
- Fecha de última actualización
- Historial de versiones (opcional)
- Imprimir/Exportar PDF

---

## ✅ CHECKLIST PRE-LANZAMIENTO

- [ ] Crear Terms of Service completo
- [ ] Crear Privacy Policy completo
- [ ] Crear Security Policy completo
- [ ] Crear Cookie Policy completo (si aplica)
- [ ] Implementar modal de aceptación de términos en registro
- [ ] Implementar modal de consentimiento de cookies
- [ ] Añadir links a documentos legales en footer
- [ ] Crear páginas legales en la app
- [ ] Verificar cumplimiento GDPR
- [ ] Verificar cumplimiento COPPA
- [ ] Revisar con abogado (recomendado)
- [ ] Export de datos funcional (T129)
- [ ] Eliminación de cuenta funcional
- [ ] Notificación de brechas preparada

---

## 📋 TAREAS RELACIONADAS

**Pendientes:**
- T129: Export de Datos Personales (GDPR)
- T50: Configuración de preferencias
- T171: Crear Documentos Legales (Términos, Privacidad, etc.)
- Implementar modales de consentimiento

**Completas ✅:**
- Aceptación de términos en registro (estructurado en flujos)

---

## ⚠️ NOTA IMPORTANTE

Esta guía es una **referencia de desarrollo**. Para aspectos legales reales y cumplimiento normativo específico, **se debe consultar con un abogado especializado** antes del lanzamiento público.

---

*Documento de guía de aspectos legales*  
*Última actualización: Febrero 2026*

