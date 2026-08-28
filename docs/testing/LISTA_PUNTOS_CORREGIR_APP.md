## Lista de puntos a corregir en la app (solo abiertos)

**Objetivo:** mantener aquí solo los puntos **pendientes / en progreso** de QA.  
**Proceso:** capa 3 del sistema → [`docs/flujos/MAPA_FLUJOS.md`](../flujos/MAPA_FLUJOS.md).  
**Dominio (opcional al anotar):** citá el dominio del MAPA (ej. participantes, eventos, pagos) para cruzar con `TASKS.md` § Índice por dominio.

**Histórico de cerrados:** [`archivo/`](./archivo/) (`ARCHIVO_LISTA_*`, ACCIONES_PENDIENTES).

### Cruce rápido dominio ↔ hallazgos

| Dominio | Notas / IDs frecuentes |
|---------|------------------------|
| Participantes / invitaciones | Cerrado 2026-08-27 — T259 iOS ✅; restos fuera de WIP |
| Planes | Cascada borrar **126**/**127** cerrados (T277 P16, 2026-08-18) |
| Eventos / calendario | T278 CRUD agente (fase 1); ítems de formularios y FAB |
| Pagos | PAY-* / ítems 101–107 · T222 |
| Offline | Ítem 58 cerrado documentalmente; roadmap T56–T62 / T265 |
| UI / navegación | Ítems 63–65 → T263–T265 |

---

### 1. Información del build (rellenar en cada ronda)

- **Versión de la app**:
- **Origen**: TestFlight / Web / Android / …
- **Fecha de la ronda de pruebas**:
- **Build ID (si aplica)**:

---

### 2. Cómo anotar cada punto nuevo

- **ID**: siguiente libre **128**.
- **Plataforma**: iOS / Web / Ambas / …
- **Pantalla / flujo**.
- **Tipo**: bug / mejora / copy / producto / discusión.
- **Gravedad**: alta / media / baja.
- **Descripción breve**.
- **Estado**: pendiente / en progreso / hecho.

> Al cerrar un punto: moverlo al archivo histórico del periodo para que esta lista siga limpia.

---

### 3. Resumen actual

- **Pendientes:** 14 (**123** deep link web; **125** create plan iOS overflow — validar; **126–129**, **132–141** abiertos; **130–131** cerrados 2026-08-27)
- **En progreso:** 0
- **Siguiente ID libre:** **142**
- **Hechos/cerrados en histórico:** 76+ (incluye **111–122**; **126–127** cascada borrar plan, 2026-08-18; **130–131** Mi resumen UI, 2026-08-27)

### Cola humana (dispositivo) — no agente

Aplazado a propósito (2026-08-18) mientras el agente cubre tests de CRUD:

- **T277 P5:** crear un plan en la app (web / iOS / Android) y verlo en la lista.
- **125:** validar en iPhone el overflow del modal al crear plan (fix ya en código; hace falta hot restart).
- **T259:** iOS Mail→HTTPS Universal Link **OK** (2026-08-27). Android `assetlinks.json` opcional.
- **124:** validar en dispositivo reabrir el mismo link de invitación + una invitación nueva.
- **123:** deep link web `/invitation/{token}` (código listo; validación aplazada).

---

### 4. Puntos abiertos

#### 141. Visibilidad del plan (público / privado) — opción futura
- **Plataforma:** todas
- **Pantalla / flujo:** Info del plan · discovery / plantillas · reglas de acceso
- **Tipo:** producto / funcionalidad futura
- **Gravedad:** baja (aplazado a propósito)
- **Descripción breve:** Campo `Plan.visibility` (`private`|`public`) y rules Firestore ya existen; create plan fuerza `private`. **Quitado de Info del plan** (2026-08-27) porque aún no hay producto real (listados públicos, copiar plantilla, etc.). Reintroducir UI + flujos cuando haya discovery / planes públicos.
- **Estado:** pendiente — opción futura
- **Gate de lanzamiento:** no
- **Referencias:** `plan.dart` (`visibility`); `firestore.rules`; create plan; LISTA / docs flujo público-privado

#### 140. UX formularios móvil tipo iOS — patrón D
- **Plataforma:** iOS / Android (prioridad; web mismo widget)
- **Pantalla / flujo:** Info del plan · modal evento · alojamiento
- **Tipo:** UX / diseño
- **Gravedad:** media
- **Descripción breve:** Patrón **D** (Settings + iOS dark). **Evento/alojamiento:** formulario único siempre editable + Cancelar/Guardar + chip estado (verde/naranja) junto a duración/noches. **Info plan:** aún view/edit. Spec: `GUIA_UI.md` § formularios tipo ficha.
- **Estado:** evento/alojamiento implementado — validar en dispositivo; Info plan pendiente de alinear
- **Gate de lanzamiento:** sí (legibilidad formularios)
- **Referencias:** `GUIA_UI.md`; `ios_grouped_form.dart`; `wd_plan_data_screen.dart`; `wd_event_dialog.dart`; `wd_accommodation_dialog.dart`; LISTA 126, 129, 130

#### 139. Detección de conflictos entre planes (inter-plan)
- **Plataforma:** todas
- **Pantalla / flujo:** Vista global del usuario / calendario personal
- **Tipo:** funcionalidad nueva (diferencial competitivo)
- **Gravedad:** media
- **Descripción breve:** Cuando un usuario participa en varios planes activos, detectar solapamientos de eventos entre planes distintos. Requiere consultar eventos de todos los planes del usuario y cruzar horarios. Complementa LISTA 138 (intra-plan). Caso de uso: familia con plan "Verano", plan "Trabajo" y plan "Boda del primo" — el martes tiene eventos en los tres. Relacionado con la consideración de Planoon como planificador recurrente/familiar (no solo viajes puntuales): si la gente usa varios planes a la vez, los conflictos entre ellos son inevitables.
- **Estado:** pendiente — diseñar
- **Gate de lanzamiento:** no (P2; depende de vista multi-plan)

#### 138. Detección automática de conflictos/solapamientos entre eventos
- **Plataforma:** todas
- **Pantalla / flujo:** Calendario / creación-edición de evento
- **Tipo:** funcionalidad nueva (diferencial competitivo)
- **Gravedad:** media
- **Descripción breve:** Detectar y avisar cuando dos eventos se solapan en horario para un mismo participante dentro de un mismo plan (ej. vuelo llega a las 10h pero tiene evento a las 9h). Ningún competidor lo hace. Bajo-medio esfuerzo, alto impacto. Para conflictos entre planes distintos, ver LISTA 139.
- **Estado:** pendiente — diseñar
- **Gate de lanzamiento:** sí

#### 137. Historial de cambios del plan ("qué cambió desde tu última visita")
- **Plataforma:** todas
- **Pantalla / flujo:** Entrada al plan / resumen
- **Tipo:** funcionalidad nueva (diferencial competitivo)
- **Gravedad:** media
- **Descripción breve:** Badge "N cambios desde tu última visita" + vista diff: "La cena se movió de 20h a 21h", "Nuevo evento: Tour guiado". Especialmente útil para el participante pasivo que abre la app de vez en cuando. Complementa LISTA 133 (avisos de cambios CRUD). Ningún competidor lo tiene.
- **Estado:** pendiente — diseñar
- **Gate de lanzamiento:** sí

#### 136. Vista "¿Qué hago ahora?" para el participante no-planificador
- **Plataforma:** todas (especialmente móvil)
- **Pantalla / flujo:** Pantalla principal / resumen del plan
- **Tipo:** funcionalidad nueva (diferencial competitivo)
- **Gravedad:** alta
- **Descripción breve:** Pantalla ultra-simple para el viajero pasivo: "Ahora → [evento actual]. Después → [siguiente evento + hora]". Sin calendario complejo, solo mi próximo evento + cómo llegar. Opcionalmente push contextual ("En 30 min: salida al aeropuerto"). Resuelve la queja más común de Wanderlog/TripIt: "no sé qué toca ahora". Ningún competidor lo tiene.
- **Estado:** pendiente — diseñar
- **Gate de lanzamiento:** sí

#### 135. Rendimiento móvil: offline-first como principio de UX
- **Plataforma:** iOS / Android
- **Pantalla / flujo:** Toda la app
- **Tipo:** principio de arquitectura / UX
- **Gravedad:** alta
- **Descripción breve:** El rendimiento en móvil es lo que hace o rompe la app (lección Wanderlog). Offline-first (Firestore cache + operaciones locales inmediatas) es la clave: la UI responde al instante, la sincronización ocurre en background. Nada debe "tardar" ni requerir tocar dos veces. Revisar que todos los CRUD principales (eventos, alojamientos, participantes, pagos) funcionen con percepción instantánea. Relacionado: T56–T62, T265.
- **Estado:** pendiente — auditar flujos principales
- **Gate de lanzamiento:** sí (parcial: los flujos core deben ser fluidos)

#### 134. Pagos: mostrar conversión de moneda inline (equivalencia visible)
- **Plataforma:** todas
- **Pantalla / flujo:** Pagos / presupuesto
- **Tipo:** mejora UX
- **Gravedad:** media
- **Descripción breve:** Al registrar o ver un pago en moneda extranjera, mostrar la equivalencia en la moneda del usuario/plan junto al importe original. La base existe (T153 multi-moneda); falta mostrarlo inline en la UI de pagos. Lección Wanderlog: presupuesto sin conversión visible es inútil.
- **Estado:** pendiente
- **Gate de lanzamiento:** sí (fase 2 pagos)

#### 133. Avisos configurables de cambios CRUD en eventos del plan
- **Plataforma:** todas
- **Pantalla / flujo:** Configuración del plan / participante
- **Tipo:** funcionalidad nueva (avisos)
- **Gravedad:** alta
- **Descripción breve:** Opción configurable para que ciertos participantes reciban avisos (campana/push/email) cuando se crean, editan o borran eventos dentro de un plan. Aplica tanto en fase de planificación como durante el viaje. Debe ser una opción por participante o por plan (decidir granularidad).
- **Estado:** pendiente — diseñar
- **Gate de lanzamiento:** sí

#### 132. Notificaciones en dispositivo: falta botón "marcar todas como leídas"
- **Plataforma:** iOS / Android
- **Pantalla / flujo:** Notificaciones
- **Tipo:** paridad web → móvil
- **Gravedad:** media
- **Descripción breve:** En web existe el botón "marcar todas como leídas"; en dispositivo no aparece. Usar icono (sin texto) para que quepa bien.
- **Estado:** pendiente
- **Gate de lanzamiento:** sí

#### 129. UX general: contraste y tamaños de letra desiguales
- **Plataforma:** iOS / Android (parcialmente web)
- **Pantalla / flujo:** Varias pantallas, especialmente resumen del plan
- **Tipo:** UX / diseño
- **Gravedad:** media
- **Descripción breve:** Falta contraste texto/fondo en algunas zonas. Tamaños de letra desiguales entre pantallas. Revisar y unificar según GUIA_UI.
- **Estado:** pendiente
- **Gate de lanzamiento:** sí (parcialmente; lo que afecte legibilidad)

#### 128. Calendario dispositivo: filtro por participante (mis eventos / seleccionados / todos)
- **Plataforma:** iOS / Android
- **Pantalla / flujo:** Vista calendario
- **Tipo:** mejora funcional
- **Gravedad:** media
- **Descripción breve:** Poder filtrar para ver solo mis eventos, los de participantes seleccionados, o todos. Pensar UX cuando hay muchas columnas (muchos participantes) en un mismo día.
- **Estado:** pendiente
- **Gate de lanzamiento:** no (mejora para luego)

#### 127. Columnas de participantes en dispositivo: eventos no se distribuyen correctamente
- **Plataforma:** iOS / Android (en web funciona bien)
- **Pantalla / flujo:** Vista calendario con eventos asignados a participantes concretos
- **Tipo:** bug funcional
- **Gravedad:** alta
- **Descripción breve:** Los eventos asignados a solo algunos participantes no se colocan en la columna correcta de cada participante en dispositivo. En web sí lo hace correctamente.
- **Estado:** pendiente
- **Gate de lanzamiento:** sí

#### 126. Modal de evento: separar visualización de edición
- **Plataforma:** todas
- **Pantalla / flujo:** Abrir evento existente
- **Tipo:** UX / producto
- **Gravedad:** media
- **Descripción breve:** En modo visualización sobran muchos campos del formulario de edición. **Hecho (patrón D):** formulario único siempre editable + Cancelar/Guardar + chip estado en hero (`EventDialog`; alineado con alojamiento).
- **Estado:** implementado — validar en dispositivo
- **Gate de lanzamiento:** sí
- **Referencias:** `wd_event_dialog.dart`; `GUIA_UI.md` § formularios tipo ficha; LISTA 140

#### 125. Crear plan iOS: overflow amarillo/negro al validar nombre (<3 chars) + texto UNP ID
- **Plataforma:** iOS
- **Pantalla / flujo:** Lista planes → Crear plan
- **Tipo:** bug UI
- **Gravedad:** media
- **Descripción breve:** El error «mínimo 3 caracteres» desbordaba el `AlertDialog`; además se mostraba «Generando UNP ID…» / ID innecesario.
- **Fix:** `SingleChildScrollView` + `errorMaxLines`; ocultar línea UNP ID en modal móvil (el ID se sigue generando en background).
- **Estado:** implementado — pendiente hot restart / validar
- **Referencias:** `pg_plans_list_page.dart` `_CreatePlanModal`

#### 124. Aceptar invitación por deep link: errores permission-denied / “already participates”
- **Plataforma:** iOS (log 2026-08-16)
- **Pantalla / flujo:** Mail → `app.planoon.com/invitation/{token}?action=accept`
- **Tipo:** bug / ruido de reintento
- **Gravedad:** media (el flujo a veces termina; log ruidoso; side effects pueden fallar)
- **Descripción breve:** Tras deep link: `already participates`, `acceptInvitation` / `onParticipantJoined` → `permission-denied`, CF `markInvitationAccepted` → «no encontrada o ya procesada», luego relectura del token → `permission-denied`. Encaja con **re-aceptar** una invitación ya procesada o participación ya `accepted`; conviene reproducir con **invitación nueva** y endurecer idempotencia (si ya está dentro → ir al plan sin error).
- **Fix (2026-08-16):** accept idempotente (`alreadyMember` + `planId`); `createParticipation` pending→accepted con `autoAccept`; side effects A2 no tumba el accept; CF `resolveInvitationByToken` + `markInvitationAccepted` idempotente; re-tap del mail → plan.
- **Estado:** implementado — **pendiente validar** en dispositivo (re-abrir mismo link + invitación nueva)
- **Referencias:** T259; `PlanParticipationService.acceptInvitation`; `InvitationService.acceptInvitationBy*`; rules `plan_invitations`

#### 123. Deep link `/invitation/{token}` (web §2)
- **Plataforma:** web (nativo = T259 aparte)
- **Pantalla / flujo:** Abrir enlace del email de invitación
- **Tipo:** gap diagrama §2 + §1.2 J/K
- **Gravedad:** alta (botón Aceptar del mail)
- **Descripción breve:** La ruta no se procesaba; `InvitationPage` eliminada.
- **Fix:** ruta pública + `InvitationPage`; doc ID = token; accept/reject by token con check email; login/registro en página; `?action=accept|reject`.
- **Estado:** **pendiente** (2026-08-10) — código listo (ruta + `InvitationPage` + J/K); **aplazamos validación/cierre**. Nativo Universal Links = T259.
- **Cómo probar:** nueva invitación → id del doc en `plan_invitations` = token → `http://localhost:<puerto>/invitation/<token>`. El mail CF usa `APP_BASE_URL` (prod).

#### 122. Email al invitar / reenviar a usuario ya registrado
- **Plataforma:** todas
- **Pantalla / flujo:** Participantes → invitar por email (registrado) · reenviar pending · re-invitar tras rechazo
- **Tipo:** gap diagrama §1.1 decisión 1
- **Gravedad:** media
- **Descripción breve:** Solo campana+push; el correo solo salía al crear `plan_invitations` (usuarios sin cuenta). Invitación directa no creaba doc → no email.
- **Fix:** al invitar registrado se cancela `plan_invitations` pending previos, se crea uno nuevo (CF `sendInvitationEmail`) y campana/push con token real.
- **Estado:** implementado y **validado** (2026-08-10) — correo al invitar/reenviar registrado; enlace → deep link §2 (web).
- **Referencias:** `DIAGRAMA_ALTAS_BAJAS_PLAN.md` §1.1; `InvitationService.createInvitation`; `functions` `sendInvitationEmail`.

#### 121. Alta/baja de participante: ¿qué pasa con eventos, alojamientos y tracks?
- **Plataforma:** todas
- **Pantalla / flujo:** Aceptar invitación · salir del plan · expulsar
- **Tipo:** producto / gap (contrato vs código)
- **Gravedad:** alta (afecta calendario, cupos, presupuesto)
- **Descripción breve:** El diagrama de altas/bajas no lo cubre. `FLUJO_GESTION_PARTICIPANTES.md` sí prevé side effects (track, asignar a eventos futuros, limpieza al expulsar). Hoy la app **no** auto-asigna al aceptar; al salir/expulsar borra `plan_participations` + `event_participants` + permisos, pero **no** limpia `participantTrackIds`/`participantIds` en eventos/alojamientos ni el track.
- **Hoy (código):**
  - Aceptar → solo `accepted` (+ aviso org).
  - Salir/expulsar → `removeParticipation` (event_participants + permissions + doc participación).
- **Opciones a acordar (alta / aceptar):**
  - **A1** — No auto-asignar: el nuevo miembro entra al plan vacío de asignaciones; el org (o él) le apunta a eventos/alojamientos.
  - **A2** — Auto en eventos/alojamientos marcados «para todos» (`isForAllParticipants`); el resto no.
  - **A3** — Preguntar al aceptar («¿Apuntarte a los eventos comunes?»).
  - **A4** — Crear track siempre; asignación a eventos = A1 o A2.
- **Opciones a acordar (baja / salir o expulsar):**
  - **B1** — Solo lo de hoy (event_participants + participación); dejar IDs huérfanos en eventos/alojamientos (filtro UI por membresía).
  - **B2** — Además quitar `userId` de `participantIds` / `participantTrackIds` en eventos y alojamientos futuros; borrar track; no borrar eventos compartidos.
  - **B3** — Como B2 + borrar eventos futuros **solo suyos** (como dice §3 del flujo participantes).
- **Acuerdo (2026-08-10):** **A2 + B2 + B3**.
  - **Alta:** auto en eventos/alojamientos futuros con `isForAllParticipants` (arrays + confirmaciones T120 si aplica).
  - **Baja:** quitar de arrays futuros (B2); **borrar** ítems futuros donde era el único participante selectivo (B3); aviso en diálogo de salir/expulsar.
- **Estado:** acordado, implementado y **validado** (2026-08-10) — A2+B2+B3; diálogo previo; notificación al org con ítems borrados.
- **Referencias:** `FLUJO_GESTION_PARTICIPANTES.md` §2/§3; `DIAGRAMA_ALTAS_BAJAS_PLAN.md` §1.4; `PlanMembershipSideEffects`.

#### 120. Expulsar participante: ¿debe notificar al expulsado?
- **Plataforma:** Android (UB) / todas
- **Pantalla / flujo:** UA elimina a UB del plan
- **Tipo:** producto / gap diagrama §3
- **Gravedad:** media
- **Descripción breve:** Tras eliminar, UB deja de ver el plan correctamente, pero **no** recibía campana ni push.
- **Decisión:** sí avisar (campana + push).
- **Estado:** corregido y **validado** (2026-08-09) — banner/campana al expulsar; plan desaparece para el expulsado.
- **Origen:** guion `altas-bajas agosto 2026` paso 3.4 (2026-08-09).

#### 119. Menú / UX pestaña Participantes a revisar
- **Plataforma:** todas
- **Pantalla / flujo:** Participantes (acciones por fila, pendientes, salir)
- **Tipo:** mejora / revisión UX
- **Gravedad:** media
- **Descripción breve:** Tras probar altas-bajas: menú Editar/Eliminar no coherente con pendientes; salida desde Info borra del todo (no estado «fuera» como rechazo). Revisar menú y alineación con diagrama §1/§3.
- **Acuerdo (2026-08-10):** salir = **borrar** participación (opción A); **sí** avisar al organizador (campana + push). Distinto de rechazo («fuera»).
- **Estado:** corregido y **validado** (2026-08-10) — menús por estado OK; aviso `participantLeft` al salir (campana + push).
- **Origen:** guion `altas-bajas agosto 2026`.

#### 118. Cancelar invitación pendiente: sin menú en UI (Participantes)
- **Plataforma:** iOS (UA) / probablemente todas
- **Pantalla / flujo:** Participantes — fila con estado pendiente
- **Tipo:** bug / gap diagrama §3
- **Gravedad:** alta (bloquea cancelar desde app)
- **Descripción breve:** El pendiente aparece en la lista, pero no muestra el menú «Editar» / «Eliminar» (sí visible en otros participantes). No se puede cancelar la invitación desde la UI.
- **Estado:** corregido y **validado** (2026-08-09) — menú «Cancelar invitación» elimina el pendiente.
- **Origen:** guion `altas-bajas agosto 2026` paso 3.1 (2026-08-09).

#### 117. Push fuera de app al invitar (Android UB) no llega
- **Plataforma:** Android
- **Pantalla / flujo:** UA invita a UB registrado → UB debería recibir FCM en background/cerrada
- **Tipo:** bug / gap (T267 / diagrama §1.1)
- **Gravedad:** media
- **Descripción breve:** En guion `altas-bajas agosto 2026`, UB vio la invitación en campana in-app y pudo aceptar, pero **no** recibió notificación del sistema fuera de la app.
- **Causa raíz (2026-08-09):** sin `POST_NOTIFICATIONS` en manifest; FCM solo pedía permiso en iOS; canal `planazoo_default` (CF) no se creaba en el dispositivo.
- **Estado:** corregido y **validado** (2026-08-09) — banner Android + tap abre modal aceptar/rechazar.
- **Origen:** 2026-08-09 sesión multiplataforma.

#### 116. Re-invitar tras rechazo: no disponible desde lista de participantes
- **Plataforma:** iOS (UA) / todas
- **Pantalla / flujo:** Participantes — usuario en estado «fuera» / rejected
- **Tipo:** mejora / gap UX (diagrama §1 caso 3)
- **Gravedad:** media
- **Descripción breve:** Tras rechazo, solo se puede re-invitar por email; debería poder hacerse desde la lista de participantes (o acción explícita sobre el usuario «fuera»).
- **Estado:** corregido y **validado** (2026-08-10) — tras rechazo UC en lista «fuera»; re-enviar desde ⋮ / lista invitar OK.
- **Origen:** guion `altas-bajas agosto 2026` (2026-08-09).

#### 115. Reinvitar por email con pending: duplica ítem en campana del invitado
- **Plataforma:** Web (UC) / todas
- **Pantalla / flujo:** Participantes → invitar por email a usuario ya pendiente
- **Tipo:** bug / gap diagrama §1 caso 2
- **Gravedad:** media
- **Descripción breve:** La app permite reenviar por mail; UA sigue con 1 pendiente; UC ve **2** invitaciones en notificaciones. Esperado: reenviar sin duplicar ítem de campana.
- **Causa raíz (2026-08-10):** campana mezclaba `plan_invitations` + `users/.../notifications` del mismo plan.
- **Estado:** corregido y **validado** (2026-08-10) — dedupe por planId + cancelar docs legacy al reinvitar directo; 1 ítem en campana.
- **Origen:** guion altas-bajas `altas-bajas agosto 2026` (2026-08-09).

#### 114. Organizador recibe N avisos idénticos al aceptar invitación
- **Plataforma:** iOS (UA) / todas
- **Pantalla / flujo:** Campana UA tras aceptar UB en Android
- **Tipo:** bug
- **Gravedad:** media
- **Descripción breve:** 6× «Invitación aceptada» iguales. Aceptar era lento; sin bloqueo de botón ni dedupe → varias llamadas a `notifyInvitationResponded` (posible también múltiples tokens FCM).
- **Estado:** corregido (2026-08-09) — dedupe por `planId`+tipo; early-return si participación ya `accepted`; botón Accept/Reject busy. Las 6 ya creadas en Firestore se pueden marcar leídas/borrar a mano.
- **Origen:** sesión multiplataforma Ago 2026.

#### 113. Notificación de invitación — muestra `planId` en lugar del nombre del plan
- **Plataforma:** Android (reproducido) / iOS / Web (misma UI)
- **Pantalla / flujo:** Campana / notificaciones unificadas → tarjeta de invitación pendiente
- **Tipo:** bug
- **Gravedad:** media
- **Descripción breve:** `invitationPlanLabel(invitation.planId)` en `wd_unified_notification_item.dart` y `wd_unified_notifications_screen.dart`.
- **Estado:** corregido (2026-08-09) — resuelve nombre vía `planByIdStreamProvider`.
- **Origen:** sesión multiplataforma Ago 2026 (UB acepta invitación en Android).

#### 110. Calendario — opción "Todos los días del plan" no aplicada en selector
- **Plataforma:** Web (menú calendario)
- **Pantalla / flujo:** Calendario del plan → menú opciones → "Todos los días del plan"
- **Tipo:** bug
- **Gravedad:** media
- **Descripción breve:** El menú exponía `days_all_plan` sin handler; además solo aparecía si el plan tenía **más** de 7 días.
- **Estado:** corregido (2026-08) — la opción se muestra cuando el plan dura **2–7 días**, aplica `visibleDays = durationInDays` (sin columnas vacías) y clamp de presets 1/3/7 a la duración del plan. Ver `CalendarConstants.resolveVisibleDays` / `canShowAllPlanDaysOnScreen`.
- **Referencia histórica:** ítem 29 / `REG-2026-014`

#### 111. Calendario — separadores verticales entre días (criterio de constantes) no trazado al 100%
- **Plataforma:** iOS / Android / Web
- **Pantalla / flujo:** Calendario multi-día (columnas de días/tracks)
- **Tipo:** bug / revisión técnica
- **Gravedad:** baja
- **Descripción breve:** Hay constantes específicas de separador vertical (`calendarVerticalSeparator*`), pero la creación de bordes sigue en utilidades genéricas (`createGridBorder`). Visualmente puede estar correcto, pero falta trazabilidad clara al criterio técnico definido para el ítem.
- **Estado:** corregido (2026-08-10) — API única `CalendarStyles.createVerticalDaySeparator` (width + opacidades web/móvil); usada en `wd_calendar_screen` y `pg_calendar_mobile_page`. `CalendarUtils.createGridBorder` queda solo para bordes genéricos.
- **Referencia histórica:** ítem 100 / `REG-2026-018`

#### 112. Calendario — alinear rejilla interna real con la demo v1 aprobada
- **Plataforma:** iOS / Android / Web
- **Pantalla / flujo:** Plan detalle → pestaña Calendario (rejilla interna `CalendarMobilePage`)
- **Tipo:** mejora UI / refactor visual
- **Gravedad:** media
- **Descripción breve:** La versión real ya adopta el marco externo de la demo (`barra unificada`, `chips 1/2/3`, `zona horaria`, contenedor). Falta trasladar los ajustes visuales de la rejilla interna aprobada en `demo/calendar-v1` (estética de celdas/pastillas y consistencia visual) a los componentes reales (`CalendarGrid`/tracks/eventos/alojamientos), sin romper lógica productiva.
- **Estado:** **cerrado** (2026-08-10) — decisión producto: el calendario actual se considera bien; no se portan más estilos de la demo v1.
- **Referencia:** acuerdo de revisión UI en chat (2026-04-22); cierre explícito en sesión QA Ago 2026.

---

### 5. Referencias rápidas

- Normas: `docs/configuracion/CONTEXT.md`
- Tareas Txxx relacionadas: `docs/tareas/TASKS.md`
- Offline móvil (58 cerrado): `docs/testing/TESTING_OFFLINE_FIRST.md`
- Push iOS: `docs/testing/ACCIONES_PENDIENTES_APP.md` (redirige a archivo) · `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md`
- Testing formal / regresiones: `docs/configuracion/TESTING_CHECKLIST.md`

---

### 6. Cierre técnico UI-SP (2026-04-23)

- **Objetivo cerrado:** unificación visual dark UI-SP y limpieza técnica de presentación sin tocar lógica de negocio.
- **Validación técnica:** `flutter analyze` sobre 21 archivos tocados en esta iteración → `No issues found`.
- **Limpieza de deuda UI:** en el scope trabajado no quedan usos visuales de `kIsWeb` ni `withOpacity(...)`.
- **Cobertura del bloque pendiente (19/19):**
  - **Ajustados con cambios UI-SP:** 17.
  - **Revisados sin cambio necesario:** `pg_admin_page`, `fullscreen_calendar_page`.
- **Trazabilidad de errores autocorregidos:** actualizado `docs/configuracion/LOG_ERRORES_AUTOFIX.md` con incidencia de scope (`_surface` fuera de alcance en `wd_notification_list_dialog`).

### 7. Consolidación técnica global (2026-04-24)

- **Validación global:** `flutter analyze lib` → `No issues found`.
- **Directorios verificados por bloques:** `lib/features`, `lib/widgets`, `lib/pages`, `lib/shared`, `lib/app`.
- **Chequeo UI-SP de deuda visual (global `lib/`):**
  - `withOpacity(...)`: 0 coincidencias.
  - `Colors.grey.shade*`: 0 coincidencias.
  - `kIsWeb`: solo usos funcionales de plataforma (sin decisiones de estilo visual por plataforma).
- **Trazabilidad técnica:** añadido registro en `docs/configuracion/LOG_ERRORES_AUTOFIX.md` para el cierre final de analyzer en `main.dart`.