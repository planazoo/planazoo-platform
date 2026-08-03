import 'package:cloud_functions/cloud_functions.dart'
    show FirebaseFunctions, FirebaseFunctionsException;
import 'logger_service.dart' show LoggerService;

/// Envío de push vía Cloud Functions (FCM Admin). No usar para spam: el servidor valida permisos.
class PushNotificationSender {
  PushNotificationSender._();

  /// Push al invitado tras crear invitación con participación `pending` (valida `invitedBy` en CF).
  static Future<void> trySendInvitationPush({
    required String invitedUserId,
    required String planId,
    required String title,
    required String body,
  }) async {
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('sendInvitationPush').call({
        'invitedUserId': invitedUserId,
        'planId': planId,
        'title': title,
        'body': body,
      });
      final data = result.data;
      LoggerService.info(
        'sendInvitationPush ok planId=$planId invited=$invitedUserId result=$data',
        context: 'PUSH_SENDER',
      );
    } on FirebaseFunctionsException catch (e, st) {
      LoggerService.error(
        'sendInvitationPush ${e.code} ${e.message}',
        context: 'PUSH_SENDER',
        error: e,
        stackTrace: st,
      );
    } catch (e, st) {
      LoggerService.error(
        'sendInvitationPush',
        context: 'PUSH_SENDER',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Push genérico (p. ej. organizador al aceptar/rechazar). Callable `sendPushNotification`.
  static Future<void> trySendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('sendPushNotification').call({
        'userId': userId,
        'title': title,
        'body': body,
        if (data != null) 'data': data,
      });
      LoggerService.info(
        'sendPushNotification ok userId=$userId result=${result.data}',
        context: 'PUSH_SENDER',
      );
    } on FirebaseFunctionsException catch (e, st) {
      LoggerService.error(
        'sendPushNotification ${e.code} ${e.message}',
        context: 'PUSH_SENDER',
        error: e,
        stackTrace: st,
      );
    } catch (e, st) {
      LoggerService.error(
        'sendPushNotification',
        context: 'PUSH_SENDER',
        error: e,
        stackTrace: st,
      );
    }
  }
}
