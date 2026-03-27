# Prompt: Trabajo autónomo de revisión y limpieza

Usa este prompt cuando quieras que la IA trabaje sola durante unas horas en tareas de sincronización doc/código, limpieza de archivos, etc. Pégalo al inicio de un chat junto con el contexto del proyecto (o después de que la IA haya leído el repo)
---

## Paso 0 (obligatorio antes de empezar): Comprobar que este archivo está actualizado

**Antes de ejecutar las fases de trabajo autónomo**, revisa que la sección **"Contexto del proyecto"** de este mismo archivo sigue siendo fiel al estado actual del repositorio:

- Comprueba que las carpetas y archivos citados existen y que la descripción (lib/app, lib/features, lib/pages, lib/widgets, docs/ y sus subcarpetas) coincide con lo que hay en el repo.
- Comprueba que los nombres de documentos en `docs/` (configuracion, guias, flujos, especificaciones, tareas, testing, etc.) y los ejemplos de archivos siguen siendo correctos. En `docs/configuracion/` deben existir, entre otros: CONTEXT.md, EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md, REVISION_IOS_VS_WEB.md, DOCS_AUDIT.md, **CHECKLIST_IOS_PUSH_DEEPLINKS.md** (A1 push / A2 deep links), **LOG_ERRORES_AUTOFIX.md**.
- Si algo ha cambiado (nueva feature, docs movidos o renombrados, convenciones actualizadas), **actualiza primero este archivo** (PROMPT_TRABAJO_AUTONOMO.md) con el contexto corregido y luego continúa con las fases 1–5.

Solo después de esta comprobación (y de actualizar este prompt si hace falta) pasa a la sección "Tu tarea" y ejecuta las fases de trabajo autónomo.

---

## Contexto del proyecto (unp_calendario / Planazoo)

**Tipo:** App Flutter multi-plataforma (Web, iOS, Android, desktop). Riverpod, Firebase (Auth, Firestore, Storage, Functions, FCM), Hive, sincronización offline activa en varios flujos.

