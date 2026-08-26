# Accesos y cuentas del proyecto

Inventario de **consolas, webs, cuentas y accesos remotos** usados en Planazoo.  
Complementa el índice técnico [`CONFIGURACIONES_PROYECTO.md`](./CONFIGURACIONES_PROYECTO.md) (qué se configura y dónde en el repo).

**Reglas**
- **No** escribir contraseñas ni secretos en este documento (ni en el repo).
- Anotar solo: URL, cuenta (email), quién tiene acceso, para qué sirve, y **dónde** está la contraseña.
- Actualizar al dar de alta un acceso nuevo o al cambiar de responsable.
- Usuarios de **prueba de la app** (login en Planazoo): ver [`USUARIOS_PRUEBA.md`](./USUARIOS_PRUEBA.md). Admins de plataforma: [`ADMINS_WHITELIST.md`](../admin/ADMINS_WHITELIST.md).

**Responsable habitual de accesos:** Cristian (único por defecto en todas las filas salvo que se indique lo contrario).  
**Cuenta operativa principal:** `unplanazoo@gmail.com`

**Última revisión:** Agosto 2026 (dominio `planoon.com` en Cloudflare)

---

## Dónde guardar secretos (decisión)

Hoy las contraseñas **no** están centralizadas. Propuesta:

| Opción | Cuándo usarla |
|--------|----------------|
| **Bitwarden** (recomendado) | Gratis, Mac + iPhone + web; vault “Planazoo” con Google, Apple, app-specific password, API keys, remoto. |
| **iCloud Keychain** | Solo como refuerzo en dispositivos Apple (autofill Safari/Apps). No sustituye un vault ordenado. |
| **1Password** | Si más adelante hay equipo y se quiere vault familiar/pago. |

**Acción pendiente:** crear cuenta Bitwarden (o elegir otra), guardar al menos: Google/`unplanazoo@gmail.com`, Apple ID, contraseña específica de apps TestFlight.  
En las tablas, columna **Secretos** = `Bitwarden (pendiente activar)` hasta confirmarlo.

---

## Convención de columnas

| Columna | Significado |
|---------|-------------|
| Servicio / URL | Consola o herramienta |
| Cuenta | Email o identificador de login |
| Quién | Personas con acceso |
| Uso | Para qué lo necesitamos |
| Secretos | Dónde están (nunca el valor) |
| Notas | 2FA, Team ID, alias, etc. |

---

## 1. Google / Firebase / Cloud (todas las webs relevantes)

Misma cuenta operativa: **`unplanazoo@gmail.com`** · Quién: **Cristian** · Secretos: recordatorio (no es la clave) `ito` · 2FA recomendado · Bitwarden pendiente.

Proyecto Firebase / GCP: **planazoo** · Web prod: `https://planazoo.web.app`

