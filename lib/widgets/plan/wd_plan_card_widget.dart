import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/features/chat/presentation/providers/chat_providers.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
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

    const cSurfaceBg = Color(0xFF1F2937);
    const cTextPrimary = Colors.white;
    const cTextSecondary = Colors.white70;
    const cTextTertiary = Colors.white60;
    const aBorderStrong = 0.12;
    final hasAnyPending = isPending;

    // W28: iconos de notificaciones y mensajes no leídos por plan
    final notifUnread = plan.id != null
        ? ref.watch(planUnreadCountProvider(plan.id)).valueOrNull ?? 0
        : 0;
    final chatUnread = plan.id != null
        ? ref.watch(unreadMessagesCountProvider(plan.id!)).valueOrNull ?? 0
        : 0;
    final totalUnread = notifUnread + chatUnread;

    // T213: card más compacta; mayor contraste cuando está seleccionada
    final textSecondary = isSelected ? cTextPrimary : cTextSecondary;
    final textTertiary = isSelected ? cTextSecondary : cTextTertiary;
    // §3.2 ítem 62: lista planes en iOS un poco más grande (touch + legibilidad).
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final cardPadH = isIos ? 20.0 : 16.0;
    final cardPadV = isIos ? 16.0 : 12.0;
    final titleFs = isIos ? 15.0 : 14.0;
    final subtitleFs = isIos ? 12.0 : 11.0;
    final metaFs = isIos ? 11.0 : 10.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColorScheme.color2
            : cSurfaceBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: null,
        border: hasAnyPending
            ? Border(
                top: BorderSide(color: Colors.orange.shade400, width: 2),
                bottom: BorderSide(color: cTextPrimary.withValues(alpha: aBorderStrong), width: 1),
              )
            : Border(
                bottom: BorderSide(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : cTextPrimary.withValues(alpha: aBorderStrong),
                  width: 1,
                ),
              ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: cardPadH, vertical: cardPadV),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlanImage(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          plan.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
                          '${plan.columnCount} días · $participantsCount participantes',
                          style: GoogleFonts.poppins(
                            color: textTertiary,
                            fontSize: metaFs,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentUser != null && plan.id != null && (isIn || isPending || isRejected))
                            _buildInteractiveStatusChip(
                              context,
                              ref,
                              isOut: isRejected,
                              isPending: isPending,
                              hasPendingInvitation: hasPendingInvitation,
                              hasPendingParticipation: hasPendingParticipation,
                            ),
                          if (currentUser != null && plan.id != null && (isIn || isPending || isRejected))
                            const SizedBox(width: 6),
                          _buildPlanStateSymbolChip(),
                        ],
                      ),
                      if (totalUnread > 0) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _activityDot(totalUnread),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
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

  Widget _activityDot(int count) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColorScheme.color3,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$count',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChipVisual(
    BuildContext context, {
    required bool isOut,
    required bool isPending,
  }) {
    Color bg;
    Color textColor;
    IconData icon;
    if (isPending) {
      bg = AppColorScheme.color3.withValues(alpha: 0.22);
      textColor = const Color(0xFFFFD9C2);
      icon = Icons.schedule_rounded;
    } else if (isOut) {
      bg = const Color(0xFFB91C1C).withValues(alpha: 0.25);
      textColor = const Color(0xFFFFD4DB);
      icon = Icons.close_rounded;
    } else {
      bg = AppColorScheme.color2;
      textColor = Colors.white;
      icon = Icons.check_rounded;
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: textColor,
      ),
    );
  }

  Widget _buildPlanStateSymbolChip() {
    final state = plan.state ?? 'planificando';
    IconData icon;
    Color bg;
    Color fg;
    switch (state) {
      case 'cancelado':
        icon = Icons.cancel_outlined;
        bg = const Color(0xFFB91C1C).withValues(alpha: 0.28);
        fg = const Color(0xFFFFD4DB);
        break;
      case 'finalizado':
        icon = Icons.check_circle;
        bg = AppColorScheme.color4.withValues(alpha: 0.45);
        fg = Colors.white;
        break;
      case 'en_curso':
        icon = Icons.play_circle_outline;
        bg = AppColorScheme.color3.withValues(alpha: 0.26);
        fg = const Color(0xFFFFE8D2);
        break;
      case 'confirmado':
        icon = Icons.check_circle_outline;
        bg = AppColorScheme.color2;
        fg = Colors.white;
        break;
      case 'planificando':
        icon = Icons.event_note;
        bg = AppColorScheme.color4.withValues(alpha: 0.30);
        fg = Colors.white.withValues(alpha: 0.95);
        break;
      default:
        icon = Icons.help_outline;
        bg = AppColorScheme.color4.withValues(alpha: 0.30);
        fg = Colors.white.withValues(alpha: 0.95);
        break;
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: fg,
      ),
    );
  }

  Widget _buildInteractiveStatusChip(
    BuildContext context,
    WidgetRef ref, {
    required bool isOut,
    required bool isPending,
    required bool hasPendingInvitation,
    required bool hasPendingParticipation,
  }) {
    final chip = _buildStatusChipVisual(context, isOut: isOut, isPending: isPending);
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

    final isIn = !isPending && !isOut;
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
              backgroundColor: const Color(0xFF1F2937),
            ),
          );
        },
        child: chip,
      );
    }

    return chip;
  }

  Widget _buildPlanImage() {
    const double imageSize = 46.0;

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
                  width: 20,
                  height: 20,
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
          size: 24,
        ),
      ),
    );
  }
}