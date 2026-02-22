import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../../../calendar/domain/models/plan_invitation.dart';
import '../../../calendar/domain/models/pending_email_event.dart';
import '../../../calendar/domain/services/plan_service.dart';

/// Genera notificaciones de prueba de todos los tipos y para varios planes.
/// Solo para desarrollo/testing.
class TestNotificationGenerator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final PlanService _planService = PlanService();

  static String _randomToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return sha256.convert(bytes).toString();
  }

  /// Genera invitaciones, eventos desde correo y notificaciones in-app para el usuario.
  /// [userId] usuario actual (Firestore user id, usado en invitaciones y en NotificationModel.userId).
  /// [authUid] Auth UID (usado en ruta users/{authUid}/pending_email_events y debe coincidir con reglas en notifications).
  /// [userEmail] email del usuario (para que las invitaciones aparezcan en su lista).
  Future<({int invitations, int pendingEvents, int appNotifications})> generate({
    required String userId,
    required String authUid,
    required String userEmail,
  }) async {
    int countInv = 0;
    int countPending = 0;
    int countNotif = 0;

    final plans = await _planService.getPlansForUser(userId).first;
    final planIds = plans.where((p) => p.id != null).map((p) => p.id!).take(3).toList();
    if (planIds.isEmpty) {
      planIds.add('plan-demo-1');
      planIds.add('plan-demo-2');
    }

    final now = DateTime.now();
    final normalizedEmail = userEmail.toLowerCase().trim();

    // 1. Invitaciones (plan_invitations) - 2 por plan distinto
    for (var i = 0; i < planIds.length && i < 2; i++) {
      final planId = planIds[i];
      try {
        final token = _randomToken();
        final inv = PlanInvitation(
          planId: planId,
          email: normalizedEmail,
          token: token,
          role: 'participant',
          createdAt: now.subtract(Duration(hours: i + 1)),
          expiresAt: now.add(const Duration(days: 7)),
          status: 'pending',
        );
        await _firestore.collection('plan_invitations').add(inv.toFirestore());
        countInv++;
      } catch (_) {}
    }

    // 2. Eventos desde correo (users/{authUid}/pending_email_events)
    final pendingTitles = [
      'Reunión equipo',
      'Cena de bienvenida',
      'Tour por la ciudad',
    ];
    for (var i = 0; i < pendingTitles.length; i++) {
      try {
        final ref = _firestore
            .collection('users')
            .doc(authUid)
            .collection('pending_email_events')
            .doc();
        await ref.set({
          'subject': pendingTitles[i],
          'bodyPlain': 'Confirmación de ${pendingTitles[i]}. Fecha: ${now.add(Duration(days: i + 1))}.',
          'fromEmail': 'noreply@example.com',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(now.subtract(Duration(hours: 2 + i))),
          'updatedAt': Timestamp.fromDate(now),
          if (i == 0) 'parsed': {
            'title': pendingTitles[i],
            'location': 'Oficina central',
            'event_type': 'reunion',
          },
        });
        countPending++;
      } catch (_) {}
    }

    // 3. Notificaciones in-app (users/{userId}/notifications) - reglas usan request.auth.uid == userId
    // Por tanto la ruta debe ser users/{authUid}/notifications para que el cliente pueda crear
    final typesAndTitles = [
      (NotificationType.announcement, '📢 Nuevo aviso en "${planIds.isNotEmpty ? "Plan" : "Plan demo"}"', 'El organizador ha publicado un aviso.'),
      (NotificationType.eventCreated, '📅 Nuevo evento creado', 'Se ha añadido un evento al plan.'),
      (NotificationType.eventUpdated, '✏️ Evento modificado', 'Un evento ha sido actualizado.'),
      (NotificationType.invitation, '📧 Invitación a un plan', 'Te han invitado a unirte a un plan.'),
      (NotificationType.planStateChanged, '🏁 Estado del plan actualizado', 'El plan ha pasado a estado confirmado.'),
      (NotificationType.participantAdded, '👤 Nuevo participante', 'Alguien se ha unido al plan.'),
      (NotificationType.invitationAccepted, '✅ Invitación aceptada', 'Un invitado ha aceptado la invitación.'),
      (NotificationType.alarm, '⏰ Recordatorio', 'En 1 hora: Reunión importante.'),
    ];
    for (var i = 0; i < typesAndTitles.length; i++) {
      final t = typesAndTitles[i];
      final planId = planIds.isNotEmpty ? planIds[i % planIds.length] : null;
      try {
        final n = NotificationModel(
          userId: authUid,
          type: t.$1,
          title: t.$2,
          body: t.$3,
          planId: planId,
          isRead: i % 3 == 0,
          createdAt: now.subtract(Duration(hours: 24 - i)),
          data: planId != null ? {'planId': planId} : null,
        );
        final id = await _notificationService.createNotification(authUid, n);
        if (id != null) countNotif++;
      } catch (_) {}
    }

    return (invitations: countInv, pendingEvents: countPending, appNotifications: countNotif);
  }
}
