# 📧 Guía Paso a Paso: Configurar Gmail SMTP para Invitaciones

## 🎯 Objetivo

Configurar el envío de emails de invitación usando **solo servicios de Google** (Gmail SMTP).

---

## 📋 Paso 1: Crear App Password de Gmail

### 1.1 Ir a tu cuenta de Google

1. Abre tu navegador y ve a: [myaccount.google.com](https://myaccount.google.com)
2. Inicia sesión con tu cuenta de Gmail

### 1.2 Activar Verificación en 2 Pasos (requerido)

1. En el menú lateral izquierdo, haz clic en **"Seguridad"**
2. Busca la sección **"Cómo iniciar sesión en Google"**
3. Busca **"Verificación en 2 pasos"**
4. Si está **desactivada**:
   - Haz clic en **"Verificación en 2 pasos"**
   - Sigue las instrucciones para activarla
   - Necesitarás tu teléfono para verificar
5. Si ya está **activada**, continúa al siguiente paso

### 1.3 Generar App Password

1. En la misma página de **"Seguridad"**, busca **"Contraseñas de aplicaciones"**
   - Si no la ves, haz clic en **"Verificación en 2 pasos"** y luego busca el enlace
2. Haz clic en **"Contraseñas de aplicaciones"**
3. Se abrirá una nueva página
4. En **"Seleccionar app"**, elige: **"Correo"**
5. En **"Seleccionar dispositivo"**, elige: **"Otro (nombre personalizado)"**
6. Escribe: **"Firebase Functions"**
7. Haz clic en **"Generar"**
8. **¡IMPORTANTE!** Copia la contraseña que aparece (16 caracteres, formato: `xxxx xxxx xxxx xxxx`)
   - ⚠️ **Solo se muestra una vez**, guárdala bien
   - Ejemplo: `abcd efgh ijkl mnop`

---

## 📋 Paso 2: Configurar Firebase Functions

### 2.1 Abrir Terminal

Abre tu terminal y navega al proyecto:

```bash
cd /Users/emmclaraso/development/unp_calendario
```

### 2.2 Verificar que Firebase CLI está instalado

```bash
firebase --version
```

Si no está instalado:
```bash
npm install -g firebase-tools
firebase login
```

### 2.3 Configurar Gmail en Firebase Functions

Ejecuta estos comandos **uno por uno**, reemplazando con tus datos:

```bash
# 1. Configurar tu email de Gmail
firebase functions:config:set gmail.user="TU_EMAIL@gmail.com"

# 2. Configurar la App Password (sin espacios, o con espacios, ambos funcionan)
firebase functions:config:set gmail.password="xxxx xxxx xxxx xxxx"

# 3. Configurar email remitente (puede ser el mismo)
firebase functions:config:set gmail.from="TU_EMAIL@gmail.com"

# 4. Configurar URL base para desarrollo local
firebase functions:config:set app.base_url="http://localhost:60508"
```

**Ejemplo real:**
```bash
firebase functions:config:set gmail.user="unplanazoo+admin@gmail.com"
firebase functions:config:set gmail.password="abcd efgh ijkl mnop"
firebase functions:config:set gmail.from="unplanazoo+admin@gmail.com"
firebase functions:config:set app.base_url="http://localhost:60508"
```

### 2.4 Verificar la configuración

```bash
firebase functions:config:get
```

Deberías ver algo como:
```
{
  "gmail": {
    "user": "tu-email@gmail.com",
    "password": "xxxx xxxx xxxx xxxx",
    "from": "tu-email@gmail.com"
  },
  "app": {
    "base_url": "http://localhost:60508"
  }
}
```

---

## 📋 Paso 3: Instalar Dependencias

### 3.1 Instalar nodemailer

```bash
cd functions
npm install
```

Esto instalará `nodemailer` y todas las dependencias necesarias.

### 3.2 Verificar que se instaló correctamente

```bash
npm list nodemailer
```

Deberías ver: `nodemailer@6.9.7` (o versión similar)

---

## 📋 Paso 4: Desplegar la Cloud Function

### 4.1 Volver a la raíz del proyecto

```bash
cd ..
```

### 4.2 Desplegar solo la función de emails

```bash
firebase deploy --only functions:sendInvitationEmail
```

**Si hay errores de lint**, puedes saltarlos temporalmente:
```bash
firebase deploy --only functions:sendInvitationEmail --no-lint
```

### 4.3 Verificar que se desplegó correctamente

Deberías ver un mensaje como:
```
✔  functions[sendInvitationEmail(us-central1)] Successful create operation.
```

---

## 📋 Paso 5: Probar el Envío de Emails

### 5.1 Crear una invitación de prueba

1. Abre tu app en el navegador
2. Ve a un plan
3. Ve a la sección de **Participantes**
4. Haz clic en **"Invitar por email"**
5. Ingresa un email de prueba (puede ser otro email tuyo)
6. Envía la invitación

### 5.2 Verificar logs

En otra terminal, ejecuta:

```bash
firebase functions:log --only sendInvitationEmail
```

Deberías ver mensajes como:
```
✅ Gmail SMTP configurado correctamente
✅ Invitation email sent via Gmail SMTP to tu-email@ejemplo.com
```

### 5.3 Verificar que llegó el email

1. Revisa la bandeja de entrada del email que usaste
2. Si no está, revisa la carpeta de **Spam**
3. El email debería tener:
   - Asunto: "Invitación a [Nombre del Plan] en Planazoo"
   - Botones de "Aceptar" y "Rechazar"
   - Link de invitación

---

## 🐛 Solución de Problemas

### Error: "Gmail SMTP configurado correctamente" pero no llegan emails

**Solución:**
1. Verifica que la App Password es correcta (16 caracteres)
2. Verifica que el email de Gmail está bien escrito
3. Revisa la carpeta de Spam
4. Verifica los logs: `firebase functions:log --only sendInvitationEmail`

### Error: "No hay servicio de email configurado"

**Solución:**
1. Verifica la configuración: `firebase functions:config:get`
2. Asegúrate de haber ejecutado todos los comandos de configuración
3. Vuelve a desplegar: `firebase deploy --only functions:sendInvitationEmail`

### Error: "Authentication failed"

**Solución:**
1. Verifica que la App Password es correcta (sin espacios extra)
2. Asegúrate de haber activado la verificación en 2 pasos
3. Genera una nueva App Password si es necesario

### Error: "Function not found"

**Solución:**
1. Verifica que estás en el directorio correcto
2. Despliega la función: `firebase deploy --only functions:sendInvitationEmail`
3. Verifica en Firebase Console → Functions que aparece `sendInvitationEmail`

---

## ✅ Checklist Final

- [ ] Verificación en 2 pasos activada
- [ ] App Password generada y copiada
- [ ] Configuración de Firebase Functions completada
- [ ] `nodemailer` instalado en `functions/`
- [ ] Cloud Function desplegada
- [ ] Invitación de prueba creada
- [ ] Email recibido correctamente
- [ ] Logs muestran "Gmail SMTP" (no SendGrid)

---

## 📝 Notas Importantes

- **App Password**: Solo se muestra una vez, guárdala bien
- **Límites Gmail**: 500 emails/día (gratis), 2,000/día (Google Workspace)
- **Desarrollo**: Usa `http://localhost:60508` como `app.base_url`
- **Producción**: Cambia a `https://planazoo.app` cuando despliegues a producción

---

## 🎉 ¡Listo!

Si has completado todos los pasos y recibes el email de invitación, **¡está funcionando!** 

Ahora todos los emails de invitación se envían usando **solo servicios de Google** (Gmail SMTP).

---

*Última actualización: $(date)*
