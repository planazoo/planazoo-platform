import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
import '../../domain/models/overlapping_event_group.dart';
import 'wd_event_cell.dart';

/// Widget que muestra múltiples eventos solapados en una sola celda
class OverlappingEventsCell extends StatefulWidget {
  final OverlappingEventGroup group;
  final int hour;
  final double width;
  final double height;
  final String planId;
  final DateTime date;
  final Function(Event) onEventSaved;
  final Function(String) onEventDeleted;
  final Function(Event, DateTime, int)? onEventMoved;
  final bool Function(Event, DateTime, int)? validateMove;
  final Function(Event, int)? onEventResized;
  final bool Function(Event, int)? validateResize;

  const OverlappingEventsCell({
    super.key,
    required this.group,
    required this.hour,
    required this.width,
    required this.height,
    required this.planId,
    required this.date,
    required this.onEventSaved,
    required this.onEventDeleted,
    this.onEventMoved,
    this.validateMove,
    this.onEventResized,
    this.validateResize,
  });

  @override
  State<OverlappingEventsCell> createState() => _OverlappingEventsCellState();
}

class _OverlappingEventsCellState extends State<OverlappingEventsCell> {

  @override
  Widget build(BuildContext context) {
    // Obtener eventos que están activos en esta hora específica
    final activeEvents = widget.group.getEventsAtHour(widget.hour);
    
    if (activeEvents.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
      );
    }

    // Siempre usar el layout de eventos solapados para mantener consistencia visual
    // Esto asegura que los eventos se vean igual en todas las horas donde están activos
    return _buildOverlappingLayout(activeEvents);
  }

    Widget _buildOverlappingLayout(List<Event> activeEvents) {
    // Limitar a máximo 3 eventos solapados
    final limitedEvents = activeEvents.take(3).toList();
    
         return DragTarget<Event>(
       onWillAcceptWithDetails: (details) {
         final event = details.data;
         if (event == null) return false;
         
         // Validar si se puede mover el evento a esta hora
         bool isValid = true;
         isValid = widget.validateMove?.call(event, widget.date, widget.hour) ?? true;
         
         return isValid;
       },
       onAcceptWithDetails: (details) {
         final event = details.data;
         widget.onEventMoved?.call(event, widget.date, widget.hour);
       },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Stack(
            children: [
              // Fondo para indicar que hay eventos solapados
              Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              
              // Eventos individuales usando EventCell para mantener toda la funcionalidad
              ...limitedEvents.asMap().entries.map((entry) {
                final event = entry.value;
                
                // Calcular posición y tamaño basado en el grupo completo de eventos solapados
                // Esto asegura que la posición sea consistente en todas las horas
                final totalGroupEvents = widget.group.events.length;
                final displayEvents = totalGroupEvents > 3 ? 3 : totalGroupEvents;
                
                // Calcular posición y tamaño para cada evento
                // Asegurar ancho mínimo para que los controles sean visibles y funcionales
                final minEventWidth = 80.0; // Ancho mínimo para controles
                final availableWidth = widget.width * 0.9;
                final calculatedWidth = availableWidth / displayEvents;
                final eventWidth = calculatedWidth < minEventWidth ? minEventWidth : calculatedWidth;
                
                // Ajustar espaciado si el ancho mínimo es mayor que el calculado
                final totalUsedWidth = eventWidth * displayEvents;
                final spacing = (widget.width - totalUsedWidth) / (displayEvents + 1);
                
                // Encontrar el índice del evento en el grupo completo para mantener posición consistente
                final groupIndex = widget.group.events.indexOf(event);
                final eventLeft = spacing + (groupIndex * (eventWidth + spacing));
                
                return Positioned(
                  left: eventLeft,
                  top: 1,
                  width: eventWidth,
                  height: widget.height - 2,
                  child: EventCell(
                    event: event,
                    planId: widget.planId,
                    date: widget.date,
                    hour: widget.hour,
                    width: eventWidth,
                    height: widget.height - 2,
                    onEventSaved: widget.onEventSaved,
                    onEventDeleted: widget.onEventDeleted,
                    onEventMoved: widget.onEventMoved,
                    validateMove: widget.validateMove,
                    onEventResized: widget.onEventResized,
                    validateResize: widget.validateResize,
                  ),
                );
              }),
              
              // No mostrar indicadores de solapamiento - los eventos son independientes
            ],
          ),
        );
      },
    );
  }

         // No necesitamos _buildOverlappingEventCard porque usamos EventCell

  // No necesitamos estos métodos auxiliares porque EventCell los maneja internamente
}
