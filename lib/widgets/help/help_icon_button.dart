import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/models/help_text.dart';
import 'package:unp_calendario/shared/providers/help_text_providers.dart';

/// T157: Botón de ayuda contextual (?). Abre un modal con texto y opcional enlace "Más información".
/// [helpId] — id del documento en Firestore (ej. plan_details.aviso).
/// [contextLabel] — nombre del contexto para accesibilidad ("Ayuda sobre [contextLabel]").
/// [defaultBody] y [defaultUrl] — fallback cuando no hay red o no existe el doc.
class HelpIconButton extends ConsumerWidget {
  const HelpIconButton({
    super.key,
    required this.helpId,
    required this.contextLabel,
    required this.defaultBody,
    this.defaultUrl,
    this.iconSize = 18,
    this.iconColor,
  });

  final String helpId;
  final String contextLabel;
  final String defaultBody;
  final String? defaultUrl;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final service = ref.read(helpTextServiceProvider);
    final color = iconColor ?? Colors.white70;

    return Semantics(
      label: 'Ayuda sobre $contextLabel',
      hint: 'Abre una explicación y un enlace a más información',
      button: true,
      child: IconButton(
        icon: Icon(Icons.help_outline, size: iconSize, color: color),
        onPressed: () => _openHelpModal(context, ref, service, locale, l10n),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
    showDialog<void>(
      context: context,
      builder: (ctx) => _HelpModal(
        title: contextLabel,
        body: body,
        url: url,
        moreInfoLabel: l10n.helpMoreInfo,
        closeLabel: l10n.close,
      ),
    );
  }
}

class _HelpModal extends StatelessWidget {
  const _HelpModal({
    required this.title,
    required this.body,
    this.url,
    required this.moreInfoLabel,
    required this.closeLabel,
  });

  final String title;
  final String body;
  final String? url;
  final String moreInfoLabel;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColorScheme.titleColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColorScheme.bodyColor,
                height: 1.4,
              ),
            ),
            if (url != null && url!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Semantics(
                label: '$moreInfoLabel sobre $title',
                link: true,
                child: InkWell(
                  onTap: () => _launchUrl(url!),
                  child: Text(
                    moreInfoLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColorScheme.interactiveColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(closeLabel),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
