# Sesión A — Estabilidad CRUD: usuarios, plan, invitaciones

**Objetivo:** Validar que el núcleo colaborativo es estable (crear plan → invitar → aceptar/rechazar → avisos) en **3 dispositivos**.  
**Criterio de calidad:** [`TIMELINE_LANZAMIENTO.md`](../producto/TIMELINE_LANZAMIENTO.md) (multi-usuario + informados).  
**Detalle largo:** [`PLAN_PRUEBAS_E2E_TRES_USUARIOS.md`](./PLAN_PRUEBAS_E2E_TRES_USUARIOS.md) fases 0–2.  
**Dominio WIP:** #1 participantes / invitaciones.

**Fecha de esta ronda:** _______________  
**Build:** iOS _____ · Android _____ · Web `app.planoon.com` / local _____

---

## Dispositivos (matriz)

| Id | Dispositivo | Email (el que uses hoy) | Rol |
|----|-------------|-------------------------|-----|
| **UA** | iPhone | | Organizador |
| **UB** | Android | | Invitado → aceptar |
| **UC** | Chrome (web) | | Invitado → **rechazar** (o aceptar si ya validaste rechazo otro día) |

Marca cada fila: ✅ / ❌ / ⚠️ (+ nota corta). Hallazgos → [`LISTA_PUNTOS_CORREGIR_APP.md`](./LISTA_PUNTOS_CORREGIR_APP.md).

---

## Bloque 0 — Login (5 min)

| # | Quién | Qué | ✅ |
|---|-------|-----|----|
| A0.1 | UA | Login iPhone → lista de planes | ✅ |
| A0.2 | UB | Login Android → lista de planes | ✅ |
| A0.3 | UC | Login web → dashboard | ✅ |

---

## Bloque 1 — Plan + invitaciones (UA)

| # | Quién | Qué | ✅ |
|---|-------|-----|----|
| A1.1 | UA | Crear plan nuevo (nombre claro, ej. `E2E Sesión A …`) | ✅ (overflow validación + ocultar UNP ID — fix 2026-08-16) |
| A1.2 | UA | Abrir plan → Participantes → solo UA organizador | ✅ |
| A1.3 | UA | Invitar **UB** por email → éxito; UB pendiente en lista | |
| A1.4 | UA | Invitar **UC** por email → éxito; UC pendiente | |
| A1.5 | UB/UC | Llega **email** Planoon (ficha plan + botones) y/o **campana/push** | |

---

## Bloque 2 — Aceptar / rechazar + avisos

| # | Quién | Qué | ✅ |
|---|-------|-----|----|
| A2.1 | UB | Aceptar desde **mail** (deep link) → plan; atrás → lista (no vuelve a invitación) | |
| A2.2 | UA | Ve a UB como participante; aviso de “aceptada” (campana/push) | |
| A2.3 | UC | **Rechazar** (mail o app) → no entra al plan | |
| A2.4 | UA | Ve rechazo / pendiente actualizado; aviso coherente | |
| A2.5 | UA | **Reenviar** a quien siga pendiente (T224) → nuevo aviso/mail sin duplicar rarezas | |
| A2.6 | UB | Re-tocar el **mismo** link Aceptar del mail → entra al plan **sin** errores ruidosos (LISTA 124) | |

---

## Cierre sesión A

| Pregunta | Sí / No |
|----------|---------|
| ¿Algún ❌ crítico (crash, no invita, no acepta, sin aviso)? | |
| ¿Paridad razonable iPhone / Android / web en este flujo? | |
| ¿Listo para **Sesión B** (eventos + apuntarse + notifs de eventos)? | |

Si todo OK en dominio #1 → cerrar T259 / 0.1 en timeline con confirmación tuya y pasar a Sesión B (E2E fases 3–5).

---

## Notas de la ronda

_(pegar aquí bugs / ⚠️)_
