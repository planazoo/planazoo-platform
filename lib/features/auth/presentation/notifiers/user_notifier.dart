import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';

class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final UserService _userService;

  UserNotifier({required UserService userService})
      : _userService = userService,
        super(const AsyncValue.loading());

  // Obtener usuario por ID
  Future<void> getUser(String userId) async {
    try {
      state = const AsyncValue.loading();
      final user = await _userService.getUser(userId);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Obtener stream de usuario por ID
  Stream<UserModel?> getUserStream(String userId) {
    return _userService.getUserStream(userId);
  }

  // Actualizar usuario
  Future<void> updateUser(UserModel user) async {
    try {
      await _userService.updateUser(user);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Actualizar nombre de usuario
  Future<void> updateDisplayName(String userId, String displayName) async {
    try {
      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(displayName: displayName);
        await _userService.updateUser(updatedUser);
        state = AsyncValue.data(updatedUser);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Actualizar foto de perfil
  Future<void> updatePhotoURL(String userId, String photoURL) async {
    try {
      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(photoURL: photoURL);
        await _userService.updateUser(updatedUser);
        state = AsyncValue.data(updatedUser);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      return await _userService.getUserStats(userId);
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Buscar usuarios
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      return await _userService.searchUsers(query);
    } catch (e) {
      throw Exception('Error al buscar usuarios: $e');
    }
  }

  // Actualizar perfil del usuario
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          displayName: displayName ?? currentUser.displayName,
          photoURL: photoURL ?? currentUser.photoURL,
        );
        await _userService.updateUser(updatedUser);
        state = AsyncValue.data(updatedUser);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Cambiar contraseña (delegar al AuthNotifier)
  Future<void> changePassword(String currentPassword, String newPassword) async {
    // Este método debería delegar al AuthNotifier
    // Por ahora lanzamos una excepción indicando que se debe usar AuthNotifier
    throw Exception('Use AuthNotifier.changePassword() para cambiar contraseñas');
  }

  // Eliminar cuenta (delegar al AuthNotifier)
  Future<void> deleteAccount(String password) async {
    // Este método debería delegar al AuthNotifier
    // Por ahora lanzamos una excepción indicando que se debe usar AuthNotifier
    throw Exception('Use AuthNotifier.deleteAccount() para eliminar cuentas');
  }
}