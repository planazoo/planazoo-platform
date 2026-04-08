# 📝 Flujo de Notas del Plan (T262)

> Define el flujo funcional de notas comunes/personales y lista de preparación del plan.

**Relacionado con:** T262 (en progreso), `lib/features/plan_notes/`, `FLUJO_CRUD_PLANES.md`  
**Versión:** 1.0  
**Fecha:** Abril 2026 (basado en implementación actual)

---

## 🎯 Objetivo

Documentar el comportamiento real de la funcionalidad **Notas** en el detalle del plan:

- notas comunes del plan,
- notas personales por usuario,
- lista de preparación (checklist) común y personal,
- política de edición para la lista común.

---

## 📍 Acceso en la app

- **Detalle del plan (`PlanDetailPage`)** -> pestaña **Notas** (`id: planNotes`).
- Pantalla renderizada: `PlanNotesScreen(plan, embedInPlanDetail: true)`.
- Disponible en navegación web+iOS dentro de la barra de tabs del plan.

---

## 🧱 Modelo de datos (Firestore)

### Documento común del plan

- Ruta: `plans/{planId}/plan_workspace/default`
- Modelo: `PlanWorkspaceData`
- Campos principales:
  - `commonNoteText: String`
  - `preparationItems: List<{id, text, done}>`
  - `preparationCommonEditPolicy: organizer_only | selected_participants | all_participants`
  - `preparationCommonEditorUserIds: String[]`
  - `planParticipantUserIds: String[]`
  - `updatedAt`

### Documento personal por usuario

- Ruta: `plans/{planId}/personal_plan_notes/{userId}`
- Modelo: `PersonalPlanNotesData`
- Campos principales:
  - `personalNoteText: String`
  - `preparationItems: List<{id, text, done}>`
  - `updatedAt`

### Ítem de preparación

- Modelo: `PlanPreparationItem`
- Campos:
  - `id` (UUID),
  - `text`,
  - `done` (checkbox).

---

## 🔐 Política de edición (lista común)

La lista común se gobierna por `PreparationCommonEditPolicy`:

1. `organizer_only`: solo organizador.
2. `selected_participants`: organizador + usuarios incluidos en `preparationCommonEditorUserIds`.
3. `all_participants`: cualquier participante aceptado del plan.

Comportamiento actual en UI/servicio:

- El organizador puede cambiar política y selección.
- Un participante con permiso puede guardar contenido común (`commonNoteText` + `preparationItems`) mediante `saveWorkspaceParticipantContent`.
- Si no tiene permiso: vista común en solo lectura (`planNotesReadOnlyHint`).

---

## 🔄 Flujo funcional

### 1) Carga inicial

1. Se abre pestaña Notas.
2. Se suscriben streams:
   - `planWorkspaceStreamProvider(planId)`
   - `personalPlanNotesStreamProvider(planId, userId)`
3. Si no existe `plan_workspace/default`:
   - organizador intenta inicializarlo con `ensureWorkspaceDocument`,
   - participantes ven mensaje de workspace no inicializado.

### 2) Edición de bloque común

1. Editar checklist común (add/toggle/delete) y/o nota común.
2. (Organizador) ajustar política de edición.
3. Guardar:
   - organizador -> `saveWorkspaceFull(...)`,
   - participante autorizado -> `saveWorkspaceParticipantContent(...)`.

### 3) Edición de bloque personal

1. Editar checklist personal y/o nota personal.
2. Guardar con `savePersonal(...)`.

### 4) UX de guardado

- Botones de guardar separados por tab (común/personal).
- Snackbars de `guardado correcto` / `error`.
- Estado local `dirty` para no pisar edición activa con snapshots remotos.

---

## ✅ Implementado actualmente

- Pestaña **Notas** integrada en detalle del plan.
- Estructura **Comunes / Personales** con `TabBar`.
- Lista de preparación en ambos tabs (checkbox + añadir + eliminar).
- Nota de texto común y nota personal.
- Políticas de edición común configurables por organizador.
- Persistencia Firestore y streams reactivos.
- Creación automática del workspace para planes sin documento común (best effort).
- Limpieza al borrar plan:
  - workspace común,
  - subcolección de notas personales.

---

## ⏳ Pendiente (fuera de este flujo base)

- Plantillas de notas (usuario/estándar) y diálogo sustituir/añadir.
- Checklist de pruebas específico en `TESTING_CHECKLIST.md` para T262.
- Cierre formal de T262 en `TASKS.md` tras validación funcional completa.

---

*Documento de flujo de notas del plan*  
*Última actualización: Abril 2026*
