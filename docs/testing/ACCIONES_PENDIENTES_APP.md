# Acciones pendientes (seguimiento fuera de la lista viva)

**Propósito:** concentrar lo que **sigue abierto** cuando `LISTA_PUNTOS_CORREGIR_APP.md` se usa solo para **nuevos** hallazgos.

**Última actualización:** 2026-03-12

---

## Infra iOS (antes P1 / P2 en la lista histórica)

Referencias cruzadas: `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md`, `docs/configuracion/REVISION_IOS_VS_WEB.md`.

### A1 — Notificaciones push iOS (APNs / FCM)

- **Plataforma:** iOS  
- **Flujo:** notificaciones push (primer plano / segundo plano / al abrir desde notificación).  
- **Objetivo:** APNs + FCM correctos; notificaciones fiables y navegación al sitio adecuado al tocar.  
- **Estado:** parcial — checklist en `CHECKLIST_IOS_PUSH_DEEPLINKS.md` (A1); falta validación completa en dispositivo y proyecto Firebase/APNs.
- **Avance 2026-04-06 (código):** `FCMService` reforzado con inicialización idempotente por usuario, cancelación de listeners para evitar duplicados (`onTokenRefresh`, `onMessage`, `onMessageOpenedApp`) y `setForegroundNotificationPresentationOptions` en iOS.
- **Avance 2026-04-06 (navegación tap push):** handler central en `App` (`navigatorKey`) + `FCMService.setNotificationTapHandler`; si el payload trae `planId`/`plan_id`, abre `PlanDetailPage` (opcional `tab`/`initialTab`).
- **Avance 2026-04-06 (contrato payload):** normalización/validación de pestaña destino (`tab`/`initialTab`) + fallback por `type` (`chat`, `planNotifications`, `payments`) documentado en `CHECKLIST_IOS_PUSH_DEEPLINKS.md`.
- **Avance 2026-04-06 (background):** `main.dart` registra `FirebaseMessaging.onBackgroundMessage(...)` con handler top-level para recepción en segundo plano.
- **Checklist operativa:** ejecutar `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` sección **“Ejecución guiada A1 (iOS push)”** y registrar evidencia (foreground/background/terminada).
- **Estado de ejecución (2026-04-06):** implementación de código preparada; **pruebas en dispositivo físico pendientes** por no disponer de iPhone en este momento.
- **Próximo paso al retomar:** iniciar por “Paso 1 — Verificar token FCM en Firestore” y continuar secuencia 2→7 de la checklist operativa.

### A2 — Deep link de invitación en iOS

- **Plataforma:** iOS  
- **Flujo:** abrir link de invitación desde Mail/Safari → app en pantalla de invitación/plan.  
- **Objetivo:** Universal Links o URL scheme + dominio/AASA + Associated Domains en Xcode.  
- **Estado:** parcial — checklist (A2); tarea relacionada **T259**.  

---

*Cuando A1/A2 queden cerrados en la práctica, actualizar este archivo o mover la nota a `TASKS.md` / release notes.*
