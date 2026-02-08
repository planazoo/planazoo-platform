import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/notifications/wd_notification_badge.dart';

/// Barra lateral izquierda del dashboard (W1: C1, R1–R13).
/// Incluye badge de notificaciones y botón de perfil.
class WdDashboardSidebar extends ConsumerWidget {
  final double columnWidth;
  final double gridHeight;
  final VoidCallback onProfileTap;

  const WdDashboardSidebar({
    super.key,
    required this.columnWidth,
    required this.gridHeight,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        width: columnWidth,
        height: gridHeight,
        decoration: const BoxDecoration(
          color: AppColorScheme.color2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: NotificationBadge(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Tooltip(
                message: loc.profileTooltip,
                child: GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
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
