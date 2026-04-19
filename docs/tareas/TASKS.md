# 📋 Lista de Tareas - Planazoo

> Consulta las normas y flujo de trabajo en `docs/configuracion/CONTEXT.md`.  
> **Tareas completadas:** ver `docs/tareas/COMPLETED_TASKS.md`.  
> **Índice de documentos por tarea (Txxx_*.md):** ver `docs/tareas/README_TAREAS.md`.

**Siguiente código de tarea: T267**

**📊 Resumen (solo pendientes):**
- **Mejoras UI/UX:** T194-T214, T226, T231, T237, T251 (widgets, info plan, calendario, cards, modales, estética forms)
- **Administración:** T183-T191, T223 (vista admin, export CSV, seed, espacio admin RUD toda la BD, T188 en progreso)
- **Auth / Perfil:** T159-T162, T173, T174, T226-T228, T232 (permisos Firestore, verificación, perfil, registro, modales)
- **Seguridad avanzada:** T166-T172 (2FA, token refresh, legal, etc.)
- **Calendario:** T35, T37, T38, T88, T96-T99, T182, T199, T210-T212, T225, T246, T238, T242, T243, T250 (campos tipo/subtipo)
- **Offline:** T56-T62
- **Permisos:** T64, T66, T67
- **Timezones:** T40-T45
- **Funcionalidades / Producto:** T20, T120-T122, T131-T136, T157-T158, T165, T190, T192, T181, T150, T224, T233, T234, T252, T254 (pantalla bienvenida), T256 (implementar Fastlane), T257 (revisión web vs iOS), T258 (icono app), T259 (deep link invitación iOS), T260 (sistema multi-moneda), **T262 (notas, plantillas, lista preparación/mini-tareas, nueva pestaña), T263-T266 (items 63/64/65/98 de lista QA)**, etc.
- **Pagos MVP:** T217-T222 (ver docs/producto/PAGOS_MVP.md).

**Total aproximado: ~99 tareas pendientes** (las completadas están en COMPLETED_TASKS.md; los códigos no se reutilizan).

**Preparación pruebas con familia:** Ver `docs/configuracion/EVALUACION_PRIMERAS_PRUEBAS_FAMILIA.md`. Ítems de prioridad alta (l10n lista planes/invitación, navegación al plan en móvil, Safe area, timezones Egipto+Londres) implementados; checklist §4 pendiente de ejecutar antes de invitar.

---

## 📋 Reglas del Sistema de Tareas

- **Códigos únicos** (T1, T2…); no reutilizar al eliminar.
- **Orden de prioridad:** por posición en el documento.
- **Estados:** Pendiente → En progreso → Completada. Completadas se mueven a `COMPLETED_TASKS.md`.
- **Aprobación:** confirmación del usuario antes de marcar completada.
- **Grupos:** tareas relacionadas se implementan y prueban juntas cuando tiene sentido.
- **Arquitectura:** Offline First y Plan Frankenstein según `CONTEXT.md`.

### Documentos de especificación / plan

- **Crear tarea:** Se puede crear un documento de especificación o plan (`Txxx_NOMBRE.md` o nombre descriptivo) en `docs/tareas/`. Si existe, **hay que documentarlo en la fila de la tarea** en este archivo (ej.: «Especificación en `docs/tareas/Txxx_*.md`» o «Plan en …»).
- **Durante la tarea:** Actualizar el documento de especificación cuando cambien criterios, fases o decisiones.
- **Al completar la tarea:** Mover la entrada a `COMPLETED_TASKS.md` y **mover el documento de especificación** a `docs/tareas/archivo/` (conservar el nombre del archivo para trazabilidad). Así la carpeta `docs/tareas/` solo contiene especificaciones de tareas pendientes o en curso.

---

## 📦 Grupos de tareas (referencia)

