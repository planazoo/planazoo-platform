import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/models/calendar_view_mode.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_utils.dart';

/// Clase que maneja la lógica específica de eventos
class CalendarEventLogic {
  /// Filtra eventos según el modo de vista y tracks
  static List<Event> filterEventsByTracks(
    List<Event> events,
    CalendarViewMode viewMode,
    String? currentUserId,
    List<String> filteredParticipantIds,
    List<ParticipantTrack> filteredTracks,
  ) {
    if (viewMode == CalendarViewMode.all) {
      return events;
    }
    
    final filteredParticipantIds = filteredTracks.map((track) => track.participantId).toList();
    
    if (viewMode == CalendarViewMode.personal) {
      if (currentUserId == null) return events;
      return events.where((event) => 
        event.commonPart?.participantIds.contains(currentUserId) == true
      ).toList();
    }
    
    if (viewMode == CalendarViewMode.custom) {
      return events.where((event) => 
        event.commonPart?.participantIds.any((id) => filteredParticipantIds.contains(id)) == true
      ).toList();
    }
    
    return events;
  }

  /// Verifica si un evento debe mostrarse en un track específico
  static bool shouldShowEventInTrack(Event event, ParticipantTrack track) {
    return event.commonPart?.participantIds.contains(track.participantId) == true;
  }

  /// Obtiene grupos consecutivos de tracks para un evento
  static List<List<ParticipantTrack>> getConsecutiveTrackGroupsForEvent(
    Event event,
    List<ParticipantTrack> tracks,
  ) {
    final eventTracks = tracks.where((track) => 
      shouldShowEventInTrack(event, track)
    ).toList();
    
    if (eventTracks.isEmpty) return [];
    
    // Ordenar por posición
    eventTracks.sort((a, b) => a.position.compareTo(b.position));
    
    final groups = <List<ParticipantTrack>>[];
    var currentGroup = <ParticipantTrack>[eventTracks.first];
    
    for (int i = 1; i < eventTracks.length; i++) {
      final currentTrack = eventTracks[i];
      final previousTrack = eventTracks[i - 1];
      
      if (currentTrack.position == previousTrack.position + 1) {
        currentGroup.add(currentTrack);
      } else {
        groups.add(currentGroup);
        currentGroup = [currentTrack];
      }
    }
    
    groups.add(currentGroup);
    return groups;
  }

  /// Calcula el span de un evento (cuántos tracks ocupa)
  static int calculateEventSpan(Event event, List<ParticipantTrack> tracks) {
    return tracks.where((track) => shouldShowEventInTrack(event, track)).length;
  }

  /// Obtiene el color de un evento
  static Color getEventColor(Event event) {
    final customColor = event.commonPart?.customColor;
    if (customColor is Color) {
      return customColor;
    }
    return AppColorScheme.color1;
  }

  /// Obtiene el texto de un evento
  static String getEventText(Event event) {
    return event.commonPart?.description ?? 'Sin título';
  }

  /// Verifica si un evento está en un día específico
  static bool isEventInDay(Event event, int dayNumber) {
    return event.commonPart?.date.day == dayNumber;
  }

  /// Obtiene eventos para un día específico
  static List<Event> getEventsForDay(List<Event> events, int dayNumber) {
    return events.where((event) => isEventInDay(event, dayNumber)).toList();
  }

  /// Calcula la posición horizontal de un evento
  static double calculateEventPosition(
    Event event,
    List<ParticipantTrack> tracks,
    double subColumnWidth,
  ) {
    final eventTracks = tracks.where((track) => 
      shouldShowEventInTrack(event, track)
    ).toList();
    
    if (eventTracks.isEmpty) return 0;
    
    eventTracks.sort((a, b) => a.position.compareTo(b.position));
    return eventTracks.first.position * subColumnWidth;
  }

  /// Calcula el ancho de un evento
  static double calculateEventWidth(
    Event event,
    List<ParticipantTrack> tracks,
    double subColumnWidth,
  ) {
    return calculateEventSpan(event, tracks) * subColumnWidth;
  }

  /// Verifica si un evento es válido
  static bool isValidEvent(Event event) {
    return event.commonPart != null && 
           event.commonPart!.description.isNotEmpty;
  }

  /// Obtiene la hora de inicio de un evento
  static String getEventStartTime(Event event) {
    final commonPart = event.commonPart;
    if (commonPart == null) return '00:00';
    
    final hour = commonPart.startHour.toString().padLeft(2, '0');
    final minute = commonPart.startMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Obtiene la duración de un evento en minutos
  static int getEventDuration(Event event) {
    return event.commonPart?.durationMinutes ?? 60;
  }

  /// Verifica si un evento es un borrador
  static bool isDraftEvent(Event event) {
    return event.commonPart?.isDraft == true;
  }

  /// Verifica si un evento es para todos los participantes
  static bool isEventForAllParticipants(Event event) {
    return event.commonPart?.isForAllParticipants == true;
  }
}
