import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_event_accent_colors.dart';
import 'package:unp_calendario/features/calendar/domain/services/previous_plan_location_helper.dart';
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
import 'package:unp_calendario/shared/utils/plan_range_utils.dart';
import 'package:unp_calendario/widgets/dialogs/expand_plan_dialog.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/shared/services/exchange_rate_service.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/widgets/dialogs/delete_event_dialog.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_file_service.dart';
import 'package:unp_calendario/widgets/plan/entity_attachments_section.dart';
import 'package:unp_calendario/widgets/plan/reservation_cancellation_form_section.dart';
import 'package:unp_calendario/features/places/data/places_api_service.dart';
import 'package:unp_calendario/features/places/presentation/widgets/place_autocomplete_field.dart';
import 'package:unp_calendario/features/flights/data/flight_status_service.dart';
import 'package:unp_calendario/features/flights/data/flight_status_result.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/widgets/plan/event_payments_tab.dart';

class EventDialog extends ConsumerStatefulWidget {
  final Event? event;
  final String? planId;
  final DateTime? initialDate;
  final int? initialHour;

  /// Minuto de inicio si se fija [initialHour] desde fuera (p. ej. FAB con plan en curso = ahora).
  final int? initialStartMinute;
  final FutureOr<void> Function(Event)? onSaved;
  final FutureOr<void> Function(String)? onDeleted;

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
      _locationController; // T225: lugar (nombre\ndirección)
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
  late List<String> _initialSelectedParticipantIds;
  late bool _isForAllParticipants; // Checkbox principal "Para todos"
  late bool _initialIsForAllParticipants;
  late String _selectedTimezone;
  late String _selectedArrivalTimezone;
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
  final _reservationSectionKey =
      GlobalKey<ReservationCancellationFormSectionState>();

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
  // Ítem 66: documentación específica para recogida/entrega de vehículo alquiler.
  late TextEditingController _rentalCompanyController;
  late TextEditingController _rentalOfficeController;
  late TextEditingController _rentalContractCodeController;
  late TextEditingController _rentalVehiclePlateController;
  late TextEditingController _rentalPickupReturnNotesController;
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
      'Otro',
      'Punto de encuentro',
      'Recogida vehículo alquiler',
      'Tiempo en aeropuerto',
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
    // Legados: ya no se ofrecen al crear; icono si el evento aún los tiene.
    'Acción|Fin viaje': Icons.flag,
    'Acción|Inicio viaje': Icons.flag_outlined,
    'Acción|Punto de encuentro': Icons.place,
    'Acción|Tiempo en aeropuerto': Icons.luggage,
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

