## Lista de puntos a corregir en la app

**Objetivo:** tener en un único sitio todos los temas de la app que vamos detectando (bugs, mejoras de UX, textos, diferencias iOS/web) para ir cerrándolos iteración a iteración.

**Última actualización de este documento:** 2026-03-12 (P18 estado personal; P3, P11–P13, P19–P20; checklist P1/P2).

---

### 1. Información del build

- **Versión de la app**: `1.0.0`
- **Origen**: TestFlight / Web
- **Fecha de la ronda de pruebas**: 
- **Build ID (si aplica)**: 

---

### 2. Cómo anotar cada punto

Para cada tema de la app que veas (bug o mejora), intenta rellenar:

- **Plataforma**: iOS / Web / Ambas
- **Pantalla / flujo**: (ej. Lista de planes, Detalle del plan → Calendario, Invitación, Perfil…)
- **Descripción breve**: 1 línea que resuma el problema.
- **Pasos para reproducir**:
  1. …
  2. …
  3. …
- **Resultado esperado**: qué esperabas que pasara.
- **Resultado real**: qué pasa ahora.
- **Notas / capturas**: opcional (enlace o referencia).

---

### 3. Puntos detectados

Usa esta tabla para tener visión rápida del estado de cada tema (los ítems **hecho** se mantienen para trazabilidad).

**Resumen rápido (2026-03-12):** **hecho** 18 · **parcial** 2 · **pendiente** 0 — *hechos: 3–20 salvo 1, 2; parcial: 1, 2 (checklist infra).*

| ID | Plataforma | Pantalla / flujo | Tipo (bug / mejora / copy) | Gravedad (alta / media / baja) | Descripción breve | Estado (pendiente / en curso / hecho / parcial) |
|----|-----------|------------------|-----------------------------|---------------------------------|-------------------|----------------------------------------|
| 1  | iOS       | Notificaciones push / fondo | mejora               | alta                            | Configurar bien APNs y comportamiento de notificaciones push en iOS (FCM) | parcial (checklist `CHECKLIST_IOS_PUSH_DEEPLINKS.md`) |
| 2  | iOS       | Invitación por link        | mejora               | media                           | Implementar deep link en iOS para que los links de invitación abran la app en la pantalla correcta | parcial (mismo checklist)              |
| 3  | iOS       | Barra de pestañas del plan | mejora UX           | baja                            | Revisar barra de pestañas del plan en iPhone pequeño (scroll, legibilidad) | hecho                                  |
| 4  | iOS       | Crear plan / volver        | bug                  | alta                            | Tras crear un plan nuevo, al pulsar atrás se queda pantalla en blanco | hecho                                  |
| 5  | iOS       | Estado inicial del plan    | bug                  | media                           | El estado por defecto de un plan nuevo no es “Planificando” | hecho                                  |
| 6  | iOS       | Cambio de estado del plan  | mejora UX           | media                           | Permitir cambiar el estado desde el icono de estado en Info del plan (derecha de la foto) | hecho                                  |
| 7  | iOS       | Calendario – scroll        | bug / rendimiento    | alta                            | Desplazamiento vertical del calendario muy lento o casi nulo | hecho                                  |
| 8  | iOS       | Card de plan – iconos      | mejora UX           | media                           | Alinear los iconos de la derecha de la card de plan verticalmente | hecho                                  |
| 9  | iOS       | Info plan – títulos campos | mejora visual        | baja                            | Aumentar tamaño de letra de los títulos en el recuadro de Info del plan | hecho                                  |
| 10 | iOS       | Eliminar plan              | mejora funcional     | media                           | Añadir opción visible para eliminar un plan en Info del plan | hecho                                  |
| 11 | iOS       | Info plan – participantes  | mejora visual        | baja                            | Llevar “Participantes” al título del recuadro y eliminar el título extra | hecho                                  |
| 12 | iOS       | Secciones Info (expansibles) | mejora UX         | media                           | Hacer expansibles las secciones Participantes, Avisos y Zona de peligro | hecho                                  |
| 13 | iOS       | Formulario evento – UI     | mejora UX           | media                           | Unificar la UI de todos los campos (descripciones, timezone, localización, etc.) | hecho                                  |
| 14 | iOS       | Eventos → refresco vistas  | bug                  | alta                            | Al crear/editar/borrar evento no se actualizan calendario, resumen, etc. | hecho                                  |
| 15 | iOS       | Página Participantes – barra superior | mejora UX | baja                       | Añadir barra superior verde con título como en el resto de páginas | hecho                                  |
| 16 | iOS       | Chat y Pagos – navegación  | mejora UX           | baja                            | Quitar la flecha que navega a la página inicial en las páginas de Chat y Pagos | hecho                                  |
| 17 | iOS       | Orden de pestañas          | mejora UX           | baja                            | Mover pestaña de Pagos entre Chat y Estadística | hecho                                  |
| 18 | iOS / Web | Estado personal en el plan | mejora funcional     | media                           | Aclarar y exponer cómo cambiar el estado personal (pending → aceptar/rechazar; in → salir); pulir “out” / copy | hecho                                  |
| 19 | iOS       | Form evento – tipo/subtipo | bug / UX           | media                           | Al seleccionar subtipo de evento desaparece el tipo; alinear con lógica de la web | hecho                                  |
| 20 | iOS       | Form evento – formato fecha/hora/duración | mejora UX | media                  | Mejorar contenido / formato visible de campos fecha, hora y duración | hecho                                  |

