import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/chat/presentation/providers/chat_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/notifications/wd_notification_badge.dart';
import 'package:unp_calendario/widgets/dialogs/wd_plans_with_unread_chat_modal.dart';

/// Barra lateral izquierda del dashboard (W1: C1, R1–R13).
/// Incluye badge de notificaciones, icono de chat (modal con planes con no leídos) y botón de perfil.
class WdDashboardSidebar extends ConsumerWidget {
  final double columnWidth;
  final double gridHeight;
  final VoidCallback onProfileTap;
  /// Lista de planes del usuario (para modal de chats no leídos y badge global).
  final List<Plan> plans;
  /// Al seleccionar un plan en el modal de chat: abrir ese plan y pestaña chat.
  final void Function(Plan plan)? onOpenChatForPlan;

  const WdDashboardSidebar({
    super.key,
    required this.columnWidth,
    required this.gridHeight,
    required this.onProfileTap,
    this.plans = const [],
    this.onOpenChatForPlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    int totalChatUnread = 0;
    for (final p in plans) {
      if (p.id != null) {
        totalChatUnread += ref.watch(unreadMessagesCountProvider(p.id!)).valueOrNull ?? 0;
      }
    }
    final showChatBadge = totalChatUnread > 0;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NotificationBadge(),
                  if (onOpenChatForPlan != null) ...[
                    const SizedBox(height: 8),
                    Tooltip(
                      message: loc.dashboardTabChat,
                      child: IconButton(
                        icon: Icon(
                          showChatBadge ? Icons.chat_bubble : Icons.chat_bubble_outline,
                          color: showChatBadge ? AppColorScheme.color3 : Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          showPlansWithUnreadChatModal(
                            context: context,
                            plans: plans,
                            onPlanSelected: onOpenChatForPlan!,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
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
