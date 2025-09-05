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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertir a formato de Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'hotelName': hotelName,
      'description': description,
      'color': color,
      'typeFamily': typeFamily,
      'typeSubtype': typeSubtype,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
