import 'package:cloud_firestore/cloud_firestore.dart';

class Plan {
  final String? id;
  final String name;
  final String unpId;
  final DateTime baseDate;
  final DateTime startDate;
  final DateTime endDate;
  final int columnCount;
  final String? accommodation;
  final String? description;
  final double? budget;
  final int? participants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime savedAt;

  const Plan({
    this.id,
    required this.name,
    required this.unpId,
    required this.baseDate,
    required this.startDate,
    required this.endDate,
    required this.columnCount,
    this.accommodation,
    this.description,
    this.budget,
    this.participants,
    required this.createdAt,
    required this.updatedAt,
    required this.savedAt,
  });

  // Crear desde Firestore
  factory Plan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Calcular fechas de inicio y fin basadas en baseDate y columnCount
    final baseDate = (data['baseDate'] as Timestamp).toDate();
    final columnCount = data['columnCount'] ?? 1;
    final startDate = baseDate;
    final endDate = baseDate.add(Duration(days: columnCount - 1));
    
    return Plan(
      id: doc.id,
      name: data['name'] ?? '',
      unpId: data['unpId'] ?? '',
      baseDate: baseDate,
      startDate: startDate,
      endDate: endDate,
      columnCount: columnCount,
      accommodation: data['accommodation'],
      description: data['description'],
      budget: data['budget']?.toDouble(),
      participants: data['participants'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      savedAt: (data['savedAt'] as Timestamp).toDate(),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'unpId': unpId,
      'baseDate': Timestamp.fromDate(baseDate),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'columnCount': columnCount,
      'accommodation': accommodation,
      'description': description,
      'budget': budget,
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }

  // Copiar con cambios
  Plan copyWith({
    String? id,
    String? name,
    String? unpId,
    DateTime? baseDate,
    DateTime? startDate,
    DateTime? endDate,
    int? columnCount,
    String? accommodation,
    String? description,
    double? budget,
    int? participants,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? savedAt,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      unpId: unpId ?? this.unpId,
      baseDate: baseDate ?? this.baseDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      columnCount: columnCount ?? this.columnCount,
      accommodation: accommodation ?? this.accommodation,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  // Getters útiles
  int get durationInDays => endDate.difference(startDate).inDays + 1;
  
  bool isDateInPlanRange(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
           date.isBefore(endDate.add(const Duration(days: 1)));
  }

  // Comparación y hash
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plan &&
        other.id == id &&
        other.name == name &&
        other.unpId == unpId &&
        other.baseDate == baseDate &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.columnCount == columnCount &&
        other.accommodation == accommodation &&
        other.description == description &&
        other.budget == budget &&
        other.participants == participants &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.savedAt == savedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        unpId.hashCode ^
        baseDate.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        columnCount.hashCode ^
        accommodation.hashCode ^
        description.hashCode ^
        budget.hashCode ^
        participants.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        savedAt.hashCode;
  }
} 