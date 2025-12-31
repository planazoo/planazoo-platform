import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';

/// Widget para seleccionar la perspectiva del usuario en el calendario
class UserPerspectiveSelector extends StatelessWidget {
  final List<PlanParticipation> participations;
  final String? selectedUserId;
  final Function(String userId) onUserSelected;
  final String? currentTimezone;

  const UserPerspectiveSelector({
    Key? key,
    required this.participations,
    required this.selectedUserId,
    required this.onUserSelected,
    this.currentTimezone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: _buildSelectorIcon(),
      tooltip: 'Cambiar perspectiva de usuario',
      onSelected: onUserSelected,
      itemBuilder: (context) => _buildMenuItems(),
    );
  }

  /// Construye el icono del selector
  Widget _buildSelectorIcon() {
    final selectedParticipation = participations.firstWhere(
      (p) => p.userId == selectedUserId,
      orElse: () => participations.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: FutureBuilder<String>(
        future: _getUserDisplayName(selectedParticipation),
        builder: (context, snapshot) {
          final displayName = snapshot.data ?? selectedParticipation.userId;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(selectedParticipation.role),
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (currentTimezone != null) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.access_time,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  _getTimezoneDisplay(currentTimezone!),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 16,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Construye los elementos del menú
  List<PopupMenuEntry<String>> _buildMenuItems() {
    return participations.map((participation) {
      return PopupMenuItem<String>(
        value: participation.userId,
        child: FutureBuilder<String>(
          future: _getUserDisplayName(participation),
          builder: (context, snapshot) {
            final displayName = snapshot.data ?? participation.userId;
            return Row(
              children: [
                Icon(
                  _getRoleIcon(participation.role),
                  color: _getRoleColor(participation.role),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (participation.personalTimezone != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _getTimezoneDisplay(participation.personalTimezone!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      Text(
                        _getRoleDisplayName(participation.role),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getRoleColor(participation.role),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (participation.userId == selectedUserId)
                  const Icon(
                    Icons.check,
                    color: Colors.blue,
                    size: 20,
                  ),
              ],
            );
          },
        ),
      );
    }).toList();
  }

  /// Obtiene el icono según el rol
  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'organizer':
        return Icons.admin_panel_settings;
      case 'participant':
        return Icons.person;
      case 'observer':
        return Icons.visibility;
      default:
        return Icons.person;
    }
  }

  /// Obtiene el color según el rol
  Color _getRoleColor(String role) {
    switch (role) {
      case 'organizer':
        return Colors.orange;
      case 'participant':
        return Colors.blue;
      case 'observer':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Obtiene el nombre de display del usuario
  Future<String> _getUserDisplayName(PlanParticipation participation) async {
    try {
      // Obtener el usuario real desde Firestore usando UserService
      final userService = UserService();
      final user = await userService.getUser(participation.userId);
      
      if (user != null) {
        // Priorizar displayName, luego username, luego email
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
          return user.displayName!;
        }
        if (user.username != null && user.username!.trim().isNotEmpty) {
          return '@${user.username!}';
        }
        return user.email;
      }
      
      // Si no se encuentra el usuario, devolver el userId como fallback
      return participation.userId;
    } catch (e) {
      // En caso de error, devolver el userId
      return participation.userId;
    }
  }

  /// Obtiene el nombre de display del rol
  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'organizer':
        return 'Organizador';
      case 'participant':
        return 'Participante';
      case 'observer':
        return 'Observador';
      default:
        return 'Usuario';
    }
  }

  /// Obtiene el display de la timezone
  String _getTimezoneDisplay(String timezone) {
    try {
      return TimezoneService.getTimezoneDisplayName(timezone);
    } catch (e) {
      return timezone.split('/').last;
    }
  }
}
