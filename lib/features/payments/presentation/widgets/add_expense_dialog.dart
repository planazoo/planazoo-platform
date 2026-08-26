import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import '../../domain/models/plan_expense.dart';
import '../providers/payment_providers.dart';

/// Diálogo para añadir un gasto tipo Tricount: quién pagó, importe, concepto, reparto.
class AddExpenseDialog extends ConsumerStatefulWidget {
  final Plan plan;
  final Map<String, String>? userIdToName;
  final VoidCallback? onSaved;
  final String? initialEventId;
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
  bool _isSaving = false;

  bool get _isEdit => widget.existingExpense != null;

  bool get _lockEventLink =>
      !_isEdit &&
      widget.initialEventId != null &&
      widget.initialEventId!.isNotEmpty;

  Currency get _currency => Currency.fromCodeOrEur(widget.plan.currency);

  @override
  void initState() {
    super.initState();
    final ed = widget.existingExpense;
    if (ed != null) {
      _amountController.text = ed.amount.toStringAsFixed(2);
      _conceptController.text = ed.concept ?? '';
      _selectedDate = ed.expenseDate;
      _selectedPayerId = ed.payerId;
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
    final participationsAsync =
        ref.read(planParticipantsProvider(widget.plan.id!));
    participationsAsync.whenData((list) async {
      final real = list.where((p) => p.role != 'observer').toList();
      final ids = real.map((p) => p.userId).toSet();
      await _resolveNames(ids);
      if (mounted && _selectedParticipantIds.isEmpty) {
        setState(() {
          _selectedParticipantIds.addAll(ids);
          _selectedPayerId ??= ids.isNotEmpty ? ids.first : null;
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

  void _onAmountChanged(String _) {
    if (_equalSplit && _selectedParticipantIds.isNotEmpty) {
      final amount =
          double.tryParse(_amountController.text.replaceAll(',', '.'));
      if (amount != null && amount > 0) {
        final per = amount / _selectedParticipantIds.length;
        for (final uid in _selectedParticipantIds) {
          _customAmountControllers[uid]?.text = per.toStringAsFixed(2);
        }
      }
    }
    setState(() {});
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

  Future<void> _openCalculator() async {
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => _CalculatorDialog(
        initialValue:
            double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0,
      ),
    );
    if (result != null && mounted) {
      _amountController.text = result.toStringAsFixed(2);
      _onAmountChanged(_amountController.text);
    }
  }

  String _userName(String userId) =>
      _resolvedNames[userId] ?? widget.userIdToName?[userId] ?? userId;

  Future<void> _pickPayer(List<String> participantIds) async {
    final loc = AppLocalizations.of(context)!;
    if (participantIds.isEmpty) return;
    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.paymentsExpensePayer,
      options: participantIds
          .map(
            (id) => IosFormPickerOption(
              value: id,
              title: _userName(id),
              selected: id == _selectedPayerId,
            ),
          )
          .toList(),
    );
    if (picked != null && mounted) setState(() => _selectedPayerId = picked);
  }

  Future<void> _pickEvent(Map<String, String> eventTitles) async {
    final loc = AppLocalizations.of(context)!;
    final options = <IosFormPickerOption<String?>>[
      IosFormPickerOption(
        value: null,
        title: loc.paymentsExpenseNoEventOption,
        selected: _selectedEventId == null || _selectedEventId!.isEmpty,
      ),
      ...eventTitles.entries.map(
        (e) => IosFormPickerOption(
          value: e.key,
          title: e.value,
          selected: e.key == _selectedEventId,
        ),
      ),
    ];
    if (_selectedEventId != null &&
        _selectedEventId!.isNotEmpty &&
        !eventTitles.containsKey(_selectedEventId)) {
      options.add(
        IosFormPickerOption(
          value: _selectedEventId,
          title: loc.paymentsExpenseUnknownLinkedEvent,
          selected: true,
        ),
      );
    }
    final picked = await IosFormPickerSheet.show<String?>(
      context: context,
      title: loc.paymentsExpenseLinkedEventLabel,
      options: options,
    );
    if (mounted) setState(() => _selectedEventId = picked);
  }

  String _eventDisplayValue(Map<String, String> eventTitles, AppLocalizations loc) {
    final id = _selectedEventId;
    if (id == null || id.isEmpty) return loc.paymentsExpenseNoEventOption;
    return eventTitles[id] ?? loc.paymentsExpenseUnknownLinkedEvent;
  }

  Future<void> _save() async {
    if (_isSaving) return;
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
              loc.snackExpenseSplitSumMismatch(
                sum.toStringAsFixed(2),
                amount.toStringAsFixed(2),
              ),
            ),
          ),
        );
        return;
      }
    }
    setState(() => _isSaving = true);
    final currentUser = ref.read(currentUserProvider);
    final linkedEventId =
        _selectedEventId != null && _selectedEventId!.isNotEmpty
            ? _selectedEventId
            : null;
    final existing = widget.existingExpense;
    final expense = PlanExpense(
      id: existing?.id,
      planId: widget.plan.id!,
      payerId: _selectedPayerId!,
      amount: amount,
      concept: _conceptController.text.isEmpty
          ? null
          : _conceptController.text.trim(),
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
    try {
      if (existing?.id != null) {
        final ok = await expenseService.updateExpense(expense);
        if (!mounted) return;
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.paymentsExpenseUpdated),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSaved?.call();
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.paymentsExpenseSaveError)),
          );
        }
      } else {
        final id = await expenseService.createExpense(expense);
        if (!mounted) return;
        if (id != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.paymentsExpenseSaved),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSaved?.call();
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.paymentsExpenseSaveError)),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final participationsAsync =
        ref.watch(planParticipantsProvider(widget.plan.id!));
    final eventsAsync = ref.watch(planEventsStreamProvider(widget.plan.id!));
    final pad = MediaQuery.sizeOf(context).width < 600 ? 12.0 : 16.0;
    final gap = 16.0;

    return Scaffold(
      backgroundColor: IosFormColors.pageBg,
      body: SafeArea(
        child: Material(
          color: IosFormColors.pageBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IosFormEditBar(
                editing: true,
                canEdit: true,
                saving: _isSaving,
                centeredTitle: true,
                modalIconActions: true,
                title: _isEdit ? loc.paymentsEditExpense : loc.paymentsAddExpenseTitle,
                editLabel: loc.edit,
                cancelLabel: loc.cancel,
                saveLabel: loc.save,
                onEdit: () {},
                onCancel: () => Navigator.of(context).pop(),
                onSave: _save,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(pad, pad, pad, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_lockEventLink) ...[
                          IosFormFooter(loc.paymentsExpenseFromEventPayerHint),
                          SizedBox(height: gap),
                        ],
                        participationsAsync.when(
                          data: (list) {
                            final real =
                                list.where((p) => p.role != 'observer').toList();
                            final participantIds =
                                real.map((p) => p.userId).toList();
                            return eventsAsync.when(
                              data: (eventList) {
                                final eventTitles = <String, String>{};
                                for (final e in eventList) {
                                  final id = e.id;
                                  if (id == null || id.isEmpty) continue;
                                  final raw = e.description.trim();
                                  eventTitles[id] = raw.isEmpty
                                      ? loc.paymentsExpenseEventFallbackTitle
                                      : raw;
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    IosGroupedCard(
                                      children: [
                                        IosSettingsRow(
                                          label: loc.paymentsExpensePayer,
                                          value: _selectedPayerId != null
                                              ? _userName(_selectedPayerId!)
                                              : '—',
                                          chevron: true,
                                          onTap: () =>
                                              _pickPayer(participantIds),
                                        ),
                                        const IosRowSeparator(),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: IosEditField(
                                                label:
                                                    '${loc.paymentsExpenseAmount} (${_currency.symbol})',
                                                controller: _amountController,
                                                keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                  decimal: true,
                                                ),
                                                onChanged: _onAmountChanged,
                                                validator: (v) {
                                                  if (v == null || v.isEmpty) {
                                                    return loc
                                                        .snackInvalidMonetaryAmount;
                                                  }
                                                  final n = double.tryParse(
                                                    v.replaceAll(',', '.'),
                                                  );
                                                  if (n == null || n <= 0) {
                                                    return loc
                                                        .snackInvalidMonetaryAmount;
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                                right: 4,
                                              ),
                                              child: IconButton(
                                                tooltip: loc.paymentsCalculator,
                                                onPressed: _openCalculator,
                                                icon: const Icon(
                                                  Icons.calculate_outlined,
                                                  color: IosFormColors
                                                      .textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const IosRowSeparator(),
                                        IosEditField(
                                          label: loc.paymentsExpenseConcept,
                                          controller: _conceptController,
                                        ),
                                        const IosRowSeparator(),
                                        IosSettingsRow(
                                          label: loc.paymentsExpenseDate,
                                          value: DateFormat('dd/MM/yyyy')
                                              .format(_selectedDate),
                                          chevron: true,
                                          onTap: _selectDate,
                                        ),
                                        if (!_lockEventLink) ...[
                                          const IosRowSeparator(),
                                          IosSettingsRow(
                                            label: loc
                                                .paymentsExpenseLinkedEventLabel,
                                            value: _eventDisplayValue(
                                              eventTitles,
                                              loc,
                                            ),
                                            chevron: true,
                                            onTap: () =>
                                                _pickEvent(eventTitles),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: gap),
                                    IosSectionLabel(
                                      loc.paymentsExpenseSplitBetween,
                                    ),
                                    const SizedBox(height: 6),
                                    IosGroupedCard(
                                      children: [
                                        IosSwitchRow(
                                          label: loc.paymentsExpenseSplitCustom,
                                          value: !_equalSplit,
                                          onChanged: (custom) {
                                            setState(() {
                                              _equalSplit = !custom;
                                              if (_equalSplit) {
                                                for (final c in _customAmountControllers
                                                    .values) {
                                                  c.dispose();
                                                }
                                                _customAmountControllers.clear();
                                              } else {
                                                final amount = double.tryParse(
                                                      _amountController.text
                                                          .replaceAll(',', '.'),
                                                    ) ??
                                                    0;
                                                final n = _selectedParticipantIds
                                                        .isEmpty
                                                    ? 1
                                                    : _selectedParticipantIds
                                                        .length;
                                                final per =
                                                    n > 0 ? amount / n : 0.0;
                                                _ensureCustomControllers(
                                                  _selectedParticipantIds
                                                      .toList(),
                                                  per,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                        if (!_equalSplit &&
                                            _selectedParticipantIds
                                                .isNotEmpty) ...[
                                          const IosRowSeparator(),
                                          ...() {
                                            final amount = double.tryParse(
                                                  _amountController.text
                                                      .replaceAll(',', '.'),
                                                ) ??
                                                0;
                                            final n =
                                                _selectedParticipantIds.length;
                                            final per =
                                                n > 0 ? amount / n : 0.0;
                                            _ensureCustomControllers(
                                              _selectedParticipantIds.toList(),
                                              per,
                                            );
                                            return _selectedParticipantIds
                                                .map((uid) {
                                              final controller =
                                                  _customAmountControllers[
                                                      uid]!;
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: IosFormColors
                                                          .nestPaddingLeft(1),
                                                    ),
                                                    child: IosEditField(
                                                      label: _userName(uid),
                                                      controller: controller,
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                      onChanged: (_) =>
                                                          setState(() {}),
                                                    ),
                                                  ),
                                                  if (uid !=
                                                      _selectedParticipantIds
                                                          .last)
                                                    IosRowSeparator(
                                                      nestLevel: 1,
                                                    ),
                                                ],
                                              );
                                            });
                                          }(),
                                        ],
                                        const IosRowSeparator(),
                                        for (var i = 0; i < real.length; i++) ...[
                                          if (i > 0) const IosRowSeparator(),
                                          IosCheckRow(
                                            label: _userName(real[i].userId),
                                            selected: _selectedParticipantIds
                                                .contains(real[i].userId),
                                            onTap: () {
                                              setState(() {
                                                final uid = real[i].userId;
                                                if (_selectedParticipantIds
                                                    .contains(uid)) {
                                                  _selectedParticipantIds
                                                      .remove(uid);
                                                  _customAmountControllers
                                                      .remove(uid)
                                                      ?.dispose();
                                                } else {
                                                  _selectedParticipantIds
                                                      .add(uid);
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (_equalSplit &&
                                        _selectedParticipantIds.isNotEmpty)
                                      Builder(
                                        builder: (context) {
                                          final amount = double.tryParse(
                                            _amountController.text
                                                .replaceAll(',', '.'),
                                          );
                                          if (amount == null || amount <= 0) {
                                            return const SizedBox.shrink();
                                          }
                                          final per = amount /
                                              _selectedParticipantIds.length;
                                          return IosFormFooter(
                                            '${loc.paymentsExpensePerPerson}: ${per.toStringAsFixed(2)} ${_currency.symbol}',
                                          );
                                        },
                                      ),
                                  ],
                                );
                              },
                              loading: () => Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: IosFormColors.accent,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              error: (_, __) => IosFormFooter(
                                loc.paymentsExpenseSaveError,
                              ),
                            );
                          },
                          loading: () => Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: IosFormColors.accent,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          error: (_, __) => IosFormFooter(
                            loc.paymentsExpenseSaveError,
                          ),
                        ),
                      ],
                    ),
                  ),
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
  const _CalculatorDialog({this.initialValue = 0});

  final double initialValue;

  @override
  State<_CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<_CalculatorDialog> {
  late String _display;

  @override
  void initState() {
    super.initState();
    _display = widget.initialValue > 0
        ? widget.initialValue.toStringAsFixed(2)
        : '0';
  }

  void _append(String s) {
    setState(() {
      if (s == '.' && _display.contains('.')) return;
      if (s == '0' && _display == '0') return;
      if (s != '.' && _display == '0') {
        _display = s;
      } else {
        _display += s;
      }
    });
  }

  void _clear() => setState(() => _display = '0');

  void _backspace() {
    setState(() {
      _display =
          _display.length <= 1 ? '0' : _display.substring(0, _display.length - 1);
    });
  }

  void _apply() {
    final v = double.tryParse(_display.replaceAll(',', '.'));
    if (v != null && v >= 0) Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: IosFormColors.groupedBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(
        loc.paymentsCalculator,
        style: const TextStyle(
          color: IosFormColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: IosFormColors.pageBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerRight,
              child: Text(
                _display,
                style: const TextStyle(
                  color: IosFormColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            loc.cancel,
            style: TextStyle(color: IosFormColors.accent),
          ),
        ),
        TextButton(
          onPressed: _apply,
          child: Text(
            loc.save,
            style: TextStyle(
              color: IosFormColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _calcButton(String label, VoidCallback onPressed,
      {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? 120 : 56,
      height: 48,
      child: Material(
        color: IosFormColors.pageBg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: IosFormColors.textPrimary,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
