# Eventos desde correo: sistema de recepción y parseo

> Cómo recibe la plataforma el correo reenviado y cómo extrae de él los datos del evento.  
> **Relacionado:** T134, `docs/producto/CORREO_EVENTOS_SPAM.md`.

**Alcance para usuarios vs administración:** Lo que ve el **usuario** en la app es solo: reenviar correos a la dirección de la plataforma, ver su buzón de eventos pendientes y asignarlos a un plan. El **catálogo de plantillas** (crear, actualizar, categorizar, generar con LLM a partir de un correo de ejemplo) es un **proceso interno de administración de la plataforma**: no está disponible en la app para usuarios finales. Solo los admins de la plataforma gestionan las plantillas.

---

## Resumen del sistema completo (con detalles)

### Visión general

El usuario **reenvía** un correo de confirmación (vuelo, hotel, alquiler, etc.) a **una dirección de la plataforma**. El sistema recibe el mensaje, valida que el remitente sea un usuario registrado y que no se supere el límite diario, extrae el cuerpo en **texto plano**, busca una **plantilla** que coincida (por asunto/cuerpo) y, si la encuentra, aplica las reglas de la plantilla para obtener campos estructurados (título, fecha, hora, ubicación, código de reserva, tipo). Esos datos se guardan como **evento pendiente** en Firestore; el usuario ve una notificación en la app, abre el **buzón de pendientes**, revisa o edita y **asigna el evento a un plan**. Si no hay plantilla que coincida o la extracción falla, el correo se guarda como **sin parsear** y el usuario puede crear el evento a mano desde el buzón. **No se usa LLM para parsear cada correo**; el LLM solo se usa en el proceso de **administración** para **generar plantillas** a partir de correos de ejemplo pegados por el admin.

---

### 1. Recepción del correo (100 % Google)

**Decisión:** Todo el flujo de recepción se hace **con productos Google**: un buzón Gmail o Google Workspace y **Gmail API**. No se usa ningún proveedor externo de inbound parse (SendGrid, Mailgun, etc.).

- **Dirección:** Una **dirección global** (ej. `eventos@planazoo.com`) como buzón real en Gmail o Google Workspace. El usuario se identifica por el **From** del correo (quien reenvía).
- **Cómo llega al backend:**
  - **Buzón** (`eventos@...`) recibe el correo reenviado por el usuario.
  - **Gmail API** lee ese buzón: un job (Cloud Scheduler + Cloud Function) hace **polling** cada X minutos, lista mensajes no leídos, extrae de cada uno **From**, **Subject** y cuerpo en **texto plano**, aplica la misma lógica (validar From = usuario registrado, rate limit, crear evento pendiente) y marca el mensaje como leído (o lo mueve a etiqueta "Procesados").
  - Opcionalmente más adelante: **Gmail API watch** + Pub/Sub para disparar la función al llegar correo nuevo (menor latencia, sin polling).
- **Implementación:**
  - **`processInboundGmail`** (Cloud Function invocada por Cloud Scheduler): conecta al buzón con Gmail API (service account + domain-wide delegation en Workspace), procesa correos no leídos y crea documentos en `users/{userId}/pending_email_events`. Ver sección "Recepción 100% Google" más abajo.
  - **`inboundEmail`** (HTTP POST): se mantiene por si en el futuro se quiere conectar un webhook externo; recibe `{ from, subject, text?, html? }` y reutiliza la misma lógica de validación y guardado.
- **Formato interno:** Para el resto del flujo se trabaja con **asunto** (string) y **cuerpo en texto plano**. Si el correo tiene solo parte HTML, se convierte HTML → texto plano antes de matchear plantillas y extraer campos.

---

### 2. Validación anti-spam (antes de parsear)

- **From = usuario registrado:** Solo se procesan correos cuyo **remitente (From)** coincida con un email de un usuario registrado en la plataforma. De momento se acepta **también alias** (ej. Gmail `+`); en el futuro solo email principal (tarea T216). Si el From no está registrado: no procesar, **no responder** al remitente, y **registrar** el intento para depuración.
- **Rate limit:** **50 correos por día** por usuario. Al superar el límite: no procesar ese correo y **avisar al usuario** (por app o email). También se registra para depuración.
- **Lista blanca:** No se usa; cualquier usuario registrado puede usar la dirección de reenvío (sujeto a rate limit).
- **Registro:** Se guardan datos de intentos rechazados (From no registrado, rate limit superado) **para depuración**.

Detalle completo en `docs/producto/CORREO_EVENTOS_SPAM.md`.

---

### 3. Parseo: solo plantillas (sin LLM por correo)

