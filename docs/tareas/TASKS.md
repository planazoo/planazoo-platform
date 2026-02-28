# 📋 Lista de Tareas - Planazoo

> Consulta las normas y flujo de trabajo en `docs/configuracion/CONTEXT.md`.  
> **Tareas completadas:** ver `docs/tareas/COMPLETED_TASKS.md`.

**Siguiente código de tarea: T244**

**📊 Resumen (solo pendientes):**
- **Mejoras UI/UX:** T194-T214, T226, T231, T237 (widgets, info plan, calendario, cards, modales)
- **Administración:** T183-T191, T223 (vista admin, export CSV, seed, espacio admin RUD toda la BD, T188 en progreso)
- **Auth / Perfil:** T159-T162, T173, T174, T226-T228, T232 (permisos Firestore, verificación, perfil, registro, modales)
- **Seguridad avanzada:** T166-T172 (2FA, token refresh, legal, etc.)
- **Calendario:** T35, T37, T38, T88, T96-T99, T182, T199, T210-T212, T225, T238, T242, T243
- **Offline:** T56-T62
- **Permisos:** T64, T66, T67
- **Timezones:** T40-T45
- **Funcionalidades / Producto:** T20, T120-T122, T131-T136, T157-T158, T165, T190, T192, T181, T150, T224, T228, T233, T234 (reenviar invitación, invitaciones, correos), etc.
- **Pagos MVP:** T217-T222 (ver docs/producto/PAGOS_MVP.md).

**Total aproximado: ~95 tareas pendientes** (las completadas están en COMPLETED_TASKS.md; los códigos no se reutilizan).

---

## 📋 Reglas del Sistema de Tareas

- **Códigos únicos** (T1, T2…); no reutilizar al eliminar.
- **Orden de prioridad:** por posición en el documento.
- **Estados:** Pendiente → En progreso → Completada. Completadas se mueven a `COMPLETED_TASKS.md`.
- **Aprobación:** confirmación del usuario antes de marcar completada.
- **Grupos:** tareas relacionadas se implementan y prueban juntas cuando tiene sentido.
- **Arquitectura:** Offline First y Plan Frankenstein según `CONTEXT.md`.

---

## 📦 Grupos de tareas (referencia)

- **Grupos 1-3:** Tracks, filtros, parte común/personal (mayoría completados).
- **Grupo 4:** Offline (T56-T62, T63-T64).
- **Grupo 5:** Timezones (T40-T45) — completados.
- **Grupo 6:** Funcionalidades avanzadas (T77-T90; varias completadas).
- **Otros:** Admin, seguridad, UI/UX, producto.

---

## 🗂️ Tareas pendientes (ordenadas por área)

### 1. Mejoras UI/UX – Widgets, Info plan, Calendario, Cards

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T204** | Info plan: imagen a media pantalla; nombre y descripción en layout acordado. | Media |
| **T205** | Modal cambio de estado del plan: estilo básico, restricciones en borrador, mensaje explicando implicación. | Media |
| **T208** | Modal evento: fecha fin por duración o manual; campo a la derecha de Duración. | Media |
| **T210** | Calendario: revisar drag and drop y desplazamiento móvil. | Media |
| **T211** | Calendario: copiar/pegar con Ctrl+mouse; corregir colocación a la altura correcta. Complementa T35. | Media |
| **T212** | Calendario en pantalla completa por defecto. | Media |
| **T226** | **UI estándar modales:** Definir y aplicar que los modales tengan barra superior en color verde con el título del modal y, si aplica, botones o textos. Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T231** | Info plan: Revisar el apartado «Avisos»: comentar, evaluar si tiene sentido mantenerlo y tomar una decisión en ese momento (mantener / simplificar / quitar). Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Baja |
| **T236** | Notificaciones: (1) En el icono de notificaciones en W1, el círculo con el número no debe tapar el icono; recolocarlo. (2) Estética de los botones Aceptar y Rechazar según estilo principal de la app. Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T237** | Página Info del plan: (1) Optimizar para ver más datos; estructura pensada sobre todo para móvil. (2) Sobre la zona de Avisos: comentar y tomar decisión en ese momento (ver T231). (3) El estado del plan debería verse en la barra superior verde. Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |

*Nota: T214 se ha fusionado en T213 (tamaño + contraste).*

---