Puedes añadir más filas a medida que aparezcan nuevos puntos.

**Mejoras recientes fuera de la tabla (referencia):** manual de ayuda en ruta pública `/help` (`HelpManualPage`) accesible desde login y desde dentro de la app (web e iOS); pestaña **Notificaciones del plan** y barra de accesos rápidos en `PlanDetailPage`; diferenciación visual notificaciones leídas/no leídas; en **Mi resumen**, iconos enlace detalle / Maps / URL por evento y alojamiento. *Documentación:* `docs/configuracion/CONTEXT.md` (regla de proximidad de acciones), `docs/especificaciones/CALENDAR_CAPABILITIES.md` (drag & drop solo web).

---

### 4. Detalle de cada punto

#### P1. Notificaciones push iOS (APNs / FCM)

- **Plataforma**: iOS
- **Pantalla / flujo**: Notificaciones push (recepción en segundo plano y al abrir la app)
- **Descripción**: Asegurar que las notificaciones push funcionen bien en iOS (app en primer y segundo plano), con configuración correcta de APNs y FCM.
- **Pasos para reproducir**:
  1. Configurar APNs en Firebase Console para la app iOS (certificado o APNs Auth Key).
  2. Verificar que `GoogleService-Info.plist` está en `ios/Runner/` y apuntando al proyecto correcto.
  3. Probar envío de notificación desde Firebase a un dispositivo con la app en segundo plano y en primer plano.
  4. Observar comportamiento en distintas situaciones (app abierta, en background, cerrada).
