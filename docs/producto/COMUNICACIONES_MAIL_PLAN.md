# Comunicaciones por mail → plan / evento

**Estado:** **Cerrado** (31 ago 2026) — corte mínimo (reenviar + colocar).  
**Trabajo:** transversal **Import** · tarea **T134** ✅.  
**No es** un dominio de proceso nuevo (#1–#9 siguen).  
**Canónico de recepción/plantillas/anti-spam:** [`CORREO_EVENTOS_SISTEMA_PARSEO.md`](./CORREO_EVENTOS_SISTEMA_PARSEO.md) (detalle técnico T134). Este archivo manda en **qué es el producto** y el orden de las fases.

**Lanzamiento:** el corte mínimo de mail (reenviar + colocar) sigue siendo **gate de lanzamiento público** (ya implementado). Hallazgos posteriores → LISTA (p. ej. **142**). Dominio WIP actual: **#2 Planes** (T277).

---

## 1. No es un dominio #10

| Pregunta | Respuesta |
|----------|-----------|
| ¿Dominio de proceso nuevo? | **No.** El orden #1→#9 no cambia. |
| ¿Dónde vive? | Transversal **Import / export / IA** ([`MAPA_FLUJOS.md`](../flujos/MAPA_FLUJOS.md)). Al implementar, el contrato de **Eventos** (#3) se actualiza (el mail acaba en un evento). |
| ¿WIP ahora? | **No.** T134 **cerrado** 2026-08-31. WIP de proceso: **#2 Planes** (T277). |

---

## 2. Qué queremos (producto)

El usuario **reenvía** (o, más adelante, un filtro lo hace por él) confirmaciones a una dirección de Planoon. En la app ve un **buzón de comunicaciones sin colocar**. Las **coloca**:

- en un **evento (o alojamiento) ya creado**, o
- **creando un evento nuevo** a partir de ese mail.

Se guarda una **copia** (cuerpo). **No** se responde al hotel. **No** hay auto-respuesta SMTP al reenvío. Al colocar, la copia vive en `events/{id}/communications` (eventos y alojamientos). Defecto **visible para el plan**; opción **Solo yo**.

El **parseo es un paso posterior**, no la puerta de entrada. Si no se extraen fechas, el mail **igual se conserva** en el evento.

Contrato corto:

> El mail entra. Tú lo colocas. La copia queda en la ficha (plan o privada). Parsear es opcional.

---

## 3. Por qué no “conectar con todas las APIs”

- eDreams tiene inventario porque **vende** (GDS/NDC), no porque lea reservas ajenas.
- Planoon es **lector**, caso **B**: el usuario **señala** cada reserva (no se conecta la cuenta Lufthansa/Booking).
- Usuario/contraseña de la aerolínea en la app: **no**.
- Un tubo de **status de vuelo** (Amadeus, T246) actualiza el **avión** (hora, retraso), no el **billete** (asiento, maleta).
- Pagar una API compra lo que el mercado vende (status). **No** abre el CRM de Booking.
- Partners grandes: pedir el PNR no convence. Sí: botón “Añadir a Planoon” / `.ics`, o que un hotel **empuje**.
- Fama o publicidad (Vueling en eventos avión): **dinero**, no datos de reserva.
- “Todo conectado y actualizado”: techo de un lector = vuelo operacional vivo; el resto es **snapshot** salvo ser agencia de **lo que hayáis emitido vosotros**.

El mail no es el diferenciador mágico. Es el canal realista para **traer el justificante** al plan. El diferencial sigue siendo **aterrizar en el plan de grupo** (colocar, participantes, avisos). El parseo de prosa es frágil; por eso **primero archivo, luego extract**.

---

## 4. Relación con docs y código ya existentes

| Fuente | Qué dice | Encaje |
|--------|----------|--------|
| T134 + `CORREO_EVENTOS_SISTEMA_PARSEO.md` | Reenvío a `eventos@`, From = usuario, plantillas, `pending_email_events`, **crear evento** | Se **reorienta**: el pendiente es comunicación sin colocar, no “evento a medias”. Conservar copia. |
| `EventDocument` / adjuntos | PDF/JPG en el evento, **comunes** | Distinto: copias en **Comunicaciones**; visibilidad defecto **plan**, opción privada. No es el bloque Adjuntos. |
| WEB_COMERCIAL Pilar 5 y 9 | Evento-contenedor; “No lo teclees. Compártelo.” | Este flujo es el corte honesto de Pilar 9 para launch. |
| TIMELINE P2 (histórico) | Import correo como post-lanzamiento | **Superado:** corte mínimo = launch público. |
| `FLUJO_CRUD_EVENTOS.md` (archivo) | Pegar mail en modal; **no guardar el cuerpo** | **T179 eliminada.** La frase de no guardar el cuerpo **queda retractada** para este producto. |
| Chat T190 | Mensajes entre participantes | No es el mail del hotel. |
| WhatsApp / capturas | — | Mismo contenedor más adelante; no launch. |

---

## 5. Decisiones cerradas (esta conversación)

| Tema | Decisión |
|------|----------|
| Privacidad de bandeja | Planoon **no lee Gmail**. El usuario **da** el mail (reenvío o filtro). |
| Modelo | Caso B: una reserva cada vez, identificada por lo que envía. |
| Escritura en proveedores | Solo **lectura**. No cambiar billetes. |
| Qué se guarda | Copia del mensaje + anexos. Sin responder. |
| Visibilidad v1 | Defecto **plan**. Opción **privado** (solo quien aportó). |
| Auto-crear eventos | **No.** Siempre colocar o confirmar creación. |
| Parseo runtime | Plantillas (T134). LLM solo en admin para generar plantillas. No es el MVP de launch. |
| Dirección | Global `eventos@` (o la configurada). Alias por plan (`eventos+planId@`): más tarde. |
| Anti-spam | From = principal **o extra verificado**; rate 50/día por usuario. **Sin auto-respuesta SMTP.** |
| Filtro Gmail/Outlook | “Una vez y olvidas”: crear/actualizar regla vía OAuth de **ajustes**, sin `gmail.readonly`. Post-corte-mínimo. |
| iCloud | Sin API decente; el usuario crea la regla a mano o reenvía. |

---

## 6. Corte mínimo de lanzamiento público

Debe funcionar de punta a punta:

1. Usuario registrado reenvía un mail de reserva a la dirección de la plataforma.
2. Aparece en su buzón de **comunicaciones sin colocar**.
3. Puede **añadirlo a un evento existente** (del plan que elija) **o crear un evento** (campos a mano si no hay parseo).
4. Luego ve la **copia** en ese evento o alojamiento (visible para el plan o solo tú).

**No** es gate: filtro automático, parseo fiable de Hertz/Booking, Wallet, WhatsApp, sync de asiento/maleta, publicidad, acuerdos con aerolíneas.

Soft launch familia (fase 0 actual): **no** bloquea por sí solo (el núcleo sigue siendo invitaciones). El **público (stores)** sí espera este corte.

---

## 7. Fases de construcción

1. **Modelo:** pending en `users/{uid}/pending_email_events`; al colocar, `events/{id}/communications`.
2. **Recepción** (`processInboundGmail`): Gmail consumidor = OAuth refresh token ([`GMAIL_INBOUND_BUZON.md`](../configuracion/GMAIL_INBOUND_BUZON.md)); From = principal o extra verificado; sin respuesta SMTP.
3. **UI colocar:** buzón → plan → evento/alojamiento existente **o** crear evento.
4. **UI ficha:** sección Comunicaciones (aparte de Adjuntos). Cuerpo: HTML o plano Outlook; **nota manual** (pegar WhatsApp) desde el buzón o la ficha; **anexos e imágenes** (Storage `communication_files/`).
5. **Perfil:** principal + 2 extras verificados, solo inbound.
6. **Después:** filtro Gmail; parseo sobre copias; alias por plan; WhatsApp **captura automática**; LISTA **142** unicidad inbound.

---

## 8. Cómo trabajarlo respecto al WIP

- **Cerrado** 2026-08-31 (corte mínimo). T277 (#2 Planes) **retomado**.
- Hallazgos de prueba → `LISTA_PUNTOS_CORREGIR_APP.md` (no reabren T134 como dominio WIP).
- Si el comportamiento del evento cambia, actualizar el stub [`FLUJO_CRUD_EVENTOS.md`](../flujos/FLUJO_CRUD_EVENTOS.md) (capa 1).

---

## 9. Copy hacia el usuario (orientativo)

*Planoon no lee tu correo. Reenvía lo que quieras guardar en el plan. Tú decides en qué evento va.*
