# Diagrama: altas y bajas en un plan

> Visión de **proceso** (qué hace cada persona), sin detalles técnicos.  
> Prosa: [`FLUJO_GESTION_PARTICIPANTES.md`](./FLUJO_GESTION_PARTICIPANTES.md) · Mapa: [`MAPA_FLUJOS.md`](./MAPA_FLUJOS.md)  
> **Estado:** borrador vivo — núcleo altas/bajas **probado** (Ago 2026); quedan POR HACER (§1.2 resto, §1.3, T268, Universal Links nativos).

**Leyenda del diagrama**
- Cajas normales = **ya implementado**
- Cajas con borde/estilo “por hacer” = **aún no implementado** (acordado o a acordar)

**Cómo usarlo:** editar hasta marcar **Acordado**; luego se implementa según este contrato.

---

## 1. Alta — invitar a alguien que **ya usa Planazoo**

El flujo empieza siempre igual: **el organizador lanza una invitación**.  
Lo que cambia es el **estado previo** de esa persona en el plan.  
Detalle de canales y ciclo de vida de avisos → **§1.1**.

```mermaid
flowchart TD
  start[Organizador lanza una invitación<br/>a una persona registrada] --> estado{¿Cuál es su estado<br/>previo en este plan?}

  estado -->|1. Nunca invitado| nuevo[Pasa a pendiente]
  estado -->|2. Ya invitado| reenviar[Se reenvía el aviso<br/>sin duplicar ítem en campana]
  estado -->|3. Había rechazado| reabrir[Vuelve a pendiente]
  estado -->|4. Ya aceptado / dentro| bloqueadoOk[No se invita:<br/>ya es participante]
  estado -->|5. Había salido o lo expulsaron| reabrirBaja[Vuelve a pendiente]
  estado -->|6. Es el organizador del plan| bloqueadoYo[No tiene sentido:<br/>no se invita a sí mismo]

  nuevo --> aviso
  reenviar --> aviso
  reabrir --> aviso
  reabrirBaja --> aviso

  aviso[Aviso: campana + push + email] --> decideComo{Cómo decide}
  decideComo -->|Toca push / email / lista| validar
  decideComo -->|Abre la app con pendientes| validar
  validar{¿Sigue siendo accionable?<br/>ver §1.2}
  validar -->|Sí| modal[Modal: aceptar / rechazar / cerrar]
  validar -->|No| avisoMuerto[Mensaje claro + borrar avisos<br/>de esa invitación]
  modal -->|Acepta| dentro[Entra en el plan<br/>Se borran avisos de esa invitación]
  modal -->|Rechaza| fuera[Sigue como rechazado / fuera<br/>Se borran avisos de esa invitación]
  modal -->|Cierra sin decidir| aviso
  dentro --> avisaOrg[Aviso al organizador:<br/>campana + push]
  fuera --> avisaOrg

  aviso -.->|Más de 24 h sin contestar| recordatorio[POR HACER: recordatorio diario<br/>al invitado T268]
  recordatorio --> canalesRec[POR HACER: actualizar campana<br/>+ push + email]
  canalesRec --> yaDecidio{¿Ya ha decidido?}
  yaDecidio -->|No| recordatorio
  yaDecidio -->|Sí| validar

  classDef todo fill:#5b3a1a,stroke:#e6a23c,stroke-width:2px,color:#fff
  class aviso,decideComo,validar,avisoMuerto,modal,avisaOrg,recordatorio,canalesRec,yaDecidio todo
```

> **Nota de leyenda:** recordatorio T268 / validación §1.2 completa / deep link §2 = POR HACER.  
> Participación `pending`, aceptar/rechazar, campana+push+email (registrado), modal al abrir, reenviar sin duplicar campana, salir/expulsar con avisos: **implementado** (Ago 2026). Al aceptar se comprueba si el plan admite altas.

**Casos al lanzar la invitación**

| # | Estado previo | Participación | Avisos (§1.1) |
|---|---------------|---------------|---------------|
| 1 | Nunca invitado | Pendiente — ✅ | Campana+push+email ✅ (CF `sendInvitationEmail` al crear `plan_invitations`) |
| 2 | Ya invitado | Sigue pending — ✅ | Reenviar **sin duplicar** campana ✅ (LISTA 115) · push+email nuevos ✅ |
| 3 | Había rechazado | Vuelve a pending — ✅ | Re-enviar desde lista ✅ (LISTA 116) · email ✅ |
| 4 | Ya aceptado | No se invita — ✅ | — |
| 5 | Había salido / expulsado | Recrea `pending` (al salir se **borra** el doc) — ✅ | Igual que invitar |
| 6 | Es el organizador | No se invita — ✅ | — |

