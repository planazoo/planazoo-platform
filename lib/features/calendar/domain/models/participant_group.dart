import 'package:cloud_firestore/cloud_firestore.dart';

/// T123: Modelo para grupos reutilizables de participantes
/// Permite crear grupos (Familia, Amigos, etc.) que pueden ser invitados colectivamente a planes
class ParticipantGroup {
  final String? id;
  final String userId; // Propietario del grupo
  final String name; // "Familia Ramos", "Amigos Universidad"
  final String? description;
  final String? icon; // Emoji o icono (opcional)
  final String? color; // Color identificador (opcional)
  final List<String> memberUserIds; // IDs de usuarios registrados en el grupo
  final List<String> memberEmails; // Emails de usuarios no registrados en el grupo
  final DateTime createdAt;
  final DateTime updatedAt;

  const ParticipantGroup({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    this.icon,
    this.color,
    required this.memberUserIds,
    required this.memberEmails,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear desde Firestore
  factory ParticipantGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParticipantGroup(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      icon: data['icon'],
      color: data['color'],
      memberUserIds: List<String>.from(data['memberUserIds'] ?? []),
      memberEmails: List<String>.from(data['memberEmails'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      'memberUserIds': memberUserIds,
      'memberEmails': memberEmails,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Copiar con cambios
  ParticipantGroup copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    String? color,
    List<String>? memberUserIds,
    List<String>? memberEmails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParticipantGroup(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      memberUserIds: memberUserIds ?? this.memberUserIds,
      memberEmails: memberEmails ?? this.memberEmails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Obtener total de miembros (usuarios + emails)
  int get totalMembers => memberUserIds.length + memberEmails.length;

  /// Verificar si el grupo está vacío
  bool get isEmpty => memberUserIds.isEmpty && memberEmails.isEmpty;

  /// Comparación y hash
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParticipantGroup &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.description == description &&
        other.icon == icon &&
        other.color == color &&
        _listEquals(other.memberUserIds, memberUserIds) &&
        _listEquals(other.memberEmails, memberEmails) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        (description?.hashCode ?? 0) ^
        (icon?.hashCode ?? 0) ^
        (color?.hashCode ?? 0) ^
        memberUserIds.hashCode ^
        memberEmails.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  /// Comparar dos listas
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'ParticipantGroup(id: $id, userId: $userId, name: $name, members: ${totalMembers})';
  }
}

