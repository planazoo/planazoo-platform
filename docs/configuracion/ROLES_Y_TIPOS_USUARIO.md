# Roles y tipos de usuario — Planazoo

> Documento de referencia único: plataforma vs plan, mapeo a código, y límites de acceso (incl. protección de datos).

**Estado:** Acordado (producto) — Jul 2026  
**Relacionado:** [`ADMINS_WHITELIST.md`](../admin/ADMINS_WHITELIST.md), [`USUARIOS_PRUEBA.md`](./USUARIOS_PRUEBA.md), [`FLUJO_GESTION_PARTICIPANTES.md`](../flujos/FLUJO_GESTION_PARTICIPANTES.md), [`FLUJO_CRUD_USUARIOS.md`](../flujos/FLUJO_CRUD_USUARIOS.md), [`GUIA_ASPECTOS_LEGALES.md`](../guias/GUIA_ASPECTOS_LEGALES.md), [`ESTADO_USUARIO_EN_EL_PLAN.md`](../ux/ESTADO_USUARIO_EN_EL_PLAN.md), T252

---

## 1. Idea clave: dos capas

| Capa | Pregunta | Dónde vive |
|------|----------|------------|
| **Plataforma** | ¿Qué puede hacer en Planazoo como producto (config, usuarios, soporte)? | `users/{uid}` (+ flags / roles futuros) |
| **Plan** | ¿Qué puede hacer **en un viaje concreto**? | `plans.userId` + `plan_participations` |

Un mismo usuario puede ser `power_admin` en la plataforma y, a la vez, `participant` en el plan de un amigo. Son independientes.

---

## 2. Roles de plataforma (acordados)

### 2.1 `user` (usuario normal)

- Cuenta registrada (`UserModel`).
- Crea planes, acepta invitaciones, usa la app.
- **No** ve herramientas de administración global.
- **Código hoy:** cualquier usuario con `isAdmin != true` (o ausente).

### 2.2 `power_admin` (administrador de plataforma)

- Configuración de la app, gestión de usuarios, whitelist, herramientas técnicas (limpieza, auditoría de datos huérfanos, etc.).
- **No tiene, por defecto, acceso de navegación a los planes de otros usuarios** (ni listado “todos los viajes”, ni abrir el calendario ajeno “porque sí”).
- **Código hoy (legado):** flag booleano `users.isAdmin == true` + `isAdmin()` en `firestore.rules`. Es más amplio de lo deseado en producción; hay que **acotar** reglas/UI hacia este modelo.
- **Lista operativa:** [`docs/admin/ADMINS_WHITELIST.md`](../admin/ADMINS_WHITELIST.md).

### 2.3 Soporte / acceso excepcional (“break-glass”)

- No es un permiso cotidiano del `power_admin`.
- Sirve para: incidencia con ticket, seguridad/abuso, ejercicio de derechos (borrado/exportación RGPD), bug crítico.
- Requisitos de producto (objetivo):
  - Abrir **un** plan por ID / contexto de soporte (no catálogo global).
  - Motivo obligatorio + **log de auditoría** (quién, cuándo, qué plan, por qué).
  - Preferible **solo lectura** o ventana temporal; revocable.
  - Preferible impersonación / vista técnica frente a “editar el viaje del usuario” a diario.

Hasta que exista UI/reglas específicas, este acceso **no debe** implementarse como “`isAdmin` puede leer toda la colección `plans` en la app”.

---

## 3. Roles dentro de un plan

Nombres de producto (UI) vs almacenamiento.

| Producto (UI) | Código / datos | Notas |
|---------------|----------------|--------|
| **Dueño / anfitrión** | `plans.userId` + participación `role: organizer` (ideal) | Creador del plan. Máximo control. Firestore trata owner de forma especial (`isPlanOwner`). |
| **Organizador / coorganizador** | `plan_participations.role = organizer` | En docs antiguos: “coorganizador”. En UI suele mostrarse como organizador. **Atención:** muchas reglas Firestore siguen limitando escrituras sensibles al **owner**, no a todo `organizer`. |
| **Participante** | `role: participant` | Miembro activo; edita su parte personal; puede proponer eventos (borrador) según T252. |
| **Observador** | `role: observer` | Solo lectura del plan. |
| **Invitado (pendiente)** | `status: pending` (participación o `plan_invitations`) | Aún no ha aceptado; no es miembro pleno. |

### Estados de participación (no son “tipos de usuario”)

En `plan_participations.status` / invitaciones: `pending` | `accepted` | `rejected` | `expired`.  
Detalle UX: [`ESTADO_USUARIO_EN_EL_PLAN.md`](../ux/ESTADO_USUARIO_EN_EL_PLAN.md).

### Enum de permisos en código (`UserRole`)

`lib/shared/models/user_role.dart`:

| `UserRole` | Uso típico |
|------------|------------|
| `admin` | Permisos amplios **en el plan** (no confundir con `power_admin` de plataforma) |
| `participant` | Participante |
| `observer` | Observador |