**Estructura principal:**
- `lib/app/` – bootstrap, rutas y tema (Estilo Base oscuro, AppColorScheme, Poppins).
- `lib/features/` – módulos por feature: auth, budget, calendar, **chat**, flights, **help** (`help/presentation/pages/help_manual_page.dart`), language, notifications, offline, payments, places, security, stats, testing (demo_data_generator), etc. Patrón domain / presentation / providers.
- `lib/pages/` – pantallas de nivel superior: `pg_dashboard_page`, `pg_plans_list_page`, `pg_calendar_mobile_page`, `pg_plan_detail_page`, `pg_profile_page`, … Invitaciones: flujo por notificaciones / participación (no hay `pg_invitation_page` dedicada).
- **Ayuda multilingüe (T157):** `lib/shared/constants/help_context_ids.dart`, `widgets/help/help_icon_button.dart`, seed `assets/help_texts_seed.json` (espejo en `docs/tareas/T157_AYUDA_TEXTOS_SEED.json`), colección Firestore `help_texts` tras “Actualizar ayuda” en admin.
- `lib/widgets/` – screens/, dialogs/, **plan/** (`wd_plan_navigation_bar.dart`, `wd_plan_user_status_label.dart`, **`plan_status_chip_actions.dart`**), `wd_event_dialog.dart` (campos “título sobre el borde” `_buildLabelOnBorderField`), etc.
- Calendario: **web/dashboard** `wd_calendar_screen.dart` (incl. drag & drop donde aplique). **Móvil** `pg_calendar_mobile_page.dart`: edición por tap + diálogo; capacidades en `docs/especificaciones/CALENDAR_CAPABILITIES.md`.
- `lib/shared/` – servicios, utils, permisos, FCM, providers de ayuda.
- `lib/l10n/` – `app_es.arb`, `app_en.arb` + generados. **Textos visibles: AppLocalizations** (CONTEXT.md §6).

**Estado reciente (marzo 2026, referencia):** **`docs/testing/LISTA_PUNTOS_CORREGIR_APP.md`** es la tabla viva de nuevos hallazgos; **infra iOS** (push / deep links) se sigue en **`docs/testing/ACCIONES_PENDIENTES_APP.md`** y `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (A1/A2). Estado personal en plan: `docs/ux/ESTADO_USUARIO_EN_EL_PLAN.md`.

**Documentación (`docs/`):**
- **README.md** – Índice: Guías, Flujos, Producto, Especificaciones, Arquitectura, UX, Configuración, Tareas, Testing, Admin.
- **configuracion/CONTEXT.md** – Normas de colaboración (doc viva, l10n, Estilo Base, referencias GUIA_UI / GUIA_SEGURIDAD).
- **configuracion/** – Además de los ya citados: **CHECKLIST_IOS_PUSH_DEEPLINKS.md**, **LOG_ERRORES_AUTOFIX.md** (bucle errores IA), TESTING_CHECKLIST, EVALUACION_PRIMERAS_PRUEBAS_FAMILIA, REVISION_IOS_VS_WEB, DOCS_AUDIT, NOMENCLATURA_UI, ONBOARDING_IA, etc.
- **guias/** – GUIA_UI, GUIA_SEGURIDAD, GESTION_TIMEZONES, PROMPT_BASE, PROMPT_INICIO_CHAT, **PROMPT_TRABAJO_AUTONOMO** (este archivo).
- **flujos/** – CRUD planes/eventos/alojamientos, FLUJO_ESTADOS_PLAN, participantes, pagos, invitaciones.
- **especificaciones/** – CALENDAR_CAPABILITIES, PLAN_FORM_FIELDS, EVENT_FORM_FIELDS, etc.
- **tareas/** – TASKS.md, COMPLETED_TASKS.md, README_TAREAS, especificaciones Txxx.
- **testing/** – INICIO_PRUEBAS_DIA1, **LISTA_PUNTOS_CORREGIR_APP** (nuevos hallazgos), **ACCIONES_PENDIENTES_APP** (infra iOS), PLAN_PRUEBAS_E2E_TRES_USUARIOS, REGISTRO_OBSERVACIONES, TESTING_OFFLINE_FIRST, SISTEMA_PRUEBAS_LOGICAS.
- **Raíz docs/** – `PROPUESTA_OPTIMIZACION_Y_SINCRONIZACION.md` (sincronización código/docs).
- **arquitectura/**, **ux/**, **producto/**, **admin/**, **design/** – según índice en docs/README.md.

**Tests:** `test/` (unit/widget); datos `tests/*.json`; scripts lógicos opcionales. Sin `integration_test/` en repo. `analysis_options.yaml` → flutter_lints.

**Convenciones:** Páginas `pg_*`, widgets `wd_*`; comunicación y docs en castellano; commits con prefijo de tarea (ej. T73:) si aplica. **`git push`:** solo con confirmación explícita del usuario (CONTEXT.md), salvo que el propio usuario pida commit+push en el mensaje.

---

## Tu tarea (trabajo autónomo, varias horas)

Trabaja de forma sistemática en el repo **unp_calendario** (Planazoo) para mejorar coherencia entre documentación y código, y para limpiar lo innecesario. Prioriza impacto y sigue las normas de `docs/configuracion/CONTEXT.md`.

**Fases sugeridas (puedes reordenar según convenga):**

1. **Documentación ↔ código**
   - Revisar `docs/README.md` y cada subcarpeta de `docs/` (configuracion, guias, flujos, especificaciones, tareas, testing, arquitectura, ux, producto). Para cada doc relevante, comprobar que los nombres de archivos, rutas, APIs y flujos descritos existan y coincidan con `lib/` y con el comportamiento actual.
   - Actualizar o anotar en el propio doc donde haya pasos obsoletos, referencias a archivos/carpetas eliminados o secciones que ya no aplican.
   - Tener en cuenta: `docs/especificaciones/EVENT_FORM_FIELDS.md` vs `lib/widgets/wd_event_dialog.dart`; `docs/especificaciones/CALENDAR_CAPABILITIES.md` vs código del calendario; flujos en `docs/flujos/` vs implementación en `lib/features/` y `lib/pages/`.
   - Revisar **`docs/testing/LISTA_PUNTOS_CORREGIR_APP.md`** (tabla viva) y, si aplica, **`docs/testing/ACCIONES_PENDIENTES_APP.md`** / **`docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md`** (A1/A2 infra iOS).
   - Si existe `docs/configuracion/EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md`, comprobar que el estado (Hecho/pendiente) y el checklist §4 reflejan el código actual (invitación móvil → PlanDetailPage, Safe area, timezones Africa/Cairo, l10n en lista de planes e invitación).
   - Usar `docs/configuracion/DOCS_AUDIT.md` y, si aplica, **`docs/PROPUESTA_OPTIMIZACION_Y_SINCRONIZACION.md`** como lista de comprobación o prioridades.

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

6. **Limpieza de ruido, warnings y textos visibles (l10n)**
   - **Debug / logs:** Buscar `print(`, `debugPrint(` y logs dejados en flujos de producción; sustituir por `LoggerService` (o equivalente del proyecto) donde aplique, o eliminar si era solo depuración. En código que solo debe loguear en desarrollo, usar `kDebugMode` / `assert` según CONTEXT.md.
   - **Analyzer:** Tras cambios, ejecutar `flutter analyze` (o `dart analyze` sobre archivos tocados). Priorizar **error** y **warning**; reducir **info** por lotes (p. ej. `deprecated_member_use`, `unused_import`) cuando no requiera refactors grandes.
   - **Multilingüe:** No dejar cadenas de UI en español/inglés fijas en `Text(`, `SnackBar`, `tooltip:`, `InputDecoration.labelText`, diálogos, etc. Añadir claves en `lib/l10n/app_es.arb` y `app_en.arb` (misma clave, textos traducidos), ejecutar `flutter gen-l10n` y usar `AppLocalizations.of(context)!` (o el patrón ya usado en la pantalla).
   - Documentar en esta misma guía (sección “Última ejecución”) un resumen de la pasada (archivos tocados, pendientes).

**Reglas durante la sesión:**
- No cambiar funcionalidad ni hacer refactors grandes de lógica salvo que sea estrictamente necesario para corregir incoherencias doc/código o eliminar código muerto.
- Respetar CONTEXT.md: no hacer push sin confirmación; no hardcodear textos (usar l10n); mantener Estilo Base y referencias a GUIA_UI/GUIA_SEGURIDAD donde aplique.
- Al final, entregar un **resumen breve**: qué has revisado, qué documentos o archivos has actualizado, qué has eliminado o movido, y qué queda pendiente o recomendado (incl. tareas sugeridas para TASKS.md si aplica).

---

## Última ejecución (12 mar 2026)

- **Paso 0:** Sin cambios estructurales al contexto del repo.
- **Fase 6 (limpieza / l10n):** Añadida la **fase 6** en este documento (debug, warnings analyzer, strings vía ARB). Añadidas y usadas claves en `app_es.arb` / `app_en.arb` + `flutter gen-l10n` para: participantes (invitación por email, diálogo enlace, invitaciones pendientes, eliminar participante, salir del plan), admin (`snackHelpUpdatedCount`, `snackHelpSyncFailedDetail`), bote (`kitty_*`, snackbars). Archivos tocados: `pg_plan_participants_page.dart`, `pg_admin_page.dart`, `kitty_contribution_dialog.dart`, `kitty_expense_dialog.dart`, `wd_participants_screen.dart` (amplio). **Pendiente sugerido:** más strings en `wd_participants_screen.dart` (p. ej. roles/descripciones, estado de invitación en subtítulo), `LoggerService` en lugar de `debugPrint`/`print` donde queden, y otro barrido de warnings.
- **Fases 1–5:** No ejecutadas en esta pasada.

---

## Ejecución anterior (21 mar 2026)

- **Paso 0:** Actualizado este archivo (Prompt trabajo autónomo): contexto alineado con `lib/features/help/`, `plan_status_chip_actions.dart`, ayuda T157, `LISTA_PUNTOS_CORREGIR_APP.md`, `CHECKLIST_IOS_PUSH_DEEPLINKS.md`, `LOG_ERRORES_AUTOFIX.md`. Verificados en disco: CONTEXT, EVALUACION_PRIMERAS_PRUEBAS_FAMILIA, REVISION_IOS_VS_WEB, DOCS_AUDIT, CHECKLIST_IOS_PUSH_DEEPLINKS.
- **Fase 1 (doc ↔ código):** Añadidos enlaces en `docs/README.md` a **LISTA_PUNTOS_CORREGIR_APP** y **CHECKLIST_IOS_PUSH_DEEPLINKS** (Testing / Configuración). Sin auditoría línea a línea de todos los .md en esta pasada.
- **Fase 2–3:** Sin eliminación de archivos ni barrido global de TODO/FIXME (riesgo de romper referencias).
- **Fase 4 (tests y calidad):** `flutter analyze`: **~695 issues** (mayoría info/deprecated/withOpacity; **sin errores** de compilación en el análisis). `flutter test`: **~30 pasan**, **~2 skip**, **~14 fallos** (incl. Firebase no inicializado en tests que tocan Firestore; `widget_test` con ProviderScope/Firebase; posible desajuste **LOGIN-009** en `login_logic_test` vs mensaje `loginUnknownError`). **No** se añadió entrada nueva en LOG_ERRORES_AUTOFIX (no se corrigieron fallos en esta sesión).
- **Fase 5:** Sin cambios a pubspec/README raíz en esta pasada.
- **Pendiente / sugerido:** Arreglar tests de Firebase con `TestWidgetsFlutterBinding` + `Firebase.initializeApp` mock o `fake_cloud_firestore`; alinear caso LOGIN-009 con auth real o actualizar `tests/login_cases.json`; revisar `widget_test.dart` (ProviderScope + skip hasta Firebase test). Infra iOS: completar A1/A2 según checklist. Reducir warnings analyzer por lotes (unused_import, deprecated_member_use).

---

## Ejecución anterior (12 mar 2026)

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
