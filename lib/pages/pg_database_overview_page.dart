import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/database_overview_providers.dart';
import 'package:unp_calendario/app/app_layout_wrapper.dart';
import 'package:unp_calendario/pages/pg_plan_details_page.dart';
import 'package:unp_calendario/pages/pg_calendar_page.dart';

class DatabaseOverviewPage extends ConsumerStatefulWidget {
  const DatabaseOverviewPage({super.key});

  @override
  ConsumerState<DatabaseOverviewPage> createState() => _DatabaseOverviewPageState();
}

class _DatabaseOverviewPageState extends ConsumerState<DatabaseOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return AppLayoutWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vista General de la Base de Datos'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar datos',
            ),
          ],
        ),
        body: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final plansAsync = ref.watch(allPlansProvider);
    
    return plansAsync.when(
      data: (plans) => _buildPlansList(plans),
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando planes...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los datos',
              style: TextStyle(fontSize: 18, color: Colors.red.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.red.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList(List plans) {
    if (plans.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay planes en la base de datos',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Crea tu primer plan para comenzar',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return _buildPlanCard(plan);
      },
    );
  }

  Widget _buildPlanCard(plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Column(
        children: [
          // Header del plan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name ?? 'Sin nombre',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          Text(
                            'ID UNP: ${plan.unpId ?? 'Sin ID'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handlePlanAction(value, plan),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.list),
                              SizedBox(width: 8),
                              Text('Ver detalles'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'calendar',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 8),
                              Text('Ver calendario'),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Fecha inicio',
                        _formatDate(plan.startDate),
                        Icons.date_range,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Fecha fin',
                        _formatDate(plan.endDate),
                        Icons.date_range,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Duración',
                        '${plan.durationInDays ?? 0} días',
                        Icons.timer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ID de Firestore del plan
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ID Firestore: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          plan.id ?? 'Sin ID',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Colors.blue.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido del plan (eventos y alojamientos)
          _buildPlanContent(plan),
        ],
      ),
    );
  }

  Widget _buildPlanContent(plan) {
    return Consumer(
      builder: (context, ref, child) {
        final eventsAsync = ref.watch(allEventsProvider);
        final accommodationsAsync = ref.watch(allAccommodationsProvider);
        
        return Column(
          children: [
            // Eventos del plan
            _buildSectionHeader('🎯 Eventos del Plan', Icons.event),
            eventsAsync.when(
              data: (allEvents) {
                final planEvents = allEvents.where((event) => 
                  event.planId == plan.id
                ).toList();
                
                if (planEvents.isEmpty) {
                  return _buildEmptyState('No hay eventos en este plan');
                }
                
                return Column(
                  children: planEvents.map((event) => _buildEventRow(event)).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _buildEmptyState('Error al cargar eventos'),
            ),
            
            // Alojamientos del plan
            _buildSectionHeader('🏨 Alojamientos del Plan', Icons.hotel),
            accommodationsAsync.when(
              data: (allAccommodations) {
                final planAccommodations = allAccommodations.where((acc) => 
                  acc.planId == plan.id
                ).toList();
                
                if (planAccommodations.isEmpty) {
                  return _buildEmptyState('No hay alojamientos en este plan');
                }
                
                return Column(
                  children: planAccommodations.map((acc) => _buildAccommodationRow(acc)).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _buildEmptyState('Error al cargar alojamientos'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow(event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event,
            size: 20,
            color: Colors.orange.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description ?? 'Sin descripción',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fecha: ${_formatDate(event.date)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Firestore: ${event.id ?? 'Sin ID'}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationRow(accommodation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hotel,
            size: 20,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accommodation.hotelName ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check-in: ${_formatDate(accommodation.checkIn)} | Check-out: ${_formatDate(accommodation.checkOut)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Firestore: ${accommodation.id ?? 'Sin ID'}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handlePlanAction(String action, plan) {
    switch (action) {
      case 'details':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppLayoutWrapper(
              child: PlanDetailsPage(plan: plan),
            ),
          ),
        );
        break;
      case 'calendar':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppLayoutWrapper(
              child: CalendarPage(plan: plan),
            ),
          ),
        );
        break;
    }
  }

  void _refreshData() {
    ref.invalidate(allPlansProvider);
    ref.invalidate(allEventsProvider);
    ref.invalidate(allAccommodationsProvider);
  }
}
