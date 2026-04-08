# Acciones pendientes (seguimiento fuera de la lista viva)

**Propósito:** concentrar lo que **sigue abierto** cuando `LISTA_PUNTOS_CORREGIR_APP.md` se usa solo para **nuevos** hallazgos.

**Última actualización:** 2026-04-06

---

## Infra iOS (antes P1 / P2 en la lista histórica)

Referencias cruzadas: `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md`, `docs/configuracion/REVISION_IOS_VS_WEB.md`, `docs/flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md`.

### A1 — Notificaciones push iOS (APNs / FCM)

- **Plataforma:** iOS  
- **Flujo:** notificaciones push (primer plano / segundo plano / al abrir desde notificación).  
- **Objetivo:** APNs + FCM correctos; notificaciones fiables y navegación al sitio adecuado al tocar.  
- **Estado:** parcial — implementación técnica lista; pendiente validación completa en iPhone físico.
- **Estado técnico (2026-04-06):**
  - `FCMService` con init idempotente por usuario, listeners sin duplicados y `setForegroundNotificationPresentationOptions`.
  - Handler central de tap push en `App` (`navigatorKey`) con apertura de `PlanDetailPage` por `planId`/`plan_id`.
  - Contrato de payload normalizado (`tab`/`initialTab` + fallback por `type`) y handler background en `main.dart`.
- **Fuente operativa única:** `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (A1 + “Ejecución guiada A1”).
- **Próximo paso al retomar:** ejecutar secuencia 1→7 de la checklist y registrar evidencia mínima (foreground/background/terminada).
- **Vinculación con lista viva:** corresponde al ítem **109** de `docs/testing/LISTA_PUNTOS_CORREGIR_APP.md` (estado técnico en curso).

#### Evidencia de ejecución A1 (2026-04-06)

- **Dispositivos detectados en entorno Flutter:**
  - iPhone físico: `00008030-001869E83699402E` (iOS 26.3.1)
  - Simulador usado en sesión activa: `92BC16E4-58CA-43E0-BABC-8F32C2DF4D7A`
- **Estado de la ejecución:** en curso.
- **Hito técnico validado (retomable):**
  - En iPhone físico ya se crea `users/{userId}/fcmTokens/{token}` con `platform=ios`, `osVersion`, `token`, `createdAt`, `updatedAt`.
- **Incidencia previa resuelta:**
  - Error `apns-token-not-set` mitigado con ajustes en iOS (`Runner.entitlements`, `CODE_SIGN_ENTITLEMENTS`, `FirebaseAppDelegateProxyEnabled`) + registro APNs en `AppDelegate` y trazas de diagnóstico.
- **Motivo de pausa actual:** no se ejecutan ahora las pruebas de envío push desde Firebase Console (falta tiempo en la sesión).
- **Checklist operativa (A1, pasos 1→7):**
  - Paso 1 (token en Firestore): **hecho** (token persistido en `fcmTokens` en iPhone físico).
  - Paso 2 (foreground): pendiente (envío real).
  - Paso 3 (background + tap): pendiente.
  - Paso 4 (terminada + tap): pendiente.
  - Paso 5 (tab explícita): pendiente.
  - Paso 6 (payload resiliente): pendiente.
  - Paso 7 (cierre): pendiente.
- **Próximo paso al retomar (directo):**
  - Enviar push de prueba por token (foreground), luego background y terminada, y registrar evidencia mínima por escenario.

### A2 — Deep link de invitación en iOS

- **Plataforma:** iOS  
- **Flujo:** abrir link de invitación desde Mail/Safari → app en pantalla de invitación/plan.  
- **Objetivo:** Universal Links o URL scheme + dominio/AASA + Associated Domains en Xcode.  
- **Estado:** parcial — checklist (A2); tarea relacionada **T259**.  
- **Alineación de flujo:** ver `docs/flujos/FLUJO_INVITACIONES_NOTIFICACIONES.md` (invitaciones/notificaciones) y `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (A2 operativo).

---

*Cuando A1/A2 queden cerrados en la práctica, actualizar este archivo o mover la nota a `TASKS.md` / release notes.*
