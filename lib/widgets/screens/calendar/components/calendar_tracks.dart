import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_accommodation_logic.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_utils.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';

/// Componente que representa los headers y estructura de tracks (participantes)
/// 
/// Responsabilidad: Headers y estructura de tracks (participantes)
/// 
/// Este componente encapsula:
/// - Filas fijas de headers
/// - Contenido del header por día
/// - Headers mini de participantes
/// - Tracks de alojamientos
class CalendarTracks extends ConsumerWidget {
  /// Lista de columnas (días) a mostrar
  final List<dynamic> columns;
  
  /// Plan actual
  final Plan plan;
  
  /// ID del usuario activo (para resaltar track)
  final String? activeUserId;
  
  /// Callback para mostrar diálogo de nuevo alojamiento
  final void Function(DateTime dayDate) onShowNewAccommodationDialog;
  
  /// Callback para mostrar diálogo de alojamiento existente
  final void Function(Accommodation accommodation) onShowAccommodationDialog;
  
  /// Callback para mostrar diálogo de gestión de participantes
  final VoidCallback onShowParticipantManagementDialog;
  
  /// Función para determinar si un alojamiento debe mostrarse en un track
  final bool Function(Accommodation accommodation, int trackIndex) shouldShowAccommodationInTrack;
  
  /// Función para obtener tracks filtrados
  final List<ParticipantTrack> Function() getFilteredTracks;
  
  /// Función para crear borde de grid
  final Border Function({bool includeRight}) createGridBorder;
  
  /// Opacidad de líneas de grid
  final double gridLineOpacity;
  
  /// Función para obtener el timezone de un participante por su ID
  final String? Function(String participantId) getParticipantTimezone;

