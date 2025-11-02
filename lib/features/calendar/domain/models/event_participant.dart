import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para participantes que se apuntan a eventos individuales
/// 
/// Este modelo permite que los participantes del plan se apunten a eventos específicos
/// dentro del plan, independientemente de su participación en el plan completo.
/// 
/// Ejemplo: Plan "Partidas de Padel 2024" → Evento "Partido domingo 15" 
/// → Los participantes se apuntan a ese evento específico
class EventParticipant {
  final String? id;
  final String eventId;
  final String userId;
  final DateTime registeredAt;
  final String? status; // 'registered', 'cancelled' (para cancelaciones futuras)

  const EventParticipant({
    this.id,
    required this.eventId,
    required this.userId,
    required this.registeredAt,
    this.status, // null = 'registered' por defecto
  });

  // Crear desde Firestore
  factory EventParticipant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventParticipant(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'registered', // 'registered' por defecto
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'registeredAt': Timestamp.fromDate(registeredAt),
      if (status != null) 'status': status,
    };
  }

  // Copiar con cambios
  EventParticipant copyWith({
    String? id,
    String? eventId,
    String? userId,
    DateTime? registeredAt,
    String? status,
  }) {
    return EventParticipant(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
    );
  }

  // Getters útiles
  bool get isRegistered => status == 'registered' || status == null;
  bool get isCancelled => status == 'cancelled';

  // Comparación y hash
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventParticipant &&
        other.id == id &&
        other.eventId == eventId &&
        other.userId == userId &&
        other.registeredAt == registeredAt &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        eventId.hashCode ^
        userId.hashCode ^
        registeredAt.hashCode ^
        (status?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'EventParticipant(id: $id, eventId: $eventId, userId: $userId, registeredAt: $registeredAt, status: $status)';
  }
}

