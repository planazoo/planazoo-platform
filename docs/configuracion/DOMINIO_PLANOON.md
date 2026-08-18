# Dominio `planoon.com`

Dominio de marca. La **app** vive en el subdominio `app.planoon.com` (mails, Universal Links / App Links). La raíz / `www` queda para web comercial.

## Registro

| Campo | Valor |
|-------|--------|
| Dominio | **`planoon.com`** |
| Registrar / DNS | **Cloudflare** ([dash.cloudflare.com](https://dash.cloudflare.com)) |
| Cuenta | **`unplanazoo@gmail.com`** |
| Login | **Google** (misma cuenta operativa del proyecto; ver [ACCESOS_Y_CUENTAS.md](./ACCESOS_Y_CUENTAS.md) §1 y §3) |
| Quién | Cristian |
| Fecha | Agosto 2026 |
| Secretos | **No** en el repo · acceso vía Google de `unplanazoo@gmail.com` · Bitwarden pendiente |

## Relación con Firebase

| URL | Rol |
|-----|-----|
| `https://planazoo.web.app` | Hosting Firebase (sigue activo) |
| **`https://app.planoon.com`** | **App Flutter** — mails, deep links, AASA · custom domain en Hosting |
| `https://planoon.com` / `www.planoon.com` | **Web comercial / landing** (futuro; no apuntar a la app) |
| `planazoo.app` | **No usar** — no resolvía; referencias históricas |

Proyecto Firebase: **planazoo**.

**Decisión (Ago 2026):** raíz `planoon.com` = comercial; `app.planoon.com` = aplicación.

## Estado (Ago 2026)

- [x] Dominio en Cloudflare
- [x] CNAME `app` → `planazoo.web.app` (DNS only)
- [x] Firebase detecta `app.planoon.com` · sitio abre (cert SSL puede tardar en mostrar candado verde)
- [x] Repo: `APP_BASE_URL` default, entitlements, Android host, client link → `https://app.planoon.com`
- [x] Certificado SSL “Connected” / sin aviso de seguridad en el navegador (`CN=app.planoon.com`, Ago 2026)
- [x] `firebase functions:config:set app.base_url="https://app.planoon.com"` (+ deploy functions)
- [ ] Redeploy hosting (AASA ya se sirve en el custom domain) + rebuild iOS
- [ ] QA: Mail → `https://app.planoon.com/invitation/{token}` abre la app
- [x] Monorepo: carpeta [`marketing/`](../../marketing/) + [MONOREPO.md](./MONOREPO.md) (landing estática; deploy Pages pendiente)
- [ ] Landing en `planoon.com` / `www` (Cloudflare Pages apuntando a `marketing/`)

Relacionado: T259 ([`docs/tareas/T259_DEEP_LINK_INVITACION_IOS.md`](../tareas/T259_DEEP_LINK_INVITACION_IOS.md)), [DEPLOY_WEB_FIREBASE_HOSTING.md](./DEPLOY_WEB_FIREBASE_HOSTING.md), [MONOREPO.md](./MONOREPO.md).