- **Grupos 1-3:** Tracks, filtros, parte común/personal (mayoría completados).
- **Grupo 4:** Offline (T56-T62, T63-T64).
- **Grupo 5:** Timezones (T40-T45) — **núcleo ya en la app**; las filas **T40–T45 en §8** siguen listadas hasta **cierre formal** (QA / migración / docs). Evitar duplicar el mensaje «completadas» aquí y en §8 sin alinear.
- **Grupo 6:** Funcionalidades avanzadas (T77-T90; varias completadas).
- **Otros:** Admin, seguridad, UI/UX, producto.

---

## 🗂️ Tareas pendientes (ordenadas por área)

### 0. Plan — notas (nueva pestaña, alta prioridad)

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T262** | **Notas del plan (comunes y personales) + plantillas + lista de preparación:** Apartado al mismo nivel que Info, Resumen, etc. Bloque **Preparación** (título l10n); lista común con permisos configurables por **organizador** (solo él / participantes elegidos / todos). Plantillas; Firestore + reglas, web+iOS. Especificación en `docs/tareas/T262_NOTAS_PLAN_COMUNES_PERSONALES.md`. **Estado real:** fase 1 implementada (`lib/features/plan_notes/`); pendiente plantillas UI, checklist pruebas y cierre con aprobación (detalle en ese .md). | **Alta** |

---

### 1. Mejoras UI/UX – Widgets, Info plan, Calendario, Cards

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T204** | Info plan: imagen a media pantalla; nombre y descripción en layout acordado. | Media |
| **T205** | Modal cambio de estado del plan: estilo básico, mensaje explicando implicación. | Media |
| **T208** | Modal evento: fecha fin por duración o manual; campo a la derecha de Duración. | Media |
| **T210** | Calendario: revisar drag and drop y desplazamiento móvil. | Media |
| **T211** | Calendario: copiar/pegar con Ctrl+mouse; corregir colocación a la altura correcta. Complementa T35. | Media |
| **T212** | Calendario en pantalla completa por defecto. | Media |
| **T226** | **UI estándar modales:** Definir y aplicar que los modales tengan barra superior en color verde con el título del modal y, si aplica, botones o textos. Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T231** | Info plan: Revisar el apartado «Avisos»: comentar, evaluar si tiene sentido mantenerlo y tomar una decisión en ese momento (mantener / simplificar / quitar). Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Baja |
| **T237** | Página Info del plan: (1) Optimizar para ver más datos; estructura pensada sobre todo para móvil. (2) Sobre la zona de Avisos: comentar y tomar decisión en ese momento (ver T231). (3) El estado del plan debería verse en la barra superior verde. Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T244** | **Mejorar visualización de los avisos en la Info del plan:** Revisar y mejorar la presentación del timeline de avisos (tipografía, espaciado, diferenciación por tipo urgente/importante/info, legibilidad en móvil, orden y agrupación). Mantener funcionalidad actual (publicar, ver, eliminar). Origen: decisión de mantener avisos (T231); notificaciones ya funcionando vía Cloud Function. | Media |
| **T251** | **Estética estándar en formularios de eventos y alojamientos:** Adecuar el modal de eventos (`wd_event_dialog.dart`) y el modal de alojamientos (`wd_accommodation_dialog.dart`) a la estética estándar de la app (barra verde, espaciado, tipografía, campos con formato "título sobre el borde", botones y estados coherentes con GUIA_UI y con el resto de modales). Complementa T226 (UI estándar modales). | Media |

*Nota: T214 se ha fusionado en T213 (tamaño + contraste).*

---

