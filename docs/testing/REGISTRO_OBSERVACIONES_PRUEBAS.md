# Registro de observaciones durante las pruebas

> Documento para ir anotando lo que vas viendo mientras pruebas. Los huecos/errores que den lugar a tareas se pueden llevar también a la sección 19 y 20 del [Plan E2E tres usuarios](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md).  
> **La sección "MIS NOTAS" debe quedar siempre al final.** Ahí vas **tus cosas** (opiniones, ideas, observaciones personales), no el resultado formal de las pruebas (✅/❌ por paso va en el Plan E2E, sección 19 y 20).

---

## Datos de sesión (UA, UB, UC y plan smoke)

### Sesión actual — matriz multiplataforma (Ago 2026)

Pruebas con **iPhone (UA) + Android (UB) + Chrome (UC)**. Ver matriz en [`USUARIOS_PRUEBA.md`](../configuracion/USUARIOS_PRUEBA.md#matriz-mínima-multiplataforma-3-usuarios--3-dispositivos).

| Rol | Dispositivo | Username | Nombre | Email | Notas |
|-----|-------------|----------|--------|-------|-------|
| **UA** | iPhone físico | `uaua` | `ua` | `unplanazoo+ua@gmail.com` | Creado 2026-08-09 desde cero. Organizador. |
| **UB** | Android físico (SM A715F) | `ubub` | `u b` | `unplanazoo+ub@gmail.com` | Registrado tras invitación por email; aceptó desde notificaciones in-app. |
| **UC** | Chrome (web) | `ucuc` | `u c` *(o `uc`, según registro)* | `unplanazoo+uc@gmail.com` | Creado 2026-08-09. Invitado y aceptado (mismo plan que UA/UB). |

- **Contraseña:** la habitual de prueba del proyecto (**no** escribir aquí ni en el repo). Misma para UA/UB/UC.
- **Estado:** **UA + UB + UC** en el mismo plan (matriz multiplataforma completa). Listos para chat / calendario / resto de sesión corta.
- **Plan de esta sesión:** `altas-bajas agosto 2026` — guion altas/bajas en curso (UA crea; UB/UC aún no invitados a este plan al inicio del guion).
- **Plan smoke anterior (matriz corta):** *(el del chat/calendario previo; distinto de este)*.

### Observaciones sesión multiplataforma (2026-08-09)

| # | Resultado | Nota |
|---|-----------|------|
| Email invitación UB | ✅ | Llegó a Gmail |
| Registro UB con email invitado | ✅ | En Android |
| Notificación in-app de invitación | ✅ | Visible tras login |
| Nombre del plan en la notificación | ❌→fix | Mostraba `planId`; corregido en código (ítem LISTA **113**) — hot restart / reinstall para verlo |
| Aceptar desde notificación | ✅ | Entra al plan; **lento** (anotar como mejora de latencia) |
| Tras aceptar: plan visible + avisos leídos/desaparecen | ✅ | Comportamiento esperado |
| UA ve a UB en Participantes | ✅ | |
| UA recibe aviso «UB aceptó» | ⚠️ | **6 notificaciones idénticas** (ítem LISTA **114**). Causa: carrera al aceptar lento sin bloquear botón + sin dedupe. Corregido en código (dedupe + botón busy + no re-notificar si ya accepted). |
| UB datos | ✅ | username `ubub`, nombre `u b`, email `unplanazoo+ub@gmail.com` |
| UC registro + invitación + aceptar (web) | ✅ | `ucuc` / `unplanazoo+uc@gmail.com` — matriz 3 dispositivos cerrada para altas |
| Chat multiplataforma | ✅ | Funciona bien entre iPhone / Android / web |
| Evento en calendario visible en los 3 | ✅ | Creado y visto en UA, UB y UC |

**Ideas (no implementadas):** notificaciones de chat agrupadas (no un push por mensaje).

**Siguiente paso sugerido:** guion altas/bajas con **plan nuevo** (ver chat / checklist abajo).

### Guion QA — altas/bajas (plan nuevo, Ago 2026)

Usuarios: UA `uaua` (iPhone), UB `ubub` (Android), UC `ucuc` (web).  
Marcar ✅/❌/⚠️ en cada paso. Gaps conocidos del diagrama: T268, modal al abrir, deep link §2, mensajes §1.2 B–I, buzón «Mis invitaciones».

**Prep:** UA crea plan nuevo (anotar nombre: `altas-bajas agosto 2026`). No invitar aún. ✅  
**1.1** Invitar UC → pendiente + campana UC. ✅  
**1.2** Reinvitar (email) con pending: ✅ **1** ítem en campana UC (validado 2026-08-10). Ítem **115**.  
**1.3** UC rechaza: limpia campana; UC en lista **fuera**; aviso a UA. ✅  
**1.4** Re-invitar tras rechazo: ✅ email + lista/menú ⋮ «Re-enviar» (validado 2026-08-10). Ítem **116**.  
**1.5** UC acepta: entra (**in** / participante); UA ve dentro + notificaciones. ✅  
**1.6** Ya dentro: no en lista invitar; por email modal «ya es participante». ✅  
**1.7** Auto-invitación: igual que 1.6 (filtrado / «ya es participante»). ✅  
**1.8** Invitar UB + aceptar: OK en app. ⚠️→✅ Push fuera de app validado (2026-08-09): banner + tap abre modal aceptar/rechazar. Ítem **117**.
**3.1** Cancelar pendiente: ✅ validado (menú Cancelar invitación). Ítem **118**.
**3.2** UC sale (Info / chip → Salir): **salida total** + aviso organizador ✅ (2026-08-10). Ítem **119**.  
**3.3** Re-invitar tras salida (lista) + UC acepta: ✅  
**3.4** UA elimina a UB: ✅ datos + **aviso** (banner/campana) validado. Ítem **120**.
**3.5** Re-invitar UB tras expulsión + aceptar: ✅  

**Guion altas-bajas `altas-bajas agosto 2026`:** cerrado (incl. **119** validado 2026-08-10).

### Sesión E2E histórica (referencia)

- **Contraseña:** no guardar en este documento (quedaría en el repo). Usar gestor de contraseñas o anotar solo en local. Misma para los tres.
- **Usuario UA (histórico):** username `cricla` / email `unplanazoo+cricla@gmail.com` — idioma **español**, misma zona horaria que UB (**Madrid (GMT+1)**).
- **Usuario UB (histórico):** email `unplanazoo+marbat@gmail.com` — idioma **español**, **misma zona horaria que UA** (**Madrid (GMT+1)**).
- **Usuario UC (histórico):** email `unplanazoo+emmcla@gmail.com` — idioma **inglés**, **otra zona horaria que UA/UB** (**Londres (GMT+0)**).
- **Plan smoke:** **Egipto Semana Santa 2026**, del 28/03/2026 al 04/04/2026.
- **Plan E2E (ciclo tres usuarios):** **Buenos Aires Marzo 2026** — del **23/03/2026** al **29/03/2026**, zona horaria Buenos Aires (GMT-3), moneda Euros.
- **Estado histórico:** UA, UB y UC creados; plan E2E creado (ciclo anterior).

**Usuario UD (para más adelante):** No registrado inicialmente. Alias `matcla` / email `unplanazoo+matcla@gmail.com` — idioma **español**, zona horaria **Nueva York (GMT-5)**. Crear cuando se quiera probar un cuarto invitado (p. ej. flujo “invitar a no registrado” adicional); tras registro: Perfil → Español, Configurar zona horaria = America/New_York.

---

## Cambios recientes (documentación y funcionalidad)

- **Invitaciones:** Invitar **desde la lista de usuarios** (además de por email): se crea invitación pendiente, el invitado recibe notificación y puede aceptar/rechazar. **El organizador recibe notificación** cuando el invitado acepta o rechaza. En la página de Participantes, el organizador ve la sección **"Invitaciones"** con el estado de cada una (Pendiente, Aceptada, Rechazada, Cancelada, Expirada). Flujos: `FLUJO_INVITACIONES_NOTIFICACIONES.md` § 1.2, `FLUJO_GESTION_PARTICIPANTES.md` § 1.2.
- **Salir del plan:** Un participante (no organizador) puede **salir del plan** desde Info del plan o desde la pestaña Participantes; confirmación y eliminación de su participación. `FLUJO_GESTION_PARTICIPANTES.md` § 2.5. Casos de prueba: `TESTING_CHECKLIST.md` § 6.4 (PART-D-002, PART-LEAVE-001) y § 7.1.6 (INV-024, INV-024b, INV-024c).
- **T225 - Google Places en alojamientos y eventos:** En el **modal de alojamiento**: primer campo de búsqueda con Places; al seleccionar un resultado se rellenan nombre y dirección; campo Dirección visible; tarjeta de ubicación y botón "Abrir en Google Maps"; datos guardados en commonPart.extraData. En el **modal de evento**: campo "Lugar" con autocompletado Places; tarjeta de ubicación y enlace a Google Maps; location + extraData. Configuración: `docs/configuracion/CONFIGURAR_GOOGLE_PLACES_API.md`. Casos de prueba: `TESTING_CHECKLIST.md` § 5.5 (ACC-PLACES-001 a 004) y § 4.1 (EVENT-C-018, EVENT-C-019). Flujos: `FLUJO_CRUD_ALOJAMIENTOS.md`, `FLUJO_CRUD_EVENTOS.md`.
- **T246 - Número de vuelo en eventos desplazamiento:** En evento tipo **Desplazamiento / Avión** aparece el campo "Número de vuelo" (ej. IB6842) y el botón "Obtener datos del vuelo". La Cloud Function `flightStatus` consulta Amadeus On-Demand Flight Status y rellena descripción, fecha, hora y duración; se guarda en extraData (flightNumber, originIata, destinationIata, etc.). Configuración: `docs/configuracion/CONFIGURAR_AMADEUS_FLIGHT_STATUS.md`. Casos de prueba: `TESTING_CHECKLIST.md` § 4.1 (EVENT-C-020, EVENT-C-021). Flujo: `FLUJO_CRUD_EVENTOS.md`.

---

## Acciones pendientes (revisar luego)

- [ ] **Borrado total de cuenta:** Al eliminar cuenta, falla con `permission-denied` (tras "Deleted 0 events"). Revisar: reglas Firestore para todas las estructuras que toca `UserService.deleteAllUserData` (p. ej. `plans/{planId}/userPreferences/{userId}` ya tenía regla añadida; confirmar despliegue de reglas y volver a probar USER-D-007). Ver `TESTING_CHECKLIST.md` § 3.5.1.
- [ ] **Espacio admin para gestionar toda la BD (RUD + huérfanos):** Panel admin para leer/actualizar/eliminar documentos (Firestore + Auth), eliminar usuario completo con relacionados, y **detectar documentos huérfanos** (referencias a usuarios/planes/eventos ya eliminados: p. ej. participations, events, event_participants, invitations con IDs inexistentes). Ver **T223** en `docs/tareas/TASKS.md` § Administración.

---

## MIS NOTAS
INSTRUCCIONES PARA EL PROMPT
Esta sección no es una tarea, es para dar contexto a la IA. Nno codigiques. dentro del documento @docs/testing/REGISTRO_OBSERVACIONES_PRUEBAS.md  hay una seccion con mis notas. De es lista crea las tareas necesarias. Hazme todas las preguntas que necesites en cada tarea para dejarla bien documentada. una vez creada la tarea, marca el texto dentro de MIS NOTAS añadiendo un "*" al principio de la frase y cambiandola de color. Así sabremos lo que has pasado a Tareas. 

*(Tus notas, opiniones e ideas — no el resultado formal de las pruebas.)*