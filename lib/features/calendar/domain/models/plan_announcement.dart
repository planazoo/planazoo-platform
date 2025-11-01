import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para representar un aviso publicado en un plan
/// 
/// Los avisos son mensajes unidireccionales que cualquier participante del plan
/// puede publicar. Todos los participantes pueden leer los avisos del plan.
class PlanAnnouncement {
  final String? id;
  final String planId;
  final String userId; // ID del usuario que publica el aviso
  final String message; // Contenido del aviso (max 1000 caracteres)
  final String? type; // Tipo opcional: 'info', 'urgent', 'important'
  final DateTime createdAt;

  const PlanAnnouncement({
    this.id,
    required this.planId,
    required this.userId,
    required this.message,
    this.type,
    required this.createdAt,
  });

  /// Crear desde Firestore
  factory PlanAnnouncement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlanAnnouncement(
      id: doc.id,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      type: data['type'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'userId': userId,
      'message': message,
      if (type != null) 'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Copiar con cambios
  PlanAnnouncement copyWith({
    String? id,
    String? planId,
    String? userId,
    String? message,
    String? type,
    DateTime? createdAt,
  }) {
    return PlanAnnouncement(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanAnnouncement &&
        other.id == id &&
        other.planId == planId &&
        other.userId == userId &&
        other.message == message &&
        other.type == type &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        planId.hashCode ^
        userId.hashCode ^
        message.hashCode ^
        type.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'PlanAnnouncement(id: $id, planId: $planId, userId: $userId, message: ${message.length > 50 ? message.substring(0, 50) + "..." : message}, type: $type, createdAt: $createdAt)';
  }
}

