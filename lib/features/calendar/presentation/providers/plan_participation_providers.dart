import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/models/plan_participation.dart';
import '../../domain/services/plan_participation_service.dart';
import '../notifiers/plan_participation_notifier.dart';
import 'calendar_providers.dart';

// Servicios
final planParticipationServiceProvider = Provider<PlanParticipationService>((ref) {
  return PlanParticipationService();
});

// Notifier
final planParticipationNotifierProvider = StateNotifierProvider.family<PlanParticipationNotifier, AsyncValue<List<PlanParticipation>>, String>((ref, planId) {
  final participationService = ref.watch(planParticipationServiceProvider);
  final planService = ref.watch(planServiceProvider);
  
  return PlanParticipationNotifier(
    planId: planId,
    participationService: participationService,
    planService: planService,
  );
});

// Providers específicos para un plan
final planParticipantsProvider = Provider.family<AsyncValue<List<PlanParticipation>>, String>((ref, planId) {
  return ref.watch(planParticipationNotifierProvider(planId));
});

// Provider para participantes reales (excluye observadores)
final planRealParticipantsProvider = Provider.family<AsyncValue<List<PlanParticipation>>, String>((ref, planId) {
  final allParticipants = ref.watch(planParticipantsProvider(planId));
  return allParticipants.when(
    data: (participants) => AsyncValue.data(
      participants.where((p) => p.isActive && !p.isObserver).toList()
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Verificaciones
final isUserParticipantProvider = FutureProvider.family<bool, ({String planId, String userId})>((ref, params) async {
  final participationService = ref.read(planParticipationServiceProvider);
  return await participationService.isUserParticipant(params.planId, params.userId);
});

final userParticipationProvider = FutureProvider.family<PlanParticipation?, ({String planId, String userId})>((ref, params) async {
  final participationService = ref.read(planParticipationServiceProvider);
  return await participationService.getParticipation(params.planId, params.userId);
});

/// Mapa userId -> nombre para mostrar (Resumen del plan). Resuelve displayName/username/email.
final planParticipantDisplayNamesProvider = FutureProvider.family<Map<String, String>, String>((ref, planId) async {
  final participantsAsync = ref.watch(planParticipantsProvider(planId));
  final list = participantsAsync.valueOrNull ?? [];
  final userService = ref.read(userServiceProvider);
  final map = <String, String>{};
  for (final p in list) {
    try {
      final user = await userService.getUser(p.userId);
      if (user != null) {
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
          map[p.userId] = user.displayName!.trim();
        } else if (user.username != null && user.username!.trim().isNotEmpty) {
          map[p.userId] = '@${user.username!.trim()}';
        } else if (user.email != null && user.email!.trim().isNotEmpty) {
          map[p.userId] = user.email!.trim();
        } else {
          map[p.userId] = p.userId;
        }
      } else {
        map[p.userId] = p.userId;
      }
    } catch (_) {
      map[p.userId] = p.userId;
    }
  }
  return map;
});
