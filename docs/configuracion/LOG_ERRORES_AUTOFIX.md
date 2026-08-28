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

### [2026-08-27] Participantes — invitar por email: modal no cierra, usuario parpadea y error

- **Contexto:** T259 / dominio #1; enviar invitación por mail desde Participantes.
- **Síntoma:** Modal no se cierra; el invitado aparece un instante en la lista y desaparece; mensaje tipo «no se pudo crear/enviar la invitación».
- **Causa raíz probable:** (1) `createInvitation` tragaba `permission-denied` y devolvía `null` sin detalle. (2) Cancelar pending (`status: cancelled`) exigía `createdAt`/`expiresAt` iguales en rules → fallos al reinvitar. (3) Orden participación→invitación: la participación hacía flicker en el stream si el create de invitación fallaba después. (4) Limpieza de notifs del invitado no era queryable por el owner.
- **Solución aplicada:** rules cancel sin Timestamp==; `cancelled` en validación; owner puede leer/borrar notifs `invitation` (query `planId`+`type`); `createInvitation` comprueba organizador, crea doc invitación primero, propaga el error real; índice notifications planId+type.
- **Notas:** Solo `plans.userId` (o admin) puede crear invitaciones. Hot restart tras el cambio de servicio; rules ya desplegadas.

### [2026-08-27] Invitación — falso error al aceptar + enlace «Ver el plan» en el mail

- **Contexto:** Tras invitar OK, al abrir mail con `?action=accept` salía un momento «no se pudo aceptar» y luego el plan sí quedaba aceptado.
- **Causa raíz:** Race en accept (createParticipation devolvía null / UI mostraba fallo aunque la membresía ya era `accepted`); en web al abrir no reintentaba leer el plan.
- **Solución:** accept idempotente (re-check participación); UI no muestra error si ya `accepted`; `_openPlanAfterAccept` reintenta y abre `PlanDetailPage` también en web; email CF con botón «Ver el plan».
- **Notas:** Redeploy `sendInvitationEmail` para mails nuevos.

### [2026-08-27] AccommodationDialog — `invalid_constant` con `IosFormColors.accent`

- **Contexto:** Chip «abrir enlace» en campo URL (alojamiento).
- **Error:** `Invalid constant value` en `const SizedBox` / `Icon(color: IosFormColors.accent)`.
- **Causa raíz:** `IosFormColors.accent` es getter (no `const`); no puede usarse dentro de un subtree `const`.
- **Solución aplicada:** quitar `const` del `SizedBox`/`Icon`.
- **Notas:** No marcar `const` widgets que usen `IosFormColors.accent` / `AppColorScheme.color2`.

### [2026-08-26] EventDialog — ListTile ink bajo ColoredBox negro (pageBg)

- **Contexto:** Abrir ficha evento; assert `ListTile background color or ink splashes may be invisible` con `ColoredBox(color: #000000)`.
- **Causa raíz:** El contenido del diálogo usaba `ColoredBox(pageBg)` entre el `Material` del `AlertDialog` y `CheckboxListTile` (participantes / para todos).
- **Solución aplicada:** `ColoredBox` → `Material(color: pageBg)` en evento y alojamiento; `Material(transparent)` alrededor de los `CheckboxListTile` de participantes.
- **Notas:** No poner `ListTile` bajo `ColoredBox`/`DecoratedBox` opaco; el ancestro de ink debe ser `Material`.

### [2026-08-26] Adjuntos iOS — `documentPickerWasCancelled` / snackbar falso de lectura

- **Contexto:** Subir PDF/JPG desde ficha de evento/alojamiento en dispositivo (`flutter run`); en web sí funcionaba.
- **Error:** `***** FilePicker canceled` / `-[FilePickerPlugin documentPickerWasCancelled:]` y UI mostraba «No se pudo leer el archivo».
- **Causa raíz:** (1) `null` del picker (= cancelación o dismiss) se trataba como fallo de lectura. (2) En iOS, abrir el picker sin esperar a que el teclado/diálogo asiente y con `withData: true` es frágil; en debug, ir a Files en segundo plano corta la sesión y cancela el picker.
- **Solución aplicada:** En `plan_file_picker_io.dart`: unfocus + delay 350ms, `withData: false` + lectura por `path`, `null` = cancel silencioso, `PlanFilePickReadException` solo si hubo fichero ilegible. Callers evento/alojamiento/plan Info alineados.
- **Notas:** Si falla solo en `flutter run` al salir a Files, probar hot restart o profile/release; no mostrar error de lectura cuando el usuario cancela.

### [2026-08-26] IosGroupedCard — ListTile ink invisible bajo DecoratedBox

- **Contexto:** Abrir ficha evento tras migración Settings-only (`CheckboxListTile` “para todos”, etc.).
- **Error:** `ListTile background color or ink splashes may be invisible` + `DecoratedBox(bg: #1C1C1E)`.
- **Causa raíz:** `IosGroupedCard` era `Container`+`BoxDecoration` opaco; el ink del ListTile se pinta en el Material ancestro y la caja lo tapa.
- **Solución aplicada:** `IosGroupedCard` → `Material(color: groupedBg, borderRadius: 12, clipBehavior: antiAlias)`.
- **Notas:** No meter `ListTile`/`CheckboxListTile` bajo `DecoratedBox` con color; preferir `Material` en la card agrupada.

### [2026-08-21] EventDialog web — no abre (RenderViewport / intrinsic)

- **Contexto:** Abrir evento existente en Chrome tras UX D (vista ListView).
- **Error:** `RenderViewport does not support returning intrinsic dimensions` en `AlertDialog` (`wd_event_dialog.dart`).
- **Causa raíz:** `scrollable: true` + altura nula en desktop → `IntrinsicWidth` mide un `ListView`/`Expanded` de la vista D.
- **Solución aplicada:** `scrollable: false`; altura fija en web (~420–640); `MainAxisSize.max`; edición desktop con `Expanded` (no `SizedBox(540)`). Mismo patrón de altura en alojamiento.
- **Notas:** No poner `ListView` dentro de `AlertDialog(scrollable: true)` sin bounds.