### 2. Calendario y eventos (lógica / interacción)

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T35** | Copiar y pegar eventos (Ctrl+mouse, etc.); colocación correcta al pegar. Ver T211 para refinamientos. | Media |
| **T37** | Gestión de eventos en borrador: visualización, filtro mostrar/ocultar, diferenciación respecto a confirmados. | Media |
| **T38** | Eliminar opción "Alojamiento" del diálogo de eventos; alojamientos en su propio diálogo. | Media |
| **T88** | Rediseño arquitectura del calendario en capas (Base → Tracks → Eventos → Interacciones). | Media |
| **T96** | Refactoring CalendarScreen (en progreso parcial). Completar componentes pendientes. Plan en `docs/tareas/T96_REFACTORING_PLAN.md`. | Media |
| **T97** | Tests de integración para funcionalidades críticas del calendario. | Media |
| **T98** | Plan de pruebas detallado del calendario. | Baja |
| **T99** | Documentación de API del calendario. | Baja |
| **T182** | Afinar UI de calendario en W28: celdas, tipografía, espaciado, tooltips. | Media |
| **T215** | Mover un evento de un plan a otro: permitir cambiar el plan al que pertenece un evento (UI + lógica + permisos). Relacionado con buzón de eventos por email y asignación a plan. | Media |
| **T225** | **Búsqueda de lugar con Google Places API:** Integrar autocompletado y Place Details para **alojamientos** y **eventos**. Plan de fases en `docs/tareas/T225_GOOGLE_PLACES_PLAN.md`. Requiere: API key (Places API), paquete Flutter, variable de entorno, UI de búsqueda + mapeo a modelo. Coste: ~10k Place Details/mes gratis. **En progreso** (Fase 1: dependencia y API key). | Media |
| **T246** | **Rellenar evento desplazamiento por número de vuelo o tren:** En evento tipo Desplazamiento, campo opcional "Número de vuelo" (ej. IB6842) o "Número de tren"; API devuelve origen, destino, horarios; rellenar descripción y fecha/hora del evento. Plan y APIs en `docs/tareas/T246_DESPLAZAMIENTO_POR_NUMERO_VUELO_TREN.md`. Fase 1: vuelos (ej. AviationStack); Fase 2 opcional: trenes (Renfe, etc.). | Media |
| **T247** | **Eventos conectados a proveedores:** Marcar eventos que se rellenan desde APIs externas (Amadeus, email, etc.) con metadatos de conexión, mostrar un badge/indicador en calendario y modal, y al cambiar campos sincronizados (fecha/hora, duración, número de vuelo, etc.), avisar al usuario de que se perderá la conexión, permitiendo elegir entre desconectar y mantener el cambio o deshacer el cambio y mantener la conexión. Testing y docs: ver `docs/tareas/T247_EVENTOS_CONECTADOS.md`. | Media |
| **T238** | **(parcial)** Modal crear evento: (1) ~~Barra verde superior con título.~~ ✅ Hecho. (2) Mejorar visualización de las opciones «General» y «Mi información». (3) Evaluar si el texto «Puedes editar esta información» es necesario. (4) Hacer muy rápido y fácil definir el evento — *decidir al abordar la tarea*: flujo corto con «Más opciones» vs todos los campos visibles reordenados, etc. (5) Orden de aparición de los campos mejorado. Relacionado con T208 (duración/hora concreta). Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T242** | **(parcial)** Página Calendario: (1) ~~Eliminar la opción «perspectiva de usuario».~~ ✅ Hecho. (2) Agrupar las opciones de la barra en un menú categorizado; revisar cuáles son necesarias. (3) Añadir menú de filtros de eventos: todos, borrador. Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T243** | Copiar planes, eventos y alojamientos: (1) Revisar si ya existe tarea (T35, T211 para eventos). (2) Crear ambas opciones: (a) copiar eventos y alojamientos dentro del mismo plan (pegar en el plan actual); (b) duplicar plan entero (plan nuevo con eventos y alojamientos copiados). Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T250** | **Definir campos por combinación tipo-subtipo de evento:** Para cada par tipo/subtipo (Desplazamiento/Avión, Desplazamiento/Taxi, Restauración/Comida, etc.), especificar qué campos son visibles, editables, obligatorios u opcionales, y en qué contexto (crear vs editar, rol del usuario). Documentar en `docs/especificaciones/EVENT_FORM_FIELDS.md` o anexo; alinear después el formulario `wd_event_dialog.dart` con esa definición. | Media |
---