- **Entrada:** Asunto + cuerpo en texto plano (y opcionalmente From, si se quiere priorizar plantillas por dominio).
- **Catálogo de plantillas:** Está en **Firestore**, en una colección tipo `email_templates`. Cada documento es una plantilla con: `id`, `name`, `locale` (es, en, …), `event_type`, `active`, `priority`, `triggers`, `fields`, `field_order`, `createdAt`, `updatedAt`. **Una plantilla por idioma** cuando el mismo proveedor envía el mismo tipo de correo en varios idiomas (ej. `hertz_recogida_es`, `hertz_recogida_en`).
- **Triggers:** Lista de condiciones para “este correo es de este tipo”. Tipos soportados: `subject_contains` (cadena en asunto), `body_contains` (cadena en cuerpo). Si el usuario reenvía desde su Gmail, el From es su Gmail, por eso los triggers se basan en **contenido** (asunto y cuerpo), no solo en From.
- **Fields:** Reglas de extracción por campo. Tipos ej.: `regex` (pattern + group sobre body o subject), `after_label` (tomar líneas tras una etiqueta, ej. “Ubicación”, hasta otra etiqueta o N líneas), `composite` (componer un campo a partir de otros, ej. título = “Hertz – {location} ({confirmation_code})”). Campos típicos: `confirmation_code`, `start_datetime` (o `start_date` + `start_time`), `location`, `title`, `event_type` (fijo en la plantilla).
- **Orden de aplicación:** (1) Normalizar cuerpo a texto plano si hace falta. (2) Recorrer plantillas (por prioridad) y **matchear** la primera cuyo trigger coincida. (3) **Extraer** con las reglas de esa plantilla; si se obtienen al menos los campos obligatorios (p. ej. título + fecha), guardar como evento pendiente. (4) Si **no hay match** o la **extracción falla**: guardar el raw como “sin parsear” en el buzón; el usuario crea el evento a mano. **En ningún caso** se llama al LLM para parsear el correo entrante.
- **Implementación:** Motor en `functions/index.js`: `runTemplateEngine(db, subject, bodyPlain)` carga `email_templates` activas, ordena por `priority`, matchea triggers (`subject_contains`, `body_contains`) y extrae campos (`regex`, `after_label`, `composite`). Se llama desde `processInboundEmail`; el documento en `pending_email_events` guarda `parsed` y `templateId` cuando hay match.

---

### 4. Guardado y experiencia de usuario

- **Evento pendiente:** Se crea un documento en Firestore (colección tipo `pending_email_events` o integrada en el usuario) con: `userId`, datos extraídos (título, fecha, ubicación, código, tipo), `templateId` usado (si aplica), `raw` opcional (para depuración), `timestamp`.
- **App (usuario):** Notificación “tienes N eventos pendientes de asignar”. El usuario abre el **buzón**, ve la lista de pendientes (parseados y sin parsear), puede **editar** los datos antes de confirmar, **asigna a un plan** y confirma → se crea el **evento real** en ese plan. Los pendientes se marcan como procesados o se eliminan.

---

### 5. Administración: generación de plantillas (solo admin)

- **Quién:** Solo **administradores de la plataforma**. No está en la app para usuarios finales.
- **Flujo para crear una plantilla desde un correo:**
  1. El admin tiene un correo de confirmación (en su buzón admin o personal, ej. Gmail).
  2. **Entrega el correo al sistema:** reenviando a una dirección interna (ej. `plantillas@...`), o pegando asunto + cuerpo en un panel de admin, o conectando su Gmail y eligiendo el mensaje (vía Gmail API).
  3. El sistema **extrae texto plano:** si hay parte `text/plain`, la usa (decodificando Base64 si aplica); si solo hay `text/html`, convierte HTML → texto plano. Monta: `Subject: ...` + cuerpo.
  4. Ese texto se envía a la **LLM** con un **prompt fijo** (ver doc, sección 2.3) que pide: “Genera una plantilla en JSON con id, name, locale, event_type, triggers (subject_contains / body_contains), fields (regex, after_label, composite)”. La LLM devuelve **solo** el JSON de la plantilla.
  5. El sistema parsea el JSON, opcionalmente **ejecuta la plantilla sobre el mismo correo** y muestra al admin “con esta plantilla se extraería: título = X, fecha = Y, …”. El admin **revisa y puede editar** (regex, triggers) antes de publicar.
  6. El admin **publica** → el documento se guarda en la colección `email_templates` de Firestore. A partir de ahí, el motor de parseo la usará para correos entrantes.
- **Idiomas:** Un correo de ejemplo en español genera una plantilla con `locale: "es"` y `id` tipo `hertz_recogida_es`; si el mismo proveedor envía en inglés, el admin puede generar otra con `locale: "en"` y `id` `hertz_recogida_en`. Una plantilla por idioma.
- **Actualizar / categorizar:** El mismo flujo permite pasar una plantilla existente + correos que fallaron o ejemplos nuevos para que la LLM sugiera cambios; o asignar/categorizar tipo de evento y nombre.

---

### 6. Extracción de texto plano desde el correo (detalle)

