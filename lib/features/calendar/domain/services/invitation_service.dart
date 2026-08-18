// ignore_for_file: unnecessary_non_null_assertion, unnecessary_null_comparison, dead_null_aware_expression

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/plan.dart';
import '../models/plan_invitation.dart';
import 'plan_participation_service.dart';
import 'plan_state_permissions.dart';
import '../../../auth/domain/services/user_service.dart';
import '../../../notifications/domain/services/notification_helper.dart';
import '../../../notifications/domain/services/notification_service.dart';

/// Resultado de aceptar/rechazar invitación (mensaje listo para UI).
class InvitationRespondResult {
  final bool success;
  final String message;
  /// Plan al que navegar tras aceptar (también si ya era miembro).
  final String? planId;
  /// Ya estaba accepted / dentro del plan (re-tap del link).
  final bool alreadyMember;

  const InvitationRespondResult({
    required this.success,
    required this.message,
    this.planId,
    this.alreadyMember = false,
  });
}

/// Resultado de validar si una invitación sigue accionable (diagrama §1.2).
class InvitationActionabilityResult {
  final bool actionable;
  /// Código corto: A, B, C, D, E, F, G, H, I, …
  final String code;
  final String message;

  const InvitationActionabilityResult({
    required this.actionable,
    required this.code,
    required this.message,
  });
}

/// Servicio para gestionar invitaciones a planes por email (T104)
/// 
/// Permite invitar usuarios por email aunque no conozcamos su ID.
/// Genera links únicos con token que expiran en 7 días.
class InvitationService {
  InvitationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collectionName = 'plan_invitations';
  PlanParticipationService? _lazyParticipationService;
  UserService? _lazyUserService;
  NotificationService? _lazyNotificationService;

  PlanParticipationService get _participationService =>
      _lazyParticipationService ??=
          PlanParticipationService(firestore: _firestore);

  UserService get _userService => _lazyUserService ??= UserService();

  NotificationService get _notificationService =>
      _lazyNotificationService ??= NotificationService();

  /// Genera un token único para una invitación
  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Crea una invitación por email
  /// 
  /// Siempre crea una invitación con token que requiere aceptación explícita,
  /// independientemente de si el usuario ya existe en el sistema o no.
  /// Esto asegura que todos los usuarios (nuevos o previamente eliminados) 
  /// deben aceptar explícitamente la invitación.
  Future<String?> createInvitation({
    required String planId,
    required String email,
    String? invitedBy,
    String role = 'participant',
    String? customMessage,
  }) async {
    try {
      // Normalizar email a minúsculas
      final normalizedEmail = email.toLowerCase().trim();

      // Si el correo ya existe en la BD, invitar directamente (crear participación pending)
      // para que aparezca en la lista de participantes y reciba notificación in-app.
      final existingUser = await _userService.getUserByEmail(normalizedEmail);
      if (existingUser != null) {
        final existingParticipation =
            await _participationService.getParticipation(planId, existingUser.id);
        if (existingParticipation != null &&
            existingParticipation.isActive &&
            existingParticipation.status == 'accepted') {
          LoggerService.warning(
            'User $normalizedEmail already participates in plan $planId',
          );
          return null;
        }

        // Usuario registrado: participación pending (nueva o ya existente sin notificación).
        String? participationId = existingParticipation?.id;
        if (participationId == null ||
            existingParticipation?.isActive != true ||
            existingParticipation?.status != 'pending') {
          participationId = await _participationService.createParticipation(
            planId: planId,
            userId: existingUser.id,
            role: role,
            invitedBy: invitedBy,
            autoAccept: false,
          );
        } else if (invitedBy != null &&
            existingParticipation!.invitedBy != invitedBy &&
            participationId != null) {
          // Alinear invitedBy con quien reenvía (la CF de push lo exige).
          try {
            await _firestore.collection('plan_participations').doc(participationId).update({
              'invitedBy': invitedBy,
            });
          } catch (e) {
            LoggerService.warning(
              'Could not update invitedBy on pending participation $participationId: $e',
            );
          }
        }
        if (participationId != null) {
          // Cancelar invitaciones pending previas y crear una nueva con token.
          // onCreate de sendInvitationEmail envía el correo (LISTA / diagrama §1.1 decisión 1).
          await dismissPendingInvitationDocsForEmail(
            planId: planId,
            email: normalizedEmail,
          );
          final token = _generateToken();
          final now = DateTime.now();
          final invitation = PlanInvitation(
            planId: planId,
            email: normalizedEmail,
            token: token,
            invitedBy: invitedBy,
            role: role,
            customMessage: customMessage,
            createdAt: now,
            expiresAt: now.add(const Duration(days: 7)),
            status: 'pending',
          );
          // Doc ID = token → get público si pending (deep link §2 sin sesión).
          await _firestore.collection(_collectionName).doc(token).set(invitation.toFirestore());

          String? inviterName;
          if (invitedBy != null) {
            final inviter = await _userService.getUser(invitedBy);
            inviterName = inviter?.displayName ?? inviter?.email ?? 'Un usuario';
          }
          await NotificationHelper().notifyInvitationCreated(
            planId: planId,
            invitedUserId: existingUser.id,
            invitedEmail: normalizedEmail,
            inviterUserId: invitedBy ?? '',
            invitationToken: token,
            planName: null,
            inviterName: inviterName,
          );
          LoggerService.database(
            'Direct invitation (participation pending + email): $participationId for $normalizedEmail',
            operation: 'CREATE',
          );
          return 'direct:$participationId';
        }
      }

      // Si ya hay pending: cancelar y crear de nuevo → reenvío email (onCreate CF) + enlace nuevo.
      await dismissPendingInvitationDocsForEmail(
        planId: planId,
        email: normalizedEmail,
      );

      // Siempre crear una invitación con token (requiere aceptación explícita)
      // Esto aplica tanto para usuarios nuevos como para usuarios previamente eliminados
      final token = _generateToken();
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 7)); // Expira en 7 días

