import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/models/calendar_view_mode.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';
import 'package:unp_calendario/widgets/wd_accommodation_dialog.dart';

/// Clase que maneja el renderizado del grid del calendario
class CalendarGridRenderer {
  final Plan plan;
  final int currentDayGroup;
  final int visibleDays;
  final CalendarViewMode viewMode;
  final List<ParticipantTrack> filteredTracks;
  final List<Event> events;
  final List<Accommodation> accommodations;
  
  CalendarGridRenderer({
    required this.plan,
    required this.currentDayGroup,
    required this.visibleDays,
    required this.viewMode,
    required this.filteredTracks,
    required this.events,
    required this.accommodations,
  });

  /// Construye el cuerpo principal del calendario
  Widget buildCalendarBody({
    required BuildContext context,
    required VoidCallback onEventTap,
    required VoidCallback onAccommodationTap,
    required VoidCallback onEmptySpaceTap,
  }) {
    return Column(
      children: [
        // Filas fijas (headers y tracks)
        _buildFixedRows(context),
        
        // Filas de datos (eventos y alojamientos)
        Expanded(
          child: _buildScrollableRows(
            onEventTap: onEventTap,
            onAccommodationTap: onAccommodationTap,
            onEmptySpaceTap: onEmptySpaceTap,
            context: context,
          ),
        ),
      ],
    );
  }

  /// Construye las filas fijas (headers y tracks)
  Widget _buildFixedRows(BuildContext context) {
    final availableWidth = MediaQuery.of(context).size.width - 16.0; // Margen lateral
    final dayWidth = availableWidth / visibleDays;
    
    return Column(
      children: [
        // Headers de días
        _buildDayHeaders(dayWidth),
        
        // Headers de participantes
        _buildParticipantHeaders(dayWidth),
        
        // Headers mini de participantes
        _buildMiniParticipantHeaders(dayWidth),
      ],
    );
  }

  /// Construye las filas de datos scrollables
  Widget _buildScrollableRows({
    required VoidCallback onEventTap,
    required VoidCallback onAccommodationTap,
    required VoidCallback onEmptySpaceTap,
    required BuildContext context,
  }) {
    final availableWidth = MediaQuery.of(context).size.width - 16.0;
    final dayWidth = availableWidth / visibleDays;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Filas de eventos
          _buildEventRows(
            dayWidth,
            onEventTap: onEventTap,
            onEmptySpaceTap: onEmptySpaceTap,
          ),
          
          // Filas de alojamientos
          _buildAccommodationRows(
            dayWidth,
            onAccommodationTap: onAccommodationTap,
            onEmptySpaceTap: onEmptySpaceTap,
          ),
        ],
      ),
    );
  }

  /// Construye los headers de días
  Widget _buildDayHeaders(double dayWidth) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColorScheme.color1.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: AppColorScheme.color1.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: List.generate(visibleDays, (dayIndex) {
          final dayNumber = currentDayGroup * visibleDays + dayIndex + 1;
          final isToday = dayNumber == DateTime.now().day;
          
          return Container(
            width: dayWidth,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColorScheme.color1.withOpacity(0.3)),
              ),
            ),
            child: Center(
              child: Text(
                'Día $dayNumber',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? AppColorScheme.color1 : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Construye los headers de participantes
  Widget _buildParticipantHeaders(double dayWidth) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColorScheme.color1.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: AppColorScheme.color1.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: List.generate(visibleDays, (dayIndex) {
          return Container(
            width: dayWidth,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColorScheme.color1.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: filteredTracks.map((track) {
                final subColumnWidth = dayWidth / filteredTracks.length;
                return Container(
                  width: subColumnWidth,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      track.participantName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ),
    );
  }

  /// Construye los headers mini de participantes
  Widget _buildMiniParticipantHeaders(double dayWidth) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: AppColorScheme.color1.withOpacity(0.02),
        border: Border(
          bottom: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: List.generate(visibleDays, (dayIndex) {
          return Container(
            width: dayWidth,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: filteredTracks.map((track) {
                final subColumnWidth = dayWidth / filteredTracks.length;
                return Container(
                  width: subColumnWidth,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColorScheme.color1.withOpacity(0.05)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      track.participantName.split(' ').map((word) => word[0]).join(''),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ),
    );
  }

  /// Construye las filas de eventos
  Widget _buildEventRows(double dayWidth, {
    required VoidCallback onEventTap,
    required VoidCallback onEmptySpaceTap,
  }) {
    return Column(
      children: List.generate(visibleDays, (dayIndex) {
        final dayNumber = currentDayGroup * visibleDays + dayIndex + 1;
        final eventsForDay = events.where((event) => 
          event.commonPart?.date.day == dayNumber
        ).toList();
        
        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              // Columna de eventos para este día
              Container(
                width: dayWidth,
                child: _buildEventColumn(
                  eventsForDay,
                  dayWidth,
                  onEventTap: onEventTap,
                  onEmptySpaceTap: onEmptySpaceTap,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Construye las filas de alojamientos
  Widget _buildAccommodationRows(double dayWidth, {
    required VoidCallback onAccommodationTap,
    required VoidCallback onEmptySpaceTap,
  }) {
    return Column(
      children: List.generate(visibleDays, (dayIndex) {
        final dayNumber = currentDayGroup * visibleDays + dayIndex + 1;
        final accommodationsForDay = accommodations.where((acc) => 
          acc.checkIn.day == dayNumber || acc.checkOut.day == dayNumber
        ).toList();
        
        return Container(
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              // Columna de alojamientos para este día
              Container(
                width: dayWidth,
                child: _buildAccommodationColumn(
                  accommodationsForDay,
                  dayWidth,
                  onAccommodationTap: onAccommodationTap,
                  onEmptySpaceTap: onEmptySpaceTap,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Construye la columna de eventos para un día específico
  Widget _buildEventColumn(List<Event> eventsForDay, double dayWidth, {
    required VoidCallback onEventTap,
    required VoidCallback onEmptySpaceTap,
  }) {
    if (eventsForDay.isEmpty) {
      return GestureDetector(
        onTap: onEmptySpaceTap,
        child: Container(
          width: dayWidth,
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
            ),
          ),
        ),
      );
    }

    return Container(
      width: dayWidth,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
        ),
      ),
      child: Stack(
        children: eventsForDay.map((event) {
          return Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: dayWidth,
            child: GestureDetector(
              onTap: onEventTap,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: (event.commonPart?.customColor as Color?) ?? AppColorScheme.color1,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    event.commonPart?.description ?? 'Sin título',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Construye la columna de alojamientos para un día específico
  Widget _buildAccommodationColumn(List<Accommodation> accommodationsForDay, double dayWidth, {
    required VoidCallback onAccommodationTap,
    required VoidCallback onEmptySpaceTap,
  }) {
    if (accommodationsForDay.isEmpty) {
      return GestureDetector(
        onTap: onEmptySpaceTap,
        child: Container(
          width: dayWidth,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
            ),
          ),
        ),
      );
    }

    return Container(
      width: dayWidth,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColorScheme.color1.withOpacity(0.1)),
        ),
      ),
      child: Stack(
        children: accommodationsForDay.map((accommodation) {
          return Positioned(
            left: 0,
            top: 5,
            height: 20,
            width: dayWidth,
            child: GestureDetector(
              onTap: onAccommodationTap,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    accommodation.hotelName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
