# 📋 Nomenclatura de Páginas, Menús y Modales

Este documento centraliza todos los nombres de páginas, pantallas, menús y modales de la aplicación para facilitar la referencia en conversaciones y documentación.

**Última actualización:** Diciembre 2025

---

## 🎯 Convención Multi-Plataforma

### Regla de Nomenclatura

A partir de Diciembre 2024, las páginas principales usan el sufijo **`_page.dart`**. La separación web vs móvil (Dashboard vs Lista de Planes) se decide en el router según la plataforma, no por el nombre del archivo.

- **`_page.dart`** - Página (contenido web o móvil según uso en el router)
- **`_shared.dart`** - Compartida (todas las plataformas), cuando se use explícitamente

### Ejemplos (nombres reales en el código):
```
pg_dashboard_page.dart        # Dashboard complejo (Web/Desktop)
pg_plans_list_page.dart       # Lista simple (iOS/Android)
pg_invitation_page.dart       # Invitaciones (todas las plataformas)
```

### Proceso:
1. Al crear/modificar una página, decidir: ¿web, móvil o compartida?
2. Aplicar el sufijo correspondiente al nombre del archivo
3. Actualizar todas las referencias (imports, rutas, etc.)
4. Documentar la decisión si es relevante

### Páginas Existentes:
Las páginas existentes se renombrarán progresivamente cuando se trabajen en ellas.

---

## 📄 Páginas Principales (Pages)

### Autenticación
- **`LoginPage`** (`lib/features/auth/presentation/pages/login_page.dart`)
  - Página de inicio de sesión - **Shared**
  - Referencia en chat: "página de login" o "LoginPage"

- **`RegisterPage`** (`lib/features/auth/presentation/pages/register_page.dart`)
  - Página de registro de nuevos usuarios - **Shared**
  - Referencia en chat: "página de registro" o "RegisterPage"

- **`EditProfilePage`** (`lib/features/auth/presentation/pages/edit_profile_page.dart`)
  - Página de edición de perfil de usuario - **Shared**
  - Referencia en chat: "página de editar perfil" o "EditProfilePage"

### Dashboard y Navegación Principal
- **`DashboardPage`** (`lib/pages/pg_dashboard_page.dart`)
  - Página principal de la aplicación (dashboard) - **Web/Desktop**
  - Contiene la lista de planes y navegación entre pantallas
  - Referencia en chat: "dashboard" o "DashboardPage"

- **`PlansListPage`** (`lib/pages/pg_plans_list_page.dart`)
  - Página principal de la aplicación para móviles - **Mobile (iOS/Android)**
  - Lista de planes con búsqueda, filtros y navegación
  - Referencia en chat: "lista de planes mobile" o "PlansListPage"

- **`PlanDetailPage`** (`lib/pages/pg_plan_detail_page.dart`)
  - Página de detalle de plan para móviles - **Mobile (iOS/Android)**
  - Contiene barra de navegación y diferentes vistas del plan (datos, calendario, participantes, estadísticas)
  - Referencia en chat: "página de detalle de plan" o "PlanDetailPage"

### Planes
- **`InvitationPage`** (`lib/pages/pg_invitation_page.dart`)
  - Página para aceptar/rechazar invitaciones a planes
  - Referencia en chat: "página de invitación" o "InvitationPage"

- **`PlanParticipantsPage`** (`lib/pages/pg_plan_participants_page.dart`)
  - Página de gestión de participantes de un plan
  - Referencia en chat: "página de participantes" o "PlanParticipantsPage"

- **`ParticipantGroupsPage`** (`lib/pages/pg_participant_groups_page.dart`)
  - Página de gestión de grupos de participantes
  - Referencia en chat: "página de grupos" o "ParticipantGroupsPage"

### Perfil
- **`ProfilePage`** (`lib/pages/pg_profile_page.dart`)
  - Página de perfil de usuario - **Shared**
  - Referencia en chat: "página de perfil" o "ProfilePage"

### Estadísticas y Pagos
- **`PlanStatsPage`** (`lib/features/stats/presentation/pages/plan_stats_page.dart`)
  - Página de estadísticas de un plan
  - Referencia en chat: "página de estadísticas" o "PlanStatsPage"

- **`PaymentSummaryPage`** (`lib/features/payments/presentation/pages/payment_summary_page.dart`)
  - Página de resumen de pagos de un plan
  - Referencia en chat: "página de pagos" o "PaymentSummaryPage"

---

## 🖥️ Pantallas (Screens)

Las pantallas son componentes que se muestran dentro del `DashboardPage` según la navegación:

- **`CalendarScreen`** (`lib/widgets/screens/wd_calendar_screen.dart`)
  - Pantalla principal del calendario de un plan
  - Referencia en chat: "pantalla del calendario" o "CalendarScreen"
  - Código interno: `currentScreen = 'calendar'`