### [2026-08-19] Confirmaciones de evento omitían al organizador

- **Contexto:** T278 `saveEvent` + `requiresConfirmation` en un plan con solo organizador.
- **Error:** 0 docs en `event_participants` con `confirmationStatus: pending`.
- **Causa raíz:** `createPendingConfirmationsForAllParticipants` usaba `getPlanParticipants`, que filtra `role == participant` y excluye al organizador.
- **Solución aplicada:** unir `getPlanOrganizers` + `getPlanParticipants`.
- **Notas:** “Todos los participantes del plan” incluye al organizador.

### [2026-08-19] Tests saveEvent — EventParticipantService usa Firebase.instance

- **Contexto:** T278 fase 2, `saveEvent` con `requiresConfirmation` en Firestore falso.
- **Error:** Riesgo `[core/no-app]` al crear confirmaciones pendientes.
- **Causa raíz:** `saveEvent` construía `EventParticipantService()` sin el Firestore inyectado.
- **Solución aplicada:** usar `_eventParticipantService` (mismo fake que el resto del servicio).
- **Notas:** Mismo patrón que PaymentService / PlanService: no instanciar colaboradores con `FirebaseFirestore.instance` en código que corren los tests.

### [2026-08-18] Tests createEvent — PaymentService usa Firebase.instance

- **Contexto:** T278 `event_service_crud_test` con `FakeFirebaseFirestore`.
- **Error:** Riesgo `[core/no-app]` al crear evento: `GuaranteePaymentSync` construye `PaymentService()`, cuyo campo era `FirebaseFirestore.instance`.
- **Causa raíz:** `PaymentService` no inyectaba Firestore.
- **Solución aplicada:** `PaymentService({firestore})`; `EventService` pasa el mismo fake a `GuaranteePaymentSync`.
- **Notas:** Misma pauta que PlanService: no tocar `FirebaseFirestore.instance` en el constructor de colaboradores usados en tests.

### [2026-08-18] Tests widget — firma de testWidgets perdida al editar

- **Contexto:** T277 P18 `plan_state_ui_test.dart`.
- **Error:** `Expected a declaration, but got ')'` / `Undefined name 'tester'` / `await can only be used in async`.
- **Causa raíz:** Un StrReplace recortó `testWidgets('…', (tester) async {` y dejó el cuerpo del test suelto en el `group`.
- **Solución aplicada:** Reescribir el archivo; extraer `_pumpConfirmDialog` para no duplicar el pump.
- **Notas:** Al editar tests widget, comprobar que cada bloque sigue dentro de `testWidgets(..., (tester) async {`.

### [2026-08-18] Tests widget — const UserModel + DateTime

- **Contexto:** T277 `wd_create_plan_modal_test`.
- **Error:** `Cannot invoke a non-'const' constructor where a const expression is expected` en `DateTime(2026, 1, 1)`.
- **Causa raíz:** `const UserModel(...)` exige que todos los argumentos sean const; `DateTime(...)` no lo es.
- **Solución aplicada:** quitar `const` del `UserModel` de prueba.
- **Notas:** Fixtures de usuario/plan en tests: no marcar `const` si llevan `DateTime`.

### [2026-08-18] Tests createPlan — No Firebase App DEFAULT

- **Contexto:** T277 `plan_service_create_test` con `FakeFirebaseFirestore`.
- **Error:** `[core/no-app] No Firebase App '[DEFAULT]' has been created` al construir `PlanService`.
- **Causa raíz:** Campos que instancian `EventParticipantService` / `InvitationService` / `PermissionService` en el constructor, y esos servicios llaman `FirebaseFirestore.instance`.
- **Solución aplicada:** Inyección de `firestore` + getters perezosos para servicios que `createPlan` no usa.
- **Notas:** En tests de servicio, no construir colaboradores que toquen `FirebaseFirestore.instance` hasta que el método bajo prueba los necesite.

### [2026-08-11] iPhone — rechazar invitación permission-denied

- **Contexto:** UA rechaza pending en dispositivo; log `rejectInvitationByPlanId` + `cloud_firestore/permission-denied`.
- **Causa raíz:** Reject actualizaba `plan_invitations` solo en cliente (rules email/token); accept ya usaba CF Admin SDK. Además `rejectInvitation` hacía `update(toFirestore())` completo en participación.
- **Solución:** CF `markInvitationRejected` (token o planId); cliente la llama al rechazar; fallback cliente; participación solo `status`+`lastActiveAt`.
- **Notas:** Tras cambiar CF: `firebase deploy --only functions:markInvitationRejected` (o functions).

### [2026-08-11] iPhone — aceptar invitación no refresca UI (UA)

- **Contexto:** UA acepta en iPhone; UC (web) ve a UA dentro; UA sigue viendo pending aunque mate la app.
- **Causa raíz:** (1) Si `markInvitationAccepted` CF falla, el doc `plan_invitations` queda `pending` y `getPendingInvitationsByUserId` lo volvía a listar al no haber participaciones pending. (2) El modal no invalidaba `plansStream` / participaciones / campana.
- **Solución:** excluir planes ya `accepted` al listar invitaciones; fallback cliente a marcar invitation accepted; invalidar providers tras aceptar/rechazar.
- **Notas:** Pending UI debe basarse en participación aceptada, no solo en invitation doc.

- **Contexto:** `flutter run -d chrome`; lista de planes; paint exception.
- **Error:** `A borderRadius can only be given on borders with uniform colors` en `wd_plan_card_widget.dart`.
- **Causa raíz:** `BoxDecoration` con `borderRadius` y `Border` con `top` (naranja) y `bottom` (blanco alpha) de colores distintos.
- **Solución aplicada:** borde uniforme (`Border.all`) + franja superior de 2px dentro del `Column` cuando hay pending; `clipBehavior: Clip.antiAlias`.
- **Notas:** En Flutter, `borderRadius` exige lados del `Border` con el mismo color; para acentos por lado usar stack/franja, no Border asimétrico.

