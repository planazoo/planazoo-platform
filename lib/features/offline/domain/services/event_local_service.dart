import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/calendar/domain/models/event.dart';
import 'local_storage_service.dart';
import 'hive_service.dart';

/// Servicio para almacenar Eventos localmente (solo móviles)
class EventLocalService extends LocalStorageService<Event> {
  EventLocalService() : super(HiveService.boxNameEvents);

  @override
  Map<String, dynamic> toMap(Event event) {
    // Usamos toFirestore() pero convertimos Timestamps a ISO strings para Hive
    final firestoreMap = event.toFirestore();
    final hiveMap = <String, dynamic>{};
    
    for (var entry in firestoreMap.entries) {
      if (entry.value is Timestamp) {
        hiveMap[entry.key] = (entry.value as Timestamp).toDate().toIso8601String();
      } else {
        hiveMap[entry.key] = entry.value;
      }
    }
    
    // Añadimos el ID si existe
    if (event.id != null) {
      hiveMap['_id'] = event.id;
    }
    
    return hiveMap;
  }

  @override
  Event fromMap(Map<String, dynamic> map) {
    // Helper para convertir fechas
    DateTime _parseDate(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is Timestamp) {
        return value.toDate();
      }
      throw ArgumentError('Invalid date format: $value');
    }

    final data = map;
    final duration = data['duration'] ?? 1;
    final startMinute = data['startMinute'] ?? 0;
    final durationMinutes = data['durationMinutes'] ?? (duration * 60);
    
    final participantTrackIds = (data['participantTrackIds'] as List<dynamic>?)
        ?.map((id) => id.toString())
        .toList() ?? [];
    
    // Cargar parte común si existe
    EventCommonPart? commonPart;
    if (data['commonPart'] != null) {
      final cp = Map<String, dynamic>.from(data['commonPart'] as Map);
      // EventCommonPart.fromMap maneja Timestamps, pero nosotros tenemos String
      // Necesitamos convertir la fecha a Timestamp antes de llamar a fromMap
      if (cp['date'] is String) {
        final dateStr = cp['date'] as String;
        cp['date'] = Timestamp.fromDate(DateTime.parse(dateStr));
      } else if (cp['date'] is! Timestamp) {
        // Si no es String ni Timestamp, intentar parsear como DateTime
        try {
          final date = cp['date'] as DateTime;
          cp['date'] = Timestamp.fromDate(date);
        } catch (e) {
          // Si falla, usar fecha actual como fallback
          cp['date'] = Timestamp.now();
        }
      }
      commonPart = EventCommonPart.fromMap(cp);
    }
    
    // Cargar partes personales si existen
    Map<String, EventPersonalPart>? personalParts;
    if (data['personalParts'] != null) {
      final raw = Map<String, dynamic>.from(data['personalParts'] as Map);
      personalParts = raw.map((key, value) => 
        MapEntry(key, EventPersonalPart.fromMap(Map<String, dynamic>.from(value as Map))));
    }

    // Convertir documentos si existen
    List<EventDocument>? documents;
    if (data['documents'] != null) {
      final docsList = data['documents'] as List<dynamic>;
      documents = docsList.map((doc) {
        final docMap = Map<String, dynamic>.from(doc as Map);
        // Convertir uploadedAt si es String
        if (docMap['uploadedAt'] is String) {
          docMap['uploadedAt'] = Timestamp.fromDate(DateTime.parse(docMap['uploadedAt'] as String));
        }
        return EventDocument.fromMap(docMap);
      }).toList();
    }

    return Event(
      id: map['_id'] as String?,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      date: _parseDate(data['date']),
      hour: data['hour'] ?? (commonPart?.startHour ?? 0),
      duration: duration,
      startMinute: startMinute,
      durationMinutes: durationMinutes,
      description: data['description'] ?? commonPart?.description ?? '',
      color: data['color'] ?? commonPart?.customColor,
      typeFamily: data['typeFamily'] ?? commonPart?.family,
      typeSubtype: data['typeSubtype'] ?? commonPart?.subtype,
      details: (data['details'] as Map<String, dynamic>?) ?? commonPart?.extraData,
      documents: documents,
      participantTrackIds: participantTrackIds,
      isDraft: data['isDraft'] ?? false,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      commonPart: commonPart,
      personalParts: personalParts,
      baseEventId: data['baseEventId'],
      isBaseEvent: data['isBaseEvent'] ?? true,
      timezone: data['timezone'],
      arrivalTimezone: data['arrivalTimezone'],
      maxParticipants: data['maxParticipants'] as int?,
      requiresConfirmation: data['requiresConfirmation'] ?? false,
      cost: data['cost'] != null ? (data['cost'] as num).toDouble() : null,
    );
  }

  /// Obtiene todos los eventos de un plan
  Future<List<Event>> getEventsByPlanId(String planId) async {
    if (!isMobile) return [];
    
    final allEvents = await getAll();
    return allEvents.where((event) => event.planId == planId).toList();
  }

  /// Obtiene eventos de un plan para una fecha específica
  Future<List<Event>> getEventsByPlanIdAndDate(String planId, DateTime date) async {
    if (!isMobile) return [];
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final planEvents = await getEventsByPlanId(planId);
    return planEvents.where((event) {
      return event.date.isAfter(startOfDay.subtract(const Duration(days: 1))) &&
             event.date.isBefore(endOfDay);
    }).toList();
  }

  /// Obtiene un evento por ID
  Future<Event?> getEventById(String eventId) async {
    return await get(eventId);
  }

  /// Guarda un evento (usa el ID como key)
  Future<void> saveEvent(Event event) async {
    if (event.id == null) {
      throw ArgumentError('Event debe tener un ID para guardarse localmente');
    }
    await save(event.id!, event);
  }

  /// Elimina un evento
  Future<void> deleteEvent(String eventId) async {
    await delete(eventId);
  }

  /// Elimina todos los eventos de un plan
  Future<void> deleteEventsByPlanId(String planId) async {
    if (!isMobile) return;
    
    final events = await getEventsByPlanId(planId);
    for (var event in events) {
      if (event.id != null) {
        await delete(event.id!);
      }
    }
  }

}

