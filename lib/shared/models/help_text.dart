/// T157: Modelo para un texto de ayuda contextual (modal + enlace).
class HelpText {
  const HelpText({
    this.title,
    required this.body,
    this.url,
  });

  final String? title;
  final String body;
  final String? url;

  factory HelpText.fromFirestore(Map<String, dynamic> data, String locale) {
    final lang = _normalizeLocale(locale);
    final body = data[lang] as String? ?? data['es'] as String? ?? data['en'] as String? ?? '';
    final url = data['url'] as String? ?? data['url_$lang'] as String?;
    return HelpText(body: body, url: url);
  }

  static String _normalizeLocale(String locale) {
    final lower = locale.toLowerCase();
    if (lower.startsWith('es')) return 'es';
    if (lower.startsWith('en')) return 'en';
    return lower.split('_').first.split('-').first;
  }
}