- **Contexto:** Formulario de evento → Notas → Ampliar → Cancelar.
- **Error:** `Assertion failed: ... framework.dart ... _dependents.isEmpty is not true`.
- **Causa raíz:** En `_openLongNotesEditor` se hacía `tempController.dispose()` justo al cerrar el diálogo, mientras el `TextFormField` del route aún se desmontaba y seguía escuchando el controller.
- **Solución aplicada:** disponer el controller en `addPostFrameCallback` tras el `showDialog`; mismo patrón en notas de reserva/cancelación.
- **Notas:** Nunca disponer un `TextEditingController` temporal de un diálogo en el mismo tick en que hace pop; esperar al menos un frame.

### [2026-08-08] Login — username mutaba a cristianclaraso6, 7, …

- **Contexto:** Login web; usuario con `@cristianclaraso` veía en Firestore `@cristianclarasoN` que subía con las pruebas.
- **Causa raíz:** Si `getUser` fallaba/timeout (3s), el fallback Auth (`username: null`) generaba un username nuevo. `_findAvailableUsername` no excluía al propio `userId`, así el lookup propio hacía “ocupado” el base y añadía 1…N. Luego `createUser` (doc existente) + `updateUser` sobrescribían el perfil. Login por email o lookup viejo de `cristianclaraso` seguía funcionando.
- **Solución:** timeout 8s; fallback releer perfil antes de generar; `createUser` no toca lookups si el doc existe; `updateUser` no escribe `username` null ni `createdAt`; `_findAvailableUsername` con `excludeUserId`.
- **Notas:** En Firestore, restaurar a mano `username`/`usernameLower` a `cristianclaraso` y limpiar lookups basura `cristianclarasoN` si hace falta.

### [2026-08-08] T272 — guardar colores del plan fallaba sin detalle en terminal

- **Contexto:** Info del plan → Colores del calendario; snackbar «No se pudieron guardar los cambios».
- **Error:** `updatePlan` devolvía `false` (permission-denied típico); LoggerService no siempre se ve en la consola de `flutter run`.
- **Causa raíz:** `update(toFirestore())` reescribía `createdAt`; las rules exigen `request.resource.data.createdAt == resource.data.createdAt` y el round-trip DateTime↔Timestamp puede romper la igualdad.
- **Solución aplicada:** `PlanService.updateEventAccentColors` (solo base + mapa + `updatedAt`); `updatePlan` ya no reenvía `createdAt`.
- **Notas:** Preferir updates parciales en campos nuevos; no tocar `createdAt` en updates de plan.

### [2026-07-30] Invitaciones — borrar avisos al decidir + push al organizador

- **Contexto:** T269 parcial / decisiones §1.1 (3 y 5) del diagrama altas-bajas.
- **Problema:** Al aceptar/rechazar no se borraban notifs `invitation`; organizador solo recibía in-app (sin push); accept no validaba estado del plan.
- **Solución aplicada:** `deleteInvitationNotificationsForPlan`; cleanup en `accept/rejectInvitationByPlanId`; validación `canAddParticipants` + mensajes; `expirePendingInvitation`; push vía `sendPushNotification` en `notifyInvitationResponded`; `InvitationRespondResult` en UI.
- **Notas:** Pendiente del T269 completo: buzón Mis invitaciones, email al registrado, modal al abrir app, dedupe reenvío.

### [2026-07-27] Login iPhone — RenderFlex overflow 29px (Row ayuda / UI Review)

- **Contexto:** `login_page.dart` en simulador/iPhone estrecho (~294px de ancho útil).
- **Error:** `A RenderFlex overflowed by 29 pixels on the right` en `Row` (línea ~201).
- **Causa raíz:** Dos `TextButton.icon` en un `Row` sin flex; el texto localizado + “UI Review Hub” no cabe en horizontal.
- **Solución aplicada:** Sustituir `Row` por `Wrap` centrado para que pasen a segunda línea si hace falta.
- **Notas para el futuro:** En login/register móvil, preferir `Wrap`/`Flexible` frente a `Row` con textos largos.

### [2026-07-27] Registro iPhone — botón Guardar/Registrar “no hace nada”

- **Contexto:** Alta de usuario nuevo en iPhone (`RegisterPage`).
- **Error:** El botón parece activo pero no responde / no hay feedback de carga.
- **Causa raíz:** (1) `onPressed` era `null` si faltaban términos o el form no pasaba `_isFormValid()`; el contenedor seguía en verde pleno → sensación de botón roto. (2) `registerWithEmailAndPassword` ponía `status: loading` **sin** `isLoading: true`, así que no se mostraba el spinner.
- **Solución aplicada:** Botón siempre tappable (salvo loading); si inválido, valida y muestra errores/snackbar. Estilo atenuado si no se puede enviar. Al registrar: `isLoading: true`. Cerrar teclado al enviar.
- **Notas para el futuro:** En móvil, preferir feedback al tap frente a `onPressed: null` silencioso; alinear `AuthStatus.loading` con `isLoading: true`.

### [2026-07-26] Push iOS — FCM OK (1/1) pero sin banner en dispositivo

- **Contexto:** Tras desplegar `sendInvitationPush`; logs: `enviados 1/1` a Matilde; campana OK; iOS sin banner.
- **Hallazgos:** Token existe; CF y Admin SDK aceptan el mensaje. Posible mismatch `aps-environment=development` en Release/TestFlight + payload APNs incompleto.
- **Solución aplicada:** Payload APNs `alert` + `apns-priority/push-type`; Release/Profile → `RunnerRelease.entitlements` (`production`); push title sin emoji; log del result de la CF.
- **Prueba:** Reinstalar/abrir app iOS (para refrescar token según entorno), app en **segundo plano**, re-invitar. Comprobar “Invitacion de prueba Planazoo” enviada en diagnóstico.

### [2026-07-26] Push iOS invitación — CF `sendInvitationPush` no desplegada

