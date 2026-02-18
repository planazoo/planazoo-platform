import 'package:cloud_firestore/cloud_firestore.dart';

/// T219: Aporte de un participante al bote común del plan
class KittyContribution {
  final String? id;
  final String planId;
  final String participantId;
  final double amount;
  final DateTime contributionDate;
  final String? concept;
  final String? registeredBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KittyContribution({
    this.id,
    required this.planId,
    required this.participantId,
    required this.amount,
    required this.contributionDate,
    this.concept,
    this.registeredBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KittyContribution.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KittyContribution(
      id: doc.id,
      planId: data['planId'] ?? '',
      participantId: data['participantId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      contributionDate: (data['contributionDate'] as Timestamp).toDate(),
      concept: data['concept'],
      registeredBy: data['registeredBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'participantId': participantId,
      'amount': amount,
      'contributionDate': Timestamp.fromDate(contributionDate),
      if (concept != null) 'concept': concept,
      if (registeredBy != null) 'registeredBy': registeredBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  KittyContribution copyWith({
    String? id,
    String? planId,
    String? participantId,
    double? amount,
    DateTime? contributionDate,
    String? concept,
    String? registeredBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KittyContribution(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      participantId: participantId ?? this.participantId,
      amount: amount ?? this.amount,
      contributionDate: contributionDate ?? this.contributionDate,
      concept: concept ?? this.concept,
      registeredBy: registeredBy ?? this.registeredBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
