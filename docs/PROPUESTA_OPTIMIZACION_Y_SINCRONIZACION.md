# 📋 Propuesta: Optimización de Código y Sincronización Documentación ↔ Código

> Revisión del proyecto para identificar optimizaciones de código y desajustes entre documentación (.md) y código.  
> **Fecha:** Febrero 2026  
> **Uso:** Decidir uno a uno qué ítems implementar.

---

## 📑 Índice

1. [Resumen ejecutivo](#1-resumen-ejecutivo)
2. [Optimizaciones de código](#2-optimizaciones-de-código)
3. [Sincronización documentación ↔ código](#3-sincronización-documentación--código)
4. [Documentación: referencias y coherencia](#4-documentación-referencias-y-coherencia)
5. [Priorización sugerida](#5-priorización-sugerida)

---

## 1. Resumen ejecutivo

| Área | Cantidad de ítems | Prioridad alta |
|------|-------------------|----------------|
| Optimización de código | 12 | 3 |
| Sincronización docs ↔ código | 14 | 6 |
| Documentación (referencias, índices) | 10 | 4 |
| **Total** | **36** | **13** |

**Hallazgos principales:**
- Varios archivos muy grandes (dashboard ~4k líneas, calendar screen ~4.5k, event dialog ~3k) que dificultan mantenimiento.
- Documentos de arquitectura y estrategia referencian nombres de archivo y modelos que no coinciden con el código actual.
- DOCS_AUDIT ya identificó referencias rotas; parte sigue sin corregir o no está reflejada en todos los sitios.
- Textos de la funcionalidad T193 (resumen del plan) y otros están hardcodeados en español; CONTEXT exige AppLocalizations.
- Firestore: la doc describe `events` como subcolección de `plans`; en código existe colección raíz `events` con `planId`.

---

## 2. Optimizaciones de código

### 2.1 Archivos muy grandes (refactor por mantenibilidad)

| Archivo | Líneas aprox. | Propuesta |
|---------|----------------|-----------|
| `lib/widgets/screens/wd_calendar_screen.dart` | ~4 500 | Extraer lógica a presenters/notifiers o a módulos por responsabilidad (grid, eventos, alojamientos, navegación). T96 (refactoring) puede incluir este archivo. |
| `lib/pages/pg_dashboard_page.dart` | ~3 950 | Extraer construcción de widgets W1–W30 a un módulo o archivos por zona (sidebar, lista planes, pie, pantallas W31). |
| `lib/widgets/wd_event_dialog.dart` | ~3 100 | Dividir en sub-widgets o por pestañas/secciones (datos básicos, participantes, coste, etc.). |
| `lib/widgets/screens/wd_plan_data_screen.dart` | ~2 600 | Extraer secciones (información base, presupuesto, participantes, estado) a widgets o archivos separados. |
| `lib/widgets/screens/wd_participants_screen.dart` | ~2 400 | Extraer listados, formularios e invitaciones a widgets o pantallas más pequeñas. |
| `lib/features/calendar/domain/services/plan_participation_service.dart` | ~844 | Valorar dividir en dominio (participations) vs lógica de invitaciones/auditoría si sigue creciendo. |

**Acción:** No es obligatorio hacerlo todo; priorizar los archivos en los que se trabaje más (p. ej. `wd_calendar_screen`, `pg_dashboard_page`) y alinear con T96.

**Refactor 2.1 – pg_dashboard_page (Feb 2026):**
- **Extraído:** Banner de zona horaria → `wd_timezone_banner.dart` (`WdTimezoneBanner`). Modal crear plan → `wd_create_plan_modal.dart` (`WdCreatePlanModal`). Pestañas W14–W25 → `wd_dashboard_nav_tabs.dart` (`WdDashboardNavTabs`). Barra lateral W1 → `wd_dashboard_sidebar.dart` (`WdDashboardSidebar`). Barra superior W2–W6 → `wd_dashboard_header_bar.dart` (`WdDashboardHeaderBar`: logo, +, showcase, imagen e info del plan).
- **Resultado:** ~740 líneas (timezone + modal + nav tabs) + ~430 líneas (W1 + W2–W6 y helpers) ≈ **~1 170 líneas menos** en `pg_dashboard_page.dart`.
- **Extraído (segunda tanda):** Filtros W26–W27 → `wd_dashboard_filters.dart` (`WdDashboardFilters`: botones Todos/Estoy in/Pendientes/Cerrados + toggle Lista/Calendario).
- **Extraído (tercera tanda):** Celdas vacías W7–W12 → `wd_dashboard_header_placeholders.dart` (`WdDashboardHeaderPlaceholders`: una fila de 6 celdas C12–C17 R1).
- **Siguientes bloques candidatos:** contenido W31 (pantallas según `currentScreen`), o pausar refactor del dashboard y priorizar otros archivos (wd_event_dialog, wd_calendar_screen).

---

### 2.2 Textos hardcodeados (multi-idioma)

CONTEXT.md y T158 exigen usar `AppLocalizations` para todos los textos visibles. Hay muchos usos de `Text('...')` y cadenas en español.

**Ejemplos detectados (muestra):**
- `plan_summary_dialog.dart`: "Resumen del plan", "Resumen copiado al portapapeles", "Copiar", "Cerrar", "Generando resumen...", "No se pudo generar el resumen."
- `plan_summary_button.dart`: tooltip "Ver resumen", label "Resumen".
- `pg_dashboard_page.dart`: decenas de cadenas (mensajes, etiquetas, botones).
- Otros: `wd_plan_data_screen`, `wd_participants_screen`, `invitation_response_dialog`, `announcement_dialog`, etc.

**Propuesta:**
- Añadir a T158 (o tarea específica) un ítem: “Migrar textos de T193 (resumen del plan) a app_es.arb / app_en.arb”.
- Crear claves para los textos del diálogo de resumen y del botón y usarlas en el código.
- Opcional: auditoría global de `Text('` y `SnackBar(content: Text('` para planificar migración por módulos.

---

### 2.3 Duplicación y reutilización

- **Servicios instanciados en bucle:** En varios sitios se hace `PlanSummaryService()`, `InvitationService()`, etc. dentro de métodos. Ya se optimizó el diálogo de resumen con un `static final`; en otros servicios valorar usar **providers** (Riverpod) para una única instancia donde aplique.
- **Lógica de “usuario actual”:** Varios widgets obtienen `ref.read(currentUserProvider)` y comprueban null antes de mostrar un botón. Ya se extrajo `PlanSummaryButton`; revisar si hay más patrones repetidos (p. ej. “solo mostrar si hay plan y usuario”) que puedan encapsularse en un widget o mixin.
- **Formateo de fechas:** Existen `DateFormatter`, `DateFormat` de intl y formateos manuales (`'${d.day}/${d.month}/${d.year}'`). Unificar criterio (p. ej. una utilidad o un único punto de formato por contexto) para evitar inconsistencias.

---

### 2.4 Rendimiento y buenas prácticas

- **Providers que podrían ser `family` o `autoDispose`:** Revisar providers que mantienen estado por `planId` o `userId` y valorar `autoDispose` donde el estado no deba persistir al salir de la pantalla.
- **Listeners y suscripciones:** Asegurar que todos los `StreamSubscription` y listeners se cancelen en `dispose` (ya hay buenas prácticas en el proyecto; una pasada de revisión no vendría mal).
- **Logs en producción:** CONTEXT pide no dejar `print()` ni logs ruidosos; verificar que el logger esté usado de forma consistente y que no queden `print` de depuración en archivos tocados recientemente.

---

## 3. Sincronización documentación ↔ código

### 3.1 Nombres de archivos y estructura (PLATFORM_STRATEGY, NOMENCLATURA_UI)

| Documento | Dice | Código real |
|-----------|------|-------------|
| `docs/arquitectura/PLATFORM_STRATEGY.md` | `pg_dashboard_web.dart`, `pg_plans_list_mobile.dart` | `pg_dashboard_page.dart`, `pg_plans_list_page.dart` |
| `docs/configuracion/NOMENCLATURA_UI.md` | Mismo | Mismo |

**Propuesta:** Actualizar PLATFORM_STRATEGY y NOMENCLATURA_UI para que los ejemplos de estructura usen los nombres reales (`pg_dashboard_page.dart`, `pg_plans_list_page.dart`) y, si se desea, añadir una nota de que la separación web/mobile es por contenido (dashboard vs lista) no por sufijo en el nombre del archivo.  
✅ **Hecho (Feb 2026).**

---

### 3.2 Modelos y arquitectura (ARCHITECTURE_DECISIONS)

| Tema | En documento | En código |
|------|----------------|-----------|
| Eventos “duplicados por participante” | Ejemplo con `participantId` y copia por participante (vueloPadre / vueloMadre) | Modelo real: `Event` con `planId`, `userId`, `commonPart`, `personalParts` (patrón común/personal), sin `participantId` como campo principal |
| Plan timezone | `Plan.baseTimezone` | `Plan.timezone` (y `baseDate` para fechas) |
| Event timezone | “Sin campo timezone específico” | `Event` tiene `timezone` y `arrivalTimezone` opcionales |

**Propuesta:** Actualizar ARCHITECTURE_DECISIONS.md:
- Sustituir el ejemplo de eventos duplicados por uno alineado con el modelo actual (commonPart / personalParts, o referencia a GUIA_PATRON_COMUN_PERSONAL).
- Corregir nombres de campos (`timezone` en lugar de `baseTimezone`; mencionar `baseDate`/columnCount para fechas).
- Mencionar que los eventos pueden tener `timezone`/`arrivalTimezone` cuando aplique.  
✅ **Hecho (Feb 2026).**

---

### 3.3 Firestore (FIRESTORE_COLLECTIONS_AUDIT)

| Documento | Dice | Código real |
|-----------|------|-------------|
| FIRESTORE_COLLECTIONS_AUDIT | `events` como subcolección: `plans/{planId}/events/{eventId}` | EventService usa colección raíz `events` con campo `planId` |
| Idem | Subcolecciones de plans: events, accommodations, payments, announcements | En código: colecciones raíz `events`, y alojamientos en la misma colección `events` con `typeFamily: 'alojamiento'` |

**Propuesta:** Actualizar FIRESTORE_COLLECTIONS_AUDIT (y cualquier otro doc que describa la estructura de Firestore) para reflejar:
- Colección raíz `events` (con `planId`, `typeFamily`, etc.).
- Que los “alojamientos” son documentos en `events` con `typeFamily == 'alojamiento'`.
- Listar el resto de colecciones raíz realmente usadas (plans, users, plan_participations, plan_invitations, etc.) según las reglas y el código.  
✅ **Hecho (Feb 2026).**

---

### 3.4 Flujos (invitaciones, aceptación por token)

- **FLUJO_INVITACIONES_NOTIFICACIONES:** Describe el flujo de invitación y aceptación. El código actual incluye:
  - Aceptación vía **Cloud Function** `markInvitationAccepted` (además de creación de participación en cliente).
  - Token en la URL y stripping de query string (`?action=accept`).

**Propuesta:** Añadir en el flujo (o en una nota técnica) que la actualización del estado de la invitación a “accepted” se hace mediante la Cloud Function `markInvitationAccepted` para evitar problemas de permisos en Firestore, y que el link puede llevar `?action=accept`.

---

### 3.5 UX / páginas (docs/ux/pages/index.md)

- El índice de páginas está bastante alineado (login, register, profile, plan_chat_screen, widgets W1–W30).
- No aparece la **página de invitación** (`pg_invitation_page.dart`) ni el **resumen del plan (T193)** (diálogo + botón en card y detalle).

**Propuesta:** Añadir en `docs/ux/pages/index.md`:
- Entrada para la página de invitación (ruta `/invitation/:token`, InvitationPage).
- Entrada para “Resumen del plan” (T193): botón en card, en detalle y en PlanDataScreen; diálogo con texto y copiar.

---

### 3.6 Testing (TESTING_CHECKLIST)

- No hay sección ni casos específicos para **T193 (resumen del plan)** ni para el flujo de **aceptación de invitación por link** (token + Cloud Function).

**Propuesta:** Añadir en TESTING_CHECKLIST:
- Casos para “Resumen del plan”: generar desde card, desde detalle, copiar al portapapeles, SnackBar de confirmación.
- Casos para invitación: abrir link con token (con y sin `?action=accept`), aceptar, comprobar que la invitación pasa a “accepted” y que el banner desaparece.

---

### 3.7 README principal y estado del proyecto

- `docs/README.md` incluye un “Estado del proyecto” muy completo. Conviene que “Completado” incluya:
  - Invitaciones por email con aceptación vía Cloud Function.
  - Resumen del plan en texto (T193) con botón en card y en detalle.

**Propuesta:** Añadir estas dos líneas en la sección correspondiente de “Completado” para que el README siga siendo fiel al estado real.

---

## 4. Documentación: referencias y coherencia

### 4.1 Referencias incorrectas (ya detectadas en DOCS_AUDIT)

- **TASKS.md** y **PROMPT_BASE.md:** Comprobar que sigan usando `docs/configuracion/CONTEXT.md` y `docs/tareas/COMPLETED_TASKS.md` (rutas correctas). Si en algún sitio sigue `docs/CONTEXT.md` o `docs/COMPLETED_TASKS.md`, corregir.
- **TASKS.md:** Varias tareas referencian documentos que no existen (`docs/TESTING_PLAN.md`, `docs/flujos/FLUJO_SEGURIDAD.md`, `docs/legal/`, `docs/estrategia/`, etc.). Opciones:
  - Sustituir por la alternativa indicada en DOCS_AUDIT (p. ej. FLUJO_SEGURIDAD → GUIA_SEGURIDAD).
  - O añadir en la tarea una nota: “Doc pendiente: ruta …” y no dejar la referencia como si el doc existiera.

---

### 4.2 Índice docs/README.md

- DOCS_AUDIT recomienda incluir en el índice: Configuración (ampliada), admin/, design/, testing/, PLATFORM_STRATEGY.
- Comprobar que **docs/README.md** enlace a:
  - `docs/arquitectura/PLATFORM_STRATEGY.md`
  - `docs/configuracion/` (lista ampliada: CONTEXT, TESTING_CHECKLIST, DEPLOY_WEB, FCM, ONBOARDING_IA, USUARIOS_PRUEBA, etc.)
  - `docs/admin/ADMINS_WHITELIST.md`
  - `docs/design/EVENT_COLOR_PALETTE.md`
  - `docs/testing/TESTING_OFFLINE_FIRST.md`  
✅ **Hecho (Feb 2026):** índice ampliado con todos estos enlaces.

---

### 4.3 CONTEXT.md

- Rutas de Flutter: Windows `C:\Users\cclaraso\...` y macOS `.../emmclaraso/...`. Si el equipo usa solo uno o ha cambiado, actualizar o dejar solo la ruta relevante para evitar confusión.  
✅ **Hecho (Feb 2026):** añadida nota en CONTEXT "Usar la ruta correspondiente a tu sistema; actualizar si tu instalación está en otra ubicación".
- La sección de documentación ya referencia flujos y guías; verificar que no falte ninguna guía nueva (p. ej. si se crea algo para invitaciones o resumen).

---

### 4.4 ONBOARDING_IA y DOCS_AUDIT

- **ONBOARDING_IA:** Incluir, si no está, una mención a que la aceptación de invitaciones usa la Cloud Function `markInvitationAccepted` y que el resumen del plan (T193) está implementado (diálogo + botón en card y detalle).
- **DOCS_AUDIT:** Marcar como “hecho” las acciones ya realizadas (corrección de rutas, ampliación del índice) y añadir una línea sobre esta propuesta (optimización + sincronización) como siguiente revisión.

---

## 5. Priorización sugerida

### Alta (impacto directo en coherencia y normas)

1. Corregir ARCHITECTURE_DECISIONS (modelo Event, Plan.timezone/baseDate).
2. Corregir FIRESTORE_COLLECTIONS_AUDIT (events como colección raíz, alojamientos en events).
3. Actualizar PLATFORM_STRATEGY y NOMENCLATURA_UI con nombres reales de archivos.
4. Añadir T193 y flujo de invitación (Cloud Function) a TESTING_CHECKLIST.
5. Migrar textos de T193 (resumen del plan) a AppLocalizations (app_es.arb / app_en.arb).
6. Añadir en docs/README.md “Resumen del plan (T193)” e “Invitaciones con aceptación vía Cloud Function” en Completado.

### Media (mejora de mantenibilidad y descubribilidad)

7. Añadir en docs/ux/pages/index.md la página de invitación y el resumen del plan.
8. Actualizar FLUJO_INVITACIONES_NOTIFICACIONES con Cloud Function y query string.
9. Revisar y corregir referencias rotas en TASKS.md (o notas “doc pendiente”).
10. Completar índice docs/README.md (config, admin, design, testing, PLATFORM_STRATEGY).
11. Refactorizar al menos uno de los archivos muy grandes (p. ej. empezar por wd_calendar_screen o pg_dashboard_page) según T96.

### Baja (cuando haya tiempo)

12. Unificar criterio de formateo de fechas y uso de providers para servicios.
13. Actualizar CONTEXT (rutas Flutter si aplica) y ONBOARDING_IA con Cloud Function y T193.
14. Revisión de providers (autoDispose/family) y de cancelación de suscripciones.

---

## Cómo usar esta propuesta

- Ir **ítem a ítem** (o por bloques): elegir uno, implementarlo y marcar en este documento o en TASKS.
- No es obligatorio hacer todo; priorizar según tiempo y impacto.
- Si se implementa algo que afecte a esta propuesta, actualizar el doc (por ejemplo tachando ítems hechos o añadiendo “Hecho en fecha X”).

---

## Estado de la propuesta (seguimiento)

**Implementado en Feb 2026:**
- 3.1 PLATFORM_STRATEGY y NOMENCLATURA_UI (nombres reales de archivos)
- 3.2 ARCHITECTURE_DECISIONS (Event, Plan, Firestore)
- 3.3 FIRESTORE_COLLECTIONS_AUDIT (events raíz, alojamientos en events)
- 3.4 FLUJO_INVITACIONES_NOTIFICACIONES (Cloud Function, ?action=accept)
- 3.5 docs/ux/pages/index.md (página invitación + resumen T193)
- 3.6 TESTING_CHECKLIST (casos T193 e invitación)
- 3.7 README estado (T193 + invitaciones Cloud Function)
- 4.1 TASKS.md (doc pendiente, referencias)
- 4.2 Índice docs/README.md (Configuración ampliada)
- 4.3 CONTEXT (nota rutas Flutter)
- 4.4 ONBOARDING_IA (Cloud Function + T193)

**Implementado (Feb 2026) – 2.3 Duplicación y reutilización:**
- InvitationService: uso de `invitationServiceProvider` en `pg_dashboard_page`, `wd_participants_screen`, `wd_notification_list_dialog`; inyección en `PlanService` desde los providers (`calendar_providers`, `database_overview_providers`).
- Formateo de fechas: `_formatDate` y formatos manuales `d/m/y` sustituidos por `DateFormatter.formatDate()` en `wd_plan_data_screen`, `wd_plan_card_widget`, `pg_dashboard_page`, `wd_participants_screen`, `pg_plans_list_page`, `wd_event_dialog`.

**Implementado (Feb 2026) – 2.2 Textos T193 a AppLocalizations:**
- Claves en `app_es.arb` y `app_en.arb`: planSummaryTitle, planSummaryCopiedToClipboard, planSummaryCopy, planSummaryCopied, planSummaryClose, planSummaryError, planSummaryGenerating, planSummaryButtonTooltip, planSummaryButtonLabel.
- `plan_summary_dialog.dart` y `plan_summary_button.dart` usan `AppLocalizations.of(context)!` para todos los textos visibles.

**Implementado (Feb 2026) – 2.2 Textos dashboard (widgets extraídos) a AppLocalizations:**
- Claves añadidas: dashboardFilterAll, dashboardFilterEstoyIn, dashboardFilterPending, dashboardFilterClosed, dashboardSelectPlan, dashboardUiShowcaseTooltip, dashboardLogo, dashboardTabPlanazoo, dashboardTabCalendar, dashboardTabIn, dashboardTabStats, dashboardTabPayments, dashboardTabChat.
- `wd_dashboard_filters.dart`, `wd_dashboard_header_bar.dart` y `wd_dashboard_nav_tabs.dart` usan `AppLocalizations` para filtros, logo, tooltip showcase, placeholder "Selecciona un plan" y etiquetas de pestañas. `WdDashboardNavTabs.tabItems(context)` devuelve la lista de pestañas con etiquetas localizadas.

**Implementado (Feb 2026) – 2.2 Textos pg_dashboard_page (diálogos Firestore, eliminar usuarios, Frankenstein):**
- Claves añadidas: understood; dashboardFirestoreInitializing, dashboardFirestoreInitialized, dashboardTestUsersLabel, dashboardTestUsersPasswordNote, dashboardTestUsersEmailNote, dashboardFirestoreSessionNote, dashboardFirestoreIndexes, dashboardFirestoreIndexesWarning, dashboardFirestoreIndexesDeployHint/Command, dashboardFirestoreConsoleHint/Steps, dashboardFirestoreDocs/Paths, dashboardFirestoreInitError(error); dashboardDeleteTestUsersTitle/Select/Warning, dashboardSelectAll, dashboardDeselectAll, dashboardDeletingUsersCount(count), dashboardDeletionCompleted, dashboardDeletedFromFirestore(count), dashboardNotFoundCount(count), dashboardErrorsCount(count), dashboardErrorsDetail, dashboardDeleteAuthNote, dashboardDeleteUsersError(error); dashboardGeneratingFrankenstein, dashboardFrankensteinSuccess, dashboardFrankensteinError.
- En `pg_dashboard_page.dart`: diálogo "Inicializando Firestore...", diálogo "Firestore Inicializado" (resultados, índices, documentación), botón "Entendido"; diálogo "Eliminar Usuarios de Prueba" (título, advertencia, Seleccionar/Deseleccionar todos), diálogo de progreso "Eliminando N usuario(s)...", diálogo "Eliminación Completada" y SnackBars de error; SnackBars del plan Frankenstein (generando, éxito, error). Todos usan `AppLocalizations.of(context)!`.

**Implementado (Feb 2026) – 2.2 Textos pg_dashboard_page (invitaciones por token y estados vacíos):**
- Claves añadidas: dashboardNoPlansYet, dashboardCreateFirstPlanHint; dashboardInvitationsPendingCount(count), dashboardInvitationTokenHint, dashboardAcceptRejectByToken; invitationPlanLabel(planId), invitationRoleLabel(role); invitationAcceptedParticipant, invitationAcceptFailed, reject, invitationRejected, invitationRejectFailed, linkCopiedToClipboard, copyLink; mustSignInToAcceptInvitations, dashboardManageInvitationByToken, dashboardInvitationLinkOrTokenLabel/Hint/Helper/Required, continueButton, invalidToken, invitationAcceptedAddedToPlan, tokenProcessingFailed, invitationRejectedSuccess; dashboardSelectPlanazoo, dashboardClickPlanToSeeCalendar; dashboardEmailLabel, dashboardIntroduceEmail; dashboardSelectPlanToSeeParticipants/Chat/Payments/Stats.
- En `pg_dashboard_page.dart`: estado vacío "Aún no tienes planes" y hint; banner de invitaciones pendientes (contador, hint, botón "Aceptar/Rechazar por token"); tarjetas de invitación (Plan/Rol, Aceptar/Rechazar, Copiar link) y SnackBars; diálogo "Gestionar invitación por token" (título, campos del formulario, Aceptar/Rechazar, Cancelar/Continuar) y todos los SnackBars del flujo; "Selecciona un Planazoo" y mensaje del calendario; label/hint del campo email; mensajes "Selecciona un plan para ver..." en participantes, chat, pagos y estadísticas. Todo usando `AppLocalizations.of(context)!`.

**Implementado (Feb 2026) – 2.4 Rendimiento (revisión parcial):**
- Eliminados `print()` de depuración en `lib/app/app.dart` (onGenerateRoute) para cumplir con CONTEXT (no dejar prints en producción).
- Comprobado que las suscripciones se cancelan en `dispose`: `PlanParticipationNotifier`, `CalendarNotifier`, `AccommodationNotifier` y `pg_dashboard_page` (_participantSubscriptions) cancelan correctamente. `LoggerService` sigue usando `print` de forma intencionada como backend de logging.

**Implementado (Feb 2026) – 2.1 Refactor pg_dashboard_page (primera tanda):**
- `WdTimezoneBanner`: `lib/widgets/dashboard/wd_timezone_banner.dart` (sugerencia de timezone; estado de carga interno).
- `WdCreatePlanModal`: `lib/widgets/dialogs/wd_create_plan_modal.dart` (crear plan; reemplaza `_CreatePlanModal`).
- `WdDashboardNavTabs`: `lib/widgets/dashboard/wd_dashboard_nav_tabs.dart` (pestañas W14–W25: planazoo, calendario, in, stats, pagos, chat + celdas vacías W20–W25).
- `WdDashboardSidebar`: `lib/widgets/dashboard/wd_dashboard_sidebar.dart` (W1: notificaciones + perfil).
- `WdDashboardHeaderBar`: `lib/widgets/dashboard/wd_dashboard_header_bar.dart` (W2–W6: logo, botón crear plan, UI Showcase, imagen e info del plan seleccionado).
- `WdDashboardFilters`: `lib/widgets/dashboard/wd_dashboard_filters.dart` (W26–W27: filtros Todos/Estoy in/Pendientes/Cerrados + toggle Lista/Calendario).
- `WdDashboardHeaderPlaceholders`: `lib/widgets/dashboard/wd_dashboard_header_placeholders.dart` (W7–W12: celdas vacías del header C12–C17).

**Implementado (Feb 2026) – 4.1 Referencias TASKS.md:**
- Añadido "(doc pendiente)" a referencias de docs no creados: `docs/admin/SCRIPTS_ADMINISTRATIVOS.md`, `docs/admin/PROCEDIMIENTOS_EMERGENCIA.md`.
- Normalizadas rutas en "Relacionado con": uso de `docs/flujos/FLUJO_*.md` en lugar de solo el nombre del archivo (FLUJO_CRUD_PLANES.md, FLUJO_INVITACIONES_NOTIFICACIONES.md, etc.). Registro en DOCS_AUDIT.

**Pendiente (entre otros):** más extracciones en 2.1 (contenido W31 o otros archivos grandes); valorar providers `autoDispose`/`family` en futuras revisiones.

*Documento vivo. Última actualización: Febrero 2026.*
