import 'package:cloud_firestore/cloud_firestore.dart';

/// T102: Modelo de pago individual de un participante
class PersonalPayment {
  final String? id;
  final String planId;
  final String participantId; // Usuario que hizo el pago
  final String? eventId; // Evento asociado (opcional, null si es pago general del plan)
  final double amount; // Monto pagado
  final DateTime paymentDate; // Fecha del pago
  final String? paymentMethod; // Efectivo, Transferencia, Tarjeta, etc.
  final String? concept; // Concepto del pago (ej: "Billetes de vuelo")
  final String? description; // Descripción detallada
  final String status; // 'pending', 'paid', 'refunded'
  final String? registeredBy; // Usuario que registró el pago (puede ser diferente al que pagó)
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? _adminCreatedBy; // Campo administrativo: ID del usuario que creó este registro (no expuesto al cliente)

  const PersonalPayment({
    this.id,
    required this.planId,
    required this.participantId,
    this.eventId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.concept,
    this.description,
    this.status = 'paid', // Por defecto 'paid'
    this.registeredBy,
    required this.createdAt,
    required this.updatedAt,
    String? adminCreatedBy, // Campo administrativo interno
  }) : _adminCreatedBy = adminCreatedBy;

  /// Crear desde Firestore
  factory PersonalPayment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PersonalPayment(
      id: doc.id,
      planId: data['planId'] ?? '',
      participantId: data['participantId'] ?? '',
      eventId: data['eventId'],
      amount: (data['amount'] as num).toDouble(),
      paymentDate: (data['paymentDate'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'],
      concept: data['concept'],
      description: data['description'],
      status: data['status'] ?? 'paid',
      registeredBy: data['registeredBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      adminCreatedBy: data['_adminCreatedBy'], // Campo administrativo
    );
  }

  /// Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'participantId': participantId,
      if (eventId != null) 'eventId': eventId,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (concept != null) 'concept': concept,
      if (description != null) 'description': description,
      'status': status,
      if (registeredBy != null) 'registeredBy': registeredBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (_adminCreatedBy != null) '_adminCreatedBy': _adminCreatedBy, // Campo administrativo
    };
  }

  PersonalPayment copyWith({
    String? id,
    String? planId,
    String? participantId,
    String? eventId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? concept,
    String? description,
    String? status,
    String? registeredBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminCreatedBy,
  }) {
    return PersonalPayment(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      participantId: participantId ?? this.participantId,
      eventId: eventId ?? this.eventId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      concept: concept ?? this.concept,
      description: description ?? this.description,
      status: status ?? this.status,
      registeredBy: registeredBy ?? this.registeredBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminCreatedBy: adminCreatedBy ?? this._adminCreatedBy,
    );
  }

  // Getters útiles
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isRefunded => status == 'refunded';
  bool get isForEvent => eventId != null && eventId!.isNotEmpty;
  bool get isGeneralPayment => eventId == null || eventId!.isEmpty;
}


