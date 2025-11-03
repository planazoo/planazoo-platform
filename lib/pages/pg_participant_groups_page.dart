import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_group.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/participant_group_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/widgets/dialogs/group_edit_dialog.dart';

/// T123: Página para gestionar grupos de participantes
class ParticipantGroupsPage extends ConsumerWidget {
  const ParticipantGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Grupos de Participantes'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Debes iniciar sesión para gestionar grupos'),
        ),
      );
    }

    final groupsAsync = ref.watch(userGroupsStreamProvider(currentUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos de Participantes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showCreateGroupDialog(context, ref, currentUser.id),
            icon: const Icon(Icons.add),
            tooltip: 'Crear grupo',
          ),
        ],
      ),
      body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes grupos creados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea un grupo para invitar múltiples personas a la vez',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateGroupDialog(context, ref, currentUser.id),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primer grupo'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _buildGroupCard(context, ref, group);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar grupos',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, WidgetRef ref, ParticipantGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description != null && group.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  group.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${group.totalMembers} miembro${group.totalMembers != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditGroupDialog(context, ref, group);
            } else if (value == 'delete') {
              _showDeleteConfirmation(context, ref, group);
            }
          },
        ),
        onTap: () => _showEditGroupDialog(context, ref, group),
      ),
    );
  }

  Color _getGroupColor(ParticipantGroup group) {
    if (group.color != null) {
      // Intentar parsear el color desde un string
      // Por simplicidad, usar colores predefinidos
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

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (context) => GroupEditDialog(
        group: null,
        userId: userId,
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, WidgetRef ref, ParticipantGroup group) {
    showDialog(
      context: context,
      builder: (context) => GroupEditDialog(
        group: group,
        userId: group.userId,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ParticipantGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text('¿Estás seguro de que quieres eliminar el grupo "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final groupService = ref.read(participantGroupServiceProvider);
              final success = await groupService.deleteGroup(group.id!);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Grupo eliminado exitosamente' 
                        : 'Error al eliminar el grupo',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

