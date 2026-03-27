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

### A2 — Deep link de invitación en iOS

- **Plataforma:** iOS  
- **Flujo:** abrir link de invitación desde Mail/Safari → app en pantalla de invitación/plan.  
- **Objetivo:** Universal Links o URL scheme + dominio/AASA + Associated Domains en Xcode.  
- **Estado:** parcial — checklist (A2); tarea relacionada **T259**.  

---

*Cuando A1/A2 queden cerrados en la práctica, actualizar este archivo o mover la nota a `TASKS.md` / release notes.*
