import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:unp_calendario/shared/utils/date_formatter.dart';
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
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

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
  
  // Inicializar _canEditGeneral como true si se está creando un evento nuevo
  // para que el campo de descripción esté habilitado desde el inicio
  bool get _canEditGeneralInitial => widget.event == null;
  
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
    'color2', // Color por defecto (mismo que W1)
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
    _selectedColor = widget.event?.commonPart?.customColor ?? 'color2';
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
    
    // Si es un evento nuevo, permitir edición desde el inicio
    final isCreating = widget.event == null;
    if (isCreating) {
      _canEditGeneral = true;
    }
    
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    // Mostrar indicador de carga mientras se inicializan los permisos
    if (_isInitializing) {
      return Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade800,
          title: Text(
            widget.event == null ? AppLocalizations.of(context)!.createEvent : AppLocalizations.of(context)!.editEvent,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColorScheme.color2),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.initializingPermissions,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Theme(
      data: AppTheme.darkTheme,
      child: AlertDialog(
        backgroundColor: Colors.grey.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        insetPadding: isMobile 
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        title: Row(
          children: [
            Flexible(
              child: Text(
                widget.event == null ? AppLocalizations.of(context)!.createEvent : AppLocalizations.of(context)!.editEvent,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (_isCreator || _isAdmin) const SizedBox(width: 8),
            // Badge de Creador
            if (_isCreator) 
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                color: AppColorScheme.color2, // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColorScheme.color2, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: isMobile ? 12 : 14, color: Colors.white),
                    if (!isMobile) ...[
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.creator,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (_isCreator && _isAdmin) const SizedBox(width: 6),
            // Badge de Admin
            if (_isAdmin) 
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade600,
                      Colors.red.shade600.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade600, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.admin_panel_settings, size: isMobile ? 12 : 14, color: Colors.white),
                    if (!isMobile) ...[
                      const SizedBox(width: 4),
                      Text(
                        'Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 520,
          child: DefaultTabController(
          length: _isAdmin ? 3 : 2,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TabBar(
                labelColor: AppColorScheme.color2,
                unselectedLabelColor: Colors.grey.shade400,
                indicatorColor: AppColorScheme.color2,
                labelStyle: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'General'),
                  Tab(text: 'Mi información'),
                  if (_isAdmin) Tab(text: 'Info de Otros'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SizedBox(
                  height: isMobile ? MediaQuery.of(context).size.height * 0.6 : 520,
                  child: TabBarView(
                    children: [
                      // Tab 1: General (Parte Común)
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Indicador de permisos
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.shade800,
                                  const Color(0xFF2C2C2C),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _canEditGeneral 
                                    ? AppColorScheme.color2.withOpacity(0.5)
                                    : Colors.grey.shade700.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _canEditGeneral ? Icons.lock_open : Icons.lock,
                                  size: 16,
                                  color: _canEditGeneral ? AppColorScheme.color2 : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _canEditGeneral ? 'Puedes editar esta información' : 'Solo lectura - información común',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: _canEditGeneral ? Colors.white : Colors.grey.shade400,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
            // Descripción
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade700.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: TextFormField(
                controller: _descriptionController,
                readOnly: !(_canEditGeneral || _canEditGeneralInitial),
                maxLines: 2,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.eventDescription,
                  hintText: AppLocalizations.of(context)!.eventDescriptionHint,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(Icons.title, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColorScheme.color2,
                      width: 2.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 2.5,
                    ),
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                ),
                validator: (value) {
                  if (!_canEditGeneral) return null;
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'La descripción es obligatoria';
                  if (v.length < 3) return 'Mínimo 3 caracteres';
                  if (v.length > 1000) return 'Máximo 1000 caracteres';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Tipo de familia
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade700.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: _typeFamilyController.text.isEmpty || !_typeFamilies.contains(_typeFamilyController.text) 
                    ? null 
                    : _typeFamilyController.text,
                dropdownColor: Colors.grey.shade800,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.eventType,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(Icons.category, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColorScheme.color2,
                      width: 2.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 2.5,
                    ),
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                ),
                items: _typeFamilies.map((family) {
                  return DropdownMenuItem(
                    value: family,
                    child: Text(
                      family,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: _canEditGeneral ? (value) {
                  setState(() {
                    _typeFamilyController.text = value ?? '';
                    _typeSubtypeController.text = ''; // Reset subtipo
                  });
                } : null,
                validator: (value) {
                  if (!_canEditGeneral) return null;
                  // Tipo es opcional, pero si hay subtipo, debe haber tipo válido
                  if ((_typeSubtypeController.text.isNotEmpty) && (value == null || !_typeFamilies.contains(value))) {
                    return AppLocalizations.of(context)!.selectValidTypeFirst;
                  }
                  return null;
                },
              ),
            ),
              const SizedBox(height: 16),
            
            // Subtipo
            if (_typeFamilyController.text.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800, // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade700.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _typeSubtypeController.text.isEmpty || 
                         !(_typeSubtypes[_typeFamilyController.text] ?? []).contains(_typeSubtypeController.text)
                      ? null 
                      : _typeSubtypeController.text,
                  dropdownColor: Colors.grey.shade800,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.eventSubtype,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(Icons.label, color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColorScheme.color2,
                        width: 2.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.red.shade400,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.red.shade400,
                        width: 2.5,
                      ),
                    ),
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  ),
                  items: (_typeSubtypes[_typeFamilyController.text] ?? []).map((subtype) {
                    return DropdownMenuItem(
                      value: subtype,
                      child: Text(
                        subtype,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _canEditGeneral ? (value) {
                    setState(() {
                      _typeSubtypeController.text = value ?? '';
                    });
                  } : null,
                  validator: (value) {
                    if (!_canEditGeneral) return null;
                    // Subtipo es opcional, pero si hay valor debe pertenecer a la lista
                    if (value != null && !(_typeSubtypes[_typeFamilyController.text] ?? []).contains(value)) {
                      return AppLocalizations.of(context)!.invalidSubtype;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
            
            // Borrador - Switch estilo iOS
            SwitchListTile.adaptive(
              title: Text(
                AppLocalizations.of(context)!.isDraft,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(context)!.isDraftSubtitle,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
              value: _isDraft,
              activeColor: AppColorScheme.color2,
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
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800, // Color sólido, sin gradiente
                  border: Border.all(
                    color: Colors.grey.shade700.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColorScheme.color2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.date,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormatter.formatDate(_selectedDate),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
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
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800, // Color sólido, sin gradiente
                  border: Border.all(
                    color: Colors.grey.shade700.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppColorScheme.color2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hora de inicio',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedHour.toString().padLeft(2, '0')}:${_selectedStartMinute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
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
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800, // Color sólido, sin gradiente
                  border: Border.all(
                    color: Colors.grey.shade700.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: AppColorScheme.color2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duración',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(_selectedDurationMinutes),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade700.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedTimezone,
                dropdownColor: Colors.grey.shade800,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.timezone,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(Icons.public, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColorScheme.color2,
                      width: 2.5,
                    ),
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                ),
                items: TimezoneService.getCommonTimezones().map((tz) {
                  return DropdownMenuItem(
                    value: tz,
                    child: Text(
                      TimezoneService.getTimezoneDisplayName(tz),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: _canEditGeneral ? (value) {
                  setState(() {
                    _selectedTimezone = value ?? 'Europe/Madrid';
                  });
                } : null,
              ),
            ),
            const SizedBox(height: 12),
            
            // Timezone de llegada (solo para vuelos/viajes)
            if (_typeFamilyController.text == 'Desplazamiento' && _typeSubtypeController.text == 'Avión')
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800, // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade700.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedArrivalTimezone,
                  dropdownColor: Colors.grey.shade800,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.arrivalTimezone,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(Icons.flight_land, color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColorScheme.color2,
                        width: 2.5,
                      ),
                    ),
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  ),
                  items: TimezoneService.getCommonTimezones().map((tz) {
                    return DropdownMenuItem(
                      value: tz,
                      child: Text(
                        TimezoneService.getTimezoneDisplayName(tz),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _canEditGeneral ? (value) {
                    setState(() {
                      _selectedArrivalTimezone = value ?? 'Europe/Madrid';
                    });
                  } : null,
                ),
              ),
            const SizedBox(height: 12),
            
            // Límite de participantes (T117)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade700.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: TextFormField(
                controller: _maxParticipantsController,
                readOnly: !_canEditGeneral,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: 'Límite de participantes (opcional)',
                  hintText: 'Ej: 10 (dejar vacío para sin límite)',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(Icons.people_outline, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColorScheme.color2,
                      width: 2.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 2.5,
                    ),
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                ),
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
            ),
            const SizedBox(height: 16),
            
            // Requiere confirmación (T120 Fase 2)
            if (_canEditGeneral)
              CheckboxListTile(
                title: Text(
                  AppLocalizations.of(context)!.requiresConfirmation,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.requiresConfirmationSubtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                value: _requiresConfirmation,
                activeColor: AppColorScheme.color2,
                onChanged: (value) {
                  setState(() {
                    _requiresConfirmation = value ?? false;
                  });
                },
                secondary: Icon(Icons.assignment_turned_in_outlined, color: AppColorScheme.color2),
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
                  color: Colors.grey.shade800, // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColorScheme.color2.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline, color: AppColorScheme.color2, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.participantsRegistered,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
              leading: Icon(Icons.palette, color: AppColorScheme.color2),
              title: Text(
                'Color',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                              ? Border.all(color: Colors.white, width: 2.5)
                              : Border.all(
                                  color: Colors.grey.shade600,
                                  width: 1,
                                ),
                          boxShadow: _selectedColor == colorName
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
                        ],
                      ),
                    ),
                  // Tab "Mi información"
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Información personal para este evento',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Asiento
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.shade800,
                                  const Color(0xFF2C2C2C),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade700.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _asientoController,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.seat,
                                hintText: AppLocalizations.of(context)!.seatHint,
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                prefixIcon: Icon(Icons.chair, color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: AppColorScheme.color2,
                                    width: 2.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                    width: 2.5,
                                  ),
                                ),
                                fillColor: Colors.transparent,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              ),
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) return null;
                                if (v.length > 50) return 'Máximo 50 caracteres';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Menú/Comida
                          _buildPersonalTextField(
                            controller: _menuController,
                            labelText: AppLocalizations.of(context)!.menu,
                            hintText: AppLocalizations.of(context)!.menuHint,
                            icon: Icons.restaurant,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return null;
                              if (v.length > 100) return 'Máximo 100 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Preferencias
                          _buildPersonalTextField(
                            controller: _preferenciasController,
                            labelText: AppLocalizations.of(context)!.preferences,
                            hintText: AppLocalizations.of(context)!.preferencesHint,
                            icon: Icons.favorite,
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
                          _buildPersonalTextField(
                            controller: _numeroReservaController,
                            labelText: AppLocalizations.of(context)!.reservationNumber,
                            hintText: AppLocalizations.of(context)!.reservationNumberHint,
                            icon: Icons.confirmation_number,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return null;
                              if (v.length > 50) return 'Máximo 50 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Puerta/Gate
                          _buildPersonalTextField(
                            controller: _gateController,
                            labelText: AppLocalizations.of(context)!.gate,
                            hintText: AppLocalizations.of(context)!.gateHint,
                            icon: Icons.door_front_door,
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
                            title: Text(
                              AppLocalizations.of(context)!.cardObtained,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context)!.cardObtainedSubtitle,
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                            value: _tarjetaObtenida,
                            activeColor: AppColorScheme.color2,
                            onChanged: (value) {
                              setState(() {
                                _tarjetaObtenida = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo: Notas personales
                          _buildPersonalTextField(
                            controller: _notasPersonalesController,
                            labelText: AppLocalizations.of(context)!.personalNotes,
                            hintText: 'Información adicional solo para ti',
                            icon: Icons.note,
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
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.shade800,
                                  const Color(0xFF2C2C2C),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColorScheme.color2.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColorScheme.color2),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Esta información es solo tuya. Otros participantes no la verán.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
              style: GoogleFonts.poppins(
                color: Colors.red.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        
        // Botón cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Botón guardar / aceptar en verde (T209)
        Container(
          decoration: BoxDecoration(
                color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade600.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _canSaveEvent() ? _saveEvent : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              widget.event == null ? AppLocalizations.of(context)!.create : AppLocalizations.of(context)!.save,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No hay otros participantes en este evento',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade800,
                  const Color(0xFF2C2C2C),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.orange.shade400.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.orange.shade300),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Como administrador, puedes ver y editar la información personal de otros participantes.',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            const Color(0xFF2C2C2C),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColorScheme.color2),
                const SizedBox(width: 8),
                FutureBuilder<String>(
                  future: _getUserDisplayName(participantId),
                  builder: (context, snapshot) {
                    final displayName = snapshot.data ?? participantId;
                    return Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                color: AppColorScheme.color2, // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorScheme.color2.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _editParticipantInfo(participantId),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(
                    AppLocalizations.of(context)!.editInfo,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800, // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade700.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.grey.shade400, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Sin permisos para editar',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

  /// Construye un campo de texto personal con estilo base
  Widget _buildPersonalTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            const Color(0xFF2C2C2C),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColorScheme.color2,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 2.5,
            ),
          ),
          fillColor: Colors.transparent,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
        validator: validator,
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
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'No especificado',
              style: GoogleFonts.poppins(
                color: value != null ? Colors.white : Colors.grey.shade500,
                fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
                fontSize: 13,
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
    final greenTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.green.shade600),
    );
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedStartMinute),
      builder: (context, child) => Theme(data: greenTheme, child: child!),
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
      builder: (context) => Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Duración',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Opciones rápidas comunes (hasta 3 horas = 180 min)
                Text(
                  'Duración común:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(12, (index) {
                  final minutes = (index + 1) * 15; // 15, 30, 45, 60, 75, 90, etc.
                  return ListTile(
                    title: Text(
                      _formatDuration(minutes),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(minutes),
                  );
                }),
                const Divider(color: Colors.grey),
                // Opciones personalizadas (hasta 24 horas)
                Text(
                  'Duraciones largas:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(21, (index) {
                  final hours = index + 4; // 4h, 5h, 6h... hasta 24h
                  final minutes = hours * 60;
                  return ListTile(
                    title: Text(
                      _formatDuration(minutes),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(minutes),
                    trailing: hours == 24 
                        ? Text(
                            '(máximo)',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          )
                        : null,
                  );
                }),
                const Divider(color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '💡 Eventos máximo 24h.\nSi necesitas más → usa Alojamientos',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
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
            content: Text(
              blockedReason ?? 'No se pueden eliminar eventos en el estado actual del plan.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade800,
          title: Text(
            AppLocalizations.of(context)!.confirmDeleteTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar el evento "${widget.event?.description}"?',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.shade600,
                    Colors.red.shade600.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade600.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.delete,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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
      return Text(
        '⚠️ No hay planId disponible',
        style: GoogleFonts.poppins(
          color: Colors.orange.shade400,
          fontSize: 12,
        ),
      );
    }
    
    final currentUser = ref.read(currentUserProvider);
    final currentUserId = currentUser?.id;
    
    // Obtener participantes reales del plan (excluye observadores)
    final participantsAsync = ref.watch(planRealParticipantsProvider(widget.planId!));
    
    return participantsAsync.when(
      data: (participations) {
        if (participations.isEmpty) {
          return Text(
            'No hay participantes en este plan',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox principal "Este evento es para todos" (T47)
            CheckboxListTile(
              title: Text(
                'Este evento es para todos los participantes del plan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                _isForAllParticipants 
                    ? 'Todos los participantes estarán incluidos automáticamente'
                    : 'Selecciona participantes específicos abajo',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
              value: _isForAllParticipants,
              activeColor: AppColorScheme.color2,
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
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            
            // Lista de participantes (solo visible si checkbox principal está desmarcado)
            if (!_isForAllParticipants) ...[
              Text(
                'Seleccionar participantes:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
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
                      title: Text(
                        participantName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: isSelected,
                      activeColor: AppColorScheme.color2,
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
                                SnackBar(
                                  content: Text(
                                    'Debe haber al menos un participante seleccionado',
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red.shade600,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        });
                      },
                      secondary: isEventCreator 
                          ? Icon(Icons.person, color: Colors.orange.shade300)
                          : null,
                      subtitle: isEventCreator 
                          ? Text(
                              'Creador del evento',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade400,
                              ),
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
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ],
        );
      },
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(color: AppColorScheme.color2),
        ),
      ),
      error: (error, stackTrace) => Text(
        'Error al cargar participantes: $error',
        style: GoogleFonts.poppins(
          color: Colors.red.shade400,
          fontSize: 12,
        ),
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
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF2C2C2C),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade700.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
                  value: _costCurrency ?? _planCurrency ?? 'EUR',
                  dropdownColor: Colors.grey.shade800,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Moneda del coste',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      _getCurrencyIcon(_costCurrency ?? _planCurrency ?? 'EUR'),
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColorScheme.color2,
                        width: 2.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  ),
                  items: Currency.supportedCurrencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency.code,
                      child: Text(
                        '${currency.code} - ${currency.symbol} ${currency.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
        const SizedBox(height: 12),
        
        // Campo de coste
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF2C2C2C),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade700.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _costController,
            enabled: _canEditGeneral,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: 'Coste del evento (opcional)',
              hintText: 'Ej: 150.50',
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              prefixIcon: Icon(
                _getCurrencyIcon(_costCurrency ?? _planCurrency ?? 'EUR'),
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColorScheme.color2,
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.red.shade400,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.red.shade400,
                  width: 2.5,
                ),
              ),
              fillColor: Colors.transparent,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            ),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColorScheme.color2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calculando...',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              if (snapshot.hasData && snapshot.data != null) {
                final convertedAmount = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade800,
                        const Color(0xFF2C2C2C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColorScheme.color2.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColorScheme.color2),
                          const SizedBox(width: 4),
                          Text(
                            'Convertido a ${_planCurrency}:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatterService.formatAmount(convertedAmount, _planCurrency!),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColorScheme.color2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '⚠️ Los tipos de cambio son orientativos. El valor real será el aplicado por tu banco o tarjeta de crédito al momento del pago.',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade400,
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
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.orange.shade400,
                    ),
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
          SnackBar(
            content: Text(
              'No tienes permisos para editar este evento',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La descripción es obligatoria',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      return;
    }

    // Validación de participantes (T47)
    // Si no está marcado "para todos", debe haber al menos un participante seleccionado
    if (!_isForAllParticipants && _selectedParticipantIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Debes seleccionar al menos un participante',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      return;
    }

    // Validar que el evento no dure más de 24 horas
    if (_selectedDurationMinutes > 1440) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Un evento no puede durar más de 24 horas.\n\n'
              '• Si es alojamiento → usa la fila de Alojamientos\n'
              '• Si son actividades diferentes → crea eventos separados por día',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade600,
            duration: const Duration(seconds: 6),
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
                SnackBar(
                  content: Text(
                    '✅ Plan expandido exitosamente',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  backgroundColor: Colors.green.shade600,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (!success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '⚠️ Error al expandir el plan',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  backgroundColor: Colors.orange.shade600,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            // Usuario canceló la expansión, no guardar el evento
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.eventNotSaved,
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  backgroundColor: Colors.grey.shade800,
                  duration: const Duration(seconds: 2),
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