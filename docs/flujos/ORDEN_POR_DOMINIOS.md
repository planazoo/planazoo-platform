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
| **1** | Participantes / altas-bajas / invitaciones (+ avisos de alta) | [`DIAGRAMA_ALTAS_BAJAS_PLAN.md`](./DIAGRAMA_ALTAS_BAJAS_PLAN.md) | **Cerrado** (2026-08-27) |
| **2** | Planes (+ estados) | [`FLUJO_CRUD_PLANES.md`](./FLUJO_CRUD_PLANES.md) · [`FLUJO_ESTADOS_PLAN.md`](./FLUJO_ESTADOS_PLAN.md) | **WIP** |
| **3** | Eventos (+ calendario) | [`FLUJO_CRUD_EVENTOS.md`](./FLUJO_CRUD_EVENTOS.md) | Siguiente |
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

**Mail (T134):** no es dominio #10. **Cerrado** 2026-08-31 (corte mínimo: reenviar + colocar). Producto: [`COMUNICACIONES_MAIL_PLAN.md`](../producto/COMUNICACIONES_MAIL_PLAN.md). Hallazgos posteriores → LISTA (p. ej. **142** unicidad inbound). No se añade fila a la tabla #1–#9.

---

## Cómo arrancar cada sesión

1. Abrir este archivo → ver **WIP actual** (**#2 Planes** / T277).
2. Abrir el contrato del dominio.
3. Trabajar solo tareas de ese dominio en `TASKS.md`.
4. Hallazgos → `LISTA_PUNTOS_CORREGIR_APP.md`.
5. Si cambió el comportamiento → actualizar el contrato.

Frase útil:  
**«Seguimos el orden definitivo. Dominio #2 Planes. Objetivo: …»**

---

## Log

- **2026-08-11:** Orden v1 elevado a **definitivo** (acuerdo de trabajo conjunto).
- **2026-08-27:** Dominio **#1 cerrado** (T259 iOS Universal Link Mail→HTTPS ✅; T269/T276 ✅; T268 aplazada; Android `assetlinks` / estética mail = fuera de WIP). **WIP → #2 Planes.**
- **2026-08-28:** **T134 intercalado** (mail → colocar; launch). T277 (#2 Planes) **aparcado**.
- **2026-08-31:** **T134 cerrado** (corte mínimo; hallazgos futuros en LISTA). **WIP → #2 Planes** (T277).
- **WIP:** **#2 Planes** · contrato [`FLUJO_CRUD_PLANES.md`](./FLUJO_CRUD_PLANES.md) · **T277**.
