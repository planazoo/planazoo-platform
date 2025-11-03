import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

class Event {
  final String? id;
  final String planId;
  final String userId; // nuevo: ID del usuario propietario
  final DateTime date;
  final int hour;
  final int duration; // Duración en horas (mantenido para compatibilidad)
  final int startMinute; // nuevo: minutos de inicio (0-59)
  final int durationMinutes; // nuevo: duración en minutos
  final String description;
  final String? color;
  final String? typeFamily; // nueva: familia (desplazamiento, restauracion, actividad)
  final String? typeSubtype; // nueva: subtipo (taxi, avion, comida, museo...)
  final Map<String, dynamic>? details; // nueva: detalles específicos por tipo
  final List<EventDocument>? documents; // nueva: documentos adjuntos
  final List<String> participantTrackIds; // nueva: IDs de los tracks participantes
  final bool isDraft; // nuevo: indica si el evento es un borrador
  final DateTime createdAt;
  final DateTime updatedAt;
  // NUEVO: estructura parte común + parte personal (compatibilidad hacia atrás)
  final EventCommonPart? commonPart;
  final Map<String, EventPersonalPart>? personalParts; // key: participantId
  // NUEVO: sistema de sincronización
  final String? baseEventId; // ID del evento original (null si es el original)
  final bool isBaseEvent; // true si es el evento original, false si es copia
  // NUEVO: sistema de timezones
  final String? timezone; // IANA timezone de salida (ej: "Europe/Madrid", "America/New_York")
  final String? arrivalTimezone; // IANA timezone de llegada (para vuelos, viajes, etc.)
  // NUEVO: sistema de registro de participantes por evento (T117)
  final int? maxParticipants; // Límite opcional de participantes para el evento
  // NUEVO: sistema de confirmación de eventos (T120 Fase 2)
  final bool requiresConfirmation; // Si requiere confirmación explícita de participantes
  // T101: sistema de presupuesto
  final double? cost; // Coste total del evento (opcional)

