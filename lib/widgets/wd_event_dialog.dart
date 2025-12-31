import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/domain/services/track_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/notifiers/calendar_notifier.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';
import 'package:unp_calendario/features/security/utils/sanitizer.dart';
import 'package:unp_calendario/shared/models/user_role.dart';
import 'package:unp_calendario/shared/models/permission.dart';
import 'package:unp_calendario/shared/models/plan_permissions.dart';
import 'package:unp_calendario/shared/services/permission_service.dart';
import 'package:unp_calendario/widgets/dialogs/edit_personal_info_dialog.dart';
import 'package:unp_calendario/widgets/permission_field.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/event/event_participant_registration_widget.dart';
import 'package:unp_calendario/shared/utils/plan_range_utils.dart';
import 'package:unp_calendario/widgets/dialogs/expand_plan_dialog.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/shared/services/exchange_rate_service.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';

class EventDialog extends ConsumerStatefulWidget {
  final Event? event;
  final String? planId;
  final DateTime? initialDate;
  final int? initialHour;
  final Function(Event)? onSaved;
  final Function(String)? onDeleted;

  const EventDialog({
    super.key,
    this.event,
    this.planId,
    this.initialDate,
    this.initialHour,
    this.onSaved,
    this.onDeleted,
  });

  @override
  ConsumerState<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends ConsumerState<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _typeFamilyController;
  late TextEditingController _typeSubtypeController;
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedDuration;
  late int _selectedStartMinute;
  late int _selectedDurationMinutes;
  late String _selectedColor;
  late bool _isDraft;
  late List<String> _selectedParticipantIds;
  late bool _isForAllParticipants; // Checkbox principal "Para todos"
  late String _selectedTimezone;
  late String _selectedArrivalTimezone;
  late TextEditingController _maxParticipantsController;
  late bool _requiresConfirmation;
  late TextEditingController _costController; // T101/T153
  String? _costCurrency; // T153: Moneda local del coste (null = moneda del plan)
  String? _planCurrency; // T153: Moneda del plan
  bool _costConverting = false; // T153: Flag para evitar loops en conversión
  bool _canEditGeneral = false;
  bool _isAdmin = false;
  bool _isCreator = false;
  PlanPermissions? _userPermissions;
  bool _isInitializing = true;
  Plan? _plan; // T109: Plan para verificar estado
  
  // Campos de información personal
  late TextEditingController _asientoController;
  late TextEditingController _menuController;
  late TextEditingController _preferenciasController;
  late TextEditingController _numeroReservaController;
  late TextEditingController _gateController;
  late TextEditingController _notasPersonalesController;
  late bool _tarjetaObtenida;

  // Colores predefinidos para eventos
  final List<String> _eventColors = [
    'blue',
    'green',
    'orange',
    'purple',
    'red',
    'teal',
    'indigo',
    'pink',
  ];

  // Familias de tipos de eventos
  final List<String> _typeFamilies = [
    'Desplazamiento',
    'Restauración',
    'Actividad',
    'Otro',
  ];

  // Subtipos por familia
  final Map<String, List<String>> _typeSubtypes = {
    'Desplazamiento': ['Taxi', 'Avión', 'Tren', 'Autobús', 'Coche', 'Caminar'],
    'Restauración': ['Desayuno', 'Comida', 'Cena', 'Snack', 'Bebida'],
    'Actividad': ['Museo', 'Monumento', 'Parque', 'Teatro', 'Concierto', 'Deporte'],
    'Otro': ['Compra', 'Reunión', 'Trabajo', 'Personal'],
  };

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores
    _descriptionController = TextEditingController(
      text: widget.event?.commonPart?.description ?? '',
    );
    _typeFamilyController = TextEditingController(
      text: widget.event?.commonPart?.family ?? '',
    );
    _typeSubtypeController = TextEditingController(
      text: widget.event?.commonPart?.subtype ?? '',
    );
    
    // Inicializar controladores de información personal
    final currentUser = ref.read(currentUserProvider);
    final currentUserId = currentUser?.id ?? '';
    final personalPart = widget.event?.personalParts?[currentUserId];
    final personalFields = personalPart?.fields ?? {};
    
    _asientoController = TextEditingController(
      text: personalFields['asiento'] ?? '',
    );
    _menuController = TextEditingController(
      text: personalFields['menu'] ?? '',
    );
    _preferenciasController = TextEditingController(
      text: personalFields['preferencias'] ?? '',
    );
    _numeroReservaController = TextEditingController(
      text: personalFields['numeroReserva'] ?? '',
    );
    _gateController = TextEditingController(
      text: personalFields['gate'] ?? '',
    );
    _notasPersonalesController = TextEditingController(
      text: personalFields['notasPersonales'] ?? '',
    );
    _tarjetaObtenida = personalFields['tarjetaObtenida'] ?? false;
    
