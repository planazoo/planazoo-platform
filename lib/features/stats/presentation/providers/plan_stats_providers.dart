import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/services/plan_stats_service.dart';
import '../../domain/models/plan_stats.dart';

/// T113: Provider del servicio de estadísticas
final planStatsServiceProvider = Provider<PlanStatsService>((ref) {
  return PlanStatsService();
});

/// T113: Provider para calcular estadísticas de un plan
final planStatsProvider = FutureProvider.family<PlanStats, String>((ref, planId) async {
  final statsService = ref.watch(planStatsServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser?.id == null) {
    throw Exception('Usuario no autenticado');
  }
  
  // Obtener el plan
  final planService = ref.watch(planServiceProvider);
  final plan = await planService.getPlanById(planId);
  
  if (plan == null) {
    throw Exception('Plan no encontrado');
  }
  
  return await statsService.calculateStats(plan, currentUser!.id);
});