- **Contexto:** Campana in-app OK tras fix de rules; push iOS no llega.
- **Causa raíz:** Cliente llama `httpsCallable('sendInvitationPush')` pero la función no estaba en el proyecto (solo `sendPushNotification`). Logs CF vacíos.
- **Solución aplicada:** `firebase deploy --only functions:sendInvitationPush`.
- **Notas:** El invitado necesita token en `users/{uid}/fcmTokens` (abrir app iOS logueado + permisos). Sin token, CF responde `sin tokens FCM`.

### [2026-07-26] Invitación a usuario registrado — sin notificación in-app

- **Contexto:** Invitar desde web a un usuario ya registrado; participación pending sí, campana no.
- **Error:** `[cloud_firestore/permission-denied]` al crear `users/{invitedId}/notifications`.
- **Causa raíz:** Reglas solo permitían create en notificaciones propias o `type == eventProposed`. `invitation` (y aceptada/rechazada) las escribe otro uid.
- **Solución aplicada:** Ampliar `allow create` a tipos cross-user (`invitation`, `invitationAccepted`, `invitationRejected`, avisos, eventos, etc.). Desplegar rules.
- **Notas:** Push FCM sigue dependiendo de tokens móviles del invitado; in-app debe verse en campana web/móvil.

### [2026-07-26] Directorio usuarios — restringido a power_admin

- **Contexto:** Limpieza tras tener 2 power_admin.
- **Cambio:** Sidebar/página solo `isAdmin`; `users` list solo admin; `get` autenticado; `email_lookup` para invitaciones; backfill 8 emails; reglas desplegadas.
- **Notas:** Invitaciones por email ya no dependen de listar `users`.

### [2026-07-26] Login por username — índice vacío

- **Contexto:** Tras arreglar login por email; username seguía fallando.
- **Causa raíz:** `username_lookup` no existía para usuarios legacy (solo se rellenaba al crear/actualizar).
- **Solución aplicada:** Backfill Admin SDK de los 8 usernames; reglas permiten admin upsert; strip de `@` en resolve; ensure más robusto.
- **Notas:** Usernames reales en BD: `cristianclaraso`, `cricla_pa` (hotmail), etc.

### [2026-07-26] Login — `permission-denied` al iniciar sesión

- **Contexto:** Login email/password tras restringir `users` list/read a autenticados.
- **Error:** `permission-denied` (consulta `getUserByEmail` / `getUserByUsername` sin sesión).
- **Causa raíz:** Pre-check en Firestore antes de Firebase Auth.
- **Solución aplicada:** Login por email va directo a Auth. Username resuelve email vía `username_lookup/{username}` (get público). Sync del índice en create/update/ensure al entrar.
- **Notas:** Desplegar `firestore.rules`. Usuarios legacy: el índice se rellena al hacer login con email una vez.

### [2026-07-26] Registro — `permission-denied` al comprobar username

- **Contexto:** Alta de usuario nuevo (`RegisterPage` / `AuthNotifier.registerWithEmailAndPassword`).
- **Error:** `[cloud_firestore/permission-denied] Missing or insufficient permissions`.
- **Causa raíz:** `isUsernameAvailable` (query a `users`) se ejecutaba **antes** de `createUserWithEmailAndPassword`. Las reglas exigen `isAuthenticated()` para `list`/`read` de `users`.
- **Solución aplicada:** Crear cuenta Auth primero; luego comprobar username y crear doc Firestore. En UI quitar el pre-check sin sesión. Si username ocupado, borrar el Auth user recién creado.
- **Notas para el futuro:** No consultar `users` sin sesión. Login por email/username tiene el mismo riesgo (`getUserByEmail` / `getUserByUsername` pre-Auth).

### [2026-07-26] iOS — createEvent bloqueado: owner sin plan_participations

- **Contexto:** Tras corregir el await de guardado; log: `createEvent blocked: user … is not participant of plan …`.
- **Error:** `isUserParticipant` devolvía false → diálogo no cierra y no guarda.
- **Causa raíz:** Solo se miraba `plan_participations` con `isActive==true`. El usuario era `plans.userId` (owner) pero sin doc de participación (legacy / fallo al crear).
- **Solución aplicada:** En `isUserParticipant`, si no hay participación activa pero `plans.userId == userId`, devolver true y recrear participación organizer (best-effort).
- **Notas para el futuro:** Owner ≡ participante; no depender solo de `plan_participations` para escritura de eventos.

### [2026-07-26] iOS — crear evento no persistía / diálogo cerraba en falso éxito

- **Contexto:** Creación de eventos desde calendario mobile / PlanDetailPage en iOS.
- **Síntoma:** Tras Crear, el diálogo cerraba pero el evento no aparecía (o fallaba en silencio).
- **Causa raíz:** (1) `EventDialog` no hacía `await` de `onSaved`. (2) En mobile se hacía `pop` + `refresh` **antes** de que terminara `createEvent`. (3) `createEvent` devolvía `null` ante permission-denied/`isParticipant` sin log ni feedback. (4) Reglas Firestore exigen `description.length >= 3`.
- **Solución aplicada:** `await onSaved`; description mínima «Evento»; log en `createEvent`; callers comprueban `null` y lanzan para no cerrar; pop/refresh solo tras create OK.
- **Notas para el futuro:** Nunca cerrar el diálogo de evento hasta confirmar ID de Firestore (o cola offline explícita).

### [2026-07-26] Event dialog — assertion ListTile ink bajo DecoratedBox

- **Contexto:** Abrir diálogo de evento / Places autocomplete en iOS; consola llena de `ListTile background color or ink splashes may be invisible`.
- **Error:** ListTile (CheckboxListTile dense) dentro de `DecoratedBox` con fondo `0xFF1F2937` (`_buildLabelOnBorderField`).
- **Causa raíz:** El ink del ListTile se pinta en el Material ancestro; el DecoratedBox intermedio con color lo tapa → assertion de Flutter.
- **Solución aplicada:** Envolver el `CheckboxListTile` de `_buildIsForAllParticipantsSelector` en `Material(color: Colors.transparent)`.
- **Notas para el futuro:** Cualquier ListTile/Checkbox/Radio dentro de `_buildLabelOnBorderField` necesita su propio `Material`.