  const CalendarTracks({
    super.key,
    required this.columns,
    required this.plan,
    required this.activeUserId,
    required this.onShowNewAccommodationDialog,
    required this.onShowAccommodationDialog,
    required this.onShowParticipantManagementDialog,
    required this.shouldShowAccommodationInTrack,
    required this.getFilteredTracks,
    required this.createGridBorder,
    required this.gridLineOpacity,
    required this.getParticipantTimezone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            // GestureDetector para capturar taps en toda la fila
          },
          child: Row(
            children: columns.map((column) {
              return Expanded(
                child: Column(
                  children: [
                    // Encabezado de la columna
                    Container(
                      height: CalendarConstants.headerHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColorScheme.gridLineColor),
                        color: _getHeaderColor(column),
                      ),
                      child: Center(
                        child: _buildHeaderContent(column),
                      ),
                    ),
                    
                    // Fila de alojamientos con tracks
                    GestureDetector(
                      onTap: () {
                        // Crear nuevo alojamiento para este día
                        final dayData = column as Map<String, dynamic>;
                        final actualDayIndex = dayData['index'] as int;
                        final dayDate = plan.startDate.add(Duration(days: actualDayIndex - 1));
                        onShowNewAccommodationDialog(dayDate);
                      },
                      child: Container(
                        height: CalendarConstants.accommodationRowHeight,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColorScheme.gridLineColor),
                          // Estilo base: fondo oscuro, sin verde
                          color: Colors.grey.shade800,
                        ),
                        child: Center(
                          child: _buildAccommodationTracks(ref, column, constraints.maxWidth),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Obtiene el color del header según el tipo de columna
  Color _getHeaderColor(dynamic column) {
    final dayData = column as Map<String, dynamic>;
    final isEmpty = dayData['isEmpty'] as bool;
    // Estilo base: fondo oscuro, sin verde
    return isEmpty ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade800;
  }

  /// Construye el contenido del header
  Widget _buildHeaderContent(dynamic column) {
    final dayData = column as Map<String, dynamic>;
    final actualDayIndex = dayData['index'] as int;
    final isEmpty = dayData['isEmpty'] as bool;
    final participants = dayData['participants'] as List<ParticipantTrack>;
    
    if (isEmpty) {
      return const Text(
        'Vacío',
        style: TextStyle(fontSize: 10, color: Colors.grey),
      );
    }
    
    // Calcular la fecha de este día del plan
    final dayDate = plan.startDate.add(Duration(days: actualDayIndex - 1));
    final formattedDate = '${dayDate.day}/${dayDate.month}';
    
    // Obtener el nombre del día de la semana (traducible)
    final dayOfWeek = DateFormat.E().format(dayDate); // 'lun', 'mar', etc.
    
    // Generar iniciales de participantes
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Día $actualDayIndex - $dayOfWeek $formattedDate',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 2),
        // Mini headers de participantes
        _buildMiniParticipantHeaders(participants),
      ],
    );
  }

  /// Construye mini headers de participantes para el header principal
  Widget _buildMiniParticipantHeaders(List<ParticipantTrack> participants) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: participants.asMap().entries.map((entry) {
        final index = entry.key;
        final participant = entry.value;
        final isLastTrack = index == participants.length - 1;
        final isActiveTrack = activeUserId != null && participant.participantId == activeUserId;
        
        // Obtener iniciales usando FutureBuilder para cargar el nombre real del usuario
        return FutureBuilder<String>(
          future: _getParticipantDisplayName(participant.participantId),
          builder: (context, snapshot) {
            final displayName = snapshot.data ?? participant.participantName;
            final initial = _getParticipantInitials(displayName, participant.position);
            
            // Obtener timezone del participante
            final participantTimezone = getParticipantTimezone(participant.participantId);
            final timezoneColor = participantTimezone != null 
                ? TimezoneService.getTimezoneBarColor(participantTimezone)
                : null;
            
            return Expanded(
              child: GestureDetector(
                onTap: onShowParticipantManagementDialog,
                child: Tooltip(
                  message: participantTimezone != null
                      ? TimezoneService.getTimezoneDisplayName(participantTimezone)
                      : 'Timezone no configurada',
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                        decoration: BoxDecoration(
                          // Fondo diferenciado para track activo
                          color: isActiveTrack 
                              ? AppColorScheme.color1.withOpacity(0.2)
                              : Colors.transparent,
                          // Borde más grueso para track activo, normal para otros (excepto último)
                          border: isLastTrack 
                              ? null 
                              : (isActiveTrack
                                  ? Border(
                                      right: BorderSide(
                                        color: AppColorScheme.gridLineColor.withOpacity(gridLineOpacity),
                                        width: 1.5, // Borde más grueso para track activo
                                      ),
                                    )
                                  : createGridBorder()),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              initial,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isActiveTrack ? FontWeight.w900 : FontWeight.bold, // Más negrita si es activo
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // Barra lateral de color para timezone (T100)
                      if (timezoneColor != null)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: timezoneColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(2),
                                bottomLeft: Radius.circular(2),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /// Obtiene el nombre de visualización de un participante por su ID
  Future<String> _getParticipantDisplayName(String userId) async {
    try {
      // Obtener el usuario real desde Firestore usando UserService
      final userService = UserService();
      final user = await userService.getUser(userId);
      
      if (user != null) {
        // Priorizar displayName, luego username, luego email
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
          return user.displayName!;
        }
        if (user.username != null && user.username!.trim().isNotEmpty) {
          return '@${user.username!}';
        }
        return user.email;
      }
      
      // Si no se encuentra el usuario, devolver el userId como fallback
      return userId;
    } catch (e) {
      // En caso de error, devolver el userId
      return userId;
    }
  }

  /// Genera las iniciales del nombre y apellido de un participante
  String _getParticipantInitials(String participantName, int position) {
    if (participantName.isEmpty) {
      return 'P${position + 1}';
    }
    
    // Si el nombre empieza con @, es un username, usar solo la primera letra después del @
    if (participantName.startsWith('@')) {
      final username = participantName.substring(1);
      if (username.isNotEmpty) {
        return username[0].toUpperCase();
      }
    }
    
    // Dividir el nombre por espacios
    final nameParts = participantName.trim().split(' ');
    
    if (nameParts.length == 1) {
      // Solo un nombre, tomar la primera letra
      return nameParts[0].substring(0, 1).toUpperCase();
    } else if (nameParts.length >= 2) {
      // Nombre y apellido, tomar la primera letra de cada uno
      final firstName = nameParts[0].substring(0, 1).toUpperCase();
      final lastName = nameParts[1].substring(0, 1).toUpperCase();
      return '$firstName$lastName';
    }
    
    return 'P${position + 1}';
  }

  /// Construye los tracks de alojamiento para cada día
  Widget _buildAccommodationTracks(WidgetRef ref, dynamic column, double availableWidth) {
    final dayData = column as Map<String, dynamic>;
    final actualDayIndex = dayData['index'] as int;
    final isEmpty = dayData['isEmpty'] as bool;
    
    if (isEmpty) {
      return const Text(
        'Sin alojamiento',
        style: TextStyle(fontSize: 8, color: Colors.grey),
      );
    }
    
    // Obtener alojamientos del plan para este día
    final accommodations = ref.watch(accommodationsProvider(
      AccommodationNotifierParams(planId: plan.id ?? ''),
    ));
    
    final dayDate = plan.startDate.add(Duration(days: actualDayIndex - 1));
    final accommodationsForDay = accommodations.where((acc) => acc.isDateInRange(dayDate)).toList();
    
    if (accommodationsForDay.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Mostrar alojamientos como tracks
    return _buildAccommodationTracksRow(ref, accommodationsForDay, availableWidth, dayDate);
  }

  /// Construye la fila de tracks de alojamiento
  Widget _buildAccommodationTracksRow(WidgetRef ref, List<Accommodation> accommodations, double availableWidth, DateTime dayDate) {
    final visibleTracks = getFilteredTracks();

    return SizedBox(
      height: CalendarConstants.accommodationRowHeight,
      child: GestureDetector(
        onTap: () {
          // Outer GestureDetector for debugging
        },
        child: ClipRect(
          child: Stack(
            children: [
              // Fondo con tracks individuales
              Row(
                children: visibleTracks.asMap().entries.map((entry) {
                  final trackIndex = entry.key;
                  final track = visibleTracks[trackIndex];
                  final isLastTrack = trackIndex == visibleTracks.length - 1;
                  final isActiveTrack = activeUserId != null && track.participantId == activeUserId;
                  
                  // Obtener timezone del participante para la barra lateral (T100)
                  final participantTimezone = getParticipantTimezone(track.participantId);
                  final timezoneColor = participantTimezone != null 
                      ? TimezoneService.getTimezoneBarColor(participantTimezone)
                      : null;
                  
                  return Expanded(
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      height: CalendarConstants.accommodationRowHeight,
                      decoration: BoxDecoration(
                        // Fondo diferenciado para track activo
                        color: isActiveTrack 
                            ? AppColorScheme.color1.withOpacity(0.05)
                            : Colors.transparent,
                        // Borde más grueso para track activo
                        border: isLastTrack
                            ? null
                            : (isActiveTrack
                                ? Border(
                                    right: BorderSide(
                                      color: AppColorScheme.gridLineColor.withOpacity(gridLineOpacity),
                                      width: 1.5, // Borde más grueso para track activo
                                    ),
                                  )
                                : createGridBorder()),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // Encontrar alojamientos que deben mostrarse en este track
                          final accommodationsForTrack = accommodations.where((accommodation) =>
                            shouldShowAccommodationInTrack(accommodation, trackIndex)
                          ).toList();

                          if (accommodationsForTrack.isNotEmpty) {
                            onShowAccommodationDialog(accommodationsForTrack.first);
                          } else {
                            onShowNewAccommodationDialog(dayDate);
                          }
                        },
                        onDoubleTap: () {
                          onShowNewAccommodationDialog(dayDate);
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    // Barra lateral de color para timezone en fila de alojamientos (T100)
                    if (timezoneColor != null)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: timezoneColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(2),
                              bottomLeft: Radius.circular(2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
                }).toList(),
              ),
              // Alojamientos individuales usando Row en lugar de Positioned
              _buildAccommodationTracksWithGrouping(ref, accommodations, visibleTracks, availableWidth, dayDate),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye tracks de alojamiento con agrupación
  Widget _buildAccommodationTracksWithGrouping(
    WidgetRef ref,
    List<Accommodation> accommodations,
    List<ParticipantTrack> visibleTracks,
    double availableWidth,
    DateTime dayDate,
  ) {
    if (accommodations.isEmpty) {
      return const SizedBox.shrink();
    }

    // Para cada alojamiento, crear sus grupos de tracks consecutivos
    final allGroups = <Map<String, dynamic>>[];
    
    for (final accommodation in accommodations) {
      final groups = _getConsecutiveTrackGroupsForAccommodation(accommodation, visibleTracks);
      for (final group in groups) {
        allGroups.add({
          'accommodation': accommodation,
          'group': group,
        });
      }
    }
    
    // Ordenar grupos por el primer track
    allGroups.sort((a, b) => (a['group'] as List<int>).first.compareTo((b['group'] as List<int>).first));
    
    // Calcular el ancho de cada subcolumna
    final columnWidth = availableWidth / columns.length;
    final subColumnWidth = CalendarUtils.getSubColumnWidth(columnWidth, visibleTracks.length);
    
    return Stack(
      children: allGroups.map((groupData) {
        final accommodation = groupData['accommodation'] as Accommodation;
        final group = groupData['group'] as List<int>;
        final startTrack = group.first;
        final groupWidth = group.length;
        
        // Calcular posición y ancho
        final left = (startTrack * subColumnWidth).toDouble();
        final width = (subColumnWidth * groupWidth).toDouble();
        
        return Positioned(
          left: left,
          top: 5,
          width: width,
          height: 20,
          child: GestureDetector(
            onTap: () => onShowAccommodationDialog(accommodation),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: 0),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: accommodation.displayColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: accommodation.displayColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _getAccommodationDayText(accommodation, dayDate),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Obtiene grupos consecutivos de tracks para un alojamiento
  List<List<int>> _getConsecutiveTrackGroupsForAccommodation(
    Accommodation accommodation,
    List<ParticipantTrack> visibleTracks,
  ) {
    final groups = <List<int>>[];
    final currentGroup = <int>[];
    
    // Si el alojamiento no tiene participantTrackIds asignados, mostrarlo en todos los tracks
    final shouldShowInAllTracks = accommodation.participantTrackIds.isEmpty;
    
    for (int i = 0; i < visibleTracks.length; i++) {
      final track = visibleTracks[i];
      final shouldShow = shouldShowInAllTracks || 
                        CalendarAccommodationLogic.shouldShowAccommodationInTrack(accommodation, track);
      
      if (shouldShow) {
        currentGroup.add(i);
      } else {
        if (currentGroup.isNotEmpty) {
          groups.add(List.from(currentGroup));
          currentGroup.clear();
        }
      }
    }
    
    if (currentGroup.isNotEmpty) {
      groups.add(currentGroup);
    }
    
    return groups;
  }

  /// Determina si un día es check-in, check-out, o día intermedio para un alojamiento
  String _getAccommodationDayText(Accommodation accommodation, DateTime dayDate) {
    final checkInDate = accommodation.checkIn;
    final checkOutDate = accommodation.checkOut;
    
    // Normalizar fechas para comparación (solo año, mes, día)
    final normalizedDayDate = DateTime(dayDate.year, dayDate.month, dayDate.day);
    final normalizedCheckIn = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    final normalizedCheckOut = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
    
    if (normalizedDayDate.isAtSameMomentAs(normalizedCheckIn)) {
      return '${accommodation.hotelName} ➡️';
    } else if (normalizedDayDate.isAtSameMomentAs(normalizedCheckOut)) {
      return '${accommodation.hotelName} ⬅️';
    } else {
      return accommodation.hotelName;
    }
  }
}

