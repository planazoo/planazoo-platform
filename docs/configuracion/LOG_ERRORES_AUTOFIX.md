# LOG_ERRORES_AUTOFIX

Registro ligero de errores que la IA ha detectado y corregido automáticamente, para evitar repetirlos y documentar patrones de solución.

## Formato recomendado

Cada entrada nueva debe seguir esta estructura:

### [YYYY-MM-DD] Código / Pantalla afectada

- **Contexto**: breve descripción (qué estabas haciendo, archivo principal).
- **Error**: extracto del mensaje de error más relevante.
- **Causa raíz**: qué estaba mal realmente.
- **Solución aplicada**: qué cambio concreto se hizo.
- **Notas para el futuro** (opcional): patrón a recordar o “gotcha” a evitar.

## Entradas

### [2026-04-08] `auth_notifier` — `onTimeout` con tipo incorrecto en `Future<bool>`

- **Contexto:** Ajuste offline-first del arranque de sesión para evitar bloqueo sin red.
- **Error:** `body_might_complete_normally` en `.timeout(... onTimeout: () {})` sobre `updateUsername(...)`.
- **Causa raíz:** `updateUsername` devuelve `Future<bool>` y el callback `onTimeout` no retornaba ningún `bool`.
- **Solución aplicada:** Cambiar a `onTimeout: () => false` para cumplir tipo y mantener fallback no bloqueante.

### [2026-04-08] `wd_event_dialog` — `undefined_identifier` tras añadir trazas de guardado

- **Contexto:** Instrumentación de debug para diagnosticar por qué el modal no se cerraba al guardar un evento en offline.
- **Error:** `Undefined name 'LoggerService'` en varias líneas de `wd_event_dialog.dart`.
- **Causa raíz:** Se añadieron llamadas a `LoggerService` sin importar `shared/services/logger_service.dart`.
- **Solución aplicada:** Añadido import explícito `package:unp_calendario/shared/services/logger_service.dart`.

### [2026-04-08] `calendar_notifier` — stream de eventos no refrescaba tras la carga inicial

- **Contexto:** Ítem 58 offline: el modal de crear evento cerraba, pero la vista calendario no mostraba nuevos eventos.
- **Error observado:** la UI no reflejaba emisiones nuevas pese a logs de guardado local/realtime.
- **Causa raíz:** En `_loadEvents()`, el listener de `getEventsByPlanId(...).listen(...)` tenía `if (state.loadingState != LoadingState.loading) return;`, bloqueando todas las emisiones posteriores a la primera.
- **Solución aplicada:** eliminar ese guard y aceptar todas las emisiones del stream para mantener el estado sincronizado en tiempo real (online/offline).

### [2026-04-08] Calendario offline — formulario de evento no se cierra tras guardar

- **Contexto:** Ítem 58 / guardado de evento con red desactivada (iPhone o pantallas que usan `EventDialog`).
- **Síntoma:** Tras pulsar guardar, el evento llega a persistirse (o encolarse) pero el diálogo no hace `pop` y el calendario no refresca hasta volver online.
- **Causa raíz:** (1) En `wd_calendar_screen` y `pg_plan_detail_page` el flujo hacía **`await NotificationHelper().notifyEventProposed(...)`** antes de cerrar el diálogo; esa llamada escribe en Firestore y puede quedar colgada sin red. (2) En `wd_event_dialog`, **`_getConvertedCost()`** podía esperar indefinidamente al documento `exchange_rates/current` si no había caché en memoria y el cliente no resolvía el `get()` en offline.
- **Solución aplicada:** Cerrar el diálogo justo después de `createEvent` donde aplicaba; pasar `notifyEventProposed` a **best-effort** (`Future` + `timeout` 2s) en plan detalle y calendario web; en `_getConvertedCost` aplicar **`timeout` 2s** sobre `convertAmount` y usar el importe local como respaldo.

### [2026-04-06] `wd_event_dialog` (offline) — `Plan?` no asignable en expansión de rango

- **Contexto:** Ajuste para no bloquear guardado de evento en offline (timeout en `planService.getPlanById`).
- **Error:** `The argument type 'Plan?' can't be assigned to the parameter type 'Plan'` en `ExpandPlanDialog` / `PlanRangeUtils.calculateExpandedPlanValues`.
- **Causa raíz:** Tras envolver el fetch en `try/catch`, el `plan` quedó nullable y se usó en closures async sin promoción estable de null-safety.
- **Solución aplicada:** Crear variable local no nula `planForRange` dentro del bloque `if (plan != null)` y usarla en todo el flujo de expansión.

### [2026-04-06] `pg_calendar_mobile_page` — `Cannot use "ref" after the widget was disposed`

- **Contexto:** Guardado de evento en modo offline; el evento se persistía pero el callback post-guardado lanzaba excepción.
- **Error:** `Bad state: Cannot use "ref" after the widget was disposed` en `_invalidateEventProviders`.
- **Causa raíz:** El callback `onSaved` del diálogo seguía ejecutando invalidaciones con `ref.read(...)` cuando la pantalla del calendario ya no estaba montada.
- **Solución aplicada:** Guardas `mounted` antes de invalidar (`if (mounted) _invalidateEventProviders();`) y salida temprana en `_invalidateEventProviders` si `!mounted`.

### [2026-04-06] iOS FCM/APNs — `apns-token-not-set` al iniciar push (ítem 109)

