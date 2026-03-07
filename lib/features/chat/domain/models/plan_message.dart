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
  /// Reacciones: emoji -> lista de userIds que pusieron esa reacción (ej. "👍" -> [id1, id2])
  /// Nullable por compatibilidad con mensajes cargados antes de existir este campo (hot reload / datos antiguos).
  final Map<String, List<String>>? reactions;

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
    this.reactions,
  });

  /// Reacciones; nunca null (vacío si no hay).
  Map<String, List<String>> get reactionsOrEmpty => reactions ?? const {};

  /// Devuelve las reacciones de forma segura. Usar en UI por si el mensaje
  /// viene de una instancia antigua (hot reload) donde el campo puede fallar al leer.
  static Map<String, List<String>> safeReactions(PlanMessage message) {
    try {
      return message.reactions ?? const {};
    } catch (_) {
      return const {};
    }
  }

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
      reactions: PlanMessage.parseReactions(data['reactions']),
    );
  }

  static Map<String, List<String>> parseReactions(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    final map = <String, List<String>>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      final list = entry.value;
      if (list is List) {
        map[key] = list.map((e) => e.toString()).toList();
      }
    }
    return map;
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
      if (reactionsOrEmpty.isNotEmpty) 'reactions': reactionsOrEmpty.map((k, v) => MapEntry(k, v)),
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
    Map<String, List<String>>? reactions,
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
      reactions: reactions ?? this.reactions,
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
