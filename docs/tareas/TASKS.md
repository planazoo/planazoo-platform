# 📋 Lista de Tareas - Planazoo

> Consulta las normas y flujo de trabajo en `docs/configuracion/CONTEXT.md`.  
> **Tareas completadas:** ver `docs/tareas/COMPLETED_TASKS.md`.

**Siguiente código de tarea: T223**

**📊 Resumen (solo pendientes):**
- **Mejoras UI/UX:** T194-T214 (widgets, info plan, calendario, cards)
- **Administración:** T183-T191 (vista admin, export CSV, seed, permisos legacy, T188 en progreso)
- **Auth / Perfil:** T159-T162, T173, T174 (permisos Firestore, verificación, perfil, soporte email)
- **Seguridad avanzada:** T166-T172 (2FA, token refresh, legal, etc.)
- **Calendario:** T35, T37, T38, T88, T96-T99, T182, T199, T210-T212
- **Offline:** T56-T62
- **Permisos:** T64, T66, T67
- **Timezones:** T40-T45
- **Funcionalidades / Producto:** T20, T120-T122, T131-T136, T157-T158, T165, T190, T192, T181, T150, etc.
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
| ~~**T194**~~ | ~~Layout W30/W31: ocultar W30 en UI, W31 hasta el final de pantalla, eliminar recuadro de color de W31.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| ~~**T195**~~ | ~~Widgets W14-W25: recuadro seleccionado con bordes superiores redondeados; icono mismo color que texto cuando seleccionado.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| ~~**T196**~~ | ~~Pantallas W14-W25: encabezado verde con título a la izquierda y espacio para más elementos (texto, botones).~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| ~~**T197**~~ | ~~Barra lateral verde a la derecha en W4, W13, W26, W27, W28, W29.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| ~~**T198**~~ | ~~Decidir estado de W29: desactivar o definir contenido. Documentar.~~ ✅ Completada (W29 = centro de mensajes; ver COMPLETED_TASKS.md) | — |
| ~~**T199**~~ | ~~Vista calendario: mejorar encabezado de cada día (legibilidad, contraste). Relacionado con T182.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| ~~**T200**~~ | ~~Info plan: fecha de inicio y fin en un mismo modal.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| ~~**T201**~~ | ~~Modal nuevo plan: fechas optativas con texto "se puede rellenar más adelante".~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| ~~**T202**~~ | ~~Barra de guardar cambios fija junto al título "Info plan".~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| ~~**T203**~~ | ~~Corregir subida de imagen en Info plan.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| **T204** | Info plan: imagen a media pantalla; nombre y descripción en layout acordado. | Media |
| **T205** | Modal cambio de estado del plan: estilo básico, restricciones en borrador, mensaje explicando implicación. | Media |
| ~~**T206**~~ | ~~Info plan: sección Información detallada en dos columnas.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| ~~**T207**~~ | ~~Aclarar en UI qué hace la sección Avisos (tooltip o texto de ayuda). Relacionado con T105.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| **T208** | Modal evento: fecha fin por duración o manual; campo a la derecha de Duración. | Media |
| ~~**T209**~~ | ~~Botón aceptar en verde en modal evento y en selector de horas.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| **T210** | Calendario: revisar drag and drop y desplazamiento móvil. | Media |
| **T211** | Calendario: copiar/pegar con Ctrl+mouse; corregir colocación a la altura correcta. Complementa T35. | Media |
| **T212** | Calendario en pantalla completa por defecto. | Media |
| ~~**T213**~~ | ~~Cards de planes: reducir tamaño y mejorar contraste en card seleccionada (texto e indicadores de estado).~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |

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
| ~~**T216**~~ | ~~Eventos por correo: eliminar la opción de aceptar alias como From; solo aceptar el email principal del usuario registrado.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |

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

---

### 4. Auth, perfil y soporte

| Código | Descripción | Prioridad |
|--------|-------------|-----------|
| **T159** | Corregir permisos Firestore para event_participants tras logout/login. | Alta |
| **T160** | Mostrar "Reenviar verificación" solo cuando sea necesario. | Media |
| ~~**T161**~~ | ~~Añadir nota sobre bandeja de spam en mensaje de registro.~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |
| **T162** | Traducir mensajes de error en auth_service (códigos en lugar de texto; UI traduce). | Media |
| **T173** | Refinar UX de perfil: modal editar, cabecera nombre+email, foto de perfil, quitar botones obsoletos. | Media |
| **T174** | Definir canal de soporte para cambios de email (landing/FAQ/formulario); actualizar modal perfil. | Baja |

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
| ~~**T189**~~ | ~~Mejorar UX del diálogo de invitaciones por email (errores dentro del modal).~~ ✅ Completada (ver COMPLETED_TASKS.md) | — |

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
| ~~**T217**~~ | ✅ Pagos MVP: unificar web/mobile. Sustituir placeholder en vista móvil por PaymentSummaryPage. | Alta (MVP) |
| ~~**T218**~~ | ✅ Pagos MVP: permisos por rol (organizador cualquier pago; participante solo "yo pagué"). | Alta (MVP) |
| ~~**T219**~~ | ✅ Pagos MVP: bote común (aportaciones, gastos, reflejo en balances). | Media |
| ~~**T220**~~ | ✅ Pagos MVP: aviso en UI y texto legal ("no procesamos cobros"). | Alta (MVP) |
| ~~**T221**~~ | ✅ Pagos MVP: actualizar FLUJO_PRESUPUESTO_PAGOS.md con decisiones y matriz de permisos. | Media |
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
