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
import 'package:unp_calendario/features/testing/family_users_generator.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';
import 'package:unp_calendario/shared/models/user_role.dart';
import 'package:unp_calendario/shared/models/permission.dart';
import 'package:unp_calendario/shared/models/plan_permissions.dart';
import 'package:unp_calendario/shared/services/permission_service.dart';
import 'package:unp_calendario/widgets/dialogs/edit_personal_info_dialog.dart';
import 'package:unp_calendario/widgets/permission_field.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

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
  late String _selectedTimezone;
  late String _selectedArrivalTimezone;
  bool _canEditGeneral = false;
  bool _isAdmin = false;
  bool _isCreator = false;
  PlanPermissions? _userPermissions;
  bool _isInitializing = true;
  
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
    'Alojamiento',
    'Otro',
  ];

  // Subtipos por familia
  final Map<String, List<String>> _typeSubtypes = {
    'Desplazamiento': ['Taxi', 'Avión', 'Tren', 'Autobús', 'Coche', 'Caminar'],
    'Restauración': ['Desayuno', 'Comida', 'Cena', 'Snack', 'Bebida'],
    'Actividad': ['Museo', 'Monumento', 'Parque', 'Teatro', 'Concierto', 'Deporte'],
    'Alojamiento': ['Hotel', 'Apartamento', 'Hostal', 'Casa'],
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
    
    // Inicializar participantes seleccionados
    _selectedParticipantIds = widget.event?.commonPart?.participantIds ?? [];
    
    // Inicializar permisos del usuario
    _initializePermissions();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga mientras se inicializan los permisos
    if (_isInitializing) {
      return AlertDialog(
        title: Text(widget.event == null ? 'Crear Evento' : 'Editar Evento'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Inicializando permisos...'),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.event == null ? 'Crear Evento' : 'Editar Evento',
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
                    'Creador',
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
      content: SizedBox(
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
              labelText: 'Descripción',
              hintText: 'Nombre del evento',
              canEdit: _canEditGeneral,
              fieldType: 'common',
              tooltipText: 'Información compartida entre todos los participantes',
              prefixIcon: Icons.title,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // Tipo de familia
            PermissionDropdownField<String>(
              value: _typeFamilyController.text.isEmpty || !_typeFamilies.contains(_typeFamilyController.text) 
                  ? null 
                  : _typeFamilyController.text,
              labelText: 'Tipo de evento',
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
            ),
              const SizedBox(height: 16),
            
            // Subtipo
            if (_typeFamilyController.text.isNotEmpty)
              PermissionDropdownField<String>(
                value: _typeSubtypeController.text.isEmpty || 
                       !(_typeSubtypes[_typeFamilyController.text] ?? []).contains(_typeSubtypeController.text)
                    ? null 
                    : _typeSubtypeController.text,
                labelText: 'Subtipo',
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
              ),
              const SizedBox(height: 16),
            
            // Borrador - Switch estilo iOS
            SwitchListTile.adaptive(
              title: const Text('Es borrador'),
              subtitle: const Text('Los borradores se muestran con menor opacidad'),
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
                          const Text(
                            'Fecha',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
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
              labelText: 'Timezone',
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
                labelText: 'Timezone de llegada',
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
            
            // Participantes
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
                            labelText: 'Asiento',
                            hintText: 'Ej: 12A, Ventana',
                            canEdit: true, // Siempre editable en parte personal
                            fieldType: 'personal',
                            tooltipText: 'Tu asiento específico para este evento',
                            prefixIcon: Icons.chair,
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Menú/Comida
                          PermissionTextField(
                            controller: _menuController,
                            labelText: 'Menú/Comida',
                            hintText: 'Ej: Vegetariano, Sin gluten',
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Tus preferencias alimentarias para este evento',
                            prefixIcon: Icons.restaurant,
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Preferencias
                          PermissionTextField(
                            controller: _preferenciasController,
                            labelText: 'Preferencias',
                            hintText: 'Ej: Cerca de la salida, Silencioso',
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Tus preferencias específicas para este evento',
                            prefixIcon: Icons.favorite,
                            maxLines: 2,
                          ),
              const SizedBox(height: 16),

                          // Campo: Número de reserva
                          PermissionTextField(
                            controller: _numeroReservaController,
                            labelText: 'Número de reserva',
                            hintText: 'Ej: ABC123, 456789',
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Tu número de reserva específico',
                            prefixIcon: Icons.confirmation_number,
                          ),
              const SizedBox(height: 16),
                          
                          // Campo: Puerta/Gate
                          PermissionTextField(
                            controller: _gateController,
                            labelText: 'Puerta/Gate',
                            hintText: 'Ej: Gate A12, Puerta 3',
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Tu puerta o gate específico',
                            prefixIcon: Icons.door_front_door,
                          ),
                          const SizedBox(height: 16),
                          
                          // Switch: Tarjeta obtenida
                          SwitchListTile.adaptive(
                            title: const Text('Tarjeta obtenida'),
                            subtitle: const Text('Marcar si ya tienes la tarjeta/entrada'),
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
                            labelText: 'Notas personales',
                            hintText: 'Información adicional solo para ti',
                            canEdit: true,
                            fieldType: 'personal',
                            tooltipText: 'Notas privadas que solo tú puedes ver',
                            prefixIcon: Icons.note,
                            maxLines: 3,
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
      actions: [
        // Botón eliminar (solo si es edición)
        if (widget.event != null)
          TextButton(
            onPressed: () => _confirmDelete(),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        
        // Botón cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        
        // Botón guardar
        ElevatedButton(
          onPressed: _saveEvent,
          child: Text(widget.event == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
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
                  label: const Text('Editar información'),
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
      // Importar el generador de usuarios para obtener los nombres
      final userInfo = FamilyUsersGenerator.getUserInfo(userId);
      if (userInfo != null) {
        return userInfo['displayName'] ?? userId;
      }
      
      // Si no está en la lista de usuarios generados, devolver el userId
      return userId;
    } catch (e) {
      return userId;
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el evento "${widget.event?.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onDeleted != null && widget.event?.id != null) {
      widget.onDeleted!(widget.event!.id!);
    }
  }

  /// Construye la sección de selección de participantes
  Widget _buildParticipantsSection() {
    // Si no hay planId, no mostrar selector de participantes
    if (widget.planId == null) {
      return const Text(
        '⚠️ No hay planId disponible',
        style: TextStyle(color: Colors.orange, fontSize: 12),
      );
    }
    
    
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
            const Text(
              'Participantes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
              const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: participations.map((participation) {
                final isSelected = _selectedParticipantIds.contains(participation.userId);
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
                            _selectedParticipantIds.add(participation.userId);
                          } else {
                            _selectedParticipantIds.remove(participation.userId);
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
            if (_selectedParticipantIds.isEmpty)
              const Text(
                'Selecciona al menos un participante',
                style: TextStyle(color: Colors.red, fontSize: 12),
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
  }

  void _saveEvent() {
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

    if (_selectedParticipantIds.isEmpty) {
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

    // Construir EventCommonPart
    final commonPart = EventCommonPart(
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      startHour: _selectedHour,
      startMinute: _selectedStartMinute,
      durationMinutes: _selectedDurationMinutes,
      customColor: _selectedColor,
      family: _typeFamilyController.text.isEmpty ? null : _typeFamilyController.text,
      subtype: _typeSubtypeController.text.isEmpty ? null : _typeSubtypeController.text,
      isDraft: _isDraft,
      participantIds: _selectedParticipantIds,
    );

    // Construir EventPersonalPart para el usuario actual
    final personalPart = EventPersonalPart(
      participantId: userId,
      fields: {
        'asiento': _asientoController.text.trim().isEmpty ? null : _asientoController.text.trim(),
        'menu': _menuController.text.trim().isEmpty ? null : _menuController.text.trim(),
        'preferencias': _preferenciasController.text.trim().isEmpty ? null : _preferenciasController.text.trim(),
        'numeroReserva': _numeroReservaController.text.trim().isEmpty ? null : _numeroReservaController.text.trim(),
        'gate': _gateController.text.trim().isEmpty ? null : _gateController.text.trim(),
        'tarjetaObtenida': _tarjetaObtenida,
        'notasPersonales': _notasPersonalesController.text.trim().isEmpty ? null : _notasPersonalesController.text.trim(),
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
      description: _descriptionController.text.trim(),
      color: _selectedColor,
      typeFamily: _typeFamilyController.text.isEmpty ? null : _typeFamilyController.text,
      typeSubtype: _typeSubtypeController.text.isEmpty ? null : _typeSubtypeController.text,
      participantTrackIds: _selectedParticipantIds,
      isDraft: _isDraft,
      timezone: _selectedTimezone,
      arrivalTimezone: _selectedArrivalTimezone,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      commonPart: commonPart,
      personalParts: personalParts,
    );


    if (widget.onSaved != null) {
      widget.onSaved!(event);
    }
  }
} 