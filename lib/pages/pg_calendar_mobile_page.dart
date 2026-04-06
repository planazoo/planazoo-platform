import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
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
import 'package:unp_calendario/features/notifications/domain/services/notification_helper.dart';

/// Página de calendario mobile completa
/// Funciona como el calendario web pero adaptado para 1-3 días visibles
///
/// En modo embebido ([hideAppBar] true) la barra superior se dibuja en el padre
/// (barra unificada Calendario|Mi resumen + rango de días + 1/2/3) y se pasan
  /// [visibleDays], [firstVisiblePlanDayIndex] y los callbacks.
class CalendarMobilePage extends ConsumerStatefulWidget {
  final Plan plan;

  /// Si true, no se muestra AppBar (la barra va en el padre). Requiere pasar [visibleDays], [firstVisiblePlanDayIndex] y callbacks.
  final bool hideAppBar;

  /// Días visibles (1, 2 o 3) cuando [hideAppBar] es true.
  final int? visibleDays;

  /// Índice 1-based del primer día del plan mostrado en la columna izquierda (lista §3.2 ítem 99).
  final int? firstVisiblePlanDayIndex;

  final ValueChanged<int>? onVisibleDaysChanged;
  final VoidCallback? onPreviousDayGroup;
  final VoidCallback? onNextDayGroup;

  const CalendarMobilePage({
    super.key,
    required this.plan,
    this.hideAppBar = false,
    this.visibleDays,
    this.firstVisiblePlanDayIndex,
    this.onVisibleDaysChanged,
    this.onPreviousDayGroup,
    this.onNextDayGroup,
  });

  @override
  ConsumerState<CalendarMobilePage> createState() => _CalendarMobilePageState();
}

class _CalendarMobilePageState extends ConsumerState<CalendarMobilePage> {
  // Número de días visibles (1, 2 o 3); iOS por defecto 3 (ID 51).
  int _visibleDays =
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ? 3 : 1;

  /// Índice 1-based: primer día del plan en la columna izquierda.
  int _firstVisiblePlanDay = 1;

