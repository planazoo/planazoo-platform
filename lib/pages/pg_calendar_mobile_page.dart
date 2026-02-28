import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/calendar_state.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/track_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/event_participant_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/event_segment.dart';
import 'package:unp_calendario/features/calendar/domain/models/overlapping_segment_group.dart';
import 'package:unp_calendario/widgets/screens/calendar/components/calendar_grid.dart';
import 'package:unp_calendario/widgets/screens/calendar/components/calendar_tracks.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_event_logic.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_accommodation_logic.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_calculations.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_utils.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';
import 'package:unp_calendario/widgets/wd_accommodation_dialog.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/shared/utils/constants.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/stats/presentation/providers/plan_stats_providers.dart';
import 'package:unp_calendario/widgets/dialogs/manage_roles_dialog.dart';

/// Página de calendario mobile completa
/// Funciona como el calendario web pero adaptado para 1-3 días visibles
class CalendarMobilePage extends ConsumerStatefulWidget {
  final Plan plan;

  const CalendarMobilePage({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<CalendarMobilePage> createState() => _CalendarMobilePageState();
}

class _CalendarMobilePageState extends ConsumerState<CalendarMobilePage> {
  // Número de días visibles (1, 2 o 3)
  int _visibleDays = 1;
  
  // Estado para la navegación de días
  int _currentDayGroup = 0;
  
  // Controladores para scroll vertical sincronizado
  final ScrollController _hoursScrollController = ScrollController();
  final ScrollController _dataScrollController = ScrollController();
  
  // Servicio de tracks
  late final TrackService _trackService;
  
  // Variables para filtros
  String? _currentUserId;
  List<String> _filteredParticipantIds = [];
  
  // Variables para perspectiva de usuario
  String? _selectedPerspectiveUserId;
  
  // Variable para controlar sincronización durante auto-scroll
  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    _trackService = TrackService();
    _initializeTracks();
    
    // Sincronizar controladores de scroll
    _hoursScrollController.addListener(_syncScrollFromHours);
    _dataScrollController.addListener(_syncScrollFromData);
    
    // Posicionar scroll en la primera hora con eventos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstEvent();
    });
  }

  @override
  void dispose() {
    _hoursScrollController.dispose();
    _dataScrollController.dispose();
    super.dispose();
  }

  void _initializeTracks() {
    if (widget.plan.id == null) {
      final participantCount = widget.plan.participants ?? 1;
      final participants = List.generate(participantCount, (index) => {
        'id': 'participant_$index',
        'name': 'Participante ${index + 1}',
      });
      _trackService.createTracksForParticipants(participants);
    }
  }

  void _syncTracksWithParticipants() {
    if (widget.plan.id == null) return;
    
    final participantsAsync = ref.watch(planRealParticipantsProvider(widget.plan.id!));
    
    participantsAsync.when(
      data: (participations) {
        final currentTracks = _trackService.getVisibleTracks();
        final currentParticipantIds = currentTracks.map((t) => t.participantId).toSet();
        final newParticipantIds = participations.map((p) => p.userId).toSet();
        
        if (currentParticipantIds.length != newParticipantIds.length || 
            !currentParticipantIds.containsAll(newParticipantIds)) {
          _trackService.syncTracksWithPlanParticipants(participations);
          _trackService.loadOrderFromFirestore(widget.plan.id!);
          _trackService.loadSelectionFromFirestore(widget.plan.id!);
        }
        
        // Inicializar usuario actual
        if (_currentUserId == null && participations.isNotEmpty) {
          final currentUser = ref.read(currentUserProvider);
          if (currentUser != null) {
            final userParticipation = participations.firstWhere(
              (p) => p.userId == currentUser.id,
              orElse: () => participations.first,
            );
            _currentUserId = userParticipation.userId;
          }
        }
      },
      loading: () {},
      error: (error, stackTrace) {
        final participantCount = widget.plan.participants ?? 1;
        final participants = List.generate(participantCount, (index) => {
          'id': 'participant_$index',
          'name': 'Participante ${index + 1}',
        });
        _trackService.createTracksForParticipants(participants);
      },
    );
  }

  void _syncScrollFromHours() {
    if (_isAutoScrolling) return;
    if (_hoursScrollController.hasClients && _dataScrollController.hasClients) {
      _dataScrollController.jumpTo(_hoursScrollController.offset);
      setState(() {});
    }
  }

  void _syncScrollFromData() {
    if (_isAutoScrolling) return;
    if (_dataScrollController.hasClients && _hoursScrollController.hasClients) {
      _hoursScrollController.jumpTo(_dataScrollController.offset);
      setState(() {});
    }
  }

  /// Scroll automático al primer evento del día visible
  /// 
  /// TODO: Implementar scroll a primer evento (Mejora UX - baja prioridad)
  /// Esto mejoraría la experiencia al abrir el calendario mostrando
  /// automáticamente el primer evento del día en lugar del inicio del día.
  void _scrollToFirstEvent() {
    // Implementación futura: calcular posición del primer evento y hacer scroll
  }

  List<dynamic> _getColumnsToShow() {
    return List.generate(_visibleDays, (dayIndex) {
      final actualDayIndex = _currentDayGroup * _visibleDays + dayIndex + 1;
      final totalDays = widget.plan.durationInDays;
      final isEmpty = actualDayIndex > totalDays;
      return {
        'type': 'day',
        'index': actualDayIndex,
        'isEmpty': isEmpty,
        'participants': _getFilteredTracks(),
      };
    });
  }

  List<ParticipantTrack> _getFilteredTracks() {
    final tracks = _trackService.getVisibleTracks();
    if (_filteredParticipantIds.isEmpty) {
      return tracks;
    }
    return tracks.where((track) => _filteredParticipantIds.contains(track.participantId)).toList();
  }

  double _getSubColumnWidth(double availableWidth) {
    final columns = _getColumnsToShow();
    final columnWidth = availableWidth / columns.length;
    final filteredTracks = _getFilteredTracks();
    final participantCount = filteredTracks.length;
    return CalendarUtils.getSubColumnWidth(columnWidth, participantCount);
  }

  Border _createGridBorder({bool includeRight = true}) {
    return Border(
      right: includeRight 
          ? BorderSide(color: AppColorScheme.gridLineColor.withOpacity(CalendarConstants.gridLineOpacity), width: 0.5)
          : BorderSide.none,
    );
  }

  bool _shouldShowAccommodationInTrack(Accommodation accommodation, int trackIndex) {
    final visibleTracks = _getFilteredTracks();
    if (trackIndex >= visibleTracks.length) return false;
    final currentTrack = visibleTracks[trackIndex];
    return CalendarAccommodationLogic.shouldShowAccommodationInTrack(accommodation, currentTrack);
  }

  String? _getParticipantTimezone(String participantId) {
    final participantsAsync = ref.read(planRealParticipantsProvider(widget.plan.id!));
    return participantsAsync.when(
      data: (participations) {
        final participation = participations.firstWhere(
          (p) => p.userId == participantId,
          orElse: () => participations.first,
        );
        return participation.personalTimezone;
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Widget _buildFixedRows() {
    final columns = _getColumnsToShow();
    
    return CalendarTracks(
      columns: columns,
      plan: widget.plan,
      activeUserId: _selectedPerspectiveUserId ?? _currentUserId,
      onShowNewAccommodationDialog: _showNewAccommodationDialog,
      onShowAccommodationDialog: _showAccommodationDialog,
      onShowParticipantManagementDialog: _showParticipantManagementDialog,
      shouldShowAccommodationInTrack: _shouldShowAccommodationInTrack,
      getFilteredTracks: _getFilteredTracks,
      createGridBorder: _createGridBorder,
      gridLineOpacity: CalendarConstants.gridLineOpacity,
      getParticipantTimezone: _getParticipantTimezone,
    );
  }

  Color _getDataCellColor(dynamic column) {
    final dayData = column as Map<String, dynamic>;
    final isEmpty = dayData['isEmpty'] as bool;
    if (isEmpty) return Colors.grey.shade100;
    return Colors.grey.shade900;
  }

  bool _isActiveTrack(ParticipantTrack track) {
    final activeUserId = _selectedPerspectiveUserId ?? _currentUserId;
    return activeUserId != null && track.participantId == activeUserId;
  }

  Widget _buildEventCellWithSubColumns(int hourIndex, dynamic column, List<ParticipantTrack> participants) {
    final dayData = column as Map<String, dynamic>;
    final actualDayIndex = dayData['index'] as int;
    final activeUserId = _selectedPerspectiveUserId ?? _currentUserId;
    
    return Row(
      children: participants.asMap().entries.map((entry) {
        final index = entry.key;
        final participant = entry.value;
        final isLastTrack = index == participants.length - 1;
        final isActiveTrack = activeUserId != null && participant.participantId == activeUserId;
        final participantTimezone = _getParticipantTimezone(participant.participantId);
        final timezoneColor = participantTimezone != null 
            ? TimezoneService.getTimezoneBarColor(participantTimezone)
            : null;
        
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: () {
              final date = widget.plan.startDate.add(Duration(days: actualDayIndex - 1));
              _showNewEventDialogForParticipant(date, hourIndex, participant);
            },
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: AppConstants.cellHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isActiveTrack 
                        ? AppColorScheme.color2.withOpacity(0.05)
                        : Colors.transparent,
                    border: isActiveTrack && !isLastTrack
                        ? Border(
                            right: BorderSide(
                              color: AppColorScheme.gridLineColor.withOpacity(CalendarConstants.gridLineOpacity),
                              width: 1.5,
                            ),
                          )
                        : (isLastTrack ? null : _createGridBorder()),
                  ),
                ),
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
        );
      }).toList(),
    );
  }

  Widget _buildDataRows() {
    final columns = _getColumnsToShow();
    
    return Row(
      children: columns.map((column) {
        final dayData = column as Map<String, dynamic>;
        final participants = dayData['participants'] as List<ParticipantTrack>;
        
        return Expanded(
          child: Column(
            children: List.generate(AppConstants.defaultRowCount, (hourIndex) {
              return Container(
                height: AppConstants.cellHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColorScheme.gridLineColor.withOpacity(CalendarConstants.gridLineOpacity)),
                  color: _getDataCellColor(column),
                ),
                child: _buildEventCellWithSubColumns(hourIndex, column, participants),
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildEventsLayer(double availableWidth) {
    return _buildDaysEventsLayerWithSubColumns(availableWidth);
  }

  List<Widget> _buildDaysEventsLayerWithSubColumns(double availableWidth) {
    final startDayIndex = _currentDayGroup * _visibleDays + 1;
    final endDayIndex = startDayIndex + _visibleDays - 1;
    final totalDays = widget.plan.durationInDays;
    final actualEndDayIndex = endDayIndex > totalDays ? totalDays : endDayIndex;
    
    List<Widget> eventWidgets = [];
    List<Event> previousDayEvents = [];
    
    final allUniqueEvents = <Event>[];
    
    for (int dayOffset = 0; dayOffset < (actualEndDayIndex - startDayIndex + 1); dayOffset++) {
      final currentDay = startDayIndex + dayOffset;
      final eventDate = widget.plan.startDate.add(Duration(days: (currentDay - 1).toInt()));
      
      final eventsForDate = ref.watch(eventsForDateProvider(
        EventsForDateParams(
          calendarParams: CalendarNotifierParams(
            planId: widget.plan.id ?? '',
            userId: widget.plan.userId,
            initialDate: widget.plan.startDate,
            initialColumnCount: widget.plan.columnCount,
          ),
          date: eventDate,
        ),
      ));
      
      final allRelevantEvents = <Event>[
        ...eventsForDate,
        ...previousDayEvents.where((e) => _eventCrossesMidnight(e)),
      ];
      
      for (final event in allRelevantEvents) {
        if (event.id != null && !allUniqueEvents.any((e) => e.id == event.id)) {
          allUniqueEvents.add(event);
        }
      }
      
      previousDayEvents = allRelevantEvents;
    }
    
    final registeredParticipantsMap = <String, Set<String>>{};
    
    for (final event in allUniqueEvents) {
      if (event.id != null) {
        final participantsAsync = ref.watch(eventParticipantsProvider(event.id!));
        participantsAsync.maybeWhen(
          data: (participants) {
            final registeredUserIds = participants
                .where((p) => p.status == 'registered')
                .map((p) => p.userId)
                .toSet();
            if (registeredUserIds.isNotEmpty) {
              registeredParticipantsMap[event.id!] = registeredUserIds;
            }
          },
          orElse: () {},
        );
      }
    }
    
    previousDayEvents = [];
    
    for (int dayOffset = 0; dayOffset < (actualEndDayIndex - startDayIndex + 1); dayOffset++) {
      final currentDay = startDayIndex + dayOffset;
      final eventDate = widget.plan.startDate.add(Duration(days: (currentDay - 1).toInt()));
      
      final eventsForDate = ref.watch(eventsForDateProvider(
        EventsForDateParams(
          calendarParams: CalendarNotifierParams(
            planId: widget.plan.id ?? '',
            userId: widget.plan.userId,
            initialDate: widget.plan.startDate,
            initialColumnCount: widget.plan.columnCount,
          ),
          date: eventDate,
        ),
      ));
      
      final allRelevantEvents = <Event>[
        ...eventsForDate,
        ...previousDayEvents.where((e) => _eventCrossesMidnight(e)),
      ];
      
      final segments = _expandEventsToSegments(allRelevantEvents, eventDate);
      
      if (segments.isNotEmpty) {
        final overlappingGroups = _detectOverlappingSegments(segments);
        
        for (final group in overlappingGroups) {
          if (group.segments.length > 1) {
            eventWidgets.addAll(_buildOverlappingSegmentWidgetsWithSubColumns(group, dayOffset, availableWidth, registeredParticipantsMap: registeredParticipantsMap));
          } else {
            final segment = group.segments.first;
            eventWidgets.addAll(_buildSegmentWidgetWithSubColumns(segment, dayOffset, availableWidth, registeredParticipantsMap: registeredParticipantsMap));
          }
        }
      }
      
      previousDayEvents = allRelevantEvents;
    }
    
    return eventWidgets;
  }

  bool _eventCrossesMidnight(Event event) {
    return event.totalEndMinutes > 1440;
  }

  List<EventSegment> _expandEventsToSegments(List<Event> events, DateTime date) {
    final segments = <EventSegment>[];
    
    for (final event in events) {
      // Filtrar alojamientos (se renderizan aparte)
      if (event.typeFamily == 'alojamiento') continue;
      
      // Crear todos los segmentos del evento
      final eventSegments = EventSegment.createSegmentsForEvent(event);
      
      // Filtrar solo el segmento de este día
      for (final segment in eventSegments) {
        if (segment.segmentDate.year == date.year &&
            segment.segmentDate.month == date.month &&
            segment.segmentDate.day == date.day) {
          segments.add(segment);
        }
      }
    }
    
    return segments;
  }

  List<OverlappingSegmentGroup> _detectOverlappingSegments(List<EventSegment> segments) {
    return OverlappingSegmentGroup.detectOverlappingGroups(segments);
  }

  List<Widget> _buildOverlappingSegmentWidgetsWithSubColumns(
    OverlappingSegmentGroup group,
    int dayOffset,
    double availableWidth, {
    required Map<String, Set<String>> registeredParticipantsMap,
  }) {
    // Implementación simplificada - usar la misma lógica que el calendario web
    return group.segments.map((segment) {
      return _buildSegmentWidgetWithSubColumns(segment, dayOffset, availableWidth, registeredParticipantsMap: registeredParticipantsMap).first;
    }).toList();
  }

  List<Widget> _buildSegmentWidgetWithSubColumns(
    EventSegment segment,
    int dayOffset,
    double availableWidth, {
    required Map<String, Set<String>> registeredParticipantsMap,
  }) {
    final columns = _getColumnsToShow();
    final columnWidth = availableWidth / columns.length;
    final subColumnWidth = _getSubColumnWidth(availableWidth);
    final filteredTracks = _getFilteredTracks();
    
    final event = segment.originalEvent;
    final eventTracks = filteredTracks.where((track) => 
      CalendarEventLogic.shouldShowEventInTrack(event, track)
    ).toList();
    
    if (eventTracks.isEmpty) return [];
    
    eventTracks.sort((a, b) => a.position.compareTo(b.position));
    final startTrack = eventTracks.first;
    final trackSpan = eventTracks.length;
    
    final left = (dayOffset * columnWidth) + (startTrack.position * subColumnWidth);
    final width = subColumnWidth * trackSpan;
    
    final top = (segment.startMinute / 60.0) * AppConstants.cellHeight;
    final height = (segment.durationMinutes / 60.0) * AppConstants.cellHeight;
    
    return [
      Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: () => _showEventDialog(event),
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: ColorUtils.colorFromName(event.color ?? 'blue'),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.description,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (eventTracks.length > 1)
                    Text(
                      '${eventTracks.length} participantes',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  void _showEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: event,
        planId: widget.plan.id ?? '',
        onSaved: (updatedEvent) async {
          // Guardar el evento actualizado
          final eventService = ref.read(eventServiceProvider);
          await eventService.updateEvent(updatedEvent);
          
          // Cerrar el diálogo
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          
          // Esperar un poco para que se actualicen los providers
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Forzar actualización del estado
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  void _showNewEventDialogForParticipant(DateTime date, int hour, ParticipantTrack track) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        planId: widget.plan.id ?? '',
        initialDate: date,
        initialHour: hour,
        onSaved: (newEvent) async {
          // Guardar el evento
          final eventService = ref.read(eventServiceProvider);
          await eventService.createEvent(newEvent);
          
          // Cerrar el diálogo
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          
          // Esperar un poco para que se actualicen los providers
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Forzar actualización del estado
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  void _showNewAccommodationDialog(DateTime dayDate) {
    if (widget.plan.id == null) return;
    showDialog(
      context: context,
      builder: (context) => AccommodationDialog(
        planId: widget.plan.id!,
        planStartDate: widget.plan.startDate,
        planEndDate: widget.plan.startDate.add(Duration(days: widget.plan.durationInDays)),
        initialCheckIn: dayDate,
        onSaved: (newAccommodation) async {
          final notifier = ref.read(accommodationNotifierProvider(AccommodationNotifierParams(planId: widget.plan.id!)).notifier);
          final success = await notifier.saveAccommodation(newAccommodation);
          if (!context.mounted) return;
          Navigator.of(context).pop();
          if (mounted) {
            if (success) {
              if (widget.plan.id != null) {
                ref.invalidate(planStatsProvider(widget.plan.id!));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alojamiento creado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al guardar el alojamiento. Por favor, inténtalo de nuevo.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showAccommodationDialog(Accommodation accommodation) {
    if (widget.plan.id == null) return;
    showDialog(
      context: context,
      builder: (context) => AccommodationDialog(
        accommodation: accommodation,
        planId: widget.plan.id!,
        planStartDate: widget.plan.startDate,
        planEndDate: widget.plan.startDate.add(Duration(days: widget.plan.durationInDays)),
        onSaved: (updatedAccommodation) async {
          final notifier = ref.read(accommodationNotifierProvider(AccommodationNotifierParams(planId: widget.plan.id!)).notifier);
          final success = await notifier.saveAccommodation(updatedAccommodation);
          if (!context.mounted) return;
          Navigator.of(context).pop();
          if (mounted) {
            if (success) {
              if (widget.plan.id != null) {
                ref.invalidate(planStatsProvider(widget.plan.id!));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alojamiento actualizado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al guardar el alojamiento. Por favor, inténtalo de nuevo.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        onDeleted: (accommodationId) async {
          final notifier = ref.read(accommodationNotifierProvider(AccommodationNotifierParams(planId: widget.plan.id!)).notifier);
          final success = await notifier.deleteAccommodation(accommodationId);
          if (!context.mounted) return;
          Navigator.of(context).pop();
          if (mounted) {
            if (success && widget.plan.id != null) {
              ref.invalidate(planStatsProvider(widget.plan.id!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alojamiento eliminado'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showParticipantManagementDialog() {
    if (widget.plan.id == null) return;
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    showDialog(
      context: context,
      builder: (context) => ManageRolesDialog(
        planId: widget.plan.id!,
        currentUserId: currentUser.id,
      ),
    );
  }

  void _previousDayGroup() {
    if (_currentDayGroup > 0) {
      setState(() {
        _currentDayGroup--;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstEvent();
      });
    }
  }

  void _nextDayGroup() {
    final totalDays = widget.plan.durationInDays;
    final startDay = _currentDayGroup * _visibleDays + 1;
    final endDay = startDay + _visibleDays - 1;
    
    if (endDay < totalDays) {
      setState(() {
        _currentDayGroup++;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstEvent();
      });
    }
  }

  void _changeVisibleDays(int days) {
    setState(() {
      _visibleDays = days;
      final totalDays = widget.plan.durationInDays;
      final currentStartDay = _currentDayGroup * _visibleDays + 1;
      if (currentStartDay > totalDays) {
        _currentDayGroup = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _syncTracksWithParticipants();
    
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final calendarParams = CalendarNotifierParams(
      planId: widget.plan.id!,
      userId: currentUser.id,
      initialDate: widget.plan.startDate,
      initialColumnCount: widget.plan.columnCount,
    );

    ref.watch(calendarNotifierProvider(calendarParams));
    
    final startDay = _currentDayGroup * _visibleDays + 1;
    final endDay = startDay + _visibleDays - 1;
    final totalDays = widget.plan.durationInDays;
    
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: _buildAppBar(startDay, endDay, totalDays),
        body: CalendarGrid(
          hoursScrollController: _hoursScrollController,
          dataScrollController: _dataScrollController,
          buildFixedRows: _buildFixedRows,
          buildDataRows: _buildDataRows,
          buildEventsLayer: _buildEventsLayer,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final visibleDays = _getColumnsToShow();
            if (visibleDays.isNotEmpty) {
              final firstDay = visibleDays.first as Map<String, dynamic>;
              final dayIndex = firstDay['index'] as int;
              final date = widget.plan.startDate.add(Duration(days: dayIndex - 1));
              _showNewEventDialogForParticipant(date, 12, _getFilteredTracks().first);
            }
          },
          backgroundColor: AppColorScheme.color2,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int startDay, int endDay, int totalDays) {
    return AppBar(
      backgroundColor: Colors.grey.shade900,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentDayGroup > 0 ? _previousDayGroup : null,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'Días $startDay-$endDay de $totalDays',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: (endDay < totalDays) ? _nextDayGroup : null,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade800, // Color sólido, sin gradiente
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade700.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDaySelectorButton(1),
              const SizedBox(width: 8),
              _buildDaySelectorButton(2),
              const SizedBox(width: 8),
              _buildDaySelectorButton(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelectorButton(int days) {
    final isSelected = _visibleDays == days;
    return GestureDetector(
      onTap: () => _changeVisibleDays(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade800,
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColorScheme.color2.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          '$days día${days > 1 ? 's' : ''}',
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey.shade400,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