- **`PlanDataScreen`** (`lib/widgets/screens/wd_plan_data_screen.dart`)
  - Pantalla de información y datos del plan
  - Referencia en chat: "pantalla de datos del plan" o "PlanDataScreen"
  - Código interno: `currentScreen = 'planData'`

- **`ParticipantsScreen`** (`lib/widgets/screens/wd_participants_screen.dart`)
  - Pantalla de gestión de participantes
  - Referencia en chat: "pantalla de participantes" o "ParticipantsScreen"
  - Código interno: `currentScreen = 'participants'`

- **`AdminInsightsScreen`** (`lib/widgets/screens/wd_admin_insights_screen.dart`)
  - Pantalla de insights administrativos (vista administrativa)
  - Referencia en chat: "pantalla de insights" o "AdminInsightsScreen" o "Vista administrativa"

- **`FullScreenCalendarPage`** (`lib/widgets/screens/fullscreen_calendar_page.dart`)
  - Página de calendario en pantalla completa - **Web**
  - Referencia en chat: "calendario pantalla completa" o "FullScreenCalendarPage"

- **`CalendarMobilePage`** (`lib/pages/pg_calendar_mobile_page.dart`)
  - Página de calendario para móviles - **Mobile (iOS/Android)**
  - Funcionalidad completa del calendario adaptada para 1-3 días visibles
  - Grid con horas, tracks de participantes, eventos y alojamientos
  - Referencia en chat: "calendario mobile" o "CalendarMobilePage"

---

## 🗨️ Modales y Diálogos (Dialogs)

### Gestión de Planes
- **`_CreatePlanModal`** (`lib/pages/pg_dashboard_page.dart`)
  - Modal para crear un nuevo plan
  - Referencia en chat: "modal de crear plan" o "CreatePlanModal"

- **`ExpandPlanDialog`** (`lib/widgets/dialogs/expand_plan_dialog.dart`)
  - Diálogo para expandir un plan (duplicar fechas)
  - Referencia en chat: "diálogo de expandir plan" o "ExpandPlanDialog"

- **`PlanValidationDialog`** (`lib/widgets/dialogs/plan_validation_dialog.dart`)
  - Diálogo que muestra validaciones del plan
  - Referencia en chat: "diálogo de validación" o "PlanValidationDialog"

### Gestión de Eventos
- **`EventDialog`** (`lib/widgets/wd_event_dialog.dart`)
  - Diálogo para crear/editar eventos
  - Referencia en chat: "diálogo de eventos" o "EventDialog" o "wd_event_dialog"

### Gestión de Alojamientos
- **`AccommodationDialog`** (`lib/widgets/wd_accommodation_dialog.dart`)
  - Diálogo para crear/editar alojamientos
  - Referencia en chat: "diálogo de alojamientos" o "AccommodationDialog" o "wd_accommodation_dialog"

### Gestión de Participantes
- **`ManageRolesDialog`** (`lib/widgets/dialogs/manage_roles_dialog.dart`)
  - Diálogo para gestionar roles y permisos de usuarios
  - Referencia en chat: "modal de gestionar participantes" o "ManageRolesDialog" o "Gestionar Participantes"

- **`InviteGroupDialog`** (`lib/widgets/dialogs/invite_group_dialog.dart`)
  - Diálogo para invitar un grupo de participantes
  - Referencia en chat: "diálogo de invitar grupo" o "InviteGroupDialog"

- **`GroupEditDialog`** (`lib/widgets/dialogs/group_edit_dialog.dart`)
  - Diálogo para crear/editar grupos de participantes
  - Referencia en chat: "diálogo de editar grupo" o "GroupEditDialog"

- **`InvitationResponseDialog`** (`lib/widgets/dialogs/invitation_response_dialog.dart`)
  - Diálogo para responder a una invitación
  - Referencia en chat: "diálogo de respuesta a invitación" o "InvitationResponseDialog"

### Pagos
- **`PaymentDialog`** (`lib/widgets/dialogs/payment_dialog.dart`)
  - Diálogo para gestionar pagos
  - Referencia en chat: "diálogo de pagos" o "PaymentDialog"

### Anuncios
- **`AnnouncementDialog`** (`lib/widgets/dialogs/announcement_dialog.dart`)
  - Diálogo para crear/editar anuncios
  - Referencia en chat: "diálogo de anuncios" o "AnnouncementDialog"

### Información Personal
- **`EditPersonalInfoDialog`** (`lib/widgets/dialogs/edit_personal_info_dialog.dart`)
  - Diálogo para editar información personal de un evento
  - Referencia en chat: "diálogo de editar info personal" o "EditPersonalInfoDialog"

### Estados del Plan
- **`StateTransitionDialog`** (`lib/features/calendar/presentation/widgets/state_transition_dialog.dart`)
  - Diálogo para cambiar el estado de un plan
  - Referencia en chat: "diálogo de cambio de estado" o "StateTransitionDialog"

### Otros Diálogos
- **`_DeletePlanDialog`** (`lib/widgets/screens/wd_plan_data_screen.dart`)
  - Diálogo de confirmación para eliminar un plan
  - Referencia en chat: "diálogo de eliminar plan" o "DeletePlanDialog"

