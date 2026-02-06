import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/plan_invitation.dart';
import 'plan_participation_service.dart';
import '../../../auth/domain/services/user_service.dart';

/// Servicio para gestionar invitaciones a planes por email (T104)
/// 
/// Permite invitar usuarios por email aunque no conozcamos su ID.
/// Genera links únicos con token que expiran en 7 días.
class InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'plan_invitations';
  final PlanParticipationService _participationService = PlanParticipationService();
  final UserService _userService = UserService();

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

      // Verificar si el usuario ya es participante activo del plan
      final existingUser = await _userService.getUserByEmail(normalizedEmail);
      if (existingUser != null) {
        final isAlreadyParticipant = await _participationService.isUserParticipant(planId, existingUser.id);
        
        if (isAlreadyParticipant) {
          LoggerService.warning(
            'User $normalizedEmail already participates in plan $planId',
          );
          // Retornar null para indicar que no se puede crear la invitación
          // El código que llama debe manejar este caso y mostrar un error al usuario
          return null;
        }
      }

      // Verificar si ya existe una invitación pendiente para este email y plan
      final existingInvitation = await getPendingInvitationByEmail(planId, normalizedEmail);
      if (existingInvitation != null) {
        LoggerService.warning(
          'Pending invitation already exists for email: $normalizedEmail, plan: $planId',
        );
        // Retornar null para indicar que ya existe una invitación pendiente
        // El código que llama debe manejar este caso y mostrar un error al usuario
        return null;
      }

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

      final docRef = await _firestore
          .collection(_collectionName)
          .add(invitation.toFirestore());

      LoggerService.database(
        'Invitation created: ${docRef.id} for email: $normalizedEmail (requires explicit acceptance)',
        operation: 'CREATE',
      );

      // El email se envía automáticamente mediante Cloud Function
      // que se activa cuando se crea el documento en Firestore (T104)
      // Ver: functions/index.js - sendInvitationEmail

      return docRef.id;
    } catch (e) {
      LoggerService.error(
        'Error creating invitation: $email, plan: $planId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return null;
    }
  }

  /// Obtener invitación por token
  Future<PlanInvitation?> getInvitationByToken(String token) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('token', isEqualTo: token)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final invitation = PlanInvitation.fromFirestore(querySnapshot.docs.first);
      
      // Verificar si expiró
      if (invitation.isExpired) {
        // Marcar como expirada
        await _firestore
            .collection(_collectionName)
            .doc(invitation.id!)
            .update({'status': 'expired'});
        return invitation.copyWith(status: 'expired');
      }

      return invitation;
    } catch (e) {
      LoggerService.error(
        'Error getting invitation by token: $token',
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
  Future<List<PlanInvitation>> getPendingInvitationsByEmail(String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .get();
      final list = querySnapshot.docs.map((d) => PlanInvitation.fromFirestore(d)).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
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
      // 1. PRIMERO: Verificar si hay participaciones pendientes (userId)
      // Si hay, significa que la invitación ya fue procesada y tenemos una participación pendiente
      // En este caso, NO necesitamos buscar invitaciones - el sistema de participaciones
      // ya maneja el estado pendiente
      final participations = await _participationService.getUserParticipations(userId).first;
      final pendingParticipations = participations.where((p) => p.status == 'pending').toList();
      
      if (pendingParticipations.isNotEmpty) {
        // Hay participaciones pendientes - esto significa que ya pasamos la fase de invitación
        // El sistema ahora funciona por userId a través de participaciones
        // No necesitamos buscar invitaciones, retornar lista vacía
        // (el sistema de participaciones ya maneja el estado pendiente)
        return [];
      }
      
      // 2. SEGUNDO: Si NO hay participaciones pendientes, buscar invitaciones por email (primera vez)
      // Esto solo ocurre cuando el usuario se acaba de registrar y aún no tiene participaciones
      // Después de aceptar la primera invitación, se creará una participación y este código
      // no se ejecutará más (se usará el sistema de participaciones)
      if (email != null) {
        return await getPendingInvitationsByEmail(email);
      }
      
      return [];
    } catch (e) {
      LoggerService.error(
        'Error getting pending invitations by userId: $userId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return [];
    }
  }

  /// Aceptar invitación directamente por planId y userId (sin token)
  /// 
  /// Útil cuando el usuario está autenticado y el email coincide con la invitación.
  /// Actualiza tanto la participación como el estado de la invitación.
  Future<bool> acceptInvitationByPlanId(String planId, String userId) async {
    try {
      // Obtener el email del usuario
      final user = await _userService.getUser(userId);
      if (user == null || user.email == null) {
        LoggerService.warning('User not found or has no email: $userId');
        return false;
      }

      // Buscar la invitación pendiente para este plan y email
      final normalizedEmail = user.email!.toLowerCase().trim();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('email', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        LoggerService.warning('No pending invitation found for plan: $planId, email: $normalizedEmail');
        return false;
      }

      final invitationDoc = querySnapshot.docs.first;
      final invitation = PlanInvitation.fromFirestore(invitationDoc);

      // Crear o actualizar la participación
      final participationId = await _participationService.createParticipation(
        planId: planId,
        userId: userId,
        role: invitation.role ?? 'participant',
        invitedBy: invitation.invitedBy,
        autoAccept: true, // Aceptar directamente
      );

      if (participationId == null) {
        LoggerService.warning('Failed to create participation for plan: $planId, userId: $userId');
        return false;
      }

      // Actualizar el estado de la invitación
      try {
        await invitationDoc.reference.update({
          'status': 'accepted',
          'respondedAt': Timestamp.fromDate(DateTime.now()),
        });

        LoggerService.database(
          'Invitation accepted by planId: ${invitation.id}, participation: $participationId',
          operation: 'UPDATE',
        );
      } catch (updateError) {
        // Si falla la actualización de la invitación, registrar pero continuar
        // La participación ya se creó, que es lo más importante
        LoggerService.error(
          'Error updating invitation status to accepted: ${invitation.id}. '
          'Participation was created successfully: $participationId',
          context: 'INVITATION_SERVICE',
          error: updateError,
        );
      }

      return true;
    } catch (e) {
      LoggerService.error(
        'Error accepting invitation by planId: $planId, userId: $userId',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Aceptar invitación por token
  /// 
  /// Crea la participación si el usuario existe, o marca la invitación como aceptada
  /// para que el usuario pueda crearse una cuenta después.
  Future<bool> acceptInvitationByToken(String token, String userId) async {
    try {
      final invitation = await getInvitationByToken(token);
      if (invitation == null || !invitation.isValid) {
        LoggerService.warning('Invalid or expired invitation token: $token');
        return false;
      }

      // Obtener el email del usuario desde Firestore para verificar que coincide con la invitación
      final user = await _userService.getUser(userId);
      if (user == null) {
        LoggerService.warning('User not found: $userId');
        return false;
      }

      // Verificar que el email del usuario coincide con el email de la invitación
      final userEmail = user.email.toLowerCase().trim();
      final invitationEmail = invitation.email?.toLowerCase().trim() ?? '';
      
      if (userEmail != invitationEmail) {
        LoggerService.warning(
          'User email ($userEmail) does not match invitation email ($invitationEmail). '
          'This may cause permission issues when updating invitation status.',
        );
        // Continuar de todas formas, la participación se puede crear
      }

      // Crear participación
      final participationId = await _participationService.createParticipation(
        planId: invitation.planId,
        userId: userId,
        role: invitation.role ?? 'participant',
        invitedBy: invitation.invitedBy,
        autoAccept: true, // Aceptar directamente
      );

      if (participationId != null) {
        // Marcar invitación como aceptada
        // Primero intentar como el usuario invitado, si falla, el owner del plan puede actualizarla
        bool updateSuccess = false;
        try {
          await _firestore
              .collection(_collectionName)
              .doc(invitation.id!)
              .update({
            'status': 'accepted',
            'respondedAt': Timestamp.fromDate(DateTime.now()),
          });

          LoggerService.database(
            'Invitation accepted: ${invitation.id}, participation created: $participationId',
            operation: 'UPDATE',
          );
          updateSuccess = true;
        } catch (updateError) {
          // Si falla, puede ser un problema de permisos (email del token no coincide)
          // En este caso, el owner del plan puede actualizar la invitación según las reglas
          // Pero no podemos hacerlo desde aquí porque no tenemos el contexto del owner
          // El error se registra para diagnóstico
          LoggerService.error(
            'Error updating invitation status to accepted: ${invitation.id}. '
            'Invitation email: ${invitation.email}, User email: $userEmail, Error: $updateError. '
            'The invitation status may need to be updated manually by the plan owner or via Cloud Function.',
            context: 'INVITATION_SERVICE',
            error: updateError,
          );
          // Continuar y retornar true porque la participación se creó correctamente
          // El estado de la invitación se puede actualizar manualmente si es necesario
          // O se puede actualizar desde una Cloud Function que tenga permisos de admin
        }
        
        // Si la actualización falló, intentar obtener el plan y verificar si el usuario actual es el owner
        // Si es el owner, intentar actualizar de nuevo (las reglas permiten que el owner actualice)
        if (!updateSuccess) {
          try {
            final planDoc = await _firestore.collection('plans').doc(invitation.planId).get();
            if (planDoc.exists) {
              final planData = planDoc.data();
              final planOwnerId = planData?['userId'] as String?;
              
              // Si el usuario actual es el owner del plan, intentar actualizar de nuevo
              // Nota: Esto solo funcionará si el usuario actual es el owner
              // En la mayoría de los casos, el usuario que acepta NO es el owner
              // Por lo tanto, esta actualización probablemente también fallará
              // Pero lo intentamos por si acaso
              if (planOwnerId == userId) {
                try {
                  await _firestore
                      .collection(_collectionName)
                      .doc(invitation.id!)
                      .update({
                    'status': 'accepted',
                    'respondedAt': Timestamp.fromDate(DateTime.now()),
                  });
                  LoggerService.database(
                    'Invitation accepted by plan owner: ${invitation.id}',
                    operation: 'UPDATE',
                  );
                  updateSuccess = true;
                } catch (ownerUpdateError) {
                  LoggerService.error(
                    'Error updating invitation status as plan owner: ${invitation.id}',
                    context: 'INVITATION_SERVICE',
                    error: ownerUpdateError,
                  );
                }
              }
            }
          } catch (planError) {
            LoggerService.error(
              'Error getting plan to check owner: ${invitation.planId}',
              context: 'INVITATION_SERVICE',
              error: planError,
            );
          }
        }
        
        return true;
      }

      return false;
    } catch (e) {
      LoggerService.error(
        'Error accepting invitation by token: $token',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Rechazar invitación por token
  Future<bool> rejectInvitationByToken(String token) async {
    try {
      final invitation = await getInvitationByToken(token);
      if (invitation == null || !invitation.isValid) {
        LoggerService.warning('Invalid or expired invitation token: $token');
        return false;
      }

      // Marcar invitación como rechazada
      await _firestore
          .collection(_collectionName)
          .doc(invitation.id!)
          .update({
        'status': 'rejected',
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      });

      LoggerService.database(
        'Invitation rejected: ${invitation.id}',
        operation: 'UPDATE',
      );
      return true;
    } catch (e) {
      LoggerService.error(
        'Error rejecting invitation by token: $token',
        context: 'INVITATION_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Cancelar invitación (owner/admin)
  Future<bool> cancelInvitation(String invitationId) async {
    try {
      await _firestore.collection(_collectionName).doc(invitationId).update({
        'status': 'cancelled',
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      });
      LoggerService.database('Invitation cancelled: $invitationId', operation: 'UPDATE');
      return true;
    } catch (e) {
      LoggerService.error('Error cancelling invitation: $invitationId', context: 'INVITATION_SERVICE', error: e);
      return false;
    }
  }

  /// Genera el link de invitación
  /// 
  /// En desarrollo web, usa localhost. En producción, usa la URL de producción.
  /// La URL base se puede configurar desde Firebase Functions config (app.base_url).
  String generateInvitationLink(String token) {
    // En desarrollo web, detectar localhost automáticamente
    // En producción, usar la URL configurada en Firebase Functions
    // Por ahora, usar localhost para desarrollo y planazoo.app para producción
    final baseUrl = kDebugMode
        ? 'http://localhost:8080'  // Desarrollo local
        : 'https://planazoo.app';   // Producción
    
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