- **Resultado esperado**: Las notificaciones llegan de forma fiable en iOS, muestran el contenido correcto y al tocar la notificación se navega al lugar adecuado en la app.
- **Resultado real**: Pendiente de validar en dispositivo real; hay configuración base pero falta revisión completa (ver `REVISION_IOS_VS_WEB.md` § 2.7).
- **Notas / capturas**: Ver también `docs/guias/GESTION_TIMEZONES.md` y `docs/configuracion/REVISION_IOS_VS_WEB.md` para contexto general de iOS. **Checklist de verificación:** `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (sección P1).
- **Estado**: parcial — checklist documentado; falta validación completa en dispositivo y proyecto Firebase/APNs.

#### P2. Deep link de invitación en iOS

- **Plataforma**: iOS
- **Pantalla / flujo**: Invitación por link → aceptación de invitación → entrar al plan
- **Descripción**: Permitir que, al abrir un link de invitación en iOS (por ejemplo desde un correo), se abra directamente la app en el flujo correcto de invitación/plan.
- **Pasos para reproducir**:
  1. Enviar una invitación a un usuario de pruebas con dispositivo iOS.
  2. Abrir el link desde Mail u otra app en el iPhone.
  3. Observar si abre solo Safari/web o si abre la app nativa.
- **Resultado esperado**: El link abre la app Planazoo en iOS y lleva al usuario a la pantalla de invitación / plan correspondiente (similar a la experiencia en web).
- **Resultado real**: Actualmente el flujo de invitación funciona, pero los links no abren la app nativa en iOS (falta configurar Universal Links o URL scheme). Ver `REVISION_IOS_VS_WEB.md` § 2.3 y § 2.9.
- **Notas / capturas**: Tarea relacionada T259 (deep link invitación iOS). **Checklist:** `docs/configuracion/CHECKLIST_IOS_PUSH_DEEPLINKS.md` (sección P2).
- **Estado**: parcial — checklist documentado; falta configurar dominio/AASA y Associated Domains en Xcode.

#### P3. Barra de pestañas del plan en iPhone pequeño

- **Plataforma**: iOS
- **Pantalla / flujo**: `PlanDetailPage` → barra de pestañas (Info, Mi resumen, Calendario, Participantes, Chat, Pagos, Stats, Notificaciones)
- **Descripción**: En iPhones pequeños (ej. SE) las **8** pestañas (incl. notificaciones del plan) pueden estar muy apretadas o requerir demasiado scroll horizontal.
- **Pasos para reproducir**:
  1. Abrir la app en un iPhone de pantalla pequeña o simulador equivalente.
  2. Entrar en el detalle de un plan y revisar la barra de pestañas en vertical.
  3. Probar el scroll horizontal, tap en cada pestaña y legibilidad de las etiquetas.
- **Resultado esperado**: Las pestañas son legibles y usables (aunque haya algo de scroll), sin que el usuario se pierda o tenga que hacer demasiados gestos para cambiar de sección.
- **Resultado real**: Pendiente de prueba manual; se sospecha que puede quedar justo de espacio y merecer un ajuste de diseño (solo iconos, pestaña “Más”, etc.). Ver `REVISION_IOS_VS_WEB.md` § 2.5.
- **Notas / capturas**: Documentar con capturas de pantalla en distintos dispositivos para decidir el ajuste de UI.
- **Estado**: pendiente

#### P4. Crear plan y volver deja pantalla en blanco

- **Plataforma**: iOS
- **Pantalla / flujo**: Crear plan → finalizar → volver atrás
- **Descripción**: Al crear un plan nuevo y pulsar la flecha de volver, la pantalla se queda en blanco, mientras que con un plan ya existente funciona bien.
- **Pasos para reproducir**:
  1. Desde la lista de planes en iOS, crear un plan nuevo.
  2. Completar el formulario y guardar.
  3. Pulsar la flecha de volver.
- **Resultado esperado**: Volver a la lista de planes o a la pantalla anterior mostrando el nuevo plan sin pantallas en blanco.
- **Resultado real**: La pantalla se queda en blanco tras crear el plan y pulsar volver.
- **Notas / capturas**: Revisar navegación tras creación de plan en iOS y estado inicial de la ruta.
- **Estado**: hecho  
  **Solución aplicada**: en `PlanDetailPage`, la flecha de volver ahora hace `Navigator.pop()` si la pila puede hacer pop y, si no (`canPop == false`), hace `pushReplacement` a `PlansListPage`. Así, tras crear un plan nuevo, volver nunca deja la app en pantalla negra sino en la lista de planes.

#### P5. Estado inicial del plan = “Planificando”

- **Plataforma**: iOS (afecta al dominio compartido)
- **Pantalla / flujo**: Crear plan → estado del plan
- **Descripción**: El estado por defecto de un plan nuevo no es “Planificando” y aparece como “desconocido”.
- **Pasos para reproducir**:
  1. Crear un plan nuevo en la app iOS.
  2. Ir a Info del plan y revisar el estado.
- **Resultado esperado**: Los planes nuevos se crean con estado “Planificando”.
- **Resultado real**: El estado aparece como “desconocido” u otro valor no deseado.
- **Notas / capturas**: Revisar valor por defecto en modelo `Plan` y flujo de creación en iOS.
- **Estado**: hecho  
  **Solución aplicada**: se confirmó que los flujos de creación (`PlansListPage` en móvil y `WdCreatePlanModal` en dashboard) crean planes con `state: 'planificando'` y que el modelo `Plan` aplica por defecto `'planificando'` cuando `state` viene nulo. Además, `PlanStateService.getStateDisplayInfo` normaliza estados nulos/vacíos o legacy (`'borrador'`) a `'planificando'`, evitando “DESCONOCIDO” en planes nuevos o antiguos.

#### P6. Cambio de estado desde icono en Info del plan

- **Plataforma**: iOS
- **Pantalla / flujo**: Detalle del plan → pestaña Info
- **Descripción**: Se quiere poder cambiar el estado del plan tocando el icono de estado que está a la derecha de la foto en Info del plan.
- **Pasos para reproducir**:
  1. Abrir un plan en iOS y entrar en Info del plan.
  2. Tocar el icono de estado a la derecha de la foto.
- **Resultado esperado**: Al tocar el icono se abre el flujo de cambio de estado del plan.
- **Resultado real**: El menú usaba `RelativeRect` fijo y no posicionaba bien el `showMenu` en móvil.
- **Notas / capturas**: `InkWell` + `Builder` sobre el badge; `_openPlanStateTransitionMenu` con `RelativeRect.fromRect` respecto al `Overlay`.
- **Estado**: hecho  
  **Solución aplicada**: `wd_plan_data_screen.dart` — helper `_openPlanStateTransitionMenu`; una sola transición llama a `_changePlanState`; varias abren menú contextual anclado al badge.

#### P7. Scroll vertical del calendario muy lento

- **Plataforma**: iOS
- **Pantalla / flujo**: Calendario del plan en iOS
- **Descripción**: El desplazamiento vertical en el calendario es extremadamente lento o casi inexistente.
- **Pasos para reproducir**:
  1. Abrir un plan con varios eventos en el calendario.
  2. Intentar desplazarse verticalmente por la vista de calendario.
- **Resultado esperado**: El scroll vertical debe ser fluido y responder al gesto del usuario.
- **Resultado real**: El scroll apenas se mueve o va muy lento.
- **Notas / capturas**: Posible conflicto con `NeverScrollableScrollPhysics`, `NestedScrollView` o listeners de gestos.
- **Estado**: hecho  
  **Solución aplicada**: en `CalendarMobilePage` se ajustó la sincronización entre `_hoursScrollController` y `_dataScrollController` usando `_isAutoScrolling` y comprobando la diferencia de offsets antes de hacer `jumpTo`, eliminando `setState()` en los listeners. Así se evitan “peleas” entre scrolls y el desplazamiento vertical es más fluido en iOS.

#### P8. Iconos de la card de plan alineados verticalmente

- **Plataforma**: iOS (pero afecta al widget compartido de cards)
- **Pantalla / flujo**: Lista de planes (cards de plan)
- **Descripción**: Los iconos de la derecha de la card de plan deben distribuirse verticalmente, no apelotonados.
- **Pasos para reproducir**:
  1. Abrir la lista de planes en iOS.
  2. Observar la disposición de los iconos en la parte derecha de cada card.
- **Resultado esperado**: Iconos alineados verticalmente con espaciado consistente y buena legibilidad.
- **Resultado real**: Corregido: fila de card con `CrossAxisAlignment.center`, separador y columna de iconos con espacio fijo.
- **Notas / capturas**: `wd_plan_card_widget.dart` y `pg_plans_list_page.dart` (lista iOS).
- **Estado**: hecho  
  **Solución aplicada**: `SizedBox` entre iconos, altura del separador ~72, `mainAxisAlignment: spaceEvenly` en la columna de acciones.

#### P9. Tamaño de títulos en Info del plan

- **Plataforma**: iOS
- **Pantalla / flujo**: Detalle del plan → Info
- **Descripción**: Los títulos de los campos dentro del recuadro de Info del plan tienen un tamaño de letra algo pequeño.
- **Pasos para reproducir**:
  1. Entrar en Info de un plan.
  2. Observar los títulos de cada campo dentro del recuadro (fechas, destino, etc.).
- **Resultado esperado**: Títulos con tamaño de fuente ligeramente superior para mejor legibilidad.
- **Resultado real**: Subidos de 13 → 14 px en labels de campos Info y resumen del plan.
- **Notas / capturas**: `_buildDateTile`, `_buildDropdownTile`, `_buildBudgetField`, timezone, resumen nombre/descripción, tiles solo lectura (organizador).
- **Estado**: hecho  
  **Solución aplicada**: `wd_plan_data_screen.dart` — `labelStyle` / títulos de bloque a **14** donde aplica.

#### P10. Añadir opción de eliminar plan en Info

- **Plataforma**: iOS
- **Pantalla / flujo**: Detalle del plan → Info
- **Descripción**: La “Zona de peligro” existía pero **al final** del scroll en móvil; muchos usuarios no la veían.
- **Pasos para reproducir**:
  1. Abrir Info de un plan en iOS como organizador.
  2. Sin hacer scroll largo, localizar eliminar plan.
- **Resultado esperado**: Opción visible con confirmación (contraseña, mismo flujo que antes).
- **Resultado real**: Bloque de peligro visible **arriba** del contenido de Info cuando `PlanDataScreen` va embebido en `PlanDetailPage` (`showAppBar: false`); en dashboard web (`showAppBar: true`) se mantiene al final como antes.
- **Notas / capturas**: Textos con `planInfoDangerZoneTitle` / `planInfoDangerZoneSubtitle` (l10n). Limpieza: un solo `_deletePlan` en estado y mapeo de errores en extensión.
- **Estado**: hecho  
  **Solución aplicada**: `wd_plan_data_screen.dart` — si `!showAppBar`, insertar `_buildDeleteButton()` justo después del resumen del plan; si `showAppBar`, solo al final. `pg_plan_detail_page` (default): `onPlanDeleted` para volver a la lista.

#### P11. Recuadro de participantes en Info

- **Plataforma**: iOS
- **Pantalla / flujo**: Detalle del plan → Info → bloque de participantes
- **Descripción**: En Info del plan, el recuadro de participantes debería llevar el título “Participantes” dentro del propio recuadro, eliminando un título duplicado encima.
- **Pasos para reproducir**:
  1. Entrar en Info del plan.
  2. Observar el bloque de participantes y sus títulos.
- **Resultado esperado**: Título “Participantes” integrado en el recuadro, consistente con el resto de campos.
- **Resultado real**: Título externo + recuadro sin título propio.
- **Notas / capturas**: Cabecera del recuadro con título + ayuda + chevron; cuerpo con lista / vacío.
- **Estado**: hecho  
  **Solución aplicada**: `wd_plan_data_screen.dart` — bloque Participantes con título dentro del card y patrón alineado con el resto de secciones Info.

#### P12. Secciones Participantes / Avisos / Zona de peligro expansibles

- **Plataforma**: iOS
- **Pantalla / flujo**: Detalle del plan → Info
- **Descripción**: Hacer que las secciones “Participantes”, “Avisos” y “Zona de peligro” sean expansibles/plegables para reducir ruido visual.
- **Pasos para reproducir**:
  1. Entrar en Info del plan.
  2. Revisar bloques de Participantes, Avisos y Zona de peligro.
- **Resultado esperado**: Cada bloque se puede expandir/plegar, mostrando solo títulos cuando están contraídos.
- **Resultado real**: Todas las secciones están siempre abiertas.
- **Notas / capturas**: Posible uso de `ExpansionTile` o similar.
- **Estado**: pendiente

#### P13. Formulario de evento – unificar UI de campos

- **Plataforma**: iOS
- **Pantalla / flujo**: Formulario de creación/edición de evento
- **Descripción**: Algunos campos (ej. timezone, localización) no siguen la misma UI/UX que otros campos del formulario (descripción, ayudas, layout).
- **Pasos para reproducir**:
  1. Abrir formulario de evento en iOS.
  2. Comparar el aspecto de campos como descripción, timezone y localización.
- **Resultado esperado**: Todos los campos del formulario comparten patrón visual y de interacción (labels, helper text, etc.).
- **Resultado real**: Hay campos que usan una UI distinta o menos clara.
- **Notas / capturas**: Helper `_buildTimezoneFieldOnBorder` (título sobre borde como `_buildLabelOnBorderField`); bloque vuelo reutiliza el mismo patrón en columna estrecha.
- **Estado**: hecho  
  **Solución aplicada**: `wd_event_dialog.dart` — timezones de evento general y de llegada (no avión) con el mismo estilo que descripción/límite; dropdown sin `Container` duplicado tipo login.

#### P14. Refresco del calendario y resumen tras cambios de eventos

- **Plataforma**: iOS
- **Pantalla / flujo**: Calendario / Mi resumen / Info tras crear/editar/borrar evento
- **Descripción**: Al crear, modificar o eliminar un evento en iOS, el calendario, el resumen y otras vistas relacionadas no se actualizan automáticamente.
- **Pasos para reproducir**:
  1. Crear/editar/borrar un evento en iOS.
  2. Volver al calendario o a Mi resumen.
- **Resultado esperado**: Las vistas se actualizan inmediatamente reflejando el cambio.
- **Resultado real**: No se ve actualizado hasta que se fuerza un refresco más fuerte (salir y volver, etc.).
- **Notas / capturas**: Revisar providers/streams y notificación de cambios en iOS.
- **Estado**: hecho  
  **Solución aplicada**: en `CalendarMobilePage` se añadió `_invalidateEventProviders()` y se usa en `onSaved`/`onDeleted` de los diálogos de eventos y alojamientos. Este helper llama a `calendarNotifier.refreshEvents()`, invalida `planStatsProvider` y hace `setState()`, de forma que calendario, resumen y vistas relacionadas se actualizan inmediatamente tras crear/editar/eliminar eventos en iOS.

#### P15. Barra superior verde en página Participantes

- **Plataforma**: iOS
- **Pantalla / flujo**: Página de participantes del plan
- **Descripción**: La página de participantes no tiene la misma barra superior verde con título que otras pantallas.
- **Pasos para reproducir**:
  1. Navegar a la página de participantes en iOS.
  2. Comparar encabezado con otras páginas (Info, Calendario, etc.).
- **Resultado esperado**: Barra superior consistente (verde con título) como el resto de secciones del plan.
- **Resultado real**: En pestaña Participantes embebida no había barra; ahora sí.
- **Notas / capturas**: Mismo estilo que `_buildParticipantsHeader()` (color2, 48px).
- **Estado**: hecho  
  **Solución aplicada**: `ParticipantsScreen` — si `isCompact && !embedInScaffold`, `Column(_buildParticipantsHeader(), Expanded(gradientBox))`.

#### P16. Flecha de navegación en Chat y Pagos

- **Plataforma**: iOS
- **Pantalla / flujo**: Pestañas Chat y Pagos del plan (`PlanDetailPage`)
- **Descripción**: En la barra superior de Chat y Pagos aparecía una flecha (leading implícito del `AppBar`) que hacía **pop** de toda la ruta y sacaba a la lista de planes, en lugar de limitarse al cambio de pestaña.
- **Pasos para reproducir**:
  1. Entrar en Chat y luego en Pagos desde el detalle de un plan.
  2. Observar la barra superior y la flecha de navegación.
- **Resultado esperado**: No debería haber una flecha que saque fuera del flujo del plan; navegación consistente con el resto de pestañas.
- **Resultado real**: Corregido al desactivar el leading implícito cuando el contenido está embebido en el detalle.
- **Notas / capturas**: Causa: `Navigator.canPop` es true bajo `PlanDetailPage`, y el `AppBar` interno mostraba back. **Dashboard web** no pasa el flag (sigue el comportamiento por defecto).
- **Estado**: hecho  
  **Solución aplicada**: parámetro `embedInPlanDetail: true` en `PlanChatScreen`, `PaymentSummaryPage` y `PlanStatsPage` (misma causa en Estadísticas); con `automaticallyImplyLeading: false` en esos `AppBar` cuando aplica. `PlanDetailPage` pasa el flag al incrustar esas pestañas.

#### P17. Orden de pestañas: colocar Pagos entre Chat y Estadística

- **Plataforma**: iOS
- **Pantalla / flujo**: Barra de pestañas de `PlanDetailPage`
- **Descripción**: Se desea que la pestaña de Pagos esté situada entre Chat y Estadística.
- **Pasos para reproducir**:
  1. Abrir detalle de un plan en iOS.
  2. Revisar el orden actual de pestañas.
- **Resultado esperado**: Orden: Info, Mi resumen, Calendario, Participantes, Chat, Pagos, Stats (y Notificaciones del plan al final del bloque; ver solución).
- **Resultado real**: ~~Pagos al final del todo~~ → **corregido** (ver solución).
- **Notas / capturas**: `PlanNavigationBar` (`wd_plan_navigation_bar.dart`).
- **Estado**: hecho  
  **Solución aplicada**: en `lib/widgets/plan/wd_plan_navigation_bar.dart` el orden de `NavigationOption` es: Info, Mi resumen, Calendario, Participantes, Chat, **Pagos**, **Stats**, Notificaciones.

#### P18. Cómo cambiar mi estado en el plan (in / out)

- **Plataforma**: iOS (y mismo patrón en web donde aplique el chip)
- **Pantalla / flujo**: Estado personal dentro de un plan (lista de planes, card de plan, barra superior del plan, participantes)
- **Descripción**: Aclarar pending / dentro / fuera y unificar feedback al pulsar **fuera** (rechazado).
- **Pasos para reproducir**:
  1. Entrar en un plan como participante con invitación pendiente o ya dentro del plan.
  2. Pulsar el chip de estado en card, barra superior o lista de planes.
- **Resultado esperado**: Textos comprensibles en español en chips compactos; ayuda contextual; al pulsar **fuera**, mensaje coherente con Notificaciones.
- **Resultado real**: Cumplido (ver solución).
- **Notas / capturas**: `plan_status_chip_actions.dart`; chips en `PlanCardWidget`, `PlansListPage`, `PlanUserStatusLabel`, `ParticipantsScreen`. Ayuda: `HelpContextIds.planDetailMyStatus`, seed `plan_detail.my_status`. Doc: `docs/ux/ESTADO_USUARIO_EN_EL_PLAN.md`.
- **Estado**: hecho  
  **Solución aplicada**: etiquetas cortas ES (**dentro** / **fuera** / **pend.**); **?** en AppBar del plan con texto de ayuda; `Semantics` en el chip; SnackBar `planStatusRejectedSnackbar` al pulsar **fuera** en AppBar, card, lista iOS y fila “yo” en participantes; corrección lógica: solo `status == 'pending'` cuenta como pendiente (eliminado `needsResponse` ambiguo que incluía `null` y duplicaba con `isPending`).

#### P19. Formulario de evento – tipo y subtipo

- **Plataforma**: iOS
- **Pantalla / flujo**: Formulario de evento (tipo/subtipo)
- **Descripción**: Al seleccionar un subtipo de evento, el tipo deja de mostrarse o desaparece de la UI; debería comportarse como en web.
- **Pasos para reproducir**:
  1. Abrir formulario de evento en iOS.
  2. Seleccionar un tipo de evento y luego un subtipo.
- **Resultado esperado**: Tipo y subtipo se muestran de forma coherente, manteniendo el contexto.
- **Resultado real**: El tipo parece desaparecer al elegir subtipo.
- **Notas / capturas**: Sustituido `Row`+`Expanded` por `Wrap` para que tipo y subtipo no compitan por ancho.
- **Estado**: hecho  
  **Solución aplicada**: `wd_event_dialog.dart` — `_buildTypeSubtypeSelector`: chips de tipo y subtipo en `Wrap` cuando la selección está colapsada.

#### P20. Formulario de evento – contenido de fecha, hora y duración

- **Plataforma**: iOS
- **Pantalla / flujo**: Formulario de evento (campos fecha, hora, duración)
- **Descripción**: El contenido visible en los campos de fecha, hora y duración debería ser más claro/consistente (formato, placeholders, etc.).
- **Pasos para reproducir**:
  1. Abrir formulario de evento en iOS.
  2. Observar campos fecha, hora y duración antes y después de seleccionar valores.
- **Resultado esperado**: Valores legibles, con formato consistente y fácil de entender.
- **Resultado real**: Formato y contenido mejorables.
- **Notas / capturas**: Claves l10n `eventDurationFormatMinutes`, `eventDurationFormatOneHour`, `eventDurationFormatHoursOnly`, `eventDurationFormatHoursMinutes` en `app_es.arb` / `app_en.arb`.
- **Estado**: hecho  
  **Solución aplicada**: hora con `DateFormatter.formatTimeOnly`; duración con `_formatDuration` usando `AppLocalizations` (es/en coherentes).


