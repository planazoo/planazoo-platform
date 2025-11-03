import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/participant_group.dart';

/// T123: Servicio para gestionar grupos de participantes reutilizables
class ParticipantGroupService {
  static const String _collectionName = 'participant_groups';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener todos los grupos de un usuario
  Stream<List<ParticipantGroup>> getUserGroups(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ParticipantGroup.fromFirestore(doc))
          .toList();
    }).handleError((error) {
      LoggerService.error('Error getting user groups: $userId', 
          context: 'PARTICIPANT_GROUP_SERVICE', error: error);
      throw error;
    });
  }

  /// Obtener un grupo por ID
  Future<ParticipantGroup?> getGroup(String groupId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(groupId)
          .get();
      
      if (doc.exists) {
        return ParticipantGroup.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting group: $groupId', 
          context: 'PARTICIPANT_GROUP_SERVICE', error: e);
      return null;
    }
  }

  /// Crear un nuevo grupo
  Future<String?> createGroup({
    required String userId,
    required String name,
    String? description,
    String? icon,
    String? color,
    List<String>? memberUserIds,
    List<String>? memberEmails,
  }) async {
    try {
      final now = DateTime.now();
      final group = ParticipantGroup(
        userId: userId,
        name: name.trim(),
        description: description?.trim(),
        icon: icon,
        color: color,
        memberUserIds: memberUserIds ?? [],
        memberEmails: memberEmails ?? [],
        createdAt: now,
        updatedAt: now,
      );

      // Validar que el nombre no esté vacío
      if (group.name.isEmpty) {
        throw Exception('El nombre del grupo no puede estar vacío');
      }

      final docRef = await _firestore
          .collection(_collectionName)
          .add(group.toFirestore());
      
      LoggerService.database('Group created: ${docRef.id}', operation: 'CREATE');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error creating group', 
          context: 'PARTICIPANT_GROUP_SERVICE', error: e);
      rethrow;
    }
  }

  /// Actualizar un grupo existente
  Future<bool> updateGroup(ParticipantGroup group) async {
    if (group.id == null) return false;
    
    try {
      final updatedGroup = group.copyWith(
        updatedAt: DateTime.now(),
      );

      // Validar que el nombre no esté vacío
      if (updatedGroup.name.trim().isEmpty) {
        throw Exception('El nombre del grupo no puede estar vacío');
      }

      await _firestore
          .collection(_collectionName)
          .doc(group.id)
          .update(updatedGroup.toFirestore());
      
      LoggerService.database('Group updated: ${group.id}', operation: 'UPDATE');
      return true;
    } catch (e) {
      LoggerService.error('Error updating group: ${group.id}', 
          context: 'PARTICIPANT_GROUP_SERVICE', error: e);
      return false;
    }
  }

  /// Eliminar un grupo
  Future<bool> deleteGroup(String groupId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(groupId)
          .delete();
      
      LoggerService.database('Group deleted: $groupId', operation: 'DELETE');
      return true;
    } catch (e) {
      LoggerService.error('Error deleting group: $groupId', 
          context: 'PARTICIPANT_GROUP_SERVICE', error: e);
      return false;
    }
  }

  /// Añadir un usuario al grupo (por ID de usuario)
  Future<bool> addUserToGroup(String groupId, String userId) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) return false;

      final updatedMemberUserIds = List<String>.from(group.memberUserIds);
      if (!updatedMemberUserIds.contains(userId)) {
        updatedMemberUserIds.add(userId);
      }

      final updatedGroup = group.copyWith(
        memberUserIds: updatedMemberUserIds,
        updatedAt: DateTime.now(),
      );

      return await updateGroup(updatedGroup);
    } catch (e) {
      LoggerService.error('Error adding user to group: $groupId, $userId', 
          context: 'PARTICIPANT_GROUP_SERVICE', error: e);
      return false;
    }
  }

  /// Añadir un email al grupo (para usuarios no registrados)
  Future<bool> addEmailToGroup(String groupId, String email) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) return false;

      final updatedMemberEmails = List<String>.from(group.memberEmails);
      if (!updatedMemberEmails.contains(email)) {
        updatedMemberEmails.add(email);
      }

      final updatedGroup = group.copyWith(
        memberEmails: updatedMemberEmails,
        updatedAt: DateTime.now(),
      );

      return await updateGroup(updatedGroup);
    } catch (e) {
      LoggerService.error('Error adding email to group: $groupId, $email', 
          context: 'PARTICIPANT_GROUP_SERVICE', error: e);
      return false;
    }
  }

  /// Eliminar un usuario del grupo
  Future<bool> removeUserFromGroup(String groupId, String userId) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) return false;

      final updatedMemberUserIds = List<String>.from(group.memberUserIds);
      updatedMemberUserIds.remove(userId);

      final updatedGroup = group.copyWith(
        memberUserIds: updatedMemberUserIds,
        updatedAt: DateTime.now(),
      );

      return await updateGroup(updatedGroup);
    } catch (e) {
      LoggerService.error('Error removing user from group: $groupId, $userId', 
          context: 'PARTICIPANT_GROUP_SERVICE', error: e);
      return false;
    }
  }

  /// Eliminar un email del grupo
  Future<bool> removeEmailFromGroup(String groupId, String email) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) return false;

      final updatedMemberEmails = List<String>.from(group.memberEmails);
      updatedMemberEmails.remove(email);

      final updatedGroup = group.copyWith(
        memberEmails: updatedMemberEmails,
        updatedAt: DateTime.now(),
      );

      return await updateGroup(updatedGroup);
    } catch (e) {
      LoggerService.error('Error removing email from group: $groupId, $email', 
          context: 'PARTICIPANT_GROUP_SERVICE', error: e);
      return false;
    }
  }
}

