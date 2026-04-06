import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
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
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/event/event_participant_registration_widget.dart';
import 'package:unp_calendario/shared/utils/plan_range_utils.dart';
import 'package:unp_calendario/widgets/dialogs/expand_plan_dialog.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/shared/services/exchange_rate_service.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_file_service.dart';
import 'package:unp_calendario/widgets/plan/entity_attachments_section.dart';
import 'package:unp_calendario/features/places/data/places_api_service.dart';
import 'package:unp_calendario/features/places/presentation/widgets/place_autocomplete_field.dart';
import 'package:unp_calendario/features/flights/data/flight_status_service.dart';
import 'package:unp_calendario/features/flights/data/flight_status_result.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/input/text_field_clear_suffix.dart';
import 'package:unp_calendario/features/payments/presentation/widgets/add_expense_dialog.dart';
import 'package:unp_calendario/features/payments/presentation/providers/payment_providers.dart';

class EventDialog extends ConsumerStatefulWidget {
  final Event? event;
  final String? planId;
  final DateTime? initialDate;
  final int? initialHour;

  /// Minuto de inicio si se fija [initialHour] desde fuera (p. ej. FAB con plan en curso = ahora).
  final int? initialStartMinute;
  final Function(Event)? onSaved;
  final Function(String)? onDeleted;

  const EventDialog({
    super.key,
    this.event,
    this.planId,
    this.initialDate,
    this.initialHour,
    this.initialStartMinute,
    this.onSaved,
    this.onDeleted,
  });

  @override
  ConsumerState<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends ConsumerState<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;

  /// Notas largas / texto de agencia (commonPart.notes).
  late TextEditingController _longNotesController;
  late TextEditingController
      _locationController; // T225: lugar del evento (Places)
  late TextEditingController _urlController; // Enlace web del evento
  PlaceDetails?
      _lastPlaceDetails; // T225: último lugar seleccionado (para lat/lng en extraData)
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
  String?
      _costCurrency; // T153: Moneda local del coste (null = moneda del plan)
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

  /// T252: Participante creando evento nuevo → solo puede guardar como propuesta (borrador).
  bool get _isParticipantCreatingProposal {
    final user = ref.read(currentUserProvider);
    return _plan != null &&
        user != null &&
        widget.event == null &&
        _plan!.userId != user.id;
  }

  // Campos de información personal
  late TextEditingController _asientoController;
  late TextEditingController _menuController;
  late TextEditingController _preferenciasController;
  late TextEditingController _numeroReservaController;
  late TextEditingController _gateController;
  late TextEditingController _notasPersonalesController;
  // T49: "Mi información" para eventos de tipo Actividad (código o documento).
  late TextEditingController _activityEntryCodeController;
  late TextEditingController _activityEntryDocUrlController;
  late bool _tarjetaObtenida;
  // T246: número de vuelo (Desplazamiento / Avión)
  late TextEditingController _flightNumberController;
  late TextEditingController _departureAirportController;
  late TextEditingController _arrivalAirportController;
  PlaceDetails? _departureAirportDetails;
  PlaceDetails? _arrivalAirportDetails;

  /// Taxi (Desplazamiento / Taxi): origen, destino y plazas.
  late TextEditingController _taxiOriginController;
  late TextEditingController _taxiDestinationController;
  PlaceDetails? _taxiOriginDetails;
  PlaceDetails? _taxiDestinationDetails;
  double? _taxiOriginStoredLat;
  double? _taxiOriginStoredLng;
  double? _taxiDestinationStoredLat;
  double? _taxiDestinationStoredLng;
  int _taxiSeats = 4;
  /// Shuttle / Transfer (Desplazamiento): terminal, aerolínea, presentación en aeropuerto (lista §3.2 ítem 90).
  late TextEditingController _transferTerminalController;
  late TextEditingController _transferAirlineController;
  late TextEditingController _transferAirportMeetController;
  FlightStatusResult? _lastFlightStatus;
  bool _flightStatusLoading = false;

  /// Evita doble envío si el usuario pulsa Crear/Guardar varias veces con red lenta (lista §3.2 ítem 89).
  bool _isSavingEvent = false;

  // T247: conexión a proveedor externo (evento conectado)
  Map<String, dynamic>? _initialConnection;
  DateTime? _initialCommonDate;
  int? _initialCommonStartHour;
  int? _initialCommonStartMinute;
  int? _initialCommonDurationMinutes;
  String? _initialFlightNumber;
  bool _disconnectConnection = false;