    // Inicializar valores
    _selectedDate = widget.initialDate ?? widget.event?.commonPart?.date ?? DateTime.now();
    _selectedHour = widget.initialHour ?? widget.event?.commonPart?.startHour ?? 9;
    _selectedDuration = (widget.event?.commonPart?.durationMinutes ?? 60) ~/ 60;
    _selectedStartMinute = widget.event?.commonPart?.startMinute ?? 0;
    _selectedDurationMinutes = widget.event?.commonPart?.durationMinutes ?? 60;
    _selectedColor = widget.event?.commonPart?.customColor ?? 'blue';
    _isDraft = widget.event?.commonPart?.isDraft ?? false;
    _selectedTimezone = widget.event?.timezone ?? 'Europe/Madrid';
    _selectedArrivalTimezone = widget.event?.arrivalTimezone ?? 'Europe/Madrid';
    
    // Inicializar controlador de límite de participantes
    _maxParticipantsController = TextEditingController(
      text: widget.event?.maxParticipants?.toString() ?? '',
    );
    
    // Inicializar requiere confirmación (T120 Fase 2)
    _requiresConfirmation = widget.event?.requiresConfirmation ?? false;
    
    // Inicializar coste (T101)
    _costController = TextEditingController(
      text: widget.event?.cost?.toString() ?? '',
    );
    
    // Inicializar participantes seleccionados y checkbox "Para todos" (T47)
    final existingCommonPart = widget.event?.commonPart;
    _isForAllParticipants = existingCommonPart?.isForAllParticipants ?? true;
    _selectedParticipantIds = List.from(existingCommonPart?.participantIds ?? []);
    
    // Si es un evento existente y no está marcado "para todos" pero no hay participantes,
    // no forzar ninguna selección. El usuario puede crear eventos sin incluirse a sí mismo.
    
    // Si es un evento nuevo, por defecto está marcado "para todos" (no necesitamos seleccionar participantes)
    
    // Cargar moneda del plan (T153) y plan completo (T109)
    if (widget.planId != null) {
      _loadPlanCurrency();
      _loadPlan();
    }
    
