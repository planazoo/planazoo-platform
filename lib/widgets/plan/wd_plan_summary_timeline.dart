import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Fase visual del punto de timeline (demo reorg → prod).
enum PlanSummaryTimelinePhase { past, current, upcoming }

/// Fila de evento estilo timeline de la demo `/demo/my-summary-reorg`.
class PlanSummaryTimelineEventRow extends StatelessWidget {
  const PlanSummaryTimelineEventRow({
    super.key,
    required this.startTime,
    required this.title,
    required this.icon,
    required this.phase,
    required this.isFirst,
    required this.isLast,
    required this.showLineBelow,
    required this.lineBelowDashed,
    this.timeRange,
    this.subtitle,
    this.durationLabel,
    this.showNowLabel = false,
    this.showDraftBadge = false,
    this.draftBadgeLetter = 'B',
    this.onTap,
    this.trailing,
  });

  final String startTime;
  final String? timeRange;
  final String title;
  final String? subtitle;
  final String? durationLabel;
  final IconData icon;
  final PlanSummaryTimelinePhase phase;
  final bool isFirst;
  final bool isLast;
  final bool showLineBelow;
  final bool lineBelowDashed;
  final bool showNowLabel;
  final bool showDraftBadge;
  final String draftBadgeLetter;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final accent = AppColorScheme.color2;
    final isCurrent = phase == PlanSummaryTimelinePhase.current;
    final isPast = phase == PlanSummaryTimelinePhase.past;
    final contentOpacity = isPast ? 0.55 : 1.0;
    final lineColor = isPast
        ? accent.withValues(alpha: 0.35)
        : accent.withValues(alpha: 0.55);
    final timeColor = isCurrent
        ? accent
        : (isPast
            ? IosFormColors.textTertiary
            : IosFormColors.textSecondary);
    final hasRange = timeRange != null && timeRange!.trim().isNotEmpty;

    return Opacity(
      opacity: contentOpacity,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 42,
              child: Padding(
                padding: EdgeInsets.only(top: isCurrent ? 16 : 14),
                child: Text(
                  startTime,
                  style: GoogleFonts.poppins(
                    color: timeColor,
                    fontSize: isCurrent ? 12 : 11,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 18,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (!isFirst || showLineBelow)
                    Positioned(
                      top: isFirst ? 22 : 0,
                      bottom: showLineBelow ? 0 : null,
                      height: showLineBelow ? null : 22,
                      child: SizedBox(
                        width: 1.5,
                        child: lineBelowDashed && !isPast
                            ? CustomPaint(
                                painter: _DashedLinePainter(
                                  color: accent.withValues(alpha: 0.4),
                                ),
                              )
                            : ColoredBox(color: lineColor),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: isCurrent ? 12 : 14),
                    child: _TimelineDot(phase: phase, accent: accent),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 6),
                    padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? accent.withValues(alpha: 0.14)
                          : IosFormColors.groupedBg,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent
                          ? Border.all(
                              color: accent.withValues(alpha: 0.65),
                              width: 1.2,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(
                              alpha: isCurrent ? 0.35 : 0.22,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 18, color: accent),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showNowLabel)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    'ahora',
                                    style: GoogleFonts.poppins(
                                      color: accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              if (showDraftBadge)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    draftBadgeLetter,
                                    style: GoogleFonts.poppins(
                                      color: Colors.orange.shade200,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              Text(
                                hasRange ? timeRange! : title,
                                maxLines: hasRange ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: isCurrent
                                      ? accent
                                      : (hasRange
                                          ? IosFormColors.textSecondary
                                          : IosFormColors.textPrimary),
                                  fontSize: hasRange ? 10 : 13,
                                  fontWeight:
                                      hasRange ? FontWeight.w500 : FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              if (hasRange) ...[
                                const SizedBox(height: 2),
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: IosFormColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                              ] else if (subtitle != null &&
                                  subtitle!.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: IosFormColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                              if (durationLabel != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  durationLabel!,
                                  style: GoogleFonts.poppins(
                                    color: accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ] else if (hasRange &&
                                  subtitle != null &&
                                  subtitle!.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: IosFormColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 6),
                          trailing!,
                        ],
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: isCurrent
                              ? accent
                              : IosFormColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Acciones compactas maps / ruta / web (solo icono).
class PlanSummaryTimelineAction extends StatelessWidget {
  const PlanSummaryTimelineAction.route({
    super.key,
    required this.onTap,
  }) : icon = Icons.route;

  const PlanSummaryTimelineAction.maps({
    super.key,
    required this.onTap,
  }) : icon = Icons.place_outlined;

  const PlanSummaryTimelineAction.web({
    super.key,
    required this.onTap,
  }) : icon = Icons.open_in_new;

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: AppColorScheme.color2),
      ),
    );
  }
}

/// Fila «esta noche · hotel» al cierre del día.
class PlanSummaryTimelineNightRow extends StatelessWidget {
  const PlanSummaryTimelineNightRow({
    super.key,
    required this.hotelName,
    this.subtitle,
    this.onTap,
    this.onMaps,
  });

  final String hotelName;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onMaps;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: IosFormColors.groupedBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColorScheme.color2.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'H',
                  style: GoogleFonts.poppins(
                    color: IosFormColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'esta noche · $hotelName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: IosFormColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: IosFormColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onMaps != null)
                IconButton(
                  tooltip: 'maps',
                  onPressed: onMaps,
                  icon: Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: AppColorScheme.color2,
                  ),
                )
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColorScheme.color2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.phase, required this.accent});

  final PlanSummaryTimelinePhase phase;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case PlanSummaryTimelinePhase.current:
        return Container(
          width: 14,
          height: 14,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent, width: 2),
            color: Colors.transparent,
          ),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
        );
      case PlanSummaryTimelinePhase.past:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
        );
      case PlanSummaryTimelinePhase.upcoming:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: IosFormColors.pageBg,
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.7), width: 1.5),
          ),
        );
    }
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0 || !size.height.isFinite) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 4.0;
    const gap = 3.0;
    var y = 0.0;
    final x = size.width / 2;
    while (y < size.height) {
      final y2 = (y + dash).clamp(0.0, size.height);
      canvas.drawLine(Offset(x, y), Offset(x, y2), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