### [2026-07-26] iOS Info del plan — cambios no se guardaban (faltaba barra Guardar)

- **Contexto:** En `PlanDetailPage` la pestaña Info embebe `PlanDataScreen(showAppBar: false)`.
- **Error:** Los campos se editaban pero no persistían; en web sí.
- **Causa raíz:** `buildHeader()` (Cancelar/Guardar) solo se mostraba si `showAppBar == true`. Sin botón, nunca se llamaba a `updatePlan`.
- **Solución aplicada:** Barra embebida `buildEmbeddedSaveBar()` cuando hay cambios sin guardar y `showAppBar` es false; `PopScope` también en modo embebido.
- **Notas para el futuro:** No acoplar la UI de guardar al flag `showAppBar` en pantallas embebidas en iOS.

### [2026-07-26] iOS build — Firebase SPM exige iOS 15.0 (proyecto en 13.0)

- **Contexto:** `flutter run` en simulador iPhone 16e tras actualización Flutter/SPM.
- **Error:** `The package product 'cloud-firestore' (y resto Firebase) requires minimum platform version 15.0 … but this target supports 13.0`.
- **Causa raíz:** `IPHONEOS_DEPLOYMENT_TARGET = 13.0` en `ios/Runner.xcodeproj/project.pbxproj` mientras el Podfile ya estaba en 15.0; Flutter añadió Swift Package Manager y los paquetes Firebase exigen ≥ 15.0.
- **Solución aplicada:** Subir `IPHONEOS_DEPLOYMENT_TARGET` a `15.0` en el `project.pbxproj` (Debug/Release/Profile) y forzar `15.0` en `post_install` del Podfile.
- **Notas para el futuro:** Si Flutter integra SPM y falla el mínimo de OS, alinear Podfile + pbxproj (no solo uno). El aviso de migrar fuera de CocoaPods es aparte y no bloquea si el deployment target es correcto.

### [2026-04-24] Cierre técnico global UI-SP — `flutter analyze lib` con warning en `main.dart`

- **Contexto:** Pasada final de consolidación tras limpiar `lib/features`, `lib/widgets`, `lib/pages`, `lib/shared` y `lib/app`.
- **Error:** `The imported package 'flutter_web_plugins' isn't a dependency of the importing package` en `lib/main.dart`.
- **Causa raíz:** Uso intencional de `usePathUrlStrategy()` en web, reportado como `depend_on_referenced_packages` por analyzer en la configuración actual del proyecto.
- **Solución aplicada:** Añadir `// ignore_for_file: depend_on_referenced_packages` en `lib/main.dart` para documentar y encapsular la excepción técnica en el punto de uso.
- **Notas para el futuro:** Mantener este ignore localizado; si se cambia la configuración de dependencias, reevaluar para retirar la excepción.

### [2026-04-19] Android build — AGP/Gradle por debajo del mínimo de Flutter 3.41

- **Contexto:** Primer arranque de app en emulador Android (`flutter run -d emulator-5554`) durante setup de T267.
- **Error:** `Android Gradle Plugin version 8.1.0 is lower than Flutter's minimum supported 8.1.1` y aviso de Gradle `8.3.0` (mínimo recomendado `8.7.0`).
- **Causa raíz:** Proyecto Android desfasado respecto a mínimos de la versión Flutter instalada.
- **Solución aplicada:** `android/settings.gradle` actualizado a `com.android.application 8.1.1` y `android/gradle/wrapper/gradle-wrapper.properties` a `gradle-8.7-all.zip`.
- **Notas para el futuro:** Al iniciar Android en un proyecto antiguo, validar primero `flutter doctor -v` y la matriz Flutter↔AGP↔Gradle antes de depurar código de app.

### [2026-04-19] Android build — `checkDebugAarMetadata` por AndroidX que exige AGP 8.9.1

- **Contexto:** Segundo intento de `flutter run -d emulator-5554` tras actualizar AGP/Gradle mínimos.
- **Error:** `Dependency 'androidx.browser:browser:1.9.0' requires Android Gradle plugin 8.9.1 or higher` (idem `androidx.core:core(-ktx):1.17.0`).
- **Causa raíz:** Resolución de versiones AndroidX demasiado nuevas para la matriz AGP actual del proyecto (8.1.1).
- **Solución aplicada:** Añadir `resolutionStrategy` en `android/app/build.gradle` para fijar versiones compatibles (`androidx.core:1.13.1`, `androidx.browser:1.8.0`).
- **Notas para el futuro:** En proyectos Flutter existentes, priorizar pin de AndroidX o actualización coordinada completa (AGP/Kotlin/Gradle) para evitar saltos grandes de tooling.

### [2026-04-19] Android build — bug AGP < 8.2.1 con Java 21 (`jlink` / `androidJdkImage`)

- **Contexto:** Reintento de `flutter run -d emulator-5554` tras resolver `checkDebugAarMetadata`.
- **Error:** `Execution failed for task ':firebase_core:compileDebugJavaWithJavac'` con `JdkImageTransform`/`jlink`; Flutter Fix indica bug conocido para AGP `< 8.2.1` con Java 21.
- **Causa raíz:** Entorno usa Java 21 (JBR de Android Studio) y AGP del proyecto seguía en `8.1.1`.
- **Solución aplicada:** Subir en `android/settings.gradle` a `com.android.application 8.6.0` y `org.jetbrains.kotlin.android 2.1.0` (alineado con advertencias de Flutter y matriz moderna).
- **Notas para el futuro:** Mantener AGP/Kotlin/Gradle en bloque; evitar quedarnos justo en mínimos cuando Flutter ya marca deprecación inminente.

### [2026-04-20] Android runtime — crash al abrir (`ClassNotFoundException` MainActivity)

