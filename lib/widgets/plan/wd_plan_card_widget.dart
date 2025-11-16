import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan_state_badge.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColorScheme.color1 : AppColorScheme.color0,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? AppColorScheme.color1 : AppColorScheme.color0,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildPlanImage(),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColorScheme.color2,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPlanDates(),
                      style: TextStyle(
                        color: AppColorScheme.color2,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${plan.columnCount} días',
                      style: TextStyle(
                        color: AppColorScheme.color2,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PlanStateBadgeCompact(
                      plan: plan,
                      fontSize: 8,
                    ),
                    const SizedBox(height: 2),
                    DaysRemainingIndicator(
                      plan: plan,
                      fontSize: 8,
                      compact: true,
                      showIcon: false,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Participantes: $participantsCount',
                      style: TextStyle(
                        color: AppColorScheme.color2,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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