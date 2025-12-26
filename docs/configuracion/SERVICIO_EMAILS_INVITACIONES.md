# 📧 Servicio de Emails de Invitaciones (T104)

## 📋 Resumen

Sistema de envío automático de emails cuando se crea una invitación a un plan. Implementado con Firebase Cloud Functions y SendGrid.

## 🏗️ Arquitectura

```
Usuario invita por email
  ↓
InvitationService.createInvitation()
  ↓
Firestore: plan_invitations/{id} creado
  ↓
Cloud Function: sendInvitationEmail (trigger onCreate)
  ↓
SendGrid API → Email enviado
  ↓
Usuario recibe email con botones "Aceptar" / "Rechazar"
```

## 📁 Archivos

- **`functions/index.js`**: Cloud Function que se ejecuta cuando se crea una invitación
- **`functions/package.json`**: Dependencias (SendGrid, Firebase Functions)
- **`lib/features/calendar/domain/services/invitation_service.dart`**: Servicio Flutter (ya crea invitaciones)

## 🔧 Configuración

### 1. SendGrid Setup

1. Crear cuenta en [SendGrid](https://sendgrid.com)
2. Generar API Key con permisos de envío
3. Verificar dominio (opcional pero recomendado)

### 2. Configurar Firebase Functions

```bash
# Configurar API key
firebase functions:config:set sendgrid.key="SG.xxxxx"

# Configurar email remitente
firebase functions:config:set sendgrid.from="noreply@planazoo.app"

# Configurar URL base de la app
firebase functions:config:set app.base_url="https://planazoo.app"
```

### 3. Desplegar

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

## 📧 Template de Email

El email incluye:
- ✅ Nombre del plan
- ✅ Nombre del organizador
- ✅ Mensaje personalizado (opcional)
- ✅ Botones "Aceptar" / "Rechazar"
- ✅ Link alternativo
- ✅ Fecha de expiración
- ✅ Template HTML responsive

## 🔄 Flujo Completo

1. **Usuario invita por email** (en `pg_plan_participants_page.dart`)
   - Se llama a `inviteUserToPlan(email)`
   - `InvitationService.createInvitation()` crea el documento en Firestore

2. **Cloud Function se activa**
   - Detecta creación en `plan_invitations/{id}`
   - Obtiene datos del plan y organizador
   - Genera HTML del email
   - Envía email vía SendGrid

3. **Usuario recibe email**
   - Ve botones de acción
   - Hace clic en "Aceptar" o "Rechazar"
   - Se abre `/invitation/{token}`
   - `InvitationPage` procesa la acción

## ⚠️ Manejo de Errores

- Si SendGrid no está configurado: warning en logs, no falla
- Si el plan no existe: error en logs, no envía email
- Si SendGrid falla: error en logs, no falla la función (invitación ya está creada)

## 🔐 Seguridad

- API Key almacenada en Firebase Functions config (encriptado)
- Emails validados por SendGrid (dominio verificado)
- Links con tokens únicos y expiración (7 días)

## 📊 Monitoreo

```bash
# Ver logs en tiempo real
firebase functions:log --only sendInvitationEmail

# Ver métricas en Firebase Console
# Functions → sendInvitationEmail → Monitoring
```

## 🧪 Testing

### Testing Local con Emulator

```bash
# Terminal 1: Iniciar emulador
firebase emulators:start --only functions,firestore

# Terminal 2: Crear invitación de prueba en Firestore emulator
# La función se ejecutará automáticamente
```

### Testing Manual

1. Crear invitación desde la app
2. Verificar que el documento se crea en Firestore
3. Verificar logs de Firebase Functions
4. Revisar email en SendGrid Activity (si está configurado)

## 🔄 Próximos Pasos (Opcional)

- [ ] Añadir tracking de aperturas/clics (SendGrid)
- [ ] Añadir recordatorios automáticos (después de 2 días sin respuesta)
- [ ] Soporte para múltiples idiomas en emails
- [ ] A/B testing de templates de email
- [ ] Estadísticas de tasa de aceptación

---

*Implementado en T104 - Sistema de Invitaciones a Planes*


