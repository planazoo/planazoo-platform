import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/calendar/domain/models/communication_attachment.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:url_launcher/url_launcher.dart';

/// Cuerpo de un mail (buzón o ficha).
/// HTML con `<a href>` si lo hay; si no, el plano de Outlook (`palabra <https://…>`).
class CommunicationBodyView extends StatelessWidget {
  final String bodyPlain;
  final String? bodyHtml;
  final List<CommunicationAttachment> attachments;

  const CommunicationBodyView({
    super.key,
    required this.bodyPlain,
    this.bodyHtml,
    this.attachments = const [],
  });

  static Future<void> openLink(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    var raw = url.trim();
    if (raw.toLowerCase().startsWith('tel:')) {
      try {
        raw = Uri.decodeFull(raw);
      } catch (_) {}
    }
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    final ok = uri.isScheme('https') ||
        uri.isScheme('http') ||
        uri.isScheme('mailto') ||
        uri.isScheme('tel');
    if (!ok) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static bool _hasRealHtmlLinks(String? html) {
    if (html == null || html.trim().isEmpty) return false;
    return RegExp(r'''<a\s[^>]*href\s*=\s*['"]?(https?|mailto|tel):''', caseSensitive: false)
        .hasMatch(html);
  }

  @override
  Widget build(BuildContext context) {
    final html = _readableHtml(bodyHtml);
    final outlookBrackets = RegExp(
      r'<(https?|tel|mailto):',
      caseSensitive: false,
    ).hasMatch(bodyPlain);
    // Hotmail/Outlook pega `palabra <https://…>` en el plano; eso manda
    // aunque exista un HTML wrapper sin el texto del enlace.
    Widget body;
    if (!outlookBrackets && _hasRealHtmlLinks(html)) {
      body = DefaultTextStyle(
        style: AppTypography.bodyStyle.copyWith(color: IosFormColors.textPrimary),
        child: Html(
          data: html!,
          shrinkWrap: true,
          style: {
            'html': Style(
              color: IosFormColors.textPrimary,
              backgroundColor: Colors.transparent,
            ),
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              color: IosFormColors.textPrimary,
              fontSize: FontSize(16),
              backgroundColor: Colors.transparent,
              lineHeight: LineHeight.number(1.4),
            ),
            'p': Style(color: IosFormColors.textPrimary),
            'div': Style(color: IosFormColors.textPrimary),
            'span': Style(color: IosFormColors.textPrimary),
            'td': Style(color: IosFormColors.textPrimary),
            'th': Style(color: IosFormColors.textPrimary),
            'li': Style(color: IosFormColors.textPrimary),
            'a': Style(
              color: IosFormColors.accent,
              textDecoration: TextDecoration.underline,
            ),
          },
          onLinkTap: (url, _, __) {
            openLink(url);
          },
        ),
      );
    } else {
      final plain = bodyPlain.trim().isEmpty ? '—' : bodyPlain;
      body = _LinkifiedPlainBody(text: plain);
    }
    if (attachments.isEmpty) return body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        body,
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.communicationAttachmentsLabel,
          style: AppTypography.caption.copyWith(color: IosFormColors.textSecondary),
        ),
        const SizedBox(height: 8),
        ...attachments.map(_attachmentBlock),
      ],
    );
  }

  Widget _attachmentBlock(CommunicationAttachment a) {
    if (a.isImage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => openLink(a.url),
          child: Image.network(
            a.url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fileRow(a),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _fileRow(a),
    );
  }

  Widget _fileRow(CommunicationAttachment a) {
    return InkWell(
      onTap: () => openLink(a.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(Icons.attach_file, size: 18, color: IosFormColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                a.name,
                style: AppTypography.bodyStyle.copyWith(color: IosFormColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quita colores inline del HTML del hotel para que el texto se lea en el sheet oscuro.
  static String? _readableHtml(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return null;
    return s
        .replaceAll(RegExp(r'''color\s*:\s*[^;}"']+;?''', caseSensitive: false), '')
        .replaceAll(RegExp(r'''background(?:-color)?\s*:\s*[^;}"']+;?''', caseSensitive: false), '')
        .replaceAll(
          RegExp(r'''\s(?:bg)?color\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)''', caseSensitive: false),
          '',
        );
  }
}

/// Outlook / Hotmail: `manage reservation <https://…>` → la palabra es el enlace.
class _LinkifiedPlainBody extends StatelessWidget {
  final String text;

  const _LinkifiedPlainBody({required this.text});

  static final _tokenRe = RegExp(
    r'\[(https?://[^\s\]]+)\]'
    r'|([^\n<]{1,80}?)\s*<((?:https?|tel|mailto):[^>]+)>'
    r'|(https?://[^\s<>]+)',
    caseSensitive: false,
  );

  static final _imageExt = RegExp(r'\.(png|jpe?g|gif|webp)(\?|$)', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.bodyStyle.copyWith(color: IosFormColors.textPrimary);
    final link = base.copyWith(
      color: IosFormColors.accent,
      decoration: TextDecoration.underline,
      decorationColor: IosFormColors.accent,
    );
    return Text.rich(
      TextSpan(style: base, children: _spans(text, base, link)),
    );
  }

  static List<InlineSpan> _spans(String text, TextStyle base, TextStyle link) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _tokenRe.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      final imageUrl = m.group(1);
      final labelRaw = m.group(2);
      final labeledUrl = m.group(3);
      final bareUrl = m.group(4);
      if (imageUrl != null) {
        if (_imageExt.hasMatch(imageUrl)) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Image.network(
                imageUrl,
                width: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _linkChip(imageUrl, imageUrl, link),
              ),
            ),
          ));
        } else {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _linkChip(imageUrl, imageUrl, link),
          ));
        }
      } else if (labeledUrl != null) {
        var label = (labelRaw ?? '').trim().replaceFirst(RegExp(r'^[|\-–—]+\s*'), '');
        if (label.contains('\n')) {
          label = label.split('\n').last.trim();
        }
        if (label.isEmpty) label = labeledUrl;
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: _linkChip(label, labeledUrl, link),
        ));
      } else if (bareUrl != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: _linkChip(bareUrl, bareUrl, link),
        ));
      }
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: base));
    }
    return spans;
  }

  static Widget _linkChip(String label, String url, TextStyle style) {
    return GestureDetector(
      onTap: () => CommunicationBodyView.openLink(url),
      child: Text(label, style: style),
    );
  }
}
