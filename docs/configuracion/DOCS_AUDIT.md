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
| **configuracion/** | CONTEXT.md, INDICE_SISTEMA_PLANES.md, DEPLOY_WEB_FIREBASE_HOSTING.md, TESTING_CHECKLIST.md, FCM_FASE1_IMPLEMENTACION.md, DEPLOY_INDICES_FIRESTORE.md, DESPLEGAR_REGLAS_FIRESTORE.md, ONBOARDING_IA.md, USUARIOS_PRUEBA.md, MIGRACION_MAC_*.md, SETUP_IOS_SIMULATOR.md, EMAILS_*, SERVICIO_EMAILS_*, GUIA_PASO_A_PASO_GMAIL_EN.md, FIRESTORE_*.md, NOMENCLATURA_UI.md, CONFIGURAR_GOOGLE_SIGNIN.md, INSTALAR_JAVA.md, TESTING_FEEDBACK_TEMPLATE.md | Parcial (solo 3 enlaces) |
| **admin/** | ADMINS_WHITELIST.md | No |
| **arquitectura/** | ARCHITECTURE_DECISIONS.md, PLATFORM_STRATEGY.md | Sí (solo ARCHITECTURE_DECISIONS) |
| **guias/** | GUIA_UI.md, GUIA_SEGURIDAD.md, GUIA_ASPECTOS_LEGALES.md, GUIA_PATRON_COMUN_PERSONAL.md, GESTION_TIMEZONES.md, PROMPT_BASE.md | Sí |
| **flujos/** | FLUJO_CRUD_*.md, FLUJO_ESTADOS_PLAN.md, FLUJO_GESTION_PARTICIPANTES.md, FLUJO_INVITACIONES_NOTIFICACIONES.md, FLUJO_PRESUPUESTO_PAGOS.md, FLUJO_VALIDACION.md, FLUJO_CONFIGURACION_APP.md | Sí |
| **especificaciones/** | CALENDAR_CAPABILITIES.md, PLAN_FORM_FIELDS.md, EVENT_FORM_FIELDS.md, ACCOMMODATION_FORM_FIELDS.md, FRANKENSTEIN_PLAN_SPEC.md, PATROCINIOS_Y_MONETIZACION.md | Sí |
| **tareas/** | TASKS.md, COMPLETED_TASKS.md, CURRENCY_SYSTEM_PROPOSAL.md, T96_REFACTORING_PLAN.md | Sí (TASKS y COMPLETED_TASKS) |
| **ux/** | plan_image_management.md, estilos/ESTILO_SOFISTICADO.md, layout/README.md, layout/LAYOUT_SPEC_SYSTEM.md, mejoras/PLANDATASCREEN_ALINEACION.md, pages/*.md (index, w1–w30, login, profile, register) | Parcial (solo plan_image y “Documentación de Widgets”) |
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
- **Próxima revisión:** Seguir ítems pendientes de la propuesta (contenido W31, otros archivos grandes, etc.); el documento de la propuesta es la referencia única de seguimiento.

---

*Documento vivo: actualizar cuando se creen nuevas carpetas (legal, estrategia, riesgos, roadmap) o se eliminen docs.*