### 3. Administración y datos

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T183** | Vista administrativa de planes y participaciones (acceso desde W1): listar planes, participantes, exportar. | Media |
| **T184** | Exportar datos administrativos a CSV (planes/eventos/alojamientos), UTF-8, cabeceras localizadas. | Media |
| **T185** | Seed automático de usuarios de prueba desde USUARIOS_PRUEBA.md (Firebase Auth + users). | Media |
| **T186** | Limpieza/cierre módulo legacy de permisos (plan_permissions, etc.) y limpieza al borrar plan. | Media |
| **T187** | Herramienta admin para eliminar todos los datos de un usuario (GDPR). | Baja |
| **T188** | Sistema de gestión administrativa — **En progreso** (Fase 1 hecha; Fase 2: _adminCreatedBy, scripts, doc). | Alta |
| **T191** | Completar UserId del administrador en ADMINS_WHITELIST.md. | Baja |
| **T223** | **Espacio admin para gestionar toda la BD (RUD + huérfanos):** Panel desde el que un administrador pueda **leer** todos los documentos de Firestore (y listar usuarios Auth), **actualizar de forma masiva** y **eliminar** documentos concretos. Incluye: (1) eliminar un usuario completo con todos sus datos relacionados (Auth + Firestore, vía UserService.deleteAllUserData o equivalente con Admin SDK); (2) **detectar y listar documentos huérfanos** — documentos que referencian entidades ya eliminadas (p. ej. `plan_participations` con `userId` o `planId` inexistente, `events` con `planId` inexistente, `event_participants` con `eventId` o `userId` inexistente, `plan_invitations`/`plan_permissions` con plan o usuario borrado). El panel debe permitir revisar esos huérfanos y eliminarlos en lote o uno a uno. La (C) de crear no es prioritaria (se hace desde la app). Relacionado con T183, T187, T188. | Alta |

---

### 4. Auth, perfil y soporte

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T159** | Corregir permisos Firestore para event_participants tras logout/login. | Alta |
| **T160** | Mostrar "Reenviar verificación" solo cuando sea necesario. | Media |
| **T162** | Traducir mensajes de error en auth_service (códigos en lugar de texto; UI traduce). | Media |
| **T173** | Refinar UX de perfil: modal editar, cabecera nombre+email, foto de perfil, quitar botones obsoletos. | Media |
| **T174** | Definir canal de soporte para cambios de email (landing/FAQ/formulario); actualizar modal perfil. | Baja |
| **T227** | Página de registro: (1) El campo nombre debería ser «nombre y apellidos». (2) Añadir control de campos rellenados: validación (no permitir enviar si faltan obligatorios) e indicador de progreso (ej. «X/Y campos completados» o barra). (3) Mejorar el recuadro de requisitos de contraseña (no debe ocupar toda la pantalla). Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T228** | Email de verificación (nuevo registro): (1) Contenido en idioma del usuario: versiones ES y EN. (2) Subject incluir nombre de la app (ej. «Verifica tu email en Planazoo» / «Verify your email in Planazoo»). (3) Firma del correo tipo «Equipo Planazoo». Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. Relacionado con T176. | Media |
| **T232** | Perfil usuario: (1) Añadir todas las zonas horarias del mundo con lista curada y etiquetas legibles (ej. «Madrid (Europe/Madrid)», «Buenos Aires (America/Argentina/Buenos_Aires)»). (2) Una vez seleccionada, visualizar la selección en el menú «Zona horaria». (3) Mostrar la zona horaria en la info del usuario en W6. (4) Mostrar el idioma seleccionado en el menú de idioma. Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |

---

### 5. Seguridad avanzada

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T166** | Implementar 2FA (Two Factor Authentication). | Media |
| **T167** | Token refresh automático. | Media |
| **T168** | Detección de dispositivos sospechosos. | Baja |
| **T169** | Encriptación de datos sensibles en Firestore. | Media |
| **T170** | Logging sin datos sensibles; no exponer emails en logs/errores. | Media |
| **T171** | Documentos legales (Términos, Política de Privacidad). | Alta (MVP) |
| **T172** | Personalizar flujo web de restablecimiento de contraseña. | Media |

---

