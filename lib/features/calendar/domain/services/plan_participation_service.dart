import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/plan_participation.dart';

class PlanParticipationService {
  static const String _collectionName = 'plan_participations';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todas las participaciones de un plan
  Stream<List<PlanParticipation>> getPlanParticipations(String planId) {
    return _firestore
        .collection(_collectionName)
        .where('planId', isEqualTo: planId)
        .where('isActive', isEqualTo: true)
        .orderBy('joinedAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PlanParticipation.fromFirestore(doc)).toList();
    });
  }

  // Obtener participaciones de un usuario
  Stream<List<PlanParticipation>> getUserParticipations(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PlanParticipation.fromFirestore(doc)).toList();
    });
  }

  // Obtener planes donde participa un usuario
  Stream<List<String>> getUserPlanIds(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()['planId'] as String).toList();
    });
  }

  // Verificar si un usuario participa en un plan
  Future<bool> isUserParticipant(String planId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      LoggerService.error('Error checking user participation: $planId, $userId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return false;
    }
  }

  // Obtener participación específica
  Future<PlanParticipation?> getParticipation(String planId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return PlanParticipation.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting participation: $planId, $userId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return null;
    }
  }

  // Crear participación (usuario se une al plan)
  Future<String?> createParticipation({
    required String planId,
    required String userId,
    required String role,
    String? invitedBy,
  }) async {
    try {
      // Verificar si ya existe una participación activa
      final existingParticipation = await getParticipation(planId, userId);
      if (existingParticipation != null) {
        LoggerService.warning('User $userId already participates in plan $planId');
        return existingParticipation.id;
      }

      final participation = PlanParticipation(
        planId: planId,
        userId: userId,
        role: role,
        joinedAt: DateTime.now(),
        isActive: true,
        invitedBy: invitedBy,
        lastActiveAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_collectionName)
          .add(participation.toFirestore());
      
      LoggerService.database('Participation created: ${docRef.id}', operation: 'CREATE');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error creating participation: $planId, $userId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return null;
    }
  }

  // Actualizar participación
  Future<bool> updateParticipation(PlanParticipation participation) async {
    if (participation.id == null) return false;
    
    try {
      await _firestore
          .collection(_collectionName)
          .doc(participation.id!)
          .update(participation.toFirestore());
      
      LoggerService.database('Participation updated: ${participation.id}', operation: 'UPDATE');
      return true;
    } catch (e) {
      LoggerService.error('Error updating participation: ${participation.id}', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return false;
    }
  }

  // Eliminar participación (desactivar)
  Future<bool> removeParticipation(String planId, String userId) async {
    try {
      final participation = await getParticipation(planId, userId);
      if (participation == null || participation.id == null) {
        LoggerService.warning('Participation not found: $planId, $userId');
        return false;
      }

      final updatedParticipation = participation.copyWith(
        isActive: false,
        lastActiveAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .doc(participation.id!)
          .update(updatedParticipation.toFirestore());
      
      LoggerService.database('Participation removed: ${participation.id}', operation: 'UPDATE');
      return true;
    } catch (e) {
      LoggerService.error('Error removing participation: $planId, $userId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return false;
    }
  }

  // Actualizar última actividad
  Future<bool> updateLastActive(String planId, String userId) async {
    try {
      final participation = await getParticipation(planId, userId);
      if (participation == null || participation.id == null) return false;

      final updatedParticipation = participation.copyWith(
        lastActiveAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .doc(participation.id!)
          .update(updatedParticipation.toFirestore());
      
      return true;
    } catch (e) {
      LoggerService.error('Error updating last active: $planId, $userId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return false;
    }
  }

  // Cambiar rol de participante
  Future<bool> changeRole(String planId, String userId, String newRole) async {
    try {
      final participation = await getParticipation(planId, userId);
      if (participation == null || participation.id == null) return false;

      final updatedParticipation = participation.copyWith(
        role: newRole,
        lastActiveAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .doc(participation.id!)
          .update(updatedParticipation.toFirestore());
      
      LoggerService.database('Role changed: $planId, $userId -> $newRole', operation: 'UPDATE');
      return true;
    } catch (e) {
      LoggerService.error('Error changing role: $planId, $userId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return false;
    }
  }

  // Obtener organizadores de un plan
  Future<List<PlanParticipation>> getPlanOrganizers(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('role', isEqualTo: 'organizer')
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => PlanParticipation.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting plan organizers: $planId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return [];
    }
  }

  // Obtener participantes de un plan (excluyendo organizadores)
  Future<List<PlanParticipation>> getPlanParticipants(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('role', isEqualTo: 'participant')
          .where('isActive', isEqualTo: true)
          .orderBy('joinedAt', descending: false)
          .get();
      
      return querySnapshot.docs
          .map((doc) => PlanParticipation.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting plan participants: $planId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return [];
    }
  }

  // Eliminar todas las participaciones de un plan (cuando se elimina el plan)
  Future<bool> removeAllPlanParticipations(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('isActive', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        final participation = PlanParticipation.fromFirestore(doc);
        final updatedParticipation = participation.copyWith(
          isActive: false,
          lastActiveAt: DateTime.now(),
        );
        batch.update(doc.reference, updatedParticipation.toFirestore());
      }

      await batch.commit();
      LoggerService.database('All participations removed for plan: $planId', operation: 'UPDATE');
      return true;
    } catch (e) {
      LoggerService.error('Error removing all plan participations: $planId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return false;
    }
  }

  // Añadir usuario a todos los planes existentes
  Future<Map<String, dynamic>> addUserToAllPlans(String userId) async {
    try {
      // Obtener todos los planes de la base de datos
      final plansSnapshot = await _firestore
          .collection('plans')
          .get();

      if (plansSnapshot.docs.isEmpty) {
        return {
          'success': true,
          'message': 'No hay planes en la base de datos',
          'plansProcessed': 0,
          'participationsCreated': 0,
        };
      }

      int plansProcessed = 0;
      int participationsCreated = 0;
      final errors = <String>[];

      // Procesar cada plan
      for (final planDoc in plansSnapshot.docs) {
        final planId = planDoc.id;
        plansProcessed++;

        try {
          // Verificar si el usuario ya participa en este plan
          final existingParticipation = await getParticipation(planId, userId);
          
          if (existingParticipation == null) {
            // Crear participación (como organizador si es el creador del plan, sino como participante)
            final planData = planDoc.data();
            final planCreatorId = planData['userId'] ?? '';
            final role = (planCreatorId == userId) ? 'organizer' : 'participant';
            
            final participationId = await createParticipation(
              planId: planId,
              userId: userId,
              role: role,
            );
            
            if (participationId != null) {
              participationsCreated++;
            }
          }
        } catch (e) {
          errors.add('Plan $planId: $e');
        }
      }

      LoggerService.database(
        'User $userId added to $participationsCreated out of $plansProcessed plans',
        operation: 'CREATE'
      );

      return {
        'success': errors.isEmpty,
        'message': errors.isEmpty 
            ? 'Usuario añadido a $participationsCreated planes exitosamente'
            : 'Usuario añadido a $participationsCreated de $plansProcessed planes. Errores: ${errors.length}',
        'plansProcessed': plansProcessed,
        'participationsCreated': participationsCreated,
        'errors': errors,
      };
    } catch (e) {
      LoggerService.error('Error adding user to all plans: $userId', 
          context: 'PLAN_PARTICIPATION_SERVICE', error: e);
      return {
        'success': false,
        'message': 'Error al procesar planes: $e',
        'plansProcessed': 0,
        'participationsCreated': 0,
        'errors': [e.toString()],
      };
    }
  }
}
