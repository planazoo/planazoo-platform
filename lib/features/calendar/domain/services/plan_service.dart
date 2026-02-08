import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../../../../shared/services/permission_service.dart';
import '../../../../features/security/services/rate_limiter_service.dart';
import '../models/plan.dart';
import '../models/plan_participation.dart';
import 'plan_participation_service.dart';
import 'invitation_service.dart';
import 'event_participant_service.dart';

class PlanService {
  PlanService({InvitationService? invitationService})
      : _invitationService = invitationService ?? InvitationService();

  static const String _collectionName = 'plans';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlanParticipationService _participationService = PlanParticipationService();
  final InvitationService _invitationService;
  final EventParticipantService _eventParticipantService = EventParticipantService();
  final PermissionService _permissionService = PermissionService();

  /// Obtener todos los planes (sin filtrar por usuario)
  /// 
  /// ⚠️ DEPRECATED: Usar `getPlansForUser(userId)` en su lugar para obtener
  /// solo los planes visibles para un usuario específico.
  /// 
  /// Este método se mantiene para:
  /// - Generadores de datos de prueba
  /// - Pantallas de administración
  /// - Providers que necesitan todos los planes
  /// 
  /// TODO: Migrar todos los consumidores a `getPlansForUser` cuando sea posible.
  @Deprecated('Usar getPlansForUser(userId) en su lugar. Este método retorna todos los planes sin filtrar.')
  Stream<List<Plan>> getPlans() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Plan.fromFirestore(doc)).toList());
  }

  // Obtener todos los planes visibles para un usuario (creados y donde participa)
  Stream<List<Plan>> getPlansForUser(String userId) {
    final controller = StreamController<List<Plan>>();
    List<Plan> ownedPlans = const <Plan>[];
    List<Plan> participantPlans = const <Plan>[];

    void emitCombined() {
      final Map<String, Plan> planMap = {};
      for (final plan in ownedPlans) {
        if (plan.id != null) {
          planMap[plan.id!] = plan;
        }
      }
      for (final plan in participantPlans) {
        if (plan.id != null) {
          planMap[plan.id!] = plan;
        }
      }

      final combined = planMap.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(combined);
    }

    final ownedSubscription = _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      ownedPlans = snapshot.docs.map((doc) => Plan.fromFirestore(doc)).toList();
      emitCombined();
    }, onError: controller.addError);

    final participationSubscription = getPlansWhereUserParticipates(userId).listen(
      (plans) {
        participantPlans = plans.where((plan) => plan.userId != userId).toList();
        emitCombined();
      },
      onError: controller.addError,
    );

    controller.onCancel = () async {
      await ownedSubscription.cancel();
      await participationSubscription.cancel();
    };

    return controller.stream;
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

  /// T107: Expandir un plan para incluir nuevas fechas
  /// Actualiza baseDate, startDate, endDate y columnCount del plan
  Future<bool> expandPlan(Plan plan, {
    required DateTime newStartDate,
    required DateTime newEndDate,
    required int newColumnCount,
  }) async {
    if (plan.id == null) return false;
    
    try {
      // Calcular nuevo baseDate (siempre será el startDate)
      final newBaseDate = DateTime(
        newStartDate.year,
        newStartDate.month,
        newStartDate.day,
      );
      
      final newStart = DateTime(
        newStartDate.year,
        newStartDate.month,
        newStartDate.day,
      );
      
      final newEnd = DateTime(
        newEndDate.year,
        newEndDate.month,
        newEndDate.day,
      );

      final expandedPlan = plan.copyWith(
        baseDate: newBaseDate,
        startDate: newStart,
        endDate: newEnd,
        columnCount: newColumnCount,
        updatedAt: DateTime.now(),
      );

      final success = await updatePlan(expandedPlan);
      
      if (success) {
        LoggerService.database(
          'Plan expanded: ${plan.id} to ${newColumnCount} days',
          operation: 'UPDATE',
        );
      }
      
      return success;
    } catch (e) {
      LoggerService.error('Error expanding plan: ${plan.id}', context: 'PLAN_SERVICE', error: e);
      return false;
    }
  }

  // Eliminar un plan
  /// 
  /// Elimina un plan y todos sus datos relacionados en el siguiente orden:
  /// 1. event_participants (participantes de eventos del plan)
  /// 2. plan_invitations (todas las invitaciones del plan)
  /// 3. events (eventos del plan - se eliminan desde event_service)
  /// 4. plan_permissions (permisos del plan)
  /// 5. plan_participations (participaciones - eliminación física)
  /// 6. plan (el plan mismo)
  /// 
  /// NOTA: La eliminación de eventos e imagen del plan se hace desde wd_plan_data_screen.dart
  /// antes de llamar a este método.
  Future<bool> deletePlan(String id) async {
    try {
      // 1. Eliminar todos los event_participants del plan
      await _eventParticipantService.deleteAllEventParticipantsByPlanId(id);
      
      // 2. Eliminar todas las invitaciones del plan
      await _invitationService.deleteInvitationsByPlanId(id);
      
      // 3. Eliminar todos los permisos del plan
      await _permissionService.deleteAllPlanPermissions(id);
      
      // 4. Eliminar físicamente todas las participaciones del plan
      await _participationService.deleteAllPlanParticipations(id);
      
      // 5. Eliminar el plan
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
  /// Invitar usuario a un plan
  /// 
  /// Si `userIdOrEmail` parece un email (contiene '@'), usa InvitationService.
  /// Si no, usa el ID directamente para crear participación.
  Future<bool> inviteUserToPlan(String planId, String userIdOrEmail, {String? invitedBy, String role = 'participant', String? customMessage}) async {
    try {
      // Detectar si es un email o un ID de usuario
      final isEmail = userIdOrEmail.contains('@');
      
      if (isEmail) {
        // Es un email: usar InvitationService (T104)
        final invitationId = await _invitationService.createInvitation(
          planId: planId,
          email: userIdOrEmail,
          invitedBy: invitedBy,
          role: role,
          customMessage: customMessage,
        );
        
        if (invitationId != null) {
          LoggerService.database('Invitation created for email $userIdOrEmail to plan $planId', operation: 'CREATE');
          // TODO: Enviar email con link (T104)
          return true;
        }
        return false;
      } else {
        // Es un ID de usuario: crear participación directamente
        final participationId = await _participationService.createParticipation(
          planId: planId,
          userId: userIdOrEmail,
          role: role,
          invitedBy: invitedBy,
        );
        
        if (participationId != null) {
          LoggerService.database('User $userIdOrEmail invited to plan $planId', operation: 'CREATE');
          return true;
        }
        return false;
      }
    } catch (e) {
      LoggerService.error('Error inviting user to plan: $planId, $userIdOrEmail', 
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