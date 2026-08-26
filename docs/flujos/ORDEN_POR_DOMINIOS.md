# Orden definitivo de trabajo por dominios

> **Acuerdo de trabajo (Ago 2026).**  
> Sistema: [`MAPA_FLUJOS.md`](./MAPA_FLUJOS.md).  
> Plantilla por dominio: [`PLANTILLA_DOMINIO.md`](./PLANTILLA_DOMINIO.md).

Este documento fija **el orden en el que trabajamos juntos**.  
No es una sugerencia: es la secuencia de dominio a dominio.

---

## Reglas fijas

1. **1 WIP a la vez:** solo un dominio de proceso activo.
2. **Seguir el orden** de la tabla de abajo.
3. **Excepción:** solo bug crítico / bloqueo de producción / acuerdo explícito de saltar.
4. Al cerrar (o aparcar) un dominio → abrir el **siguiente** del orden.
5. Tareas nuevas van al dominio que corresponda; no abren un dominio fuera de turno.

---

## Orden definitivo

| # | Dominio | Contrato / entrada | Estado |
|---|---------|-------------------|--------|
| **1** | Participantes / altas-bajas / invitaciones (+ avisos de alta) | [`DIAGRAMA_ALTAS_BAJAS_PLAN.md`](./DIAGRAMA_ALTAS_BAJAS_PLAN.md) | **WIP actual** (T259) |
| **2** | Planes (+ estados) | [`FLUJO_CRUD_PLANES.md`](./FLUJO_CRUD_PLANES.md) · [`FLUJO_ESTADOS_PLAN.md`](./FLUJO_ESTADOS_PLAN.md) | Siguiente |
| **3** | Eventos (+ calendario) | [`FLUJO_CRUD_EVENTOS.md`](./FLUJO_CRUD_EVENTOS.md) | En cola |
| **4** | Alojamientos | [`FLUJO_CRUD_ALOJAMIENTOS.md`](./FLUJO_CRUD_ALOJAMIENTOS.md) | En cola |
| **5** | Pagos | [`FLUJO_PRESUPUESTO_PAGOS.md`](./FLUJO_PRESUPUESTO_PAGOS.md) | En cola |
| **6** | Notas del plan | [`FLUJO_NOTAS_PLAN.md`](./FLUJO_NOTAS_PLAN.md) | En cola |
| **7** | Auth / usuarios / perfil | [`FLUJO_CRUD_USUARIOS.md`](./FLUJO_CRUD_USUARIOS.md) | En cola |
| **8** | Admin | `docs/admin/` + TASKS admin | En cola |
| **9** | Config app / validación | [`FLUJO_CONFIGURACION_APP.md`](./FLUJO_CONFIGURACION_APP.md) · [`FLUJO_VALIDACION.md`](./FLUJO_VALIDACION.md) | En cola |

### Por qué este orden

1 → quién está en el plan y cómo entra/sale  
2 → ciclo de vida del plan  
3–4 → contenido operativo (eventos / alojamientos)  
5–6 → capas sobre plan ya estable (pagos / notas)  
7–9 → perfil, admin y mantenimiento (después del núcleo de uso diario)

---

## Transversales (no rompen el orden)

Offline, Chat, Plataforma/release, UI transversal, Timezones, Permisos, Import/IA, etc.  
Se tocan **dentro** del dominio WIP cuando hacen falta, o como bug urgente.  
No abren un dominio propio fuera de secuencia.

**Mail (T134):** no es dominio #10. Producto: [`COMUNICACIONES_MAIL_PLAN.md`](../producto/COMUNICACIONES_MAIL_PLAN.md). Gate de **lanzamiento público** (corte mínimo). Implementar intercala capa de launch (acuerdo explícito) o espera a Eventos (#3); no se añade fila a la tabla #1–#9.

---

## Cómo arrancar cada sesión

1. Abrir este archivo → ver **WIP actual** (`#1` ahora).
2. Abrir el contrato del dominio.
3. Trabajar solo tareas de ese dominio en `TASKS.md`.
4. Hallazgos → `LISTA_PUNTOS_CORREGIR_APP.md`.
5. Si cambió el comportamiento → actualizar el contrato.

Frase útil:  
**«Seguimos el orden definitivo. Dominio #1. Objetivo: …»**

---

## Log

- **2026-08-11:** Orden v1 elevado a **definitivo** (acuerdo de trabajo conjunto).
- **WIP:** Dominio #1 — Participantes / invitaciones (**T259** deep link nativo en curso; T276 ✅ T269 ✅; T268 aplazada).