**Después de responder**
- Acepta → dentro del plan · se **borran** avisos de esa invitación · organizador: campana + push.  
- Rechaza → visible como «fuera» · se **borran** avisos de esa invitación · organizador: campana + push · se puede volver a invitar (caso 3).  
- Cierra sin decidir → avisos siguen · al reabrir la app (o tocar aviso) vuelve el modal.

**Mientras no responde**
- Cada 24 h: recordatorio (actualizar campana + push + email) hasta decidir → **T268 (por hacer)**.
- Al abrir la app con pendientes → modal automático → ✅ (§1.1 decisión 2).

**Efectos en datos (borrador — para ver el formato)**

| Paso del diagrama | Efecto en datos |
|-------------------|-----------------|
| 1. Nunca invitado → pendiente | Crea `plan_participations` con `status: pending`, `isActive: true` · aviso campana + push + email al invitado |
| 2. Ya invitado → reenviar aviso | No cambia el `status` (sigue `pending`) · actualiza el aviso accionable de campana · push + email nuevos |
| 3. Había rechazado → vuelve a pendiente | Actualiza `plan_participations`: `rejected` → `pending` · aviso campana + push + email |
| 4. Ya aceptado | Sin escritura de invitación |
| 5. Había salido / expulsado → pendiente | Recrea `plan_participations` `pending` (tras salir/expulsar el doc se había borrado) · aviso |
| 6. Es el organizador | Sin escritura |
| Acepta | `plan_participations.status` → `accepted` · **borra** avisos de esa invitación · campana + push al organizador |
| Rechaza | `plan_participations.status` → `rejected` (sigue visible) · **borra** avisos de esa invitación · campana + push al organizador |
| Recordatorio 24 h (T268) | Sin cambio de `status` · push + email (+ actualizar campana) *(por hacer)* |
| Al abrir la app con pendientes | Muestra modal de decisión *(por hacer)* · antes valida §1.2 |
| Participante sale (§3) | **Borra** participación · campana + push al organizador (`participantLeft`) — ✅ LISTA 119 |
| Organizador expulsa (§3) | **Borra** participación · campana + push al expulsado (`participantRemoved`) — ✅ LISTA 120 |

### 1.1 Avisos de la invitación (invitado registrado)

Contrato de **cómo avisamos** y **qué pasa con esos avisos**.  
El §1 dice *cuándo* se invita; aquí, *cómo se entera* y *cómo decide*.  
**Antes de abrir el modal de decisión** → validar §1.2 (aviso / plan / invitación aún válidos).  
**Decisiones 1–5: acordadas** (ver tabla abajo). Email registrado ✅; quedan T268 y deep link §2.

```mermaid
flowchart TD
  invita[Organizador invita / reenvía] --> canales{Canales al invitado}

  canales --> campana[Campana: un ítem accionable por invitación]
  canales --> push[Push en el móvil si puede]
  canales --> email[Email al invitado registrado]

  campana --> verLista[Ve la lista de notificaciones]
  push --> tocaPush[Toca el push]
  email --> tocaEmail[Abre el correo / enlace]

  verLista --> validar
  tocaPush --> validar
  tocaEmail --> validar
  autoEntry[Al abrir la app con pendientes] --> validar

  validar{¿La invitación sigue siendo<br/>accionable? §1.2}
  validar -->|Sí| modal[Modal: aceptar / rechazar / cerrar]
  validar -->|No| invalido[Mensaje claro del motivo<br/>+ se borran avisos de esa invitación]

  modal -->|Acepta| limpia[Se borran avisos de ESA invitación]
  modal -->|Rechaza| limpia
  modal -->|Cierra sin decidir| queda[Siguen pendientes]

  queda --> reabre{Más tarde}
  reabre -->|Lista / push / email / recordatorio| validar
  reabre --> autoEntry

  limpia --> avisaOrg[Aviso al organizador: campana + push]

  classDef todo fill:#5b3a1a,stroke:#e6a23c,stroke-width:2px,color:#fff
  class validar,invalido todo
```

