import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/models/kitty_expense.dart';
import '../providers/payment_providers.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// T219: Diálogo para registrar un gasto del bote común (solo organizador)
class KittyExpenseDialog extends ConsumerWidget {
  final Plan plan;
  final VoidCallback? onSaved;

  const KittyExpenseDialog({
    super.key,
    required this.plan,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser?.id != plan.userId) {
      return AlertDialog(
        title: Text(loc.kittyExpenseNotAllowedTitle, style: AppTypography.titleStyle),
        content: Text(loc.kittyExpenseOrganizerOnlyBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.close),
          ),
        ],
      );
    }
    return _KittyExpenseForm(plan: plan, onSaved: onSaved);
  }
}

class _KittyExpenseForm extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onSaved;

  const _KittyExpenseForm({required this.plan, this.onSaved});

  @override
  ConsumerState<_KittyExpenseForm> createState() => _KittyExpenseFormState();
}

class _KittyExpenseFormState extends ConsumerState<_KittyExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackInvalidMonetaryAmount)),
      );
      return;
    }
    final concept = _conceptController.text.trim();
    if (concept.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackExpenseConceptRequired)),
      );
      return;
    }
    final expense = KittyExpense(
      planId: widget.plan.id!,
      amount: amount,
      expenseDate: _selectedDate,
      concept: concept,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final kittyService = ref.read(kittyServiceProvider);
    final id = await kittyService.createExpense(expense);
    if (!mounted) return;
    if (id != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackExpenseRegistered), backgroundColor: Colors.green),
      );
      widget.onSaved?.call();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackSaveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.kittyRegisterExpenseTitle, style: AppTypography.titleStyle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _conceptController,
                  decoration: InputDecoration(
                    labelText: loc.kittyExpenseConceptLabel,
                    prefixIcon: const Icon(Icons.description),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? loc.snackExpenseConceptRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: loc.kittyAmountLabel,
                    prefixIcon: const Icon(Icons.money),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return loc.kittyValidationEnterAmount;
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n == null || n <= 0) return loc.snackInvalidMonetaryAmount;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: loc.kittyDateLabel,
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: AppTypography.bodyStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(loc.cancel)),
        FilledButton(onPressed: _save, child: Text(loc.save)),
      ],
    );
  }
}