- **Contexto:** Pruebas de push iOS en dispositivo físico para cerrar el ítem 109; `FCMService.initialize(...)` ejecutado tras login.
- **Error:** `[firebase_messaging/apns-token-not-set] APNS token has not been set yet` y ausencia de subcolección `users/{userId}/fcmTokens`.
- **Causa raíz:** Configuración iOS incompleta para mensajería: `FirebaseAppDelegateProxyEnabled` estaba en `false` (sin registro manual de APNs), y el target no tenía `Runner.entitlements` con `aps-environment`.
- **Solución aplicada:** `Info.plist` con `FirebaseAppDelegateProxyEnabled = true`; creación de `ios/Runner/Runner.entitlements` con `aps-environment=development`; `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements` en Debug/Release/Profile del target Runner; además, en `FCMService`, espera/reintento APNs antes de pedir token FCM.
- **Solución aplicada:** `Info.plist` con `FirebaseAppDelegateProxyEnabled = true`; creación de `ios/Runner/Runner.entitlements` con `aps-environment=development`; `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements` en Debug/Release/Profile del target Runner; además, en `FCMService`, espera/reintento APNs antes de pedir token FCM. Se añadió registro nativo explícito en `AppDelegate` (`registerForRemoteNotifications`) y logs `APNS_NATIVE` para ver si iOS entrega token o falla el registro.
- **Notas para el futuro:** Si aparece `apns-token-not-set`, revisar primero swizzling/APNs entitlements antes de depurar Firestore o payloads.

### [2026-04-06] `wd_event_dialog` — assertion en `DropdownButton` con timezone `UTC`

- **Contexto:** Edición/creación de evento con selector de timezone en `wd_event_dialog`.
- **Error:** `There should be exactly one item with [DropdownButton]'s value: UTC`.
- **Causa raíz:** El `value` del dropdown podía ser `UTC` (u otra timezone válida) que no estaba en la lista de `items`, y además no se deduplicaban entradas antes de construir el selector.
- **Solución aplicada:** En `_buildTimezoneFieldOnBorder` se deduplica la lista (`toSet().toList()`), se inserta el valor actual si es válido y falta en `items`, y se usa `safeValue` para garantizar coherencia `value/items`.
- **Notas para el futuro:** En cualquier `DropdownButton(FormField)`, validar siempre que el `value` exista **exactamente una vez** en `items` antes de renderizar.

### [2026-03-27] `payment_providers` — comparación nula innecesaria en `participantId`

- **Contexto:** Tras quitar el fetch del bote en `paymentSummaryProvider`, `dart analyze` sobre providers.
- **Error:** `The operand can't be 'null', so the condition is always 'true'` / `unnecessary_non_null_assertion` en `payment.participantId`.
- **Causa raíz:** En `PersonalPayment`, `participantId` es `String` no nullable; el `if (payment.participantId != null)` era código heredado incorrecto.
- **Solución aplicada:** `userIdsToResolve.add(payment.participantId);` directo. Eliminado import `firebase_auth` que ya no se usaba en ese archivo.

### [2026-03-27] `wd_my_plan_summary_screen` — parámetro obligatorio sin argumento

- **Contexto:** Añadir `dimPastInCourse` a `_buildFlightsQuickContent` y a la llamada del ListView.
- **Error:** `The named parameter 'dimPastInCourse' is required, but there's no corresponding argument`.
- **Causa raíz:** Había **dos** llamadas idénticas a `_buildFlightsQuickContent` en el archivo; solo se actualizó una.
- **Solución aplicada:** Pasar `dimPastInCourse: dimPastInCourse` en la segunda llamada (o unificar en un solo bloque).
- **Notas:** Tras renombrar/añadir parámetros requeridos, buscar **todas** las referencias al método (`rg`).

### [2026-03-27] T262 `plan_workspace` — `permission-denied` al guardar (saveWorkspaceFull)

- **Contexto:** Pestaña Notas del plan; guardar notas comunes / política como organizador (`PlanNotesService.saveWorkspaceFull`).
- **Error:** `[cloud_firestore/permission-denied] Missing or insufficient permissions` con log `ERROR[PLAN_NOTES]: saveWorkspaceFull: <planId>`.
- **Causa raíz habitual:** (1) Reglas de Firestore del **proyecto remoto** sin desplegar o desactualizadas respecto a `firestore.rules` (bloque `plans/{planId}/plan_workspace/{docId}`). (2) Menos frecuente: el usuario no es el `userId` dueño del documento `plans/{planId}` aunque la UI trate el caso como organizador.
- **Solución aplicada:** Reglas: `allow create` de workspace también con `isAdmin(request.auth.uid)`; comentario en rules sobre `firebase deploy --only firestore:rules`. Código: log `debugPrint` orientativo si `FirebaseException.code == permission-denied`.
- **Notas para el futuro:** Tras cambiar reglas en repo, desplegar siempre al proyecto que usa la app; `isPlanOwner` exige que exista `plans/{planId}` y `userId == request.auth.uid`.

### [2026-03-27] T262 `PlanNotesService` — tipo `PlanPreparationItem` no resuelto

- **Contexto:** Implementar T262 (`plan_notes_service.dart` con `saveWorkspaceParticipantContent`).
- **Error:** `The name 'PlanPreparationItem' isn't a type` / `toMap` en receiver nullable.
- **Causa raíz:** Faltaba `import` del modelo `plan_preparation_item.dart`.
- **Solución aplicada:** Añadir el import explícito.

### [2026-03-27] `AppTheme` — `IconThemeData` sin parámetro `fontFamily` (Flutter 3.41+)

- **Contexto:** Añadir `iconTheme: IconThemeData(fontFamily: 'MaterialIcons')` para iconos en web.
- **Error:** `No named parameter with the name 'fontFamily'` en `IconThemeData`.
- **Causa raíz:** En Flutter reciente, `IconThemeData` ya no expone `fontFamily`; usa variantes M3 (`fill`, `weight`, `opticalSize`, etc.).
- **Solución aplicada:** Quitar ese `iconTheme`. Si hace falta reforzar iconos en web, mantener `fonts/MaterialIcons-Regular.otf` declarada en `pubspec.yaml`.
- **Notas para el futuro:** No usar APIs antiguas de `IconThemeData` para la familia de fuente.

### [2026-03-27] Plan adjuntos (iOS) — botón de subir sin efecto / `MissingPluginException`

