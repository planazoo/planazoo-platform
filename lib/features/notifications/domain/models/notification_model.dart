import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de notificaciones
enum NotificationType {
  announcement, // Nuevo aviso en un plan
  eventCreated, // Nuevo evento creado
  eventUpdated, // Evento modificado
  eventDeleted, // Evento eliminado
  invitation, // Invitación a un plan
  invitationAccepted, // Invitación aceptada
  invitationRejected, // Invitación rechazada
  planStateChanged, // Estado del plan cambió
  participantAdded, // Nuevo participante añadido
  participantRemoved, // Participante eliminado
  alarm, // Alarma/recordatorio de evento
}

/// Modelo para representar una notificación del usuario
/// 
/// Las notificaciones se guardan en Firestore: users/{userId}/notifications/{notificationId}
class NotificationModel {
  final String? id;
  final String userId; // Usuario que recibe la notificación
  final NotificationType type;
  final String title;
  final String body;
  final String? planId; // ID del plan relacionado (opcional)
  final String? eventId; // ID del evento relacionado (opcional)
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // Datos adicionales (opcional)

  const NotificationModel({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.planId,
    this.eventId,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  /// Crear desde Firestore
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.announcement,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      planId: data['planId'],
      eventId: data['eventId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      data: data['data'] != null ? Map<String, dynamic>.from(data['data']) : null,
    );
  }

  /// Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      if (planId != null) 'planId': planId,
      if (eventId != null) 'eventId': eventId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      if (data != null) 'data': data,
    };
  }

  /// Copiar con cambios
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? planId,
    String? eventId,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      planId: planId ?? this.planId,
      eventId: eventId ?? this.eventId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.title == title &&
        other.body == body &&
        other.planId == planId &&
        other.eventId == eventId &&
        other.isRead == isRead &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        type.hashCode ^
        title.hashCode ^
        body.hashCode ^
        planId.hashCode ^
        eventId.hashCode ^
        isRead.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: ${type.name}, title: $title, isRead: $isRead)';
  }
}
