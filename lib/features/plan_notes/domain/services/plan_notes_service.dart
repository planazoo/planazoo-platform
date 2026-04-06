import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unp_calendario/features/plan_notes/domain/models/plan_preparation_item.dart';
import 'package:unp_calendario/features/plan_notes/domain/models/plan_workspace_data.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';

/// T262: Notas del plan (común/personal) y listas de preparación en subcolecciones.
class PlanNotesService {
  PlanNotesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String workspaceCollection = 'plan_workspace';
  static const String workspaceDocId = 'default';
  static const String personalCollection = 'personal_plan_notes';

  DocumentReference<Map<String, dynamic>> _workspaceRef(String planId) =>
      _firestore.collection('plans').doc(planId).collection(workspaceCollection).doc(workspaceDocId);

  DocumentReference<Map<String, dynamic>> _personalRef(String planId, String userId) =>
      _firestore.collection('plans').doc(planId).collection(personalCollection).doc(userId);

  Stream<PlanWorkspaceData?> watchWorkspace(String planId) {
    return _workspaceRef(planId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return PlanWorkspaceData.fromFirestore(snap);
    });
  }

  Stream<PersonalPlanNotesData?> watchPersonal(String planId, String userId) {
    return _personalRef(planId, userId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return PersonalPlanNotesData.fromFirestore(snap);
    });
  }

  /// Crea el documento workspace si no existe (solo debe llamar el organizador).
  Future<void> ensureWorkspaceDocument({
    required String planId,
    required String organizerUserId,
  }) async {
    final ref = _workspaceRef(planId);
    try {
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (snap.exists) return;
        tx.set(ref, {
          'commonNoteText': '',
          'preparationItems': <Map<String, dynamic>>[],
          'preparationCommonEditPolicy': PreparationCommonEditPolicy.organizerOnly.firestoreValue,
          'preparationCommonEditorUserIds': <String>[],
          'planParticipantUserIds': <String>[organizerUserId],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e, st) {
      LoggerService.error(
        'ensureWorkspaceDocument failed: $planId',
        context: 'PLAN_NOTES',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Mapa inicial al crear un plan nuevo (llamado desde PlanService.createPlan).
  static Map<String, dynamic> initialWorkspacePayload(String organizerUserId) {
    return {
      'commonNoteText': '',
      'preparationItems': <Map<String, dynamic>>[],
      'preparationCommonEditPolicy': PreparationCommonEditPolicy.organizerOnly.firestoreValue,
      'preparationCommonEditorUserIds': <String>[],
      'planParticipantUserIds': <String>[organizerUserId],
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<bool> saveWorkspaceFull({
    required String planId,
    required PlanWorkspaceData data,
  }) async {
    try {
      await _workspaceRef(planId).set(data.toFirestoreMap(), SetOptions(merge: true));
      return true;
    } catch (e, st) {
      LoggerService.error('saveWorkspaceFull: $planId', context: 'PLAN_NOTES', error: e, stackTrace: st);
      if (e is FirebaseException && e.code == 'permission-denied') {
        debugPrint(
          '[PLAN_NOTES] permission-denied en plan_workspace: ¿reglas desplegadas? '
          '(firebase deploy --only firestore:rules). Solo el userId del plan (organizador) puede crear/actualizar workspace.',
        );
      }
      return false;
    }
  }

  /// Participantes autorizados: solo texto común + ítems (reglas Firestore validan).
  Future<bool> saveWorkspaceParticipantContent({
    required String planId,
    required String commonNoteText,
    required List<PlanPreparationItem> preparationItems,
  }) async {
    try {
      await _workspaceRef(planId).update({
        'commonNoteText': commonNoteText,
        'preparationItems': preparationItems.map((e) => e.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      LoggerService.error(
        'saveWorkspaceParticipantContent: $planId',
        context: 'PLAN_NOTES',
        error: e,
      );
      return false;
    }
  }

  Future<bool> savePersonal({
    required String planId,
    required String userId,
    required PersonalPlanNotesData data,
  }) async {
    try {
      await _personalRef(planId, userId).set(data.toFirestoreMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      LoggerService.error('savePersonal: $planId', context: 'PLAN_NOTES', error: e);
      return false;
    }
  }

  Future<void> deleteWorkspaceForPlan(String planId) async {
    try {
      await _workspaceRef(planId).delete();
    } catch (e) {
      LoggerService.error('deleteWorkspaceForPlan: $planId', context: 'PLAN_NOTES', error: e);
    }
  }

  /// Borra todos los documentos de notas personales del plan (best effort).
  Future<void> deleteAllPersonalNotesForPlan(String planId) async {
    try {
      final qs = await _firestore.collection('plans').doc(planId).collection(personalCollection).get();
      final batch = _firestore.batch();
      for (final d in qs.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    } catch (e) {
      LoggerService.error(
        'deleteAllPersonalNotesForPlan: $planId',
        context: 'PLAN_NOTES',
        error: e,
      );
    }
  }
}