  /// Adjuntos (PDF/JPG/PNG) guardados en `Event.documents`.
  List<EventDocument> _eventDocuments = [];
  bool _uploadingEventAttachment = false;

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
    'Acción',
    'Otro',
  ];

  // Subtipos por familia
  final Map<String, List<String>> _typeSubtypes = {
    'Desplazamiento': [
      'Taxi',
      'Avión',
      'Tren',
      'Autobús',
      'Coche',
      'Caminar',
      'Shuttle',
      'Transfer'
    ],
    'Restauración': ['Desayuno', 'Comida', 'Cena', 'Snack', 'Bebida'],
    'Actividad': [
      'Concierto',
      'Deporte',
      'Disfrutar hotel',
      'Monumento',
      'Museo',
      'Parque',
      'Teatro',
      'Tour',
    ],
    'Acción': [
      'Embarque',
      'Entrega vehículo alquiler',
      'Fin viaje',
      'Inicio viaje',
      'Otro',
      'Punto de encuentro',
      'Recogida vehículo alquiler',
    ],
    'Otro': ['Compra', 'Reunión', 'Trabajo', 'Personal'],
  };

  /// Iconos por tipo de evento (familia).
  static const Map<String, IconData> _typeIcons = {
    'Desplazamiento': Icons.directions_car,
    'Restauración': Icons.restaurant,
    'Actividad': Icons.local_activity,
    'Acción': Icons.touch_app,
    'Otro': Icons.more_horiz,
  };

  /// Iconos por subtipo (clave: 'Tipo|Subtipo' para desambiguar).
  static const Map<String, IconData> _subtypeIcons = {
    'Desplazamiento|Taxi': Icons.local_taxi,
    'Desplazamiento|Avión': Icons.flight,
    'Desplazamiento|Tren': Icons.train,
    'Desplazamiento|Autobús': Icons.directions_bus,
    'Desplazamiento|Coche': Icons.directions_car,
    'Desplazamiento|Caminar': Icons.directions_walk,
    'Desplazamiento|Shuttle': Icons.airport_shuttle,
    'Desplazamiento|Transfer': Icons.airport_shuttle,
    'Restauración|Desayuno': Icons.free_breakfast,
    'Restauración|Comida': Icons.lunch_dining,
    'Restauración|Cena': Icons.dinner_dining,
    'Restauración|Snack': Icons.cookie,
    'Restauración|Bebida': Icons.local_bar,
    'Actividad|Museo': Icons.museum,
    'Actividad|Monumento': Icons.account_balance,
    'Actividad|Parque': Icons.park,
    'Actividad|Teatro': Icons.theater_comedy,
    'Actividad|Concierto': Icons.music_note,
    'Actividad|Deporte': Icons.sports_soccer,
    'Actividad|Disfrutar hotel': Icons.hotel,
    'Actividad|Tour': Icons.explore,
    'Acción|Embarque': Icons.directions_boat,
    // Valores legados (Firestore) hasta que se reediten y guarden con el nuevo texto
    'Acción|Recogida': Icons.shopping_bag,
    'Acción|Entrega': Icons.inventory_2,
    'Acción|Recogida vehículo alquiler': Icons.shopping_bag,
    'Acción|Entrega vehículo alquiler': Icons.inventory_2,
    'Acción|Fin viaje': Icons.flag,
    'Acción|Inicio viaje': Icons.flag_outlined,
    'Acción|Punto de encuentro': Icons.place,
    'Acción|Otro': Icons.more_horiz,
    'Otro|Compra': Icons.shopping_cart,
    'Otro|Reunión': Icons.groups,
    'Otro|Trabajo': Icons.work,
    'Otro|Personal': Icons.person,
  };

  /// Selector gráfico tipo/subtipo: true = mostrar rejilla de tipos.
  bool _typePickerExpanded = true;

  /// Selector gráfico subtipo: true = mostrar rejilla de subtipos (cuando hay tipo).
  bool _subtypePickerExpanded = true;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores
    _descriptionController = TextEditingController(
      text: widget.event?.commonPart?.description ?? '',
    );
    _longNotesController = TextEditingController(
      text: widget.event?.commonPart?.notes ?? '',
    );
    _eventDocuments =
        List<EventDocument>.from(widget.event?.documents ?? const []);
    _locationController = TextEditingController(
      text: widget.event?.commonPart?.location ?? '',
    );
    _urlController = TextEditingController(
      text: widget.event?.commonPart?.url ?? '',
    );
    final initialFamily = widget.event?.commonPart?.family ?? '';
    var initialSubtype = widget.event?.commonPart?.subtype ?? '';
    // §3.2 ítem 95: renombre subtipos alquiler; normalizar legado al abrir
    if (initialFamily == 'Acción') {
      if (initialSubtype == 'Recogida') {
        initialSubtype = 'Recogida vehículo alquiler';
      } else if (initialSubtype == 'Entrega') {
        initialSubtype = 'Entrega vehículo alquiler';
      }
    }
    _typeFamilyController = TextEditingController(text: initialFamily);
    _typeSubtypeController = TextEditingController(text: initialSubtype);

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
    _activityEntryCodeController = TextEditingController(
      text: personalFields['ticketCode'] ?? '',
    );
    _activityEntryDocUrlController = TextEditingController(
      text: personalFields['ticketDocUrl'] ?? '',
    );
    _tarjetaObtenida = personalFields['tarjetaObtenida'] ?? false;
    _flightNumberController = TextEditingController(
      text:
          widget.event?.commonPart?.extraData?['flightNumber'] as String? ?? '',
    );
    final ed = widget.event?.commonPart?.extraData;
    final depAirport = ed?['departureAirport'] as String? ??
        ed?['originName'] as String? ??
        '';
    final arrAirport = ed?['arrivalAirport'] as String? ??
        ed?['destinationName'] as String? ??
        '';
    _departureAirportController = TextEditingController(text: depAirport);
    _arrivalAirportController = TextEditingController(text: arrAirport);
    _taxiOriginController = TextEditingController(
      text: ed?['taxiOriginAddress'] as String? ?? '',
    );
    _taxiDestinationController = TextEditingController(
      text: ed?['taxiDestinationAddress'] as String? ?? '',
    );
    final oLat = ed?['taxiOriginLat'];
    final oLng = ed?['taxiOriginLng'];
    final dLat = ed?['taxiDestinationLat'];
    final dLng = ed?['taxiDestinationLng'];
    if (oLat != null) _taxiOriginStoredLat = (oLat as num).toDouble();
    if (oLng != null) _taxiOriginStoredLng = (oLng as num).toDouble();
    if (dLat != null) _taxiDestinationStoredLat = (dLat as num).toDouble();
    if (dLng != null) _taxiDestinationStoredLng = (dLng as num).toDouble();
    final seats = ed?['taxiSeats'];
    if (seats != null) {
      if (seats is int) {
        _taxiSeats = seats.clamp(1, 9);
      } else if (seats is num) {
        _taxiSeats = seats.toInt().clamp(1, 9);
      }
    }
    _transferTerminalController = TextEditingController(
      text: ed?['transferTerminal'] as String? ?? '',
    );
    _transferAirlineController = TextEditingController(
      text: ed?['transferAirline'] as String? ?? '',
    );
    _transferAirportMeetController = TextEditingController(
      text: ed?['transferAirportMeet'] as String? ?? '',
    );
    if (ed != null && ed['flightNumber'] != null) {
      _lastFlightStatus = FlightStatusResult(
        flightNumber: ed['flightNumber'] as String? ?? '',
        carrierCode: ed['carrierCode'] as String?,
        originIata: ed['originIata'] as String?,
        destinationIata: ed['destinationIata'] as String?,
        originName: ed['originName'] as String?,
        destinationName: ed['destinationName'] as String?,
        departureScheduled: ed['departureScheduled'] as String?,
        arrivalScheduled: ed['arrivalScheduled'] as String?,
        durationMinutes: ed['durationMinutes'] as int?,
        airlineName: ed['airlineName'] as String?,
      );
    }

    // T247: guardar estado inicial de conexión y campos sincronizados
    _initialConnection = widget.event?.commonPart?.connection;
    _initialCommonDate = widget.event?.commonPart?.date;
    _initialCommonStartHour = widget.event?.commonPart?.startHour;
    _initialCommonStartMinute = widget.event?.commonPart?.startMinute;
    _initialCommonDurationMinutes = widget.event?.commonPart?.durationMinutes;
    _initialFlightNumber = ed != null ? ed['flightNumber'] as String? : null;
    // Inicializar valores
    _selectedDate =
        widget.initialDate ?? widget.event?.commonPart?.date ?? DateTime.now();
    final depStr = ed?['departureScheduled'] as String?;
    if (depStr != null && depStr.isNotEmpty) {
      final dt = DateTime.tryParse(depStr);
      if (dt != null) {
        // Fecha del vuelo = fecha del evento; ya actualizada arriba si Amadeus devolvió hora salida
      }
    }
    _selectedHour =
        widget.initialHour ?? widget.event?.commonPart?.startHour ?? 9;
    _selectedDuration = (widget.event?.commonPart?.durationMinutes ?? 60) ~/ 60;
    _selectedStartMinute =
        widget.initialStartMinute ?? widget.event?.commonPart?.startMinute ?? 0;
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
    _selectedParticipantIds =
        List.from(existingCommonPart?.participantIds ?? []);

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

    // Selector gráfico tipo/subtipo: colapsar si ya hay selección
    _typePickerExpanded = _typeFamilyController.text.isEmpty;
    _subtypePickerExpanded = _typeSubtypeController.text.isEmpty &&
        _typeFamilyController.text.isNotEmpty;
  }

  /// T247: Manejar aviso de desconexión de eventos conectados a proveedores externos.
  Future<bool> _handleConnectionBeforeSave() async {
    // Si no había conexión previa, nada que hacer
    if (_initialConnection == null) {
      _disconnectConnection = false;
      return true;
    }
    final provider = _initialConnection!['provider'] as String?;
    // Por ahora solo tratamos Amadeus (vuelos)
    if (provider != 'amadeus') {
      _disconnectConnection = false;
      return true;
    }

    bool changed = false;
    if (_initialCommonDate != null && _selectedDate != _initialCommonDate) {
      changed = true;
    }
    if (_initialCommonStartHour != null &&
        _selectedHour != _initialCommonStartHour) {
      changed = true;
    }
    if (_initialCommonStartMinute != null &&
        _selectedStartMinute != _initialCommonStartMinute) {
      changed = true;
    }
    if (_initialCommonDurationMinutes != null &&
        _selectedDurationMinutes != _initialCommonDurationMinutes) {
      changed = true;
    }
    final currentFlightNumber = _flightNumberController.text.trim();
    final initialFlightNumber = _initialFlightNumber?.trim() ?? '';
    if (currentFlightNumber != initialFlightNumber) {
      changed = true;
    }

    if (!changed) {
      _disconnectConnection = false;
      return true;
    }

    // Mostrar diálogo de confirmación
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Evento conectado',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Este evento está conectado a Amadeus (datos de vuelo).\n\n'
          'Si continúas, se desconectará y dejará de actualizarse desde el proveedor.\n\n'
          '¿Quieres continuar y desconectar, o cancelar para mantener la conexión?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade200,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColorScheme.color2,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Desconectar y continuar',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      // Usuario acepta desconectar
      _disconnectConnection = true;
      return true;
    } else {
      // Usuario cancela, no guardar
      _disconnectConnection = false;
      return false;
    }
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
      final currentUser = ref.read(currentUserProvider);
      if (plan != null && mounted) {
        setState(() {
          _plan = plan;
          // Zona horaria del plan por defecto en eventos nuevos (lista puntos P24).
          if (widget.event == null &&
              plan.timezone != null &&
              plan.timezone!.trim().isNotEmpty) {
            _selectedTimezone = plan.timezone!;
            _selectedArrivalTimezone = plan.timezone!;
          }
          // T252: Si es participante creando evento nuevo, solo puede ser borrador (propuesta)
          if (widget.event == null &&
              currentUser != null &&
              plan.userId != currentUser.id) {
            _isDraft = true;
          }
          // T252: El organizador debe poder ver el selector borrador/confirmado en cualquier evento (p. ej. para aceptar propuestas)
          if (currentUser != null && plan.userId == currentUser.id) {
            _canEditGeneral = true;
          }
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
    _userPermissions ??= PlanPermissions(
      // Por defecto, asumir que es participante si no hay permisos específicos
      planId: widget.planId!,
      userId: currentUser.id,
      role: UserRole.participant,
      permissions:
          DefaultPermissions.getDefaultPermissions(UserRole.participant),
      assignedAt: DateTime.now(),
    );

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
    _longNotesController.dispose();
    _locationController.dispose();
    _urlController.dispose();
    _typeFamilyController.dispose();
    _typeSubtypeController.dispose();
    _asientoController.dispose();
    _menuController.dispose();
    _preferenciasController.dispose();
    _numeroReservaController.dispose();
    _gateController.dispose();
    _notasPersonalesController.dispose();
    _activityEntryCodeController.dispose();
    _activityEntryDocUrlController.dispose();
    _flightNumberController.dispose();
    _departureAirportController.dispose();
    _arrivalAirportController.dispose();
    _taxiOriginController.dispose();
    _taxiDestinationController.dispose();
    _transferTerminalController.dispose();
    _transferAirlineController.dispose();
    _transferAirportMeetController.dispose();
    _maxParticipantsController.dispose();
    _costController.dispose(); // T101
    super.dispose();
  }

  /// Decoración tipo login: fondo sólido, borde y sombra (estética unificada).
  BoxDecoration _buildLoginStyleDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade800,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade700.withValues(alpha: 0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 3),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 6,
          offset: const Offset(0, 1),
          spreadRadius: -2,
        ),
      ],
    );
  }

  /// Decoración para campos con título sobre el borde (sin sombra).
  BoxDecoration get _borderedFieldDecoration => BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withValues(alpha: 0.5),
          width: 1,
        ),
      );

  /// Estilo del título que va sobre el borde del campo.
  TextStyle get _labelOnBorderStyle => GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w500,
      );

  /// Campo con título sobre el borde superior (formato unificado Descripción, Timezone, etc.).
  /// [contentPadding] por defecto (18) para campos estándar; (8) para campos con icono/botón a la derecha.
  Widget _buildLabelOnBorderField({
    required String label,
    required Widget child,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final padding = contentPadding ??
        const EdgeInsets.only(top: 14, left: 18, right: 18, bottom: 18);
    return Container(
      decoration: _borderedFieldDecoration,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 14,
            top: -7,
            child: Container(
              color: Colors.grey.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(label, style: _labelOnBorderStyle),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }

  /// Envuelve [child] en una capa que, si no puede editar (solo lectura), muestra SnackBar al tocar.
  Widget _wrapReadOnlyIfNeeded({required Widget child}) {
    if (_canEditGeneral) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showReadOnlySnackBar,
            ),
          ),
        ),
      ],
    );
  }

  void _showReadOnlySnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.eventReadOnlySnackBar,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Un solo campo: dirección del evento (Places) + acceso a Maps con marcador.
  /// Se usa solo cuando el evento NO es Desplazamiento (para eventos localizados: 1 dirección).
  /// Dentro del campo se muestra "Localización".
  Widget _buildUnifiedLocationField() {
    final loc = AppLocalizations.of(context)!;
    final hasCoords = _lastPlaceDetails?.lat != null ||
        (widget.event?.commonPart?.extraData?['placeLat'] != null);
    final hasAddress = _locationController.text.trim().isNotEmpty;
    final canOpenMaps = hasCoords || hasAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlaceAutocompleteField(
          controller: _locationController,
          initialAddress: widget.event?.commonPart?.location,
          lodgingOnly: false,
          labelText: loc.eventAddressSingleLabel,
          hintText: loc.eventAddressSingleHint,
          fontSize: 12,
          onPlaceSelected: (PlaceDetails details) {
            setState(() {
              _lastPlaceDetails = details;
              final addr = details.formattedAddress;
              _locationController.text = (addr != null &&
                      addr.isNotEmpty &&
                      addr != details.displayName)
                  ? '${details.displayName}, $addr'
                  : details.displayName;
            });
          },
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(Icons.location_on,
                color:
                    canOpenMaps ? AppColorScheme.color2 : Colors.grey.shade600),
            tooltip: loc.openInGoogleMaps,
            onPressed: canOpenMaps ? _openLocationInGoogleMaps : null,
          ),
        ),
      ],
    );
  }

  Widget _buildNonTransportTimezoneSelector() {
    final loc = AppLocalizations.of(context)!;
    return _buildLabelOnBorderField(
      label: loc.timezone,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${TimezoneService.getTimezoneCityName(_selectedTimezone)} (${TimezoneService.getUtcOffsetFormatted(_selectedTimezone)})',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildFlightTimezoneCircle(
            timezone: _selectedTimezone,
            tooltip:
                '${loc.timezone}: ${TimezoneService.getTimezoneCityName(_selectedTimezone)} (${TimezoneService.getUtcOffsetFormatted(_selectedTimezone)})',
            onTap: _canEditGeneral
                ? () => _openFlightTimezonePicker(isArrival: false)
                : _showReadOnlySnackBar,
          ),
        ],
      ),
    );
  }

  Widget _buildIsForAllParticipantsSelector() {
    final loc = AppLocalizations.of(context)!;
    return _wrapReadOnlyIfNeeded(
      child: _buildLabelOnBorderField(
        label: loc.eventDialogParticipantsScopeLabel,
        contentPadding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
        child: CheckboxTheme(
          data: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColorScheme.color2;
              }
              return Colors.grey.shade700;
            }),
            side: BorderSide(color: Colors.grey.shade500, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: CheckboxListTile(
            title: Text(
              loc.eventDialogForAllParticipantsTitle,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _isForAllParticipants
                    ? loc.eventDialogForAllParticipantsSubtitleOn
                    : loc.eventDialogForAllParticipantsSubtitleOff,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ),
            value: _isForAllParticipants,
            onChanged: _canEditGeneral
                ? (value) {
                    setState(() {
                      _isForAllParticipants = value ?? true;
                      if (_isForAllParticipants) {
                        _selectedParticipantIds.clear();
                      }
                    });
                  }
                : null,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            horizontalTitleGap: 10,
          ),
        ),
      ),
    );
  }

  /// Campo opcional: enlace web del evento (p. ej. reserva, web del lugar).
  Widget _buildUrlField() {
    final loc = AppLocalizations.of(context)!;
    return _buildLabelOnBorderField(
      label: loc.eventUrlLabel,
      child: TextFormField(
        controller: _urlController,
        readOnly: !_canEditGeneral,
        decoration: InputDecoration(
          hintText: loc.eventUrlHint,
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          counterText: '',
        ),
        keyboardType: TextInputType.url,
        maxLength: 500,
        maxLines: 1,
      ),
    );
  }

  Future<void> _openLongNotesEditor() async {
    final loc = AppLocalizations.of(context)!;
    final tempController =
        TextEditingController(text: _longNotesController.text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            loc.eventLongNotesLabel,
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 680,
            child: TextFormField(
              controller: tempController,
              minLines: 8,
              maxLines: 16,
              readOnly: !_canEditGeneral,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: loc.eventLongNotesLabel,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: _canEditGeneral
                  ? () => Navigator.of(context).pop(tempController.text)
                  : null,
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
    tempController.dispose();
    if (!mounted || result == null) return;
    setState(() {
      _longNotesController.text = result;
    });
  }

  Future<void> _pickEventAttachment() async {
    final planId = widget.planId;
    if (planId == null) return;
    final picked = await PlanFileService.pickAttachment();
    if (picked == null) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.entityAttachmentsReadError,
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }
    final validationError = PlanFileService.validateAttachment(picked);
    if (validationError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError,
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }
    setState(() => _uploadingEventAttachment = true);
    try {
      final uploaded = await PlanFileService.uploadAttachment(
        planId: planId,
        file: picked,
        filenamePrefix: 'evt',
      );
      if (!mounted) return;
      setState(() {
        _eventDocuments = [
          ..._eventDocuments,
          EventDocument.fromPlanAttachment(uploaded)
        ];
      });
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.entityAttachmentsUploadError('$e'),
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingEventAttachment = false);
    }
  }

  Future<void> _deleteEventAttachment(EventDocument doc) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final loc = AppLocalizations.of(ctx)!;
            return Theme(
              data: AppTheme.darkTheme,
              child: AlertDialog(
                backgroundColor: Colors.grey.shade900,
                title: Text(loc.entityAttachmentsDeleteTitle,
                    style: GoogleFonts.poppins(color: Colors.white)),
                content: Text(
                  loc.entityAttachmentsDeleteConfirm(doc.name),
                  style: GoogleFonts.poppins(color: Colors.grey.shade300),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(loc.cancel)),
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(loc.delete)),
                ],
              ),
            );
          },
        ) ??
        false;
    if (!confirm) return;
    setState(() => _uploadingEventAttachment = true);
    try {
      await PlanFileService.deleteAttachment(doc.url);
      if (!mounted) return;
      setState(() {
        _eventDocuments =
            _eventDocuments.where((d) => d.url != doc.url).toList();
      });
    } catch (_) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.entityAttachmentsDeleteError,
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingEventAttachment = false);
    }
  }

  /// Selector gráfico de tipo y subtipo de evento (iconos + chips con "+" para reabrir).
  Widget _buildTypeSubtypeSelector() {
    final loc = AppLocalizations.of(context)!;
    final narrow = MediaQuery.sizeOf(context).width < 520;
    final typeGridAspect = narrow ? 2.05 : 2.65;
    final hasType = _typeFamilyController.text.isNotEmpty &&
        _typeFamilies.contains(_typeFamilyController.text);
    final subtypes = hasType
        ? (_typeSubtypes[_typeFamilyController.text] ?? [])
        : <String>[];
    // Mostrar siempre tipo + subtipo cuando hay texto de subtipo (evita que solo quede visible el subtipo).
    final hasSubtype = _typeSubtypeController.text.trim().isNotEmpty;

    if (!_canEditGeneral) {
      return _buildLabelOnBorderField(
        label: loc.eventType,
        contentPadding:
            const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasType || hasSubtype)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasType)
                    _buildTypeSubtypeChip(
                      label: _typeFamilyController.text,
                      icon: _typeIcons[_typeFamilyController.text] ??
                          Icons.category,
                    ),
                  if (hasSubtype)
                    _buildTypeSubtypeChip(
                      label: _typeSubtypeController.text,
                      icon: _subtypeIcons[
                              '${_typeFamilyController.text}|${_typeSubtypeController.text}'] ??
                          Icons.label,
                    ),
                ],
              )
            else
              Text(
                '—',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      );
    }

    return _buildLabelOnBorderField(
      label: loc.eventType,
      contentPadding:
          const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_typePickerExpanded) ...[
            Builder(
              builder: (context) {
                final sortedFamilies = [..._typeFamilies]
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: typeGridAspect,
                  ),
                  itemCount: sortedFamilies.length,
                  itemBuilder: (context, index) {
                    final family = sortedFamilies[index];
                    final selected = _typeFamilyController.text == family;
                    return _buildTypeSubtypeChip(
                      label: family,
                      icon: _typeIcons[family] ?? Icons.category,
                      selected: selected,
                      onTap: () {
                        setState(() {
                          _typeFamilyController.text = family;
                          _typeSubtypeController.text = '';
                          _typePickerExpanded = false;
                          _subtypePickerExpanded = true;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ] else ...[
            if (hasType && _subtypePickerExpanded) ...[
              _buildTypeSubtypeChip(
                label: _typeFamilyController.text,
                icon: _typeIcons[_typeFamilyController.text] ?? Icons.category,
                selected: true,
                showPlus: true,
                onTap: () {
                  setState(() {
                    _typePickerExpanded = true;
                    _subtypePickerExpanded = false;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                loc.eventSubtype,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final sortedSubtypes = [
                    ...subtypes
                  ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: typeGridAspect,
                    ),
                    itemCount: sortedSubtypes.length,
                    itemBuilder: (context, index) {
                      final subtype = sortedSubtypes[index];
                      final selected = _typeSubtypeController.text == subtype;
                      return _buildTypeSubtypeChip(
                        label: subtype,
                        icon: _subtypeIcons[
                                '${_typeFamilyController.text}|$subtype'] ??
                            Icons.label,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            _typeSubtypeController.text = subtype;
                            _subtypePickerExpanded = false;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ] else ...[
              // P19: Wrap evita que Expanded recorte el tipo cuando hay subtipo
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildTypeSubtypeChip(
                    label: _typeFamilyController.text,
                    icon: _typeIcons[_typeFamilyController.text] ??
                        Icons.category,
                    selected: true,
                    showPlus: true,
                    onTap: () {
                      setState(() {
                        _typePickerExpanded = true;
                        _subtypePickerExpanded = false;
                      });
                    },
                  ),
                  if (hasSubtype)
                    _buildTypeSubtypeChip(
                      label: _typeSubtypeController.text,
                      icon: _subtypeIcons[
                              '${_typeFamilyController.text}|${_typeSubtypeController.text}'] ??
                          Icons.label,
                      selected: true,
                      showPlus: true,
                      onTap: () {
                        setState(() => _subtypePickerExpanded = true);
                      },
                    )
                  else
                    _buildTypeSubtypeChip(
                      label: loc.chooseSubtypeLabel,
                      icon: Icons.add,
                      selected: false,
                      showPlus: false,
                      onTap: () {
                        setState(() => _subtypePickerExpanded = true);
                      },
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSubtypeChip({
    required String label,
    required IconData icon,
    bool selected = false,
    bool showPlus = false,
    VoidCallback? onTap,
  }) {
    final color = selected ? AppColorScheme.color2 : Colors.grey.shade700;
    final borderColor = selected ? AppColorScheme.color2 : Colors.grey.shade600;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20,
                  color:
                      selected ? AppColorScheme.color2 : Colors.grey.shade400),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : Colors.grey.shade300,
                  ),
                ),
              ),
              if (showPlus) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: selected ? Colors.white : Colors.grey.shade500,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea horarios de salida/llegada para la tarjeta del vuelo (T246).
  String _formatFlightTimes(String? depIso, String? arrIso) {
    final dep =
        depIso != null && depIso.isNotEmpty ? DateTime.tryParse(depIso) : null;
    final arr =
        arrIso != null && arrIso.isNotEmpty ? DateTime.tryParse(arrIso) : null;
    if (dep != null && arr != null) {
      return '${DateFormatter.formatTimeOnly(dep)} – ${DateFormatter.formatTimeOnly(arr)}';
    }
    if (dep != null) return DateFormatter.formatTimeOnly(dep);
    if (arr != null) return DateFormatter.formatTimeOnly(arr);
    return '';
  }

  /// Construye la descripción a guardar: si el usuario rellenó el campo, se usa; si no, se genera solo a partir de subtipo y ubicación.
  String _buildDescriptionForSave() {
    final userDesc = _descriptionController.text.trim();
    if (userDesc.isNotEmpty) return userDesc;

    final family = _typeFamilyController.text.trim();
    final subtype = _typeSubtypeController.text.trim();
    const maxPart = 50; // truncar partes largas (ej. direcciones)

    String short(String s) =>
        s.length <= maxPart ? s : '${s.substring(0, maxPart)}…';

    // Vuelo: usar descripción de Amadeus si existe, si no "Vuelo salida → llegada"
    if (family == 'Desplazamiento' && subtype == 'Avión') {
      final fromAmadeus = _lastFlightStatus?.shortDescription.trim();
      if (fromAmadeus != null && fromAmadeus.isNotEmpty) return fromAmadeus;
      final dep = _departureAirportController.text.trim();
      final arr = _arrivalAirportController.text.trim();
      if (dep.isNotEmpty && arr.isNotEmpty) {
        return 'Vuelo ${short(dep)} → ${short(arr)}';
      }
      return subtype.isNotEmpty ? subtype : 'Vuelo';
    }

    // Otro desplazamiento (taxi, tren, etc.): solo subtipo y opcionalmente origen → destino
    if (family == 'Desplazamiento' && subtype.isNotEmpty) {
      final origin = _taxiOriginController.text.trim();
      final dest = _taxiDestinationController.text.trim();
      if (origin.isNotEmpty && dest.isNotEmpty) {
        return '$subtype · ${short(origin)} → ${short(dest)}';
      }
      if (subtype == 'Shuttle' || subtype == 'Transfer') {
        final term = _transferTerminalController.text.trim();
        final air = _transferAirlineController.text.trim();
        final bits = <String>[];
        if (term.isNotEmpty) bits.add(term);
        if (air.isNotEmpty) bits.add(air);
        if (bits.isNotEmpty) return '$subtype · ${bits.join(' · ')}';
      }
      return subtype;
    }

    // Evento con localización única
    final location = _locationController.text.trim();
    if (location.isNotEmpty) {
      if (subtype.isNotEmpty) return '$subtype · ${short(location)}';
      return short(location);
    }

    // Sin ubicación: solo subtipo
    if (subtype.isNotEmpty) return subtype;
    return 'Evento';
  }

  /// Bloque Origen + Destino (+ opcionalmente Plazas) para Desplazamiento (Taxi, Tren, Autobús, Coche, Caminar).
  /// Origen y Destino con el mismo formato (título sobre el borde) que Descripción y Timezone.
  /// [showPlazas] true solo para Taxi.
  Widget _buildTransportOriginDestinationBlock({required bool showPlazas}) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Origen
        _buildLabelOnBorderField(
          label: loc.taxiOriginLabel,
          contentPadding:
              const EdgeInsets.only(top: 14, left: 8, right: 0, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PlaceAutocompleteField(
                  controller: _taxiOriginController,
                  initialAddress: null,
                  lodgingOnly: false,
                  labelText: '',
                  hintText: loc.taxiOriginHint,
                  fontSize: 12,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  onPlaceSelected: (PlaceDetails details) {
                    setState(() {
                      _taxiOriginDetails = details;
                      final addr = details.formattedAddress;
                      _taxiOriginController.text = (addr != null &&
                              addr.isNotEmpty &&
                              addr != details.displayName)
                          ? '${details.displayName}, $addr'
                          : details.displayName;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.map_outlined,
                  color: (_taxiOriginDetails != null ||
                          _taxiOriginController.text.trim().isNotEmpty)
                      ? AppColorScheme.color2
                      : Colors.grey.shade600,
                ),
                tooltip: loc.openInGoogleMaps,
                onPressed: () => _openTaxiAddressInMaps(
                  _taxiOriginController.text.trim(),
                  _taxiOriginDetails?.lat ?? _taxiOriginStoredLat,
                  _taxiOriginDetails?.lng ?? _taxiOriginStoredLng,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Destino
        _buildLabelOnBorderField(
          label: loc.taxiDestinationLabel,
          contentPadding:
              const EdgeInsets.only(top: 14, left: 8, right: 0, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PlaceAutocompleteField(
                  controller: _taxiDestinationController,
                  initialAddress: null,
                  lodgingOnly: false,
                  labelText: '',
                  hintText: loc.taxiDestinationHint,
                  fontSize: 12,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  onPlaceSelected: (PlaceDetails details) {
                    setState(() {
                      _taxiDestinationDetails = details;
                      final addr = details.formattedAddress;
                      _taxiDestinationController.text = (addr != null &&
                              addr.isNotEmpty &&
                              addr != details.displayName)
                          ? '${details.displayName}, $addr'
                          : details.displayName;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.map_outlined,
                  color: (_taxiDestinationDetails != null ||
                          _taxiDestinationController.text.trim().isNotEmpty)
                      ? AppColorScheme.color2
                      : Colors.grey.shade600,
                ),
                tooltip: loc.openInGoogleMaps,
                onPressed: () => _openTaxiAddressInMaps(
                  _taxiDestinationController.text.trim(),
                  _taxiDestinationDetails?.lat ?? _taxiDestinationStoredLat,
                  _taxiDestinationDetails?.lng ?? _taxiDestinationStoredLng,
                ),
              ),
            ],
          ),
        ),
        if (showPlazas) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _taxiSeats.clamp(1, 9),
            decoration: InputDecoration(
              labelText: loc.taxiSeatsLabel,
              hintText: loc.taxiSeatsHint,
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(Icons.airline_seat_recline_normal,
                  color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            dropdownColor: Colors.grey.shade800,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            items: List.generate(9, (i) => i + 1).map((n) {
              return DropdownMenuItem<int>(value: n, child: Text('$n'));
            }).toList(),
            onChanged: _canEditGeneral
                ? (int? value) {
                    if (value != null) setState(() => _taxiSeats = value);
                  }
                : null,
          ),
        ],
      ],
    );
  }

  /// Campos extra para Shuttle / Transfer hacia/desde aeropuerto (ítem 90).
  Widget _buildGroundTransferAirportExtraFields() {
    final loc = AppLocalizations.of(context)!;
    final ro = !(_canEditGeneral || _canEditGeneralInitial);
    InputDecoration deco(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade500,
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
          fillColor: Colors.transparent,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabelOnBorderField(
          label: loc.eventTransferTerminalLabel,
          contentPadding:
              const EdgeInsets.only(top: 14, left: 8, right: 8, bottom: 8),
          child: TextFormField(
            controller: _transferTerminalController,
            readOnly: ro,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: deco(loc.eventTransferTerminalHint),
          ),
        ),
        const SizedBox(height: 12),
        _buildLabelOnBorderField(
          label: loc.eventTransferAirlineLabel,
          contentPadding:
              const EdgeInsets.only(top: 14, left: 8, right: 8, bottom: 8),
          child: TextFormField(
            controller: _transferAirlineController,
            readOnly: ro,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: deco(loc.eventTransferAirlineHint),
          ),
        ),
        const SizedBox(height: 12),
        _buildLabelOnBorderField(
          label: loc.eventTransferAirportMeetLabel,
          contentPadding:
              const EdgeInsets.only(top: 14, left: 8, right: 8, bottom: 8),
          child: TextFormField(
            controller: _transferAirportMeetController,
            readOnly: ro,
            minLines: 1,
            maxLines: 2,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: deco(loc.eventTransferAirportMeetHint),
          ),
        ),
      ],
    );
  }

  /// Lista §3.2 ítem 108: prueba estática de patrocinio contextual.
  /// Solo UI; no hay red publicitaria ni tracking en esta fase.
  Widget _buildStaticSponsorCard() {
    final loc = AppLocalizations.of(context)!;
    final subtype = _typeSubtypeController.text.trim();
    final sponsor = _getStaticSponsorForSubtype(subtype);
    if (sponsor == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorScheme.color2.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorScheme.color2.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_outlined, size: 18, color: AppColorScheme.color2),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  loc.eventSponsoredBy(sponsor.name),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                loc.eventSponsoredTag,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColorScheme.color2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            loc.eventSponsoredStaticHint,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _openSponsoredLink(sponsor.url),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(loc.eventSponsoredOpenOffer),
            ),
          ),
        ],
      ),
    );
  }

  _StaticSponsorData? _getStaticSponsorForSubtype(String subtype) {
    switch (subtype) {
      case 'Taxi':
        return const _StaticSponsorData(name: 'FreeNow', url: 'https://www.free-now.com');
      case 'Avión':
        return const _StaticSponsorData(name: 'eDreams', url: 'https://www.edreams.es');
      case 'Coche':
        return const _StaticSponsorData(name: 'Avis', url: 'https://www.avis.com');
      case 'Shuttle':
      case 'Transfer':
        return const _StaticSponsorData(name: 'Uber', url: 'https://www.uber.com');
      default:
        return null;
    }
  }

  Future<void> _openSponsoredLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.eventSponsoredOpenError)),
    );
  }

  Future<void> _openTaxiAddressInMaps(
      String address, double? lat, double? lng) async {
    String url;
    if (lat != null && lng != null) {
      url = 'https://www.google.com/maps?q=$lat,$lng';
    } else if (address.isNotEmpty) {
      url =
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    } else {
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Campo Fecha / Hora / Duración con título sobre el borde.
  Widget _buildWhenField({
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isMobile,
    required double fsBody,
  }) {
    return _buildLabelOnBorderField(
      label: label,
      contentPadding: EdgeInsets.only(
          left: 8, right: 8, top: 14, bottom: isMobile ? 10 : 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: fsBody,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// P13: Timezone con el mismo patrón que el resto de campos (título sobre el borde).
  /// [compact] para la columna estrecha junto a aeropuertos en vuelos.
  Widget _buildTimezoneFieldOnBorder({
    required String label,
    required String value,
    required void Function(String?)? onChanged,
    bool compact = false,
    IconData? leadingIcon,
    bool showCityInMenuAndGmtSelected = false,
  }) {
    final fs = compact ? 11.0 : 13.0;
    final pad = compact
        ? const EdgeInsets.only(top: 8, left: 4, right: 4, bottom: 8)
        : const EdgeInsets.only(top: 10, left: 6, right: 8, bottom: 10);
    final commonTimezones =
        TimezoneService.getCommonTimezones().toSet().toList();
    // Evita assertion del Dropdown cuando el valor actual (p. ej. "UTC")
    // no está en la lista común o hay duplicados.
    if (value.trim().isNotEmpty &&
        !commonTimezones.contains(value) &&
        TimezoneService.isValidTimezone(value)) {
      commonTimezones.insert(0, value);
    }
    final safeValue =
        commonTimezones.contains(value) ? value : commonTimezones.first;
    final dropdown = DropdownButtonFormField<String>(
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: Colors.grey.shade800,
      style: GoogleFonts.poppins(
          fontSize: fs, color: Colors.white, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        filled: false,
      ),
      icon: Icon(Icons.arrow_drop_down,
          color: Colors.grey.shade400, size: compact ? 20 : 24),
      selectedItemBuilder: showCityInMenuAndGmtSelected
          ? (context) => commonTimezones.map((tz) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimezoneService.getUtcOffsetFormatted(tz),
                    style: GoogleFonts.poppins(
                        fontSize: fs,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList()
          : null,
      items: commonTimezones.map((tz) {
        return DropdownMenuItem<String>(
          value: tz,
          child: showCityInMenuAndGmtSelected
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        TimezoneService.getTimezoneCityName(tz),
                        style: GoogleFonts.poppins(
                          fontSize: fs,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      TimezoneService.getUtcOffsetFormatted(tz),
                      style: GoogleFonts.poppins(
                        fontSize: fs - 1,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Text(
                  TimezoneService.getUtcOffsetFormatted(tz),
                  style: GoogleFonts.poppins(
                      fontSize: fs,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
        );
      }).toList(),
      onChanged: onChanged,
    );

    return _buildLabelOnBorderField(
      label: label,
      contentPadding: pad,
      child: leadingIcon != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(leadingIcon,
                    size: compact ? 18 : 20, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Expanded(child: dropdown),
              ],
            )
          : dropdown,
    );
  }

  String _timezoneOffsetBadge(String timezone) {
    final gmt = TimezoneService.getUtcOffsetFormatted(timezone);
    return gmt.startsWith('GMT') ? gmt.replaceFirst('GMT', '') : gmt;
  }

  Future<void> _openFlightTimezonePicker({required bool isArrival}) async {
    if (!_canEditGeneral) return;
    final selected = isArrival ? _selectedArrivalTimezone : _selectedTimezone;
    final all = TimezoneService.getCommonTimezones();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.grey.shade900,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: all.length,
          itemBuilder: (context, index) {
            final tz = all[index];
            return ListTile(
              dense: true,
              selected: tz == selected,
              leading: Icon(
                Icons.public,
                color: tz == selected
                    ? AppColorScheme.color2
                    : Colors.grey.shade400,
              ),
              title: Text(
                TimezoneService.getTimezoneCityName(tz),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: Text(
                TimezoneService.getUtcOffsetFormatted(tz),
                style: GoogleFonts.poppins(
                  color: tz == selected
                      ? AppColorScheme.color2
                      : Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => Navigator.of(context).pop(tz),
            );
          },
        ),
      ),
    );
    if (!mounted || picked == null) return;
    setState(() {
      if (isArrival) {
        _selectedArrivalTimezone = picked;
      } else {
        _selectedTimezone = picked;
      }
    });
  }

  Widget _buildFlightTimezoneCircle({
    required String timezone,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColorScheme.color2.withValues(alpha: 0.18),
              border:
                  Border.all(color: AppColorScheme.color2.withValues(alpha: 0.65)),
            ),
            alignment: Alignment.center,
            child: Text(
              _timezoneOffsetBadge(timezone),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// T246: Bloque número de vuelo + botón Obtener datos (Amadeus).
  /// Aeropuertos con Google Places (formato título sobre el borde); timezone salida/llegada al lado de cada uno.
  Widget _buildFlightNumberBlock() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Aeropuerto de origen
        _buildLabelOnBorderField(
          label: loc.departureAirportLabel,
          contentPadding:
              const EdgeInsets.only(top: 14, left: 8, right: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PlaceAutocompleteField(
                  controller: _departureAirportController,
                  initialAddress: null,
                  lodgingOnly: false,
                  labelText: '',
                  hintText: loc.departureAirportHint,
                  fontSize: 12,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  onPlaceSelected: (PlaceDetails details) {
                    setState(() {
                      _departureAirportDetails = details;
                      final addr = details.formattedAddress;
                      _departureAirportController.text = (addr != null &&
                              addr.isNotEmpty &&
                              addr != details.displayName)
                          ? '${details.displayName}, $addr'
                          : details.displayName;
                    });
                    _autodetectFlightTimezoneFromPlace(
                      details: details,
                      isArrival: false,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              _buildFlightTimezoneCircle(
                timezone: _selectedTimezone,
                tooltip:
                    '${loc.timezone}: ${TimezoneService.getTimezoneCityName(_selectedTimezone)} (${TimezoneService.getUtcOffsetFormatted(_selectedTimezone)})',
                onTap: () => _openFlightTimezonePicker(isArrival: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Aeropuerto de destino
        _buildLabelOnBorderField(
          label: loc.arrivalAirportLabel,
          contentPadding:
              const EdgeInsets.only(top: 14, left: 8, right: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PlaceAutocompleteField(
                  controller: _arrivalAirportController,
                  initialAddress: null,
                  lodgingOnly: false,
                  labelText: '',
                  hintText: loc.arrivalAirportHint,
                  fontSize: 12,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  onPlaceSelected: (PlaceDetails details) {
                    setState(() {
                      _arrivalAirportDetails = details;
                      final addr = details.formattedAddress;
                      _arrivalAirportController.text = (addr != null &&
                              addr.isNotEmpty &&
                              addr != details.displayName)
                          ? '${details.displayName}, $addr'
                          : details.displayName;
                    });
                    _autodetectFlightTimezoneFromPlace(
                      details: details,
                      isArrival: true,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              _buildFlightTimezoneCircle(
                timezone: _selectedArrivalTimezone,
                tooltip:
                    '${loc.arrivalTimezone}: ${TimezoneService.getTimezoneCityName(_selectedArrivalTimezone)} (${TimezoneService.getUtcOffsetFormatted(_selectedArrivalTimezone)})',
                onTap: () => _openFlightTimezonePicker(isArrival: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _flightNumberController,
                readOnly: !_canEditGeneral,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: loc.flightNumberLabel,
                  hintText: loc.flightNumberHint,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(Icons.flight, color: Colors.grey.shade400),
                  suffixIcon: _canEditGeneral
                      ? IconButton(
                          onPressed:
                              _flightStatusLoading ? null : _fetchFlightStatus,
                          icon: _flightStatusLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColorScheme.color2,
                                  ),
                                )
                              : Icon(Icons.search, color: Colors.grey.shade400),
                          tooltip: loc.getFlightDataButton,
                        )
                      : null,
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _lastFlightStatus != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _lastFlightStatus!.shortDescription,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_lastFlightStatus!.departureScheduled != null ||
                            _lastFlightStatus!.arrivalScheduled != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatFlightTimes(
                              _lastFlightStatus!.departureScheduled,
                              _lastFlightStatus!.arrivalScheduled,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _fetchFlightStatus() async {
    final number = _flightNumberController.text.trim();
    if (number.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.flightNumberRequired,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }
      return;
    }
    setState(() => _flightStatusLoading = true);
    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final result = await FlightStatusService().getFlightStatus(
        flightNumber: number,
        date: dateStr,
      );
      if (!mounted) return;
      if (result == null) {
        setState(() => _flightStatusLoading = false);
        return;
      }
      setState(() {
        _lastFlightStatus = result;
        _flightStatusLoading = false;
        _descriptionController.text = result.shortDescription;
        // Rellenar aeropuertos desde Amadeus (originName/originIata, destinationName/destinationIata)
        _departureAirportController.text =
            result.originName ?? result.originIata ?? '';
        _arrivalAirportController.text =
            result.destinationName ?? result.destinationIata ?? '';
        final dep = result.departureScheduled;
        final arr = result.arrivalScheduled;
        if (dep != null && dep.isNotEmpty) {
          final dt = DateTime.tryParse(dep);
          if (dt != null) {
            _selectedDate = DateTime(dt.year, dt.month, dt.day);
            _selectedHour = dt.hour;
            _selectedStartMinute = dt.minute;
          }
        }
        if (result.durationMinutes != null && result.durationMinutes! > 0) {
          _selectedDurationMinutes = result.durationMinutes!;
          _selectedDuration = _selectedDurationMinutes ~/ 60;
        } else if (arr != null &&
            arr.isNotEmpty &&
            dep != null &&
            dep.isNotEmpty) {
          final start = DateTime.tryParse(dep);
          final end = DateTime.tryParse(arr);
          if (start != null && end != null && end.isAfter(start)) {
            _selectedDurationMinutes = end.difference(start).inMinutes;
            _selectedDuration = _selectedDurationMinutes ~/ 60;
          }
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.flightDataLoaded,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _flightStatusLoading = false);
      final msg = e.message ?? e.code;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _flightStatusLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Future<void> _autodetectFlightTimezoneFromPlace({
    required PlaceDetails details,
    required bool isArrival,
  }) async {
    final lat = details.lat;
    final lng = details.lng;
    if (lat == null || lng == null) return;

    final service = PlacesApiService(
      apiKey: const String.fromEnvironment('PLACES_API_KEY', defaultValue: ''),
    );
    final detectedTimezone = await service.getTimezoneForCoordinates(
      lat: lat,
      lng: lng,
      dateTime: _selectedDate,
    );
    if (!mounted || detectedTimezone == null || detectedTimezone.trim().isEmpty) {
      return;
    }

    final normalizedTimezone =
        TimezoneService.normalizeToCommonTimezone(detectedTimezone);
    setState(() {
      if (isArrival) {
        _selectedArrivalTimezone = normalizedTimezone;
      } else {
        _selectedTimezone = normalizedTimezone;
      }
    });
  }

  /// Abre la ubicación en Google Maps (por coordenadas o por búsqueda de dirección).
  Future<void> _openLocationInGoogleMaps() async {
    final lat = _lastPlaceDetails?.lat ??
        (widget.event?.commonPart?.extraData?['placeLat'] as num?)?.toDouble();
    final lng = _lastPlaceDetails?.lng ??
        (widget.event?.commonPart?.extraData?['placeLng'] as num?)?.toDouble();
    final locationText = _locationController.text.trim();
    final address = _lastPlaceDetails?.formattedAddress ??
        widget.event?.commonPart?.extraData?['placeAddress'] as String? ??
        (locationText.isNotEmpty
            ? locationText
            : widget.event?.commonPart?.location);
    final String url;
    if (lat != null && lng != null) {
      url = 'https://www.google.com/maps?q=$lat,$lng';
    } else if (address != null && address.isNotEmpty) {
      url =
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    } else {
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildDraftStatusOption({
    required String label,
    required bool selected,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? Colors.white.withValues(alpha: 0.35) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 14, vertical: isMobile ? 6 : 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 11 : 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Lista §3.2 ítem 102: acceso a añadir gasto ligado al evento (solo si ya tiene id y hay plan).
  List<Widget>? _eventDialogLinkedExpenseBarActions(bool isMobile) {
    final planId = widget.planId;
    final eventId = widget.event?.id;
    if (planId == null || eventId == null || eventId.isEmpty) return null;
    final loc = AppLocalizations.of(context)!;
    return [
      IconButton(
        icon: Icon(Icons.receipt_long_outlined,
            size: isMobile ? 20 : 22, color: Colors.white),
        tooltip: loc.eventDialogAddLinkedExpenseTooltip,
        onPressed: _openAddExpenseLinkedToThisEvent,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    ];
  }

  Future<void> _openAddExpenseLinkedToThisEvent() async {
    final planId = widget.planId;
    final eventId = widget.event?.id;
    if (!mounted || planId == null || eventId == null || eventId.isEmpty) {
      return;
    }
    final planService = ref.read(planServiceProvider);
    final plan = await planService.getPlanById(planId);
    if (!mounted || plan == null || plan.id == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => AddExpenseDialog(
          plan: plan,
          initialEventId: eventId,
          onSaved: () {
            ref.invalidate(paymentSummaryProvider(plan.id!));
          },
        ),
      ),
    );
  }

  /// T238: Barra verde superior del modal (UI estándar).
  /// Si [showDraftSwitch] es true, se muestra el selector Borrador/Confirmado alineado a la derecha.
  /// En móvil puede mostrarse [showCloseButton] para cerrar el modal.
  Widget _buildEventDialogGreenBar(
    BuildContext context,
    String title, {
    required bool isMobile,
    required bool showBadges,
    bool showDraftSwitch = false,
    bool isDraft = false,
    ValueChanged<bool>? onDraftChanged,
    bool showCloseButton = false,
    VoidCallback? onClose,
    List<Widget>? trailingActions,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF79A2A8),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isMobile ? 0 : 18),
        ),
      ),
      child: Row(
        children: [
          if (showCloseButton && onClose != null) ...[
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 14 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (trailingActions != null) ...trailingActions,
          if (showBadges && _isCreator) ...[
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white54, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person,
                      size: isMobile ? 12 : 14, color: Colors.white),
                  if (!isMobile) ...[
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.creator,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (showBadges && _isCreator && _isAdmin) const SizedBox(width: 6),
          if (showBadges && _isAdmin)
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade700.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white54, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.admin_panel_settings,
                      size: isMobile ? 12 : 14, color: Colors.white),
                  if (!isMobile) ...[
                    const SizedBox(width: 4),
                    Text(
                      'Admin',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          if (showDraftSwitch && onDraftChanged != null) ...[
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white54, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDraftStatusOption(
                    label: AppLocalizations.of(context)!.eventStatusDraft,
                    selected: isDraft,
                    isMobile: isMobile,
                    onTap: () => onDraftChanged(true),
                  ),
                  _buildDraftStatusOption(
                    label: AppLocalizations.of(context)!.eventStatusConfirmed,
                    selected: !isDraft,
                    isMobile: isMobile,
                    onTap: () => onDraftChanged(false),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// T252: Mensaje en el modal cuando un participante crea un evento (solo propuesta/borrador).
  Widget _buildProposalHint(BuildContext context, bool isMobile) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding:
          EdgeInsets.fromLTRB(isMobile ? 12 : 20, 8, isMobile ? 12 : 20, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColorScheme.color2.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColorScheme.color2.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline,
                size: isMobile ? 20 : 22, color: AppColorScheme.color2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loc.eventProposalParticipantHint,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 13,
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Mostrar indicador de carga mientras se inicializan los permisos
    if (_isInitializing) {
      final title = widget.event == null
          ? AppLocalizations.of(context)!.createEvent
          : AppLocalizations.of(context)!.editEvent;
      return Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 0 : 18),
          ),
          insetPadding: isMobile
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          title: null,
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: isMobile ? MediaQuery.sizeOf(context).width : null,
            height: isMobile ? MediaQuery.sizeOf(context).height * 0.4 : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildEventDialogGreenBar(context, title,
                    isMobile: isMobile, showBadges: false),
                Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                          color: AppColorScheme.color2),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        AppLocalizations.of(context)!.initializingPermissions,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dialogTitle = widget.event == null
        ? AppLocalizations.of(context)!.createEvent
        : AppLocalizations.of(context)!.editEvent;
    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    // El AlertDialog coloca [content] y luego [actions] en columna. Si el content ocupa
    // casi toda la pantalla, la fila Eliminar/Cancelar/Guardar queda fuera del viewport o
    // bajo el área táctil (p. ej. Chrome estrecho / móvil). Reservar altura para acciones + safe area.
    const actionsRowReserve = 112.0;
    final contentHeight = isMobile
        ? (screenSize.height - padding.vertical - 64 - actionsRowReserve)
            .clamp(240.0, 9000.0)
        : null;
    final contentWidth = isMobile ? screenSize.width : null;

    return Theme(
      data: AppTheme.darkTheme,
      child: AlertDialog(
        scrollable: true,
        backgroundColor: Colors.grey.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 0 : 18),
        ),
        insetPadding: isMobile
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        title: null,
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: contentWidth,
          height: contentHeight,
          child: Column(
            mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEventDialogGreenBar(
                context,
                dialogTitle,
                isMobile: isMobile,
                showBadges: true,
                showDraftSwitch:
                    _canEditGeneral && !_isParticipantCreatingProposal,
                isDraft: _isDraft,
                onDraftChanged: (value) => setState(() => _isDraft = value),
                showCloseButton: isMobile,
                onClose: () => Navigator.of(context).pop(),
                trailingActions: _eventDialogLinkedExpenseBarActions(isMobile),
              ),
              if (_isParticipantCreatingProposal)
                _buildProposalHint(context, isMobile),
              isMobile
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                        child: Form(
                          key: _formKey,
                          child: SizedBox(
                            width: double.infinity,
                            child: DefaultTabController(
                              length: _isAdmin ? 3 : 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final tabController =
                                          DefaultTabController.of(context);
                                      final tabLabels = [
                                        AppLocalizations.of(context)!
                                            .eventTabGeneral,
                                        AppLocalizations.of(context)!
                                            .eventTabMyInfo,
                                        if (_isAdmin)
                                          AppLocalizations.of(context)!
                                              .eventTabOthersInfo,
                                      ].whereType<String>().toList();
                                      return ListenableBuilder(
                                        listenable: tabController,
                                        builder: (context, _) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6),
                                            child: Row(
                                              children: List.generate(
                                                  tabController.length, (i) {
                                                final isSelected =
                                                    tabController.index == i;
                                                return Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 2),
                                                    child: _EventTabChip(
                                                      label: tabLabels[i],
                                                      isSelected: isSelected,
                                                      isMobile: true,
                                                      onTap: () => tabController
                                                          .animateTo(i),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: TabBarView(
                                      children:
                                          _buildEventTabViews(isMobile: true),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 540,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Form(
                          key: _formKey,
                          child: SizedBox(
                            width: 520,
                            child: DefaultTabController(
                              length: _isAdmin ? 3 : 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final tabController =
                                          DefaultTabController.of(context);
                                      final tabLabels = [
                                        AppLocalizations.of(context)!
                                            .eventTabGeneral,
                                        AppLocalizations.of(context)!
                                            .eventTabMyInfo,
                                        if (_isAdmin)
                                          AppLocalizations.of(context)!
                                              .eventTabOthersInfo,
                                      ].whereType<String>().toList();
                                      return ListenableBuilder(
                                        listenable: tabController,
                                        builder: (context, _) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Row(
                                              children: List.generate(
                                                  tabController.length, (i) {
                                                final isSelected =
                                                    tabController.index == i;
                                                return Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4),
                                                    child: _EventTabChip(
                                                      label: tabLabels[i],
                                                      isSelected: isSelected,
                                                      isMobile: false,
                                                      onTap: () => tabController
                                                          .animateTo(i),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: TabBarView(
                                      children:
                                          _buildEventTabViews(isMobile: false),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
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
                  color: Colors.green.shade600.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed:
                  (_canSaveEvent() && !_isSavingEvent) ? _saveEvent : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSavingEvent
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.event == null
                          ? AppLocalizations.of(context)!.create
                          : AppLocalizations.of(context)!.save,
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

  /// Lista de pestañas del formulario (General, Mi información, [Otros]). Compartido entre móvil y desktop.
  List<Widget> _buildEventTabViews({required bool isMobile}) {
    return [
      _buildGeneralTabScroll(isMobile),
      _buildMyInfoTabScroll(isMobile),
      if (_isAdmin) _buildOthersInfoTab(),
    ].whereType<Widget>().toList();
  }

  bool _hasGeneralEventTypeSelected() {
    final f = _typeFamilyController.text.trim();
    return f.isNotEmpty && _typeFamilies.contains(f);
  }

  Widget _buildGeneralTabScroll(bool isMobile) {
    final pad = isMobile ? 6.0 : 8.0;
    final fsBody = isMobile ? 13.0 : 14.0;
    final contentPad = isMobile ? 14.0 : 18.0;
    final spacing = isMobile ? 12.0 : 16.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Identidad: Tipo y subtipo
          _wrapReadOnlyIfNeeded(child: _buildTypeSubtypeSelector()),
          SizedBox(height: spacing),
          if (widget.event == null && !_hasGeneralEventTypeSelected())
            Padding(
              padding: EdgeInsets.fromLTRB(contentPad, 0, contentPad, 12),
              child: Text(
                AppLocalizations.of(context)!.eventSelectTypeFirstHint,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
          if (widget.event != null || _hasGeneralEventTypeSelected()) ...[
            // Descripción del evento
            _wrapReadOnlyIfNeeded(
              child: _buildLabelOnBorderField(
                label: AppLocalizations.of(context)!.eventDescription,
                child: TextFormField(
                  controller: _descriptionController,
                  readOnly: !(_canEditGeneral || _canEditGeneralInitial),
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.eventDescriptionHint,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon:
                        Icon(Icons.subject, color: Colors.grey.shade400),
                    suffixIcon: textFieldClearSuffix(
                      _descriptionController,
                      onCleared: () => setState(() {}),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  ),
                  validator: (value) {
                    if (!_canEditGeneral) return null;
                    final v = value?.trim() ?? '';
                    if (v.isNotEmpty && v.length < 3) {
                      return 'Mínimo 3 caracteres';
                    }
                    if (v.length > 1000) return 'Máximo 1000 caracteres';
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: spacing),
            // Fecha / Hora / Duración justo debajo de Descripción.
            Row(
              children: [
                Expanded(
                  child: _buildWhenField(
                    label: AppLocalizations.of(context)!.date,
                    value: DateFormatter.formatDate(_selectedDate),
                    onTap:
                        _canEditGeneral ? _selectDate : _showReadOnlySnackBar,
                    isMobile: isMobile,
                    fsBody: fsBody,
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Expanded(
                  child: _buildWhenField(
                    label: AppLocalizations.of(context)!.time,
                    value: DateFormatter.formatTimeOnly(
                      DateTime(2000, 1, 1, _selectedHour, _selectedStartMinute),
                    ),
                    onTap: _canEditGeneral
                        ? _selectStartTime
                        : _showReadOnlySnackBar,
                    isMobile: isMobile,
                    fsBody: fsBody,
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Expanded(
                  child: _buildWhenField(
                    label: AppLocalizations.of(context)!.duration,
                    value: _formatDuration(_selectedDurationMinutes),
                    onTap: _canEditGeneral
                        ? _selectDuration
                        : _showReadOnlySnackBar,
                    isMobile: isMobile,
                    fsBody: fsBody,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            _wrapReadOnlyIfNeeded(
              child: _buildLabelOnBorderField(
                label: AppLocalizations.of(context)!.eventLongNotesLabel,
                child: TextFormField(
                  controller: _longNotesController,
                  readOnly: !(_canEditGeneral || _canEditGeneralInitial),
                  minLines: 1,
                  maxLines: 3,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.eventLongNotesLabel,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(Icons.article_outlined,
                        color: Colors.grey.shade400),
                    suffixIcon: IconButton(
                      tooltip: 'Ampliar',
                      onPressed: _openLongNotesEditor,
                      icon:
                          Icon(Icons.open_in_full, color: Colors.grey.shade400),
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
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing),
            if (widget.planId != null)
              EntityAttachmentsSection(
                title:
                    AppLocalizations.of(context)!.entityAttachmentsEventTitle,
                files: _eventDocuments,
                canManage: _canEditGeneral || _canEditGeneralInitial,
                isUploading: _uploadingEventAttachment,
                onUpload: (_canEditGeneral || _canEditGeneralInitial)
                    ? _pickEventAttachment
                    : null,
                onDelete: _deleteEventAttachment,
              ),
            if (widget.planId != null) SizedBox(height: spacing),
            _buildIsForAllParticipantsSelector(),
            SizedBox(height: spacing),
            if (_planCurrency != null)
              _wrapReadOnlyIfNeeded(child: _buildCostFieldWithCurrency()),
            if (_planCurrency != null) const SizedBox(height: 16),
            // Dirección: 1 campo (Dirección del evento) si NO es Desplazamiento; 2 campos (Origen, Destino) si es Desplazamiento
            if (_typeFamilyController.text != 'Desplazamiento') ...[
              _buildUnifiedLocationField(),
              SizedBox(height: spacing),
            ],
            // Desplazamiento: siempre Origen + Destino (Avión = aeropuertos; resto = direcciones)
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text == 'Avión')
              _wrapReadOnlyIfNeeded(child: _buildFlightNumberBlock()),
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text == 'Avión')
              SizedBox(height: spacing),
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text.isNotEmpty &&
                _typeSubtypeController.text != 'Avión')
              _wrapReadOnlyIfNeeded(
                  child: _buildTransportOriginDestinationBlock(
                      showPlazas: _typeSubtypeController.text == 'Taxi')),
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text.isNotEmpty &&
                _typeSubtypeController.text != 'Avión')
              SizedBox(height: spacing),
            if (_typeFamilyController.text == 'Desplazamiento' &&
                (_typeSubtypeController.text == 'Shuttle' ||
                    _typeSubtypeController.text == 'Transfer')) ...[
              _wrapReadOnlyIfNeeded(
                  child: _buildGroundTransferAirportExtraFields()),
              SizedBox(height: spacing),
            ],
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text.isNotEmpty) ...[
              _buildStaticSponsorCard(),
              SizedBox(height: spacing),
            ],
            _wrapReadOnlyIfNeeded(child: _buildUrlField()),
            SizedBox(height: spacing),
            // Timezone:
            // - No desplazamiento: selector rápido estilo vuelo (ID 45).
            // - Desplazamiento no avión: selector clásico ida/llegada.
            if (_typeFamilyController.text != 'Desplazamiento')
              _buildNonTransportTimezoneSelector(),
            if (_typeFamilyController.text != 'Desplazamiento')
              const SizedBox(height: 12),
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text != 'Avión')
              _wrapReadOnlyIfNeeded(
                child: _buildTimezoneFieldOnBorder(
                  label: AppLocalizations.of(context)!.timezone,
                  value: _selectedTimezone,
                  leadingIcon: Icons.public,
                  showCityInMenuAndGmtSelected: true,
                  onChanged: _canEditGeneral
                      ? (value) {
                          setState(() {
                            _selectedTimezone = value ?? 'Europe/Madrid';
                          });
                        }
                      : null,
                ),
              ),
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text != 'Avión')
              const SizedBox(height: 12),

            // Timezone de llegada (solo desplazamiento no avión)
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text != 'Avión')
              _wrapReadOnlyIfNeeded(
                child: _buildTimezoneFieldOnBorder(
                  label: AppLocalizations.of(context)!.arrivalTimezone,
                  value: _selectedArrivalTimezone,
                  leadingIcon: Icons.flight_land,
                  showCityInMenuAndGmtSelected: true,
                  onChanged: _canEditGeneral
                      ? (value) {
                          setState(() {
                            _selectedArrivalTimezone = value ?? 'Europe/Madrid';
                          });
                        }
                      : null,
                ),
              ),
            const SizedBox(height: 16),
            // 3. Participación: asignación y registro (ID 47/48)
            // Participantes (tracks asignados)
            _wrapReadOnlyIfNeeded(child: _buildParticipantsSection()),
            const SizedBox(height: 16),

            // Registro de participantes (quién se ha apuntado)
            if (widget.event != null && widget.planId != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800, // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColorScheme.color2.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            color: AppColorScheme.color2, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!
                                .participantsRegistered,
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
            // 4. Opciones avanzadas al final (ID 47)
            _wrapReadOnlyIfNeeded(
              child: _buildLabelOnBorderField(
                label: 'Límite de participantes (opcional)',
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
                    hintText: 'Ej: 10 (dejar vacío para sin límite)',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon:
                        Icon(Icons.people_outline, color: Colors.grey.shade400),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  ),
                  validator: (value) {
                    if (!_canEditGeneral) return null;
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return null;
                    final intValue = int.tryParse(v);
                    if (intValue == null) return 'Debe ser un número válido';
                    if (intValue < 1) return 'Debe ser mayor que 0';
                    if (intValue > 1000) return 'Máximo 1000 participantes';
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                secondary: Icon(Icons.assignment_turned_in_outlined,
                    color: AppColorScheme.color2),
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 16),

            // 5. Apariencia: Color
            _wrapReadOnlyIfNeeded(
              child: ListTile(
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
                        onTap: !_canEditGeneral
                            ? null
                            : () {
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
                                      color: color.withValues(alpha: 0.5),
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyInfoTabScroll(bool isMobile) {
    final pad = isMobile ? 6.0 : 8.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Información personal para este evento',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Campo: Asiento (estética tipo login)
          Container(
            decoration: _buildLoginStyleDecoration(),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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

          // Campos personalizados según tipo de evento (ID 49).
          if (_typeFamilyController.text == 'Actividad') ...[
            _buildPersonalTextField(
              controller: _activityEntryCodeController,
              labelText: 'Código de entrada',
              hintText: 'Ej: ABC123 o el código del ticket',
              icon: Icons.confirmation_number,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return null;
                if (v.length > 50) return 'Máximo 50 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPersonalTextField(
              controller: _activityEntryDocUrlController,
              labelText: 'URL del ticket/archivo (opcional)',
              hintText: 'Ej: https://... (opcional)',
              icon: Icons.insert_drive_file,
              keyboardType: TextInputType.url,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return null;
                if (v.length > 500) return 'Máximo 500 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
          ] else ...[
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
          ],

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
            activeThumbColor: AppColorScheme.color2,
            activeTrackColor: AppColorScheme.color2.withValues(alpha: 0.5),
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
            decoration: _buildLoginStyleDecoration().copyWith(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColorScheme.color2.withValues(alpha: 0.5),
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
    );
  }

  /// T109: Verifica si se puede guardar/crear el evento según el estado del plan
  bool _canSaveEvent() {
    if (_plan == null) {
      return true; // Si no hay plan cargado, permitir por defecto
    }

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
    if (_plan == null) {
      return true; // Si no hay plan cargado, permitir por defecto
    }
    return PlanStatePermissions.canDeleteEvents(_plan!);
  }

  /// Construye el tab de información de otros participantes (solo para admins)
  Widget _buildOthersInfoTab() {
    final currentUser = ref.read(currentUserProvider);
    final currentUserId = currentUser?.id ?? '';

    // Filtrar participantes excluyendo al usuario actual
    final otherParticipants =
        _selectedParticipantIds.where((id) => id != currentUserId).toList();

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
            decoration: _buildLoginStyleDecoration().copyWith(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.orange.shade400.withValues(alpha: 0.5),
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
          ...otherParticipants
              .map((participantId) => _buildParticipantCard(participantId)),
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
      decoration: _buildLoginStyleDecoration().copyWith(
        borderRadius: BorderRadius.circular(18),
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
            if (widget.event?.commonPart?.family == 'Actividad') ...[
              _buildReadOnlyField(
                  'Código de entrada', personalFields['ticketCode']),
              _buildReadOnlyField(
                  'URL del ticket/archivo', personalFields['ticketDocUrl']),
            ] else ...[
              _buildReadOnlyField('Menú', personalFields['menu']),
              _buildReadOnlyField(
                  'Preferencias', personalFields['preferencias']),
              _buildReadOnlyField(
                  'Número de reserva', personalFields['numeroReserva']),
              _buildReadOnlyField('Gate', personalFields['gate']),
            ],
            _buildReadOnlyField('Tarjeta obtenida',
                personalFields['tarjetaObtenida'] == true ? 'Sí' : 'No'),
            _buildReadOnlyField(
                'Notas personales', personalFields['notasPersonales']),

            const SizedBox(height: 16),
            // Solo mostrar botón de editar si el usuario tiene permisos
            if (_userPermissions
                    ?.hasPermission(Permission.eventEditOthersPersonal) ??
                false)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColorScheme.color2, // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorScheme.color2.withValues(alpha: 0.4),
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
                    color: Colors.grey.shade700.withValues(alpha: 0.5),
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: _buildLoginStyleDecoration(),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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

  /// T246: selector de fecha del vuelo (para búsqueda en Amadeus).
  Future<void> _selectStartTime() async {
    final greenTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context)
          .colorScheme
          .copyWith(primary: Colors.green.shade600),
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
                  final minutes =
                      (index + 1) * 15; // 15, 30, 45, 60, 75, 90, etc.
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
        _selectedDuration =
            (durationMinutes / 60).ceil(); // Mantener compatibilidad
      });
    }
  }

  String _formatDuration(int minutes) {
    final loc = AppLocalizations.of(context)!;
    if (minutes < 60) {
      return loc.eventDurationFormatMinutes(minutes);
    }
    if (minutes == 60) {
      return loc.eventDurationFormatOneHour;
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return loc.eventDurationFormatHoursOnly(hours);
    }
    return loc.eventDurationFormatHoursMinutes(hours, remainingMinutes);
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
      final blockedReason =
          PlanStatePermissions.getBlockedReason('delete_event', _plan!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              blockedReason ??
                  'No se pueden eliminar eventos en el estado actual del plan.',
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
                    Colors.red.shade600.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade600.withValues(alpha: 0.4),
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

    if (confirmed == true &&
        widget.onDeleted != null &&
        widget.event?.id != null) {
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

    // Obtener participantes reales del plan (excluye observadores)
    final participantsAsync =
        ref.watch(planRealParticipantsProvider(widget.planId!));

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
                final isSelected =
                    _selectedParticipantIds.contains(participation.userId);
                final isEventCreator =
                    widget.event?.userId == participation.userId;

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
                            if (!_selectedParticipantIds
                                .contains(participation.userId)) {
                              _selectedParticipantIds.add(participation.userId);
                            }
                          } else {
                            // No permitir deseleccionar si es el único seleccionado
                            if (_selectedParticipantIds.length > 1) {
                              _selectedParticipantIds
                                  .remove(participation.userId);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Debe haber al menos un participante seleccionado',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white),
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
              }),

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

  /// T153: Construir campo de coste con selector de moneda y conversión automática.
  /// Moneda del coste y Coste del evento con formato título sobre el borde.
  Widget _buildCostFieldWithCurrency() {
    final exchangeRateService = ExchangeRateService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Moneda + coste en una sola línea (ID 48)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLabelOnBorderField(
                label: 'Moneda del coste',
                child: DropdownButtonFormField<String>(
                  initialValue: _costCurrency ?? _planCurrency ?? 'EUR',
                  isExpanded: true,
                  dropdownColor: Colors.grey.shade800,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
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
                  selectedItemBuilder: (context) {
                    return Currency.supportedCurrencies.map((currency) {
                      return Text(
                        '${currency.code} ${currency.symbol}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList();
                  },
                  onChanged: _canEditGeneral
                      ? (value) async {
                          if (value == null) return;
                          setState(() => _costCurrency = value);
                          await _convertCostToPlanCurrency(exchangeRateService);
                        }
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLabelOnBorderField(
                label: 'Coste del evento (opcional)',
                child: TextFormField(
                  controller: _costController,
                  enabled: _canEditGeneral,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ej: 150.50',
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  ),
                  onChanged: _canEditGeneral
                      ? (value) {
                          _convertCostToPlanCurrency(exchangeRateService);
                        }
                      : null,
                  validator: (value) {
                    if (!_canEditGeneral) return null;
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return null;
                    final doubleValue = double.tryParse(v.replaceAll(',', '.'));
                    if (doubleValue == null) return 'Debe ser un número válido';
                    if (doubleValue < 0) return 'No puede ser negativo';
                    if (doubleValue > 1000000) return 'Máximo 1.000.000';
                    return null;
                  },
                ),
              ),
            ),
          ],
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
                  decoration: _buildLoginStyleDecoration().copyWith(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColorScheme.color2.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: AppColorScheme.color2),
                          const SizedBox(width: 4),
                          Text(
                            'Convertido a $_planCurrency:',
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
                        CurrencyFormatterService.formatAmount(
                            convertedAmount, _planCurrency!),
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

    final localAmount =
        double.tryParse(_costController.text.replaceAll(',', '.'));
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
  Future<void> _convertCostToPlanCurrency(
      ExchangeRateService exchangeRateService) async {
    if (_costConverting) return; // Evitar loops
    if (_costCurrency == null || _planCurrency == null) return;
    if (_costCurrency == _planCurrency) return; // Misma moneda, no convertir
    if (_costController.text.trim().isEmpty) return;

    final localAmount =
        double.tryParse(_costController.text.replaceAll(',', '.'));
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
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.eventDialogFixValidationErrors,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    // Tipo de evento obligatorio (lista puntos P21).
    if (_typeFamilyController.text.isEmpty ||
        !_typeFamilies.contains(_typeFamilyController.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.selectValidTypeFirst,
                style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }
      return;
    }
    // Validación tipo/subtipo (selector gráfico sin FormField)
    if (_typeSubtypeController.text.isNotEmpty &&
        (_typeFamilyController.text.isEmpty ||
            !_typeFamilies.contains(_typeFamilyController.text))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.selectValidTypeFirst,
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }
    final allowedSubtypes = _typeFamilyController.text.isNotEmpty
        ? (_typeSubtypes[_typeFamilyController.text] ?? [])
        : <String>[];
    if (_typeSubtypeController.text.isNotEmpty &&
        !allowedSubtypes.contains(_typeSubtypeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.invalidSubtype,
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }
    // Validar permisos antes de proceder
    if (!_canEditGeneral) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.noPermissionEditEvent,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    // Descripción opcional: no validar que esté rellenada

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

    if (!mounted) return;
    setState(() => _isSavingEvent = true);
    try {
      // Aviso si se van a romper conexiones externas (T247)
      final shouldContinue = await _handleConnectionBeforeSave();
      if (!shouldContinue) {
        return;
      }

      // Obtener el userId del usuario actual
      final currentUser = ref.read(currentUserProvider);
      final userId = currentUser?.id ?? '';

      // Construir EventCommonPart (T47). T225: location y opcional extraData con coordenadas
      final locationText = _locationController.text.trim();
      final locationSanitized = locationText.isEmpty
          ? null
          : Sanitizer.sanitizePlainText(locationText, maxLength: 500);
      final baseExtra =
          Map<String, dynamic>.from(widget.event?.commonPart?.extraData ?? {});
      if (_lastPlaceDetails != null) {
        if (_lastPlaceDetails!.lat != null) {
          baseExtra['placeLat'] = _lastPlaceDetails!.lat;
        }
        if (_lastPlaceDetails!.lng != null) {
          baseExtra['placeLng'] = _lastPlaceDetails!.lng;
        }
        if (_lastPlaceDetails!.formattedAddress != null) {
          baseExtra['placeAddress'] = _lastPlaceDetails!.formattedAddress;
        }
        baseExtra['placeName'] = _lastPlaceDetails!.displayName;
      }
      if (_lastFlightStatus != null) {
        baseExtra['flightNumber'] = _lastFlightStatus!.flightNumber;
        if (_lastFlightStatus!.carrierCode != null) {
          baseExtra['carrierCode'] = _lastFlightStatus!.carrierCode;
        }
        if (_lastFlightStatus!.originIata != null) {
          baseExtra['originIata'] = _lastFlightStatus!.originIata;
        }
        if (_lastFlightStatus!.destinationIata != null) {
          baseExtra['destinationIata'] = _lastFlightStatus!.destinationIata;
        }
        if (_lastFlightStatus!.originName != null) {
          baseExtra['originName'] = _lastFlightStatus!.originName;
        }
        if (_lastFlightStatus!.destinationName != null) {
          baseExtra['destinationName'] = _lastFlightStatus!.destinationName;
        }
        if (_lastFlightStatus!.departureScheduled != null) {
          baseExtra['departureScheduled'] =
              _lastFlightStatus!.departureScheduled;
        }
        if (_lastFlightStatus!.arrivalScheduled != null) {
          baseExtra['arrivalScheduled'] = _lastFlightStatus!.arrivalScheduled;
        }
        if (_lastFlightStatus!.durationMinutes != null) {
          baseExtra['durationMinutes'] = _lastFlightStatus!.durationMinutes;
        }
        if (_lastFlightStatus!.airlineName != null) {
          baseExtra['airlineName'] = _lastFlightStatus!.airlineName;
        }
      }
      // Número de vuelo manual (persistir aunque no se use Amadeus)
      final flightNoManual = _flightNumberController.text.trim();
      if (flightNoManual.isNotEmpty) {
        baseExtra['flightNumber'] =
            Sanitizer.sanitizePlainText(flightNoManual, maxLength: 32);
      }
      // Aeropuerto salida/llegada (Desplazamiento / Avión) — texto y opcionalmente lat/lng desde Places
      if (_typeFamilyController.text == 'Desplazamiento' &&
          _typeSubtypeController.text == 'Avión') {
        final dep = _departureAirportController.text.trim();
        final arr = _arrivalAirportController.text.trim();
        if (dep.isNotEmpty) {
          baseExtra['departureAirport'] =
              Sanitizer.sanitizePlainText(dep, maxLength: 200);
        }
        if (arr.isNotEmpty) {
          baseExtra['arrivalAirport'] =
              Sanitizer.sanitizePlainText(arr, maxLength: 200);
        }
        if (_departureAirportDetails != null) {
          if (_departureAirportDetails!.lat != null) {
            baseExtra['departureAirportLat'] = _departureAirportDetails!.lat;
          }
          if (_departureAirportDetails!.lng != null) {
            baseExtra['departureAirportLng'] = _departureAirportDetails!.lng;
          }
          if (_departureAirportDetails!.formattedAddress != null) {
            baseExtra['departureAirportAddress'] =
                _departureAirportDetails!.formattedAddress;
          }
        }
        if (_arrivalAirportDetails != null) {
          if (_arrivalAirportDetails!.lat != null) {
            baseExtra['arrivalAirportLat'] = _arrivalAirportDetails!.lat;
          }
          if (_arrivalAirportDetails!.lng != null) {
            baseExtra['arrivalAirportLng'] = _arrivalAirportDetails!.lng;
          }
          if (_arrivalAirportDetails!.formattedAddress != null) {
            baseExtra['arrivalAirportAddress'] =
                _arrivalAirportDetails!.formattedAddress;
          }
        }
      }
      // Desplazamiento (no Avión): origen, destino (direcciones + coordenadas); Taxi además plazas
      if (_typeFamilyController.text == 'Desplazamiento' &&
          _typeSubtypeController.text != 'Avión' &&
          _typeSubtypeController.text.isNotEmpty) {
        final originAddr = _taxiOriginController.text.trim();
        final destAddr = _taxiDestinationController.text.trim();
        if (originAddr.isNotEmpty) {
          baseExtra['taxiOriginAddress'] =
              Sanitizer.sanitizePlainText(originAddr, maxLength: 500);
          if (_taxiOriginDetails?.lat != null) {
            baseExtra['taxiOriginLat'] = _taxiOriginDetails!.lat;
          }
          if (_taxiOriginDetails?.lng != null) {
            baseExtra['taxiOriginLng'] = _taxiOriginDetails!.lng;
          }
        }
        if (destAddr.isNotEmpty) {
          baseExtra['taxiDestinationAddress'] =
              Sanitizer.sanitizePlainText(destAddr, maxLength: 500);
          if (_taxiDestinationDetails?.lat != null) {
            baseExtra['taxiDestinationLat'] = _taxiDestinationDetails!.lat;
          }
          if (_taxiDestinationDetails?.lng != null) {
            baseExtra['taxiDestinationLng'] = _taxiDestinationDetails!.lng;
          }
        }
        if (_typeSubtypeController.text == 'Taxi') {
          baseExtra['taxiSeats'] = _taxiSeats;
        }
        final subTr = _typeSubtypeController.text;
        if (subTr == 'Shuttle' || subTr == 'Transfer') {
          final term = _transferTerminalController.text.trim();
          final air = _transferAirlineController.text.trim();
          final meet = _transferAirportMeetController.text.trim();
          if (term.isNotEmpty) {
            baseExtra['transferTerminal'] =
                Sanitizer.sanitizePlainText(term, maxLength: 200);
          } else {
            baseExtra.remove('transferTerminal');
          }
          if (air.isNotEmpty) {
            baseExtra['transferAirline'] =
                Sanitizer.sanitizePlainText(air, maxLength: 200);
          } else {
            baseExtra.remove('transferAirline');
          }
          if (meet.isNotEmpty) {
            baseExtra['transferAirportMeet'] =
                Sanitizer.sanitizePlainText(meet, maxLength: 500);
          } else {
            baseExtra.remove('transferAirportMeet');
          }
        } else {
          baseExtra.remove('transferTerminal');
          baseExtra.remove('transferAirline');
          baseExtra.remove('transferAirportMeet');
        }
      } else {
        baseExtra.remove('transferTerminal');
        baseExtra.remove('transferAirline');
        baseExtra.remove('transferAirportMeet');
      }

      // Descripción: si el usuario dejó el campo vacío, generar una a partir de tipo, subtipo y ubicación
      final descriptionToSave = _buildDescriptionForSave();

      // T247: calcular metadatos de conexión
      Map<String, dynamic>? connection;
      // Si hay nuevo resultado de vuelo, marcamos conexión Amadeus
      if (_lastFlightStatus != null) {
        final dateIso =
            '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
        connection = {
          'provider': 'amadeus',
          'type': 'flight',
          'externalId': '${_lastFlightStatus!.flightNumber}-$dateIso',
          'source': 'T246',
          'lastSyncAt': DateTime.now().toUtc().toIso8601String(),
          'fields': [
            'date',
            'startHour',
            'startMinute',
            'durationMinutes',
            'extraData.flightNumber',
            'extraData.departureAirport',
            'extraData.arrivalAirport',
            'extraData.originIata',
            'extraData.destinationIata',
            'extraData.departureScheduled',
            'extraData.arrivalScheduled',
          ],
        };
      } else if (_initialConnection != null && !_disconnectConnection) {
        // Mantener conexión previa si no se ha pedido desconectar
        connection = _initialConnection;
      } else {
        connection = null;
      }
      // T252: Participante creando → solo borrador (propuesta)
      final effectiveIsDraft = _isParticipantCreatingProposal ? true : _isDraft;
      final commonPart = EventCommonPart(
        description:
            Sanitizer.sanitizePlainText(descriptionToSave, maxLength: 1000),
        date: _selectedDate,
        startHour: _selectedHour,
        startMinute: _selectedStartMinute,
        durationMinutes: _selectedDurationMinutes,
        customColor: _selectedColor,
        family: _typeFamilyController.text.isEmpty
            ? null
            : _typeFamilyController.text,
        subtype: _typeSubtypeController.text.isEmpty
            ? null
            : _typeSubtypeController.text,
        location: locationSanitized,
        url: _urlController.text.trim().isEmpty
            ? null
            : Sanitizer.sanitizePlainText(_urlController.text.trim(),
                maxLength: 500),
        notes: _longNotesController.text.trim().isEmpty
            ? null
            : Sanitizer.sanitizePlainText(_longNotesController.text.trim(),
                maxLength: 8000),
        isDraft: effectiveIsDraft,
        extraData: baseExtra.isEmpty ? null : baseExtra,
        connection: connection,
        // Si está marcado "para todos", participantIds debe estar vacío
        // Si no, debe contener los IDs seleccionados
        participantIds: _isForAllParticipants ? [] : _selectedParticipantIds,
        isForAllParticipants: _isForAllParticipants,
      );

      // Construir EventPersonalPart para el usuario actual
      final personalPart = EventPersonalPart(
        participantId: userId,
        fields: {
          'asiento': Sanitizer.sanitizePlainText(_asientoController.text,
                      maxLength: 50)
                  .isEmpty
              ? null
              : Sanitizer.sanitizePlainText(_asientoController.text,
                  maxLength: 50),
          'menu':
              Sanitizer.sanitizePlainText(_menuController.text, maxLength: 100)
                      .isEmpty
                  ? null
                  : Sanitizer.sanitizePlainText(_menuController.text,
                      maxLength: 100),
          'preferencias': Sanitizer.sanitizePlainText(
                      _preferenciasController.text,
                      maxLength: 200)
                  .isEmpty
              ? null
              : Sanitizer.sanitizePlainText(_preferenciasController.text,
                  maxLength: 200),
          'numeroReserva': Sanitizer.sanitizePlainText(
                      _numeroReservaController.text,
                      maxLength: 50)
                  .isEmpty
              ? null
              : Sanitizer.sanitizePlainText(_numeroReservaController.text,
                  maxLength: 50),
          'gate':
              Sanitizer.sanitizePlainText(_gateController.text, maxLength: 50)
                      .isEmpty
                  ? null
                  : Sanitizer.sanitizePlainText(_gateController.text,
                      maxLength: 50),
          'tarjetaObtenida': _tarjetaObtenida,
          'notasPersonales': Sanitizer.sanitizePlainText(
                      _notasPersonalesController.text,
                      maxLength: 1000)
                  .isEmpty
              ? null
              : Sanitizer.sanitizePlainText(_notasPersonalesController.text,
                  maxLength: 1000),
          // T49: Actividades (código / documento opcional).
          'ticketCode': Sanitizer.sanitizePlainText(
                      _activityEntryCodeController.text,
                      maxLength: 50)
                  .isEmpty
              ? null
              : Sanitizer.sanitizePlainText(_activityEntryCodeController.text,
                  maxLength: 50),
          'ticketDocUrl': Sanitizer.sanitizePlainText(
                      _activityEntryDocUrlController.text,
                      maxLength: 500)
                  .isEmpty
              ? null
              : Sanitizer.sanitizePlainText(_activityEntryDocUrlController.text,
                  maxLength: 500),
        },
      );

      // Construir mapa de personalParts (mantener existentes + añadir/actualizar el actual)
      final Map<String, EventPersonalPart> personalParts =
          Map.from(widget.event?.personalParts ?? {});
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
        description:
            Sanitizer.sanitizePlainText(descriptionToSave, maxLength: 1000),
        color: _selectedColor,
        typeFamily: _typeFamilyController.text.isEmpty
            ? null
            : _typeFamilyController.text,
        typeSubtype: _typeSubtypeController.text.isEmpty
            ? null
            : _typeSubtypeController.text,
        participantTrackIds: _selectedParticipantIds,
        isDraft: effectiveIsDraft,
        timezone: _selectedTimezone,
        arrivalTimezone: _selectedArrivalTimezone,
        maxParticipants: _maxParticipantsController.text.trim().isEmpty
            ? null
            : int.tryParse(_maxParticipantsController.text.trim()),
        requiresConfirmation: _requiresConfirmation,
        cost:
            await _getConvertedCost(), // T153: Coste convertido a moneda del plan
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        commonPart: commonPart,
        personalParts: personalParts,
        documents: _eventDocuments.isEmpty
            ? null
            : List<EventDocument>.from(_eventDocuments),
      );

      // T107: Detectar si el evento se extiende fuera del rango del plan
      if (widget.planId != null && !effectiveIsDraft) {
        final planService = ref.read(planServiceProvider);
        final plan = await planService.getPlanById(widget.planId!);
        if (!mounted) return;

        if (plan != null) {
          final expansionInfo =
              PlanRangeUtils.detectEventOutsideRange(event, plan);

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
              final newPlanValues = PlanRangeUtils.calculateExpandedPlanValues(
                  plan, expansionInfo);
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
    } finally {
      if (mounted) {
        setState(() => _isSavingEvent = false);
      }
    }
  }
}

class _StaticSponsorData {
  final String name;
  final String url;

  const _StaticSponsorData({required this.name, required this.url});
}

/// Chip de pestaña del diálogo de evento (estilo W14/W15: fondo destacado si seleccionado).
class _EventTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isMobile;
  final VoidCallback onTap;

  const _EventTabChip({
    required this.label,
    required this.isSelected,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? Colors.white : Colors.grey.shade400;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 10 : 12,
          horizontal: isMobile ? 8 : 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withValues(alpha: 0.85),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade800,
                    const Color(0xFF2C2C2C),
                  ],
                ),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.color2
                : Colors.grey.shade700.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColorScheme.color2.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
