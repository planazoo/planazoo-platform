import 'dart:convert';

/// Modelo que representa un track (columna) de participante en el calendario
/// 
/// Cada participante del plan tiene un track que define:
/// - Su posición visual en el calendario
/// - Su color personalizado
/// - Si está visible o no
/// - Información básica del participante
class ParticipantTrack {
  /// ID único del track
  final String id;
  
  /// ID del participante al que pertenece este track
  final String participantId;
  
  /// Nombre del participante para mostrar en el header
  final String participantName;
  
  /// Posición del track en el calendario (0 = primera columna, 1 = segunda, etc.)
  final int position;
  
  /// Color personalizado del track (opcional)
  final String? customColor;
  
  /// Si el track está visible en el calendario
  final bool isVisible;
  
  /// Fecha de creación del track
  final DateTime createdAt;
  
  /// Fecha de última modificación
  final DateTime updatedAt;

  const ParticipantTrack({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.position,
    this.customColor,
    this.isVisible = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia del track con algunos campos modificados
  ParticipantTrack copyWith({
    String? id,
    String? participantId,
    String? participantName,
    int? position,
    String? customColor,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParticipantTrack(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      position: position ?? this.position,
      customColor: customColor ?? this.customColor,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte el track a un mapa para serialización
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'position': position,
      'customColor': customColor,
      'isVisible': isVisible,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crea un track desde un mapa (deserialización)
  factory ParticipantTrack.fromMap(Map<String, dynamic> map) {
    return ParticipantTrack(
      id: map['id'] ?? '',
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? '',
      position: map['position'] ?? 0,
      customColor: map['customColor'],
      isVisible: map['isVisible'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Convierte el track a JSON
  String toJson() {
    return jsonEncode(toMap());
  }

  /// Crea un track desde JSON
  factory ParticipantTrack.fromJson(String source) {
    return ParticipantTrack.fromMap(jsonDecode(source));
  }

  @override
  String toString() {
    return 'ParticipantTrack(id: $id, participantId: $participantId, participantName: $participantName, position: $position, customColor: $customColor, isVisible: $isVisible)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParticipantTrack &&
        other.id == id &&
        other.participantId == participantId &&
        other.participantName == participantName &&
        other.position == position &&
        other.customColor == customColor &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        participantId.hashCode ^
        participantName.hashCode ^
        position.hashCode ^
        customColor.hashCode ^
        isVisible.hashCode;
  }
}

/// Lista de colores predefinidos para tracks
class TrackColors {
  static const List<String> predefined = [
    '#FF6B6B', // Rojo coral
    '#4ECDC4', // Verde agua
    '#45B7D1', // Azul claro
    '#FFA07A', // Salmón
    '#98D8C8', // Verde menta
    '#F7DC6F', // Amarillo claro
    '#BB8FCE', // Púrpura claro
    '#85C1E9', // Azul cielo
    '#F8C471', // Naranja claro
    '#82E0AA', // Verde claro
  ];

  /// Obtiene un color basado en el índice del track
  static String getColorForPosition(int position) {
    return predefined[position % predefined.length];
  }
}
