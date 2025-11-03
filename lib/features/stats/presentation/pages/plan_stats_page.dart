import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import '../../domain/models/plan_stats.dart';
import '../providers/plan_stats_providers.dart';
import '../../../budget/domain/models/budget_summary.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';

/// T113: Página de estadísticas del plan
class PlanStatsPage extends ConsumerWidget {
  final Plan plan;

  const PlanStatsPage({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(planStatsProvider(plan.id!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas del Plan'),
        backgroundColor: AppColorScheme.color2,
        foregroundColor: Colors.white,
      ),
      body: statsAsync.when(
        data: (stats) => _buildStatsContent(context, ref, stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error al cargar estadísticas',
                style: AppTypography.titleStyle.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTypography.bodyStyle.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, WidgetRef ref, PlanStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen general
          _buildSummarySection(stats),
          const SizedBox(height: 24),
          
          // Eventos por tipo
          if (stats.eventsByFamily.isNotEmpty) ...[
            _buildEventsByFamilySection(stats),
            const SizedBox(height: 24),
          ],
          
          // Distribución temporal
          if (stats.eventsByDate.isNotEmpty) ...[
            _buildTemporalDistributionSection(stats),
            const SizedBox(height: 24),
          ],
          
          // Participantes
          _buildParticipantsSection(context, ref, stats),
          const SizedBox(height: 24),
          
          // Presupuesto (T101)
          if (stats.budgetSummary != null && stats.budgetSummary!.totalCost > 0) ...[
            _buildBudgetSection(stats.budgetSummary!),
            const SizedBox(height: 24),
          ],
          
          // Eventos por subtipo (si hay)
          if (stats.eventsBySubtype.isNotEmpty) ...[
            _buildEventsBySubtypeSection(stats),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarySection(PlanStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen General',
              style: AppTypography.titleStyle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Eventos',
                    stats.totalEvents.toString(),
                    Icons.event,
                    AppColorScheme.color2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Confirmados',
                    stats.confirmedEvents.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Borradores',
                    stats.draftEvents.toString(),
                    Icons.edit_note,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Duración Total',
                    '${(stats.averageDurationHours * stats.totalEvents).toStringAsFixed(1)}h',
                    Icons.access_time,
                    AppColorScheme.color3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.titleStyle.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodyStyle.copyWith(
              color: AppColorScheme.color4,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsByFamilySection(PlanStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eventos por Tipo',
              style: AppTypography.titleStyle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.eventsByFamily.entries.map((entry) {
              final percentage = stats.totalEvents > 0
                  ? (entry.value / stats.totalEvents) * 100
                  : 0.0;
              return _buildBarChartItem(
                _getFamilyLabel(entry.key),
                entry.value,
                percentage,
                _getFamilyColor(entry.key),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartItem(String label, int value, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorScheme.color4,
                  ),
                ),
              ),
              Text(
                '$value (${percentage.toStringAsFixed(1)}%)',
                style: AppTypography.bodyStyle.copyWith(
                  color: AppColorScheme.color4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 24,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemporalDistributionSection(PlanStats stats) {
    final sortedDates = stats.eventsByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    final maxEvents = stats.eventsByDate.values.reduce((a, b) => a > b ? a : b);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución Temporal',
              style: AppTypography.titleStyle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${stats.daysWithEvents} días con eventos',
              style: AppTypography.bodyStyle.copyWith(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedDates.take(10).map((entry) {
              final percentage = maxEvents > 0 ? (entry.value / maxEvents) * 100 : 0.0;
              final dateFormat = DateFormat('dd/MM');
              return _buildBarChartItem(
                dateFormat.format(entry.key),
                entry.value,
                percentage,
                AppColorScheme.color2,
              );
            }),
            if (sortedDates.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... y ${sortedDates.length - 10} días más',
                  style: AppTypography.bodyStyle.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context, WidgetRef ref, PlanStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participantes',
              style: AppTypography.titleStyle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    stats.totalParticipants.toString(),
                    Icons.people,
                    AppColorScheme.color2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Activos',
                    stats.activeParticipants.toString(),
                    Icons.person,
                    Colors.green,
                  ),
                ),
              ],
            ),
            if (stats.totalParticipants > 0) ...[
              const SizedBox(height: 16),
              Text(
                'Actividad: ${stats.participantActivityPercentage.toStringAsFixed(1)}%',
                style: AppTypography.bodyStyle.copyWith(
                  color: AppColorScheme.color4,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Distribución de Eventos',
              style: AppTypography.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorScheme.color4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Para todos: ${stats.eventsForAllParticipants}',
              style: AppTypography.bodyStyle,
            ),
            Text(
              'Específicos: ${stats.eventsWithSpecificParticipants}',
              style: AppTypography.bodyStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsBySubtypeSection(PlanStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eventos por Subtipo',
              style: AppTypography.titleStyle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.eventsBySubtype.entries.map((entry) {
              final percentage = stats.totalEvents > 0
                  ? (entry.value / stats.totalEvents) * 100
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: AppTypography.bodyStyle,
                      ),
                    ),
                    Text(
                      '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                      style: AppTypography.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getFamilyLabel(String family) {
    final labels = {
      'desplazamiento': 'Desplazamiento',
      'alojamiento': 'Alojamiento',
      'actividad': 'Actividad',
      'restauracion': 'Restauración',
      'otro': 'Otro',
    };
    return labels[family] ?? family;
  }

  Color _getFamilyColor(String family) {
    final colors = {
      'desplazamiento': Colors.blue,
      'alojamiento': Colors.purple,
      'actividad': Colors.green,
      'restauracion': Colors.orange,
      'otro': Colors.grey,
    };
    return colors[family] ?? AppColorScheme.color2;
  }
  
  Widget _buildBudgetSection(BudgetSummary budget) {
    final planCurrency = plan.currency; // T153
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Presupuesto',
              style: AppTypography.titleStyle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Coste total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorScheme.color2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColorScheme.color2.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coste Total',
                        style: AppTypography.bodyStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatterService.formatAmount(budget.totalCost, planCurrency),
                        style: AppTypography.titleStyle.copyWith(
                          color: AppColorScheme.color2,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.account_balance_wallet,
                    size: 48,
                    color: AppColorScheme.color2.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Costes por tipo
            if (budget.costByEventType.isNotEmpty) ...[
              Text(
                'Por Tipo de Evento',
                style: AppTypography.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorScheme.color4,
                ),
              ),
              const SizedBox(height: 8),
              ...budget.costByEventType.entries.map((entry) {
                final percentage = budget.totalCost > 0
                    ? (entry.value / budget.totalCost) * 100
                    : 0.0;
                return _buildBarChartItemForBudget(
                  _getFamilyLabel(entry.key),
                  entry.value,
                  percentage,
                  _getFamilyColor(entry.key),
                );
              }),
            ],
            
            const SizedBox(height: 16),
            
            // Desglose eventos vs alojamientos
            if (budget.eventsCost > 0 || budget.accommodationsCost > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Eventos',
                      CurrencyFormatterService.formatAmount(budget.eventsCost, planCurrency),
                      Icons.event,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Alojamientos',
                      CurrencyFormatterService.formatAmount(budget.accommodationsCost, planCurrency),
                      Icons.hotel,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Nota informativa
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${budget.eventsWithCost} eventos y ${budget.accommodationsWithCost} alojamientos con coste definido',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
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
  
  Widget _buildBarChartItemForBudget(String label, double value, double percentage, Color color) {
    final planCurrency = plan.currency; // T153
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorScheme.color4,
                  ),
                ),
              ),
              Text(
                '${CurrencyFormatterService.formatAmount(value, planCurrency)} (${percentage.toStringAsFixed(1)}%)',
                style: AppTypography.bodyStyle.copyWith(
                  color: AppColorScheme.color4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 24,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

