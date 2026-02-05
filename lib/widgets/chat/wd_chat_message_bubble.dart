import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/chat/domain/models/plan_message.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../shared/utils/date_formatter.dart';
import '../../app/theme/color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget que muestra una burbuja de mensaje tipo WhatsApp
class ChatMessageBubble extends ConsumerWidget {
  final PlanMessage message;
  final String? senderDisplayName;
  final String? senderUsername;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.senderDisplayName,
    this.senderUsername,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isOwnMessage = currentUser != null && message.userId == currentUser.id;
    final isRead = currentUser != null && message.isReadBy(currentUser.id);

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
            // Nombre del remitente (solo si no es nuestro mensaje)
            if (!isOwnMessage && senderDisplayName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 12),
                child: Text(
                  senderDisplayName ?? senderUsername ?? 'Usuario',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            // Burbuja del mensaje
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? AppColorScheme.color2 // Color para mensajes propios
                    : Colors.grey.shade800, // Color para mensajes de otros
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
                  // Mensaje
                  Text(
                    message.message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Timestamp y estado
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      if (isOwnMessage) ...[
                        const SizedBox(width: 4),
                        // Indicador de estado (solo para mensajes propios)
                        Icon(
                          isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: isRead
                              ? Colors.blue.shade300 // Leído (azul)
                              : Colors.white.withOpacity(0.7), // Enviado (gris)
                        ),
                      ],
                      if (message.isEdited) ...[
                        const SizedBox(width: 4),
                        Text(
                          'editado',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
