import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/models/kitty_expense.dart';
import '../providers/payment_providers.dart';
import 'package:unp_calendario/app/theme/typography.dart';

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
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser?.id != plan.userId) {
      return AlertDialog(
        title: Text('No permitido', style: AppTypography.titleStyle),
        content: const Text('Solo el organizador del plan puede registrar gastos del bote.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
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
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido')),
      );
      return;
    }
    final concept = _conceptController.text.trim();
    if (concept.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica el concepto del gasto')),
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
        const SnackBar(content: Text('Gasto registrado'), backgroundColor: Colors.green),
      );
      widget.onSaved?.call();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Registrar gasto del bote', style: AppTypography.titleStyle),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _conceptController,
                  decoration: const InputDecoration(
                    labelText: 'Concepto *',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Indica el concepto' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto *',
                    prefixIcon: Icon(Icons.money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa un monto';
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n == null || n <= 0) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha *',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
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
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
