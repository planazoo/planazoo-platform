import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/color_scheme.dart';

/// Widget de input para escribir mensajes en el chat
class ChatInput extends ConsumerStatefulWidget {
  final Function(String message) onSend;

  const ChatInput({
    super.key,
    required this.onSend,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  static const Color _pageBg = Color(0xFF111827);
  static const Color _surface = Color(0xFF1F2937);
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSend(message);
      _controller.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _pageBg,
        border: Border(
          top: BorderSide(
            color: Colors.white12,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Campo de texto
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent &&
                        (event.logicalKey == LogicalKeyboardKey.enter ||
                            event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
                      if (HardwareKeyboard.instance.isAltPressed) {
                        return KeyEventResult.ignored;
                      }
                      _handleSend();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: _controller,
                    onChanged: (text) {
                      setState(() {
                        _isComposing = text.trim().isNotEmpty;
                      });
                    },
                    onSubmitted: (_) => _handleSend(),
                    style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white60,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón de enviar
            Container(
              decoration: BoxDecoration(
                color: _isComposing
                    ? AppColorScheme.color2
                    : Colors.white24,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: _isComposing
                      ? Colors.white
                      : Colors.white,
                ),
                onPressed: _isComposing ? _handleSend : null,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
