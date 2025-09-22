import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/calendar_exports.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/shared/utils/constants.dart';
import 'package:unp_calendario/widgets/wd_accommodation_cell.dart';
import 'package:unp_calendario/widgets/wd_event_cell.dart';
import 'package:unp_calendario/widgets/wd_overlapping_events_cell.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

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
  // Parámetros para el provider del calendario
  late CalendarNotifierParams _calendarParams;
  
  // Parámetros para el provider de alojamientos
  late AccommodationNotifierParams _accommodationParams;
  
  // Controller para el scroll horizontal
  final ScrollController _scrollController = ScrollController();
  
  // Estado para los indicadores de scroll
  double _scrollOffset = 0.0;
  double _maxScrollExtent = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Obtener el userId del usuario actual
    final currentUser = ref.read(currentUserProvider);
    final userId = currentUser?.id ?? '';
    
    // Inicializar parámetros del calendario usando la fecha de inicio del plan
    _calendarParams = CalendarNotifierParams(
      planId: widget.plan.id ?? '',
      userId: userId,
      initialDate: widget.plan.startDate,
      initialColumnCount: widget.plan.columnCount ?? AppConstants.defaultColumnCount,
    );
    
    // Inicializar parámetros de alojamientos
    _accommodationParams = AccommodationNotifierParams(
      planId: widget.plan.id ?? '',
    );
    
    // Inicializar los valores de scroll después de la construcción
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollValues();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Actualiza los valores de scroll para los indicadores
  void _updateScrollValues() {
    if (_scrollController.hasClients) {
      setState(() {
        _scrollOffset = _scrollController.offset;
        _maxScrollExtent = _scrollController.position.maxScrollExtent;
      });
    }
  }

  // Getters para acceder al estado del calendario
  CalendarState get _calendarState => ref.watch(calendarStateProvider(_calendarParams));
  CalendarNotifier get _calendarNotifier => ref.read(calendarNotifierProvider(_calendarParams).notifier);
  
  // Getters para acceder al estado de alojamientos
  AccommodationState get _accommodationState => ref.watch(accommodationStateProvider(_accommodationParams));
  AccommodationNotifier get _accommodationNotifier => ref.read(accommodationNotifierProvider(_accommodationParams).notifier);
  
  // Getters para propiedades específicas
  List<Event> get _events => _calendarState.events;
  List<Accommodation> get _accommodations => _accommodationState.accommodations;
  DateTime get selectedDate => _calendarState.selectedDate;
  int get columnCount => _calendarState.columnCount + 1; // +1 para incluir la columna de horas

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar del calendario
        Container(
          height: 56,
          color: AppColorScheme.color2, // Usar color2 del esquema
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    widget.plan.name,
                    style: const TextStyle(
                      color: AppColorScheme.color0, // Usar color0 (blanco) para texto
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Botón para agregar alojamiento
              IconButton(
                onPressed: _showNewAccommodationDialog,
                icon: const Icon(Icons.hotel, color: AppColorScheme.color0),
                tooltip: 'Agregar alojamiento',
              ),
              const SizedBox(width: 8),
              // Botón para eliminar día
              IconButton(
                onPressed: columnCount > 1 ? _removeColumn : null,
                icon: Icon(
                  Icons.remove,
                  color: columnCount > 1 ? AppColorScheme.color0 : AppColorScheme.disabledColor,
                ),
                tooltip: 'Eliminar día',
              ),
              // Botón para añadir día
              IconButton(
                onPressed: _addColumn,
                icon: const Icon(Icons.add, color: AppColorScheme.color0),
                tooltip: 'Añadir día',
              ),
              const SizedBox(width: 16),
              // Selector de fecha
              DateSelector(
                selectedDate: selectedDate,
                onDateChanged: _onDateChanged,
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        // Tabla del calendario con filas fijas
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Anchos fijos simplificados
              const hoursColumnWidth = 80.0;
              const daysColumnWidth = 320.0; // 4 veces las horas (80 × 4)
              
              
              final columnWidths = {
                for (int i = 0; i < columnCount; i++)
                  i: i == 0 
                      ? const FixedColumnWidth(hoursColumnWidth) // Columna de horas
                      : const FixedColumnWidth(daysColumnWidth), // Columnas de días
              };
              
              // Siempre con scroll horizontal para consistencia con indicadores
              return _buildCalendarWithScrollIndicators(
                columnWidths: columnWidths,
                cellWidth: daysColumnWidth,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construye el calendario con indicadores de scroll horizontal
  Widget _buildCalendarWithScrollIndicators({
    required Map<int, TableColumnWidth> columnWidths,
    required double cellWidth,
  }) {
    return Stack(
      children: [
        // Calendario con scroll
        NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification || notification is ScrollEndNotification) {
              _updateScrollValues();
            }
            return false;
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: _buildFixedCalendarTable(
              columnWidths: columnWidths,
              cellWidth: cellWidth,
            ),
          ),
        ),
        // Indicadores de scroll
        _buildScrollIndicators(),
      ],
    );
  }

  /// Construye los indicadores de scroll horizontal
  Widget _buildScrollIndicators() {
    final showLeftIndicator = _scrollOffset > 0;
    final showRightIndicator = _scrollOffset < _maxScrollExtent;
    
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicador izquierdo (solo si hay contenido hacia la izquierda)
          if (showLeftIndicator)
            _buildScrollIndicator(
              isLeft: true,
              onTap: () => _scrollLeft(),
            )
          else
            const SizedBox(width: 40), // Espacio reservado
          
          // Indicador derecho (solo si hay contenido hacia la derecha)
          if (showRightIndicator)
            _buildScrollIndicator(
              isLeft: false,
              onTap: () => _scrollRight(),
            )
          else
            const SizedBox(width: 40), // Espacio reservado
        ],
      ),
    );
  }

  /// Construye un indicador de scroll individual
  Widget _buildScrollIndicator({
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
            isLeft 
                ? AppColorScheme.color4.withOpacity(0.1) 
                : Colors.transparent,
            Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColorScheme.color0,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColorScheme.gridLineColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorScheme.color4.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isLeft ? Icons.chevron_left : Icons.chevron_right,
              color: AppColorScheme.color4,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  /// Scroll hacia la izquierda
  void _scrollLeft() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset - 320, // Ancho de una columna de día
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Scroll hacia la derecha
  void _scrollRight() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset + 320, // Ancho de una columna de día
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Construye una tabla del calendario con filas fijas
  Widget _buildFixedCalendarTable({
    required Map<int, TableColumnWidth> columnWidths,
    required double cellWidth,
  }) {
    return Column(
      children: [
        // Filas fijas (encabezado y alojamientos)
        Table(
          border: TableBorder(
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide.none,
            top: const BorderSide(color: AppColorScheme.gridLineColor),
            bottom: const BorderSide(color: AppColorScheme.gridLineColor),
            left: const BorderSide(color: AppColorScheme.gridLineColor),
            right: const BorderSide(color: AppColorScheme.gridLineColor),
          ),
          columnWidths: columnWidths,
          children: [
            _buildHeaderRow(),
            _buildAccommodationRow(cellWidth),
          ],
        ),
        // Filas con scroll (datos de horas)
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide.none,
                verticalInside: BorderSide.none,
                top: const BorderSide(color: AppColorScheme.gridLineColor),
                bottom: const BorderSide(color: AppColorScheme.gridLineColor),
                left: const BorderSide(color: AppColorScheme.gridLineColor),
                right: const BorderSide(color: AppColorScheme.gridLineColor),
              ),
              columnWidths: columnWidths,
              children: _buildDataRows(cellWidth),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye una tabla del calendario con las especificaciones dadas
  Widget _buildCalendarTable({
    required Map<int, TableColumnWidth> columnWidths,
    required double cellWidth,
  }) {
    return Table(
      border: TableBorder.all(color: AppColorScheme.gridLineColor),
      columnWidths: columnWidths,
      children: [
        _buildHeaderRow(),
        _buildAccommodationRow(cellWidth),
      ],
    );
  }

  /// Construye la fila de encabezado
  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: AppColorScheme.color1), // Usar color1 del esquema
      children: List.generate(columnCount, (col) {
        if (col == 0) {
          return Container(
            height: 50,
            padding: const EdgeInsets.all(8),
            child: const Center(
              child: Text(
                'Hora',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          );
        } else {
          final date = DateService.getDateForColumn(selectedDate, col - 1);
          return Container(
            height: 50,
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateService.getDayName(date.date),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  Text(
                    'Día ${col} - ${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(fontSize: 6, color: AppColorScheme.color2), // Usar color2 del esquema
                  ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  /// Construye la fila de alojamientos
  TableRow _buildAccommodationRow(double cellWidth) {
    return TableRow(
      decoration: BoxDecoration(color: AppColorScheme.color1.withOpacity(0.5)), // Usar color1 con transparencia
      children: List.generate(columnCount, (col) {
        if (col == 0) {
          return Container(
            height: 40,
            padding: const EdgeInsets.all(8),
            child: const Center(
              child: Text(
                'Alojamiento',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          );
        } else {
          return _buildAccommodationCell(col - 1, cellWidth);
        }
      }),
    );
  }

  /// Construye las filas de datos (horas) con eventos solapados
  List<TableRow> _buildDataRows(double cellWidth) {
    return List.generate(AppConstants.defaultRowCount, (row) {
      return TableRow(
        children: List.generate(columnCount, (col) {
          if (col == 0) {
            return _buildTimeCell(row);
          } else {
            return _buildEventCellWithOverlapping(row, col - 1, cellWidth);
          }
        }),
      );
    });
  }

  /// Construye una celda de hora
  Widget _buildTimeCell(int row) {
    return Container(
      height: AppConstants.cellHeight,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColorScheme.color0, // Usar color0 del esquema
        border: Border.all(color: AppColorScheme.gridLineColor), // Usar gridLineColor del esquema
      ),
      child: Align(
        alignment: Alignment.topCenter, // Alineado a la parte superior
        child: Padding(
          padding: const EdgeInsets.only(top: 4), // Pequeño margen superior
          child: Text(
            '${row.toString().padLeft(2, '0')}:00',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  /// Construye una celda de evento con soporte para eventos solapados
  Widget _buildEventCellWithOverlapping(int row, int col, double cellWidth) {
    final date = DateService.getDateForColumn(selectedDate, col);
    final hour = row;
    
    // Obtener todos los eventos de este día
    final dayEvents = _events.where((event) {
      return event.date.year == date.date.year &&
             event.date.month == date.date.month &&
             event.date.day == date.date.day;
    }).toList();
    
    // Buscar eventos que están activos en esta hora específica
    final activeEvents = dayEvents.where((event) {
      return hour >= event.hour && hour < (event.hour + event.duration);
    }).toList();
    
    // Si hay eventos activos, calcular el ancho basado en el grupo de solapamiento
    if (activeEvents.isNotEmpty) {
      // Encontrar el grupo de solapamiento para cada evento activo
      final overlappingGroups = _groupOverlappingEvents(dayEvents);
      
      // Si hay más de un evento, mostrar como solapados
      if (activeEvents.length > 1) {
        // Crear lista de widgets para todos los eventos activos
        final eventWidgets = <Widget>[];
        
        for (final event in activeEvents) {
          for (final group in overlappingGroups) {
            if (group.events.contains(event)) {
              final eventIndex = group.events.indexOf(event);
              final totalEvents = group.events.length;
              final eventWidth = cellWidth / totalEvents;
              final leftPosition = eventIndex * eventWidth;
              
              eventWidgets.add(
                Positioned(
                  left: leftPosition,
                  width: eventWidth,
                  height: AppConstants.cellHeight,
                  child: GestureDetector(
                    onTap: () => _showEventDialog(event),
                    onPanStart: (details) => _handleEventDragStart(event, details),
                    onPanUpdate: (details) => _handleEventDragUpdate(event, details),
                    onPanEnd: (details) => _handleEventDragEnd(event, details),
                    child: EventCell(
                      event: event,
                      planId: widget.plan.id ?? '',
                      date: date.date,
                      hour: hour,
                      cellWidth: eventWidth,
                      onTap: () => _showEventDialog(event),
                      onEventMoved: _onEventMoved,
                      onEventResized: _onEventResized,
                      onEventDeleted: _onEventDeleted,
                    ),
                  ),
                ),
              );
              break; // Salir del bucle interno una vez encontrado el grupo
            }
          }
        }
        
        return Container(
          height: AppConstants.cellHeight,
          width: cellWidth,
          decoration: BoxDecoration(
            border: Border.all(color: AppColorScheme.gridLineColor),
            color: Colors.transparent,
          ),
          child: Stack(
            children: eventWidgets,
          ),
        );
      } else {
        // Si hay solo un evento, mostrar normalmente
        return _buildEventCell(row, col, cellWidth);
      }
    }
    
    // Si no hay eventos, mostrar celda vacía
    return _buildEventCell(row, col, cellWidth);
  }

  /// Construye eventos solapados dentro de una celda
  Widget _buildOverlappingEventsInCell(List<Event> events, double cellWidth, DateTime date, int hour) {
    return Row(
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        final width = cellWidth / events.length;
        
        return Expanded(
          child: Container(
            height: AppConstants.cellHeight,
            width: width,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            child: EventCell(
              event: event,
              planId: widget.plan.id ?? '',
              date: date,
              hour: hour,
              cellWidth: width,
              onTap: () => _showEventDialog(event),
              onEventMoved: _onEventMoved,
              onEventResized: _onEventResized,
              onEventDeleted: _onEventDeleted,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Construye eventos solapados posicionados absolutamente (método no usado)
  List<Widget> _buildOverlappingEvents(double cellWidth) {
    final events = <Widget>[];
    
    for (int col = 1; col < columnCount; col++) {
      final date = DateService.getDateForColumn(selectedDate, col - 1);
      
      // Obtener todos los eventos de este día
      final dayEvents = _events.where((event) {
        return event.date.year == date.date.year &&
               event.date.month == date.date.month &&
               event.date.day == date.date.day;
      }).toList();
      
      // Agrupar eventos solapados
      final overlappingGroups = _groupOverlappingEvents(dayEvents);
      
      for (final group in overlappingGroups) {
        for (int eventIndex = 0; eventIndex < group.events.length; eventIndex++) {
          final event = group.events[eventIndex];
          final totalEvents = group.events.length;
          
          // Calcular posición y tamaño
          final left = (col - 1) * cellWidth + (eventIndex * cellWidth / totalEvents);
          final top = group.startHour * AppConstants.cellHeight;
          final width = cellWidth / totalEvents;
          final height = (group.endHour - group.startHour + 1) * AppConstants.cellHeight;
          
          events.add(
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: EventCell(
                event: event,
                planId: widget.plan.id ?? '',
                date: date.date,
                hour: event.hour,
                cellWidth: width,
                onTap: () => _showEventDialog(event),
                onEventMoved: _onEventMoved,
                onEventResized: _onEventResized,
                onEventDeleted: _onEventDeleted,
              ),
            ),
          );
        }
      }
    }
    
    return events;
  }

  /// Agrupa eventos solapados
  List<OverlappingEventGroup> _groupOverlappingEvents(List<Event> events) {
    if (events.isEmpty) return [];
    
    final groups = <OverlappingEventGroup>[];
    final processedEvents = <String>{};
    
    for (final event in events) {
      if (processedEvents.contains(event.id)) continue;
      
      final overlappingEvents = <Event>[event];
      final eventQueue = <Event>[event];
      processedEvents.add(event.id ?? '');
      
      int startHour = event.hour;
      int endHour = event.hour + event.duration - 1;
      
      while (eventQueue.isNotEmpty) {
        final currentEvent = eventQueue.removeAt(0);
        
        for (final otherEvent in events) {
          if (processedEvents.contains(otherEvent.id)) continue;
          if (otherEvent.id == currentEvent.id) continue;
          
          final otherStart = otherEvent.hour;
          final otherEnd = otherEvent.hour + otherEvent.duration - 1;
          
          if (_hasOverlap(startHour, endHour, otherStart, otherEnd)) {
            overlappingEvents.add(otherEvent);
            eventQueue.add(otherEvent);
            processedEvents.add(otherEvent.id ?? '');
            
            startHour = startHour < otherStart ? startHour : otherStart;
            endHour = endHour > otherEnd ? endHour : otherEnd;
          }
        }
      }
      
      if (overlappingEvents.length > 1) {
        groups.add(OverlappingEventGroup(
          events: overlappingEvents,
          date: event.date,
          startHour: startHour,
          endHour: endHour,
          maxOverlap: overlappingEvents.length,
        ));
      }
    }
    
    return groups;
  }

  /// Verifica si dos rangos de tiempo se solapan
  bool _hasOverlap(int start1, int end1, int start2, int end2) {
    return (start1 <= end2) && (end1 >= start2);
  }

  // Variables para drag & drop de eventos solapados
  bool _isDraggingOverlapping = false;
  Offset _dragStartPosition = Offset.zero;
  double _dragOffset = 0.0;
  double _dragOffsetX = 0.0;

  /// Maneja el inicio del drag de un evento solapado
  void _handleEventDragStart(Event event, DragStartDetails details) {
    _dragStartPosition = details.localPosition;
    _isDraggingOverlapping = true;
    print('🔄 Inicio drag evento solapado: ${event.description}');
  }

  /// Maneja la actualización del drag de un evento solapado
  void _handleEventDragUpdate(Event event, DragUpdateDetails details) {
    if (_isDraggingOverlapping) {
      final delta = details.localPosition - _dragStartPosition;
      _dragOffset = delta.dy;
      _dragOffsetX = delta.dx;
      print('🔄 Drag update: deltaY=${delta.dy}, deltaX=${delta.dx}');
    }
  }

  /// Maneja el final del drag de un evento solapado
  void _handleEventDragEnd(Event event, DragEndDetails details) {
    if (_isDraggingOverlapping) {
      // Calcular nueva posición basada en el offset
      final hourDelta = _calculateNewHour(_dragOffset);
      final dayDelta = _calculateNewDate(_dragOffsetX);
      
      // Calcular nueva hora y fecha absolutas
      final newHour = (event.hour + hourDelta).clamp(0, 23);
      final newDate = event.date.add(Duration(days: dayDelta));
      
      print('🔄 Drag end: deltaHora=$hourDelta, deltaDias=$dayDelta');
      print('🔄 Nueva posición: hora=$newHour, fecha=$newDate');
      
      // Solo mover si hay cambio significativo
      if (newHour != event.hour || newDate != event.date) {
        print('✅ Moviendo evento a nueva posición');
        _onEventMoved(event, newDate, newHour);
      } else {
        print('❌ No hay cambio significativo, cancelando movimiento');
      }
      
      _isDraggingOverlapping = false;
      _dragOffset = 0.0;
      _dragOffsetX = 0.0;
    }
  }

  /// Calcula nueva hora basada en el offset vertical
  int _calculateNewHour(double offset) {
    const pixelsPerHour = 60.0;
    final hourDelta = (offset / pixelsPerHour).round();
    return hourDelta; // Retorna el delta de horas
  }

  /// Calcula delta de días basado en el offset horizontal
  int _calculateNewDate(double offset) {
    const pixelsPerDay = 120.0; // Aproximado
    final dayDelta = (offset / pixelsPerDay).round();
    return dayDelta; // Retorna delta de días
  }

  /// Construye una celda de evento
  Widget _buildEventCell(int row, int col, double cellWidth) {
    final date = DateService.getDateForColumn(selectedDate, col);
    final hour = row;
    final overlappingGroup = _getOverlappingGroupForCell(row, col);
    final eventAtThisHour = _getEventAtHour(date.date, hour);

    return Container(
      height: AppConstants.cellHeight,
      width: cellWidth,
      decoration: BoxDecoration(
        border: Border.all(color: AppColorScheme.gridLineColor), // Usar gridLineColor del esquema
        color: _hasConflicts(row, col) 
            ? AppColorScheme.color3.withOpacity(0.1) // Usar color3 con transparencia para conflictos
            : Colors.transparent,
      ),
      child: overlappingGroup != null
          ? OverlappingEventsCell(
              group: overlappingGroup,
              planId: widget.plan.id ?? '',
              date: date.date,
              hour: hour,
              cellWidth: cellWidth,
              onEventMoved: _onEventMoved,
              onEventResized: _onEventResized,
              onEventDeleted: _onEventDeleted,
            )
          : eventAtThisHour != null
              ? EventCell(
                  event: eventAtThisHour,
                  planId: widget.plan.id ?? '',
                  date: date.date,
                  hour: hour,
                  cellWidth: cellWidth,
                  onTap: () => _showEventDialog(eventAtThisHour),
                  onEventMoved: _onEventMoved,
                  onEventResized: _onEventResized,
                  onEventDeleted: _onEventDeleted,
                )
              : EventCell(
                  event: null,
                  planId: widget.plan.id ?? '',
                  date: date.date,
                  hour: hour,
                  cellWidth: cellWidth,
                  onTap: () => _showNewEventDialog(date.date, hour),
                ),
    );
  }

  /// Obtiene el grupo de eventos solapados para una celda específica
  OverlappingEventGroup? _getOverlappingGroupForCell(int row, int col) {
    final date = DateService.getDateForColumn(selectedDate, col);
    final hour = row;
    
    // Buscar eventos que están activos en esta hora específica
    final activeEvents = _events.where((event) {
      return event.date.year == date.date.year &&
             event.date.month == date.date.month &&
             event.date.day == date.date.day &&
             hour >= event.hour &&
             hour < (event.hour + event.duration);
    }).toList();
    
    // Debug: mostrar eventos activos
    if (activeEvents.length > 1) {
      print('🟠 Eventos solapados detectados en ${date.date} hora $hour:');
      for (final event in activeEvents) {
        print('  - ${event.description} (${event.hour}:00-${event.hour + event.duration}:00)');
      }
    }
    
    // Si hay más de un evento en esta hora, crear un grupo solapado
    if (activeEvents.length > 1) {
      return OverlappingEventGroup(
        events: activeEvents,
        date: date.date,
        startHour: activeEvents.map((e) => e.hour).reduce((a, b) => a < b ? a : b),
        endHour: activeEvents.map((e) => e.hour + e.duration - 1).reduce((a, b) => a > b ? a : b),
        maxOverlap: activeEvents.length,
      );
    }
    
    return null;
  }

  /// Construir la celda de alojamiento con el patrón visual específico
  Widget _buildAccommodationCell(int col, double cellWidth) {
    // Mostrar indicador de carga si está cargando
    if (_accommodationState.isLoading) {
      return Container(
        width: cellWidth,
        height: AppConstants.cellHeight,
        decoration: BoxDecoration(
          border: Border.all(color: AppColorScheme.gridLineColor), // Usar gridLineColor del esquema
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    
    // Obtener alojamientos para esta columna
    final accommodations = _getAccommodationsForColumn(col);
    
    // Usar la nueva AccommodationCell que maneja múltiples alojamientos
    return AccommodationCell(
      accommodations: accommodations,
      onTap: accommodations.isEmpty ? _showNewAccommodationDialog : null,
      onAccommodationTap: accommodations.isNotEmpty ? _showAccommodationDialog : null,
      width: cellWidth,
      height: AppConstants.cellHeight,
    );
  }

  /// Obtener alojamientos para una columna específica
  List<Accommodation> _getAccommodationsForColumn(int col) {
    // Obtener la fecha correspondiente a esta columna
    final date = DateService.getDateForColumn(selectedDate, col);
    final normalizedDate = DateTime(date.date.year, date.date.month, date.date.day);
    
    // Filtrar alojamientos que estén en esta fecha específica
    final filteredAccommodations = _accommodations.where((accommodation) {
      // Normalizar las fechas para comparación
      final checkIn = DateTime(accommodation.checkIn.year, accommodation.checkIn.month, accommodation.checkIn.day);
      final checkOut = DateTime(accommodation.checkOut.year, accommodation.checkOut.month, accommodation.checkOut.day);
      
      // Un alojamiento se muestra en una columna si:
      // 1. La fecha de la columna está entre checkIn y checkOut (inclusive)
      // 2. O si es la fecha de checkIn (para mostrar desde el primer día)
      final isInRange = (normalizedDate.isAfter(checkIn.subtract(const Duration(days: 1))) && 
                        normalizedDate.isBefore(checkOut.add(const Duration(days: 1))) &&
                        (normalizedDate.isAtSameMomentAs(checkIn) || 
                         normalizedDate.isAtSameMomentAs(checkOut) ||
                         (normalizedDate.isAfter(checkIn) && normalizedDate.isBefore(checkOut))));
      
      return isInRange;
    }).toList();
    
    // Eliminar duplicados por ID para evitar mostrar el mismo alojamiento múltiples veces
    final uniqueAccommodations = <String, Accommodation>{};
    for (final accommodation in filteredAccommodations) {
      if (accommodation.id != null) {
        uniqueAccommodations[accommodation.id!] = accommodation;
      }
    }
    
    return uniqueAccommodations.values.toList();
  }

  /// Verifica si hay conflictos en una celda específica
  bool _hasConflicts(int row, int col) {
    final date = DateService.getDateForColumn(selectedDate, col);
    final hour = row;
    
    // Contar eventos en esta celda
    final eventsInCell = _events.where((event) {
      return event.date.year == date.date.year &&
             event.date.month == date.date.month &&
             event.date.day == date.date.day &&
             event.hour == hour;
    }).length;
    
    // Si hay más de 1 evento, hay conflicto
    return eventsInCell > 1;
  }

  /// Obtiene el evento que está activo en una hora específica
  Event? _getEventAtHour(DateTime date, int hour) {
    return _events.where((event) {
      return event.date.year == date.year &&
             event.date.month == date.month &&
             event.date.day == date.day &&
             hour >= event.hour &&
             hour < (event.hour + event.duration);
    }).firstOrNull;
  }

  // Métodos para manejar eventos
  void _onEventMoved(Event event, DateTime newDate, int newHour) {
    _calendarNotifier.moveEvent(event, newDate, newHour);
  }

  void _onEventResized(Event event, int newDuration) {
    _calendarNotifier.resizeEvent(event, newDuration);
  }

  void _onEventDeleted(String eventId) {
    _calendarNotifier.deleteEvent(eventId);
  }

  void _showEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: event,
        planId: widget.plan.id ?? '',
        onSaved: (updatedEvent) {
          _calendarNotifier.updateEvent(updatedEvent);
          Navigator.of(context).pop();
        },
        onDeleted: (eventId) {
          _calendarNotifier.deleteEvent(eventId);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showNewEventDialog(DateTime date, int hour) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: null,
        planId: widget.plan.id ?? '',
        initialDate: date,
        initialHour: hour,
        onSaved: (newEvent) {
          _calendarNotifier.createEvent(newEvent);
          Navigator.of(context).pop();
        },
        onDeleted: (eventId) {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showNewAccommodationDialog() {
    // Implementar diálogo de alojamiento
  }

  void _showAccommodationDialog(Accommodation accommodation) {
    // Implementar diálogo de alojamiento
  }

  // Métodos para la AppBar
  void _addColumn() {
    _calendarNotifier.addColumn();
  }

  void _removeColumn() {
    _calendarNotifier.removeColumn();
  }

  void _onDateChanged(DateTime newDate) {
    _calendarNotifier.changeSelectedDate(newDate);
  }
}