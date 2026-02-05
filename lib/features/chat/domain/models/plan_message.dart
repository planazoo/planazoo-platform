import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para representar un mensaje en el chat del plan
/// 
/// Los mensajes son bidireccionales: cualquier participante del plan
/// puede enviar y recibir mensajes. Los mensajes se muestran en tiempo real.
class PlanMessage {
  final String? id;
  final String planId;
  final String userId; // ID del usuario que envía el mensaje
  final String message; // Contenido del mensaje (max 5000 caracteres)
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? editedAt; // Timestamp si el mensaje fue editado
  final DateTime? deletedAt; // Timestamp si el mensaje fue eliminado
  final List<String> readBy; // Lista de userIds que han leído el mensaje
  final String? replyTo; // ID del mensaje al que responde (opcional)

  const PlanMessage({
    this.id,
    required this.planId,
    required this.userId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    this.editedAt,
    this.deletedAt,
    this.readBy = const [],
    this.replyTo,
  });

  /// Crear desde Firestore
  factory PlanMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Manejar createdAt - puede ser Timestamp o null
    DateTime createdAt;
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }
    
    // Manejar updatedAt - puede ser Timestamp o null
    DateTime updatedAt;
    if (data['updatedAt'] != null) {
      if (data['updatedAt'] is Timestamp) {
        updatedAt = (data['updatedAt'] as Timestamp).toDate();
      } else {
        updatedAt = DateTime.now();
      }
    } else {
      updatedAt = createdAt;
    }
    
    return PlanMessage(
      id: doc.id,
      planId: data['planId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      editedAt: data['editedAt'] != null && data['editedAt'] is Timestamp
          ? (data['editedAt'] as Timestamp).toDate()
          : null,
      deletedAt: data['deletedAt'] != null && data['deletedAt'] is Timestamp
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      readBy: data['readBy'] != null
          ? List<String>.from(data['readBy'])
          : [],
      replyTo: data['replyTo']?.toString(),
    );
  }

  /// Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'userId': userId,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (editedAt != null) 'editedAt': Timestamp.fromDate(editedAt!),
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
      'readBy': readBy,
      if (replyTo != null) 'replyTo': replyTo,
    };
  }

  /// Copiar con cambios
  PlanMessage copyWith({
    String? id,
    String? planId,
    String? userId,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<String>? readBy,
    String? replyTo,
  }) {
    return PlanMessage(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      readBy: readBy ?? this.readBy,
      replyTo: replyTo ?? this.replyTo,
    );
  }

  /// Verificar si el mensaje está eliminado
  bool get isDeleted => deletedAt != null;

  /// Verificar si el mensaje fue editado
  bool get isEdited => editedAt != null;

  /// Verificar si un usuario específico ha leído el mensaje
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  @override
  String toString() {
    return 'PlanMessage(id: $id, planId: $planId, userId: $userId, message: ${message.length > 50 ? "${message.substring(0, 50)}..." : message}, createdAt: $createdAt)';
  }
}