  /// Filtro rápido sobre tipo/subtipo (solo visible con la rejilla abierta).
  late final TextEditingController _typeSearchController;

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
    final edLoc = widget.event?.commonPart?.extraData;
    final savedPlaceName = (edLoc?['placeName'] as String?)?.trim() ?? '';
    final savedPlaceAddress =
        (edLoc?['placeAddress'] as String?)?.trim() ?? '';
    final savedLocation = widget.event?.commonPart?.location?.trim() ?? '';
    _locationController = TextEditingController(
      text: formatPlaceNameAndAddress(
        savedPlaceName.isNotEmpty ? savedPlaceName : savedLocation,
        savedPlaceName.isNotEmpty ? savedPlaceAddress : null,
      ),
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
    _typeSearchController = TextEditingController();

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
    final originName = (ed?['taxiOriginName'] as String?)?.trim() ?? '';
    final originAddress =
        (ed?['taxiOriginAddress'] as String?)?.trim() ?? '';
    _taxiOriginController = TextEditingController(
      text: formatPlaceNameAndAddress(
        originName.isNotEmpty ? originName : originAddress,
        originName.isNotEmpty ? originAddress : null,
      ),
    );
    final destName = (ed?['taxiDestinationName'] as String?)?.trim() ?? '';
    final destAddress =
        (ed?['taxiDestinationAddress'] as String?)?.trim() ?? '';
    _taxiDestinationController = TextEditingController(
      text: formatPlaceNameAndAddress(
        destName.isNotEmpty ? destName : destAddress,
        destName.isNotEmpty ? destAddress : null,
      ),
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
    _rentalCompanyController = TextEditingController(
      text: ed?['rentalCompany'] as String? ?? '',
    );
    _rentalOfficeController = TextEditingController(
      text: ed?['rentalOffice'] as String? ?? '',
    );
    _rentalContractCodeController = TextEditingController(
      text: ed?['rentalContractCode'] as String? ?? '',
    );
    _rentalVehiclePlateController = TextEditingController(
      text: ed?['rentalVehiclePlate'] as String? ?? '',
    );
    _rentalPickupReturnNotesController = TextEditingController(
      text: ed?['rentalPickupReturnNotes'] as String? ?? '',
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

    // Inicializar coste (T101)
    _costController = TextEditingController(
      text: widget.event?.cost?.toString() ?? '',
    );

    // Inicializar participantes seleccionados y checkbox "Para todos" (T47)
    final existingCommonPart = widget.event?.commonPart;
    _isForAllParticipants = existingCommonPart?.isForAllParticipants ?? true;
    _selectedParticipantIds =
        List.from(existingCommonPart?.participantIds ?? []);
    _initialIsForAllParticipants = _isForAllParticipants;
    _initialSelectedParticipantIds = List.from(_selectedParticipantIds);

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

    final loc = AppLocalizations.of(context)!;
    final result = await IosFormConfirmSheet.show(
      context: context,
      title: loc.eventConnectedTitle,
      message: loc.eventConnectedMessage,
      cancelLabel: loc.cancel,
      confirmLabel: loc.eventConnectedDisconnect,
      destructive: false,
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
          if (widget.event == null) {
            _syncAccentColorFromPlanConfig();
          }
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
          if (widget.event == null) {
            _syncAccentColorFromPlanConfig();
          }
        });
      }
    } catch (e) {
      // Si falla, no hacer nada
    }
  }

  /// T272: color de carril desde la config del plan (crear o al cambiar familia).
  void _syncAccentColorFromPlanConfig({bool force = false}) {
    if (_plan == null) return;
    if (!force && widget.event != null) return;
    _selectedColor = PlanEventAccentColors.resolve(
      _plan!,
      _typeFamilyController.text,
    );
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
    _typeSearchController.dispose();
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
    _rentalCompanyController.dispose();
    _rentalOfficeController.dispose();
    _rentalContractCodeController.dispose();
    _rentalVehiclePlateController.dispose();
    _rentalPickupReturnNotesController.dispose();
    _costController.dispose(); // T101
    super.dispose();
  }

  // Surfaces iOS D (GUIA_UI formularios tipo ficha).
  static const Color _formSurface = IosFormColors.pageBg;
  static const Color _fieldSurface = IosFormColors.groupedBg;
  static const double _fieldRadius = 12;
  static const double _fieldGap = 14;
  static const double _fieldIconSize = 20;
  static const EdgeInsets _fieldContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  TextStyle get _labelStyle => const TextStyle(
        fontSize: 13,
        color: IosFormColors.textSecondary,
        fontWeight: FontWeight.w400,
      );

  TextStyle get _valueStyle => const TextStyle(
        fontSize: 17,
        color: IosFormColors.textPrimary,
        fontWeight: FontWeight.w400,
        height: 1.2,
      );

  TextStyle get _hintStyle => const TextStyle(
        fontSize: 17,
        color: IosFormColors.textTertiary,
        fontWeight: FontWeight.w400,
        height: 1.2,
      );

  Icon _fieldIcon(IconData icon) =>
      Icon(icon, size: _fieldIconSize, color: IosFormColors.textSecondary);

  /// Decoración tipo login: fondo sólido, sin borde duro (patrón D).
  BoxDecoration _buildLoginStyleDecoration() {
    return BoxDecoration(
      color: _fieldSurface,
      borderRadius: BorderRadius.circular(_fieldRadius),
    );
  }

  InputDecoration _standardFieldDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    bool showErrorBorder = false,
    String? counterText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      counterText: counterText,
      labelStyle: _labelStyle,
      hintStyle: _hintStyle,
      prefixIcon: prefixIcon != null ? _fieldIcon(prefixIcon) : null,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: showErrorBorder
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1),
            )
          : InputBorder.none,
      focusedErrorBorder: showErrorBorder
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            )
          : InputBorder.none,
      filled: true,
      fillColor: Colors.transparent,
      isDense: true,
      contentPadding: _fieldContentPadding,
    );
  }

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

  /// Localización: un solo campo con nombre (1ª línea) y dirección (2ª).
  /// Fila Places dentro de card Settings (label arriba + autocomplete).
  Widget _iosPlaceFieldRow({
    required String label,
    required String hint,
    required TextEditingController controller,
    required void Function(PlaceDetails details) onPlaceSelected,
    String? initialAddress,
    VoidCallback? onOpenMaps,
    bool canOpenMaps = false,
  }) {
    final canEdit = _canEditGeneral || _canEditGeneralInitial;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: IosFormColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                IgnorePointer(
                  ignoring: !canEdit,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                    child: PlaceAutocompleteField(
                      controller: controller,
                      initialAddress: initialAddress,
                      lodgingOnly: false,
                      preferNameAndAddressTwoLines: true,
                      maxLines: 2,
                      showFloatingLabel: false,
                      labelText: label,
                      hintText: hint,
                      fontSize: 17,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      onPlaceSelected: onPlaceSelected,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onOpenMaps != null)
            IconButton(
              tooltip: AppLocalizations.of(context)!.openInGoogleMaps,
              onPressed: canOpenMaps ? onOpenMaps : null,
              icon: Icon(
                Icons.map_outlined,
                size: 22,
                color: canOpenMaps
                    ? IosFormColors.accent
                    : IosFormColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  String _timezoneRowValue(String timezone) =>
      '${TimezoneService.getTimezoneCityName(timezone)} (${TimezoneService.getUtcOffsetFormatted(timezone)})';

  Widget _buildUnifiedLocationField() {
    final loc = AppLocalizations.of(context)!;
    final previous = _lookupPreviousPlanLocation();
    final canEdit = _canEditGeneral || _canEditGeneralInitial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: IgnorePointer(
                  ignoring: !canEdit,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                    child: PlaceAutocompleteField(
                      controller: _locationController,
                      initialAddress: _locationController.text.isNotEmpty
                          ? _locationController.text
                          : null,
                      lodgingOnly: false,
                      preferNameAndAddressTwoLines: true,
                      minLines: 1,
                      maxLines: 2,
                      showFloatingLabel: false,
                      labelText: '',
                      hintText: loc.eventAddressSingleHint,
                      fontSize: 17,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      onPlaceSelected: (PlaceDetails details) {
                        setState(() {
                          _lastPlaceDetails = details;
                          _locationController.text = formatPlaceNameAndAddress(
                            details.displayName,
                            details.formattedAddress,
                          );
                          final web = details.websiteUri?.trim();
                          if (web != null && web.isNotEmpty) {
                            _urlController.text = web;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: _locationController,
                builder: (context, _) {
                  final canOpenMaps = _canOpenEventLocationInMaps;
                  return IconButton(
                    tooltip: loc.openInGoogleMaps,
                    onPressed: canOpenMaps ? _openLocationInGoogleMaps : null,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: Icon(
                      Icons.map_outlined,
                      size: 22,
                      color: canOpenMaps
                          ? IosFormColors.accent
                          : IosFormColors.textTertiary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (previous != null && canEdit) ...[
          const IosRowSeparator(),
          IosSettingsRow(
            label: loc.usePreviousLocation,
            value: () {
              final raw = (previous.sourceLabel ?? previous.address).trim();
              if (raw.isEmpty) return '—';
              return raw.length > 36 ? '${raw.substring(0, 34)}…' : raw;
            }(),
            valueColor: IosFormColors.accent,
            chevron: true,
            onTap: () => _applyPreviousPlanLocation(previous),
          ),
        ],
      ],
    );
  }

  bool get _canOpenEventLocationInMaps {
    final hasCoords = _lastPlaceDetails?.lat != null ||
        (widget.event?.commonPart?.extraData?['placeLat'] != null);
    return hasCoords || _locationController.text.trim().isNotEmpty;
  }

  /// Texto corto de localización (1ª línea = nombre).
  String get _eventLocationDisplayText {
    final parsed = parsePlaceNameAndAddress(_locationController.text);
    if (parsed.name.isNotEmpty) return parsed.name;
    return parsed.address;
  }

  PreviousPlanLocation? _lookupPreviousPlanLocation() {
    final planId = widget.planId;
    final user = ref.watch(currentUserProvider);
    if (planId == null || user == null) return null;

    final eventsAsync = ref.watch(planEventsStreamProvider(planId));
    final events = eventsAsync.valueOrNull ?? const <Event>[];

    final accParams = AccommodationNotifierParams(planId: planId);
    ref.watch(accommodationNotifierProvider(accParams));
    final accommodations = ref.watch(accommodationsProvider(accParams));

    final targetStart = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour,
      _selectedStartMinute,
    );

    return PreviousPlanLocationHelper.find(
      userId: user.id,
      targetStart: targetStart,
      events: events,
      accommodations: accommodations,
      excludeEventId: widget.event?.id,
    );
  }

  /// Alojamientos con ubicación el [day] (check-in inclusive / check-out exclusive).
  List<PreviousPlanLocation> _lookupAccommodationsForDay(DateTime day) {
    final planId = widget.planId;
    final user = ref.watch(currentUserProvider);
    if (planId == null || user == null) return const [];

    final accParams = AccommodationNotifierParams(planId: planId);
    ref.watch(accommodationNotifierProvider(accParams));
    final accommodations = ref.watch(accommodationsProvider(accParams));

    return PreviousPlanLocationHelper.sameDayAccommodations(
      userId: user.id,
      day: day,
      accommodations: accommodations,
    );
  }

  /// Destino: hotel del día del evento.
  List<PreviousPlanLocation> _lookupSameDayAccommodations() =>
      _lookupAccommodationsForDay(_selectedDate);

  /// Origen: hotel de la noche anterior (día civil previo al evento).
  List<PreviousPlanLocation> _lookupPreviousDayAccommodations() =>
      _lookupAccommodationsForDay(
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
            .subtract(const Duration(days: 1)),
      );

  void _applyPreviousPlanLocation(PreviousPlanLocation previous) {
    setState(() {
      final label = (previous.sourceLabel ?? '').trim();
      final address = previous.address.trim();
      _locationController.text = formatPlaceNameAndAddress(
        label.isNotEmpty ? label : address,
        label.isNotEmpty ? address : null,
      );
      _lastPlaceDetails = PlaceDetails(
        displayName: label.isNotEmpty ? label : address,
        formattedAddress: address.isNotEmpty ? address : null,
        lat: previous.lat,
        lng: previous.lng,
      );
    });
  }

  void _applyPreviousPlanLocationToOrigin(PreviousPlanLocation previous) {
    setState(() {
      final label = (previous.sourceLabel ?? '').trim();
      final address = previous.address.trim();
      _taxiOriginController.text = formatPlaceNameAndAddress(
        label.isNotEmpty ? label : address,
        label.isNotEmpty ? address : null,
      );
      _taxiOriginDetails = PlaceDetails(
        displayName: label.isNotEmpty ? label : address,
        formattedAddress: address.isNotEmpty ? address : null,
        lat: previous.lat,
        lng: previous.lng,
      );
      _taxiOriginStoredLat = previous.lat;
      _taxiOriginStoredLng = previous.lng;
    });
  }

  void _applyPreviousPlanLocationToDestination(PreviousPlanLocation previous) {
    setState(() {
      final label = (previous.sourceLabel ?? '').trim();
      final address = previous.address.trim();
      _taxiDestinationController.text = formatPlaceNameAndAddress(
        label.isNotEmpty ? label : address,
        label.isNotEmpty ? address : null,
      );
      _taxiDestinationDetails = PlaceDetails(
        displayName: label.isNotEmpty ? label : address,
        formattedAddress: address.isNotEmpty ? address : null,
        lat: previous.lat,
        lng: previous.lng,
      );
      _taxiDestinationStoredLat = previous.lat;
      _taxiDestinationStoredLng = previous.lng;
    });
  }

  String _twoLinePlaceDisplayName(String text) {
    final parsed = parsePlaceNameAndAddress(text);
    if (parsed.name.isNotEmpty) return parsed.name;
    return parsed.address;
  }

  String _twoLinePlaceMapsQuery(String text) {
    final parsed = parsePlaceNameAndAddress(text);
    if (parsed.address.isNotEmpty) return parsed.address;
    return parsed.name;
  }

  /// Botón(es) para usar un alojamiento como origen o destino.
  Widget? _buildAccommodationEndpointActions({
    required List<PreviousPlanLocation> hotels,
    required void Function(PreviousPlanLocation hotel) onApply,
    required String Function(String shortLabel) singleLabel,
    required String menuLabel,
  }) {
    if (!(_canEditGeneral || _canEditGeneralInitial)) return null;
    if (hotels.isEmpty) return null;

    if (hotels.length == 1) {
      final hotel = hotels.first;
      final label = (hotel.sourceLabel ?? hotel.address).trim();
      final short =
          label.length > 32 ? '${label.substring(0, 30)}…' : label;
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => onApply(hotel),
          icon: Icon(
            Icons.hotel_outlined,
            size: 16,
            color: AppColorScheme.color2,
          ),
          label: Text(
            singleLabel(short),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColorScheme.color2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
            foregroundColor: AppColorScheme.color2,
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<PreviousPlanLocation>(
        tooltip: menuLabel,
        onSelected: onApply,
        itemBuilder: (context) => hotels
            .map(
              (h) => PopupMenuItem(
                value: h,
                child: Text(
                  h.sourceLabel ?? h.address,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            )
            .toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hotel_outlined,
                  size: 16, color: AppColorScheme.color2),
              const SizedBox(width: 6),
              Text(
                menuLabel,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColorScheme.color2,
                ),
              ),
              Icon(Icons.arrow_drop_down,
                  size: 18, color: AppColorScheme.color2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNonTransportTimezoneSelector() {
    final loc = AppLocalizations.of(context)!;
    final canEdit = _canEditGeneral;
    final value =
        '${TimezoneService.getTimezoneCityName(_selectedTimezone)} (${TimezoneService.getUtcOffsetFormatted(_selectedTimezone)})';
    return IosSettingsRow(
      label: loc.timezone,
      value: value,
      chevron: canEdit,
      onTap: canEdit
          ? () => _openFlightTimezonePicker(isArrival: false)
          : null,
    );
  }

  /// Alcance de participantes: switch «Para todos» + lista en la misma card.
  Widget _buildParticipantsScopeSection() {
    final loc = AppLocalizations.of(context)!;
    final canEdit = _canEditGeneral;
    final planId = widget.planId;

    final children = <Widget>[
      IosSwitchRow(
        label: loc.eventDialogForAllShort,
        value: _isForAllParticipants,
        onChanged: canEdit
            ? (value) {
                setState(() {
                  _isForAllParticipants = value;
                  if (_isForAllParticipants) {
                    _selectedParticipantIds.clear();
                  }
                });
              }
            : null,
      ),
    ];

    String? footerText = _isForAllParticipants
        ? loc.eventDialogForAllParticipantsSubtitleOn
        : loc.eventDialogForAllParticipantsSubtitleOff;
    Color? footerColor;

    if (!_isForAllParticipants) {
      children.add(const IosRowSeparator());
      children.add(
        IosGroupedCardCaption(loc.eventDialogParticipantsPickCaption),
      );

      if (planId == null) {
        children.add(
          IosSettingsRow(
            label: loc.eventDialogNoParticipantsInPlan,
            value: '',
          ),
        );
      } else {
        final participantsAsync =
            ref.watch(planRealParticipantsProvider(planId));
        participantsAsync.when(
          data: (participations) {
            if (participations.isEmpty) {
              children.add(
                IosSettingsRow(
                  label: loc.eventDialogNoParticipantsInPlan,
                  value: '',
                ),
              );
              return;
            }
            for (var i = 0; i < participations.length; i++) {
              final participation = participations[i];
              final isSelected =
                  _selectedParticipantIds.contains(participation.userId);
              final isEventCreator =
                  widget.event?.userId == participation.userId;
              if (i > 0) children.add(const IosRowSeparator());
              children.add(
                FutureBuilder<String>(
                  future: _getUserDisplayName(participation.userId),
                  builder: (context, snapshot) {
                    final displayName =
                        snapshot.data ?? participation.userId;
                    String secondary = '';
                    if (isEventCreator) {
                      secondary = loc.eventDialogEventCreator;
                    } else if (participation.isOrganizer) {
                      secondary = loc.planRoleOrganizer;
                    }
                    return IosCheckRow(
                      label: displayName,
                      value: secondary,
                      selected: isSelected,
                      indented: true,
                      onTap: canEdit
                          ? () {
                              setState(() {
                                if (isSelected) {
                                  if (_selectedParticipantIds.length > 1) {
                                    _selectedParticipantIds
                                        .remove(participation.userId);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          loc.eventDialogSelectAtLeastOne,
                                          style: GoogleFonts.poppins(
                                              color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red.shade600,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else if (!_selectedParticipantIds
                                    .contains(participation.userId)) {
                                  _selectedParticipantIds
                                      .add(participation.userId);
                                }
                              });
                            }
                          : null,
                    );
                  },
                ),
              );
            }
            if (_selectedParticipantIds.isEmpty &&
                !_isLegacyEventWithoutParticipants) {
              footerText = loc.eventDialogSelectAtLeastOne;
              footerColor = IosFormColors.danger;
            }
          },
          loading: () {
            children.add(
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            );
          },
          error: (_, __) {
            footerText = loc.eventDialogParticipantsLoadError;
            footerColor = IosFormColors.danger;
          },
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IosSectionLabel(loc.eventDialogParticipantsScopeLabel),
        IosGroupedCard(children: children),
        if (footerText != null && footerText!.isNotEmpty)
          IosFormFooter(footerText!, color: footerColor),
      ],
    );
  }

  /// Campo opcional: enlace web del evento (p. ej. reserva, web del lugar).
  Widget _buildUrlField() {
    final loc = AppLocalizations.of(context)!;
    final canEdit = _canEditGeneral || _canEditGeneralInitial;
    return IosGroupedCard(
      children: [
        IgnorePointer(
          ignoring: !canEdit,
          child: IosEditField(
            label: loc.eventUrlLabel,
            controller: _urlController,
            keyboardType: TextInputType.url,
            hint: loc.eventUrlHint,
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (_canOpenEventWebLink) ...[
          const IosRowSeparator(),
          IosSettingsRow(
            label: loc.openWebLink,
            value: _urlController.text.trim(),
            valueColor: IosFormColors.accent,
            chevron: true,
            onTap: _openEventWebLink,
          ),
        ],
      ],
    );
  }

  bool get _canOpenEventWebLink {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) return false;
    final withScheme = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(withScheme);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  Future<void> _openEventWebLink() async {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) return;
    final withScheme = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(withScheme);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
          backgroundColor: const Color(0xFF111827),
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
    // No disponer el controller hasta que el route del diálogo haya
    // desmontado el TextField (si no → Assertion _dependents.isEmpty).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tempController.dispose();
    });
    if (!mounted || result == null) return;
    setState(() {
      _longNotesController.text = result;
    });
  }

  Future<void> _pickEventAttachment() async {
    final planId = widget.planId;
    if (planId == null) return;
    final PickedPlanFile picked;
    try {
      final result = await PlanFileService.pickAttachment();
      // null = cancelación del selector nativo (no es error de lectura).
      if (result == null) return;
      picked = result;
    } catch (_) {
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
    final loc = AppLocalizations.of(context)!;
    final confirm = await IosFormConfirmSheet.show(
      context: context,
      title: loc.entityAttachmentsDeleteTitle,
      message: loc.entityAttachmentsDeleteConfirm(doc.name),
      cancelLabel: loc.cancel,
      confirmLabel: loc.delete,
      destructive: true,
    );
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

  void _clearTypeSearch() {
    if (_typeSearchController.text.isEmpty) return;
    _typeSearchController.clear();
  }

  bool _matchesTypeQuery(String value, String query) {
    if (query.isEmpty) return true;
    return value.toLowerCase().contains(query);
  }

  /// Resultados de búsqueda global (familia y/o subtipo).
  List<({String family, String? subtype})> _typeSearchHits(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final hits = <({String family, String? subtype})>[];
    for (final family in _typeFamilies) {
      if (_matchesTypeQuery(family, query)) {
        hits.add((family: family, subtype: null));
      }
      for (final subtype in _typeSubtypes[family] ?? const <String>[]) {
        if (_matchesTypeQuery(subtype, query)) {
          hits.add((family: family, subtype: subtype));
        }
      }
    }
    hits.sort((a, b) {
      final la = a.subtype ?? a.family;
      final lb = b.subtype ?? b.family;
      return la.toLowerCase().compareTo(lb.toLowerCase());
    });
    return hits;
  }

  Widget _buildEventTypeSearchField() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: _typeSearchController,
        style: _valueStyle.copyWith(fontSize: 13),
        cursorColor: AppColorScheme.color2,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: loc.eventTypeSearchHint,
          hintStyle: _hintStyle.copyWith(fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 18, color: Colors.white70),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 36, minHeight: 36),
          suffixIcon: _typeSearchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: loc.search,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () {
                    setState(_clearTypeSearch);
                  },
                  icon: const Icon(Icons.close, size: 16, color: Colors.white60),
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  /// Selector gráfico de tipo y subtipo de evento (iconos + chips con "+" para reabrir).
  Widget _buildTypeSubtypeSelector() {
    final loc = AppLocalizations.of(context)!;
    final narrow = MediaQuery.sizeOf(context).width < 520;
    // Celdas un poco más bajas: tipografía 2 líneas + icono sin exceso de aire.
    final typeGridAspect = narrow ? 1.28 : 1.55;
    final hasType = _typeFamilyController.text.isNotEmpty &&
        _typeFamilies.contains(_typeFamilyController.text);
    final subtypes = hasType
        ? (_typeSubtypes[_typeFamilyController.text] ?? [])
        : <String>[];
    // Mostrar siempre tipo + subtipo cuando hay texto de subtipo (evita que solo quede visible el subtipo).
    final hasSubtype = _typeSubtypeController.text.trim().isNotEmpty;
    final searchQuery = _typeSearchController.text.trim().toLowerCase();
    final showSearch = _typePickerExpanded ||
        (hasType && _subtypePickerExpanded);

    // Fila colapsada: solo subtipo (más espacio); si no hay, familia.
    String collapsedTypeValue() {
      if (hasSubtype) return _typeSubtypeController.text.trim();
      if (hasType) return _typeFamilyController.text.trim();
      return '';
    }

    if (!_canEditGeneral) {
      final typeValue = collapsedTypeValue();
      return IosSettingsRow(
        label: loc.eventType,
        value: typeValue.isEmpty ? '—' : typeValue,
      );
    }

    final typeValue = collapsedTypeValue();
    final pickerOpen = _typePickerExpanded || _subtypePickerExpanded;

    if (!pickerOpen) {
      return IosSettingsRow(
        label: loc.eventType,
        value: typeValue.isEmpty ? '—' : typeValue,
        chevron: true,
        onTap: () {
          setState(() {
            if (hasType) {
              _subtypePickerExpanded = true;
              _typePickerExpanded = false;
            } else {
              _typePickerExpanded = true;
            }
            _clearTypeSearch();
          });
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSearch) ...[
            _buildEventTypeSearchField(),
            const SizedBox(height: 10),
          ],
          if (_typePickerExpanded) ...[
            Builder(
              builder: (context) {
                if (searchQuery.isNotEmpty) {
                  final hits = _typeSearchHits(searchQuery);
                  if (hits.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        loc.eventTypeSearchEmpty,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: narrow ? 8 : 10,
                      mainAxisSpacing: narrow ? 8 : 10,
                      childAspectRatio: typeGridAspect,
                    ),
                    itemCount: hits.length,
                    itemBuilder: (context, index) {
                      final hit = hits[index];
                      final isSubtype = hit.subtype != null;
                      final label = isSubtype
                          ? '${hit.subtype}\n${hit.family}'
                          : hit.family;
                      final icon = isSubtype
                          ? (_subtypeIcons['${hit.family}|${hit.subtype}'] ??
                              Icons.label)
                          : (_typeIcons[hit.family] ?? Icons.category);
                      return _buildTypeSubtypeChip(
                        label: label,
                        icon: icon,
                        gridTile: true,
                        onTap: () {
                          setState(() {
                            _typeFamilyController.text = hit.family;
                            _typeSubtypeController.text = hit.subtype ?? '';
                            _typePickerExpanded = false;
                            _subtypePickerExpanded = hit.subtype == null;
                            _clearTypeSearch();
                            _syncAccentColorFromPlanConfig(force: true);
                          });
                        },
                      );
                    },
                  );
                }

                final sortedFamilies = [..._typeFamilies]
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: narrow ? 8 : 10,
                    mainAxisSpacing: narrow ? 8 : 10,
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
                      gridTile: true,
                      onTap: () {
                        setState(() {
                          _typeFamilyController.text = family;
                          _typeSubtypeController.text = '';
                          _typePickerExpanded = false;
                          _subtypePickerExpanded = true;
                          _clearTypeSearch();
                          _syncAccentColorFromPlanConfig(force: true);
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
                    _clearTypeSearch();
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                loc.eventSubtype,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final sortedSubtypes = [...subtypes]
                    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                  final filtered = searchQuery.isEmpty
                      ? sortedSubtypes
                      : sortedSubtypes
                          .where((s) => _matchesTypeQuery(s, searchQuery))
                          .toList();
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        loc.eventTypeSearchEmpty,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: narrow ? 8 : 10,
                      mainAxisSpacing: narrow ? 8 : 10,
                      childAspectRatio: typeGridAspect,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final subtype = filtered[index];
                      final selected = _typeSubtypeController.text == subtype;
                      return _buildTypeSubtypeChip(
                        label: subtype,
                        icon: _subtypeIcons[
                                '${_typeFamilyController.text}|$subtype'] ??
                            Icons.label,
                        selected: selected,
                        gridTile: true,
                        onTap: () {
                          setState(() {
                            _typeSubtypeController.text = subtype;
                            _subtypePickerExpanded = false;
                            _clearTypeSearch();
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
                        _clearTypeSearch();
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
                        setState(() {
                          _subtypePickerExpanded = true;
                          _clearTypeSearch();
                        });
                      },
                    )
                  else
                    _buildTypeSubtypeChip(
                      label: loc.chooseSubtypeLabel,
                      icon: Icons.add,
                      selected: false,
                      showPlus: false,
                      onTap: () {
                        setState(() {
                          _subtypePickerExpanded = true;
                          _clearTypeSearch();
                        });
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
    bool gridTile = false,
    VoidCallback? onTap,
  }) {
    final color = selected
        ? AppColorScheme.color2.withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.06);
    final borderColor = selected
        ? AppColorScheme.color2
        : Colors.white.withValues(alpha: 0.12);
    final labelColor = selected ? Colors.white : Colors.white70;

    final Widget content;
    if (gridTile) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: labelColor),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                height: 1.1,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: labelColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            if (showPlus) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.add_circle_outline,
                size: 15,
                color: selected ? Colors.white : Colors.white54,
              ),
            ],
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: gridTile ? double.infinity : null,
          height: gridTile ? double.infinity : null,
          alignment: gridTile ? Alignment.center : null,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: content,
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
      final origin = _twoLinePlaceDisplayName(_taxiOriginController.text);
      final dest = _twoLinePlaceDisplayName(_taxiDestinationController.text);
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

    // Acción vinculada a vehículo de alquiler: sugerir texto útil con compañía/oficina.
    if (family == 'Acción' &&
        (subtype == 'Recogida vehículo alquiler' ||
            subtype == 'Entrega vehículo alquiler')) {
      final company = _rentalCompanyController.text.trim();
      final office = _rentalOfficeController.text.trim();
      if (company.isNotEmpty && office.isNotEmpty) {
        return '$subtype · ${short(company)} (${short(office)})';
      }
      if (company.isNotEmpty) return '$subtype · ${short(company)}';
      return subtype;
    }

    // Evento con localización (prioriza nombre del lugar)
    final location = _eventLocationDisplayText;
    if (location.isNotEmpty) {
      if (subtype.isNotEmpty) return '$subtype · ${short(location)}';
      return short(location);
    }

    // Sin ubicación: solo subtipo
    if (subtype.isNotEmpty) return subtype;
    return 'Evento';
  }

  /// Bloque Origen + Destino (+ opcionalmente Plazas) para Desplazamiento.
  Widget _buildTransportOriginDestinationBlock({required bool showPlazas}) {
    final loc = AppLocalizations.of(context)!;
    final previous = _lookupPreviousPlanLocation();
    final canEdit = _canEditGeneral || _canEditGeneralInitial;
    return IosGroupedCard(
      children: [
        _iosPlaceFieldRow(
          label: loc.taxiOriginLabel,
          hint: loc.taxiOriginHint,
          controller: _taxiOriginController,
          initialAddress: _taxiOriginController.text.isNotEmpty
              ? _taxiOriginController.text
              : null,
          canOpenMaps: _taxiOriginController.text.trim().isNotEmpty ||
              _taxiOriginDetails != null ||
              _taxiOriginStoredLat != null,
          onOpenMaps: () => _openTaxiAddressInMaps(
            _twoLinePlaceMapsQuery(_taxiOriginController.text),
            _taxiOriginDetails?.lat ?? _taxiOriginStoredLat,
            _taxiOriginDetails?.lng ?? _taxiOriginStoredLng,
          ),
          onPlaceSelected: (PlaceDetails details) {
            setState(() {
              _taxiOriginDetails = details;
              _taxiOriginController.text = formatPlaceNameAndAddress(
                details.displayName,
                details.formattedAddress,
              );
              _taxiOriginStoredLat = details.lat;
              _taxiOriginStoredLng = details.lng;
            });
          },
        ),
        if (previous != null && canEdit)
          IosSettingsRow(
            label: loc.usePreviousLocation,
            value: () {
              final raw = (previous.sourceLabel ?? previous.address).trim();
              if (raw.isEmpty) return '—';
              return raw.length > 36 ? '${raw.substring(0, 34)}…' : raw;
            }(),
            valueColor: IosFormColors.accent,
            chevron: true,
            onTap: () => _applyPreviousPlanLocationToOrigin(previous),
          ),
        Builder(
          builder: (context) {
            final hotelAction = _buildAccommodationEndpointActions(
              hotels: _lookupPreviousDayAccommodations(),
              onApply: _applyPreviousPlanLocationToOrigin,
              singleLabel: loc.useAccommodationAsOrigin,
              menuLabel: loc.useAccommodationAsOriginMenu,
            );
            if (hotelAction == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: hotelAction,
            );
          },
        ),
        const IosRowSeparator(),
        _iosPlaceFieldRow(
          label: loc.taxiDestinationLabel,
          hint: loc.taxiDestinationHint,
          controller: _taxiDestinationController,
          initialAddress: _taxiDestinationController.text.isNotEmpty
              ? _taxiDestinationController.text
              : null,
          canOpenMaps: _taxiDestinationController.text.trim().isNotEmpty ||
              _taxiDestinationDetails != null ||
              _taxiDestinationStoredLat != null,
          onOpenMaps: () => _openTaxiAddressInMaps(
            _twoLinePlaceMapsQuery(_taxiDestinationController.text),
            _taxiDestinationDetails?.lat ?? _taxiDestinationStoredLat,
            _taxiDestinationDetails?.lng ?? _taxiDestinationStoredLng,
          ),
          onPlaceSelected: (PlaceDetails details) {
            setState(() {
              _taxiDestinationDetails = details;
              _taxiDestinationController.text = formatPlaceNameAndAddress(
                details.displayName,
                details.formattedAddress,
              );
              _taxiDestinationStoredLat = details.lat;
              _taxiDestinationStoredLng = details.lng;
            });
          },
        ),
        Builder(
          builder: (context) {
            final hotelAction = _buildAccommodationEndpointActions(
              hotels: _lookupSameDayAccommodations(),
              onApply: _applyPreviousPlanLocationToDestination,
              singleLabel: loc.useAccommodationAsDestination,
              menuLabel: loc.useAccommodationAsDestinationMenu,
            );
            if (hotelAction == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: hotelAction,
            );
          },
        ),
        const IosRowSeparator(),
        ListenableBuilder(
          listenable: Listenable.merge([
            _taxiOriginController,
            _taxiDestinationController,
          ]),
          builder: (context, _) {
            final canOpenRoute =
                _taxiOriginController.text.trim().isNotEmpty &&
                    _taxiDestinationController.text.trim().isNotEmpty;
            return IosSettingsRow(
              label: loc.openRouteInGoogleMaps,
              value: '',
              valueColor: IosFormColors.accent,
              chevron: canOpenRoute,
              onTap: canOpenRoute ? _openTransportRouteInGoogleMaps : null,
            );
          },
        ),
        if (showPlazas) ...[
          const IosRowSeparator(),
          IosSettingsRow(
            label: loc.taxiSeatsLabel,
            value: '$_taxiSeats',
            chevron: canEdit,
            onTap: canEdit
                ? () async {
                    final picked = await IosFormPickerSheet.show<int>(
                      context: context,
                      title: loc.taxiSeatsLabel,
                      options: List.generate(
                        9,
                        (i) => IosFormPickerOption(
                          value: i + 1,
                          title: '${i + 1}',
                          selected: _taxiSeats == i + 1,
                        ),
                      ),
                    );
                    if (picked != null && mounted) {
                      setState(() => _taxiSeats = picked);
                    }
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
    return IosGroupedCard(
      children: [
        IgnorePointer(
          ignoring: ro,
          child: IosEditField(
            label: loc.eventTransferTerminalLabel,
            controller: _transferTerminalController,
            hint: loc.eventTransferTerminalHint,
          ),
        ),
        const IosRowSeparator(),
        IgnorePointer(
          ignoring: ro,
          child: IosEditField(
            label: loc.eventTransferAirlineLabel,
            controller: _transferAirlineController,
            hint: loc.eventTransferAirlineHint,
          ),
        ),
        const IosRowSeparator(),
        IgnorePointer(
          ignoring: ro,
          child: IosEditField(
            label: loc.eventTransferAirportMeetLabel,
            controller: _transferAirportMeetController,
            minLines: 1,
            maxLines: 2,
            hint: loc.eventTransferAirportMeetHint,
          ),
        ),
      ],
    );
  }

  bool get _isRentalVehicleActionSubtype {
    if (_typeFamilyController.text != 'Acción') return false;
    final s = _typeSubtypeController.text;
    return s == 'Recogida vehículo alquiler' ||
        s == 'Entrega vehículo alquiler';
  }

  Widget _buildRentalVehicleActionFields() {
    final loc = AppLocalizations.of(context)!;
    final ro = !(_canEditGeneral || _canEditGeneralInitial);
    return IosGroupedCard(
      children: [
        IgnorePointer(
          ignoring: ro,
          child: IosEditField(
            label: loc.eventRentalCompanyLabel,
            controller: _rentalCompanyController,
            hint: loc.eventRentalCompanyHint,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return null;
              if (v.length > 120) return 'Máximo 120 caracteres';
              return null;
            },
          ),
        ),
        const IosRowSeparator(),
        IgnorePointer(
          ignoring: ro,
          child: IosEditField(
            label: loc.eventRentalOfficeLabel,
            controller: _rentalOfficeController,
            hint: loc.eventRentalOfficeHint,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return null;
              if (v.length > 180) return 'Máximo 180 caracteres';
              return null;
            },
          ),
        ),
        const IosRowSeparator(),
        IgnorePointer(
          ignoring: ro,
          child: IosEditField(
            label: loc.eventRentalContractCodeLabel,
            controller: _rentalContractCodeController,
            hint: loc.eventRentalContractCodeHint,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return null;
              if (v.length > 60) return 'Máximo 60 caracteres';
              return null;
            },
          ),
        ),
        const IosRowSeparator(),
        IgnorePointer(
          ignoring: ro,
          child: IosEditField(
            label: loc.eventRentalVehiclePlateLabel,
            controller: _rentalVehiclePlateController,
            hint: loc.eventRentalVehiclePlateHint,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return null;
              if (v.length > 20) return 'Máximo 20 caracteres';
              return null;
            },
          ),
        ),
        const IosRowSeparator(),
        IgnorePointer(
          ignoring: ro,
          child: IosEditField(
            label: loc.eventRentalPickupReturnNotesLabel,
            controller: _rentalPickupReturnNotesController,
            minLines: 1,
            maxLines: 3,
            hint: loc.eventRentalPickupReturnNotesHint,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return null;
              if (v.length > 600) return 'Máximo 600 caracteres';
              return null;
            },
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
              color: Colors.white70,
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

  /// Modo de viaje para la URL de direcciones según el subtipo.
  String _transportMapsTravelMode() {
    switch (_typeSubtypeController.text) {
      case 'Caminar':
        return 'walking';
      case 'Autobús':
      case 'Tren':
      case 'Shuttle':
      case 'Transfer':
        return 'transit';
      case 'Coche':
      case 'Taxi':
      default:
        return 'driving';
    }
  }

  String _mapsDirPoint({
    required String address,
    double? lat,
    double? lng,
  }) {
    if (lat != null && lng != null) return '$lat,$lng';
    return address.trim();
  }

  /// Abre Google Maps con ruta origen → destino (muestra duración en Maps).
  Future<void> _openTransportRouteInGoogleMaps() async {
    final origin = _mapsDirPoint(
      address: _twoLinePlaceMapsQuery(_taxiOriginController.text),
      lat: _taxiOriginDetails?.lat ?? _taxiOriginStoredLat,
      lng: _taxiOriginDetails?.lng ?? _taxiOriginStoredLng,
    );
    final destination = _mapsDirPoint(
      address: _twoLinePlaceMapsQuery(_taxiDestinationController.text),
      lat: _taxiDestinationDetails?.lat ?? _taxiDestinationStoredLat,
      lng: _taxiDestinationDetails?.lng ?? _taxiDestinationStoredLng,
    );
    if (origin.isEmpty || destination.isEmpty) return;

    final url = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': origin,
      'destination': destination,
      'travelmode': _transportMapsTravelMode(),
    });
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openFlightTimezonePicker({required bool isArrival}) async {
    if (!_canEditGeneral) return;
    final selected = isArrival ? _selectedArrivalTimezone : _selectedTimezone;
    final all = TimezoneService.getCommonTimezones();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF111827),
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
                    : Colors.white70,
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
                      : Colors.white70,
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

  /// T246: Bloque vuelo (aeropuertos + nº + Amadeus) en card Settings.
  Widget _buildFlightNumberBlock() {
    final loc = AppLocalizations.of(context)!;
    final canEdit = _canEditGeneral;
    return IosGroupedCard(
      children: [
        _iosPlaceFieldRow(
          label: loc.departureAirportLabel,
          hint: loc.departureAirportHint,
          controller: _departureAirportController,
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
        IosSettingsRow(
          label: loc.timezone,
          value: _timezoneRowValue(_selectedTimezone),
          chevron: canEdit,
          onTap: canEdit
              ? () => _openFlightTimezonePicker(isArrival: false)
              : null,
        ),
        const IosRowSeparator(),
        _iosPlaceFieldRow(
          label: loc.arrivalAirportLabel,
          hint: loc.arrivalAirportHint,
          controller: _arrivalAirportController,
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
        IosSettingsRow(
          label: loc.arrivalTimezone,
          value: _timezoneRowValue(_selectedArrivalTimezone),
          chevron: canEdit,
          onTap: canEdit
              ? () => _openFlightTimezonePicker(isArrival: true)
              : null,
        ),
        const IosRowSeparator(),
        IgnorePointer(
          ignoring: !canEdit,
          child: IosEditField(
            label: loc.flightNumberLabel,
            controller: _flightNumberController,
            hint: loc.flightNumberHint,
          ),
        ),
        if (canEdit) ...[
          const IosRowSeparator(),
          IosSettingsRow(
            label: loc.getFlightDataButton,
            value: _flightStatusLoading
                ? '…'
                : (_lastFlightStatus?.shortDescription ?? ''),
            valueColor: IosFormColors.accent,
            chevron: !_flightStatusLoading,
            onTap: _flightStatusLoading ? null : _fetchFlightStatus,
          ),
        ],
        if (_lastFlightStatus != null &&
            (_lastFlightStatus!.departureScheduled != null ||
                _lastFlightStatus!.arrivalScheduled != null)) ...[
          const IosRowSeparator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Text(
              _formatFlightTimes(
                _lastFlightStatus!.departureScheduled,
                _lastFlightStatus!.arrivalScheduled,
              ),
              style: const TextStyle(
                fontSize: 13,
                color: IosFormColors.textSecondary,
              ),
            ),
          ),
        ],
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
    final fromField = _twoLinePlaceMapsQuery(_locationController.text);
    final address = _lastPlaceDetails?.formattedAddress ??
        (fromField.isNotEmpty ? fromField : null) ??
        widget.event?.commonPart?.extraData?['placeAddress'] as String? ??
        widget.event?.commonPart?.location;
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
        color: _formSurface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
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
                fontSize: isMobile ? 14 : 17,
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

  void _onEventCancel() {
    Navigator.of(context).pop();
  }

  Future<void> _onEventSave() async {
    await _saveEvent();
  }

  String _formatEventDateLabel() => DateFormatter.formatDate(_selectedDate);

  String _formatEventTimeLabel() {
    final hh = _selectedHour.toString().padLeft(2, '0');
    final mm = _selectedStartMinute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatEventDurationLabel() {
    final h = _selectedDurationMinutes ~/ 60;
    final m = _selectedDurationMinutes % 60;
    if (h > 0 && m > 0) return '$h h $m min';
    if (h > 0) return '$h h';
    return '$m min';
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
          backgroundColor: _formSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 0 : 18),
            side: isMobile
                ? BorderSide.none
                : BorderSide(
                    color: Colors.white.withValues(alpha: 0.22), width: 1),
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
                          color: Colors.white70,
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
    final contentHeight = isMobile
        ? screenSize.height
        : (screenSize.height - 96).clamp(420.0, 640.0);
    final contentWidth = isMobile ? screenSize.width : 520.0;
    final canEditBar =
        (_canEditGeneral || _canEditGeneralInitial) && _canSaveEvent();

    return Theme(
      data: AppTheme.darkTheme,
      child: AlertDialog(
        // scrollable:true fuerza IntrinsicWidth y rompe ListView (vista D) en web.
        scrollable: false,
        backgroundColor: _formSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 0 : 18),
          side: isMobile
              ? BorderSide.none
              : BorderSide(
                  color: Colors.white.withValues(alpha: 0.22), width: 1),
        ),
        insetPadding: isMobile
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        title: null,
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: contentWidth,
          height: contentHeight,
          // Material (no ColoredBox): ListTile/Checkbox ink bajo pageBg negro.
          child: Material(
            color: _formSurface,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: IosFormEditBar(
                          editing: true,
                          canEdit: canEditBar,
                          saving: _isSavingEvent,
                          centeredTitle: true,
                          modalIconActions: true,
                          editLabel: AppLocalizations.of(context)!.edit,
                          cancelLabel: AppLocalizations.of(context)!
                              .planDetailsBarCancelShort,
                          saveLabel: widget.event == null
                              ? AppLocalizations.of(context)!.create
                              : AppLocalizations.of(context)!
                                  .planDetailsBarSaveShort,
                          title: dialogTitle,
                          onEdit: () {},
                          onCancel: _onEventCancel,
                          onSave: _onEventSave,
                        ),
                      ),
                    ],
                  ),
                  if (_isParticipantCreatingProposal)
                    _buildProposalHint(context, isMobile),
                  Expanded(
                    child: _buildEventTabsForm(isMobile: isMobile),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Formulario único con pestañas (General / Mi info / Pagos / [Otros]).
  int get _eventFormTabCount => 3 + (_isAdmin ? 1 : 0);

  Widget _buildEventTabsForm({required bool isMobile}) {
    final horizontalPad = isMobile ? 12.0 : 16.0;
    final topPad = isMobile ? 8.0 : 12.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPad, topPad, horizontalPad, 0),
      child: Form(
        key: _formKey,
        child: SizedBox(
          width: isMobile ? double.infinity : 520,
          child: DefaultTabController(
            length: _eventFormTabCount,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Builder(
                  builder: (context) {
                    final tabController = DefaultTabController.of(context);
                    final tabLabels = [
                      AppLocalizations.of(context)!.eventTabGeneral,
                      AppLocalizations.of(context)!.eventTabMyInfo,
                      AppLocalizations.of(context)!.eventTabPayments,
                      if (_isAdmin)
                        AppLocalizations.of(context)!.eventTabOthersInfo,
                    ].whereType<String>().toList();
                    return ListenableBuilder(
                      listenable: tabController,
                      builder: (context, _) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
                          child: IosSegmentedControl(
                            labels: tabLabels,
                            selectedIndex: tabController.index,
                            fontSize: isMobile ? 12 : 13,
                            onChanged: tabController.animateTo,
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: TabBarView(
                    children: _buildEventTabViews(isMobile: isMobile),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickEventStatus() async {
    final loc = AppLocalizations.of(context)!;
    final picked = await IosFormPickerSheet.show<bool>(
      context: context,
      title: loc.planDetailsStateLabel,
      options: [
        IosFormPickerOption(
          value: true,
          title: loc.eventStatusDraft,
          selected: _isDraft,
        ),
        IosFormPickerOption(
          value: false,
          title: loc.eventStatusConfirmed,
          selected: !_isDraft,
        ),
      ],
    );
    if (picked != null && mounted) {
      setState(() => _isDraft = picked);
    }
  }

  /// Lista de pestañas del formulario (General, Mi info, Pagos, [Otros]).
  List<Widget> _buildEventTabViews({required bool isMobile}) {
    return [
      _buildGeneralTabScroll(isMobile),
      _buildMyInfoTabScroll(isMobile),
      _buildPaymentsTabScroll(isMobile),
      if (_isAdmin) _buildOthersInfoTab(),
    ].whereType<Widget>().toList();
  }

  Widget _buildPaymentsTabScroll(bool isMobile) {
    return EventPaymentsTab(
      plan: _plan,
      eventId: widget.event?.id,
      budgetCost: widget.event?.cost,
      planCurrency: _planCurrency ?? 'EUR',
      isMobile: isMobile,
    );
  }

  bool _hasGeneralEventTypeSelected() {
    final f = _typeFamilyController.text.trim();
    return f.isNotEmpty && _typeFamilies.contains(f);
  }

  Widget _buildGeneralTabScroll(bool isMobile) {
    final pad = isMobile ? 4.0 : 8.0;
    final spacing = isMobile ? _fieldGap : 16.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, isMobile ? 16 : 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero: título + chips (fecha / hora / duración / estado)
          Builder(builder: (context) {
            final loc = AppLocalizations.of(context)!;
            final canEdit = _canEditGeneral || _canEditGeneralInitial;
            final titleText = _descriptionController.text.trim().isEmpty
                ? loc.editEvent
                : _descriptionController.text.trim();
            final showAsDraft =
                _isParticipantCreatingProposal ? true : _isDraft;
            final statusColor = showAsDraft
                ? ColorUtils.confirmedColors['actividad']! // naranja app
                : ColorUtils.confirmedColors['alojamiento']!; // verde app
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IosHeroHeader(
                  title: canEdit ? null : titleText,
                  titleWidget: canEdit
                      ? TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(
                            color: IosFormColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            height: 1.15,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: loc.eventDescriptionHint,
                            hintStyle: const TextStyle(
                              color: IosFormColors.textTertiary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                              height: 1.15,
                            ),
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
                          onChanged: (_) => setState(() {}),
                        )
                      : null,
                  chips: [
                    IosHeroChipData(
                      _formatEventDateLabel(),
                      accent: true,
                      onTap: canEdit ? _selectDate : null,
                    ),
                    IosHeroChipData(
                      _formatEventTimeLabel(),
                      onTap: canEdit ? _selectStartTime : null,
                    ),
                    IosHeroChipData(
                      _formatEventDurationLabel(),
                      onTap: canEdit ? _selectDuration : null,
                    ),
                    IosHeroChipData(
                      showAsDraft
                          ? loc.eventStatusDraft
                          : loc.eventStatusConfirmed,
                      color: statusColor,
                      onTap: (!_isParticipantCreatingProposal && canEdit)
                          ? _pickEventStatus
                          : null,
                    ),
                  ],
                ),
              ],
            );
          }),
          // Tipo / subtipo (label solo dentro de la fila Settings)
          SizedBox(height: spacing),
          IosGroupedCard(
            children: [
              _wrapReadOnlyIfNeeded(child: _buildTypeSubtypeSelector()),
            ],
          ),
          if (widget.event == null && !_hasGeneralEventTypeSelected())
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: spacing),
              child: Text(
                AppLocalizations.of(context)!.eventSelectTypeFirstHint,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.white70),
              ),
            ),
          if (widget.event != null || _hasGeneralEventTypeSelected()) ...[
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text == 'Avión') ...[
              SizedBox(height: spacing),
              _wrapReadOnlyIfNeeded(child: _buildFlightNumberBlock()),
            ],
            // Ubicación / transporte / extras
            if (_typeFamilyController.text != 'Desplazamiento') ...[
              SizedBox(height: spacing),
              IosGroupedCard(
                children: [
                  _buildUnifiedLocationField(),
                  const IosRowSeparator(),
                  _buildNonTransportTimezoneSelector(),
                ],
              ),
            ],
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text.isNotEmpty &&
                _typeSubtypeController.text != 'Avión') ...[
              SizedBox(height: spacing),
              _wrapReadOnlyIfNeeded(
                  child: _buildTransportOriginDestinationBlock(
                      showPlazas: _typeSubtypeController.text == 'Taxi')),
            ],
            if (_typeFamilyController.text == 'Desplazamiento' &&
                (_typeSubtypeController.text == 'Shuttle' ||
                    _typeSubtypeController.text == 'Transfer')) ...[
              SizedBox(height: spacing),
              _wrapReadOnlyIfNeeded(
                  child: _buildGroundTransferAirportExtraFields()),
            ],
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text.isNotEmpty) ...[
              SizedBox(height: spacing),
              _buildStaticSponsorCard(),
            ],
            if (_isRentalVehicleActionSubtype) ...[
              SizedBox(height: spacing),
              _wrapReadOnlyIfNeeded(child: _buildRentalVehicleActionFields()),
            ],
            if (_typeFamilyController.text == 'Desplazamiento' &&
                _typeSubtypeController.text != 'Avión') ...[
              SizedBox(height: spacing),
              IosGroupedCard(
                children: [
                  IosSettingsRow(
                    label: AppLocalizations.of(context)!.timezone,
                    value: _timezoneRowValue(_selectedTimezone),
                    chevron: _canEditGeneral,
                    onTap: _canEditGeneral
                        ? () => _openFlightTimezonePicker(isArrival: false)
                        : null,
                  ),
                  const IosRowSeparator(),
                  IosSettingsRow(
                    label: AppLocalizations.of(context)!.arrivalTimezone,
                    value: _timezoneRowValue(_selectedArrivalTimezone),
                    chevron: _canEditGeneral,
                    onTap: _canEditGeneral
                        ? () => _openFlightTimezonePicker(isArrival: true)
                        : null,
                  ),
                ],
              ),
            ],
            SizedBox(height: spacing),
            // 6. URL + notas + archivos + coste + reserva
            _wrapReadOnlyIfNeeded(child: _buildUrlField()),
            SizedBox(height: spacing),
            _wrapReadOnlyIfNeeded(child: _buildLongNotesField()),
            if (widget.planId != null) ...[
              SizedBox(height: spacing),
              // Archivos (Settings: Añadir + filas por archivo)
              IosGroupedCard(
                children: [
                  EntityAttachmentsSection(
                    title: '',
                    files: _eventDocuments,
                    canManage: _canEditGeneral || _canEditGeneralInitial,
                    isUploading: _uploadingEventAttachment,
                    onUpload: (_canEditGeneral || _canEditGeneralInitial)
                        ? _pickEventAttachment
                        : null,
                    onDelete: _deleteEventAttachment,
                    embeddedInGroupedCard: true,
                  ),
                ],
              ),
            ],
            if (_planCurrency != null) ...[
              SizedBox(height: spacing),
              _wrapReadOnlyIfNeeded(child: _buildCostFieldWithCurrency()),
            ],
            if (widget.planId != null && _planCurrency != null) ...[
              SizedBox(height: spacing),
              // T273 Reserva / cancelación (siempre moneda del plan)
              _wrapReadOnlyIfNeeded(
                child: Builder(builder: (context) {
                  final parts = ref
                          .watch(planRealParticipantsProvider(widget.planId!))
                          .valueOrNull ??
                      [];
                  final names = ref
                          .watch(planParticipantDisplayNamesProvider(widget.planId!))
                          .valueOrNull ??
                      {};
                  final payers = parts
                      .map(
                        (p) => ReservationPayerOption(
                          userId: p.userId,
                          label: names[p.userId] ?? p.userId,
                        ),
                      )
                      .toList();
                  return ReservationCancellationFormSection(
                    key: _reservationSectionKey,
                    initial: widget.event?.reservationCancellation,
                    payers: payers,
                    defaultTimezone: _selectedTimezone.isNotEmpty
                        ? _selectedTimezone
                        : _plan?.timezone,
                    currencyCode: _planCurrency!,
                    readOnly: !_canEditGeneral,
                  );
                }),
              ),
            ],
            SizedBox(height: spacing),
            // Participantes (switch + lista en la misma card)
            _wrapReadOnlyIfNeeded(child: _buildParticipantsScopeSection()),
            SizedBox(height: spacing),
            // Color
            _wrapReadOnlyIfNeeded(child: _buildColorSelectorRow()),
            SizedBox(height: spacing),
          ],
          if (widget.event != null &&
              _canDeleteEvent() &&
              (_canEditGeneral || _canEditGeneralInitial)) ...[
            const SizedBox(height: 20),
            IosDestructiveTile(
              label: AppLocalizations.of(context)!.delete,
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLongNotesField() {
    final loc = AppLocalizations.of(context)!;
    final canEdit = _canEditGeneral || _canEditGeneralInitial;
    return IosGroupedCard(
      children: [
        Stack(
          children: [
            IgnorePointer(
              ignoring: !canEdit,
              child: IosEditField(
                label: loc.eventLongNotesLabel,
                controller: _longNotesController,
                minLines: 2,
                maxLines: 4,
                hint: loc.eventLongNotesLabel,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: loc.expandEditorTooltip,
                onPressed: _openLongNotesEditor,
                icon: const Icon(
                  Icons.open_in_full,
                  size: 18,
                  color: IosFormColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyInfoTabScroll(bool isMobile) {
    final pad = isMobile ? 4.0 : 8.0;
    final gap = isMobile ? _fieldGap : 16.0;
    final loc = AppLocalizations.of(context)!;
    final isActivity = _typeFamilyController.text == 'Actividad';

    String? maxLenValidator(String? value, int max) {
      final v = value?.trim() ?? '';
      if (v.isEmpty) return null;
      if (v.length > max) return loc.maxCharacters(max);
      return null;
    }

    final cardChildren = <Widget>[
      IosEditField(
        label: loc.seat,
        controller: _asientoController,
        hint: loc.seatHint,
        validator: (v) => maxLenValidator(v, 50),
      ),
    ];

    if (isActivity) {
      cardChildren.addAll([
        const IosRowSeparator(),
        IosEditField(
          label: loc.eventMyInfoEntryCodeLabel,
          controller: _activityEntryCodeController,
          hint: loc.eventMyInfoEntryCodeHint,
          validator: (v) => maxLenValidator(v, 50),
        ),
        const IosRowSeparator(),
        IosEditField(
          label: loc.eventMyInfoTicketUrlLabel,
          controller: _activityEntryDocUrlController,
          hint: loc.eventMyInfoTicketUrlHint,
          keyboardType: TextInputType.url,
          validator: (v) => maxLenValidator(v, 500),
        ),
      ]);
    } else {
      cardChildren.addAll([
        const IosRowSeparator(),
        IosEditField(
          label: loc.menu,
          controller: _menuController,
          hint: loc.menuHint,
          validator: (v) => maxLenValidator(v, 100),
        ),
        const IosRowSeparator(),
        IosEditField(
          label: loc.preferences,
          controller: _preferenciasController,
          hint: loc.preferencesHint,
          maxLines: 2,
          minLines: 1,
          validator: (v) => maxLenValidator(v, 200),
        ),
        const IosRowSeparator(),
        IosEditField(
          label: loc.reservationNumber,
          controller: _numeroReservaController,
          hint: loc.reservationNumberHint,
          validator: (v) => maxLenValidator(v, 50),
        ),
        const IosRowSeparator(),
        IosEditField(
          label: loc.gate,
          controller: _gateController,
          hint: loc.gateHint,
          validator: (v) => maxLenValidator(v, 50),
        ),
      ]);
    }

    cardChildren.addAll([
      const IosRowSeparator(),
      IosSwitchRow(
        label: loc.cardObtained,
        value: _tarjetaObtenida,
        onChanged: (value) => setState(() => _tarjetaObtenida = value),
      ),
      const IosRowSeparator(),
      IosEditField(
        label: loc.personalNotes,
        controller: _notasPersonalesController,
        hint: loc.eventMyInfoPersonalNotesHint,
        maxLines: 4,
        minLines: 2,
        validator: (v) => maxLenValidator(v, 1000),
      ),
    ]);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, isMobile ? 16 : 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.eventMyInfoSubtitle,
            style: const TextStyle(
              fontSize: 12,
              color: IosFormColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: gap),
          IosGroupedCard(children: cardChildren),
          SizedBox(height: gap),
          IosFormFooter(loc.eventMyInfoPrivacyFooter),
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

  bool get _isLegacyEventWithoutParticipants {
    return widget.event != null &&
        !_initialIsForAllParticipants &&
        _initialSelectedParticipantIds.isEmpty;
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
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade400.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(_fieldRadius),
              border: Border.all(
                color: Colors.orange.shade400.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings,
                    color: Colors.orange.shade300, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Como administrador puedes ver la información personal de otros participantes.',
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
          const SizedBox(height: 14),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _buildLoginStyleDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColorScheme.color2, size: 20),
                const SizedBox(width: 8),
                FutureBuilder<String>(
                  future: _getUserDisplayName(participantId),
                  builder: (context, snapshot) {
                    final displayName = snapshot.data ?? participantId;
                    return Flexible(
                      child: Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

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
                  color: const Color(0xFF1F2937), // Color sólido, sin gradiente
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Sin permisos para editar',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
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
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'No especificado',
              style: GoogleFonts.poppins(
                color: value != null ? Colors.white : Colors.white60,
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
      builder: (context) => _EventDurationPickerDialog(
        initialMinutes: _selectedDurationMinutes,
        startHour: _selectedHour,
        startMinute: _selectedStartMinute,
        formatDuration: _formatDuration,
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

  Widget _buildColorSelectorRow() {
    final loc = AppLocalizations.of(context)!;
    return IosGroupedCard(
      children: [
        IosColorSettingRow(
          label: loc.color,
          color: _getColorFromName(_selectedColor),
          chevron: _canEditGeneral,
          onTap: _canEditGeneral ? _showColorPicker : null,
        ),
      ],
    );
  }

  Future<void> _showColorPicker() async {
    final loc = AppLocalizations.of(context)!;
    final picked = await IosFormColorPickerSheet.show(
      context: context,
      title: loc.color,
      selectedId: _selectedColor,
      options: _eventColors
          .map(
            (colorName) => IosFormColorPickerOption(
              id: colorName,
              color: _getColorFromName(colorName),
            ),
          )
          .toList(),
    );
    if (!mounted || picked == null) return;
    setState(() => _selectedColor = picked);
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
                  AppLocalizations.of(context)!.eventDeleteBlockedFallback,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final confirmed = await showDeleteEventConfirmDialog(
      context,
      description: widget.event?.description ?? '',
    );

    if (confirmed == true &&
        widget.onDeleted != null &&
        widget.event?.id != null) {
      widget.onDeleted!(widget.event!.id!);
    }
  }

  /// Coste: una fila — importe a la izquierda, moneda (código+símbolo) a la derecha.
  Widget _buildCostFieldWithCurrency() {
    final loc = AppLocalizations.of(context)!;
    final exchangeRateService = ExchangeRateService();
    final currencyValue = _costCurrency ?? _planCurrency ?? 'EUR';
    final currency = Currency.fromCodeOrEur(currencyValue);
    final canEdit = _canEditGeneral;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IosGroupedCard(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: IgnorePointer(
                      ignoring: !canEdit,
                      child: TextFormField(
                        controller: _costController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: IosFormColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        cursorColor: IosFormColors.accent,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: '${loc.cost}: ${loc.costHint}',
                          hintStyle: const TextStyle(
                            color: IosFormColors.textTertiary,
                            fontSize: 17,
                          ),
                        ),
                        onChanged: canEdit
                            ? (_) => _convertCostToPlanCurrency(
                                  exchangeRateService,
                                )
                            : null,
                        validator: (value) {
                          if (!canEdit) return null;
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return null;
                          final doubleValue =
                              double.tryParse(v.replaceAll(',', '.'));
                          if (doubleValue == null) return loc.mustBeValidNumber;
                          if (doubleValue < 0) return loc.cannotBeNegative;
                          if (doubleValue > 1000000) return loc.maxAmount;
                          return null;
                        },
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: canEdit ? _pickCostCurrency : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${currency.code} ${currency.symbol}',
                              style: const TextStyle(
                                color: IosFormColors.textSecondary,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (canEdit) ...[
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right,
                                color: IosFormColors.textTertiary,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_costCurrency != null &&
            _planCurrency != null &&
            _costCurrency != _planCurrency &&
            _costController.text.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: _buildCostConversionHint(),
          ),
      ],
    );
  }

  Future<void> _pickCostCurrency() async {
    final loc = AppLocalizations.of(context)!;
    final current = _costCurrency ?? _planCurrency ?? 'EUR';
    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.costCurrency,
      options: Currency.supportedCurrencies
          .map(
            (c) => IosFormPickerOption(
              value: c.code,
              title: '${c.code} — ${c.symbol} ${c.name}',
              selected: c.code == current,
            ),
          )
          .toList(),
    );
    if (picked != null && mounted) {
      setState(() => _costCurrency = picked);
      await _convertCostToPlanCurrency(ExchangeRateService());
    }
  }

  Widget _buildCostConversionHint() {
    final loc = AppLocalizations.of(context)!;
    final exchangeRateService = ExchangeRateService();
    return FutureBuilder<double?>(
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
                    color: IosFormColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  loc.calculating,
                  style: const TextStyle(
                    fontSize: 12,
                    color: IosFormColors.textSecondary,
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
              color: IosFormColors.groupedBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: IosFormColors.accent.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.convertedTo(_planCurrency!),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: IosFormColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatterService.formatAmount(
                    convertedAmount,
                    _planCurrency!,
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: IosFormColors.accent,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
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

    // Convertir a moneda del plan (timeout: en offline la lectura Firestore de tipos puede colgar).
    final exchangeRateService = ExchangeRateService();
    try {
      final convertedAmount = await exchangeRateService
          .convertAmount(
            localAmount,
            _costCurrency!,
            _planCurrency!,
          )
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () => null,
          );
      return convertedAmount ?? localAmount;
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
    if (!_isForAllParticipants &&
        _selectedParticipantIds.isEmpty &&
        !_isLegacyEventWithoutParticipants) {
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

      // Construir EventCommonPart (T47). T225: location (nombre) + extraData dirección/coords
      final parsedLocation =
          parsePlaceNameAndAddress(_locationController.text);
      final locationForCommon = parsedLocation.name.isNotEmpty
          ? parsedLocation.name
          : parsedLocation.address;
      final locationSanitized = locationForCommon.isEmpty
          ? null
          : Sanitizer.sanitizePlainText(locationForCommon, maxLength: 500);
      final baseExtra =
          Map<String, dynamic>.from(widget.event?.commonPart?.extraData ?? {});
      if (parsedLocation.name.isNotEmpty) {
        baseExtra['placeName'] =
            Sanitizer.sanitizePlainText(parsedLocation.name, maxLength: 200);
      } else {
        baseExtra.remove('placeName');
      }
      if (parsedLocation.address.isNotEmpty) {
        baseExtra['placeAddress'] = Sanitizer.sanitizePlainText(
            parsedLocation.address,
            maxLength: 500);
      } else {
        baseExtra.remove('placeAddress');
      }
      if (_lastPlaceDetails != null) {
        if (_lastPlaceDetails!.lat != null) {
          baseExtra['placeLat'] = _lastPlaceDetails!.lat;
        }
        if (_lastPlaceDetails!.lng != null) {
          baseExtra['placeLng'] = _lastPlaceDetails!.lng;
        }
      } else if (locationForCommon.isEmpty) {
        baseExtra.remove('placeLat');
        baseExtra.remove('placeLng');
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
        final parsedOrigin =
            parsePlaceNameAndAddress(_taxiOriginController.text);
        final parsedDest =
            parsePlaceNameAndAddress(_taxiDestinationController.text);
        if (parsedOrigin.name.isNotEmpty || parsedOrigin.address.isNotEmpty) {
          if (parsedOrigin.name.isNotEmpty) {
            baseExtra['taxiOriginName'] = Sanitizer.sanitizePlainText(
                parsedOrigin.name,
                maxLength: 200);
          } else {
            baseExtra.remove('taxiOriginName');
          }
          baseExtra['taxiOriginAddress'] = Sanitizer.sanitizePlainText(
            parsedOrigin.address.isNotEmpty
                ? parsedOrigin.address
                : parsedOrigin.name,
            maxLength: 500,
          );
          if (_taxiOriginDetails?.lat != null) {
            baseExtra['taxiOriginLat'] = _taxiOriginDetails!.lat;
          }
          if (_taxiOriginDetails?.lng != null) {
            baseExtra['taxiOriginLng'] = _taxiOriginDetails!.lng;
          }
        } else {
          baseExtra.remove('taxiOriginName');
          baseExtra.remove('taxiOriginAddress');
          baseExtra.remove('taxiOriginLat');
          baseExtra.remove('taxiOriginLng');
        }
        if (parsedDest.name.isNotEmpty || parsedDest.address.isNotEmpty) {
          if (parsedDest.name.isNotEmpty) {
            baseExtra['taxiDestinationName'] = Sanitizer.sanitizePlainText(
                parsedDest.name,
                maxLength: 200);
          } else {
            baseExtra.remove('taxiDestinationName');
          }
          baseExtra['taxiDestinationAddress'] = Sanitizer.sanitizePlainText(
            parsedDest.address.isNotEmpty
                ? parsedDest.address
                : parsedDest.name,
            maxLength: 500,
          );
          if (_taxiDestinationDetails?.lat != null) {
            baseExtra['taxiDestinationLat'] = _taxiDestinationDetails!.lat;
          }
          if (_taxiDestinationDetails?.lng != null) {
            baseExtra['taxiDestinationLng'] = _taxiDestinationDetails!.lng;
          }
        } else {
          baseExtra.remove('taxiDestinationName');
          baseExtra.remove('taxiDestinationAddress');
          baseExtra.remove('taxiDestinationLat');
          baseExtra.remove('taxiDestinationLng');
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
      if (_isRentalVehicleActionSubtype) {
        final company = _rentalCompanyController.text.trim();
        final office = _rentalOfficeController.text.trim();
        final contract = _rentalContractCodeController.text.trim();
        final plate = _rentalVehiclePlateController.text.trim();
        final notes = _rentalPickupReturnNotesController.text.trim();

        if (company.isNotEmpty) {
          baseExtra['rentalCompany'] =
              Sanitizer.sanitizePlainText(company, maxLength: 120);
        } else {
          baseExtra.remove('rentalCompany');
        }
        if (office.isNotEmpty) {
          baseExtra['rentalOffice'] =
              Sanitizer.sanitizePlainText(office, maxLength: 180);
        } else {
          baseExtra.remove('rentalOffice');
        }
        if (contract.isNotEmpty) {
          baseExtra['rentalContractCode'] =
              Sanitizer.sanitizePlainText(contract, maxLength: 60);
        } else {
          baseExtra.remove('rentalContractCode');
        }
        if (plate.isNotEmpty) {
          baseExtra['rentalVehiclePlate'] =
              Sanitizer.sanitizePlainText(plate, maxLength: 20);
        } else {
          baseExtra.remove('rentalVehiclePlate');
        }
        if (notes.isNotEmpty) {
          baseExtra['rentalPickupReturnNotes'] =
              Sanitizer.sanitizePlainText(notes, maxLength: 600);
        } else {
          baseExtra.remove('rentalPickupReturnNotes');
        }
      } else {
        baseExtra.remove('rentalCompany');
        baseExtra.remove('rentalOffice');
        baseExtra.remove('rentalContractCode');
        baseExtra.remove('rentalVehiclePlate');
        baseExtra.remove('rentalPickupReturnNotes');
      }

      // Descripción: si el usuario dejó el campo vacío, generar una a partir de tipo, subtipo y ubicación
      var descriptionToSave = _buildDescriptionForSave().trim();
      // Firestore rules: description.size() >= 3
      if (descriptionToSave.length < 3) {
        descriptionToSave = 'Evento';
      }

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
        maxParticipants: widget.event?.maxParticipants,
        requiresConfirmation: widget.event?.requiresConfirmation ?? false,
        cost:
            await _getConvertedCost(), // T153: Coste convertido a moneda del plan
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        commonPart: commonPart,
        personalParts: personalParts,
        documents: _eventDocuments.isEmpty
            ? null
            : List<EventDocument>.from(_eventDocuments),
        reservationCancellation: _reservationSectionKey.currentState?.toModel(),
      );

      // T107: Detectar si el evento se extiende fuera del rango del plan
      if (widget.planId != null && !effectiveIsDraft) {
        final planService = ref.read(planServiceProvider);
        Plan? plan;
        try {
          // En offline este fetch remoto puede tardar o fallar; no debe bloquear el guardado.
          plan = await planService
              .getPlanById(widget.planId!)
              .timeout(const Duration(seconds: 3));
        } catch (_) {
          plan = null;
        }
        if (!mounted) return;

        if (plan != null) {
          final planForRange = plan;
          final expansionInfo =
              PlanRangeUtils.detectEventOutsideRange(event, planForRange);

          if (expansionInfo != null) {
            // Mostrar diálogo de confirmación
            final shouldExpand = await showDialog<bool>(
              context: context,
              builder: (context) => ExpandPlanDialog(
                plan: planForRange,
                expansionInfo: expansionInfo,
              ),
            );

            if (shouldExpand == true) {
              // Expandir el plan
              final newPlanValues = PlanRangeUtils.calculateExpandedPlanValues(
                  planForRange, expansionInfo);
              final success = await planService.expandPlan(
                planForRange,
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
                    backgroundColor: const Color(0xFF1F2937),
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
        await widget.onSaved!(event);
      }
    } catch (e, st) {
      LoggerService.error(
        'Error saving event from dialog',
        context: 'EVENT_DIALOG',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.eventNotSaved,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
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

/// Diálogo de duración: campo manual, hora fin (calcula duración) y presets.
class _EventDurationPickerDialog extends StatefulWidget {
  const _EventDurationPickerDialog({
    required this.initialMinutes,
    required this.startHour,
    required this.startMinute,
    required this.formatDuration,
  });

  final int initialMinutes;
  final int startHour;
  final int startMinute;
  final String Function(int minutes) formatDuration;

  @override
  State<_EventDurationPickerDialog> createState() =>
      _EventDurationPickerDialogState();
}

class _EventDurationPickerDialogState extends State<_EventDurationPickerDialog> {
  late final TextEditingController _customController;
  String? _customError;

  DateTime get _startAsDateTime =>
      DateTime(2000, 1, 1, widget.startHour, widget.startMinute);

  TimeOfDay get _impliedEndTime {
    final end = _startAsDateTime
        .add(Duration(minutes: widget.initialMinutes.clamp(1, 1440)));
    return TimeOfDay(hour: end.hour, minute: end.minute);
  }

  String get _startTimeLabel =>
      DateFormatter.formatTimeOnly(_startAsDateTime);

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(
      text: _formatCustomInput(widget.initialMinutes.clamp(1, 1440)),
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  /// Preferir `H:MM` si hay horas; si no, solo minutos.
  String _formatCustomInput(int minutes) {
    if (minutes < 60) return '$minutes';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  /// Acepta: `90`, `1:30`, `1h30`, `1h 30m`, `2h`.
  int? _parseCustomDuration(String raw) {
    final text = raw.trim().toLowerCase().replaceAll(',', '.');
    if (text.isEmpty) return null;

    final hm = RegExp(r'^(\d+)\s*[h:]\s*(\d{1,2})\s*m?$').firstMatch(text);
    if (hm != null) {
      final hours = int.parse(hm.group(1)!);
      final minutes = int.parse(hm.group(2)!);
      if (minutes > 59) return null;
      return hours * 60 + minutes;
    }

    final hoursOnly = RegExp(r'^(\d+)\s*h$').firstMatch(text);
    if (hoursOnly != null) {
      return int.parse(hoursOnly.group(1)!) * 60;
    }

    final minutesOnly = RegExp(r'^(\d+)\s*m(?:in)?$').firstMatch(text);
    if (minutesOnly != null) {
      return int.parse(minutesOnly.group(1)!);
    }

    final asInt = int.tryParse(text);
    if (asInt != null) return asInt;

    return null;
  }

  int _durationFromEndTime(TimeOfDay end) {
    final startMin = widget.startHour * 60 + widget.startMinute;
    var endMin = end.hour * 60 + end.minute;
    // Si fin ≤ inicio, asumimos que cruza medianoche (máx. 24 h).
    if (endMin <= startMin) {
      endMin += 24 * 60;
    }
    return endMin - startMin;
  }

  Future<void> _pickEndTime() async {
    final greenTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context)
          .colorScheme
          .copyWith(primary: Colors.green.shade600),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: _impliedEndTime,
      builder: (context, child) => Theme(data: greenTheme, child: child!),
    );
    if (!mounted || picked == null) return;

    final total = _durationFromEndTime(picked);
    if (total < 1 || total > 1440) {
      setState(() => _customError =
          AppLocalizations.of(context)!.eventDurationCustomInvalid);
      return;
    }
    Navigator.of(context).pop(total);
  }

  void _applyCustom() {
    final total = _parseCustomDuration(_customController.text);
    if (total == null || total < 1 || total > 1440) {
      setState(() => _customError =
          AppLocalizations.of(context)!.eventDurationCustomInvalid);
      return;
    }
    Navigator.of(context).pop(total);
  }

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF111827),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColorScheme.color2, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      prefixIcon: const Icon(Icons.timelapse, color: Colors.white70, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final sectionStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontSize: 14,
    );
    final itemStyle = GoogleFonts.poppins(color: Colors.white, fontSize: 14);
    final endLabel = DateFormatter.formatTimeOnly(
      DateTime(2000, 1, 1, _impliedEndTime.hour, _impliedEndTime.minute),
    );

    return Theme(
      data: AppTheme.darkTheme,
      child: AlertDialog(
        backgroundColor: const Color(0xFF374151),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          loc.duration,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: const Icon(Icons.schedule, color: Colors.white70),
                    title: Text(
                      '${loc.eventDurationEndTime}: $endLabel',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      loc.eventDurationEndTimeHint(_startTimeLabel),
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(Icons.edit_outlined,
                        color: Colors.white54, size: 18),
                    onTap: _pickEndTime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(loc.eventDurationCustom, style: sectionStyle),
                const SizedBox(height: 10),
                TextField(
                  controller: _customController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  style: itemStyle,
                  decoration: _fieldDecoration(
                    loc.eventDurationCustom,
                    loc.eventDurationCustomHint,
                  ),
                  onChanged: (_) {
                    if (_customError != null) {
                      setState(() => _customError = null);
                    }
                  },
                  onSubmitted: (_) => _applyCustom(),
                ),
                if (_customError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _customError!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red.shade300,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: _applyCustom,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorScheme.color2,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    loc.eventDurationApplyCustom,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                Text(loc.eventDurationCommon, style: sectionStyle),
                const SizedBox(height: 4),
                ...List.generate(12, (index) {
                  final minutes = (index + 1) * 15;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title:
                        Text(widget.formatDuration(minutes), style: itemStyle),
                    onTap: () => Navigator.of(context).pop(minutes),
                  );
                }),
                const Divider(color: Colors.white24),
                Text(loc.eventDurationLong, style: sectionStyle),
                const SizedBox(height: 4),
                ...List.generate(21, (index) {
                  final hours = index + 4;
                  final minutes = hours * 60;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title:
                        Text(widget.formatDuration(minutes), style: itemStyle),
                    onTap: () => Navigator.of(context).pop(minutes),
                    trailing: hours == 24
                        ? Text(
                            '(máx.)',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          )
                        : null,
                  );
                }),
                const SizedBox(height: 8),
                Text(
                  loc.eventDurationMaxHint,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip de pestaña del diálogo de evento (estilo W14/W15: fondo destacado si seleccionado).

/// Presentación a pantalla completa en móvil (barrier opaco).
Future<T?> showEventFormDialog<T>({
  required BuildContext context,
  required Widget dialog,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: IosFormColors.pageBg,
    useSafeArea: false,
    builder: (context) => dialog,
  );
}
