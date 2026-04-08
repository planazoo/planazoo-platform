import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/auth/domain/models/user_model.dart';
import 'hive_service.dart';
import 'local_storage_service.dart';

/// Persistencia local del perfil del usuario autenticado (solo móviles).
///
/// Un único documento bajo la key [HiveKeys.currentUser] para arranque offline estable.
class HiveKeys {
  HiveKeys._();

  static const String currentUser = 'current';
}

/// Servicio para almacenar el snapshot del usuario actual en Hive.
class UserLocalService extends LocalStorageService<UserModel> {
  UserLocalService() : super(HiveService.boxNameCurrentUser);

  @override
  Map<String, dynamic> toMap(UserModel user) {
    final firestoreMap = user.toFirestore();
    dynamic convertTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate().toIso8601String();
      } else if (value is Map) {
        return value.map((k, v) => MapEntry(k, convertTimestamp(v)));
      } else if (value is List) {
        return value.map(convertTimestamp).toList();
      }
      return value;
    }

    final hiveMap = <String, dynamic>{};
    for (final e in firestoreMap.entries) {
      hiveMap[e.key] = convertTimestamp(e.value);
    }
    hiveMap['_id'] = user.id;
    return hiveMap;
  }

  @override
  UserModel fromMap(Map<String, dynamic> map) {
    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.parse(v);
      if (v is Timestamp) return v.toDate();
      return null;
    }

    final id = map['_id'] as String? ?? '';
    return UserModel(
      id: id,
      email: map['email'] as String? ?? '',
      username: map['username'] as String?,
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      defaultTimezone: map['defaultTimezone'] as String?,
      createdAt: parseDt(map['createdAt']) ?? DateTime.now(),
      lastLoginAt: parseDt(map['lastLoginAt']),
      isActive: map['isActive'] as bool? ?? true,
      isAdmin: map['isAdmin'] as bool? ?? false,
    );
  }

  Future<void> saveCurrentUser(UserModel user) async {
    await save(HiveKeys.currentUser, user);
  }

  /// Devuelve el usuario cacheado solo si coincide con el UID de Firebase Auth.
  Future<UserModel?> getCurrentUserIfMatches(String uid) async {
    final cached = await get(HiveKeys.currentUser);
    if (cached == null || cached.id != uid) return null;
    return cached;
  }

  Future<void> clearCurrentUser() async {
    await delete(HiveKeys.currentUser);
  }
}
