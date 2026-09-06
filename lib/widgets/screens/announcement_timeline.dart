import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/announcement_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Widget para mostrar el timeline de avisos de un plan
class AnnouncementTimeline extends ConsumerWidget {
  final String planId;
  final VoidCallback? onPublishTap;
  /// En true (p. ej. iOS): fondo oscuro y menos altura por ítem
  final bool compact;

  const AnnouncementTimeline({
    super.key,
    required this.planId,
    this.onPublishTap,
    this.compact = false,
  });

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'urgent':
        return Icons.warning_amber;
      case 'important':
        return Icons.priority_high;
      default:
        return Icons.info_outline;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'urgent':
        return Colors.orange;
      case 'important':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatRelativeTime(DateTime dateTime, AppLocalizations loc) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return loc.timeAgoMoments;
        }
        return loc.timeAgoMinutes(difference.inMinutes);
      }
      return loc.timeAgoHours(difference.inHours);
    }
    if (difference.inDays == 1) {
      return loc.yesterday;
    }
    if (difference.inDays < 7) {
      return loc.timeAgoDays(difference.inDays);
    }
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final announcementsAsync = ref.watch(planAnnouncementsProvider(planId));
    final currentUser = ref.watch(currentUserProvider);
    final participantsAsync = ref.watch(planParticipantsProvider(planId));

    // Obtener mapa de userId -> PlanParticipation para acceder a nombres de usuario
    participantsAsync.when(
      data: (data) => data,
      loading: () => <PlanParticipation>[],
      error: (_, __) => <PlanParticipation>[],
    );

    return announcementsAsync.when(
      data: (announcements) {
        if (announcements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 48,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.announcementsEmpty,
                  style: AppTypography.bodyStyle.copyWith(
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.announcementsEmptyHint,
                  style: AppTypography.bodyStyle.copyWith(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          reverse: false, // Mostrar más recientes arriba
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            final isOwn = currentUser?.id == announcement.userId;
            final typeColor = _getTypeColor(announcement.type);
            final typeIcon = _getTypeIcon(announcement.type);
            
            // Obtener el nombre del usuario del autor usando FutureBuilder
            return FutureBuilder<UserModel?>(
              future: _getUser(announcement.userId, ref),
              builder: (context, userSnapshot) {
                final authorName = userSnapshot.data?.displayIdentifier ?? announcement.userId.substring(0, 8);

            final bgColor = compact ? const Color(0xFF1F2937) : Colors.white;
            final textColor = compact ? Colors.white : AppColorScheme.color4;
            final secondaryColor = compact ? Colors.white70 : Colors.white60;
            final padding = compact ? 10.0 : 16.0;
            final spacing = compact ? 6.0 : 12.0;
            final marginBottom = compact ? 8.0 : 16.0;
            final iconSize = compact ? 14.0 : 16.0;

            return Container(
              margin: EdgeInsets.only(bottom: marginBottom),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(compact ? 10 : 12),
                border: Border.all(
                  color: typeColor.withValues(alpha: compact ? 0.5 : 0.3),
                  width: compact ? 1 : 1.5,
                ),
                boxShadow: compact
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(compact ? 4 : 6),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(compact ? 4 : 6),
                          ),
                          child: Icon(
                            typeIcon,
                            size: iconSize,
                            color: typeColor,
                          ),
                        ),
                        SizedBox(width: compact ? 6 : 8),
                        Expanded(
                          child: Text(
                            authorName,
                            style: AppTypography.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: compact ? 13 : null,
                            ),
                          ),
                        ),
                        Text(
                          _formatRelativeTime(announcement.createdAt, loc),
                          style: TextStyle(
                            fontSize: compact ? 11 : 12,
                            color: secondaryColor,
                          ),
                        ),
                        if (announcement.type == 'urgent') ...[
                          SizedBox(width: compact ? 6 : 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 6 : 8,
                              vertical: compact ? 1 : 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(compact ? 6 : 8),
                            ),
                            child: Text(
                              loc.announcementBadgeUrgent,
                              style: TextStyle(
                                fontSize: compact ? 9 : 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                        if (announcement.type == 'important') ...[
                          SizedBox(width: compact ? 6 : 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 6 : 8,
                              vertical: compact ? 1 : 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(compact ? 6 : 8),
                            ),
                            child: Text(
                              loc.announcementBadgeImportant,
                              style: TextStyle(
                                fontSize: compact ? 9 : 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: spacing),
                    Text(
                      announcement.message,
                      style: AppTypography.bodyStyle.copyWith(
                        color: textColor,
                        fontSize: compact ? 13 : null,
                      ),
                      maxLines: compact ? 3 : null,
                      overflow: compact ? TextOverflow.ellipsis : null,
                    ),
                    if (isOwn)
                      Padding(
                        padding: EdgeInsets.only(top: compact ? 4 : 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _showDeleteConfirmation(context, ref, announcement.id!);
                              },
                              icon: Icon(Icons.delete_outline, size: compact ? 14 : 16),
                              label: Text(loc.delete, style: TextStyle(fontSize: compact ? 12 : null)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8),
                                minimumSize: Size(0, compact ? 28 : 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              loc.announcementsLoadError,
              style: AppTypography.bodyStyle.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserModel?> _getUser(String userId, WidgetRef ref) async {
    try {
      final userService = ref.read(userServiceProvider);
      return await userService.getUser(userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String announcementId,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await IosFormConfirmSheet.show(
      context: context,
      title: loc.deleteAnnouncementTitle,
      message: loc.deleteAnnouncementConfirm,
      cancelLabel: loc.cancel,
      confirmLabel: loc.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final announcementService = ref.read(announcementServiceProvider);
    final success = await announcementService.deleteAnnouncement(planId, announcementId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? loc.announcementDeleted : loc.announcementDeleteError),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}