  const Event({
    this.id,
    required this.planId,
    required this.userId,
    required this.date,
    required this.hour,
    required this.duration,
    this.startMinute = 0, // por defecto empieza al inicio de la hora
    this.durationMinutes = 60, // por defecto 1 hora completa
    required this.description,
    this.color,
    this.typeFamily,
    this.typeSubtype,
    this.details,
    this.documents,
    this.participantTrackIds = const [], // por defecto sin tracks asignados
    this.isDraft = false, // por defecto no es borrador
    required this.createdAt,
    required this.updatedAt,
    this.commonPart,
    this.personalParts,
    this.baseEventId, // null por defecto (evento original)
    this.isBaseEvent = true, // por defecto es evento original
    this.timezone, // null por defecto (usará timezone del plan)
    this.arrivalTimezone, // null por defecto (mismo que timezone)
    this.maxParticipants, // null por defecto (sin límite)
    this.requiresConfirmation = false, // por defecto no requiere confirmación
    this.cost, // null por defecto (sin coste definido)
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final duration = data['duration'] ?? 1;
    
    // Compatibilidad con datos existentes: si no hay startMinute/durationMinutes,
    // calcular basado en hour/duration existentes
    final startMinute = data['startMinute'] ?? 0;
    final durationMinutes = data['durationMinutes'] ?? (duration * 60);
    
    // Compatibilidad con datos existentes: si no hay participantTrackIds, usar lista vacía
    final participantTrackIds = (data['participantTrackIds'] as List<dynamic>?)
        ?.map((id) => id.toString())
        .toList() ?? [];
    
    // Cargar parte común si existe (compatibilidad)
    EventCommonPart? commonPart;
    if (data['commonPart'] != null) {
      final Map<String, dynamic> cp = Map<String, dynamic>.from(data['commonPart'] as Map);
      commonPart = EventCommonPart.fromMap(cp);
    }
    // Cargar partes personales si existen
    Map<String, EventPersonalPart>? personalParts;
    if (data['personalParts'] != null) {
      final raw = Map<String, dynamic>.from(data['personalParts'] as Map);
      personalParts = raw.map((key, value) => MapEntry(key, EventPersonalPart.fromMap(Map<String, dynamic>.from(value as Map))));
    }

    return Event(
      id: doc.id,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      hour: data['hour'] ?? (commonPart?.startHour ?? 0),
      duration: duration,
      startMinute: startMinute,
      durationMinutes: durationMinutes,
      description: data['description'] ?? commonPart?.description ?? '',
      color: data['color'] ?? commonPart?.customColor,
      typeFamily: data['typeFamily'] ?? commonPart?.family,
      typeSubtype: data['typeSubtype'] ?? commonPart?.subtype,
      details: (data['details'] as Map<String, dynamic>?) ?? commonPart?.extraData,
      documents: (data['documents'] as List<dynamic>?)
          ?.map((doc) => EventDocument.fromMap(doc))
          .toList(),
      participantTrackIds: participantTrackIds,
      isDraft: data['isDraft'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      commonPart: commonPart,
      personalParts: personalParts,
      baseEventId: data['baseEventId'],
      isBaseEvent: data['isBaseEvent'] ?? true, // por defecto true para compatibilidad
      timezone: data['timezone'], // null por defecto para compatibilidad
      arrivalTimezone: data['arrivalTimezone'], // null por defecto para compatibilidad
      maxParticipants: data['maxParticipants'] != null ? data['maxParticipants'] as int : null, // null por defecto
      requiresConfirmation: data['requiresConfirmation'] ?? false, // por defecto false para compatibilidad
      cost: data['cost'] != null ? (data['cost'] as num).toDouble() : null, // T101
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'planId': planId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'hour': hour,
      'duration': duration,
      'startMinute': startMinute,
      'durationMinutes': durationMinutes,
      'description': description,
      'color': color,
      if (typeFamily != null) 'typeFamily': typeFamily,
      if (typeSubtype != null) 'typeSubtype': typeSubtype,
      if (details != null) 'details': details,
      if (documents != null) 'documents': documents!.map((doc) => doc.toMap()).toList(),
      'participantTrackIds': participantTrackIds,
      'isDraft': isDraft,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isBaseEvent': isBaseEvent,
      if (timezone != null) 'timezone': timezone,
      if (arrivalTimezone != null) 'arrivalTimezone': arrivalTimezone,
      if (maxParticipants != null) 'maxParticipants': maxParticipants,
      'requiresConfirmation': requiresConfirmation, // Siempre incluir para claridad
      if (cost != null) 'cost': cost, // T101
    };
    // Escribir estructura nueva si está presente
    if (commonPart != null) {
      map['commonPart'] = commonPart!.toMap();
    }
    if (personalParts != null && personalParts!.isNotEmpty) {
      map['personalParts'] = personalParts!.map((k, v) => MapEntry(k, v.toMap()));
    }
    if (baseEventId != null) {
      map['baseEventId'] = baseEventId;
    }
    return map;
  }

  Event copyWith({
    String? id,
    String? planId,
    String? userId,
    DateTime? date,
    int? hour,
    int? duration,
    int? startMinute,
    int? durationMinutes,
    String? description,
    String? color,
    String? typeFamily,
    String? typeSubtype,
    Map<String, dynamic>? details,
    List<EventDocument>? documents,
    List<String>? participantTrackIds,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
    EventCommonPart? commonPart,
    Map<String, EventPersonalPart>? personalParts,
    String? baseEventId,
    bool? isBaseEvent,
    String? timezone,
    String? arrivalTimezone,
    int? maxParticipants,
    bool? requiresConfirmation,
    double? cost,
  }) {
    return Event(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      duration: duration ?? this.duration,
      startMinute: startMinute ?? this.startMinute,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      color: color ?? this.color,
      typeFamily: typeFamily ?? this.typeFamily,
      typeSubtype: typeSubtype ?? this.typeSubtype,
      details: details ?? this.details,
      documents: documents ?? this.documents,
      participantTrackIds: participantTrackIds ?? this.participantTrackIds,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      commonPart: commonPart ?? this.commonPart,
      personalParts: personalParts ?? this.personalParts,
      baseEventId: baseEventId ?? this.baseEventId,
      isBaseEvent: isBaseEvent ?? this.isBaseEvent,
      timezone: timezone ?? this.timezone,
      arrivalTimezone: arrivalTimezone ?? this.arrivalTimezone,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      cost: cost ?? this.cost,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, planId: $planId, date: $date, hour: $hour, startMinute: $startMinute, duration: $duration, durationMinutes: $durationMinutes, description: $description, typeFamily: $typeFamily, typeSubtype: $typeSubtype, documents: ${documents?.length ?? 0})';
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
        other.startMinute == startMinute &&
        other.durationMinutes == durationMinutes &&
        other.description == description &&
        other.color == color &&
        other.typeFamily == typeFamily &&
        other.typeSubtype == typeSubtype &&
        other.documents == documents &&
        other.isDraft == isDraft &&
        other.commonPart == commonPart &&
        other.baseEventId == baseEventId &&
        other.isBaseEvent == isBaseEvent &&
        other.timezone == timezone &&
        other.arrivalTimezone == arrivalTimezone;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        planId.hashCode ^
        date.hashCode ^
        hour.hashCode ^
        duration.hashCode ^
        startMinute.hashCode ^
        durationMinutes.hashCode ^
        description.hashCode ^
        color.hashCode ^
        (typeFamily?.hashCode ?? 0) ^
        (typeSubtype?.hashCode ?? 0) ^
        (documents?.hashCode ?? 0) ^
        isDraft.hashCode ^
        (commonPart?.hashCode ?? 0) ^
        (baseEventId?.hashCode ?? 0) ^
        isBaseEvent.hashCode ^
        (timezone?.hashCode ?? 0) ^
        (arrivalTimezone?.hashCode ?? 0);
  }

  // Métodos de utilidad para trabajar con minutos exactos
  
  /// Obtiene el minuto total de inicio del evento (hora * 60 + startMinute)
  /// 
  /// NOTA: Para eventos con timezones diferentes, este método devuelve los minutos
  /// en la timezone de salida. Para comparaciones entre eventos con timezones diferentes,
  /// usar overlapsWith() que maneja la conversión automáticamente.
  int get totalStartMinutes => hour * 60 + startMinute;
  
  /// Obtiene el minuto total de fin del evento
  /// 
  /// NOTA: Para eventos con timezones diferentes, este método devuelve los minutos
  /// en la timezone de salida. Para comparaciones entre eventos con timezones diferentes,
  /// usar overlapsWith() que maneja la conversión automáticamente.
  int get totalEndMinutes => totalStartMinutes + durationMinutes;
  
  /// Obtiene la hora de fin del evento
  int get endHour => totalEndMinutes ~/ 60;
  
  /// Obtiene el minuto de fin del evento
  int get endMinute => totalEndMinutes % 60;
  
  /// Verifica si el evento está activo en un minuto específico
  /// 
  /// Para eventos con timezones diferentes, este método verifica si el minuto
  /// especificado está dentro del rango del evento en la timezone de salida.
  bool isActiveAt(int hour, int minute) {
    final checkMinutes = hour * 60 + minute;
    return checkMinutes >= totalStartMinutes && checkMinutes < totalEndMinutes;
  }

  /// Verifica si el evento está activo en una fecha/hora específica considerando timezones
  /// 
  /// Este método es más preciso para eventos con timezones diferentes ya que
  /// convierte la fecha/hora de verificación a la timezone del evento.
  bool isActiveAtDateTime(DateTime dateTime) {
    if (!_hasDifferentTimezones(this)) {
      // Sin timezones diferentes, usar lógica normal
      return isActiveAt(dateTime.hour, dateTime.minute);
    }
    
    // Con timezones diferentes, verificar en tiempo real
    final eventStart = _getRealStartDateTime(this);
    final eventEnd = _getRealEndDateTime(this);
    
    // Convertir la fecha de verificación a UTC para comparación
    final checkUtc = TimezoneService.localToUtc(dateTime, timezone!);
    
    return checkUtc.isAfter(eventStart) && checkUtc.isBefore(eventEnd);
  }
  
  /// Verifica si el evento se solapa con otro evento
  bool overlapsWith(Event other) {
    // Si ambos eventos tienen timezones diferentes, usar lógica especial
    if (_hasDifferentTimezones(this) || _hasDifferentTimezones(other)) {
      return _overlapsWithTimezoneAware(other);
    }
    
    // Lógica original para eventos sin timezones diferentes
    return totalStartMinutes < other.totalEndMinutes && 
           totalEndMinutes > other.totalStartMinutes;
  }

  /// Verifica si un evento tiene timezones diferentes
  bool _hasDifferentTimezones(Event event) {
    return event.timezone != null && 
           event.timezone!.isNotEmpty && 
           event.arrivalTimezone != null && 
           event.arrivalTimezone!.isNotEmpty &&
           event.timezone != event.arrivalTimezone;
  }

  /// Verifica solapamiento considerando timezones
  bool _overlapsWithTimezoneAware(Event other) {
    // Para eventos con timezones diferentes, necesitamos verificar
    // si se solapan en el tiempo real (no en minutos locales)
    
    // Calcular fechas reales de inicio y fin para ambos eventos
    final thisStart = _getRealStartDateTime(this);
    final thisEnd = _getRealEndDateTime(this);
    final otherStart = _getRealStartDateTime(other);
    final otherEnd = _getRealEndDateTime(other);
    
    // Verificar solapamiento en tiempo real
    return thisStart.isBefore(otherEnd) && thisEnd.isAfter(otherStart);
  }

  /// Obtiene la fecha/hora real de inicio considerando timezones
  DateTime _getRealStartDateTime(Event event) {
    if (!_hasDifferentTimezones(event)) {
      return DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.hour,
        event.startMinute,
      );
    }
    
    // Con timezones diferentes, convertir a UTC para comparación
    final localDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );
    
    return TimezoneService.localToUtc(localDateTime, event.timezone!);
  }

