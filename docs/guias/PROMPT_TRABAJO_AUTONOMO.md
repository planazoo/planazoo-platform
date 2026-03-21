# Prompt: Trabajo autónomo de revisión y limpieza

Usa este prompt cuando quieras que la IA trabaje sola durante unas horas en tareas de sincronización doc/código, limpieza de archivos, etc. Pégalo al inicio de un chat junto con el contexto del proyecto (o después de que la IA haya leído el repo)
---

## Paso 0 (obligatorio antes de empezar): Comprobar que este archivo está actualizado

**Antes de ejecutar las fases de trabajo autónomo**, revisa que la sección **"Contexto del proyecto"** de este mismo archivo sigue siendo fiel al estado actual del repositorio:

- Comprueba que las carpetas y archivos citados existen y que la descripción (lib/app, lib/features, lib/pages, lib/widgets, docs/ y sus subcarpetas) coincide con lo que hay en el repo.
- Comprueba que los nombres de documentos en `docs/` (configuracion, guias, flujos, especificaciones, tareas, testing, etc.) y los ejemplos de archivos siguen siendo correctos. En `docs/configuracion/` deben existir, entre otros: CONTEXT.md, EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md, REVISION_IOS_VS_WEB.md, DOCS_AUDIT.md.
- Si algo ha cambiado (nueva feature, docs movidos o renombrados, convenciones actualizadas), **actualiza primero este archivo** (PROMPT_TRABAJO_AUTONOMO.md) con el contexto corregido y luego continúa con las fases 1–5.

Solo después de esta comprobación (y de actualizar este prompt si hace falta) pasa a la sección "Tu tarea" y ejecuta las fases de trabajo autónomo.

---

## Contexto del proyecto (unp_calendario / Planazoo)

**Tipo:** App Flutter multi-plataforma (Web, iOS, Android, desktop). Riverpod, Firebase (Auth, Firestore, Storage, Functions, FCM), Hive, offline-first en roadmap.

**Estructura principal:**
- `lib/app/` – bootstrap y tema (Estilo Base oscuro, AppColorScheme, Poppins).
- `lib/features/` – módulos por feature: auth, budget, calendar, **chat** (mensajes, reacciones, plan_messages), flights, language, notifications, offline, payments, places, security, stats, testing (demo_data_generator). Cada uno suele tener domain/, presentation/, providers.
- `lib/pages/` – pantallas de nivel superior: pg_dashboard_page, pg_plans_list_page, pg_calendar_mobile_page, pg_plan_detail_page, pg_profile_page, pg_plan_participants_page, pg_participant_groups_page, etc. (no hay pg_invitation_page; invitación por notificaciones/directa).
- Manual de ayuda beta público: `features/help/presentation/pages/help_manual_page.dart`, ruta `'/help'` accesible desde login y también desde dentro de la app (web/iOS).
- `lib/widgets/` – UI reutilizable: screens/, dialogs/, plan/, event/, notifications/, etc. Incluye `wd_event_dialog.dart` (formulario de eventos con formato “título sobre el borde” y helper `_buildLabelOnBorderField`).
- Calendario: drag & drop de eventos se mantiene en `wd_calendar_screen.dart` (web/dashboard). En móvil (`pg_calendar_mobile_page.dart`) edición por tap + diálogo (sin DnD), decisión de producto documentada.
- `lib/shared/` – servicios, utils, permisos, FCM.
- `lib/l10n/` – localizaciones generadas (app_es.arb, app_en.arb). **Todos los textos visibles deben usar AppLocalizations** (CONTEXT.md §6).

