import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fila de itinerario de Mi resumen: icono, hora, título, badges, chips Maps/web.
class PlanSummaryLinkRow extends StatelessWidget {
  const PlanSummaryLinkRow({
    super.key,
    required this.text,
    this.onOpenDetail,
    this.mapsQuery,
    this.routeUrl,
    this.webUrl,
    this.leadingIcon,
    this.timeLabel,
    this.subtitle,
    this.subtitleEmphasizeAll = false,
    this.mutedPast = false,
    this.showDraftBadge = false,
    this.typeBadgeIcon,
    this.typeBadgeTooltip,
    this.forceShowLeadingIcon = false,
  });

  final String text;
  final VoidCallback? onOpenDetail;
  final String? mapsQuery;
  final String? routeUrl;
  final String? webUrl;
  final IconData? leadingIcon;
  final String? timeLabel;
  final String? subtitle;
  final bool subtitleEmphasizeAll;
  final bool mutedPast;
  final bool showDraftBadge;
  final IconData? typeBadgeIcon;
  final String? typeBadgeTooltip;
  final bool forceShowLeadingIcon;

  static const double rowHeight = 48;
  static const double _chipSize = 26;
  static const double _chipGap = 4;
  static const double _timeColWidth = 82;
  static const double _leadingIconWidth = 22;
  static const Color _textSecondary = Colors.white70;
  static const Color _textTertiary = Colors.white60;
  static const Color _textMuted = Color(0x8AFFFFFF);
  static const TextHeightBehavior _tightFirstLineHeight = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: true,
  );

  static Future<void> openMapsQuery(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openWebUrl(String rawUrl) async {
    final normalized = _normalizeUrl(rawUrl);
    if (normalized == null) return;
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static String? _normalizeUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://$value';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hasRoute = routeUrl != null && routeUrl!.trim().isNotEmpty;
    final hasMaps =
        !hasRoute && mapsQuery != null && mapsQuery!.trim().isNotEmpty;
    final hasWebUrl = webUrl != null && webUrl!.trim().isNotEmpty;
    final titleColor = mutedPast
        ? _textMuted
        : (onOpenDetail != null ? AppColorScheme.color2 : _textSecondary);
    final subColor = mutedPast
        ? _textMuted
        : (subtitleEmphasizeAll ? Colors.orange.shade200 : _textTertiary);
    final subWeight = mutedPast
        ? FontWeight.w400
        : (subtitleEmphasizeAll ? FontWeight.w600 : FontWeight.w400);
    final iconColor = mutedPast ? _textMuted : _textTertiary;
    final timeColor = mutedPast ? _textMuted : _textSecondary;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final showLeadingIcon =
        leadingIcon != null && (!isMobile || forceShowLeadingIcon);
    final showTypeBadge = typeBadgeIcon != null;
    final typeBadgeColor = mutedPast ? _textMuted : AppColorScheme.color2;

    return SizedBox(
      height: rowHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenDetail,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showLeadingIcon) ...[
                SizedBox(
                  width: _leadingIconWidth,
                  child: Icon(leadingIcon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 6),
              ],
              if (timeLabel != null) ...[
                SizedBox(
                  width: _timeColWidth,
                  child: Text(
                    timeLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: timeColor,
                      height: 1.2,
                    ),
                    textHeightBehavior: _tightFirstLineHeight,
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        if (showDraftBadge) ...[
                          Tooltip(
                            message: loc.eventStatusDraft,
                            child: Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(right: 6),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade800
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.orange.shade300
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              child: Text(
                                loc.myPlanSummaryDraftBadgeLetter,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade100,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (showTypeBadge) ...[
                          Tooltip(
                            message: typeBadgeTooltip ?? '',
                            child: Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(right: 6),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: typeBadgeColor.withValues(
                                  alpha: mutedPast ? 0.15 : 0.22,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: typeBadgeColor.withValues(
                                    alpha: mutedPast ? 0.35 : 0.55,
                                  ),
                                ),
                              ),
                              child: Icon(
                                typeBadgeIcon,
                                size: 12,
                                color: mutedPast ? _textMuted : Colors.white,
                              ),
                            ),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            text,
                            maxLines: hasSubtitle ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: timeLabel != null ? 14 : 13,
                              color: titleColor,
                              height: 1.2,
                            ),
                            textHeightBehavior: _tightFirstLineHeight,
                          ),
                        ),
                      ],
                    ),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: subColor,
                          fontWeight: subWeight,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasRoute || hasMaps || hasWebUrl) ...[
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasRoute)
                      SizedBox(
                        width: _chipSize,
                        height: _chipSize,
                        child: Tooltip(
                          message: loc.openRouteInGoogleMaps,
                          child: _LinkChip(
                            icon: Icons.route,
                            onTap: () => openWebUrl(routeUrl!),
                          ),
                        ),
                      ),
                    if (hasRoute && (hasMaps || hasWebUrl))
                      const SizedBox(width: _chipGap),
                    if (hasMaps)
                      SizedBox(
                        width: _chipSize,
                        height: _chipSize,
                        child: _LinkChip(
                          icon: Icons.location_on,
                          onTap: () => openMapsQuery(mapsQuery!),
                        ),
                      ),
                    if (hasMaps && hasWebUrl) const SizedBox(width: _chipGap),
                    if (hasWebUrl)
                      SizedBox(
                        width: _chipSize,
                        height: _chipSize,
                        child: _LinkChip(
                          icon: Icons.public,
                          onTap: () => openWebUrl(webUrl!),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColorScheme.color2.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Icon(icon, size: 15, color: AppColorScheme.color2),
        ),
      ),
    );
  }
}