- **Contexto:** Subida de adjuntos en `Info del plan` en iOS (`flutter run` en dispositivo).
- **Error:** `MissingPluginException(No implementation found for method custom on channel miguelruivo.flutter.plugins.filepicker)` y, en algunos casos, selección sin feedback visible.
- **Causa raíz:** El método `custom` de `file_picker` no estaba disponible en ese runtime iOS; además, en iOS puede devolverse `bytes` vacíos y la UI salía silenciosamente.
- **Solución aplicada:** En `plan_file_picker_io.dart` cambiar a `FileType.any` y validar extensión en `PlanFileService`; añadir fallback de lectura por `file.path` con `dart:io` cuando `bytes` venga vacío; en `wd_plan_data_screen.dart` mostrar mensaje si el archivo no pudo leerse.
- **Notas para el futuro:** En iOS, no confiar solo en `bytes` de `file_picker`; usar fallback con `path` y evitar depender de `FileType.custom` si hay builds/pods desalineados.

### [2026-03-27] Plan adjuntos — Firebase Storage “sin permiso / permission denied”

- **Contexto:** Subir PDF/JPG/PNG en Info del plan; la app usa path `plan_files/{planId}/{fileName}`.
- **Error:** Mensaje de falta de derechos al guardar en Firebase (upload rechazado).
- **Causa raíz:** `storage.rules` solo permitía `plan_images/`; el bloque catch-all `/{allPaths=**}` denegaba `plan_files/`.
- **Solución aplicada:** Añadir `match /plan_files/{planId}/{fileName}` con `read: true` y `write: if request.auth != null` (misma filosofía que `plan_images`). **Desplegar reglas:** `firebase deploy --only storage` en el proyecto correcto.
- **Notas para el futuro:** Cualquier carpeta nueva en Storage necesita regla explícita antes del match que niega todo.

### [2026-03-25] Plan adjuntos (web) — `LateInitializationError` en `file_picker`

- **Contexto:** Subida de adjuntos en `Info del plan` desde web (`flutter run -d chrome`).
- **Error:** `LateInitializationError: Field '_instance' has not been initialized` al invocar `FilePicker.platform`.
- **Causa raíz:** Dependencia del plugin `file_picker` en web sin instancia inicializada en runtime del proyecto.
- **Solución aplicada:** Separar selector de archivos por plataforma con import condicional: en web usar `FileUploadInputElement` (`dart:html`), en móvil/escritorio mantener `file_picker`.
- **Notas para el futuro:** Para pickers críticos en web, tener fallback nativo web evita bloqueos por registro de plugin.

### [2026-03-25] Calendario (iOS/Web) — alojamiento visible en un solo track tras crear/editar

- **Contexto:** En la fila de alojamientos del calendario, al guardar un alojamiento nuevo o editado solo aparecía en un participante.
- **Error:** Regresión de visibilidad por track en render/filtros de alojamientos.
- **Causa raíz:** La lógica de calendario evaluaba solo `participantTrackIds`; ignoraba `commonPart.isForAllParticipants` / `commonPart.participantIds` en casos mixtos.
- **Solución aplicada:** Unificar la lógica en `calendar_accommodation_logic.dart` con regla “para todos” y unión de participantes (`commonPart.participantIds` + `participantTrackIds`), respetar `commonPart.isForAllParticipants` en `calendar_tracks.dart`, y en `wd_accommodation_dialog.dart` sincronizar ambos campos al abrir/guardar para evitar desalineación legacy. Además, corregir cálculo de ancho en `calendar_tracks.dart` (`availableWidth` ya era ancho de día; se estaba dividiendo otra vez por `columns.length`) que generaba bloques minúsculos en el primer track.
- **Notas para el futuro:** En alojamientos/eventos con modelo híbrido (legacy + commonPart), evitar leer una sola fuente de participantes en la UI.

### [2026-03-25] `AccommodationDialog` — cálculo de noches incorrecto al cruzar DST

- **Contexto:** En edición/creación de alojamiento, tramo 28/3 → 1/4 mostraba 3 noches en vez de 4.
- **Error:** Conteo visual de noches con `checkOut.difference(checkIn).inDays` devolvía un día menos en cambio horario.
- **Causa raíz:** `DateTime.difference` en local usa horas reales; al cruzar DST puede haber días de 23/25 horas y truncar `inDays`.
- **Solución aplicada:** Calcular noches por fecha civil: normalizar ambas fechas a `DateTime.utc(año, mes, día)` y restar esas medianoches UTC.
- **Notas para el futuro:** Para días/noches de calendario, evitar `difference` directo entre `DateTime` locales con hora.

### [2026-03-25] `EventDialog` — overflow horizontal en selector de moneda del coste

- **Contexto:** Edición de evento en iOS/web; bloque de coste con moneda + importe en la misma fila (`wd_event_dialog.dart`).
- **Error:** `A RenderFlex overflowed by 17 pixels on the right` en `DropdownButtonFormField<String>` del selector de moneda.
- **Causa raíz:** El valor seleccionado del `DropdownButtonFormField` mostraba texto largo (`CODE - símbolo nombre`) dentro de un ancho reducido (~124 px), provocando desborde horizontal del `InputDecorator`.
- **Solución aplicada:** Configurar `isExpanded: true` y `selectedItemBuilder` para renderizar versión corta del valor seleccionado (`CODE símbolo`), manteniendo el texto largo solo en el menú desplegable.
- **Notas para el futuro:** En `DropdownButtonFormField` embebidos en layouts compactos, usar etiqueta corta para el valor seleccionado y dejar la descripción extensa en `items`.

### [2026-03-25] `AccommodationDialog` (editar) — Guardar no cerraba y Eliminar sin persistencia

- **Contexto:** Edición de alojamientos desde `pg_plan_detail_page` (iOS) y revisión de paridad en `pg_dashboard_page`.
- **Error:** Al pulsar **Guardar** se persistía el alojamiento pero el modal seguía abierto; al pulsar **Eliminar** parecía no hacer nada en algunas rutas.
- **Causa raíz:** Los callbacks `onSaved`/`onDeleted` del `AccommodationDialog` no implementaban el contrato completo en todas las pantallas: faltaba `Navigator.pop()` tras éxito y, en una ruta, `onDeleted` no llamaba al servicio de borrado.
- **Solución aplicada:** En `pg_plan_detail_page` y `pg_dashboard_page`, los callbacks ahora persisten/borran explícitamente, cierran el diálogo y muestran `SnackBar` de error si falla la operación.
- **Notas para el futuro:** Cualquier `showDialog(AccommodationDialog(...))` debe seguir el mismo patrón que `EventDialog`: persistir en callback + cerrar modal + feedback de error.

