import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/models/help_text.dart';
import 'package:unp_calendario/shared/providers/help_text_providers.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// T157: Botón de ayuda contextual (?). Abre un modal con texto y opcional enlace "Más información".
/// [helpId] — id del documento en Firestore (ej. plan_details.aviso).
/// [contextLabel] — nombre del contexto para accesibilidad ("Ayuda sobre [contextLabel]").
/// [defaultBody] y [defaultUrl] — fallback cuando no hay red o no existe el doc.
/// [compact] — cabe en fila Settings de [IosFormColors.rowHeight] (44); usar en
/// cabeceras colapsables / trailings de fila.
class HelpIconButton extends ConsumerWidget {
  const HelpIconButton({
    super.key,
    required this.helpId,
    required this.contextLabel,
    required this.defaultBody,
    this.defaultUrl,
    this.iconSize = 18,
    this.iconColor,
    this.compact = false,
  });

  final String helpId;
  final String contextLabel;
  final String defaultBody;
  final String? defaultUrl;
  final double iconSize;
  final Color? iconColor;
  /// Si true, tamaño táctil ≤ 28 para no romper filas de 44 px.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final service = ref.read(helpTextServiceProvider);
    final color = iconColor ?? IosFormColors.textSecondary;
    final resolvedIconSize = compact ? 16.0 : iconSize;
    final tapExtent = compact ? 28.0 : 32.0;

    return Semantics(
      label: l10n.helpAboutContext(contextLabel),
      hint: l10n.helpSemanticsHint,
      button: true,
      child: IconButton(
        icon: Icon(Icons.help_outline, size: resolvedIconSize, color: color),
        onPressed: () => _openHelpModal(context, ref, service, locale, l10n),
        padding: EdgeInsets.all(compact ? 2 : 4),
        constraints: BoxConstraints(
          minWidth: tapExtent,
          minHeight: tapExtent,
          maxWidth: tapExtent,
          maxHeight: tapExtent,
        ),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Future<void> _openHelpModal(
    BuildContext context,
    WidgetRef ref,
    dynamic service,
    String locale,
    AppLocalizations l10n,
  ) async {
    final HelpText? helpText = await service.getHelpText(helpId, locale);
    final String body = helpText?.body.isNotEmpty == true ? helpText!.body : defaultBody;
    final String? url = helpText?.url ?? defaultUrl;

    if (!context.mounted) return;
    await IosFormMessageSheet.show(
      context: context,
      title: contextLabel,
      okLabel: l10n.close,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            body,
            style: const TextStyle(
              color: IosFormColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          if (url != null && url.isNotEmpty) ...[
            const SizedBox(height: 16),
            Semantics(
              label: '${l10n.helpMoreInfo} $contextLabel',
              link: true,
              child: InkWell(
                onTap: () => _launchUrl(url),
                child: Text(
                  l10n.helpMoreInfo,
                  style: TextStyle(
                    color: IosFormColors.accent,
                    fontSize: 15,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
