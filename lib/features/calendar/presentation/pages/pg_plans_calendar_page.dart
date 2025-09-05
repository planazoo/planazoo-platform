import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_overview_providers.dart';
import '../../../../app/app_layout_wrapper.dart';
import 'pg_calendar_page.dart';
import 'pg_plan_details_page.dart';

class PlansCalendarPage extends ConsumerStatefulWidget {
  const PlansCalendarPage({super.key});

  @override
  ConsumerState<PlansCalendarPage> createState() => _PlansCalendarPageState();
}

class _PlansCalendarPageState extends ConsumerState<PlansCalendarPage> {
  late DateTime _currentMonth;
  late DateTime _nextMonth;
  String _searchQuery = '';
  String _selectedFilter = 'Todos';
  
  final List<String> _filterOptions = [
    'Todos',
    'Activos',
    'Completados',
    'Este mes',
    'Próximo mes',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _nextMonth = DateTime(now.year, now.month + 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    return AppLayoutWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendario de Planes'),
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar datos',
            ),
          ],
        ),
        body: Column(
          children: [
            // 🔍 Barra de búsqueda y filtros
            _buildSearchAndFilters(),
            
            // 📅 Navegación de meses
            _buildMonthNavigation(),
            
            // 📋 Contenido del calendario
            Expanded(
              child: _buildCalendarContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: '🔍 Buscar planes por nombre...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Filtros
          Row(
            children: [
              Text(
                'Filtros: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.indigo.shade100,
                          checkmarkColor: Colors.indigo.shade700,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonths,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Meses anteriores',
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMonthCard(_currentMonth, 'Mes Actual'),
                _buildMonthCard(_nextMonth, 'Próximo Mes'),
              ],
            ),
          ),
          IconButton(
            onPressed: _nextMonths,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Meses siguientes',
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(DateTime month, String label) {
    final monthName = _getMonthName(month.month);
    final year = month.year;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.indigo.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$monthName $year',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Pestañas de meses
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.indigo.shade700,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.indigo.shade700,
              tabs: [
                Tab(
                  text: _getMonthName(_currentMonth.month),
                ),
                Tab(
                  text: _getMonthName(_nextMonth.month),
                ),
              ],
            ),
          ),
          
          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              children: [
                _buildMonthCalendar(_currentMonth),
                _buildMonthCalendar(_nextMonth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(DateTime month) {
    final plansAsync = ref.watch(allPlansProvider);
    
    return plansAsync.when(
      data: (allPlans) {
        // Filtrar planes según búsqueda y filtros
        final filteredPlans = _filterPlans(allPlans);
        
        if (filteredPlans.isEmpty) {
          return _buildEmptyState(month);
        }
        
        // Agrupar planes por fecha
        final plansByDate = _groupPlansByDate(filteredPlans, month);
        
        return _buildCalendarTable(month, plansByDate);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los planes',
              style: TextStyle(fontSize: 18, color: Colors.red.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.red.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTable(DateTime month, Map<DateTime, List> plansByDate) {
    // Obtener el primer día del mes
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    
    // Obtener el día de la semana del primer día (1 = Lunes, 7 = Domingo)
    final firstWeekday = firstDayOfMonth.weekday;
    
    // Calcular cuántos días del mes anterior necesitamos mostrar
    final daysFromPreviousMonth = firstWeekday - 1;
    
    // Obtener el último día del mes anterior
    final lastDayOfPreviousMonth = firstDayOfMonth.subtract(const Duration(days: 1));
    
    // Calcular el número total de semanas necesarias
    final daysInMonth = _getDaysInMonth(month);
    final totalDaysToShow = daysFromPreviousMonth + daysInMonth;
    final totalWeeks = ((totalDaysToShow - 1) ~/ 7) + 1;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header de días de la semana
          _buildWeekdayHeader(),
          const SizedBox(height: 8),
          
          // Tabla del calendario
          ...List.generate(totalWeeks, (weekIndex) {
            return _buildWeekRow(
              weekIndex,
              month,
              daysFromPreviousMonth,
              daysInMonth,
              plansByDate,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    
    return Row(
      children: weekdays.map((weekday) {
        final isWeekend = weekday == 'Sáb' || weekday == 'Dom';
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Text(
              weekday,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWeekend ? Colors.red.shade600 : Colors.indigo.shade700,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekRow(
    int weekIndex,
    DateTime month,
    int daysFromPreviousMonth,
    int daysInMonth,
    Map<DateTime, List> plansByDate,
  ) {
    return Row(
      children: List.generate(7, (dayIndex) {
        final dayOffset = weekIndex * 7 + dayIndex;
        final isFromPreviousMonth = dayOffset < daysFromPreviousMonth;
        final isFromNextMonth = dayOffset >= daysFromPreviousMonth + daysInMonth;
        
        DateTime date;
        if (isFromPreviousMonth) {
          // Día del mes anterior
          final previousMonth = month.month == 1 ? 12 : month.month - 1;
          final previousYear = month.month == 1 ? month.year - 1 : month.year;
          final dayInPreviousMonth = _getDaysInMonth(DateTime(previousYear, previousMonth, 1)) - daysFromPreviousMonth + dayOffset + 1;
          date = DateTime(previousYear, previousMonth, dayInPreviousMonth);
        } else if (isFromNextMonth) {
          // Día del mes siguiente
          final nextMonth = month.month == 12 ? 1 : month.month + 1;
          final nextYear = month.month == 12 ? month.year + 1 : month.year;
          final dayInNextMonth = dayOffset - daysFromPreviousMonth - daysInMonth + 1;
          date = DateTime(nextYear, nextMonth, dayInNextMonth);
        } else {
          // Día del mes actual
          final dayInCurrentMonth = dayOffset - daysFromPreviousMonth + 1;
          date = DateTime(month.year, month.month, dayInCurrentMonth);
        }
        
        final dayPlans = plansByDate[date] ?? [];
        final isCurrentMonth = !isFromPreviousMonth && !isFromNextMonth;
        final isToday = _isToday(date);
        final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
        
        return Expanded(
          child: _buildDayCell(
            date,
            dayPlans,
            isCurrentMonth,
            isToday,
            isWeekend,
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(
    DateTime date,
    List plans,
    bool isCurrentMonth,
    bool isToday,
    bool isWeekend,
  ) {
    return Container(
      height: 120, // Altura fija para todas las celdas
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isToday 
            ? Colors.blue.shade50 
            : isCurrentMonth 
                ? Colors.white 
                : Colors.grey.shade100,
        border: Border.all(
          color: isToday 
              ? Colors.blue.shade300 
              : Colors.grey.shade300,
          width: isToday ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header del día
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              color: isToday 
                  ? Colors.blue.shade600 
                  : isWeekend 
                      ? Colors.red.shade100 
                      : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isToday 
                        ? Colors.white 
                        : isCurrentMonth 
                            ? Colors.black87 
                            : Colors.grey.shade600,
                  ),
                ),
                if (plans.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${plans.length}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Contenido del día (planes)
          Expanded(
            child: plans.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    padding: const EdgeInsets.all(2),
                    itemCount: plans.length > 3 ? 3 : plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return _buildPlanChipCompact(plan);
                    },
                  ),
          ),
          
          // Indicador de más planes si hay más de 3
          if (plans.length > 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                '+${plans.length - 3} más',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanChipCompact(plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPlanCalendar(plan),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.indigo.shade300, width: 0.5),
            ),
            child: Text(
              plan.name ?? 'Sin nombre',
              style: TextStyle(
                color: Colors.indigo.shade800,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(DateTime month) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay planes en ${_getMonthName(month.month)} ${month.year}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea planes para verlos en el calendario',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares
  List _filterPlans(List allPlans) {
    List filteredPlans = allPlans;
    
    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filteredPlans = filteredPlans.where((plan) =>
        plan.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false
      ).toList();
    }
    
    // Filtro por tipo
    switch (_selectedFilter) {
      case 'Activos':
        // Filtrar por planes activos (fecha futura)
        filteredPlans = filteredPlans.where((plan) =>
          plan.startDate?.isAfter(DateTime.now()) ?? false
        ).toList();
        break;
      case 'Completados':
        // Filtrar por planes completados (fecha pasada)
        filteredPlans = filteredPlans.where((plan) =>
          plan.endDate?.isBefore(DateTime.now()) ?? false
        ).toList();
        break;
      case 'Este mes':
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month, 1);
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        filteredPlans = filteredPlans.where((plan) =>
          plan.startDate?.isAfter(currentMonth.subtract(const Duration(days: 1))) ?? false &&
          plan.startDate?.isBefore(nextMonth) ?? false
        ).toList();
        break;
      case 'Próximo mes':
        final now = DateTime.now();
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        final nextNextMonth = DateTime(now.year, now.month + 2, 1);
        filteredPlans = filteredPlans.where((plan) =>
          plan.startDate?.isAfter(nextMonth.subtract(const Duration(days: 1))) ?? false &&
          plan.startDate?.isBefore(nextNextMonth) ?? false
        ).toList();
        break;
    }
    
    return filteredPlans;
  }

  Map<DateTime, List> _groupPlansByDate(List plans, DateTime month) {
    final Map<DateTime, List> plansByDate = {};
    
    for (final plan in plans) {
      if (plan.startDate != null) {
        // Crear entradas para cada día del rango del plan
        final startDate = DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day);
        final endDate = plan.endDate != null 
            ? DateTime(plan.endDate.year, plan.endDate.month, plan.endDate.day)
            : startDate;
        
        DateTime currentDate = startDate;
        while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
          // Solo incluir fechas del mes actual
          if (currentDate.month == month.month && currentDate.year == month.year) {
            final normalizedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
            plansByDate.putIfAbsent(normalizedDate, () => []).add(plan);
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
    }
    
    return plansByDate;
  }

  void _navigateToPlanCalendar(plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppLayoutWrapper(
          child: CalendarPage(plan: plan),
        ),
      ),
    );
  }

  void _handlePlanAction(String action, plan) {
    switch (action) {
      case 'calendar':
        _navigateToPlanCalendar(plan);
        break;
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
    }
  }

  void _previousMonths() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _nextMonth = DateTime(_nextMonth.year, _nextMonth.month - 1, 1);
    });
  }

  void _nextMonths() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _nextMonth = DateTime(_nextMonth.year, _nextMonth.month + 1, 1);
    });
  }

  void _refreshData() {
    ref.invalidate(allPlansProvider);
  }

  // Utilidades de fecha
  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }

  int _getDaysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    return '${date.day}/${date.month}/${date.year}';
  }
}
