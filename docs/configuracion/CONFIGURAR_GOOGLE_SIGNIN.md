# 🔐 Guía de Configuración: Google Sign-In en Firebase

> Guía paso a paso para habilitar Google Sign-In en Firebase Console

**Relacionado con:** T164 - Login con Google  
**Fecha:** Enero 2025

---

## 📋 Requisitos Previos

- ✅ Proyecto Firebase creado
- ✅ Firebase Authentication habilitado
- ✅ `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) configurados
- ✅ Dependencia `google_sign_in` añadida a `pubspec.yaml`

---

## 🚀 Pasos de Configuración

### 1. Habilitar Google como Proveedor de Autenticación

1. **Ir a Firebase Console:**
   - Abre [Firebase Console](https://console.firebase.google.com/)
   - Selecciona tu proyecto (`planazoo`)

2. **Navegar a Authentication:**
   - En el menú lateral, haz clic en **"Authentication"**
   - Haz clic en la pestaña **"Sign-in method"**

3. **Habilitar Google:**
   - En la lista de proveedores, busca **"Google"**
   - Haz clic en **"Google"**
   - Activa el toggle **"Enable"**
   - **Email de soporte del proyecto:** Ingresa un email válido (puede ser el mismo del proyecto)
   - Haz clic en **"Save"**

✅ **Google Sign-In está ahora habilitado en Firebase**

---

### 2. Configurar Client ID para Web

**⚠️ IMPORTANTE:** Si tu app se ejecuta en web, necesitas configurar el Client ID. **Sin esto, la app fallará al iniciar en web.**

1. En la configuración de Google Sign-In, haz clic en **"Web SDK configuration"**
2. **Copia el "Web client ID"** (formato: `XXXXX-XXXXX.apps.googleusercontent.com`)
3. **Descomenta y actualiza el meta tag en `web/index.html`:**
   ```html
   <!-- Busca esta línea (está comentada): -->
   <!-- <meta name="google-signin-client_id" content="TU_CLIENT_ID_AQUI.apps.googleusercontent.com"> -->
   
   <!-- Descoméntala y reemplaza TU_CLIENT_ID_AQUI con tu Client ID real: -->
   <meta name="google-signin-client_id" content="794752310537-XXXXXXXXXX.apps.googleusercontent.com">
   ```
4. **Opcional:** Añade tus dominios autorizados (ej: `localhost`, `tu-dominio.com`)
5. Guarda los cambios

**Ubicación del archivo:** `web/index.html` (en la sección `<head>`, línea ~29)

**⚠️ NOTA:** Si no configuras el Client ID, la app fallará al iniciar en web con el error: "ClientID not set"

---

### 3. Verificación de Configuración

Para verificar que todo está configurado correctamente:

1. **En Firebase Console:**
   - Ve a **Authentication > Sign-in method**
   - Verifica que **Google** aparece como **"Enabled"** (verde)

2. **En la App:**
   - Ejecuta la app
   - Ve a la pantalla de login
   - Deberías ver el botón **"Continuar con Google"**
   - Al hacer clic, debería abrirse el selector de cuenta de Google

---

## ⚠️ Notas Importantes

### Android

- **SHA-1 Fingerprint:** Asegúrate de que el SHA-1 de tu app está configurado en Firebase Console
  - Ve a **Project Settings > Your apps > Android app**
  - Añade el SHA-1 fingerprint si no está presente
  - Descarga el `google-services.json` actualizado

### iOS

- **URL Scheme:** El `GoogleService-Info.plist` ya contiene la configuración necesaria
- **Info.plist:** No se requiere configuración adicional en `Info.plist` para Google Sign-In

### Web

- **Dominios autorizados:** Asegúrate de añadir tus dominios en la configuración de Google Sign-In
- **OAuth consent screen:** Si es necesario, configura la pantalla de consentimiento en Google Cloud Console

---

## 🧪 Testing

Después de configurar, prueba:

1. **Login con Google (nuevo usuario):**
   - Usa una cuenta de Google que NO esté registrada
   - Verifica que se crea el usuario en Firestore
   - Verifica que se genera un username automático

2. **Login con Google (usuario existente):**
   - Usa una cuenta de Google que YA esté registrada
   - Verifica que el login funciona correctamente

3. **Cancelación:**
   - Cancela el selector de cuenta
   - Verifica que no se muestra error

---

## 📚 Referencias

- [Firebase Auth - Google Sign-In](https://firebase.google.com/docs/auth/flutter/federated-auth#google)
- [google_sign_in package](https://pub.dev/packages/google_sign_in)
- [Firebase Console](https://console.firebase.google.com/)

---

**Última actualización:** Enero 2025  
**Versión:** 1.0