    // Inicializar permisos del usuario
    _initializePermissions();
  }

  /// Cargar moneda del plan (T153) y plan completo (T109)
  Future<void> _loadPlanCurrency() async {
    if (widget.planId == null) return;
    
    try {
      final planService = ref.read(planServiceProvider);
      final plan = await planService.getPlanById(widget.planId!);
      if (plan != null && mounted) {
        setState(() {
          _planCurrency = plan.currency;
          // Si no hay moneda de coste establecida, usar la del plan
          _costCurrency ??= plan.currency;
          _plan = plan; // T109: Guardar plan para verificar estado
        });
      }
    } catch (e) {
      // Si falla, usar EUR por defecto
      if (mounted) {
        setState(() {
          _planCurrency = 'EUR';
          _costCurrency ??= 'EUR';
        });
      }
    }
  }
  
  /// Cargar plan completo (T109)
  Future<void> _loadPlan() async {
    if (widget.planId == null) return;
    
    try {
      final planService = ref.read(planServiceProvider);
      final plan = await planService.getPlanById(widget.planId!);
      if (plan != null && mounted) {
        setState(() {
          _plan = plan;
        });
      }
    } catch (e) {
      // Si falla, no hacer nada
    }
  }

  /// Inicializa los permisos del usuario en el plan
  Future<void> _initializePermissions() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.id == null || widget.planId == null) {
      _isInitializing = false;
      if (mounted) setState(() {});
      return;
    }

    final permissionService = PermissionService();
    _userPermissions = await permissionService.getUserPermissions(
      widget.planId!,
      currentUser!.id,
    );

    // Si no hay permisos específicos, usar permisos por defecto según el rol
    if (_userPermissions == null) {
      // Por defecto, asumir que es participante si no hay permisos específicos
      _userPermissions = PlanPermissions(
        planId: widget.planId!,
        userId: currentUser.id,
        role: UserRole.participant,
        permissions: DefaultPermissions.getDefaultPermissions(UserRole.participant),
        assignedAt: DateTime.now(),
      );
    }

    // Determinar permisos de edición
    final isCreating = widget.event == null;
    final isOwner = widget.event?.userId == currentUser.id;
    
    _isCreator = isOwner;
    _isAdmin = _userPermissions?.isAdmin ?? false;
    
    // Puede editar la parte general si:
    // - Es admin
    // - Está creando un evento nuevo
    // - Es el creador del evento
    _canEditGeneral = _isAdmin || isCreating || isOwner;

    _isInitializing = false;

    if (mounted) {
      setState(() {});
      
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _typeFamilyController.dispose();
    _typeSubtypeController.dispose();
    _asientoController.dispose();
    _menuController.dispose();
    _preferenciasController.dispose();
    _numeroReservaController.dispose();
    _gateController.dispose();
    _notasPersonalesController.dispose();
    _maxParticipantsController.dispose();
    _costController.dispose(); // T101
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga mientras se inicializan los permisos
    if (_isInitializing) {
      return AlertDialog(
        title: Text(widget.event == null ? AppLocalizations.of(context)!.createEvent : AppLocalizations.of(context)!.editEvent),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.initializingPermissions),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.event == null ? AppLocalizations.of(context)!.createEvent : AppLocalizations.of(context)!.editEvent,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          // Badge de Creador
          if (_isCreator) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.creator,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 6),
          // Badge de Admin
          if (_isAdmin) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.admin_panel_settings, size: 14, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
        width: 520,
        child: DefaultTabController(
          length: _isAdmin ? 3 : 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                tabs: [
                  const Tab(text: 'General'),
                  const Tab(text: 'Mi información'),
                  if (_isAdmin) const Tab(text: 'Info de Otros'),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 520,
                child: TabBarView(
                  children: [
                    // Tab 1: General (Parte Común)
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Indicador de permisos
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _canEditGeneral ? Colors.green.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _canEditGeneral ? Colors.green.shade200 : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _canEditGeneral ? Icons.lock_open : Icons.lock,
                                  size: 16,
                                  color: _canEditGeneral ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _canEditGeneral ? 'Puedes editar esta información' : 'Solo lectura - información común',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _canEditGeneral ? Colors.green.shade700 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
            // Descripción
            PermissionTextField(
              controller: _descriptionController,
              labelText: AppLocalizations.of(context)!.eventDescription,
              hintText: AppLocalizations.of(context)!.eventDescriptionHint,
              canEdit: _canEditGeneral,
              fieldType: 'common',
              tooltipText: 'Información compartida entre todos los participantes',
              prefixIcon: Icons.title,
              maxLines: 2,
              validator: (value) {
                if (!_canEditGeneral) return null;
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'La descripción es obligatoria';
                if (v.length < 3) return 'Mínimo 3 caracteres';
                if (v.length > 1000) return 'Máximo 1000 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Tipo de familia
            PermissionDropdownField<String>(
              value: _typeFamilyController.text.isEmpty || !_typeFamilies.contains(_typeFamilyController.text) 
                  ? null 
                  : _typeFamilyController.text,
              labelText: AppLocalizations.of(context)!.eventType,
              canEdit: _canEditGeneral,
              fieldType: 'common',
              tooltipText: 'Categoría general del evento (compartida)',
              prefixIcon: Icons.category,
              items: _typeFamilies.map((family) {
                return DropdownMenuItem(
                  value: family,
                  child: Text(family),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _typeFamilyController.text = value ?? '';
                  _typeSubtypeController.text = ''; // Reset subtipo
                });
              },
              validator: (value) {
                if (!_canEditGeneral) return null;
                // Tipo es opcional, pero si hay subtipo, debe haber tipo válido
                if ((_typeSubtypeController.text.isNotEmpty) && (value == null || !_typeFamilies.contains(value))) {
                  return AppLocalizations.of(context)!.selectValidTypeFirst;
                }
                return null;
              },
            ),
              const SizedBox(height: 16),
            
            // Subtipo
            if (_typeFamilyController.text.isNotEmpty)
              PermissionDropdownField<String>(
                value: _typeSubtypeController.text.isEmpty || 
                       !(_typeSubtypes[_typeFamilyController.text] ?? []).contains(_typeSubtypeController.text)
                    ? null 
                    : _typeSubtypeController.text,
                labelText: AppLocalizations.of(context)!.eventSubtype,
                canEdit: _canEditGeneral,
                fieldType: 'common',
                tooltipText: 'Especificación detallada del tipo de evento',
                prefixIcon: Icons.label,
                items: (_typeSubtypes[_typeFamilyController.text] ?? []).map((subtype) {
                  return DropdownMenuItem(
                    value: subtype,
                    child: Text(subtype),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _typeSubtypeController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (!_canEditGeneral) return null;
                  // Subtipo es opcional, pero si hay valor debe pertenecer a la lista
                  if (value != null && !(_typeSubtypes[_typeFamilyController.text] ?? []).contains(value)) {
                    return AppLocalizations.of(context)!.invalidSubtype;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            
            // Borrador - Switch estilo iOS
            SwitchListTile.adaptive(
              title: Text(AppLocalizations.of(context)!.isDraft),
              subtitle: Text(AppLocalizations.of(context)!.isDraftSubtitle),
              value: _isDraft,
              onChanged: !_canEditGeneral ? null : (value) {
                setState(() {
                  _isDraft = value;
                });
              },
            ),
            const SizedBox(height: 8),
            
            // Fecha - Con estilo editable
            InkWell(
              onTap: _canEditGeneral ? _selectDate : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
        children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.date,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, size: 20, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Hora - Con estilo editable
            InkWell(
              onTap: _canEditGeneral ? _selectStartTime : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
            children: [
                    Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
              Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                            'Hora de inicio',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                            Text(
                            '${_selectedHour.toString().padLeft(2, '0')}:${_selectedStartMinute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    Icon(Icons.edit, size: 20, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Duración - Con estilo editable
            InkWell(
              onTap: _canEditGeneral ? _selectDuration : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                children: [
                    Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            'Duración',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                          const SizedBox(height: 4),
                        Text(
                            _formatDuration(_selectedDurationMinutes),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                    Icon(Icons.edit, size: 20, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Timezone
            PermissionDropdownField<String>(
              value: _selectedTimezone,
              labelText: AppLocalizations.of(context)!.timezone,
              canEdit: _canEditGeneral,
              fieldType: 'common',
              tooltipText: 'Zona horaria del evento (se usa para conversiones UTC)',
              prefixIcon: Icons.public,
              items: TimezoneService.getCommonTimezones().map((tz) {
                return DropdownMenuItem(
                  value: tz,
                  child: Text(TimezoneService.getTimezoneDisplayName(tz)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimezone = value ?? 'Europe/Madrid';
                });
              },
            ),
            const SizedBox(height: 12),
            
            // Timezone de llegada (solo para vuelos/viajes)
            if (_typeFamilyController.text == 'Desplazamiento' && _typeSubtypeController.text == 'Avión')
              PermissionDropdownField<String>(
                value: _selectedArrivalTimezone,
                labelText: AppLocalizations.of(context)!.arrivalTimezone,
                canEdit: _canEditGeneral,
                fieldType: 'common',
                tooltipText: 'Zona horaria del destino (para vuelos internacionales)',
                prefixIcon: Icons.flight_land,
                items: TimezoneService.getCommonTimezones().map((tz) {
                  return DropdownMenuItem(
                    value: tz,
                    child: Text(TimezoneService.getTimezoneDisplayName(tz)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedArrivalTimezone = value ?? 'Europe/Madrid';
                  });
                },
              ),
            const SizedBox(height: 12),
            
            // Límite de participantes (T117)
            PermissionTextField(
              controller: _maxParticipantsController,
              labelText: 'Límite de participantes (opcional)',
              hintText: 'Ej: 10 (dejar vacío para sin límite)',
              canEdit: _canEditGeneral,
              fieldType: 'common',
              tooltipText: 'Máximo número de personas que pueden apuntarse a este evento',
              prefixIcon: Icons.people_outline,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (!_canEditGeneral) return null;
                final v = value?.trim() ?? '';
                if (v.isEmpty) return null; // Opcional
                final intValue = int.tryParse(v);
                if (intValue == null) return 'Debe ser un número válido';
                if (intValue < 1) return 'Debe ser mayor que 0';
                if (intValue > 1000) return 'Máximo 1000 participantes';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Requiere confirmación (T120 Fase 2)
            if (_canEditGeneral)
              CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.requiresConfirmation),
                subtitle: Text(AppLocalizations.of(context)!.requiresConfirmationSubtitle),
                value: _requiresConfirmation,
                onChanged: (value) {
                  setState(() {
                    _requiresConfirmation = value ?? false;
                  });
                },
                secondary: const Icon(Icons.assignment_turned_in_outlined),
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 16),
            
            // Coste del evento (T101/T153)
            if (_planCurrency != null) _buildCostFieldWithCurrency(),
            const SizedBox(height: 16),
            
            // Sección de registro de participantes (T117)
            if (widget.event != null && widget.planId != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.participantsRegistered,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    EventParticipantRegistrationWidget(
                      event: widget.event!,
                      planId: widget.planId!,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // Participantes (tracks asignados)
            _buildParticipantsSection(),
            const SizedBox(height: 16),
            
            // Color
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Color'),
              subtitle: Row(
                children: _eventColors.map((colorName) {
                  final color = _getColorFromName(colorName);
                  return GestureDetector(
                    onTap: !_canEditGeneral ? null : () {
          setState(() {
                        _selectedColor = colorName;
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == colorName 
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
                ),
              ),
            ],
          ),
                    ),
                    // Tab "Mi información"
                    SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                          const SizedBox(height: 16),
                            Text(
                            'Información personal para este evento',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Asiento
                          PermissionTextField(
                            controller: _asientoController,
                            labelText: AppLocalizations.of(context)!.seat,
                            hintText: AppLocalizations.of(context)!.seatHint,
                            canEdit: true, // Siempre editable en parte personal
                            fieldType: 'personal',
                            tooltipText: 'Tu asiento específico para este evento',
                            prefixIcon: Icons.chair,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return null;
                              if (v.length > 50) return 'Máximo 50 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Menú/Comida
                          PermissionTextField(
                            controller: _menuController,
                            labelText: AppLocalizations.of(context)!.menu,
                            hintText: AppLocalizations.of(context)!.menuHint,
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Tus preferencias alimentarias para este evento',
                            prefixIcon: Icons.restaurant,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return null;
                              if (v.length > 100) return 'Máximo 100 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Preferencias
                          PermissionTextField(
                            controller: _preferenciasController,
                            labelText: AppLocalizations.of(context)!.preferences,
                            hintText: AppLocalizations.of(context)!.preferencesHint,
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Tus preferencias específicas para este evento',
                            prefixIcon: Icons.favorite,
                            maxLines: 2,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return null;
                              if (v.length > 200) return 'Máximo 200 caracteres';
                              return null;
                            },
                          ),
              const SizedBox(height: 16),

                          // Campo: Número de reserva
                          PermissionTextField(
                            controller: _numeroReservaController,
                            labelText: AppLocalizations.of(context)!.reservationNumber,
                            hintText: AppLocalizations.of(context)!.reservationNumberHint,
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Tu número de reserva específico',
                            prefixIcon: Icons.confirmation_number,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return null;
                              if (v.length > 50) return 'Máximo 50 caracteres';
                              return null;
                            },
                          ),
              const SizedBox(height: 16),
                          
                          // Campo: Puerta/Gate
                          PermissionTextField(
                            controller: _gateController,
                            labelText: AppLocalizations.of(context)!.gate,
                            hintText: AppLocalizations.of(context)!.gateHint,
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Tu puerta o gate específico',
                            prefixIcon: Icons.door_front_door,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return null;
                              if (v.length > 50) return 'Máximo 50 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Switch: Tarjeta obtenida
                          SwitchListTile.adaptive(
                            title: Text(AppLocalizations.of(context)!.cardObtained),
                            subtitle: Text(AppLocalizations.of(context)!.cardObtainedSubtitle),
                            value: _tarjetaObtenida,
                onChanged: (value) {
                  setState(() {
                                _tarjetaObtenida = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Notas personales
                          PermissionTextField(
                            controller: _notasPersonalesController,
                            labelText: AppLocalizations.of(context)!.personalNotes,
                            hintText: 'Información adicional solo para ti',
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Notas privadas que solo tú puedes ver',
                            prefixIcon: Icons.note,
                            maxLines: 3,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return null;
                              if (v.length > 1000) return 'Máximo 1000 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Info sobre privacidad
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                                  child: Text(
                                    'Esta información es solo tuya. Otros participantes no la verán.',
                          style: TextStyle(
                                      color: Colors.blue.shade700,
                            fontSize: 12,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                    ),
                    // Tab 3: Info de Otros (Solo Admins)
                    if (_isAdmin)
                      _buildOthersInfoTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
      actions: [
        // Botón eliminar (solo si es edición) (T109: Deshabilitado según estado del plan)
        if (widget.event != null)
          TextButton(
            onPressed: _canDeleteEvent() ? () => _confirmDelete() : null,
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        
        // Botón cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        
        // Botón guardar (T109: Deshabilitado según estado del plan)
        ElevatedButton(
          onPressed: _canSaveEvent() ? _saveEvent : null,
          child: Text(widget.event == null ? AppLocalizations.of(context)!.create : AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  /// T109: Verifica si se puede guardar/crear el evento según el estado del plan
  bool _canSaveEvent() {
    if (_plan == null) return true; // Si no hay plan cargado, permitir por defecto
    
    if (widget.event == null) {
      // Crear evento nuevo
      return PlanStatePermissions.canAddEvents(_plan!);
    } else {
      // Modificar evento existente
      return PlanStatePermissions.canModifyEvents(_plan!);
    }
  }
  
  /// T109: Verifica si se puede eliminar el evento según el estado del plan
  bool _canDeleteEvent() {
    if (_plan == null) return true; // Si no hay plan cargado, permitir por defecto
    return PlanStatePermissions.canDeleteEvents(_plan!);
  }

  /// Construye el tab de información de otros participantes (solo para admins)
  Widget _buildOthersInfoTab() {
    final currentUser = ref.read(currentUserProvider);
    final currentUserId = currentUser?.id ?? '';
    
    // Filtrar participantes excluyendo al usuario actual
    final otherParticipants = _selectedParticipantIds.where((id) => id != currentUserId).toList();
    
    if (otherParticipants.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay otros participantes en este evento',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Como administrador, puedes ver y editar la información personal de otros participantes.',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...otherParticipants.map((participantId) => _buildParticipantCard(participantId)),
        ],
      ),
    );
  }

  /// Construye una tarjeta para mostrar/editar la información de un participante
  Widget _buildParticipantCard(String participantId) {
    final personalPart = widget.event?.personalParts?[participantId];
    final personalFields = personalPart?.fields ?? {};
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                FutureBuilder<String>(
                  future: _getUserDisplayName(participantId),
                  builder: (context, snapshot) {
                    final displayName = snapshot.data ?? participantId;
                    return Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Campos de información personal del participante
            _buildReadOnlyField('Asiento', personalFields['asiento']),
            _buildReadOnlyField('Menú', personalFields['menu']),
            _buildReadOnlyField('Preferencias', personalFields['preferencias']),
            _buildReadOnlyField('Número de reserva', personalFields['numeroReserva']),
            _buildReadOnlyField('Gate', personalFields['gate']),
            _buildReadOnlyField('Tarjeta obtenida', personalFields['tarjetaObtenida'] == true ? 'Sí' : 'No'),
            _buildReadOnlyField('Notas personales', personalFields['notasPersonales']),
            
            const SizedBox(height: 16),
            // Solo mostrar botón de editar si el usuario tiene permisos
            if (_userPermissions?.hasPermission(Permission.eventEditOthersPersonal) ?? false)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editParticipantInfo(participantId),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(AppLocalizations.of(context)!.editInfo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade800,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.grey.shade600, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Sin permisos para editar',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construye un campo de solo lectura
  Widget _buildReadOnlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'No especificado',
              style: TextStyle(
                color: value != null ? Colors.black87 : Colors.grey.shade500,
                fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Edita la información personal de un participante específico
  void _editParticipantInfo(String participantId) async {
    if (widget.event == null || widget.planId == null) return;
    
    final participantName = await _getUserDisplayName(participantId);
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => EditPersonalInfoDialog(
          event: widget.event!,
          participantId: participantId,
          participantName: participantName,
          planId: widget.planId!,
          onSaved: (updatedEvent) {
            // Actualizar el evento en el estado local si es necesario
            setState(() {});
          },
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (!mounted) return;
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedStartMinute),
    );
    
    if (!mounted) return;
    
    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedStartMinute = picked.minute;
      });
    }
  }

  Future<void> _selectDuration() async {
    final int? durationMinutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duración'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
      children: [
              // Opciones rápidas comunes (hasta 3 horas = 180 min)
              const Text('Duración común:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
              ...List.generate(12, (index) {
                final minutes = (index + 1) * 15; // 15, 30, 45, 60, 75, 90, etc.
                return ListTile(
                  title: Text(_formatDuration(minutes)),
                  onTap: () => Navigator.of(context).pop(minutes),
                );
              }),
              const Divider(),
              // Opciones personalizadas (hasta 24 horas)
              const Text('Duraciones largas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...List.generate(21, (index) {
                final hours = index + 4; // 4h, 5h, 6h... hasta 24h
                final minutes = hours * 60;
                return ListTile(
                  title: Text(_formatDuration(minutes)),
                  onTap: () => Navigator.of(context).pop(minutes),
                  trailing: hours == 24 
                      ? const Text('(máximo)', style: TextStyle(fontSize: 11, color: Colors.grey))
                      : null,
                );
              }),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
              child: Text(
                  '💡 Eventos máximo 24h.\nSi necesitas más → usa Alojamientos',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    if (!mounted) return;
    
    if (durationMinutes != null) {
      setState(() {
        _selectedDurationMinutes = durationMinutes;
        _selectedDuration = (durationMinutes / 60).ceil(); // Mantener compatibilidad
      });
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes} min';
    } else if (minutes == 60) {
      return '1 hora';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  Color _getColorFromName(String colorName) {
    return ColorUtils.colorFromName(colorName);
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
    if (!_canDeleteEvent() && _plan != null) {
      final blockedReason = PlanStatePermissions.getBlockedReason('delete_event', _plan!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(blockedReason ?? 'No se pueden eliminar eventos en el estado actual del plan.'),
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
        content: Text('¿Estás seguro de que quieres eliminar el evento "${widget.event?.description}"?'),
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

    if (confirmed == true && widget.onDeleted != null && widget.event?.id != null) {
      widget.onDeleted!(widget.event!.id!);
    }
  }

  /// Construye la sección de selección de participantes (T47)
  Widget _buildParticipantsSection() {
    // Si no hay planId, no mostrar selector de participantes
    if (widget.planId == null) {
      return const Text(
        '⚠️ No hay planId disponible',
        style: TextStyle(color: Colors.orange, fontSize: 12),
      );
    }
    
    final currentUser = ref.read(currentUserProvider);
    final currentUserId = currentUser?.id;
    
    // Obtener participantes reales del plan (excluye observadores)
    final participantsAsync = ref.watch(planRealParticipantsProvider(widget.planId!));
    
    return participantsAsync.when(
      data: (participations) {
        if (participations.isEmpty) {
          return const Text(
            'No hay participantes en este plan',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox principal "Este evento es para todos" (T47)
            CheckboxListTile(
              title: const Text(
                'Este evento es para todos los participantes del plan',
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
                    _selectedParticipantIds.clear();
                  }
                  // Si se desmarca "para todos", no forzar ninguna selección
                  // El usuario puede seleccionar los participantes que desee
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
              
              // Lista de checkboxes de participantes
              ...participations.map((participation) {
                final isSelected = _selectedParticipantIds.contains(participation.userId);
                final isCreator = participation.userId == currentUserId && 
                                  (widget.event == null || widget.event?.userId == currentUserId);
                final isEventCreator = widget.event?.userId == participation.userId;
                
                return FutureBuilder<String>(
                  future: _getUserDisplayName(participation.userId),
                  builder: (context, snapshot) {
                    final displayName = snapshot.data ?? participation.userId;
                    final roleText = participation.isOrganizer 
                        ? ' (Organizador)' 
                        : participation.isParticipant 
                            ? ' (Participante)'
                            : '';
                    final participantName = '$displayName$roleText';
                    
                    return CheckboxListTile(
                      title: Text(participantName),
                      value: isSelected,
                      onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              if (!_selectedParticipantIds.contains(participation.userId)) {
                                _selectedParticipantIds.add(participation.userId);
                              }
                            } else {
                              // No permitir deseleccionar si es el único seleccionado
                              if (_selectedParticipantIds.length > 1) {
                                _selectedParticipantIds.remove(participation.userId);
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
                      activeColor: Colors.blue,
                      secondary: isEventCreator 
                          ? const Icon(Icons.person, color: Colors.orange)
                          : null,
                      subtitle: isEventCreator 
                          ? const Text(
                              'Creador del evento',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                );
              }).toList(),
              
              // Mensaje de validación
              if (_selectedParticipantIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '⚠️ Selecciona al menos un participante',
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
        'Error al cargar participantes: $error',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  /// T153: Construir campo de coste con selector de moneda y conversión automática
  Widget _buildCostFieldWithCurrency() {
    final exchangeRateService = ExchangeRateService();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de moneda local
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _costCurrency ?? _planCurrency ?? 'EUR',
                decoration: InputDecoration(
                  labelText: 'Moneda del coste',
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
                onChanged: _canEditGeneral ? (value) async {
                  if (value == null) return;
                  
                  setState(() {
                    _costCurrency = value;
                  });
                  
                  // Convertir automáticamente si hay un monto y la moneda cambió
                  await _convertCostToPlanCurrency(exchangeRateService);
                } : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Campo de coste
        PermissionField(
          canEdit: _canEditGeneral,
          fieldType: 'common',
          fieldName: 'Coste del evento (opcional)',
          tooltipText: 'Coste total del evento en ${CurrencyFormatterService.getName(_costCurrency ?? _planCurrency ?? 'EUR')}',
          icon: _getCurrencyIcon(_costCurrency ?? _planCurrency ?? 'EUR'),
          child: TextFormField(
            controller: _costController,
            enabled: _canEditGeneral,
            decoration: InputDecoration(
              labelText: 'Coste del evento (opcional)',
              hintText: 'Ej: 150.50',
              prefixIcon: Icon(_getCurrencyIcon(_costCurrency ?? _planCurrency ?? 'EUR')),
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: _canEditGeneral ? (value) {
              // Convertir automáticamente cuando cambia el monto (sin await para no bloquear)
              _convertCostToPlanCurrency(exchangeRateService);
            } : null,
            validator: (value) {
              if (!_canEditGeneral) return null;
              final v = value?.trim() ?? '';
              if (v.isEmpty) return null; // Opcional
              final doubleValue = double.tryParse(v.replaceAll(',', '.'));
              if (doubleValue == null) return 'Debe ser un número válido';
              if (doubleValue < 0) return 'No puede ser negativo';
              if (doubleValue > 1000000) return 'Máximo 1.000.000';
              return null;
            },
          ),
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
    
    // Si no hay monedas definidas o son iguales, retornar el monto tal cual
    if (_costCurrency == null || _planCurrency == null) {
      return localAmount;
    }
    
    if (_costCurrency == _planCurrency) {
      return localAmount;
    }
    
    // Convertir a moneda del plan
    final exchangeRateService = ExchangeRateService();
    try {
      final convertedAmount = await exchangeRateService.convertAmount(
        localAmount,
        _costCurrency!,
        _planCurrency!,
      );
      return convertedAmount;
    } catch (e) {
      // Si falla la conversión, retornar el monto original
      return localAmount;
    }
  }

  /// T153: Convertir coste a moneda del plan automáticamente
  Future<void> _convertCostToPlanCurrency(ExchangeRateService exchangeRateService) async {
    if (_costConverting) return; // Evitar loops
    if (_costCurrency == null || _planCurrency == null) return;
    if (_costCurrency == _planCurrency) return; // Misma moneda, no convertir
    if (_costController.text.trim().isEmpty) return;
    
    final localAmount = double.tryParse(_costController.text.replaceAll(',', '.'));
    if (localAmount == null) return;
    
    setState(() {
      _costConverting = true;
    });
    
    try {
      // El coste se guardará en la moneda del plan
      // Solo mostramos la conversión, pero no actualizamos el campo
      // El campo muestra el monto en la moneda local
      await exchangeRateService.convertAmount(
        localAmount,
        _costCurrency!,
        _planCurrency!,
      );
    } catch (e) {
      // Error silencioso, se mostrará en el FutureBuilder
    } finally {
      if (mounted) {
        setState(() {
          _costConverting = false;
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    // Validación de formulario (campos con validator)
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Validar permisos antes de proceder
    if (!_canEditGeneral) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permisos para editar este evento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La descripción es obligatoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validación de participantes (T47)
    // Si no está marcado "para todos", debe haber al menos un participante seleccionado
    if (!_isForAllParticipants && _selectedParticipantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar al menos un participante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que el evento no dure más de 24 horas
    if (_selectedDurationMinutes > 1440) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Un evento no puede durar más de 24 horas.\n\n'
            '• Si es alojamiento → usa la fila de Alojamientos\n'
            '• Si son actividades diferentes → crea eventos separados por día',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }

    // Obtener el userId del usuario actual
    final currentUser = ref.read(currentUserProvider);
    final userId = currentUser?.id ?? '';

    // Construir EventCommonPart (T47)
    final commonPart = EventCommonPart(
      description: Sanitizer.sanitizePlainText(_descriptionController.text, maxLength: 1000),
      date: _selectedDate,
      startHour: _selectedHour,
      startMinute: _selectedStartMinute,
      durationMinutes: _selectedDurationMinutes,
      customColor: _selectedColor,
      family: _typeFamilyController.text.isEmpty ? null : _typeFamilyController.text,
      subtype: _typeSubtypeController.text.isEmpty ? null : _typeSubtypeController.text,
      isDraft: _isDraft,
      // Si está marcado "para todos", participantIds debe estar vacío
      // Si no, debe contener los IDs seleccionados
      participantIds: _isForAllParticipants ? [] : _selectedParticipantIds,
      isForAllParticipants: _isForAllParticipants,
    );

    // Construir EventPersonalPart para el usuario actual
    final personalPart = EventPersonalPart(
      participantId: userId,
      fields: {
        'asiento': Sanitizer.sanitizePlainText(_asientoController.text, maxLength: 50).isEmpty ? null : Sanitizer.sanitizePlainText(_asientoController.text, maxLength: 50),
        'menu': Sanitizer.sanitizePlainText(_menuController.text, maxLength: 100).isEmpty ? null : Sanitizer.sanitizePlainText(_menuController.text, maxLength: 100),
        'preferencias': Sanitizer.sanitizePlainText(_preferenciasController.text, maxLength: 200).isEmpty ? null : Sanitizer.sanitizePlainText(_preferenciasController.text, maxLength: 200),
        'numeroReserva': Sanitizer.sanitizePlainText(_numeroReservaController.text, maxLength: 50).isEmpty ? null : Sanitizer.sanitizePlainText(_numeroReservaController.text, maxLength: 50),
        'gate': Sanitizer.sanitizePlainText(_gateController.text, maxLength: 50).isEmpty ? null : Sanitizer.sanitizePlainText(_gateController.text, maxLength: 50),
        'tarjetaObtenida': _tarjetaObtenida,
        'notasPersonales': Sanitizer.sanitizePlainText(_notasPersonalesController.text, maxLength: 1000).isEmpty ? null : Sanitizer.sanitizePlainText(_notasPersonalesController.text, maxLength: 1000),
      },
    );

    // Construir mapa de personalParts (mantener existentes + añadir/actualizar el actual)
    final Map<String, EventPersonalPart> personalParts = Map.from(widget.event?.personalParts ?? {});
    personalParts[userId] = personalPart;

    final event = Event(
      id: widget.event?.id,
      planId: widget.planId ?? '',
      userId: userId,
      date: _selectedDate,
      hour: _selectedHour,
      duration: _selectedDuration,
      startMinute: _selectedStartMinute,
      durationMinutes: _selectedDurationMinutes,
      description: Sanitizer.sanitizePlainText(_descriptionController.text, maxLength: 1000),
      color: _selectedColor,
      typeFamily: _typeFamilyController.text.isEmpty ? null : _typeFamilyController.text,
      typeSubtype: _typeSubtypeController.text.isEmpty ? null : _typeSubtypeController.text,
      participantTrackIds: _selectedParticipantIds,
      isDraft: _isDraft,
      timezone: _selectedTimezone,
      arrivalTimezone: _selectedArrivalTimezone,
      maxParticipants: _maxParticipantsController.text.trim().isEmpty 
          ? null 
          : int.tryParse(_maxParticipantsController.text.trim()),
      requiresConfirmation: _requiresConfirmation,
      cost: await _getConvertedCost(), // T153: Coste convertido a moneda del plan
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      commonPart: commonPart,
      personalParts: personalParts,
    );

    // T107: Detectar si el evento se extiende fuera del rango del plan
    if (widget.planId != null && !_isDraft) {
      final planService = ref.read(planServiceProvider);
      final plan = await planService.getPlanById(widget.planId!);
      
      if (plan != null) {
        final expansionInfo = PlanRangeUtils.detectEventOutsideRange(event, plan);
        
        if (expansionInfo != null) {
          // Mostrar diálogo de confirmación
          final shouldExpand = await showDialog<bool>(
            context: context,
            builder: (context) => ExpandPlanDialog(
              plan: plan,
              expansionInfo: expansionInfo,
            ),
          );
          
          if (shouldExpand == true) {
            // Expandir el plan
            final newPlanValues = PlanRangeUtils.calculateExpandedPlanValues(plan, expansionInfo);
            final success = await planService.expandPlan(
              plan,
              newStartDate: newPlanValues['startDate'] as DateTime,
              newEndDate: newPlanValues['endDate'] as DateTime,
              newColumnCount: newPlanValues['columnCount'] as int,
            );
            
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Plan expandido exitosamente'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (!success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ Error al expandir el plan'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            // Usuario canceló la expansión, no guardar el evento
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.eventNotSaved),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            return; // No guardar el evento si no se expande el plan
          }
        }
      }
    }

    if (widget.onSaved != null) {
      widget.onSaved!(event);
    }
  }
} 