### 2. Calendario y eventos (lógica / interacción)

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T35** | Copiar y pegar eventos (Ctrl+mouse, etc.); colocación correcta al pegar. Ver T211 para refinamientos. | Media |
| **T37** | Gestión de eventos en borrador: visualización, filtro mostrar/ocultar, diferenciación respecto a confirmados. | Media |
| **T38** | Eliminar opción "Alojamiento" del diálogo de eventos; alojamientos en su propio diálogo. | Media |
| **T88** | Rediseño arquitectura del calendario en capas (Base → Tracks → Eventos → Interacciones). | Media |
| **T96** | Refactoring CalendarScreen (en progreso parcial). Completar componentes pendientes. | Media |
| **T97** | Tests de integración para funcionalidades críticas del calendario. | Media |
| **T98** | Plan de pruebas detallado del calendario. | Baja |
| **T99** | Documentación de API del calendario. | Baja |
| **T182** | Afinar UI de calendario en W28: celdas, tipografía, espaciado, tooltips. | Media |
| **T215** | Mover un evento de un plan a otro: permitir cambiar el plan al que pertenece un evento (UI + lógica + permisos). Relacionado con buzón de eventos por email y asignación a plan. | Media |
| **T225** | **Búsqueda de lugar con Google Places API:** Integrar autocompletado y Place Details (Google Places API) para **alojamientos** y **eventos**. En el diálogo de alojamiento: campo de búsqueda con sugerencias (tipo lodging); al elegir un resultado, rellenar nombre (y opcionalmente dirección, coordenadas). La misma opción se añadirá al diálogo de eventos (campo descripción/lugar con búsqueda). Requiere: API key en Google Cloud (Places API), paquete Flutter (p. ej. google_place), variable de entorno para la key, UI de búsqueda + Place Details y mapeo a modelo. Coste: ~10k Place Details/mes gratis; con sesión el Autocomplete no se cobra. | Media |
| **T238** | Modal crear evento: (1) ~~Barra verde superior con título.~~ ✅ Hecho. (2) Mejorar visualización de las opciones «General» y «Mi información». (3) Evaluar si el texto «Puedes editar esta información» es necesario. (4) Hacer muy rápido y fácil definir el evento — *decidir al abordar la tarea*: flujo corto con «Más opciones» vs todos los campos visibles reordenados, etc. (5) Orden de aparición de los campos mejorado. Relacionado con T208 (duración/hora concreta). Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T242** | Página Calendario: (1) ~~Eliminar la opción «perspectiva de usuario».~~ ✅ Hecho. (2) Agrupar las opciones de la barra en un menú categorizado; revisar cuáles son necesarias. (3) Añadir menú de filtros de eventos: todos, borrador. Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
| **T243** | Copiar planes, eventos y alojamientos: (1) Revisar si ya existe tarea (T35, T211 para eventos). (2) Crear ambas opciones: (a) copiar eventos y alojamientos dentro del mismo plan (pegar en el plan actual); (b) duplicar plan entero (plan nuevo con eventos y alojamientos copiados). Origen: REGISTRO_OBSERVACIONES_PRUEBAS.md § MIS NOTAS. | Media |
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

---

### 7. Permisos (T64, T66, T67)

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T64** | UI condicional según permisos (EventDialog, campos editables/readonly, indicadores). | Alta |
| **T66** | Transferencia de propiedad de eventos (selector nuevo propietario, confirmación). | Media |
| **T67** | Rol observador (solo lectura), UI diferenciada. | Baja |

---

### 8. Timezones (T40-T45)

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
---

### 10. IA, importación, exportación, integración

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T131** | Sincronización con calendarios externos (.ics, etc.). | Media |
| **T133** | Exportación profesional de planes (PDF/Email). | Media |
| **T134** | Eventos desde correo reenviado a dirección plataforma: usuario reenvía confirmación a una dirección nuestra; parseo y creación de evento (buzón + asignación a plan). **Solo From = usuario registrado.** Anti-spam: rate limiting por usuario, lista blanca opcional (beta). Decisiones a cerrar en `docs/producto/CORREO_EVENTOS_SPAM.md`. | Alta |
| **T181** | Definir guía de layout modular para pantallas (grid, secciones, espaciados). | Media |

---

### 11. Producto, legal, privacidad, ayuda

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T135** | Gestión de cookies (web). | Alta (MVP web) |
| **T136** | App Tracking Transparency (iOS). | Alta (MVP iOS) |
| **T150** | Definición de MVP y roadmap de lanzamiento. | Alta |
| **T157** | Sistema de ayuda contextual. | Baja |
| **T158** | Completar sistema multi-idioma. | Media |
| **T165** | Definir y crear usuarios de administración (modelo, Firestore, documentación). | Media |
| **T192** | Adaptar la app a personas con discapacidad (accesibilidad). | Media |
| **T176** | Unificar plantillas de correos transaccionales (verificación, recuperación, invitaciones). | Baja |

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
| **T132** | Definición del sistema de agencias de viajes. | Baja |
| **T154-T156** | Migración a Mac/iOS. | Baja |
| **T22** | Definir sistema de IDs de planes (concurrencia, colisiones). | Media |

---

## ✅ Tareas eliminadas o fusionadas en esta limpieza

- **T49** — Obsoleta (reemplazada por sistema de tracks T71, T78-T80).
- **T178** — Duplicada de T177 (aviso timezone dispositivo); ya completada en COMPLETED_TASKS.
- **T18** — Página administración Firebase; sustituida por vista administrativa T183-T188.
- **T19** — Valorar hover W14-W25; eliminada por bajo valor.
- **T31** — Aumentar tamaño de letra widgets; cubierto por mejoras UI (T194-T196).
- **T180** — Fusionada en T179 (IA importar desde correo).
- **T179** — Eliminada: "Importar desde mail" (pegar correo en modal en la app) ya no es de interés; solo se mantiene el flujo de correo reenviado a dirección plataforma (T134).
- **T214** — Fusionada en T213 (cards: tamaño + contraste).

Las tareas **completadas** que estaban en este archivo han pasado a `COMPLETED_TASKS.md` (incluida T164 Login con Google). Para detalle histórico de cualquier tarea, consultar ese archivo o el historial de git.