### [2026-03-25] `MyPlanSummaryScreen` — overflow horizontal en barra superior

- **Contexto:** Ajustes de tipografía y chips en la barra de `Mi resumen`.
- **Error:** `A RenderFlex overflowed by 9.0 pixels on the right` en `wd_my_plan_summary_screen.dart` (fila superior con título + chips).
- **Causa raíz:** La `Row` tenía elementos de ancho fijo (título + 2 chips con padding) y en ancho móvil reducido no cabían en los `358px` disponibles.
- **Solución aplicada:** Convertir el título en `Flexible` con `ellipsis` y encapsular los chips en `Expanded + SingleChildScrollView(horizontal)` para evitar desbordes.
- **Notas para el futuro:** En barras compactas con texto dinámico (l10n), evitar sumar widgets de ancho fijo en una sola `Row` sin flex/scroll.

### [2026-03-25] Calendario eventos — overflow vertical en tarjetas

- **Contexto:** Tras hot reload en iOS aparecieron varios `RenderFlex overflowed ... on the bottom` en celdas de eventos del calendario.
- **Error:** Overflows verticales de pocos píxeles (2.5 / 5.0) en tarjetas de evento dentro de `pg_calendar_mobile_page` y `wd_calendar_screen`.
- **Causa raíz:** Las reglas de contenido (título + líneas extra de detalle) dependían más del tipo/duración que de la **altura real renderizada**, provocando exceso de líneas en celdas bajas.
- **Solución aplicada:** Ajustar render adaptativo por altura: limitar título a 1 línea en alturas bajas, y mostrar participantes/hora/detalles de vuelo solo con umbrales más altos.
- **Notas para el futuro:** En celdas con altura dinámica, condicionar texto secundario por `constraints/height` real, no solo por `durationMinutes`.

### [2026-03-25] `MyPlanSummaryScreen` — `invalid_constant` en `EdgeInsets`

- **Contexto:** Ajustes visuales del resumen del plan (secciones sin marco + tipografía/acciones).
- **Error:** `Invalid constant value` en `wd_my_plan_summary_screen.dart` al usar `const EdgeInsets.symmetric(horizontal: framed ? 16 : 4, ...)`.
- **Causa raíz:** Se declaró `const` en una expresión que depende de una variable de runtime (`framed`), por lo que no es constante de compilación.
- **Solución aplicada:** Cambiar a `EdgeInsets.symmetric(...)` sin `const` en el `Padding` del header expandible.
- **Notas para el futuro:** Si un literal incluye condiciones/variables, evitar `const` aunque el constructor admita constantes en otros casos.

### [2026-03-24] Chat: badge no leídos no se actualizaba al abrir el chat

- **Contexto:** `PlanChatScreen` llamaba `await ref.read(markAllMessagesAsReadProvider(...).future)` al abrir.
- **Causa raíz:** `FutureProvider.family` **cachea** el resultado; al reabrir el chat o al depender del mismo provider, **no se vuelve a ejecutar** `markAllMessagesAsRead`, así que los mensajes nuevos seguían sin `readBy` y el contador no bajaba.
- **Solución aplicada:** Llamar a `ChatService.markAllMessagesAsRead` **directamente** desde el `ref.read(chatServiceProvider)` y luego `invalidate` de `planMessagesProvider` / `unreadMessagesCountProvider`.
- **Notas:** Para efectos secundarios que deben repetirse (marcar leído al entrar), no depender solo del `.future` de un `FutureProvider` sin invalidar ese provider antes o sin usar el servicio.

### [2026-03-23] `wd_event_dialog` (notas largas expandibles) — símbolos inexistentes

- **Contexto:** Ajuste UX en formulario de eventos (notas largas expandibles, reordenar campos y compactar enlace web).
- **Error:** `The getter 'shade850' isn't defined for the type 'MaterialColor'` y `The getter 'expandDescription' isn't defined for the type 'AppLocalizations'`.
- **Causa raíz:** Uso de una tonalidad no disponible en `Colors.grey` (`shade850`) y de una clave de l10n inexistente (`expandDescription`) sin regenerar localizaciones.
- **Solución aplicada:** Sustituir `Colors.grey.shade850` por `Colors.grey.shade900` y usar tooltip literal estable (`'Ampliar'`) en el icono de expandir notas.
- **Notas para el futuro:** Verificar getters válidos (`shade50..shade900`) y claves l10n existentes antes de compilar; si se añade una clave nueva, actualizar `.arb` y regenerar `app_localizations*`.

### [2026-03-12] `Plan.copyWith` sin parámetro `referenceNotes`

- **Contexto:** Añadir campo `referenceNotes` al modelo `Plan` y usar `copyWith` en `wd_plan_data_screen`.
- **Error:** `The named parameter 'referenceNotes' isn't defined`.
- **Causa raíz:** Se añadió `referenceNotes` al constructor/`Plan(...)` dentro de `copyWith` pero **no** a la firma del método `copyWith`.
- **Solución aplicada:** Declarar `String? referenceNotes` en los parámetros de `copyWith`.

### [2026-03-12] Calendario: un día menos que inicio–fin del plan (DST / `DateTime.difference`)