### 6. Infraestructura Offline (Grupo 4)

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T56** | Base de datos local (SQLite/Hive, CRUD, migración desde Firestore). | Alta |
| **T57** | Cola de sincronización (operaciones pendientes, retry, indicadores). | Alta |
| **T58** | Resolución de conflictos (timestamp, último cambio gana, notificación). | Media |
| **T59** | Indicadores de estado offline en UI. | Media |
| **T60** | Sincronización en tiempo real (listeners Firestore). | Alta |
| **T61** | Notificaciones push offline. | Media |
| **T62** | Testing exhaustivo Offline First. | Media |

> **Nota (2026-04-08):** La verificación de lista **ítem 58** («offline first» móvil) quedó **cerrada** documentalmente con arquitectura **Firestore-first** + réplica Hive + `current_user` — ver [TESTING_OFFLINE_FIRST.md](../testing/TESTING_OFFLINE_FIRST.md), [LISTA_PUNTOS_CORREGIR_APP.md](../testing/LISTA_PUNTOS_CORREGIR_APP.md) y regresión **REG-2026-022** en [TESTING_CHECKLIST.md](../configuracion/TESTING_CHECKLIST.md) §12.3. Las tareas **T56–T62** siguen siendo roadmap (cola Hive explícita, pruebas amplias, etc.); el **ítem 65** de la lista es necesidad de producto más amplia (consulta offline total / web).

---

### 7. Permisos (T64, T66, T67)

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T64** | UI condicional según permisos (EventDialog, campos editables/readonly, indicadores). | Alta |
| **T66** | Transferencia de propiedad de eventos (selector nuevo propietario, confirmación). | Media |
| **T67** | Rol observador (solo lectura), UI diferenciada. | Baja |

---

### 8. Timezones (T40-T45)

> **Nota:** No contradecir el resumen de grupos: el comportamiento principal de timezones ya está en producción; estas filas son **seguimiento / cierre administrativo** (tests T44–T45, migración T43, etc.) hasta moverlas a `COMPLETED_TASKS.md`.

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T40** | Fundamentos timezone: campo timezone en Event, guardar/mostrar hora local del evento. | Alta |
| **T41** | EventDialog: selector de timezone. | Media |
| **T42** | Conversión de timezone en calendario (mostrar hora local del evento). | Media |
| **T43** | Migración de eventos existentes a timezone. | Media |
| **T44** | Testing de timezones. | Baja |
| **T45** | Plan Frankenstein: casos de timezone. | Baja |

---

### 9. Participantes, invitaciones y formularios

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T20** | Página de miembros del plan: listar, añadir, editar, eliminar; integración con participaciones. | Alta |
| **T120** | Sistema de invitaciones y confirmación de eventos (base implementada; faltan notificaciones push, etc.). | Alta |
| **T121** | Revisión y enriquecimiento de formularios EventDialog y AccommodationDialog por tipo. | Media |
| **T122** | Guardar plan como plantilla (local, editar, usar plantilla). | Baja |
| **T224** | **Reenviar invitación:** Permitir al organizador reenviar una invitación pendiente (por email o desde lista) por si el usuario no la ha recibido (email no llegó, notificación perdida, etc.). UI en Participantes → sección Invitaciones: acción "Reenviar" por invitación pendiente; regenerar/enviar de nuevo notificación y, si aplica, email con link. Relacionado con T104, T105; ver FLUJO_INVITACIONES_NOTIFICACIONES. | Media |
| **T233** | Página Participantes: (1) La lista de participantes ha de ser lo primero; hacerla más compacta para ver el máximo posible. (2) La parte de invitar va a continuación de la lista. (3) Revisar si la parte de aceptar invitaciones es necesaria — *aclarar al abordar la tarea*: ¿se refiere a la vista del organizador (gestionar invitaciones) o a la del invitado (aceptar/rechazar)? (4) Eliminar el botón «Aceptar/Rechazar por token» y todo el código y documentación relacionada (opción ya no activa). (5) Eliminar el icono «X» para cerrar si ya no es necesario. (6) En la barra superior solo ha de aparecer el nombre de la página, sin el nombre del plan. Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T234** | Invitaciones: (1) Cuando la invitación está enviada, el usuario invitado (ej. UB) ha de aparecer en la lista de participantes con estado «pendiente de aceptar invitación» (verificar si ya está implementado). (2) Cuando el invitado acepta o rechaza, el organizador (ej. UA) ha de recibir notificación. (3) En el recuadro de enviar por mail, añadir icono «?» para explicar cada tipo de usuario (participante, observador). Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T261** | **Cancelar plan (flujo completo y comunicación):** Evaluar e implementar todo el flujo cuando un plan se cancela, con foco en avisar correctamente a participantes. Incluir: (1) estado/acción de cancelación y permisos; (2) impacto en visibilidad del plan y eventos; (3) notificaciones in-app y push/email a organizador e invitados/participantes; (4) texto legal/UX del mensaje de cancelación; (5) comportamiento offline/sincronización; (6) pruebas E2E web+iOS. Actualizar flujos y documentación relacionados (`FLUJO_CRUD_PLANES.md`, `FLUJO_INVITACIONES_NOTIFICACIONES.md`, checklist de testing). | Alta |
---