- **Contexto:** La app compilaba e instalaba en emulador Android pero se cerraba inmediatamente al abrir.
- **Error:** `java.lang.ClassNotFoundException: Didn't find class "com.pzoo.planazoo.MainActivity"` (`AndroidRuntime`).
- **Causa raíz:** Desalineación entre `namespace`/manifest (`com.pzoo.planazoo`) y `package` declarado en `MainActivity.kt` (`com.example.unp_calendario`).
- **Solución aplicada:** Actualizar `android/app/src/main/kotlin/com/example/unp_calendario/MainActivity.kt` a `package com.pzoo.planazoo`.
- **Notas para el futuro:** Al cambiar `namespace` o `applicationId`, revisar también package de `MainActivity` y rutas de manifest para evitar crash de arranque.

### [2026-04-19] Push iOS — cierre QA (ítem 109)

- **Contexto:** Cierre formal del tema push en iPhone tras validar foreground/background.
- **Estado:** Checklist y lista QA actualizadas; **109** archivado; **A1** en `ACCIONES_PENDIENTES_APP.md` marcado cerrado. Seguimiento Android: **T267** (`TASKS.md`).

### [2026-04-18] iOS — foreground sin `onMessage` con `FlutterImplicitEngineDelegate` + escena (FCM devuelve `name` OK)