  int get _effectiveVisibleDays =>
      widget.hideAppBar && widget.visibleDays != null
          ? widget.visibleDays!
          : _visibleDays;
  int get _effectiveFirstVisiblePlanDay =>
      widget.hideAppBar && widget.firstVisiblePlanDayIndex != null
          ? widget.firstVisiblePlanDayIndex!
          : _firstVisiblePlanDay;

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
    _firstVisiblePlanDay =
        Plan.initialVisiblePlanDayIndex(widget.plan, _visibleDays);

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
      final target = _hoursScrollController.offset;
      if ((_dataScrollController.offset - target).abs() < 0.5) return;
      _isAutoScrolling = true;
      _dataScrollController.jumpTo(target);
      _isAutoScrolling = false;
    }
  }

  void _syncScrollFromData() {
    if (_isAutoScrolling) return;
    if (_dataScrollController.hasClients && _hoursScrollController.hasClients) {
      final target = _dataScrollController.offset;
      if ((_hoursScrollController.offset - target).abs() < 0.5) return;
      _isAutoScrolling = true;
      _hoursScrollController.jumpTo(target);
      _isAutoScrolling = false;
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
    return List.generate(_effectiveVisibleDays, (dayIndex) {
      final actualDayIndex = _effectiveFirstVisiblePlanDay + dayIndex;
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
    final inner = CalendarUtils.innerDayColumnWidth(columnWidth);
    final filteredTracks = _getFilteredTracks();
    final participantCount = filteredTracks.length;
    return CalendarUtils.getSubColumnWidth(inner, participantCount);
  }

  Border _createGridBorder({bool includeRight = true}) {
    return Border(
      right: includeRight
          ? BorderSide(
              color: Colors.white.withOpacity(CalendarConstants.calendarSeparatorOpacityMobile),
              width: CalendarConstants.calendarVerticalSeparatorWidth,
            )
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

  Color _getDataCellColor(dynamic column, int visibleDayIndex) {
    final dayData = column as Map<String, dynamic>;
    final isEmpty = dayData['isEmpty'] as bool;
    if (isEmpty) return Colors.grey.shade100;
    return visibleDayIndex % 2 == 0 ? const Color(0xFF1E1E1E) : const Color(0xFF161616);
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
              final date = widget.plan.dateForPlanDayIndex(actualDayIndex);
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
      children: columns.asMap().entries.map((entry) {
        final visibleDayIndex = entry.key;
        final column = entry.value;
        final dayData = column as Map<String, dynamic>;
        final participants = dayData['participants'] as List<ParticipantTrack>;

        return Expanded(
          child: Column(
            children: List.generate(AppConstants.defaultRowCount, (hourIndex) {
              return Container(
                height: AppConstants.cellHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColorScheme.gridLineColor.withOpacity(CalendarConstants.gridLineOpacity)),
                  color: _getDataCellColor(column, visibleDayIndex),
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
    final startDayIndex = _effectiveFirstVisiblePlanDay;
    final endDayIndex = startDayIndex + _effectiveVisibleDays - 1;
    final totalDays = widget.plan.durationInDays;
    final actualEndDayIndex = endDayIndex > totalDays ? totalDays : endDayIndex;
    
    List<Widget> eventWidgets = [];
    List<Event> previousDayEvents = [];
    
    final allUniqueEvents = <Event>[];
    
    for (int dayOffset = 0; dayOffset < (actualEndDayIndex - startDayIndex + 1); dayOffset++) {
      final currentDay = startDayIndex + dayOffset;
      final eventDate = widget.plan.dateForPlanDayIndex(currentDay);
      
      final eventsForDate = ref.watch(eventsForDateProvider(
        EventsForDateParams(
          calendarParams: CalendarNotifierParams(
            planId: widget.plan.id ?? '',
            userId: widget.plan.userId,
            initialDate: widget.plan.startDate,
            initialColumnCount: widget.plan.durationInDays,
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
      final eventDate = widget.plan.dateForPlanDayIndex(currentDay);
      
      final eventsForDate = ref.watch(eventsForDateProvider(
        EventsForDateParams(
          calendarParams: CalendarNotifierParams(
            planId: widget.plan.id ?? '',
            userId: widget.plan.userId,
            initialDate: widget.plan.startDate,
            initialColumnCount: widget.plan.durationInDays,
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
    
    final left = CalendarUtils.dayColumnContentLeft(columnWidth, dayOffset) + (startTrack.position * subColumnWidth);
    final width = subColumnWidth * trackSpan;
    
    final top = (segment.startMinute / 60.0) * AppConstants.cellHeight;
    final height = (segment.durationMinutes / 60.0) * AppConstants.cellHeight;
    final showDetailLines =
        segment.durationMinutes >= CalendarConstants.shortEventTitleOnlyMaxMinutes;
    final showParticipantsLine = showDetailLines && eventTracks.length > 1 && height >= 28;
    final titleMaxLines = (!showDetailLines || showParticipantsLine) ? 1 : 2;
    final innerPadding = height < 16 ? 1.0 : (height < 24 ? 2.0 : 4.0);
    final tinyHeight = height < 18;
    
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
              padding: EdgeInsets.all(innerPadding),
              child: tinyHeight
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _eventTitleWithTransportCode(event),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _eventTitleWithTransportCode(event),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: titleMaxLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showParticipantsLine)
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

  void _showEventDialog(Event event) async {
    Event eventToShow = event;
    if (event.id != null) {
      final fresh = await ref.read(eventServiceProvider).getEventByIdFromServer(event.id!);
      if (fresh != null) eventToShow = fresh;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EventDialog(
        event: eventToShow,
        planId: widget.plan.id ?? '',
        onSaved: (updatedEvent) async {
          final eventService = ref.read(eventServiceProvider);
          await eventService.updateEvent(updatedEvent);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          _invalidateEventProviders();
        },
        onDeleted: (eventId) async {
          final eventService = ref.read(eventServiceProvider);
          await eventService.deleteEvent(eventId);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          _invalidateEventProviders();
        },
      ),
    );
  }

  String? _transportCodeLabel(Event event) {
    final extra = event.commonPart?.extraData;
    if (extra == null) return null;
    for (final key in const ['flightNumber', 'trainNumber', 'transportNumber']) {
      final value = extra[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String _eventTitleWithTransportCode(Event event) {
    final code = _transportCodeLabel(event);
    return code != null ? '$code · ${event.description}' : event.description;
  }

  void _showNewEventDialogForParticipant(
    DateTime date,
    int hour,
    ParticipantTrack track, {
    int? initialStartMinute,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EventDialog(
        planId: widget.plan.id ?? '',
        initialDate: date,
        initialHour: hour,
        initialStartMinute: initialStartMinute,
        onSaved: (newEvent) async {
          final eventService = ref.read(eventServiceProvider);
          final eventId = await eventService.createEvent(newEvent);
          
          // T252: Si es propuesta (borrador de un participante), notificar al organizador
          if (newEvent.isDraft && widget.plan.userId != null && newEvent.userId != widget.plan.userId) {
            await NotificationHelper().notifyEventProposed(
              organizerUserId: widget.plan.userId!,
              planId: widget.plan.id ?? '',
              planName: widget.plan.name,
              eventId: eventId,
              eventDescription: newEvent.description,
            );
          }
          
          // Cerrar el diálogo
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          _invalidateEventProviders();
        },
      ),
    );
  }

  /// Invalida los providers de eventos/estadísticas para refrescar calendario, resumen, etc. en mobile.
  void _invalidateEventProviders() {
    if (widget.plan.id == null) {
      if (mounted) setState(() {});
      return;
    }
    final calendarParams = CalendarNotifierParams(
      planId: widget.plan.id!,
      userId: widget.plan.userId,
      initialDate: widget.plan.startDate,
      initialColumnCount: widget.plan.durationInDays,
    );
    final calendarNotifier = ref.read(calendarNotifierProvider(calendarParams).notifier);
    calendarNotifier.refreshEvents();
    ref.invalidate(planStatsProvider(widget.plan.id!));
    if (mounted) {
      setState(() {});
    }
  }

  void _showNewAccommodationDialog(DateTime dayDate) {
    if (widget.plan.id == null) return;
    showDialog(
      context: context,
      builder: (context) => AccommodationDialog(
        planId: widget.plan.id!,
        planStartDate: widget.plan.startDate,
        planEndDate: DateTime(
          widget.plan.endDate.year,
          widget.plan.endDate.month,
          widget.plan.endDate.day,
        ),
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
        planEndDate: DateTime(
          widget.plan.endDate.year,
          widget.plan.endDate.month,
          widget.plan.endDate.day,
        ),
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
    if (_effectiveFirstVisiblePlanDay <= 1) return;
    if (widget.onPreviousDayGroup != null) {
      widget.onPreviousDayGroup!();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstEvent();
      });
      return;
    }
    setState(() {
      _firstVisiblePlanDay = math.max(
        1,
        _firstVisiblePlanDay - _effectiveVisibleDays,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstEvent();
    });
  }

  void _nextDayGroup() {
    final totalDays = widget.plan.durationInDays;
    final startDay = _effectiveFirstVisiblePlanDay;
    final endDay = startDay + _effectiveVisibleDays - 1;
    if (endDay >= totalDays) return;
    if (widget.onNextDayGroup != null) {
      widget.onNextDayGroup!();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstEvent();
      });
      return;
    }
    setState(() {
      final next = _firstVisiblePlanDay + _effectiveVisibleDays;
      _firstVisiblePlanDay = next > totalDays ? totalDays : next;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstEvent();
    });
  }

  void _changeVisibleDays(int days) {
    if (widget.onVisibleDaysChanged != null) {
      widget.onVisibleDaysChanged!(days);
      return;
    }
    setState(() {
      _visibleDays = days;
      final totalDays = widget.plan.durationInDays;
      if (_firstVisiblePlanDay > totalDays) {
        _firstVisiblePlanDay =
            Plan.initialVisiblePlanDayIndex(widget.plan, _visibleDays);
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
      initialColumnCount: widget.plan.durationInDays,
    );

    ref.watch(calendarNotifierProvider(calendarParams));
    
    final startDay = _effectiveFirstVisiblePlanDay;
    final endDay = startDay + _effectiveVisibleDays - 1;
    final totalDays = widget.plan.durationInDays;

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: widget.hideAppBar
            ? null
            : _buildAppBar(startDay, endDay, totalDays),
        body: CalendarGrid(
          hoursScrollController: _hoursScrollController,
          dataScrollController: _dataScrollController,
          buildFixedRows: _buildFixedRows,
          buildDataRows: _buildDataRows,
          buildEventsLayer: _buildEventsLayer,
          onAccommodationHeaderTap: () {
            // Usar el mismo flujo móvil de creación de alojamientos.
            final visibleDays = _getColumnsToShow();
            if (visibleDays.isNotEmpty) {
              final firstDay = visibleDays.first as Map<String, dynamic>;
              final dayIndex = firstDay['index'] as int;
              final date = widget.plan.dateForPlanDayIndex(dayIndex);
              _showNewAccommodationDialog(date);
            } else {
              _showNewAccommodationDialog(widget.plan.startDate);
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final tracks = _getFilteredTracks();
            if (tracks.isEmpty) return;
            final d = NewEventFromButtonDefaults.forPlan(widget.plan);
            _showNewEventDialogForParticipant(
              d.date,
              d.hour,
              tracks.first,
              initialStartMinute: d.startMinute,
            );
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
            onPressed:
                _effectiveFirstVisiblePlanDay > 1 ? _previousDayGroup : null,
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
    final isSelected = _effectiveVisibleDays == days;
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
