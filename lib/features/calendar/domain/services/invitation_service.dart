import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  static const String _collectionName = 'planInvitations';
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
  /// Si el usuario ya existe (por email), busca su ID y crea participación directamente.
  /// Si no existe, crea una invitación con token.
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

      // Primero, intentar buscar si el usuario ya existe por email
      final existingUser = await _userService.getUserByEmail(normalizedEmail);
      
      if (existingUser != null) {
        // Usuario existe: crear participación directamente
        LoggerService.database(
          'User found by email: $normalizedEmail, creating participation directly',
          operation: 'CREATE',
        );
        
        final participationId = await _participationService.createParticipation(
          planId: planId,
          userId: existingUser.id,
          role: role,
          invitedBy: invitedBy,
          autoAccept: false, // Invitación pendiente
        );
        
        if (participationId != null) {
          // TODO: Enviar notificación push si está disponible
          LoggerService.database(
            'Participation created directly for user: ${existingUser.id}',
            operation: 'CREATE',
          );
          return participationId; // Retornar el ID de participación en lugar de invitación
        }
        return null;
      }

      // Usuario no existe: crear invitación con token
      final token = _generateToken();
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 7)); // Expira en 7 días

      // Verificar si ya existe una invitación pendiente para este email y plan
      final existingInvitation = await _getPendingInvitationByEmail(planId, normalizedEmail);
      if (existingInvitation != null) {
        LoggerService.warning(
          'Pending invitation already exists for email: $normalizedEmail, plan: $planId',
        );
        return existingInvitation.id;
      }

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
        'Invitation created: ${docRef.id} for email: $normalizedEmail',
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

  /// Obtener invitación pendiente por email y plan
  Future<PlanInvitation?> _getPendingInvitationByEmail(String planId, String email) async {
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

  /// Genera el link de invitación
  String generateInvitationLink(String token) {
    // TODO: Configurar URL base desde configuración
    const baseUrl = 'https://planazoo.app'; // O desde configuración
    return '$baseUrl/invitation/$token';
  }

  /// Obtener todas las invitaciones pendientes de un plan
  Future<List<PlanInvitation>> getPendingInvitations(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PlanInvitation.fromFirestore(doc))
          .toList();
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
}

