import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/chat/domain/models/plan_message.dart';
import '../../features/chat/presentation/providers/chat_providers.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../app/theme/color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emojis disponibles para reacciones (clic derecho o pulsación larga en el mensaje)
const List<String> _reactionEmojis = ['👍', '❤️', '😂', '😮', '😢', '🔥'];

const Color _kWebBorder = Color(0xFFE2E8F0);
const Color _kWebMuted = Color(0xFF64748B);
const Color _kWebOnSurface = Color(0xFF0F172A);
const Color _kWebReactionBg = Color(0xFFF1F5F9);

/// Widget que muestra una burbuja de mensaje tipo WhatsApp
class ChatMessageBubble extends ConsumerWidget {
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
        isOwnMessage ? Colors.white : (kIsWeb ? _kWebOnSurface : Colors.white);
    final metaColor = isOwnMessage
        ? Colors.white.withValues(alpha: 0.7)
        : (kIsWeb ? _kWebMuted : Colors.white.withValues(alpha: 0.7));
    final editedColor = isOwnMessage
        ? Colors.white.withValues(alpha: 0.6)
        : (kIsWeb ? _kWebMuted : Colors.white.withValues(alpha: 0.6));

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
                    color: kIsWeb ? _kWebMuted : Colors.grey.shade400,
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
                      : (kIsWeb ? Colors.white : Colors.grey.shade800),
                  border: !isOwnMessage && kIsWeb
                      ? Border.all(color: _kWebBorder)
                      : null,
                  boxShadow: !isOwnMessage && kIsWeb
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
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
                                ? Colors.blue.shade300
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
                            onTap: () => _toggleReaction(context, ref, emoji),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppColorScheme.color2.withValues(alpha: 0.6)
                                    : (kIsWeb
                                        ? _kWebReactionBg
                                        : Colors.white.withValues(alpha: 0.1)),
                                borderRadius: BorderRadius.circular(12),
                                border: !isMe && kIsWeb
                                    ? Border.all(color: _kWebBorder.withValues(alpha: 0.6))
                                    : null,
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
                                        color: (isOwnMessage || !kIsWeb)
                                            ? Colors.white70
                                            : _kWebMuted,
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
      color: kIsWeb ? Colors.white : Colors.grey.shade800,
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
      if (emoji != null) _toggleReaction(context, ref, emoji);
    });
  }

  Future<void> _toggleReaction(BuildContext context, WidgetRef ref, String emoji) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || message.id == null) return;
    final chatService = ref.read(chatServiceProvider);
    final ok = await chatService.toggleReaction(planId, message.id!, currentUser.id, emoji);
    if (ok && context.mounted) {
      ref.invalidate(planMessagesProvider(planId));
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
