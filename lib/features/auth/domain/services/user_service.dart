import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_participant_service.dart';
import 'package:unp_calendario/shared/services/permission_service.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';
  static const String _usernameLookupCollection = 'username_lookup';
  static const String _emailLookupCollection = 'email_lookup';
  
  // Servicios para eliminación en cascada (lazy initialization para evitar dependencias circulares)
  PlanService? _planService;
  PlanParticipationService? _participationService;
  EventService? _eventService;
  EventParticipantService? _eventParticipantService;
  PermissionService? _permissionService;
  
  PlanService get planService => _planService ??= PlanService();
  PlanParticipationService get participationService => _participationService ??= PlanParticipationService();
  EventService get eventService => _eventService ??= EventService();
  EventParticipantService get eventParticipantService => _eventParticipantService ??= EventParticipantService();
  PermissionService get permissionService => _permissionService ??= PermissionService();

  // Crear usuario en Firestore
  Future<String?> createUser(UserModel user) async {
    try {
      // Verificar si el usuario ya existe
      final doc = await _firestore
          .collection(_collection)
          .doc(user.id)
          .get();

      if (doc.exists) {
        // No tocar lookups ni sobrescribir username con un modelo incompleto
        // (p. ej. fallback Auth sin username → cristianclaraso6).
        return user.id;
      }

      // Crear usuario con su ID específico
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .set(user.toFirestore());
      await ensureUserLookups(user);
      return user.id;
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
      final normalized = email.trim().toLowerCase();
      if (normalized.isEmpty) return null;

      final lookup = await _firestore
          .collection(_emailLookupCollection)
          .doc(normalized)
          .get();
      if (lookup.exists) {
        final userId = lookup.data()?['userId'] as String?;
        if (userId != null && userId.isNotEmpty) {
          return await getUser(userId);
        }
      }

      // Fallback legacy (solo power_admin puede listar `users`)
      try {
        final querySnapshot = await _firestore
            .collection(_collection)
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          final user = UserModel.fromFirestore(querySnapshot.docs.first);
          await ensureUserLookups(user);
          return user;
        }
      } catch (_) {}
      return null;
    } catch (e) {
      throw 'Error al obtener usuario por email: $e';
    }
  }

  // Obtener usuario por username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final normalized = username.trim().toLowerCase();
      final email = await getEmailByUsername(normalized);
      if (email == null) return null;

      // Preferir perfil completo si las reglas lo permiten
      final byEmail = await getUserByEmail(email);
      if (byEmail != null) return byEmail;

      final lookup = await _firestore
          .collection(_usernameLookupCollection)
          .doc(normalized)
          .get();
      final userId = lookup.data()?['userId'] as String?;
      if (userId == null) return null;
      return UserModel(
        id: userId,
        email: email,
        username: normalized,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
    } catch (e) {
      throw 'Error al obtener usuario por username: $e';
    }
  }

  /// Mantiene índices `username_lookup` + `email_lookup`.
  Future<void> ensureUserLookups(UserModel user, {String? previousUsername}) async {
    await ensureUsernameLookup(user, previousUsername: previousUsername);
    await ensureEmailLookup(user);
  }

  /// Alias conservado.
  Future<void> ensureUsernameLookup(UserModel user, {String? previousUsername}) async {
    final currentRaw = user.username?.trim().toLowerCase() ?? '';
    final previousRaw = previousUsername?.trim().toLowerCase() ?? '';
    final current = currentRaw.startsWith('@') ? currentRaw.substring(1) : currentRaw;
    final previous =
        previousRaw.startsWith('@') ? previousRaw.substring(1) : previousRaw;
    if (current.isEmpty && previous.isEmpty) {
      return;
    }
    if (user.email.trim().isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    if (previous.isNotEmpty && previous != current) {
      batch.delete(_firestore.collection(_usernameLookupCollection).doc(previous));
    }
    if (current.isNotEmpty) {
      batch.set(
        _firestore.collection(_usernameLookupCollection).doc(current),
        {
          'userId': user.id,
          'email': user.email.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }
    await batch.commit();
  }

  Future<void> ensureEmailLookup(UserModel user) async {
    final emailKey = user.email.trim().toLowerCase();
    if (emailKey.isEmpty) return;
    await _firestore.collection(_emailLookupCollection).doc(emailKey).set({
      'userId': user.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Resuelve email desde username sin listar `users` (login sin sesión).
  Future<String?> getEmailByUsername(String username) async {
    var normalized = username.trim().toLowerCase();
    if (normalized.startsWith('@')) {
      normalized = normalized.substring(1);
    }
    if (normalized.isEmpty) return null;
    final lookup = await _firestore
        .collection(_usernameLookupCollection)
        .doc(normalized)
        .get();
    if (!lookup.exists) return null;
    final email = lookup.data()?['email'] as String?;
    if (email == null || email.trim().isEmpty) return null;
    return email.trim();
  }

  // Actualizar usuario
  Future<void> updateUser(UserModel user) async {
    try {
      final data = user.toFirestore();
      // No borrar username existente escribiendo null (login fallback / Auth sin username).
      if (user.username == null || user.username!.trim().isEmpty) {
        data.remove('username');
        data.remove('usernameLower');
      }
      // No reenviar createdAt (igualdad exacta en rules / precisión Timestamp).
      data.remove('createdAt');
      await _firestore.collection(_collection).doc(user.id).update(data);
      if (user.username != null && user.username!.trim().isNotEmpty) {
        await ensureUserLookups(user);
      } else {
        await ensureEmailLookup(user);
      }
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

  // Eliminar usuario permanentemente (solo el documento del usuario)
  // Para eliminar todos los datos del usuario, usar deleteAllUserData()
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

  // Eliminar todos los datos de un usuario (eliminación completa)
  ///
  /// Elimina todos los datos relacionados con un usuario en el siguiente orden:
  /// 1. Obtener email del usuario (necesario para eliminar invitaciones)
  /// 2. Planes creados por el usuario (y todos sus datos relacionados)
  /// 3. Participaciones en planes (plan_participations)
  /// 4. Eventos creados por el usuario (y sus event_participants)
  /// 5. Participaciones en eventos (event_participants donde el usuario es participante)
  /// 6. Permisos del usuario (plan_permissions)
  /// 7. Invitaciones por email (plan_invitations)
  /// 8. Pagos personales (personal_payments)
  /// 9. Grupos de participantes (participant_groups)
  /// 10. Preferencias del usuario (userPreferences)
  /// 11. Preferencias por plan (plans/{planId}/userPreferences/{userId})
  /// 12. El usuario mismo (users/{userId})
  ///
  /// NOTA: Este método es destructivo e irreversible. Usar solo para eliminación de cuenta.
  /// Al añadir nuevas estructuras de BD por usuario, actualizar este método y la documentación
  /// de pruebas (TESTING_CHECKLIST.md § 3.5.1 Borrado total de usuario; FLUJO_CRUD_USUARIOS.md).
  Future<bool> deleteAllUserData(String userId) async {
    try {
      LoggerService.database('Starting complete user data deletion for: $userId', operation: 'DELETE');
      
      // 0. Obtener email del usuario ANTES de eliminar nada (necesario para invitaciones)
      String? userEmail;
      final userDoc = await _firestore.collection(_collection).doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        userEmail = userData['email'] as String?;
      }
      
      // 1. Eliminar planes creados por el usuario (esto elimina en cascada eventos, participaciones, etc.)
      final userPlansSnapshot = await _firestore
          .collection('plans')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final planDoc in userPlansSnapshot.docs) {
        final planId = planDoc.id;
        LoggerService.database('Deleting plan $planId owned by user $userId', operation: 'DELETE');
        await planService.deletePlan(planId);
      }
      
      // 2. Eliminar participaciones en planes (donde el usuario es participante, no organizador)
      final participationsSnapshot = await _firestore
          .collection('plan_participations')
          .where('userId', isEqualTo: userId)
          .get();
      
      if (participationsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in participationsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        LoggerService.database('Deleted ${participationsSnapshot.docs.length} plan participations', operation: 'DELETE');
      }
      
      // 3. Eliminar eventos creados por el usuario (que no pertenecen a planes ya eliminados)
      final userEventsSnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final eventDoc in userEventsSnapshot.docs) {
        final eventId = eventDoc.id;
        await eventService.deleteEvent(eventId);
      }
      LoggerService.database('Deleted ${userEventsSnapshot.docs.length} events', operation: 'DELETE');
      
      // 4. Eliminar participaciones en eventos (event_participants)
      final eventParticipantsSnapshot = await _firestore
          .collection('event_participants')
          .where('userId', isEqualTo: userId)
          .get();
      
      if (eventParticipantsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in eventParticipantsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        LoggerService.database('Deleted ${eventParticipantsSnapshot.docs.length} event participants', operation: 'DELETE');
      }
      
      // 5. Eliminar permisos del usuario (plan_permissions)
      final permissionsSnapshot = await _firestore
          .collection('plan_permissions')
          .where('userId', isEqualTo: userId)
          .get();
      
      if (permissionsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in permissionsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        LoggerService.database('Deleted ${permissionsSnapshot.docs.length} plan permissions', operation: 'DELETE');
      }
      
      // 6. Eliminar invitaciones por email (plan_invitations) y las creadas por el usuario (invitedBy)
      if (userEmail != null) {
        final invitationsSnapshot = await _firestore
            .collection('plan_invitations')
            .where('email', isEqualTo: userEmail.toLowerCase())
            .get();
        
        if (invitationsSnapshot.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in invitationsSnapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          LoggerService.database('Deleted ${invitationsSnapshot.docs.length} plan invitations', operation: 'DELETE');
        }
      }
      // Invitaciones creadas por el usuario (pueden ser de planes de otros owners)
      final createdInvitationsSnapshot = await _firestore
          .collection('plan_invitations')
          .where('invitedBy', isEqualTo: userId)
          .get();
      if (createdInvitationsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in createdInvitationsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        LoggerService.database('Deleted ${createdInvitationsSnapshot.docs.length} plan invitations created by user', operation: 'DELETE');
      }
      
      // 7. Eliminar pagos personales (personal_payments)
      final paymentsSnapshot = await _firestore
          .collection('personal_payments')
          .where('participantId', isEqualTo: userId)
          .get();
      
      if (paymentsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in paymentsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        LoggerService.database('Deleted ${paymentsSnapshot.docs.length} personal payments', operation: 'DELETE');
      }
      
      // 8. Eliminar grupos de participantes (participant_groups)
      final groupsSnapshot = await _firestore
          .collection('participant_groups')
          .where('userId', isEqualTo: userId)
          .get();
      
      if (groupsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in groupsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        LoggerService.database('Deleted ${groupsSnapshot.docs.length} participant groups', operation: 'DELETE');
      }
      
      // 9. Eliminar preferencias del usuario (userPreferences)
      try {
        final preferencesDoc = await _firestore
            .collection('userPreferences')
            .doc(userId)
            .get();
        
        if (preferencesDoc.exists) {
          await preferencesDoc.reference.delete();
          LoggerService.database('Deleted user preferences', operation: 'DELETE');
        }
      } catch (e) {
        // Ignorar si no existe
        LoggerService.debug('No user preferences found or error deleting: $e', context: 'USER_SERVICE');
      }
      
      // 10. Eliminar preferencias por plan (plans/{planId}/userPreferences/{userId})
      // Esto requiere obtener todos los planes donde el usuario participó
      // Por ahora, lo haremos de forma más simple: buscar en todos los planes
      // (Nota: Esto puede ser costoso si hay muchos planes, pero es necesario para limpieza completa)
      try {
        final allPlansSnapshot = await _firestore.collection('plans').get();
        final batch = _firestore.batch();
        int deletedPreferences = 0;
        
        for (final planDoc in allPlansSnapshot.docs) {
          final planId = planDoc.id;
          final preferencesRef = _firestore
              .collection('plans')
              .doc(planId)
              .collection('userPreferences')
              .doc(userId);
          
          final prefDoc = await preferencesRef.get();
          if (prefDoc.exists) {
            batch.delete(preferencesRef);
            deletedPreferences++;
          }
        }
        
        if (deletedPreferences > 0) {
          await batch.commit();
          LoggerService.database('Deleted $deletedPreferences plan-specific user preferences', operation: 'DELETE');
        }
      } catch (e) {
        LoggerService.warning('Error deleting plan-specific preferences: $e', context: 'USER_SERVICE');
        // Continuar aunque falle, no es crítico
      }
      
      // 11. Finalmente, eliminar el usuario mismo
      await deleteUser(userId);
      LoggerService.database('User $userId completely deleted', operation: 'DELETE');
      
      return true;
    } catch (e) {
      LoggerService.error('Error deleting all user data: $userId', context: 'USER_SERVICE', error: e);
      throw 'Error al eliminar todos los datos del usuario: $e';
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

  // Obtener todos los usuarios (directorio / administración)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection(_collection)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (_) {
        // Sin índice o docs sin createdAt: listado sin orden.
        querySnapshot = await _firestore.collection(_collection).get();
      }

      final users = <UserModel>[];
      for (final doc in querySnapshot.docs) {
        try {
          users.add(UserModel.fromFirestore(doc));
        } catch (e) {
          // Doc incompleto: mapear con defaults seguros.
          final data = doc.data() as Map<String, dynamic>? ?? {};
          users.add(UserModel(
            id: doc.id,
            email: data['email']?.toString() ?? '',
            username: data['username']?.toString(),
            displayName: data['displayName']?.toString(),
            photoURL: data['photoURL']?.toString(),
            defaultTimezone: data['defaultTimezone']?.toString(),
            createdAt: data['createdAt'] is Timestamp
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.fromMillisecondsSinceEpoch(0),
            lastLoginAt: data['lastLoginAt'] is Timestamp
                ? (data['lastLoginAt'] as Timestamp).toDate()
                : null,
            isActive: data['isActive'] as bool? ?? true,
            isAdmin: data['isAdmin'] as bool? ?? false,
          ));
        }
      }
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
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
          .where('displayName', isLessThan: '${query}z')
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
    final lookup = await _firestore.collection(_usernameLookupCollection).doc(u).get();
    if (!lookup.exists) {
      // Fallback legacy (usuarios aún sin índice), solo si hay sesión
      try {
        final snapshot = await _firestore
            .collection(_collection)
            .where('usernameLower', isEqualTo: u)
            .limit(1)
            .get();
        if (snapshot.docs.isEmpty) return true;
        if (excludeUserId != null && snapshot.docs.first.id == excludeUserId) return true;
        return false;
      } catch (_) {
        // Sin sesión y sin lookup → tratar como disponible
        return true;
      }
    }
    final ownerId = lookup.data()?['userId'] as String?;
    if (excludeUserId != null && ownerId == excludeUserId) return true;
    return false;
  }

  // Actualizar username del usuario (normalizado y con índice en lowercase)
  Future<bool> updateUsername(String userId, String username) async {
    final normalized = username.trim().toLowerCase();
    // Comprobar disponibilidad excluyendo al propio usuario
    final available = await isUsernameAvailable(normalized, excludeUserId: userId);
    if (!available) return false;

    final existing = await getUser(userId);
    final previous = existing?.username;

    await _firestore.collection(_collection).doc(userId).update({
      'username': normalized,
      'usernameLower': normalized,
    });

    final email = existing?.email;
    if (email != null) {
      await ensureUserLookups(
        UserModel(
          id: userId,
          email: email,
          username: normalized,
          createdAt: existing?.createdAt ?? DateTime.now(),
        ),
        previousUsername: previous,
      );
    }
    return true;
  }
}
