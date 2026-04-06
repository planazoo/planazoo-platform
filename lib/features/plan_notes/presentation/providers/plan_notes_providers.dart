import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/plan_notes/domain/models/plan_workspace_data.dart';
import 'package:unp_calendario/features/plan_notes/domain/services/plan_notes_service.dart';

final planNotesServiceProvider = Provider<PlanNotesService>((ref) {
  return PlanNotesService();
});

/// `null` = documento aún no existe (planes antiguos hasta que el organizador inicialice).
final planWorkspaceStreamProvider =
    StreamProvider.autoDispose.family<PlanWorkspaceData?, String>((ref, planId) {
  return ref.watch(planNotesServiceProvider).watchWorkspace(planId);
});

/// Clave estable para familia de notas personales.
class PersonalPlanNotesKey {
  final String planId;
  final String userId;

  const PersonalPlanNotesKey({required this.planId, required this.userId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalPlanNotesKey &&
          other.planId == planId &&
          other.userId == userId;

  @override
  int get hashCode => Object.hash(planId, userId);
}

final personalPlanNotesStreamProvider =
    StreamProvider.autoDispose.family<PersonalPlanNotesData?, PersonalPlanNotesKey>((ref, key) {
  return ref.watch(planNotesServiceProvider).watchPersonal(key.planId, key.userId);
});
