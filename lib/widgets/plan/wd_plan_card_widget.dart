import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
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
import 'package:unp_calendario/widgets/plan/plan_status_chip_actions.dart';

class PlanCardWidget extends ConsumerWidget {
  final Plan plan;
  final VoidCallback? onTap;
  final bool isSelected;
  final VoidCallback? onDelete;
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
                  p.userId == currentUser.id && p.isPending),
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
    final webLight = kIsWeb;

    // W28: iconos de notificaciones y mensajes no leídos por plan
    final notifUnread = plan.id != null
        ? ref.watch(planUnreadCountProvider(plan.id)).valueOrNull ?? 0
        : 0;
    final chatUnread = plan.id != null
        ? ref.watch(unreadMessagesCountProvider(plan.id!)).valueOrNull ?? 0
        : 0;
    final showNotifIcon = notifUnread > 0 && onNotificationsTap != null;
    final showChatIcon = chatUnread > 0 && onChatTap != null;
    final showActionColumn = plan.id != null && (showNotifIcon || showChatIcon);

    // T213: card más compacta; mayor contraste cuando está seleccionada
    final textSecondary = isSelected
        ? Colors.white.withValues(alpha: 0.95)
        : (webLight ? const Color(0xFF475569) : Colors.grey.shade400);
    final textTertiary = isSelected
        ? Colors.white.withValues(alpha: 0.85)
        : (webLight ? const Color(0xFF64748B) : Colors.grey.shade500);
    // §3.2 ítem 62: lista planes en iOS un poco más grande (touch + legibilidad).
    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final cardPadH = isIos ? 20.0 : 16.0;
    final cardPadV = isIos ? 16.0 : 12.0;
    final titleFs = isIos ? 14.0 : 12.0;
    final subtitleFs = isIos ? 11.0 : 10.0;
    final metaFs = isIos ? 10.0 : 9.0;
    final badgeFs = isIos ? 9.0 : 8.0;
    final dividerH = isIos ? 80.0 : 72.0;

    return Container(
      margin: EdgeInsets.only(bottom: webLight ? 8 : 0),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColorScheme.color2
            : (webLight ? Colors.white : Colors.grey.shade900),
        borderRadius: BorderRadius.circular(webLight ? 12 : 0),
        boxShadow: webLight
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        border: hasAnyPending
            ? Border(
                top: BorderSide(color: webLight ? const Color(0xFFF59E0B) : Colors.orange.shade400, width: 2),
                bottom: BorderSide(color: webLight ? const Color(0xFFE2E8F0) : AppColorScheme.color2, width: 1),
              )
            : Border(
                bottom: BorderSide(
                  color: isSelected
                      ? (webLight ? const Color(0xFFD5E2EE) : Colors.white.withValues(alpha: 0.25))
                      : (webLight ? const Color(0xFFE2E8F0) : AppColorScheme.color2),
                  width: 1,
                ),
              ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: cardPadH, vertical: cardPadV),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(webLight ? 12 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildPlanImage(),
                        if (currentUser != null && plan.id != null && (isIn || isPending || isRejected)) ...[
                          const SizedBox(height: 6),
                          _buildInteractiveStatusChip(
                            context,
                            ref,
                            isIn: isIn,
                            isOut: isRejected,
                            isPending: isPending,
                            hasPendingInvitation: hasPendingInvitation,
                            hasPendingParticipation: hasPendingParticipation,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            plan.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: webLight ? const Color(0xFF0F172A) : Colors.white,
                              fontSize: titleFs,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatPlanDates(),
                            style: GoogleFonts.poppins(
                              color: textSecondary,
                              fontSize: subtitleFs,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${plan.columnCount} días',
                            style: GoogleFonts.poppins(
                              color: textTertiary,
                              fontSize: metaFs,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              PlanStateBadgeCompact(
                                plan: plan,
                                fontSize: badgeFs,
                                onColoredBackground: isSelected,
                              ),
                              const SizedBox(width: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.groups_2_outlined,
                                    size: 13,
                                    color: webLight ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$participantsCount',
                                    style: GoogleFonts.poppins(
                                      color: textTertiary,
                                      fontSize: badgeFs,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          DaysRemainingIndicator(
                            plan: plan,
                            fontSize: badgeFs,
                            compact: true,
                            showIcon: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Columna vertical estrecha: iconos resumen, notificaciones, chat
            if (showActionColumn) ...[
                Container(
                  width: 1,
                  height: dividerH,
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  color: (isSelected
                          ? (webLight ? const Color(0xFFB6C7DA) : Colors.white)
                          : (webLight ? const Color(0xFFCBD5E1) : Colors.grey.shade600))
                      .withValues(alpha: 0.35),
                ),
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (showNotifIcon)
                        GestureDetector(
                          onTap: () => onNotificationsTap!(plan),
                          child: Icon(
                            Icons.notifications,
                            size: _badgeIconSize,
                            color: AppColorScheme.color3,
                          ),
                        ),
                      if (showNotifIcon && showChatIcon) const SizedBox(height: 8),
                      if (showChatIcon)
                        GestureDetector(
                          onTap: () => onChatTap!(plan),
                          child: Icon(
                            Icons.chat_bubble,
                            size: _badgeIconSize,
                            color: AppColorScheme.color3,
                          ),
                        ),
                  ],
                ),
                ),
              ],
          ],
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

  Widget _buildStatusChipVisual(
    BuildContext context, {
    required bool isIn,
    required bool isOut,
    required bool isPending,
  }) {
    String label;
    Color bg;
    Color textColor;
    if (isPending) {
      label = '?';
      bg = PlanUserStatusColors.pendingBg;
      textColor = PlanUserStatusColors.pendingText;
    } else if (isOut) {
      label = 'out';
      bg = PlanUserStatusColors.outBg;
      textColor = PlanUserStatusColors.outText;
    } else {
      label = 'in';
      bg = PlanUserStatusColors.inBg;
      textColor = PlanUserStatusColors.inText;
    }
    return Container(
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

  Widget _buildInteractiveStatusChip(
    BuildContext context,
    WidgetRef ref, {
    required bool isIn,
    required bool isOut,
    required bool isPending,
    required bool hasPendingInvitation,
    required bool hasPendingParticipation,
  }) {
    final chip = _buildStatusChipVisual(context, isIn: isIn, isOut: isOut, isPending: isPending);
    final uid = ref.read(currentUserProvider)?.id;
    final pid = plan.id;

    if (isPending && pid != null && uid != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => planStatusChipShowPendingActions(
          context,
          ref,
          planId: pid,
          userId: uid,
          hasPendingInvitation: hasPendingInvitation,
          hasPendingParticipation: hasPendingParticipation,
        ),
        child: chip,
      );
    }

    if (isIn && pid != null && uid != null) {
      final isOrganizer = plan.userId == uid;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isOrganizer) {
            final loc = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.planCardOrganizerChipMessage)),
            );
          } else {
            planStatusChipShowLeavePlan(context, ref, plan: plan, userId: uid);
          }
        },
        child: chip,
      );
    }

    if (isOut && pid != null && uid != null) {
      final loc = AppLocalizations.of(context)!;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.planStatusRejectedSnackbar, style: GoogleFonts.poppins(color: Colors.white)),
              backgroundColor: Colors.grey.shade800,
            ),
          );
        },
        child: chip,
      );
    }

    return chip;
  }

  Widget _buildPlanImage() {
    const double imageSize = 32.0;

    if (plan.imageUrl != null && ImageService.isValidImageUrl(plan.imageUrl)) {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColorScheme.color2.withValues(alpha: 0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: plan.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColorScheme.color2.withValues(alpha: 0.1),
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
          border: Border.all(color: AppColorScheme.color2.withValues(alpha: 0.3)),
        ),
        child: _buildDefaultImage(),
      );
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      color: AppColorScheme.color2.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColorScheme.color2.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }
}