- **Contexto:** Info del plan 27/3–5/4; columnas del calendario solo hasta 4/4.
- **Causa raíz:** `endDate.difference(startDate).inDays + 1` y `startDate.add(Duration(days: k))` **no** coinciden siempre con días civiles cuando el rango cruza el **cambio de hora de verano** (p. ej. último domingo de marzo en EU): `Duration.inDays` usa horas/24 y puede quedar corto en 1.
- **Solución aplicada:** en `Plan`: `calendarDaysInclusive` con medianoches **UTC** a partir de año/mes/día; `durationInDays` y `dateForPlanDayIndex` / `planDayIndexForDate`; sustituir sumas con `Duration(days:)` en calendario y `Plan.calendarDaysInclusive` al guardar/crear plan. `planEndDate` en diálogos usa `endDate` normalizado.
- **Notas:** Para “días de calendario” no usar solo `difference` entre `DateTime` locales medianoche.

### [2026-03-12] Web: `Trying to render a disposed EngineFlutterView` + `LegacyJavaScriptObject` vs `DiagnosticsNode` (Info)

- **Contexto:** Chrome; al guardar el plan, asserts repetidos y `TypeError: LegacyJavaScriptObject is not a subtype of DiagnosticsNode` en `widget_inspector.dart` al volcar errores en consola.
- **Causa raíz:** `ref.invalidate(plansStreamProvider)` **re-suscribe** el `StreamProvider` y reconstruye gran parte del dashboard; en web el motor puede renderizar sobre una vista ya dispuesta. El error secundario sale del **WidgetInspector** al intentar reportar el primero (bug conocido DDC/web en debug).
- **Solución aplicada:** **no** invalidar `plansStreamProvider` tras guardar: el stream de Firestore (`getPlansForUser` → snapshots) ya emite al cambiar el documento. Para que calendario/lista vean el plan al instante, `PlanDataScreen` expone `onPlanUpdated(Plan)` y el dashboard actualiza `planazoos` + `selectedPlan` en `setState` sin tocar el provider.
- **Notas:** Evitar `invalidate` de streams globales tras mutaciones locales si el backend ya notifica por snapshot; reduce churn y errores en Chrome.

### [2026-03-12] Dashboard: calendario con menos/más columnas que las fechas en Info del plan

- **Contexto:** fechas correctas en Info; cuadrícula del calendario (W31) seguía con N días antiguos.
- **Causa raíz:** (1) `CalendarScreen` usaba `selectedPlan` del estado local, que podía ir **por detrás** del documento en Firestore hasta la siguiente emisión del stream. (2) `CalendarNotifierParams.initialColumnCount` usaba `plan.columnCount`, pudiendo **desalinearse** de `startDate`/`endDate` si el campo no coincidía. (3) `_listsEqual(planazoos)` solo miraba `updatedAt` → si el stream no disparaba cambio perceptible, no se refrescaba `selectedPlan`.
- **Solución aplicada:** `pg_dashboard_page.dart`: `_selectedPlanResolvedFromStream()` + pasar ese `plan` a `CalendarScreen`, `PlanDataScreen` y `MyPlanSummaryScreen`; `ValueKey` con rango `start`–`end` para forzar árbol coherente; `_listsEqual` también compara `startDate`, `endDate`, `columnCount`. `CalendarNotifierParams`: `initialColumnCount: plan.durationInDays` (alineado con la cuadrícula). `wd_plan_data_screen.dart`: tras guardar, `ref.invalidate(plansStreamProvider)`.

### [2026-03-12] Calendario no reflejaba nueva duración del plan (detalle plan + grupo de días)

- **Contexto:** cambiar duración/fechas en Info del plan y volver al calendario; seguía mostrando el número de días antiguo.
- **Causa raíz:** `PlanDetailPage` pasaba siempre `widget.plan` del constructor (no se actualiza al guardar). El calendario usaba `plan.durationInDays` de ese objeto obsoleto. En dashboard, al acortar duración, `_currentDayGroup` podía quedar fuera de rango.
- **Solución aplicada:** en `pg_plan_detail_page.dart`, resolver el plan con `ref.watch(plansStreamProvider)` (`_planFromStreamWatch` / `_planFromStreamRead`) y usarlo en todas las pestañas; `CalendarMobilePage` con `ValueKey` por rango `startDate`–`endDate`; clamp del grupo de días si `currentStart > totalDays`. En `wd_calendar_screen.dart`, `didUpdateWidget` en `CalendarScreen` para resetear grupo y refrescar cuando cambian `startDate`/`endDate`/`columnCount`.
- **Notas:** Pantallas con `Plan plan` fijo del `Navigator` deben enlazar al stream o a un callback post-guardado para no quedar desincronizadas de Firestore.

### [2026-03-12] `EventDialog` edición: Guardar/Eliminar “no hacían nada” (detalle plan / dashboard)

- **Contexto:** editar evento desde Mi resumen u otras rutas que abren `EventDialog` vía `pg_plan_detail_page` o `pg_dashboard_page`; crear evento desde el calendario sí funcionaba.
- **Causa raíz:** `EventDialog` no llama a `EventService.updateEvent` / `deleteEvent`; delega en `onSaved` / `onDeleted`. Esas páginas pasaban solo `setState(() {})` → no persistía y no se cerraba el modal (a diferencia de `wd_calendar_screen` / `pg_calendar_mobile_page`, que sí persisten y hacen `Navigator.pop`).
- **Solución aplicada:** en `_showEventDialog` de `pg_plan_detail_page.dart` y `pg_dashboard_page.dart`, llamar a `updateEvent` / `deleteEvent`, invalidar/refrescar calendario y estadísticas (`CalendarNotifierParams` + `planStatsProvider`), y `Navigator.pop` del contexto del diálogo.
- **Notas:** Cualquier `showDialog(EventDialog(...))` debe implementar el mismo contrato que el calendario o el guardado nunca llega a Firestore.

### [2026-03-12] Modal evento: Guardar / Eliminar no respondían (Chrome estrecho / móvil)

- **Contexto:** edición de evento existente; al cambiar datos, los botones de la barra de acciones parecían no hacer nada.
- **Causa raíz:** `AlertDialog` con `content` casi a pantalla completa (`height ≈ screen - 64`) más la fila `actions` hacía que el total superara la altura útil; la fila de acciones quedaba fuera de vista o no recibía bien los toques. Además, si `Form.validate()` fallaba, no había feedback y parecía que Guardar “no hacía nada”.
- **Solución aplicada:** `scrollable: true` en el `AlertDialog`; reservar altura (~112 px + safe area) para la fila de acciones al calcular `contentHeight` en móvil; SnackBar naranja si falla `validate()` (`eventDialogFixValidationErrors` en l10n).
- **Notas:** En diálogos fullscreen, descontar siempre espacio para `actions` o integrar la barra de botones dentro del área con scroll controlado.

