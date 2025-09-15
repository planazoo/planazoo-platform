import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/overlapping_event_group.dart';
import 'package:unp_calendario/widgets/wd_event_cell.dart';

/// Widget que muestra múltiples eventos solapados en una sola celda
class OverlappingEventsCell extends StatefulWidget {
  final OverlappingEventGroup group;
  final int hour;
  final String planId;
  final DateTime date;
  final double? cellWidth;
  final Function(Event)? onEventTap;
  final Function(Event)? onEventEdit;
  final Function(Event)? onEventDelete;
  final Function(Event, DateTime, int)? onEventMoved;
  final Function(Event, int)? onEventResized;
  final Function(String)? onEventDeleted;

  const OverlappingEventsCell({
    super.key,
    required this.group,
    required this.hour,
    required this.planId,
    required this.date,
    this.cellWidth,
    this.onEventTap,
    this.onEventEdit,
    this.onEventDelete,
    this.onEventMoved,
    this.onEventResized,
    this.onEventDeleted,
  });

  @override
  State<OverlappingEventsCell> createState() => _OverlappingEventsCellState();
}

class _OverlappingEventsCellState extends State<OverlappingEventsCell> {
  @override
  Widget build(BuildContext context) {
    print('🟠 Renderizando OverlappingEventsCell con ${widget.group.events.length} eventos');
    
    return Container(
      height: 60, // Usar la altura estándar de celda del calendario
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF9800), width: 2), // Naranja Material Design
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xFFFF9800).withValues(alpha: 0.1), // Naranja transparente
      ),
      child: Stack(
        children: [
          // Indicador de solapamiento
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800), // Naranja Material Design
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.group.events.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Eventos solapados distribuidos verticalmente
          ...widget.group.events.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final cellWidth = widget.cellWidth ?? 120.0; // Usar cellWidth si está disponible
            final totalEvents = widget.group.events.length;
            
            // Calcular ancho y posición vertical
            final width = (cellWidth - 4) / totalEvents; // Dividir el ancho entre todos los eventos
            final left = index * width; // Posición horizontal basada en el índice
            
            // Calcular altura y posición vertical basada en la duración del evento
            final eventStartHour = event.hour;
            final eventEndHour = event.hour + event.duration;
            final currentHour = widget.hour;
            
            // Solo mostrar si el evento está activo en esta hora
            if (currentHour >= eventStartHour && currentHour < eventEndHour) {
              // Calcular posición vertical dentro de la celda
              final verticalOffset = (currentHour - eventStartHour) * 60.0; // 60px por hora
              final height = event.duration * 60.0; // Altura total del evento
              
              return Positioned(
                left: left + 1, // Pequeño margen
                top: -verticalOffset, // Posición vertical negativa para que empiece desde arriba
                width: width - 2, // Ancho con margen
                height: height, // Altura total del evento
                child: EventCell(
                  event: event,
                  planId: widget.planId,
                  date: widget.date,
                  hour: widget.hour,
                  cellWidth: width - 2, // Usar el ancho calculado
                  onTap: () => widget.onEventTap?.call(event),
                  onEventMoved: widget.onEventMoved,
                  onEventResized: widget.onEventResized,
                  onEventDeleted: widget.onEventDeleted,
                ),
              );
            }
            
            return const SizedBox.shrink(); // No mostrar si no está activo en esta hora
          }),
        ],
      ),
    );
  }
}