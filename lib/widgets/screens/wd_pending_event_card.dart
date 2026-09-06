import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/pending_email_event.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';

export 'package:unp_calendario/widgets/screens/wd_place_communication_flow.dart' show PendingEmailEventActions;

/// Tarjeta reutilizable para un mail sin colocar. Usada en buzón y en notificaciones.
class WdPendingEventCard extends StatelessWidget {
  final PendingEmailEvent pending;
  final String userId;
  final VoidCallback onAssign;
  final VoidCallback onDiscard;
  final VoidCallback? onTap;
  /// Si true, reduce padding y tamaños para lista de notificaciones general.
  final bool compact;

  const WdPendingEventCard({
    super.key,
    required this.pending,
    required this.userId,
    required this.onAssign,
    required this.onDiscard,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final margin = compact ? const EdgeInsets.only(bottom: 6) : const EdgeInsets.only(bottom: 12);
    final padding = compact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8) : const EdgeInsets.all(16.0);
    final titleStyle = compact
        ? AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.w600, color: AppColorScheme.color1, fontSize: 12)
        : AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.w600, color: AppColorScheme.color1);
    final captionStyle = compact
        ? AppTypography.caption.copyWith(color: AppColorScheme.color4, fontSize: 11)
        : AppTypography.caption.copyWith(color: AppColorScheme.color4);
    final spacing = compact ? 6.0 : 12.0;

    return Card(
      margin: margin,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pending.displayTitle, style: titleStyle),
              SizedBox(height: compact ? 2 : 4),
              if (pending.kind == 'manual')
                Text(loc.communicationKindManual, style: captionStyle)
              else if (pending.fromEmail != null && pending.fromEmail!.isNotEmpty)
                Text(pending.fromEmail!, style: captionStyle),
              if (pending.createdAt != null)
                Text(DateFormatter.formatDateTime(pending.createdAt!), style: captionStyle),
              if (pending.attachments.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.attach_file, size: compact ? 12 : 14, color: captionStyle.color),
                    const SizedBox(width: 4),
                    Text('${pending.attachments.length}', style: captionStyle),
                  ],
                ),
              SizedBox(height: spacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onDiscard,
                    style: compact
                        ? TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          )
                        : null,
                    child: Text(loc.pendingEventsDiscard, style: compact ? captionStyle : null),
                  ),
                  SizedBox(width: compact ? 6 : 8),
                  FilledButton(
                    onPressed: onAssign,
                    style: compact
                        ? FilledButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          )
                        : null,
                    child: Text(loc.pendingEventsAssignToPlan, style: compact ? captionStyle : null),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
