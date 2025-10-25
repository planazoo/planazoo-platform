import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(selectedParticipation.role),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            _getUserDisplayName(selectedParticipation),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (currentTimezone != null) ...[
            const SizedBox(width: 4),
            Text(
              _getTimezoneDisplay(currentTimezone!),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
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
      ),
    );
  }

  /// Construye los elementos del menú
  List<PopupMenuEntry<String>> _buildMenuItems() {
    return participations.map((participation) {
      return PopupMenuItem<String>(
        value: participation.userId,
        child: Row(
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
                    _getUserDisplayName(participation),
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
  String _getUserDisplayName(PlanParticipation participation) {
    // Por ahora usamos el userId, pero en el futuro podríamos obtener el nombre real
    return 'Usuario ${participation.userId.substring(0, 8)}...';
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
