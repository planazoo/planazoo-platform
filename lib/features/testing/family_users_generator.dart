import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';

/// Generador de usuarios de la familia para testing
class FamilyUsersGenerator {
  static final UserService _userService = UserService();

  /// Lista de usuarios de la familia
  static const List<Map<String, String>> familyMembers = [
    {
      'id': 'cristian_claraso',
      'email': 'cricla@hotmail.com',
      'displayName': 'Cristian Claraso',
    },
    {
      'id': 'mar_batllori',
      'email': 'mbatllo@hotmail.com',
      'displayName': 'Mar Batllori',
    },
    {
      'id': 'emma_claraso',
      'email': 'emmcla575@gmail.com',
      'displayName': 'Emma Claraso',
    },
    {
      'id': 'matilde_claraso',
      'email': 'matcla575@outlook.com',
      'displayName': 'Matilde Claraso',
    },
    {
      'id': 'jimena_claraso',
      'email': 'jimcla575@gmail.com',
      'displayName': 'Jimena Claraso',
    },
  ];

  /// Lista de usuarios invitados adicionales
  static const List<Map<String, String>> guestUsers = [
    {
      'id': 'invitado_1',
      'email': 'invitado1@gmail.com',
      'displayName': 'Invitado 1',
    },
    {
      'id': 'invitado_2',
      'email': 'invitado2@gmail.com',
      'displayName': 'Invitado 2',
    },
  ];

  /// Genera todos los usuarios de la familia
  static Future<List<String>> generateFamilyUsers() async {
    final createdUserIds = <String>[];
    
    try {
      LoggerService.info('Generando usuarios de la familia...');
      
      for (final userData in familyMembers) {
        final user = UserModel(
          id: userData['id']!,
          email: userData['email']!,
          displayName: userData['displayName']!,
          createdAt: DateTime.now(),
        );
        
        final userId = await _userService.createUser(user);
        if (userId != null) {
          createdUserIds.add(userId);
          LoggerService.info('Usuario creado: ${user.displayName} (${user.email})');
        } else {
          LoggerService.warning('No se pudo crear usuario: ${user.displayName}');
        }
      }
      
      LoggerService.info('Usuarios de familia creados: ${createdUserIds.length}/${familyMembers.length}');
      return createdUserIds;
      
    } catch (e) {
      LoggerService.error('Error generando usuarios de familia', error: e);
      return createdUserIds;
    }
  }

  /// Genera usuarios invitados adicionales
  static Future<List<String>> generateGuestUsers() async {
    final createdUserIds = <String>[];
    
    try {
      LoggerService.info('Generando usuarios invitados...');
      
      for (final userData in guestUsers) {
        final user = UserModel(
          id: userData['id']!,
          email: userData['email']!,
          displayName: userData['displayName']!,
          createdAt: DateTime.now(),
        );
        
        final userId = await _userService.createUser(user);
        if (userId != null) {
          createdUserIds.add(userId);
          LoggerService.info('Usuario invitado creado: ${user.displayName} (${user.email})');
        } else {
          LoggerService.warning('No se pudo crear usuario invitado: ${user.displayName}');
        }
      }
      
      LoggerService.info('Usuarios invitados creados: ${createdUserIds.length}/${guestUsers.length}');
      return createdUserIds;
      
    } catch (e) {
      LoggerService.error('Error generando usuarios invitados', error: e);
      return createdUserIds;
    }
  }

  /// Genera todos los usuarios (familia + invitados)
  static Future<List<String>> generateAllUsers() async {
    final allCreatedIds = <String>[];
    
    // Generar usuarios de familia
    final familyIds = await generateFamilyUsers();
    allCreatedIds.addAll(familyIds);
    
    // Generar usuarios invitados
    final guestIds = await generateGuestUsers();
    allCreatedIds.addAll(guestIds);
    
    LoggerService.info('Total usuarios creados: ${allCreatedIds.length}');
    return allCreatedIds;
  }

  /// Obtiene los IDs de los usuarios de familia para usar en planes
  static List<String> getFamilyUserIds() {
    return familyMembers.map((user) => user['id']!).toList();
  }

  /// Obtiene los IDs de todos los usuarios (familia + invitados)
  static List<String> getAllUserIds() {
    return [
      ...familyMembers.map((user) => user['id']!),
      ...guestUsers.map((user) => user['id']!),
    ];
  }

  /// Verifica si un usuario existe en la familia
  static bool isFamilyMember(String userId) {
    return familyMembers.any((user) => user['id'] == userId);
  }

  /// Obtiene información de un usuario por ID
  static Map<String, String>? getUserInfo(String userId) {
    final allUsers = [...familyMembers, ...guestUsers];
    try {
      return allUsers.firstWhere((user) => user['id'] == userId);
    } catch (e) {
      return null;
    }
  }
}
