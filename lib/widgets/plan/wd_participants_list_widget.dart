import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';

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

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isOrganizer 
                      ? Colors.blue.shade100 
                      : Colors.green.shade100,
                  child: Icon(
                    isOrganizer ? Icons.admin_panel_settings : Icons.person,
                    color: isOrganizer 
                        ? Colors.blue.shade700 
                        : Colors.green.shade700,
                  ),
                ),
                title: Text(
                  participation.userId, // TODO: Mostrar nombre del usuario
                  style: TextStyle(
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOrganizer ? 'Organizador' : 'Participante',
                      style: TextStyle(
                        color: isOrganizer ? Colors.blue.shade700 : Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Se unió: ${_formatDate(participation.joinedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: showActions && isCurrentUser && isOrganizer
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          _handleMenuAction(context, ref, participation, value);
                        },
                        itemBuilder: (context) => [
                          if (!isOrganizer)
                            const PopupMenuItem(
                              value: 'make_organizer',
                              child: Text('Hacer organizador'),
                            ),
                          if (!isOrganizer)
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
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    PlanParticipation participation,
    String action,
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
