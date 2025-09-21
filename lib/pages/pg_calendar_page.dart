import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/shared/utils/constants.dart';
import 'package:unp_calendario/features/calendar/calendar_exports.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/widgets/wd_accommodation_cell.dart';
import 'package:unp_calendario/widgets/wd_event_cell_controller.dart';
import 'package:unp_calendario/widgets/wd_event_cell.dart';
import 'package:unp_calendario/widgets/wd_overlapping_events_cell.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';
import 'package:unp_calendario/widgets/wd_date_selector.dart';

class CalendarPage extends ConsumerStatefulWidget {
  final Plan plan;

  const CalendarPage({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  // Referencias a las celdas para notificar resize
  final Map<String, EventCellController> _cellReferences = {};
  
  // Parámetros para el provider del calendario
  late CalendarNotifierParams _calendarParams;
  
  // Parámetros para el provider de alojamientos
  late AccommodationNotifierParams _accommodationParams;

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
  }

  @override
  void dispose() {
    // Limpiar referencias de celdas
    _cellReferences.clear();
    
    super.dispose();
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
  int get columnCount => _calendarState.columnCount;

  // Los eventos se cargan automáticamente a través del CalendarNotifier

  // ===== MÉTODOS AUXILIARES =====
  
  /// Muestra un SnackBar con el mensaje especificado
  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Construye una tabla del calendario con las especificaciones dadas
  Widget _buildCalendarTable({
    required Map<int, TableColumnWidth> columnWidths,
    required double cellWidth,
  }) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: columnWidths,
      children: [
        _buildHeaderRow(),
        _buildAccommodationRow(cellWidth),
        ..._buildDataRows(cellWidth),
      ],
    );
  }

