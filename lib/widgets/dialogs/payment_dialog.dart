import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/payments/domain/models/personal_payment.dart';
import 'package:unp_calendario/features/payments/presentation/providers/payment_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/shared/services/exchange_rate_service.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Valores estables guardados en Firestore; etiquetas localizadas en UI.
const _paymentMethodIds = [
  'cash',
  'transfer',
  'card',
  'bizum',
  'paypal',
  'other'
];

const _legacyPaymentMethodToId = {
  'Efectivo': 'cash',
  'Transferencia': 'transfer',
  'Tarjeta': 'card',
  'Bizum': 'bizum',
  'PayPal': 'paypal',
  'Otro': 'other',
};

String? _normalizePaymentMethodFromStorage(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (_legacyPaymentMethodToId.containsKey(raw)) {
    return _legacyPaymentMethodToId[raw];
  }
  if (_paymentMethodIds.contains(raw)) return raw;
  return 'other';
}

String _paymentMethodLabel(AppLocalizations loc, String id) {
  switch (id) {
    case 'cash':
      return loc.paymentsMethodCash;
    case 'transfer':
      return loc.paymentsMethodTransfer;
    case 'card':
      return loc.paymentsMethodCard;
    case 'bizum':
      return loc.paymentsMethodBizum;
    case 'paypal':
      return loc.paymentsMethodPayPal;
    case 'other':
      return loc.paymentsMethodOther;
    default:
      return loc.paymentsMethodOther;
  }
}

/// T102: Pantalla a pantalla completa para registrar o editar un pago (misma línea que AddExpenseDialog).
class PaymentDialog extends ConsumerStatefulWidget {
  final String planId;
  final Plan? plan;
  final String? eventId;
  final PersonalPayment? payment;
  final Event? event;
  final Function()? onSaved;

  const PaymentDialog({
    super.key,
    required this.planId,
    this.plan,
    this.eventId,
    this.payment,
    this.event,
    this.onSaved,
  });

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _conceptController;
  late TextEditingController _descriptionController;

  String? _selectedParticipantId;
  DateTime _selectedDate = DateTime.now();
  String? _selectedPaymentMethod;
  String _selectedStatus = 'paid';
  String? _paymentCurrency;
  String? _planCurrency;
  Map<String, String> _resolvedNames = {};

