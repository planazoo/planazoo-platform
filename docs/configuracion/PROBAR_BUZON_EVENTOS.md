# Probar el buzón de eventos desde correo

> Pasos para verificar que el listado y "Asignar a plan" funcionan sin depender aún del correo real.

## 1. Crear la subcolección y el primer documento (paso a paso)

La subcolección **se crea al añadir el primer documento**. Sigue estos pasos en orden.

---

### Paso 1 — Abrir Firestore
1. Entra en [Firebase Console](https://console.firebase.google.com).
2. Elige tu proyecto.
3. En el menú izquierdo: **Build** → **Firestore Database** (o **Firestore**).

---

### Paso 2 — Ir a tu usuario (importante: Auth UID)
4. En la pestaña **"Data"** / **"Datos"** verás la lista de colecciones.
5. Haz **clic en la colección** `users`.
6. Verás una lista de documentos. La app solo puede leer eventos en **users / [Auth UID] / pending_email_events**. El **Auth UID** es el UID de Firebase Authentication (no siempre coincide con otro ID que uses en la app). En el Buzón de la app se muestra como **"ID usuario (Auth UID): xxx"** — ese es el ID del documento de `users` donde debes crear la subcolección.
7. **Haz clic en el documento** de `users` cuyo **ID** es exactamente ese Auth UID (el que muestra el Buzón).

---

### Paso 3 — Crear la subcolección
8. Se abre la vista del documento de ese usuario. Baja hasta la sección **"Subcollections"** / **"Subcolecciones"** (puede estar vacía).
9. Pulsa el botón **"Start collection"** o **"Iniciar colección"** (a veces aparece como **+ Collection** o un **+** al lado de "Subcollections").
10. En el campo **"Collection ID"** / **"ID de colección"** escribe exactamente (sin espacios, sin mayúsculas extra):
    ```
    pending_email_events
    ```
11. Pulsa **"Next"** / **"Siguiente"**.

---

### Paso 4 — Añadir el primer documento
12. Ahora te pide crear el **primer documento** de esa subcolección.
13. **Document ID:** deja **"Auto-ID"** y pulsa **"Next"** / **"Siguiente"**.

14. Añade cada **campo** con **"Add field"** / **"Añadir campo"**. Para cada uno elige **tipo** y escribe el **valor**:

| # | Nombre del campo | Tipo        | Valor |
|---|------------------|-------------|--------|
| 1 | `subject`        | string      | `Confirmación Hertz - Recogida` |
| 2 | `bodyPlain`      | string      | `Cuerpo de prueba del correo` |
| 3 | `fromEmail`      | string      | Tu email (el que usas en la app) |
| 4 | `status`         | string      | `pending` (tiene que ser exactamente esta palabra) |
| 5 | `createdAt`      | timestamp   | Pulsa el icono de reloj y elige "Now" / "Ahora" |
| 6 | `updatedAt`      | timestamp   | Pulsa el icono de reloj y elige "Now" / "Ahora" |

15. **(Opcional)** Si quieres que en la app se vea un **título y una ubicación** ya rellenados, añade un campo más:
   - **Nombre:** `parsed`
   - **Tipo:** map
   - Dentro del map, añade estas entradas (en la consola suele ser "Add field" dentro del map):
     - `title` (string) → `Hertz – Oficina Centro (ABC123)`
     - `location` (string) → `Calle Ejemplo 1, Madrid`
     - `event_type` (string) → `rental`

16. Pulsa **"Save"** / **"Guardar"**.

---

### Si "Save" no se activa o no te deja guardar

- **Revisa si sale algún mensaje en rojo** debajo de algún campo (por ejemplo "Required" o "Invalid"). Esos campos hay que corregirlos.
- **Timestamps:** asegúrate de haber dado valor a `createdAt` y `updatedAt`. En la consola suele haber un **icono de reloj** o un desplegable; elige **"Now"** / **"Ahora"** para usar la fecha y hora actual. Si lo dejas vacío, a veces Save se queda deshabilitado.
- **Prueba con solo 4 campos** (mínimo para que la app lo muestre):
  1. `subject` (string) → `Confirmación prueba`
  2. `bodyPlain` (string) → `Cuerpo`
  3. `status` (string) → `pending`
  4. `createdAt` (timestamp) → Now  
  Guarda. Luego puedes **editar** el documento y añadir `updatedAt`, `fromEmail`, etc.
- Si usas **español**: el botón puede llamarse **"Guardar"** o estar abajo; a veces hay que hacer **scroll** para verlo.
- **Navegador:** prueba en otra pestaña o en modo incógnito por si hay alguna extensión bloqueando.

## 1.1 Editar el documento si la mayoría de campos están vacíos

Si ya guardaste con pocos campos, puedes **editar** el documento:

1. En Firestore: **users** → tu usuario → subcolección **pending_email_events** → haz clic en el documento.
2. Pulsa **"Add field"** / **"Añadir campo"** (o el lápiz si el campo existe y está vacío) y rellena al menos:

| Campo       | Tipo      | Valor |
|------------|-----------|--------|
| `subject`  | string    | Ej. `Confirmación Hertz - Recogida` (es lo que se verá como título si no hay `parsed`) |
| `status`   | string    | **`pending`** (obligatorio: solo se listan los que tienen exactamente este valor) |
| `bodyPlain`| string    | Cualquier texto (ej. `Cuerpo del correo`) |
| `fromEmail`| string    | Tu email (opcional) |
| `updatedAt`| timestamp | Now (si no lo tenías) |

3. **(Opcional)** Para que en la app se vea un **título y ubicación** más claros, añade un campo **`parsed`** (tipo **map**) y dentro del map:
   - `title` (string) → ej. `Hertz – Oficina Centro (ABC123)`
   - `location` (string) → ej. `Calle Ejemplo 1, Madrid`

4. Guarda. En la app (pestaña **Buzón**) debería aparecer el evento; si no, comprueba que **`status`** es exactamente **`pending`** (minúsculas).

---

## 2. Probar en la app

1. Inicia la app y **inicia sesión** con el mismo usuario cuyo `userId` usaste en Firestore.
2. Selecciona un **plan** (necesitas al menos uno para poder asignar).
3. Abre la pestaña **"Buzón"** en el dashboard (icono de correo).
4. Deberías ver el evento pendiente de prueba:
   - Con **título** (el de `parsed.title` si existe, si no el `subject`).
   - Si añadiste `parsed`, la **ubicación** debajo.
   - Si no hay `parsed`, la etiqueta **"Sin parsear"**.
5. **Asignar a plan:** pulsa "Asignar a plan", elige un plan en el modal y confirma. Debe crearse un evento en ese plan (revisa la pestaña Calendario) y el pendiente debe desaparecer del listado (pasa a `assigned`).
6. **Descartar:** crea otro documento de prueba si quieres y prueba "Descartar"; debe pedir confirmación y luego el item debe desaparecer (status `discarded`).

## 3. Si ves "Missing or insufficient permissions"

**Despliega las reglas de Firestore.** La regla para `pending_email_events` está en el archivo pero debe estar desplegada en Firebase:

```bash
firebase deploy --only firestore:rules
```

(o `npx firebase-tools deploy --only firestore:rules`)

Sin este despliegue, Firebase usa reglas antiguas y deniega el acceso a la subcolección. Ver `docs/configuracion/DESPLEGAR_REGLAS_FIRESTORE.md`.

---

## 4. Lista de comprobación si no ves el evento

Hazlo **en este orden**:

1. **Abre el Buzón en la app** y anota el **Auth UID** que aparece arriba (ej. `xYz123Abc...`).
2. **En Firestore:** Ve a **users** → busca el documento cuyo **ID** es exactamente ese Auth UID (cópialo y pega en la búsqueda si hace falta). **Abre ese documento** (clic en la fila).
3. Dentro de ese documento, en **Subcollections**, debe existir **pending_email_events**. Si no existe, créala (Start collection → ID: `pending_email_events`) y añade un documento con los campos indicados arriba.
4. Si **sí** existe: entra en **pending_email_events** y comprueba que hay al menos un documento con:
   - **status** = `pending` (minúsculas, sin espacios).
   - **createdAt** = timestamp (tipo "timestamp", con fecha).
5. **Vuelve a la app**, cierra el Buzón y ábrelo de nuevo (o recarga la página). Mira el texto de depuración: **"Documentos en users/...: X. Con status pending: Y."**
   - **X = 0:** La ruta está vacía o el documento no tiene `createdAt`. Crea el documento bajo users/[Auth UID]/pending_email_events con createdAt.
   - **X ≥ 1 pero Y = 0:** Hay documentos pero ninguno tiene status "pending". Edita el documento y pon el campo **status** = `pending` (string, minúsculas).
   - **Y ≥ 1:** Deberías ver la lista; si no, puede ser un fallo de la interfaz (dímelo).

## 5. Siguiente: correo real

Cuando el flujo de correo esté configurado (buzón Gmail/Workspace + `processInboundGmail` o webhook a `inboundEmail`), los documentos en `pending_email_events` se crearán solos al reenviar correos a la dirección de la plataforma. Este documento sirve solo para probar la **app** sin depender de eso.
