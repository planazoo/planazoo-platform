import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../../../../features/security/services/rate_limiter_service.dart';
import '../models/plan.dart';
import '../models/plan_participation.dart';
import 'plan_participation_service.dart';

class PlanService {
  static const String _collectionName = 'plans';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlanParticipationService _participationService = PlanParticipationService();

  // Obtener todos los planes
  Stream<List<Plan>> getPlans() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Plan.fromFirestore(doc)).toList();
    });
  }

  // Obtener planes por userId (solo planes creados por el usuario)
  Stream<List<Plan>> getPlansByUserId(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Plan.fromFirestore(doc)).toList();
    });
  }

  // Obtener planes donde participa un usuario (incluyendo invitaciones)
  Stream<List<Plan>> getPlansWhereUserParticipates(String userId) {
    return _participationService.getUserPlanIds(userId).asyncMap((planIds) async {
      if (planIds.isEmpty) return <Plan>[];
      
      final plans = <Plan>[];
      for (final planId in planIds) {
        final plan = await getPlanById(planId);
        if (plan != null) plans.add(plan);
      }
      return plans..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // Obtener un plan por ID
  Future<Plan?> getPlanById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return Plan.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting plan by ID: $id', context: 'PLAN_SERVICE', error: e);
      return null;
    }
  }

  // Obtener un plan por unp_ID
  Future<Plan?> getPlanByUnpId(String unpId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('unpId', isEqualTo: unpId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return Plan.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting plan by unpId: $unpId', context: 'PLAN_SERVICE', error: e);
      return null;
    }
  }

  /// Generar un UNP ID único automáticamente
  /// Formato: {username}-{contador} (ej: juancarlos-1, juancarlos-2)
  /// Si no tiene username, usa: user-{userId_short}-{contador}
  Future<String> generateUniqueUnpId(String userId, {String? username}) async {
    try {
      // Construir el prefijo base
      String basePrefix;
      if (username != null && username.isNotEmpty) {
        // Usar username si está disponible
        basePrefix = username.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      } else {
        // Usar ID de usuario acortado si no hay username
        basePrefix = 'user-${userId.substring(0, 8)}';
      }
      
      // Buscar todos los planes del usuario para determinar el siguiente número
      final userPlans = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();
      
      // Encontrar el siguiente número disponible
      int nextNumber = 1;
      final existingUnpIds = userPlans.docs
          .map((doc) => doc.data()['unpId'] as String? ?? '')
          .where((id) => id.startsWith('$basePrefix-'))
          .map((id) {
            try {
              final parts = id.split('-');
              return int.tryParse(parts.last) ?? 0;
            } catch (e) {
              return 0;
            }
          })
          .toList();
      
      if (existingUnpIds.isNotEmpty) {
        nextNumber = existingUnpIds.reduce((a, b) => a > b ? a : b) + 1;
      }
      
      final generatedId = '$basePrefix-$nextNumber';
      LoggerService.debug('Generated unique UNP ID: $generatedId', context: 'PLAN_SERVICE');
      return generatedId;
    } catch (e) {
      LoggerService.error('Error generating unique UNP ID', context: 'PLAN_SERVICE', error: e);
      // Fallback a timestamp si falla
      return 'plan-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Crear un nuevo plan
  Future<String?> createPlan(Plan plan) async {
    try {
      // Verificar rate limiting para creación de planes
      final rateLimiter = RateLimiterService();
      final planLimitCheck = await rateLimiter.checkPlanCreation(plan.userId);
      
      if (!planLimitCheck.allowed) {
        throw Exception(planLimitCheck.getErrorMessage());
      }
      
      final docRef = await _firestore.collection(_collectionName).add(plan.toFirestore());
      final planId = docRef.id;
      
      // Crear participación del creador como organizador (autoAccept: true porque es el creador)
      await _participationService.createParticipation(
        planId: planId,
        userId: plan.userId,
        role: 'organizer',
        autoAccept: true,
      );
      
      // Registrar creación exitosa de plan
      await rateLimiter.recordPlanCreation(plan.userId);
      
      LoggerService.database('Plan created successfully with ID: $planId', operation: 'CREATE');
      return planId;
    } catch (e) {
      LoggerService.error('Error creating plan: ${plan.name}', context: 'PLAN_SERVICE', error: e);
      return null;
    }
  }

  // Actualizar un plan existente
  Future<bool> updatePlan(Plan plan) async {
    if (plan.id == null) return false;
    
    try {
      final updatedPlan = plan.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collectionName)
          .doc(plan.id)
          .update(updatedPlan.toFirestore());
      LoggerService.database('Plan updated successfully: ${plan.id}', operation: 'UPDATE');
      return true;
    } catch (e) {
      LoggerService.error('Error updating plan: ${plan.id}', context: 'PLAN_SERVICE', error: e);
      return false;
    }
  }

  // Eliminar un plan
  Future<bool> deletePlan(String id) async {
    try {
      // Eliminar todas las participaciones del plan
      await _participationService.removeAllPlanParticipations(id);
      
      // Eliminar el plan
      await _firestore.collection(_collectionName).doc(id).delete();
      LoggerService.database('Plan deleted successfully: $id', operation: 'DELETE');
      return true;
    } catch (e) {
      LoggerService.error('Error deleting plan: $id', context: 'PLAN_SERVICE', error: e);
      return false;
    }
  }

  // Guardar plan (crear o actualizar)
  Future<bool> savePlan(Plan plan) async {
    if (plan.id == null) {
      // Crear nuevo plan
      final now = DateTime.now();
      final newPlan = plan.copyWith(
        createdAt: now,
        updatedAt: now,
        savedAt: now,
      );
      final id = await createPlan(newPlan);
      return id != null;
    } else {
      // Actualizar plan existente
      final updatedPlan = plan.copyWith(
        updatedAt: DateTime.now(),
        savedAt: DateTime.now(),
      );
      return await updatePlan(updatedPlan);
    }
  }

  // Guardar plan por unp_ID (sobrescribir si existe)
  Future<bool> savePlanByUnpId(Plan plan) async {
    try {
      // Buscar si ya existe un plan con el mismo unp_ID
      final existingPlan = await getPlanByUnpId(plan.unpId);
      final now = DateTime.now();
      
      if (existingPlan != null) {
        // Sobrescribir el plan existente
        final updatedPlan = plan.copyWith(
          id: existingPlan.id,
          createdAt: existingPlan.createdAt, // Mantener la fecha de creación original
          updatedAt: now,
          savedAt: now,
        );
        return await updatePlan(updatedPlan);
      } else {
        // Crear nuevo plan
        final newPlan = plan.copyWith(
          createdAt: now,
          updatedAt: now,
          savedAt: now,
        );
        final id = await createPlan(newPlan);
        return id != null;
      }
    } catch (e) {
      // Error saving plan by unpId: $e
      return false;
    }
  }

  /// Obtener el alojamiento de un plan desde la colección de eventos
  Future<Map<String, dynamic>?> getAccommodation(String planId) async {
    try {
      // Buscar en la colección de eventos donde typeFamily = "alojamiento"
      final querySnapshot = await _firestore
          .collection('events')
          .where('planId', isEqualTo: planId)
          .where('typeFamily', isEqualTo: 'alojamiento')
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        LoggerService.database('Accommodation found for plan: $planId', operation: 'READ');
        return data;
      } else {
        // Debug: verificar si hay eventos en general para este plan
        try {
          final allEvents = await _firestore
              .collection('events')
              .where('planId', isEqualTo: planId)
              .get();
          
          if (allEvents.docs.isNotEmpty) {
            LoggerService.debug('Found ${allEvents.docs.length} events for plan $planId, but none of type "alojamiento"', context: 'ACCOMMODATION');
          } else {
            LoggerService.debug('No events found for plan $planId', context: 'ACCOMMODATION');
          }
        } catch (debugError) {
          LoggerService.error('Error in debug of getAccommodation for plan: $planId', context: 'ACCOMMODATION', error: debugError);
        }
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting accommodation for plan: $planId', context: 'PLAN_SERVICE', error: e);
      return null;
    }
  }

  // ===== MÉTODOS DE PARTICIPACIÓN =====

  // Invitar usuario a un plan
  Future<bool> inviteUserToPlan(String planId, String userId, {String? invitedBy}) async {
    try {
      final participationId = await _participationService.createParticipation(
        planId: planId,
        userId: userId,
        role: 'participant',
        invitedBy: invitedBy,
      );
      
      if (participationId != null) {
        LoggerService.database('User $userId invited to plan $planId', operation: 'CREATE');
        return true;
      }
      return false;
    } catch (e) {
      LoggerService.error('Error inviting user to plan: $planId, $userId', 
          context: 'PLAN_SERVICE', error: e);
      return false;
    }
  }

  // Remover usuario de un plan
  Future<bool> removeUserFromPlan(String planId, String userId) async {
    try {
      final success = await _participationService.removeParticipation(planId, userId);
      if (success) {
        LoggerService.database('User $userId removed from plan $planId', operation: 'UPDATE');
      }
      return success;
    } catch (e) {
      LoggerService.error('Error removing user from plan: $planId, $userId', 
          context: 'PLAN_SERVICE', error: e);
      return false;
    }
  }

  // Obtener participantes de un plan
  Stream<List<PlanParticipation>> getPlanParticipants(String planId) {
    return _participationService.getPlanParticipations(planId);
  }

  // Verificar si usuario participa en un plan
  Future<bool> isUserParticipant(String planId, String userId) async {
    return await _participationService.isUserParticipant(planId, userId);
  }

  // Obtener participación específica
  Future<PlanParticipation?> getParticipation(String planId, String userId) async {
    return await _participationService.getParticipation(planId, userId);
  }

  // Cambiar rol de participante
  Future<bool> changeParticipantRole(String planId, String userId, String newRole) async {
    try {
      final success = await _participationService.changeRole(planId, userId, newRole);
      if (success) {
        LoggerService.database('Role changed for user $userId in plan $planId to $newRole', operation: 'UPDATE');
      }
      return success;
    } catch (e) {
      LoggerService.error('Error changing participant role: $planId, $userId', 
          context: 'PLAN_SERVICE', error: e);
      return false;
    }
  }

  // Actualizar última actividad del usuario en el plan
  Future<bool> updateUserLastActive(String planId, String userId) async {
    return await _participationService.updateLastActive(planId, userId);
  }
} 