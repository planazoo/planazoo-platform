# T259 – Deep link invitación en iOS

**Objetivo:** Que el link de invitación a un plan (p. ej. el que se envía por email) abra la app iOS directamente en la pantalla de invitación, en paridad con la experiencia web.

**Referencia:** `docs/configuracion/REVISION_IOS_VS_WEB.md` §2.3 y §3 ítem 7; decisión de igualar (opción B) en revisión iOS vs Web diferencia 7.

---

## Contexto

- **Web:** La ruta `/invitation/{token}` abre la web y muestra `InvitationPage`. Funciona bien.
- **iOS (actual):** La misma URL suele abrir el navegador; no está configurado Universal Links ni URL scheme, por lo que “abrir en la app” desde el link no está garantizado.

## Opciones de implementación

1. **Universal Links:** El dominio (ej. planazoo.web.app o el dominio de la web) declara en `apple-app-site-association` que las rutas `/invitation/*` se abren en la app. Requiere:
   - Associated Domains en Xcode (ej. `applinks:planazoo.web.app`)
   - Archivo `apple-app-site-association` en el servidor (Firebase Hosting puede servirlo en `/.well-known/`)
   - En la app: manejar la URL de arranque y en segundo plano (e.g. `getInitialUri` / `uriLinkStream` con `app_links` o equivalente)

2. **Custom URL scheme:** Ej. `planazoo://invitation/{token}`. Los emails/enlaces tendrían que usar esta URL (requiere que el backend o el frontend generen links con este esquema para clientes conocidos o una landing que redirija). Más simple de configurar; menos “nativo” que Universal Links.

Recomendación: priorizar **Universal Links** si el dominio de la web puede servirse el archivo de asociación; así un solo link sirve para web y para abrir la app en iOS.

## Entregables

- [ ] Decisión: Universal Links vs URL scheme (y si se mantiene un solo link o dos variantes).
- [ ] Configuración en Xcode (Associated Domains o URL scheme).
- [ ] Archivo `apple-app-site-association` en el servidor (si Universal Links).
- [ ] Código en la app para obtener la URL inicial y en foreground/background y navegar a `InvitationPage` con el token.
- [ ] Prueba: abrir link desde Mail/Safari y verificar que abre la app en la pantalla de invitación.
- [ ] Actualizar `REVISION_IOS_VS_WEB.md` ítem 7 como resuelto.
