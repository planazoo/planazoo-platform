/// Origen de la notificación en el sistema unificado.
enum UnifiedNotificationSource {
  planInvitations,
  pendingEmailEvents,
  usersNotifications,
  eventNotifications,
}

/// Tipo de notificación para la lista unificada (campana / W20).
enum UnifiedNotificationType {
  invitation,
  emailEvent,
  announcement,
  eventCreated,
  eventUpdated,
  eventDeleted,
  eventChange,
  invitationAccepted,
  invitationRejected,
  planStateChanged,
  participantAdded,
  participantRemoved,
  alarm,
  other,
}

/// Modelo de lectura unificado para la lista global de notificaciones.
/// Agrega invitaciones, eventos desde correo, avisos y notificaciones de actividad.
class UnifiedNotification {
  final String id;
  final UnifiedNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? planId;
  final String? eventId;
  final UnifiedNotificationSource source;
  /// true = pendiente de acción (aceptar/rechazar, asignar a plan); false = solo informativa.
  final bool requiresAction;
  /// Payload para acciones: planId, token, invitationId, pendingEventId, etc.
  final Map<String, dynamic>? data;
  /// Objeto original para acciones (ej. PendingEmailEvent, PlanInvitation) si se necesita en la UI.
  final Object? sourcePayload;

  const UnifiedNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.planId,
    this.eventId,
    required this.source,
    required this.requiresAction,
    this.data,
    this.sourcePayload,
  });
}
