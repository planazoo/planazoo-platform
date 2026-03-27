# Checklist iOS: push (FCM/APNs) y deep links de invitación

Referencia para **A1** (notificaciones) y **A2** (links de invitación) de `docs/testing/ACCIONES_PENDIENTES_APP.md` (antes P1/P2 de la lista histórica).

## A1 — Notificaciones push (FCM + APNs)

1. **Firebase / Apple**
   - En Firebase Console: proyecto correcto, app iOS con bundle ID coincidente con Xcode.
   - APNs: certificado o **APNs Authentication Key** subido en Firebase (Cloud Messaging → Apple app configuration).

2. **Proyecto iOS**
   - `GoogleService-Info.plist` en `ios/Runner/`, copiado del proyecto Firebase correcto.
   - Capabilities: **Push Notifications** (y **Background Modes** → Remote notifications si aplica).
   - `Podfile` / pods actualizados tras cambios de Firebase.

3. **Código**
   - Solicitud de permiso de notificaciones en el momento adecuado (onboarding o primer uso).
   - Manejo de token FCM y refresco; envío a backend si guardáis el token por usuario.

4. **Pruebas en dispositivo real**
   - App en primer plano, segundo plano y terminada; notificación de prueba desde Firebase Console.
   - Comprobar payload y navegación al tocar (si está implementada).

*Documentación relacionada:* `docs/configuracion/REVISION_IOS_VS_WEB.md` (§ notificaciones), guías FCM de FlutterFire.

## A2 — Deep link / Universal Links de invitación

1. **Dominio y Apple**
   - Dominio HTTPS con archivo **apple-app-site-association** (AASA) servido sin redirect y con `Content-Type` correcto.
   - En Apple Developer: **Associated Domains** para el App ID (`applinks:tu-dominio`).

2. **Xcode**
   - Target Runner → **Signing & Capabilities** → **Associated Domains** con los mismos dominios que el AASA.

3. **Rutas en la app**
   - Router (p. ej. `go_router`) con rutas que coincidan con los paths del link de invitación.
   - Probar link desde Mail/Safari → debe abrir la app y resolver la ruta (plan / invitación).

4. **Alternativa / complemento: URL scheme**
   - Registrar **URL Types** en Xcode para esquema propio (`planazoo://` o similar) si se usan links que no pasan por Universal Links.

*Documentación relacionada:* `REVISION_IOS_VS_WEB.md` § deep links, tarea T259 si está referenciada en el repo.

---

**Estado:** checklist de verificación; la validación final es siempre en **dispositivo físico** y con el **mismo bundle / entorno** que TestFlight/App Store.
