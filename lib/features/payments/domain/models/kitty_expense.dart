import 'package:cloud_firestore/cloud_firestore.dart';

/// T219: Gasto pagado desde el bote común (repartido entre participantes)
class KittyExpense {
  final String? id;
  final String planId;
  final double amount;
  final DateTime expenseDate;
  final String concept;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KittyExpense({
    this.id,
    required this.planId,
    required this.amount,
    required this.expenseDate,
    required this.concept,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KittyExpense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KittyExpense(
      id: doc.id,
      planId: data['planId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      expenseDate: (data['expenseDate'] as Timestamp).toDate(),
      concept: data['concept'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'amount': amount,
      'expenseDate': Timestamp.fromDate(expenseDate),
      'concept': concept,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  KittyExpense copyWith({
    String? id,
    String? planId,
    double? amount,
    DateTime? expenseDate,
    String? concept,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KittyExpense(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      concept: concept ?? this.concept,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
