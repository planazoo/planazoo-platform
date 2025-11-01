import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/logger_service.dart';
import '../../domain/models/plan_announcement.dart';
import '../../domain/services/announcement_service.dart';

/// Provider para AnnouncementService
final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService();
});

/// Provider para obtener los avisos de un plan
final planAnnouncementsProvider = StreamProvider.family<List<PlanAnnouncement>, String>((ref, planId) {
  final announcementService = ref.read(announcementServiceProvider);
  try {
    return announcementService.getAnnouncements(planId);
  } catch (e) {
    LoggerService.error('Error getting announcements for plan: $planId', context: 'ANNOUNCEMENT_PROVIDERS', error: e);
    return Stream.value([]); // Retornar lista vacía en caso de error
  }
});

/// Provider para contar avisos de un plan
final planAnnouncementsCountProvider = FutureProvider.family<int, String>((ref, planId) async {
  final announcementService = ref.read(announcementServiceProvider);
  try {
    return await announcementService.countAnnouncements(planId);
  } catch (e) {
    LoggerService.error('Error counting announcements for plan: $planId', context: 'ANNOUNCEMENT_PROVIDERS', error: e);
    return 0; // Retornar 0 en caso de error
  }
});

