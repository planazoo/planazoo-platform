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
      await FirebaseFunctions.instance.httpsCallable('sendInvitationPush').call({
        'invitedUserId': invitedUserId,
        'planId': planId,
        'title': title,
        'body': body,
      });
      LoggerService.info(
        'sendInvitationPush ok planId=$planId invited=$invitedUserId',
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
}
