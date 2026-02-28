import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan_state_badge.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/invitation_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/widgets/plan/days_remaining_indicator.dart';
import 'package:unp_calendario/widgets/plan/plan_summary_button.dart';

class PlanCardWidget extends ConsumerWidget {
  final Plan plan;
  final VoidCallback? onTap;
  final bool isSelected;
  final VoidCallback? onDelete;
  /// Si se proporciona, el icono de resumen abre el resumen en el panel (W31) en lugar del diálogo.
  final void Function(Plan plan)? onSummaryInPanel;

  const PlanCardWidget({
    super.key,
    required this.plan,
    this.onTap,
    this.isSelected = false,
    this.onDelete,
    this.onSummaryInPanel,
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

    // T213: card más compacta; mayor contraste cuando está seleccionada
    final textSecondary = isSelected ? Colors.white.withOpacity(0.95) : Colors.grey.shade400;
    final textTertiary = isSelected ? Colors.white.withOpacity(0.85) : Colors.grey.shade500;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColorScheme.color2
            : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: hasPendingInvitation
            ? Border.all(color: Colors.orange.shade400, width: 2)
            : isSelected
                ? Border.all(color: Colors.white.withOpacity(0.25), width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.35 : 0.4),
            blurRadius: isSelected ? 10 : 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                        if (hasPendingInvitation)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade400,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mail_outline, size: 10, color: Colors.white),
                                const SizedBox(width: 2),
                                Text(
                                  'Invitación',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (plan.id != null)
                          PlanSummaryButton(
                            plan: plan,
                            iconOnly: true,
                            foregroundColor: isSelected ? Colors.white : Colors.white70,
                            onShowInPanel: onSummaryInPanel,
                          ),
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
      ),
    );
  }

  String _formatPlanDates() {
    final start = plan.startDate;
    final end = plan.endDate;
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatDate(DateTime date) => DateFormatter.formatDate(date);

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