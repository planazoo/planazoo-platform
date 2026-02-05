# 📧 Enviar Emails de Invitación con Gmail SMTP (Solo Google)

## 📋 Resumen

Solución alternativa para enviar emails de invitación usando **Gmail SMTP** en lugar de SendGrid, manteniendo todo dentro del ecosistema de Google.

## ✅ Ventajas

- ✅ **100% Google**: Usa solo servicios de Google
- ✅ **Sin servicios externos**: No necesitas SendGrid ni otras APIs
- ✅ **Gratis**: Gmail permite hasta 500 emails/día
- ✅ **Simple**: Configuración más sencilla que Gmail API
- ✅ **Integrado**: Funciona directamente con Firebase Functions

## 🔧 Configuración

### Paso 1: Crear App Password de Gmail

1. Ve a tu cuenta de Google: [myaccount.google.com](https://myaccount.google.com)
2. Ve a **Seguridad**
3. Activa la **Verificación en 2 pasos** (requerido para App Passwords)
4. Ve a **Contraseñas de aplicaciones**
5. Genera una nueva contraseña para "Correo" y "Otro (personalizado)" → "Firebase Functions"
6. **Copia la contraseña generada** (16 caracteres, sin espacios)

### Paso 2: Configurar en Firebase Functions

```bash
# Configurar email de Gmail
firebase functions:config:set gmail.user="tu-email@gmail.com"
firebase functions:config:set gmail.password="xxxx xxxx xxxx xxxx"  # App Password (16 caracteres)

# Configurar email remitente (puede ser el mismo)
firebase functions:config:set gmail.from="tu-email@gmail.com"

# Configurar URL base de la app
firebase functions:config:set app.base_url="http://localhost:60508"  # Desarrollo
# firebase functions:config:set app.base_url="https://planazoo.app"  # Producción
```

### Paso 3: Actualizar código de la función

El código ya está actualizado para usar `nodemailer` con Gmail SMTP en lugar de SendGrid.

### Paso 4: Instalar dependencias y desplegar

```bash
cd functions
npm install
cd ..
firebase deploy --only functions:sendInvitationEmail
```

## 📊 Límites de Gmail

- **Gratis**: 500 emails/día
- **Google Workspace**: 2,000 emails/día (plan básico)
- **Rate limiting**: Máximo 100 emails por minuto

## ⚠️ Consideraciones

### Seguridad

- ✅ Usa **App Password** (no tu contraseña normal)
- ✅ La App Password se almacena encriptada en Firebase Functions config
- ✅ Puedes revocar la App Password en cualquier momento

### Límites

- ⚠️ Si necesitas más de 500 emails/día, considera:
  - Actualizar a Google Workspace
  - Usar Gmail API (más complejo pero más flexible)
  - Usar Cloud Identity API (para invitaciones de usuarios)

### Producción

Para producción, considera:
- Usar un email dedicado (ej: `noreply@tudominio.com`)
- Configurar SPF/DKIM en tu dominio
- Usar Google Workspace para mejor deliverability

## 🔄 Migración desde SendGrid

Si ya tenías SendGrid configurado:

1. El código detecta automáticamente si hay configuración de Gmail
2. Si hay Gmail configurado, usa Gmail SMTP
3. Si no hay Gmail pero hay SendGrid, usa SendGrid (backward compatible)
4. Si no hay ninguno, muestra warning en logs

## 🧪 Testing

```bash
# Ver logs en tiempo real
firebase functions:log --only sendInvitationEmail

# Crear una invitación de prueba desde la app
# Verificar que el email llega correctamente
```

## 📝 Notas

- **Desarrollo**: Usa `http://localhost:60508` como `app.base_url`
- **Producción**: Usa `https://planazoo.app` como `app.base_url`
- **App Password**: Se genera una vez, cópiala bien (solo se muestra una vez)

---

*Implementado como alternativa a SendGrid para mantener todo en el ecosistema Google*