- **Si el correo viene por Gmail API:** `payload.parts` → buscar parte con `mimeType === 'text/plain'`; si existe, decodificar `body.data` (Base64url) y usar ese string como cuerpo. Si no hay `text/plain` y sí `text/html`, decodificar la parte HTML y convertir HTML → texto plano. Asunto: en `payload.headers`, cabecera `Subject`.
- **Si el correo viene por inbound parse (webhook):** El POST suele traer campos `text` y/o `html` y `subject`. Usar `text` si existe; si solo `html`, convertir a texto plano.
- **Formato final para la LLM (solo cuando el admin genera plantilla):** `"Subject: " + asunto + "\n\n" + cuerpoEnTextoPlano`.

---

### 7. Ejemplo de plantilla: Hertz recogida (ES)

- **id:** `hertz_recogida_es`
- **name:** Hertz - Recogida de alquiler (ES)
- **locale:** es
- **event_type:** rental
- **triggers:** subject_contains "recogida de alquiler" o "Hertz"; body_contains "emails.hertz.com" o "N.º DE CONFIRMACIÓN:"
- **fields:** confirmation_code (regex tras "N.º DE CONFIRMACIÓN:"), start_datetime (regex línea “Fecha y hora”), location (after_label "Ubicación" hasta "Horario de apertura"), title (composite con location + confirmation_code).

El JSON completo está en el doc (sección 2.1). El **prompt** para que la LLM genere una plantilla desde un correo pegado está en la sección 2.3.

---

### 8. Decisiones cerradas (referencia)

| Tema | Decisión |
|------|----------|
| Recepción | **100% Google:** Buzón Gmail/Workspace + Gmail API (polling con Cloud Scheduler). Sin proveedores externos de inbound. |
| Dirección | Global (`eventos@...`); usuario identificado por From. |
| Anti-spam | From = usuario registrado (de momento + alias); 50 correos/día; no responder a no registrado; registrar rechazos para depuración. |
| Parseo | Solo plantillas; sin LLM por correo. LLM solo para crear/actualizar/categorizar plantillas (admin). |
| Catálogo | Firestore, colección `email_templates`; solo admins escriben. |
| Idiomas | Una plantilla por idioma; campo `locale`. |
| Fallo de parseo | Guardar como “sin parsear” en buzón; usuario crea evento a mano. |

---

## 1. Recepción del correo: cómo llega a nosotros

El usuario reenvía una confirmación (vuelo, hotel, restaurante, etc.) **a una dirección nuestra**. Esa dirección debe ser capaz de “entregar” el mensaje a nuestro backend. Opciones típicas:

| Opción | Descripción | Pros | Contras |
|--------|-------------|------|---------|
| **A) Inbound parse (webhook)** | Servicio de email (SendGrid, Mailgun, Postmark, Amazon SES, etc.) recibe el correo en nuestra dirección y hace **POST a una URL nuestra** (Cloud Function) con el contenido ya parseado (from, to, subject, body texto/HTML, adjuntos). | No mantener buzón; el proveedor hace el trabajo sucio; escalable. | Dependencia de un proveedor; configurar dominio (MX, SPF, DKIM). |
| **B) Polling de un buzón** | Una dirección tipo `eventos@planazoo.com` es un buzón real (Gmail, Google Workspace, etc.); un job (Cloud Scheduler + Function) **lee el buzón** periódicamente (p. ej. IMAP o Gmail API) y procesa mensajes nuevos. | Control total; no depender de inbound parse. | Mantener credenciales del buzón; latencia según frecuencia del poll; más código. |
| **C) Email forwarding + webhook** | El correo llega a un buzón y un servicio (Zapier, Make, o custom) reenvía el contenido a nuestra URL. | Flexible. | Capa extra; mismo tema de buzón o de integración. |

**Recomendación para MVP:** **A) Inbound parse** con un proveedor externo, **o B) Buzón Google** si se prefiere todo en ecosistema Google (ver sección 1.1).

### 1.1 ¿Podemos usar un servicio de Google para inbound?

**Google no ofrece** un producto tipo “inbound parse” (recibir correo y hacer POST a tu URL). Las opciones con stack Google son:

| Opción Google | Descripción |
|---------------|-------------|
| **Gmail o Google Workspace (buzón)** | Crear una cuenta tipo `eventos@tudominio.com` (o alias) en Gmail/Workspace. Un **job** (Cloud Scheduler + Cloud Function) lee el buzón cada X minutos vía **Gmail API** (list messages, get message, extraer body). Los mensajes nuevos se procesan y se marcan como leídos (o se mueven a una etiqueta “Procesados”). |
| **Gmail API Push (opcional)** | En lugar de polling, se puede usar **Gmail API watch** (pub/sub): Gmail notifica a un topic de Pub/Sub cuando llega correo nuevo; una Cloud Function suscrita al topic se dispara y procesa. Reduce latencia y evita polling constante. |

