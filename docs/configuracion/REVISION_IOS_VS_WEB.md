# Revisión iOS vs Web – Planazoo

**Objetivo:** Alinear la versión iOS con la web y preparar lanzamiento en modo prueba (TestFlight).  
**Fecha:** Marzo 2026

---

## 1. Resumen de rutas y pantallas

| Área | Web | iOS |
|------|-----|-----|
| **Entrada autenticada** | `DashboardPage` (grid, W1–W31) | `PlansListPage` (lista de planes) |
| **Detalle de plan** | Contenido en panel W31 (CalendarScreen, PlanDataScreen, etc.) | `PlanDetailPage` con `PlanNavigationBar` (Info, Mi resumen, Calendario, Participantes, Chat, Stats, Pagos) |
| **Calendario** | `CalendarScreen` (desktop) | `CalendarMobilePage` (1–3 días, misma lógica) |
| **Invitación por link** | `InvitationPage` vía `/invitation/{token}` | Misma ruta; en iOS el link debe abrir la app (Universal Links / URL scheme) |

La decisión de qué mostrar (mobile vs desktop) se hace en `app.dart` con `PlatformUtils.shouldShowMobileUI(context)`.

---

## 2. Problemas y mejoras detectadas

### 2.1 Multi-idioma (textos hardcodeados)

**Norma del proyecto (CONTEXT.md):** todos los textos visibles deben usar `AppLocalizations`.

- **`pg_plans_list_page.dart`**
  - `'No tienes planes aún'`, `'Crea tu primer plan para comenzar'`, `'No se encontraron planes'`, `'Error al cargar planes'`, `'Todos'`, `'Estoy in'`, `'Pendientes'`, `'Cerrados'`, `'Perfil'`.
  - SnackBars y mensajes de error en español.
- **`pg_invitation_page.dart`**
  - `'Invitación a Plan'`, `'Iniciar sesión'`, `'Crear cuenta'`, `'Rechazar invitación'`, `'Invitación aceptada. Redirigiendo al plan...'`, diálogos de rechazo, `'Volver'`, etc.

**Acción:** Añadir claves en `app_es.arb` y `app_en.arb` y sustituir todos estos textos por `AppLocalizations.of(context)!.key`.

---

### 2.2 Invitación aceptada en iOS: ir al plan

- **Web:** Tras aceptar, `pushReplacementNamed('/')` lleva al Dashboard (y el plan puede estar seleccionado por argumentos).
- **iOS:** `pushReplacementNamed('/')` lleva a `PlansListPage`; el usuario no entra directamente al plan al que acaba de unirse.

**Acción:** Tras aceptar la invitación en móvil, navegar a `PlanDetailPage(plan: plan)` del plan de la invitación en lugar de solo a `/`. Requiere obtener el `Plan` desde la invitación (ya disponible en `_buildInvitationDetails`).

---

### 2.3 Deep links en iOS (invitación por link)

- Las rutas `/invitation/{token}` funcionan si la app ya está abierta o si se usa una URL que el sistema enruta a la app.
- Para que un link (p. ej. desde correo) abra la app en iOS hace falta:
  - **Universal Links** (asociar dominio con la app), o
  - **Custom URL scheme** (ej. `planazoo://invitation/xxx`).

**Acción:** Para TestFlight, decidir si los links de invitación serán solo para web o también para abrir la app; si es lo segundo, configurar Universal Links o URL scheme y manejar la URL en la app (ej. `WidgetsBinding` + comprobar `Uri.base` o argumentos de lanzamiento).

---

### 2.4 Safe area y notch / barra inferior

- **PlansListPage:** El `bottomNavigationBar` ya usa `SafeArea` (respeta home indicator).
- **PlanDetailPage:** El `Scaffold` no envuelve el cuerpo en `SafeArea`; el `AppBar` cubre el notch. Revisar en dispositivo real si el contenido queda tapado por el home indicator en la parte inferior (sobre todo en Calendario / lista).

**Acción:** Revisar en simulador con iPhone con notch/Dynamic Island; si hace falta, envolver el contenido de `_buildContent()` o el `body` en `SafeArea` (o solo `bottom: true` si el problema es solo abajo).

---

### 2.5 Barra de pestañas del plan (PlanNavigationBar)

- Hay 7 opciones (Info, Mi resumen, Calendario, Participantes, Chat, Stats, Pagos) en un `ListView` horizontal.
- En pantallas estrechas las pestañas pueden quedar muy comprimidas o requerir mucho scroll horizontal; las etiquetas pueden truncarse.

**Acción:** Probar en iPhone pequeño (ej. SE) y en orientación vertical. Si molesta, valorar: solo iconos en móvil, o agrupar (ej. “Más” con menú) y dejar las 4–5 más usadas visibles.

---

### 2.6 Import innecesario en PlansListPage

- `pg_plans_list_page.dart` tiene `import 'dart:io';` pero no usa `Platform` ni nada de `dart:io`.

**Acción:** Eliminar `import 'dart:io';` para evitar confusión y posibles problemas si en el futuro se compila este archivo en un contexto donde `dart:io` no esté permitido.

