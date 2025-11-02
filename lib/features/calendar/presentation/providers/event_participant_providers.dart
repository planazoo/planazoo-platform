import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/logger_service.dart';
import '../../domain/models/event_participant.dart';
import '../../domain/services/event_participant_service.dart';

/// Provider para EventParticipantService
final eventParticipantServiceProvider = Provider<EventParticipantService>((ref) {
  return EventParticipantService();
});

/// Provider para obtener los participantes de un evento (Stream)
final eventParticipantsProvider = StreamProvider.family<List<EventParticipant>, String>((ref, eventId) {
  final eventParticipantService = ref.read(eventParticipantServiceProvider);
  try {
    return eventParticipantService.getEventParticipants(eventId);
  } catch (e) {
    LoggerService.error(
      'Error getting event participants for event: $eventId',
      context: 'EVENT_PARTICIPANT_PROVIDERS',
      error: e,
    );
    return Stream.value([]); // Retornar lista vacía en caso de error
  }
});

/// Provider para obtener el número de participantes de un evento (Future)
final eventParticipantsCountProvider = FutureProvider.family<int, String>((ref, eventId) async {
  final eventParticipantService = ref.read(eventParticipantServiceProvider);
  try {
    return await eventParticipantService.countParticipants(eventId);
  } catch (e) {
    LoggerService.error(
      'Error counting participants for event: $eventId',
      context: 'EVENT_PARTICIPANT_PROVIDERS',
      error: e,
    );
    return 0; // Retornar 0 en caso de error
  }
});

/// Provider para verificar si un usuario está registrado en un evento (Future)
final isUserRegisteredProvider = FutureProvider.family<bool, ({String eventId, String userId})>((ref, params) async {
  final eventParticipantService = ref.read(eventParticipantServiceProvider);
  try {
    return await eventParticipantService.isUserRegistered(params.eventId, params.userId);
  } catch (e) {
    LoggerService.error(
      'Error checking user registration: ${params.eventId}, ${params.userId}',
      context: 'EVENT_PARTICIPANT_PROVIDERS',
      error: e,
    );
    return false; // Retornar false en caso de error
  }
});

