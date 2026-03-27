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
  final String? state; // planificando, confirmado, en_curso, finalizado, cancelado (borrador unificado con planificando)
  final String? visibility; // private, public
  final String? timezone; // IANA timezone (ej: "Europe/Madrid")
  /// Texto libre: correos con agencias, proveedores, etc. (P20 lista puntos).
  final String? referenceNotes;
  /// Archivos adjuntos del plan (PDF/JPG/PNG).
  final List<PlanAttachment> attachments;
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
    this.referenceNotes,
    this.attachments = const [],
    this.currency = 'EUR', // T153: Default EUR
    required this.createdAt,
    required this.updatedAt,
    required this.savedAt,
  });

  // Crear desde Firestore
  factory Plan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final baseDateRaw = (data['baseDate'] as Timestamp).toDate();
    final baseDate = DateTime(baseDateRaw.year, baseDateRaw.month, baseDateRaw.day);
    final columnCount = (data['columnCount'] as num?)?.toInt() ?? 1;

    // Preferir startDate/endDate guardados (fuente de verdad al editar el plan).
    // Fallback histórico: derivar fin desde baseDate + columnCount.
    final DateTime startDate;
    final DateTime endDate;
    if (data['startDate'] is Timestamp && data['endDate'] is Timestamp) {
      final s = (data['startDate'] as Timestamp).toDate();
      final e = (data['endDate'] as Timestamp).toDate();
      startDate = DateTime(s.year, s.month, s.day);
      endDate = DateTime(e.year, e.month, e.day);
    } else {
      startDate = baseDate;
      endDate = baseDate.add(Duration(days: columnCount - 1));
    }
    
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
      state: data['state'] ?? 'planificando', // Default a planificando (borrador eliminado)
      visibility: data['visibility'] ?? 'private', // Default a privado
      timezone: data['timezone'],
      referenceNotes: data['referenceNotes'] as String?,
      attachments: (data['attachments'] as List<dynamic>?)
              ?.map((item) => PlanAttachment.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const [],
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
      'state': state ?? 'planificando', // Default a planificando
      'visibility': visibility ?? 'private', // Default a privado
      'timezone': timezone,
      if (referenceNotes != null) 'referenceNotes': referenceNotes,
      if (attachments.isNotEmpty)
        'attachments': attachments.map((attachment) => attachment.toMap()).toList(),
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
    String? referenceNotes,
    List<PlanAttachment>? attachments,
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
      referenceNotes: referenceNotes ?? this.referenceNotes,
      attachments: attachments ?? this.attachments,
      currency: currency ?? this.currency, // T153
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  // Getters útiles
  /// Días inclusivos [startDate, endDate] como fechas civiles.
  /// No usar [DateTime.difference] directamente entre medianoches locales: al cruzar el cambio
  /// de hora de verano (p. ej. último domingo de marzo en EU) `.inDays` puede quedar corto en 1.
  int get durationInDays => Plan.calendarDaysInclusive(startDate, endDate);

  /// Número de días de calendario entre dos fechas (inclusivo ambos extremos).
  static int calendarDaysInclusive(DateTime start, DateTime end) {
    final s = DateTime.utc(start.year, start.month, start.day);
    final e = DateTime.utc(end.year, end.month, end.day);
    return e.difference(s).inDays + 1;
  }

  /// Día 1 = primer día del plan ([startDate] como fecha civil). Inmune a DST (no usar `Duration(days:)`).
  DateTime dateForPlanDayIndex(int oneBasedIndex) {
    if (oneBasedIndex < 1) {
      return DateTime(startDate.year, startDate.month, startDate.day);
    }
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    return DateTime(s.year, s.month, s.day + (oneBasedIndex - 1));
  }

  /// Índice 1-based del día del plan para [date] (solo año/mes/día). Coherente con [durationInDays] y DST.
  int planDayIndexForDate(DateTime date) {
    final a = DateTime(startDate.year, startDate.month, startDate.day);
    final b = DateTime(date.year, date.month, date.day);
    return Plan.calendarDaysInclusive(a, b);
  }
  
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
        other.state == state &&
        other.visibility == visibility &&
        other.timezone == timezone &&
        other.referenceNotes == referenceNotes &&
        other.attachments == attachments &&
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
        referenceNotes.hashCode ^
        attachments.hashCode ^
        currency.hashCode ^ // T153
        createdAt.hashCode ^
        updatedAt.hashCode ^
        savedAt.hashCode;
  }
}

class PlanAttachment {
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime uploadedAt;

  const PlanAttachment({
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
  });

  factory PlanAttachment.fromMap(Map<String, dynamic> map) {
    final uploadedAtRaw = map['uploadedAt'];
    final uploadedAt = uploadedAtRaw is Timestamp
        ? uploadedAtRaw.toDate()
        : DateTime.tryParse(uploadedAtRaw?.toString() ?? '') ?? DateTime.now();
    return PlanAttachment(
      name: map['name']?.toString() ?? 'archivo',
      url: map['url']?.toString() ?? '',
      type: map['type']?.toString() ?? 'application/octet-stream',
      size: (map['size'] as num?)?.toInt() ?? 0,
      uploadedAt: uploadedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'type': type,
      'size': size,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanAttachment &&
        other.name == name &&
        other.url == url &&
        other.type == type &&
        other.size == size &&
        other.uploadedAt == uploadedAt;
  }

  @override
  int get hashCode {
    return Object.hash(name, url, type, size, uploadedAt);
  }
}