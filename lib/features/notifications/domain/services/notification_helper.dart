import '../../../../shared/services/logger_service.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../../../calendar/domain/services/plan_participation_service.dart';
import '../../../calendar/domain/services/plan_service.dart';

/// Helper para crear notificaciones automáticamente en diferentes situaciones
class NotificationHelper {
  final NotificationService _notificationService;
  final PlanParticipationService _participationService;
  final PlanService _planService;

  NotificationHelper({
    NotificationService? notificationService,
    PlanParticipationService? participationService,
    PlanService? planService,
  })  : _notificationService = notificationService ?? NotificationService(),
        _participationService = participationService ?? PlanParticipationService(),
        _planService = planService ?? PlanService();

  /// Crear notificaciones cuando se publica un aviso en un plan
  /// 
  /// [planId] - ID del plan
  /// [announcementUserId] - ID del usuario que publicó el aviso (no recibirá notificación)
  /// [announcementMessage] - Mensaje del aviso (para el body de la notificación)
  /// [announcementType] - Tipo del aviso ('info', 'urgent', 'important')
  /// [planName] - Nombre del plan (opcional, se obtendrá si no se proporciona)
  Future<int> notifyAnnouncementCreated({
    required String planId,
    required String announcementUserId,
    required String announcementMessage,
    String? announcementType,
    String? planName,
  }) async {
    try {
      // Obtener nombre del plan si no se proporciona
      String finalPlanName = planName ?? 'Un plan';
      if (planName == null) {
        final plan = await _planService.getPlanById(planId);
        if (plan != null) {
          finalPlanName = plan.name;
        }
      }

      // Obtener todos los participantes del plan
      final participations = await _participationService
          .getPlanParticipations(planId)
          .first;

      // Filtrar participantes activos y excluir al que publicó el aviso
      final participantIds = participations
          .where((p) => p.isActive && p.userId != announcementUserId)
          .map((p) => p.userId)
          .toList();

      if (participantIds.isEmpty) {
        LoggerService.info(
          'No hay participantes para notificar sobre el aviso en plan: $planId',
          context: 'NOTIFICATION_HELPER',
        );
        return 0;
      }

      // Crear título y body según el tipo
      String title;
      String body;
      
      if (announcementType == 'urgent') {
        title = '🚨 Aviso urgente en "$finalPlanName"';
        body = announcementMessage.length > 100
            ? '${announcementMessage.substring(0, 100)}...'
            : announcementMessage;
      } else if (announcementType == 'important') {
        title = '⚠️ Aviso importante en "$finalPlanName"';
        body = announcementMessage.length > 100
            ? '${announcementMessage.substring(0, 100)}...'
            : announcementMessage;
      } else {
        title = '📢 Nuevo aviso en "$finalPlanName"';
        body = announcementMessage.length > 100
            ? '${announcementMessage.substring(0, 100)}...'
            : announcementMessage;
      }

      // Crear notificación base
      final notification = NotificationModel(
        userId: '', // Se asignará para cada usuario
        type: NotificationType.announcement,
        title: title,
        body: body,
        planId: planId,
        createdAt: DateTime.now(),
        data: {
          'announcementType': announcementType ?? 'info',
          'announcementUserId': announcementUserId,
        },
      );

      // Crear notificaciones para todos los participantes
      final count = await _notificationService.createNotificationsForUsers(
        participantIds,
        notification,
      );

      LoggerService.info(
        'Notificaciones de aviso creadas: $count para plan: $planId',
        context: 'NOTIFICATION_HELPER',
      );

      return count;
    } catch (e) {
      LoggerService.error(
        'Error creando notificaciones de aviso para plan: $planId',
        context: 'NOTIFICATION_HELPER',
        error: e,
      );
      return 0;
    }
  }

