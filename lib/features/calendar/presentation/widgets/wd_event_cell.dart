import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/utils/constants.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../../shared/utils/color_utils.dart';
import '../../../../shared/services/logger_service.dart';
import '../../domain/models/event.dart';
import 'wd_event_dialog.dart';

class EventCell extends StatefulWidget {
  final Event? event;
  final String planId;
  final DateTime date;
  final int hour;
  final double width;
  final double height;
  final Function(Event) onEventSaved;
  final Function(String) onEventDeleted;
  final Function(Event, DateTime, int)? onEventMoved; // Nueva función para mover eventos
  final bool Function(Event, DateTime, int)? validateMove; // Función para validar si se puede mover
  final Function(Event, int)? onEventResized; // Nueva función para redimensionar duración
  final bool Function(Event, int)? validateResize; // Validación de redimensionado
  final Function(Event, int)? onResizeStart; // Callback cuando inicia el resize
  final Function(Event, int)? onResizeUpdate; // Callback cuando se actualiza el resize
  final Function(Event)? onResizeEnd; // Callback cuando termina el resize
  final Function(String, EventCellController)? onCellRegistered; // Callback para registrar la celda
  final Function(String)? onCellUnregistered; // Callback para desregistrar la celda

  const EventCell({
    super.key,
    this.event,
    required this.planId,
    required this.date,
    required this.hour,
    required this.width,
    required this.height,
    required this.onEventSaved,
    required this.onEventDeleted,
    this.onEventMoved,
    this.validateMove,
    this.onEventResized,
    this.validateResize,
    this.onResizeStart,
    this.onResizeUpdate,
    this.onResizeEnd,
    this.onCellRegistered,
    this.onCellUnregistered,
  });

  @override
  State<EventCell> createState() => _EventCellState();
}

class _EventCellState extends State<EventCell> {
  bool _isDragTarget = false;
  bool _isValidDrop = false;

  // Estado para redimensionar
  bool _isResizing = false;
  int? _previewDuration;
  late int _initialDuration;
  double _resizeDragDy = 0;
  bool _isResizeValid = true;
  
  // Estado para saber si esta celda está siendo afectada por un resize
  bool _isAffectedByResize = false;

  // Info tooltip overlay
  OverlayEntry? _infoOverlay;
  
  // Método para ser notificado de un resize que afecta a esta celda
  void notifyResizeAffects(int newDuration) {
    if (mounted) {
      setState(() {
        _isAffectedByResize = true;
      });
    }
  }
  
  // Método para limpiar el estado de resize
  void clearResizeAffects() {
    if (mounted) {
      setState(() {
        _isAffectedByResize = false;
      });
    }
  }

  // Truncar texto con sufijo '....'
  String _truncateWithDots(String text, int maxChars) {
    if (text.length <= maxChars) return text;
    final truncated = text.substring(0, maxChars).trimRight();
    return '$truncated....';
  }



