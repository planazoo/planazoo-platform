import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart' show EventDocument;
import 'package:unp_calendario/features/calendar/domain/services/plan_file_service.dart';
import 'package:unp_calendario/widgets/plan/entity_attachments_section.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/places/data/places_api_service.dart';
import 'package:unp_calendario/features/places/presentation/widgets/place_autocomplete_field.dart';
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
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late TextEditingController _addressController; // T225: dirección desde Places o a mano
  late TextEditingController _urlController; // Enlace web del alojamiento
  PlaceDetails? _lastPlaceDetails; // T225: último lugar seleccionado (lat/lng en extraData)
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
  late bool _isDraft; // Borrador / Confirmado (igual que eventos)

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
    'Crucero',
    'Otro',
  ];

  late String _selectedType;

  List<EventDocument> _accommodationDocuments = [];
  bool _uploadingAccAttachment = false;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores
    _hotelNameController = TextEditingController(
      text: widget.accommodation?.hotelName ?? '',
    );
    _addressController = TextEditingController(
      text: widget.accommodation?.commonPart?.address ?? '',
    );
    _urlController = TextEditingController(
      text: widget.accommodation?.commonPart?.url ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.accommodation?.description ?? '',
    );
    _costController = TextEditingController(
      text: _formatCostForInput(widget.accommodation?.cost),
    );
    
    // Inicializar fechas
    _selectedCheckIn = widget.initialCheckIn ?? widget.accommodation?.checkIn ?? widget.planStartDate;
    _selectedCheckOut = widget.accommodation?.checkOut ?? _selectedCheckIn.add(const Duration(days: 1));
    _selectedColor = widget.accommodation?.color ?? 'blue';
    
    // Normalizar tipo de alojamiento (capitalizar primera letra)
    final typeFromDB = widget.accommodation?.typeSubtype ?? '';
    _selectedType = _normalizeType(typeFromDB);
    
    // Inicializar participantes seleccionados y checkbox "Para todos" (igual que eventos)
    final existingParticipantIds = <String>{
      ...(widget.accommodation?.participantTrackIds ?? const <String>[]),
      ...(widget.accommodation?.commonPart?.participantIds ?? const <String>[]),
    };
    final existingIsForAll = widget.accommodation?.commonPart?.isForAllParticipants;
    // Priorizar bandera explícita de commonPart y, si no existe, usar compatibilidad legacy.
    _isForAllParticipants = existingIsForAll ?? existingParticipantIds.isEmpty;
    _selectedParticipantTrackIds = existingParticipantIds.toList();
    _isDraft = widget.accommodation?.isDraft ??
        widget.accommodation?.commonPart?.isDraft ??
        false;
    
    // Si es un alojamiento nuevo, por defecto está marcado "para todos" (no necesitamos seleccionar participantes)
    // Si es un alojamiento existente y no está marcado "para todos" pero no hay participantes,
    // asegurar que al menos haya uno seleccionado (se validará al guardar)
    
    // Cargar moneda del plan (T153)
    _loadPlanCurrency();

    _accommodationDocuments = List<EventDocument>.from(widget.accommodation?.documents ?? const []);
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
    _addressController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    _costController.dispose(); // T101
    super.dispose();
  }

  Future<void> _pickAccommodationAttachment() async {
    final picked = await PlanFileService.pickAttachment();
    if (picked == null) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.entityAttachmentsReadError,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
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
          content: Text(validationError, style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }
    setState(() => _uploadingAccAttachment = true);
    try {
      final uploaded = await PlanFileService.uploadAttachment(
        planId: widget.planId,
        file: picked,
        filenamePrefix: 'acc',
      );
      if (!mounted) return;
      setState(() {
        _accommodationDocuments = [..._accommodationDocuments, EventDocument.fromPlanAttachment(uploaded)];
      });
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.entityAttachmentsUploadError('$e'), style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingAccAttachment = false);
    }
  }

  Future<void> _deleteAccommodationAttachment(EventDocument doc) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final loc = AppLocalizations.of(ctx)!;
            return Theme(
              data: AppTheme.darkTheme,
              child: AlertDialog(
                backgroundColor: const Color(0xFF111827),
                title: Text(loc.entityAttachmentsDeleteTitle, style: GoogleFonts.poppins(color: Colors.white)),
                content: Text(
                  loc.entityAttachmentsDeleteConfirm(doc.name),
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.cancel)),
                  TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.delete)),
                ],
              ),
            );
          },
        ) ??
        false;
    if (!confirm) return;
    setState(() => _uploadingAccAttachment = true);
    try {
      await PlanFileService.deleteAttachment(doc.url);
      if (!mounted) return;
      setState(() {
        _accommodationDocuments = _accommodationDocuments.where((d) => d.url != doc.url).toList();
      });
    } catch (_) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.entityAttachmentsDeleteError, style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingAccAttachment = false);
    }
  }

  /// Decoración tipo login (estética unificada con evento y login).
  static const Color _fieldSurface = Color(0xFF1F2937);
  static const double _fieldRadius = 14;
  static const double _fieldGap = 16;
  static const double _fieldIconSize = 20;
  static const EdgeInsets _fieldContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 16);

  TextStyle get _labelStyle => GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      );

  TextStyle get _valueStyle => GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w500,
        height: 1.2,
      );

  TextStyle get _hintStyle => GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.white60,
        fontWeight: FontWeight.w400,
        height: 1.2,
      );

  TextStyle get _captionStyle => GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.white70,
        fontWeight: FontWeight.w400,
      );

  TextStyle get _linkStyle => GoogleFonts.poppins(
        fontSize: 13,
        color: AppColorScheme.color2,
        fontWeight: FontWeight.w600,
      );

  Icon _fieldIcon(IconData icon) =>
      Icon(icon, size: _fieldIconSize, color: Colors.white70);

  BoxDecoration _buildLoginStyleDecoration() {
    return BoxDecoration(
      color: _fieldSurface,
      borderRadius: BorderRadius.circular(_fieldRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.12),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 10,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Material(
      color: _fieldSurface,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }

  bool get _canOpenLocationInMaps {
    final address = _addressController.text.trim();
    return _lastPlaceDetails?.lat != null ||
        (widget.accommodation?.commonPart?.extraData?['placeLat'] != null) ||
        address.isNotEmpty;
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

  Widget _buildLocationSection() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Nombre = búsqueda Places (también se puede escribir a mano)
        Container(
          decoration: _buildLoginStyleDecoration(),
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: _labelStyle,
                hintStyle: _hintStyle,
                prefixIconColor: Colors.white70,
                contentPadding: _fieldContentPadding,
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            child: PlaceAutocompleteField(
              controller: _hotelNameController,
              initialAddress: _hotelNameController.text.isNotEmpty
                  ? _hotelNameController.text
                  : null,
              lodgingOnly: false,
              preferDisplayName: true,
              labelText: loc.accommodationName,
              hintText: loc.placeSearchHint,
              prefixIcon: Icons.hotel,
              fontSize: 14,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return loc.accommodationNameRequired;
                if (v.length < 2) return loc.minCharacters(2);
                if (v.length > 100) return loc.maxCharacters(100);
                return null;
              },
              onPlaceSelected: (PlaceDetails details) {
                setState(() {
                  _lastPlaceDetails = details;
                  _hotelNameController.text = details.displayName;
                  if ((details.formattedAddress ?? '').trim().isNotEmpty) {
                    _addressController.text = details.formattedAddress!;
                  }
                  final web = details.websiteUri?.trim();
                  if (web != null && web.isNotEmpty) {
                    _urlController.text = web;
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(height: _fieldGap),
        // Dirección: se rellena desde Places o se escribe a mano
        Container(
          decoration: _buildLoginStyleDecoration(),
          child: TextFormField(
            controller: _addressController,
            maxLines: 2,
            style: _valueStyle,
            decoration: _standardFieldDecoration(
              labelText: loc.placeAddressLabel,
              hintText: loc.placeSearchHint,
              prefixIcon: Icons.place,
            ).copyWith(
              suffixIcon: _canOpenLocationInMaps
                  ? IconButton(
                      tooltip: loc.openInGoogleMaps,
                      onPressed: _openLocationInGoogleMaps,
                      icon: Icon(
                        Icons.map_outlined,
                        size: _fieldIconSize,
                        color: AppColorScheme.color2,
                      ),
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  bool get _canOpenWebLink {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) return false;
    final withScheme = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(withScheme);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  Future<void> _openAccommodationWebLink() async {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) return;
    final withScheme = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(withScheme);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openLocationInGoogleMaps() async {
    final lat = _lastPlaceDetails?.lat ?? (widget.accommodation?.commonPart?.extraData?['placeLat'] as num?)?.toDouble();
    final lng = _lastPlaceDetails?.lng ?? (widget.accommodation?.commonPart?.extraData?['placeLng'] as num?)?.toDouble();
    final addressText = _addressController.text.trim();
    final address = _lastPlaceDetails?.formattedAddress
        ?? widget.accommodation?.commonPart?.extraData?['placeAddress'] as String?
        ?? (addressText.isNotEmpty ? addressText : widget.accommodation?.commonPart?.address);
    final String url;
    if (lat != null && lng != null) {
      url = 'https://www.google.com/maps?q=$lat,$lng';
    } else if (address != null && address.isNotEmpty) {
      url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    } else {
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final title = widget.accommodation == null ? loc.newAccommodation : loc.editAccommodation;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenSize = MediaQuery.sizeOf(context);
    final contentWidth = isMobile ? screenSize.width : null;
    final contentHeight = isMobile ? screenSize.height - 64 : null;
    // Fondo del panel del form: más claro que el backdrop (111827) para ver márgenes en web.
    // Mismo color en móvil (pantalla completa). Campos internos siguen en gris más oscuro.
    const formSurface = _formSurface;
    return Theme(
      data: AppTheme.darkTheme,
      child: AlertDialog(
        backgroundColor: formSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 0 : 18),
          side: isMobile
              ? BorderSide.none
              : BorderSide(color: Colors.white.withValues(alpha: 0.22), width: 1),
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
              // T240 / T226: barra superior con título + Borrador/Confirmado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: formSurface,
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isMobile ? 0 : 18),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_canSaveAccommodation()) ...[
                      const SizedBox(width: 8),
                      _buildDraftStatusToggle(isMobile: isMobile),
                    ],
                  ],
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
                      // Qué / dónde: Places + resumen (o entrada manual) → tipo
                      _buildLocationSection(),
                      const SizedBox(height: _fieldGap),
                      Container(
                        decoration: _buildLoginStyleDecoration(),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          decoration: _standardFieldDecoration(
                            labelText: AppLocalizations.of(context)!.accommodationType,
                            prefixIcon: Icons.category,
                          ),
                          dropdownColor: _fieldSurface,
                          style: _valueStyle,
                          items: _accommodationTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type, style: _valueStyle),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value ?? 'Hotel';
                            });
                          },
                          validator: (value) {
                            if (value == null || !_accommodationTypes.contains(value)) {
                              return AppLocalizations.of(context)!.invalidAccommodationType;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: _fieldGap),
                      // Cuándo: check-in / check-out (mismo range picker) + noches
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStayDateTile(
                                  label: AppLocalizations.of(context)!.checkIn,
                                  date: _selectedCheckIn,
                                  icon: Icons.login,
                                ),
                              ),
                              const SizedBox(width: _fieldGap),
                              Expanded(
                                child: _buildStayDateTile(
                                  label: AppLocalizations.of(context)!.checkOut,
                                  date: _selectedCheckOut,
                                  icon: Icons.logout,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: _buildLoginStyleDecoration(),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.nights_stay,
                                  size: _fieldIconSize,
                                  color: AppColorScheme.color2,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.nights(
                                    _calculateNights(
                                      _selectedCheckIn,
                                      _selectedCheckOut,
                                    ),
                                  ),
                                  style: _valueStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: _fieldGap),
                      // Coste
                      if (_planCurrency != null) ...[
                        _buildCostFieldWithCurrency(),
                        const SizedBox(height: _fieldGap),
                      ],
                      // Extras: enlace → descripción → adjuntos
                      Container(
                        decoration: _buildLoginStyleDecoration(),
                        child: TextFormField(
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          maxLength: 500,
                          style: _valueStyle,
                          onChanged: (_) => setState(() {}),
                          decoration: _standardFieldDecoration(
                            labelText: AppLocalizations.of(context)!.eventUrlLabel,
                            hintText: AppLocalizations.of(context)!.eventUrlHint,
                            prefixIcon: Icons.link,
                            counterText: '',
                          ).copyWith(
                            suffixIcon: _canOpenWebLink
                                ? IconButton(
                                    tooltip:
                                        AppLocalizations.of(context)!.openWebLink,
                                    onPressed: _openAccommodationWebLink,
                                    icon: Icon(
                                      Icons.open_in_new,
                                      size: _fieldIconSize,
                                      color: AppColorScheme.color2,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: _fieldGap),
                      Container(
                        decoration: _buildLoginStyleDecoration(),
                        child: TextFormField(
                          controller: _descriptionController,
                          minLines: 3,
                          maxLines: 8,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          style: _valueStyle,
                          decoration: _standardFieldDecoration(
                            labelText:
                                AppLocalizations.of(context)!.accommodationNotes,
                            hintText: AppLocalizations.of(context)!
                                .accommodationNotesHint,
                            prefixIcon: Icons.notes,
                          ).copyWith(
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return null;
                            if (v.length > 1000) {
                              return AppLocalizations.of(context)!
                                  .maxCharacters(1000);
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: _fieldGap),
                      EntityAttachmentsSection(
                        title: AppLocalizations.of(context)!
                            .entityAttachmentsAccommodationTitle,
                        files: _accommodationDocuments,
                        canManage: _canSaveAccommodation(),
                        isUploading: _uploadingAccAttachment,
                        onUpload: _canSaveAccommodation()
                            ? _pickAccommodationAttachment
                            : null,
                        onDelete: _deleteAccommodationAttachment,
                      ),
                      const SizedBox(height: _fieldGap),
                      // Participantes (separado del color)
                      _buildSectionCard(
                        child: _buildParticipantSelection(),
                      ),
                      const SizedBox(height: _fieldGap),
                      // Color compacto: muestra el seleccionado; al tocar abre selector
                      _buildColorSelectorRow(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      actions: [
        if (widget.accommodation != null)
          TextButton(
            onPressed: _canDeleteAccommodation() ? () => _confirmDelete() : null,
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _canSaveAccommodation() ? _saveAccommodation : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorScheme.color2,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: Text(
            widget.accommodation == null
                ? AppLocalizations.of(context)!.create
                : AppLocalizations.of(context)!.save,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildDraftStatusToggle({required bool isMobile}) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white38, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDraftStatusOption(
            label: loc.eventStatusDraft,
            selected: _isDraft,
            isMobile: isMobile,
            onTap: () => setState(() => _isDraft = true),
          ),
          _buildDraftStatusOption(
            label: loc.eventStatusConfirmed,
            selected: !_isDraft,
            isMobile: isMobile,
            onTap: () => setState(() => _isDraft = false),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftStatusOption({
    required String label,
    required bool selected,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 10,
          vertical: isMobile ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColorScheme.color2.withValues(alpha: 0.85)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 11 : 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: Colors.white.withValues(alpha: selected ? 1 : 0.75),
          ),
        ),
      ),
    );
  }

  Widget _buildStayDateTile({
    required String label,
    required DateTime date,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _selectStayDateRange,
        borderRadius: BorderRadius.circular(_fieldRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: _buildLoginStyleDecoration(),
          child: Row(
            children: [
              _fieldIcon(icon),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: _labelStyle),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: _valueStyle,
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

  /// Fondo del panel del form (web/móvil); mismo tono en el date range picker.
  static const Color _formSurface = Color(0xFF374151);

  Future<void> _selectStayDateRange() async {
    final loc = AppLocalizations.of(context)!;
    final firstDate = DateTime(
      widget.planStartDate.year,
      widget.planStartDate.month,
      widget.planStartDate.day,
    );
    final lastDate = widget.planEndDate != null
        ? DateTime(
            widget.planEndDate!.year,
            widget.planEndDate!.month,
            widget.planEndDate!.day,
          )
        : firstDate.add(const Duration(days: 365));

    var start = DateTime(_selectedCheckIn.year, _selectedCheckIn.month, _selectedCheckIn.day);
    var end = DateTime(_selectedCheckOut.year, _selectedCheckOut.month, _selectedCheckOut.day);
    if (start.isBefore(firstDate)) start = firstDate;
    if (end.isAfter(lastDate)) end = lastDate;
    if (!end.isAfter(start)) {
      end = start.add(const Duration(days: 1));
      if (end.isAfter(lastDate)) end = lastDate;
    }

    final rangeTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColorScheme.color2,
            onPrimary: Colors.white,
            surface: _formSurface,
            onSurface: Colors.white,
          ),
      scaffoldBackgroundColor: _formSurface,
      datePickerTheme: DatePickerThemeData(
        backgroundColor: _formSurface,
        rangePickerBackgroundColor: _formSurface,
        rangePickerHeaderBackgroundColor: _formSurface,
        rangePickerHeaderForegroundColor: Colors.white,
        rangePickerElevation: 8,
        rangePickerSurfaceTintColor: Colors.transparent,
        rangePickerShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
        ),
        headerBackgroundColor: _formSurface,
        headerForegroundColor: Colors.white,
        rangeSelectionBackgroundColor: AppColorScheme.color2.withValues(alpha: 0.28),
        rangeSelectionOverlayColor: WidgetStateProperty.all(
          AppColorScheme.color2.withValues(alpha: 0.12),
        ),
        todayForegroundColor: WidgetStateProperty.all(AppColorScheme.color2),
        todayBorder: BorderSide(color: AppColorScheme.color2),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColorScheme.color2;
          return null;
        }),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColorScheme.color2,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _formSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorScheme.color2,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: DateTimeRange(start: start, end: end),
      helpText: loc.accommodationStayDatesHelp,
      cancelText: loc.cancel,
      confirmText: loc.accept,
      saveText: loc.accept,
      builder: (context, child) {
        // Material fuerza el range calendar a tamaño de pantalla; limitamos
        // MediaQuery para que se comporte como modal centrado.
        final screen = MediaQuery.sizeOf(context);
        final width = (screen.width - 48).clamp(280.0, 420.0);
        final height = (screen.height - 48).clamp(420.0, 560.0);
        final modalSize = Size(width, height);
        return Theme(
          data: rangeTheme,
          child: Center(
            child: SizedBox(
              width: modalSize.width,
              height: modalSize.height,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(size: modalSize),
                child: child!,
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedCheckIn = DateTime(picked.start.year, picked.start.month, picked.start.day);
      var checkOut = DateTime(picked.end.year, picked.end.month, picked.end.day);
      if (!checkOut.isAfter(_selectedCheckIn)) {
        checkOut = _selectedCheckIn.add(const Duration(days: 1));
      }
      _selectedCheckOut = checkOut;
    });
  }

  Widget _buildColorSelectorRow() {
    final loc = AppLocalizations.of(context)!;
    final selected = _getColorFromName(_selectedColor);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showColorPicker,
        borderRadius: BorderRadius.circular(_fieldRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: _buildLoginStyleDecoration(),
          child: Row(
            children: [
              _fieldIcon(Icons.palette_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(loc.color, style: _valueStyle),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: selected,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more, size: _fieldIconSize, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showColorPicker() async {
    final loc = AppLocalizations.of(context)!;
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return Theme(
          data: AppTheme.darkTheme,
          child: AlertDialog(
            backgroundColor: _formSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
            ),
            title: Text(
              loc.color,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _accommodationColors.map((colorName) {
                final color = _getColorFromName(colorName);
                final isSelected = _selectedColor == colorName;
                return GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(colorName),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColorScheme.color2 : Colors.white38,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  loc.cancel,
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || picked == null) return;
    setState(() => _selectedColor = picked);
  }

  Color _getColorFromName(String colorName) {
    return ColorUtils.colorFromName(colorName);
  }

  /// Cálculo por fecha civil para evitar desajustes por cambio horario (DST).
  int _calculateNights(DateTime checkIn, DateTime checkOut) {
    final checkInUtcDate = DateTime.utc(checkIn.year, checkIn.month, checkIn.day);
    final checkOutUtcDate = DateTime.utc(checkOut.year, checkOut.month, checkOut.day);
    return checkOutUtcDate.difference(checkInUtcDate).inDays;
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
                CheckboxListTile(
                  title: Text(
                    'Para todos los participantes',
                    style: _valueStyle,
                  ),
                  value: _isForAllParticipants,
                  onChanged: (value) {
                    setState(() {
                      _isForAllParticipants = value ?? true;
                      if (_isForAllParticipants) {
                        _selectedParticipantTrackIds.clear();
                      } else {
                        if (currentUserId != null &&
                            !_selectedParticipantTrackIds.contains(currentUserId)) {
                          _selectedParticipantTrackIds.add(currentUserId);
                        }
                      }
                    });
                  },
                  activeColor: AppColorScheme.color2,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),
                if (!_isForAllParticipants) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: participations.map((participation) {
                      final isSelected =
                          _selectedParticipantTrackIds.contains(participation.userId);
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
                                  if (!_selectedParticipantTrackIds
                                      .contains(participation.userId)) {
                                    _selectedParticipantTrackIds
                                        .add(participation.userId);
                                  }
                                } else {
                                  if (_selectedParticipantTrackIds.length > 1) {
                                    _selectedParticipantTrackIds
                                        .remove(participation.userId);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Elige al menos un participante',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              });
                            },
                            selectedColor:
                                AppColorScheme.color2.withValues(alpha: 0.35),
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.06),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColorScheme.color2
                                  : Colors.white.withValues(alpha: 0.12),
                            ),
                            checkmarkColor: Colors.white,
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  if (_selectedParticipantTrackIds.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Elige al menos un participante',
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

  /// T153: Construir campo de coste con selector de moneda y conversión automática (estética tipo login)
  Widget _buildCostFieldWithCurrency() {
    final exchangeRateService = ExchangeRateService();
    final currencyValue = _costCurrency ?? _planCurrency ?? 'EUR';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: _buildLoginStyleDecoration(),
                  alignment: Alignment.center,
                  child: DropdownButtonFormField<String>(
                    initialValue: currencyValue,
                    isExpanded: true,
                    decoration: _standardFieldDecoration(
                      labelText: AppLocalizations.of(context)!.costCurrency,
                      prefixIcon: _getCurrencyIcon(currencyValue),
                    ),
                    dropdownColor: _fieldSurface,
                    style: _valueStyle,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white70,
                      size: 22,
                    ),
                    selectedItemBuilder: (context) {
                      return Currency.supportedCurrencies.map((currency) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            currency.code,
                            overflow: TextOverflow.ellipsis,
                            style: _valueStyle,
                          ),
                        );
                      }).toList();
                    },
                    items: Currency.supportedCurrencies.map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency.code,
                        child: Text(
                          '${currency.code} - ${currency.symbol} ${currency.name}',
                          style: _valueStyle,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _costCurrency = value);
                      await _convertCostToPlanCurrency(exchangeRateService);
                    },
                  ),
                ),
              ),
              const SizedBox(width: _fieldGap),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: _buildLoginStyleDecoration(),
                  alignment: Alignment.center,
                  child: TextFormField(
                    controller: _costController,
                    style: _valueStyle,
                    decoration: _standardFieldDecoration(
                      labelText: AppLocalizations.of(context)!.cost,
                      hintText: AppLocalizations.of(context)!.costHint,
                      prefixIcon: Icons.payments_outlined,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) async {
                      await _convertCostToPlanCurrency(exchangeRateService);
                    },
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return null;
                      final doubleValue =
                          double.tryParse(v.replaceAll(',', '.'));
                      if (doubleValue == null) {
                        return AppLocalizations.of(context)!.mustBeValidNumber;
                      }
                      if (doubleValue < 0) {
                        return AppLocalizations.of(context)!.cannotBeNegative;
                      }
                      if (doubleValue > 1000000) {
                        return AppLocalizations.of(context)!.maxAmount;
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
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
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.calculating,
                        style: _captionStyle,
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                final convertedAmount = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColorScheme.color2.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(_fieldRadius),
                    border: Border.all(
                      color: AppColorScheme.color2.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColorScheme.color2,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!
                                .convertedTo(_planCurrency!),
                            style: _linkStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatterService.formatAmount(
                          convertedAmount,
                          _planCurrency!,
                        ),
                        style: _valueStyle.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '⚠️ Los tipos de cambio son orientativos. El valor real será el aplicado por tu banco o tarjeta de crédito al momento del pago.',
                        style: _captionStyle.copyWith(
                          fontSize: 10,
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

  /// T153: Obtener coste convertido a la moneda del plan (redondeado a decimales de la moneda).
  Future<double?> _getConvertedCost() async {
    if (_costController.text.trim().isEmpty) return null;
    
    final localAmount = double.tryParse(_costController.text.replaceAll(',', '.'));
    if (localAmount == null) return null;
    
    if (_costCurrency == null || _planCurrency == null || _costCurrency == _planCurrency) {
      return _roundCost(localAmount, _planCurrency ?? _costCurrency);
    }
    
    final exchangeRateService = ExchangeRateService();
    try {
      final converted = await exchangeRateService.convertAmount(
        localAmount,
        _costCurrency!,
        _planCurrency!,
      );
      if (converted == null) return _roundCost(localAmount, _planCurrency);
      return _roundCost(converted, _planCurrency);
    } catch (e) {
      return _roundCost(localAmount, _planCurrency);
    }
  }

  String _formatCostForInput(double? amount) {
    if (amount == null) return '';
    final currencyCode = _planCurrency ?? _costCurrency ?? 'EUR';
    final digits = Currency.fromCodeOrEur(currencyCode).decimalDigits;
    return amount.toStringAsFixed(digits);
  }

  double _roundCost(double amount, String? currencyCode) {
    final digits = Currency.fromCodeOrEur(currencyCode ?? 'EUR').decimalDigits;
    return double.parse(amount.toStringAsFixed(digits));
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

    final hotelName = Sanitizer.sanitizePlainText(_hotelNameController.text, maxLength: 100);
    final description = Sanitizer.sanitizePlainText(_descriptionController.text, maxLength: 1000).isEmpty
        ? null
        : Sanitizer.sanitizePlainText(_descriptionController.text, maxLength: 1000);
    final address = _addressController.text.trim().isEmpty ? null : _addressController.text.trim();

    // T225: extraData con coordenadas y dirección del lugar (Places)
    final baseExtra = Map<String, dynamic>.from(widget.accommodation?.commonPart?.extraData ?? {});
    if (_lastPlaceDetails != null) {
      if (_lastPlaceDetails!.lat != null) baseExtra['placeLat'] = _lastPlaceDetails!.lat;
      if (_lastPlaceDetails!.lng != null) baseExtra['placeLng'] = _lastPlaceDetails!.lng;
      if (_lastPlaceDetails!.formattedAddress != null) baseExtra['placeAddress'] = _lastPlaceDetails!.formattedAddress;
      baseExtra['placeName'] = _lastPlaceDetails!.displayName;
    }

    final url = _urlController.text.trim().isEmpty ? null : _urlController.text.trim();
    final selectedParticipantIds = _selectedParticipantTrackIds.toSet().toList();
    final commonPart = AccommodationCommonPart(
      hotelName: hotelName,
      checkIn: _selectedCheckIn,
      checkOut: _selectedCheckOut,
      description: description,
      typeSubtype: normalizedType,
      customColor: _selectedColor,
      address: address,
      url: url,
      participantIds: _isForAllParticipants ? [] : selectedParticipantIds,
      isForAllParticipants: _isForAllParticipants,
      extraData: baseExtra.isEmpty ? null : baseExtra,
      isDraft: _isDraft,
    );

    final accommodation = Accommodation(
      id: widget.accommodation?.id,
      planId: widget.planId,
      checkIn: _selectedCheckIn,
      checkOut: _selectedCheckOut,
      hotelName: hotelName,
      description: description,
      color: _selectedColor,
      typeFamily: 'alojamiento',
      typeSubtype: normalizedType,
      participantTrackIds: _isForAllParticipants ? [] : selectedParticipantIds,
      cost: costValue,
      createdAt: widget.accommodation?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      commonPart: commonPart,
      documents: _accommodationDocuments.isEmpty ? null : List<EventDocument>.from(_accommodationDocuments),
      isDraft: _isDraft,
    );

    if (widget.onSaved != null) {
      widget.onSaved!(accommodation);
    }
  }
}
