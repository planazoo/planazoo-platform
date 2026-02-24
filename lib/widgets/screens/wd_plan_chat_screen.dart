import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/chat/domain/models/plan_message.dart';
import '../../features/chat/presentation/providers/chat_providers.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/domain/services/user_service.dart';
import '../../features/auth/domain/models/user_model.dart';
import '../../app/theme/color_scheme.dart';
import '../chat/wd_chat_message_bubble.dart';
import '../chat/wd_chat_input.dart';
import '../../shared/services/logger_service.dart';

/// Pantalla de chat del plan tipo WhatsApp
class PlanChatScreen extends ConsumerStatefulWidget {
  final String planId;
  final String planName;

  const PlanChatScreen({
    super.key,
    required this.planId,
    required this.planName,
  });

  @override
  ConsumerState<PlanChatScreen> createState() => _PlanChatScreenState();
}

class _PlanChatScreenState extends ConsumerState<PlanChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, UserModel> _userCache = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUser(String userId) async {
    if (_userCache.containsKey(userId)) return;

    try {
      final userService = UserService();
      final user = await userService.getUser(userId);
      if (user != null && mounted) {
        setState(() {
          _userCache[userId] = user;
        });
      }
    } catch (e) {
      LoggerService.error(
        'Error loading user: $userId',
        context: 'PLAN_CHAT_SCREEN',
        error: e,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSendMessage(String messageText) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final message = PlanMessage(
      planId: widget.planId,
      userId: currentUser.id,
      message: messageText,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final chatService = ref.read(chatServiceProvider);
    final messageId = await chatService.sendMessage(widget.planId, message);

    if (messageId != null) {
      // Marcar como leído inmediatamente (mensaje propio)
      await chatService.markMessageAsRead(
        widget.planId,
        messageId,
        currentUser.id,
      );

      // Scroll al final después de enviar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(planMessagesProvider(widget.planId));
    final currentUser = ref.watch(currentUserProvider);

    // Marcar todos los mensajes como leídos cuando se abre el chat
    if (currentUser != null) {
      ref.read(markAllMessagesAsReadProvider((
        planId: widget.planId,
        userId: currentUser.id,
      )).future);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: AppColorScheme.color2,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Chat del plan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.1,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // Cargar usuarios de los mensajes
                for (var message in messages) {
                  if (!_userCache.containsKey(message.userId)) {
                    _loadUser(message.userId);
                  }
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay mensajes aún',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sé el primero en escribir',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Scroll al final cuando hay nuevos mensajes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final user = _userCache[message.userId];

                    return ChatMessageBubble(
                      message: message,
                      senderDisplayName: user?.displayName,
                      senderUsername: user?.username,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) {
                LoggerService.error(
                  'Error loading messages for plan: ${widget.planId}',
                  context: 'PLAN_CHAT_SCREEN',
                  error: error,
                  stackTrace: stack,
                );
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar mensajes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(planMessagesProvider(widget.planId));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorScheme.color2,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reintentar',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Input de mensaje
          if (currentUser != null)
            ChatInput(
              onSend: _handleSendMessage,
            ),
        ],
      ),
    );
  }
}
