import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  final String planId;
  final String userId; // nuevo: ID del usuario propietario
  final DateTime date;
  final int hour;
  final int duration; // Duración en horas
  final String description;
  final String? color;
  final String? typeFamily; // nueva: familia (desplazamiento, restauracion, actividad)
  final String? typeSubtype; // nueva: subtipo (taxi, avion, comida, museo...)
  final Map<String, dynamic>? details; // nueva: detalles específicos por tipo
  final List<EventDocument>? documents; // nueva: documentos adjuntos
  final bool isDraft; // nuevo: indica si el evento es un borrador
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    this.id,
    required this.planId,
    required this.userId,
    required this.date,
    required this.hour,
    required this.duration,
    required this.description,
    this.color,
    this.typeFamily,
    this.typeSubtype,
    this.details,
    this.documents,
    this.isDraft = false, // por defecto no es borrador
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      hour: data['hour'] ?? 0,
      duration: data['duration'] ?? 1,
      description: data['description'] ?? '',
      color: data['color'],
      typeFamily: data['typeFamily'],
      typeSubtype: data['typeSubtype'],
      details: (data['details'] as Map<String, dynamic>?),
      documents: (data['documents'] as List<dynamic>?)
          ?.map((doc) => EventDocument.fromMap(doc))
          .toList(),
      isDraft: data['isDraft'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'hour': hour,
      'duration': duration,
      'description': description,
      'color': color,
      if (typeFamily != null) 'typeFamily': typeFamily,
      if (typeSubtype != null) 'typeSubtype': typeSubtype,
      if (details != null) 'details': details,
      if (documents != null) 'documents': documents!.map((doc) => doc.toMap()).toList(),
      'isDraft': isDraft,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Event copyWith({
    String? id,
    String? planId,
    String? userId,
    DateTime? date,
    int? hour,
    int? duration,
    String? description,
    String? color,
    String? typeFamily,
    String? typeSubtype,
    Map<String, dynamic>? details,
    List<EventDocument>? documents,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      color: color ?? this.color,
      typeFamily: typeFamily ?? this.typeFamily,
      typeSubtype: typeSubtype ?? this.typeSubtype,
      details: details ?? this.details,
      documents: documents ?? this.documents,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, planId: $planId, date: $date, hour: $hour, duration: $duration, description: $description, typeFamily: $typeFamily, typeSubtype: $typeSubtype, documents: ${documents?.length ?? 0})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.id == id &&
        other.planId == planId &&
        other.date == date &&
        other.hour == hour &&
        other.duration == duration &&
        other.description == description &&
        other.color == color &&
        other.typeFamily == typeFamily &&
        other.typeSubtype == typeSubtype &&
        other.documents == documents &&
        other.isDraft == isDraft;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        planId.hashCode ^
        date.hashCode ^
        hour.hashCode ^
        duration.hashCode ^
        description.hashCode ^
        color.hashCode ^
        (typeFamily?.hashCode ?? 0) ^
        (typeSubtype?.hashCode ?? 0) ^
        (documents?.hashCode ?? 0) ^
        isDraft.hashCode;
  }
}

// Nueva clase para documentos de eventos
class EventDocument {
  final String? id;
  final String name;
  final String url;
  final String type; // pdf, image, doc, etc.
  final int size; // tamaño en bytes
  final DateTime uploadedAt;
  final String? description;

  const EventDocument({
    this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
    this.description,
  });

  factory EventDocument.fromMap(Map<String, dynamic> map) {
    return EventDocument(
      id: map['id'],
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? '',
      size: map['size'] ?? 0,
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'size': size,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      if (description != null) 'description': description,
    };
  }

  EventDocument copyWith({
    String? id,
    String? name,
    String? url,
    String? type,
    int? size,
    DateTime? uploadedAt,
    String? description,
  }) {
    return EventDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
      size: size ?? this.size,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'EventDocument(name: $name, type: $type, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventDocument &&
        other.id == id &&
        other.name == name &&
        other.url == url &&
        other.type == type &&
        other.size == size;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ url.hashCode ^ type.hashCode ^ size.hashCode;
  }
} 