**Importante:** `UserRole.admin` ≠ `users.isAdmin` / `power_admin`. Uno es rol de plan; el otro es privilegio de plataforma.

### Modos de producto (no son roles de BD)

T252 — “planificador” vs “viajero”: formas de usar la app (calendario vs “Mi resumen”), no campos en Firestore.

---

## 4. Matriz resumida de acceso

### Plataforma

| Acción | `user` | `power_admin` | Soporte break-glass |
|--------|---------|---------------|---------------------|
| Usar la app / sus planes | ✅ | ✅ (como usuario) | — |
| Panel config global / usuarios | ❌ | ✅ | Según diseño |
| Listar todos los planes de todos | ❌ | ❌ (objetivo) | ❌ |
| Abrir un plan ajeno por incidencia | ❌ | ❌ por defecto | ✅ con motivo + auditoría |

### Dentro de un plan (orientativo)

| Acción | Dueño | Organizador* | Participante | Observador | Pendiente |
|--------|-------|--------------|--------------|------------|-----------|
| Ver plan / calendario | ✅ | ✅ | ✅ | ✅ | Limitado |
| Editar info del plan | ✅ | Según reglas/UI | ❌ / limitado | ❌ | ❌ |
| Invitar / quitar gente | ✅ (reglas: owner) | UI puede mostrar; Firestore a menudo solo owner | ❌ | ❌ | ❌ |
| Crear/editar eventos (común) | ✅ | ✅ / según permisos | Propuesta / personal | ❌ | ❌ |
| Salir del plan | N/A (borrar o transferir) | ✅ | ✅ | ✅ | — |
| Borrar el plan | ✅ | ❌ (doc) | ❌ | ❌ | ❌ |

\*Coorganizador/`organizer` no-owner: alinear UI y `firestore.rules` en una tarea futura; hoy hay **desfase** documentado.

### Owner sin `plan_participations`

El dueño (`plans.userId`) **sigue siendo participante** a efectos de producto aunque falte el documento de participación (planes legacy). El cliente debe tratarlo como tal (`isUserParticipant` con fallback a owner). Conviene sanear datos creando la participación `organizer` cuando se detecte el hueco.

---

## 5. Protección de datos (orientación de producto)

No es asesoramiento legal; alinea producto con [`GUIA_ASPECTOS_LEGALES.md`](../guias/GUIA_ASPECTOS_LEGALES.md).

1. Los planes contienen **datos personales** (y a menudo de terceros invitados).
2. Acceso de personal autorizado solo con **finalidad** clara (soporte, seguridad, cumplimiento), **minimización** y, en lo posible, **auditoría**.
3. Declarar en política de privacidad el acceso excepcional de personal autorizado.
4. Evitar que `power_admin` = “puedo abrir cualquier viaje desde la app”.

---

## 6. Estado de implementación vs objetivo

| Concepto | Objetivo (este doc) | Código / reglas hoy |
|----------|---------------------|---------------------|
| `user` | Rol base | Implícito |
| `power_admin` | Admin plataforma sin browse de planes | `users.isAdmin` + reglas muy amplias |
| Break-glass | Acceso puntual auditado | No modelado como flujo de producto |
| Directorio usuarios (W1) | Solo `power_admin` | **Temporal:** visible a todos los autenticados; `allow list` users abierto. Lookups `username_lookup` / `email_lookup` listos para cuando se restrinja. |
| Dueño del plan | `plans.userId` | ✅ |
| organizer / participant / observer | En `plan_participations` | ✅ strings; UI l10n |
| Coorganizador con mismos writes que owner | Dec parcial | ⚠️ A menudo solo owner en rules |
| Invitado pending | status / invitations | ✅ |

**Tareas futuras sugeridas (no bloquean este doc):**

1. Renombrar/documentar en código `isAdmin` → semántica `power_admin`.
2. Acotar `firestore.rules` para que admin de plataforma no implique lectura libre de todos los planes en cliente.
3. Flujo break-glass + colección `admin_access_logs`.
4. Alinear coorganizador (UI + rules) o dejar explícito que solo el dueño invita/elimina.

---

## 7. Glosario rápido

| Término | Significado |
|---------|-------------|
| **Owner / dueño** | `plans.userId` |
| **Organizer** | Rol en participación; puede ser el dueño u otro |
| **power_admin** | Admin de la plataforma Planazoo |
| **isAdmin (legado)** | Flag actual ≈ power_admin, demasiado permisivo |
| **UserRole.admin** | Permiso amplio **en un plan**, no plataforma |
| **Break-glass** | Acceso excepcional justificado a un plan |

---

## 8. Referencias de prueba

Emails y cuentas de testing por rol: [`USUARIOS_PRUEBA.md`](./USUARIOS_PRUEBA.md).  
E2E tres usuarios (UA organizador, UB/UC participantes): [`PLAN_PRUEBAS_E2E_TRES_USUARIOS.md`](../testing/PLAN_PRUEBAS_E2E_TRES_USUARIOS.md).
