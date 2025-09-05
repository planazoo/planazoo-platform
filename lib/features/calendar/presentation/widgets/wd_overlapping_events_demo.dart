import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
import '../../domain/models/overlapping_event_group.dart';
import 'overlapping_events_cell.dart';

/// Widget de demostración que muestra eventos solapados
class OverlappingEventsDemo extends StatelessWidget {
  const OverlappingEventsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Crear eventos de ejemplo que se solapan
    final demoEvents = _createDemoEvents();
    final groups = OverlappingEventGroup.createGroups(demoEvents, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo: Eventos Solapados'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Eventos Solapados - Demostración',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta demostración muestra cómo se visualizan eventos que se solapan en el tiempo:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Mostrar cada grupo de eventos solapados
            ...groups.map((group) => _buildGroupDemo(group)),
            
            const SizedBox(height: 32),
            
            // Explicación de la funcionalidad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Características del Sistema:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('🎯', 'Detección automática de solapamientos'),
                  _buildFeatureItem('📱', 'Visualización clara de múltiples eventos'),
                  _buildFeatureItem('🎨', 'Colores diferenciados para cada evento'),
                  _buildFeatureItem('📏', 'Posicionamiento inteligente sin superposición'),
                  _buildFeatureItem('🔍', 'Indicadores visuales de conflicto'),
                  _buildFeatureItem('⚡', 'Interacción táctil para cada evento'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupDemo(OverlappingEventGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Grupo de ${group.maxOverlap} eventos solapados',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${group.startHour}:00 - ${group.endHour + 1}:00',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Mostrar eventos individuales
          ...group.events.map((event) => _buildEventInfo(event)),
          
          const SizedBox(height: 16),
          
          // Demostración visual
          Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: OverlappingEventsCell(
              group: group,
              hour: group.startHour,
              width: 400,
              height: 80,
              planId: 'demo',
              date: group.date,
              onEventSaved: (event) {},
              onEventDeleted: (id) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getEventColor(event).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getEventColor(event).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getEventIcon(event),
            color: _getEventColor(event),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.description,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${event.hour}:00 (${event.duration}h)',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Color _getEventColor(Event event) {
    if (event.color == null) return Colors.blue;
    
    switch (event.color) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getEventIcon(Event event) {
    final family = event.typeFamily;
    final subtype = event.typeSubtype;

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

  List<Event> _createDemoEvents() {
    final now = DateTime.now();
    
    return [
      // Evento 1: Desayuno 8:00-9:00
      Event(
        planId: 'demo',
        date: now,
        hour: 8,
        duration: 1,
        description: 'Desayuno en el hotel',
        color: 'blue',
        typeFamily: 'restauracion',
        typeSubtype: 'desayuno',
        createdAt: now,
        updatedAt: now,
      ),
      
      // Evento 2: Visita al museo 8:30-10:30 (se solapa con desayuno)
      Event(
        planId: 'demo',
        date: now,
        hour: 8,
        duration: 2,
        description: 'Visita al Museo del Prado',
        color: 'green',
        typeFamily: 'actividad',
        typeSubtype: 'museo',
        createdAt: now,
        updatedAt: now,
      ),
      
      // Evento 3: Almuerzo 12:00-13:00
      Event(
        planId: 'demo',
        date: now,
        hour: 12,
        duration: 1,
        description: 'Almuerzo en restaurante local',
        color: 'orange',
        typeFamily: 'restauracion',
        typeSubtype: 'comida',
        createdAt: now,
        updatedAt: now,
      ),
      
      // Evento 4: Paseo por la ciudad 12:30-14:30 (se solapa con almuerzo)
      Event(
        planId: 'demo',
        date: now,
        hour: 12,
        duration: 2,
        description: 'Paseo por el centro histórico',
        color: 'purple',
        typeFamily: 'actividad',
        typeSubtype: 'lugar turístico',
        createdAt: now,
        updatedAt: now,
      ),
      
      // Evento 5: Cena 19:00-20:00
      Event(
        planId: 'demo',
        date: now,
        hour: 19,
        duration: 1,
        description: 'Cena en tapas bar',
        color: 'red',
        typeFamily: 'restauracion',
        typeSubtype: 'cena',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
