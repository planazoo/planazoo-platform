import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';
import '../models/permission.dart';
import '../models/plan_permissions.dart';

/// Servicio para gestionar permisos de usuarios en planes
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache de permisos para optimización
  final Map<String, PlanPermissions> _permissionsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Tiempo de vida del cache (5 minutos)
  static const Duration _cacheLifetime = Duration(minutes: 5);

  /// Obtiene los permisos de un usuario en un plan
  Future<PlanPermissions?> getUserPermissions(String planId, String userId) async {
    final cacheKey = '${planId}_$userId';
    
    // Verificar cache
    if (_permissionsCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey]!;
      if (DateTime.now().difference(cacheTime) < _cacheLifetime) {
        return _permissionsCache[cacheKey];
      }
    }

    try {
      final doc = await _firestore
          .collection('plan_permissions')
          .doc('${planId}_$userId')
          .get();

      if (!doc.exists) {
        return null;
      }

      final permissions = PlanPermissions.fromFirestore(doc);
      
      // Actualizar cache
      _permissionsCache[cacheKey] = permissions;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      return permissions;
    } catch (e) {
      print('Error obteniendo permisos: $e');
      return null;
    }
  }

  /// Asigna permisos a un usuario en un plan
  Future<bool> assignPermissions({
    required String planId,
    required String userId,
    required UserRole role,
    Set<Permission>? customPermissions,
    String? assignedBy,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final permissions = customPermissions ?? DefaultPermissions.getDefaultPermissions(role);
      
      final planPermissions = PlanPermissions(
        planId: planId,
        userId: userId,
        role: role,
        permissions: permissions,
        assignedBy: assignedBy,
        assignedAt: DateTime.now(),
        expiresAt: expiresAt,
        metadata: metadata,
      );

      await _firestore
          .collection('plan_permissions')
          .doc('${planId}_$userId')
          .set(planPermissions.toFirestore());

      // Actualizar cache
      final cacheKey = '${planId}_$userId';
      _permissionsCache[cacheKey] = planPermissions;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return true;
    } catch (e) {
      print('Error asignando permisos: $e');
      return false;
    }
  }

  /// Actualiza el rol de un usuario
  Future<bool> updateUserRole({
    required String planId,
    required String userId,
    required UserRole newRole,
    String? updatedBy,
  }) async {
    try {
      final currentPermissions = await getUserPermissions(planId, userId);
      if (currentPermissions == null) {
        return false;
      }

      final newPermissions = currentPermissions.copyWith(
        role: newRole,
        permissions: DefaultPermissions.getDefaultPermissions(newRole),
        assignedBy: updatedBy,
        assignedAt: DateTime.now(),
      );

      await _firestore
          .collection('plan_permissions')
          .doc('${planId}_$userId')
          .update(newPermissions.toFirestore());

      // Actualizar cache
      final cacheKey = '${planId}_$userId';
      _permissionsCache[cacheKey] = newPermissions;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return true;
    } catch (e) {
      print('Error actualizando rol: $e');
      return false;
    }
  }

  /// Añade permisos específicos a un usuario
  Future<bool> addPermissions({
    required String planId,
    required String userId,
    required Set<Permission> permissions,
    String? updatedBy,
  }) async {
    try {
      final currentPermissions = await getUserPermissions(planId, userId);
      if (currentPermissions == null) {
        return false;
      }

      final newPermissions = currentPermissions.permissions.union(permissions);
      final updatedPermissions = currentPermissions.copyWith(
        permissions: newPermissions,
        assignedBy: updatedBy,
        assignedAt: DateTime.now(),
      );

      await _firestore
          .collection('plan_permissions')
          .doc('${planId}_$userId')
          .update(updatedPermissions.toFirestore());

      // Actualizar cache
      final cacheKey = '${planId}_$userId';
      _permissionsCache[cacheKey] = updatedPermissions;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return true;
    } catch (e) {
      print('Error añadiendo permisos: $e');
      return false;
    }
  }

  /// Quita permisos específicos de un usuario
  Future<bool> removePermissions({
    required String planId,
    required String userId,
    required Set<Permission> permissions,
    String? updatedBy,
  }) async {
    try {
      final currentPermissions = await getUserPermissions(planId, userId);
      if (currentPermissions == null) {
        return false;
      }

      final newPermissions = currentPermissions.permissions.difference(permissions);
      final updatedPermissions = currentPermissions.copyWith(
        permissions: newPermissions,
        assignedBy: updatedBy,
        assignedAt: DateTime.now(),
      );

      await _firestore
          .collection('plan_permissions')
          .doc('${planId}_$userId')
          .update(updatedPermissions.toFirestore());

      // Actualizar cache
      final cacheKey = '${planId}_$userId';
      _permissionsCache[cacheKey] = updatedPermissions;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return true;
    } catch (e) {
      print('Error quitando permisos: $e');
      return false;
    }
  }

  /// Elimina todos los permisos de un usuario en un plan
  Future<bool> revokeAllPermissions(String planId, String userId) async {
    try {
      await _firestore
          .collection('plan_permissions')
          .doc('${planId}_$userId')
          .delete();

      // Limpiar cache
      final cacheKey = '${planId}_$userId';
      _permissionsCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);

      return true;
    } catch (e) {
      print('Error revocando permisos: $e');
      return false;
    }
  }

  /// Verifica si un usuario tiene un permiso específico
  Future<bool> hasPermission({
    required String planId,
    required String userId,
    required Permission permission,
  }) async {
    final permissions = await getUserPermissions(planId, userId);
    return permissions?.hasPermission(permission) ?? false;
  }

  /// Verifica si un usuario tiene cualquiera de los permisos dados
  Future<bool> hasAnyPermission({
    required String planId,
    required String userId,
    required List<Permission> permissions,
  }) async {
    final userPermissions = await getUserPermissions(planId, userId);
    return userPermissions?.hasAnyPermission(permissions) ?? false;
  }

  /// Verifica si un usuario tiene todos los permisos dados
  Future<bool> hasAllPermissions({
    required String planId,
    required String userId,
    required List<Permission> permissions,
  }) async {
    final userPermissions = await getUserPermissions(planId, userId);
    return userPermissions?.hasAllPermissions(permissions) ?? false;
  }

  /// Obtiene todos los usuarios con permisos en un plan
  Future<List<PlanPermissions>> getPlanUsers(String planId) async {
    try {
      final querySnapshot = await _firestore
          .collection('plan_permissions')
          .where('planId', isEqualTo: planId)
          .get();

      return querySnapshot.docs
          .map((doc) => PlanPermissions.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error obteniendo usuarios del plan: $e');
      return [];
    }
  }

  /// Obtiene usuarios con un rol específico en un plan
  Future<List<PlanPermissions>> getUsersByRole(String planId, UserRole role) async {
    try {
      final querySnapshot = await _firestore
          .collection('plan_permissions')
          .where('planId', isEqualTo: planId)
          .where('role', isEqualTo: role.toStorageString())
          .get();

      return querySnapshot.docs
          .map((doc) => PlanPermissions.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error obteniendo usuarios por rol: $e');
      return [];
    }
  }

  /// Limpia el cache de permisos
  void clearCache() {
    _permissionsCache.clear();
    _cacheTimestamps.clear();
  }

  /// Limpia permisos expirados del cache
  void cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheLifetime) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _permissionsCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Obtiene estadísticas de permisos de un plan
  Future<Map<String, dynamic>> getPlanPermissionStats(String planId) async {
    try {
      final users = await getPlanUsers(planId);
      
      final stats = <String, int>{
        'total_users': users.length,
        'admins': 0,
        'participants': 0,
        'observers': 0,
        'expired_permissions': 0,
      };
      
      for (final user in users) {
        switch (user.role) {
          case UserRole.admin:
            stats['admins'] = (stats['admins'] ?? 0) + 1;
            break;
          case UserRole.participant:
            stats['participants'] = (stats['participants'] ?? 0) + 1;
            break;
          case UserRole.observer:
            stats['observers'] = (stats['observers'] ?? 0) + 1;
            break;
        }
        
        if (user.isExpired) {
          stats['expired_permissions'] = (stats['expired_permissions'] ?? 0) + 1;
        }
      }
      
      return stats;
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }
}
