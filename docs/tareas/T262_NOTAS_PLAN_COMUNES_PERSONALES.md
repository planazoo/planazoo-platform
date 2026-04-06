# T262 — Notas del plan (comunes y personales)

**Estado:** Pendiente (prioridad **Alta**); **implementación parcial en código** (marzo 2026). La tarea sigue en `TASKS.md` hasta cierre con tu aprobación.  
**Lista maestra:** `docs/tareas/TASKS.md`.

**Hecho (fase 1):** Pestaña **Notas** al mismo nivel que Info / Mi resumen / Calendario… en móvil (`PlanNavigationBar`) y web (`WdDashboardNavTabs` W21). Pantalla `lib/features/plan_notes/` (`PlanNotesService`, `PlanNotesScreen`): notas comunes y personales, lista **Preparación** con checkbox, política de edición de la lista común (organizador / seleccionados / todos). Firestore: `plans/{planId}/plan_workspace/default`, `plans/{planId}/personal_plan_notes/{userId}`; al crear plan se inicializa workspace; al borrar plan se limpian esas subcolecciones. Reglas en `firestore.rules`; subcolección `users/{uid}/note_templates/{templateId}` con reglas (UI plantillas pendiente). i18n: claves `planNotes*` en ARB. Despliegue: `npx firebase deploy --only firestore:rules`.

**Pendiente respecto a este documento:** Plantillas de usuario y estándar, diálogo sustituir/añadir al aplicar plantilla, posible sync automática de `planParticipantUserIds` al unirse gente (hoy se actualiza al guardar el organizador), entradas en `TESTING_CHECKLIST.md`.

## Objetivo

Añadir un **apartado de navegación nuevo** al mismo nivel que **Info del plan**, **Resumen**, **Calendario**, **Participantes**, **Chat**, **Pagos**, etc.: **Notas del plan**, con dos tipos de contenido:

1. **Notas comunes del plan** — visibles para quien tenga acceso al plan (definir en implementación: todos los participantes vs solo organizador que edita; propuesta inicial: lectura para participantes, edición restringida al organizador o según permisos del plan).
2. **Notas personales** — por usuario y por plan; solo el autor las ve y edita (equivalente a “mi libreta” dentro del contexto del viaje).

3. **Plantillas de notas** — complemento a lo anterior:
   - **Plantillas del usuario:** desde el texto actual de una nota (común o personal del plan), el usuario puede **guardar como plantilla** (nombre opcional, contenido = copia del texto en ese momento). Las plantillas son **suyas** (no se comparten con otros usuarios salvo futura ampliación explícita).
   - **Importar plantilla:** al elegir una plantilla propia (p. ej. en plan nuevo o desde Notas), si el campo de destino (común o personal) **ya tiene texto**, **preguntar al usuario** si desea **sustituir** todo el contenido o **añadir la plantilla a continuación** (concatenar al final; definir separador si hace falta, p. ej. doble salto de línea). Si el destino está **vacío**, aplicar el texto **sin** mostrar ese paso.
   - **Plantillas estándar (curadas):** el producto incluye un **conjunto fijo** de plantillas predefinidas (contenido en **l10n** o recurso versionado con la app, por idioma). Tras elegir destino (notas comunes o personales), al aplicar se usa el **mismo criterio** que al importar: diálogo **sustituir** vs **añadir a continuación** solo si hay contenido previo en ese destino.

4. **Lista de preparación (mini-tareas / checklist)** — ver **propuesta** en la sección siguiente; objetivo: cosas sencillas a preparar para el plan, marcar hechas con un gesto claro, sin convertirse en un gestor de tareas completo.

## Propuesta: lista de preparación (mini-tareas)

### Enfoque de producto

- **Qué es:** una **lista de ítems con checkbox** (texto corto, una línea por ítem), pensada para “qué hay que preparar” (documentación, reservas, maleta, compras grupales, etc.), no para deadlines, asignaciones ni subtareas anidadas.
- **Qué no es (v1):** fechas límite, responsables, prioridades, comentarios por ítem, adjuntos, notificaciones. Si hiciera falta más adelante, valorar una tarea aparte o enlazar con otro módulo.
- **Dónde vive:** **alineada con Notas** — misma pantalla o subsección clara:
  - **Lista común del plan:** visible para los participantes del plan con acceso a la pestaña Notas/Preparación; sirve para preparativos compartidos (“reservar restaurante”, “alquilar coche”). **Quién puede modificarla** la define el **organizador** (ver siguiente apartado).
  - **Lista personal:** por usuario y plan (como las notas personales); solo el autor (“pasaporte”, “cargador”).
