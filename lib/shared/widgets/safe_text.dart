import 'package:flutter/material.dart';
import '../../features/security/utils/sanitizer.dart';

/// Widget para mostrar texto de forma segura, escapando HTML automáticamente
/// 
/// En Flutter, el widget Text escapa HTML automáticamente, pero este widget
/// hace explícita la intención de mostrar contenido seguro y sanitiza antes de mostrar.
class SafeText extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool allowHtml; // Si true, permite HTML básico (aún no implementado con flutter_html)

  const SafeText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.allowHtml = false,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sanitizar texto plano (remover caracteres especiales peligrosos)
    final sanitized = Sanitizer.sanitizePlainText(text);

    // Si allowHtml es true, sanitizar HTML también
    final finalText = allowHtml ? Sanitizer.sanitizeHtml(sanitized) : sanitized;

    // Flutter Text escapa HTML automáticamente, pero aquí hacemos explícita la sanitización
    return Text(
      finalText,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

