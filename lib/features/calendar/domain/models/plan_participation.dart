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
  final String? status; // 'pending', 'accepted', 'rejected', 'expired' (para invitaciones)
  final String? _adminCreatedBy; // Campo administrativo: ID del usuario que creó este registro (no expuesto al cliente)

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
    this.status, // null para participaciones antiguas (aceptadas por defecto)
    String? adminCreatedBy, // Campo administrativo interno
  }) : _adminCreatedBy = adminCreatedBy;

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
      status: data['status'], // null por defecto para compatibilidad hacia atrás
      adminCreatedBy: data['_adminCreatedBy'], // Campo administrativo
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
      if (status != null) 'status': status,
      if (_adminCreatedBy != null) '_adminCreatedBy': _adminCreatedBy, // Campo administrativo
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
    String? status,
    String? adminCreatedBy,
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
      status: status ?? this.status,
      adminCreatedBy: adminCreatedBy ?? this._adminCreatedBy,
    );
  }

  // Getters útiles
  bool get isOrganizer => role == 'organizer';
  bool get isParticipant => role == 'participant';
  bool get isObserver => role == 'observer';
  
  // Getters para estados de invitación
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted' || status == null; // null = aceptado por defecto (compatibilidad)
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired';
  bool get needsResponse => status == 'pending' || status == null; // null = antiguos, necesitan aceptar por retrocompatibilidad
  
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
        other.lastActiveAt == lastActiveAt &&
        other.status == status;
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
        (lastActiveAt?.hashCode ?? 0) ^
        (status?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'PlanParticipation(id: $id, planId: $planId, userId: $userId, role: $role, personalTimezone: $personalTimezone, isActive: $isActive, status: $status)';
  }
}
