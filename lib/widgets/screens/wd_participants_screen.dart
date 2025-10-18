import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';

class ParticipantsScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onBack;

  const ParticipantsScreen({
    super.key,
    required this.plan,
    this.onBack,
  });

  @override
  ConsumerState<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends ConsumerState<ParticipantsScreen> {
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoadingUsers = true;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final userService = ref.read(userServiceProvider);
      final users = await userService.getAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      LoggerService.error('Error loading users', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = (user.displayName ?? '').toLowerCase();
          final email = user.email.toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _inviteUser(UserModel user) async {
    try {
      final participationService = ref.read(planParticipationServiceProvider);
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await participationService.createParticipation(
        planId: widget.plan.id!,
        userId: user.id,
        role: 'participant',
        invitedBy: currentUser.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${user.displayName ?? user.email} invitado al plan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Error inviting user', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al invitar usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeParticipant(PlanParticipation participation) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar a este participante del plan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final participationService = ref.read(planParticipationServiceProvider);
        await participationService.removeParticipation(widget.plan.id!, participation.userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Participante eliminado del plan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error('Error removing participant', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar participante: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeRole(PlanParticipation participation, String newRole) async {
    try {
      final participationService = ref.read(planParticipationServiceProvider);
      await participationService.updateParticipation(
        participation.copyWith(role: newRole),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Rol actualizado a $newRole'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Error updating role', context: 'ParticipantsScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar rol: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildParticipantsList() {
    return Consumer(
      builder: (context, ref, child) {
        final participantsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));
        
        return participantsAsync.when(
          data: (participations) => _buildParticipantsContent(participations),
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando participantes...'),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error al cargar participantes: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(planParticipantsProvider(widget.plan.id!));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticipantsContent(List<PlanParticipation> participations) {
    if (participations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay participantes en este plan',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: participations.length,
      itemBuilder: (context, index) {
        final participation = participations[index];
        return _buildParticipantCard(participation);
      },
    );
  }

  Widget _buildParticipantCard(PlanParticipation participation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: _getRoleColor(participation.role),
              child: Text(
                _getInitials(participation.userId),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Información del participante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participation.userId,
                    style: AppTypography.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(participation.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getRoleLabel(participation.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Se unió: ${_formatDate(participation.joinedAt)}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botones de acción
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'change_role':
                    _showRoleChangeDialog(participation);
                    break;
                  case 'remove':
                    _removeParticipant(participation);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'change_role',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Cambiar rol'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleChangeDialog(PlanParticipation participation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar rol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selecciona un nuevo rol para ${participation.userId}:'),
            const SizedBox(height: 16),
            _buildRoleOption(participation, 'organizer', 'Organizador'),
            _buildRoleOption(participation, 'participant', 'Participante'),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(PlanParticipation participation, String role, String label) {
    final isSelected = participation.role == role;
    
    return ListTile(
      leading: Radio<String>(
        value: role,
        groupValue: participation.role,
        onChanged: (value) {
          Navigator.of(context).pop();
          _changeRole(participation, value!);
        },
      ),
      title: Text(label),
      subtitle: Text(_getRoleDescription(role)),
    );
  }

  Widget _buildInviteUsersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorScheme.color0,
        border: Border(
          bottom: BorderSide(color: AppColorScheme.color2, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invitar usuarios',
                style: AppTypography.titleStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Campo de búsqueda
          TextField(
            onChanged: _filterUsers,
            decoration: InputDecoration(
              hintText: 'Buscar usuarios por nombre o email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de usuarios filtrados
          if (_isLoadingUsers)
            const Center(child: CircularProgressIndicator())
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty 
                            ? 'No hay usuarios disponibles'
                            : 'No se encontraron usuarios',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColorScheme.color2,
                            child: Text(
                              _getInitials(user.id),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(user.displayName ?? user.email),
                          subtitle: Text(user.email),
                          trailing: ElevatedButton(
                            onPressed: () => _inviteUser(user),
                            child: const Text('Invitar'),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'organizer':
        return Colors.purple;
      case 'participant':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'organizer':
        return 'Organizador';
      case 'participant':
        return 'Participante';
      default:
        return 'Desconocido';
    }
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'organizer':
        return 'Puede editar el plan y gestionar participantes';
      case 'participant':
        return 'Puede ver y participar en el plan';
      default:
        return '';
    }
  }

  String _getInitials(String userId) {
    if (userId.isEmpty) return '?';
    return userId.substring(0, 1).toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInviteUsersSection(),
        Expanded(
          child: _buildParticipantsList(),
        ),
      ],
    );
  }
}
