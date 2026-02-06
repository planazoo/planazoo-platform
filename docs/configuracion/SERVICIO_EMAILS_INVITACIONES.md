# 📧 Servicio de Emails de Invitaciones (T104)

## 📋 Resumen

Sistema de envío automático de emails cuando se crea una invitación a un plan. Implementado con Firebase Cloud Functions.

**⚠️ IMPORTANTE:** Este servicio ahora usa **Gmail SMTP** (solo Google). Para configuración detallada, ver **[EMAILS_CON_GMAIL_SMTP.md](./EMAILS_CON_GMAIL_SMTP.md)**.

**Nota histórica:** Anteriormente se usaba SendGrid, pero se migró a Gmail SMTP para mantener todo en el ecosistema Google. El código mantiene compatibilidad con SendGrid como fallback.

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

**👉 Ver guía completa:** [EMAILS_CON_GMAIL_SMTP.md](./EMAILS_CON_GMAIL_SMTP.md)

### Resumen Rápido

1. **Crear App Password de Gmail** (requiere verificación en 2 pasos)
2. **Configurar Firebase Functions** con credenciales de Gmail
3. **Desplegar Cloud Function**

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
   - Envía email vía Gmail SMTP (o SendGrid como fallback si Gmail no está configurado)

3. **Usuario recibe email**
   - Ve botones de acción
   - Hace clic en "Aceptar" o "Rechazar"
   - Se abre `/invitation/{token}`
   - `InvitationPage` procesa la acción

## ⚠️ Manejo de Errores

- Si Gmail SMTP no está configurado: intenta usar SendGrid como fallback
- Si SendGrid tampoco está configurado: warning en logs, no falla
- Si el plan no existe: error en logs, no envía email
- Si el servicio de email falla: error en logs, no falla la función (invitación ya está creada)

## 🔐 Seguridad

- App Password de Gmail almacenada en Firebase Functions config (encriptado)
- Links con tokens únicos y expiración (7 días)
- Verificación de email del usuario antes de aceptar invitación

## 📊 Monitoreo

```bash
# Ver logs en tiempo real
npx firebase-tools functions:log --only sendInvitationEmail

# Ver métricas en Firebase Console
# Functions → sendInvitationEmail → Monitoring
```

## 🧪 Testing

1. Crear invitación desde la app
2. Verificar que el documento se crea en Firestore
3. Verificar logs de Firebase Functions (debería mostrar "Gmail SMTP" o "SendGrid")
4. Revisar bandeja de entrada del email destino

## 🔄 Próximos Pasos (Opcional)

- [ ] Añadir recordatorios automáticos (después de 2 días sin respuesta)
- [ ] Soporte para múltiples idiomas en emails
- [ ] Estadísticas de tasa de aceptación

---

## 📚 Documentación Relacionada

- **[EMAILS_CON_GMAIL_SMTP.md](./EMAILS_CON_GMAIL_SMTP.md)** - Guía completa de configuración de Gmail SMTP
- **[GUIA_PASO_A_PASO_GMAIL_EN.md](./GUIA_PASO_A_PASO_GMAIL_EN.md)** - Guía en inglés

---

*Implementado en T104 - Sistema de Invitaciones a Planes*  
*Migrado a Gmail SMTP para mantener todo en el ecosistema Google*


