/// Roles de usuario en el sistema
enum UserRole {
  /// Administrador del plan - acceso completo
  admin,
  
  /// Participante activo - puede crear/editar eventos
  participant,
  
  /// Observador - solo lectura
  observer,
}

extension UserRoleExtension on UserRole {
  /// Nombre legible del rol
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.participant:
        return 'Participante';
      case UserRole.observer:
        return 'Observador';
    }
  }

  /// Descripción del rol
  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Acceso completo al plan, puede gestionar participantes y eventos';
      case UserRole.participant:
        return 'Puede crear y editar eventos, gestionar su información personal';
      case UserRole.observer:
        return 'Solo lectura, puede ver eventos pero no modificarlos';
    }
  }

  /// Icono asociado al rol
  String get iconName {
    switch (this) {
      case UserRole.admin:
        return 'admin_panel_settings';
      case UserRole.participant:
        return 'person';
      case UserRole.observer:
        return 'visibility';
    }
  }

  /// Color asociado al rol
  String get colorName {
    switch (this) {
      case UserRole.admin:
        return 'red';
      case UserRole.participant:
        return 'blue';
      case UserRole.observer:
        return 'grey';
    }
  }

  /// Nivel de permisos (mayor número = más permisos)
  int get permissionLevel {
    switch (this) {
      case UserRole.admin:
        return 3;
      case UserRole.participant:
        return 2;
      case UserRole.observer:
        return 1;
    }
  }

  /// Convierte el rol a string para almacenamiento
  String toStorageString() {
    return name;
  }

  /// Crea un rol desde string de almacenamiento
  static UserRole fromStorageString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.observer, // Default seguro
    );
  }
}
