import 'package:flutter_test/flutter_test.dart';
import '../shared/models/user_role.dart';
import '../shared/models/permission.dart';
import '../shared/models/plan_permissions.dart';
import '../shared/services/permission_service.dart';

void main() {
  group('UserRole Tests', () {
    test('UserRole display names are correct', () {
      expect(UserRole.admin.displayName, 'Administrador');
      expect(UserRole.participant.displayName, 'Participante');
      expect(UserRole.observer.displayName, 'Observador');
    });

    test('UserRole permission levels are correct', () {
      expect(UserRole.admin.permissionLevel, 3);
      expect(UserRole.participant.permissionLevel, 2);
      expect(UserRole.observer.permissionLevel, 1);
    });

    test('UserRole serialization works', () {
      expect(UserRole.admin.toStorageString(), 'admin');
      expect(UserRoleExtension.fromStorageString('participant'), UserRole.participant);
      expect(UserRoleExtension.fromStorageString('invalid'), UserRole.observer);
    });
  });

  group('Permission Tests', () {
    test('Permission display names are correct', () {
      expect(Permission.planView.displayName, 'Ver plan');
      expect(Permission.eventCreate.displayName, 'Crear eventos');
      expect(Permission.accommodationEditOwn.displayName, 'Editar alojamientos propios');
    });

    test('Permission categories are correct', () {
      expect(Permission.planView.category, 'Plan');
      expect(Permission.eventCreate.category, 'Eventos');
      expect(Permission.accommodationEditOwn.category, 'Alojamientos');
      expect(Permission.trackView.category, 'Tracks');
      expect(Permission.filterUse.category, 'Filtros');
    });

    test('Permission serialization works', () {
      expect(Permission.planView.toStorageString(), 'planView');
      expect(PermissionExtension.fromStorageString('eventCreate'), Permission.eventCreate);
      expect(PermissionExtension.fromStorageString('invalid'), Permission.eventView);
    });
  });

  group('PlanPermissions Tests', () {
    test('PlanPermissions creation works', () {
      final permissions = PlanPermissions(
        planId: 'test-plan',
        userId: 'test-user',
        role: UserRole.participant,
        permissions: {Permission.eventView, Permission.eventCreate},
        assignedAt: DateTime.now(),
      );

      expect(permissions.planId, 'test-plan');
      expect(permissions.userId, 'test-user');
      expect(permissions.role, UserRole.participant);
      expect(permissions.permissions.length, 2);
      expect(permissions.isParticipant, true);
      expect(permissions.isAdmin, false);
      expect(permissions.isObserver, false);
    });

    test('Permission checking works', () {
      final permissions = PlanPermissions(
        planId: 'test-plan',
        userId: 'test-user',
        role: UserRole.participant,
        permissions: {Permission.eventView, Permission.eventCreate},
        assignedAt: DateTime.now(),
      );

      expect(permissions.hasPermission(Permission.eventView), true);
      expect(permissions.hasPermission(Permission.eventEditAny), false);
      expect(permissions.hasAnyPermission([Permission.eventView, Permission.planDelete]), true);
      expect(permissions.hasAllPermissions([Permission.eventView, Permission.eventCreate]), true);
      expect(permissions.hasAllPermissions([Permission.eventView, Permission.planDelete]), false);
    });

    test('Expired permissions work', () {
      final expiredPermissions = PlanPermissions(
        planId: 'test-plan',
        userId: 'test-user',
        role: UserRole.participant,
        permissions: {Permission.eventView},
        assignedAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(expiredPermissions.isExpired, true);
      expect(expiredPermissions.hasPermission(Permission.eventView), false);
    });

    test('Permissions by category work', () {
      final permissions = PlanPermissions(
        planId: 'test-plan',
        userId: 'test-user',
        role: UserRole.admin,
        permissions: {
          Permission.planView,
          Permission.eventView,
          Permission.eventCreate,
          Permission.accommodationView,
        },
        assignedAt: DateTime.now(),
      );

      final categorized = permissions.permissionsByCategory;
      expect(categorized['Plan']?.length, 1);
      expect(categorized['Eventos']?.length, 2);
      expect(categorized['Alojamientos']?.length, 1);
    });
  });

  group('DefaultPermissions Tests', () {
    test('Admin permissions are comprehensive', () {
      final adminPerms = DefaultPermissions.getDefaultPermissions(UserRole.admin);
      expect(adminPerms.contains(Permission.planDelete), true);
      expect(adminPerms.contains(Permission.eventEditAny), true);
      expect(adminPerms.contains(Permission.accommodationDeleteAny), true);
      expect(adminPerms.contains(Permission.planManageAdmins), true);
    });

    test('Participant permissions are limited', () {
      final participantPerms = DefaultPermissions.getDefaultPermissions(UserRole.participant);
      expect(participantPerms.contains(Permission.planDelete), false);
      expect(participantPerms.contains(Permission.eventEditAny), false);
      expect(participantPerms.contains(Permission.eventEditOwn), true);
      expect(participantPerms.contains(Permission.eventCreate), true);
    });

    test('Observer permissions are read-only', () {
      final observerPerms = DefaultPermissions.getDefaultPermissions(UserRole.observer);
      expect(observerPerms.contains(Permission.eventCreate), false);
      expect(observerPerms.contains(Permission.eventEditOwn), false);
      expect(observerPerms.contains(Permission.eventView), true);
      expect(observerPerms.contains(Permission.planView), true);
    });
  });

  group('PermissionService Tests', () {
    late PermissionService permissionService;

    setUp(() {
      permissionService = PermissionService();
    });

    test('Service is singleton', () {
      final service1 = PermissionService();
      final service2 = PermissionService();
      expect(identical(service1, service2), true);
    });

    test('Cache operations work', () {
      permissionService.clearCache();
      expect(permissionService._permissionsCache.isEmpty, true);
      expect(permissionService._cacheTimestamps.isEmpty, true);
    });

    // Nota: Los tests de Firestore requieren configuración de Firebase
    // y se ejecutarían en integración, no en unit tests
  });
}
