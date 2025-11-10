import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  // Crear usuario en Firestore
  Future<String?> createUser(UserModel user) async {
    try {
      // Verificar si el usuario ya existe
      if (user.id != null) {
        final doc = await _firestore
            .collection(_collection)
            .doc(user.id!)
            .get();
        
        if (doc.exists) {
          return user.id; // Usuario ya existe
        }
        
        // Crear usuario con su ID específico
        await _firestore
            .collection(_collection)
            .doc(user.id!)
            .set(user.toFirestore());
        return user.id;
      }
      
      // Si no tiene ID, crear con ID aleatorio
      final docRef = await _firestore
          .collection(_collection)
          .add(user.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Error al crear usuario: $e';
    }
  }

  // Obtener usuario por ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error al obtener usuario: $e';
    }
  }

  // Obtener usuario por ID (alias para compatibilidad)
  Future<UserModel?> getUserById(String userId) async {
    return getUser(userId);
  }

  // Obtener stream de usuario por ID
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Obtener usuario por email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw 'Error al obtener usuario por email: $e';
    }
  }

  // Obtener usuario por username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final normalized = username.trim().toLowerCase();
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('usernameLower', isEqualTo: normalized)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw 'Error al obtener usuario por username: $e';
    }
  }

  // Actualizar usuario
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  // Actualizar usuario por ID (alias para compatibilidad)
  Future<bool> updateUserById(String userId, UserModel user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .update(user.toFirestore());
      return true;
    } catch (e) {
      throw 'Error al actualizar usuario: $e';
    }
  }

  // Actualizar último login
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Error al actualizar último login: $e';
    }
  }

  // Actualizar perfil del usuario
  Future<bool> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoURL,
    String? defaultTimezone,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (displayName != null) {
        updateData['displayName'] = displayName;
      }
      if (photoURL != null) {
        updateData['photoURL'] = photoURL;
      }
      if (defaultTimezone != null) {
        updateData['defaultTimezone'] = defaultTimezone;
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection(_collection)
            .doc(userId)
            .update(updateData);
      }
      return true;
    } catch (e) {
      throw 'Error al actualizar perfil: $e';
    }
  }

  // Desactivar usuario (soft delete)
  Future<bool> deactivateUser(String userId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .update({
        'isActive': false,
      });
      return true;
    } catch (e) {
      throw 'Error al desactivar usuario: $e';
    }
  }

  // Eliminar usuario permanentemente
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .delete();
      return true;
    } catch (e) {
      throw 'Error al eliminar usuario: $e';
    }
  }

  // Verificar si el usuario existe
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      throw 'Error al verificar usuario: $e';
    }
  }

  // Obtener todos los usuarios (para administración)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error al obtener usuarios: $e';
    }
  }

  // Obtener usuarios activos
  Future<List<UserModel>> getActiveUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error al obtener usuarios activos: $e';
    }
  }

  // Buscar usuarios por nombre
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .where('isActive', isEqualTo: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar usuarios: $e');
    }
  }

  // Buscar usuarios por nombre (alias para compatibilidad)
  Future<List<UserModel>> searchUsersByName(String name) async {
    return searchUsers(name);
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Obtener conteo de planes
      final plansSnapshot = await _firestore
          .collection('plans')
          .where('userId', isEqualTo: userId)
          .get();

      // Obtener conteo de eventos
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: userId)
          .get();

      return {
        'plansCount': plansSnapshot.docs.length,
        'eventsCount': eventsSnapshot.docs.length,
      };
    } catch (e) {
      throw 'Error al obtener estadísticas: $e';
    }
  }

  // Verificar disponibilidad de username (case-insensitive)
  Future<bool> isUsernameAvailable(String candidate, {String? excludeUserId}) async {
    final u = candidate.trim().toLowerCase();
    final snapshot = await _firestore
        .collection(_collection)
        .where('usernameLower', isEqualTo: u)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return true;
    // Si existe, permitir solo si pertenece al mismo usuario (edición propia)
    if (excludeUserId != null && snapshot.docs.first.id == excludeUserId) return true;
    return false;
  }

  // Actualizar username del usuario (normalizado y con índice en lowercase)
  Future<bool> updateUsername(String userId, String username) async {
    final normalized = username.trim().toLowerCase();
    // Comprobar disponibilidad excluyendo al propio usuario
    final available = await isUsernameAvailable(normalized, excludeUserId: userId);
    if (!available) return false;

    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({
          'username': normalized,
          'usernameLower': normalized,
        });
    return true;
  }
}
