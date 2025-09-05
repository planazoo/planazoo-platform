import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/fixed_table/fixed_table.dart';
import '../../../../shared/utils/constants.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../../shared/services/logger_service.dart';
import '../../calendar_exports.dart';
import '../widgets/wd_accommodation_cell.dart';
import 'package:unp_calendario/app/app_layout_wrapper.dart';
import 'pg_plan_details_page.dart';

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
    
    // Inicializar parámetros del calendario usando la fecha de inicio del plan
    _calendarParams = CalendarNotifierParams(
      planId: widget.plan.id ?? '',
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

  /// Obtiene el grupo de eventos solapados para una celda específica
  OverlappingEventGroup? _getOverlappingGroupForCell(int row, int col) {
    final date = DateService.getDateForColumn(selectedDate, col);
    final hour = row;
    
    // Crear grupos de eventos solapados para esta fecha
    final groups = OverlappingEventGroup.createGroups(_events, date.date);
    
    // Encontrar el grupo que contiene esta hora
    for (final group in groups) {
      if (hour >= group.startHour && hour <= group.endHour) {
        return group;
      }
    }
    
    return null;
  }

  void _onEventSaved(Event event) async {
    // Refrescar los eventos para mostrar el nuevo evento
    await _calendarNotifier.refreshEvents();
    
    // Verificar que el widget esté montado antes de usar el context
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Evento "${event.description}" guardado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onEventDeleted(String eventId) async {
    final success = await _calendarNotifier.deleteEvent(eventId);
    
    // Verificar que el widget esté montado antes de usar el context
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento eliminado'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar el evento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Nueva función de validación para eventos solapados que permite mover eventos
  bool _validateMoveForOverlapping(Event event, DateTime targetDate, int targetHour) {
    return _calendarState.validateMove(event, targetDate, targetHour);
  }

  // Validar si una nueva duración es posible sin conflictos (misma fecha)
  // NOTA: Ahora permite eventos solapados para mostrar múltiples eventos en el mismo horario
  bool _validateResize(Event event, int proposedDuration) {
    // Permitir eventos solapados - no hay conflictos de horarios
    // Los eventos se mostrararán usando el sistema de eventos solapados
    return true;
  }

  // Manejar el movimiento de un evento
  void _onEventMoved(Event event, DateTime newDate, int newHour) async {
    final success = await _calendarNotifier.moveEvent(event, newDate, newHour);
    
    // Verificar que el widget esté montado antes de usar el context
    if (!mounted) return;
    
    if (success) {
      // Verificar si ya existe un evento en la celda destino
      final existingEvent = _events.where((e) => 
        e.id != event.id && // No es el mismo evento
        e.date.year == newDate.year &&
        e.date.month == newDate.month &&
        e.date.day == newDate.day &&
        e.hour == newHour
      ).firstOrNull;
      
      if (existingEvent != null) {
        // Hay un evento existente en la misma celda
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evento "${event.description}" movido y se mostrará solapado con "${existingEvent.description}"'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // No hay eventos solapados
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evento "${event.description}" movido exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al mover el evento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Manejar redimensionado de duración
  void _onEventResized(Event event, int newDuration) async {
    final success = await _calendarNotifier.resizeEvent(event, newDuration);
    
    // Verificar que el widget esté montado antes de usar el context
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Duración actualizada a ${newDuration}h'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar la duración'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    
         // Debug: imprimir información para verificar
    
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
         cellState.notifyResizeAffects(newDuration);
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
    _calendarNotifier.addColumn();
  }

  void removeColumn() {
    _calendarNotifier.removeColumn();
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

    /// Manejar alojamiento guardado
  void _onAccommodationSaved(Accommodation accommodation) async {
    // El alojamiento ya se guardó en el diálogo, solo mostrar mensaje de éxito
    // Verificar que el widget esté montado antes de usar el context
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alojamiento "${accommodation.hotelName}" guardado'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  /// Manejar alojamiento eliminado
  void _onAccommodationDeleted(String accommodationId) async {
    final success = await _accommodationNotifier.deleteAccommodation(accommodationId);
    
    // Verificar que el widget esté montado antes de usar el context
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alojamiento eliminado'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar alojamiento: ${_accommodationState.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// Manejar alojamiento movido
  void _onAccommodationMoved(Accommodation accommodation, DateTime newCheckIn, DateTime newCheckOut) async {
    final success = await _accommodationNotifier.moveAccommodation(accommodation, newCheckIn, newCheckOut);
    
    // Verificar que el widget esté montado antes de usar el context
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alojamiento "${accommodation.hotelName}" movido'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al mover alojamiento: ${_accommodationState.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
     
     return CalendarWithErrorHandling(
       state: _calendarState,
       onRetry: () => _calendarNotifier.clearError(),
       onClearError: () => _calendarNotifier.clearError(),
       child: CalendarWithLoadingStates(
         state: _calendarState,
         child: _buildCalendarContent(),
       ),
     );
   }

  /// Construir el contenido principal del calendario
  Widget _buildCalendarContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.name),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AppLayoutWrapper(
                  child: HomePage(),
                ),
              ),
            );
          },
        ),
        actions: [
          const Spacer(),
          // Botón para ver detalles del plan
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppLayoutWrapper(
                    child: PlanDetailsPage(plan: widget.plan),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.list),
            tooltip: 'Ver detalles del plan',
          ),
          const SizedBox(width: 8),
          // Botón para agregar alojamiento
          IconButton(
            onPressed: _showNewAccommodationDialog,
            icon: const Icon(Icons.hotel),
            tooltip: 'Agregar alojamiento',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: columnCount > AppConstants.defaultColumnCount ? removeColumn : null,
            icon: Icon(
              Icons.remove,
              color: columnCount > AppConstants.defaultColumnCount ? null : Colors.grey,
            ),
            tooltip: 'Eliminar día',
          ),
          IconButton(
            onPressed: addColumn,
            icon: const Icon(Icons.add),
            tooltip: 'Añadir día',
          ),
          const SizedBox(width: 16),
          DateSelector(
            selectedDate: selectedDate,
            onDateChanged: onDateChanged,
          ),
          const SizedBox(width: 16),
          const Spacer(),
        ],
      ),
      body: Column(
        children: [
          // Tabla
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calcular el ancho disponible para las celdas
                final availableWidth = constraints.maxWidth - AppConstants.firstColumnWidth;
                final cellWidth = (availableWidth / columnCount).clamp(120.0, double.infinity);
                final needsScroll = cellWidth <= 120.0;
                
                return Column(
                  children: [
                                         // Tabla que usa el espacio restante
                     Expanded(
                       child: FixedTable(
                         rowCount: AppConstants.defaultRowCount + 1, // +1 para la fila de alojamiento
                         colCount: columnCount,
                         cellWidth: cellWidth,
                         cellHeight: AppConstants.cellHeight,
                         fixedFirstColumnWidth: AppConstants.firstColumnWidth,
                         enableHorizontalScroll: needsScroll,
                                                 onControllersReady: (
                           verticalController,
                           verticalControllerFixed,
                         ) {
                           // _tableVerticalController = verticalController; // Removed
                           // _tableVerticalControllerFixed = verticalControllerFixed; // Removed
                         },
                                                 cellBuilder: (row, col) {
                           if (row == 0) {
                             return _buildAccommodationCell(col, cellWidth);
                           }
                           
                           // Ajustar el índice de fila para los eventos (restar 1 porque la fila 0 es alojamiento)
                           final eventRow = row - 1;
                           final date = DateService.getDateForColumn(selectedDate, col);
                           final overlappingGroup = _getOverlappingGroupForCell(eventRow, col);

                           // Si no hay eventos en esta celda, mostrar celda vacía con DragTarget
                                                        if (overlappingGroup == null) {
                                                           return EventCell(
                                event: null, // Celda vacía
                                planId: widget.plan.id ?? '',
                                date: date.date,
                               hour: eventRow,
                               width: cellWidth,
                               height: AppConstants.cellHeight,
                               onEventSaved: _onEventSaved,
                               onEventDeleted: _onEventDeleted,
                               onEventMoved: _onEventMoved,
                               validateMove: _validateMoveForOverlapping,
                               onEventResized: _onEventResized,
                               validateResize: _validateResize,
                               onResizeStart: _onResizeStart,
                               onResizeUpdate: _onResizeUpdate,
                               onResizeEnd: _onResizeEnd,
                               onCellRegistered: _registerCell,
                               onCellUnregistered: _unregisterCell,
                             );
                           }

                           // Si hay eventos solapados, usar OverlappingEventsCell
                           if (overlappingGroup.maxOverlap > 1) {
                                                           return OverlappingEventsCell(
                                group: overlappingGroup,
                                hour: eventRow,
                                width: cellWidth,
                                height: AppConstants.cellHeight,
                                planId: widget.plan.id ?? '',
                                date: date.date,
                               onEventSaved: _onEventSaved,
                               onEventDeleted: _onEventDeleted,
                               onEventMoved: _onEventMoved,
                               validateMove: _validateMoveForOverlapping,
                               onEventResized: _onEventResized,
                               validateResize: _validateResize,
                             );
                           }

                           // Si solo hay un evento, usar EventCell normal
                           final event = overlappingGroup.events.first;
                                                       return EventCell(
                              event: event,
                              planId: widget.plan.id ?? '',
                              date: date.date,
                             hour: eventRow,
                             width: cellWidth,
                             height: AppConstants.cellHeight,
                             onEventSaved: _onEventSaved,
                             onEventDeleted: _onEventDeleted,
                             onEventMoved: _onEventMoved,
                             validateMove: _validateMoveForOverlapping,
                               onEventResized: _onEventResized,
                               validateResize: _validateResize,
                               onResizeStart: _onResizeStart,
                               onResizeUpdate: _onResizeUpdate,
                               onResizeEnd: _onResizeEnd,
                               onCellRegistered: _registerCell,
                               onCellUnregistered: _unregisterCell,
                             );
                           },
                        headerBuilder: (col) {
                          final calendarDate = DateService.getDateForColumn(selectedDate, col);
                          final isToday = calendarDate.isToday;
                          
                          return Container(
                            width: cellWidth,
                            height: AppConstants.cellHeight,
                            decoration: BoxDecoration(
                              color: isToday ? Colors.orange.shade100 : Colors.grey.shade100,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Número del día
                                Text(
                                  'Día ${col + 1}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isToday ? Colors.orange.shade800 : Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                // Fecha del día
                                Text(
                                  DateFormatter.formatDate(calendarDate.date),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isToday ? Colors.orange.shade700 : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                                                 // Nota: La información del alojamiento ahora se muestra en una fila especial debajo del encabezado
                              ],
                            ),
                          );
                        },
                                                 fixedColumnBuilder: (row) {
                           // Fila 0 es la fila de alojamiento
                           if (row == 0) {
                             return Container(
                               width: AppConstants.firstColumnWidth,
                               height: AppConstants.cellHeight,
                               decoration: BoxDecoration(
                                 color: Colors.blue.shade100,
                                 border: Border.all(color: Colors.grey.shade300),
                               ),
                               child: Center(
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Icon(
                                       Icons.hotel,
                                       size: 16,
                                       color: Colors.blue.shade700,
                                     ),
                                     const SizedBox(height: 1),
                                     Text(
                                       'Alojamiento',
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         fontSize: 10,
                                         color: Colors.blue.shade700,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             );
                           }
                           
                           // Ajustar el índice de fila para las horas (restar 1 porque la fila 0 es alojamiento)
                           final hourRow = row - 1;
                           return Container(
                             width: AppConstants.firstColumnWidth,
                             height: AppConstants.cellHeight,
                             decoration: BoxDecoration(
                               color: Colors.blue.shade50,
                               border: Border.all(color: Colors.grey.shade300),
                             ),
                             child: Center(
                               child: Text(
                                 DateFormatter.formatTime(hourRow),
                                 style: const TextStyle(
                                   fontWeight: FontWeight.bold,
                                   fontSize: 12,
                                 ),
                               ),
                             ),
                           );
                         },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
