import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import '../../domain/models/payment_summary.dart';
import '../../domain/models/plan_expense.dart';
import '../../domain/services/balance_service.dart';
import '../providers/payment_providers.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import '../widgets/add_expense_dialog.dart';
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

  static const Color _webPageBg = Color(0xFFF1F5F9);
  static const Color _webOnSurface = Color(0xFF0F172A);
  static const Color _webMuted = Color(0xFF64748B);
  static const Color _webBorder = Color(0xFFE2E8F0);

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
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 24,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: -4,
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    if (kIsWeb) {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _webBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
    return _darkCardDecoration();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(paymentSummaryProvider(plan.id!));
    final balanceService = ref.watch(balanceServiceProvider);

    return Theme(
      data: kIsWeb ? AppTheme.lightTheme : AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: kIsWeb ? _webPageBg : Colors.grey.shade900,
        appBar: AppBar(
          automaticallyImplyLeading: !embedInPlanDetail,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: kIsWeb
              ? const Border(bottom: BorderSide(color: _webBorder))
              : null,
          title: Text(
            loc.paymentsSummaryTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kIsWeb ? const Color(0xFF1F2937) : Colors.white,
            ),
          ),
          backgroundColor: kIsWeb ? _webPageBg : AppColorScheme.color2,
          foregroundColor: kIsWeb ? const Color(0xFF1F2937) : Colors.white,
          iconTheme: IconThemeData(
            color: kIsWeb ? const Color(0xFF1F2937) : Colors.white,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: loc.paymentsAddExpense,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (ctx) => AddExpenseDialog(
                      plan: plan,
                      onSaved: () =>
                          ref.invalidate(paymentSummaryProvider(plan.id!)),
                    ),
                  ),
                );
              },
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
                        color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
    if (kIsWeb) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.amber.shade800, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loc.paymentsDisclaimerText,
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
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSummary(BuildContext context, PaymentSummary summary) {
    final planCurrency = plan.currency; // T153
    final loc = AppLocalizations.of(context)!;
    final totalBalance = summary.totalPaid - summary.totalCost;
    final smallStyle = AppTypography.bodyStyle.copyWith(
      fontSize: 13,
      color: kIsWeb ? _webOnSurface : Colors.white,
    );

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.paymentsGeneralSummaryTitle,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 15,
              color: kIsWeb ? _webOnSurface : Colors.white,
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
                color: _getBalanceColor(totalBalance).withValues(alpha: 0.5),
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
        gradient: kIsWeb
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF8FAFC),
                  Colors.white,
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.2),
                ],
              ),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: style.copyWith(
              fontSize: 12,
              color: kIsWeb ? _webMuted : Colors.grey.shade300,
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
    final eventsAsync = ref.watch(planEventsStreamProvider(plan.id!));

    return expensesAsync.when(
      data: (expenses) {
        return eventsAsync.when(
          data: (planEvents) {
            final eventTitles = <String, String>{};
            for (final ev in planEvents) {
              final id = ev.id;
              if (id == null || id.isEmpty) continue;
              final t = ev.description.trim();
              eventTitles[id] =
                  t.isNotEmpty ? t : loc.paymentsExpenseEventFallbackTitle;
            }
            return _buildActivityExpenseCard(
              context,
              ref,
              summary,
              expenses,
              planCurrency,
              eventTitles,
              loc,
            );
          },
          loading: () => _buildActivityExpenseCard(
            context,
            ref,
            summary,
            expenses,
            planCurrency,
            const {},
            loc,
          ),
          error: (_, __) => _buildActivityExpenseCard(
            context,
            ref,
            summary,
            expenses,
            planCurrency,
            const {},
            loc,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildActivityExpenseCard(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary,
    List<PlanExpense> expenses,
    String planCurrency,
    Map<String, String> eventTitles,
    AppLocalizations loc,
  ) {
    final userIdToName = {
      for (final e in summary.balancesByParticipant.entries)
        e.key: e.value.userName
    };
    return Container(
      decoration: _cardDecoration(),
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
                  color: kIsWeb ? _webOnSurface : Colors.white,
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
                        onSaved: () =>
                            ref.invalidate(paymentSummaryProvider(plan.id!)),
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
                loc.paymentsActivityEmpty,
                style: AppTypography.bodyStyle.copyWith(
                  fontSize: 13,
                  color: kIsWeb ? _webMuted : Colors.grey.shade500,
                ),
              ),
            )
          else
            ...expenses.map((e) => _buildActivityExpenseRow(
                  context,
                  ref,
                  plan,
                  e,
                  summary,
                  planCurrency,
                  eventTitles,
                  loc,
                  userIdToName,
                )),
        ],
      ),
    );
  }

  Widget _buildActivityExpenseRow(
    BuildContext context,
    WidgetRef ref,
    Plan plan,
    PlanExpense expense,
    PaymentSummary summary,
    String planCurrency,
    Map<String, String> eventTitles,
    AppLocalizations loc,
    Map<String, String> userIdToName,
  ) {
    final payerName =
        summary.balancesByParticipant[expense.payerId]?.userName ?? expense.payerId;
    final currentUser = ref.watch(currentUserProvider);
    final canManage = _canManagePlanExpense(plan, expense, currentUser?.id);
    final dateStr = DateFormat('dd/MM/yyyy').format(expense.expenseDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.receipt, size: 20, color: kIsWeb ? _webMuted : Colors.grey.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.concept?.isNotEmpty == true
                      ? expense.concept!
                      : loc.paymentsExpenseDefaultConcept,
                  style: AppTypography.bodyStyle.copyWith(
                    fontSize: 13,
                    color: kIsWeb ? _webOnSurface : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  loc.paymentsExpenseRowMeta(dateStr, payerName),
                  style: AppTypography.bodyStyle.copyWith(
                    fontSize: 11,
                    color: kIsWeb ? _webMuted : Colors.grey.shade500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (expense.eventId != null &&
                    expense.eventId!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '· ${eventTitles[expense.eventId!] ?? loc.paymentsExpenseUnknownLinkedEvent}',
                    style: AppTypography.bodyStyle.copyWith(
                      fontSize: 11,
                      color: AppColorScheme.color3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
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
          if (expense.id != null && canManage) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: kIsWeb ? _webMuted : Colors.grey.shade400, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onSelected: (value) async {
                if (value == 'edit') {
                  if (!context.mounted) return;
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      fullscreenDialog: true,
                      builder: (ctx) => AddExpenseDialog(
                        plan: plan,
                        userIdToName: userIdToName,
                        existingExpense: expense,
                        onSaved: () =>
                            ref.invalidate(paymentSummaryProvider(plan.id!)),
                      ),
                    ),
                  );
                  return;
                }
                if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) {
                      final dialog = AlertDialog(
                        title: Text(loc.paymentsExpenseDeleteConfirmTitle),
                        content: Text(loc.paymentsExpenseDeleteConfirmBody),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(loc.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(
                              loc.delete,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      );
                      if (kIsWeb) {
                        return Theme(
                          data: AppTheme.lightTheme,
                          child: dialog,
                        );
                      }
                      return dialog;
                    },
                  );
                  if (confirmed != true || !context.mounted) return;
                  final ok = await ref
                      .read(expenseServiceProvider)
                      .deleteExpense(expense.id!);
                  if (!context.mounted) return;
                  if (ok) {
                    ref.invalidate(paymentSummaryProvider(plan.id!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.paymentsExpenseDeleted),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.paymentsExpenseDeleteError)),
                    );
                  }
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text(loc.paymentsEditExpense),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text(loc.delete),
                ),
              ],
            ),
          ],
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
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.paymentsBalancesSectionTitle,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 15,
              color: kIsWeb ? _webOnSurface : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.paymentsBalancesTricountHint,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 12,
              color: kIsWeb ? _webMuted : Colors.grey.shade500,
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
    final cardBg =
        kIsWeb ? const Color(0xFFF8FAFC) : Colors.black.withValues(alpha: 0.25);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cardBg,
        border: Border.all(
          color: balanceColor.withValues(alpha: 0.4),
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
                color: kIsWeb ? Colors.white : Colors.grey.shade900,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: balanceColor.withValues(alpha: 0.5),
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
            backgroundColor: kIsWeb
                ? const Color(0xFFF1F5F9)
                : Colors.black.withValues(alpha: 0.2),
            textColor: kIsWeb ? _webOnSurface : Colors.white,
            collapsedTextColor: kIsWeb ? _webOnSurface : Colors.white,
            iconColor: kIsWeb ? _webMuted : Colors.white,
            collapsedIconColor: kIsWeb ? _webMuted : Colors.white,
            leading: CircleAvatar(
              backgroundColor: balanceColor.withValues(alpha: 0.2),
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
                color: kIsWeb ? _webOnSurface : Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _getBalanceStatusText(context, balance),
              style: AppTypography.bodyStyle.copyWith(
                fontSize: 12,
                color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
                    Divider(color: kIsWeb ? _webBorder : Colors.grey.shade700),
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
                          color: kIsWeb ? _webOnSurface : Colors.white,
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
                                    style: AppTypography.bodyStyle.copyWith(
                                      fontSize: 12,
                                      color: kIsWeb ? _webOnSurface : Colors.white70,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(payment.paymentDate),
                                  style: AppTypography.bodyStyle.copyWith(
                                    fontSize: 11,
                                    color: kIsWeb ? _webMuted : Colors.grey.shade400,
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
              color: kIsWeb ? _webMuted : Colors.grey.shade300,
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
              color: color ?? (kIsWeb ? _webOnSurface : Colors.white),
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
      decoration: _cardDecoration(),
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
                  color: kIsWeb ? _webOnSurface : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.paymentsTransferSuggestionsSubtitle,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 12,
              color: kIsWeb ? _webMuted : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ...suggestions.map((suggestion) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kIsWeb
                      ? const Color(0xFFF8FAFC)
                      : Colors.black.withValues(alpha: 0.3),
                  border: Border.all(color: AppColorScheme.color2.withValues(alpha: 0.7)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        suggestion.fromUserName,
                        style: AppTypography.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kIsWeb ? _webOnSurface : Colors.white,
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
                          color: kIsWeb ? _webOnSurface : Colors.white,
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

  /// Organizador, quien pagó o quien registró el gasto pueden editar/eliminar.
  bool _canManagePlanExpense(Plan plan, PlanExpense expense, String? currentUserId) {
    if (currentUserId == null) return false;
    if (plan.userId == currentUserId) return true;
    if (expense.payerId == currentUserId) return true;
    if (expense.registeredBy != null && expense.registeredBy == currentUserId) return true;
    return false;
  }
}