  // Nuevo: obtener segmento secuencial por celda (rellena cada celda antes de pasar a la siguiente)
  String _getSequentialSegment(String description, int segmentIndex, int maxCharsPerSegment) {
    final clean = description.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isEmpty) return '';
    final start = (segmentIndex * maxCharsPerSegment).clamp(0, clean.length);
    final end = (start + maxCharsPerSegment).clamp(0, clean.length);
    if (start >= end) return '';
    final chunk = clean.substring(start, end);
    // Añadir '....' si hay más texto después de este segmento
    final hasMore = end < clean.length;
    return hasMore ? _truncateWithDots(chunk, maxCharsPerSegment) : chunk;
  }

  Color _getEventColor() {
    if (widget.event == null) return Colors.transparent;
    
    // Usar ColorUtils para obtener el color basado en el tipo y estado de borrador
    return ColorUtils.getEventBackgroundColor(
      widget.event!.typeFamily,
      widget.event!.isDraft,
    );
  }

  IconData _getEventIcon() {
    final family = widget.event?.typeFamily;
    final subtype = widget.event?.typeSubtype;

    if (family == 'desplazamiento') {
      switch (subtype) {
        case 'avion':
          return Icons.flight;
        case 'tren':
          return Icons.train;
        case 'ferry':
          return Icons.directions_boat;
        case 'bus':
          return Icons.directions_bus;
        case 'coche':
          return Icons.directions_car;
        case 'taxi':
          return Icons.local_taxi;
        default:
          return Icons.directions;
      }
    }

    if (family == 'restauracion') {
      switch (subtype) {
        case 'desayuno':
          return Icons.free_breakfast;
        case 'brunch':
          return Icons.restaurant_menu;
        case 'comida':
        case 'cena':
          return Icons.restaurant;
        default:
          return Icons.restaurant;
      }
    }

    if (family == 'actividad') {
      switch (subtype) {
        case 'museo':
          return Icons.museum;
        case 'lugar turístico':
          return Icons.travel_explore;
        case 'actividad deportiva':
          return Icons.sports;
        default:
          return Icons.event;
      }
    }

    return Icons.event_note;
  }

  void _showEventDialog() async {
    final result = await showDialog<Event>(
      context: context,
      builder: (context) => EventDialog(
        event: widget.event,
        planId: widget.planId,
        date: widget.date,
        hour: widget.hour,
        validateEvent: (date, startHour, duration, excludeId) {
          // Permitir eventos solapados - no hay conflictos de horarios
          return false;
        },
      ),
    );

    if (result != null) {
      widget.onEventSaved(result);
    }
  }

  void _showDeleteDialog() {
    if (widget.event == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content: Text('¿Estás seguro de que quieres eliminar "${widget.event!.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onEventDeleted(widget.event!.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Widget para el preview durante el arrastre
  Widget _buildDragPreview() {
    if (widget.event == null) return const SizedBox.shrink();
    
    // Limitar caracteres para el preview (2 líneas aprox.)
    final baseText = widget.event!.isDraft 
      ? '[BORRADOR] ${widget.event!.description}'
      : widget.event!.description;
    final previewText = _truncateWithDots(baseText, 40);

    return Container(
      width: widget.width * 0.8,
      height: widget.height * 0.7, // Reducir altura para evitar overflow
      clipBehavior: Clip.hardEdge, // Añadir clip para evitar overflow
      decoration: BoxDecoration(
        color: _getEventColor(),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_getEventIcon(), size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Expanded(
              child: SizedBox(
                height: widget.height * 0.6, // Altura fija para evitar overflow
                child: Stack(
                  children: [
                    // Texto principal centrado
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Text(
                        previewText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    // Duración en la parte inferior (solo si hay duración > 1)
                    if (widget.event!.duration > 1)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Text(
                          '${widget.event!.duration}h',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoOverlay() {
    if (widget.event == null || _infoOverlay != null) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;

    final event = widget.event!;
    final startHour = event.hour.toString().padLeft(2, '0');
    final endHour = (event.hour + event.duration).toString().padLeft(2, '0');
    final dateStr = DateFormatter.formatDate(event.date);

    _infoOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + size.width + 8,
        top: position.dy,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 300),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
                        child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con título y botón de cerrar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _hideInfoOverlay,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fecha: $dateStr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Hora: $startHour:00 - $endHour:00',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Duración: ${event.duration}h',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (event.color != null) 
                  Text(
                    'Color: ${event.color}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (event.typeFamily != null) 
                  Text(
                    'Tipo: ${event.typeFamily}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (event.typeSubtype != null) 
                  Text(
                    'Subtipo: ${event.typeSubtype}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                // Información de documentos adjuntos
                if (event.documents != null && event.documents!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.attach_file, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${event.documents!.length} documento${event.documents!.length == 1 ? '' : 's'} adjunto${event.documents!.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    if (_infoOverlay != null) {
      overlay.insert(_infoOverlay!);
      
      // Cerrar automáticamente después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _infoOverlay != null) {
          _hideInfoOverlay();
        }
      });
    }
  }

  void _hideInfoOverlay() {
    _infoOverlay?.remove();
    _infoOverlay = null;
  }

  @override
  void initState() {
    super.initState();
    // Registrar esta celda para poder recibir notificaciones de resize
    if (widget.onCellRegistered != null) {
      // Usar formato consistente de fecha
      final normalizedDate = DateTime(widget.date.year, widget.date.month, widget.date.day);
      final cellKey = '${normalizedDate.toIso8601String()}_${widget.hour}';
      final controller = _EventCellControllerImpl(this);
      
      widget.onCellRegistered!(cellKey, controller);
    }
  }

  @override
  void dispose() {
    _hideInfoOverlay();
    
          // Desregistrar esta celda
      if (widget.onCellUnregistered != null) {
        // Usar formato consistente de fecha
        final normalizedDate = DateTime(widget.date.year, widget.date.month, widget.date.day);
        final cellKey = '${normalizedDate.toIso8601String()}_${widget.hour}';
        
        widget.onCellUnregistered!(cellKey);
      }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasEvent = widget.event != null;
    final backgroundColor = hasEvent ? _getEventColor() : Colors.transparent;
    
    // Modo compacto para celdas con poca altura
    final bool isCompact = widget.height <= 30;

    // Calcular líneas permitidas según altura de la celda
    final int lines = widget.height >= AppConstants.minCellHeightForTwoLines ? 2 : 1;
    final int perLineChars = lines == 2 ? 18 : 12;
    final int maxChars = lines * perLineChars;

    // Si hay evento, calcular el índice del segmento en función de la hora relativa
    int? segmentIndex;
    int segments = 0;
    if (hasEvent) {
      segments = widget.event!.duration;
      segmentIndex = (widget.hour - widget.event!.hour).clamp(0, segments - 1);
    }

    final String? displayDescription = hasEvent
        ? (widget.event!.isDraft 
            ? '[BORRADOR] ${_getSequentialSegment(widget.event!.description, segmentIndex!, maxChars)}'
            : _getSequentialSegment(widget.event!.description, segmentIndex!, maxChars))
        : null;

    // Color del borde según el estado de drag, resize o afectado por resize
    Color borderColor = Colors.grey.shade300;
    double borderWidth = 1.0;
    
    if (_isDragTarget) {
      if (_isValidDrop) {
        borderColor = Colors.green;
        borderWidth = 3.0;
      } else {
        borderColor = Colors.red;
        borderWidth = 3.0;
      }
    }

    if (_isResizing) {
      borderColor = _isResizeValid ? Colors.green : Colors.red;
      borderWidth = 3.0;
    }
    
    // Si esta celda está siendo afectada por un resize, mostrar borde verde
    if (_isAffectedByResize) {
      borderColor = Colors.green;
      borderWidth = 3.0;
    }

    // Configurar bordes y esquinas redondeadas para eventos multi-hora
    BorderRadius? borderRadius;
    bool useCustomBorders = false;
    
    if (hasEvent && widget.event!.duration > 1) {
      // Evento multi-hora: aplicar esquinas redondeadas
      if (isFirstHour) {
        // Primera hora: esquinas superiores redondeadas
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        );
      } else if (isLastHour) {
        // Última hora: esquinas inferiores redondeadas
        borderRadius = const BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        );
      }
      // Para eventos multi-hora, usaremos bordes personalizados
      useCustomBorders = true;
    }

    Widget cellContent = Container(
      width: widget.width > 0 ? widget.width : null,
      height: widget.height,
      clipBehavior: Clip.hardEdge, // Añadir clip para evitar overflow
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: borderRadius,
        color: backgroundColor,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge, // Añadir clip al Stack también
        fit: StackFit.expand, // Asegurar que el Stack se ajuste al tamaño del contenedor
        children: [
          // Contenido principal del evento
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showEventDialog,
              onLongPress: hasEvent ? _showDeleteDialog : null,
              child: Container(
                padding: EdgeInsets.all(isCompact ? 2 : 4),
                child: hasEvent
                    ? isFirstHour
                        ? Stack(
                            children: [
                              // Contenido del evento en una sola línea para evitar overflow
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayDescription!,
                                      style: TextStyle(
                                        fontSize: isCompact ? 9 : 10,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: widget.event!.isDraft ? FontStyle.italic : FontStyle.normal,
                                      ),
                                      maxLines: lines,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!isCompact && ((_previewDuration ?? widget.event!.duration) > 1))
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Text(
                                        '${(_previewDuration ?? widget.event!.duration)}h',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  // Indicador de documentos adjuntos
                                  if (!isCompact && widget.event!.documents != null && widget.event!.documents!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Icon(
                                        Icons.attach_file,
                                        size: 10,
                                        color: Colors.blue[600],
                                      ),
                                    ),
                                ],
                              ),
                              // Indicador de borrador
                              if (widget.event!.isDraft)
                                Positioned(
                                  top: -2,
                                  left: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              // Icono de menú-evento (tres puntos)
                              Positioned(
                                top: -2, // Mover más arriba
                                right: -2, // Mover más a la derecha
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 16),
                                  padding: EdgeInsets.zero,
                                  onSelected: (value) {
                                    if (value == 'eliminar') {
                                      _showDeleteDialog();
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem<String>(
                                      value: 'eliminar',
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ),
                              // Icono de información
                              Positioned(
                                top: -2,
                                right: 18, // Posicionar a la izquierda del menú
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: _showInfoOverlay,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Colors.blue[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            displayDescription!,
                            style: TextStyle(
                              fontSize: isCompact ? 9 : 10,
                              fontWeight: FontWeight.w500,
                              fontStyle: widget.event!.isDraft ? FontStyle.italic : FontStyle.normal,
                            ),
                            maxLines: lines,
                            overflow: TextOverflow.ellipsis,
                          )
                    : null,
              ),
            ),
          ),
          // Líneas separadoras personalizadas para eventos multi-hora
          if (useCustomBorders && hasEvent && widget.event!.duration > 1)
            ..._buildCustomSeparatorLines(borderColor, borderWidth),
        ],
      ),
    );

    // Agregar el handle de redimensionado en la última hora del evento
    if (hasEvent && isLastHour) {
      cellContent = Stack(
        children: [
          cellContent,
                                           Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeRow,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (_) {
                    if (widget.event == null) return;
                    setState(() {
                      _isResizing = true;
                      _resizeDragDy = 0;
                      _initialDuration = widget.event!.duration;
                      _previewDuration = _initialDuration;
                      _isResizeValid = true;
                    });
                    
                    // Notificar que inicia el resize
                    if (widget.onResizeStart != null) {
                      widget.onResizeStart!(widget.event!, _initialDuration);
                    }
                  },
                  onPanUpdate: (details) {
                    if (widget.event == null) return;
                    _resizeDragDy += details.delta.dy;
                    final deltaRows = (_resizeDragDy / widget.height).round();
                    int proposed = _initialDuration + deltaRows;
                    if (proposed < 1) proposed = 1;
                    // Límite superior por cuadrícula (24 horas)
                    final maxByGrid = 24 - widget.event!.hour + 1;
                    if (proposed > maxByGrid) proposed = maxByGrid;

                    bool valid = true;
                    if (widget.validateResize != null) {
                      valid = widget.validateResize!(widget.event!, proposed);
                    }

                    setState(() {
                      _previewDuration = proposed;
                      _isResizeValid = valid;
                    });
                    
                    // Notificar la actualización del resize
                    if (widget.onResizeUpdate != null) {
                      widget.onResizeUpdate!(widget.event!, proposed);
                    }
                  },
                  onPanEnd: (_) {
                    if (widget.event == null) return;
                    final newDuration = _previewDuration ?? widget.event!.duration;
                    if (widget.onEventResized != null && _isResizeValid && newDuration != widget.event!.duration) {
                      widget.onEventResized!(widget.event!, newDuration);
                    }
                    setState(() {
                      _isResizing = false;
                      _previewDuration = null;
                      _resizeDragDy = 0;
                      _isResizeValid = true;
                    });
                    
                    // Notificar que termina el resize
                    if (widget.onResizeEnd != null) {
                      widget.onResizeEnd!(widget.event!);
                    }
                  },
                  child: Container(
                    height: 8, // Altura fija para el área de resize
                            decoration: BoxDecoration(
          color: Colors.grey.shade400.withValues(alpha: 0.3),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
          ),
        ),
                    child: Center(
                      child: Icon(
                        Icons.drag_handle,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

         Widget result;
     if (hasEvent) {
       // Para eventos, crear un Draggable que también actúa como DragTarget
       result = DragTarget<Event>(
         onWillAcceptWithDetails: (details) {
           final draggedEvent = details.data;
           if (draggedEvent == null || (widget.event != null && draggedEvent.id == widget.event!.id)) return false;
           
           // Validar si se puede mover el evento arrastrado a esta hora
           bool isValid = true;
           isValid = widget.validateMove?.call(draggedEvent, widget.date, widget.hour) ?? true;
           
           setState(() {
             _isDragTarget = true;
             _isValidDrop = isValid;
           });
           
           return isValid;
         },
         onAcceptWithDetails: (details) {
           final draggedEvent = details.data;
           widget.onEventMoved?.call(draggedEvent, widget.date, widget.hour);
           setState(() {
             _isDragTarget = false;
             _isValidDrop = false;
           });
         },
         onLeave: (draggedEvent) {
           setState(() {
             _isDragTarget = false;
             _isValidDrop = false;
           });
         },
         builder: (context, candidateData, rejectedData) {
           // Dentro del DragTarget, crear el Draggable
           return Draggable<Event>(
             data: widget.event!,
             feedback: _buildDragPreview(),
             childWhenDragging: Opacity(
               opacity: 0.5,
               child: cellContent,
             ),
             child: cellContent,
           );
         },
       );
     } else {
       // Para celdas vacías, solo DragTarget
       result = DragTarget<Event>(
         onWillAcceptWithDetails: (details) {
           final event = details.data;
           if (event == null) return false;
           
           // Validar si hay conflicto de horarios usando la función de validación
           bool isValid = true;
           isValid = widget.validateMove?.call(event, widget.date, widget.hour) ?? true;
           
           setState(() {
             _isDragTarget = true;
             _isValidDrop = isValid;
           });
           
           return isValid;
         },
         onAcceptWithDetails: (details) {
           final event = details.data;
           widget.onEventMoved?.call(event, widget.date, widget.hour);
           setState(() {
             _isDragTarget = false;
             _isValidDrop = false;
           });
         },
         onLeave: (event) {
           setState(() {
             _isDragTarget = false;
             _isValidDrop = false;
           });
         },
         builder: (context, candidateData, rejectedData) {
           return cellContent;
         },
       );
     }

    return result;
  }

  // Construir líneas separadoras personalizadas para eventos multi-hora
  List<Widget> _buildCustomSeparatorLines(Color borderColor, double borderWidth) {
    final List<Widget> lines = [];
    
    if (widget.event == null || widget.event!.duration <= 1) return lines;
    
    // Línea superior modificada (excepto para la primera hora)
    if (!isFirstHour) {
      lines.add(
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: borderWidth * 0.5,
            color: borderColor.withValues(alpha: 0.3),
          ),
        ),
      );
    }
    
    // Línea inferior modificada (excepto para la última hora)
    if (!isLastHour) {
      lines.add(
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: borderWidth * 0.5,
            color: borderColor.withValues(alpha: 0.3),
          ),
        ),
      );
    }
    
    return lines;
  }

  // Determinar si es la primera y última hora del evento
  bool get isFirstHour => widget.event != null && widget.hour == widget.event!.hour;
  bool get isLastHour => widget.event != null && widget.hour == (widget.event!.hour + widget.event!.duration - 1);
}

// Interfaz pública para controlar EventCell desde fuera
abstract class EventCellController {
  void notifyResizeAffects(int newDuration);
  void clearResizeAffects();
}

// Implementación de EventCellController
class _EventCellControllerImpl implements EventCellController {
  final _EventCellState _state;
  
  _EventCellControllerImpl(this._state);
  
  @override
  void notifyResizeAffects(int newDuration) {
    _state.notifyResizeAffects(newDuration);
  }
  
  @override
  void clearResizeAffects() {
    _state.clearResizeAffects();
  }
} 