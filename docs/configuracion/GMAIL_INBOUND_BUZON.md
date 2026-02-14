# Recepción de correos (buzón) con Gmail API

> Configuración para que la plataforma lea el buzón con Gmail API (recepción 100% Google).  
> Relacionado: `docs/producto/CORREO_EVENTOS_SISTEMA_PARSEO.md`, Cloud Function `processInboundGmail`.

**Buzón actual:** `unplanzoo+eventos@gmail.com` (los usuarios reenvían sus confirmaciones a esta dirección).

## Requisitos

- Un buzón Gmail o **Google Workspace** (actual: `unplanzoo+eventos@gmail.com`). Los usuarios reenvían ahí sus confirmaciones.
- **Autenticación:**  
  - **Si el buzón es Google Workspace** (ej. `eventos@tudominio.com`): **Domain-wide delegation** con una Service Account que impersona a ese usuario (lo que describe este doc).  
  - **Si el buzón es Gmail consumidor** (ej. `unplanzoo+eventos@gmail.com`): Domain-wide delegation **no aplica**. Hace falta **OAuth 2.0** con refresh token de esa cuenta (el usuario/administrador autoriza la app una vez; se guarda el refresh token y la Cloud Function usa ese token para acceder al buzón). La implementación actual en código usa solo JWT + impersonation (Workspace). Para usar `unplanzoo+eventos@gmail.com` habría que añadir flujo OAuth y guardar el refresh token en config/Secret Manager.

## Pasos

### 1. Service Account y clave

1. En Google Cloud Console → IAM y administración → Cuentas de servicio, crea una cuenta de servicio (o usa una existente del proyecto de Firebase).
2. Crea una **clave JSON** y descárgala. Necesitarás `client_email` y `private_key` (o el JSON completo).

### 2. Domain-wide delegation (Google Workspace)

1. En la cuenta de servicio, copia el **ID de cliente numérico** (no el email).
2. En **Google Workspace Admin** (admin.google.com) → Seguridad → Controles de acceso y datos → Delegación de autoridad de dominio.
3. Añade el ID de cliente con los siguientes scopes:
   - `https://www.googleapis.com/auth/gmail.readonly`
   - `https://www.googleapis.com/auth/gmail.modify`
4. Guarda.

### 3. Variables de entorno / Firebase config

En el proyecto de Cloud Functions (Secret Manager, env al desplegar, o `firebase functions:config:set`), configura:

| Variable / config | Descripción |
|-------------------|-------------|
| `GMAIL_INBOUND_MAILBOX` o `gmail_inbound.mailbox` | Un solo buzón (actual: `unplanzoo+eventos@gmail.com`). |
| `GMAIL_INBOUND_MAILBOX_LIST` o `gmail_inbound.mailbox_list` | **Varios buzones** (resiliencia): lista separada por comas (`eventos@,eventos-backup@`) o JSON array. El job procesa cada uno; si uno falla, sigue con el siguiente. |
| `GMAIL_INBOUND_SA_JSON` o `gmail_inbound.service_account_json` | JSON completo de la clave de la SA (string). **O bien** los dos siguientes. |
| `GMAIL_INBOUND_SA_CLIENT_EMAIL` / `gmail_inbound.client_email` | `client_email` de la SA. |
| `GMAIL_INBOUND_SA_PRIVATE_KEY` / `gmail_inbound.private_key` | `private_key` de la SA (con `\n` si es necesario). |
| `GMAIL_POLL_SECRET` o `gmail_inbound.poll_secret` | (Opcional) Secreto que debe enviar Cloud Scheduler en la cabecera `X-Gmail-Poll-Secret`. |

Ejemplo con Firebase config (solo para desarrollo; en producción usar Secret Manager o env):

```bash
firebase functions:config:set gmail_inbound.mailbox="unplanzoo+eventos@gmail.com"
# Y la SA: mejor inyectar GMAIL_INBOUND_SA_JSON como variable de entorno en Cloud Functions.
```

### 4. Cloud Scheduler

1. En Google Cloud Console → Cloud Scheduler, crea un job.
2. Frecuencia: p. ej. cada 10 minutos (`*/10 * * * *`).
3. Tipo: HTTP.
4. URL: `https://<region>-<project>.cloudfunctions.net/processInboundGmail` (sustituir región y proyecto).
5. Método: POST (o GET).
6. Si configuraste `GMAIL_POLL_SECRET`, añade cabecera: `X-Gmail-Poll-Secret` = valor del secreto.

Tras el primer deploy de functions, la URL estará en la consola de Firebase o en la salida de `firebase deploy --only functions`.

### 5. Habilitar Gmail API

En Google Cloud Console → APIs y servicios → Biblioteca, busca **Gmail API** y habilítala para el proyecto.

---

## Varios buzones y desvío (resiliencia)

Si la cuenta principal (`eventos@`) sufre un ataque, se bloquea o deja de funcionar, puedes:

1. **Varios buzones en el mismo job:** Configura `GMAIL_INBOUND_MAILBOX_LIST` con dos (o más) direcciones, por ejemplo:
   - `eventos@tudominio.com,eventos-backup@tudominio.com`
   La misma Service Account (con domain-wide delegation) puede impersonar a cualquiera de las cuentas del dominio. El job procesa primero el principal y luego el de respaldo; si uno falla (auth, cuenta deshabilitada), se registra y se continúa con el siguiente. La respuesta del job incluye `byMailbox` con el resultado por buzón.

2. **Desvío en Google Workspace:** En Admin (admin.google.com) → Apps → Google Workspace → Gmail → Configuración de enrutamiento (o Reenvío), puedes:
   - Hacer que **eventos@** reenvíe todo a **eventos-backup@** cuando quieras (p. ej. tras un incidente). Los correos nuevos llegarán al backup; el job, si tiene ambos en `GMAIL_INBOUND_MAILBOX_LIST`, los leerá del backup cuando entren ahí.
   - O definir una **regla**: si la cuenta eventos@ está en cuarentena o deshabilitada, el administrador puede activar reenvío a eventos-backup@ y añadir (o dejar ya configurado) eventos-backup@ en la lista de buzones.

3. **Cambio rápido de buzón:** Si solo usas un buzón (`GMAIL_INBOUND_MAILBOX`), en caso de incidente puedes cambiar la variable a la cuenta de respaldo y redesplegar (o actualizar la config en Secret Manager/env) para que el job lea solo del backup hasta que se recupere el principal.
