import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/announcement_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

/// Widget para mostrar el timeline de avisos de un plan
class AnnouncementTimeline extends ConsumerWidget {
  final String planId;
  final VoidCallback? onPublishTap;

  const AnnouncementTimeline({
    super.key,
    required this.planId,
    this.onPublishTap,
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

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Hace unos momentos';
        } else {
          return 'Hace ${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''}';
        }
      } else {
        return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      }
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(planAnnouncementsProvider(planId));
    final currentUser = ref.watch(currentUserProvider);
    final participantsAsync = ref.watch(planParticipantsProvider(planId));

    // Obtener mapa de userId -> PlanParticipation para acceder a nombres de usuario
    final participants = participantsAsync.when(
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
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay avisos aún',
                  style: AppTypography.bodyStyle.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sé el primero en publicar un aviso',
                  style: AppTypography.bodyStyle.copyWith(
                    color: Colors.grey.shade500,
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

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: typeColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con usuario y tipo
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            typeIcon,
                            size: 16,
                            color: typeColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authorName,
                            style: AppTypography.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColorScheme.color4,
                            ),
                          ),
                        ),
                        if (announcement.type == 'urgent')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'URGENTE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          )
                        else if (announcement.type == 'important')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'IMPORTANTE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Mensaje
                    Text(
                      announcement.message,
                      style: AppTypography.bodyStyle,
                    ),
                    const SizedBox(height: 12),
                    // Footer con timestamp y opción de eliminar
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatRelativeTime(announcement.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        if (isOwn)
                          TextButton.icon(
                            onPressed: () {
                              _showDeleteConfirmation(context, ref, announcement.id!);
                            },
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Eliminar'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                      ],
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
              'Error al cargar avisos',
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

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String announcementId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Aviso'),
        content: const Text('¿Estás seguro de que deseas eliminar este aviso? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final announcementService = ref.read(announcementServiceProvider);
              final success = await announcementService.deleteAnnouncement(planId, announcementId);
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '✅ Aviso eliminado' : '❌ Error al eliminar'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

