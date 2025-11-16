import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para participantes que se apuntan a eventos individuales
/// 
/// Este modelo permite que los participantes del plan se apunten a eventos específicos
/// dentro del plan, independientemente de su participación en el plan completo.
/// 
/// Ejemplo: Plan "Partidas de Padel 2024" → Evento "Partido domingo 15" 
/// → Los participantes se apuntan a ese evento específico
/// 
/// Soporta dos modos:
/// - Registro voluntario (T117): el participante se apunta voluntariamente
/// - Confirmación obligatoria (T120 Fase 2): el evento requiere confirmación explícita
class EventParticipant {
  final String? id;
  final String eventId;
  final String userId;
  final DateTime registeredAt;
  final String? status; // 'registered', 'cancelled' (para cancelaciones futuras)
  // NUEVO: estado de confirmación para eventos que requieren confirmación (T120 Fase 2)
  // null = no aplica (evento no requiere confirmación), 'pending' = pendiente, 'confirmed' = confirmado, 'declined' = declinado
  final String? confirmationStatus;
  final String? _adminCreatedBy; // Campo administrativo: ID del usuario que creó este registro (no expuesto al cliente)

  const EventParticipant({
    this.id,
    required this.eventId,
    required this.userId,
    required this.registeredAt,
    this.status, // null = 'registered' por defecto
    this.confirmationStatus, // null = no aplica, 'pending' = pendiente, 'confirmed' = confirmado, 'declined' = declinado
    String? adminCreatedBy, // Campo administrativo interno
  }) : _adminCreatedBy = adminCreatedBy;

  // Crear desde Firestore
  factory EventParticipant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventParticipant(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'registered', // 'registered' por defecto
      confirmationStatus: data['confirmationStatus'], // null por defecto (compatibilidad hacia atrás)
      adminCreatedBy: data['_adminCreatedBy'], // Campo administrativo
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'registeredAt': Timestamp.fromDate(registeredAt),
      if (status != null) 'status': status,
      if (confirmationStatus != null) 'confirmationStatus': confirmationStatus,
      if (_adminCreatedBy != null) '_adminCreatedBy': _adminCreatedBy, // Campo administrativo
    };
  }

  // Copiar con cambios
  EventParticipant copyWith({
    String? id,
    String? eventId,
    String? userId,
    DateTime? registeredAt,
    String? status,
    String? confirmationStatus,
    String? adminCreatedBy,
  }) {
    return EventParticipant(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
      confirmationStatus: confirmationStatus ?? this.confirmationStatus,
      adminCreatedBy: adminCreatedBy ?? this._adminCreatedBy,
    );
  }

  // Getters útiles
  bool get isRegistered => status == 'registered' || status == null;
  bool get isCancelled => status == 'cancelled';
  
  // Getters para confirmación (T120 Fase 2)
  bool get needsConfirmation => confirmationStatus == 'pending';
  bool get isConfirmed => confirmationStatus == 'confirmed';
  bool get isDeclined => confirmationStatus == 'declined';
  bool get hasConfirmationStatus => confirmationStatus != null;

  // Comparación y hash
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventParticipant &&
        other.id == id &&
        other.eventId == eventId &&
        other.userId == userId &&
        other.registeredAt == registeredAt &&
        other.status == status &&
        other.confirmationStatus == confirmationStatus;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        eventId.hashCode ^
        userId.hashCode ^
        registeredAt.hashCode ^
        (status?.hashCode ?? 0) ^
        (confirmationStatus?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'EventParticipant(id: $id, eventId: $eventId, userId: $userId, registeredAt: $registeredAt, status: $status, confirmationStatus: $confirmationStatus)';
  }
}

