import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/plan_participation.dart';
import '../../domain/services/plan_participation_service.dart';
import '../../domain/services/plan_service.dart';

class PlanParticipationNotifier extends StateNotifier<AsyncValue<List<PlanParticipation>>> {
  final String _planId;
  final PlanParticipationService _participationService;
  final PlanService _planService;

  PlanParticipationNotifier({
    required String planId,
    required PlanParticipationService participationService,
    required PlanService planService,
  }) : _planId = planId,
       _participationService = participationService,
       _planService = planService,
       super(const AsyncValue.loading()) {
    _loadParticipations();
  }

  Future<void> _loadParticipations() async {
    state = const AsyncValue.loading();
    try {
      _participationService.getPlanParticipations(_planId).listen((participations) {
        state = AsyncValue.data(participations);
      }, onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Obtener participantes de un plan
  void loadPlanParticipants(String planId) {
    state = const AsyncValue.loading();
    _participationService.getPlanParticipations(planId).listen(
      (participations) {
        state = AsyncValue.data(participations);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  // Invitar usuario a un plan
  Future<bool> inviteUserToPlan(String planId, String userId, {String? invitedBy}) async {
    try {
      state = const AsyncValue.loading();
      
      final success = await _planService.inviteUserToPlan(
        planId, 
        userId, 
        invitedBy: invitedBy,
      );
      
      if (success) {
        // Recargar la lista de participantes
        loadPlanParticipants(planId);
      }
      
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Remover usuario de un plan
  Future<bool> removeUserFromPlan(String planId, String userId) async {
    try {
      state = const AsyncValue.loading();
      
      final success = await _planService.removeUserFromPlan(planId, userId);
      
      if (success) {
        // Recargar la lista de participantes
        loadPlanParticipants(planId);
      }
      
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Cambiar rol de participante
  Future<bool> changeParticipantRole(String planId, String userId, String newRole) async {
    try {
      state = const AsyncValue.loading();
      
      final success = await _planService.changeParticipantRole(planId, userId, newRole);
      
      if (success) {
        // Recargar la lista de participantes
        loadPlanParticipants(planId);
      }
      
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Actualizar última actividad del usuario
  Future<bool> updateUserLastActive(String planId, String userId) async {
    try {
      return await _planService.updateUserLastActive(planId, userId);
    } catch (e) {
      return false;
    }
  }

  // Verificar si usuario participa en un plan
  Future<bool> isUserParticipant(String planId, String userId) async {
    try {
      return await _planService.isUserParticipant(planId, userId);
    } catch (e) {
      return false;
    }
  }

  // Obtener participación específica
  Future<PlanParticipation?> getParticipation(String planId, String userId) async {
    try {
      return await _planService.getParticipation(planId, userId);
    } catch (e) {
      return null;
    }
  }

  // Obtener solo organizadores
  List<PlanParticipation> get organizers {
    return state.when(
      data: (participations) => participations.where((p) => p.isOrganizer).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Obtener solo participantes (no organizadores)
  List<PlanParticipation> get participants {
    return state.when(
      data: (participations) => participations.where((p) => p.isParticipant).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Obtener participantes activos
  List<PlanParticipation> get activeParticipants {
    return state.when(
      data: (participations) => participations.where((p) => p.isActive).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Contar participantes
  int get participantCount {
    return state.when(
      data: (participations) => participations.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  // Contar organizadores
  int get organizerCount {
    return organizers.length;
  }

  // Contar participantes (no organizadores)
  int get regularParticipantCount {
    return participants.length;
  }
}