      final invitation = PlanInvitation(
        planId: planId,
        email: normalizedEmail,
        token: token,
        invitedBy: invitedBy,
        role: role,
        customMessage: customMessage,
        createdAt: now,
        expiresAt: expiresAt,
        status: 'pending',
      );

      // Doc ID = token → get público si pending (deep link §2 sin sesión).
      await _firestore.collection(_collectionName).doc(token).set(invitation.toFirestore());

      LoggerService.database(
        'Invitation created: $token for email: $normalizedEmail (requires explicit acceptance)',
        operation: 'CREATE',
      );

      // El email se envía automáticamente mediante Cloud Function
      // que se activa cuando se crea el documento en Firestore (T104)
      // Ver: functions/index.js - sendInvitationEmail

      return token;
    } catch (e) {
      LoggerService.error(
        'Error creating invitation: $email, plan: $planId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return null;
    }
  }

  /// Obtener invitación por ID
  Future<PlanInvitation?> getInvitationById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return PlanInvitation.fromFirestore(doc);
    } catch (e) {
      LoggerService.error('Error getting invitation by id: $id', context: 'INVITATION_SERVICE', error: e);
      return null;
    }
  }

  /// Obtener invitación por token (deep link `/invitation/{token}`).
  ///
  /// Preferencia: documento con ID = token (lectura pública si `pending`).
  /// Fallback legacy: query por campo `token` (requiere autenticación por rules de list).
  Future<PlanInvitation?> getInvitationByToken(String token) async {
    try {
      final trimmed = token.trim();
      if (trimmed.isEmpty) return null;

      final byId = await _firestore.collection(_collectionName).doc(trimmed).get();
      if (byId.exists) {
        return _invitationFromDocConsideringExpiry(byId);
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('token', isEqualTo: trimmed)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        return _getInvitationByTokenViaCloudFunction(trimmed);
      }
      return _invitationFromDocConsideringExpiry(querySnapshot.docs.first);
    } catch (e) {
      LoggerService.warning(
        'Client getInvitationByToken failed, trying CF: $token',
        context: 'INVITATION_SERVICE',
      );
      return _getInvitationByTokenViaCloudFunction(token.trim());
    }
  }

  /// Lectura Admin SDK cuando las rules niegan el doc (p. ej. ya no `pending`).
  Future<PlanInvitation?> _getInvitationByTokenViaCloudFunction(String token) async {
    if (token.isEmpty) return null;
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('resolveInvitationByToken')
          .call({'token': token});
      final data = Map<String, dynamic>.from(result.data as Map);
      if (data['found'] != true) return null;
      return PlanInvitation(
        id: data['id'] as String?,
        planId: data['planId'] as String? ?? '',
        email: data['email'] as String? ?? '',
        token: data['token'] as String? ?? token,
        invitedBy: data['invitedBy'] as String?,
        role: data['role'] as String? ?? 'participant',
        customMessage: data['customMessage'] as String?,
        createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
            DateTime.now(),
        expiresAt: DateTime.tryParse(data['expiresAt'] as String? ?? '') ??
            DateTime.now().add(const Duration(days: 7)),
        status: data['status'] as String? ?? 'pending',
        respondedAt: data['respondedAt'] != null
            ? DateTime.tryParse(data['respondedAt'] as String)
            : null,
      );
    } catch (e) {
      LoggerService.error(
        'Error getting invitation by token (CF): $token',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return null;
    }
  }

  Future<PlanInvitation> _invitationFromDocConsideringExpiry(
    DocumentSnapshot doc,
  ) async {
    final invitation = PlanInvitation.fromFirestore(doc);
    if (invitation.isPending && invitation.isExpired) {
      try {
        await doc.reference.update({
          'status': 'expired',
          'respondedAt': Timestamp.fromDate(DateTime.now()),
        });
      } catch (_) {
        // Sin sesión el update puede fallar; igual devolvemos estado expirado en cliente.
      }
      return invitation.copyWith(status: 'expired');
    }
    return invitation;
  }

  /// Aceptar por token (enlace del email). Bloquea si el email de sesión ≠ invitación (caso J).
  Future<InvitationRespondResult> acceptInvitationByToken(
    String token,
    String userId,
  ) async {
    try {
      final invitation = await getInvitationByToken(token);
      if (invitation == null) {
        return const InvitationRespondResult(
          success: false,
          message: 'Esta invitación ya no está disponible',
        );
      }
      if (invitation.isAccepted) {
        return InvitationRespondResult(
          success: true,
          message: 'Ya formas parte de este plan',
          planId: invitation.planId,
          alreadyMember: true,
        );
      }
      if (invitation.isRejected) {
        return const InvitationRespondResult(
          success: false,
          message: 'Ya rechazaste esta invitación',
        );
      }
      if (invitation.status == 'cancelled') {
        return const InvitationRespondResult(
          success: false,
          message: 'El organizador canceló la invitación',
        );
      }
      if (!invitation.isValid) {
        return const InvitationRespondResult(
          success: false,
          message: 'Esta invitación ha caducado',
        );
      }

      final user = await _userService.getUser(userId);
      if (user == null) {
        return const InvitationRespondResult(
          success: false,
          message: 'Esta cuenta ya no está disponible',
        );
      }

      final userEmail = user.email.toLowerCase().trim();
      final invitationEmail = invitation.email.toLowerCase().trim();
      if (userEmail != invitationEmail) {
        return InvitationRespondResult(
          success: false,
          message:
              'Esta invitación es para $invitationEmail. Cierra sesión o usa la cuenta invitada.',
        );
      }

      // Reutiliza el flujo por planId (participación, CF, avisos, side effects A2).
      return acceptInvitationByPlanId(invitation.planId, userId);
    } catch (e) {
      LoggerService.error(
        'Error accepting invitation by token: $token',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return const InvitationRespondResult(
        success: false,
        message: 'Error al aceptar la invitación',
      );
    }
  }

  /// Rechazar por token. Misma comprobación de identidad (caso J).
  Future<InvitationRespondResult> rejectInvitationByToken(
    String token,
    String userId,
  ) async {
    try {
      final invitation = await getInvitationByToken(token);
      if (invitation == null || !invitation.isValid) {
        return const InvitationRespondResult(
          success: false,
          message: 'Esta invitación ya no está pendiente',
        );
      }

      final user = await _userService.getUser(userId);
      if (user == null) {
        return const InvitationRespondResult(
          success: false,
          message: 'Esta cuenta ya no está disponible',
        );
      }

      final userEmail = user.email.toLowerCase().trim();
      final invitationEmail = invitation.email.toLowerCase().trim();
      if (userEmail != invitationEmail) {
        return InvitationRespondResult(
          success: false,
          message:
              'Esta invitación es para $invitationEmail. Cierra sesión o usa la cuenta invitada.',
        );
      }

      return rejectInvitationByPlanId(invitation.planId, userId);
    } catch (e) {
      LoggerService.error(
        'Error rejecting invitation by token: $token',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return const InvitationRespondResult(
        success: false,
        message: 'Error al rechazar la invitación',
      );
    }
  }

  /// Obtener invitación pendiente por email y plan (público para uso en UI)
  Future<PlanInvitation?> getPendingInvitationByEmail(String planId, String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('email', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return PlanInvitation.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      LoggerService.error(
        'Error getting pending invitation by email: $email, plan: $planId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return null;
    }
  }

  /// Listar invitaciones pendientes para un email (todas los planes)
  /// 
  /// NOTA: Este método se usa principalmente para la primera vez (recién registrado).
  /// Después del primer acceso, usar getPendingInvitationsByUserId.
  /// Fuerza lectura desde servidor para evitar caché y filtra en cliente solo pending y no expiradas.
  Future<List<PlanInvitation>> getPendingInvitationsByEmail(String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .get(const GetOptions(source: Source.server));
      final list = querySnapshot.docs
          .map((d) => PlanInvitation.fromFirestore(d))
          .where((inv) => inv.isPending && !inv.isExpired)
          .toList();
      list.sort((a, b) => (b.createdAt).compareTo(a.createdAt));
      return list;
    } catch (e) {
      LoggerService.error('Error getting pending invitations by email: $email', context: 'INVITATION_SERVICE', error: e);
      return [];
    }
  }

  /// Obtener invitaciones pendientes por userId (prioritario)
  /// 
  /// Estrategia:
  /// 1. Si hay participaciones pendientes (userId) → NO buscar invitaciones
  ///    (la invitación ya fue procesada, la participación pendiente es suficiente)
  /// 2. Si NO hay participaciones pendientes → buscar invitaciones por email (primera vez)
  /// 
  /// Esto asegura que después del primer acceso, todo se relacione por userId
  /// a través de participaciones, no por email.
  Future<List<PlanInvitation>> getPendingInvitationsByUserId(String userId, String? email) async {
    try {
      final participations = await _participationService.getUserParticipations(userId).first;
      final pendingParticipations = participations.where((p) => p.status == 'pending').toList();
      
      if (pendingParticipations.isNotEmpty) {
        // Hay participaciones pendientes - el estado lo marcan las participaciones.
        return [];
      }

      // Planes donde ya está aceptado o rechazado: no deben reaparecer como invitación pendiente
      // (p. ej. si markInvitationAccepted/Rejected CF falló y el doc invitation sigue pending).
      final settledPlanIds = participations
          .where((p) =>
              p.isActive && (p.isAccepted || p.isRejected))
          .map((p) => p.planId)
          .toSet();
      
      if (email == null) return [];
      final list = await getPendingInvitationsByEmail(email!);
      return list
          .where((inv) =>
              inv.isPending &&
              !inv.isExpired &&
              !settledPlanIds.contains(inv.planId))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error getting pending invitations by userId: $userId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return [];
    }
  }

  Future<void> _cleanupInviteeInvitationNotifications(String userId, String planId) async {
    await _notificationService.deleteInvitationNotificationsForPlan(
      userId: userId,
      planId: planId,
    );
  }

  /// Valida si la invitación/participación pending sigue accionable (§1.2 casos A–I).
  /// Si [cleanupIfInvalid] y no es accionable, borra avisos `invitation` del plan
  /// y marca `expired` cuando el plan ya no admite altas o caducó.
  Future<InvitationActionabilityResult> evaluateInvitationActionability({
    required String planId,
    required String userId,
    bool cleanupIfInvalid = true,
  }) async {
    try {
      final user = await _userService.getUser(userId);
      if (user == null) {
        return const InvitationActionabilityResult(
          actionable: false,
          code: 'L',
          message: 'Esta cuenta ya no está disponible',
        );
      }

      final planDoc = await _firestore.collection('plans').doc(planId).get();
      if (!planDoc.exists) {
        if (cleanupIfInvalid) {
          await _cleanupInviteeInvitationNotifications(userId, planId);
        }
        return const InvitationActionabilityResult(
          actionable: false,
          code: 'I',
          message: 'Esta invitación ya no está disponible',
        );
      }
      final plan = Plan.fromFirestore(planDoc);

      final part = await _participationService.getParticipation(planId, userId);
      if (part != null && part.isActive && part.status == 'accepted') {
        if (cleanupIfInvalid) {
          await _cleanupInviteeInvitationNotifications(userId, planId);
        }
        return const InvitationActionabilityResult(
          actionable: false,
          code: 'B',
          message: 'Ya formas parte de este plan',
        );
      }

      final email = user.email.toLowerCase().trim();
      PlanInvitation? pendingInv;
      if (email.isNotEmpty) {
        pendingInv = await getPendingInvitationByEmail(planId, email);
      }

      final hasPendingPart = part != null && part.isActive && part.isPending;
      final hasPendingInv = pendingInv != null && pendingInv.isPending;

      if (!hasPendingPart && !hasPendingInv) {
        if (part != null && part.isRejected) {
          if (cleanupIfInvalid) {
            await _cleanupInviteeInvitationNotifications(userId, planId);
          }
          return const InvitationActionabilityResult(
            actionable: false,
            code: 'C',
            message: 'Ya rechazaste esta invitación',
          );
        }
        // Última invitación cancelada / caducada por email (si hay cuenta).
        if (email.isNotEmpty) {
          final latest = await _latestInvitationForEmail(planId, email);
          if (latest != null) {
            if (latest.status == 'cancelled') {
              if (cleanupIfInvalid) {
                await _cleanupInviteeInvitationNotifications(userId, planId);
              }
              return const InvitationActionabilityResult(
                actionable: false,
                code: 'D',
                message: 'El organizador canceló la invitación',
              );
            }
            if (latest.status == 'expired' || latest.isExpired) {
              if (cleanupIfInvalid) {
                await _cleanupInviteeInvitationNotifications(userId, planId);
              }
              return const InvitationActionabilityResult(
                actionable: false,
                code: 'E',
                message: 'Esta invitación ha caducado',
              );
            }
          }
        }
        if (cleanupIfInvalid) {
          await _cleanupInviteeInvitationNotifications(userId, planId);
        }
        return const InvitationActionabilityResult(
          actionable: false,
          code: 'A_gone',
          message: 'Ya no hay invitación pendiente',
        );
      }

      if (pendingInv != null && pendingInv.isExpired) {
        if (pendingInv.id != null) {
          await _firestore.collection(_collectionName).doc(pendingInv.id).update({
            'status': 'expired',
            'respondedAt': Timestamp.fromDate(DateTime.now()),
          });
        }
        await _participationService.expirePendingInvitation(planId, userId);
        if (cleanupIfInvalid) {
          await _cleanupInviteeInvitationNotifications(userId, planId);
        }
        return const InvitationActionabilityResult(
          actionable: false,
          code: 'E',
          message: 'Esta invitación ha caducado',
        );
      }

      if (!PlanStatePermissions.canAddParticipants(plan)) {
        final state = plan.state ?? 'planificando';
        final code = switch (state) {
          'en_curso' => 'F',
          'finalizado' => 'G',
          'cancelado' => 'H',
          _ => 'F',
        };
        final message = switch (state) {
          'en_curso' => 'El plan ya ha empezado; ya no puedes unirte',
          'finalizado' => 'Este plan ya ha terminado',
          'cancelado' => 'Este plan fue cancelado',
          _ => 'Ya no puedes unirte a este plan',
        };
        if (cleanupIfInvalid) {
          await _participationService.expirePendingInvitation(planId, userId);
          await _cleanupInviteeInvitationNotifications(userId, planId);
        }
        return InvitationActionabilityResult(
          actionable: false,
          code: code,
          message: message,
        );
      }

      return const InvitationActionabilityResult(
        actionable: true,
        code: 'A',
        message: 'Invitación pendiente',
      );
    } catch (e) {
      LoggerService.error(
        'Error evaluating invitation actionability: $planId / $userId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return const InvitationActionabilityResult(
        actionable: false,
        code: 'I',
        message: 'Esta invitación ya no está disponible',
      );
    }
  }

  Future<PlanInvitation?> _latestInvitationForEmail(String planId, String email) async {
    try {
      final snap = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('email', isEqualTo: email)
          .limit(20)
          .get();
      if (snap.docs.isEmpty) return null;
      final list = snap.docs.map(PlanInvitation.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list.first;
    } catch (_) {
      return null;
    }
  }

  /// Si el plan no admite altas, limpia avisos y marca participación expired.
  Future<InvitationRespondResult?> _blockIfPlanNotJoinable({
    required String planId,
    required String userId,
  }) async {
    final planDoc = await _firestore.collection('plans').doc(planId).get();
    if (!planDoc.exists) {
      await _participationService.expirePendingInvitation(planId, userId);
      await _cleanupInviteeInvitationNotifications(userId, planId);
      return const InvitationRespondResult(
        success: false,
        message: 'Esta invitación ya no está disponible',
      );
    }
    final plan = Plan.fromFirestore(planDoc);
    if (PlanStatePermissions.canAddParticipants(plan)) {
      return null;
    }
    await _participationService.expirePendingInvitation(planId, userId);
    await _cleanupInviteeInvitationNotifications(userId, planId);
    final state = plan.state ?? 'planificando';
    final message = switch (state) {
      'en_curso' => 'El plan ya ha empezado; ya no puedes unirte',
      'finalizado' => 'Este plan ya ha terminado',
      'cancelado' => 'Este plan fue cancelado',
      _ => 'Ya no puedes unirte a este plan',
    };
    return InvitationRespondResult(success: false, message: message);
  }

  /// Aceptar invitación directamente por planId y userId (sin token)
  Future<InvitationRespondResult> acceptInvitationByPlanId(String planId, String userId) async {
    try {
      final user = await _userService.getUser(userId);
      if (user == null || user.email == null) {
        return const InvitationRespondResult(
          success: false,
          message: 'Error: usuario no encontrado',
        );
      }

      final blocked = await _blockIfPlanNotJoinable(planId: planId, userId: userId);
      if (blocked != null) return blocked;

      // Ya dentro: no re-notificar al organizador (evita duplicados por taps repetidos).
      final existingPart = await _participationService.getParticipation(planId, userId);
      if (existingPart != null &&
          existingPart.isActive &&
          existingPart.status == 'accepted') {
        await _cleanupInviteeInvitationNotifications(userId, planId);
        return InvitationRespondResult(
          success: true,
          message: 'Ya formas parte de este plan',
          planId: planId,
          alreadyMember: true,
        );
      }

      final normalizedEmail = user.email!.toLowerCase().trim();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('email', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        final ok = await _participationService.acceptInvitation(planId, userId);
        if (ok) {
          final respondedDisplay =
              user.displayName?.trim().isNotEmpty == true ? user.displayName! : user.email!;
          final part = await _participationService.getParticipation(planId, userId);
          await NotificationHelper().notifyInvitationResponded(
            inviterUserId: part?.invitedBy,
            planId: planId,
            respondedUserDisplay: respondedDisplay,
            accepted: true,
          );
          await _cleanupInviteeInvitationNotifications(userId, planId);
          return const InvitationRespondResult(
            success: true,
            message: 'Has aceptado la invitación',
          );
        }
        await _cleanupInviteeInvitationNotifications(userId, planId);
        return const InvitationRespondResult(
          success: false,
          message: 'Esta invitación ya no está pendiente',
        );
      }

      final invitationDoc = querySnapshot.docs.first;
      final invitation = PlanInvitation.fromFirestore(invitationDoc);

      if (invitation.isExpired) {
        await invitationDoc.reference.update({
          'status': 'expired',
          'respondedAt': Timestamp.fromDate(DateTime.now()),
        });
        await _participationService.expirePendingInvitation(planId, userId);
        await _cleanupInviteeInvitationNotifications(userId, planId);
        return const InvitationRespondResult(
          success: false,
          message: 'Esta invitación ha caducado',
        );
      }

      final participationId = await _participationService.createParticipation(
        planId: planId,
        userId: userId,
        role: invitation.role ?? 'participant',
        invitedBy: invitation.invitedBy,
        autoAccept: true,
      );

      if (participationId == null) {
        return const InvitationRespondResult(
          success: false,
          message: 'No se pudo aceptar la invitación',
        );
      }

      // Tras createParticipation: si ya accepted, no re-notificar ni fallar por side effects.
      final afterCreate =
          await _participationService.getParticipation(planId, userId);
      final wasAlreadyAccepted = afterCreate != null &&
          afterCreate.isActive &&
          afterCreate.status == 'accepted';

      if (!wasAlreadyAccepted) {
        await _participationService.acceptInvitation(planId, userId);
      }

      final token = invitation.token;
      if (token.isNotEmpty) {
        if (kDebugMode) {
          LoggerService.debug('Calling markInvitationAccepted Cloud Function (acceptByPlanId)', context: 'INVITATION_SERVICE');
        }
        try {
          final result = await FirebaseFunctions.instance
              .httpsCallable('markInvitationAccepted')
              .call({'token': token});
          final data = result.data as Map<String, dynamic>?;
          if (data != null && data['success'] == true) {
            LoggerService.database(
              'Invitation accepted via Cloud Function (planId): ${invitation.id}, participation: $participationId',
              operation: 'UPDATE',
            );
          }
        } catch (cfError) {
          // Idempotente: CF puede devolver not-found si ya estaba accepted.
          LoggerService.warning(
            'markInvitationAccepted CF (planId flow): $planId — $cfError',
            context: 'INVITATION_SERVICE',
          );
          try {
            await invitationDoc.reference.update({
              'status': 'accepted',
              'respondedAt': Timestamp.fromDate(DateTime.now()),
            });
          } catch (_) {
            // Rules pueden negar update si ya no está pending; OK.
          }
        }
      } else {
        try {
          await invitationDoc.reference.update({
            'status': 'accepted',
            'respondedAt': Timestamp.fromDate(DateTime.now()),
          });
        } catch (_) {}
      }

      if (!wasAlreadyAccepted) {
        final respondedDisplay =
            user.displayName?.trim().isNotEmpty == true ? user.displayName! : user.email!;
        await NotificationHelper().notifyInvitationResponded(
          inviterUserId: invitation.invitedBy,
          planId: planId,
          respondedUserDisplay: respondedDisplay,
          accepted: true,
        );
      }
      await _cleanupInviteeInvitationNotifications(userId, planId);
      return InvitationRespondResult(
        success: true,
        message: wasAlreadyAccepted
            ? 'Ya formas parte de este plan'
            : 'Has aceptado la invitación',
        planId: planId,
        alreadyMember: wasAlreadyAccepted,
      );
    } catch (e) {
      LoggerService.error(
        'Error accepting invitation by planId: $planId, userId: $userId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return InvitationRespondResult(
        success: false,
        message: 'Error al aceptar la invitación',
      );
    }
  }

  /// Rechazar invitación directamente por planId y userId (sin token)
  Future<InvitationRespondResult> rejectInvitationByPlanId(String planId, String userId) async {
    try {
      final user = await _userService.getUser(userId);
      if (user == null || user.email == null) {
        return const InvitationRespondResult(
          success: false,
          message: 'Error: usuario no encontrado',
        );
      }

      final normalizedEmail = user.email!.toLowerCase().trim();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('email', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      String? inviterUserId;
      String? invitationToken;

      if (querySnapshot.docs.isEmpty) {
        final ok = await _participationService.rejectInvitation(planId, userId);
        if (ok) {
          final respondedDisplay =
              user.displayName?.trim().isNotEmpty == true ? user.displayName! : user.email!;
          final part = await _participationService.getParticipation(planId, userId);
          inviterUserId = part?.invitedBy;
          await NotificationHelper().notifyInvitationResponded(
            inviterUserId: inviterUserId,
            planId: planId,
            respondedUserDisplay: respondedDisplay,
            accepted: false,
          );
          await _cleanupInviteeInvitationNotifications(userId, planId);
          return const InvitationRespondResult(
            success: true,
            message: 'Has rechazado la invitación',
          );
        }
        await _cleanupInviteeInvitationNotifications(userId, planId);
        return const InvitationRespondResult(
          success: false,
          message: 'Esta invitación ya no está pendiente',
        );
      }

      final doc = querySnapshot.docs.first;
      final inv = PlanInvitation.fromFirestore(doc);
      inviterUserId = inv.invitedBy;
      invitationToken = inv.token.isNotEmpty ? inv.token : doc.id;

      // Igual que accept: marcar invitation vía CF (Admin SDK) para evitar permission-denied.
      try {
        await FirebaseFunctions.instance
            .httpsCallable('markInvitationRejected')
            .call({
          if (invitationToken != null && invitationToken.isNotEmpty)
            'token': invitationToken,
          'planId': planId,
        });
      } catch (cfError) {
        LoggerService.error(
          'Cloud Function markInvitationRejected failed (planId flow): $planId. Falling back to client update.',
          context: 'INVITATION_SERVICE',
          error: cfError,
        );
        try {
          await doc.reference.update({
            'status': 'rejected',
            'respondedAt': Timestamp.fromDate(DateTime.now()),
          });
        } catch (e) {
          LoggerService.error(
            'Client fallback mark invitation rejected failed: $planId',
            context: 'INVITATION_SERVICE',
            error: e,
          );
          // Seguir: al menos rechazar participación.
        }
      }

      final partOk = await _participationService.rejectInvitation(planId, userId);
      if (!partOk) {
        // La invitation pudo quedar rejected; UI debe reflejar fuera igual.
        LoggerService.warning(
          'Participation reject returned false after invitation reject: $planId / $userId',
          context: 'INVITATION_SERVICE',
        );
      }
      LoggerService.database('Invitation rejected by planId: ${doc.id}', operation: 'UPDATE');

      final respondedDisplay = user.displayName?.trim().isNotEmpty == true ? user.displayName! : user.email!;
      await NotificationHelper().notifyInvitationResponded(
        inviterUserId: inviterUserId,
        planId: planId,
        respondedUserDisplay: respondedDisplay,
        accepted: false,
      );
      await _cleanupInviteeInvitationNotifications(userId, planId);
      return const InvitationRespondResult(
        success: true,
        message: 'Has rechazado la invitación',
      );
    } catch (e) {
      LoggerService.error(
        'Error rejecting invitation by planId: $planId, userId: $userId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return const InvitationRespondResult(
        success: false,
        message: 'Error al rechazar la invitación',
      );
    }
  }

  /// Cancelar invitación (owner/admin).
  /// También limpia participación `pending` del invitado (si ya tiene cuenta) y sus avisos in-app.
  Future<bool> cancelInvitation(String invitationId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(invitationId).get();
      if (!doc.exists) {
        LoggerService.warning('Invitation not found to cancel: $invitationId');
        return false;
      }
      final invitation = PlanInvitation.fromFirestore(doc);
      if (invitation.status != 'pending') {
        LoggerService.warning(
          'Invitation $invitationId is not pending (status: ${invitation.status})',
        );
        return false;
      }

      await doc.reference.update({
        'status': 'cancelled',
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      });
      LoggerService.database('Invitation cancelled: $invitationId', operation: 'UPDATE');

      final email = invitation.email.toLowerCase().trim();
      final invitee = await _userService.getUserByEmail(email);
      if (invitee != null) {
        final part = await _participationService.getParticipation(invitation.planId, invitee.id);
        if (part != null && part.isPending) {
          await _participationService.removeParticipation(invitation.planId, invitee.id);
        }
        await _cleanupInviteeInvitationNotifications(invitee.id, invitation.planId);
      }

      return true;
    } catch (e) {
      LoggerService.error('Error cancelling invitation: $invitationId', context: 'INVITATION_SERVICE', error: e);
      return false;
    }
  }

  /// Marca como cancelados los docs `plan_invitations` pending de un email/plan.
  /// No toca participaciones (p. ej. invitación directa con pending activo).
  Future<int> dismissPendingInvitationDocsForEmail({
    required String planId,
    required String email,
  }) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('email', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .get();

      if (querySnapshot.docs.isEmpty) return 0;

      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'status': 'cancelled',
          'respondedAt': now,
        });
      }
      await batch.commit();
      LoggerService.database(
        'Dismissed ${querySnapshot.docs.length} pending invitation doc(s) for $normalizedEmail plan $planId',
        operation: 'UPDATE',
      );
      return querySnapshot.docs.length;
    } catch (e) {
      LoggerService.error(
        'Error dismissing pending invitation docs: $email, plan: $planId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return 0;
    }
  }

  /// Cancela la invitación pendiente de un email en un plan (si existe) y limpia participación pending.
  Future<bool> cancelPendingInvitationForEmail({
    required String planId,
    required String email,
  }) async {
    final pending = await getPendingInvitationByEmail(planId, email);
    if (pending?.id != null) {
      return cancelInvitation(pending!.id!);
    }
    final invitee = await _userService.getUserByEmail(email.toLowerCase().trim());
    if (invitee != null) {
      final part = await _participationService.getParticipation(planId, invitee.id);
      if (part != null && part.isPending) {
        final ok = await _participationService.removeParticipation(planId, invitee.id);
        if (ok) {
          await _cleanupInviteeInvitationNotifications(invitee.id, planId);
        }
        return ok;
      }
    }
    return false;
  }

  /// Cancela invitación pendiente asociada a una participación pending (por userId).
  Future<bool> cancelPendingForParticipation({
    required String planId,
    required String userId,
  }) async {
    final user = await _userService.getUser(userId);
    final email = user?.email.toLowerCase().trim();
    if (email != null && email.isNotEmpty) {
      final pending = await getPendingInvitationByEmail(planId, email);
      if (pending?.id != null) {
        return cancelInvitation(pending!.id!);
      }
    }
    final part = await _participationService.getParticipation(planId, userId);
    if (part != null && part.isPending) {
      final ok = await _participationService.removeParticipation(planId, userId);
      if (ok) {
        await _cleanupInviteeInvitationNotifications(userId, planId);
      }
      return ok;
    }
    return false;
  }

  /// Genera el link de invitación
  /// 
  /// En desarrollo web, usa localhost. En producción, usa la URL de producción.
  /// La URL base se puede configurar desde Firebase Functions config (app.base_url).
  String generateInvitationLink(String token) {
    // Web en debug: origen actual (localhost:puerto). Producción / móvil: app.planoon.com.
    // Los emails de la CF usan APP_BASE_URL (https://app.planoon.com).
    final String baseUrl;
    if (kIsWeb && kDebugMode) {
      baseUrl = Uri.base.origin;
    } else if (kDebugMode) {
      baseUrl = 'http://localhost:8080';
    } else {
      baseUrl = 'https://app.planoon.com';
    }
    return '$baseUrl/invitation/$token';
  }

  /// Obtener todas las invitaciones pendientes de un plan
  Future<List<PlanInvitation>> getPendingInvitations(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('status', isEqualTo: 'pending')
          .get();

      final list = querySnapshot.docs
          .map((doc) => PlanInvitation.fromFirestore(doc))
          .toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return list;
    } catch (e) {
      LoggerService.error(
        'Error getting pending invitations: $planId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return [];
    }
  }

  /// Obtener todas las invitaciones de un plan (cualquier estado: pending, accepted, rejected, cancelled, expired)
  Future<List<PlanInvitation>> getInvitationsForPlan(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .get();

      final list = querySnapshot.docs
          .map((doc) => PlanInvitation.fromFirestore(doc))
          .toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return list;
    } catch (e) {
      LoggerService.error(
        'Error getting invitations for plan: $planId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return [];
    }
  }

  /// Limpiar invitaciones expiradas (llamar periódicamente)
  Future<int> cleanExpiredInvitations() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .get();

      final batch = _firestore.batch();
      int cleaned = 0;

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'status': 'expired'});
        cleaned++;
      }

      if (cleaned > 0) {
        await batch.commit();
        LoggerService.database(
          'Cleaned $cleaned expired invitations',
          operation: 'UPDATE',
        );
      }

      return cleaned;
    } catch (e) {
      LoggerService.error(
        'Error cleaning expired invitations',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return 0;
    }
  }

  /// Eliminar todas las invitaciones (cualquier estado) de un plan
  Future<int> deleteInvitationsByPlanId(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .get();

      if (querySnapshot.docs.isEmpty) return 0;

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      LoggerService.database(
        'Deleted ${querySnapshot.docs.length} invitations for plan $planId',
        operation: 'DELETE',
      );
      return querySnapshot.docs.length;
    } catch (e) {
      LoggerService.error(
        'Error deleting invitations by planId: $planId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return 0;
    }
  }

  /// Eliminar todas las invitaciones dirigidas a un email (cualquier estado)
  Future<int> deleteInvitationsByEmail(String email) async {
    try {
      final normalized = email.toLowerCase().trim();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: normalized)
          .get();
      if (querySnapshot.docs.isEmpty) return 0;
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      LoggerService.database(
        'Deleted ${querySnapshot.docs.length} invitations for email $normalized',
        operation: 'DELETE',
      );
      return querySnapshot.docs.length;
    } catch (e) {
      LoggerService.error(
        'Error deleting invitations by email: $email',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return 0;
    }
  }

  /// Eliminar todas las invitaciones creadas por un usuario (invitedBy)
  Future<int> deleteInvitationsByInviter(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('invitedBy', isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isEmpty) return 0;
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      LoggerService.database(
        'Deleted ${querySnapshot.docs.length} invitations created by $userId',
        operation: 'DELETE',
      );
      return querySnapshot.docs.length;
    } catch (e) {
      LoggerService.error(
        'Error deleting invitations by inviter: $userId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return 0;
    }
  }
}

