# Recepción de correos (buzón) con Gmail API

> Configuración para que la plataforma lea el buzón con Gmail API (recepción 100% Google).  
> Relacionado: `docs/producto/CORREO_EVENTOS_SISTEMA_PARSEO.md` (documento canónico T134), Cloud Function `processInboundGmail`.

**Buzón actual:** `unplanazoo+eventos@gmail.com` (los usuarios reenvían sus confirmaciones a esta dirección).

El job **no** está “encendido” solo con desplegar código: hace falta autorizar esa cuenta Gmail (OAuth) o, en Workspace, una service account.

## Requisitos

- Un buzón Gmail o **Google Workspace**. Los usuarios reenvían ahí.
- **Gmail consumidor** (`unplanazoo+eventos@gmail.com`): **OAuth 2.0** con refresh token de la cuenta dueña de esa bandeja. Domain-wide delegation **no aplica**.
- **Google Workspace** (`eventos@tudominio.com`): service account + **domain-wide delegation** (sección más abajo).

El poll lista no leídos recientes (incl. spam) y **solo procesa** si To / Delivered-To contiene el buzón. Gmail trata `+` como AND, así que no se usa `deliveredto:"user+alias"` en la query. `GMAIL_INBOUND_QUERY` puede sustituir la query. La respuesta del job incluye `authenticatedAs` (cuenta Gmail del token OAuth).

## Gmail consumidor (lanzamiento actual) — OAuth

### 1. APIs

En [Google Cloud Console](https://console.cloud.google.com/) proyecto **planazoo**: APIs y servicios → Biblioteca → **Gmail API** → Habilitar.

### 2. Pantalla de consentimiento OAuth (Google Auth Platform)

Mismo proyecto que el login de la app: **dejar Audience en In production** (no pasar a Testing: rompería Google Sign-In para usuarios que no están en la lista de prueba).

1. [Auth Platform](https://console.cloud.google.com/auth/overview?project=planazoo): **Data Access** → scopes `gmail.readonly` y `gmail.modify`.
2. Sale **Verification required / Approval required**. **No** enviar la app a verificación: solo se autoriza el buzón. Al consentir aparecerá “Google no ha verificado esta app” → Avanzado → continuar.

### 3. Cliente OAuth (escritorio)

1. Auth Platform → **Clients** → Create client → tipo **Desktop app**.
2. Nombre: `Planoon Gmail inbound`.
3. URI de redirección: `http://127.0.0.1:4180/oauth2callback`.
4. **Client ID** (28 ago 2026; se puede rotar):  
   `794752310537-041ja0c2p4c4u0enmso390ueojhsifn9.apps.googleusercontent.com`  
   El **client secret** no se documenta aquí (solo Functions config / vault).

### 4. Autorizar una vez (refresh token)

En el Mac, con la cuenta **dueña del buzón** en el navegador:

```bash
cd /Users/emmclaraso/development/unp_calendario/functions
GMAIL_INBOUND_OAUTH_CLIENT_ID="794752310537-041ja0c2p4c4u0enmso390ueojhsifn9.apps.googleusercontent.com" \
GMAIL_INBOUND_OAUTH_CLIENT_SECRET="…" \
npm run gmail-inbound-oauth
```

Abre la URL que imprime el script, acepta permisos, copia el **refresh token** de la terminal (no va a git).

### 5. Config de Functions y deploy

Desde la raíz del repo:

```bash
npx firebase-tools functions:config:set \
  gmail_inbound.mailbox="unplanazoo+eventos@gmail.com" \
  gmail_inbound.oauth_client_id="….apps.googleusercontent.com" \
  gmail_inbound.oauth_client_secret="…" \
  gmail_inbound.oauth_refresh_token="…"

npx firebase-tools deploy --only functions:processInboundGmail
```

Equivalente por env: `GMAIL_INBOUND_MAILBOX`, `GMAIL_INBOUND_OAUTH_CLIENT_ID`, `GMAIL_INBOUND_OAUTH_CLIENT_SECRET`, `GMAIL_INBOUND_OAUTH_REFRESH_TOKEN`.

### 6. Cloud Scheduler

Job HTTP cada 2 minutos (`*/2 * * * *`), GET o POST a  
`https://us-central1-planazoo.cloudfunctions.net/processInboundGmail`  
con **OIDC** (la función no es pública). Si configuras `GMAIL_POLL_SECRET` / `gmail_inbound.poll_secret`, cabecera `X-Gmail-Poll-Secret`.

Disparo a mano (dueño del proyecto):

```bash
curl -sS \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  "https://us-central1-planazoo.cloudfunctions.net/processInboundGmail"
```

El correo tiene que seguir **no leído**. Si ya lo abriste en Gmail, márcalo otra vez como no leído.

---

## Workspace — Service Account (cuando el buzón sea del dominio)

### 1. Service Account y clave

1. IAM → Cuentas de servicio: crea o usa una del proyecto Firebase.
2. Clave JSON: `client_email` y `private_key`.

### 2. Domain-wide delegation

1. En la SA, **ID de cliente numérico**.
2. Admin Workspace → Seguridad → Delegación de autoridad de dominio.
3. Scopes: `gmail.readonly` y `gmail.modify`.

### 3. Config

| Variable / config | Descripción |
|-------------------|-------------|
| `GMAIL_INBOUND_MAILBOX` o `gmail_inbound.mailbox` | Un buzón. Defecto en código: `unplanazoo+eventos@gmail.com`. |
| `GMAIL_INBOUND_MAILBOX_LIST` o `gmail_inbound.mailbox_list` | Varios buzones (coma o JSON). |
| `GMAIL_INBOUND_OAUTH_*` / `gmail_inbound.oauth_*` | Gmail consumidor (arriba). |
| `GMAIL_INBOUND_SA_JSON` o `gmail_inbound.service_account_json` | JSON de la SA. **O** client_email + private_key. |
| `GMAIL_INBOUND_SA_CLIENT_EMAIL` / `gmail_inbound.client_email` | |
| `GMAIL_INBOUND_SA_PRIVATE_KEY` / `gmail_inbound.private_key` | `\n` si hace falta. |
| `GMAIL_POLL_SECRET` o `gmail_inbound.poll_secret` | Cabecera `X-Gmail-Poll-Secret`. |
| `GMAIL_INBOUND_QUERY` o `gmail_inbound.query` | Query Gmail opcional (sustituye el `deliveredto` por defecto). |

El cliente OAuth **gana** sobre la SA si ambos están configurados.

---

## Varios buzones y desvío (resiliencia)

Si la cuenta principal (`eventos@`) se bloquea:

1. **Varios buzones en el mismo job:** `GMAIL_INBOUND_MAILBOX_LIST` (p. ej. `eventos@,eventos-backup@`). Con **Workspace**, la misma SA puede impersonar ambos. Con **OAuth de consumidor**, el token es **una** cuenta Gmail: los extra en la lista son alias/`deliveredto` de esa misma bandeja.
2. **Desvío en Google Workspace:** reenvío o ruta hacia el backup; el job debe incluir ese buzón en la lista.
3. **Cambio rápido:** cambiar `GMAIL_INBOUND_MAILBOX` y redesplegar o actualizar Secret Manager.
