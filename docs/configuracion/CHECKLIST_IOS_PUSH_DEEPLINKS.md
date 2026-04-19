# Checklist iOS: push (FCM/APNs) y deep links de invitación

> Fuente operativa de referencia para A1/A2.  
> `FCM_FASE1_IMPLEMENTACION.md` mantiene solo el contexto técnico de arquitectura.

Referencia para **A1** (notificaciones) y **A2** (links de invitación) de `docs/testing/ACCIONES_PENDIENTES_APP.md` (antes P1/P2 de la lista histórica).

### Estado push iOS (2026-04 — cerrado en app)

- **Validado en iPhone físico:** foreground (`FirebaseMessaging.onMessage` + feedback in-app), background con banner/tap.
- **Embedding obligatorio para FCM en foreground:** no usar `UIApplicationSceneManifest` + `FlutterImplicitEngineDelegate` solo con registro en `didInitializeImplicitFlutterEngine` (puede romper `onMessage` en Dart; ver [flutter#185048](https://github.com/flutter/flutter/issues/185048)). Mantener **`AppDelegate` clásico** con `GeneratedPluginRegistrant.register(with: self)` en `application:didFinishLaunchingWithOptions:`.
- **Seguimiento:** paridad **Android** → `docs/tareas/TASKS.md` **T267**.

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

5. **Contrato mínimo del payload push (app actual)**
   - Para navegación al detalle del plan, enviar **`planId`** (o `plan_id`).
   - Opcional: **`tab`** o **`initialTab`** con uno de:
     - `planData`, `planNotes`, `mySummary`, `calendar`, `participants`, `chat`, `planNotifications`, `stats`, `payments`.
   - Si `tab` no viene o es inválido, la app intenta inferir pestaña por `type` / `notificationType` / `category`:
     - chat/message -> `chat`
     - announcement/event_change/event_proposed/invitation* -> `planNotifications`
     - payment/expense/balance -> `payments`
   - Si no hay `planId`, no se fuerza navegación.

6. **Payloads de prueba rápidos (Firebase Console / Cloud Function)**
   - Chat del plan:
     ```json
     {
       "planId": "PLAN_ID_REAL",
       "type": "chat"
     }
     ```
   - Notificaciones del plan (avisos/cambios):
     ```json
     {
       "planId": "PLAN_ID_REAL",
       "type": "announcement"
     }
     ```
   - Pagos (gasto/balance):
     ```json
     {
       "planId": "PLAN_ID_REAL",
       "type": "payment"
     }
     ```
   - Forzar pestaña concreta:
     ```json
     {
       "planId": "PLAN_ID_REAL",
       "tab": "payments"
     }
     ```

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

---

## ✅ Ejecución guiada A1 (iOS push) — lista operativa

Usa esta secuencia para cerrar el punto **109** con evidencia real.

### 0) Precondiciones (bloqueantes)

- App iOS instalada en dispositivo físico y sesión iniciada.
- `GoogleService-Info.plist` del proyecto correcto en `ios/Runner`.
- Capabilities activas en Xcode: **Push Notifications** y (si aplica) **Background Modes > Remote notifications**.
- APNs key/cert configurado en Firebase Console (app iOS correcta).
- En Firestore existe al menos un token en `users/{userId}/fcmTokens/{token}`.

### 1) Smoke técnico de token

- Acción:
  - Abrir app iOS recién instalada.
  - Aceptar permisos de notificación.
  - Verificar en Firestore que aparece/actualiza el token del usuario.
- Esperado:
  - Se crea o actualiza documento en `fcmTokens`.
  - Al relanzar app no se duplican listeners ni falla init (comportamiento estable).

### 2) Prueba foreground (app abierta)

- Payload recomendado (custom data; mismo contrato que en background):
  ```json
  {
    "planId": "PLAN_ID_REAL",
    "type": "announcement"
  }
  ```
- Acción:
  - App en primer plano.
  - Enviar push desde Firebase Console o Cloud Function.
- Esperado:
  - En consola Flutter: línea `FCM onMessage ...` y log `Notificación recibida en primer plano`.
  - En la app: **SnackBar** con título/cuerpo del push (feedback in-app).
  - No crash ni navegación inesperada automática.

**Nota iOS (HTTP v1 / curl):**

- Para **ver banner / Centro de notificaciones** (sobre todo en **background**), hace falta un mensaje **visible**: bloque `notification` (y/o `aps.alert` vía FCM). Un mensaje **solo `data`** con `aps` = `content-available` es un **push silencioso**: en background **no** verás aviso en la bandeja (comportamiento esperado de iOS).
- Todos los valores del mapa `data` en FCM v1 deben ser **strings**.
- Push silencioso en iOS: suele requerir cabeceras APNs coherentes (`apns-push-type`, `apns-priority`). Si el `curl` devuelve error JSON de FCM/APNs, revisar mensaje y payload.

**Ejemplo HTTP v1 “visible” (background + datos para la app):** usar de nuevo el `curl` con `notification` + `data` que ya te funcionaba para background.

### 3) Prueba background (app en segundo plano)

- Payload recomendado:
  ```json
  {
    "planId": "PLAN_ID_REAL",
    "type": "chat"
  }
  ```
- Acción:
  - Enviar app a background.
  - Enviar push.
  - Tocar notificación.
- Esperado:
  - App abre `PlanDetailPage`.
  - Selecciona pestaña inferida por tipo (`chat`).

### 4) Prueba app terminada (cold start)

- Payload recomendado:
  ```json
  {
    "planId": "PLAN_ID_REAL",
    "type": "payment"
  }
  ```
- Acción:
  - Forzar cierre total de la app.
  - Enviar push.
  - Tocar notificación.
- Esperado:
  - App arranca y procesa `getInitialMessage()`.
  - Abre plan correcto y pestaña `payments`.

### 5) Prueba de tab explícita (contrato payload)

- Payload recomendado:
  ```json
  {
    "planId": "PLAN_ID_REAL",
    "tab": "planNotifications"
  }
  ```
- Acción:
  - App en background o terminada.
  - Tocar notificación.
- Esperado:
  - Se abre `PlanDetailPage` en `planNotifications` (tab explícita prevalece).

### 6) Prueba de resiliencia de payload

- Casos:
  - Sin `planId`.
  - `tab` inválida (`"foo"`).
- Esperado:
  - Sin crash.
  - Sin navegación forzada cuando falte `planId`.
  - Con `tab` inválida, fallback por tipo (si existe) o comportamiento por defecto.

### 7) Criterio de cierre del 109

Marcar **hecho** cuando:

- Pasan las pruebas 1–6 en dispositivo iOS real.
- Se valida al menos un caso foreground, uno background y uno terminada.
- Queda evidencia mínima en `ACCIONES_PENDIENTES_APP.md` (fecha, dispositivo, resultado, incidencias).

Si falla algún paso, mantener **en progreso** y anotar bloqueo concreto (APNs, token, payload, navegación).
