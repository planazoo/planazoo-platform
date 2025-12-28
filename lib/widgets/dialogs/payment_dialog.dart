import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/features/payments/domain/models/personal_payment.dart';
import 'package:unp_calendario/features/payments/presentation/providers/payment_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/shared/services/exchange_rate_service.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';

/// T102: Diálogo para registrar o editar un pago
class PaymentDialog extends ConsumerStatefulWidget {
  final String planId;
  final String? eventId; // Opcional: si el pago está asociado a un evento
  final PersonalPayment? payment; // Si se proporciona, es edición
  final Event? event; // Evento asociado (opcional)
  final Function()? onSaved;

  const PaymentDialog({
    super.key,
    required this.planId,
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
  String? _paymentCurrency; // T153: Moneda local del pago
  String? _planCurrency; // T153: Moneda del plan

  final List<String> _paymentMethods = [
    'Efectivo',
    'Transferencia',
    'Tarjeta',
    'Bizum',
    'PayPal',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    
    // Cargar moneda del plan (T153)
    _loadPlanCurrency();
    
    if (widget.payment != null) {
      // Modo edición
      _amountController = TextEditingController(
        text: widget.payment!.amount.toStringAsFixed(2),
      );
      _conceptController = TextEditingController(text: widget.payment!.concept ?? '');
      _descriptionController = TextEditingController(text: widget.payment!.description ?? '');
      _selectedParticipantId = widget.payment!.participantId;
      _selectedDate = widget.payment!.paymentDate;
      _selectedPaymentMethod = widget.payment!.paymentMethod;
      _selectedStatus = widget.payment!.status;
    } else {
      // Modo creación
      _amountController = TextEditingController();
      _conceptController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }
  
  /// Cargar moneda del plan (T153)
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

  /// T153: Construir campo de monto con selector de moneda
  Widget _buildAmountFieldWithCurrency() {
    final exchangeRateService = ExchangeRateService();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de moneda local
        DropdownButtonFormField<String>(
          value: _paymentCurrency ?? _planCurrency ?? 'EUR',
          decoration: InputDecoration(
            labelText: 'Moneda del pago',
            prefixIcon: Icon(_getCurrencyIcon(_paymentCurrency ?? _planCurrency ?? 'EUR')),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: Currency.supportedCurrencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency.code,
              child: Text('${currency.code} - ${currency.symbol} ${currency.name}'),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _paymentCurrency = value);
          },
        ),
        const SizedBox(height: 12),
        
        // Campo de monto
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: 'Monto *',
            prefixIcon: Icon(_getCurrencyIcon(_paymentCurrency ?? _planCurrency ?? 'EUR')),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa un monto';
            }
            final amount = double.tryParse(value.replaceAll(',', '.'));
            if (amount == null || amount <= 0) {
              return 'Monto inválido';
            }
            if (amount > 1000000) {
              return 'Monto muy alto (máximo 1.000.000)';
            }
            return null;
          },
        ),
        
        // Mostrar conversión si la moneda local es diferente a la del plan
        if (_paymentCurrency != null && 
            _planCurrency != null && 
            _paymentCurrency != _planCurrency &&
            _amountController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          FutureBuilder<double?>(
            future: exchangeRateService.convertAmount(
              double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0,
              _paymentCurrency!,
              _planCurrency!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Calculando...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }
              
              if (snapshot.hasData && snapshot.data != null) {
                final convertedAmount = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Convertido a ${_planCurrency}:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatterService.formatAmount(convertedAmount, _planCurrency!),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '⚠️ Los tipos de cambio son orientativos. El valor real será el aplicado por tu banco o tarjeta de crédito al momento del pago.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
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

  /// T153: Obtener icono según moneda
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

  /// T153: Obtener monto convertido a la moneda del plan
  Future<double?> _getConvertedAmount() async {
    if (_amountController.text.trim().isEmpty) return null;
    
    final localAmount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (localAmount == null) return null;
    
    if (_paymentCurrency == null || _planCurrency == null || _paymentCurrency == _planCurrency) {
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

    if (_selectedParticipantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un participante')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    final amount = await _getConvertedAmount();
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido')),
      );
      return;
    }

    final paymentService = ref.read(paymentServiceProvider);
    
    final payment = PersonalPayment(
      id: widget.payment?.id,
      planId: widget.planId,
      participantId: _selectedParticipantId!,
      eventId: widget.eventId ?? widget.event?.id,
      amount: amount, // T153: Ya convertido a moneda del plan
      paymentDate: _selectedDate,
      paymentMethod: _selectedPaymentMethod,
      concept: _conceptController.text.isEmpty ? null : _conceptController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
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
          content: Text(widget.payment == null ? 'Pago registrado' : 'Pago actualizado'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSaved?.call();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el pago'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final participationsAsync = ref.watch(
      planParticipantsProvider(widget.planId),
    );

    return AlertDialog(
      title: Text(
        widget.payment == null ? 'Registrar Pago' : 'Editar Pago',
        style: AppTypography.titleStyle,
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Evento asociado (si aplica)
                if (widget.event != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColorScheme.color1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColorScheme.color1.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, color: AppColorScheme.color1),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Evento asociado:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(widget.event!.description),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Participante
                Text(
                  'Participante *',
                  style: AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                participationsAsync.when(
                  data: (participations) {
                    final realParticipants = participations
                        .where((p) => p.role != 'observer')
                        .toList();

                    return DropdownButtonFormField<String>(
                      value: _selectedParticipantId,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      hint: const Text('Selecciona un participante'),
                      items: realParticipants.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.userId,
                          child: Text(p.userId), // TODO: Usar nombre real
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedParticipantId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un participante';
                        }
                        return null;
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
                const SizedBox(height: 16),

                // Monto con selector de moneda (T153)
                if (_planCurrency != null) ...[
                  _buildAmountFieldWithCurrency(),
                  const SizedBox(height: 16),
                ] else ...[
                  // Fallback mientras carga la moneda
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto *',
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un monto';
                      }
                      final amount = double.tryParse(value.replaceAll(',', '.'));
                      if (amount == null || amount <= 0) {
                        return 'Monto inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Fecha de pago
                Text(
                  'Fecha de pago *',
                  style: AppTypography.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: AppTypography.bodyStyle,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Método de pago
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: InputDecoration(
                    labelText: 'Método de pago',
                    prefixIcon: const Icon(Icons.payment),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  hint: const Text('Selecciona un método'),
                  items: _paymentMethods.map((method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Concepto
                TextFormField(
                  controller: _conceptController,
                  decoration: InputDecoration(
                    labelText: 'Concepto',
                    prefixIcon: const Icon(Icons.label),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: const Icon(Icons.description),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
                const SizedBox(height: 16),

                // Estado (solo si es edición o se quiere cambiar)
                if (widget.payment != null) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      prefixIcon: const Icon(Icons.info),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                      DropdownMenuItem(value: 'paid', child: Text('Pagado')),
                      DropdownMenuItem(value: 'refunded', child: Text('Reembolsado')),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _savePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorScheme.color2,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.payment == null ? 'Registrar' : 'Guardar'),
        ),
      ],
    );
  }
}