**Conclusión:** La plataforma usa **solo Google** para recepción: **buzón Gmail/Workspace + Gmail API** (polling con Cloud Scheduler). Todo queda en el ecosistema Google (dominio, buzón, Cloud Functions, Scheduler).

### 1.2 Recepción 100% Google: configuración e implementación

- **Buzón:** Una cuenta o alias tipo `eventos@tudominio.com` en Google Workspace (recomendado) o Gmail. Los usuarios reenvían ahí sus confirmaciones.
- **Autenticación Gmail API (Workspace):** Service account del proyecto GCP con **domain-wide delegation**. En Admin de Google Workspace se autoriza al client ID de la SA con los scopes `https://www.googleapis.com/auth/gmail.readonly` y `https://www.googleapis.com/auth/gmail.modify` (para marcar como leído). La Cloud Function usa la SA para **impersonar** al usuario del buzón (`eventos@...`) y listar/leer mensajes.
- **Configuración (Firebase config o variables de entorno en la Cloud Function):**
  - **Buzón:** `GMAIL_INBOUND_MAILBOX` o `functions.config().gmail_inbound.mailbox` = email del buzón. Actual: `unplanzoo+eventos@gmail.com` (ver `docs/configuracion/GMAIL_INBOUND_BUZON.md`).
  - **Service account (domain-wide delegation):** Una de las dos:
    - `GMAIL_INBOUND_SA_JSON`: JSON completo de la clave de la cuenta de servicio (string).
    - O bien `GMAIL_INBOUND_SA_CLIENT_EMAIL` + `GMAIL_INBOUND_SA_PRIVATE_KEY` (la clave con `\n` escapados o reales).
  - **Protección del job:** `GMAIL_POLL_SECRET` o `gmail_inbound.poll_secret`: si está definido, Cloud Scheduler debe enviar la cabecera `X-Gmail-Poll-Secret` con ese valor (evita que cualquiera llame la URL).
- **Cloud Scheduler:** Crear un job en Google Cloud Console (Cloud Scheduler) que ejecute cada 5–10 minutos (ej. `*/10 * * * *`), método HTTP POST (o GET), URL = `https://<region>-<project>.cloudfunctions.net/processInboundGmail`, y cabecera `X-Gmail-Poll-Secret: <valor>` si se configuró el secreto.
- **Varios buzones (resiliencia):** Se puede configurar **más de un buzón** (`GMAIL_INBOUND_MAILBOX_LIST`: lista separada por comas o JSON array). El job procesa cada buzón en secuencia; si uno falla (cuenta bloqueada, auth, cuota), se registra el error y se sigue con el siguiente. Así se puede tener `eventos@` principal y `eventos-backup@`; si el principal sufre un ataque o se deshabilita, se puede desviar el correo al backup en Workspace y el job ya lee ambos (o solo el backup si se quita el principal de la lista).
- **Desvío en Workspace:** En Google Workspace Admin se puede configurar **reenvío** desde `eventos@` hacia `eventos-backup@` (o una regla de enrutamiento). En caso de incidente, se activa el reenvío y se asegura que la lista de buzones del job incluya el buzón de respaldo (o se cambia la config para usar solo el backup).
- **Implementación:** La función `processInboundGmail` recorre la lista de buzones, para cada uno lista mensajes con `is:unread`, obtiene From (se extrae la dirección de "Nombre <email>"), Subject y cuerpo (text/plain o html→texto), llama a `processInboundEmail` y marca el mensaje como leído.
- **Detalle de extracción desde Gmail API:** En `payload.headers` se busca `From` y `Subject`. En `payload.parts` se busca la parte con `mimeType === 'text/plain'`; si no hay, la parte `text/html` y se convierte a texto plano. Decodificación Base64url en `body.data` cuando exista.

### 1.3 Riesgos de la solución (buzón + Gmail API)

