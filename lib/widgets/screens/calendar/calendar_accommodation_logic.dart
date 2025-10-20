import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/models/calendar_view_mode.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_utils.dart';

/// Clase que maneja la lógica específica de alojamientos
class CalendarAccommodationLogic {
  /// Filtra alojamientos según el modo de vista y tracks
  static List<Accommodation> filterAccommodationsByTracks(
    List<Accommodation> accommodations,
    CalendarViewMode viewMode,
    String? currentUserId,
    List<String> filteredParticipantIds,
    List<ParticipantTrack> filteredTracks,
  ) {
    if (viewMode == CalendarViewMode.all) {
      return accommodations;
    }
    
    final filteredParticipantIds = filteredTracks.map((track) => track.participantId).toList();
    
    if (viewMode == CalendarViewMode.personal) {
      if (currentUserId == null) return accommodations;
      return accommodations.where((acc) => 
        acc.participantTrackIds.contains(currentUserId)
      ).toList();
    }
    
    if (viewMode == CalendarViewMode.custom) {
      return accommodations.where((acc) => 
        acc.participantTrackIds.any((id) => filteredParticipantIds.contains(id))
      ).toList();
    }
    
    return accommodations;
  }

  /// Verifica si un alojamiento debe mostrarse en un track específico
  static bool shouldShowAccommodationInTrack(Accommodation accommodation, ParticipantTrack track) {
    return accommodation.participantTrackIds.contains(track.participantId);
  }

  /// Obtiene grupos consecutivos de tracks para un alojamiento
  static List<List<ParticipantTrack>> getConsecutiveTrackGroupsForAccommodation(
    Accommodation accommodation,
    List<ParticipantTrack> tracks,
  ) {
    final accommodationTracks = tracks.where((track) => 
      shouldShowAccommodationInTrack(accommodation, track)
    ).toList();
    
    if (accommodationTracks.isEmpty) return [];
    
    // Ordenar por posición
    accommodationTracks.sort((a, b) => a.position.compareTo(b.position));
    
    final groups = <List<ParticipantTrack>>[];
    var currentGroup = <ParticipantTrack>[accommodationTracks.first];
    
    for (int i = 1; i < accommodationTracks.length; i++) {
      final currentTrack = accommodationTracks[i];
      final previousTrack = accommodationTracks[i - 1];
      
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

  /// Calcula el span de un alojamiento (cuántos tracks ocupa)
  static int calculateAccommodationSpan(Accommodation accommodation, List<ParticipantTrack> tracks) {
    return tracks.where((track) => shouldShowAccommodationInTrack(accommodation, track)).length;
  }

  /// Obtiene el color de un alojamiento
  static Color getAccommodationColor(Accommodation accommodation) {
    if (accommodation.color != null) {
      // TODO: Convertir string a Color si es necesario
      return Colors.green;
    }
    return Colors.green;
  }

  /// Obtiene el texto de un alojamiento
  static String getAccommodationText(Accommodation accommodation) {
    return accommodation.hotelName;
  }

  /// Verifica si un alojamiento está en un día específico
  static bool isAccommodationInDay(Accommodation accommodation, int dayNumber) {
    return accommodation.checkIn.day == dayNumber || accommodation.checkOut.day == dayNumber;
  }

  /// Obtiene alojamientos para un día específico
  static List<Accommodation> getAccommodationsForDay(List<Accommodation> accommodations, int dayNumber) {
    return accommodations.where((acc) => isAccommodationInDay(acc, dayNumber)).toList();
  }

  /// Calcula la posición horizontal de un alojamiento
  static double calculateAccommodationPosition(
    Accommodation accommodation,
    List<ParticipantTrack> tracks,
    double subColumnWidth,
  ) {
    final accommodationTracks = tracks.where((track) => 
      shouldShowAccommodationInTrack(accommodation, track)
    ).toList();
    
    if (accommodationTracks.isEmpty) return 0;
    
    accommodationTracks.sort((a, b) => a.position.compareTo(b.position));
    return accommodationTracks.first.position * subColumnWidth;
  }

  /// Calcula el ancho de un alojamiento
  static double calculateAccommodationWidth(
    Accommodation accommodation,
    List<ParticipantTrack> tracks,
    double subColumnWidth,
  ) {
    return calculateAccommodationSpan(accommodation, tracks) * subColumnWidth;
  }

  /// Verifica si un alojamiento es válido
  static bool isValidAccommodation(Accommodation accommodation) {
    return accommodation.hotelName.isNotEmpty;
  }

  /// Obtiene la fecha de check-in
  static DateTime getCheckInDate(Accommodation accommodation) {
    return accommodation.checkIn;
  }

  /// Obtiene la fecha de check-out
  static DateTime getCheckOutDate(Accommodation accommodation) {
    return accommodation.checkOut;
  }

  /// Verifica si es día de check-in
  static bool isCheckInDay(Accommodation accommodation, int dayNumber) {
    return accommodation.checkIn.day == dayNumber;
  }

  /// Verifica si es día de check-out
  static bool isCheckOutDay(Accommodation accommodation, int dayNumber) {
    return accommodation.checkOut.day == dayNumber;
  }

  /// Obtiene el texto del día para un alojamiento
  static String getAccommodationDayText(Accommodation accommodation, int dayNumber) {
    final baseText = accommodation.hotelName;
    
    if (isCheckInDay(accommodation, dayNumber)) {
      return '➡️ $baseText';
    } else if (isCheckOutDay(accommodation, dayNumber)) {
      return '$baseText ⬅️';
    }
    
    return baseText;
  }

  /// Calcula la duración del alojamiento en días
  static int getAccommodationDuration(Accommodation accommodation) {
    return accommodation.checkOut.difference(accommodation.checkIn).inDays;
  }

  /// Verifica si un alojamiento está activo en un día específico
  static bool isAccommodationActive(Accommodation accommodation, int dayNumber) {
    return dayNumber >= accommodation.checkIn.day && dayNumber <= accommodation.checkOut.day;
  }

  /// Obtiene el tipo de alojamiento
  static String getAccommodationType(Accommodation accommodation) {
    return accommodation.typeFamily;
  }

  /// Obtiene el subtipo de alojamiento
  static String getAccommodationSubtype(Accommodation accommodation) {
    return accommodation.typeSubtype;
  }
}
