import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Verificaciones
final isUserParticipantProvider = FutureProvider.family<bool, ({String planId, String userId})>((ref, params) async {
  final participationService = ref.read(planParticipationServiceProvider);
  return await participationService.isUserParticipant(params.planId, params.userId);
});

final userParticipationProvider = FutureProvider.family<PlanParticipation?, ({String planId, String userId})>((ref, params) async {
  final participationService = ref.read(planParticipationServiceProvider);
  return await participationService.getParticipation(params.planId, params.userId);
});
