# Comunicaciones por mail → plan / evento

**Estado:** Acordado en conversación (24–25 ago 2026). Producto, no código aún.  
**Trabajo:** transversal **Import** · tarea **T134** (reorientada).  
**No es** un dominio de proceso nuevo (#1–#9 siguen).  
**Canónico de recepción/plantillas/anti-spam:** [`CORREO_EVENTOS_SISTEMA_PARSEO.md`](./CORREO_EVENTOS_SISTEMA_PARSEO.md) (detalle técnico T134). Este archivo manda en **qué es el producto** y el orden de las fases.

**Lanzamiento:** el corte mínimo de mail (reenviar + colocar) es **gate de lanzamiento público**, no un extra P2. No abre el dominio Eventos por su cuenta: se intercala como capa de launch (igual que legal/stores), con acuerdo explícito respecto al WIP #1.

---

## 1. No es un dominio #10

| Pregunta | Respuesta |
|----------|-----------|
| ¿Dominio de proceso nuevo? | **No.** El orden #1→#9 no cambia. |
| ¿Dónde vive? | Transversal **Import / export / IA** ([`MAPA_FLUJOS.md`](../flujos/MAPA_FLUJOS.md)). Al implementar, el contrato de **Eventos** (#3) se actualiza (el mail acaba en un evento). |
| ¿WIP ahora? | El WIP sigue **#1 participantes**. Documentar ≠ implementar. Para *construir* el mail antes de cerrar #1 hace falta **acuerdo explícito de saltar/intercalar** ([`ORDEN_POR_DOMINIOS.md`](../flujos/ORDEN_POR_DOMINIOS.md) regla 3). |

---

## 2. Qué queremos (producto)

El usuario **reenvía** (o, más adelante, un filtro lo hace por él) confirmaciones a una dirección de Planoon. En la app ve un **buzón de comunicaciones sin colocar**. Las **coloca**:

- en un **evento (o alojamiento) ya creado**, o
- **creando un evento nuevo** a partir de ese mail.

Se guarda una **copia** (cuerpo + anexos). **No** se responde al hotel. En v1 las copias viven en la **cuenta del usuario** (parte personal), no en el wiki del grupo.

El **parseo es un paso posterior**, no la puerta de entrada. Si no se extraen fechas, el mail **igual se conserva** en el evento.

Contrato corto:

> El mail entra. Tú lo colocas. La copia se queda en tu cuenta. Parsear es opcional.

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
| `EventDocument` / adjuntos | PDF/JPG en el evento, **comunes** | Distinto: comunicaciones v1 son **personales**. |
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
| Visibilidad v1 | Cuenta del **usuario** (personal). El grupo no ve el mail salvo “compartir” futuro. |
| Auto-crear eventos | **No.** Siempre colocar o confirmar creación. |
| Parseo runtime | Plantillas (T134). LLM solo en admin para generar plantillas. No es el MVP de launch. |
| Dirección | Global `eventos@` (o la configurada). Alias por plan (`eventos+planId@`): más tarde. |
| Anti-spam | From = email principal registrado; rate limit (ver parseo T134). |
| Filtro Gmail/Outlook | “Una vez y olvidas”: crear/actualizar regla vía OAuth de **ajustes**, sin `gmail.readonly`. Post-corte-mínimo. |
| iCloud | Sin API decente; el usuario crea la regla a mano o reenvía. |

---

## 6. Corte mínimo de lanzamiento público

Debe funcionar de punta a punta:

1. Usuario registrado reenvía un mail de reserva a la dirección de la plataforma.
2. Aparece en su buzón de **comunicaciones sin colocar**.
3. Puede **añadirlo a un evento existente** (del plan que elija) **o crear un evento** (campos a mano si no hay parseo).
4. Luego ve la **copia** en ese evento (apartado personal).

**No** es gate: filtro automático, parseo fiable de Hertz/Booking, Wallet, WhatsApp, sync de asiento/maleta, publicidad, acuerdos con aerolíneas.

Soft launch familia (fase 0 actual): **no** bloquea por sí solo (el núcleo sigue siendo invitaciones). El **público (stores)** sí espera este corte.

---

## 7. Fases de construcción (cuando se implemente)

1. **Modelo** `Communication`: copia mail+anexos en `users/{uid}/…`; `planId` / `eventId` opcionales.
2. **Recepción** ya esbozada (T134 / `processInboundGmail`): el documento deja de ser solo “evento pendiente”.
3. **UI colocar:** lista → plan → evento existente **o** crear evento.
4. **UI evento:** comunicaciones personales.
5. **Después:** filtro Gmail; parseo sobre copias; alias por plan; otros tipos (WhatsApp, captura) en el mismo contenedor.
6. **Vuelos vivos (T246/T247):** paralelo, no sustituye el archivo de mail.

---

## 8. Cómo trabajarlo respecto al WIP

- **Documentar** (este archivo): hecho; no rompe #1.
- **Implementar:** o se **aparca #1** con acuerdo y se intercala esta capa de launch, o se espera a poder tocar Eventos. No abrir un dominio “Mail” en `ORDEN_POR_DOMINIOS.md`.
- Hallazgos de prueba → `LISTA_PUNTOS_CORREGIR_APP.md`.
- Al implementar, actualizar el stub [`FLUJO_CRUD_EVENTOS.md`](../flujos/FLUJO_CRUD_EVENTOS.md) (capa 1) si el comportamiento del evento cambia.

---

## 9. Copy hacia el usuario (orientativo)

*Planoon no lee tu correo. Reenvía lo que quieras guardar en el plan. Tú decides en qué evento va.*
