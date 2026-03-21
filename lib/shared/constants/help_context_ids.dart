/// T157: Identificadores de contexto de ayuda (conexión ayuda ↔ pantalla/widget).
/// Usar estas constantes en HelpIconButton para evitar strings mágicos y tener
/// una sola fuente de verdad. Al añadir un nuevo "?", añadir aquí la constante
/// y en docs/tareas/T157_AYUDA_MULTIIDIOMA.md § 6 y en el seed (assets + docs).
class HelpContextIds {
  HelpContextIds._();

  // ----- Info del plan (wd_plan_data_screen) -----
  /// Sección Avisos
  static const String planDetailsAviso = 'plan_details.aviso';
  /// Información detallada: fechas, moneda, presupuesto, visibilidad, zona horaria
  static const String planDetailsInfo = 'plan_details.info';
  /// Participantes del plan
  static const String planDetailsParticipants = 'plan_details.participants';
  /// Salir del plan (participantes no organizadores)
  static const String planDetailsLeave = 'plan_details.leave';
  /// Barra superior "Info del plan" (título de la pantalla)
  static const String planDetailsHeader = 'plan_details.header';

  // ----- Crear plan (wd_create_plan_modal) -----
  static const String createPlanGeneral = 'create_plan.general';

  // ----- Dashboard -----
  /// Pestañas: Info, Mi resumen, Calendario, Participantes, Chat, Notificaciones, etc.
  static const String dashboardTabs = 'dashboard.tabs';
  /// Lista de planes (columna izquierda)
  static const String dashboardPlanList = 'dashboard.plan_list';

  /// Detalle del plan (móvil): chip **in/out/pend.** en la AppBar — qué significa y cómo actuar
  static const String planDetailMyStatus = 'plan_detail.my_status';

  // ----- Calendario -----
  /// Vista de calendario (pistas, eventos, alojamientos)
  static const String calendarView = 'calendar.view';

  // ----- Mi resumen -----
  static const String mySummary = 'my_summary';

  // ----- Chat del plan -----
  static const String chatPlan = 'chat.plan';

  // ----- Notificaciones -----
  static const String notifications = 'notifications';

  // ----- Perfil -----
  /// Zona horaria en perfil
  static const String profileTimezone = 'profile.timezone';

  // ----- Admin -----
  /// Actualizar ayuda (subir seed a Firestore)
  static const String adminUpdateHelp = 'admin.update_help';
  /// UI Showcase
  static const String adminUiShowcase = 'admin.ui_showcase';
}