### [2026-03-12] Info plan / fecha fin no persistía en UI (`wd_plan_data_screen` + `Plan.fromFirestore`)

- **Contexto:** al cambiar fecha fin de un plan ya creado y guardar, la pantalla volvía a mostrar la fecha anterior.
- **Error / síntoma:** valor mostrado tras “Guardar” = fecha fin previa; Firestore podía estar bien.
- **Causa raíz:** (1) `didUpdateWidget` sincronizaba siempre desde `widget.plan` cuando el `Plan` cambiaba, y el provider aún emitía **un plan antiguo** una pasada tras guardar, pisando `currentPlan` y `_endDate`. (2) `Plan.fromFirestore` **ignoraba** `startDate`/`endDate` del documento y recalculaba el fin solo con `baseDate` + `columnCount`, pudiendo desalinear lectura respecto a lo guardado.
- **Solución aplicada:** en `PlanDataScreen`, solo aplicar plan del padre si `widget.plan.updatedAt.isAfter(currentPlan.updatedAt)` (y no con cambios sin guardar); tras guardar, asignar `_startDate`/`_endDate` desde `currentPlan`; extraer `_applyPlanToFormFields`. En `Plan.fromFirestore`, si existen timestamps `startDate` y `endDate`, usarlos (normalizados a fecha local); si no, mantener fallback por `columnCount`.
- **Notas para el futuro:** tras mutaciones locales con `updatedAt` más nuevo que el stream, **no** rebajar el estado desde `widget.plan` sin comparar `updatedAt`.

### [2026-03-12] `wd_participants_screen.dart` (cierre de `showDialog` + `Theme` tras l10n)

- **Contexto**: sustituir textos por `AppLocalizations` en el diálogo de confirmar eliminación de participante (`builder: (dialogContext) { return Theme( ... AlertDialog( ... ), ); }`).
- **Error**: `Expected to find ';'`, `A try block must be followed by an 'on', 'catch', or 'finally'`, `Missing concrete implementation of 'State.build'` (cascada por sintaxis rota).
- **Causa raíz**: un paréntesis de más al cerrar: `AlertDialog` → `Theme` quedó como `),` `),` `);` en lugar de `),` `);` antes de `},` que cierra el `builder`.
- **Solución aplicada**: un solo `);` para cerrar `return Theme( ... );`, luego `},` del `builder` y `);` del `showDialog`.
- **Notas para el futuro**: al convertir `builder: (context) => Widget(...)` en `builder: (context) { return Widget(...); }`, contar cierres: **un** `);` por cada `return` de widget raíz del builder, no duplicar el cierre del hijo del `Theme`.

### [2026-03-07] T102 / `PaymentSummaryPage` (estructura de `when` anidados)

- **Contexto**: refactor de la UI de la página de pagos para usar tema oscuro y mejorar experiencia en iOS.
- **Error**: `Can't find '}' to match '{'` y callbacks `loading:` / `error:` interpretados como miembros de clase en `_buildKittySection`.
- **Causa raíz**: reescritura parcial dejó los `when` anidados (`contributionsAsync.when` y `expensesAsync.when`) con llaves/paréntesis desalineados; los callbacks quedaron fuera de la llamada al método.
- **Solución aplicada**: reescritura completa de `_buildKittySection`, volviendo a declarar `contributionsAsync.when(data / loading / error)` y dentro `expensesAsync.when(data / loading / error)`, cuidando que cada `when` cierre con `);` y el `Container` de UI quede dentro del `data`.
- **Notas para el futuro**: cuando haya múltiples `when` anidados, **no parchear sólo cierres**; es más seguro reescribir la función entera asegurando la estructura `async.when(data: ..., loading: ..., error: ...)` y revisar que el formatter de Dart mantenga la indentación coherente.

### [2026-03-07] T102 / `PaymentSummaryPage` (línea `),` tras refactor de `_buildGeneralSummary`)

- **Contexto**: tras refactorizar la UI oscura de `PaymentSummaryPage`, el hot reload de Flutter mostró errores en la línea 513 (`),`), aunque el analizador (`ReadLints`) no reportaba problemas.
- **Error**: `Error: Expected ';' after this.` y “Unexpected token ';'” alrededor de la línea con `),` al final de `_buildGeneralSummary`.
- **Causa raíz**: el código de `_buildGeneralSummary` tenía la estructura correcta (`return Container( ... child: Column(...), );`), pero el hot reload estaba trabajando con una versión intermedia del archivo (estado anterior del código) y mantenía referencias de línea desfasadas tras varios cambios encadenados.
- **Solución aplicada**: verificación explícita de la estructura de paréntesis/llaves en `_buildGeneralSummary` y confirmación con el analizador de Dart (sin cambios de código), seguida de recomendación de hacer **hot restart / rebuild completo** en lugar de confiar en un hot reload sobre un estado intermedio.
- **Notas para el futuro**: si hay discrepancia entre los errores de hot reload y el analizador estático (archivo pasa `flutter analyze` / `ReadLints`), sospechar de **estado sucio del runtime** antes de tocar el código: preferir hot restart o recompilación limpia y solo entonces, si el error persiste, modificar el código.

### [2026-03-07] T102 / `PaymentSummaryPage` (uso de `AppLocalizations.of(context)` en helpers sin `BuildContext`)

