import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class UserModel {
  final String id;
  final String email;
  final String? username; // @username para búsqueda fácil (ej: @juancarlos)
  final String? displayName;
  final String? photoURL;
  final String? defaultTimezone;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final bool isAdmin; // Indica si el usuario es administrador de la plataforma

  const UserModel({
    required this.id,
    required this.email,
    this.username, // Opcional, usado para búsqueda y identificación amigable
    this.displayName,
    this.photoURL,
    this.defaultTimezone,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.isAdmin = false, // Por defecto, los usuarios no son administradores
  });

  // Factory constructor para crear desde Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      defaultTimezone: data['defaultTimezone'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  // Factory constructor para crear desde Firebase Auth User
  factory UserModel.fromFirebaseAuth(fb_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: null, // Username se asigna después de registro
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      defaultTimezone: null,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
      isAdmin: false,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    final usernameLower = username?.toLowerCase();
    return {
      'email': email,
      'username': username,
      'usernameLower': usernameLower,
      'displayName': displayName,
      'photoURL': photoURL,
      if (defaultTimezone != null) 'defaultTimezone': defaultTimezone,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
      'isAdmin': isAdmin,
    };
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? photoURL,
    String? defaultTimezone,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      defaultTimezone: defaultTimezone ?? this.defaultTimezone,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, displayName: $displayName, defaultTimezone: $defaultTimezone)';
  }
  
  // Getter para mostrar nombre amigable
  String get displayIdentifier {
    if (username != null && username!.isNotEmpty) {
      return '@$username';
    }
    return displayName ?? email;
  }
}
