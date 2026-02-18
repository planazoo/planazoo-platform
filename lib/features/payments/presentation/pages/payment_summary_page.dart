import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import '../../domain/models/payment_summary.dart';
import '../../domain/services/balance_service.dart';
import '../providers/payment_providers.dart';
import '../../../../widgets/dialogs/payment_dialog.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import '../widgets/kitty_contribution_dialog.dart';
import '../widgets/kitty_expense_dialog.dart';
import '../../domain/models/kitty_contribution.dart';
import '../../domain/models/kitty_expense.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';

/// T102: Página de resumen de pagos y balances del plan
class PaymentSummaryPage extends ConsumerWidget {
  final Plan plan;

  const PaymentSummaryPage({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(paymentSummaryProvider(plan.id!));
    final balanceService = ref.watch(balanceServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Pagos'),
        backgroundColor: AppColorScheme.color2,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar pago',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => PaymentDialog(
                  planId: plan.id!,
                  plan: plan,
                  onSaved: () {
                    // Refrescar el resumen
                    ref.invalidate(paymentSummaryProvider(plan.id!));
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) {
          final transferSuggestions = balanceService.calculateTransferSuggestions(summary);
          return _buildSummaryContent(context, ref, summary, transferSuggestions);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error al cargar resumen de pagos',
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

  Widget _buildSummaryContent(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary,
    List<TransferSuggestion> transferSuggestions,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // T220: Aviso legal — la app no procesa cobros
          _buildPaymentDisclaimer(context),
          const SizedBox(height: 16),

          // Resumen general
          _buildGeneralSummary(summary),
          const SizedBox(height: 24),

          // T219: Bote común
          _buildKittySection(context, ref),
          const SizedBox(height: 24),

          // Balances por participante
          _buildBalancesSection(context, ref, summary),
          const SizedBox(height: 24),

          // Sugerencias de transferencias
          if (transferSuggestions.isNotEmpty) ...[
            _buildTransferSuggestionsSection(transferSuggestions),
            const SizedBox(height: 24),
          ],

          // Gráfico de balances
          _buildBalanceChart(summary),
        ],
      ),
    );
  }

  /// T220: Aviso breve de que la app no procesa cobros (solo anotación y cuadre).
  Widget _buildPaymentDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade800, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'La app no procesa cobros; solo sirve para anotar pagos y cuadrar entre el grupo.',
              style: AppTypography.bodyStyle.copyWith(
                fontSize: 13,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// T219: Sección Bote común (aportaciones, gastos, saldo)
  Widget _buildKittySection(BuildContext context, WidgetRef ref) {
    final planCurrency = plan.currency;
    final contributionsAsync = ref.watch(kittyContributionsProvider(plan.id!));
    final expensesAsync = ref.watch(kittyExpensesProvider(plan.id!));
    final currentUser = ref.watch(currentUserProvider);
    final isOrganizer = currentUser?.id == plan.userId;

    return contributionsAsync.when(
      data: (contributions) {
        return expensesAsync.when(
          data: (expenses) {
            final totalContributions = contributions.fold<double>(0.0, (s, c) => s + c.amount);
            final totalExpenses = expenses.fold<double>(0.0, (s, e) => s + e.amount);
            final kittyBalance = totalContributions - totalExpenses;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.savings, color: AppColorScheme.color2),
                        const SizedBox(width: 8),
                        Text(
                          'Bote común',
                          style: AppTypography.titleStyle.copyWith(
                            color: AppColorScheme.color4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Saldo: ${CurrencyFormatterService.formatAmount(kittyBalance, planCurrency)}',
                          style: AppTypography.bodyStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kittyBalance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Aportación'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => KittyContributionDialog(
                                plan: plan,
                                onSaved: () {
                                  ref.invalidate(paymentSummaryProvider(plan.id!));
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        if (isOrganizer)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.remove_circle_outline),
                            label: const Text('Gasto del bote'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => KittyExpenseDialog(
                                  plan: plan,
                                  onSaved: () {
                                    ref.invalidate(paymentSummaryProvider(plan.id!));
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    if (contributions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Aportaciones',
                        style: AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...contributions.take(10).map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_upward, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${c.participantId}: ${c.concept ?? "Aporte"}',
                                    style: AppTypography.bodyStyle.copyWith(fontSize: 12),
                                  ),
                                ),
                                Text(
                                  '${CurrencyFormatterService.formatAmount(c.amount, planCurrency)} · ${DateFormat('dd/MM/yyyy').format(c.contributionDate)}',
                                  style: AppTypography.bodyStyle.copyWith(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )),
                      if (contributions.length > 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+ ${contributions.length - 10} más',
                            style: AppTypography.bodyStyle.copyWith(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                    ],
                    if (expenses.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Gastos del bote',
                        style: AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...expenses.take(10).map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_downward, size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.concept,
                                    style: AppTypography.bodyStyle.copyWith(fontSize: 12),
                                  ),
                                ),
                                Text(
                                  '-${CurrencyFormatterService.formatAmount(e.amount, planCurrency)} · ${DateFormat('dd/MM/yyyy').format(e.expenseDate)}',
                                  style: AppTypography.bodyStyle.copyWith(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )),
                      if (expenses.length > 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+ ${expenses.length - 10} más',
                            style: AppTypography.bodyStyle.copyWith(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error al cargar gastos del bote: $e', style: AppTypography.bodyStyle),
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Error al cargar bote: $e', style: AppTypography.bodyStyle),
        ),
      ),
    );
  }

  Widget _buildGeneralSummary(PaymentSummary summary) {
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
                    'Coste Total',
                    CurrencyFormatterService.formatAmount(summary.totalCost, planCurrency),
                    Icons.money,
                    AppColorScheme.color2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Pagado',
                    CurrencyFormatterService.formatAmount(summary.totalPaid, planCurrency),
                    Icons.payment,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Participantes',
                    summary.totalParticipants.toString(),
                    Icons.people,
                    AppColorScheme.color1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getBalanceColor(summary.totalPaid - summary.totalCost)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getBalanceColor(summary.totalPaid - summary.totalCost)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getBalanceIcon(summary.totalPaid - summary.totalCost),
                    color: _getBalanceColor(summary.totalPaid - summary.totalCost),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balance General',
                          style: AppTypography.bodyStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          CurrencyFormatterService.formatAmount(summary.totalPaid - summary.totalCost, planCurrency),
                          style: AppTypography.titleStyle.copyWith(
                            color: _getBalanceColor(summary.totalPaid - summary.totalCost),
                            fontWeight: FontWeight.bold,
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.titleStyle.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalancesSection(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary,
  ) {
    final balances = summary.balancesByParticipant.values.toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balances por Participante',
              style: AppTypography.titleStyle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...balances.map((balance) => _buildParticipantBalanceCard(context, ref, balance)),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantBalanceCard(
    BuildContext context,
    WidgetRef ref,
    ParticipantBalance balance,
  ) {
    final planCurrency = plan.currency; // T153

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getBalanceColor(balance.balance).withOpacity(0.2),
          child: Icon(
            _getBalanceIcon(balance.balance),
            color: _getBalanceColor(balance.balance),
          ),
        ),
        title: Text(
          balance.userName,
          style: AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _getBalanceStatusText(balance),
          style: AppTypography.bodyStyle.copyWith(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getBalanceColor(balance.balance).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getBalanceColor(balance.balance).withOpacity(0.3),
            ),
          ),
          child: Text(
            CurrencyFormatterService.formatAmount(balance.balance, planCurrency),
            style: AppTypography.bodyStyle.copyWith(
              color: _getBalanceColor(balance.balance),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceDetailRow('Coste asignado', CurrencyFormatterService.formatAmount(balance.totalCost, planCurrency)),
                const SizedBox(height: 8),
                _buildBalanceDetailRow('Total pagado', CurrencyFormatterService.formatAmount(balance.totalPaid, planCurrency)),
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 8),
                _buildBalanceDetailRow(
                  'Balance',
                  CurrencyFormatterService.formatAmount(balance.balance, planCurrency),
                  isBold: true,
                  color: _getBalanceColor(balance.balance),
                ),
                if (balance.payments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Pagos registrados:',
                    style: AppTypography.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...balance.payments.map((payment) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${CurrencyFormatterService.formatAmount(payment.amount, planCurrency)} - ${payment.concept ?? payment.eventDescription ?? "Sin concepto"}',
                            style: AppTypography.bodyStyle.copyWith(fontSize: 12),
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(payment.paymentDate),
                          style: AppTypography.bodyStyle.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyStyle.copyWith(
            color: Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyStyle.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransferSuggestionsSection(List<TransferSuggestion> suggestions) {
    final planCurrency = plan.currency; // T153

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.swap_horiz, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Sugerencias de Transferencias',
                  style: AppTypography.titleStyle.copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestions.map((suggestion) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      suggestion.fromUserName,
                      style: AppTypography.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatterService.formatAmount(suggestion.amount, planCurrency),
                    style: AppTypography.bodyStyle.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.toUserName,
                      style: AppTypography.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceChart(PaymentSummary summary) {
    final balances = summary.balancesByParticipant.values.toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));

    final maxBalance = balances.isEmpty
        ? 100.0
        : balances.map((b) => b.balance.abs()).reduce((a, b) => a > b ? a : b);

    if (maxBalance == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución de Balances',
              style: AppTypography.titleStyle.copyWith(
                color: AppColorScheme.color4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...balances.map((balance) => _buildBalanceBar(balance, maxBalance)),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceBar(ParticipantBalance balance, double maxBalance) {
    final planCurrency = plan.currency; // T153
    final width = (balance.balance.abs() / maxBalance).clamp(0.0, 1.0);
    final isPositive = balance.balance >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                balance.userName,
                style: AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                CurrencyFormatterService.formatAmount(balance.balance, planCurrency),
                style: AppTypography.bodyStyle.copyWith(
                  color: _getBalanceColor(balance.balance),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade200,
            ),
            child: FractionallySizedBox(
              alignment: isPositive ? Alignment.centerLeft : Alignment.centerRight,
              widthFactor: width,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _getBalanceColor(balance.balance),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBalanceColor(double balance) {
    if (balance > 0) {
      return Colors.green; // Acreedor
    } else if (balance < 0) {
      return Colors.red; // Deudor
    } else {
      return Colors.grey; // Equilibrado
    }
  }

  IconData _getBalanceIcon(double balance) {
    if (balance > 0) {
      return Icons.trending_up; // Acreedor
    } else if (balance < 0) {
      return Icons.trending_down; // Deudor
    } else {
      return Icons.check_circle; // Equilibrado
    }
  }

  String _getBalanceStatusText(ParticipantBalance balance) {
    final planCurrency = plan.currency; // T153
    if (balance.isCreditor) {
      return 'Debe recibir ${CurrencyFormatterService.formatAmount(balance.toReceiveAmount, planCurrency)}';
    } else if (balance.isDebtor) {
      return 'Debe pagar ${CurrencyFormatterService.formatAmount(balance.pendingAmount, planCurrency)}';
    } else {
      return 'Balance equilibrado';
    }
  }
}

