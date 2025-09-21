import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/app/app_layout_wrapper.dart';
import 'package:unp_calendario/pages/pg_dashboard_page.dart';
import 'package:unp_calendario/pages/pg_plan_participants_page.dart';

class PlanDetailsPage extends ConsumerStatefulWidget {
  final Plan plan;

  const PlanDetailsPage({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<PlanDetailsPage> createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends ConsumerState<PlanDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles: ${widget.plan.name}'),
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
                  child: DashboardPage(),
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: _showNewEventDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Crear evento',
          ),
          IconButton(
            onPressed: _showNewAccommodationDialog,
            icon: const Icon(Icons.hotel),
            tooltip: 'Crear alojamiento',
          ),
          IconButton(
            onPressed: _showParticipants,
            icon: const Icon(Icons.people),
            tooltip: 'Gestionar participantes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 Información del Plan
            _buildPlanInfoCard(),
            const SizedBox(height: 24),
            
            // 📅 Resumen de Fechas
            _buildDatesSummary(),
            const SizedBox(height: 24),
            
            // 🏨 Alojamientos
            _buildAccommodationsSection(),
            const SizedBox(height: 24),
            
            // 🕐 Eventos
            _buildEventsSection(),
          ],
        ),
      ),
    );
  }

  /// Construir tarjeta de información del plan
  Widget _buildPlanInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 32,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plan.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        'ID: ${widget.plan.unpId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Fecha Inicio',
                    DateFormatter.formatDate(widget.plan.startDate),
                    Icons.play_arrow,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Fecha Fin',
                    DateFormatter.formatDate(widget.plan.endDate),
                    Icons.stop,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Duración',
                    '${widget.plan.columnCount} días',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 🔍 ID único de Firestore del Plan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID Firestore del Plan:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          widget.plan.id ?? 'Sin ID',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir item de información
  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Construir resumen de fechas
  Widget _buildDatesSummary() {
    final dates = <DateTime>[];
    for (int i = 0; i < widget.plan.columnCount; i++) {
      dates.add(widget.plan.startDate.add(Duration(days: i)));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 Fechas del Plan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dates.map((date) {
                final isToday = date.year == DateTime.now().year &&
                               date.month == DateTime.now().month &&
                               date.day == DateTime.now().day;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.orange.shade100 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isToday ? Colors.orange.shade300 : Colors.blue.shade200,
                    ),
                  ),
                  child: Text(
                    DateFormatter.formatDate(date),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isToday ? Colors.orange.shade800 : Colors.blue.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir sección de alojamientos
  Widget _buildAccommodationsSection() {
    // TODO: Obtener alojamientos del provider
    final accommodations = <Accommodation>[]; // Placeholder
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hotel,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  '🏨 Alojamientos (${accommodations.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (accommodations.isEmpty)
              _buildEmptyState(
                'No hay alojamientos configurados',
                'Toca el botón de hotel para crear uno',
                Icons.hotel_outlined,
              )
            else
              ...accommodations.map((accommodation) => _buildAccommodationItem(accommodation)),
          ],
        ),
      ),
    );
  }

  /// Construir sección de eventos
  Widget _buildEventsSection() {
    // TODO: Obtener eventos del provider
    final events = <Event>[]; // Placeholder
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  '🕐 Eventos (${events.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              _buildEmptyState(
                'No hay eventos programados',
                'Toca el botón + para crear uno',
                Icons.event_outlined,
              )
            else
              ...events.map((event) => _buildEventItem(event)),
          ],
        ),
      ),
    );
  }

  /// Construir item de alojamiento
  Widget _buildAccommodationItem(Accommodation accommodation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  accommodation.hotelName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showAccommodationDialog(accommodation),
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'Editar alojamiento',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                '${DateFormatter.formatDate(accommodation.checkIn)} - ${DateFormatter.formatDate(accommodation.checkOut)}',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                '${accommodation.duration} días',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 🔍 ID único de Firestore del Alojamiento
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'ID: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  accommodation.id ?? 'Sin ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construir item de evento
  Widget _buildEventItem(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showEventDialog(event),
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'Editar evento',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(
                DateFormatter.formatDate(event.date),
                style: TextStyle(color: Colors.green.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(
                '${event.hour}:00 - ${event.hour + event.duration}:00 (${event.duration}h)',
                style: TextStyle(color: Colors.green.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 🔍 ID único de Firestore del Evento
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'ID: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  event.id ?? 'Sin ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construir estado vacío
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo para crear nuevo evento
  void _showNewEventDialog() {
    // TODO: Implementar creación de evento
    
  }

  /// Mostrar diálogo para crear nuevo alojamiento
  void _showNewAccommodationDialog() {
    // TODO: Implementar creación de alojamiento
    
  }

  /// Mostrar página de participantes
  void _showParticipants() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppLayoutWrapper(
          child: PlanParticipantsPage(plan: widget.plan),
        ),
      ),
    );
  }

  /// Mostrar diálogo para editar evento
  void _showEventDialog(Event event) {
    // TODO: Implementar edición de evento
    
  }

  /// Mostrar diálogo para editar alojamiento
  void _showAccommodationDialog(Accommodation accommodation) {
    // TODO: Implementar edición de alojamiento
    
  }
}
