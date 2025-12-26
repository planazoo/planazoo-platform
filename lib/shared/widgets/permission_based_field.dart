import 'package:flutter/material.dart';
import '../models/permission.dart';
import '../models/plan_permissions.dart';
import '../models/user_role.dart';

/// Widget que muestra un campo de formulario con permisos
class PermissionBasedField extends StatelessWidget {
  final Widget child;
  final Permission requiredPermission;
  final PlanPermissions? userPermissions;
  final bool isOwner;
  final String? tooltipText;
  final Widget? lockedIcon;

  const PermissionBasedField({
    super.key,
    required this.child,
    required this.requiredPermission,
    required this.userPermissions,
    this.isOwner = false,
    this.tooltipText,
    this.lockedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = userPermissions?.hasPermission(requiredPermission) ?? false;
    final canEdit = hasPermission || isOwner;

    if (canEdit) {
      return child;
    }

    return Stack(
      children: [
        // Campo deshabilitado
        Opacity(
          opacity: 0.6,
          child: AbsorbPointer(
            child: child,
          ),
        ),
        
        // Indicador de bloqueo
        Positioned(
          top: 8,
          right: 8,
          child: Tooltip(
            message: tooltipText ?? 'Sin permisos para editar',
            child: lockedIcon ?? 
              const Icon(
                Icons.lock,
                size: 16,
                color: Colors.grey,
              ),
          ),
        ),
      ],
    );
  }
}

/// Widget que muestra un botón con permisos
class PermissionBasedButton extends StatelessWidget {
  final Widget child;
  final Permission requiredPermission;
  final PlanPermissions? userPermissions;
  final bool isOwner;
  final VoidCallback? onPressed;
  final String? tooltipText;

  const PermissionBasedButton({
    super.key,
    required this.child,
    required this.requiredPermission,
    required this.userPermissions,
    this.isOwner = false,
    this.onPressed,
    this.tooltipText,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = userPermissions?.hasPermission(requiredPermission) ?? false;
    final canPress = hasPermission || isOwner;

    if (canPress) {
      return child;
    }

    return Tooltip(
      message: tooltipText ?? 'Sin permisos para esta acción',
      child: Opacity(
        opacity: 0.5,
        child: AbsorbPointer(
          child: child,
        ),
      ),
    );
  }
}

/// Widget que muestra información de permisos
class PermissionInfoWidget extends StatelessWidget {
  final PlanPermissions? userPermissions;
  final String? planId;

  const PermissionInfoWidget({
    super.key,
    this.userPermissions,
    this.planId,
  });

  @override
  Widget build(BuildContext context) {
    if (userPermissions == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getRoleColor(userPermissions!.role).withOpacity(0.1),
        border: Border.all(
          color: _getRoleColor(userPermissions!.role).withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getRoleIcon(userPermissions!.role),
            color: _getRoleColor(userPermissions!.role),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rol: ${userPermissions!.role.displayName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getRoleColor(userPermissions!.role),
                  ),
                ),
                if (userPermissions!.isExpired)
                  const Text(
                    '⚠️ Permisos expirados',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                Text(
                  '${userPermissions!.permissions.length} permisos activos',
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

/// Widget que muestra una lista de permisos por categoría
class PermissionListWidget extends StatelessWidget {
  final PlanPermissions userPermissions;
  final bool showOnlyActive;

  const PermissionListWidget({
    super.key,
    required this.userPermissions,
    this.showOnlyActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final permissionsByCategory = userPermissions.permissionsByCategory;
    
    if (permissionsByCategory.isEmpty) {
      return const Center(
        child: Text('No hay permisos asignados'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: permissionsByCategory.length,
      itemBuilder: (context, index) {
        final category = permissionsByCategory.keys.elementAt(index);
        final permissions = permissionsByCategory[category]!;
        
        return Card(
          child: ExpansionTile(
            title: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: permissions.map((permission) {
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(permission.displayName),
                subtitle: Text(
                  permission.description,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Widget que muestra un campo de texto con indicadores de permisos
class PermissionBasedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final Permission requiredPermission;
  final PlanPermissions? userPermissions;
  final bool isOwner;
  final int? maxLines;
  final IconData? icon;

  const PermissionBasedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.requiredPermission,
    required this.userPermissions,
    this.hintText,
    this.isOwner = false,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = userPermissions?.hasPermission(requiredPermission) ?? false;
    final canEdit = hasPermission || isOwner;

    return TextField(
      controller: controller,
      readOnly: !canEdit,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(
          canEdit ? (icon ?? Icons.edit) : Icons.lock,
          color: canEdit ? Colors.green : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: canEdit ? Colors.green.shade300 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: canEdit ? Colors.green.shade300 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: canEdit ? Colors.green.shade500 : Colors.grey.shade400,
          ),
        ),
        filled: true,
        fillColor: canEdit ? Colors.green.shade50 : Colors.grey.shade50,
      ),
    );
  }
}
