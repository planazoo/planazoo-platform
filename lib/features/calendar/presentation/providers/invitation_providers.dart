import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/logger_service.dart';
import '../../domain/models/plan_invitation.dart';
import '../../domain/services/invitation_service.dart';

/// Provider para InvitationService
final invitationServiceProvider = Provider<InvitationService>((ref) {
  return InvitationService();
});

/// Provider para obtener una invitación por token
final invitationByTokenProvider = FutureProvider.family<PlanInvitation?, String>((ref, token) async {
  final invitationService = ref.read(invitationServiceProvider);
  try {
    return await invitationService.getInvitationByToken(token);
  } catch (e) {
    LoggerService.error(
      'Error getting invitation by token: $token',
      context: 'INVITATION_PROVIDERS',
      error: e,
    );
    return null;
  }
});

/// Provider para obtener invitaciones pendientes de un plan
final pendingInvitationsProvider = FutureProvider.family<List<PlanInvitation>, String>((ref, planId) async {
  final invitationService = ref.read(invitationServiceProvider);
  try {
    return await invitationService.getPendingInvitations(planId);
  } catch (e) {
    LoggerService.error(
      'Error getting pending invitations for plan: $planId',
      context: 'INVITATION_PROVIDERS',
      error: e,
    );
    return [];
  }
});


