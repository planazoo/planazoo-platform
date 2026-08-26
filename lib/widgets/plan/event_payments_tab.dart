import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/payments/domain/models/plan_expense.dart';
import 'package:unp_calendario/features/payments/presentation/providers/payment_providers.dart';
import 'package:unp_calendario/features/payments/presentation/widgets/add_expense_dialog.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Pestaña Pagos del formulario de evento: coste previsto + gastos Tricount ligados.
class EventPaymentsTab extends ConsumerWidget {
  const EventPaymentsTab({
    super.key,
    required this.plan,
    required this.eventId,
    this.budgetCost,
    required this.planCurrency,
    required this.isMobile,
  });

  final Plan? plan;
  final String? eventId;
  final double? budgetCost;
  final String planCurrency;
  final bool isMobile;

  static bool canManageExpense(
    Plan plan,
    PlanExpense expense,
    String? currentUserId,
  ) {
    if (currentUserId == null) return false;
    if (plan.userId == currentUserId) return true;
    if (expense.payerId == currentUserId) return true;
    if (expense.registeredBy != null && expense.registeredBy == currentUserId) {
      return true;
    }
    return false;
  }

  Future<void> _openExpenseDialog(
    BuildContext context,
    WidgetRef ref, {
    PlanExpense? existing,
  }) async {
    final p = plan;
    final eid = eventId;
    if (p?.id == null || eid == null || eid.isEmpty) return;

    final names = ref.read(planParticipantDisplayNamesProvider(p!.id!)).valueOrNull;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => AddExpenseDialog(
          plan: p,
          userIdToName: names,
          initialEventId: eid,
          existingExpense: existing,
          onSaved: () {
            ref.invalidate(paymentSummaryProvider(p.id!));
            ref.invalidate(planExpensesProvider(p.id!));
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PlanExpense expense,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final p = plan;
    if (p?.id == null || expense.id == null) return;

    final confirmed = await IosFormConfirmSheet.show(
      context: context,
      title: loc.paymentsExpenseDeleteConfirmTitle,
      message: loc.paymentsExpenseDeleteConfirmBody,
      cancelLabel: loc.cancel,
      confirmLabel: loc.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final ok =
        await ref.read(expenseServiceProvider).deleteExpense(expense.id!);
    if (!context.mounted) return;
    if (ok) {
      ref.invalidate(paymentSummaryProvider(p!.id!));
      ref.invalidate(planExpensesProvider(p.id!));
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final pad = isMobile ? 4.0 : 8.0;
    final gap = isMobile ? 12.0 : 16.0;
    final p = plan;
    final eid = eventId;
    final currentUserId = ref.watch(currentUserProvider)?.id;

    if (p?.id == null || eid == null || eid.isEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, isMobile ? 16 : 12),
        child: IosGroupedCard(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                loc.eventPaymentsSaveFirst,
                style: const TextStyle(
                  color: IosFormColors.textSecondary,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final expensesAsync = ref.watch(planExpensesProvider(p!.id!));
    final namesAsync = ref.watch(planParticipantDisplayNamesProvider(p.id!));

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, isMobile ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IosGroupedCard(
            children: [
              IosSettingsRow(
                label: loc.eventPaymentsBudgetLabel,
                value: budgetCost != null && budgetCost! > 0
                    ? CurrencyFormatterService.formatAmount(
                        budgetCost!,
                        planCurrency,
                      )
                    : '—',
              ),
            ],
          ),
          IosFormFooter(loc.eventPaymentsBudgetFooter),
          SizedBox(height: gap),
          IosSectionLabel(loc.eventPaymentsSectionExpenses),
          const SizedBox(height: 6),
          expensesAsync.when(
            data: (all) {
              final names = namesAsync.valueOrNull ?? {};
              final linked =
                  all.where((e) => e.eventId == eid).toList(growable: false);
              final total =
                  linked.fold<double>(0, (sum, e) => sum + e.amount);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (linked.isEmpty)
                    IosGroupedCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Text(
                            loc.eventPaymentsEmpty,
                            style: const TextStyle(
                              color: IosFormColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    IosGroupedCard(
                      children: [
                        for (var i = 0; i < linked.length; i++) ...[
                          if (i > 0) const IosRowSeparator(),
                          _LinkedExpenseRow(
                            expense: linked[i],
                            payerName: names[linked[i].payerId] ??
                                linked[i].payerId,
                            planCurrency: planCurrency,
                            canManage: canManageExpense(
                              p,
                              linked[i],
                              currentUserId,
                            ),
                            loc: loc,
                            onEdit: () => _openExpenseDialog(
                              context,
                              ref,
                              existing: linked[i],
                            ),
                            onDelete: () =>
                                _confirmDelete(context, ref, linked[i]),
                          ),
                        ],
                      ],
                    ),
                  if (linked.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    IosFormFooter(
                      loc.eventPaymentsRecordedTotal(
                        CurrencyFormatterService.formatAmount(
                          total,
                          planCurrency,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: gap),
                  IosGroupedCard(
                    children: [
                      IosSettingsRow(
                        label: loc.paymentsAddExpense,
                        value: '',
                        chevron: true,
                        onTap: () => _openExpenseDialog(context, ref),
                      ),
                    ],
                  ),
                  IosFormFooter(loc.paymentsExpenseFromEventPayerHint),
                ],
              );
            },
            loading: () => Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: IosFormColors.accent,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (_, __) => IosFormFooter(loc.paymentsExpenseSaveError),
          ),
        ],
      ),
    );
  }
}

class _LinkedExpenseRow extends StatelessWidget {
  const _LinkedExpenseRow({
    required this.expense,
    required this.payerName,
    required this.planCurrency,
    required this.canManage,
    required this.loc,
    required this.onEdit,
    required this.onDelete,
  });

  final PlanExpense expense;
  final String payerName;
  final String planCurrency;
  final bool canManage;
  final AppLocalizations loc;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final concept = expense.concept?.trim().isNotEmpty == true
        ? expense.concept!.trim()
        : loc.paymentsExpenseDefaultConcept;
    final dateStr = DateFormat('dd/MM/yyyy').format(expense.expenseDate);
    final meta = loc.paymentsExpenseRowMeta(dateStr, payerName);
    final amountStr = CurrencyFormatterService.formatAmount(
      expense.amount,
      planCurrency,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canManage ? onEdit : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concept,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: IosFormColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: IosFormColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                amountStr,
                style: const TextStyle(
                  color: IosFormColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (canManage)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: IosFormColors.textSecondary,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(loc.paymentsEditExpense),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(loc.delete),
                    ),
                  ],
                )
              else
                const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
