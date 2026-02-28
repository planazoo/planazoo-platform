import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';
import 'package:unp_calendario/features/security/utils/sanitizer.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/shared/services/exchange_rate_service.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
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
  late bool _isForAllParticipants; // Checkbox principal "Para todos"

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
    
    // Inicializar participantes seleccionados y checkbox "Para todos" (igual que eventos)
    final existingParticipantTrackIds = widget.accommodation?.participantTrackIds ?? [];
    // Si el alojamiento existente tiene participantTrackIds, no está "para todos"
    _isForAllParticipants = existingParticipantTrackIds.isEmpty;
    _selectedParticipantTrackIds = List.from(existingParticipantTrackIds);
    
    // Si es un alojamiento nuevo, por defecto está marcado "para todos" (no necesitamos seleccionar participantes)
    // Si es un alojamiento existente y no está marcado "para todos" pero no hay participantes,
    // asegurar que al menos haya uno seleccionado (se validará al guardar)
    
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
    final loc = AppLocalizations.of(context)!;
    final title = widget.accommodation == null ? loc.newAccommodation : loc.editAccommodation;
    return AlertDialog(
      title: null,
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // T240 / T226: Barra verde superior con título (UI estándar modales)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF79A2A8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Form(
                key: _formKey,
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
                title: Text(AppLocalizations.of(context)!.checkIn),
              subtitle: Text('${_selectedCheckIn.day}/${_selectedCheckIn.month}/${_selectedCheckIn.year}'),
              onTap: _selectCheckInDate,
            ),
            
            // Check-out
              ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.checkOut),
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
                    AppLocalizations.of(context)!.nights(_selectedCheckOut.difference(_selectedCheckIn).inDays),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Color
            Text(AppLocalizations.of(context)!.color, style: const TextStyle(fontWeight: FontWeight.bold)),
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
          ),
        ],
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
        final currentUserId = ref.watch(currentUserProvider)?.id;
        
        return participationsAsync.when(
          data: (participations) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox principal "Este alojamiento es para todos" (igual que eventos)
                CheckboxListTile(
                  title: const Text(
                    'Este alojamiento es para todos los participantes del plan',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: _isForAllParticipants 
                      ? const Text('Todos los participantes estarán incluidos automáticamente')
                      : const Text('Selecciona participantes específicos abajo'),
                  value: _isForAllParticipants,
                  onChanged: (value) {
                    setState(() {
                      _isForAllParticipants = value ?? true;
                      // Si se marca "para todos", limpiar selección individual
                      if (_isForAllParticipants) {
                        _selectedParticipantTrackIds.clear();
                      } else {
                        // Si se desmarca, asegurar que al menos el usuario actual esté seleccionado
                        if (currentUserId != null && !_selectedParticipantTrackIds.contains(currentUserId)) {
                          _selectedParticipantTrackIds.add(currentUserId);
                        }
                      }
                    });
                  },
                  activeColor: Colors.blue,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                
                // Lista de participantes (solo visible si checkbox principal está desmarcado)
                if (!_isForAllParticipants) ...[
                  const Text(
                    'Seleccionar participantes:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Lista de FilterChips de participantes
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
                                  if (!_selectedParticipantTrackIds.contains(participation.userId)) {
                                    _selectedParticipantTrackIds.add(participation.userId);
                                  }
                                } else {
                                  // No permitir deseleccionar si es el único seleccionado
                                  if (_selectedParticipantTrackIds.length > 1) {
                                    _selectedParticipantTrackIds.remove(participation.userId);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Debe haber al menos un participante seleccionado'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
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
                  
                  // Mensaje de validación
                  if (_selectedParticipantTrackIds.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Debes seleccionar al menos un participante',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
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
            AppLocalizations.of(context)!.errorLoadingParticipants(error.toString()),
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
            if (doubleValue == null) return AppLocalizations.of(context)!.mustBeValidNumber;
            if (doubleValue < 0) return AppLocalizations.of(context)!.cannotBeNegative;
            if (doubleValue > 1000000) return AppLocalizations.of(context)!.maxAmount;
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.calculating, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                            AppLocalizations.of(context)!.convertedTo(_planCurrency!),
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
                    AppLocalizations.of(context)!.conversionError,
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

  /// Obtiene el nombre de visualización de un usuario por su ID
  Future<String> _getUserDisplayName(String userId) async {
    try {
      // Obtener el usuario real desde Firestore usando UserService
      final userService = UserService();
      final user = await userService.getUser(userId);
      
      if (user != null) {
        // Priorizar displayName, luego username, luego email
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
          return user.displayName!;
        }
        if (user.username != null && user.username!.trim().isNotEmpty) {
          return '@${user.username!}';
        }
        return user.email;
      }
      
      // Si no se encuentra el usuario, devolver el userId como fallback
      return userId;
    } catch (e) {
      // En caso de error, devolver el userId
      return userId;
    }
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
            SnackBar(
          content: Text(AppLocalizations.of(context)!.accommodationNameRequiredError),
                backgroundColor: Colors.red,
              ),
            );
      return;
    }

    // Validar fechas
    if (_selectedCheckOut.isBefore(_selectedCheckIn) || _selectedCheckOut.isAtSameMomentAs(_selectedCheckIn)) {
          ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.checkOutAfterCheckInError),
              backgroundColor: Colors.red,
            ),
          );
      return;
    }

    // Validar participantes (igual que eventos)
    if (!_isForAllParticipants && _selectedParticipantTrackIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar al menos un participante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Normalizar el tipo seleccionado antes de guardar
    final normalizedType = _normalizeType(_selectedType);

    double? costValue;
    try {
      costValue = await _getConvertedCost();
    } catch (_) {
      // Si falla la conversión de moneda, guardar sin coste
    }

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
      // Si está marcado "para todos", participantTrackIds debe estar vacío
      // Si no, debe contener los IDs seleccionados
      participantTrackIds: _isForAllParticipants ? [] : _selectedParticipantTrackIds,
      cost: costValue, // T153: Coste convertido a moneda del plan
      createdAt: widget.accommodation?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.onSaved != null) {
      widget.onSaved!(accommodation);
    }
  }
}
