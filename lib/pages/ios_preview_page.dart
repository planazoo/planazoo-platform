

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/widgets/ios_simulator.dart';

// Provider para obtener la lista de planes
final plansListProvider = StreamProvider<List<Plan>>((ref) {
  final planService = ref.read(planServiceProvider);
  return planService.getPlans();
});

class IOSPreviewPage extends ConsumerStatefulWidget {
  const IOSPreviewPage({super.key});

  @override
  ConsumerState<IOSPreviewPage> createState() => _IOSPreviewPageState();
}

class _IOSPreviewPageState extends ConsumerState<IOSPreviewPage> {
  int _currentIndex = 0;
  Plan? _selectedPlan; // Plan seleccionado para el calendario

  List<Widget> get _pages => [
    _buildPlansPageWithRealData(),
    _buildSimpleCalendarPage(),
  ];

  final List<String> _deviceNames = [
    'iPhone 15 Pro',
    'iPhone 15',
    'iPhone 14 Pro',
    'iPhone SE',
  ];

  int _selectedDevice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('iOS Preview'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedDevice = _deviceNames.indexOf(value);
              });
            },
            itemBuilder: (context) => _deviceNames
                .map((device) => PopupMenuItem(
                      value: device,
                      child: Text(device),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_iphone),
                  const SizedBox(width: 8),
                  Text(_deviceNames[_selectedDevice]),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Device selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _deviceNames.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_deviceNames[i]),
                      selected: _selectedDevice == i,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedDevice = i;
                          });
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          // iOS Simulator
          Expanded(
            child: IOSSimulator(
              deviceName: _deviceNames[_selectedDevice],
              width: _getDeviceWidth(_selectedDevice),
              height: _getDeviceHeight(_selectedDevice),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  brightness: Brightness.light,
                ),
                home: Scaffold(
                  appBar: AppBar(
                    title: Text(_currentIndex == 0 ? 'Planes' : 'Calendario'),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  body: Column(
                    children: [
                      Expanded(child: _pages[_currentIndex]),
                      // iOS-style bottom navigation
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: BottomNavigationBar(
                          currentIndex: _currentIndex,
                          onTap: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          type: BottomNavigationBarType.fixed,
                          selectedItemColor: Colors.blue,
                          unselectedItemColor: Colors.grey,
                          items: const [
                            BottomNavigationBarItem(
                              icon: Icon(Icons.list),
                              label: 'Planes',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.calendar_today),
                              label: 'Calendario',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getDeviceWidth(int deviceIndex) {
    switch (deviceIndex) {
      case 0: // iPhone 15 Pro
        return 393;
      case 1: // iPhone 15
        return 393;
      case 2: // iPhone 14 Pro
        return 393;
      case 3: // iPhone SE
        return 375;
      default:
        return 375;
    }
  }

  double _getDeviceHeight(int deviceIndex) {
    switch (deviceIndex) {
      case 0: // iPhone 15 Pro
        return 700;
      case 1: // iPhone 15
        return 700;
      case 2: // iPhone 14 Pro
        return 700;
      case 3: // iPhone SE
        return 600;
      default:
        return 700;
    }
  }

  Widget _buildSimpleCalendarPage() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header del calendario
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Calendario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: Agregar evento
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            // Vista de calendario con 3 días en columna
            Expanded(
              child: _buildCalendarGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Usar el plan seleccionado o un plan de ejemplo si no hay ninguno seleccionado
    final planToUse = _selectedPlan ?? _getSamplePlan();
    
    // Generar días basados en el plan seleccionado
    final startDate = planToUse.startDate;
    final days = List.generate(planToUse.columnCount, (index) => 
      startDate.add(Duration(days: index))
    );
    final calendarParams = CalendarNotifierParams(
      planId: planToUse.id ?? '',
      initialDate: planToUse.startDate,
      initialColumnCount: 3,
    );
    
    // Observar el estado del calendario
    final calendarState = ref.watch(calendarStateProvider(calendarParams));
    final events = calendarState.events;
    
    return Column(
      children: [
        // Header con información del plan seleccionado
        if (_selectedPlan != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedPlan!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'UNP: ${_selectedPlan!.unpId}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedPlan = null;
                      _currentIndex = 0; // Volver a la lista de planes
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
        // Header con días de la semana
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              // Columna fija para horas
              Container(
                width: 50,
                child: const Text(
                  'Hora',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              // Headers de días (3 columnas)
              Expanded(
                child: Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            _getDayHeader(days[i]),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Cuerpo del calendario
        Expanded(
          child: calendarState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : calendarState.hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar eventos',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            calendarState.errorMessage ?? 'Error desconocido',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: 24, // 24 horas
                      itemBuilder: (context, hourIndex) {
                        return Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Columna fija para hora
                              Container(
                                width: 50,
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '${hourIndex.toString().padLeft(2, '0')}:00',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              // 3 columnas de días
                              Expanded(
                                child: Row(
                                  children: [
                                    for (int dayIndex = 0; dayIndex < 3; dayIndex++)
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.grey.shade200,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: _buildDayCell(hourIndex, dayIndex, days[dayIndex], events),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildDayCell(int hour, int dayIndex, DateTime date, List<Event> events) {
    // Filtrar eventos para esta fecha y hora específica
    final eventsForThisHour = events.where((event) {
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      final cellDate = DateTime(date.year, date.month, date.day);
      return eventDate.isAtSameMomentAs(cellDate) && event.hour == hour;
    }).toList();
    
    // Debug: mostrar información en la primera celda
    if (hour == 0 && dayIndex == 0) {
      print('DEBUG: Total eventos cargados: ${events.length}');
      print('DEBUG: Fecha de la celda: $date');
      print('DEBUG: Eventos para esta celda: ${eventsForThisHour.length}');
      if (events.isNotEmpty) {
        print('DEBUG: Primer evento: ${events.first.description} en ${events.first.date} a las ${events.first.hour}:00');
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(2),
      child: eventsForThisHour.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  eventsForThisHour.first.description,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            )
          : Container(
              child: hour == 0 
                ? Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  )
                : null,
            ),
    );
  }

  String _getDayHeader(DateTime date) {
    const weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final weekDay = weekDays[date.weekday - 1];
    return '$weekDay\n${date.day}';
  }

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }

  Widget _buildPlansPageWithRealData() {
    final plansAsync = ref.watch(plansListProvider);
    
    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No hay planes disponibles',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea tu primer plan para comenzar',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
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
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                title: Text(
                  plan.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'UNP: ${plan.unpId}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(plan.startDate)} - ${_formatDate(plan.endDate)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (plan.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.description ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${plan.participants}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'participantes',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Navegar al calendario del plan seleccionado
                  setState(() {
                    _selectedPlan = plan; // Asignar el plan seleccionado
                    _currentIndex = 1; // Cambiar a la vista de calendario
                  });
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando planes...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar planes',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static Plan _getSamplePlan() {
    final now = DateTime.now();
    return Plan(
      id: 'sample-plan-ios',
      name: 'Plan de Ejemplo iOS',
      unpId: 'UNP001',
      baseDate: now,
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      columnCount: 7,
      description: 'Plan de ejemplo para preview de iOS',
      budget: 1000.0,
      participants: 2,
      createdAt: now,
      updatedAt: now,
      savedAt: now,
    );
  }
}
