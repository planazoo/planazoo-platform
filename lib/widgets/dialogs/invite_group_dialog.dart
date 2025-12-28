import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_group.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/participant_group_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';

/// T123: Diálogo para invitar un grupo completo a un plan
class InviteGroupDialog extends ConsumerWidget {
  final String planId;
  final String userId;

  const InviteGroupDialog({
    super.key,
    required this.planId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(userGroupsStreamProvider(userId));

    return AlertDialog(
      title: const Text('Invitar Grupo'),
      content: SizedBox(
        width: 400,
        child: groupsAsync.when(
          data: (groups) {
            if (groups.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_add, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes grupos creados',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crea un grupo primero para poder invitarlo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona un grupo para invitar:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      if (group.isEmpty) return const SizedBox.shrink();
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getGroupColor(group),
                            child: Text(
                              group.icon ?? group.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            group.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${group.totalMembers} miembro${group.totalMembers != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _inviteGroup(context, ref, group),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar grupos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Color _getGroupColor(ParticipantGroup group) {
    if (group.color != null) {
      final colorMap = {
        'blue': Colors.blue,
        'green': Colors.green,
        'orange': Colors.orange,
        'purple': Colors.purple,
        'red': Colors.red,
        'teal': Colors.teal,
        'indigo': Colors.indigo,
        'pink': Colors.pink,
      };
      return colorMap[group.color] ?? Colors.blue;
    }
    return Colors.blue;
  }

  Future<void> _inviteGroup(
    BuildContext context,
    WidgetRef ref,
    ParticipantGroup group,
  ) async {
    // Confirmar invitación del grupo
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invitar Grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Invitar a todos los miembros de "${group.name}"?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Se enviarán invitaciones a:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            if (group.memberUserIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• ${group.memberUserIds.length} usuario${group.memberUserIds.length != 1 ? 's' : ''} registrado${group.memberUserIds.length != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            if (group.memberEmails.isNotEmpty)
              Text(
                '• ${group.memberEmails.length} email${group.memberEmails.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Invitar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Invitar a cada miembro
    final notifier = ref.read(planParticipationNotifierProvider(planId).notifier);
    final currentUser = ref.read(currentUserProvider);
    int successCount = 0;
    int errorCount = 0;

    // Mostrar indicador de progreso
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Enviando invitaciones...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Invitar usuarios por ID
    for (final userId in group.memberUserIds) {
      try {
        final success = await notifier.inviteUserToPlan(
          planId,
          userId,
          invitedBy: currentUser?.id,
        );
        if (success) {
          successCount++;
        } else {
          errorCount++;
        }
      } catch (e) {
        errorCount++;
      }
    }

    // Invitar usuarios por email
    for (final email in group.memberEmails) {
      try {
        final success = await notifier.inviteUserToPlan(
          planId,
          email,
          invitedBy: currentUser?.id,
        );
        if (success) {
          successCount++;
        } else {
          errorCount++;
        }
      } catch (e) {
        errorCount++;
      }
    }

    // Cerrar diálogo de progreso
    if (context.mounted) {
      Navigator.of(context).pop(); // Cerrar diálogo de progreso
      Navigator.of(context).pop(); // Cerrar diálogo de selección de grupo

      // Mostrar resultado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invitaciones enviadas: $successCount exitosas${errorCount > 0 ? ', $errorCount errores' : ''}',
          ),
          backgroundColor: errorCount == 0 ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