- **Título en UI (l10n):** de momento **«Preparación»** como etiqueta principal del bloque (lista + contexto); evitar confusión con el sistema de tareas internas del proyecto (`TASKS.md`).

### Permisos de edición — lista común de preparación

Configuración **solo el organizador del plan** (o rol equivalente ya existente en el modelo de permisos del plan). Tres modos:

1. **Solo el organizador** puede **crear** ítems en la lista común; el resto **solo lectura**.
2. **Algunos usuarios:** el organizador elige participantes que pueden **crear** (y el resto de operaciones sobre ítems; ver siguiente párrafo).
3. **Todos los participantes** del plan pueden **crear** ítems en la lista común.

**Reglas CRUD unificadas (mismas que crear):** la **lectura** de la lista común sigue el **acceso al plan** (quien ve el plan / la pestaña Notas la ve). Las **mutaciones** —**crear** ítem, **actualizar** texto o `done`, **borrar** ítem— comparten **exactamente la misma** condición de permiso que la de **crear** (no reglas más laxas o estrictas por operación). En **Firestore** y **cliente**: una sola comprobación de “puede mutar la lista común”. Quien no la cumple: **solo lectura**.

**UI:** ajuste en Info del plan, ajustes del plan, o menú contextual del bloque Preparación — donde encaje mejor con el resto de permisos; debe ser **fácil de encontrar** para el organizador y **legible** para el resto (“Solo tú puedes editar”, “Editan: Ana, Luis”, “Todos pueden editar”).  
**Datos:** persistir en el plan (o documento de notas común) campos p. ej. `preparationCommonEditPolicy` (`organizer_only` | `selected_participants` | `all_participants`) y, si aplica, `preparationCommonEditorUserIds: string[]` (uids de participantes autorizados). Las **reglas Firestore** y la **UI** deben coincidir: validar en cliente y denegar en servidor si el usuario no está en el conjunto permitido para **cualquier** escritura sobre la lista común.

### UX (sencillo)

- Cada fila: **checkbox o interruptor visual** a la izquierda + **texto** editable al toque o con icono lápiz; **marcar hecho** en un toque sobre el checkbox.
- Ítems **hechos:** texto tachado y/o color atenuado; opcional **plegar** o enlace “Mostrar completadas” para no llenar la pantalla.
- **Añadir:** campo “Añadir ítem…” al final o botón `+`; Enter / botón confirma nueva línea.
- **Eliminar:** deslizar a la izquierda (móvil) o icono papelera por fila (web); confirmación solo si se desea evitar borrados accidentales (producto puede decidir sin confirmación en v1).
- **Reordenar:** **fase 2 opcional** (arrastrar filas); v1 puede ser orden fijo por `createdAt` o `order` incremental.
- **Plantillas:** una plantilla estándar (o sección de plantilla) podría **rellenar la lista** con varios ítems de golpe (misma lógica sustituir/añadir que el texto de notas, adaptada a lista: sustituir toda la lista vs añadir ítems al final).

### Datos (recomendación)

- Guardar en el **mismo documento** que el bloque de notas correspondiente (común o personal), p. ej. campo `preparationItems`: arreglo de objetos `{ id, text, done, order?, updatedAt? }` con `id` estable (UUID) para toggles y ediciones sin reescribir todo el array a ciegas.
- **Concurrencia:** si dos personas editan la lista común, usar actualizaciones atómicas donde sea posible o documentar “último escritor gana” en ítems conflictivos; para v1 suele bastar con merge por `id`.
- **Reglas Firestore:** documento **personal** = solo `userId` (CRUD completo de su documento). Documento **común** = lectura según acceso al plan; **toda escritura** que afecte a la lista común (`preparationItems` y, si aplica, campos de política solo modificables por organizador) usa **la misma función de permiso** que para **crear** un ítem: no separar `update`/`delete` de `create` en reglas distintas.

### Criterios de aceptación añadidos (checklist)

