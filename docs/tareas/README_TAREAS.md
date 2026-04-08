# 📋 Sistema de tareas – Planazoo

Este documento describe la organización de las tareas del proyecto y la relación con los archivos en `docs/tareas/`.

---

## 1. Archivos principales

| Archivo | Uso |
|--------|-----|
| **TASKS.md** | Lista única de tareas **pendientes**. Códigos T1, T2, … no reutilizados. Siguiente código: ver cabecera del archivo. |
| **COMPLETED_TASKS.md** | Tareas **completadas** (movidas aquí desde TASKS.md). Histórico y detalle de implementación. |

**Reglas:** Ver sección «Reglas del Sistema de Tareas» en `TASKS.md`. Completadas → mover a `COMPLETED_TASKS.md` con aprobación del usuario.

**Carpeta `archivo/`:** Documentos de especificación de tareas **ya completadas**. Al cerrar una tarea, su `Txxx_*.md` se mueve aquí (ver reglas en `TASKS.md`).

---

## 2. Documentos de especificación por tarea (pendientes / en curso)

Algunas tareas tienen un `.md` propio con especificación, plan de fases o criterios. Relación con `TASKS.md`:

| Código | Archivo | Nota |
|--------|---------|------|
| T96 | `T96_REFACTORING_PLAN.md` | Plan de refactor CalendarScreen; T96 pendiente. |
| T225 | `T225_GOOGLE_PLACES_PLAN.md` | Plan de fases Google Places; T225 en progreso. |
| T246 | `T246_DESPLAZAMIENTO_POR_NUMERO_VUELO_TREN.md` | Plan y APIs vuelo/tren. |
| T247 | `T247_EVENTOS_CONECTADOS.md` | Eventos conectados a proveedores; testing y docs. |
| T252 | `T252_PARTICIPANTES_USUARIOS_VS_PLANIFICADORES.md` | Especificación participantes vs planificadores. |
| T253 | `T253_CHAT_FECHA_MENSAJES.md` | Opciones fecha mensajes chat. |
| T254 | `T254_PANTALLA_BIENVENIDA_PLANAZOO.md` | Especificación pantalla bienvenida. |
| T256 | `T256_IMPLEMENTAR_FASTLANE.md` | Plan implementación Fastlane (eval. T255 en `archivo/`). |
| T257 | `T257_REVISION_WEB_VS_IOS.md` | Checklist revisión web vs iOS; hallazgos en `REVISION_IOS_VS_WEB.md`. |
| T258 | `T258_ICONO_APP.md` | Detalle icono app iOS/Android. |
| T259 | `T259_DEEP_LINK_INVITACION_IOS.md` | Deep link invitación iOS. |
| T260 | `CURRENCY_SYSTEM_PROPOSAL.md` | Especificación sistema multi-moneda (T260). |
| T262 | `T262_NOTAS_PLAN_COMUNES_PERSONALES.md` | Notas, plantillas, lista preparación (mini-tareas con checkbox). |

En `TASKS.md`, las filas de estas tareas **deben** indicar que existe el documento (ej. «Especificación en `docs/tareas/Txxx_*.md`»).

**Auditoría (Abr 2026):** los `T*.md` presentes en `docs/tareas/` están en uso (pendientes/en curso y referenciados en `TASKS.md` o en documentación activa), por lo que **no se eliminan ni se archivan** en esta revisión.

---

## 3. Archivo (especificaciones de tareas completadas)

Los documentos de especificación de tareas **completadas** se mueven a `docs/tareas/archivo/` al cerrar la tarea. Se mantiene el nombre del archivo para trazabilidad. Ver reglas en `TASKS.md` § Documentos de especificación / plan.

**Actualmente en archivo:** `T255_EVALUACION_FASTLANE.md` (T255 completada).

---

## 4. Otros documentos en docs/tareas

`CURRENCY_SYSTEM_PROPOSAL.md` es la especificación de la tarea **T260** (sistema multi-moneda). El resto son `TASKS.md`, `COMPLETED_TASKS.md`, `README_TAREAS.md` y los `Txxx_*.md` de tareas pendientes o en curso.

---

## 5. Dónde buscar

- **¿Qué hay que hacer?** → `TASKS.md` (pendientes) y resumen por área en la cabecera.
- **¿Cómo se hizo una tarea completada?** → `COMPLETED_TASKS.md` (buscar por Txxx).
- **¿Spec de una tarea pendiente/en curso?** → `docs/tareas/Txxx_*.md` o el enlace en la fila de `TASKS.md`.
- **¿Spec de una tarea ya completada?** → `docs/tareas/archivo/` (mismo nombre de archivo).
- **Normas de trabajo** → `docs/configuracion/CONTEXT.md`.

---

## 6. Mantenimiento (flujo)

- **Crear tarea (con o sin spec):** Añadir fila en `TASKS.md`. Si se crea documento de especificación/plan, **documentar en la fila** que existe (enlace al archivo) y opcionalmente añadir línea en la tabla de la sección 2.
- **Durante la tarea:** Actualizar el documento de especificación cuando cambien criterios, fases o decisiones.
- **Completar tarea:** (1) Mover la entrada a `COMPLETED_TASKS.md` (una sola por Txxx). (2) Si la tarea tenía documento de especificación en `docs/tareas/`, **moverlo a `docs/tareas/archivo/`** (mismo nombre de archivo).
- Los **códigos T** no se reutilizan al eliminar o completar tareas.