### 10. IA, importación, exportación, integración

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T131** | Sincronización con calendarios externos (.ics, etc.). | Media |
| **T133** | Exportación profesional de planes (PDF/Email). | Media |
| **T134** | Eventos desde correo reenviado a dirección plataforma: usuario reenvía confirmación a una dirección nuestra; parseo y creación de evento (buzón + asignación a plan). **Solo From = usuario registrado.** Anti-spam: rate limiting por usuario, lista blanca opcional (beta). Decisiones y esquema en `docs/producto/CORREO_EVENTOS_SISTEMA_PARSEO.md`. | Alta |
| **T181** | Definir guía de layout modular para pantallas (grid, secciones, espaciados). | Media |

---

### 11. Producto, legal, privacidad, ayuda

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T135** | Gestión de cookies (web). | Alta (MVP web) |
| **T136** | App Tracking Transparency (iOS). | Alta (MVP iOS) |
| **T150** | Definición de MVP y roadmap de lanzamiento. | Alta |
| **T157** | **Sistema de ayuda contextual multi-idioma:** Textos de ayuda en base de datos (Firestore); icono «?» en los lugares que lo necesiten; al pulsar, modal con explicación y enlace a web con contenido ampliado; soporte para personas invidentes (accesibilidad, lectores de pantalla). Especificación en `docs/tareas/T157_AYUDA_MULTIIDIOMA.md`. Relacionado: T158 (multi-idioma app), T192 (accesibilidad). | Baja |
| **T158** | Completar sistema multi-idioma. | Media |
| **T165** | Definir y crear usuarios de administración (modelo, Firestore, documentación). | Media |
| **T192** | Adaptar la app a personas con discapacidad (accesibilidad). | Media |
| **T176** | Unificar plantillas de correos transaccionales (verificación, recuperación, invitaciones). | Baja |
| **T254** | **Pantalla de bienvenida a Planazoo:** Crear una pantalla de bienvenida/onboarding con explicación de qué hace la app. Especificación en `docs/tareas/T254_PANTALLA_BIENVENIDA_PLANAZOO.md`. | Media |
| **T256** | **Implementar Fastlane** para publicar apps iOS y Android. Tras evaluación T255: `fastlane init` en `ios/` y `android/`, Appfile y credenciales, lanes beta (TestFlight + Play interna) y opcionalmente release; Gemfile en ambas carpetas; opcional CI (GitHub Actions). Ver `docs/tareas/T256_IMPLEMENTAR_FASTLANE.md`. | Media |
| **T257** | **Revisión web vs iOS (prioridad iOS):** Identificar y cerrar diferencias entre versión web (más desarrollada) e iOS. La plataforma prioritaria es iOS. Checklist y hallazgos en `docs/configuracion/REVISION_IOS_VS_WEB.md`; tarea en `docs/tareas/T257_REVISION_WEB_VS_IOS.md`. | Alta |
| **T258** | **Icono de la app Planazoo:** Configuración y mantenimiento del icono propio en iOS y Android (sin borde blanco, full bleed si aplica). Detalle en `docs/tareas/T258_ICONO_APP.md`. | Baja |
| **T259** | **Deep link invitación en iOS:** Implementar Universal Links o custom URL scheme para que el link de invitación (p. ej. desde email) abra la app iOS directamente en la pantalla de invitación, en paridad con la experiencia web. Incluye: configuración Associated Domains (Universal Links) o URL scheme en Xcode, archivo apple-app-site-association en el servidor si aplica, y manejo de la URL en la app (WidgetsBinding / getInitialUri). Referencia: `docs/configuracion/REVISION_IOS_VS_WEB.md` §2.3 y §3 ítem 7. Detalle en `docs/tareas/T259_DEEP_LINK_INVITACION_IOS.md`. | Media |
| **T260** | **Sistema multi-moneda:** Soporte de múltiples monedas por plan (EUR, USD, GBP, etc.), formateo automático en UI según moneda del plan y, opcionalmente, conversión de tipos de cambio al visualizar o registrar. Relacionado con T101 (presupuesto) y T102 (pagos). Especificación en `docs/tareas/CURRENCY_SYSTEM_PROPOSAL.md`. | Media |
| **T263** | **Brief y decisión de icono app (traslado de ítem 63):** Definir brief final de marca para icono Planazoo (concepto visual de las dos “oo”, variantes, criterios de legibilidad en tamaños pequeños, versión iOS/Android, exportables necesarios) y dejar decisión cerrada para implementación en T258. | Baja |
| **T264** | **Navegación inferior + patrón de creación (traslado de ítem 64):** Decidir diseño de producto para barras inferiores/FAB y menú de creación contextual (“Otros…” incluido), con criterio de paridad web/iOS y plan de implementación por fases (sin codificar hasta cierre de diseño). | Media |
| **T265** | **Offline first amplio (traslado de ítem 65):** Definir roadmap funcional y técnico para consulta offline total (móvil y enfoque web/PWA), priorizar MVP y fases sobre T56-T62, con criterios de éxito y checklist de validación. | Alta |
| **T266** | **Asistente por reglas (traslado de ítem 98):** Definir alcance de producto para sugerencias inteligentes basadas en reglas (ej. vuelo→taxi, estado plan vs fechas), catálogo inicial de reglas, UX de presentación y métricas de valor antes de implementación. | Media |

