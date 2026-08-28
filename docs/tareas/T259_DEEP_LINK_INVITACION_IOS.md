# T259 – Deep link invitación en iOS (y Android)

**Estado:** **cerrado iOS** (2026-08-27). Dominio #1 cerrado; Android `assetlinks.json` queda opcional fuera de WIP.

**Objetivo:** Que el link de invitación a un plan (p. ej. el que se envía por email) abra la app nativa en la pantalla de invitación, en paridad con la experiencia web.

**Referencia:** `docs/configuracion/REVISION_IOS_VS_WEB.md` §2.3 y §3 ítem 7; contrato `DIAGRAMA_ALTAS_BAJAS_PLAN.md` §2 / §1.2 K.

---

## Contexto

- **Web:** `/invitation/{token}` → `InvitationPage` ✅
- **Nativo (en curso):** mismo HTTPS + scheme `planazoo://` → `InvitationPage` vía `app_links`

## Decisión (Ago 2026)

1. **Un solo link de email** HTTPS (no cambiar emails a `planazoo://` como único canal).
2. **Dominio canónico de la app:** `app.planoon.com` (Cloudflare + Firebase). Raíz `planoon.com` reservada para web comercial. Ver [`DOMINIO_PLANOON.md`](../configuracion/DOMINIO_PLANOON.md).
3. **Universal Links / App Links** cuando AASA esté en `app.planoon.com` + Associated Domains.
4. **Custom scheme** `planazoo://invitation/{token}` para pruebas en simulador / debug.

## Hecho en repo (slice 1)

- [x] `app_links` + listener en `lib/app/app.dart` (cold + warm start; no en web)
- [x] Parser `lib/shared/utils/invitation_deep_link.dart` + test
- [x] iOS `CFBundleURLTypes` scheme `planazoo` (probado en dispositivo)
- [x] iOS Associated Domains: `applinks:app.planoon.com`
- [x] Android intent-filters (scheme + https `app.planoon.com`)
- [x] AASA en hosting (se sirve en el custom domain al estar Connected)
- [x] Dominio `app.planoon.com` conectado (DNS); SSL puede seguir provisionándose
- [x] Defaults repo → `https://app.planoon.com` (client + CF fallback)

## Pendiente ops / QA

- [x] Cert SSL Connected (`CN=app.planoon.com`)
- [x] `firebase functions:config:set app.base_url="https://app.planoon.com"` + deploy functions
- [x] AASA en `https://app.planoon.com/.well-known/apple-app-site-association` → JSON 200
- [x] Rebuild app iOS (Associated Domains) — validado en dispositivo
- [ ] (Android) `assetlinks.json` si se quiere App Link verificado
- [x] Prueba dispositivo: Mail → HTTPS `app.planoon.com/invitation/...` abre la app (**OK** 2026-08-27, iPhone)
- [x] Marcar `REVISION_IOS_VS_WEB.md` ítem 7 como resuelto cuando pase QA

## Archivos clave

| Pieza | Path |
|-------|------|
| Listener | `lib/app/app.dart` |
| Parser | `lib/shared/utils/invitation_deep_link.dart` |
| Página | `lib/pages/pg_invitation_page.dart` |
| AASA | `web/.well-known/apple-app-site-association` |
| Hosting | `firebase.json` |
