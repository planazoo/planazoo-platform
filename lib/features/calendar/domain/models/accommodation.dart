import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Accommodation {
  final String? id;
  final String planId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String hotelName;
  final String? description;
  final String? color;
  final String typeFamily;
  final String typeSubtype;
  final List<String> participantTrackIds; // IDs de tracks de participantes asignados
  final DateTime createdAt;
  final DateTime updatedAt;
  // NUEVO: estructura parte común + parte personal (similar a eventos)
  final AccommodationCommonPart? commonPart;
  final Map<String, AccommodationPersonalPart>? personalParts; // key: participantId

  const Accommodation({
    this.id,
    required this.planId,
    required this.checkIn,
    required this.checkOut,
    required this.hotelName,
    this.description,
    this.color,
    this.typeFamily = 'alojamiento',
    this.typeSubtype = 'hotel',
    this.participantTrackIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.commonPart,
    this.personalParts,
  });

  /// Crear desde un documento de Firestore
  factory Accommodation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Accommodation(
      id: doc.id,
      planId: data['planId'] ?? '',
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      checkOut: (data['checkOut'] as Timestamp).toDate(),
      hotelName: data['hotelName'] ?? '',
      description: data['description'],
      color: data['color'],
      typeFamily: data['typeFamily'] ?? 'alojamiento',
      typeSubtype: data['typeSubtype'] ?? 'hotel',
      participantTrackIds: List<String>.from(data['participantTrackIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      commonPart: data['commonPart'] != null 
          ? AccommodationCommonPart.fromMap(data['commonPart'] as Map<String, dynamic>)
          : null,
      personalParts: data['personalParts'] != null
          ? (data['personalParts'] as Map<String, dynamic>).map((k, v) => MapEntry(k, AccommodationPersonalPart.fromMap(v as Map<String, dynamic>)))
          : null,
    );
  }

  /// Convertir a formato de Firestore
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'planId': planId,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'hotelName': hotelName,
      'description': description,
      'color': color,
      'typeFamily': typeFamily,
      'typeSubtype': typeSubtype,
      'participantTrackIds': participantTrackIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
    // Escribir estructura nueva si está presente
    if (commonPart != null) {
      map['commonPart'] = commonPart!.toMap();
    }
    if (personalParts != null && personalParts!.isNotEmpty) {
      map['personalParts'] = personalParts!.map((k, v) => MapEntry(k, v.toMap()));
    }
    return map;
  }

  /// Crear una copia con cambios
  Accommodation copyWith({
    String? id,
    String? planId,
    DateTime? checkIn,
    DateTime? checkOut,
    String? hotelName,
    String? description,
    String? color,
    String? typeFamily,
    String? typeSubtype,
    List<String>? participantTrackIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    AccommodationCommonPart? commonPart,
    Map<String, AccommodationPersonalPart>? personalParts,
  }) {
    return Accommodation(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      hotelName: hotelName ?? this.hotelName,
      description: description ?? this.description,
      color: color ?? this.color,
      typeFamily: typeFamily ?? this.typeFamily,
      typeSubtype: typeSubtype ?? this.typeSubtype,
      participantTrackIds: participantTrackIds ?? this.participantTrackIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      commonPart: commonPart ?? this.commonPart,
      personalParts: personalParts ?? this.personalParts,
    );
  }

  /// Obtener la duración en días
  int get duration {
    return checkOut.difference(checkIn).inDays;
  }

  /// Verificar si una fecha está dentro del rango de alojamiento
  bool isDateInRange(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedCheckIn = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final normalizedCheckOut = DateTime(checkOut.year, checkOut.month, checkOut.day);
    
    return normalizedDate.isAfter(normalizedCheckIn.subtract(const Duration(days: 1))) &&
           normalizedDate.isBefore(normalizedCheckOut.add(const Duration(days: 1)));
  }
  
  /// Verificar si las fechas del alojamiento son válidas para un plan
  bool isValidForPlan(DateTime planStartDate, DateTime planEndDate) {
    final normalizedCheckIn = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final normalizedCheckOut = DateTime(checkOut.year, checkOut.month, checkOut.day);
    final normalizedPlanStart = DateTime(planStartDate.year, planStartDate.month, planStartDate.day);
    final normalizedPlanEnd = DateTime(planEndDate.year, planEndDate.month, planEndDate.day);
    
    // El check-in debe ser después o igual al inicio del plan
    // El check-out debe ser antes o igual al fin del plan
    return normalizedCheckIn.isAfter(normalizedPlanStart.subtract(const Duration(days: 1))) &&
           normalizedCheckOut.isBefore(normalizedPlanEnd.add(const Duration(days: 1)));
  }

  /// Obtener el color del alojamiento
  Color get displayColor {
    if (color != null) {
      switch (color!.toLowerCase()) {
        case 'red': return const Color(0xFFE57373);
        case 'blue': return const Color(0xFF81C784);
        case 'green': return const Color(0xFF64B5F6);
        case 'yellow': return const Color(0xFFFFB74D);
        case 'purple': return const Color(0xFFBA68C8);
        case 'orange': return const Color(0xFFFF8A65);
        case 'pink': return const Color(0xFFF06292);
        case 'brown': return const Color(0xFFA1887F);
        case 'grey':
        case 'gray': return const Color(0xFF90A4AE);
        default: return const Color(0xFF64B5F6); // Azul por defecto
      }
    }
    return const Color(0xFF64B5F6); // Azul por defecto
  }

  @override
  String toString() {
    return 'Accommodation(id: $id, planId: $planId, hotelName: $hotelName, checkIn: $checkIn, checkOut: $checkOut)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Accommodation &&
        other.id == id &&
        other.planId == planId &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.hotelName == hotelName;
  }

  @override
  int get hashCode {
    return Object.hash(id, planId, checkIn, checkOut, hotelName);
  }
}

