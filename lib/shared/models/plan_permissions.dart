import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';
import 'permission.dart';

/// Permisos específicos de un usuario en un plan
class PlanPermissions {
  final String planId;
  final String userId;
  final UserRole role;
  final Set<Permission> permissions;
  final String? assignedBy; // Usuario que asignó estos permisos
  final DateTime assignedAt;
  final DateTime? expiresAt; // Permisos temporales
  final Map<String, dynamic>? metadata; // Datos adicionales
  final String? _adminCreatedBy; // Campo administrativo: ID del usuario que creó este registro (no expuesto al cliente)

  const PlanPermissions({
    required this.planId,
    required this.userId,
    required this.role,
    required this.permissions,
    this.assignedBy,
    required this.assignedAt,
    this.expiresAt,
    this.metadata,
    String? adminCreatedBy, // Campo administrativo interno
  }) : _adminCreatedBy = adminCreatedBy;

  /// Crea permisos desde Firestore
  factory PlanPermissions.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PlanPermissions(
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      role: UserRoleExtension.fromStorageString(data['role'] ?? 'observer'),
      permissions: (data['permissions'] as List<dynamic>?)
          ?.map((p) => PermissionExtension.fromStorageString(p))
          .toSet() ?? {},
      assignedBy: data['assignedBy'],
      assignedAt: (data['assignedAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      metadata: data['metadata'] as Map<String, dynamic>?,
      adminCreatedBy: data['_adminCreatedBy'], // Campo administrativo
    );
  }

  /// Convierte permisos a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'userId': userId,
      'role': role.toStorageString(),
      'permissions': permissions.map((p) => p.toStorageString()).toList(),
      'assignedBy': assignedBy,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'metadata': metadata,
      if (_adminCreatedBy != null) '_adminCreatedBy': _adminCreatedBy, // Campo administrativo
    };
  }

  /// Crea una copia con cambios
  PlanPermissions copyWith({
    String? planId,
    String? userId,
    UserRole? role,
    Set<Permission>? permissions,
    String? assignedBy,
    DateTime? assignedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    String? adminCreatedBy,
  }) {
    return PlanPermissions(
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedAt: assignedAt ?? this.assignedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
      adminCreatedBy: adminCreatedBy ?? this._adminCreatedBy,
    );
  }

  /// Verifica si el usuario tiene un permiso específico
  bool hasPermission(Permission permission) {
    // Verificar si los permisos han expirado
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return false;
    }
    
    return permissions.contains(permission);
  }

  /// Verifica si el usuario tiene cualquiera de los permisos dados
  bool hasAnyPermission(List<Permission> requiredPermissions) {
    return requiredPermissions.any((permission) => hasPermission(permission));
  }

  /// Verifica si el usuario tiene todos los permisos dados
  bool hasAllPermissions(List<Permission> requiredPermissions) {
    return requiredPermissions.every((permission) => hasPermission(permission));
  }

  /// Verifica si los permisos han expirado
  bool get isExpired {
    return expiresAt != null && DateTime.now().isAfter(expiresAt!);
  }

  /// Verifica si es administrador
  bool get isAdmin {
    return role == UserRole.admin;
  }

  /// Verifica si es participante activo
  bool get isParticipant {
    return role == UserRole.participant;
  }

  /// Verifica si es observador
  bool get isObserver {
    return role == UserRole.observer;
  }

  /// Obtiene permisos por categoría
  Map<String, List<Permission>> get permissionsByCategory {
    final Map<String, List<Permission>> categorized = {};
    
    for (final permission in permissions) {
      final category = permission.category;
      categorized.putIfAbsent(category, () => []).add(permission);
    }
    
    return categorized;
  }

  @override
  String toString() {
    return 'PlanPermissions(planId: $planId, userId: $userId, role: ${role.displayName}, permissions: ${permissions.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanPermissions &&
        other.planId == planId &&
        other.userId == userId &&
        other.role == role &&
        other.permissions == permissions &&
        other.assignedBy == assignedBy &&
        other.assignedAt == assignedAt &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return planId.hashCode ^
        userId.hashCode ^
        role.hashCode ^
        permissions.hashCode ^
        assignedBy.hashCode ^
        assignedAt.hashCode ^
        expiresAt.hashCode;
  }
}

/// Permisos por defecto según el rol
class DefaultPermissions {
  /// Permisos por defecto para administradores
  static const Set<Permission> adminPermissions = {
    // Plan
    Permission.planView,
    Permission.planEdit,
    Permission.planDelete,
    Permission.planManageParticipants,
    Permission.planManageAdmins,
    
    // Eventos
    Permission.eventView,
    Permission.eventCreate,
    Permission.eventEditOwn,
    Permission.eventEditAny,
    Permission.eventDeleteOwn,
    Permission.eventDeleteAny,
    Permission.eventViewOthersPersonal,
    Permission.eventEditOthersPersonal,
    
    // Alojamientos
    Permission.accommodationView,
    Permission.accommodationCreate,
    Permission.accommodationEditOwn,
    Permission.accommodationEditAny,
    Permission.accommodationDeleteOwn,
    Permission.accommodationDeleteAny,
    
    // Tracks
    Permission.trackView,
    Permission.trackReorder,
    Permission.trackManageVisibility,
    
    // Filtros
    Permission.filterUse,
    Permission.filterSaveCustom,
  };

  /// Permisos por defecto para participantes
  static const Set<Permission> participantPermissions = {
    // Plan
    Permission.planView,
    
    // Eventos
    Permission.eventView,
    Permission.eventCreate,
    Permission.eventEditOwn,
    Permission.eventDeleteOwn,
    
    // Alojamientos
    Permission.accommodationView,
    Permission.accommodationCreate,
    Permission.accommodationEditOwn,
    Permission.accommodationDeleteOwn,
    
    // Tracks
    Permission.trackView,
    
    // Filtros
    Permission.filterUse,
  };

  /// Permisos por defecto para observadores
  static const Set<Permission> observerPermissions = {
    // Plan
    Permission.planView,
    
    // Eventos
    Permission.eventView,
    
    // Alojamientos
    Permission.accommodationView,
    
    // Tracks
    Permission.trackView,
    
    // Filtros
    Permission.filterUse,
  };

  /// Obtiene permisos por defecto para un rol
  static Set<Permission> getDefaultPermissions(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return adminPermissions;
      case UserRole.participant:
        return participantPermissions;
      case UserRole.observer:
        return observerPermissions;
    }
  }
}