| Servicio / URL | Uso | Notas |
|----------------|-----|-------|
| [accounts.google.com](https://accounts.google.com) | Login Google / seguridad de la cuenta | 2FA, dispositivos, recuperación |
| [myaccount.google.com](https://myaccount.google.com) | Cuenta Google (seguridad, privacidad) | Contraseñas de apps Gmail si aplica |
| [gmail.com](https://mail.google.com) | Correo `unplanazoo@gmail.com` | Alias `unplanazoo+…@gmail.com` → misma bandeja |
| [Firebase Console](https://console.firebase.google.com/) | Proyecto **planazoo**: Auth, Firestore, Functions, Storage, Hosting, FCM | Entrada principal backend |
| [Firebase → Authentication](https://console.firebase.google.com/project/planazoo/authentication) | Usuarios Auth, proveedores (email, Google) | |
| [Firebase → Firestore](https://console.firebase.google.com/project/planazoo/firestore) | Datos, reglas, índices | Deploy reglas: docs configuracion |
| [Firebase → Functions](https://console.firebase.google.com/project/planazoo/functions) | Cloud Functions (push, emails, etc.) | |
| [Firebase → Storage](https://console.firebase.google.com/project/planazoo/storage) | Imágenes / archivos | [IMAGENES_PLAN_FIREBASE.md](./IMAGENES_PLAN_FIREBASE.md), [STORAGE_CORS.md](./STORAGE_CORS.md) |
| [Firebase → Hosting](https://console.firebase.google.com/project/planazoo/hosting) | Web producción | [DEPLOY_WEB_FIREBASE_HOSTING.md](./DEPLOY_WEB_FIREBASE_HOSTING.md) · `https://planazoo.web.app` |
| [Firebase → Messaging (FCM)](https://console.firebase.google.com/project/planazoo/messaging) | Push / campañas de prueba | APNs key en ajustes del proyecto iOS |
| [Firebase → Project settings](https://console.firebase.google.com/project/planazoo/settings/general) | Apps iOS/Android/Web, `GoogleService-Info.plist`, `google-services.json` | Archivos locales en gitignore |
| [Google Cloud Console](https://console.cloud.google.com/) | APIs, facturación, IAM (mismo proyecto) | Vinculado a Firebase |
| [APIs y servicios](https://console.cloud.google.com/apis) | Habilitar Places, Maps, etc. | [CONFIGURAR_GOOGLE_PLACES_API.md](./CONFIGURAR_GOOGLE_PLACES_API.md) |
| [Credenciales (API keys)](https://console.cloud.google.com/apis/credentials) | API keys y restricciones | No hardcodear secretas en el repo |
| [Facturación GCP](https://console.cloud.google.com/billing) | Facturación / crédito Places | |
| [Google Cloud → OAuth consent / clients](https://console.cloud.google.com/apis/credentials) | Clientes OAuth (Google Sign-In) | [CONFIGURAR_GOOGLE_SIGNIN.md](./CONFIGURAR_GOOGLE_SIGNIN.md) · también en Firebase Auth |
| [Google Remote Desktop](https://remotedesktop.google.com/) | Acceso remoto al Mac de build | Detalle en §5 · PIN recordatorio `9534x2` · Mac pwd recordatorio `ola` |
| [Google Play Console](https://play.google.com/console) | Publicación Android (futuro) | **Pendiente** si aún no hay app en Play |
| [sites.google.com](https://sites.google.com) | Landing / Sites | Hoy: **no usado** en el proyecto |
| Firebase CLI (`firebase login`) | Deploy desde el Mac | Sesión ligada a esta cuenta Google |

**Recordatorio de secretos Google (no son las claves reales):** login → `ito` · app password Gmail/SMTP si se usa → Bitwarden cuando se active · Remote Desktop: ver §5.

---

## 2. Apple (todas las webs relevantes)

Misma cuenta en casi todo: **`unplanazoo@gmail.com`** · Quién: **Cristian** · Secretos: recordatorio (no es la clave) `ito` · 2FA · **Application Password** (abajo).

### Application Password (imprescindible para publicar / TestFlight)

Con 2FA, Apple **no** acepta la contraseña normal del Apple ID al subir el IPA. Hace falta una **contraseña específica de apps** (*app-specific password* / *Application Password*).

| Qué | Detalle |
|-----|---------|
| Para qué | `xcrun altool --upload-app` · `fastlane beta` / `upload_to_testflight` |
| Variable de entorno | `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` (solo en terminal local; **no** en el repo) |
| Dónde se crea | [appleid.apple.com](https://appleid.apple.com) → Inicio de sesión y seguridad → **Contraseñas de apps** → Generar |
| Formato | `xxxx-xxxx-xxxx-xxxx` (solo se muestra al crearla; si se pierde, revocar y crear otra) |
| Cuenta | `unplanazoo@gmail.com` |
| Quién | Cristian |
| Valor actual (temporal; rotar) | `sqwt-ovst-syoq-zhqz` |
| Recordatorio | Temporal en este doc hasta Bitwarden · **cambiar** tras uso en chat |
| Guía | [FASTLANE_IOS_APPSTORE.md](./FASTLANE_IOS_APPSTORE.md) (sección 2FA) |

**Nota:** Si se compartió en un chat o quedó expuesta, **revocarla** en appleid.apple.com y generar una nueva; guardar solo en Bitwarden (cuando esté activo) o en el recordatorio de esta tabla.

| Servicio / URL | Uso | Notas |
|----------------|-----|-------|
| [appleid.apple.com](https://appleid.apple.com) | Gestión Apple ID, 2FA, **Contraseñas de apps** | Aquí se crea/revoca el Application Password |
| [developer.apple.com](https://developer.apple.com) | Programa Developer, Membership, docs | **Team ID:** `5X78V2WTNZ` |
| [developer.apple.com/account](https://developer.apple.com/account) | Cuenta Developer (resumen) | Entrada habitual tras login |
| [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/certificates/list) | Certificados, App IDs, perfiles, keys (APNs) | Firma iOS / push |
| [appstoreconnect.apple.com](https://appstoreconnect.apple.com) | App, versiones, **TestFlight**, reseñas, finanzas | **itc_team_id:** `5X78V2WTNZ` · Bundle: `com.mycompany.myplanazoo` |
| [App Store Connect → Users and Access](https://appstoreconnect.apple.com/access/users) | Usuarios del equipo ASC, roles, API keys | Añadir testers internos / keys CI |
| [TestFlight (web ASC)](https://appstoreconnect.apple.com/apps) → app → TestFlight | Builds, grupos de testers, compliance | Tras `flutter build ipa` + altool/fastlane |
| [icloud.com](https://www.icloud.com) | iCloud ligado al Apple ID (si se usa) | Opcional |
| [support.apple.com](https://support.apple.com) | Soporte / recuperación de cuenta | Referencia |
| Transporter (app Mac) | Subir IPA sin Fastlane | Misma Apple ID en el Mac · arrastrar `build/ios/ipa/*.ipa` |
| Fastlane / `altool` (local, no web) | Subida a TestFlight | Requiere **Application Password** · [FASTLANE_IOS_APPSTORE.md](./FASTLANE_IOS_APPSTORE.md) |
| Xcode → Settings → Accounts | Login Apple ID en el Mac de build | Firma automática · Team `5X78V2WTNZ` |

**Recordatorio de secretos Apple (no son las claves reales):** login Apple ID → `ito` · Application Password → ver tabla de arriba.

---

## 3. Hosting, dominios y web

| Servicio / URL | Cuenta | Quién | Uso | Secretos | Notas |
|----------------|--------|-------|-----|----------|-------|
| Firebase Hosting / `planazoo.web.app` + `app.planoon.com` | `unplanazoo@gmail.com` | Cristian | Web app producción | Ver §1 | [DEPLOY_WEB_FIREBASE_HOSTING.md](./DEPLOY_WEB_FIREBASE_HOSTING.md) · AASA |
| **Dominio `planoon.com`** | Cloudflare · login **`unplanazoo@gmail.com`** (Google) | Cristian | Marca + DNS | Login = Google (§1) | Apex/www = comercial ([`marketing/`](../../marketing/)) · **app** = `app.planoon.com` · [DOMINIO_PLANOON.md](./DOMINIO_PLANOON.md) · [MONOREPO.md](./MONOREPO.md) |
| [dash.cloudflare.com](https://dash.cloudflare.com) | `unplanazoo@gmail.com` (SSO Google) | Cristian | DNS, registrar, SSL | Cuenta Google / Bitwarden pendiente | Zona `planoon.com` |

**Estado dominio (Ago 2026):** `app.planoon.com` en Firebase Hosting (DNS OK; SSL puede seguir provisionándose). Repo actualizado a `https://app.planoon.com`. Pendiente: config CF `app.base_url`, redeploy functions/hosting, rebuild iOS, QA Universal Links.

---

## 4. Código, CI e IDE

| Servicio / URL | Cuenta | Quién | Uso | Secretos | Notas |
|----------------|--------|-------|-----|----------|-------|
| GitHub ([planazoo-platform](https://github.com/planazoo/planazoo-platform.git)) | `unplanazoo@gmail.com` | Cristian | Código, PRs, Issues | Recordatorio (no es la clave): `ito` · clave real pendiente de guardar en Bitwarden | Remoto: `https://github.com/planazoo/planazoo-platform.git` |
| Cursor | `cricla@hotmail.com` | Cristian | IDE + agente | Recordatorio (no es la clave): `ito` · clave real pendiente Bitwarden | Suscripción Cursor; no hay cuenta en el repo |
| Xcode / Apple en Mac de build | `unplanazoo@gmail.com` | Cristian | Firma, archive, simulators | Keychain local + Apple ID (Bitwarden pendiente) | [SETUP_IOS_SIMULATOR.md](./SETUP_IOS_SIMULATOR.md) |

---

## 5. Acceso remoto a ordenadores

| Equipo | Cómo se accede | Quién | Uso | Secretos | Notas |
|--------|---------------|-------|-----|----------|-------|
| Mac de desarrollo / build iOS | [Google Remote Desktop](https://remotedesktop.google.com/) | Cristian | Compilar, firmar, TestFlight | Cuenta Google: recordatorio `ito` · PIN remoto: recordatorio `9534x2` · password Mac: recordatorio `ola` (valores reales pendientes Bitwarden) | Usuario Google: `unplanazoo@gmail.com` |
| PC Windows (si aplica) | — | — | — | — | No aplica por ahora |
| Raspberry Pi / lab QA (si aplica) | _(pendiente)_ | Cristian | QA nocturno E2E | | Ver docs testing QA nocturno |

---

## 6. Marketing y redes sociales

| Servicio / URL | Cuenta | Quién | Uso | Secretos | Notas |
|----------------|--------|-------|-----|----------|-------|
| [gmail.com](https://mail.google.com) | `myplanoon@gmail.com` | Cristian | Correo de marca Planoon (público / soporte) | Bitwarden pendiente | Separada de la cuenta operativa `unplanazoo@gmail.com` |
| [instagram.com/@myplanoon](https://www.instagram.com/myplanoon/) | `@myplanoon` | Cristian | Presencia en Instagram | Bitwarden pendiente | Creada Ago 2026 |

---

## 7. Otros servicios (APIs de terceros)

| Servicio / URL | Cuenta | Quién | Uso | Secretos | Notas |
|----------------|--------|-------|-----|----------|-------|
| Amadeus (vuelos) | — | — | Estado de vuelo / eventos | — | **Pendiente / no activo** · [CONFIGURAR_AMADEUS_FLIGHT_STATUS.md](./CONFIGURAR_AMADEUS_FLIGHT_STATUS.md) |
| _(añadir filas)_ | | | | | |

---

## 8. Cuentas de la app (referencia cruzada)

| Tema | Documento |
|------|-----------|
| Usuarios de prueba (emails alias `unplanazoo+…`) | [USUARIOS_PRUEBA.md](./USUARIOS_PRUEBA.md) |
| Power admins (`isAdmin`) | [ADMINS_WHITELIST.md](../admin/ADMINS_WHITELIST.md) |
| Roles plataforma vs plan | [ROLES_Y_TIPOS_USUARIO.md](./ROLES_Y_TIPOS_USUARIO.md) |

---

## Checklist al incorporar un acceso nuevo

1. Añadir fila en la sección correspondiente.  
2. Guardar la contraseña **solo** en Bitwarden (u otro gestor elegido).  
3. Activar 2FA si el servicio lo permite.  
4. Si afecta a despliegue o firma, actualizar también [`CONFIGURACIONES_PROYECTO.md`](./CONFIGURACIONES_PROYECTO.md).  
5. Si es cuenta admin de la app, actualizar whitelist / usuarios de prueba.