  /// Construye la fila de encabezado
  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blue.shade100),
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
                    style: const TextStyle(fontSize: 6, color: Colors.blue),
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
      decoration: BoxDecoration(color: Colors.green.shade50),
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

  /// Construye las filas de datos (horas)
  List<TableRow> _buildDataRows(double cellWidth) {
    return List.generate(AppConstants.defaultRowCount, (row) {
      return TableRow(
        children: List.generate(columnCount, (col) {
          if (col == 0) {
            return _buildTimeCell(row);
          } else {
            return _buildEventCell(row, col - 1, cellWidth);
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
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          '${row.toString().padLeft(2, '0')}:00',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
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
        border: Border.all(color: Colors.grey.shade300),
        color: _hasConflicts(row, col) 
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: overlappingGroup != null
          ? OverlappingEventsCell(
              group: overlappingGroup,
              planId: widget.plan.id ?? '',
              date: date.date,
              hour: hour,
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

  void _onEventSaved(Event event) async {
    final success = event.id == null 
        ? await _calendarNotifier.createEvent(event)
        : await _calendarNotifier.updateEvent(event);
    
    final message = success 
        ? 'Evento "${event.description}" guardado'
        : 'Error al guardar evento "${event.description}"';
    final color = success ? Colors.green : Colors.red;
    
    _showSnackBar(message, color);
  }

  void _onEventDeleted(String eventId) async {
    final success = await _calendarNotifier.deleteEvent(eventId);
    
    final message = success ? 'Evento eliminado' : 'Error al eliminar el evento';
    final color = success ? Colors.orange : Colors.red;
    
    _showSnackBar(message, color);
  }

  void _onEventMoved(Event event, DateTime newDate, int newHour) async {
    final success = await _calendarNotifier.moveEvent(event, newDate, newHour);
    
    if (success) {
      final existingEvent = _events.where((e) => 
        e.id != event.id &&
        e.date.year == newDate.year &&
        e.date.month == newDate.month &&
        e.date.day == newDate.day &&
        e.hour == newHour
      ).firstOrNull;
      
      final message = existingEvent != null
          ? 'Evento "${event.description}" movido y se mostrará solapado con "${existingEvent.description}"'
          : 'Evento "${event.description}" movido exitosamente';
      final color = existingEvent != null ? Colors.orange : Colors.green;
      
      _showSnackBar(message, color);
      } else {
      _showSnackBar('Error al mover el evento', Colors.red);
    }
  }

  void _onEventResized(Event event, int newDuration) async {
    final success = await _calendarNotifier.resizeEvent(event, newDuration);
    
    final message = success 
        ? 'Duración actualizada a ${newDuration}h'
        : 'Error al actualizar la duración';
    final color = success ? Colors.green : Colors.red;
    
    _showSnackBar(message, color);
  }
  
  // Callbacks para el resize visual
  void _onResizeStart(Event event, int currentDuration) {
    // Notificar a las celdas que se van a afectar
    _notifyCellsForResize(event, currentDuration);
  }
  
  void _onResizeUpdate(Event event, int newDuration) {
    // Actualizar la notificación a las celdas
    _notifyCellsForResize(event, newDuration);
  }
  
  void _onResizeEnd(Event event) {
    // Limpiar todas las notificaciones de resize
    _clearAllResizeNotifications();
  }
  
  // Notificar a las celdas que se van a afectar por el resize
  void _notifyCellsForResize(Event event, int newDuration) {
    // Normalizar la fecha para evitar problemas de comparación
    final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
    final startHour = event.hour;
    final endHour = startHour + newDuration - 1;
    
    // Limpiar notificaciones anteriores
    _clearAllResizeNotifications();
    
    // Notificar a todas las celdas que se van a afectar
    for (int hour = startHour; hour <= endHour; hour++) {
      // Crear múltiples formatos de clave para asegurar coincidencia
      final possibleKeys = [
        '${eventDate.toIso8601String()}_$hour',
        '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}_$hour',
        '${eventDate.millisecondsSinceEpoch ~/ 86400000}_$hour', // Días desde epoch
      ];
      
      EventCellController? cellState;
      String? matchedKey;
      
      // Buscar la celda usando diferentes formatos de clave
      for (final key in possibleKeys) {
        if (_cellReferences.containsKey(key)) {
          cellState = _cellReferences[key];
          matchedKey = key;
          break;
        }
      }
      
             if (cellState != null) {
        cellState.notifyResizeAffects(Duration(minutes: newDuration));
       }
    }
  }
  
  // Limpiar todas las notificaciones de resize
  void _clearAllResizeNotifications() {
    for (final cellState in _cellReferences.values) {
      cellState.clearResizeAffects();
    }
  }
  
  // Registrar una referencia a una celda
  void _registerCell(String key, EventCellController cellState) {
    _cellReferences[key] = cellState;
  }
  
     // Desregistrar una referencia a una celda
   void _unregisterCell(String key) {
     _cellReferences.remove(key);
   }

     /// Construir la celda de alojamiento con el patrón visual específico
  Widget _buildAccommodationCell(int col, double cellWidth) {
    
    // Mostrar indicador de carga si está cargando
    if (_accommodationState.isLoading) {
      return Container(
        width: cellWidth,
        height: AppConstants.cellHeight,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
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

  /// Mostrar diálogo para editar alojamiento existente
  void _showAccommodationDialog(Accommodation accommodation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext dialogContext) => AccommodationDialog(
        accommodation: accommodation,
        planId: widget.plan.id ?? '',
        planStartDate: widget.plan.startDate,
        planEndDate: widget.plan.endDate,
        onSaved: _onAccommodationSaved,
        onDeleted: _onAccommodationDeleted,
        onMoved: _onAccommodationMoved,
      ),
    );
  }

  void addColumn() {
    // Añadir día por detrás (al final del plan)
    _calendarNotifier.addColumn();
  }

  void removeColumn() {
    // Eliminar día por detrás (del final del plan)
    if (columnCount > AppConstants.defaultColumnCount) {
    _calendarNotifier.removeColumn();
    }
  }

  void onDateChanged(DateTime newDate) {
    _calendarNotifier.changeSelectedDate(newDate);
  }

  // ===== MÉTODOS PARA GESTIONAR ALOJAMIENTOS =====

  /// Obtener alojamientos para una columna específica
  List<Accommodation> _getAccommodationsForColumn(int col) {
    // Obtener la fecha correspondiente a esta columna
    final date = DateService.getDateForColumn(selectedDate, col);
    final normalizedDate = DateTime(date.date.year, date.date.month, date.date.day);
    
    // Filtrar alojamientos que estén en esta fecha específica
    // Solo mostrar alojamientos que estén activos en esta fecha exacta
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

  void _onAccommodationSaved(Accommodation accommodation) async {
    _showSnackBar('Alojamiento "${accommodation.hotelName}" guardado', Colors.green);
  }
  
  void _onAccommodationDeleted(String accommodationId) async {
    final success = await _accommodationNotifier.deleteAccommodation(accommodationId);
    
    final message = success 
        ? 'Alojamiento eliminado'
        : 'Error al eliminar alojamiento: ${_accommodationState.error}';
    final color = success ? Colors.orange : Colors.red;
    
    _showSnackBar(message, color);
  }
  
  void _onAccommodationMoved(Accommodation accommodation, DateTime newCheckIn, DateTime newCheckOut) async {
    final success = await _accommodationNotifier.moveAccommodation(accommodation, newCheckIn, newCheckOut);
    
    final message = success 
        ? 'Alojamiento "${accommodation.hotelName}" movido'
        : 'Error al mover alojamiento: ${_accommodationState.error}';
    final color = success ? Colors.blue : Colors.red;
    
    _showSnackBar(message, color);
  }

  /// Mostrar diálogo para crear nuevo alojamiento
  void _showNewAccommodationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext dialogContext) => AccommodationDialog(
        accommodation: null,
        planId: widget.plan.id ?? '',
        planStartDate: widget.plan.startDate,
        planEndDate: widget.plan.endDate,
        onSaved: _onAccommodationSaved,
        onDeleted: _onAccommodationDeleted,
        onMoved: _onAccommodationMoved,
      ),
    );
  }

         @override
    Widget build(BuildContext context) {
    return _buildCalendarContent();
   }

  /// Construir el contenido principal del calendario
  Widget _buildCalendarContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.name),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          const Spacer(),
          // Botón para agregar alojamiento
          IconButton(
            onPressed: _showNewAccommodationDialog,
            icon: const Icon(Icons.hotel),
            tooltip: 'Agregar alojamiento',
          ),
          const SizedBox(width: 8),
          // Botón para eliminar día
          IconButton(
            onPressed: columnCount > AppConstants.defaultColumnCount ? removeColumn : null,
            icon: Icon(
              Icons.remove,
              color: columnCount > AppConstants.defaultColumnCount ? null : Colors.grey,
            ),
            tooltip: 'Eliminar día',
          ),
          // Botón para añadir día
          IconButton(
            onPressed: addColumn,
            icon: const Icon(Icons.add),
            tooltip: 'Añadir día',
          ),
          const SizedBox(width: 16),
          // Selector de fecha
          DateSelector(
            selectedDate: selectedDate,
            onDateChanged: onDateChanged,
          ),
          const SizedBox(width: 16),
          const Spacer(),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calcular el ancho disponible para las celdas
          final availableWidth = constraints.maxWidth - AppConstants.firstColumnWidth;
          final cellWidth = availableWidth / (columnCount - 1); // Dividir entre las columnas de días (excluyendo la columna de horas)
          final needsScroll = columnCount > 5; // Scroll cuando hay más de 5 columnas
          
          return needsScroll 
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: _buildCalendarTable(
                      columnWidths: {
                        for (int i = 0; i < columnCount; i++)
                          i: i == 0 
                              ? const FixedColumnWidth(80.0)
                              : const FixedColumnWidth(120.0),
                      },
                      cellWidth: 120.0,
                    ),
                  ),
                )
              : _buildCalendarTable(
                  columnWidths: {
                    for (int i = 0; i < columnCount; i++)
                      i: i == 0 
                          ? const FixedColumnWidth(80.0)
                          : FixedColumnWidth(cellWidth),
                  },
                  cellWidth: cellWidth,
                );
        },
      ),
    );
  }

  void _showEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: event,
        planId: widget.plan.id ?? '',
        onSaved: (updatedEvent) {
          _onEventSaved(updatedEvent);
          Navigator.of(context).pop();
        },
        onDeleted: (eventId) {
          _onEventDeleted(eventId);
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
          _onEventSaved(newEvent);
          Navigator.of(context).pop();
        },
        onDeleted: (eventId) {
          _onEventDeleted(eventId);
          Navigator.of(context).pop();
        },
      ),
    );
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
}