**Decisiones acordadas**

| # | Pregunta | Acuerdo | Implementación |
|---|----------|---------|----------------|
| 1 | Email al invitado ya registrado | **Sí** | ✅ crea `plan_invitations` → CF `sendInvitationEmail` (invitar y reenviar) |
| 2 | Al reabrir la app con pendientes | **Modal automático** | ✅ una vez por sesión (Dashboard / lista móvil) |
| 3 | Al aceptar / rechazar | **Borrar** avisos de esa invitación | ✅ |
| 4 | Al reenviar si ya pendiente | Un solo ítem accionable en campana + push (+ email) nuevos | ✅ campana+push (LISTA 115) + email |
| 5 | Aviso al organizador al responder | **Campana + push** | ✅ |

**Canales**

| Canal | Al invitar / reenviar | Hoy |
|-------|----------------------|-----|
| Campana (lista notificaciones) | Sí — **un** aviso accionable por plan/invitación | ✅ (dedupe por plan) |
| Push móvil | Sí, si hay permiso/token | ✅ |
| Email al registrado | Sí | ✅ (mismo template CF; enlace `/invitation/{token}` → deep link §2) |

**Dónde ve las pendientes**

| Sitio | Qué ve | Hoy |
|-------|--------|-----|
| Lista de la campana | Ítems de invitación a planes | Implementado |
| Badge de la campana | Solo las que siguen sin resolver | Parcial / a revisar |
| Al abrir la app | Modal automático si hay pendientes | ✅ una vez por sesión |
| Lista de planes | El plan aparece (participación pendiente) | Implementado |

**Ciclo de vida del aviso**

| Momento | Qué ocurre | Hoy |
|---------|------------|-----|
| Se invita | Campana + push + email | ✅ |
| Se reenvía (ya pendiente) | Actualiza el ítem de campana · push + email nuevos | ✅ |
| Toca push, email o ítem de lista | Valida §1.2 → modal o mensaje de inválido | Push/lista/modal ✅; abrir enlace email → §2 |
| Cierra el modal sin decidir | Aviso **sigue** en la lista | ✅ |
| Vuelve a abrir la app | Modal automático con pendientes | ✅ una vez por sesión |
| Acepta o rechaza | **Borrar** avisos de esa invitación · badge baja | ✅ |
| Organizador | Campana + push de la respuesta | ✅ |

**Nota sobre el “caso más seguro” (decisión 4):** no acumular varios ítems pendientes del mismo plan (confunde el badge y la lista). Un único aviso accionable + canales “interruptivos” (push/email) en cada reenvío.

### 1.2 Acceso desde un aviso que ya no es válido

Cuando el usuario entra por **push**, **email**, **ítem de campana** o **modal al abrir la app**, la app **valida primero** si la invitación sigue siendo accionable.  
Si no lo es: **no** muestra aceptar/rechazar; muestra un **mensaje concreto**; **borra** los avisos de esa invitación (misma regla que al decidir).

```mermaid
flowchart TD
  entrada[Usuario toca aviso o abre app<br/>con una invitación pendiente aparente] --> checks{Validaciones en orden}

  checks --> c1{¿Existe la invitación<br/>o participación pending?}
  c1 -->|No| m1[Ya no hay invitación pendiente]
  c1 -->|Sí| c2{¿Estado de la invitación?}

  c2 -->|accepted| m2[Ya formas parte del plan]
  c2 -->|rejected| m3[Ya rechazaste esta invitación]
  c2 -->|cancelled / cancelada por org| m4[El organizador canceló la invitación]
  c2 -->|expired o pasó expiresAt| m5[La invitación ha caducado]
  c2 -->|pending| c3{¿Estado del plan?}

  c3 -->|planificando / confirmado| ok[Abrir modal aceptar / rechazar]
  c3 -->|en_curso| m6[El plan ya ha empezado:<br/>ya no se puede unir]
  c3 -->|finalizado| m7[El plan ya ha terminado]
  c3 -->|cancelado| m8[El plan fue cancelado]

  m1 --> limpia
  m2 --> limpia
  m3 --> limpia
  m4 --> limpia
  m5 --> limpia
  m6 --> limpia
  m7 --> limpia
  m8 --> limpia
  limpia[Borrar avisos de esa invitación<br/>y bajar badge] --> fin[Fin — sin cambiar participación<br/>salvo si ya estaba accepted]

  classDef todo fill:#5b3a1a,stroke:#e6a23c,stroke-width:2px,color:#fff
  class entrada,checks,c1,c2,c3,m1,m2,m3,m4,m5,m6,m7,m8,limpia todo
```

