# Firebase Functions para Planazoo

## 📧 Servicio de Emails de Invitación (T104)

Este directorio contiene las Cloud Functions de Firebase para enviar emails de invitación cuando se crea una invitación en Firestore.

## 🚀 Configuración

### 1. Instalar dependencias

```bash
cd functions
npm install
```

### 2. Configurar SendGrid

Obtén una API key de SendGrid desde [https://sendgrid.com](https://sendgrid.com)

#### Opción A: Configurar en Firebase Functions (recomendado)

```bash
firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"
firebase functions:config:set sendgrid.from="noreply@planazoo.app"
firebase functions:config:set app.base_url="https://app.planoon.com"
```

#### Opción B: Variables de entorno locales (para testing)

Crea un archivo `.env` en el directorio `functions/`:

```
SENDGRID_API_KEY=your_api_key_here
FROM_EMAIL=noreply@planazoo.app
APP_BASE_URL=https://app.planoon.com
```

### 3. Desplegar Functions

```bash
# Desde la raíz del proyecto
firebase deploy --only functions
```

### 4. Verificar logs

```bash
firebase functions:log
```

## 🔧 Funciones Implementadas

### `sendInvitationEmail`

**Trigger:** Se ejecuta automáticamente cuando se crea un documento en `plan_invitations/{invitationId}`.

**Qué hace:**
1. Verifica que la invitación tenga status `pending`
2. Obtiene información del plan y del organizador
3. Genera un email HTML con botones de "Aceptar" / "Rechazar"
4. Envía el email usando SendGrid
5. Maneja errores sin romper el flujo (la invitación ya está creada)

**Email incluye:**
- Nombre del plan
- Nombre del organizador
- Mensaje personalizado (si existe)
- Botones de acción (Aceptar/Rechazar)
- Link alternativo
- Fecha de expiración
- Template HTML responsive

## 🧪 Testing Local

### Usar Emulator

```bash
# Iniciar emulador
npm run serve

# En otra terminal, crear una invitación en Firestore emulator
# La función se ejecutará automáticamente
```

### Testing Manual

Puedes probar la función manualmente usando el shell de Firebase:

```bash
npm run shell
```

## 📝 Notas

- Si SendGrid no está configurado, la función registrará un warning pero no fallará
- Los emails incluyen un template HTML responsive
- Los links incluyen parámetros `?action=accept` o `?action=reject` (opcional, la página puede procesarlos)
- La función no falla si no puede obtener información del plan/organizador (usa valores por defecto)

## 🔐 Seguridad

- La API key de SendGrid debe estar configurada como secret en Firebase Functions
- No incluyas la API key en el código fuente
- Usa variables de entorno o Firebase Functions config


