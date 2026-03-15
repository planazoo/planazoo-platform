/// T157: Identificadores de contexto de ayuda (conexión ayuda ↔ pantalla/widget).
/// Usar estas constantes en HelpIconButton para evitar strings mágicos y tener
/// una sola fuente de verdad. Al añadir un nuevo "?", añadir aquí la constante
/// y en docs/tareas/T157_AYUDA_MULTIIDIOMA.md § 6 y en el seed (assets + docs).
class HelpContextIds {
  HelpContextIds._();

  /// Info del plan → sección Avisos (wd_plan_data_screen)
  static const String planDetailsAviso = 'plan_details.aviso';
}