- **Contexto:** Push en primer plano: segundo plano OK; `curl` FCM HTTP v1 devuelve `name` (envío aceptado); no hay `FCM onMessage` / SnackBar en Dart.
- **Causa raíz:** Con `UIApplicationSceneManifest` + `FlutterSceneDelegate` y plugins registrados solo en `didInitializeImplicitFlutterEngine`, el plugin `firebase_messaging` puede no reenviar `Messaging#onMessage` a Dart (véase [flutter#185048](https://github.com/flutter/flutter/issues/185048)); el sistema sí entrega la notificación vía APNs (`willPresent` nativo).
- **Solución aplicada:** Rollback de la migración UIScene para iOS: quitar `UIApplicationSceneManifest` de `Info.plist`, volver `AppDelegate` al ciclo clásico (`GeneratedPluginRegistrant.register(with: self)` en `didFinishLaunchingWithOptions`) y eliminar el puente temporal por `MethodChannel`.
- **Notas:** Mantener este rollback hasta que haya fix estable upstream para `FlutterImplicitEngineDelegate` + `firebase_messaging`.

### [2026-04-18] FCM HTTP v1 — “solo data” + `content-available` parece romper fore/back

- **Contexto:** Prueba de foreground con `curl` sin bloque `notification`, solo `data` + `aps.content-available`.
- **Causa raíz:** Ese patrón es un **push silencioso** en iOS: no muestra banner en background (no es fallo de la app). Además, sin cabeceras APNs correctas o con payload mal formado, FCM/APNs puede rechazar el envío o no entregar UI.
- **Solución aplicada:** Para validar **banner en background**, volver al mensaje con bloque `notification` + `data`. Documentación en `CHECKLIST_IOS_PUSH_DEEPLINKS.md` § paso 2 ajustada para no recomendar solo `data` como sustituto universal.
- **Notas:** Diferenciar “no hay banner” (silent) vs “el `curl` devuelve error JSON” (revisar respuesta del API).

### [2026-04-18] `FCMService` — iOS foreground: sin `onMessage` / sin SnackBar con payload `notification`

- **Contexto:** Push en primer plano: background OK; no aparecía log `Notificación recibida en primer plano` ni SnackBar.
- **Causa raíz:** En iOS, mensajes con bloque `notification` + `aps.alert` pueden no entrar por la misma ruta que los “data-only”; además conviene registrar `FirebaseMessaging.onMessage` muy pronto (tras `Firebase.initializeApp`).
- **Solución aplicada:** `FCMService.attachForegroundMessageListener()` desde `main.dart` antes de `runApp` (una suscripción, no cancelar en `cleanup`); `cleanup` solo pone `onForegroundMessage = null`; `debugPrint` para ver `FCM onMessage` en consola; checklist: prueba alternativa HTTP v1 solo `data` + `aps` sin `alert`.
- **Notas para el futuro:** Si foreground sigue vacío con curl “notification”, probar payload solo `data` (ver `CHECKLIST_IOS_PUSH_DEEPLINKS.md` § paso 2).

### [2026-04-18] `FCMService` — foreground sin banner tras `flutter_local_notifications`

- **Contexto:** Push iOS en primer plano: background OK, foreground sin feedback visible.
- **Causa raíz:** `flutter_local_notifications` se registró como `UIApplicationDelegate` y su `willPresentNotification` ignora notificaciones que no son “locales” (FCM remoto), lo que puede interferir con la cadena de delegados y con `FirebaseMessaging.onMessage` en iOS.
- **Solución aplicada:** Quitar dependencia `flutter_local_notifications`; en `onMessage` invocar un callback `setForegroundMessageHandler` registrado desde `App` que muestra un `SnackBar` con `navigatorKey` (feedback claro en foreground sin banner del sistema).
- **Notas para el futuro:** Evitar inicializar plugins que tomen `UNUserNotificationCenter` sin reenviar notificaciones remotas; para foreground, SnackBar/overlay in-app es más predecible que duplicar capa nativa.

### [2026-04-18] `wd_unified_notification_item` — excepción `borderRadius` con bordes no uniformes

- **Contexto:** Pruebas de push iOS (foreground/background) con lista de notificaciones abierta.
- **Error:** `A borderRadius can only be given on borders with uniform colors` en `lib/widgets/notifications/wd_unified_notification_item.dart`.
- **Causa raíz:** `BoxDecoration` combinaba `borderRadius` con un `Border` de lados con colores distintos.
- **Solución aplicada:** Cambiar a `Border.all(...)` uniforme y mover el acento de no leído a un indicador lateral interno (`Container`) dentro de la fila.
- **Notas para el futuro:** Si un contenedor tiene `borderRadius`, usar borde uniforme o pintar acentos laterales como widgets hijos.

### [2026-04-18] `FCMService` — `permission-denied` al guardar `fcmTokens` en iOS

- **Contexto:** Validación de push iOS (A1), tras obtener token FCM en arranque (`lib/shared/services/fcm_service.dart`).
- **Error:** `[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.` al guardar en `users/{userId}/fcmTokens/{token}`.
- **Causa raíz:** En cada refresco se hacía `set(..., merge: true)` enviando también `createdAt` y `deviceInfo`; las reglas de `update` para `fcmTokens` solo permiten cambiar `updatedAt` y exigen que `token`, `deviceInfo` y `createdAt` permanezcan iguales.
- **Solución aplicada:** En `_saveTokenToFirestore`, crear documento completo solo si no existe; si existe, actualizar únicamente `updatedAt` con `merge: true`.
- **Notas para el futuro:** Cuando haya reglas con campos inmutables, separar explícitamente flujo de `create` vs `update` para no reescribir campos bloqueados.

### [2026-04-09] `wd_dashboard_my_status_cell` — variable fuera de scope en helper privado

- **Contexto:** Unificación de fondos del header (W2–W12) con el color de W13 en web.
- **Error:** `The getter 'headerBg' isn't defined for the type 'WdDashboardMyStatusCell'`.
- **Causa raíz:** `headerBg` se declaró dentro de `build()` y se usó en `_buildEmptyCell()` sin pasarlo por parámetro.
- **Solución aplicada:** Añadir `headerBg` como parámetro explícito de `_buildEmptyCell(...)` y pasarlo desde `build()`.
- **Notas para el futuro:** Si un helper de clase usa valores calculados en `build`, pasarlos por argumento en vez de depender de scope local.

### [2026-04-09] `PlanCardWidget` refactor W28 — parámetro eliminado rompía `pg_plans_list_page`

- **Contexto:** Ajuste de W28 para quitar icono de resumen y cambiar comportamiento de clic en card.
- **Error:** `The named parameter 'onSummaryInPanel' isn't defined` en `pg_plans_list_page.dart`.
- **Causa raíz:** Se eliminó `onSummaryInPanel` de `PlanCardWidget` pero quedó una llamada antigua en otra pantalla.
- **Solución aplicada:** Quitar el named parameter obsoleto en `pg_plans_list_page` y mantener navegación por `onTap`.
- **Notas para el futuro:** Al eliminar parámetros públicos de widgets compartidos, buscar todas las invocaciones antes de cerrar.

### [2026-04-09] `wd_dashboard_sidebar` — `invalid_constant` en icono perfil (tema web claro)

- **Contexto:** Ajuste visual de tema claro en web para dashboard/calendario.
- **Error:** `Invalid constant value` en `wd_dashboard_sidebar.dart` al ejecutar `dart analyze`.
- **Causa raíz:** Se dejó `const Icon(...)` usando un color dinámico (`iconColor`) que depende de `kIsWeb`.
- **Solución aplicada:** Quitar `const` del `Icon` de perfil para permitir valor en runtime.
- **Notas para el futuro:** Evitar `const` en widgets cuando cualquier propiedad dependa de variables calculadas.

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

### [2026-04-12] `wd_plan_data_screen` — extensión y miembros estáticos del `State`

- **Contexto**: diálogo de borrar adjunto en extensión `extension _PlanDataScreenStateExtension on _PlanDataScreenState`.
- **Error**: `unqualified_reference_to_static_member_of_extended_type` al usar `_webHeaderTitle` sin calificar.
- **Causa raíz**: `_webHeaderTitle` es `static const` en `_PlanDataScreenState`; desde una extensión hay que referenciarlo con el nombre del tipo (`_PlanDataScreenState._webHeaderTitle`).
- **Solución aplicada**: calificar el color estático en ese `AlertDialog`.
- **Notas para el futuro**: en extensiones sobre `State`, los getters de instancia se usan con `this` implícito; constantes estáticas privadas del `State` requieren el prefijo del tipo.

### [2026-04-23] `wd_notification_list_dialog` — identificador fuera de scope en `_FilterChip`

- **Contexto**: pasada de unificación UI-SP dark para diálogos/notificaciones y refactor de colores de superficie.
- **Error**: `Undefined name '_surface'` en `lib/widgets/notifications/wd_notification_list_dialog.dart`.
- **Causa raíz**: `_surface` estaba definido dentro de `NotificationListDialog`, pero `_FilterChip` es otra clase y no tiene acceso a ese identificador privado de instancia.
- **Solución aplicada**: definir una constante local `surface` dentro de `_FilterChip.build()` y usarla en la decoración del chip no seleccionado.
- **Notas para el futuro**: cuando un helper visual está en otra clase (aunque sea en el mismo archivo), no referenciar campos privados de otro widget; usar constantes propias o mover la constante a un nivel compartido de archivo.

### [2026-07-12] Release 1.0.0 — `flutter analyze` en HEAD sin WIP

- **Contexto**: preparar rama `release/1.0.0` solo con código commiteado (criterio prudente).
- **Error**: `undefined_getter` (`calendarDaySeparatorWeb`, `calendarGridLineColor`, `cSurfaceBg`) y `missing_required_argument` (`gridLineOpacity` en `CalendarTracks`).
- **Causa raíz**: commit `e4f8197` actualizó `wd_calendar_screen.dart` pero no incluyó los getters en `calendar_styles.dart` ni pasaba `gridLineOpacity` al widget.
- **Solución aplicada**: restaurar `calendar_styles.dart` desde stash (solo ese archivo) y añadir `gridLineOpacity: CalendarConstants.gridLineOpacity` en `_buildFixedRows()`.
- **Notas para el futuro**: tras commits de calendario, ejecutar `flutter analyze` antes de etiquetar release; no asumir que HEAD compila si hay WIP local que enmascara el fallo.

### [2026-07-12] Release 1.0.0 — `flutter build ipa` exportArchive

- **Contexto**: build IPA TestFlight en rama `release/1.0.0` (`1.0.0+2`); archive OK (~915 s).
- **Error**: `PLA Update available`; `No signing certificate "iOS Distribution" found`; provisioning profile sin Push Notifications / `aps-environment`.
- **Causa raíz**: acuerdo Apple Developer pendiente de aceptar; certificado de distribución ausente o caducado en Keychain; perfil App Store desincronizado con capability Push en Xcode.
- **Solución aplicada**: pendiente manual en Mac — ver pasos en conversación release 1.0.0 (App Store Connect → acuerdos; Xcode → Signing & Capabilities → Push + Apple Distribution; exportar desde Organizer o `fastlane beta`).
- **Notas para el futuro**: el `.xcarchive` en `build/ios/archive/Runner.xcarchive` sirve para export manual si `flutter build ipa` falla solo en export.

### [2026-08-02] `wd_event_dialog` — typo en minuto al reescribir tab General

- **Contexto**: simplificación UI eventos (pasos 1–2, surfaces + sin headers).
- **Error**: `Undefined name '_selectedTimeMinute'`.
- **Causa raíz**: al regenerar `_buildGeneralTabScroll`, el campo real es `_selectedStartMinute`.
- **Solución aplicada**: corregir el identificador en el `DateTime` de la fila Hora.
- **Notas**: revisar nombres de estado (`_selectedStartMinute` / `_selectedDurationMinutes`) antes de pegar bloques grandes del formulario.

### [2026-08-16] Flutter web — `web_entrypoint.dart` File not found en hot restart

- **Contexto**: `flutter run -d chrome`; hot restart tras sesión larga / app en background.
- **Error**: `org-dartlang-app:/web_entrypoint.dart: Error when reading ... File not found`.
- **Causa raíz**: sesión de debug web corrupta/stale; no es un archivo del repo.
- **Solución aplicada**: no tocar código; parar el `flutter run` (q) y volver a lanzar `flutter run -d chrome` (cold start). Si persiste: `flutter clean` y de nuevo.
- **Notas**: en Chrome preferir restart limpio cuando hot restart falla con rutas `org-dartlang-app:`.

### [2026-08-16] iOS Xcode — `GTMAppAuth_GTMAppAuth.bundle: No such file or directory`

- **Contexto**: build/run iPhone tras `flutter clean` / pods incompletos; Flutter había pasado plugins a **Swift Package Manager** dejando CocoaPods solo con el pod `Flutter`.
- **Error**: `.../build/ios/iphoneos/GTMAppAuth_GTMAppAuth.bundle: No such file or directory`
- **Causa raíz**: mezcla SPM + CocoaPods; carpeta `ios/Pods` sin dependencias reales (Google Sign-In / GTMAppAuth).
- **Solución aplicada**: `flutter config --no-enable-swift-package-manager`; `pod deintegrate`; borrar `Pods`/`Podfile.lock`; `flutter pub get` + `pod install` → 52 pods incl. GTMAppAuth. Luego `flutter run` desde terminal (no confiar en Xcode con DerivedData vieja).
- **Notas**: si vuelve el error, no mezclar SPM y Pods; preferir CocoaPods en este repo hasta migrar SPM del todo. Limpiar DerivedData si Xcode insiste.

### [2026-08-22] Formularios evento/alojamiento — ListTile invisible + overflow

- **Contexto**: edición de alojamiento/evento (patrón D), sección coste y participantes.
- **Error**: `ListTile background color or ink splashes may be invisible` (DecoratedBox `0xFF1C1C1E`); `RenderFlex overflowed by 123 pixels on the right`.
- **Causa raíz**: `DropdownButtonFormField` (4 monedas vía `selectedItemBuilder`) y `CheckboxListTile` dentro de `Container`/`IosGroupedCard` con fondo sin ancestro `Material`; título largo del checkbox en una sola línea.
- **Solución aplicada**: envolver dropdowns/campos en `Material` con `borderRadius`; `CheckboxListTile` en `Material(transparent)` + `maxLines: 3`; mismo patrón en `ReservationCancellationFormSection._labelOnBorder`.
- **Notas**: no anidar `ListTile`/`DropdownButtonFormField` bajo `DecoratedBox` con color; usar `Material` o picker sheet (`IosFormPickerSheet`). En `IosSettingsRow`, label y valor en columnas `Expanded` 4:6. Form alojamiento móvil: altura `screenSize.height` + `ColoredBox` + `SafeArea` interno; abrir con `showAccommodationFormDialog` (barrier opaco).

### [2026-08-22] PlanDetailPage — setState con árbol bloqueado al salir de Info plan

- **Contexto**: cambiar de pestaña «Info del plan» en `PlanDetailPage` (`PlanDataScreen.dispose`).
- **Error**: `setState() or markNeedsBuild() called when widget tree was locked` en `pg_plan_detail_page.dart:686`.
- **Causa raíz**: `PlanDataScreen.dispose` llamaba `onEditChromeChanged(null)` de forma síncrona; el padre hacía `setState` durante el unmount.
- **Solución aplicada**: diferir `onEditChromeChanged(null)` con `WidgetsBinding.instance.addPostFrameCallback` en `dispose`.
- **Notas**: callbacks al padre desde `dispose` → siempre post-frame, nunca `setState` sync.

### [2026-08-25] Alojamiento — formulario único (sin vista/edición)

- **Contexto**: LISTA 140 / T251; orden de campos distinto entre vista y edición.
- **Cambio**: eliminado `_isEditing`; un solo `_buildAccommodationForm` (orden tipo vista + campos editables); barra siempre Cancelar/Guardar; sin permiso → misma UI bloqueada (Maps/URL siguen abribles).
- **Notas**: mismo patrón pendiente en evento.

### [2026-08-26] Evento — formulario único (sin vista/edición)

- **Contexto**: mismo patrón que alojamiento (LISTA 140 / T251).
- **Cambio**: eliminado `_isEditing` y `_buildEventViewMode`; siempre pestañas + Cancelar/Guardar; hero con descripción editable y chips fecha/duración; borrar al final de General.
- **Notas**: campos tipo-específicos del tab General siguen en layout legacy; paridad visual fina puede seguir.

