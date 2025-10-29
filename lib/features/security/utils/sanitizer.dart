class Sanitizer {
  // Whitelist simple de tags permitidos en HTML ligero
  static const Set<String> _allowedTags = {
    'b', 'strong', 'i', 'em', 'u', 'br', 'p', 'ul', 'ol', 'li', 'a'
  };

  // Sanea texto plano: recorta y normaliza espacios
  static String sanitizePlainText(String? input, {int? maxLength}) {
    final value = (input ?? '').trim();
    if (value.isEmpty) return '';
    final collapsed = value.replaceAll(RegExp(r"\s+"), ' ');
    if (maxLength != null && collapsed.length > maxLength) {
      return collapsed.substring(0, maxLength);
    }
    return collapsed;
  }

  // Sanea HTML muy básico con whitelist de tags y atributos seguros para <a>
  static String sanitizeHtml(String? html) {
    if (html == null || html.isEmpty) return '';
    var out = html;
    // Eliminar scripts/iframes/styles y on* handlers
    out = out.replaceAll(RegExp(r'<\s*(script|style|iframe)[^>]*>[\s\S]*?<\s*/\s*\1\s*>', multiLine: true, caseSensitive: false), '');
    out = out.replaceAll(RegExp(r'on[a-zA-Z]+\s*=\s*"[^"]*"', caseSensitive: false), '');
    out = out.replaceAll(RegExp(r"on[a-zA-Z]+\s*=\s*'[^']*'", caseSensitive: false), '');
    out = out.replaceAll(RegExp(r'on[a-zA-Z]+\s*=\s*[^\s>]+', caseSensitive: false), '');

    // Quitar tags no permitidos manteniendo su contenido
    out = out.replaceAllMapped(RegExp(r"<\/?([a-zA-Z0-9]+)([^>]*)>", multiLine: true), (m) {
      final tag = m.group(1)!.toLowerCase();
      final closing = m.group(0)!.startsWith('</');
      if (!_allowedTags.contains(tag)) {
        return '';
      }
      if (tag == 'a' && !closing) {
        final attrs = m.group(2) ?? '';
        final hrefMatch = RegExp('href="([^"]*)"|href=\'([^\']*)\'|href=([^\\s>]+)').firstMatch(attrs);
        String href = '';
        if (hrefMatch != null) {
          href = (hrefMatch.group(1) ?? hrefMatch.group(2) ?? hrefMatch.group(3) ?? '').trim();
        }
        if (!(href.startsWith('http://') || href.startsWith('https://'))) {
          href = '';
        }
        final titleMatch = RegExp('title="([^"]*)"|title=\'([^\']*)\'').firstMatch(attrs);
        final title = (titleMatch?.group(1) ?? titleMatch?.group(2) ?? '').trim();
        final safe = StringBuffer('<a');
        if (href.isNotEmpty) safe.write(' href=\"$href\" rel=\"noopener noreferrer\"');
        if (title.isNotEmpty) safe.write(' title=\"$title\"');
        safe.write('>');
        return safe.toString();
      }
      return closing ? '</$tag>' : '<$tag>';
    });
    return out;
  }
}


