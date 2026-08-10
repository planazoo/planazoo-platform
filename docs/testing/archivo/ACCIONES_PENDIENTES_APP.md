# Acciones pendientes (seguimiento fuera de la lista viva)

**Propósito:** concentrar lo que **sigue abierto** cuando `LISTA_PUNTOS_CORREGIR_APP.md` se usa solo para **nuevos** hallazgos.

**Última actualización:** 2026-04-19

---

## Infra iOS (antes P1 / P2 en la lista histórica)

Referencias cruzadas: `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md`, `docs/configuracion/REVISION_IOS_VS_WEB.md`, `docs/flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md`.

### A1 — Notificaciones push iOS (APNs / FCM)

- **Plataforma:** iOS  
- **Flujo:** notificaciones push (primer plano / segundo plano / al abrir desde notificación).  
- **Objetivo:** APNs + FCM correctos; notificaciones fiables y navegación al sitio adecuado al tocar.  
- **Estado:** **cerrado en app (2026-04-19)** — validación en iPhone físico (foreground + background operativos; ítem **109** archivado).
- **Estado técnico (2026-04-19):**
  - `FCMService` con init idempotente por usuario, listeners sin duplicados y `setForegroundNotificationPresentationOptions`.
  - Handler central de tap push en `App` (`navigatorKey`) con apertura de `PlanDetailPage` por `planId`/`plan_id`.
  - Contrato de payload normalizado (`tab`/`initialTab` + fallback por `type`) y handler background en `main.dart`.
  - **iOS:** `AppDelegate` clásico (`GeneratedPluginRegistrant.register(with: self)`); sin `UIApplicationSceneManifest` (requerido para que `FirebaseMessaging.onMessage` funcione en foreground con el stack actual).
- **Fuente operativa única:** `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (A1 + “Ejecución guiada A1” + bloque “Estado push iOS”).
- **Vinculación con lista viva:** ítem **109** cerrado; detalle en `docs/testing/ARCHIVO_LISTA_PUNTOS_CORREGIR_APP_2026_04.md`.
- **Seguimiento multiplataforma:** Android + FCM → **T267** en `docs/tareas/TASKS.md`.

#### Evidencia de ejecución A1 (2026-04-19)

- **Dispositivo:** iPhone físico `00008030-001869E83699402E`.
- **Resultado:** foreground con `onMessage` + feedback in-app; background con entrega/banner; token FCM en Firestore (`users/{uid}/fcmTokens/{token}`).
- **Nota:** pruebas formales paso a paso 1→7 de la checklist pueden repetirse antes de TestFlight; el cierre de producto para QA lista viva queda registrado arriba.

### A2 — Deep link de invitación en iOS

- **Plataforma:** iOS  
- **Flujo:** abrir link de invitación desde Mail/Safari → app en pantalla de invitación/plan.  
- **Objetivo:** Universal Links o URL scheme + dominio/AASA + Associated Domains en Xcode.  
- **Estado:** parcial — checklist (A2); tarea relacionada **T259**.  
- **Alineación de flujo:** ver `docs/flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md` (invitaciones/notificaciones) y `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (A2 operativo).

## Infra Android (nuevo seguimiento)

### A3 — App Android local + push invitación (paridad)

- **Plataforma:** Android  
- **Flujo:** ejecución app en Android + invitación entre usuarios con push y apertura al plan/pestaña de participantes.
- **Objetivo:** paridad operativa con iOS en el caso de invitación (T267).
- **Estado:** pendiente de arranque local (en este entorno falta SDK Android en `flutter doctor`).
- **Guía operativa:** `docs/configuracion/SETUP_ANDROID_LOCAL.md`.
- **Checklist mínimo al retomar:**
  - Android toolchain OK (`flutter doctor -v`).
  - App corre en dispositivo/emulador Android.
  - Token FCM Android guardado en `users/{uid}/fcmTokens`.
  - Caso invitación: push llega y al tap abre `PlanDetailPage` en `participants`.
  - Registrar evidencia y actualizar `TESTING_CHECKLIST.md`.

---

*A1 cerrado (2026-04-19). Pendientes activos de esta hoja: A2 (deep link iOS) y A3 (Android + push).*