| Riesgo | Descripción | Mitigación |
|--------|-------------|------------|
| **Acceso al buzón** | La Service Account con domain-wide delegation puede leer y modificar todo el buzón. Si se filtra la clave, un atacante tendría ese acceso. | Guardar la clave en Secret Manager (no en env plano); rotación periódica; mínimo privilegio (solo esa SA para este uso). |
| **Endpoint público** | Si no se configura `GMAIL_POLL_SECRET`, cualquiera que conozca la URL de `processInboundGmail` puede invocarla (desperdicio de cuota, posible DoS). | Configurar siempre `GMAIL_POLL_SECRET` y usarlo en Cloud Scheduler; opcionalmente restringir por IP si Scheduler usa IP fija. |
| **Duplicados por fallo** | Si la función falla *después* de crear el evento pendiente pero *antes* de marcar el mensaje como leído, en la siguiente ejecución se procesaría el mismo correo otra vez → evento duplicado. | Aceptable para MVP; más adelante se puede guardar el `messageId` de Gmail en el documento pendiente y deduplicar por él antes de crear. |
| **Identificación por From** | El usuario se identifica por la cabecera From. En reenvíos típicos (Gmail “reenviar”) From es quien reenvía; en otros clientes o flujos podría variar y atribuirse mal. | Documentar que “el usuario es quien reenvía”; en entornos controlados (app + reenvío desde Gmail) el riesgo es bajo. |
| **Dependencia de Workspace** | Si se deja de usar Google Workspace o se revoca la delegación, el job deja de funcionar. | Tener claro el contrato/dominio; monitoreo de fallos del job (alertas en Cloud Monitoring). |
| **Contenido sensible en Firestore** | Se guarda `bodyPlain` (cuerpo del correo) en `pending_email_events`; puede contener datos personales o códigos de reserva. | Reglas Firestore ya limitan a que solo el usuario propietario lea sus documentos; definir política de retención y borrado según RGPD/privacidad. |
| **Cuotas Gmail API** | Límites por proyecto (p. ej. mensajes/día). En volumen alto podría haber rechazos. | Revisar cuotas en consola; si crece el uso, solicitar aumento o repartir carga (varios buzones/jobs). |

---

## 2. Parseo del cuerpo del correo: de texto a “evento”

El cuerpo del mensaje (texto plano o HTML convertido a texto) es un correo de confirmación típico: líneas con fecha, hora, lugar, referencia, etc. Hay que extraer **campos estructurados** para crear un evento (título, fecha/hora inicio, duración o fin, ubicación, tipo, código de reserva, etc.). Opciones:

| Enfoque | Descripción | Pros | Contras |
|---------|-------------|------|---------|
| **1) Reglas / regex** | Patrones fijos para fechas, horas, “Vuelo”, “Hotel”, etc. | Barato, sin llamadas externas, rápido. | Frágil; cada proveedor (Ryanair, Booking, etc.) tiene formato distinto; muchos edge cases. |
| **2) Plantillas por remitente/contenido** | Parser específico por proveedor o tipo de correo (triggers + regex/patrones). | Muy preciso, sin coste por correo, predecible. | Mantenimiento: añadir plantillas; el LLM se usa **solo para crear/actualizar/categorizar plantillas**, no para evaluar cada mail (ver 2.2). |

**Decisión:** **Solo plantillas** para parsear cada correo entrante. **No** se usa LLM para evaluar los mails. El LLM se usa únicamente como **herramienta para crear, actualizar y categorizar las plantillas** (sección 2.2). Si no hay plantilla que coincida o la extracción falla → guardar el correo como “sin parsear” en el buzón para que el usuario cree el evento a mano.

### 2.1 Sistema de plantillas (profundización)

La idea es tener **plantillas de parseo** por proveedor o tipo de correo: cada plantilla define “cómo extraer” los campos del evento a partir del cuerpo (y opcionalmente del asunto o de cabeceras). Así se obtiene precisión alta para los correos más frecuentes (vuelos, hoteles, restaurantes conocidos) sin depender del LLM en todos los casos.

#### Qué es una plantilla

- **Trigger (cuándo aplicar):** Por **dominio/remitente** del correo (ej. `@ryanair.com`, `noreply@booking.com`) o por **patrón en asunto** (ej. “Confirmación de vuelo”, “Your booking”) o por **patrón en las primeras líneas del cuerpo**.  
  **Problema:** Si el usuario **reenvía** desde su Gmail, el `From` que recibimos es su Gmail, no `noreply@ryanair.com`. Por eso el trigger no puede ser solo el From actual; hay que poder matchear también por **contenido**: asunto, o líneas del cuerpo que suelen contener “From: …” o “Sent by …” en reenvíos, o cadenas típicas del proveedor (ej. “Ryanair”, “Booking.com”).
- **Definición de extracción:** Para cada campo del evento (título, fecha inicio, hora, duración o fecha fin, ubicación, tipo, código de reserva), la plantilla define **cómo extraerlo**:
  - **Regex** sobre el texto completo o sobre un bloque (ej. “la línea que contiene ‘Date:’ seguida de una fecha”).
  - **Patrón por líneas:** “línea 3 = título”, “buscar línea que empiece por ‘Check-in:’ y extraer fecha”.
  - **Bloques:** “entre ‘---’ y ‘---’ está la tabla del vuelo; extraer filas con origen, destino, hora”.

#### Idiomas: una plantilla por idioma vs multidioma

Los correos del mismo proveedor pueden llegar en distintos idiomas (ej. Hertz en español “N.º DE CONFIRMACIÓN”, “Ubicación” vs inglés “Confirmation number”, “Location”). Dos enfoques:

| Enfoque | Descripción | Pros | Contras |
|--------|-------------|------|---------|
| **Una plantilla por idioma** | Documentos separados en Firestore: `hertz_recogida_es`, `hertz_recogida_en`. Cada uno tiene triggers y reglas de extracción en ese idioma (etiquetas, cadenas del asunto). | Estructura clara; cada plantilla es simple. | Más documentos; duplicar lógica al añadir un idioma. |
| **Una plantilla multidioma** | Un solo documento por proveedor/tipo; en triggers y en reglas (ej. `after_label`) se permiten **varios valores**: `labels: ["Ubicación", "Location"]`, `subject_contains: ["recogida de alquiler", "rental pickup"]`. El motor prueba todos hasta que uno coincida. | Un solo documento por lógica de negocio; menos duplicación. | Schema algo más complejo; hay que definir bien el formato (array de valores por trigger/campo). |

**Decisión recomendada:** **Una plantilla por idioma** (ej. `id: hertz_recogida_es`, `hertz_recogida_en`) con un campo opcional `locale` o `lang` (es, en, …) para filtrar o priorizar. Es más fácil de generar con la LLM (un correo de ejemplo = un idioma = una plantilla) y de mantener. Si más adelante se quiere agrupar, se puede usar un `provider` o `template_group` (ej. `hertz_recogida`) compartido.

Formato posible de una plantilla (ejemplo conceptual, podría ser YAML o JSON en repo o Firestore):

```yaml
id: ryanair
name: Ryanair
triggers:
  - type: subject_contains
    value: "Ryanair"
  - type: body_contains
    value: "ryanair.com"
fields:
  title: { regex: "Flight (\\w+)\\s*-\\s*(.+?) to (.+?)", groups: [1,2,3] }  # o composición
  start_date: { regex: "Departure: (\\d{2}/\\d{2}/\\d{4})", group: 1 }
  start_time: { regex: "Time: (\\d{2}:\\d{2})", group: 1 }
  location: { from_line: "Airport: (.+)", regex: "(.+)" }
  confirmation_code: { regex: "Booking reference: (\\w+)", group: 1 }
  event_type: flight
```

(El ejemplo es ilustrativo; la sintaxis real se definiría al implementar.)

#### Ejemplo: plantilla Hertz (recogida de alquiler)

Documento de ejemplo tal como podría guardarse en Firestore para el correo de confirmación de Hertz:

```json
{
  "id": "hertz_recogida_es",
  "name": "Hertz - Recogida de alquiler (ES)",
  "locale": "es",
  "event_type": "rental",
  "active": true,
  "priority": 10,
  "createdAt": "2026-02-06T12:00:00Z",
  "updatedAt": "2026-02-06T12:00:00Z",
  "triggers": [
    { "type": "subject_contains", "value": "recogida de alquiler" },
    { "type": "subject_contains", "value": "Hertz" },
    { "type": "body_contains", "value": "emails.hertz.com" },
    { "type": "body_contains", "value": "N.º DE CONFIRMACIÓN:" }
  ],
  "fields": {
    "confirmation_code": {
      "type": "regex",
      "source": "body",
      "pattern": "N\\.º DE CONFIRMACIÓN:\\s*(L\\d+)",
      "group": 1
    },
    "start_datetime": {
      "type": "regex",
      "source": "body",
      "pattern": "Fecha y hora\\s*\\n\\s*([A-Za-z]{3},\\s*[A-Za-z]{3}\\s+\\d{1,2},\\s*\\d{4}\\s*\\|\\s*\\d{1,2}:\\d{2}\\s*[AP]M)",
      "group": 1
    },
    "location": {
      "type": "after_label",
      "source": "body",
      "label": "Ubicación",
      "stop_at": "Horario de apertura",
      "max_lines": 3
    },
    "title": {
      "type": "composite",
      "template": "Hertz – {location_line1} ({confirmation_code})",
      "dependencies": ["location", "confirmation_code"]
    }
  },
  "field_order": ["confirmation_code", "start_datetime", "location", "title"]
}
```

La sintaxis de `fields` (regex, after_label, composite) debe coincidir con el motor de extracción que se implemente.

#### Orden de aplicación

1. **Normalizar entrada:** Cuerpo en texto plano (si llega HTML, convertir a texto); opcionalmente incluir en el “texto a parsear” una línea tipo `Original-From: ...` si el cliente de correo la añade al reenviar.
2. **Matchear plantilla:** Recorrer plantillas por prioridad (ej. por dominio si tenemos From original, luego por subject, luego por body). Primera que coincida → usar esa plantilla.
3. **Extraer con la plantilla:** Aplicar las reglas de la plantilla; si se obtienen al menos título + fecha (o los obligatorios del schema), guardar como evento pendiente.
4. **Si no hay match o la extracción falla:** Guardar el raw como “sin parsear” en el buzón para que el usuario lo vea y pueda crear el evento a mano. **No** se llama al LLM para parsear ese correo.

#### Mantenimiento de plantillas