**Tabla de casos (contrato) — estado del aviso / plan**

| # | Situación al entrar por el aviso | Qué ve el usuario | ¿Modal aceptar/rechazar? | Avisos | Hoy |
|---|----------------------------------|-------------------|--------------------------|--------|-----|
| A | Invitación / participación **pending** y plan `planificando` o `confirmado` | Modal normal | Sí | Siguen hasta decidir | ✅ modal (push/lista/email doc); deep link §2 |
| B | Invitación **ya aceptada** / ya es participante | «Ya formas parte de este plan» (ideal: ir al plan) | No | Se borran | ✅ al abrir modal |
| C | Invitación **ya rechazada** | «Ya rechazaste esta invitación» | No | Se borran | ✅ al abrir modal |
| D | Invitación **cancelada** por el organizador | «El organizador canceló la invitación» | No | Se borran | ✅ al abrir modal (si hay doc) |
| E | Invitación **caducada** (7 días / `expired`) | «Esta invitación ha caducado» | No | Se borran | ✅ al abrir modal / al aceptar |
| F | Plan **en marcha** (`en_curso`) | «El plan ya ha empezado; ya no puedes unirte» | No | Se borran | ✅ al abrir modal / al aceptar |
| G | Plan **finalizado** | «Este plan ya ha terminado» | No | Se borran | ✅ al abrir modal / al aceptar |
| H | Plan **cancelado** | «Este plan fue cancelado» | No | Se borran | ✅ al abrir modal / al aceptar |
| I | Aviso huérfano (plan/invitación borrados) | «Esta invitación ya no está disponible» | No | Se borran | ✅ al abrir modal |

**Tabla de casos — identidad, carrera, roles, avisos**

| # | Situación | Qué ve / qué hace la app | Hoy |
|---|-----------|--------------------------|-----|
| J | Sesión actual **≠** email/usuario de la invitación | «Esta invitación es para otra cuenta. Cierra sesión o usa la cuenta invitada.» No aceptar con la sesión equivocada | ✅ en `InvitationPage` / accept|reject by token |
| K | Sin sesión / hay que registrarse (enlace email §2) | Flujo registro/login y luego revalidar §1.2; si el email no coincide, caso J | ✅ web deep link; nativo → T259 |
| L | Usuario **eliminado / desactivado** entre aviso y tap | «Esta cuenta ya no está disponible» · limpiar avisos locales si aplica | Gap |
| M | Misma dirección de email, **cuenta recreada** (otro `userId`) | Solo válido si la invitación apunta al email/userId actual; si no, invitación no aplicable + el org puede reinvitar | Gap |
| N | Aceptó en dispositivo A; luego toca push en B | Caso B («ya formas parte») · limpiar avisos en B | Gap parcial |
| O | Doble tap / aceptar y rechazar a la vez | Una sola operación gana (idempotente); la segunda ve B o C · sin estados corruptos | Gap |
| P | Organizador **cancela o reenvía** con el modal abierto | Al confirmar: revalidar §1.2; si canceló → D; si reenvió → sigue A con datos frescos | Gap |
| Q | Plan cambia a `en_curso` / `finalizado` / `cancelado` con modal abierto | Al confirmar: revalidar → F/G/H · no aceptar a ciegas | Gap |
| R | Cambia el **organizador** / ownership con pendientes | Invitación sigue válida si plan + pending siguen (A); el aviso al responder va al organizador **actual** | A acordar / Gap |
| S | Invitar a quien **ya es co-organizador** u otro rol dentro | Como caso 4 del §1: no reinvitar; si llega aviso viejo → B | Parcial |
| T | Auto-invitación (buscarse a sí mismo) | Bloquear al crear (caso 6 §1); si llega aviso absurdo → «No puedes invitarte a ti mismo» + borrar | A revisar |
| U | Plan **inaccesible** por permisos tras el aviso | «No tienes acceso a este plan» · borrar avisos · no crash | Gap |
| V | Caducidad 7 días: reloj cliente vs servidor | Decidir **siempre por reloj de servidor** (`expiresAt` / CF) | A reforzar |
| W | App reinstalada: push viejo perdido, queda **email** | Abrir email → misma validación §1.2; campana se reconstruye desde datos | Parcial (email ✅; deep link §2) |
| X | Varios recordatorios T268 y responde a uno viejo | Revalidar; si ya decidió → B/C; si sigue pending → A; limpiar avisos de esa invitación | POR HACER con T268 |
| Y | Notificaciones del SO desactivadas | Sigue email + campana + **modal al abrir app** (§1.1); no depender solo del push | Parcial |
| Z | Ítem de campana “leído” pero sigue `pending` (o al revés) | La acción depende del **estado** participación/invitación, no de `isRead`; al decidir o invalidar → borrar | Gap |
| AA | Correo **viejo** tras rechazo + **re-invitación** nueva | Aviso/enlace viejo → C o E; solo el de la invitación **actual** pending → A | Gap |
| AB | Cupo lleno / lista de espera *(si existe en producto)* | «El plan no admite más participantes» · no aceptar | A acordar si hay cupos |
| AC | Unirse en `en_curso` si el org lo permite explícitamente | **Por defecto no** (caso F). Flag futuro “permitir altas en curso” sería excepción documentada | Acorde F |