---

### 12. Pagos MVP (primer MVP) — sistema de pagos (T102)

> **Presupuesto del plan (T101)** = costes del plan, total, estadísticas (se ve en **W17 Estadísticas**). **Sistema de pagos (T102)** = quién ha pagado qué, balances, deudas/créditos (se ve en **W18 Pagos**). Decisiones en `docs/producto/PAGOS_MVP.md`. Pruebas E2E: fase 11.5; casos PAY-* en TESTING_CHECKLIST § 9.2.

**Completadas (Feb 2026):** T217, T218, T219, T220, T221. **Pendiente:** T222 (ejecutar E2E y casos PAY-*).

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T222** | Pagos MVP: ejecutar y validar. Ejecutar fase 11.5 Pagos del plan E2E (tres usuarios) y casos PAY-001 a PAY-007 del TESTING_CHECKLIST; marcar resultados. | Media |

---

### 13. Otras (chat, agencias, migración, futuro)

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T190** | Sistema de chat bidireccional del plan (tipo WhatsApp) — en progreso. | Media |
| **T253** | **Chat: mostrar fecha de los mensajes.** Opciones: (A) separador con la fecha al cambiar de día (estilo WhatsApp) + hora en cada burbuja; (B) fecha y hora en cada mensaje. Especificación y recomendación en `docs/tareas/T253_CHAT_FECHA_MENSAJES.md`. | Media |
| **T132** | Definición del sistema de agencias de viajes. | Baja |
| **T154-T156** | Migración a Mac/iOS. | Baja |
| **T22** | Definir sistema de IDs de planes (concurrencia, colisiones). | Media |
| **T252** | **Participantes "usuarios" vs "planificadores":** Definir y documentar soluciones de producto y UX para participantes que usan la app más como viajeros (resumen por participante, hoy/mañana, lista cronológica, accesos rápidos a vuelos/alojamiento, propuestas de eventos, confirmación de asistencia, recordatorios, exportar/imprimir). Especificación completa en `docs/tareas/T252_PARTICIPANTES_USUARIOS_VS_PLANIFICADORES.md`. Alcance: no incluye cambios de permisos/roles ni rediseño completo del calendario; export/offline se diseñan aquí, implementación según T56–T62. | Media |
| **T249** | Migrar usos de `withOpacity` a `withValues` en widgets clave (`wd_event_dialog.dart`, `wd_plan_data_screen.dart`, `wd_calendar_screen.dart`, `wd_participants_screen.dart`), manteniendo exactamente el mismo aspecto visual (alpha equivalente) y corrigiendo los lints deprecados. | Baja |
| **T248** | Tests unitarios: configurar setup para tests que usan Firebase o PermissionService (Firebase.initializeApp en test; ProviderScope en widget_test). Actualmente fallan circular_dependency_test, permission_system_test y widget_test. | Baja |