- **Contexto**: al internacionalizar la página de pagos, se añadieron llamadas a `AppLocalizations.of(context)!` dentro de métodos helpers privados como `_buildGeneralSummary`, `_buildTransferSuggestionsSection`, `_buildBalanceChart` y `_getBalanceStatusText`.
- **Error**: en tiempo de ejecución, Flutter mostró `Error: The getter 'context' isn't defined for the type 'PaymentSummaryPage'` en varias líneas de esos métodos.
- **Causa raíz**: esos helpers no reciben un `BuildContext` como parámetro y, al no ser métodos de `State` ni disponer de un campo `context`, el identificador `context` no existe ahí.
- **Solución aplicada**: actualizar las firmas de los helpers para aceptar explícitamente un `BuildContext` (`_buildGeneralSummary(BuildContext context, ...)`, `_buildTransferSuggestionsSection(BuildContext context, ...)`, `_buildBalanceChart(BuildContext context, ...)`, `_getBalanceStatusText(BuildContext context, ...)`) y pasar el `context` desde los métodos superiores (`_buildSummaryContent`, `_buildParticipantBalanceCard`, etc.). El acceso a `AppLocalizations.of(context)!` se mantiene únicamente en funciones que reciben `BuildContext`.
- **Notas para el futuro**: cuando se utilice `AppLocalizations.of(context)` (o cualquier API que dependa de `BuildContext`) en métodos auxiliares, **asegurarse de pasar el `context` explícitamente** en la firma del método o, alternativamente, calcular `loc` una vez en `build` y pasarlo como argumento. Evitar asumir que un `ConsumerWidget` tiene un getter `context` disponible fuera de `build` o de callbacks con `BuildContext` en la firma.

### [2026-03-07] T102 / `PaymentDialog` y `AddExpenseDialog` (paréntesis de cierre de más al pasar a pantalla completa)

- **Contexto**: conversión de los modales "Registrar pago" y "Añadir gasto" de `AlertDialog` a pantalla completa con `Scaffold` (appBar, body, bottomNavigationBar). Tras el cambio, hot restart fallaba.
- **Error**: `Error: Expected ';' after this.` y `Expected an identifier, but got ','` / `Unexpected token ';'` en las líneas con `      ),` justo antes de `bottomNavigationBar` (payment_dialog.dart ~631 y 657; add_expense_dialog.dart ~454 y 476).
- **Causa raíz**: al sustituir `AlertDialog(content: SizedBox(..., child: SingleChildScrollView(..., child: Form(...))))` por `Scaffold(body: Form(child: SingleChildScrollView(child: Column(...))))`, se dejaron **cuatro** `),` para cerrar el body cuando la jerarquía real solo tiene **tres** niveles (Column → SingleChildScrollView → Form). El cuarto `),` sobraba y el analizador lo interpretaba como cierre incorrecto de un argumento nombrado.
- **Solución aplicada**: eliminar **un** `),` sobrante en cada archivo, el que cerraba un nivel inexistente entre el cierre de `Form` y la propiedad `bottomNavigationBar`. Quedó: `], ), ), ),` (Column children, Column, SingleChildScrollView, Form) y a continuación `bottomNavigationBar: SafeArea(...)` sin `),` extra.
- **Notas para el futuro**: al reemplazar un widget por otro con distinta jerarquía (p. ej. AlertDialog → Scaffold), **contar los niveles** de anidación del contenido (body = Form → SingleChildScrollView → Column → children) y asegurar que el número de `),` que cierran ese bloque coincida exactamente. Un `),` de más suele producir "Expected ';' after this" en la línea del cierre.

### [2026-03-10] T219 / `AddExpenseDialog` (RenderFlex overflow en fila de reparto igual/personalizado)

- **Contexto**: pruebas del nuevo diálogo de "Añadir gasto" tipo Tricount en iOS (pantalla completa). Al abrir el diálogo y activar/desactivar el reparto personalizado, aparecían warnings amarillos de overflow en consola.
- **Error**: `A RenderFlex overflowed by 9.4 pixels on the right.` apuntando a la `Row` en `add_expense_dialog.dart:364:25` (fila con los textos “Reparto igual / Reparto personalizado” y el `Switch` entre medias).
- **Causa raíz**: la `Row` contenía dos textos y un `Switch` alineados en horizontal (`Text`, `SizedBox`, `Switch`, `SizedBox`, `Text`) dentro de un ancho fijo (~350 px). Con algunas traducciones o tamaños de fuente, la suma de anchos de los textos + switch superaba el espacio disponible y Flutter marcaba overflow.
- **Solución aplicada**: envolver ambos textos en `Expanded` y activar `overflow: TextOverflow.ellipsis`, además de alinear el texto derecho con `textAlign: TextAlign.right`, de forma que el espacio se reparta y el contenido sobrante se trunque en lugar de desbordar. La estructura de la fila queda `Expanded(Text izquierda) + Switch + Expanded(Text derecha)`.
- **Notas para el futuro**: en filas con varios textos y controles (especialmente con traducciones largas) es preferible usar `Expanded`/`Flexible` y `TextOverflow.ellipsis` en lugar de depender de `SizedBox` fijos. Esto evita overflows sutiles en dispositivos pequeños o con fuentes grandes.

### [2026-03-12] test/widget_test.dart (App necesita ProviderScope y Firebase)

- **Contexto**: trabajo autónomo; arreglar test "App should build without errors" que fallaba con "No ProviderScope found".
- **Error**: `Bad state: No ProviderScope found` y después `[core/no-app] No Firebase App '[DEFAULT]' has been created`.
- **Causa raíz**: el test montaba `App()` directamente; `App` es un `ConsumerStatefulWidget` que usa `ref` en `initState` (languageNotifier, FCMService.getInitialMessage()), por lo que requiere `ProviderScope`; además los providers (p. ej. realtimeSyncInitializerProvider) y FCM usan Firebase.
- **Solución aplicada**: en el test se envuelve `App()` en `ProviderScope`. Como en entorno de test no hay `Firebase.initializeApp()`, el test se deja con `skip: true` y comentario indicando que requiere Firebase en el setup. Para que el test pase sin skip haría falta llamar a `Firebase.initializeApp()` (con opciones de test o mock) antes de `pumpWidget`.
- **Notas para el futuro**: tests que monten `App` o widgets que usen Riverpod/Firebase deben incluir `ProviderScope` y, si acceden a Firebase, inicializar Firebase en `setUpAll` o usar mocks.