  /// Obtiene la fecha/hora real de fin considerando timezones
  DateTime _getRealEndDateTime(Event event) {
    if (!_hasDifferentTimezones(event)) {
      return DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.hour,
        event.startMinute,
      ).add(Duration(minutes: event.durationMinutes));
    }
    
    // Con timezones diferentes, calcular llegada real y convertir a UTC
    final departureDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );
    
    final departureUtc = TimezoneService.localToUtc(departureDateTime, event.timezone!);
    final arrivalUtc = departureUtc.add(Duration(minutes: event.durationMinutes));
    
    return arrivalUtc;
  }

  /// Obtiene la fecha/hora de salida real considerando timezones
  DateTime get realDepartureDateTime => _getRealStartDateTime(this);
  
  /// Obtiene la fecha/hora de llegada real considerando timezones
  DateTime get realArrivalDateTime => _getRealEndDateTime(this);
  
  /// Obtiene la duración real del evento en minutos considerando timezones
  int get realDurationMinutes {
    if (!_hasDifferentTimezones(this)) {
      return durationMinutes;
    }
    
    final start = _getRealStartDateTime(this);
    final end = _getRealEndDateTime(this);
    return end.difference(start).inMinutes;
  }
  
  /// Verifica si el evento cruza medianoche considerando timezones
  bool get crossesMidnightWithTimezone {
    if (!_hasDifferentTimezones(this)) {
      return totalEndMinutes > 1440;
    }
    
    final departureDate = DateTime(date.year, date.month, date.day);
    final arrivalDate = DateTime(
      realArrivalDateTime.year,
      realArrivalDateTime.month,
      realArrivalDateTime.day,
    );
    
    return !departureDate.isAtSameMomentAs(arrivalDate);
  }
  
  // ========== MÉTODOS DE SINCRONIZACIÓN ==========
  
  /// Obtiene el ID del evento base (el original)
  String? get eventBaseId => isBaseEvent ? id : baseEventId;
  
  /// Verifica si este evento es una copia de otro
  bool get isEventCopy => !isBaseEvent && baseEventId != null;
  
  /// Verifica si este evento es el original
  bool get isEventOriginal => isBaseEvent && baseEventId == null;
  
  /// Crea una copia de este evento para un participante específico
  Event createCopyForParticipant(String participantId) {
    if (!isBaseEvent) {
      throw StateError('Solo se pueden crear copias desde el evento original');
    }
    
    return copyWith(
      id: null, // Se asignará al guardar
      userId: participantId,
      isBaseEvent: false,
      baseEventId: id, // Referencia al evento original
      personalParts: {participantId: EventPersonalPart(participantId: participantId)},
    );
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

// NUEVOS MODELOS: Parte común y parte personal
class EventCommonPart {
  final String description;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int durationMinutes;
  final String? location;
  final String? notes;
  final String? family;
  final String? subtype;
  final String? customColor;
  final List<String> participantIds; // participantes incluidos en la parte común
  final bool isForAllParticipants;
  final bool isDraft;
  final Map<String, dynamic>? extraData;

  const EventCommonPart({
    required this.description,
    required this.date,
    required this.startHour,
    required this.startMinute,
    required this.durationMinutes,
    this.location,
    this.notes,
    this.family,
    this.subtype,
    this.customColor,
    this.participantIds = const [],
    this.isForAllParticipants = true,
    this.isDraft = false,
    this.extraData,
  });

  factory EventCommonPart.fromMap(Map<String, dynamic> map) {
    return EventCommonPart(
      description: map['description'] ?? '',
      date: (map['date'] is Timestamp) ? (map['date'] as Timestamp).toDate() : DateTime.parse(map['date'] as String),
      startHour: map['startHour'] ?? 0,
      startMinute: map['startMinute'] ?? 0,
      durationMinutes: map['durationMinutes'] ?? 60,
      location: map['location'],
      notes: map['notes'],
      family: map['family'],
      subtype: map['subtype'],
      customColor: map['customColor'],
      participantIds: (map['participantIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      isForAllParticipants: map['isForAllParticipants'] ?? true,
      isDraft: map['isDraft'] ?? false,
      extraData: map['extraData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'date': Timestamp.fromDate(date),
      'startHour': startHour,
      'startMinute': startMinute,
      'durationMinutes': durationMinutes,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (family != null) 'family': family,
      if (subtype != null) 'subtype': subtype,
      if (customColor != null) 'customColor': customColor,
      'participantIds': participantIds,
      'isForAllParticipants': isForAllParticipants,
      'isDraft': isDraft,
      if (extraData != null) 'extraData': extraData,
    };
  }
}

class EventPersonalPart {
  final String participantId;
  final Map<String, dynamic>? fields; // campos específicos (asiento, menú, notas...)

  const EventPersonalPart({
    required this.participantId,
    this.fields,
  });

  factory EventPersonalPart.fromMap(Map<String, dynamic> map) {
    return EventPersonalPart(
      participantId: map['participantId'] ?? '',
      fields: map['fields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      if (fields != null) 'fields': fields,
    };
  }
}