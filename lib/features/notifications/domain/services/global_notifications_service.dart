import 'dart:async';
import '../models/unified_notification.dart';
import '../models/notification_model.dart';
import '../../../../features/calendar/domain/models/plan_invitation.dart';
import '../../../../features/calendar/domain/models/pending_email_event.dart';
import '../../../../features/calendar/domain/services/pending_email_event_service.dart';
import 'notification_service.dart';

/// Servicio que agrega todas las fuentes de notificaciones en una sola lista ordenada por fecha.
class GlobalNotificationsService {
  final PendingEmailEventService _pendingService = PendingEmailEventService();
  final NotificationService _notificationService = NotificationService();

  /// Combina invitaciones (lista inicial), stream de eventos desde correo y stream de notificaciones.
  /// Orden: createdAt descendente. Incluye clasificación requiresAction.
  Stream<List<UnifiedNotification>> streamGlobalNotifications({
    required List<PlanInvitation> invitations,
    required String authUid,
    required String userId,
  }) {
    final controller = StreamController<List<UnifiedNotification>>.broadcast();
    List<UnifiedNotification> latestPending = [];
    List<UnifiedNotification> latestNotif = [];
    final inviteList = invitations
        .where((i) => i.status == 'pending')
        .map(_invitationToUnified)
        .toList();

    void emit() {
      final merged = _mergeAndSort(inviteList, latestPending, latestNotif);
      if (!controller.isClosed) controller.add(merged);
    }

    emit();

    final subPending = _pendingService
        .streamPendingEvents(authUid)
        .listen((events) {
          latestPending = events
              .where((e) => e.status == 'pending')
              .map((e) => _pendingToUnified(e, authUid))
              .toList();
          emit();
        }, onError: controller.addError, onDone: () {});

    final subNotif = _notificationService
        .getNotifications(userId)
        .listen((list) {
          latestNotif = list.map(_notificationToUnified).toList();
          emit();
        }, onError: controller.addError, onDone: () {});

    controller.onCancel = () {
      subPending.cancel();
      subNotif.cancel();
    };

    return controller.stream;
  }

  /// Total de notificaciones "no leídas": invitaciones pendientes + eventos pendientes + NotificationModel no leídas.
  Stream<int> streamUnreadCount({
    required List<PlanInvitation> invitations,
    required String authUid,
    required String userId,
  }) {
    return streamGlobalNotifications(
      invitations: invitations,
      authUid: authUid,
      userId: userId,
    ).map((list) => list.where((n) => n.requiresAction || !n.isRead).length);
  }

  static List<UnifiedNotification> _mergeAndSort(
    List<UnifiedNotification> a,
    List<UnifiedNotification> b,
    List<UnifiedNotification> c,
  ) {
    final merged = [...a, ...b, ...c];
    merged.sort((x, y) => y.createdAt.compareTo(x.createdAt));
    return merged;
  }

  static UnifiedNotification _invitationToUnified(PlanInvitation inv) {
    return UnifiedNotification(
      id: 'inv_${inv.planId}_${inv.id ?? inv.token}',
      type: UnifiedNotificationType.invitation,
      title: 'Invitación a plan',
      body: 'Te han invitado al plan ${inv.planId}',
      createdAt: inv.createdAt,
      isRead: false,
      planId: inv.planId,
      source: UnifiedNotificationSource.planInvitations,
      requiresAction: true,
      data: {
        'planId': inv.planId,
        'invitationId': inv.id,
        'token': inv.token,
        'email': inv.email,
        'role': inv.role,
      },
      sourcePayload: inv,
    );
  }

  static UnifiedNotification _pendingToUnified(PendingEmailEvent e, String authUid) {
    return UnifiedNotification(
      id: 'pending_${e.id}',
      type: UnifiedNotificationType.emailEvent,
      title: e.displayTitle,
      body: e.bodyPlain.length > 120 ? '${e.bodyPlain.substring(0, 120)}...' : e.bodyPlain,
      createdAt: e.createdAt ?? DateTime.now(),
      isRead: false,
      source: UnifiedNotificationSource.pendingEmailEvents,
      requiresAction: true,
      data: {
        'pendingEventId': e.id,
        'authUid': authUid,
      },
      sourcePayload: e,
    );
  }

  static UnifiedNotification _notificationToUnified(NotificationModel n) {
    final type = _mapNotificationType(n.type);
    final requiresAction = type == UnifiedNotificationType.invitation;
    final data = <String, dynamic>{};
    if (n.data != null) data.addAll(n.data!);
    data['notificationId'] = n.id;
    return UnifiedNotification(
      id: 'notif_${n.id}',
      type: type,
      title: n.title,
      body: n.body,
      createdAt: n.createdAt,
      isRead: n.isRead,
      planId: n.planId,
      eventId: n.eventId,
      source: UnifiedNotificationSource.usersNotifications,
      requiresAction: requiresAction,
      data: data,
      sourcePayload: n,
    );
  }

  static UnifiedNotificationType _mapNotificationType(NotificationType t) {
    switch (t) {
      case NotificationType.invitation:
        return UnifiedNotificationType.invitation;
      case NotificationType.announcement:
        return UnifiedNotificationType.announcement;
      case NotificationType.eventCreated:
        return UnifiedNotificationType.eventCreated;
      case NotificationType.eventUpdated:
        return UnifiedNotificationType.eventUpdated;
      case NotificationType.eventDeleted:
        return UnifiedNotificationType.eventDeleted;
      case NotificationType.invitationAccepted:
        return UnifiedNotificationType.invitationAccepted;
      case NotificationType.invitationRejected:
        return UnifiedNotificationType.invitationRejected;
      case NotificationType.planStateChanged:
        return UnifiedNotificationType.planStateChanged;
      case NotificationType.participantAdded:
        return UnifiedNotificationType.participantAdded;
      case NotificationType.participantRemoved:
        return UnifiedNotificationType.participantRemoved;
      case NotificationType.alarm:
        return UnifiedNotificationType.alarm;
      default:
        return UnifiedNotificationType.other;
    }
  }
}
