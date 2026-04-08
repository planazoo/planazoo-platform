# Auditoría de documentación (docs/)

> Revisión de archivos .md: mantener, actualizar, eliminar y referencias cruzadas.  
> **Fecha:** Febrero 2026

---

## 1. Resumen

- **Total de .md en docs/:** 76 archivos
- **Referencias rotas detectadas:** varias (rutas incorrectas o documentos/carpetas que no existen)
- **Índice oficial:** `docs/README.md` — no incluye todas las carpetas ni todos los config

---

## 2. Estructura actual (lo que SÍ existe)

| Carpeta | Archivos | En índice README |
|---------|----------|------------------|
| **configuracion/** | CONTEXT.md, INDICE_SISTEMA_PLANES.md, DEPLOY_WEB_*, TESTING_CHECKLIST.md, FCM_FASE1_IMPLEMENTACION.md, DESPLEGAR_*, ONBOARDING_IA.md, USUARIOS_PRUEBA.md, MIGRACION_MAC_*, SETUP_IOS_SIMULATOR.md, EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md, REVISION_IOS_VS_WEB.md, DOCS_AUDIT.md, NOMENCLATURA_UI.md, CONFIGURAR_GOOGLE_*, etc. | En docs/README.md (Configuración) |
| **admin/** | ADMINS_WHITELIST.md | No |
| **arquitectura/** | ARCHITECTURE_DECISIONS.md, PLATFORM_STRATEGY.md | Sí (solo ARCHITECTURE_DECISIONS) |
| **guias/** | GUIA_UI.md, GUIA_SEGURIDAD.md, GUIA_ASPECTOS_LEGALES.md, GUIA_PATRON_COMUN_PERSONAL.md, GESTION_TIMEZONES.md, PROMPT_BASE.md | Sí |
| **flujos/** | FLUJO_CRUD_*.md, FLUJO_ESTADOS_PLAN.md, FLUJO_GESTION_PARTICIPANTES.md, FLUJO_INVITACIONES_NOTIFICACIONES.md, FLUJO_PRESUPUESTO_PAGOS.md, FLUJO_VALIDACION.md, FLUJO_CONFIGURACION_APP.md | Sí |
| **especificaciones/** | CALENDAR_CAPABILITIES.md, PLAN_FORM_FIELDS.md, EVENT_FORM_FIELDS.md, ACCOMMODATION_FORM_FIELDS.md, FRANKENSTEIN_PLAN_SPEC.md, PATROCINIOS_Y_MONETIZACION.md | Sí |
| **tareas/** | TASKS.md, COMPLETED_TASKS.md, README_TAREAS.md (índice de Txxx_*.md), CURRENCY_SYSTEM_PROPOSAL.md, T96/T225/T246/T247/T252–T259_*.md | Sí (TASKS y COMPLETED_TASKS) |
| **ux/** | plan_image_management.md, estilos/ESTILO_SOFISTICADO.md, pages/*.md (index, w1–w30, login, profile, register) | Parcial (solo plan_image y “Documentación de Widgets”) |
| **design/** | EVENT_COLOR_PALETTE.md | No |
| **testing/** | TESTING_OFFLINE_FIRST.md | No |

---

## 3. Referencias rotas (documentos o rutas que NO existen)

### 3.1 Rutas incorrectas (falta subcarpeta)

- **`docs/CONTEXT.md`** → Correcto: **`docs/configuracion/CONTEXT.md`**  
  Aparece en: TASKS.md (línea 3), PROMPT_BASE.md (línea 6).
- **`docs/COMPLETED_TASKS.md`** → Correcto: **`docs/tareas/COMPLETED_TASKS.md`**  
  Aparece en: TASKS.md (línea 52).

### 3.2 Documentos referenciados pero no creados

**En TASKS.md (y a veces en otros):**

- `docs/TESTING_PLAN.md`
- `docs/API_DOCUMENTATION.md`
- `docs/CONTRIBUTING.md`
- `docs/SERVICE_EXAMPLES.md`
- `docs/flujos/FLUJO_SEGURIDAD.md` (varias tareas)
- `docs/estrategia/` (carpeta no existe): DIFERENCIACION_COMPETITIVA.md, INTEGRACIONES_PROVEEDORES.md, BARRERAS_ENTRADA.md
- `docs/riesgos/` (carpeta no existe): ANALISIS_RIESGOS.md, PLAN_RESPUESTA_INCIDENTES.md, MONITOREO_ALERTAS.md, BACKUP_RECOVERY.md
- `docs/roadmap/` (carpeta no existe): MVP_DEFINITION.md, ROADMAP_v1.0.md, ROADMAP_v1.1.md, ROADMAP_v2.0.md
- `docs/flujos/FLUJO_GESTION_AGENCIAS.md`
- `docs/flujos/FLUJO_CRUD_TEMPLATES_PLANES.md`
- `docs/flujos/FLUJO_IMPORTACION_DESDE_EMAIL.md`
- `docs/guias/GUIA_MODELO_NEGOCIO_AGENCIAS.md`
- `docs/legal/` (carpeta no existe): terms_of_service.md, privacy_policy.md, security_policy.md, cookie_policy.md
- `docs/configuracion/INDICES_ANALISIS_COMPARACION.md`
- `docs/configuracion/INDICES_OBSOLETOS_VERIFICACION.md`
- `docs/configuracion/ESTRATEGIA_INDICES_ELIMINAR_TODOS.md`
- `docs/configuracion/USUARIOS_ADMINISTRACION.md`

**En GUIA_ASPECTOS_LEGALES.md:**  
Ubicaciones previstas para documentos legales: `docs/legal/terms_of_service.md`, etc. (carpeta y archivos no existen aún).

---

## 4. Recomendaciones

### 4.1 Mantener y solo corregir referencias

- **docs/README.md** – Mantener. Es el índice principal. Opción: añadir enlaces a Configuración (TESTING_CHECKLIST, FCM, ONBOARDING_IA, USUARIOS_PRUEBA), admin/, design/, testing/ si quieres que todo esté descubrible desde el índice.
- **CONTEXT.md, TASKS.md, COMPLETED_TASKS.md, ARCHITECTURE_DECISIONS.md, guías, flujos, especificaciones** – Mantener. Son el núcleo del proyecto.
- **configuracion/** – Mantener todos los que uses (deploy, Firestore, emails, testing, usuarios, migración Mac, etc.). Eliminar solo los que estén obsoletos o duplicados (revisión manual por nombre).

### 4.2 Actualizar (correcciones mínimas)

- **TASKS.md:** Sustituir `docs/CONTEXT.md` por `docs/configuracion/CONTEXT.md` y `docs/COMPLETED_TASKS.md` por `docs/tareas/COMPLETED_TASKS.md`.
- **PROMPT_BASE.md:** Sustituir `docs/CONTEXT.md` por `docs/configuracion/CONTEXT.md`.
- Para el resto de referencias a documentos no existentes en TASKS.md: o bien **crear el documento** (cuando corresponda), o **dejar una nota** en la tarea del estilo “Documento pendiente: docs/legal/…”, o **quitar la referencia** si la tarea está cancelada/obsoleta.

### 4.3 Referencias a “documentos futuros”

- **docs/legal/**, **docs/estrategia/**, **docs/riesgos/**, **docs/roadmap/** – Son referencias a trabajo futuro. Opciones:
  - **Opción A:** Dejar las referencias y crear las carpetas/archivos cuando toque (por ejemplo al hacer T171 documentos legales).
  - **Opción B:** En TASKS.md, cambiar el texto a “(pendiente: crear docs/legal/…)” para que quede claro que el doc aún no existe.
- **FLUJO_SEGURIDAD.md** – No existe. Si tenéis contenido de seguridad en GUIA_SEGURIDAD.md, se puede añadir en TASKS.md una referencia a `docs/guias/GUIA_SEGURIDAD.md` en lugar de un flujo inexistente, o crear un flujo mínimo más adelante.

### 4.4 Eliminar

- No se recomienda eliminar .md solo por tener referencias rotas; primero corregir rutas y luego decidir si algún doc sobra (por ejemplo si NOMENCLATURA_UI está duplicado con GUIA_UI, o un config muy antiguo).

### 4.5 Índice docs/README.md

- Añadir sección **Configuración** con enlaces a: CONTEXT.md, INDICE_SISTEMA_PLANES.md, DEPLOY_WEB_FIREBASE_HOSTING.md, TESTING_CHECKLIST.md, FCM_FASE1_IMPLEMENTACION.md, ONBOARDING_IA.md, USUARIOS_PRUEBA.md (y otros que quieras destacar).
- Añadir **admin/**: ADMINS_WHITELIST.md.
- Añadir **design/**: EVENT_COLOR_PALETTE.md.
- Añadir **testing/**: TESTING_OFFLINE_FIRST.md.
- En **Arquitectura**, añadir PLATFORM_STRATEGY.md.

---

## 5. Acciones realizadas en esta auditoría

- [x] Listado de todos los .md en docs/
- [x] Comparación con docs/README.md
- [x] Búsqueda de referencias cruzadas y detección de rutas incorrectas y documentos inexistentes
- [x] Corrección de rutas en TASKS.md y PROMPT_BASE.md (ya aplicada: usan docs/configuracion/CONTEXT.md y docs/tareas/COMPLETED_TASKS.md)
- [x] Actualización de docs/README.md (índice ampliado con Configuración, admin, design, testing, PLATFORM_STRATEGY)
- [x] Flujos y guías: fechas "Última actualización" actualizadas a Febrero 2026
- [x] TASKS.md: convención de referencias reforzada; añadido "(doc pendiente)" a todas las rutas de documentos/carpetas no existentes (API_DOCUMENTATION, CONTRIBUTING, SERVICE_EXAMPLES, TESTING_PLAN, legal/, estrategia/, riesgos/, roadmap/, FLUJO_*, GUIA_MODELO_NEGOCIO_AGENCIAS, INDICES_*, USUARIOS_ADMINISTRACION)
- [x] **Siguiente revisión (Feb 2026):** Se usó el documento `docs/PROPUESTA_OPTIMIZACION_Y_SINCRONIZACION.md` para aplicar sincronización doc↔código (ARCHITECTURE_DECISIONS, FIRESTORE_COLLECTIONS_AUDIT, PLATFORM_STRATEGY, NOMENCLATURA_UI, FLUJO_INVITACIONES, TESTING_CHECKLIST, README, ux/pages, ONBOARDING_IA, CONTEXT, TASKS referencias, índice README).
- [x] **Refactor 2.1 pg_dashboard_page (Feb 2026):** Extraídos a `lib/widgets/dashboard/` y `lib/widgets/dialogs/wd_create_plan_modal.dart`: WdTimezoneBanner, WdCreatePlanModal, WdDashboardNavTabs, WdDashboardSidebar, WdDashboardHeaderBar, WdDashboardFilters, WdDashboardHeaderPlaceholders. Estado y siguientes pasos en PROPUESTA_OPTIMIZACION_Y_SINCRONIZACION.md (sección 2.1 y Estado de la propuesta).
- [x] **Referencias TASKS.md (Feb 2026):** Añadido "(doc pendiente)" a `docs/admin/SCRIPTS_ADMINISTRATIVOS.md` y `docs/admin/PROCEDIMIENTOS_EMERGENCIA.md`; normalizadas rutas en "Relacionado con" a `docs/flujos/FLUJO_*.md` donde solo se citaba el nombre del archivo.
- [x] **FLUJO_ESTADOS_PLAN (Mar 2026):** Eliminada mención a migración legacy (state 'borrador'); documento alineado con código: planes solo Planificando → Confirmado → En curso → Finalizado/Cancelado. Última actualización del doc: Marzo 2026.
- [x] **Limpieza Fase 1 (Abr 2026):** Eliminados docs de baja tracción/solape: `TESTING_FEEDBACK_TEMPLATE.md`, `TAREA_AGENTE_REVISION_INPUT_MD.md`, `DOCS_EVALUACION_UNO_A_UNO.md`, `ux/layout/*`, `ux/mejoras/PLANDATASCREEN_ALINEACION.md`, `ux/PROPUESTA_CALENDARIO_IOs_FILA_UNICA_TOP.md`, `ux/RESUMEN_PLAN_ESTRUCTURA_Y_MEJORAS.md`.
- [x] **Limpieza Fase 2 (Abr 2026, push/FCM):** Consolidada la operación en `CHECKLIST_IOS_PUSH_DEEPLINKS.md` como fuente única A1/A2; `FCM_FASE1_IMPLEMENTACION.md` queda como referencia técnica de arquitectura y `ACCIONES_PENDIENTES_APP.md` como estado ejecutivo (sin duplicar pasos).
- [x] **Limpieza Fase 3 (Abr 2026, producto):** Consolidada posición de producto vs IA en `configuracion/ONBOARDING_IA.md`; eliminados `producto/POSICION_PRODUCTO_FRENTE_A_IA.md` y `producto/BUZON_UNIFICADO_NOTIFICACIONES.md`; referencias de notificaciones centralizadas en `NOTIFICACIONES_ESPECIFICACION.md`.
- [x] **Limpieza Fase 4 (Abr 2026, correo eventos):** Consolidado T134 en `producto/CORREO_EVENTOS_SISTEMA_PARSEO.md` (recepción + anti-spam + esquema Firestore); eliminados `producto/CORREO_EVENTOS_SPAM.md` y `producto/CORREO_EVENTOS_FIRESTORE_SCHEMA.md`; referencias de tareas/histórico actualizadas.
- [x] **Limpieza Fase 5 (Abr 2026, flujos):** Auditoría estricta de `docs/flujos/FLUJO_*.md`; metadatos normalizados (versión/fecha/última actualización), estado push iOS alineado y `FLUJO_PRESUPUESTO_PAGOS.md` ajustado al estado actual (bote común legacy fuera de UI principal).
- **Próxima revisión:** Seguir ítems pendientes de la propuesta (contenido W31, otros archivos grandes, etc.); el documento de la propuesta es la referencia única de seguimiento.

### 5.1 Control final de flujos (Abr 2026)

| Archivo | Estado | Observación | Acción futura |
|--------|--------|-------------|---------------|
| `FLUJO_CRUD_PLANES.md` | Alineado | Estados del plan y metadatos consistentes. | Revisar tras cierres de offline/push. |
| `FLUJO_CRUD_EVENTOS.md` | Alineado | Refleja cambios recientes de formulario y guardado. | Revisar al cerrar T250 (matriz tipo/subtipo). |
| `FLUJO_CRUD_ALOJAMIENTOS.md` | Alineado | Metadatos normalizados. | Revisar si cambia flujo de check-in/out. |
| `FLUJO_GESTION_PARTICIPANTES.md` | Alineado | Coherente con invitaciones actuales. | Ajustar si cambia “añadir sin invitar”. |
| `FLUJO_INVITACIONES_NOTIFICACIONES.md` | Alineado (con pendiente) | Push documentado con base técnica lista. | Cerrar texto tras validación iPhone físico (A1/A2). |
| `FLUJO_PRESUPUESTO_PAGOS.md` | Alineado (con legado) | Bote común marcado como histórico/legacy. | Reabrir solo si producto reintroduce bote en UI. |
| `FLUJO_ESTADOS_PLAN.md` | Alineado | Sin mención activa a estado borrador de plan. | Sin acción inmediata. |
| `FLUJO_CRUD_USUARIOS.md` | Alineado | v1.5 (Abr 2026): snapshot `current_user` + `UserLocalService` enlazado con `TESTING_OFFLINE_FIRST.md`. | Revisar tras cambios fuertes de auth/perfil. |
| `FLUJO_CONFIGURACION_APP.md` | Alineado | Alcance vigente de configuración claro. | Revisar cuando entren preferencias avanzadas. |
| `FLUJO_VALIDACION.md` | Alineado | Metadatos normalizados y coherencia general. | Revisar al cerrar validaciones avanzadas/offline. |

---

## 6. ¿Son necesarios todos los .md?

**No.** Hay ~109 .md en docs/; no todos tienen el mismo peso. Esta sección clasifica por necesidad.

### 6.1 Nucleo imprescindible (no eliminar)

- **docs/README.md** – Índice de la documentación.
- **configuracion/CONTEXT.md** – Normas del proyecto.
- **tareas/TASKS.md** y **tareas/COMPLETED_TASKS.md** – Gestión de tareas.
- **guias/** – GUIA_UI.md, GUIA_SEGURIDAD.md, PROMPT_BASE.md, PROMPT_INICIO_CHAT.md, PROMPT_TRABAJO_AUTONOMO.md, GESTION_TIMEZONES.md.
- **configuracion/** – TESTING_CHECKLIST.md, USUARIOS_PRUEBA.md, EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md, REVISION_IOS_VS_WEB.md, DESPLEGAR_REGLAS_FIRESTORE.md, ONBOARDING_IA.md.
- **flujos/** – FLUJO_CRUD_PLANES.md, FLUJO_CRUD_EVENTOS.md, FLUJO_CRUD_ALOJAMIENTOS.md, FLUJO_ESTADOS_PLAN.md, FLUJO_GESTION_PARTICIPANTES.md, FLUJO_INVITACIONES_NOTIFICACIONES.md, FLUJO_CRUD_USUARIOS.md.
- **especificaciones/** – CALENDAR_CAPABILITIES.md, EVENT_FORM_FIELDS.md, PLAN_FORM_FIELDS.md, FRANKENSTEIN_PLAN_SPEC.md (si se usa el plan de pruebas).
- **arquitectura/** – ARCHITECTURE_DECISIONS.md, PLATFORM_STRATEGY.md.
- **testing/** – PLAN_PRUEBAS_E2E_TRES_USUARIOS.md, INICIO_PRUEBAS_DIA1.md, REGISTRO_OBSERVACIONES_PRUEBAS.md, SISTEMA_PRUEBAS_LOGICAS.md, TESTING_OFFLINE_FIRST.md (Hive móvil + `current_user`).

### 6.2 Útiles pero opcionales (mantener si se usan)

- **configuracion/** – DOCS_AUDIT.md (auditoría), CONFIGURAR_GOOGLE_*, DEPLOY_*, CHECKLIST_IOS_PUSH_DEEPLINKS.md, FCM_FASE1_IMPLEMENTACION.md, MIGRACION_MAC_*, SETUP_IOS_SIMULATOR.md, CREAR_USUARIOS_DESDE_CERO.md, emails/Gmail (si se usan invitaciones por correo).
- **producto/** – NOTIFICACIONES_ESPECIFICACION.md, NOTIFICACIONES_PLAN_CODIFICACION.md, PAGOS_MVP.md, PAGOS_PARIDAD_TRICOUNT.md.
- **ux/pages/** (w1–w30, login, register, profile) – Especificaciones de widgets; útiles para diseño/QA; si no se mantienen, GUIA_UI y NOMENCLATURA_UI pueden bastar.
- **design/EVENT_COLOR_PALETTE.md**, **admin/ADMINS_WHITELIST.md**.

### 6.3 Candidatos a archivar o fusionar (reducir ruido)

- **PROPUESTA_OPTIMIZACION_Y_SINCRONIZACION.md** (raíz): Cuando todos los ítems estén hechos o descartados, mover el estado final a COMPLETED_TASKS o a un “Estado de la propuesta” en DOCS_AUDIT y archivar el doc (o borrarlo si ya no aporta).
- **(Hecho, Abr 2026)** Se eliminó `DOCS_EVALUACION_UNO_A_UNO.md` y se consolidó la auditoría en este archivo (`DOCS_AUDIT.md`).
- **(Hecho, Abr 2026)** `producto/POSICION_PRODUCTO_FRENTE_A_IA.md` consolidado en `configuracion/ONBOARDING_IA.md` y eliminado.
- **ux/plan_info_aviso_t231.md**: Mantener mientras siga referenciado por QA/flujo; revisar en próximas limpiezas si se integra en un único resumen UX.
- **Especificaciones de producto futuro** (PATROCINIOS_Y_MONETIZACION, CORREO_EVENTOS_*, etc.): Mantener si hay roadmap; si no, mover a una carpeta `docs/producto/futuro/` o _archivo para no mezclar con lo activo.

### 6.4 No recomendado eliminar sin revisar

- Cualquier .md referenciado desde CONTEXT.md, TASKS.md, ONBOARDING_IA.md o desde el código (comentarios, README de lib/).
- Flujos y guías citados en CONTEXT: mantener al menos el enlace o un doc resumen si se fusionan varios.

**Resumen:** Se puede reducir cantidad archivando o fusionando los de §6.3 y agrupando “producto futuro” sin tocar el núcleo (§6.1). No es obligatorio eliminar; es una opción para que la documentación sea más manejable.

---

*Documento vivo: actualizar cuando se creen nuevas carpetas (legal, estrategia, riesgos, roadmap) o se eliminen docs.*
