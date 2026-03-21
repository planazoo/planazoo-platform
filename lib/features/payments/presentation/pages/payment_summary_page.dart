import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import '../../domain/models/payment_summary.dart';
import '../../domain/models/plan_expense.dart';
import '../../domain/services/balance_service.dart';
import '../providers/payment_providers.dart';
import '../../../../widgets/dialogs/payment_dialog.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import '../widgets/kitty_contribution_dialog.dart';
import '../widgets/kitty_expense_dialog.dart';
import '../widgets/add_expense_dialog.dart';
import '../../domain/models/kitty_contribution.dart';
import '../../domain/models/kitty_expense.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// T102: Página de resumen de pagos y balances del plan
class PaymentSummaryPage extends ConsumerWidget {
  final Plan plan;
  /// En [PlanDetailPage] evita la flecha del AppBar que hace pop de todo el detalle (P16).
  final bool embedInPlanDetail;

  const PaymentSummaryPage({
    super.key,
    required this.plan,
    this.embedInPlanDetail = false,
  });

  BoxDecoration _darkCardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF424242),
          Color(0xFF2C2C2C),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.grey.shade700,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 24,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: -4,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(paymentSummaryProvider(plan.id!));
    final balanceService = ref.watch(balanceServiceProvider);

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          automaticallyImplyLeading: !embedInPlanDetail,
          title: Text(
            loc.paymentsSummaryTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColorScheme.color2,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.add),
              tooltip: 'Añadir',
              onSelected: (value) {
                if (value == 'expense') {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      fullscreenDialog: true,
                      builder: (ctx) => AddExpenseDialog(
                        plan: plan,
                        onSaved: () => ref.invalidate(paymentSummaryProvider(plan.id!)),
                      ),
                    ),
                  );
                } else if (value == 'payment') {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      fullscreenDialog: true,
                      builder: (ctx) => PaymentDialog(
                        planId: plan.id!,
                        plan: plan,
                        onSaved: () => ref.invalidate(paymentSummaryProvider(plan.id!)),
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'expense',
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, size: 22),
                      const SizedBox(width: 12),
                      Flexible(child: Text(loc.paymentsAddExpense, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'payment',
                  child: Row(
                    children: [
                      const Icon(Icons.payment, size: 22),
                      const SizedBox(width: 12),
                      Flexible(child: Text(loc.paymentsRegisterPayment, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: summaryAsync.when(
            data: (summary) {
              final transferSuggestions = balanceService.calculateTransferSuggestions(summary);
              return _buildSummaryContent(context, ref, summary, transferSuggestions);
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColorScheme.color2),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      loc.paymentsSummaryError,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
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
          _buildGeneralSummary(context, summary),
          const SizedBox(height: 24),

          // T219: Bote común
          _buildKittySection(context, ref, summary),
          const SizedBox(height: 24),

          // Actividad (gastos tipo Tricount)
          _buildActivitySection(context, ref, summary),
          const SizedBox(height: 24),

          // Balances por participante
          _buildBalancesSection(context, ref, summary),
          const SizedBox(height: 24),

          // Sugerencias de transferencias
          if (transferSuggestions.isNotEmpty) ...[
            _buildTransferSuggestionsSection(context, transferSuggestions),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  /// T220: Aviso breve de que la app no procesa cobros (solo anotación y cuadre).
  Widget _buildPaymentDisclaimer(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF424242),
            Color(0xFF2C2C2C),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColorScheme.color3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColorScheme.color3, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.paymentsDisclaimerText,
              style: AppTypography.bodyStyle.copyWith(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// T219: Sección Bote común (aportaciones, gastos, saldo)
  Widget _buildKittySection(BuildContext context, WidgetRef ref, PaymentSummary summary) {
    final loc = AppLocalizations.of(context)!;
    final planCurrency = plan.currency;
    final userIdToName = { for (final e in summary.balancesByParticipant.entries) e.key: e.value.userName };
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

            return Container(
              decoration: _darkCardDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.paymentsKittyTitle,
                    style: AppTypography.bodyStyle.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(loc.paymentsKittyAddContribution),
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
                          label: Text(loc.paymentsKittyAddExpense),
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
                      const Spacer(),
                      Text(
                        '${loc.paymentsKittyBalanceLabel}: ${CurrencyFormatterService.formatAmount(kittyBalance, planCurrency)}',
                        style: AppTypography.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kittyBalance >= 0 ? Colors.green : Colors.red,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  if (contributions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                        loc.paymentsKittyContributionsTitle,
                      style: AppTypography.bodyStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...contributions.take(10).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${userIdToName[c.participantId] ?? c.participantId}: ${c.concept ?? "Aporte"}',
                                style: AppTypography.bodyStyle.copyWith(fontSize: 12, color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${CurrencyFormatterService.formatAmount(c.amount, planCurrency)} · ${DateFormat('dd/MM/yyyy').format(c.contributionDate)}',
                                style: AppTypography.bodyStyle.copyWith(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (contributions.length > 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                            loc.paymentsKittyMoreItems(contributions.length - 10),
                          style: AppTypography.bodyStyle.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                  ],
                  if (expenses.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                        loc.paymentsKittyExpensesTitle,
                      style: AppTypography.bodyStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...expenses.take(10).map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.concept,
                                style: AppTypography.bodyStyle.copyWith(fontSize: 12, color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '-${CurrencyFormatterService.formatAmount(e.amount, planCurrency)} · ${DateFormat('dd/MM/yyyy').format(e.expenseDate)}',
                                style: AppTypography.bodyStyle.copyWith(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (expenses.length > 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                            loc.paymentsKittyMoreItems(expenses.length - 10),
                          style: AppTypography.bodyStyle.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
          loading: () => Container(
            decoration: _darkCardDecoration(),
            padding: const EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(color: AppColorScheme.color2)),
          ),
          error: (e, _) => Container(
            decoration: _darkCardDecoration(),
            padding: const EdgeInsets.all(20),
            child: Text(
              loc.paymentsKittyExpensesLoadError(e.toString()),
              style: AppTypography.bodyStyle.copyWith(color: Colors.white),
            ),
          ),
        );
      },
      loading: () => Container(
        decoration: _darkCardDecoration(),
        padding: const EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: AppColorScheme.color2)),
      ),
      error: (e, _) => Container(
        decoration: _darkCardDecoration(),
        padding: const EdgeInsets.all(20),
        child: Text(
          loc.paymentsKittyLoadError(e.toString()),
          style: AppTypography.bodyStyle.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGeneralSummary(BuildContext context, PaymentSummary summary) {
    final planCurrency = plan.currency; // T153
    final loc = AppLocalizations.of(context)!;
    final totalBalance = summary.totalPaid - summary.totalCost;
    final smallStyle = AppTypography.bodyStyle.copyWith(
      fontSize: 13,
      color: Colors.white,
    );

    return Container(
      decoration: _darkCardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.paymentsGeneralSummaryTitle,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  loc.paymentsGeneralSummaryTotalCost,
                  CurrencyFormatterService.formatAmount(summary.totalCost, planCurrency),
                  AppColorScheme.color2,
                  smallStyle: smallStyle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  loc.paymentsGeneralSummaryTotalPaid,
                  CurrencyFormatterService.formatAmount(summary.totalPaid, planCurrency),
                  Colors.green,
                  smallStyle: smallStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBalanceColor(totalBalance).withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getBalanceIcon(totalBalance),
                  color: _getBalanceColor(totalBalance),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.paymentsGeneralSummaryBalanceTitle,
                        style: smallStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        CurrencyFormatterService.formatAmount(totalBalance, planCurrency),
                        style: smallStyle.copyWith(
                          color: _getBalanceColor(totalBalance),
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
    );
  }

  Widget _buildStatCard(String label, String value, Color color, {TextStyle? smallStyle}) {
    final style = smallStyle ?? AppTypography.bodyStyle;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.2),
          ],
        ),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: style.copyWith(
              fontSize: 12,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: style.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary,
  ) {
    final loc = AppLocalizations.of(context)!;
    final planCurrency = plan.currency;
    final expensesAsync = ref.watch(planExpensesProvider(plan.id!));
    return expensesAsync.when(
      data: (expenses) {
        final userIdToName = {for (final e in summary.balancesByParticipant.entries) e.key: e.value.userName};
        return Container(
          decoration: _darkCardDecoration(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.paymentsActivityTitle,
                    style: AppTypography.bodyStyle.copyWith(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(loc.paymentsAddExpense),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          fullscreenDialog: true,
                          builder: (ctx) => AddExpenseDialog(
                            plan: plan,
                            userIdToName: userIdToName,
                            onSaved: () => ref.invalidate(paymentSummaryProvider(plan.id!)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (expenses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Sin gastos. Añade el primero arriba.',
                    style: AppTypography.bodyStyle.copyWith(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                )
              else
                ...expenses.map((e) => _buildActivityExpenseRow(context, e, summary, planCurrency)),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildActivityExpenseRow(
    BuildContext context,
    PlanExpense expense,
    PaymentSummary summary,
    String planCurrency,
  ) {
    final payerName = summary.balancesByParticipant[expense.payerId]?.userName ?? expense.payerId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.receipt, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.concept?.isNotEmpty == true ? expense.concept! : 'Gasto',
                  style: AppTypography.bodyStyle.copyWith(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(expense.expenseDate)} · $payerName pagó',
                  style: AppTypography.bodyStyle.copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatterService.formatAmount(expense.amount, planCurrency),
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            overflow: TextOverflow.ellipsis,
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
    final loc = AppLocalizations.of(context)!;
    final balances = summary.balancesByParticipant.values.toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));

    return Container(
      decoration: _darkCardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.paymentsBalancesSectionTitle,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...balances.map((balance) => _buildParticipantBalanceCard(context, ref, balance)),
        ],
      ),
    );
  }

  Widget _buildParticipantBalanceCard(
    BuildContext context,
    WidgetRef ref,
    ParticipantBalance balance,
  ) {
    final loc = AppLocalizations.of(context)!;
    final planCurrency = plan.currency; // T153
    final balanceColor = _getBalanceColor(balance.balance);
    final amountText = CurrencyFormatterService.formatAmount(balance.balance, planCurrency);
    final cardBg = Colors.black.withOpacity(0.25);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cardBg,
        border: Border.all(
          color: balanceColor.withOpacity(0.4),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Label del importe en el borde superior (estilo campo UI estándar)
          Positioned(
            top: -10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: balanceColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                amountText,
                style: AppTypography.bodyStyle.copyWith(
                  fontSize: 12,
                  color: balanceColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ExpansionTile(
            collapsedBackgroundColor: Colors.transparent,
            backgroundColor: Colors.black.withOpacity(0.2),
            textColor: Colors.white,
            collapsedTextColor: Colors.white,
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            leading: CircleAvatar(
              backgroundColor: balanceColor.withOpacity(0.2),
              child: Icon(
                _getBalanceIcon(balance.balance),
                color: balanceColor,
              ),
            ),
            title: Text(
              balance.userName,
              style: AppTypography.bodyStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _getBalanceStatusText(context, balance),
              style: AppTypography.bodyStyle.copyWith(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const SizedBox.shrink(),
            children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceDetailRow(
                  loc.paymentsBalanceAssignedCost,
                  CurrencyFormatterService.formatAmount(balance.totalCost, planCurrency),
                ),
                const SizedBox(height: 8),
                _buildBalanceDetailRow(
                  loc.paymentsBalanceTotalPaid,
                  CurrencyFormatterService.formatAmount(balance.totalPaid, planCurrency),
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade700),
                const SizedBox(height: 8),
                _buildBalanceDetailRow(
                  loc.paymentsGeneralSummaryBalanceTitle,
                  CurrencyFormatterService.formatAmount(balance.balance, planCurrency),
                  isBold: true,
                  color: _getBalanceColor(balance.balance),
                ),
                if (balance.payments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    loc.paymentsBalancePaymentsTitle,
                    style: AppTypography.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                            style: AppTypography.bodyStyle.copyWith(fontSize: 12, color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(payment.paymentDate),
                          style: AppTypography.bodyStyle.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade400,
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
        ],
      ),
    );
  }

  Widget _buildBalanceDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTypography.bodyStyle.copyWith(
              color: Colors.grey.shade300,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyStyle.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildTransferSuggestionsSection(BuildContext context, List<TransferSuggestion> suggestions) {
    final planCurrency = plan.currency; // T153
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: _darkCardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz, color: AppColorScheme.color2),
              const SizedBox(width: 8),
              Text(
                loc.paymentsTransferSuggestionsTitle,
                style: AppTypography.titleStyle.copyWith(
                  color: Colors.white,
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
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(color: AppColorScheme.color2.withOpacity(0.7)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        suggestion.fromUserName,
                        style: AppTypography.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 18, color: AppColorScheme.color2),
                    const SizedBox(width: 6),
                    Text(
                      CurrencyFormatterService.formatAmount(suggestion.amount, planCurrency),
                      style: AppTypography.bodyStyle.copyWith(
                        color: AppColorScheme.color2,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 18, color: AppColorScheme.color2),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        suggestion.toUserName,
                        style: AppTypography.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
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

  String _getBalanceStatusText(BuildContext context, ParticipantBalance balance) {
    final planCurrency = plan.currency; // T153
    final loc = AppLocalizations.of(context)!;
    if (balance.isCreditor) {
      return loc.paymentsBalanceStatusCreditor(
        CurrencyFormatterService.formatAmount(balance.toReceiveAmount, planCurrency),
      );
    } else if (balance.isDebtor) {
      return loc.paymentsBalanceStatusDebtor(
        CurrencyFormatterService.formatAmount(balance.pendingAmount, planCurrency),
      );
    } else {
      return loc.paymentsBalanceStatusSettled;
    }
  }
}