  /// Crear notificación cuando se envía una invitación a un plan
  /// 
  /// [planId] - ID del plan
  /// [invitedUserId] - ID del usuario invitado (si existe en la app)
  /// [invitedEmail] - Email del usuario invitado
  /// [inviterUserId] - ID del usuario que envía la invitación
  /// [invitationToken] - Token de la invitación
  /// [planName] - Nombre del plan (opcional)
  /// [inviterName] - Nombre del organizador (opcional)
  Future<bool> notifyInvitationCreated({
    required String planId,
    String? invitedUserId,
    required String invitedEmail,
    required String inviterUserId,
    required String invitationToken,
    String? planName,
    String? inviterName,
  }) async {
    try {
      // Si el usuario no existe en la app, no podemos crear notificación in-app
      // (recibirá el email)
      if (invitedUserId == null) {
        LoggerService.info(
          'User not found in app for email: $invitedEmail. Notification will not be created (email sent instead)',
          context: 'NOTIFICATION_HELPER',
        );
        return false;
      }

      // Obtener nombre del plan si no se proporciona
      String finalPlanName = planName ?? 'Un plan';
      if (planName == null) {
        final plan = await _planService.getPlanById(planId);
        if (plan != null) {
          finalPlanName = plan.name;
        }
      }

      // Usar el nombre del organizador proporcionado o el por defecto
      String finalInviterName = inviterName ?? 'Un usuario';

      // Crear notificación
      final notification = NotificationModel(
        userId: invitedUserId,
        type: NotificationType.invitation,
        title: '📧 Invitación a "$finalPlanName"',
        body: '$finalInviterName te ha invitado a unirte al plan "$finalPlanName"',
        planId: planId,
        createdAt: DateTime.now(),
        data: {
          'token': invitationToken,
          'inviterUserId': inviterUserId,
          'inviterName': finalInviterName,
          'email': invitedEmail,
        },
      );

      final notificationId = await _notificationService.createNotification(
        invitedUserId,
        notification,
      );

      if (notificationId != null) {
        LoggerService.info(
          'Invitation notification created for user: $invitedUserId, plan: $planId',
          context: 'NOTIFICATION_HELPER',
        );
        return true;
      }

      return false;
    } catch (e) {
      LoggerService.error(
        'Error creating invitation notification for plan: $planId',
        context: 'NOTIFICATION_HELPER',
        error: e,
      );
      return false;
    }
  }

  /// Notificar al organizador (invitador) cuando un invitado acepta o rechaza la invitación.
  ///
  /// [inviterUserId] - ID del usuario que envió la invitación (recibe la notificación)
  /// [planId] - ID del plan
  /// [respondedUserDisplay] - Nombre o email del que respondió (para el cuerpo del mensaje)
  /// [accepted] - true si aceptó, false si rechazó
  Future<bool> notifyInvitationResponded({
    required String? inviterUserId,
    required String planId,
    required String respondedUserDisplay,
    required bool accepted,
  }) async {
    if (inviterUserId == null || inviterUserId.isEmpty) return false;
    try {
      String finalPlanName = 'Un plan';
      final plan = await _planService.getPlanById(planId);
      if (plan != null) finalPlanName = plan.name;

      final type = accepted ? NotificationType.invitationAccepted : NotificationType.invitationRejected;
      final title = accepted
          ? '✅ Invitación aceptada'
          : 'Invitación rechazada';
      final body = accepted
          ? '$respondedUserDisplay ha aceptado tu invitación al plan "$finalPlanName"'
          : '$respondedUserDisplay ha rechazado tu invitación al plan "$finalPlanName"';

      final notification = NotificationModel(
        userId: inviterUserId,
        type: type,
        title: title,
        body: body,
        planId: planId,
        createdAt: DateTime.now(),
        data: {'accepted': accepted, 'respondedUserDisplay': respondedUserDisplay},
      );

      final id = await _notificationService.createNotification(inviterUserId, notification);
      if (id != null) {
        LoggerService.info(
          'Invitation response notification created for inviter: $inviterUserId, plan: $planId',
          context: 'NOTIFICATION_HELPER',
        );
        return true;
      }
      return false;
    } catch (e) {
      LoggerService.error(
        'Error creating invitation response notification for plan: $planId',
        context: 'NOTIFICATION_HELPER',
        error: e,
      );
      return false;
    }
  }
}
