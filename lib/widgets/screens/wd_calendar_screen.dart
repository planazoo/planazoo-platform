import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/event_segment.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/overlapping_segment_group.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/services/track_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/accommodation_service.dart';
import 'package:unp_calendario/shared/utils/constants.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/calendar/domain/services/date_service.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';
import 'package:unp_calendario/widgets/wd_accommodation_dialog.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final Plan plan;

  const CalendarScreen({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  // Estado para la navegación de días (grupos de 7 días)
  int _currentDayGroup = 0; // Grupo actual de 7 días (0 = días 1-7, 1 = días 8-14, etc.)
  static const int _daysPerGroup = 7;
  
  // Controladores para scroll vertical sincronizado
  final ScrollController _hoursScrollController = ScrollController();
  final ScrollController _dataScrollController = ScrollController();
  
  // Variables para drag & drop de eventos
  Event? _draggingEvent;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  
  // Variable para controlar sincronización durante auto-scroll
  bool _isAutoScrolling = false;
  
  // Flag para forzar reconstrucción de eventos
  int _eventRefreshCounter = 0;
  
  // Servicio de tracks para gestionar participantes
  late final TrackService _trackService;
  
  // Modo de visualización: 'days' (días) o 'tracks' (participantes)
  String _viewMode = 'days';
  
  // Número de días visibles simultáneamente (1-7)
  int _visibleDays = 7;

  @override
  void initState() {
    super.initState();
    
    // Inicializar el servicio de tracks
    _trackService = TrackService();
    _initializeTracks();
    
    // Sincronizar controladores de scroll
    _hoursScrollController.addListener(_syncScrollFromHours);
    _dataScrollController.addListener(_syncScrollFromData);
    
    // Posicionar el scroll en la hora del primer evento
    // Usar múltiples intentos con delays incrementales para asegurar que los datos estén cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstEvent();
    });
    
    // Reintentar después de delays más largos
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scrollToFirstEvent();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _scrollToFirstEvent();
    });
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _scrollToFirstEvent();
    });
  }

  @override
  void dispose() {
    _hoursScrollController.dispose();
    _dataScrollController.dispose();
    super.dispose();
  }

  /// Inicializa los tracks basándose en los participantes del plan
  void _initializeTracks() {
    // Crear tracks para los participantes del plan
    final participants = widget.plan.participants.map((p) => {
      'id': p['id'] ?? '',
      'name': p['name'] ?? 'Participante',
    }).toList();
    
    _trackService.createTracksForParticipants(participants);
  }

  /// Obtiene las columnas a mostrar según el modo de vista
  List<dynamic> _getColumnsToShow() {
    if (_viewMode == 'tracks') {
      return _trackService.getVisibleTracks();
    } else {
      // Modo días: generar lista de días basada en _visibleDays
      return List.generate(_visibleDays, (dayIndex) {
        final actualDayIndex = _currentDayGroup * _daysPerGroup + dayIndex + 1;
        final totalDays = widget.plan.durationInDays;
        final isEmpty = actualDayIndex > totalDays;
        return {
          'type': 'day',
          'index': actualDayIndex,
          'isEmpty': isEmpty,
        };
      });
    }
  }

  /// Obtiene el ancho de cada columna según el modo
  double _getColumnWidth(double availableWidth) {
    final columns = _getColumnsToShow();
    return availableWidth / columns.length;
  }

  /// Sincroniza el scroll desde la columna de horas hacia los datos
  void _syncScrollFromHours() {
    // No sincronizar durante auto-scroll
    if (_isAutoScrolling) {
      return;
    }
    
    if (_hoursScrollController.hasClients && _dataScrollController.hasClients) {
      _dataScrollController.jumpTo(_hoursScrollController.offset);
      // Actualizar la UI para que los eventos se reposicionen
      setState(() {});
    }
  }

  /// Sincroniza el scroll desde los datos hacia la columna de horas
  void _syncScrollFromData() {
    // No sincronizar durante auto-scroll
    if (_isAutoScrolling) {
      return;
    }
    
    if (_dataScrollController.hasClients && _hoursScrollController.hasClients) {
      _hoursScrollController.jumpTo(_dataScrollController.offset);
      // Actualizar la UI para que los eventos se reposicionen
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildCalendarBody(),
    );
  }

  /// Construye el AppBar con navegación de días
  PreferredSizeWidget _buildAppBar() {
    final startDay = _currentDayGroup * _daysPerGroup + 1;
    final endDay = (startDay + _daysPerGroup - 1);
    final totalDays = widget.plan.durationInDays;
    
    return AppBar(
      toolbarHeight: 48.0, // Reducido de 56px (por defecto) a 48px
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentDayGroup > 0 ? _previousDayGroup : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Días anteriores',
          ),
          Text(
            _viewMode == 'tracks' 
              ? 'Tracks (${_trackService.getVisibleTracksCount()} participantes)'
              : 'Días $startDay-${startDay + _visibleDays - 1} de $totalDays ($_visibleDays visibles)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          IconButton(
            onPressed: (startDay + _visibleDays - 1) < totalDays ? _nextDayGroup : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Días siguientes',
          ),
        ],
      ),
      actions: [
        // Control de días visibles (solo en modo días)
        if (_viewMode == 'days')
          PopupMenuButton<int>(
            icon: const Icon(Icons.tune, color: Colors.white),
            tooltip: 'Ajustar días visibles',
            onSelected: (int value) {
              setState(() {
                _visibleDays = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.calendar_view_day, size: 16),
                    const SizedBox(width: 8),
                    const Text('1 día'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.calendar_view_week, size: 16),
                    const SizedBox(width: 8),
                    const Text('3 días'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 7,
                child: Row(
                  children: [
                    Icon(Icons.calendar_view_month, size: 16),
                    const SizedBox(width: 8),
                    const Text('7 días'),
                  ],
                ),
              ),
            ],
          ),
        
        // Botón para cambiar modo de vista
        IconButton(
          onPressed: _toggleViewMode,
          icon: Icon(
            _viewMode == 'tracks' ? Icons.calendar_view_day : Icons.people,
            color: Colors.white,
          ),
          tooltip: _viewMode == 'tracks' ? 'Cambiar a vista días' : 'Cambiar a vista tracks',
        ),
      ],
      backgroundColor: AppColorScheme.color1,
      foregroundColor: Colors.white,
    );
  }

  /// Cambia entre el modo días y tracks
  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == 'days' ? 'tracks' : 'days';
    });
  }

  /// Navega al grupo anterior de días
  void _previousDayGroup() {
    if (_currentDayGroup > 0) {
      setState(() {
        _currentDayGroup--;
      });
      // Reposicionar scroll después del cambio
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstEvent();
      });
    }
  }

  /// Navega al grupo siguiente de días
  void _nextDayGroup() {
    final totalDays = widget.plan.durationInDays;
    final startDay = _currentDayGroup * _daysPerGroup + 1;
    final endDay = startDay + _visibleDays - 1;
    
    if (endDay < totalDays) {
      setState(() {
        _currentDayGroup++;
      });
      // Reposicionar scroll después del cambio
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstEvent();
      });
    }
  }

  /// Construye el cuerpo del calendario
  Widget _buildCalendarBody() {
    return Stack(
      children: [
        // Capa 1: Calendario base (fijo)
        Row(
          children: [
            // Columna FIJO (horas) - fija
            _buildFixedHoursColumn(),
            
            // Columnas de datos - 7 días fijos
            Expanded(
              child: _buildDataColumns(),
            ),
          ],
        ),
        
      ],
    );
  }

  /// Construye la columna fija de horas
  Widget _buildFixedHoursColumn() {
    return Container(
      width: 80.0, // Ancho fijo para mostrar "00:00"
      child: Column(
        children: [
          // Encabezado (primera celda)
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: AppColorScheme.gridLineColor),
              color: AppColorScheme.color1,
            ),
            child: const Center(
              child: SizedBox.shrink(), // Celda vacía
            ),
          ),
          
          // Fila de alojamientos FIJA
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: AppColorScheme.gridLineColor),
              color: AppColorScheme.color1.withOpacity(0.5),
            ),
            child: const Center(
              child: Text(
                'Alojamiento',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          
        // Filas de horas con scroll vertical
        Expanded(
          child: SingleChildScrollView(
            controller: _hoursScrollController,
              child: Column(
                children: List.generate(AppConstants.defaultRowCount, (index) {
                  return Container(
                    height: AppConstants.cellHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColorScheme.gridLineColor),
                      color: AppColorScheme.color0,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${index.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye las columnas de datos (7 días)
  Widget _buildDataColumns() {
    return Column(
      children: [
        // Filas fijas (encabezado y alojamientos)
        _buildFixedRows(),
        
        // Filas con scroll vertical (datos de horas)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Capa 1: Datos de la tabla
                  SingleChildScrollView(
                    controller: _dataScrollController,
                    child: Stack(
                      children: [
                        _buildDataRows(),
                        // Capa 2: Eventos (Positioned) - Ahora dentro del SingleChildScrollView
                        ..._buildEventsLayer(constraints.maxWidth),
                        // Capa 3: Detector invisible para doble clicks en celdas vacías (deshabilitado temporalmente)
                        // _buildDoubleClickDetector(constraints.maxWidth),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construye las filas fijas (encabezado y alojamientos)
  Widget _buildFixedRows() {
    final columns = _getColumnsToShow();
    
    return Row(
      children: columns.map((column) {
        return Expanded(
          child: Column(
            children: [
              // Encabezado de la columna
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColorScheme.gridLineColor),
                  color: _getHeaderColor(column),
                ),
                child: Center(
                  child: _buildHeaderContent(column),
                ),
              ),
              
              // Contenido adicional (alojamientos para días, espacio vacío para tracks)
              Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColorScheme.gridLineColor),
                  color: _getContentColor(column),
                ),
                child: Center(
                  child: _buildAdditionalContent(column),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Obtiene el color del header según el tipo de columna
  Color _getHeaderColor(dynamic column) {
    if (_viewMode == 'tracks') {
      final track = column as ParticipantTrack;
      return ColorUtils.hexToColor(track.customColor ?? TrackColors.getColorForPosition(track.position));
    } else {
      final dayData = column as Map<String, dynamic>;
      final isEmpty = dayData['isEmpty'] as bool;
      return isEmpty ? Colors.grey.shade200 : AppColorScheme.color1;
    }
  }

  /// Obtiene el color del contenido según el tipo de columna
  Color _getContentColor(dynamic column) {
    if (_viewMode == 'tracks') {
      return AppColorScheme.color1.withOpacity(0.5);
    } else {
      final dayData = column as Map<String, dynamic>;
      final isEmpty = dayData['isEmpty'] as bool;
      return isEmpty ? Colors.grey.shade100 : AppColorScheme.color1.withOpacity(0.5);
    }
  }

  /// Construye el contenido del header
  Widget _buildHeaderContent(dynamic column) {
    if (_viewMode == 'tracks') {
      final track = column as ParticipantTrack;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            track.participantName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Track ${track.position + 1}',
            style: const TextStyle(
              fontSize: 8,
              color: Colors.white70,
            ),
          ),
        ],
      );
    } else {
      final dayData = column as Map<String, dynamic>;
      final actualDayIndex = dayData['index'] as int;
      final isEmpty = dayData['isEmpty'] as bool;
      
      if (isEmpty) {
        return const Text(
          'Vacío',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        );
      }
      
      // Calcular la fecha de este día del plan
      final dayDate = widget.plan.startDate.add(Duration(days: actualDayIndex - 1));
      final formattedDate = '${dayDate.day}/${dayDate.month}/${dayDate.year}';
      
      // Obtener el nombre del día de la semana (traducible)
      final dayOfWeek = DateFormat.E().format(dayDate); // 'lun', 'mar', etc.
      
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Día $actualDayIndex - $dayOfWeek',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }

  /// Construye el contenido adicional (alojamientos para días)
  Widget _buildAdditionalContent(dynamic column) {
    if (_viewMode == 'tracks') {
      // Para tracks, solo mostramos espacio vacío
      return const Text(
        'Mi Track',
        style: TextStyle(fontSize: 8, color: Colors.grey),
      );
    } else {
      final dayData = column as Map<String, dynamic>;
      final actualDayIndex = dayData['index'] as int;
      final isEmpty = dayData['isEmpty'] as bool;
      
      if (isEmpty) {
        return const Text(
          'Sin alojamiento',
          style: TextStyle(fontSize: 8, color: Colors.grey),
        );
      }
      
      return _buildAccommodationCell(actualDayIndex);
    }
  }

  /// Construye las filas de datos (horas)
  Widget _buildDataRows() {
    final columns = _getColumnsToShow();
    
    return Row(
      children: columns.map((column) {
        return Expanded(
          child: Column(
            children: List.generate(AppConstants.defaultRowCount, (hourIndex) {
              return Container(
                height: AppConstants.cellHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColorScheme.gridLineColor),
                  color: _getDataCellColor(column),
                ),
                child: _buildEventCell(hourIndex, column),
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  /// Obtiene el color de la celda de datos según el tipo de columna
  Color _getDataCellColor(dynamic column) {
    if (_viewMode == 'tracks') {
      return AppColorScheme.color0;
    } else {
      final dayData = column as Map<String, dynamic>;
      final isEmpty = dayData['isEmpty'] as bool;
      return isEmpty ? Colors.grey.shade100 : AppColorScheme.color0;
    }
  }

  /// Construye la celda de alojamiento
  Widget _buildAccommodationCell(int dayIndex) {
    // Obtener la fecha de este día
    final dayDate = widget.plan.startDate.add(Duration(days: dayIndex - 1));
    
    // Obtener alojamientos del plan
    final accommodations = ref.watch(accommodationsProvider(
      AccommodationNotifierParams(planId: widget.plan.id ?? ''),
    ));
    
    // Filtrar alojamientos para este día específico
    final accommodationsForDay = accommodations.where((acc) => acc.isDateInRange(dayDate)).toList();
    
    if (accommodationsForDay.isEmpty) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: () => _showNewAccommodationDialog(dayDate),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
        ),
      );
    }
    
    // Mostrar el primer alojamiento (si hay varios, mostrar el más relevante)
    final accommodation = accommodationsForDay.first;
    
    return GestureDetector(
      onTap: () => _showAccommodationDialog(accommodation),
      onDoubleTap: () => _showNewAccommodationDialog(dayDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: Text(
          accommodation.hotelName,
          style: TextStyle(
            fontSize: 10,
            color: accommodation.displayColor,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Construye la capa de eventos usando EventSegments (estilo Google Calendar)
  List<Widget> _buildEventsLayer(double availableWidth) {
    if (_viewMode == 'tracks') {
      return _buildTracksEventsLayer(availableWidth);
    } else {
      return _buildDaysEventsLayer(availableWidth);
    }
  }

  /// Construye la capa de eventos para el modo tracks
  List<Widget> _buildTracksEventsLayer(double availableWidth) {
    List<Widget> eventWidgets = [];
    
    // Obtener todos los eventos del plan (por ahora, usar todos los eventos)
    // TODO: Optimizar para obtener solo eventos relevantes
    final allEvents = ref.watch(eventsProvider(
      CalendarNotifierParams(
        planId: widget.plan.id ?? '',
        userId: widget.plan.userId,
        initialDate: widget.plan.startDate,
        initialColumnCount: widget.plan.columnCount,
      ),
    ));

    // Procesar cada evento
    for (final event in allEvents) {
      final eventWidget = _buildTrackEventWidget(event, availableWidth);
      if (eventWidget != null) {
        eventWidgets.add(eventWidget);
      }
    }

    return eventWidgets;
  }

  /// Construye la capa de eventos para el modo días (comportamiento original)
  List<Widget> _buildDaysEventsLayer(double availableWidth) {
    final startDayIndex = _currentDayGroup * _daysPerGroup + 1;
    final endDayIndex = startDayIndex + _daysPerGroup - 1;
    final totalDays = widget.plan.durationInDays;
    final actualEndDayIndex = endDayIndex > totalDays ? totalDays : endDayIndex;
    
    List<Widget> eventWidgets = [];
    List<Event> previousDayEvents = []; // Cache de eventos del día anterior
    
    // Obtener eventos para cada día en el rango actual
    for (int dayOffset = 0; dayOffset < (actualEndDayIndex - startDayIndex + 1); dayOffset++) {
      final currentDay = startDayIndex + dayOffset;
      final eventDate = widget.plan.startDate.add(Duration(days: currentDay - 1));
      
      // Obtener eventos para esta fecha usando ref.watch para reaccionar a cambios
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
      
      // NUEVO: Combinar eventos de hoy + eventos de ayer que continúan hoy
      final allRelevantEvents = <Event>[
        ...eventsForDate,
        ...previousDayEvents.where((e) => _eventCrossesMidnight(e)),
      ];
      
      // Expandir eventos a segmentos para este día específico
      final segments = _expandEventsToSegments(allRelevantEvents, eventDate);
      
      if (segments.isNotEmpty) {
        // Detectar segmentos solapados
        final overlappingGroups = _detectOverlappingSegments(segments);
        
        // Renderizar grupos de segmentos solapados
        for (final group in overlappingGroups) {
          if (group.segments.length > 1) {
            // Hay solapamiento - renderizar con layout especial
            eventWidgets.addAll(_buildOverlappingSegmentWidgets(group, dayOffset, availableWidth));
          } else {
            // Solo un segmento - renderizado normal
            final segment = group.segments.first;
            eventWidgets.add(_buildSegmentWidget(segment, dayOffset, availableWidth));
          }
        }
      }
      
      // CORREGIDO: Guardar TODOS los eventos procesados (no solo eventsForDate)
      // Esto asegura que eventos multi-día se propaguen correctamente al siguiente día
      previousDayEvents = allRelevantEvents;
    }
    
    return eventWidgets;
  }

  /// Construye un widget de evento para el modo tracks
  Widget? _buildTrackEventWidget(Event event, double availableWidth) {
    // Calcular posición y ancho del evento
    final positionData = _calculateEventPositionAndWidth(event, availableWidth);
    final x = positionData['x']!;
    final width = positionData['width']!;

    // Calcular posición Y basada en la hora del evento
    final startTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );
    
    final planStartTime = DateTime(
      widget.plan.startDate.year,
      widget.plan.startDate.month,
      widget.plan.startDate.day,
      0, // Empezar desde medianoche
    );
    
    final minutesFromStart = startTime.difference(planStartTime).inMinutes;
    final y = (minutesFromStart / 60.0) * AppConstants.cellHeight;
    final height = (event.durationMinutes / 60.0) * AppConstants.cellHeight;

    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => _showEventDialog(event),
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: ColorUtils.hexToColor(event.color ?? AppColorScheme.color2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (event.participantTrackIds.length > 1)
                  Text(
                    '${event.participantTrackIds.length} participantes',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Expande una lista de eventos a segmentos para un día específico
  /// Incluye eventos que empiezan en este día Y continuaciones de eventos del día anterior
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

  /// Detecta segmentos solapados usando el nuevo sistema
  List<OverlappingSegmentGroup> _detectOverlappingSegments(List<EventSegment> segments) {
    return OverlappingSegmentGroup.detectOverlappingGroups(segments);
  }


  /// Construye un evento en una posición específica (para eventos solapados)
  Widget _buildEventWidgetAtPosition(Event event, double x, double width, double availableWidth) {
    final cellHeight = AppConstants.cellHeight;
    final scrollOffset = _dataScrollController.hasClients ? _dataScrollController.offset : 0.0;
    
    final totalFixedHeight = 0.0;
    final y = totalFixedHeight + (event.totalStartMinutes * cellHeight / 60);
    
    // Calcular altura del evento
    double height;
    if (_eventCrossesMidnight(event)) {
      final startTime = event.hour * 60 + event.startMinute;
      final midnightMinutes = 1440;
      final currentDayDurationMinutes = midnightMinutes - startTime;
      height = (currentDayDurationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    } else {
      height = (event.durationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    }
    
    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: _buildDraggableEvent(event),
    );
  }

  /// Construye una continuación en una posición específica (para continuaciones solapadas)
  Widget _buildContinuationWidgetAtPosition(Event continuationEvent, double x, double width, double availableWidth) {
    final cellHeight = AppConstants.cellHeight;
    final scrollOffset = _dataScrollController.hasClients ? _dataScrollController.offset : 0.0;
    
    // Las continuaciones siempre empiezan a las 00:00
    final totalFixedHeight = 0.0;
    final y = totalFixedHeight + (0 * cellHeight / 60); // Empieza en 00:00
    
    // La duración ya está calculada correctamente en el evento virtual
    final height = (continuationEvent.durationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    
    return Positioned(
      left: x,
      top: y - scrollOffset,
      width: width,
      height: height,
      child: _buildDraggableEventForContinuation(continuationEvent, height),
    );
  }

  /// Construye un evento draggable para continuación (cuando está solapada)
  Widget _buildDraggableEventForContinuation(Event continuationEvent, double height) {
    // Las continuaciones NO son draggables por ahora
    // Solo se puede arrastrar el evento original desde su día inicial

    // Calcular tamaño de fuente basado en la altura del evento
    double fontSize;
    if (height < 20) {
      fontSize = 6;
    } else if (height < 40) {
      fontSize = 8;
    } else {
      fontSize = 10;
    }

    return GestureDetector(
      onTap: () {
        // Al hacer click, abrir el diálogo del evento ORIGINAL
        // Necesitamos encontrar el evento original (esto es un hack temporal)
        // En producción deberíamos pasar el evento original al método
        _showEventDialog(continuationEvent);
      },
      // DESHABILITADO: No permitir drag desde continuaciones
      // Solo se puede arrastrar desde el evento original en el día anterior
      // onPanStart, onPanUpdate, onPanEnd están intencionalmente NO implementados
      child: Container(
          decoration: BoxDecoration(
            color: ColorUtils.getEventColor(continuationEvent.typeFamily, continuationEvent.isDraft, customColor: continuationEvent.color),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: ColorUtils.getEventBorderColor(continuationEvent.typeFamily, continuationEvent.isDraft, customColor: continuationEvent.color),
              width: 1,
            ),
          ),
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción del evento
                  Text(
                    continuationEvent.description,
                    style: TextStyle(
                      color: ColorUtils.getEventTextColor(continuationEvent.typeFamily, continuationEvent.isDraft, customColor: continuationEvent.color),
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Hora - para continuaciones siempre es 00:00 - XX:XX
                  Flexible(
                    child: Text(
                      '00:00 - ${continuationEvent.durationMinutes ~/ 60}:${(continuationEvent.durationMinutes % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: ColorUtils.getEventTextColor(continuationEvent.typeFamily, continuationEvent.isDraft, customColor: continuationEvent.color),
                        fontSize: fontSize - 2,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
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
  }

  /// Verifica si un evento cruza medianoche
  bool _eventCrossesMidnight(Event event) {
    final startTime = event.hour * 60 + event.startMinute;
    final endTime = startTime + event.durationMinutes;
    return endTime > 1440; // 1440 minutos = 24 horas
  }

  /// Verifica si añadir/mover un evento excedería el límite de 3 eventos solapados
  /// 
  /// Regla de negocio: Máximo 3 eventos pueden solaparse simultáneamente en cualquier momento
  /// 
  /// [eventToCheck] - El evento que queremos añadir/mover
  /// [targetDate] - La fecha donde queremos colocar el evento
  /// [eventIdToExclude] - ID del evento a excluir del conteo (cuando editamos un evento existente)
  /// 
  /// Returns true si añadir este evento excedería el límite de 3 solapados
  bool _wouldExceedOverlapLimit({
    required Event eventToCheck,
    required DateTime targetDate,
    String? eventIdToExclude,
  }) {
    const int MAX_OVERLAPPING = 3;
    
    // Obtener eventos para la fecha objetivo
    final eventsForDate = ref.read(eventsForDateProvider(
      EventsForDateParams(
        calendarParams: CalendarNotifierParams(
          planId: widget.plan.id ?? '',
          userId: widget.plan.userId,
          initialDate: widget.plan.startDate,
          initialColumnCount: widget.plan.columnCount,
        ),
        date: targetDate,
      ),
    ));
    
    // Crear segmentos para todos los eventos relevantes (incluyendo continuaciones del día anterior)
    final allRelevantEvents = <Event>[...eventsForDate];
    
    // Si el día anterior tiene eventos que cruzan medianoche, necesitamos incluirlos
    if (targetDate.isAfter(widget.plan.startDate)) {
      final previousDate = targetDate.subtract(const Duration(days: 1));
      final previousDayEvents = ref.read(eventsForDateProvider(
        EventsForDateParams(
          calendarParams: CalendarNotifierParams(
            planId: widget.plan.id ?? '',
            userId: widget.plan.userId,
            initialDate: widget.plan.startDate,
            initialColumnCount: widget.plan.columnCount,
          ),
          date: previousDate,
        ),
      ));
      
      allRelevantEvents.addAll(
        previousDayEvents.where((e) => _eventCrossesMidnight(e))
      );
    }
    
    // Añadir el evento a validar a la lista (si no es edición)
    allRelevantEvents.add(eventToCheck);
    
    // Expandir a segmentos para este día
    final segments = _expandEventsToSegments(allRelevantEvents, targetDate);
    
    // Filtrar eventos de alojamiento y el evento a excluir
    final relevantSegments = segments.where((segment) {
      if (segment.originalEvent.typeFamily == 'alojamiento') return false;
      if (eventIdToExclude != null && segment.originalEvent.id == eventIdToExclude) return false;
      return true;
    }).toList();
    
    // Para cada minuto del día, verificar cuántos eventos están activos
    final eventToCheckStart = eventToCheck.hour * 60 + eventToCheck.startMinute;
    final eventToCheckEnd = eventToCheckStart + eventToCheck.durationMinutes;
    
    // Solo necesitamos verificar los minutos que ocupa el evento a validar
    for (int minute = eventToCheckStart; minute < eventToCheckEnd.clamp(0, 1440); minute++) {
      int overlappingCount = 0;
      
      // Contar cuántos segmentos ocupan este minuto específico
      for (final segment in relevantSegments) {
        final segmentStart = segment.startMinute;
        final segmentEnd = segment.endMinute;
        
        // ¿Este segmento ocupa este minuto?
        if (minute >= segmentStart && minute < segmentEnd) {
          overlappingCount++;
        }
      }
      
      // Si en algún minuto hay más de MAX_OVERLAPPING eventos, excede el límite
      if (overlappingCount > MAX_OVERLAPPING) {
        return true;
      }
    }
    
    return false; // No excede el límite
  }

  /// Crea un evento virtual que representa la continuación de un evento que cruza medianoche
  Event _createContinuationEvent(Event originalEvent) {
    final startTime = originalEvent.hour * 60 + originalEvent.startMinute;
    final endTime = startTime + originalEvent.durationMinutes;
    final continuationDurationMinutes = endTime - 1440; // Duración en el día siguiente
    
    // Crear fecha para el día siguiente
    final nextDayDate = originalEvent.date.add(const Duration(days: 1));
    
    return Event(
      id: '${originalEvent.id}_continuation', // ID único para evitar conflictos en drag & drop
      planId: originalEvent.planId,
      userId: originalEvent.userId,
      date: nextDayDate,
      description: originalEvent.description,
      typeFamily: originalEvent.typeFamily,
      hour: 0, // Empieza a las 00:00
      duration: 0, // Mantenido por compatibilidad
      startMinute: 0,
      durationMinutes: continuationDurationMinutes,
      color: originalEvent.color,
      isDraft: originalEvent.isDraft,
      createdAt: originalEvent.createdAt,
      updatedAt: originalEvent.updatedAt,
    );
  }

  /// Obtiene el evento original a partir del ID de una continuación
  String _getOriginalEventId(String continuationId) {
    return continuationId.replaceAll('_continuation', '');
  }

  /// Verifica si un evento es una continuación virtual
  bool _isContinuationEvent(Event event) {
    return event.id?.endsWith('_continuation') ?? false;
  }

  /// Construye un widget de evento para el día siguiente (parte que cruza medianoche)
  Widget _buildEventWidgetForNextDay(Event event, int dayOffset, double availableWidth) {
    final cellWidth = availableWidth / _daysPerGroup;
    final cellHeight = AppConstants.cellHeight;
    
    final x = (dayOffset * cellWidth) + (cellWidth * 0.025);
    final scrollOffset = _dataScrollController.hasClients ? _dataScrollController.offset : 0.0;
    
    // Calcular la parte del evento que está en el día siguiente
    final startTime = event.hour * 60 + event.startMinute;
    final endTime = startTime + event.durationMinutes;
    final midnightMinutes = 1440; // 24:00 = 1440 minutos
    
    // La parte que cruza medianoche empieza a las 00:00 del día siguiente
    final nextDayStartMinutes = 0;
    final nextDayEndMinutes = endTime - midnightMinutes;
    final nextDayDurationMinutes = nextDayEndMinutes - nextDayStartMinutes;
    
    // Ajustar posición Y: empezar desde el top de las celdas de datos
    final totalFixedHeight = 0.0; // Ajustado para alineación correcta en 00:00h
    final baseY = totalFixedHeight + (nextDayStartMinutes * cellHeight / 60);
    final y = baseY - scrollOffset;
    
    final width = cellWidth * 0.95;
    final height = (nextDayDurationMinutes * cellHeight / 60).clamp(0.0, 1440.0); // Limitar altura máxima
    
    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: _buildDraggableEventForNextDay(event, height),
    );
  }


  /// Construye un evento draggable para el día siguiente con fuente ajustada
  Widget _buildDraggableEventForNextDay(Event event, double height) {
    final isThisEventDragging = _draggingEvent?.id == event.id;

    final displayOffset = isThisEventDragging
        ? _calculateConsistentPosition(event, _dragOffset)
        : _dragOffset;

    // Calcular tamaño de fuente basado en la altura del evento
    double fontSize;
    if (height < 20) {
      fontSize = 6; // Muy pequeño para eventos muy pequeños
    } else if (height < 40) {
      fontSize = 8; // Pequeño para eventos pequeños
    } else {
      fontSize = 10; // Tamaño normal
    }

    return GestureDetector(
      onTap: () => _showEventDialog(event),
      onPanStart: (details) => _startDrag(event, details),
      onPanUpdate: (details) => _updateDrag(details),
      onPanEnd: (details) => _endDrag(details),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          displayOffset.dx,
          displayOffset.dy,
          0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ColorUtils.getEventColor(event.typeFamily, event.isDraft, customColor: event.color),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: ColorUtils.getEventBorderColor(event.typeFamily, event.isDraft, customColor: event.color),
              width: 1,
            ),
            boxShadow: isThisEventDragging ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.all(1), // Padding mínimo
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título del evento
                  Flexible(
                    child: Text(
                      event.description,
                      style: TextStyle(
                        color: ColorUtils.getEventTextColor(event.typeFamily, event.isDraft, customColor: event.color),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1, // Solo una línea para eventos pequeños
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Mostrar horas solo si hay espacio suficiente
                  if (height > 25) ...[
                    const SizedBox(height: 2),
                    
                    // Horas en una sola línea para eventos multi-día
                    Flexible(
                      child: Text(
                        '00:00 - ${_formatNextDayEndTime(event)}',
                        style: TextStyle(
                          color: ColorUtils.getEventTextColor(event.typeFamily, event.isDraft, customColor: event.color),
                          fontSize: fontSize - 2,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Posiciona el scroll en la hora del primer evento del plan
  void _scrollToFirstEvent() {
    // Verificar que el plan tenga ID
    if (widget.plan.id == null) {
      return;
    }
    
    // Intentar obtener eventos con un pequeño delay para asegurar que estén cargados
    Future.delayed(const Duration(milliseconds: 100), () {
      _performScrollToFirstEvent();
    });
  }
  
  /// Realiza el scroll al primer evento (llamado con delay)
  void _performScrollToFirstEvent() {
    // Verificar que el widget sigue montado
    if (!mounted) return;
    
    // Obtener todos los eventos del plan
    final allEvents = <Event>[];
    for (int i = 0; i < widget.plan.durationInDays; i++) {
      final date = widget.plan.startDate.add(Duration(days: i));
      try {
        final events = ref.read(eventsForDateProvider(EventsForDateParams(
          calendarParams: CalendarNotifierParams(
            planId: widget.plan.id!,
            userId: widget.plan.userId,
            initialDate: widget.plan.startDate,
          ),
          date: date,
        )));
        allEvents.addAll(events);
      } catch (e) {
        // Si hay error al obtener eventos, continuar con el siguiente día
        continue;
      }
    }
    
    // Si no hay eventos, no hacer scroll
    if (allEvents.isEmpty) {
      return;
    }
    
    // Encontrar el evento que empieza más temprano
    Event? earliestEvent;
    int earliestTime = 1440; // 24:00 en minutos
    
    for (final event in allEvents) {
      final eventTime = event.hour * 60 + event.startMinute;
      if (eventTime < earliestTime) {
        earliestTime = eventTime;
        earliestEvent = event;
      }
    }
    
    if (earliestEvent == null) {
      return;
    }
    
    // Calcular la posición de scroll
    final cellHeight = AppConstants.cellHeight;
    final headerHeight = 60.0; // Altura de la fila de días
    final accommodationHeight = 30.0; // Altura de la fila de alojamientos
    final totalFixedHeight = headerHeight + accommodationHeight;
    
    // Determinar la posición de scroll basada en el tipo de evento
    int targetScrollMinutes;
    
    // Verificar si es un evento de todo el día
    final isAllDayEvent = _isAllDayEvent(earliestEvent);
    
    if (isAllDayEvent) {
      // Para eventos de todo el día, mostrar desde las 00:00
      targetScrollMinutes = 0;
    } else {
      // Para eventos normales, mostrar 1 hora antes del primer evento
      final eventStartMinutes = earliestEvent.hour * 60 + earliestEvent.startMinute;
      targetScrollMinutes = (eventStartMinutes - 60).clamp(0, 1380); // Máximo hasta 23:00
    }
    
    final scrollPosition = totalFixedHeight + (targetScrollMinutes * cellHeight / 60);
    
    // Aplicar el scroll
    if (_dataScrollController.hasClients) {
      final maxScrollExtent = _dataScrollController.position.maxScrollExtent;
      final finalScrollPosition = scrollPosition.clamp(0.0, maxScrollExtent);
      
      // Deshabilitar sincronización durante el auto-scroll
      _isAutoScrolling = true;
      
      _dataScrollController.animateTo(
        finalScrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        // Forzar actualización de la UI para reposicionar eventos
        if (mounted) {
          setState(() {});
        }
        
        // Rehabilitar sincronización después del scroll
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _isAutoScrolling = false;
            // Forzar otra actualización después de reabilitar sincronización
            setState(() {});
          }
        });
      });
      
      // Sincronizar también el scroll de horas
      if (_hoursScrollController.hasClients) {
        _hoursScrollController.animateTo(
          finalScrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Determina si un evento es de todo el día
  bool _isAllDayEvent(Event event) {
    // Un evento es de todo el día si:
    // 1. Empieza a las 00:00 y dura al menos 20 horas, O
    // 2. Dura al menos 23 horas (independientemente de la hora de inicio)
    final durationHours = event.durationMinutes / 60;
    final startsAtMidnight = event.hour == 0 && event.startMinute == 0;
    
    return (startsAtMidnight && durationHours >= 20) || durationHours >= 23;
  }

  /// Formatea la hora de fin para eventos multi-día en el segundo día
  String _formatNextDayEndTime(Event event) {
    // Calcular cuántos minutos del evento están en el segundo día
    final nextDayStartMinutes = 0; // Empieza a las 00:00 del segundo día
    final nextDayEndMinutes = event.totalEndMinutes - 1440; // Minutos que sobran después de 24:00
    
    // Convertir a hora:minuto
    final endHour = nextDayEndMinutes ~/ 60;
    final endMinute = nextDayEndMinutes % 60;
    
    return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }
  
  /// Obtiene la hora de fin para mostrar en eventos que cruzan medianoche (día actual)
  String _getNextDayEndTime(Event event) {
    final nextDayEndMinutes = event.totalEndMinutes - 1440;
    final endHour = nextDayEndMinutes ~/ 60;
    final endMinute = nextDayEndMinutes % 60;
    return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')} +1';
  }

  /// Construye widgets para segmentos solapados
  List<Widget> _buildOverlappingSegmentWidgets(OverlappingSegmentGroup group, int dayOffset, double availableWidth) {
    final cellWidth = availableWidth / _daysPerGroup;
    final widgets = <Widget>[];
    
    // Indicador de límite alcanzado
    const int MAX_OVERLAPPING = 3;
    final isAtLimit = group.segments.length >= MAX_OVERLAPPING;
    
    // Calcular ancho para cada segmento solapado
    final segmentWidth = (cellWidth * 0.95) / group.segments.length;
    
    for (int i = 0; i < group.segments.length; i++) {
      final segment = group.segments[i];
      final x = (dayOffset * cellWidth) + (cellWidth * 0.025) + (i * segmentWidth);
      
      widgets.add(_buildSegmentWidgetAtPosition(
        segment, 
        x, 
        segmentWidth, 
        availableWidth,
        showLimitIndicator: isAtLimit && i == group.segments.length - 1, // Mostrar en el último
      ));
    }
    
    return widgets;
  }

  /// Construye un segmento en una posición específica (para segmentos solapados)
  Widget _buildSegmentWidgetAtPosition(
    EventSegment segment, 
    double x, 
    double width, 
    double availableWidth, {
    bool showLimitIndicator = false,
  }) {
    final cellHeight = AppConstants.cellHeight;
    
    // NO restar scrollOffset porque los eventos están dentro del SingleChildScrollView
    final totalFixedHeight = 0.0;
    final y = totalFixedHeight + (segment.startMinute * cellHeight / 60);
    
    // Calcular altura del segmento
    final height = (segment.durationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    
    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: _buildDraggableSegment(segment, height, showLimitIndicator: showLimitIndicator),
    );
  }

  /// Construye un segmento individual (sin solapamiento)
  Widget _buildSegmentWidget(EventSegment segment, int dayOffset, double availableWidth) {
    final cellWidth = availableWidth / _daysPerGroup;
    final cellHeight = AppConstants.cellHeight;
    
    final x = (dayOffset * cellWidth) + (cellWidth * 0.025);
    final width = cellWidth * 0.95;
    
    // NO restar scrollOffset porque los eventos están dentro del SingleChildScrollView
    final totalFixedHeight = 0.0;
    final y = totalFixedHeight + (segment.startMinute * cellHeight / 60);
    
    // Calcular altura del segmento
    final height = (segment.durationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    
    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: _buildDraggableSegment(segment, height),
    );
  }

  /// Construye un segmento draggable
  Widget _buildDraggableSegment(EventSegment segment, double height, {bool showLimitIndicator = false}) {
    final originalEvent = segment.originalEvent;
    final isThisEventDragging = _draggingEvent?.id == originalEvent.id;
    
    // Calcular posición magnética si está siendo arrastrado
    final displayOffset = isThisEventDragging 
        ? _calculateConsistentPosition(originalEvent, _dragOffset)
        : Offset.zero;
    
    // Calcular tamaño de fuente basado en la altura
    double fontSize;
    if (height < 20) {
      fontSize = 6;
    } else if (height < 40) {
      fontSize = 8;
    } else {
      fontSize = 10;
    }
    
    // IMPORTANTE: Solo permitir drag desde el primer segmento del evento
    // Continuaciones (isFirst=false) solo son clickeables, no draggables
    final Widget child = segment.isFirst
        ? GestureDetector(
            onTap: () => _showEventDialog(originalEvent),
            onPanStart: (details) => _startDrag(originalEvent, details),
            onPanUpdate: (details) => _updateDrag(details),
            onPanEnd: (details) => _endDrag(details),
            child: _buildSegmentContainer(segment, height, fontSize, isThisEventDragging, displayOffset, showLimitIndicator),
          )
        : GestureDetector(
            onTap: () => _showEventDialog(originalEvent),
            // Sin onPanStart/Update/End - las continuaciones NO son draggables
            child: _buildSegmentContainer(segment, height, fontSize, false, Offset.zero, showLimitIndicator),
          );
    
    return child;
  }

  /// Construye el container visual del segmento (separado para reutilización)
  Widget _buildSegmentContainer(EventSegment segment, double height, double fontSize, bool isDragging, Offset displayOffset, bool showLimitIndicator) {
    return Stack(
      children: [
        AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          displayOffset.dx,
          displayOffset.dy,
          0,
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorUtils.getEventColor(segment.typeFamily, segment.isDraft, customColor: segment.color),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: ColorUtils.getEventBorderColor(segment.typeFamily, segment.isDraft, customColor: segment.color),
              width: 1,
            ),
            boxShadow: isDragging ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: ClipRect(
            child: Padding(
              padding: EdgeInsets.all(height < 15 ? 0.5 : 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Descripción del evento
                  Flexible(
                    child: Text(
                      segment.description,
                      style: TextStyle(
                        color: ColorUtils.getEventTextColor(segment.typeFamily, segment.isDraft, customColor: segment.color),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Hora
                  if (height > 15)
                    Flexible(
                      child: Text(
                        _formatSegmentTime(segment),
                        style: TextStyle(
                          color: ColorUtils.getEventTextColor(segment.typeFamily, segment.isDraft, customColor: segment.color),
                          fontSize: fontSize - 2,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Indicador visual de límite alcanzado
      if (showLimitIndicator)
        Positioned(
          top: 2,
          right: 2,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.9),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Formatea el tiempo de un segmento según si es inicio, continuación o fin
  String _formatSegmentTime(EventSegment segment) {
    final startHour = segment.startMinute ~/ 60;
    final startMin = segment.startMinute % 60;
    final endHour = segment.endMinute ~/ 60;
    final endMin = segment.endMinute % 60;
    
    if (segment.isFirst && segment.isLast) {
      // Evento normal de un solo día
      return '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')} - ${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
    } else if (segment.isFirst) {
      // Primer día de evento multi-día
      return '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')} - ${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')} +1';
    } else if (segment.isLast) {
      // Último día de evento multi-día
      return '00:00 - ${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
    } else {
      // Día intermedio (raro, pero posible en eventos muy largos)
      return '00:00 - 23:59';
    }
  }

  /// Construye un evento individual como Positioned widget
  Widget _buildEventWidget(Event event, double availableWidth) {
    final startDayIndex = _currentDayGroup * _daysPerGroup + 1;
    final eventDayIndex = event.date.difference(widget.plan.startDate).inDays + 1;
    final dayIndex = eventDayIndex - startDayIndex;
    
    // Si el evento no está en el rango de días actual, no lo mostramos
    if (dayIndex < 0 || dayIndex >= _daysPerGroup) {
      return const SizedBox.shrink();
    }
    
        // Usar el ancho real disponible pasado desde LayoutBuilder
        final cellWidth = availableWidth / _daysPerGroup;
        
    final cellHeight = AppConstants.cellHeight;
    
    
    final x = (dayIndex * cellWidth) + (cellWidth * 0.025); // Centrado: 2.5% de margen a cada lado
    final scrollOffset = _dataScrollController.hasClients ? _dataScrollController.offset : 0.0;
    
    // Posición Y: ahora que los eventos están dentro del SingleChildScrollView,
    // no necesitamos restar el scrollOffset
    final totalFixedHeight = 0.0; // Ajustado para alineación correcta en 00:00h
    final y = totalFixedHeight + (event.totalStartMinutes * cellHeight / 60);
    
    final width = cellWidth * 0.95; // 5% más estrecho que la columna
    
    // Calcular altura del evento - si cruza medianoche, mostrar solo la parte del día actual
    double height;
    if (_eventCrossesMidnight(event)) {
      final startTime = event.hour * 60 + event.startMinute;
      final midnightMinutes = 1440; // 24:00 = 1440 minutos
      final endTime = startTime + event.durationMinutes;
      final currentDayDurationMinutes = midnightMinutes - startTime;
      height = (currentDayDurationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    } else {
      height = (event.durationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    }
    
    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: _buildDraggableEvent(event),
    );
  }

  /// Construye un evento draggable
  Widget _buildDraggableEvent(Event event) {
    final isThisEventDragging = _draggingEvent?.id == event.id;
    
    // Calcular posición magnética si está siendo arrastrado
    final displayOffset = isThisEventDragging 
        ? _calculateConsistentPosition(event, _dragOffset)
        : _dragOffset;
    
    // Calcular altura del evento para ajustar el tamaño de fuente
    final eventHeight = (event.durationMinutes * AppConstants.cellHeight / 60);
    
    // Calcular tamaño de fuente basado en la altura del evento
    double fontSize;
    if (eventHeight < 20) {
      fontSize = 6; // Muy pequeño para eventos muy pequeños
    } else if (eventHeight < 40) {
      fontSize = 8; // Pequeño para eventos pequeños
    } else {
      fontSize = 10; // Tamaño normal
    }
    
    return GestureDetector(
      onTap: () => _showEventDialog(event),
      onPanStart: (details) => _startDrag(event, details),
      onPanUpdate: (details) => _updateDrag(details),
      onPanEnd: (details) => _endDrag(details),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
        transform: isThisEventDragging ? Matrix4.translationValues(displayOffset.dx, displayOffset.dy, 0) : null,
        child: Container(
          decoration: BoxDecoration(
            color: ColorUtils.getEventColor(event.typeFamily, event.isDraft, customColor: event.color),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: ColorUtils.getEventBorderColor(event.typeFamily, event.isDraft, customColor: event.color),
              width: 1,
            ),
            boxShadow: isThisEventDragging ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: ClipRect(
            child: Padding(
              padding: EdgeInsets.all(eventHeight < 30 ? 1 : 2), // Padding más pequeño
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título del evento
                  Flexible(
                    child: Text(
                      event.description,
                      style: TextStyle(
                        color: ColorUtils.getEventTextColor(event.typeFamily, event.isDraft, customColor: event.color),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: eventHeight < 30 ? 1 : 2, // Líneas adaptativas
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Mostrar horas solo si hay espacio suficiente
                  if (eventHeight > 25) ...[
                    const SizedBox(height: 2),
                    
                    // Horas en una sola línea
                    Flexible(
                      child: Text(
                        _eventCrossesMidnight(event)
                            ? '${event.hour.toString().padLeft(2, '0')}:${event.startMinute.toString().padLeft(2, '0')} - ${_getNextDayEndTime(event)}'
                            : '${event.hour.toString().padLeft(2, '0')}:${event.startMinute.toString().padLeft(2, '0')} - ${event.endHour.toString().padLeft(2, '0')}:${event.endMinute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: ColorUtils.getEventTextColor(event.typeFamily, event.isDraft, customColor: event.color),
                          fontSize: fontSize - 2,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Inicia el drag de un evento
  void _startDrag(Event event, DragStartDetails details) {
    setState(() {
      _draggingEvent = event;
      _isDragging = true;
      _dragOffset = Offset.zero;
    });
  }

  /// Actualiza la posición durante el drag
  void _updateDrag(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  /// Calcula la posición magnética para el drag visual
  // Función común para calcular la posición consistente
  Offset _calculateConsistentPosition(Event event, Offset dragOffset) {
    // Obtener dimensiones de celda
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 80.0;
    final cellWidth = availableWidth / _daysPerGroup;
    
    // Calcular posición actual del evento
    final currentDayIndex = event.date.difference(widget.plan.startDate).inDays + 1;
    final startDayIndex = _currentDayGroup * _daysPerGroup + 1;
    final currentColumnIndex = currentDayIndex - startDayIndex;
    
    // Calcular nueva columna basada en el offset horizontal
    final totalOffsetX = dragOffset.dx;
    final columnProgress = totalOffsetX / cellWidth;
    final newColumnOffset = columnProgress.round(); // Inmediato
    final newColumnIndex = currentColumnIndex + newColumnOffset;
    
    // Verificar que la nueva columna esté en el rango válido
    if (newColumnIndex < 0 || newColumnIndex >= _daysPerGroup) {
      return dragOffset; // Mantener posición actual si está fuera de rango
    }
    
    // Calcular offset magnético horizontal - usar el dragOffset directamente
    final magneticX = dragOffset.dx;
    
    // Para el magnetismo vertical, usar el dragOffset.dy directamente
    // SIN cálculos complejos - solo el movimiento del mouse
    final magneticY = dragOffset.dy;
    
    
    
    
    
    return Offset(magneticX, magneticY);
  }

  /// Termina el drag y posiciona el evento
  void _endDrag(DragEndDetails details) async {
    if (_draggingEvent == null) return;
    
    
    final eventToUpdate = _draggingEvent!;
    final dragOffset = _dragOffset;
    
    try {
      // Calcular la nueva posición basada en el offset del drag
      final newPosition = _calculateNewEventPosition(eventToUpdate, dragOffset);
      
      if (newPosition != null) {
        // Crear una copia del evento con la nueva posición
        final updatedEvent = eventToUpdate.copyWith(
          date: newPosition['date'] as DateTime,
          hour: newPosition['hour'] as int,
          startMinute: newPosition['startMinute'] as int,
          updatedAt: DateTime.now(),
        );
        
        // VALIDAR: ¿Excedería el límite de 3 solapados en la nueva posición?
        if (_wouldExceedOverlapLimit(
          eventToCheck: updatedEvent,
          targetDate: updatedEvent.date,
          eventIdToExclude: eventToUpdate.id, // Excluir el evento que estamos moviendo
        )) {
          // Mostrar mensaje y cancelar el drag
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '⚠️ No se puede mover: ya hay 3 eventos en ese horario',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          
          // Limpiar estado (el evento vuelve a su posición original)
          setState(() {
            _draggingEvent = null;
            _isDragging = false;
            _dragOffset = Offset.zero;
          });
          return; // Cancelar el drag
        }
        
        // Si pasa validación, actualizar el evento en la base de datos
        final eventService = ref.read(eventServiceProvider);
        final success = await eventService.updateEvent(updatedEvent);
        
        if (success) {
          // Invalidar el CalendarNotifier que es la fuente real de los datos
          ref.invalidate(calendarNotifierProvider(
            CalendarNotifierParams(
              planId: widget.plan.id ?? '',
              userId: widget.plan.userId,
              initialDate: widget.plan.startDate,
              initialColumnCount: widget.plan.columnCount,
            ),
          ));
          
          // Forzar reconstrucción de la UI
          setState(() {});
        }
      }
    } catch (e) {
      // Error updating event
    } finally {
      // Limpiar estado después de procesar el drop
      setState(() {
        _draggingEvent = null;
        _isDragging = false;
        _dragOffset = Offset.zero;
      });
    }
  }

  /// Calcula la nueva posición del evento basada en el offset del drag
  Map<String, dynamic>? _calculateNewEventPosition(Event event, Offset dragOffset) {
    try {
      // Obtener el ancho de una celda
      final screenWidth = MediaQuery.of(context).size.width;
      final availableWidth = screenWidth - 80.0; // Restar columna de horas
      final cellWidth = availableWidth / _daysPerGroup;
      final cellHeight = AppConstants.cellHeight;
      
      // Usar la misma función común para calcular la posición
      final consistentPosition = _calculateConsistentPosition(event, dragOffset);
      
      // Calcular nueva columna (día) basada en la posición consistente
      final currentDayIndex = event.date.difference(widget.plan.startDate).inDays + 1;
      final startDayIndex = _currentDayGroup * _daysPerGroup + 1;
      final currentColumnIndex = currentDayIndex - startDayIndex;
      
      // Usar el mismo cálculo que en _calculateConsistentPosition
      final columnProgress = dragOffset.dx / cellWidth;
      final newColumnOffset = columnProgress.round();
      final newColumnIndex = currentColumnIndex + newColumnOffset;
      
      // Verificar que la nueva columna esté en el rango válido
      if (newColumnIndex < 0 || newColumnIndex >= _daysPerGroup) {
        return null; // Fuera del rango visible
      }
      
      // Calcular nueva fila (hora) basada en el dragOffset directamente
      final currentMinuteOffset = event.totalStartMinutes;
      final minuteDelta = (dragOffset.dy / cellHeight * 60).round();
      final newMinuteOffset = currentMinuteOffset + minuteDelta;
      
      // NO aplicar clamp aquí - permitir movimiento libre
      // El clamp se aplicará solo al final después del snap
      final targetMinuteOffset = newMinuteOffset;
      
      // Convertir a hora y minuto
      final newHour = targetMinuteOffset ~/ 60;
      final newStartMinute = targetMinuteOffset % 60;
      
      // Ajustar a intervalos de 15 minutos
      final adjustedMinute = (newStartMinute / 15).round() * 15;
      final finalHour = adjustedMinute >= 60 ? newHour + 1 : newHour;
      final finalStartMinute = adjustedMinute >= 60 ? 0 : adjustedMinute;
      
      // Aplicar clamp solo al final
      final finalMinuteOffset = finalHour * 60 + finalStartMinute;
      final clampedFinalOffset = finalMinuteOffset.clamp(0, 1439);
      final finalHourClamped = clampedFinalOffset ~/ 60;
      final finalStartMinuteClamped = clampedFinalOffset % 60;
      
      // Calcular nueva fecha
      final newDayIndex = startDayIndex + newColumnIndex;
      final newDate = widget.plan.startDate.add(Duration(days: newDayIndex - 1));
      
      return {
        'date': newDate,
        'hour': finalHourClamped,
        'startMinute': finalStartMinuteClamped,
      };
    } catch (e) {
      return null;
    }
  }

  /// Construye la celda de evento (ahora vacía, los eventos están en la capa separada)
  Widget _buildEventCell(int hourIndex, dynamic column) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: () {
        if (_viewMode == 'tracks') {
          // En modo tracks, crear evento para el track específico
          final track = column as ParticipantTrack;
          _showNewEventDialogForTrack(track, hourIndex);
        } else {
          // En modo días, crear evento para el día específico
          final dayData = column as Map<String, dynamic>;
          final dayIndex = dayData['index'] as int;
          final date = widget.plan.startDate.add(Duration(days: dayIndex - 1));
          _showNewEventDialog(date, hourIndex);
        }
      },
      child: Container(
        height: AppConstants.cellHeight,
        width: double.infinity,
        // Celda vacía, los eventos están en la capa separada
        // Doble click para crear eventos
      ),
    );
  }

  /// Muestra el diálogo para crear un nuevo evento para un track específico
  void _showNewEventDialogForTrack(ParticipantTrack track, int hourIndex) {
    // Por ahora, usar la fecha actual como referencia
    // TODO: En T70, esto se integrará con el sistema de eventos multi-track
    final date = DateTime.now();
    _showNewEventDialog(date, hourIndex);
  }

  /// Calcula qué tracks debe abarcar un evento (span horizontal)
  List<int> _calculateEventTrackSpan(Event event) {
    if (_viewMode != 'tracks') {
      // En modo días, no hay span horizontal
      return [];
    }

    final visibleTracks = _trackService.getVisibleTracks();
    final eventTrackIds = event.participantTrackIds;
    
    // Si el evento no tiene tracks asignados, asignarlo al primer track
    if (eventTrackIds.isEmpty) {
      return [0];
    }

    // Encontrar las posiciones de los tracks del evento
    final trackPositions = <int>[];
    for (int i = 0; i < visibleTracks.length; i++) {
      final track = visibleTracks[i];
      if (eventTrackIds.contains(track.id)) {
        trackPositions.add(i);
      }
    }

    // Si no se encontraron tracks, asignar al primer track
    if (trackPositions.isEmpty) {
      return [0];
    }

    // Ordenar las posiciones
    trackPositions.sort();
    
    // Crear lista completa desde la primera posición hasta la última
    final spanPositions = <int>[];
    for (int i = trackPositions.first; i <= trackPositions.last; i++) {
      spanPositions.add(i);
    }

    return spanPositions;
  }

  /// Obtiene el ancho y posición X para un evento que abarca múltiples tracks
  Map<String, double> _calculateEventPositionAndWidth(Event event, double availableWidth) {
    final spanPositions = _calculateEventTrackSpan(event);
    
    if (spanPositions.isEmpty) {
      // Evento sin span, usar ancho de una columna
      final columnWidth = _getColumnWidth(availableWidth);
      return {
        'x': 0,
        'width': columnWidth,
      };
    }

    final columnWidth = _getColumnWidth(availableWidth);
    final startX = spanPositions.first * columnWidth;
    final spanWidth = spanPositions.length * columnWidth;

    return {
      'x': startX,
      'width': spanWidth,
    };
  }

  /// Muestra el diálogo para editar un evento existente
  void _showEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: event,
        planId: widget.plan.id ?? '',
        onSaved: (updatedEvent) async {
          // VALIDAR: ¿Excedería el límite de 3 solapados?
          if (_wouldExceedOverlapLimit(
            eventToCheck: updatedEvent,
            targetDate: updatedEvent.date,
            eventIdToExclude: event.id, // Excluir el evento actual del conteo
          )) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '⚠️ No se puede guardar: ya hay 3 eventos en ese horario.\n'
                    'Por favor, elige otra hora o reduce la duración.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            }
            return; // No guardar
          }
          
          // Si pasa validación, guardar
          final eventService = ref.read(eventServiceProvider);
          await eventService.updateEvent(updatedEvent);
          // Invalidar todos los providers de eventos para esta fecha
          _invalidateEventProviders();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        onDeleted: (eventId) async {
          final eventService = ref.read(eventServiceProvider);
          await eventService.deleteEvent(eventId);
          // Invalidar todos los providers de eventos para esta fecha
          _invalidateEventProviders();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  /// Muestra el diálogo para crear un nuevo evento
  void _showNewEventDialog(DateTime date, int hour) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: null,
        planId: widget.plan.id ?? '',
        initialDate: date,
        initialHour: hour,
        onSaved: (newEvent) async {
          // VALIDAR: ¿Excedería el límite de 3 solapados?
          if (_wouldExceedOverlapLimit(
            eventToCheck: newEvent,
            targetDate: newEvent.date,
            eventIdToExclude: null, // No excluir nada, es evento nuevo
          )) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '⚠️ No se puede crear: ya hay 3 eventos en ese horario.\n'
                    'Por favor, elige otra hora o reduce la duración.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            }
            return; // No guardar
          }
          
          // Si pasa validación, crear evento
          final eventService = ref.read(eventServiceProvider);
          await eventService.createEvent(newEvent);
          
          // Cerrar el diálogo primero
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          
          // Esperar un poco y luego invalidar providers
          await Future.delayed(const Duration(milliseconds: 100));
          _invalidateEventProviders();
          
          // Esperar un poco más y forzar otra actualización
          await Future.delayed(const Duration(milliseconds: 200));
          setState(() {});
        },
        onDeleted: (eventId) {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Verifica si hay un evento en la posición especificada
  bool _hasEventAtPosition(int dayIndex, int hourIndex) {
    final eventDate = widget.plan.startDate.add(Duration(days: dayIndex - 1));
    
    try {
      final eventsForDate = ref.read(eventsForDateProvider(
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
      
      // Verificar si hay algún evento que ocupe esta hora
      for (final event in eventsForDate) {
        final eventStartHour = event.hour;
        final eventEndHour = event.hour + (event.durationMinutes / 60).ceil();
        
        if (hourIndex >= eventStartHour && hourIndex < eventEndHour) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Invalida todos los providers de eventos para refrescar la UI
  void _invalidateEventProviders() {
    // Incrementar contador para forzar reconstrucción
    _eventRefreshCounter++;
    
    // Invalidar el provider principal de eventos de forma genérica
    ref.invalidate(eventsForDateProvider);
    
    // También invalidar el provider del calendario si existe
    final calendarParams = CalendarNotifierParams(
      planId: widget.plan.id!,
      userId: widget.plan.userId,
      initialDate: widget.plan.startDate,
      initialColumnCount: widget.plan.columnCount, // Usar columnCount del plan, no _daysPerGroup
    );
    ref.invalidate(calendarNotifierProvider(calendarParams));
    
    // Forzar actualización de la UI
    setState(() {});
  }

  /// Muestra el diálogo para editar un alojamiento existente
  void _showAccommodationDialog(Accommodation accommodation) {
    showDialog(
      context: context,
      builder: (context) => AccommodationDialog(
        accommodation: accommodation,
        planId: widget.plan.id ?? '',
        planStartDate: widget.plan.startDate,
        planEndDate: widget.plan.startDate.add(Duration(days: widget.plan.durationInDays)),
        onSaved: (updatedAccommodation) async {
          final accommodationService = ref.read(accommodationServiceProvider);
          await accommodationService.saveAccommodation(updatedAccommodation);
          Navigator.of(context).pop();
          // Invalidar providers de alojamientos después de cerrar el diálogo
          if (mounted) {
            ref.invalidate(accommodationNotifierProvider(AccommodationNotifierParams(planId: widget.plan.id ?? '')));
          }
        },
        onDeleted: (accommodationId) async {
          final accommodationService = ref.read(accommodationServiceProvider);
          await accommodationService.deleteAccommodation(accommodationId);
          Navigator.of(context).pop();
          // Invalidar providers de alojamientos después de cerrar el diálogo
          if (mounted) {
            ref.invalidate(accommodationNotifierProvider(AccommodationNotifierParams(planId: widget.plan.id ?? '')));
          }
        },
      ),
    );
  }

  /// Muestra el diálogo para crear un nuevo alojamiento
  void _showNewAccommodationDialog(DateTime checkInDate) {
    showDialog(
      context: context,
      builder: (context) => AccommodationDialog(
        accommodation: null,
        planId: widget.plan.id ?? '',
        planStartDate: widget.plan.startDate,
        planEndDate: widget.plan.startDate.add(Duration(days: widget.plan.durationInDays)),
        initialCheckIn: checkInDate,
        onSaved: (newAccommodation) async {
          final accommodationService = ref.read(accommodationServiceProvider);
          await accommodationService.saveAccommodation(newAccommodation);
          Navigator.of(context).pop();
          // Invalidar providers de alojamientos después de cerrar el diálogo
          if (mounted) {
            ref.invalidate(accommodationNotifierProvider(AccommodationNotifierParams(planId: widget.plan.id ?? '')));
          }
        },
        onDeleted: (accommodationId) {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

