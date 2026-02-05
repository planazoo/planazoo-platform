import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/plan_message.dart';
import '../../domain/services/chat_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Provider para el servicio de chat
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

/// StreamProvider para obtener todos los mensajes de un plan
final planMessagesProvider = StreamProvider.family<List<PlanMessage>, String>((ref, planId) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getMessages(planId);
});

/// StreamProvider para obtener el contador de mensajes no leídos
final unreadMessagesCountProvider = StreamProvider.family<int, String>((ref, planId) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return Stream.value(0);
  }

  final chatService = ref.watch(chatServiceProvider);
  return chatService.getUnreadCountStream(planId, currentUser.id);
});

/// FutureProvider para marcar un mensaje como leído
final markMessageAsReadProvider = FutureProvider.family<bool, ({String planId, String messageId, String userId})>((ref, params) async {
  final chatService = ref.watch(chatServiceProvider);
  return await chatService.markMessageAsRead(
    params.planId,
    params.messageId,
    params.userId,
  );
});

/// FutureProvider para marcar todos los mensajes como leídos
final markAllMessagesAsReadProvider = FutureProvider.family<int, ({String planId, String userId})>((ref, params) async {
  final chatService = ref.watch(chatServiceProvider);
  return await chatService.markAllMessagesAsRead(
    params.planId,
    params.userId,
  );
});

/// FutureProvider para enviar un mensaje
final sendMessageProvider = FutureProvider.family<String?, ({String planId, PlanMessage message})>((ref, params) async {
  final chatService = ref.watch(chatServiceProvider);
  return await chatService.sendMessage(
    params.planId,
    params.message,
  );
});

/// FutureProvider para editar un mensaje
final editMessageProvider = FutureProvider.family<bool, ({String planId, String messageId, String newMessage, String userId})>((ref, params) async {
  final chatService = ref.watch(chatServiceProvider);
  return await chatService.editMessage(
    params.planId,
    params.messageId,
    params.newMessage,
    params.userId,
  );
});

/// FutureProvider para eliminar un mensaje
final deleteMessageProvider = FutureProvider.family<bool, ({String planId, String messageId, String userId})>((ref, params) async {
  final chatService = ref.watch(chatServiceProvider);
  return await chatService.deleteMessage(
    params.planId,
    params.messageId,
    params.userId,
  );
});
