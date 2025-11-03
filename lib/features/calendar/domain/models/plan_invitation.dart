import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para invitaciones a planes por email (T104)
/// 
/// Permite invitar a usuarios que aún no tienen cuenta o que no conocemos su ID
/// mediante un link único con token que expira en 7 días.
class PlanInvitation {
  final String? id;
  final String planId;
  final String email; // Email del invitado
  final String token; // Token único para el link
  final String? invitedBy; // ID del usuario que envía la invitación
  final String? role; // Rol propuesto: 'participant' o 'observer'
  final String? customMessage; // Mensaje personalizado opcional
  final DateTime createdAt;
  final DateTime expiresAt; // Fecha de expiración (7 días por defecto)
  final String? status; // 'pending', 'accepted', 'rejected', 'expired'
  final DateTime? respondedAt; // Fecha en que se respondió la invitación

  const PlanInvitation({
    this.id,
    required this.planId,
    required this.email,
    required this.token,
    this.invitedBy,
    this.role = 'participant',
    this.customMessage,
    required this.createdAt,
    required this.expiresAt,
    this.status = 'pending',
    this.respondedAt,
  });

  // Crear desde Firestore
  factory PlanInvitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlanInvitation(
      id: doc.id,
      planId: data['planId'] ?? '',
      email: data['email'] ?? '',
      token: data['token'] ?? '',
      invitedBy: data['invitedBy'],
      role: data['role'] ?? 'participant',
      customMessage: data['customMessage'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'email': email,
      'token': token,
      if (invitedBy != null) 'invitedBy': invitedBy,
      'role': role ?? 'participant',
      if (customMessage != null) 'customMessage': customMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status ?? 'pending',
      if (respondedAt != null) 'respondedAt': Timestamp.fromDate(respondedAt!),
    };
  }

  // Copiar con cambios
  PlanInvitation copyWith({
    String? id,
    String? planId,
    String? email,
    String? token,
    String? invitedBy,
    String? role,
    String? customMessage,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? status,
    DateTime? respondedAt,
  }) {
    return PlanInvitation(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      email: email ?? this.email,
      token: token ?? this.token,
      invitedBy: invitedBy ?? this.invitedBy,
      role: role ?? this.role,
      customMessage: customMessage ?? this.customMessage,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  // Getters útiles
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired' || DateTime.now().isAfter(expiresAt);
  bool get isValid => isPending && !isExpired;

  // Comparación y hash
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanInvitation &&
        other.id == id &&
        other.planId == planId &&
        other.email == email &&
        other.token == token &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        planId.hashCode ^
        email.hashCode ^
        token.hashCode ^
        (status?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'PlanInvitation(id: $id, planId: $planId, email: $email, token: $token, status: $status)';
  }
}


