import 'package:cloud_firestore/cloud_firestore.dart';

class Plan {
  final String? id;
  final String name;
  final String unpId;
  final String userId;
  final DateTime baseDate;
  final DateTime startDate;
  final DateTime endDate;
  final int columnCount;
  final String? accommodation;
  final String? description;
  final double? budget;
  final int? participants;
  final String? imageUrl;
  final String? state; // borrador, planificando, confirmado, en_curso, finalizado, cancelado
  final String? visibility; // private, public
  final String? timezone; // IANA timezone (ej: "Europe/Madrid")
  final String currency; // T153: Código ISO de moneda (EUR, USD, GBP, JPY, etc.) - default: EUR
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime savedAt;

  const Plan({
    this.id,
    required this.name,
    required this.unpId,
    required this.userId,
    required this.baseDate,
    required this.startDate,
    required this.endDate,
    required this.columnCount,
    this.accommodation,
    this.description,
    this.budget,
    this.participants,
    this.imageUrl,
    this.state,
    this.visibility,
    this.timezone,
    this.currency = 'EUR', // T153: Default EUR
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
      userId: data['userId'] ?? '',
      baseDate: baseDate,
      startDate: startDate,
      endDate: endDate,
      columnCount: columnCount,
      accommodation: data['accommodation'],
      description: data['description'],
      budget: data['budget']?.toDouble(),
      participants: data['participants'],
      imageUrl: data['imageUrl'],
      state: data['state'] ?? 'borrador', // Default a borrador si no existe
      visibility: data['visibility'] ?? 'private', // Default a privado
      timezone: data['timezone'],
      currency: data['currency'] ?? 'EUR', // T153: Default EUR para migración
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
      'userId': userId,
      'baseDate': Timestamp.fromDate(baseDate),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'columnCount': columnCount,
      'accommodation': accommodation,
      'description': description,
      'budget': budget,
      'participants': participants,
      'imageUrl': imageUrl,
      'state': state ?? 'borrador', // Default a borrador
      'visibility': visibility ?? 'private', // Default a privado
      'timezone': timezone,
      'currency': currency, // T153
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
    String? userId,
    DateTime? baseDate,
    DateTime? startDate,
    DateTime? endDate,
    int? columnCount,
    String? accommodation,
    String? description,
    double? budget,
    int? participants,
    String? imageUrl,
    String? state,
    String? visibility,
    String? timezone,
    String? currency, // T153
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? savedAt,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      unpId: unpId ?? this.unpId,
      userId: userId ?? this.userId,
      baseDate: baseDate ?? this.baseDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      columnCount: columnCount ?? this.columnCount,
      accommodation: accommodation ?? this.accommodation,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      participants: participants ?? this.participants,
      imageUrl: imageUrl ?? this.imageUrl,
      state: state ?? this.state,
      visibility: visibility ?? this.visibility,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency, // T153
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
        other.imageUrl == imageUrl &&
        other.currency == currency && // T153
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
        imageUrl.hashCode ^
        state.hashCode ^
        visibility.hashCode ^
        timezone.hashCode ^
        currency.hashCode ^ // T153
        createdAt.hashCode ^
        updatedAt.hashCode ^
        savedAt.hashCode;
  }
} 