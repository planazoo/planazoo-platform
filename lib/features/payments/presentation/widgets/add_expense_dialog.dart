import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import '../../domain/models/plan_expense.dart';
import '../providers/payment_providers.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Diálogo para añadir un gasto tipo Tricount: quién pagó, importe, concepto, reparto entre participantes.
class AddExpenseDialog extends ConsumerStatefulWidget {
  final Plan plan;
  /// Opcional: nombres por userId. Si no se pasa, el diálogo mostrará userId hasta que se resuelvan.
  final Map<String, String>? userIdToName;
  final VoidCallback? onSaved;
  /// Preselecciona el evento del plan (p. ej. desde el diálogo de evento — ítem 102).
  final String? initialEventId;
  /// Modo edición: mismo formulario, guardado con `updateExpense`.
  final PlanExpense? existingExpense;

  const AddExpenseDialog({
    super.key,
    required this.plan,
    this.userIdToName,
    this.onSaved,
    this.initialEventId,
    this.existingExpense,
  });

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedPayerId;
  final Set<String> _selectedParticipantIds = {};
  Map<String, String> _resolvedNames = {};
  bool _equalSplit = true;
  final Map<String, TextEditingController> _customAmountControllers = {};
  String? _selectedEventId;

  @override
  void initState() {
    super.initState();
    final ed = widget.existingExpense;
    if (ed != null) {
      _amountController.text = ed.amount.toStringAsFixed(2);
      _conceptController.text = ed.concept ?? '';
      _selectedDate = ed.expenseDate;
      _selectedPayerId = ed.payerId;
      _selectedParticipantIds.clear();
      _selectedParticipantIds.addAll(ed.participantIds);
      _equalSplit = ed.equalSplit;
      _selectedEventId = ed.eventId;
      if (widget.userIdToName != null && widget.userIdToName!.isNotEmpty) {
        _resolvedNames = Map.from(widget.userIdToName!);
      }
      if (!ed.equalSplit && ed.customShares != null) {
        for (final uid in ed.participantIds) {
          final v = ed.customShares![uid] ?? 0.0;
          _customAmountControllers[uid] =
              TextEditingController(text: v.toStringAsFixed(2));
        }
      }
    } else {
      _selectedEventId = widget.initialEventId;
      if (widget.userIdToName != null && widget.userIdToName!.isNotEmpty) {
        _resolvedNames = Map.from(widget.userIdToName!);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _initParticipants());
  }

  Future<void> _resolveNames(Set<String> userIds) async {
    if (userIds.isEmpty) return;
    final userService = ref.read(userServiceProvider);
    final map = <String, String>{};
    for (final uid in userIds) {
      if (_resolvedNames.containsKey(uid)) {
        map[uid] = _resolvedNames[uid]!;
        continue;
      }
      try {
        final user = await userService.getUser(uid);
        final name = (user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName
                : user?.email) ??
            uid;
        map[uid] = name;
      } catch (_) {
        map[uid] = uid;
      }
    }
    if (mounted) setState(() => _resolvedNames.addAll(map));
  }

  void _initParticipants() {
    final participationsAsync = ref.read(planParticipantsProvider(widget.plan.id!));
    participationsAsync.whenData((list) async {
      final real = list.where((p) => p.role != 'observer').toList();
      final ids = real.map((p) => p.userId).toSet();
      await _resolveNames(ids);
      if (mounted && _selectedParticipantIds.isEmpty) {
        setState(() {
          _selectedParticipantIds.addAll(ids);
          if (_selectedPayerId == null && ids.isNotEmpty) {
            _selectedPayerId = ids.first;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    for (final c in _customAmountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureCustomControllers(List<String> participantIds, double amountPerPerson) {
    final current = _customAmountControllers.keys.toSet();
    final needed = participantIds.toSet();
    for (final id in current.difference(needed)) {
      _customAmountControllers.remove(id)?.dispose();
    }
    for (final id in needed.difference(current)) {
      _customAmountControllers[id] = TextEditingController(
        text: amountPerPerson.toStringAsFixed(2),
      );
    }
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

  String _userName(String userId) =>
      _resolvedNames[userId] ?? widget.userIdToName?[userId] ?? userId;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackInvalidMonetaryAmount)),
      );
      return;
    }
    if (_selectedPayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackSelectWhoPaid)),
      );
      return;
    }
    if (_selectedParticipantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackSelectAtLeastOneForSplit)),
      );
      return;
    }
    Map<String, double>? customShares;
    if (!_equalSplit) {
      customShares = {};
      double sum = 0;
      for (final uid in _selectedParticipantIds) {
        final c = _customAmountControllers[uid];
        final v = double.tryParse(c?.text.replaceAll(',', '.') ?? '');
        if (v == null || v < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.snackCheckCustomSplitAmounts)),
          );
          return;
        }
        customShares[uid] = v;
        sum += v;
      }
      if ((sum - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.snackExpenseSplitSumMismatch(sum.toStringAsFixed(2), amount.toStringAsFixed(2)),
            ),
          ),
        );
        return;
      }
    }
    final currentUser = ref.read(currentUserProvider);
    final linkedEventId = _selectedEventId != null && _selectedEventId!.isNotEmpty
        ? _selectedEventId
        : null;
    final existing = widget.existingExpense;
    final expense = PlanExpense(
      id: existing?.id,
      planId: widget.plan.id!,
      payerId: _selectedPayerId!,
      amount: amount,
      concept: _conceptController.text.isEmpty ? null : _conceptController.text.trim(),
      expenseDate: _selectedDate,
      participantIds: _selectedParticipantIds.toList(),
      equalSplit: _equalSplit,
      customShares: customShares,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      registeredBy: existing?.registeredBy ?? currentUser?.id,
      eventId: linkedEventId,
    );
    final expenseService = ref.read(expenseServiceProvider);
    if (existing?.id != null) {
      final ok = await expenseService.updateExpense(expense);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.paymentsExpenseUpdated),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaved?.call();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.paymentsExpenseSaveError),
          ),
        );
      }
      return;
    }
    final id = await expenseService.createExpense(expense);
    if (!mounted) return;
    if (id != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.paymentsExpenseSaved),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSaved?.call();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.paymentsExpenseSaveError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final participationsAsync = ref.watch(planParticipantsProvider(widget.plan.id!));

    final isEdit = widget.existingExpense != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? loc.paymentsEditExpense : loc.paymentsAddExpense,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColorScheme.color2,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.initialEventId != null &&
                  widget.initialEventId!.isNotEmpty &&
                  widget.existingExpense == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColorScheme.color3.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColorScheme.color3.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColorScheme.color3, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.paymentsExpenseFromEventPayerHint,
                          style: AppTypography.bodyStyle.copyWith(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(loc.paymentsExpensePayer, style: AppTypography.bodyStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                participationsAsync.when(
                  data: (list) {
                    final real = list.where((p) => p.role != 'observer').toList();
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedPayerId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      hint: const Text('Selecciona'),
                      items: real
                          .map((p) => DropdownMenuItem<String>(
                                value: p.userId,
                                child: Text(
                                  _userName(p.userId),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPayerId = v),
                      validator: (v) => v == null ? 'Selecciona quién pagó' : null,
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: '${loc.paymentsExpenseAmount} *',
                          prefixIcon: const Icon(Icons.euro),
                          border: const OutlineInputBorder(),
                          filled: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) {
                          if (_equalSplit && _selectedParticipantIds.isNotEmpty) {
                            final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
                            if (amount != null && amount > 0) {
                              final per = amount / _selectedParticipantIds.length;
                              for (final uid in _selectedParticipantIds) {
                                _customAmountControllers[uid]?.text = per.toStringAsFixed(2);
                              }
                            }
                          }
                          setState(() {});
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) return '${loc.paymentsExpenseAmount} requerido';
                          final n = double.tryParse(v.replaceAll(',', '.'));
                          if (n == null || n <= 0) return 'Importe inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.calculate),
                      tooltip: loc.paymentsCalculator,
                      onPressed: () async {
                        final result = await showDialog<double>(
                          context: context,
                          builder: (ctx) => _CalculatorDialog(
                            initialValue: double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0,
                          ),
                        );
                        if (result != null && mounted) {
                          _amountController.text = result.toStringAsFixed(2);
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conceptController,
                  decoration: InputDecoration(
                    labelText: loc.paymentsExpenseConcept,
                    prefixIcon: const Icon(Icons.description),
                    border: const OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: loc.paymentsExpenseDate,
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                      filled: true,
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: AppTypography.bodyStyle),
                  ),
                ),
                const SizedBox(height: 16),
                ref.watch(planEventsStreamProvider(widget.plan.id!)).when(
                      data: (eventList) {
                        var withIds = eventList
                            .where((e) => e.id != null && e.id!.isNotEmpty)
                            .toList()
                          ..sort((a, b) => a.date.compareTo(b.date));
                        final seen = <String>{};
                        final items = <DropdownMenuItem<String?>>[
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(loc.paymentsExpenseNoEventOption),
                          ),
                        ];
                        for (final e in withIds) {
                          final id = e.id!;
                          if (seen.contains(id)) continue;
                          seen.add(id);
                          final raw = e.description.trim();
                          final label =
                              raw.isEmpty ? loc.paymentsExpenseEventFallbackTitle : raw;
                          final short = label.length > 48
                              ? '${label.substring(0, 48)}…'
                              : label;
                          items.add(
                            DropdownMenuItem<String?>(
                              value: id,
                              child:
                                  Text(short, overflow: TextOverflow.ellipsis),
                            ),
                          );
                        }
                        final sel = _selectedEventId;
                        if (sel != null &&
                            sel.isNotEmpty &&
                            !seen.contains(sel)) {
                          items.add(
                            DropdownMenuItem<String?>(
                              value: sel,
                              child: Text(
                                loc.paymentsExpenseUnknownLinkedEvent,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }
                        String? dropdownValue;
                        if (sel != null &&
                            sel.isNotEmpty &&
                            items.any((i) => i.value == sel)) {
                          dropdownValue = sel;
                        }
                        return DropdownButtonFormField<String?>(
                          initialValue: dropdownValue,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: loc.paymentsExpenseLinkedEventLabel,
                            prefixIcon: const Icon(Icons.event),
                            border: const OutlineInputBorder(),
                            filled: true,
                          ),
                          items: items,
                          onChanged: (v) =>
                              setState(() => _selectedEventId = v),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                const SizedBox(height: 16),
                Text(loc.paymentsExpenseSplitBetween, style: AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                participationsAsync.when(
                  data: (list) {
                    final real = list.where((p) => p.role != 'observer').toList();
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...real
                            .map((p) => CheckboxListTile(
                                  title: Text(_userName(p.userId), overflow: TextOverflow.ellipsis),
                                  value: _selectedParticipantIds.contains(p.userId),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        _selectedParticipantIds.add(p.userId);
                                      } else {
                                        _selectedParticipantIds.remove(p.userId);
                                        _customAmountControllers.remove(p.userId)?.dispose();
                                      }
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                )),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loc.paymentsExpenseSplitEqual,
                                style: AppTypography.bodyStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: !_equalSplit,
                              onChanged: (v) {
                                setState(() {
                                  _equalSplit = !v;
                                  if (_equalSplit) {
                                    for (final c in _customAmountControllers.values) {
                                      c.dispose();
                                    }
                                    _customAmountControllers.clear();
                                  } else {
                                    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
                                    final n = _selectedParticipantIds.isEmpty ? 1 : _selectedParticipantIds.length;
                                    final per = n > 0 ? amount / n : 0.0;
                                    _ensureCustomControllers(_selectedParticipantIds.toList(), per);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loc.paymentsExpenseSplitCustom,
                                style: AppTypography.bodyStyle,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (!_equalSplit && _selectedParticipantIds.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...() {
                            final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
                            final n = _selectedParticipantIds.length;
                            final per = n > 0 ? amount / n : 0.0;
                            _ensureCustomControllers(_selectedParticipantIds.toList(), per);
                            return _selectedParticipantIds.map((uid) {
                              final controller = _customAmountControllers[uid]!;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: Text(_userName(uid), overflow: TextOverflow.ellipsis, style: AppTypography.bodyStyle.copyWith(fontSize: 13)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          prefixText: '€ ',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                          }(),
                        ],
                        if (_equalSplit && _selectedParticipantIds.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
                              if (amount == null || amount <= 0) return const SizedBox.shrink();
                              final per = amount / _selectedParticipantIds.length;
                              return Text(
                                '${loc.paymentsExpensePerPerson}: ${per.toStringAsFixed(2)} €',
                                style: AppTypography.bodyStyle.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(loc.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  child: Text(loc.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Calculadora simple para obtener un importe y aplicarlo al campo de gasto.
class _CalculatorDialog extends StatefulWidget {
  final double initialValue;

  const _CalculatorDialog({this.initialValue = 0});

  @override
  State<_CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<_CalculatorDialog> {
  late String _display;
  double? _result;

  @override
  void initState() {
    super.initState();
    _display = widget.initialValue > 0 ? widget.initialValue.toStringAsFixed(2) : '0';
  }

  void _append(String s) {
    setState(() {
      if (_result != null) {
        _display = s;
        _result = null;
        return;
      }
      if (s == '.' && _display.contains('.')) return;
      if (s == '0' && _display == '0') return;
      if (s != '.' && _display == '0') {
        _display = s;
      } else {
        _display += s;
      }
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _result = null;
    });
  }

  void _backspace() {
    setState(() {
      if (_display.length <= 1) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
      _result = null;
    });
  }

  void _apply() {
    final v = double.tryParse(_display.replaceAll(',', '.'));
    if (v != null && v >= 0) {
      Navigator.of(context).pop(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.paymentsCalculator),
      content: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerRight,
              child: Text(
                _display,
                style: AppTypography.titleStyle.copyWith(fontSize: 24),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _calcButton('7', () => _append('7')),
                _calcButton('8', () => _append('8')),
                _calcButton('9', () => _append('9')),
                _calcButton('C', _clear),
                _calcButton('4', () => _append('4')),
                _calcButton('5', () => _append('5')),
                _calcButton('6', () => _append('6')),
                _calcButton('⌫', _backspace),
                _calcButton('1', () => _append('1')),
                _calcButton('2', () => _append('2')),
                _calcButton('3', () => _append('3')),
                const SizedBox(width: 56, height: 48),
                _calcButton('0', () => _append('0')),
                _calcButton('.', () => _append('.')),
                _calcButton('=', _apply, fullWidth: true),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _apply, child: const Text('Aplicar')),
      ],
    );
  }

  Widget _calcButton(String label, VoidCallback onPressed, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? 120 : 56,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
