# 🔧 Solucionar Emails de Invitación

## 📋 Problema

Los emails de registro funcionan, pero los emails de invitación NO se envían.

## 🔍 Diagnóstico

**Emails de registro:**
- ✅ Usan Firebase Auth nativo (`sendEmailVerification()`)
- ✅ Funcionan automáticamente sin configuración adicional

**Emails de invitación:**
- ❌ Requieren Cloud Function desplegada
- ❌ Requieren SendGrid configurado (API key)
- ❌ La función debe estar activa en Firebase

## ✅ Solución Paso a Paso

### Paso 1: Verificar si la función está desplegada

#### Opción A: Desde Firebase Console (Web)

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Functions** (en el menú lateral)
4. Busca `sendInvitationEmail`
5. Si **NO aparece** → la función NO está desplegada
6. Si **aparece** → verifica que esté activa (status: "Deployed")

#### Opción B: Desde Terminal (si tienes Firebase CLI)

```bash
# Ver funciones desplegadas
firebase functions:list

# Ver logs de la función
firebase functions:log --only sendInvitationEmail
```

### Paso 2: Configurar SendGrid

#### 2.1 Obtener API Key de SendGrid

1. Ve a [SendGrid](https://sendgrid.com)
2. Inicia sesión o crea una cuenta
3. Ve a **Settings** → **API Keys**
4. Crea una nueva API Key con permisos de "Mail Send"
5. **Copia la API key** (solo se muestra una vez)

#### 2.2 Configurar en Firebase

**Opción A: Desde Terminal (recomendado)**

```bash
# Configurar API key
firebase functions:config:set sendgrid.key="SG.xxxxx_TU_API_KEY_AQUI"

# Configurar email remitente
firebase functions:config:set sendgrid.from="noreply@planazoo.app"

# Configurar URL base de la app (para desarrollo local)
firebase functions:config:set app.base_url="http://localhost:60508"

# Para producción, usar:
# firebase functions:config:set app.base_url="https://planazoo.app"
```

**Opción B: Desde Firebase Console**

1. Ve a **Functions** → **Configuration**
2. Busca "Environment variables" o "Config"
3. Añade:
   - `sendgrid.key` = `SG.xxxxx_TU_API_KEY`
   - `sendgrid.from` = `noreply@planazoo.app`
   - `app.base_url` = `http://localhost:60508` (o tu URL de producción)

### Paso 3: Instalar dependencias y desplegar

```bash
# Desde la raíz del proyecto
cd functions
npm install
cd ..

# Desplegar la función
firebase deploy --only functions:sendInvitationEmail
```

**Si hay errores de lint:**

```bash
# Desplegar sin lint (solo para desarrollo)
firebase deploy --only functions:sendInvitationEmail --no-lint
```

### Paso 4: Verificar que funciona

#### 4.1 Crear una invitación de prueba

1. Desde la app, invita a un usuario por email
2. Verifica que el documento se crea en Firestore (`plan_invitations/{id}`)

#### 4.2 Verificar logs

**Desde Firebase Console:**
1. Ve a **Functions** → `sendInvitationEmail`
2. Ve a la pestaña **Logs**
3. Busca mensajes como:
   - ✅ `Invitation email sent successfully to...`
   - ❌ `SendGrid API key not configured`
   - ❌ `Error sending invitation email...`

**Desde Terminal:**
```bash
firebase functions:log --only sendInvitationEmail
```

#### 4.3 Verificar en SendGrid

1. Ve a [SendGrid Activity](https://app.sendgrid.com/email_activity)
2. Busca emails enviados a la dirección de prueba
3. Verifica que el email llegó correctamente

## 🐛 Troubleshooting

### Error: "SendGrid API key not configured"

**Solución:**
- Verifica que configuraste la API key en Firebase Functions config
- Asegúrate de haber desplegado después de configurar

### Error: "Plan not found"

**Solución:**
- Verifica que el `planId` en la invitación existe en Firestore
- Verifica permisos de lectura en Firestore rules

### Error: "Function not found" o función no desplegada

**Solución:**
1. Verifica que `functions/index.js` contiene `exports.sendInvitationEmail`
2. Instala dependencias: `cd functions && npm install`
3. Despliega: `firebase deploy --only functions`

### Los emails no llegan

**Verificar:**
1. ✅ La función se ejecuta (ver logs)
2. ✅ SendGrid tiene la API key configurada
3. ✅ El email remitente está verificado en SendGrid
4. ✅ Revisa la carpeta de spam
5. ✅ Verifica que el email destino es válido

## 📝 Notas Importantes

- **Desarrollo local:** Usa `http://localhost:60508` como `app.base_url`
- **Producción:** Usa `https://planazoo.app` como `app.base_url`
- **SendGrid Free Tier:** Permite 100 emails/día gratis
- **Verificación de dominio:** Recomendado para producción (evita spam)

## 🔄 Próximos Pasos

Una vez que funcione:
- [ ] Verificar que los emails llegan correctamente
- [ ] Probar el flujo completo (invitación → aceptar/rechazar)
- [ ] Configurar dominio verificado en SendGrid (producción)
- [ ] Añadir tracking de aperturas/clics (opcional)

---

*Última actualización: $(date)*