- [ ] Lista común y lista personal (o bloques en la misma vista) con ítems **añadir / editar / marcar hecho / borrar**.
- [ ] **Organizador:** configurar quién puede mutar la lista común — solo yo / participantes elegidos / todos; persistido; **Firestore:** misma condición para create/update/delete de ítems.
- [ ] Participantes sin permiso de mutación: **solo lectura** en lista común (sin controles de edición o deshabilitados).
- [ ] Persistencia y reglas alineadas con notas comunes/personales.
- [ ] Accesible y usable en **web e iOS** (tamaño táctil del checkbox).
- [ ] Cadenas en `AppLocalizations`.

## Alcance UX

- Nueva **pestaña / entrada en la barra inferior o rail** del detalle del plan (paridad **web e iOS**).
- Pantalla dedicada (no un subapartado dentro de Info): título claro, secciones o pestañas internas “Comunes” / “Personales” según diseño (una sola vista con dos bloques también es válido). Dentro de cada bloque, orden sugerido: **lista de preparación (mini-tareas)** arriba o justo debajo del título, **nota libre** debajo (o pestañas “Preparación” / “Notas” si se prefiere separar).
- Texto largo admisible (límites y sanitizado alineados con otros campos de notas del proyecto).
- **Multi-idioma:** todas las cadenas vía `AppLocalizations` (incluidas las plantillas estándar).
- **Plantillas:** flujos explícitos en UI: guardar plantilla desde nota, listado/gestión de plantillas propias (mínimo: elegir al importar; opcional: renombrar/eliminar), galería o lista de plantillas estándar con destino común/personal. Al volcar texto de una plantilla sobre una nota que **ya tenga contenido**, **preguntar**: **sustituir** las notas actuales del destino o **añadir a continuación** (textos localizados claros). Si el destino está **vacío**, se puede aplicar directamente sin diálogo (sustituir y añadir serían equivalentes).

## Datos (borrador para implementación)

- **Comunes:** campo o subdocumento en el **plan** (p. ej. `planNotes` / `commonNotes`) o colección `plan_notes` con `planId` y tipo `common` — decidir en fase técnica (evitar duplicar `referenceNotes` de Info si ya cubre un caso distinto: aquí el foco es “libreta compartida” vs notas de referencia del formulario Info). Incluir **`preparationItems`** (o equivalente) en el mismo agregado que el texto común si el modelo es un solo documento.
- **Personales:** documento por par `(planId, userId)` en Firestore (p. ej. `plan_personal_notes/{planId}_{userId}` o subcolección bajo `plans/{id}/personalNotes/{userId}`), con reglas que solo permitan leer/escribir al propio `userId`. Mismo campo de **ítems de preparación** en el documento personal.
- **Plantillas de usuario:** subcolección bajo el usuario (p. ej. `users/{uid}/note_templates/{templateId}`) con campos `title`, `body`, `updatedAt`; solo el propio `uid` puede leer/escribir. Las plantillas estándar **no** van a Firestore: viven en código/recursos + traducciones.

## Criterios de aceptación (inicial)

- [ ] Nueva opción de navegación visible en detalle de plan (web + iOS).
- [ ] Notas comunes persistidas y recargadas; permisos coherentes con el modelo del plan.
- [ ] Notas personales persistidas por usuario; ningún otro participante puede verlas.
- [ ] Reglas Firestore y, si aplica, índices documentados / desplegados.
- [ ] **Plantillas usuario:** guardar texto actual como plantilla; listar/importar; al importar, **diálogo sustituir vs añadir a continuación**; CRUD mínimo coherente con el diseño elegido.
- [ ] **Plantillas estándar:** conjunto inicial acordado (producto), localizado; al aplicar, **mismo diálogo sustituir vs añadir a continuación** según destino (común o personal).
- [ ] **Lista de preparación (mini-tareas):** común + personal; CRUD ítems; marcar hecho en un toque; ver criterios en sección «Propuesta: lista de preparación».
- [ ] Entradas en `TESTING_CHECKLIST` para regresión básica.

## Referencias

- `docs/flujos/FLUJO_CRUD_PLANES.md`, `FLUJO_CONFIGURACION_APP.md`
- `docs/configuracion/CONTEXT.md` (consistencia web/iOS, l10n)
- Info del plan y campo `referenceNotes` (no confundir propósito; T262 es apartado propio de producto)
