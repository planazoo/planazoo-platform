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
import 'package:unp_calendario/widgets/plan/days_remaining_indicator.dart';

class PlanCardWidget extends ConsumerWidget {
  final Plan plan;
  final VoidCallback? onTap;
  final bool isSelected;
  final VoidCallback? onDelete;

  const PlanCardWidget({
    super.key,
    required this.plan,
    this.onTap,
    this.isSelected = false,
    this.onDelete,
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColorScheme.color2 // Color sólido, sin gradiente
            : Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        // Borde naranja si hay invitación pendiente
        border: hasPendingInvitation
            ? Border.all(
                color: Colors.orange.shade400,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildPlanImage(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasPendingInvitation)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade400,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mail_outline,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Invitación',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPlanDates(),
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${plan.columnCount} días',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    PlanStateBadgeCompact(
                      plan: plan,
                      fontSize: 9,
                    ),
                    const SizedBox(height: 4),
                    DaysRemainingIndicator(
                      plan: plan,
                      fontSize: 9,
                      compact: true,
                      showIcon: false,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Participantes: $participantsCount',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 9,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPlanImage() {
    const double imageSize = 40.0;

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