- **Catálogo:** El catálogo de plantillas **vive en Firestore** (colección tipo `email_templates` o `plantillas_correo`). Cada documento = una plantilla (id, name, triggers, fields, event_type, active, createdAt, etc.). Las Cloud Functions que parsean el correo entrante leen esta colección; solo los admins de la plataforma pueden crear, editar o desactivar plantillas. Sin redespliegue al añadir o cambiar plantillas.
- **Añadir una nueva:** Crear plantilla para un nuevo remitente/proveedor. Aquí es donde entra el **LLM** (ver 2.2): como herramienta para **crear, actualizar y categorizar** plantillas, no para parsear cada correo.
- **Prioridad:** Si dos plantillas pudieran coincidir, definir orden (ej. por dominio primero, luego por subject más específico).
- **Tests:** Tener correos de ejemplo por plantilla y tests que comprueben que la extracción devuelve el JSON esperado.

#### Ventajas del sistema de plantillas (sin LLM en el flujo de correo)

- **Precisión** en proveedores conocidos; **cero coste por correo** y sin latencia de IA en recepción.
- **Previsibilidad** y fácil depuración (sabes qué plantilla se aplicó).
- **Escalable:** Se amplía el catálogo de plantillas; el LLM ayuda a **generar** esas plantillas a partir de ejemplos.

### 2.2 Uso del LLM: crear, actualizar y categorizar plantillas (solo administración)

El **LLM no se usa para evaluar/parsear cada correo entrante**. Se usa como soporte para el mantenimiento del catálogo de plantillas, en un **proceso exclusivo del admin de la plataforma** (no expuesto a usuarios de la app). Los usuarios no pueden crear ni editar plantillas.

| Uso | Descripción |
|-----|-------------|
| **Crear plantillas** | Dado uno o varios **correos de ejemplo** (raw o texto), el LLM sugiere una **definición de plantilla**: triggers (patrones en asunto/cuerpo que identifiquen este tipo de correo) y reglas de extracción por campo (regex o patrones de líneas). Un humano revisa, ajusta si hace falta y añade la plantilla al catálogo. |
| **Actualizar plantillas** | Si una plantilla existente deja de matchear bien (ej. el proveedor cambió el formato), se le pasa la plantilla actual + correos de ejemplo nuevos o que fallaron. El LLM sugiere **cambios** en triggers o en las reglas de extracción. Revisión humana y actualización del catálogo. |
| **Categorizar plantillas** | Asignar o sugerir **tipo de evento** (vuelo, hotel, restaurante, transporte, etc.) y nombre legible para la plantilla; opcionalmente agrupar plantillas por categoría. Ayuda a mantener el catálogo ordenado y a que la app muestre mejor el tipo de evento creado. |

**Flujo típico (admin):** Proceso interno (UI de admin o script, no en la app de usuarios) donde el admin pega o sube un correo de ejemplo → el LLM propone una plantilla (o una actualización) → el equipo la revisa, la prueba con más ejemplos y la publica al catálogo. El parseo en tiempo real de los correos entrantes sigue siendo **solo con plantillas**, sin llamadas al LLM. Los usuarios finales no tienen acceso a este flujo.

### 2.3 Prompt para generar plantilla desde correo pegado

Cuando el admin pega el contenido de un correo (asunto + cuerpo en texto plano), se envía a la LLM con el siguiente prompt (o variante equivalente). La salida debe ser **solo** el JSON de la plantilla, sin texto adicional, para poder parsearla y guardarla en Firestore.

---

**Prompt del sistema (instrucciones fijas):**

