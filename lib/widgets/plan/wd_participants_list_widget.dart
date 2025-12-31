import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';

class ParticipantsListWidget extends ConsumerWidget {
  final String planId;
  final bool showActions;

  const ParticipantsListWidget({
    super.key,
    required this.planId,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(planParticipantsProvider(planId));
    final currentUser = ref.watch(currentUserProvider);
    final planAsync = ref.watch(planByIdStreamProvider(planId));
    final userService = ref.watch(userServiceProvider);

    return planAsync.when(
      data: (plan) {
        return participantsAsync.when(
      data: (participations) {
        if (participations.isEmpty) {
          return const Center(
            child: Text(
              'No hay participantes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: participations.length,
          itemBuilder: (context, index) {
            final participation = participations[index];
            final isCurrentUser = participation.userId == currentUser?.id;
            final isOrganizer = participation.isOrganizer;

            return FutureBuilder(
              future: userService.getUser(participation.userId),
              builder: (context, snapshot) {
                final user = snapshot.data;
                final displayName = user?.displayName ?? participation.userId;
                final username = user?.username != null ? '@${user!.username}' : participation.userId;

                final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                final textColor = isDarkMode ? Colors.white : Colors.grey.shade900;
                final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isOrganizer
                          ? (isDarkMode ? Colors.blue.shade800 : Colors.blue.shade100)
                          : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
                      child: Icon(
                        isOrganizer ? Icons.admin_panel_settings : Icons.person,
                        color: isOrganizer
                            ? (isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700)
                            : (isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
                        size: 18,
                      ),
                      radius: 18,
                    ),
                    title: Text(
                      '$displayName $username',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    trailing: showActions && isCurrentUser && isOrganizer && plan != null
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              _handleMenuAction(context, ref, participation, value, plan);
                            },
                            itemBuilder: (context) => [
                              if (!isOrganizer)
                                const PopupMenuItem(
                                  value: 'make_organizer',
                                  child: Text('Hacer organizador'),
                                ),
                              if (!isOrganizer &&
                                  PlanStatePermissions.canRemoveParticipants(plan))
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remover'),
                                ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            );
          },
        );
      },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error al cargar participantes: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error al cargar plan: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    PlanParticipation participation,
    String action,
    Plan plan, // T109: Plan para verificar estado
  ) {
    final notifier = ref.read(planParticipationNotifierProvider(planId).notifier);

    switch (action) {
      case 'make_organizer':
        _showConfirmDialog(
          context,
          'Hacer organizador',
          '¿Estás seguro de que quieres hacer organizador a este usuario?',
          () async {
            final success = await notifier.changeParticipantRole(
              planId,
              participation.userId,
              'organizer',
            );
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario promovido a organizador')),
              );
            }
          },
        );
        break;
      case 'remove':
        // T109: Verificar si se puede remover participantes según el estado del plan
        if (!PlanStatePermissions.canRemoveParticipants(plan)) {
          final blockedReason = PlanStatePermissions.getBlockedReason('remove_participants', plan);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(blockedReason ?? 'No se pueden remover participantes en el estado actual del plan.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
        
        _showConfirmDialog(
          context,
          'Remover participante',
          '¿Estás seguro de que quieres remover a este usuario del plan?',
          () async {
            final success = await notifier.removeUserFromPlan(
              planId,
              participation.userId,
            );
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario removido del plan')),
              );
            }
          },
        );
        break;
    }
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