**Reglas**
- Misma lógica **da igual el canal** (correo viejo, push viejo, campana, abrir app).
- En F/G/H/AB: **no** se puede aceptar aunque la participación siga `pending`.
- Tras mensaje de caso inválido (B–I y J–AC según aplique): **borrar** avisos de esa invitación.
- Antes de confirmar aceptar/rechazar en el modal: **revalidar** (cubre P, Q, O, N).
- Si ya era `accepted` (B/N): no re-aceptar; ideal navegar al plan.
- Recordatorios T268 **solo** si sigue siendo caso A; si pasa a inválido, dejar de recordar y limpiar.
- Identidad (J, K, M): **nunca** aplicar una invitación a la sesión equivocada.

**Efectos en datos (casos inválidos / carrera)**

| Caso | Datos |
|------|--------|
| B–I, F–H, E | No aceptar · no rechazar de nuevo · **borrar** notificaciones · si sigue `pending` y ya no admite altas o caducó → marcar `expired` (o equiv.) |
| J, K, M | Sin escritura sobre la invitación ajena · mensaje · no marcar accepted en la sesión actual |
| O, P, Q | Operación idempotente + revalidación al confirmar |
| A (válido) | Flujo normal §1 / §1.1 |

### 1.3 Espacio para gestionar invitaciones (propuesta)

Las invitaciones son la puerta de entrada al producto: no pueden vivir solo en un push fugaz o un ítem perdido en la campana general.

**Cómo lo veo**
- **Sí hace falta un sitio claro** «Mis invitaciones» (sección fija en Inicio/Dashboard o entrada desde campana): lista de pendientes accionables, con aceptar / rechazar / ver detalle del plan.
- La **campana** sigue siendo el canal de aviso (y de historial corto); el **buzón de invitaciones** es la bandeja de trabajo.
- El **modal al abrir la app** (§1.1) no sustituye ese espacio: es un atajo cuando hay pendientes; si hay varias, mejor ir a la lista.
- En Participantes (lado organizador) ya se gestionan las enviadas; el hueco fuerte es el **lado invitado**.

```mermaid
flowchart LR
  avisos[Push / email / campana] --> validar[Validar §1.2]
  validar -->|Accionable| buzon[Mis invitaciones]
  validar -->|Inválido| msg[Mensaje + limpiar]
  abrirApp[Abrir app] --> buzon
  buzon --> modal[Aceptar / rechazar]
  modal --> planes[Mis planes]
```

**Contenido mínimo del buzón (invitado)**

| Elemento | Notas |
|----------|--------|
| Lista de pendientes (caso A) | Plan, quién invita, fecha, caducidad |
| Acciones | Aceptar / Rechazar (con revalidación §1.2) |
| Vacío | Copy claro |
| Opcional: recientes resueltas | Aceptada / Rechazada / Caducada (solo lectura, pocos días) |