---

### 2.7 FCM (notificaciones push) en iOS

- **Código:** `FCMService` ya solicita permisos en iOS (`requestPermission`) y evita web (`kIsWeb`).
- **Info.plist:** No hay `UIBackgroundModes` con `remote-notification`; sin eso, las notificaciones en segundo plano pueden no entregarse correctamente.
- **APNs:** Para FCM en iOS hace falta configurar APNs (certificado o key en Firebase Console) y que el proyecto tenga el capability “Push Notifications” en Xcode.

**Acción:**
  - Añadir en `ios/Runner/Info.plist` (o en Xcode → Signing & Capabilities) el modo de fondo:
    ```xml
    <key>UIBackgroundModes</key>
    <array>
      <string>remote-notification</string>
    </array>
    ```
  - Comprobar que existe `GoogleService-Info.plist` en `ios/Runner/` (suele estar en .gitignore).
  - En Firebase Console, configurar APNs para la app iOS (certificado o APNs Auth Key).

---

### 2.8 Info.plist – otros permisos

- No hay descripciones de uso para cámara/fotos (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`). Si en algún flujo (p. ej. imagen del plan) se abre el selector de fotos o la cámara, iOS puede rechazar el acceso o crashear sin estas claves.

**Acción:** Si la app usa cámara o galería, añadir las claves correspondientes con un texto claro para el usuario.

---

### 2.9 Funcionalidades que dependen de plataforma

- **Hive (offline):** `HiveService.initialize()` se llama en `main.dart`; `HiveService` solo inicializa en móvil (no en web). Correcto para iOS.
- **Google Places:** En `places_api_service.dart` y `place_autocomplete_field.dart` hay comprobaciones `kIsWeb`; en iOS el autocompletado debería funcionar si la API key está configurada (variable de entorno / configuración por plataforma).
- **Conectividad:** `ConnectivityService` en web no usa el plugin nativo; en iOS sí. Revisar que en simulador/dispositivo el estado “sin conexión” se refleje bien en la UI si se usa.

---

## 3. Checklist pre–TestFlight (resumen)

| # | Ítem | Prioridad | Estado (revisión Marzo 2026) |
|---|------|-----------|------------------------------|
| 1 | Sustituir textos hardcodeados por AppLocalizations en `pg_plans_list_page.dart` y `pg_invitation_page.dart` | Alta | **Hecho:** PlansListPage ya usaba `loc.plansList*` y `loc.createPlan*` en SnackBars. InvitationPage: sustituidos todos los textos visibles por claves (invitationYouHaveBeenInvited, invitationPlanDetails, invitationLabelName, invitationWrongUserWarning, invitationExpiresOn, etc.) en ES/EN y en los archivos de localización. |
| 2 | Tras aceptar invitación en móvil, navegar a `PlanDetailPage(plan)` del plan aceptado | Media | **Hecho:** En `pg_invitation_page.dart` (líneas 430-434) si `shouldShowMobileUI` y `plan != null` se hace `pushReplacement(PlanDetailPage(plan))`. |
| 3 | Revisar Safe area en `PlanDetailPage` (sobre todo parte inferior) | Media | **Hecho:** El `body` del Scaffold está envuelto en `SafeArea` (línea 73). Revisar en dispositivo real si el home indicator tapa algo. |
| 4 | Quitar `import 'dart:io'` de `pg_plans_list_page.dart` | Baja | **Hecho:** Ya no existe ese import. |
| 5 | Añadir `UIBackgroundModes` → `remote-notification` en Info.plist para FCM | Alta (si quieres push en iOS) | **Hecho:** Añadido en `ios/Runner/Info.plist`. |
| 6 | Comprobar GoogleService-Info.plist y APNs en Firebase para iOS | Alta | **Pendiente:** Verificar en proyecto y Firebase Console. |
| 7 | Decidir y, si aplica, implementar deep link (Universal Links o URL scheme) para invitaciones | Media | **Pendiente.** |
| 8 | Probar barra de pestañas del plan en iPhone pequeño; ajustar si hace falta | Baja | **Pendiente** (prueba manual). |
| 9 | Añadir descripciones de uso cámara/fotos en Info.plist si la app las usa | Media | **Hecho:** Añadidos `NSPhotoLibraryUsageDescription` y `NSCameraUsageDescription` en `ios/Runner/Info.plist` (la app usa ImagePicker para imagen del plan y perfil). |

---

## 3b. Checklist de paridad Web vs iOS (T257) – rellenado

| Área | Estado | Notas |
|------|--------|--------|
| **Lista de planes** | Paridad | iOS: filtros (todos, estoy in, pendientes, cerrados), búsqueda (`WdPlanSearchWidget`), crear plan, card con imagen, iconos resumen/notificaciones/chat, navegación a detalle. Mismo contenido que web (PlanListWidget + PlanCardWidget). |
| **Detalle del plan / pestañas** | Paridad | Las 7 pestañas existen en iOS (Info, Mi resumen, Calendario, Participantes, Chat, Stats, Pagos). Mismas pantallas: `WdPlanDataScreen`, `WdMyPlanSummaryScreen`, `CalendarMobilePage`/resumen, `PgPlanParticipantsPage`, `WdPlanChatScreen`, `PlanStatsPage`, `PaymentSummaryPage`. |
| **Calendario** | Paridad funcional | iOS usa `CalendarMobilePage` (1–3 días visibles), con tracks, eventos, alojamientos, diálogos crear/editar evento y alojamiento. Menos vista “rejilla grande” que web; adecuado para móvil. |
| **Notificaciones e invitaciones** | Paridad + 1 pendiente | Aceptar/rechazar invitación en ambas. Tras aceptar en móvil ya se navega a `PlanDetailPage(plan)`. **Pendiente:** deep link (Universal Links o URL scheme) para abrir app desde link de invitación. |
| **Perfil y ajustes** | Paridad | Acceso desde barra inferior en iOS (`ProfilePage`). Misma página que web (edición, idioma, zona horaria, eliminar cuenta). |
| **Multi-idioma** | OK | PlansListPage e InvitationPage usan solo AppLocalizations. InvitationPage: añadidas y usadas claves para header, detalles del plan, aviso email incorrecto y fecha de expiración (ES/EN). |
| **Safe area y navegación** | OK | `PlansListPage` y `PlanDetailPage` usan `SafeArea`. Barra de pestañas del plan: 7 opciones en horizontal; en iPhone pequeño puede requerir scroll (pendiente prueba manual, ítem 8). |
| **Consistencia visual** | OK | Cards, iconos naranja para no leídos, bordes solo arriba/abajo y ancho completo aplicados en web e iOS (CONTEXT.md). |

---

## 4. Chat: mensajes no se ven entre móvil y web (corregido)

**Problema:** Los mensajes creados en móvil no se veían en web y viceversa.

**Causa probable:**  
**Errores ocultos:** Si la consulta al stream de mensajes fallaba (permisos, red, etc.), el código devolvía una lista vacía en silencio (`.handleError` devolvía `[]` y el `catch` hacía `Stream.value([])`), por lo que la UI mostraba “sin mensajes” en lugar del error real.  
*Nota:* El índice de un solo campo `createdAt` en la subcolección `messages` **no hace falta** definirlo en `firestore.indexes.json`; Firestore lo crea automáticamente (single-field index). Si lo añades, el deploy devuelve HTTP 400: "this index is not necessary".

**Cambios realizados:**

1. **Manejo de errores en `ChatService.getMessages()`**  
   - En `handleError`: se registra el error y se hace **rethrow** para que el stream emita el error y la UI muestre el estado de error con el botón "Reintentar".  
   - En el `catch` al crear el stream: se devuelve `Stream.error(e)` en lugar de `Stream.value(<PlanMessage>[])`, para que la pantalla de chat muestre el error y no una lista vacía.

**Comprobaciones recomendadas:**

- Abrir el mismo plan en web y en móvil, enviar un mensaje desde uno y comprobar que aparece en el otro.  
- Si algo falla, en la UI de chat debería mostrarse el mensaje de error y "Reintentar"; revisar logs (LoggerService) para el texto completo del error (permisos, red, etc.).

---

## 5. Siguientes pasos

- Ir cerrando los puntos por prioridad (por ejemplo: 1 → 5/6 → 2 → 3 → 7 → resto).
- Después de cambios, volver a probar en simulador y, si es posible, en dispositivo real antes de subir a TestFlight.

Si quieres, podemos bajar al detalle de uno en uno (por ejemplo: primero multi-idioma en las dos páginas, luego invitación y deep link, luego FCM/Info.plist).

---

## 6. Revisión diferencias una a una (Marzo 2026)

Decisión por diferencia: **mantener distinto (A)** o **igualar (B)**.

| # | Diferencia | Decisión | Notas |
|---|------------|----------|--------|
| 1 | Pantalla de entrada (Dashboard web vs PlansListPage iOS) | **A** | Mantener: estrategia por plataforma (PLATFORM_STRATEGY). |
| 2 | Detalle de plan (panel web vs página con pestañas iOS) | **A** | Mantener: consecuencia de la entrada. |
| 3 | Vista calendario (CalendarScreen vs CalendarMobilePage) | **A** | Mantener: adaptación por tamaño. |
| 4 | Offline / Hive / sync (solo móvil) | **A** | Mantener: web siempre online. |
| 5 | FCM push (solo móvil) | **A** | Mantener. |
| 6 | Google Places (Cloud Function web vs API directa móvil) | **A** | Mantener: misma UX, distinta implementación. |
| 7 | Invitación por link / deep link en iOS | **B** | Igualar: implementar deep link. **T259** creada. |
| 8 | Barra de pestañas del plan (7 tabs, scroll en iPhone pequeño) | **A** | Mantener: aceptar scroll. |
| 9 | Diálogos evento/alojamiento (fullscreen vs modal por ancho) | **A** | Mantener: adaptación responsive. |
| 10 | ConnectivityService (web sin plugin vs móvil con plugin) | **A** | Mantener. |

**Pendiente de implementación:** T259 – Deep link invitación iOS (Universal Links o URL scheme).
