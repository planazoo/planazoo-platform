import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/participant_group.dart';
import '../../domain/services/participant_group_service.dart';

/// T123: Providers Riverpod para grupos de participantes

// Servicio
final participantGroupServiceProvider = Provider<ParticipantGroupService>((ref) {
  return ParticipantGroupService();
});

// Stream de grupos de un usuario
final userGroupsStreamProvider = StreamProvider.family<List<ParticipantGroup>, String>((ref, userId) {
  final groupService = ref.watch(participantGroupServiceProvider);
  return groupService.getUserGroups(userId);
});

// Provider para obtener grupos de un usuario (Future)
final userGroupsProvider = FutureProvider.family<List<ParticipantGroup>, String>((ref, userId) async {
  final groupService = ref.read(participantGroupServiceProvider);
  return await groupService.getUserGroups(userId).first;
});

// Provider para obtener un grupo por ID
final groupByIdProvider = FutureProvider.family<ParticipantGroup?, String>((ref, groupId) async {
  final groupService = ref.read(participantGroupServiceProvider);
  return await groupService.getGroup(groupId);
});