---

## 🎛️ Componentes de UI Específicos

### Calendario
- **`CalendarTracks`** (`lib/widgets/screens/calendar/components/calendar_tracks.dart`)
  - Componente que renderiza las pistas (tracks) de participantes en el calendario
  - Referencia en chat: "CalendarTracks" o "pistas del calendario"

- **`CalendarGrid`** (`lib/widgets/screens/calendar/components/calendar_grid.dart`)
  - Componente que renderiza la cuadrícula del calendario
  - Referencia en chat: "CalendarGrid" o "cuadrícula del calendario"

- **`UserPerspectiveSelector`** (`lib/widgets/screens/calendar/user_perspective_selector.dart`)
  - Selector para cambiar la perspectiva de usuario en el calendario
  - Referencia en chat: "selector de perspectiva" o "UserPerspectiveSelector"

### Navegación Mobile
- **`PlanNavigationBar`** (`lib/widgets/plan/wd_plan_navigation_bar.dart`)
  - Barra de navegación horizontal para opciones del plan en móviles - **Mobile (iOS/Android)**
  - Muestra iconos para acceder a diferentes secciones del plan (Info, Mi resumen, calendario, participantes, chat, pagos, estadísticas, notificaciones del plan)
  - Referencia en chat: "barra de navegación del plan" o "PlanNavigationBar"

### Anuncios
- **`AnnouncementTimeline`** (`lib/widgets/screens/announcement_timeline.dart`)
  - Timeline de anuncios de un plan
  - Referencia en chat: "timeline de anuncios" o "AnnouncementTimeline"

### Desarrollo y Testing
- **`UIShowcasePage`** (`lib/pages/pg_ui_showcase_page.dart`)
  - Página de demostración de diferentes estilos UI - **Desarrollo/Testing**
  - Muestra diferentes estilos visuales (Minimalista, Estilo Base, Clásico, Moderno) para comparación
  - Referencia en chat: "página de showcase UI" o "UIShowcasePage"

---

## 📱 Navegación Interna

### Dashboard Web
El `DashboardPage` gestiona la navegación entre pantallas usando el estado `currentScreen`:

- `'calendar'` → Muestra `CalendarScreen`
- `'planData'` → Muestra `PlanDataScreen`
- `'participants'` → Muestra `ParticipantsScreen`
- `'profile'` → Muestra `ProfilePage`
- `'payments'` → Muestra `PaymentSummaryPage`
- `'stats'` → Muestra `PlanStatsPage`

### Navegación Mobile
En móviles, la navegación funciona de forma diferente:

- **`PlansListPage`** → Primera pantalla después del login (lista de planes)
  - Al seleccionar un plan → Navega a `PlanDetailPage`
  
- **`PlanDetailPage`** → Página principal de un plan seleccionado
  - Contiene `PlanNavigationBar` para cambiar entre vistas
  - Vistas disponibles (orden en barra, ver `wd_plan_navigation_bar.dart`):
    - `'planData'` → Muestra `PlanDataScreen`
    - `'mySummary'` → Mi resumen del plan
    - `'calendar'` → Muestra `CalendarMobilePage`
    - `'participants'` → Muestra `PlanParticipantsPage` / participantes
    - `'chat'` → Chat del plan
    - `'payments'` → Muestra `PaymentSummaryPage` / pagos
    - `'stats'` → Muestra `PlanStatsPage` (solo organizador según permisos)
    - `'planNotifications'` → Notificaciones del plan

---

## 🎯 Convenciones de Nomenclatura

### Archivos
- **Páginas**: Prefijo `pg_` (ej: `pg_dashboard_page.dart`)
- **Widgets de diálogo**: Prefijo `wd_` (ej: `wd_event_dialog.dart`)
- **Pantallas**: Prefijo `wd_` (ej: `wd_calendar_screen.dart`)
- **Componentes**: Sin prefijo específico, nombre descriptivo

### Clases
- **Páginas**: Sufijo `Page` (ej: `DashboardPage`)
- **Pantallas**: Sufijo `Screen` (ej: `CalendarScreen`)
- **Diálogos**: Sufijo `Dialog` (ej: `EventDialog`)
- **Modales**: Sufijo `Modal` (ej: `_CreatePlanModal`)

### Referencias en Chat
- Usar el nombre de la clase directamente (ej: "CalendarScreen")
- O usar descripción en español (ej: "pantalla del calendario")
- Para modales/diálogos, usar "modal de..." o "diálogo de..."

---

## 📝 Notas

- Los nombres con prefijo `_` (como `_CreatePlanModal`) son clases privadas dentro de un archivo
- Algunos componentes pueden tener múltiples nombres (ej: "Vista administrativa" = `AdminInsightsScreen`)
- Este documento debe actualizarse cuando se añadan nuevas páginas, pantallas o modales

---

**Mantenedor:** Equipo de Desarrollo UNP Calendario  
**Versión:** 1.1