**Hoy:** hay piezas (campana unificada, badges, `userPendingInvitationsProvider` incompleto para invites directas). **No** hay un buzón de primera clase para el invitado → **POR HACER** (acordar UX e implementar).

---

## 2. Alta — invitar por **email** a alguien que **aún no tiene cuenta**

```mermaid
flowchart TD
  A[Organizador invita por email] --> B[Se envía un correo con enlace]
  B --> C[La persona abre el enlace]
  C --> V{¿Sigue siendo accionable?<br/>misma lógica §1.2}
  V -->|Sí| D{¿Acepta o rechaza?}
  V -->|No| X[Mensaje del motivo<br/>invitación no usable]
  D -->|Acepta| E[Entra en el plan]
  D -->|Rechaza| F[No entra en el plan]
```

**Notas**
- El enlace caduca a los 7 días (caso E del §1.2).
- Si el email ya tenía una invitación pendiente a ese plan: se **reenvía** (cancela la anterior + nuevo token/email).
- Plan en marcha / finalizado / cancelado: mismos mensajes F/G/H del §1.2.
- **Hoy (web):** ruta `/invitation/{token}` → `InvitationPage` (pública). Sin sesión → login/registro (K); email de sesión ≠ invitado → aviso (J); `?action=accept|reject` ejecuta tras login correcto.
- **Hoy (nativo iOS/Android):** Universal Links / App Links **aún no** (T259); el mail abre el navegador → flujo web.
- Nuevas invitaciones: doc ID = token (lectura pública si `pending`).

---

## 3. Baja — salir, quitar o cancelar invitación

```mermaid
flowchart TD
  A{¿Quién actúa?}
  A -->|El invitado o participante| B[Sale del plan o rechaza la invitación]
  A -->|El organizador| C{¿Qué hace?}
  C -->|Quita a alguien del plan| D[Esa persona deja de participar]
  C -->|Cancela una invitación pendiente| E[La invitación deja de estar activa]
  B --> F[Fin]
  D --> F
  E --> F
```

**Pendiente de acordar:** avisos al **cancelar** invitación pendiente (¿avisar al invitado?).

**Acuerdo QA 2026-08-09 (LISTA 120):** al **expulsar**, el expulsado **sí** recibe campana + push. ✅ `notifyParticipantRemoved`.

**Acuerdo QA 2026-08-10 (LISTA 119):** al **salir**, se **borra** la participación; el organizador recibe campana + push (`participantLeft`). ✅ validado.

### 1.4 / §3 bis — Efectos en eventos, alojamientos y tracks (LISTA **121**)

**Acuerdo 2026-08-10:** **A2 + B2 + B3**.

| Momento | Contrato | Implementación |
|---------|----------|----------------|
| Acepta | Entrar en ítems futuros **«para todos»**; no en selectivos | `onParticipantJoined` |
| Sale / expulsan | Quitar de arrays futuros (B2); **borrar** futuros solo-suyos (B3); avisar en diálogo | `previewSoloOwnedFutureItems` + `onParticipantLeft` |
| Track UI | Derivado de participaciones activas | Sync en calendario |

Validación: A2+B2+B3 + aviso diálogo + lista en notificación al organizador ✅ 2026-08-10.

---

## 4. Checklist de acuerdo

- [x] §1 invitar registrado (casos 1–6) — **probado** Ago 2026; falta T268  
- [x] §1.1 avisos — decisiones 1–5 **acordadas e implementadas** (email registrado ✅; queda T268)  
- [ ] §1.2 acceso por aviso inválido / carrera / identidad (casos A–AC) — parcial (A–I ✅; J/K en deep link web ✅)  
- [ ] §1.3 buzón «Mis invitaciones» (lado invitado)  
- [x] §1.4 efectos en eventos/alojamientos/tracks al alta/baja — **LISTA 121** A2+B2+B3 ✅  
- [x] §2 invitar por email sin cuenta — deep link **web** ✅ (`InvitationPage`); nativo Universal Links = T259  
- [x] §3 bajas básicas — salir / expulsar / cancelar pendiente + avisos 119/120 ✅; aviso al cancelar pendiente a acordar; limpieza profunda eventos = 121  

**Estado:** `Borrador vivo` — núcleo altas/bajas + email + deep link web; quedan §1.2 resto, §1.3, T268, Universal Links nativos.