  @override
  void initState() {
    super.initState();
    _loadPlanCurrency();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveNames());
    if (widget.payment != null) {
      _amountController = TextEditingController(
        text: widget.payment!.amount.toStringAsFixed(2),
      );
      _conceptController =
          TextEditingController(text: widget.payment!.concept ?? '');
      _descriptionController =
          TextEditingController(text: widget.payment!.description ?? '');
      _selectedParticipantId = widget.payment!.participantId;
      _selectedDate = widget.payment!.paymentDate;
      _selectedPaymentMethod =
          _normalizePaymentMethodFromStorage(widget.payment!.paymentMethod);
      _selectedStatus = widget.payment!.status;
    } else {
      _amountController = TextEditingController();
      _conceptController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  Future<void> _loadPlanCurrency() async {
    try {
      final planService = ref.read(planServiceProvider);
      final plan = await planService.getPlanById(widget.planId);
      if (plan != null && mounted) {
        setState(() {
          _planCurrency = plan.currency;
          _paymentCurrency ??= plan.currency;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _planCurrency = 'EUR';
          _paymentCurrency ??= 'EUR';
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _resolveNames() async {
    final participationsAsync =
        ref.read(planParticipantsProvider(widget.planId));
    participationsAsync.whenData((list) async {
      final userIds =
          list.where((p) => p.role != 'observer').map((p) => p.userId).toSet();
      final userService = ref.read(userServiceProvider);
      final map = <String, String>{};
      for (final uid in userIds) {
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
      if (mounted) setState(() => _resolvedNames = map);
    });
  }

  String _userName(String userId) => _resolvedNames[userId] ?? userId;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildAmountFieldWithCurrency(AppLocalizations loc) {
    final exchangeRateService = ExchangeRateService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _paymentCurrency ?? _planCurrency ?? 'EUR',
          decoration: InputDecoration(
            labelText: loc.paymentsPersonalPaymentCurrency,
            prefixIcon: Icon(
                _getCurrencyIcon(_paymentCurrency ?? _planCurrency ?? 'EUR')),
            border: const OutlineInputBorder(),
            filled: true,
          ),
          items: Currency.supportedCurrencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency.code,
              child: Text(
                  '${currency.code} - ${currency.symbol} ${currency.name}'),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _paymentCurrency = value);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: '${loc.paymentsExpenseAmount} *',
            prefixIcon: Icon(
                _getCurrencyIcon(_paymentCurrency ?? _planCurrency ?? 'EUR')),
            border: const OutlineInputBorder(),
            filled: true,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return loc.paymentsPersonalAmountValidationRequired;
            }
            final amount = double.tryParse(value.replaceAll(',', '.'));
            if (amount == null || amount <= 0) {
              return loc.paymentsPersonalAmountValidationInvalid;
            }
            if (amount > 1000000) {
              return loc.paymentsPersonalAmountValidationTooHigh;
            }
            return null;
          },
        ),
        if (_paymentCurrency != null &&
            _planCurrency != null &&
            _paymentCurrency != _planCurrency &&
            _amountController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          FutureBuilder<double?>(
            future: exchangeRateService.convertAmount(
              double.tryParse(_amountController.text.replaceAll(',', '.')) ??
                  0.0,
              _paymentCurrency!,
              _planCurrency!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text(loc.paymentsPersonalCalculating,
                          style: TextStyle(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                final convertedAmount = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            loc.paymentsPersonalConvertedTo(_planCurrency!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatterService.formatAmount(
                            convertedAmount, _planCurrency!),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.paymentsPersonalExchangeDisclaimer,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }

  IconData _getCurrencyIcon(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'EUR':
        return Icons.euro;
      case 'USD':
        return Icons.attach_money;
      case 'GBP':
        return Icons.currency_pound;
      case 'JPY':
        return Icons.currency_yen;
      default:
        return Icons.money;
    }
  }

  Future<double?> _getConvertedAmount() async {
    if (_amountController.text.trim().isEmpty) return null;

    final localAmount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (localAmount == null) return null;

    if (_paymentCurrency == null ||
        _planCurrency == null ||
        _paymentCurrency == _planCurrency) {
      return localAmount;
    }

    final exchangeRateService = ExchangeRateService();
    try {
      return await exchangeRateService.convertAmount(
        localAmount,
        _paymentCurrency!,
        _planCurrency!,
      );
    } catch (e) {
      return localAmount;
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackUserNotAuthenticated)),
      );
      return;
    }

    final isOrganizer =
        widget.plan == null || currentUser!.id == widget.plan!.userId;
    final participantId = isOrganizer ? _selectedParticipantId : currentUser.id;
    if (participantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackSelectParticipant)),
      );
      return;
    }

    final amount = await _getConvertedAmount();
    if (!mounted) return;
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackInvalidMonetaryAmount)),
      );
      return;
    }

    final paymentService = ref.read(paymentServiceProvider);

    final payment = PersonalPayment(
      id: widget.payment?.id,
      planId: widget.planId,
      participantId: participantId,
      eventId: widget.eventId ?? widget.event?.id,
      amount: amount,
      paymentDate: _selectedDate,
      paymentMethod: _selectedPaymentMethod,
      concept: _conceptController.text.isEmpty ? null : _conceptController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      status: _selectedStatus,
      registeredBy: currentUser!.id,
      createdAt: widget.payment?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await paymentService.savePayment(payment);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.payment == null
              ? loc.paymentsPersonalPaymentSaved
              : loc.paymentsPersonalPaymentUpdated),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSaved?.call();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.paymentsPersonalPaymentSaveError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final participationsAsync = ref.watch(
      planParticipantsProvider(widget.planId),
    );
    final currentUser = ref.watch(currentUserProvider);
    final isOrganizer =
        widget.plan == null || currentUser?.id == widget.plan!.userId;

    if (!isOrganizer &&
        currentUser?.id != null &&
        _selectedParticipantId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedParticipantId == null) {
          setState(() => _selectedParticipantId = currentUser!.id);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.payment == null
              ? loc.paymentsRegisterPayment
              : loc.paymentsEditPayment,
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
              if (widget.event != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: scheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${loc.paymentsPersonalEventLabel}:',
                              style: AppTypography.bodyStyle.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(widget.event!.description,
                                style: AppTypography.bodyStyle
                                    .copyWith(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                '${loc.paymentsExpensePayer} *',
                style: AppTypography.bodyStyle
                    .copyWith(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (!isOrganizer)
                InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  child: Text(loc.paymentsPersonalYouPaid,
                      style: AppTypography.bodyStyle),
                )
              else
                participationsAsync.when(
                  data: (participations) {
                    final realParticipants = participations
                        .where((p) => p.role != 'observer')
                        .toList();
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedParticipantId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      hint: Text(loc.kittySelectParticipantHint),
                      items: realParticipants
                          .map(
                            (p) => DropdownMenuItem<String>(
                              value: p.userId,
                              child: Text(_userName(p.userId),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedParticipantId = value),
                      validator: (value) =>
                          value == null ? loc.snackSelectWhoPaid : null,
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) =>
                      Text(loc.kittyLoadParticipantsError(error.toString())),
                ),
              const SizedBox(height: 16),
              if (_planCurrency != null) ...[
                _buildAmountFieldWithCurrency(loc),
                const SizedBox(height: 16),
              ] else ...[
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: '${loc.paymentsExpenseAmount} *',
                    prefixIcon: const Icon(Icons.money),
                    border: const OutlineInputBorder(),
                    filled: true,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.paymentsPersonalAmountValidationRequired;
                    }
                    final amount = double.tryParse(value.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) {
                      return loc.paymentsPersonalAmountValidationInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '${loc.paymentsExpenseDate} *',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                    filled: true,
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: AppTypography.bodyStyle,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: loc.paymentsPersonalMethod,
                  prefixIcon: const Icon(Icons.payment),
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
                hint: Text(loc.paymentsPersonalMethodHint),
                items: _paymentMethodIds
                    .map(
                      (id) => DropdownMenuItem<String>(
                        value: id,
                        child: Text(_paymentMethodLabel(loc, id)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conceptController,
                decoration: InputDecoration(
                  labelText: loc.paymentsExpenseConcept,
                  prefixIcon: const Icon(Icons.label),
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: loc.paymentsPersonalDescriptionOptional,
                  prefixIcon: const Icon(Icons.description),
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 16),
              if (widget.payment != null) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: loc.paymentsPersonalStatus,
                    prefixIcon: const Icon(Icons.info_outline),
                    border: const OutlineInputBorder(),
                    filled: true,
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'pending',
                        child: Text(loc.paymentsPersonalStatusPending)),
                    DropdownMenuItem(
                        value: 'paid',
                        child: Text(loc.paymentsPersonalStatusPaid)),
                    DropdownMenuItem(
                        value: 'refunded',
                        child: Text(loc.paymentsPersonalStatusRefunded)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
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
                  onPressed: _savePayment,
                  child: Text(widget.payment == null
                      ? loc.paymentsPersonalRegister
                      : loc.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