// NUEVOS MODELOS: Parte común y parte personal para alojamientos
class AccommodationCommonPart {
  final String hotelName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String? description;
  final String? notes;
  final String? typeFamily;
  final String? typeSubtype;
  final String? customColor;
  final String? address;
  final String? contactInfo;
  final Map<String, dynamic>? amenities;
  final int? maxCapacity;
  final List<String> participantIds; // participantes incluidos en la parte común
  final bool isForAllParticipants;
  final Map<String, dynamic>? extraData;

  const AccommodationCommonPart({
    required this.hotelName,
    required this.checkIn,
    required this.checkOut,
    this.description,
    this.notes,
    this.typeFamily,
    this.typeSubtype,
    this.customColor,
    this.address,
    this.contactInfo,
    this.amenities,
    this.maxCapacity,
    this.participantIds = const [],
    this.isForAllParticipants = true,
    this.extraData,
  });

  factory AccommodationCommonPart.fromMap(Map<String, dynamic> map) {
    return AccommodationCommonPart(
      hotelName: map['hotelName'] ?? '',
      checkIn: (map['checkIn'] is Timestamp) 
          ? (map['checkIn'] as Timestamp).toDate() 
          : DateTime.parse(map['checkIn'] as String),
      checkOut: (map['checkOut'] is Timestamp) 
          ? (map['checkOut'] as Timestamp).toDate() 
          : DateTime.parse(map['checkOut'] as String),
      description: map['description'],
      notes: map['notes'],
      typeFamily: map['typeFamily'],
      typeSubtype: map['typeSubtype'],
      customColor: map['customColor'],
      address: map['address'],
      contactInfo: map['contactInfo'],
      amenities: map['amenities'] as Map<String, dynamic>?,
      maxCapacity: map['maxCapacity'],
      participantIds: (map['participantIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      isForAllParticipants: map['isForAllParticipants'] ?? true,
      extraData: map['extraData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hotelName': hotelName,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (typeFamily != null) 'typeFamily': typeFamily,
      if (typeSubtype != null) 'typeSubtype': typeSubtype,
      if (customColor != null) 'customColor': customColor,
      if (address != null) 'address': address,
      if (contactInfo != null) 'contactInfo': contactInfo,
      if (amenities != null) 'amenities': amenities,
      if (maxCapacity != null) 'maxCapacity': maxCapacity,
      'participantIds': participantIds,
      'isForAllParticipants': isForAllParticipants,
      if (extraData != null) 'extraData': extraData,
    };
  }
}

class AccommodationPersonalPart {
  final String participantId;
  final String? roomNumber; // Número de habitación individual
  final String? bedType; // Tipo de cama (individual, matrimonio, etc.)
  final Map<String, dynamic>? preferences; // Preferencias personales (piso alto, sin ruido, etc.)
  final Map<String, dynamic>? notes; // Notas personales del alojamiento
  final Map<String, dynamic>? fields; // Campos específicos adicionales

  const AccommodationPersonalPart({
    required this.participantId,
    this.roomNumber,
    this.bedType,
    this.preferences,
    this.notes,
    this.fields,
  });

  factory AccommodationPersonalPart.fromMap(Map<String, dynamic> map) {
    return AccommodationPersonalPart(
      participantId: map['participantId'] ?? '',
      roomNumber: map['roomNumber'],
      bedType: map['bedType'],
      preferences: map['preferences'] as Map<String, dynamic>?,
      notes: map['notes'] as Map<String, dynamic>?,
      fields: map['fields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      if (roomNumber != null) 'roomNumber': roomNumber,
      if (bedType != null) 'bedType': bedType,
      if (preferences != null) 'preferences': preferences,
      if (notes != null) 'notes': notes,
      if (fields != null) 'fields': fields,
    };
  }
}