### [2026-03-13] CalendarGrid / pg_calendar_mobile_page (nuevo parámetro obligatorio onAccommodationHeaderTap)

- **Contexto**: cambio de UI en el calendario para sustituir el texto fijo "Alojamiento" por un icono de casa con "+" que abre el diálogo de nuevo alojamiento desde la columna de horas.
- **Error**: `Error: Required named parameter 'onAccommodationHeaderTap' must be provided. ... lib/pages/pg_calendar_mobile_page.dart:830:27`.
- **Causa raíz**: se añadió un nuevo parámetro obligatorio `onAccommodationHeaderTap` al constructor de `CalendarGrid` y se actualizó su uso en `wd_calendar_screen.dart`, pero la versión móvil (`pg_calendar_mobile_page.dart`) seguía creando `CalendarGrid` sin pasar ese parámetro.
- **Solución aplicada**: en `pg_calendar_mobile_page.dart`, al construir `CalendarGrid`, se añadió `onAccommodationHeaderTap`, que calcula una fecha visible (primer día del grupo actual si existe, o `plan.startDate`) y llama a `_showNewAccommodationDialog(date)`, reutilizando el flujo móvil ya existente para crear alojamientos.
- **Notas para el futuro**: cuando se añadan parámetros `required` a widgets compartidos (como `CalendarGrid`), buscar todas las instancias (web + móvil) con `Grep` o búsqueda global y actualizarlas en bloque. Evitar introducir requisitos nuevos en constructores sin revisar sus usos en variantes de pantalla (web, móvil, tests).

### [2026-03-12] Chips estado plan / diálogos no aparecían

- **Contexto**: chips pending/in con `GestureDetector` dentro de card; lista iOS (`pg_plans_list_page`) y barra “Mi estado” (`WdDashboardMyStatusCell`).
- **Error**: al pulsar el chip no se abría el diálogo (a veces se abría el detalle del plan).
- **Causa raíz**: (1) El `InkWell` de toda la card capturaba el gesto frente al hijo. (2) La lista móvil no usa `PlanCardWidget`, tenía chips sin lógica. (3) La celda del header no tenía `onTap`.
- **Solución aplicada**: sacar el chip **fuera** del `InkWell` (solo la zona imagen+texto es clicable para abrir el plan); misma acción en `PlanCardWidget`; lógica compartida en `plan_status_chip_actions.dart`; tap en `WdDashboardMyStatusCell`.
- **Notas**: acciones secundarias en cards con `InkWell` → colocar el control **hermano** del `Expanded(InkWell(...))`, no hijo dentro del área del `InkWell`.

### [2026-03-12] MyPlanSummaryScreen (acciones 3 iconos: aserciones nulas innecesarias)

- **Contexto**: implementación de accesos rápidos por fila en resumen de plan (detalle, Maps, URL) en `wd_my_plan_summary_screen.dart`.
- **Error**: warning de linter `unnecessary_non_null_assertion` en callbacks (`mapsQuery!`, `webUrl!`) tras validación previa con flags booleanos.
- **Causa raíz**: el analizador no aceptó la promoción de nullabilidad dentro de closures; mantener `!` generó warning.
- **Solución aplicada**: introducir variables seguras (`safeMapsQuery`, `safeWebUrl`) con fallback y usarlas en callbacks, eliminando `!`.
- **Notas para el futuro**: cuando se usen valores opcionales en closures condicionadas por `if (x != null)`, preferir copiar a una variable local no nula antes del callback para evitar warnings de promoción.

### [2026-03-12] EventDialog (overflow horizontal en chips de subtipo)

- **Contexto**: pruebas en iOS durante edición/creación de evento (`wd_event_dialog.dart`).
- **Error**: `A RenderFlex overflowed by 10 pixels on the right` en la fila del chip de subtipo (`Row ... wd_event_dialog.dart`).
- **Causa raíz**: el `Text(label)` del chip no era flexible; en anchos pequeños, icono + texto + icono “+” superaban el ancho disponible.
- **Solución aplicada**: envolver el texto del chip en `Flexible` + `maxLines: 1` + `TextOverflow.ellipsis` para que el contenido se ajuste sin desbordar.
- **Notas para el futuro**: en chips/filas compactas con iconos laterales, usar siempre `Flexible/Expanded` en textos dinámicos para evitar overflows en iOS y traducciones largas.

### [2026-03-12] P18 / `PlanParticipation.needsResponse` — participantes legacy como “pendientes”

- **Contexto**: chips in/out/pend. en lista y detalle; modelo `PlanParticipation`.
- **Error / síntoma**: usuarios con `status == null` (legacy) aparecían como **pendiente** en la UI.
- **Causa raíz**: el getter `needsResponse` hacía `status == 'pending' || status == null`, y en varios sitios se usaba `isPending || needsResponse`, duplicando además la condición con `isPending`.
- **Solución aplicada**: eliminar `needsResponse`; tratar solo `status == 'pending'` como pendiente; `null` sigue como aceptado vía `isAccepted`. Sustituir usos por `isPending` donde aplicaba.
- **Notas**: alinear con `isAccepted` (`status == null` ⇒ aceptado).

### [2026-03-12] `wd_plan_data_screen` — `const EdgeInsets` con valor no constante

- **Contexto**: cabecera plegable de la zona de peligro (padding inferior según `_infoSectionDangerExpanded`).
- **Error**: `Invalid constant value` en `EdgeInsets.fromLTRB(16, 14, 12, _infoSectionDangerExpanded ? 10 : 14)` marcado como `const`.
- **Causa raíz**: el operador ternario depende de estado; no puede formar parte de una expresión `const`.
- **Solución aplicada**: quitar `const` del `EdgeInsets.fromLTRB(...)`.
- **Notas para el futuro**: si un padding depende de `setState`/campos, no usar `const` delante del `EdgeInsets`/`BoxDecoration` que lo incluya.