---

## ✅ Tareas eliminadas o fusionadas en esta limpieza

- **T236** — Movida a `COMPLETED_TASKS.md` (implementada en Feb 2026 junto con T230 y T239).
- **T49** — Obsoleta (reemplazada por sistema de tracks T71, T78-T80).
- **T178** — Duplicada de T177 (aviso timezone dispositivo); ya completada en COMPLETED_TASKS.
- **T18** — Página administración Firebase; sustituida por vista administrativa T183-T188.
- **T19** — Valorar hover W14-W25; eliminada por bajo valor.
- **T31** — Aumentar tamaño de letra widgets; cubierto por mejoras UI (T194-T196).
- **T180** — Fusionada en T179 (IA importar desde correo).
- **T179** — Eliminada: "Importar desde mail" (pegar correo en modal en la app) ya no es de interés; solo se mantiene el flujo de correo reenviado a dirección plataforma (T134).
- **T214** — Fusionada en T213 (cards: tamaño + contraste).

Las tareas **completadas** que estaban en este archivo han pasado a `COMPLETED_TASKS.md` (incluida T164 Login con Google). Para detalle histórico de cualquier tarea, consultar ese archivo o el historial de git.

### Relación con `docs/testing/LISTA_PUNTOS_CORREGIR_APP.md`

- **Propósito distinto:** `TASKS.md` = códigos **Txxx** (especificaciones y roadmap). La lista de puntos = IDs numéricos (**34–61**, **62–109**, …) de **pruebas / bugs / UX** por ronda.
- **Colisión de números:** un ID como **94** en la lista (*defaults al crear evento desde FAB*) **no** es la **T94** de `COMPLETED_TASKS.md` (refactor CalendarScreen). En referencias cruzadas usar siempre **«ítem 94»** vs **«T94»**.
- **Complementarios (ejemplos):** **T257** (revisión iOS vs web) ↔ muchos ítems §3.2; **T250** / `EVENT_FORM_FIELDS.md` ↔ **90**, **92–97**; **T246** ↔ **90**, **50** (histórico); **T262** ↔ **66** (contrato en notas); **T263** ↔ **63** (icono), **T264** ↔ **64** (barras/FAB), **T265** ↔ **65** (offline amplio), **T266** ↔ **98** (asistente); **T56–T62** ↔ roadmap offline técnico; **ítem 58** ↔ verificación cerrada 2026-04-08 — `TESTING_OFFLINE_FIRST.md`, **REG-2026-022** en `TESTING_CHECKLIST.md`; pagos **T102** / **T222** ↔ **101–107**; **T259** ↔ **109** (push + deep links en otros docs).