**Documentación (`docs/`):**
- **README.md** – Índice principal: Guías, Flujos, Producto, Especificaciones, Arquitectura, UX, Configuración, Tareas, Testing, Admin. La lista completa de enlaces está en README; aquí solo se citan ejemplos.
- **configuracion/CONTEXT.md** – Normas: doc viva, reutilizar antes que crear, commits atómicos, no push sin confirmación, Estilo Base, multi-idioma obligatorio, referencias a GUIA_UI, GUIA_SEGURIDAD, flujos en `docs/flujos/`.
- **configuracion/** – CONTEXT.md, TESTING_CHECKLIST.md, USUARIOS_PRUEBA.md, DEPLOY_*, DESPLEGAR_REGLAS_FIRESTORE.md, DOCS_AUDIT.md, **EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md** (checklist y estado para pruebas con familia), **REVISION_IOS_VS_WEB.md** (iOS vs web, TestFlight, checklist), CONFIGURAR_GOOGLE_*, CREAR_USUARIOS_DESDE_CERO.md, etc.
- **guias/** – GUIA_UI.md, GUIA_SEGURIDAD.md, GUIA_PATRON_COMUN_PERSONAL.md, GESTION_TIMEZONES.md, PROMPT_BASE.md, PROMPT_INICIO_CHAT.md, PROMPT_TRABAJO_AUTONOMO.md.
- **flujos/** – FLUJO_CRUD_PLANES.md, FLUJO_CRUD_EVENTOS.md, FLUJO_CRUD_ALOJAMIENTOS.md, FLUJO_ESTADOS_PLAN.md, FLUJO_GESTION_PARTICIPANTES.md, etc.
- **especificaciones/** – CALENDAR_CAPABILITIES.md, EVENT_FORM_FIELDS.md, PLAN_FORM_FIELDS.md, ACCOMMODATION_FORM_FIELDS.md, FRANKENSTEIN_PLAN_SPEC.md.
- **tareas/** – TASKS.md (pendientes, códigos T###), COMPLETED_TASKS.md, propuestas (T96, T225, T246, T247, T252, etc.).
- **testing/** – INICIO_PRUEBAS_DIA1.md, REGISTRO_OBSERVACIONES_PRUEBAS.md, PLAN_PRUEBAS_E2E_TRES_USUARIOS.md, TESTING_OFFLINE_FIRST.md, SISTEMA_PRUEBAS_LOGICAS.md.
- **arquitectura/** – ARCHITECTURE_DECISIONS.md, PLATFORM_STRATEGY.md (naming pg_*, wd_*).
- **ux/** – ESTADO_USUARIO_EN_EL_PLAN.md, plan_image_management.md, pages/, layout/, estilos/, mejoras/. **producto/**, **admin/**, **design/** – más especificaciones y guías.

**Tests:** Unit/widget en `test/` (calendar, auth, permissions); datos en `tests/*.json`. No hay `integration_test/`. `analysis_options.yaml` usa flutter_lints.

**Convenciones:** Páginas `pg_*`, widgets `wd_*`; comunicación y docs en castellano; commits con prefijo de tarea (ej. T73:) si aplica; no hacer `git push` sin confirmación explícita del usuario.

---

## Tu tarea (trabajo autónomo, varias horas)

Trabaja de forma sistemática en el repo **unp_calendario** (Planazoo) para mejorar coherencia entre documentación y código, y para limpiar lo innecesario. Prioriza impacto y sigue las normas de `docs/configuracion/CONTEXT.md`.

**Fases sugeridas (puedes reordenar según convenga):**

1. **Documentación ↔ código**
   - Revisar `docs/README.md` y cada subcarpeta de `docs/` (configuracion, guias, flujos, especificaciones, tareas, testing, arquitectura, ux, producto). Para cada doc relevante, comprobar que los nombres de archivos, rutas, APIs y flujos descritos existan y coincidan con `lib/` y con el comportamiento actual.
   - Actualizar o anotar en el propio doc donde haya pasos obsoletos, referencias a archivos/carpetas eliminados o secciones que ya no aplican.
   - Tener en cuenta: `docs/especificaciones/EVENT_FORM_FIELDS.md` vs `lib/widgets/wd_event_dialog.dart`; `docs/especificaciones/CALENDAR_CAPABILITIES.md` vs código del calendario; flujos en `docs/flujos/` vs implementación en `lib/features/` y `lib/pages/`.
   - Si existe `docs/configuracion/EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md`, comprobar que el estado (Hecho/pendiente) y el checklist §4 reflejan el código actual (invitación móvil → PlanDetailPage, Safe area, timezones Africa/Cairo, l10n en lista de planes e invitación).
   - Usar `docs/configuracion/DOCS_AUDIT.md` y, si aplica, `PROPUESTA_OPTIMIZACION_Y_SINCRONIZACION.md` como lista de comprobación o prioridades.

2. **Limpieza de archivos**
   - Identificar archivos obsoletos, duplicados o de solo ejemplo que no se referencien desde el resto del código ni desde scripts (buscar imports y menciones en docs).
   - No borrar sin comprobar referencias; si hay dudas, dejar una nota en comentario o en un doc en lugar de eliminar.
   - Considerar `lib/widgets/`, `lib/pages/`, `lib/features/*/presentation/` y cualquier carpeta que haya quedado vacía o con un solo archivo huérfano.

3. **Estructura y convenciones**
   - Verificar que la estructura de `lib/` (features, shared, widgets, pages) sea coherente con el uso real (imports, rutas, providers).
   - Revisar TODOs/FIXMEs en el código: cerrar los que ya estén resueltos o anotar en TASKS.md si dan lugar a una tarea.
   - Eliminar o acotar bloques grandes de código comentado que ya no aporten.

4. **Tests y calidad**
   - Ejecutar `flutter test` y `flutter analyze`; anotar fallos o warnings relevantes.
   - Cada vez que se corrija un error de compilación/runtime/linter durante la sesión autónoma, añadir una entrada breve en `docs/configuracion/LOG_ERRORES_AUTOFIX.md` siguiendo el formato del propio archivo (contexto, error, causa raíz y solución aplicada).
   - Revisar que `docs/testing/` (REGISTRO_OBSERVACIONES_PRUEBAS.md, TESTING_OFFLINE_FIRST.md, etc.) describa cómo ejecutar pruebas y qué cubren; actualizar si el setup ha cambiado.

5. **Configuración y dependencias**
   - Revisar `pubspec.yaml`, `README.md` (raíz) y los “Cómo configurar” en `docs/configuracion/` (Google, Amadeus, Firebase, Gmail, etc.): pasos de instalación, variables de entorno (ej. `functions/.env`), y nombres de proyectos/APIs. Corregir discrepancias con el estado actual del repo.

**Reglas durante la sesión:**
- No cambiar funcionalidad ni hacer refactors grandes de lógica salvo que sea estrictamente necesario para corregir incoherencias doc/código o eliminar código muerto.
- Respetar CONTEXT.md: no hacer push sin confirmación; no hardcodear textos (usar l10n); mantener Estilo Base y referencias a GUIA_UI/GUIA_SEGURIDAD donde aplique.
- Al final, entregar un **resumen breve**: qué has revisado, qué documentos o archivos has actualizado, qué has eliminado o movido, y qué queda pendiente o recomendado (incl. tareas sugeridas para TASKS.md si aplica).

---

## Última ejecución (12 mar 2026)

- **Paso 0:** Verificado: estructura lib/ (app, features, pages, widgets) y docs/ (configuracion, guias, flujos, etc.) coincide con el repo. CONTEXT.md, EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md, REVISION_IOS_VS_WEB.md, DOCS_AUDIT.md presentes en configuracion/.
- **Fase 1 (doc ↔ código):** Actualizado `docs/flujos/FLUJO_ESTADOS_PLAN.md`: eliminada la línea de "Migración legacy" (planes con state 'borrador'); los planes viven solo en Planificando → Confirmado → En curso → Finalizado/Cancelado. Fecha del documento: Marzo 2026. PROMPT_BASE.md ya usa `docs/configuracion/CONTEXT.md`. TASKS.md ya usa rutas correctas a CONTEXT y COMPLETED_TASKS.
- **Fase 2–3:** No se eliminaron archivos ni se tocaron TODOs/FIXMEs (evitar cambios de lógica; limpieza de archivos requeriría revisión manual de referencias).
- **Fase 4 (tests y calidad):** `flutter analyze`: 703 issues (warnings + info, sin errores de compilación). `flutter test`: 30 pasan, ~1 skip, 15 fallan; el fallo principal es `test/widget_test.dart` (App necesita ProviderScope; ya documentado en ejecución anterior). No se añadió entrada en LOG_ERRORES_AUTOFIX (no se corrigieron errores en esta sesión).
- **Fase 5:** pubspec.yaml y README revisados; sin discrepancias detectadas.
- **Pendiente / sugerido:** Arreglar `test/widget_test.dart` envolviendo `App()` en `ProviderScope` (o usar widget test que no dependa de Riverpod/Firebase); reducir warnings del analyzer por prioridad (unused_import, unnecessary_null_assertion, etc.); ejecutar checklist §4 de EVALUACION_PRIMERAS_PRUEBAS_FAMILIA antes de invitar a familia.

---

## Ejecución anterior (7 mar 2026)

- **Paso 0:** Contexto actualizado: añadidos en configuracion/ `EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md` (checklist y estado para pruebas con familia) y `REVISION_IOS_VS_WEB.md` (iOS vs web, TestFlight); feature **chat** (mensajes, reacciones) en lib/features/; guias/ y tareas/ con referencias actuales.
- **Fase 1 (doc ↔ código):** EVALUACION_PRIMERAS_PRUEBAS_FAMILIA refleja estado actual: ítems 3.1.1–3.1.4 marcados Hecho (l10n planes list e invitación, navegación al plan en móvil, Safe area, timezones Africa/Cairo). README enlaza a EVALUACION y REVISION_IOS_VS_WEB en Configuración.
- **Limpieza / consolidación:** DOCS_AUDIT y DOCS_EVALUACION_UNO_A_UNO se mantienen; se añadió referencia cruzada (resumen en DOCS_AUDIT, evaluación detallada en DOCS_EVALUACION). No se eliminaron .md; INICIO_PRUEBAS_DIA1 y EVALUACION_PRIMERAS_PRUEBAS_FAMILIA son complementarios (inicio genérico vs checklist familia).
- **TASKS.md:** Rutas a CONTEXT y COMPLETED_TASKS ya correctas. Añadida línea en Resumen sobre preparación pruebas familia (ver EVALUACION_PRIMERAS_PRUEBAS_FAMILIA).
- **Pendiente / sugerido:** Tarea para arreglar tests que requieren Firebase/ProviderScope en setup; ejecutar checklist §4 de EVALUACION_PRIMERAS_PRUEBAS_FAMILIA antes de invitar a familia.
