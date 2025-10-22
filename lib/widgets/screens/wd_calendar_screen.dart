import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/event_segment.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/overlapping_segment_group.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/domain/services/track_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/accommodation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/shared/utils/constants.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/calendar/domain/services/date_service.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';
import 'package:unp_calendario/widgets/wd_accommodation_dialog.dart';
import 'package:unp_calendario/features/calendar/domain/models/calendar_view_mode.dart';
import 'package:unp_calendario/shared/models/permission.dart';
import 'package:unp_calendario/shared/services/permission_service.dart';
import 'package:unp_calendario/widgets/dialogs/manage_roles_dialog.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_filters.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_track_reorder.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_app_bar.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_utils.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_constants.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_event_logic.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_accommodation_logic.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_styles.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_navigation.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_validations.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_calculations.dart';
import 'package:unp_calendario/widgets/screens/fullscreen_calendar_page.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final int? initialVisibleDays;

  const CalendarScreen({
    super.key,
    required this.plan,
    this.initialVisibleDays,
  });

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  // Constantes para dimensiones y estilos
  // Constantes para alturas y dimensiones
  static const double _accommodationRowHeight = CalendarConstants.accommodationRowHeight;
  static const double _headerHeight = CalendarConstants.headerHeight;
  static const double _miniHeaderHeight = CalendarConstants.miniHeaderHeight;
  static const double _gridLineOpacity = CalendarConstants.gridLineOpacity;
  
  // Estado para la navegación de días (grupos dinámicos según días visibles)
  int _currentDayGroup = 0; // Grupo actual (0 = primeros días, 1 = siguientes días, etc.)
  
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
  
  // Clases para manejar filtros y reordenación
  late final CalendarFilters _calendarFilters;
  late final CalendarTrackReorder _calendarTrackReorder;
  CalendarAppBar? _calendarAppBar;
  
  // Número de días visibles simultáneamente (1-7)
  int _visibleDays = 7;
  
  // Variables para filtros de vista
  CalendarViewMode _viewMode = CalendarViewMode.all;
  String? _currentUserId;
  List<String> _filteredParticipantIds = [];

  @override
  void initState() {
    super.initState();
    
    // Usar el número de días visibles inicial si se proporciona
    if (widget.initialVisibleDays != null) {
      _visibleDays = widget.initialVisibleDays!;
    }
    
    // Inicializar el servicio de tracks
    _trackService = TrackService();
    _initializeTracks();
    
    // Inicializar clases auxiliares
    _calendarFilters = CalendarFilters(_trackService);
    _calendarTrackReorder = CalendarTrackReorder(_trackService);
    _calendarAppBar = CalendarAppBar(
      plan: widget.plan,
      currentDayGroup: _currentDayGroup,
      visibleDays: _visibleDays,
      viewMode: _viewMode,
      calendarFilters: _calendarFilters,
      calendarTrackReorder: _calendarTrackReorder,
    );
    
    // Inicializar usuario actual para filtros
    _currentUserId = _trackService.getVisibleTracks().isNotEmpty 
        ? _trackService.getVisibleTracks().first.participantId 
        : null;
    
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

  /// Inicializa los tracks basándose en los participantes reales del plan
  void _initializeTracks() {
    // Si no hay plan ID, crear tracks ficticios como fallback
    if (widget.plan.id == null) {
      final participantCount = widget.plan.participants ?? 1;
      final participants = List.generate(participantCount, (index) => {
        'id': 'participant_$index',
        'name': 'Participante ${index + 1}',
      });
      _trackService.createTracksForParticipants(participants);
    }
  }

  /// Sincroniza tracks con participantes (llamado desde build)
  void _syncTracksWithParticipants() {
    if (widget.plan.id == null) return;
    
    final participantsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));
    
    participantsAsync.when(
      data: (participations) {
        // Solo sincronizar si los tracks no están ya sincronizados
        final currentTracks = _trackService.getVisibleTracks();
        final currentParticipantIds = currentTracks.map((t) => t.participantId).toSet();
        final newParticipantIds = participations.map((p) => p.userId).toSet();
        
        if (currentParticipantIds.length != newParticipantIds.length || 
            !currentParticipantIds.containsAll(newParticipantIds)) {
          final participantIds = participations.map((p) => p.userId).join(', ');
          _trackService.syncTracksWithPlanParticipants(participations);
          
          // Cargar orden y selección guardados desde Firestore
          _trackService.loadOrderFromFirestore(widget.plan.id!);
          _trackService.loadSelectionFromFirestore(widget.plan.id!);
        }
      },
      loading: () {
        // Estado de carga
      },
      error: (error, stackTrace) {
        // En caso de error, usar tracks ficticios como fallback
        final participantCount = widget.plan.participants ?? 1;
        final participants = List.generate(participantCount, (index) => {
          'id': 'participant_$index',
          'name': 'Participante ${index + 1}',
        });
        _trackService.createTracksForParticipants(participants);
      },
    );
  }


  /// Obtiene las columnas a mostrar (días con subcolumnas de participantes)
  List<dynamic> _getColumnsToShow() {
    // Generar lista de días basada en _visibleDays
    return List.generate(_visibleDays, (dayIndex) {
      final actualDayIndex = _currentDayGroup * _visibleDays + dayIndex + 1;
      final totalDays = widget.plan.durationInDays;
      final isEmpty = actualDayIndex > totalDays;
      return {
        'type': 'day',
        'index': actualDayIndex,
        'isEmpty': isEmpty,
        'participants': _getFilteredTracks(), // Subcolumnas por participante
      };
    });
  }

  /// Obtiene el ancho de cada columna principal (día)
  double _getColumnWidth(double availableWidth) {
    final columns = _getColumnsToShow();
    return availableWidth / columns.length;
  }

  /// Obtiene el ancho de cada subcolumna (participante dentro de un día)
  double _getSubColumnWidth(double availableWidth) {
    final columns = _getColumnsToShow();
    final columnWidth = availableWidth / columns.length;
    final filteredTracks = _getFilteredTracks();
    final participantCount = filteredTracks.length;
    return CalendarUtils.getSubColumnWidth(columnWidth, participantCount);
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
    // Sincronizar tracks con participantes reales
    _syncTracksWithParticipants();
    
    // Forzar inicialización del CalendarNotifier para asegurar que se carguen los eventos
    final calendarParams = CalendarNotifierParams(
      planId: widget.plan.id!,
      userId: widget.plan.userId,
      initialDate: widget.plan.startDate,
      initialColumnCount: widget.plan.columnCount,
    );
    
    // Leer el notifier para forzar su inicialización
    ref.read(calendarNotifierProvider(calendarParams));
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildCalendarBody(),
    );
  }

  /// Construye el AppBar con navegación de días
  PreferredSizeWidget _buildAppBar() {
    _updateCalendarAppBar();
    
    return _calendarAppBar!.buildAppBar(
      onPreviousDayGroup: _previousDayGroup,
      onNextDayGroup: _nextDayGroup,
      onVisibleDaysChanged: (int value) {
        setState(() {
          _visibleDays = value;
          // Resetear al primer grupo si el grupo actual ya no es válido
          final totalDays = widget.plan.durationInDays;
          final currentStartDay = _currentDayGroup * _visibleDays + 1;
          if (currentStartDay > totalDays) {
            _currentDayGroup = 0;
          }
        });
      },
      canManageRoles: _canManageRoles,
      onManageRoles: _showManageRolesDialog,
      onFilterChanged: (CalendarViewMode result) {
        setState(() {
          _viewMode = result;
        });
      },
      onCustomFilter: _showCustomViewDialog,
      onReorderTracks: _showParticipantManagementDialog,
      onFullscreen: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenCalendarPage(
              plan: widget.plan,
              visibleDays: _visibleDays,
            ),
            fullscreenDialog: true,
          ),
        );
      },
    );
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
    final startDay = _currentDayGroup * _visibleDays + 1;
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
            height: _headerHeight,
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
            height: _accommodationRowHeight,
            decoration: _createBorderedDecoration(
              color: AppColorScheme.color1.withOpacity(0.3),
            ),
            child: const Center(
              child: Text(
                'Alojamiento',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
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

  /// Crea un borde común para elementos de la grilla
  Border _createGridBorder({bool includeRight = true}) {
    return Border(
      right: includeRight 
          ? BorderSide(color: AppColorScheme.gridLineColor.withOpacity(_gridLineOpacity), width: 0.5)
          : BorderSide.none,
    );
  }

  /// Crea un BoxDecoration común para contenedores con borde
  BoxDecoration _createBorderedDecoration({Color? color}) {
    return BoxDecoration(
      border: Border.all(color: AppColorScheme.gridLineColor),
      color: color,
    );
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

  /// Construye las filas fijas (encabezado y alojamientos)
  Widget _buildFixedRows() {
    final columns = _getColumnsToShow();
    
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
                      height: _headerHeight,
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
                      final dayDate = widget.plan.startDate.add(Duration(days: actualDayIndex - 1));
                      _showNewAccommodationDialog(dayDate);
                    },
                    child: Container(
                      height: _accommodationRowHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColorScheme.gridLineColor),
                        color: AppColorScheme.color1.withOpacity(0.3),
                      ),
                      child: Center(
                        child: _buildAccommodationTracks(column, constraints.maxWidth),
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
    return isEmpty ? Colors.grey.shade200 : AppColorScheme.color1;
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
    final dayDate = widget.plan.startDate.add(Duration(days: actualDayIndex - 1));
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
        
        // Generar iniciales del nombre y apellido
        final initial = _getParticipantInitials(participant.participantName, participant.position);
            
        return Expanded(
          child: GestureDetector(
            onTap: () {
              // Abrir modal de gestión de participantes al hacer click en el header
              _showParticipantManagementDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              decoration: BoxDecoration(
                // Agregar línea vertical derecha para separar tracks (excepto el último)
                border: isLastTrack 
                    ? null 
                    : _createGridBorder(),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Genera las iniciales del nombre y apellido de un participante
  String _getParticipantInitials(String participantName, int position) {
    if (participantName.isEmpty) {
      return 'P${position + 1}';
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
  Widget _buildAccommodationTracks(dynamic column, double availableWidth) {
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
      AccommodationNotifierParams(planId: widget.plan.id ?? ''),
    ));
    
    final dayDate = widget.plan.startDate.add(Duration(days: actualDayIndex - 1));
    final accommodationsForDay = accommodations.where((acc) => acc.isDateInRange(dayDate)).toList();
    
    
    if (accommodationsForDay.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Mostrar alojamientos como tracks
    return _buildAccommodationTracksRow(accommodationsForDay, availableWidth, dayDate);
  }

  /// Construye la fila de tracks de alojamiento
  Widget _buildAccommodationTracksRow(List<Accommodation> accommodations, double availableWidth, DateTime dayDate) {
    final visibleTracks = _getFilteredTracks();

    return SizedBox(
                      height: _accommodationRowHeight,
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
              final isLastTrack = trackIndex == visibleTracks.length - 1;
              
              return Expanded(
                child: Container(
                  height: _accommodationRowHeight,
                  decoration: BoxDecoration(
                    border: isLastTrack
                        ? null
                        : _createGridBorder(),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Encontrar alojamientos que deben mostrarse en este track
                      final accommodationsForTrack = accommodations.where((accommodation) =>
                        _shouldShowAccommodationInTrack(accommodation, trackIndex)
                      ).toList();

                      if (accommodationsForTrack.isNotEmpty) {
                        _showAccommodationDialog(accommodationsForTrack.first);
                      } else {
                        final dayDate = accommodations.isNotEmpty
                            ? accommodations.first.checkIn
                            : DateTime.now();
                        _showNewAccommodationDialog(dayDate);
                      }
                    },
                    onDoubleTap: () {
                      final dayDate = accommodations.isNotEmpty
                          ? accommodations.first.checkIn
                          : DateTime.now();
                      _showNewAccommodationDialog(dayDate);
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
            // Alojamientos individuales usando Row en lugar de Positioned
            _buildAccommodationTracksWithGrouping(accommodations, visibleTracks, availableWidth, dayDate),
        ],
          ),
        ),
      ),
    );
  }



  /// Determina si un alojamiento debe mostrarse en un track específico
  bool _shouldShowAccommodationInTrack(Accommodation accommodation, int trackIndex) {
    final visibleTracks = _getFilteredTracks();
    if (trackIndex >= visibleTracks.length) return false;
    
    final currentTrack = visibleTracks[trackIndex];
    return CalendarAccommodationLogic.shouldShowAccommodationInTrack(accommodation, currentTrack);
  }

  /// Construye las filas de datos (horas)
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
                  border: Border.all(color: AppColorScheme.gridLineColor),
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

  /// Obtiene el color de la celda de datos según el tipo de columna
  Color _getDataCellColor(dynamic column) {
    final dayData = column as Map<String, dynamic>;
    final isEmpty = dayData['isEmpty'] as bool;
    return isEmpty ? Colors.grey.shade100 : AppColorScheme.color0;
  }

  /// Construye la celda de evento con subcolumnas de participantes
  Widget _buildEventCellWithSubColumns(int hourIndex, dynamic column, List<ParticipantTrack> participants) {
    final dayData = column as Map<String, dynamic>;
    final actualDayIndex = dayData['index'] as int;
    
    return Row(
      children: participants.asMap().entries.map((entry) {
        final index = entry.key;
        final participant = entry.value;
        final isLastTrack = index == participants.length - 1;
        
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: () {
              final date = widget.plan.startDate.add(Duration(days: actualDayIndex - 1));
              _showNewEventDialogForParticipant(date, hourIndex, participant);
            },
            child: Container(
              height: AppConstants.cellHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                // Agregar línea vertical derecha para separar tracks (excepto el último)
                border: isLastTrack 
                    ? null 
                    : _createGridBorder(),
              ),
            ),
          ),
        );
      }).toList(),
    );
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
          _getAccommodationDayText(accommodation, dayDate),
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
    return _buildDaysEventsLayerWithSubColumns(availableWidth);
  }

  /// Construye la capa de eventos para días con subcolumnas de participantes
  List<Widget> _buildDaysEventsLayerWithSubColumns(double availableWidth) {
    final startDayIndex = _currentDayGroup * _visibleDays + 1;
    final endDayIndex = startDayIndex + _visibleDays - 1;
    final totalDays = widget.plan.durationInDays;
    final actualEndDayIndex = endDayIndex > totalDays ? totalDays : endDayIndex;
    
    
    List<Widget> eventWidgets = [];
    List<Event> previousDayEvents = []; // Cache de eventos del día anterior
    
    // Obtener eventos para cada día en el rango actual
    for (int dayOffset = 0; dayOffset < (actualEndDayIndex - startDayIndex + 1); dayOffset++) {
      final currentDay = startDayIndex + dayOffset;
      final eventDate = widget.plan.startDate.add(Duration(days: (currentDay - 1).toInt()));
      
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
            eventWidgets.addAll(_buildOverlappingSegmentWidgetsWithSubColumns(group, dayOffset, availableWidth));
          } else {
            // Solo un segmento - renderizado normal
            final segment = group.segments.first;
            eventWidgets.addAll(_buildSegmentWidgetWithSubColumns(segment, dayOffset, availableWidth));
          }
        }
      }
      
      // CORREGIDO: Guardar TODOS los eventos procesados (no solo eventsForDate)
      // Esto asegura que eventos multi-día se propaguen correctamente al siguiente día
      previousDayEvents = allRelevantEvents;
    }
    
    return eventWidgets;
  }

  /// Construye la capa de eventos para el modo días (comportamiento original)
  List<Widget> _buildDaysEventsLayer(double availableWidth) {
    final startDayIndex = _currentDayGroup * _visibleDays + 1;
    final endDayIndex = startDayIndex + _visibleDays - 1;
    final totalDays = widget.plan.durationInDays;
    final actualEndDayIndex = endDayIndex > totalDays ? totalDays : endDayIndex;
    
    List<Widget> eventWidgets = [];
    List<Event> previousDayEvents = []; // Cache de eventos del día anterior
    
    // Obtener eventos para cada día en el rango actual
    for (int dayOffset = 0; dayOffset < (actualEndDayIndex - startDayIndex + 1); dayOffset++) {
      final currentDay = startDayIndex + dayOffset;
      final eventDate = widget.plan.startDate.add(Duration(days: (currentDay - 1).toInt()));
      
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
            color: ColorUtils.colorFromName(event.color ?? 'blue'),
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

  /// Verifica si un evento crearía conflictos de solapamiento por participante
  /// 
  /// Regla de negocio: Un participante no puede tener eventos confirmados solapados
  /// Los eventos en borrador SÍ pueden solaparse
  /// 
  /// [eventToCheck] - El evento que queremos añadir/mover
  /// [targetDate] - La fecha donde queremos colocar el evento
  /// [eventIdToExclude] - ID del evento a excluir del conteo (cuando editamos un evento existente)
  /// 
  /// Returns true si hay conflicto de solapamiento por participante
  bool _wouldCreateParticipantConflict({
    required Event eventToCheck,
    required DateTime targetDate,
    String? eventIdToExclude,
  }) {
    // Los borradores pueden solaparse, no validar
    if (eventToCheck.isDraft) return false;
    
    // Si no tiene participantes, no hay conflicto
    if (eventToCheck.participantTrackIds.isEmpty) return false;

    final eventStartMinutes = eventToCheck.hour * 60 + eventToCheck.startMinute;
    final eventEndMinutes = eventStartMinutes + eventToCheck.durationMinutes;

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

    // Buscar eventos existentes en la misma fecha
    for (final existingEvent in eventsForDate) {
      if (existingEvent.id == eventIdToExclude) continue; // Excluir el evento que estamos editando
      if (existingEvent.isDraft) continue; // Ignorar borradores
      if (existingEvent.date != targetDate) continue;

      final existingStartMinutes = existingEvent.hour * 60 + existingEvent.startMinute;
      final existingEndMinutes = existingStartMinutes + existingEvent.durationMinutes;

      // Verificar si hay solapamiento temporal
      if (eventStartMinutes < existingEndMinutes && eventEndMinutes > existingStartMinutes) {
        // Verificar si hay participantes en común
        for (final participantId in eventToCheck.participantTrackIds) {
          if (existingEvent.participantTrackIds.contains(participantId)) {
            return true; // HAY CONFLICTO
          }
        }
      }
    }

    return false; // NO HAY CONFLICTO
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
    final cellWidth = availableWidth / _visibleDays;
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
    final cellWidth = availableWidth / _visibleDays;
    final widgets = <Widget>[];
    
    // Calcular ancho para cada segmento solapado
    final segmentWidth = (cellWidth * 0.95) / group.segments.length;
    
    for (int i = 0; i < group.segments.length; i++) {
      final segment = group.segments[i];
      final x = (dayOffset * cellWidth) + (cellWidth * 0.025) + (i * segmentWidth);
      
      final totalFixedHeight = 0.0;
      widgets.add(Positioned(
        left: x,
        top: totalFixedHeight + (segment.startMinute * AppConstants.cellHeight / 60),
        width: segmentWidth,
        height: (segment.durationMinutes * AppConstants.cellHeight / 60).clamp(0.0, 1440.0),
        child: _buildDraggableSegment(segment, (segment.durationMinutes * AppConstants.cellHeight / 60).clamp(0.0, 1440.0), showLimitIndicator: false),
      ));
    }
    
    return widgets;
  }

  /// Construye un segmento con subcolumnas de participantes
  /// Muestra eventos individualmente en cada track de participante
  List<Widget> _buildSegmentWidgetWithSubColumns(EventSegment segment, int dayOffset, double availableWidth) {
    final cellWidth = availableWidth / _visibleDays;
    final subColumnWidth = _getSubColumnWidth(availableWidth);
    final cellHeight = AppConstants.cellHeight;
    final dayX = dayOffset * cellWidth;
    final totalFixedHeight = 0.0;
    final y = totalFixedHeight + (segment.startMinute * cellHeight / 60);
    final height = (segment.durationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    
    final visibleTracks = _getFilteredTracks();
    final widgets = <Widget>[];
    
    // Obtener todos los grupos de tracks consecutivos donde se muestra este evento
    final consecutiveGroups = _getConsecutiveTrackGroupsForEvent(segment.originalEvent);
    
    if (consecutiveGroups.isNotEmpty) {
      // Renderizar cada grupo consecutivo como un bloque separado
      for (final group in consecutiveGroups) {
        if (group.length > 1) {
          // Grupo de múltiples tracks consecutivos - mostrar como un bloque ancho
          final firstTrackIndex = group.first;
          
          // Calcular posición y ancho para el evento combinado
          final positionInfo = _calculateEventPosition(segment.originalEvent, firstTrackIndex, subColumnWidth);
          final startX = dayX + (positionInfo['startX'] as double);
          final trackWidth = subColumnWidth;
          final totalWidth = trackWidth * group.length;
          
          
          widgets.add(
            Positioned(
              left: startX,
              top: y,
              width: totalWidth,
              height: height,
              child: _buildDraggableSegment(segment, height),
            ),
          );
        } else {
          // Grupo de un solo track - mostrar como bloque individual
          final trackIndex = group.first;
          final positionInfo = _calculateEventPosition(segment.originalEvent, trackIndex, subColumnWidth);
          final x = dayX + (positionInfo['startX'] as double);
          final width = positionInfo['width'] as double;
          
          widgets.add(
            Positioned(
              left: x,
              top: y,
              width: width,
              height: height,
              child: _buildDraggableSegment(segment, height),
            ),
          );
        }
      }
    } else {
      // Fallback: comportamiento original si no hay grupos
      for (int trackIndex = 0; trackIndex < visibleTracks.length; trackIndex++) {
        if (_shouldShowEventInTrack(segment.originalEvent, trackIndex)) {
          final positionInfo = _calculateEventPosition(segment.originalEvent, trackIndex, subColumnWidth);
          final x = dayX + (positionInfo['startX'] as double);
          final width = positionInfo['width'] as double;
          
          widgets.add(
            Positioned(
              left: x,
              top: y,
              width: width,
              height: height,
              child: _buildDraggableSegment(segment, height),
            ),
          );
        }
      }
    }
    
    return widgets;
  }

  /// Construye widgets para segmentos solapados con subcolumnas
  /// Muestra eventos individualmente en cada track de participante con capas superpuestas
  List<Widget> _buildOverlappingSegmentWidgetsWithSubColumns(OverlappingSegmentGroup group, int dayOffset, double availableWidth) {
    final cellWidth = availableWidth / _visibleDays;
    final subColumnWidth = _getSubColumnWidth(availableWidth);
    final widgets = <Widget>[];
    final visibleTracks = _getFilteredTracks();
    
    // Ordenar segmentos por número de participantes (más participantes primero = fondo)
    final sortedSegments = List<EventSegment>.from(group.segments);
    sortedSegments.sort((a, b) {
      final aParticipantCount = a.originalEvent.participantTrackIds.length;
      final bParticipantCount = b.originalEvent.participantTrackIds.length;
      return bParticipantCount.compareTo(aParticipantCount); // Descendente
    });
    
    // Para cada segmento en el grupo (ordenados por número de participantes)
    for (int i = 0; i < sortedSegments.length; i++) {
      final segment = sortedSegments[i];
      final dayX = dayOffset * cellWidth;
      final totalFixedHeight = 0.0;
      final y = totalFixedHeight + (segment.startMinute * AppConstants.cellHeight / 60);
      final height = (segment.durationMinutes * AppConstants.cellHeight / 60).clamp(0.0, 1440.0);
      
      final event = segment.originalEvent;
      
      // Obtener todos los grupos de tracks consecutivos donde se muestra este evento
      final consecutiveGroups = _getConsecutiveTrackGroupsForEvent(event);
      
      if (consecutiveGroups.isNotEmpty) {
        // Renderizar cada grupo consecutivo como un bloque separado
        for (final group in consecutiveGroups) {
          if (group.length > 1) {
            // Grupo de múltiples tracks consecutivos - mostrar como un bloque ancho
            final firstTrackIndex = group.first;
            
            // Calcular posición y ancho para el evento combinado
            final positionInfo = _calculateEventPosition(event, firstTrackIndex, subColumnWidth);
            final startX = dayX + (positionInfo['startX'] as double);
            final trackWidth = subColumnWidth;
            final totalWidth = trackWidth * group.length;
            
            // Ajustar altura para capas superpuestas
            double adjustedHeight = height;
            if (i > 0) {
              // Eventos superpuestos: altura ligeramente reducida para mostrar capas
              adjustedHeight = height * (0.8 + (0.1 * (sortedSegments.length - i) / sortedSegments.length));
            }
            
            widgets.add(
              Positioned(
                left: startX,
                top: y,
                width: totalWidth,
                height: adjustedHeight,
                child: _buildDraggableSegment(
                  segment, 
                  adjustedHeight, 
                  showLimitIndicator: false,
                  isOverlapping: true,
                  layerIndex: i,
                ),
              ),
            );
          } else {
            // Grupo de un solo track - mostrar como bloque individual
            final trackIndex = group.first;
            final positionInfo = _calculateEventPosition(event, trackIndex, subColumnWidth);
            final x = dayX + (positionInfo['startX'] as double);
            final width = positionInfo['width'] as double;
            
            // Ajustar altura para capas superpuestas
            double adjustedHeight = height;
            if (i > 0) {
              // Eventos superpuestos: altura ligeramente reducida para mostrar capas
              adjustedHeight = height * (0.8 + (0.1 * (sortedSegments.length - i) / sortedSegments.length));
            }
            
            widgets.add(
              Positioned(
                left: x,
                top: y,
                width: width,
                height: adjustedHeight,
                child: _buildDraggableSegment(
                  segment, 
                  adjustedHeight, 
                  showLimitIndicator: false,
                  isOverlapping: true,
                  layerIndex: i,
                ),
              ),
            );
          }
        }
      } else {
        // Fallback: comportamiento original si no hay grupos
        for (int trackIndex = 0; trackIndex < visibleTracks.length; trackIndex++) {
          if (_shouldShowEventInTrack(event, trackIndex)) {
            final positionInfo = _calculateEventPosition(event, trackIndex, subColumnWidth);
            final x = dayX + (positionInfo['startX'] as double);
            final width = positionInfo['width'] as double;
            
            // Ajustar altura para capas superpuestas
            double adjustedHeight = height;
            if (i > 0) {
              // Eventos superpuestos: altura ligeramente reducida para mostrar capas
              adjustedHeight = height * (0.8 + (0.1 * (sortedSegments.length - i) / sortedSegments.length));
            }
            
            widgets.add(
              Positioned(
                left: x,
                top: y,
                width: width,
                height: adjustedHeight,
                child: _buildDraggableSegment(
                  segment, 
                  adjustedHeight, 
                  showLimitIndicator: false,
                  isOverlapping: true,
                  layerIndex: i,
                ),
              ),
            );
          }
        }
      }
    }
    
    return widgets;
  }

  /// Obtiene el índice del participante para un evento
  int _getParticipantIndexForEvent(Event event) {
    // Si el evento tiene participantTrackIds, usar el primero
    if (event.participantTrackIds.isNotEmpty) {
      final tracks = _trackService.getVisibleTracks();
      for (int i = 0; i < tracks.length; i++) {
        if (tracks[i].id == event.participantTrackIds.first) {
          return i;
        }
      }
    }
    
    // Por defecto, asignar al primer participante
    return 0;
  }

  /// Calcula la posición individual de un evento en un track específico
  /// Retorna un Map con 'startX' y 'width' para el track individual
  Map<String, double> _calculateEventPosition(Event event, int trackIndex, double subColumnWidth) {
    // Para eventos multi-participante, cada instancia ocupa solo su track individual
    // El ancho es siempre el ancho de una subcolumna
    final startX = trackIndex * subColumnWidth;
    
    return {
      'startX': startX,
      'width': subColumnWidth,
    };
  }

  /// Calcula la posición y ancho para eventos multi-participante que se extienden horizontalmente
  /// Retorna un Map con 'startX' y 'width' para el evento completo
  Map<String, double> _calculateEventSpan(Event event, double subColumnWidth) {
    final visibleTracks = _getFilteredTracks();
    
    // Encontrar los tracks donde debe mostrarse este evento
    final relevantTracks = <int>[];
    for (int trackIndex = 0; trackIndex < visibleTracks.length; trackIndex++) {
      if (_shouldShowEventInTrack(event, trackIndex)) {
        relevantTracks.add(trackIndex);
      }
    }
    
    if (relevantTracks.isEmpty) {
      // Si no hay tracks relevantes, usar el primer track por defecto
      return {
        'startX': 0.0,
        'width': subColumnWidth,
      };
    }
    
    // Calcular la posición de inicio (track más a la izquierda)
    final startTrackIndex = relevantTracks.first;
    final startX = startTrackIndex * subColumnWidth;
    
    // Calcular el ancho total (todos los tracks relevantes)
    final totalWidth = relevantTracks.length * subColumnWidth;
    
    return {
      'startX': startX,
      'width': totalWidth,
    };
  }

  /// Verifica si un evento debe mostrarse en un track específico
  bool _shouldShowEventInTrack(Event event, int trackIndex) {
    final visibleTracks = _getFilteredTracks();
    
    if (trackIndex >= visibleTracks.length) return false;
    
    final track = visibleTracks[trackIndex];
    return CalendarEventLogic.shouldShowEventInTrack(event, track);
  }

  /// Obtiene todos los grupos de tracks consecutivos donde se muestra un evento
  /// Cada grupo consecutivo se puede mostrar como un solo bloque
  List<List<int>> _getConsecutiveTrackGroupsForEvent(Event event) {
    final visibleTracks = _getFilteredTracks();
    final tracksWhereShown = <int>[];
    
    // Encontrar todos los tracks donde se muestra el evento
    for (int trackIndex = 0; trackIndex < visibleTracks.length; trackIndex++) {
      if (_shouldShowEventInTrack(event, trackIndex)) {
        tracksWhereShown.add(trackIndex);
      }
    }
    
    // Si solo aparece en un track, devolverlo como un grupo
    if (tracksWhereShown.length <= 1) {
      return tracksWhereShown.isEmpty ? [] : [tracksWhereShown];
    }
    
    // Ordenar tracks
    final sortedTracks = tracksWhereShown..sort();
    
    // Agrupar tracks consecutivos
    final consecutiveGroups = <List<int>>[];
    List<int> currentGroup = [sortedTracks.first];
    
    for (int i = 1; i < sortedTracks.length; i++) {
      if (sortedTracks[i] - sortedTracks[i - 1] == 1) {
        // Es consecutivo, agregar al grupo actual
        currentGroup.add(sortedTracks[i]);
      } else {
        // No es consecutivo, finalizar grupo actual y empezar uno nuevo
        consecutiveGroups.add(List.from(currentGroup));
        currentGroup = [sortedTracks[i]];
      }
    }
    // Agregar el último grupo
    consecutiveGroups.add(currentGroup);
    
    return consecutiveGroups;
  }

  /// Obtiene los tracks consecutivos donde se muestra un evento (método de compatibilidad)
  /// Si el evento aparece en tracks consecutivos, los agrupa para mostrar como un solo bloque
  /// Si hay múltiples grupos consecutivos, devuelve el grupo más grande
  List<int> _getConsecutiveTracksForEvent(Event event) {
    final groups = _getConsecutiveTrackGroupsForEvent(event);
    if (groups.isEmpty) return [];
    
    // Devolver el grupo más grande
    groups.sort((a, b) => b.length.compareTo(a.length));
    return groups.first;
  }

  /// Obtiene todos los grupos de tracks consecutivos donde se muestra un alojamiento
  /// Cada grupo consecutivo se puede mostrar como un solo bloque
  List<List<int>> _getConsecutiveTrackGroupsForAccommodation(Accommodation accommodation) {
    final visibleTracks = _getFilteredTracks();
    final tracksWhereShown = <int>[];
    
    // Encontrar todos los tracks donde se muestra el alojamiento
    for (int trackIndex = 0; trackIndex < visibleTracks.length; trackIndex++) {
      if (_shouldShowAccommodationInTrack(accommodation, trackIndex)) {
        tracksWhereShown.add(trackIndex);
      }
    }
    
    // Si solo aparece en un track, devolverlo como un grupo
    if (tracksWhereShown.length <= 1) {
      return tracksWhereShown.isEmpty ? <List<int>>[] : <List<int>>[tracksWhereShown];
    }
    
    // Ordenar tracks
    final sortedTracks = tracksWhereShown..sort();
    
    // Agrupar tracks consecutivos
    final consecutiveGroups = <List<int>>[];
    List<int> currentGroup = [sortedTracks.first];
    
    for (int i = 1; i < sortedTracks.length; i++) {
      if (sortedTracks[i] - sortedTracks[i - 1] == 1) {
        // Es consecutivo, agregar al grupo actual
        currentGroup.add(sortedTracks[i]);
      } else {
        // No es consecutivo, finalizar grupo actual y empezar uno nuevo
        consecutiveGroups.add(List.from(currentGroup));
        currentGroup = [sortedTracks[i]];
      }
    }
    
    // Agregar el último grupo
    consecutiveGroups.add(currentGroup);
    
    return consecutiveGroups;
  }

  /// Construye un segmento individual (sin solapamiento)
  Widget _buildSegmentWidget(EventSegment segment, int dayOffset, double availableWidth) {
    final cellWidth = availableWidth / _visibleDays;
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
  Widget _buildDraggableSegment(EventSegment segment, double height, {bool showLimitIndicator = false, bool isOverlapping = false, int layerIndex = 0}) {
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
            child: _buildSegmentContainer(segment, height, fontSize, isThisEventDragging, displayOffset, showLimitIndicator, isOverlapping: isOverlapping, layerIndex: layerIndex),
          )
        : GestureDetector(
            onTap: () => _showEventDialog(originalEvent),
            // Sin onPanStart/Update/End - las continuaciones NO son draggables
            child: _buildSegmentContainer(segment, height, fontSize, false, Offset.zero, showLimitIndicator, isOverlapping: isOverlapping, layerIndex: layerIndex),
          );
    
    return child;
  }

  /// Construye el container visual del segmento (separado para reutilización)
  Widget _buildSegmentContainer(EventSegment segment, double height, double fontSize, bool isDragging, Offset displayOffset, bool showLimitIndicator, {bool isOverlapping = false, int layerIndex = 0}) {
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
              width: isOverlapping ? 2 : 1, // Borde más grueso para eventos superpuestos
            ),
            boxShadow: isDragging ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : isOverlapping ? [
              // Sombra para eventos superpuestos (más capas = más sombra)
              BoxShadow(
                color: Colors.black.withOpacity(0.1 + (layerIndex * 0.05)),
                blurRadius: 2 + (layerIndex * 2),
                offset: Offset(0, 1 + (layerIndex * 0.5)),
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
    // Convertir evento de UTC a timezone local para mostrar
    final localEvent = _convertEventFromUtc(event);
    
    final startDayIndex = _currentDayGroup * _visibleDays + 1;
    final eventDayIndex = localEvent.date.difference(widget.plan.startDate).inDays + 1;
    final dayIndex = eventDayIndex - startDayIndex;
    
    // Si el evento no está en el rango de días actual, no lo mostramos
    if (dayIndex < 0 || dayIndex >= _visibleDays) {
      return const SizedBox.shrink();
    }
    
        // Usar el ancho real disponible pasado desde LayoutBuilder
        final cellWidth = availableWidth / _visibleDays;
        
    final cellHeight = AppConstants.cellHeight;
    
    
    final x = (dayIndex * cellWidth) + (cellWidth * 0.025); // Centrado: 2.5% de margen a cada lado
    final scrollOffset = _dataScrollController.hasClients ? _dataScrollController.offset : 0.0;
    
    // Posición Y: ahora que los eventos están dentro del SingleChildScrollView,
    // no necesitamos restar el scrollOffset
    final totalFixedHeight = 0.0; // Ajustado para alineación correcta en 00:00h
    final y = totalFixedHeight + (localEvent.totalStartMinutes * cellHeight / 60);
    
    final width = cellWidth * 0.95; // 5% más estrecho que la columna
    
    // Calcular altura del evento - si cruza medianoche, mostrar solo la parte del día actual
    double height;
    if (_eventCrossesMidnight(localEvent)) {
      final startTime = localEvent.hour * 60 + localEvent.startMinute;
      final midnightMinutes = 1440; // 24:00 = 1440 minutos
      final endTime = startTime + localEvent.durationMinutes;
      final currentDayDurationMinutes = midnightMinutes - startTime;
      height = (currentDayDurationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    } else {
      height = (localEvent.durationMinutes * cellHeight / 60).clamp(0.0, 1440.0);
    }
    
    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: _buildDraggableEvent(localEvent),
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
    final cellWidth = availableWidth / _visibleDays;
    
    // Calcular posición actual del evento
    final currentDayIndex = event.date.difference(widget.plan.startDate).inDays + 1;
    final startDayIndex = _currentDayGroup * _visibleDays + 1;
    final currentColumnIndex = currentDayIndex - startDayIndex;
    
    // Calcular nueva columna basada en el offset horizontal
    final totalOffsetX = dragOffset.dx;
    final columnProgress = totalOffsetX / cellWidth;
    final newColumnOffset = columnProgress.round(); // Inmediato
    final newColumnIndex = currentColumnIndex + newColumnOffset;
    
    // Verificar que la nueva columna esté en el rango válido
    if (newColumnIndex < 0 || newColumnIndex >= _visibleDays) {
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
        
        // VALIDAR: ¿Crearía conflicto de participante?
        if (_wouldCreateParticipantConflict(
          eventToCheck: updatedEvent,
          targetDate: updatedEvent.date,
          eventIdToExclude: eventToUpdate.id, // Excluir el evento que estamos moviendo
        )) {
          // Mostrar mensaje y cancelar el drag
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '⚠️ No se puede mover: un participante ya tiene un evento confirmado en ese horario',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
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
      final cellWidth = availableWidth / _visibleDays;
      final cellHeight = AppConstants.cellHeight;
      
      // Usar la misma función común para calcular la posición
      final consistentPosition = _calculateConsistentPosition(event, dragOffset);
      
      // Calcular nueva columna (día) basada en la posición consistente
      final currentDayIndex = event.date.difference(widget.plan.startDate).inDays + 1;
      final startDayIndex = _currentDayGroup * _visibleDays + 1;
      final currentColumnIndex = currentDayIndex - startDayIndex;
      
      // Usar el mismo cálculo que en _calculateConsistentPosition
      final columnProgress = dragOffset.dx / cellWidth;
      final newColumnOffset = columnProgress.round();
      final newColumnIndex = currentColumnIndex + newColumnOffset;
      
      // Verificar que la nueva columna esté en el rango válido
      if (newColumnIndex < 0 || newColumnIndex >= _visibleDays) {
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
      final newDate = widget.plan.startDate.add(Duration(days: (newDayIndex - 1).toInt()));
      
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
    final dayData = column as Map<String, dynamic>;
    final dayIndex = dayData['index'] as int;
    final date = widget.plan.startDate.add(Duration(days: dayIndex - 1));
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: () {
        // Crear evento para el día específico (asignado al primer participante por defecto)
        _showNewEventDialog(date, hourIndex);
      },
      child: Container(
        height: AppConstants.cellHeight,
        width: double.infinity,
        // Celda vacía, los eventos están en la capa separada
        // Doble click para crear eventos
      ),
    );
  }

  /// Muestra el diálogo para crear un nuevo evento para un participante específico
  void _showNewEventDialogForParticipant(DateTime date, int hourIndex, ParticipantTrack participant) {
    _showNewEventDialog(date, hourIndex, participantId: participant.id);
  }

  /// Calcula qué tracks debe abarcar un evento (span horizontal)
  List<int> _calculateEventTrackSpan(Event event) {
    // En el nuevo sistema, los eventos no abarcan múltiples tracks
    // Cada evento se asigna a un participante específico
    return [];
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
          // VALIDAR: ¿Crearía conflicto de participante?
          if (_wouldCreateParticipantConflict(
            eventToCheck: updatedEvent,
            targetDate: updatedEvent.date,
            eventIdToExclude: event.id, // Excluir el evento actual del conteo
          )) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '⚠️ No se puede guardar: un participante ya tiene un evento confirmado en ese horario.\n'
                    'Por favor, elige otra hora, reduce la duración o cambia los participantes.',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ),
              );
            }
            return; // No guardar
          }

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
  void _showNewEventDialog(DateTime date, int hour, {String? participantId}) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: null,
        planId: widget.plan.id ?? '',
        initialDate: date,
        initialHour: hour,
        onSaved: (newEvent) async {
          // VALIDAR: ¿Crearía conflicto de participante?
          if (_wouldCreateParticipantConflict(
            eventToCheck: newEvent,
            targetDate: newEvent.date,
            eventIdToExclude: null, // No excluir nada, es evento nuevo
          )) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '⚠️ No se puede crear: un participante ya tiene un evento confirmado en ese horario.\n'
                    'Por favor, elige otra hora, reduce la duración o cambia los participantes.',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ),
              );
            }
            return; // No guardar
          }

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
    
    // Obtener el notifier existente y refrescar los eventos
    final calendarParams = CalendarNotifierParams(
      planId: widget.plan.id!,
      userId: widget.plan.userId,
      initialDate: widget.plan.startDate,
      initialColumnCount: widget.plan.columnCount,
    );
    
    // Refrescar eventos usando el método del notifier existente
    final calendarNotifier = ref.read(calendarNotifierProvider(calendarParams).notifier);
    calendarNotifier.refreshEvents();
    
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
            // Forzar actualización de la UI
            setState(() {});
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
            // Forzar actualización de la UI
            setState(() {});
          }
        },
        onDeleted: (accommodationId) {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Construye los tracks de alojamiento con agrupación para tracks consecutivos
  Widget _buildAccommodationTracksWithGrouping(List<Accommodation> accommodations, List<dynamic> visibleTracks, double availableWidth, DateTime dayDate) {
    if (accommodations.isEmpty) {
      // Si no hay alojamientos, mostrar solo "Tap para crear" en todos los tracks
      return Row(
        children: visibleTracks.asMap().entries.map((entry) {
          final trackIndex = entry.key;
          final isLastTrack = trackIndex == visibleTracks.length - 1;
          
          return Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: isLastTrack
                    ? null
                    : _createGridBorder(),
              ),
              child: GestureDetector(
                onTap: () => _showNewAccommodationDialog(DateTime.now()),
                onDoubleTap: () => _showNewAccommodationDialog(DateTime.now()),
                child: Center(
                  child: Text(
                    'Tap para crear',
                    style: TextStyle(
                      fontSize: 6,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Para cada alojamiento, crear sus grupos de tracks consecutivos
    final allGroups = <Map<String, dynamic>>[];
    
    for (final accommodation in accommodations) {
      final groups = _getConsecutiveTrackGroupsForAccommodation(accommodation);
      for (final group in groups) {
        allGroups.add({
          'accommodation': accommodation,
          'group': group,
        });
      }
    }
    
    // Ordenar grupos por el primer track
    allGroups.sort((a, b) => (a['group'] as List<int>).first.compareTo((b['group'] as List<int>).first));
    
    // Calcular el ancho de cada subcolumna (igual que los eventos)
    final subColumnWidth = _getSubColumnWidth(availableWidth);
    
    
    return Stack(
      children: allGroups.map((groupData) {
        final accommodation = groupData['accommodation'] as Accommodation;
        final group = groupData['group'] as List<int>;
        final startTrack = group.first;
        final groupWidth = group.length;
        
        // Calcular posición y ancho (igual que los eventos)
        // Para alojamientos, no hay dayX porque están en la fila fija
        final left = startTrack * subColumnWidth;
        final width = subColumnWidth * groupWidth;
        
        
        return Positioned(
          left: left,
          top: 5,
          width: width,
          height: 20,
          child: GestureDetector(
            onTap: () => _showAccommodationDialog(accommodation),
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
                          fontSize: 8, // Mismo tamaño que eventos para altura < 40
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

  /// Actualiza la instancia de CalendarAppBar cuando cambian las variables
  void _updateCalendarAppBar() {
    _calendarAppBar = CalendarAppBar(
      plan: widget.plan,
      currentDayGroup: _currentDayGroup,
      visibleDays: _visibleDays,
      viewMode: _viewMode,
      calendarFilters: _calendarFilters,
      calendarTrackReorder: _calendarTrackReorder,
    );
  }

  List<ParticipantTrack> _getFilteredTracks() {
    return _calendarFilters.getFilteredTracks(
      _viewMode,
      _currentUserId,
      _filteredParticipantIds,
    );
  }

  /// Obtiene el nombre del modo de vista actual
  String _getCurrentViewName() {
    return _calendarFilters.getCurrentViewName(_viewMode);
  }

  /// Obtiene el icono del modo de vista actual
  IconData _getCurrentViewIcon() {
    return _calendarFilters.getCurrentViewIcon(_viewMode);
  }

  /// Muestra el diálogo de vista personalizada
  void _showCustomViewDialog() {
    _calendarFilters.showCustomViewDialog(
      context,
      _filteredParticipantIds,
      (viewMode, participantIds) {
        setState(() {
          _viewMode = viewMode;
          _filteredParticipantIds = participantIds;
        });
      },
    );
  }

  /// Muestra el diálogo integrado de gestión de participantes
  void _showParticipantManagementDialog() {
    _calendarTrackReorder.showParticipantManagementDialog(
      context,
      widget.plan.id!,
      _currentUserId ?? '',
      () {
        // Callback para reordenación
        setState(() {});
      },
      () {
        // Callback para selección
        setState(() {});
      },
    );
  }

  /// Verifica si el usuario actual puede gestionar roles
  Future<bool> _canManageRoles() async {
    try {
      final permissionService = PermissionService();
      final currentUserId = 'cristian_claraso'; // TODO: Obtener del contexto de auth
      
      return await permissionService.hasPermission(
        planId: widget.plan.id!,
        userId: currentUserId,
        permission: Permission.planManageAdmins,
      );
    } catch (e) {
      debugPrint('Error verificando permisos de gestión de roles: $e');
      return false;
    }
  }

  /// Muestra el diálogo de gestión de roles
  void _showManageRolesDialog() {
    final currentUserId = 'cristian_claraso'; // TODO: Obtener del contexto de auth
    
    showDialog(
      context: context,
      builder: (context) => ManageRolesDialog(
        planId: widget.plan.id!,
        currentUserId: currentUserId,
        onRolesChanged: () {
          // Refrescar la UI si es necesario
          setState(() {});
        },
      ),
    );
  }

  // ========== MÉTODOS DE TIMEZONE ==========
  
  /// Convierte un evento de UTC a timezone local para mostrar
  Event _convertEventFromUtc(Event event) {
    if (event.timezone == null || event.timezone!.isEmpty) {
      return event;
    }
    
    // Crear DateTime UTC del evento
    final utcDateTime = DateTime.utc(
      event.date.year,
      event.date.month,
      event.date.day,
      event.hour,
      event.startMinute,
    );
    
    // Convertir a timezone local
    final localDateTime = TimezoneService.utcToLocal(utcDateTime, event.timezone!);
    
    // Crear evento con fecha/hora local
    return event.copyWith(
      date: localDateTime,
      hour: localDateTime.hour,
      startMinute: localDateTime.minute,
    );
  }
}