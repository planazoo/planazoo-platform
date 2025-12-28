import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/shared/models/user_role.dart';
import 'package:unp_calendario/shared/models/permission.dart';
import 'package:unp_calendario/shared/models/plan_permissions.dart';
import 'package:unp_calendario/shared/services/permission_service.dart';

/// Diálogo para gestionar roles y permisos de usuarios en un plan
class ManageRolesDialog extends ConsumerStatefulWidget {
  final String planId;
  final String currentUserId;
  final Function()? onRolesChanged;

  const ManageRolesDialog({
    super.key,
    required this.planId,
    required this.currentUserId,
    this.onRolesChanged,
  });

  @override
  ConsumerState<ManageRolesDialog> createState() => _ManageRolesDialogState();
}

class _ManageRolesDialogState extends ConsumerState<ManageRolesDialog> {
  final PermissionService _permissionService = PermissionService();
  
  List<PlanPermissions> _allUsers = [];
  bool _isLoading = true;
  PlanPermissions? _currentUserPermissions;

  @override
  void initState() {
    super.initState();
    _loadUsersAndPermissions();
  }

  Future<void> _loadUsersAndPermissions() async {
    try {
      // Obtener todos los usuarios del plan
      _allUsers = await _permissionService.getPlanUsers(widget.planId);
      
      // Obtener permisos del usuario actual
      _currentUserPermissions = await _permissionService.getUserPermissions(
        widget.planId,
        widget.currentUserId,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: Colors.red),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Gestión de Roles',
              style: TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 600,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // Verificar si el usuario actual puede gestionar roles
    final canManageRoles = _currentUserPermissions?.hasPermission(Permission.planManageAdmins) ?? false;
    
    if (!canManageRoles) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes permisos para gestionar roles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Información del usuario actual
        _buildCurrentUserInfo(),
        
        const SizedBox(height: 16),
        
        // Lista de usuarios
        Expanded(
          child: _buildUsersList(),
        ),
        
        const SizedBox(height: 16),
        
        // Estadísticas
        _buildStats(),
      ],
    );
  }

  Widget _buildCurrentUserInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getRoleColor(_currentUserPermissions?.role ?? UserRole.observer).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getRoleColor(_currentUserPermissions?.role ?? UserRole.observer).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getRoleIcon(_currentUserPermissions?.role ?? UserRole.observer),
            color: _getRoleColor(_currentUserPermissions?.role ?? UserRole.observer),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu rol: ${_currentUserPermissions?.role.displayName ?? "Desconocido"}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_currentUserPermissions?.permissions.length ?? 0} permisos activos',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_allUsers.isEmpty) {
      return const Center(
        child: Text('No hay usuarios en este plan'),
      );
    }

    return ListView.builder(
      itemCount: _allUsers.length,
      itemBuilder: (context, index) {
        final user = _allUsers[index];
        final isCurrentUser = user.userId == widget.currentUserId;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
              child: Icon(
                _getRoleIcon(user.role),
                color: _getRoleColor(user.role),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    _getUserDisplayName(user.userId),
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TÚ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rol: ${user.role.displayName}'),
                Text(
                  '${user.permissions.length} permisos • Asignado: ${_formatDate(user.assignedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (user.isExpired)
                  const Text(
                    '⚠️ Permisos expirados',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
              ],
            ),
            trailing: isCurrentUser
                ? const Icon(Icons.person, color: Colors.blue)
                : PopupMenuButton<UserRole>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (newRole) => _changeUserRole(user.userId, newRole),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: UserRole.admin,
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Administrador'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: UserRole.participant,
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Participante'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: UserRole.observer,
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Observador'),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildStats() {
    final adminCount = _allUsers.where((u) => u.role == UserRole.admin).length;
    final participantCount = _allUsers.where((u) => u.role == UserRole.participant).length;
    final observerCount = _allUsers.where((u) => u.role == UserRole.observer).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Admins', adminCount, Colors.red),
          _buildStatItem('Participantes', participantCount, Colors.blue),
          _buildStatItem('Observadores', observerCount, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _changeUserRole(String userId, UserRole newRole) async {
    try {
      // Validaciones
      if (newRole == UserRole.admin) {
        final currentAdminCount = _allUsers.where((u) => u.role == UserRole.admin).length;
        if (currentAdminCount >= 3) {
          _showError('No se pueden tener más de 3 administradores');
          return;
        }
      }

      final success = await _permissionService.updateUserRole(
        planId: widget.planId,
        userId: userId,
        newRole: newRole,
        updatedBy: widget.currentUserId,
      );

      if (success) {
        // Recargar la lista
        await _loadUsersAndPermissions();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol cambiado a ${newRole.displayName}'),
            backgroundColor: Colors.green,
          ),
        );

        // Notificar cambio
        widget.onRolesChanged?.call();
      } else {
        _showError('Error al cambiar el rol');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getUserDisplayName(String userId) {
    try {
      // Mapeo simple de IDs a nombres para testing
      final nameMap = {
        'cristian_claraso': 'Cristian Claraso',
        'maria_del_mar': 'María del Mar',
        'emma': 'Emma',
        'matilde': 'Matilde',
        'jimena': 'Jimena',
      };
      return nameMap[userId] ?? 'Usuario $userId';
    } catch (e) {
      return 'Usuario $userId';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.participant:
        return Colors.blue;
      case UserRole.observer:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.participant:
        return Icons.person;
      case UserRole.observer:
        return Icons.visibility;
    }
  }
}
