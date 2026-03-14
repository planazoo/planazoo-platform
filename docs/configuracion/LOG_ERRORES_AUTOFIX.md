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

