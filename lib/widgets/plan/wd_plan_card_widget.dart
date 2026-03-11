import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan_state_badge.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_user_status_label.dart';
import 'package:unp_calendario/features/chat/presentation/providers/chat_providers.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/widgets/plan/days_remaining_indicator.dart';
import 'package:unp_calendario/widgets/plan/plan_summary_button.dart';

class PlanCardWidget extends ConsumerWidget {
  final Plan plan;
  final VoidCallback? onTap;
  final bool isSelected;
  final VoidCallback? onDelete;
  /// Si se proporciona, el icono de resumen abre la página de resumen (no el diálogo generador).
  final void Function(Plan plan)? onSummaryInPanel;
  /// Al clic en icono notificaciones: abrir página de notificaciones del plan.
  final void Function(Plan plan)? onNotificationsTap;
  /// Al clic en icono chat: abrir página de chat del plan.
  final void Function(Plan plan)? onChatTap;

  const PlanCardWidget({
    super.key,
    required this.plan,
    this.onTap,
    this.isSelected = false,
    this.onDelete,
    this.onSummaryInPanel,
    this.onNotificationsTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsCount = plan.id != null
        ? ref.watch(planRealParticipantsProvider(plan.id!)).maybeWhen(
              data: (list) => list.length,
              orElse: () => plan.participants ?? 0,
            )
        : plan.participants ?? 0;

    // Verificar si hay invitación pendiente para este plan
    final pendingInvitationsAsync = ref.watch(userPendingInvitationsProvider);
    final hasPendingInvitation = pendingInvitationsAsync.maybeWhen(
      data: (invitations) => plan.id != null && invitations.any((inv) => inv.planId == plan.id),
      orElse: () => false,
    );

    // Participación pendiente o rechazada (invitación directa)
    final currentUser = ref.watch(currentUserProvider);
    final participantsAsync = plan.id != null ? ref.watch(planParticipantsProvider(plan.id!)) : const AsyncValue.data([]);
    final hasPendingParticipation = plan.id != null &&
        currentUser != null &&
        participantsAsync.maybeWhen(
              data: (participants) => participants.any((p) =>
                  p.userId == currentUser.id && (p.isPending || p.needsResponse)),
              orElse: () => false,
            );
    final hasRejectedParticipation = plan.id != null &&
        currentUser != null &&
        participantsAsync.maybeWhen(
              data: (participants) => participants.any((p) => p.userId == currentUser.id && p.isRejected),
              orElse: () => false,
            );

    // Estado usuario en el plan: in (verde), out (rojo), pending (naranja)
    final isPending = hasPendingInvitation || hasPendingParticipation;
    final isRejected = hasRejectedParticipation;
    final isIn = currentUser != null && !isPending && !isRejected &&
        (plan.userId == currentUser.id ||
            participantsAsync.maybeWhen(
                  data: (participants) => participants.any((p) => p.userId == currentUser.id && p.isAccepted),
                  orElse: () => false,
                ));

    final hasAnyPending = isPending;

    // W28: iconos de notificaciones y mensajes no leídos por plan
    final notifUnread = plan.id != null
        ? ref.watch(planUnreadCountProvider(plan.id)).valueOrNull ?? 0
        : 0;
    final chatUnread = plan.id != null
        ? ref.watch(unreadMessagesCountProvider(plan.id!)).valueOrNull ?? 0
        : 0;

    // T213: card más compacta; mayor contraste cuando está seleccionada
    final textSecondary = isSelected ? Colors.white.withOpacity(0.95) : Colors.grey.shade400;
    final textTertiary = isSelected ? Colors.white.withOpacity(0.85) : Colors.grey.shade500;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColorScheme.color2
            : Colors.grey.shade900,
        borderRadius: BorderRadius.zero,
        border: hasAnyPending
            ? Border(
                top: BorderSide(color: Colors.orange.shade400, width: 2),
                bottom: BorderSide(color: AppColorScheme.color2, width: 1),
              )
            : Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.white.withOpacity(0.25) : AppColorScheme.color2,
                  width: 1,
                ),
              ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zona principal: imagen + nombre, fechas, estado, participantes
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanImage(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  plan.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Estado en el plan: in (verde) / out (rojo) / pending (naranja)
                              if (currentUser != null && plan.id != null && (isIn || isPending || isRejected))
                                _buildStatusChip(context, isIn: isIn, isOut: isRejected, isPending: isPending),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatPlanDates(),
                            style: GoogleFonts.poppins(
                              color: textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${plan.columnCount} días',
                            style: GoogleFonts.poppins(
                              color: textTertiary,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          PlanStateBadgeCompact(
                            plan: plan,
                            fontSize: 8,
                            onColoredBackground: isSelected,
                          ),
                          const SizedBox(height: 2),
                          DaysRemainingIndicator(
                            plan: plan,
                            fontSize: 8,
                            compact: true,
                            showIcon: false,
                          ),
                          Text(
                            'Participantes: $participantsCount',
                            style: GoogleFonts.poppins(
                              color: textTertiary,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Columna vertical estrecha: iconos resumen, notificaciones, chat
              if (plan.id != null) ...[
                Container(
                  width: 1,
                  height: 40,
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  color: (isSelected ? Colors.white : Colors.grey.shade600).withOpacity(0.3),
                ),
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlanSummaryButton(
                      plan: plan,
                      iconOnly: true,
                      foregroundColor: isSelected ? Colors.white : Colors.white70,
                      onShowInPanel: onSummaryInPanel,
                    ),
                    GestureDetector(
                      onTap: onNotificationsTap != null ? () => onNotificationsTap!(plan) : null,
                      child: _buildBadgeIcon(
                        icon: notifUnread > 0 ? Icons.notifications : Icons.notifications_outlined,
                        hasUnread: notifUnread > 0,
                        isSelected: isSelected,
                      ),
                    ),
                    GestureDetector(
                      onTap: onChatTap != null ? () => onChatTap!(plan) : null,
                      child: _buildBadgeIcon(
                        icon: chatUnread > 0 ? Icons.chat_bubble : Icons.chat_bubble_outline,
                        hasUnread: chatUnread > 0,
                        isSelected: isSelected,
                      ),
                    ),
                  ],
                ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatPlanDates() {
    final start = plan.startDate;
    final end = plan.endDate;
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatDate(DateTime date) => DateFormatter.formatDate(date);

  static const double _badgeIconSize = 20.0;

  Widget _buildBadgeIcon({
    required IconData icon,
    required bool hasUnread,
    required bool isSelected,
  }) {
    final color = hasUnread
        ? AppColorScheme.color3
        : (isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade400);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Icon(icon, size: _badgeIconSize, color: color),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required bool isIn,
    required bool isOut,
    required bool isPending,
  }) {
    final loc = AppLocalizations.of(context)!;
    String label;
    Color bg;
    Color textColor;
    if (isPending) {
      label = loc.statusShortPending;
      bg = PlanUserStatusColors.pendingBg;
      textColor = PlanUserStatusColors.pendingText;
    } else if (isOut) {
      label = loc.statusShortOut;
      bg = PlanUserStatusColors.outBg;
      textColor = PlanUserStatusColors.outText;
    } else {
      label = loc.statusShortIn;
      bg = PlanUserStatusColors.inBg;
      textColor = PlanUserStatusColors.inText;
    }
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPending ? PlanUserStatusColors.pendingBorder : isOut ? PlanUserStatusColors.outBorder : PlanUserStatusColors.inBorder,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPlanImage() {
    const double imageSize = 32.0;

    if (plan.imageUrl != null && ImageService.isValidImageUrl(plan.imageUrl)) {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColorScheme.color2.withOpacity(0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: plan.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColorScheme.color2.withOpacity(0.1),
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildDefaultImage(),
          ),
        ),
      );
    } else {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColorScheme.color2.withOpacity(0.3)),
        ),
        child: _buildDefaultImage(),
      );
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      color: AppColorScheme.color2.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColorScheme.color2.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }
}