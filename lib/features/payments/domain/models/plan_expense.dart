import 'package:cloud_firestore/cloud_firestore.dart';

/// Gastos tipo Tricount: quién pagó, importe, concepto, reparto entre participantes.
/// Integra con BalanceService para coste por participante y lo pagado por el pagador.
class PlanExpense {
  final String? id;
  final String planId;
  /// Quién pagó (userId).
  final String payerId;
  final double amount;
  final String? concept;
  final DateTime expenseDate;
  /// Participantes entre los que se reparte el gasto (userIds).
  final List<String> participantIds;
  /// true = reparto igual; false = usar customShares.
  final bool equalSplit;
  /// Si equalSplit es false: parte por userId. La suma debe ser amount.
  final Map<String, double>? customShares;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? registeredBy;
  /// Evento del plan al que se asocia el gasto (lista §3.2 ítem 102).
  final String? eventId;

  const PlanExpense({
    this.id,
    required this.planId,
    required this.payerId,
    required this.amount,
    this.concept,
    required this.expenseDate,
    required this.participantIds,
    this.equalSplit = true,
    this.customShares,
    required this.createdAt,
    required this.updatedAt,
    this.registeredBy,
    this.eventId,
  });

  /// Parte que corresponde a un participante (coste asignado).
  double shareFor(String userId) {
    if (!participantIds.contains(userId)) return 0.0;
    if (equalSplit && participantIds.isNotEmpty) {
      return amount / participantIds.length;
    }
    return customShares?[userId] ?? 0.0;
  }

  factory PlanExpense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final customSharesRaw = data['customShares'];
    Map<String, double>? customShares;
    if (customSharesRaw is Map) {
      customShares = customSharesRaw.map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    }
    return PlanExpense(
      id: doc.id,
      planId: data['planId'] ?? '',
      payerId: data['payerId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      concept: data['concept'],
      expenseDate: (data['expenseDate'] as Timestamp).toDate(),
      participantIds: List<String>.from(data['participantIds'] ?? []),
      equalSplit: data['equalSplit'] ?? true,
      customShares: customShares,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      registeredBy: data['registeredBy'],
      eventId: data['eventId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'payerId': payerId,
      'amount': amount,
      if (concept != null && concept!.isNotEmpty) 'concept': concept,
      'expenseDate': Timestamp.fromDate(expenseDate),
      'participantIds': participantIds,
      'equalSplit': equalSplit,
      if (customShares != null && customShares!.isNotEmpty)
        'customShares': customShares!.map((k, v) => MapEntry(k, v)),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (registeredBy != null) 'registeredBy': registeredBy,
      if (eventId != null && eventId!.isNotEmpty) 'eventId': eventId,
    };
  }

  PlanExpense copyWith({
    String? id,
    String? planId,
    String? payerId,
    double? amount,
    String? concept,
    DateTime? expenseDate,
    List<String>? participantIds,
    bool? equalSplit,
    Map<String, double>? customShares,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? registeredBy,
    String? eventId,
  }) {
    return PlanExpense(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      payerId: payerId ?? this.payerId,
      amount: amount ?? this.amount,
      concept: concept ?? this.concept,
      expenseDate: expenseDate ?? this.expenseDate,
      participantIds: participantIds ?? this.participantIds,
      equalSplit: equalSplit ?? this.equalSplit,
      customShares: customShares ?? this.customShares,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      registeredBy: registeredBy ?? this.registeredBy,
      eventId: eventId ?? this.eventId,
    );
  }
}
