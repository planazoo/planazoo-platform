import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/chat/domain/models/plan_message.dart';
import '../../features/chat/presentation/providers/chat_providers.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../app/theme/color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emojis disponibles para reacciones (clic derecho o pulsación larga en el mensaje)
const List<String> _reactionEmojis = ['👍', '❤️', '😂', '😮', '😢', '🔥'];

/// Widget que muestra una burbuja de mensaje tipo WhatsApp
class ChatMessageBubble extends ConsumerWidget {
  static const Color _surface = Color(0xFF1F2937);
  final String planId;
  final PlanMessage message;
  final String? senderDisplayName;
  final String? senderUsername;

  const ChatMessageBubble({
    super.key,
    required this.planId,
    required this.message,
    this.senderDisplayName,
    this.senderUsername,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isOwnMessage = currentUser != null && message.userId == currentUser.id;
    final isRead = currentUser != null && message.isReadBy(currentUser.id);
    // Defensivo: mensajes antiguos/hot reload pueden hacer que .reactions falle al leer
    final reactions = PlanMessage.safeReactions(message);

    final bodyTextColor =
        Colors.white;
    final metaColor = isOwnMessage
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.7);
    final editedColor = isOwnMessage
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.6);

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isOwnMessage && senderDisplayName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 12),
                child: Text(
                  senderDisplayName ?? senderUsername ?? 'Usuario',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            GestureDetector(
              onSecondaryTapDown: (details) => _showReactionMenu(context, ref, details.globalPosition),
              onLongPress: () {
                final box = context.findRenderObject() as RenderBox?;
                if (box != null) {
                  final offset = box.localToGlobal(Offset.zero);
                  _showReactionMenu(context, ref, Offset(offset.dx + box.size.width / 2, offset.dy));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isOwnMessage
                      ? AppColorScheme.color2
                      : _surface,
                  border: isOwnMessage
                      ? null
                      : Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isOwnMessage ? 18 : 4),
                    bottomRight: Radius.circular(isOwnMessage ? 4 : 18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: bodyTextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: metaColor,
                          ),
                        ),
                        if (isOwnMessage) ...[
                          const SizedBox(width: 4),
                          Icon(
                            isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: isRead
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                        ],
                        if (message.isEdited) ...[
                          const SizedBox(width: 4),
                          Text(
                            'editado',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: editedColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (reactions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: reactions.entries.map((e) {
                          final emoji = e.key;
                          final userIds = e.value;
                          final count = userIds.length;
                          final isMe = currentUser != null && userIds.contains(currentUser.id);
                          return GestureDetector(
                            onTap: () => _toggleReaction(ref, emoji),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppColorScheme.color2.withValues(alpha: 0.6)
                                    : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 14)),
                                  if (count > 1) ...[
                                    const SizedBox(width: 2),
                                    Text(
                                      '$count',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: isOwnMessage
                                            ? Colors.white70
                                            : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionMenu(BuildContext context, WidgetRef ref, Offset globalPosition) {
    const double menuWidth = 220;
    const double menuHeight = 56;
    final screenSize = MediaQuery.of(context).size;
    final left = (globalPosition.dx - menuWidth / 2).clamp(8.0, screenSize.width - menuWidth - 8);
    final top = (globalPosition.dy - menuHeight - 8).clamp(8.0, screenSize.height - menuHeight - 8);
    final position = RelativeRect.fromLTRB(left, top, left + menuWidth, top + menuHeight);
    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _surface,
      elevation: 8,
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: SizedBox(
            width: menuWidth,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: _reactionEmojis.map((emoji) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(emoji);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ).then((emoji) {
      if (emoji != null) _toggleReaction(ref, emoji);
    });
  }

  Future<void> _toggleReaction(WidgetRef ref, String emoji) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || message.id == null) return;
    final chatService = ref.read(chatServiceProvider);
    final ok = await chatService.toggleReaction(planId, message.id!, currentUser.id, emoji);
    if (ok) {
      ref.invalidate(planMessagesProvider(planId));
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
