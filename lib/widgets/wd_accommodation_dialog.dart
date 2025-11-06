import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';
import 'package:unp_calendario/features/security/utils/sanitizer.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/shared/services/exchange_rate_service.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

class AccommodationDialog extends ConsumerStatefulWidget {
  final Accommodation? accommodation;
  final String planId;
  final DateTime planStartDate;
  final DateTime? planEndDate;
  final DateTime? initialCheckIn;
  final Function(Accommodation)? onSaved;
  final Function(String)? onDeleted;

  const AccommodationDialog({
    super.key,
    this.accommodation,
    required this.planId,
    required this.planStartDate,
    this.planEndDate,
    this.initialCheckIn,
    this.onSaved,
    this.onDeleted,
  });

  @override
  ConsumerState<AccommodationDialog> createState() => _AccommodationDialogState();
}

class _AccommodationDialogState extends ConsumerState<AccommodationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hotelNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController; // T101/T153
  String? _costCurrency; // T153: Moneda local del coste
  String? _planCurrency; // T153: Moneda del plan
  bool _costConverting = false; // T153: Flag para evitar loops
  Plan? _plan; // T109: Plan para verificar estado
  late DateTime _selectedCheckIn;
  late DateTime _selectedCheckOut;
  late String _selectedColor;
  late List<String> _selectedParticipantTrackIds;

  // Colores predefinidos para alojamientos
  final List<String> _accommodationColors = [
    'blue',
    'green',
    'purple',
    'orange',
    'red',
    'yellow',
    'pink',
    'brown',
  ];

  // Tipos de alojamiento
  final List<String> _accommodationTypes = [
    'Hotel',
    'Apartamento',
    'Hostal',
    'Casa',
    'Resort',
    'Camping',
    'Otro',
  ];

  late String _selectedType;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores
    _hotelNameController = TextEditingController(
      text: widget.accommodation?.hotelName ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.accommodation?.description ?? '',
    );
    _costController = TextEditingController(
      text: widget.accommodation?.cost?.toString() ?? '',
    );
    
    // Inicializar fechas
    _selectedCheckIn = widget.initialCheckIn ?? widget.accommodation?.checkIn ?? widget.planStartDate;
    _selectedCheckOut = widget.accommodation?.checkOut ?? _selectedCheckIn.add(const Duration(days: 1));
    _selectedColor = widget.accommodation?.color ?? 'blue';
    
    // Normalizar tipo de alojamiento (capitalizar primera letra)
    final typeFromDB = widget.accommodation?.typeSubtype ?? '';
    _selectedType = _normalizeType(typeFromDB);
    
    // Inicializar participantes seleccionados
    _selectedParticipantTrackIds = widget.accommodation?.participantTrackIds ?? [];
    
    // Cargar moneda del plan (T153)
    _loadPlanCurrency();
  }
  
  /// Cargar moneda del plan (T153) y plan completo (T109)
  Future<void> _loadPlanCurrency() async {
    try {
      final planService = ref.read(planServiceProvider);
      final plan = await planService.getPlanById(widget.planId);
      if (plan != null && mounted) {
        setState(() {
          _planCurrency = plan.currency;
          _costCurrency ??= plan.currency;
          _plan = plan; // T109: Guardar plan para verificar estado
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _planCurrency = 'EUR';
          _costCurrency ??= 'EUR';
        });
      }
    }
  }
  
  /// T109: Verifica si se puede guardar/crear el alojamiento según el estado del plan
  bool _canSaveAccommodation() {
    if (_plan == null) return true; // Si no hay plan cargado, permitir por defecto
    
    if (widget.accommodation == null) {
      // Crear alojamiento nuevo
      return PlanStatePermissions.canAddEvents(_plan!);
    } else {
      // Modificar alojamiento existente
      return PlanStatePermissions.canModifyEvents(_plan!);
    }
  }
  
  /// T109: Verifica si se puede eliminar el alojamiento según el estado del plan
  bool _canDeleteAccommodation() {
    if (_plan == null) return true; // Si no hay plan cargado, permitir por defecto
    return PlanStatePermissions.canDeleteEvents(_plan!);
  }
  
  /// Normaliza el tipo de alojamiento a formato capitalizado
  String _normalizeType(String type) {
    if (type.isEmpty) return 'Hotel';
    
    // Si el tipo está en la lista de tipos disponibles, devolverlo tal cual
    if (_accommodationTypes.contains(type)) {
      return type;
    }
    
    // Capitalizar la primera letra
    if (type.isNotEmpty) {
      return type[0].toUpperCase() + type.substring(1).toLowerCase();
    }
    
    return 'Hotel';
  }

  @override
  void dispose() {
    _hotelNameController.dispose();
    _descriptionController.dispose();
    _costController.dispose(); // T101
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.accommodation == null ? 'Nuevo Alojamiento' : 'Editar Alojamiento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Nombre del hotel/alojamiento
              TextFormField(
                controller: _hotelNameController,
                decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.accommodationName,
                hintText: AppLocalizations.of(context)!.accommodationNameHint,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.hotel),
              ),
              maxLines: 1,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return AppLocalizations.of(context)!.accommodationNameRequired;
                if (v.length < 2) return AppLocalizations.of(context)!.minCharacters(2);
                if (v.length > 100) return AppLocalizations.of(context)!.maxCharacters(100);
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Tipo de alojamiento
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.accommodationType,
                  border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _accommodationTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value ?? 'Hotel';
                });
              },
                validator: (value) {
                // Validar que el valor esté en la lista
                if (value == null || !_accommodationTypes.contains(value)) {
                  return AppLocalizations.of(context)!.invalidAccommodationType;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Descripción
              TextFormField(
                controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.descriptionOptional,
                hintText: AppLocalizations.of(context)!.additionalNotes,
                  border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 3,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return null;
                if (v.length > 1000) return AppLocalizations.of(context)!.maxCharacters(1000);
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Coste del alojamiento (T101/T153)
            if (_planCurrency != null) _buildCostFieldWithCurrency(),
              const SizedBox(height: 16),
              
            // Check-in
              ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.login),
                title: const Text('Check-in'),
              subtitle: Text('${_selectedCheckIn.day}/${_selectedCheckIn.month}/${_selectedCheckIn.year}'),
              onTap: _selectCheckInDate,
            ),
            
            // Check-out
              ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout),
                title: const Text('Check-out'),
              subtitle: Text('${_selectedCheckOut.day}/${_selectedCheckOut.month}/${_selectedCheckOut.year}'),
              onTap: _selectCheckOutDate,
            ),
            
            const SizedBox(height: 8),
            
            // Duración
              Container(
              padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                  const Icon(Icons.nights_stay, size: 20),
                  const SizedBox(width: 8),
                    Text(
                    '${_selectedCheckOut.difference(_selectedCheckIn).inDays} noche(s)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Color
            const Text('Color:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _accommodationColors.map((colorName) {
                final color = _getColorFromName(colorName);
                final isSelected = _selectedColor == colorName;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorName;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: isSelected 
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Selección de participantes
            _buildParticipantSelection(),
            ],
          ),
        ),
      ),
      actions: [
        // Botón eliminar (solo si es edición) (T109: Deshabilitado según estado del plan)
        if (widget.accommodation != null)
          TextButton(
            onPressed: _canDeleteAccommodation() ? () => _confirmDelete() : null,
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        
        // Botón cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        
        // Botón guardar (T109: Deshabilitado según estado del plan)
        ElevatedButton(
          onPressed: _canSaveAccommodation() ? _saveAccommodation : null,
          child: Text(widget.accommodation == null ? AppLocalizations.of(context)!.create : AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedCheckIn,
      firstDate: widget.planStartDate,
      lastDate: widget.planEndDate ?? widget.planStartDate.add(const Duration(days: 365)),
    );
    
    if (!mounted) return;
    
    if (picked != null && picked != _selectedCheckIn) {
      setState(() {
        _selectedCheckIn = picked;
        // Asegurar que check-out es después de check-in
        if (_selectedCheckOut.isBefore(_selectedCheckIn) || _selectedCheckOut.isAtSameMomentAs(_selectedCheckIn)) {
          _selectedCheckOut = _selectedCheckIn.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedCheckOut,
      firstDate: _selectedCheckIn.add(const Duration(days: 1)),
      lastDate: widget.planEndDate ?? widget.planStartDate.add(const Duration(days: 365)),
    );
    
    if (!mounted) return;
    
    if (picked != null && picked != _selectedCheckOut) {
      setState(() {
        _selectedCheckOut = picked;
      });
    }
  }

  Color _getColorFromName(String colorName) {
    return ColorUtils.colorFromName(colorName);
  }

  /// Construye la sección de selección de participantes
  Widget _buildParticipantSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final participationsAsync = ref.watch(planRealParticipantsProvider(widget.planId));
        
        return participationsAsync.when(
          data: (participations) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Participantes:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: participations.map((participation) {
                    final isSelected = _selectedParticipantTrackIds.contains(participation.userId);
                    return FutureBuilder<String>(
                      future: _getUserDisplayName(participation.userId),
                      builder: (context, snapshot) {
                        final displayName = snapshot.data ?? participation.userId;
                        return FilterChip(
                          label: Text(displayName),
                          selected: isSelected,
                          onSelected: (selected) {
    setState(() {
                              if (selected) {
                                _selectedParticipantTrackIds.add(participation.userId);
                              } else {
                                _selectedParticipantTrackIds.remove(participation.userId);
                              }
                            });
                          },
                          selectedColor: Colors.blue.shade100,
                          checkmarkColor: Colors.blue.shade800,
                        );
                      },
                    );
                  }).toList(),
                ),
                if (_selectedParticipantTrackIds.isEmpty)
                  const Text(
                    'Sin participantes seleccionados (aparecerá en el primer track)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Text(
            'Error al cargar participantes: $error',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        );
      },
    );
  }

  /// T153: Construir campo de coste con selector de moneda y conversión automática
  Widget _buildCostFieldWithCurrency() {
    final exchangeRateService = ExchangeRateService();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de moneda local
        DropdownButtonFormField<String>(
          value: _costCurrency ?? _planCurrency ?? 'EUR',
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.costCurrency,
            prefixIcon: Icon(_getCurrencyIcon(_costCurrency ?? _planCurrency ?? 'EUR')),
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
          onChanged: (value) async {
            if (value == null) return;
            setState(() => _costCurrency = value);
            await _convertCostToPlanCurrency(exchangeRateService);
          },
        ),
        const SizedBox(height: 12),
        
        // Campo de coste
        TextFormField(
          controller: _costController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.costOptional,
            hintText: AppLocalizations.of(context)!.costHint,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(_getCurrencyIcon(_costCurrency ?? _planCurrency ?? 'EUR')),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) async {
            await _convertCostToPlanCurrency(exchangeRateService);
          },
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return null;
            final doubleValue = double.tryParse(v.replaceAll(',', '.'));
            if (doubleValue == null) return 'Debe ser un número válido';
            if (doubleValue < 0) return 'No puede ser negativo';
            if (doubleValue > 1000000) return 'Máximo 1.000.000';
            return null;
          },
        ),
        
        // Mostrar conversión si la moneda local es diferente a la del plan
        if (_costCurrency != null && 
            _planCurrency != null && 
            _costCurrency != _planCurrency &&
            _costController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          FutureBuilder<double?>(
            future: exchangeRateService.convertAmount(
              double.tryParse(_costController.text.replaceAll(',', '.')) ?? 0.0,
              _costCurrency!,
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
              
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'No se pudo calcular la conversión',
                    style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
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

  /// T153: Obtener coste convertido a la moneda del plan
  Future<double?> _getConvertedCost() async {
    if (_costController.text.trim().isEmpty) return null;
    
    final localAmount = double.tryParse(_costController.text.replaceAll(',', '.'));
    if (localAmount == null) return null;
    
    if (_costCurrency == null || _planCurrency == null || _costCurrency == _planCurrency) {
      return localAmount;
    }
    
    final exchangeRateService = ExchangeRateService();
    try {
      return await exchangeRateService.convertAmount(
        localAmount,
        _costCurrency!,
        _planCurrency!,
      );
    } catch (e) {
      return localAmount;
    }
  }

  /// T153: Convertir coste a moneda del plan automáticamente
  Future<void> _convertCostToPlanCurrency(ExchangeRateService exchangeRateService) async {
    if (_costConverting) return;
    if (_costCurrency == null || _planCurrency == null || _costCurrency == _planCurrency) return;
    if (_costController.text.trim().isEmpty) return;
    
    final localAmount = double.tryParse(_costController.text.replaceAll(',', '.'));
    if (localAmount == null) return;
    
    setState(() => _costConverting = true);
    
    try {
      await exchangeRateService.convertAmount(localAmount, _costCurrency!, _planCurrency!);
    } catch (e) {
      // Error silencioso
    } finally {
      if (mounted) {
        setState(() => _costConverting = false);
      }
    }
  }

  /// Obtiene el nombre de visualización de un usuario
  Future<String> _getUserDisplayName(String userId) async {
    // Mapeo de user IDs a nombres reales para el plan Frankenstein
    final userNames = {
      'uJRMMGniO2bwfbdD3S11QMXQT912': 'Cristian Claraso',
      'mar_batllori': 'Mar Batllori',
      'emma_claraso': 'Emma Claraso',
      'matilde_claraso': 'Matilde Claraso',
      'jimena_claraso': 'Jimena Claraso',
    };
    
    return userNames[userId] ?? userId;
  }

  Future<void> _confirmDelete() async {
    // T109: Verificar si se puede eliminar según el estado del plan
    if (!_canDeleteAccommodation() && _plan != null) {
      final blockedReason = PlanStatePermissions.getBlockedReason('delete_event', _plan!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(blockedReason ?? 'No se pueden eliminar alojamientos en el estado actual del plan.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDeleteTitle),
        content: Text('¿Estás seguro de que quieres eliminar el alojamiento "${widget.accommodation?.hotelName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onDeleted != null && widget.accommodation?.id != null) {
      widget.onDeleted!(widget.accommodation!.id!);
    }
  }

  Future<void> _saveAccommodation() async {
    // T109: Verificar si se puede guardar según el estado del plan
    if (!_canSaveAccommodation() && _plan != null) {
      final action = widget.accommodation == null ? 'create_event' : 'modify_event';
      final blockedReason = PlanStatePermissions.getBlockedReason(action, _plan!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(blockedReason ?? 'No se pueden ${widget.accommodation == null ? 'crear' : 'modificar'} alojamientos en el estado actual del plan.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Validar nombre del hotel
    if (_hotelNameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
          content: Text('El nombre del alojamiento es obligatorio'),
                backgroundColor: Colors.red,
              ),
            );
      return;
    }

    // Validar fechas
    if (_selectedCheckOut.isBefore(_selectedCheckIn) || _selectedCheckOut.isAtSameMomentAs(_selectedCheckIn)) {
          ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de check-out debe ser posterior al check-in'),
              backgroundColor: Colors.red,
            ),
          );
      return;
    }

    // Normalizar el tipo seleccionado antes de guardar
    final normalizedType = _normalizeType(_selectedType);

    final accommodation = Accommodation(
      id: widget.accommodation?.id,
      planId: widget.planId,
      checkIn: _selectedCheckIn,
      checkOut: _selectedCheckOut,
      hotelName: Sanitizer.sanitizePlainText(_hotelNameController.text, maxLength: 100),
      description: Sanitizer.sanitizePlainText(_descriptionController.text, maxLength: 1000).isEmpty
          ? null
          : Sanitizer.sanitizePlainText(_descriptionController.text, maxLength: 1000),
      color: _selectedColor,
      typeFamily: 'alojamiento',
      typeSubtype: normalizedType,
      participantTrackIds: _selectedParticipantTrackIds,
      cost: await _getConvertedCost(), // T153: Coste convertido a moneda del plan
      createdAt: widget.accommodation?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.onSaved != null) {
      widget.onSaved!(accommodation);
    }
  }
}
