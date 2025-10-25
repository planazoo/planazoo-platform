import 'package:cloud_firestore/cloud_firestore.dart';

class PlanParticipation {
  final String? id;
  final String planId;
  final String userId;
  final String role; // 'organizer', 'participant', 'observer'
  final String? personalTimezone; // IANA timezone personal del participante
  final DateTime joinedAt;
  final bool isActive;
  final String? invitedBy; // ID del usuario que invitó
  final DateTime? lastActiveAt;

  const PlanParticipation({
    this.id,
    required this.planId,
    required this.userId,
    required this.role,
    this.personalTimezone,
    required this.joinedAt,
    this.isActive = true,
    this.invitedBy,
    this.lastActiveAt,
  });

  // Crear desde Firestore
  factory PlanParticipation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlanParticipation(
      id: doc.id,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      role: data['role'] ?? 'participant',
      personalTimezone: data['personalTimezone'],
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      invitedBy: data['invitedBy'],
      lastActiveAt: data['lastActiveAt'] != null 
          ? (data['lastActiveAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'userId': userId,
      'role': role,
      if (personalTimezone != null) 'personalTimezone': personalTimezone,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isActive': isActive,
      if (invitedBy != null) 'invitedBy': invitedBy,
      if (lastActiveAt != null) 'lastActiveAt': Timestamp.fromDate(lastActiveAt!),
    };
  }

  // Copiar con cambios
  PlanParticipation copyWith({
    String? id,
    String? planId,
    String? userId,
    String? role,
    String? personalTimezone,
    DateTime? joinedAt,
    bool? isActive,
    String? invitedBy,
    DateTime? lastActiveAt,
  }) {
    return PlanParticipation(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      personalTimezone: personalTimezone ?? this.personalTimezone,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      invitedBy: invitedBy ?? this.invitedBy,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  // Getters útiles
  bool get isOrganizer => role == 'organizer';
  bool get isParticipant => role == 'participant';
  bool get isObserver => role == 'observer';
  
  // Comparación y hash
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanParticipation &&
        other.id == id &&
        other.planId == planId &&
        other.userId == userId &&
        other.role == role &&
        other.personalTimezone == personalTimezone &&
        other.joinedAt == joinedAt &&
        other.isActive == isActive &&
        other.invitedBy == invitedBy &&
        other.lastActiveAt == lastActiveAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        planId.hashCode ^
        userId.hashCode ^
        role.hashCode ^
        (personalTimezone?.hashCode ?? 0) ^
        joinedAt.hashCode ^
        isActive.hashCode ^
        (invitedBy?.hashCode ?? 0) ^
        (lastActiveAt?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'PlanParticipation(id: $id, planId: $planId, userId: $userId, role: $role, personalTimezone: $personalTimezone, isActive: $isActive)';
  }
}
