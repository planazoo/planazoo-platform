# Eventos desde correo: schema Firestore

> Modelo de datos en Firestore para plantillas de parseo y eventos pendientes.  
> **Relacionado:** T134, `docs/producto/CORREO_EVENTOS_SISTEMA_PARSEO.md`, `docs/producto/CORREO_EVENTOS_SPAM.md`.

---

## 1. Colección `email_templates`

Almacena las **plantillas de parseo** (una por proveedor/idioma). La leen las Cloud Functions al procesar correos entrantes; solo los **admins** pueden crear, actualizar o eliminar documentos.

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| (documentId) | string | — | Identificador único de la plantilla (ej. `hertz_recogida_es`). Puede usarse como ID del documento. |
| name | string | sí | Nombre legible (ej. "Hertz - Recogida de alquiler (ES)"). |
| locale | string | no | Código de idioma (ej. `es`, `en`). Una plantilla por idioma. |
| event_type | string | sí | Tipo de evento: `flight`, `hotel`, `rental`, `restaurant`, `transport`, `other`. |
| active | boolean | sí | Si está activa para el motor de parseo. |
| priority | number | no | Orden al matchear (menor = mayor prioridad). Por defecto 10. |
| triggers | array | sí | Lista de condiciones. Cada elemento: `{ type: "subject_contains" \| "body_contains", value: string }`. |
| fields | map | sí | Reglas de extracción por campo. Claves: confirmation_code, start_datetime, location, title, etc. Valor: objeto con `type` ("regex", "after_label", "composite"), y según tipo: `pattern`, `group`, `source`, `label`, `stop_at`, `max_lines`, `template`, `dependencies`. |
| field_order | array | no | Orden de evaluación de campos (para composite que dependen de otros). |
| createdAt | timestamp | sí | Fecha de creación. |
| updatedAt | timestamp | sí | Fecha de última actualización. |

**Reglas de seguridad:** Ver `firestore.rules` → `match /email_templates/{templateId}`. Lectura: autenticados. Escritura (create/update/delete): solo `isAdmin(userId)`.

**Ejemplo:** Ver el JSON de Hertz en `docs/producto/CORREO_EVENTOS_SISTEMA_PARSEO.md` (sección "Ejemplo: plantilla Hertz").

---

## 2. Subcolección `users/{userId}/pending_email_events`

Eventos **pendientes de asignar** a un plan (buzón del usuario). Cada documento es un correo recibido que se guardó como pendiente (parseado o sin parsear). Las Cloud Functions crean documentos aquí al procesar correos; el usuario los lista en la app, edita si quiere y asigna a un plan (entonces se crea el evento real y se elimina o marca como procesado este documento).

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| (documentId) | string | — | ID auto o generado (ej. Firestore auto-id). |
| subject | string | sí | Asunto del correo. |
| bodyPlain | string | sí | Cuerpo del correo en texto plano. |
| fromEmail | string | no | Email del remitente (por trazabilidad). |
| parsed | map \| null | no | Si se aplicó una plantilla: objeto con los campos extraídos (title, start_datetime, location, confirmation_code, event_type, etc.). Si no hay match o falló la extracción: null. |
| templateId | string \| null | no | ID de la plantilla usada (si aplica). Null si sin parsear. |
| status | string | no | Ej. `pending`, `assigned`, `discarded`. Por defecto `pending`. |
| createdAt | timestamp | sí | Fecha de recepción/creación. |
| updatedAt | timestamp | no | Última actualización (ej. al editar o asignar). |

**Reglas de seguridad:** Ver `firestore.rules` → `match /users/{userId}/pending_email_events/{eventId}`. Solo el usuario propietario (`request.auth.uid == userId`) puede read/write. Las Cloud Functions usan Admin SDK y no están sujetas a reglas.

**Consultas típicas:** Listar pendientes del usuario: `users/{userId}/pending_email_events` con `orderBy('createdAt', 'desc')`. Filtrar por `status == 'pending'` si se usa ese campo.

---

## 3. Índices

- Para listar `pending_email_events` por usuario con `orderBy('createdAt', 'desc')`: en subcolecciones un solo `orderBy` no suele requerir índice compuesto. Si más adelante se añade `where('status','==','pending').orderBy('createdAt','desc')`, añadir el índice en `firestore.indexes.json` (collectionGroup `pending_email_events`, fields status ASC, createdAt DESC).

---

## 4. Registro de intentos rechazados (anti-spam)

Según `CORREO_EVENTOS_SPAM.md`, se registran intentos rechazados (From no registrado, rate limit superado) **para depuración**. Opciones:

- **Colección dedicada:** Ej. `email_rejection_logs` con documentos que incluyan fromEmail, reason, timestamp (y opcionalmente userId si se pudo resolver). Solo Cloud Functions (admin) escriben; solo admins leen. Habría que añadir `match /email_rejection_logs/{logId}` en `firestore.rules` (write: false para client; o permitir solo admin read).
- **O en Cloud Logging / BigQuery:** Sin colección Firestore, solo logs desde la Cloud Function. Más ligero; la decisión de “datos para depuración” puede cumplirse con logs.

La Cloud Function de recepción (`inboundEmail`) está implementada en `functions/index.js`: rechazos (From no registrado, rate limit) se registran en logs (console.warn). Si más adelante se quiere persistir en Firestore, se puede añadir la colección y reglas aquí.