```
Eres un asistente que genera definiciones de plantillas de parseo para correos de confirmación. Tu salida debe ser ÚNICAMENTE un objeto JSON válido, sin markdown ni texto antes o después.

El usuario te pasará un correo de confirmación (asunto + cuerpo en texto plano). Tu tarea es generar una plantilla que permita extraer de correos similares los siguientes campos de evento:
- title (título del evento; puede ser compuesto a partir de otros campos)
- start_datetime o start_date + start_time (fecha y hora de inicio)
- end_datetime o duration (opcional; fecha/hora fin o duración)
- location (ubicación)
- confirmation_code (código de reserva/confirmación)
- event_type (tipo: flight, hotel, rental, restaurant, transport, other)

Estructura JSON que debes devolver (usa exactamente estas claves):

{
  "id": "identificador_unico_snake_case",
  "name": "Nombre legible de la plantilla (ej. Proveedor - Tipo de confirmación)",
  "event_type": "flight|hotel|rental|restaurant|transport|other",
  "active": true,
  "priority": 10,
  "triggers": [
    { "type": "subject_contains", "value": "cadena que identifique este tipo de correo en el asunto" },
    { "type": "body_contains", "value": "cadena que identifique este tipo de correo en el cuerpo" }
  ],
  "fields": {
    "confirmation_code": { "type": "regex", "source": "body", "pattern": "regex con un grupo de captura", "group": 1 },
    "start_datetime": { ... },
    "location": { "type": "after_label", "source": "body", "label": "Etiqueta que precede al valor", "stop_at": "Etiqueta que marca el fin del bloque", "max_lines": 5 },
    "title": { "type": "composite", "template": "Texto con {campo1} y {campo2}", "dependencies": ["campo1", "campo2"] }
  },
  "field_order": ["confirmation_code", "start_datetime", "location", "title"]
}

Reglas:
- triggers: incluye al menos 2 condiciones (subject_contains y/o body_contains) que identifiquen de forma fiable este tipo de correo. Usa cadenas que aparezcan en el correo (nombre del proveedor, dominio, etiquetas típicas).
- fields: para cada campo usa "regex" (con "pattern" y "group") cuando el valor esté en una línea con patrón claro; usa "after_label" cuando el valor esté justo después de una etiqueta (ej. "Ubicación" seguido de la dirección). Para title puedes usar "composite" si se compone de otros campos.
- id: nombre corto en snake_case derivado del proveedor y tipo (ej. hertz_recogida, ryanair_vuelo).
- event_type: elige el más adecuado (rental para alquiler coche, flight para vuelos, hotel para hoteles, etc.).
- No inventes datos: las cadenas en triggers y los patrones en fields deben basarse en el correo que te pasan.
- Responde SOLO con el JSON. Sin explicaciones ni texto alrededor.
```

---

**Mensaje del usuario (variable):**

```
Correo de ejemplo:

Subject: [aquí el asunto que pegó el admin]

[aquí el cuerpo en texto plano que pegó el admin]
```

---

La respuesta de la LLM se parsea como JSON, se valida (id, triggers, fields obligatorios) y se muestra al admin para revisión y prueba antes de guardar en Firestore. Si la LLM devuelve texto alrededor del JSON, se puede intentar extraer el primer bloque `{ ... }` antes de parsear.

---

## 3. Flujo end-to-end propuesto

1. **Recepción:** Correo a `eventos@...` (dirección global; ver 4) → Inbound (webhook externo o Gmail API) entrega a Cloud Function.
2. **Validación:** From = usuario registrado (o alias si aplica); rate limit 50/día; si falla, registrar para depuración y no responder.
3. **Parseo:** Cuerpo (text/plain o HTML→text) → **solo plantillas** (match por subject/body/From); si hay match, extraer con la plantilla y guardar evento pendiente. Si no hay match o la extracción falla: guardar raw “sin parsear” en buzón para edición manual. **No** se usa LLM para parsear correos.
4. **Guardado:** Crear documento “evento pendiente” en Firestore, con userId, datos parseados, plantilla usada (si aplica), raw (opcional), timestamp.
5. **App:** Notificación “tienes N eventos pendientes”; usuario abre buzón, revisa/edita, asigna a un plan y confirma → evento real en el plan.

---

## 4. Decisiones (estado)

| Tema | Decisión / estado |
|------|-------------------|
| **Proveedor inbound** | **Usar servicio de Google:** buzón Gmail/Workspace + **Gmail API** (polling o push con watch). Alternativa: proveedor externo (SendGrid, Mailgun) con webhook a Cloud Function. |
| **Dirección** | **Global** (una sola dirección tipo `eventos@...`); el usuario se identifica por **From**. No cerrado al 100%: se puede revisar si hace falta dirección por usuario más adelante. |
| **Parseo** | **Solo plantillas** (por remitente/contenido; ver 2.1). Sin LLM para evaluar correos. **LLM solo para crear, actualizar y categorizar plantillas** (ver 2.2). |
| **Schema de salida** | Aceptado: campos obligatorios y opcionales (título, start, end o duration, location, type, confirmationCode); si no se puede extraer fecha, guardar como pendiente de revisión o sin parsear en buzón. |
| **Reintentos / fallo** | Aceptado: si el parseo falla, guardar el raw como “sin parsear” para que el usuario lo vea en el buzón y pueda crear el evento a mano. |
| **Catálogo de plantillas** | **Firestore.** Colección (ej. `email_templates`) donde se guardan las plantillas; las Cloud Functions leen de ahí al parsear. Solo admins escriben; sin deploy al publicar o editar plantillas. |
| **Idiomas** | **Una plantilla por idioma** (ej. `hertz_recogida_es`, `hertz_recogida_en`). Campo opcional `locale`/`lang` (es, en, …). Un correo de ejemplo en un idioma genera una plantilla en ese idioma; si el mismo proveedor envía en varios idiomas, se crean varias plantillas. Ver sección 2.1 “Idiomas”. |

Cuando se implemente T134, bajar a criterios de aceptación y diseño técnico (Cloud Function, colección Firestore, formato de plantillas). La herramienta de LLM para plantillas (crear/actualizar/categorizar) puede ser una tarea o fase aparte (admin/backoffice).
