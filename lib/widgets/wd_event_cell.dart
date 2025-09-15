import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';

class EventCell extends StatefulWidget {
  final Event? event;
  final String planId;
  final DateTime date;
  final int? hour;
  final double? cellWidth;
  final VoidCallback? onTap;
  final Function(Event, DateTime, int)? onEventMoved;
  final Function(Event, int)? onEventResized;
  final Function(String)? onEventDeleted;

  const EventCell({
    super.key,
    this.event,
    required this.planId,
    required this.date,
    this.hour,
    this.cellWidth,
    this.onTap,
    this.onEventMoved,
    this.onEventResized,
    this.onEventDeleted,
  });

  @override
  State<EventCell> createState() => _EventCellState();
}

class _EventCellState extends State<EventCell> {
  bool _isDragging = false;
  Offset _dragStartPosition = Offset.zero;
  double _dragOffset = 0.0;
  double _dragOffsetX = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.event == null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid), // Gris claro Material Design
          ),
          child: const Center(
            child: Icon(Icons.add, color: Color(0xFF9E9E9E), size: 16), // Gris claro Material Design
          ),
      ),
    );
  }

    return MouseRegion(
      cursor: _isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: (details) {
          _dragStartPosition = details.localPosition;
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            final delta = details.localPosition - _dragStartPosition;
            setState(() {
              _dragOffset = delta.dy; // Para movimiento vertical
              _dragOffsetX = delta.dx; // Para movimiento horizontal
            });
          }
        },
        onPanEnd: (details) {
          if (_isDragging) {
            _handleDragEnd(details);
          }
          setState(() {
            _isDragging = false;
            _dragOffset = 0.0;
            _dragOffsetX = 0.0;
          });
        },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
        padding: const EdgeInsets.all(4),
        transform: Matrix4.translationValues(_dragOffsetX, _dragOffset, 0),
      decoration: BoxDecoration(
          color: ColorUtils.getEventColor(widget.event!.typeFamily, widget.event!.isDraft),
          borderRadius: _getBorderRadius(),
          border: _getEventBorder(),
          boxShadow: _isDragging 
              ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Contenido del evento - Solo mostrar en la primera hora
            if (_isFirstHourOfEvent())
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.event!.description ?? 'Event',
                      style: TextStyle(
                        color: ColorUtils.getEventTextColor(widget.event!.typeFamily, widget.event!.isDraft),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.event!.isDraft)
                      const Text(
                        'BORRADOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            // Botones de duración (+ y -) - Solo en la última hora del evento
            if (widget.onEventResized != null && _isLastHourOfEvent())
              Positioned(
                bottom: 4,
                right: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón -
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _decreaseDuration(),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: Colors.black,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Botón +
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _increaseDuration(),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
          ),
        ),
      ),
    );
    }
    
  void _handleDragEnd(DragEndDetails details) {
    if (widget.onEventMoved != null && widget.event != null) {
      // Calcular nueva posición basada en los offsets
      final newHour = _calculateNewHour(_dragOffset);
      final newDate = _calculateNewDate(_dragOffsetX);
      
      // Solo mover si hay cambio en hora o fecha
      if (newHour != widget.event!.hour || newDate != widget.date) {
        widget.onEventMoved!(widget.event!, newDate, newHour);
      }
    }
  }

  void _increaseDuration() {
    if (widget.onEventResized != null && widget.event != null) {
      final currentDuration = widget.event!.duration;
      final newDuration = currentDuration + 1;
      
      // Verificar que no exceda las 24 horas
      if (newDuration <= 24) {
        widget.onEventResized!(widget.event!, newDuration);
      }
    }
  }

  void _decreaseDuration() {
    if (widget.onEventResized != null && widget.event != null) {
      final currentDuration = widget.event!.duration;
      final newDuration = currentDuration - 1;
      
      // Verificar que no sea menor a 1 hora
      if (newDuration >= 1) {
        widget.onEventResized!(widget.event!, newDuration);
      }
    }
  }

  bool _isFirstHourOfEvent() {
    if (widget.event == null || widget.hour == null) return false;
    
    // La primera hora del evento es la hora de inicio
    return widget.hour == widget.event!.hour;
  }

  bool _isLastHourOfEvent() {
    if (widget.event == null || widget.hour == null) return false;
    
    // La última hora del evento es: hora_inicio + duración - 1
    final lastHour = widget.event!.hour + widget.event!.duration - 1;
    return widget.hour == lastHour;
  }

  BorderRadius _getBorderRadius() {
    if (widget.event == null) return BorderRadius.circular(8);
    
    final isFirst = _isFirstHourOfEvent();
    final isLast = _isLastHourOfEvent();
    
    if (isFirst && isLast) {
      // Evento de una sola hora - todas las esquinas redondeadas
      return BorderRadius.circular(8);
    } else if (isFirst) {
      // Primera hora de evento multi-hora - solo esquinas superiores
      return const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      );
    } else if (isLast) {
      // Última hora de evento multi-hora - solo esquinas inferiores
      return const BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      );
    } else {
      // Horas intermedias - sin esquinas redondeadas
      return BorderRadius.zero;
    }
  }

  Border? _getEventBorder() {
    if (_isDragging) {
      return Border.all(color: Colors.white, width: 2);
    }
    
    if (widget.event == null) return null;
    
    final color = ColorUtils.getEventBorderColor(widget.event!.typeFamily, widget.event!.isDraft);
    
    // Usar borde uniforme para evitar conflictos con borderRadius
    return Border.all(color: color, width: 1);
  }

  int _calculateNewHour(double offset) {
    // Convertir offset en píxeles a horas
    const pixelsPerHour = 60.0; // Altura de cada celda de hora
    final hourDelta = (offset / pixelsPerHour).round();
    final newHour = widget.event!.hour + hourDelta;
    
    // Limitar entre 0 y 23
    return newHour.clamp(0, 23);
  }

  DateTime _calculateNewDate(double offset) {
    // Convertir offset en píxeles a días
    // Usar el ancho real de celda si está disponible
    final cellWidth = widget.cellWidth ?? 120.0; // Fallback si no se proporciona
    final dayDelta = (offset / cellWidth).round();
    final newDate = widget.date.add(Duration(days: dayDelta));
    
    return newDate;
  }


  Color _getColorFromString(String? colorName) {
    switch (colorName) {
      case 'blue': return const Color(0xFF2196F3);
      case 'green': return const Color(0xFF4CAF50);
      case 'orange': return const Color(0xFFFF9800);
      case 'purple': return Colors.purple;
      case 'red': return Colors.red;
      case 'teal': return Colors.teal;
      case 'indigo': return Colors.indigo;
      case 'pink': return Colors.pink;
      default: return const Color(0xFF2196F3);
    }
  }
} 