import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/plan.dart';

class PlanService {
  static const String _collectionName = 'plans';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Crear un nuevo plan
  Future<String?> createPlan(Plan plan) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(plan.toFirestore());
      LoggerService.database('Plan created successfully with ID: ${docRef.id}', operation: 'CREATE');
      return docRef.id;
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
} 