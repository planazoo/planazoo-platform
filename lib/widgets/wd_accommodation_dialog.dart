import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart' show EventDocument;
import 'package:unp_calendario/features/calendar/domain/services/plan_file_service.dart';
import 'package:unp_calendario/widgets/plan/entity_attachments_section.dart';
import 'package:unp_calendario/widgets/plan/reservation_cancellation_form_section.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/places/data/places_api_service.dart';
import 'package:unp_calendario/features/places/presentation/widgets/place_autocomplete_field.dart';
import 'package:unp_calendario/shared/utils/accommodation_type_l10n.dart';
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
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:unp_calendario/widgets/plan/event_payments_tab.dart';
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
  final _reservationSectionKey =
      GlobalKey<ReservationCancellationFormSectionState>();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hotelNameController;
  late TextEditingController _addressController; // T225: dirección desde Places o a mano
  late TextEditingController _urlController; // Enlace web del alojamiento
  PlaceDetails? _lastPlaceDetails; // T225: último lugar seleccionado (lat/lng en extraData)
  late TextEditingController _descriptionController;
  late TextEditingController _roomNumberController;
  late TextEditingController _bedTypeController;
  late TextEditingController _preferencesController;
  late TextEditingController _personalNotesController;
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

  // Tipos de alojamiento (valores DB legacy en español)
  List<String> get _accommodationTypes => accommodationTypeDbValues;

  late String _selectedType;

  List<EventDocument> _accommodationDocuments = [];
  bool _uploadingAccAttachment = false;
  bool _isSaving = false;

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
    final currentUserId = ref.read(currentUserProvider)?.id ?? '';
    final personalPart = widget.accommodation?.personalParts?[currentUserId];
    _roomNumberController = TextEditingController(
      text: personalPart?.roomNumber ?? '',
    );
    _bedTypeController = TextEditingController(
      text: personalPart?.bedType ?? '',
    );
    _preferencesController = TextEditingController(
      text: personalPart?.preferences?['text']?.toString() ?? '',
    );
    _personalNotesController = TextEditingController(
      text: personalPart?.fields?['notasPersonales']?.toString() ??
          personalPart?.notes?['text']?.toString() ??
          '',
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

  bool get _canEdit => _canSaveAccommodation();

  Widget _wrapReadOnlyIfNeeded({required Widget child}) {
    if (_canEdit) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: _showReadOnlySnackBar),
          ),
        ),
      ],
    );
  }

  void _showReadOnlySnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.eventReadOnlySnackBar),
        duration: const Duration(seconds: 2),
      ),
    );
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
    _roomNumberController.dispose();
    _bedTypeController.dispose();
    _preferencesController.dispose();
    _personalNotesController.dispose();
    _costController.dispose(); // T101
    super.dispose();
  }

  Future<void> _pickAccommodationAttachment() async {
    final PickedPlanFile picked;
    try {
      final result = await PlanFileService.pickAttachment();
      if (result == null) return;
      picked = result;
    } catch (_) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.entityAttachmentsReadError),
          backgroundColor: IosFormColors.danger,
        ),
      );
      return;
    }
    final validationError = PlanFileService.validateAttachment(picked);
    if (validationError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
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
          content: Text(loc.entityAttachmentsUploadError('$e')),
          backgroundColor: IosFormColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingAccAttachment = false);
    }
  }

  Future<void> _deleteAccommodationAttachment(EventDocument doc) async {
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
          content: Text(loc.entityAttachmentsDeleteError),
          backgroundColor: IosFormColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingAccAttachment = false);
    }
  }

  /// Decoración tipo login (estética unificada con evento y login).
  static const Color _formSurface = IosFormColors.pageBg;
  static const double _fieldIconSize = 20;

  void _onCancel() {
    Navigator.of(context).pop();
  }

  Future<void> _onSave() async {
    await _saveAccommodation();
  }

  /// Formulario General (pestaña 0).
  Widget _buildGeneralTabScroll(bool isMobile, AppLocalizations loc) {
    const spacing = IosFormColors.cardGap;
    final pad = isMobile ? 4.0 : 8.0;
    final nights = _calculateNights(_selectedCheckIn, _selectedCheckOut);
    final stay = _formatStayRange();
    final status = _isDraft ? loc.eventStatusDraft : loc.eventStatusConfirmed;
    final statusColor = _isDraft
        ? ColorUtils.confirmedColors['actividad']!
        : ColorUtils.confirmedColors['alojamiento']!;
    final hotelName = _hotelNameController.text.trim();
    final displayTitle = hotelName.isEmpty
        ? (widget.accommodation == null
            ? loc.newAccommodation
            : loc.editAccommodation)
        : hotelName;
    final canEdit = _canEdit;

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, isMobile ? 16 : 12),
      children: [
        IosHeroHeader(
          title: canEdit ? null : displayTitle,
          titleWidget: canEdit ? _buildHeroNameField(loc) : null,
          subtitle: stay,
          onSubtitleTap: canEdit ? _selectStayDateRange : null,
          chips: [
            IosHeroChipData(
              loc.nights(nights),
              accent: true,
              onTap: canEdit ? _selectStayDateRange : null,
            ),
            IosHeroChipData(
              status,
              color: statusColor,
              onTap: canEdit ? _pickAccommodationStatus : null,
            ),
          ],
        ),
        const SizedBox(height: spacing),
        _wrapReadOnlyIfNeeded(child: _buildLocationAndTypeCard(loc, canEdit)),
        const SizedBox(height: spacing),
        _wrapReadOnlyIfNeeded(child: _buildUrlField(loc, canEdit)),
        const SizedBox(height: spacing),
        _wrapReadOnlyIfNeeded(child: _buildNotesField(loc, canEdit)),
        const SizedBox(height: spacing),
        _wrapReadOnlyIfNeeded(
          child: IosGroupedCard(
            children: [
              EntityAttachmentsSection(
                title: '',
                files: _accommodationDocuments,
                canManage: canEdit,
                isUploading: _uploadingAccAttachment,
                onUpload: canEdit ? _pickAccommodationAttachment : null,
                onDelete: _deleteAccommodationAttachment,
                embeddedInGroupedCard: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing),
        _wrapReadOnlyIfNeeded(child: _buildParticipantsScopeSection()),
        if (_planCurrency != null) ...[
          const SizedBox(height: spacing),
          _wrapReadOnlyIfNeeded(child: _buildCostFieldWithCurrency(loc, canEdit)),
          const SizedBox(height: spacing),
          _wrapReadOnlyIfNeeded(
            child: Builder(builder: (context) {
              final parts = ref
                      .watch(planRealParticipantsProvider(widget.planId))
                      .valueOrNull ??
                  [];
              final names = ref
                      .watch(
                          planParticipantDisplayNamesProvider(widget.planId))
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
                initial: widget.accommodation?.reservationCancellation,
                payers: payers,
                defaultTimezone: _plan?.timezone,
                currencyCode: _planCurrency!,
                readOnly: !canEdit,
              );
            }),
          ),
        ],
        const SizedBox(height: spacing),
        _wrapReadOnlyIfNeeded(child: _buildColorSelectorRow(loc, canEdit)),
        if (_canDeleteAccommodation() && canEdit) ...[
          const SizedBox(height: IosFormColors.cardGap),
          IosDestructiveTile(
            label: loc.delete,
            onPressed: _confirmDelete,
          ),
        ],
      ],
    );
  }

  static const int _accommodationFormTabCount = 3;

  Widget _buildAccommodationTabsForm({required bool isMobile}) {
    final horizontalPad = isMobile ? 12.0 : 16.0;
    final topPad = isMobile ? 8.0 : 12.0;
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPad, topPad, horizontalPad, 0),
      child: SizedBox(
        width: isMobile ? double.infinity : 520,
        child: DefaultTabController(
          length: _accommodationFormTabCount,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);
                  final tabLabels = [
                    loc.eventTabGeneral,
                    loc.eventTabMyInfo,
                    loc.eventTabPayments,
                  ];
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
                  children: [
                    _buildGeneralTabScroll(isMobile, loc),
                    _buildMyInfoTabScroll(isMobile, loc),
                    _buildPaymentsTabScroll(isMobile),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyInfoTabScroll(bool isMobile, AppLocalizations loc) {
    final pad = isMobile ? 4.0 : 8.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, isMobile ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.accommodationMyInfoSubtitle,
            style: const TextStyle(
              fontSize: 12,
              color: IosFormColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: IosFormColors.cardGap),
          _wrapReadOnlyIfNeeded(
            child: IosGroupedCard(
              children: [
                IosEditField(
                  label: loc.accommodationMyInfoRoomNumber,
                  controller: _roomNumberController,
                  hint: loc.accommodationMyInfoRoomNumberHint,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return null;
                    if (v.length > 50) return loc.maxCharacters(50);
                    return null;
                  },
                ),
                const IosRowSeparator(),
                IosEditField(
                  label: loc.accommodationMyInfoBedType,
                  controller: _bedTypeController,
                  hint: loc.accommodationMyInfoBedTypeHint,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return null;
                    if (v.length > 50) return loc.maxCharacters(50);
                    return null;
                  },
                ),
                const IosRowSeparator(),
                IosEditField(
                  label: loc.preferences,
                  controller: _preferencesController,
                  hint: loc.preferencesHint,
                  maxLines: 2,
                  minLines: 1,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return null;
                    if (v.length > 200) return loc.maxCharacters(200);
                    return null;
                  },
                ),
                const IosRowSeparator(),
                IosEditField(
                  label: loc.personalNotes,
                  controller: _personalNotesController,
                  hint: loc.accommodationNotesHint,
                  maxLines: 4,
                  minLines: 2,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return null;
                    if (v.length > 1000) return loc.maxCharacters(1000);
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: IosFormColors.cardGap),
          IosFormFooter(loc.accommodationMyInfoPrivacyFooter),
        ],
      ),
    );
  }

  Widget _buildPaymentsTabScroll(bool isMobile) {
    return EventPaymentsTab(
      plan: _plan,
      accommodationId: widget.accommodation?.id,
      budgetCost: widget.accommodation?.cost,
      planCurrency: _planCurrency ?? 'EUR',
      isMobile: isMobile,
    );
  }

  Widget _buildLocationAndTypeCard(AppLocalizations loc, bool canEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IosSectionLabel(loc.accommodationSectionLocation),
        IosGroupedCard(
          children: canEdit
              ? [
                  _buildAddressField(loc),
                  const IosRowSeparator(),
                  IosSettingsRow(
                    label: loc.accommodationType,
                    value: localizedAccommodationType(loc, _selectedType),
                    chevron: true,
                    onTap: _pickAccommodationType,
                  ),
                ]
              : [
                  if (_addressController.text.trim().isNotEmpty)
                    IosSettingsRow(
                      label: loc.placeAddressLabel,
                      value: _addressController.text.trim(),
                      multiline: true,
                      valueColor:
                          _canOpenLocationInMaps ? IosFormColors.accent : null,
                      chevron: _canOpenLocationInMaps,
                      onTap: _canOpenLocationInMaps
                          ? _openLocationInGoogleMaps
                          : null,
                    )
                  else
                    IosSettingsRow(
                      label: loc.placeAddressLabel,
                      value: '—',
                    ),
                  const IosRowSeparator(),
                  IosSettingsRow(
                    label: loc.accommodationType,
                    value: localizedAccommodationType(loc, _selectedType),
                  ),
                ],
        ),
      ],
    );
  }

  Widget _buildUrlField(AppLocalizations loc, bool canEdit) {
    final card = IosGroupedCard(
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
        if (_canOpenWebLink) ...[
          const IosRowSeparator(),
          IosSettingsRow(
            label: loc.openWebLink,
            value: _urlController.text.trim(),
            valueColor: IosFormColors.accent,
            chevron: true,
            onTap: _openAccommodationWebLink,
          ),
        ],
      ],
    );
    if (!_canOpenWebLink) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IosSectionLabel(loc.eventUrlLabel),
        card,
      ],
    );
  }

  Widget _buildNotesField(AppLocalizations loc, bool canEdit) {
    return IosGroupedCard(
      children: [
        Stack(
          children: [
            IgnorePointer(
              ignoring: !canEdit,
              child: IosEditField(
                label: loc.accommodationNotes,
                controller: _descriptionController,
                maxLines: 4,
                minLines: 2,
                hint: loc.accommodationNotesHint,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return null;
                  if (v.length > 1000) return loc.maxCharacters(1000);
                  return null;
                },
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

  Future<void> _openLongNotesEditor() async {
    final loc = AppLocalizations.of(context)!;
    final canEdit = _canEdit;
    final tempController =
        TextEditingController(text: _descriptionController.text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: IosFormColors.groupedBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            loc.accommodationNotes,
            style: const TextStyle(
              color: IosFormColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: 680,
            child: TextFormField(
              controller: tempController,
              minLines: 8,
              maxLines: 16,
              readOnly: !canEdit,
              style: const TextStyle(color: IosFormColors.textPrimary),
              cursorColor: IosFormColors.accent,
              decoration: InputDecoration(
                hintText: loc.accommodationNotesHint,
                hintStyle: const TextStyle(color: IosFormColors.textTertiary),
                filled: true,
                fillColor: IosFormColors.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: canEdit
                  ? () => Navigator.of(context).pop(tempController.text)
                  : null,
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tempController.dispose();
    });
    if (!mounted || result == null) return;
    setState(() {
      _descriptionController.text = result;
    });
  }

  Widget _buildCostFieldWithCurrency(AppLocalizations loc, bool canEdit) {
    final currencyValue = _costCurrency ?? _planCurrency ?? 'EUR';
    final amountRaw = _costController.text.trim();
    final display = amountRaw.isEmpty
        ? '—'
        : '$amountRaw ${Currency.fromCodeOrEur(currencyValue).code}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormField<String>(
          validator: (_) {
            if (!canEdit) return null;
            final v = _costController.text.trim();
            if (v.isEmpty) return null;
            final doubleValue = double.tryParse(v.replaceAll(',', '.'));
            if (doubleValue == null) return loc.mustBeValidNumber;
            if (doubleValue < 0) return loc.cannotBeNegative;
            if (doubleValue > 1000000) return loc.maxAmount;
            return null;
          },
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IosGroupedCard(
                  children: [
                    IosSettingsRow(
                      label: loc.planDetailsBudgetLabel,
                      value: display,
                      chevron: canEdit,
                      onTap: canEdit
                          ? () async {
                              await _pickCostSheet(loc);
                              field.didChange(_costController.text);
                            }
                          : null,
                    ),
                  ],
                ),
                if (field.hasError && field.errorText != null)
                  IosFormFooter(
                    field.errorText!,
                    color: IosFormColors.danger,
                  ),
              ],
            );
          },
        ),
        if (_costCurrency != null &&
            _planCurrency != null &&
            _costCurrency != _planCurrency &&
            _costController.text.trim().isNotEmpty)
          _buildCostConversionHint(),
      ],
    );
  }

  Future<void> _pickCostSheet(AppLocalizations loc) async {
    final amountController = TextEditingController(text: _costController.text);
    var sheetCurrency = _costCurrency ?? _planCurrency ?? 'EUR';
    String? errorText;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: IosFormColors.groupedBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInner) {
            final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
            final currency = Currency.fromCodeOrEur(sheetCurrency);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottomInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: IosFormColors.separator,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.planDetailsBudgetLabel,
                      style: const TextStyle(
                        color: IosFormColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    IosGroupedCard(
                      children: [
                        IosEditField(
                          label: loc.paymentsExpenseAmount,
                          controller: amountController,
                          hint: loc.costHint,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) {
                            if (errorText != null) {
                              setInner(() => errorText = null);
                            }
                          },
                        ),
                        const IosRowSeparator(),
                        IosSettingsRow(
                          label: loc.costCurrency,
                          value: '${currency.code} ${currency.symbol}',
                          chevron: true,
                          onTap: () async {
                            final picked = await IosFormPickerSheet.show<String>(
                              context: ctx,
                              title: loc.costCurrency,
                              options: Currency.supportedCurrencies
                                  .map(
                                    (c) => IosFormPickerOption(
                                      value: c.code,
                                      title:
                                          '${c.code} — ${c.symbol} ${c.name}',
                                      selected: c.code == sheetCurrency,
                                    ),
                                  )
                                  .toList(),
                            );
                            if (picked == null) return;
                            setInner(() => sheetCurrency = picked);
                          },
                        ),
                      ],
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          errorText!,
                          style: const TextStyle(
                            color: IosFormColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    IosFormSheetActions(
                      cancelLabel: loc.cancel,
                      confirmLabel: loc.planNotesApplySelection,
                      onCancel: () => Navigator.of(ctx).pop(false),
                      onConfirm: () {
                        final trimmed = amountController.text.trim();
                        if (trimmed.isEmpty) {
                          Navigator.of(ctx).pop(true);
                          return;
                        }
                        final sanitized = trimmed.replaceAll(',', '.');
                        final parsed = double.tryParse(sanitized);
                        if (parsed == null) {
                          setInner(() => errorText = loc.mustBeValidNumber);
                          return;
                        }
                        if (parsed < 0) {
                          setInner(() => errorText = loc.cannotBeNegative);
                          return;
                        }
                        if (parsed > 1000000) {
                          setInner(() => errorText = loc.maxAmount);
                          return;
                        }
                        amountController.text = sanitized;
                        Navigator.of(ctx).pop(true);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    final raw = amountController.text.trim();
    final chosenCurrency = sheetCurrency;
    amountController.dispose();
    if (!mounted || applied != true) return;

    setState(() {
      _costController.text = raw;
      _costCurrency = chosenCurrency;
    });
    await _convertCostToPlanCurrency(ExchangeRateService());
  }

  Widget _buildColorSelectorRow(AppLocalizations loc, bool canEdit) {
    return IosGroupedCard(
      children: [
        IosColorSettingRow(
          label: loc.color,
          color: _getColorFromName(_selectedColor),
          chevron: canEdit,
          onTap: canEdit ? _showColorPicker : null,
        ),
      ],
    );
  }

  /// Alcance de participantes: switch «Para todos» + lista en la misma card.
  Widget _buildParticipantsScopeSection() {
    final loc = AppLocalizations.of(context)!;
    final canEdit = _canEdit;
    final currentUserId = ref.watch(currentUserProvider)?.id;

    final children = <Widget>[
      IosSwitchRow(
        label: loc.eventDialogForAllShort,
        value: _isForAllParticipants,
        onChanged: canEdit
            ? (value) {
                setState(() {
                  _isForAllParticipants = value;
                  if (_isForAllParticipants) {
                    _selectedParticipantTrackIds.clear();
                  } else if (currentUserId != null &&
                      !_selectedParticipantTrackIds.contains(currentUserId)) {
                    _selectedParticipantTrackIds.add(currentUserId);
                  }
                });
              }
            : null,
      ),
    ];

    String? footerText = _isForAllParticipants
        ? loc.eventDialogForAllParticipantsSubtitleOn
        : loc.accommodationParticipantsSubtitleOff;
    Color? footerColor;

    if (!_isForAllParticipants) {
      children.add(const IosRowSeparator());

      final participantsAsync =
          ref.watch(planRealParticipantsProvider(widget.planId));
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
                _selectedParticipantTrackIds.contains(participation.userId);
            if (i > 0) children.add(const IosRowSeparator(nestLevel: 1));
            children.add(
              FutureBuilder<String>(
                future: _getUserDisplayName(participation.userId),
                builder: (context, snapshot) {
                  final displayName =
                      snapshot.data ?? participation.userId;
                  String secondary = '';
                  if (participation.isOrganizer) {
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
                                if (_selectedParticipantTrackIds.length > 1) {
                                  _selectedParticipantTrackIds
                                      .remove(participation.userId);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        loc.eventDialogSelectAtLeastOne,
                                      ),
                                      backgroundColor: IosFormColors.danger,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else if (!_selectedParticipantTrackIds
                                  .contains(participation.userId)) {
                                _selectedParticipantTrackIds
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
          if (_selectedParticipantTrackIds.isEmpty) {
            footerText = loc.eventDialogSelectAtLeastOne;
            footerColor = IosFormColors.danger;
          }
        },
        loading: () {
          children.add(
            const SizedBox(
              height: IosFormColors.rowHeight,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isForAllParticipants) IosSectionLabel(loc.participants),
        IosGroupedCard(children: children),
        if (footerText != null && footerText!.isNotEmpty)
          IosFormFooter(footerText!, color: footerColor),
      ],
    );
  }

  String _formatShortDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatStayRange() =>
      '${_formatShortDate(_selectedCheckIn)} – ${_formatShortDate(_selectedCheckOut)}';

  /// Dirección con Places: rellena dirección y, si el nombre está vacío, el nombre.
  Widget _buildAddressField(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        IosFormColors.rowPaddingH,
        IosFormColors.rowPaddingV,
        8,
        IosFormColors.rowPaddingV,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.placeAddressLabel,
                  style: const TextStyle(
                    color: IosFormColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Theme(
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
                    controller: _addressController,
                    initialAddress: _addressController.text.isNotEmpty
                        ? _addressController.text
                        : null,
                    lodgingOnly: true,
                    preferDisplayName: false,
                    showFloatingLabel: false,
                    maxLines: 3,
                    labelText: loc.placeAddressLabel,
                    hintText: loc.placeSearchHint,
                    prefixIcon: Icons.place_outlined,
                    fontSize: 17,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    onPlaceSelected: (PlaceDetails details) {
                      setState(() {
                        _lastPlaceDetails = details;
                        final address = (details.formattedAddress ?? '').trim();
                        if (address.isNotEmpty) {
                          _addressController.text = address;
                        }
                        final placeName = details.displayName.trim();
                        if (placeName.isNotEmpty) {
                          final currentName = _hotelNameController.text.trim();
                          final nameLooksLikeAddress = currentName.isEmpty ||
                              currentName == address ||
                              (address.isNotEmpty &&
                                  currentName.contains(address)) ||
                              currentName.split(',').length >= 3;
                          if (nameLooksLikeAddress) {
                            _hotelNameController.text = placeName;
                          }
                        }
                        final web = details.websiteUri?.trim();
                        if (web != null && web.isNotEmpty) {
                          _urlController.text = web;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_canOpenLocationInMaps)
            ListenableBuilder(
              listenable: _addressController,
              builder: (context, _) {
                if (!_canOpenLocationInMaps) return const SizedBox.shrink();
                return IconButton(
                  tooltip: loc.openInGoogleMaps,
                  onPressed: _openLocationInGoogleMaps,
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                    maxWidth: 28,
                    maxHeight: 28,
                  ),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.map_outlined,
                    size: _fieldIconSize,
                    color: IosFormColors.accent,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  bool get _canOpenLocationInMaps {
    final address = _addressController.text.trim();
    return _lastPlaceDetails?.lat != null ||
        (widget.accommodation?.commonPart?.extraData?['placeLat'] != null) ||
        address.isNotEmpty;
  }

  Future<void> _pickAccommodationType() async {
    final loc = AppLocalizations.of(context)!;
    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.accommodationType,
      options: _accommodationTypes
          .map(
            (type) => IosFormPickerOption(
              value: type,
              title: localizedAccommodationType(loc, type),
            ),
          )
          .toList(),
    );
    if (picked != null && mounted) {
      setState(() => _selectedType = picked);
    }
  }

  Future<void> _pickAccommodationStatus() async {
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

  Widget _buildHeroNameField(AppLocalizations loc) {
    return TextFormField(
      controller: _hotelNameController,
      maxLines: 2,
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
        hintText: loc.accommodationNameHint,
        hintStyle: const TextStyle(
          color: IosFormColors.textTertiary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.15,
        ),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return loc.accommodationNameRequired;
        if (v.length < 2) return loc.minCharacters(2);
        if (v.length > 100) return loc.maxCharacters(100);
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  bool _hotelNameLooksLikeAddress(String name, String? address) {
    if (name.isEmpty) return false;
    final addr = (address ?? '').trim();
    if (addr.isNotEmpty &&
        (name == addr || name.contains(addr) || addr.contains(name))) {
      return true;
    }
    // Muchas comas → suele ser dirección formateada de Places.
    return name.split(',').length >= 3;
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
    final title =
        widget.accommodation == null ? loc.newAccommodation : loc.editAccommodation;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final screenSize = MediaQuery.sizeOf(context);
    final contentWidth = isMobile ? screenSize.width : 520.0;
    final contentHeight = isMobile
        ? screenSize.height
        : (screenSize.height - 96).clamp(420.0, 640.0);
    const formSurface = _formSurface;

    return Theme(
      data: AppTheme.darkTheme,
      child: AlertDialog(
        scrollable: false,
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
          // Material (no ColoredBox): evita assert ListTile ink bajo pageBg.
          child: Material(
            color: formSurface,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: IosFormEditBar(
                          editing: true,
                          canEdit: _canEdit,
                          saving: _isSaving,
                          centeredTitle: true,
                          modalIconActions: true,
                          editLabel: loc.edit,
                          cancelLabel: loc.planDetailsBarCancelShort,
                          saveLabel: widget.accommodation == null
                              ? loc.create
                              : loc.planDetailsBarSaveShort,
                          title: title,
                          onEdit: () {},
                          onCancel: _onCancel,
                          onSave: _onSave,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: _buildAccommodationTabsForm(isMobile: isMobile),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fondo del panel del form (web/móvil); mismo tono en el date range picker.
  // `_formSurface` declarado junto a `_fieldSurface` (tokens iOS D).

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
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColorScheme.color2,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
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
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
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

  Future<void> _showColorPicker() async {
    final loc = AppLocalizations.of(context)!;
    final picked = await IosFormColorPickerSheet.show(
      context: context,
      title: loc.color,
      selectedId: _selectedColor,
      options: _accommodationColors
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

  Color _getColorFromName(String colorName) {
    return ColorUtils.colorFromName(colorName);
  }

  /// Cálculo por fecha civil para evitar desajustes por cambio horario (DST).
  int _calculateNights(DateTime checkIn, DateTime checkOut) {
    final checkInUtcDate = DateTime.utc(checkIn.year, checkIn.month, checkIn.day);
    final checkOutUtcDate = DateTime.utc(checkOut.year, checkOut.month, checkOut.day);
    return checkOutUtcDate.difference(checkInUtcDate).inDays;
  }

  /// Hint de conversión de moneda (T153).
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
          return IosFormFooter(loc.calculating);
        }

        if (snapshot.hasData && snapshot.data != null) {
          final convertedAmount = snapshot.data!;
          final amount = CurrencyFormatterService.formatAmount(
            convertedAmount,
            _planCurrency!,
          );
          return IosFormFooter(
            '${loc.convertedTo(_planCurrency!)} $amount',
          );
        }

        if (snapshot.hasError) {
          return IosFormFooter(
            loc.conversionError,
            color: Colors.orange.shade400,
          );
        }

        return const SizedBox.shrink();
      },
    );
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
    final loc = AppLocalizations.of(context)!;
    if (!_canDeleteAccommodation() && _plan != null) {
      final blockedReason =
          PlanStatePermissions.getBlockedReason('delete_event', _plan!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              blockedReason ?? loc.accommodationDeleteBlockedFallback,
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final confirmed = await IosFormConfirmSheet.show(
      context: context,
      title: loc.confirmDeleteTitle,
      message: loc.confirmDeleteAccommodationMessage(
        widget.accommodation?.hotelName ?? '',
      ),
      cancelLabel: loc.cancel,
      confirmLabel: loc.delete,
      destructive: true,
    );

    if (confirmed && widget.onDeleted != null && widget.accommodation?.id != null) {
      widget.onDeleted!(widget.accommodation!.id!);
    }
  }

  Future<bool> _saveAccommodation() async {
    final loc = AppLocalizations.of(context)!;
    if (!_canSaveAccommodation() && _plan != null) {
      final action =
          widget.accommodation == null ? 'create_event' : 'modify_event';
      final blockedReason = PlanStatePermissions.getBlockedReason(action, _plan!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              blockedReason ??
                  (widget.accommodation == null
                      ? loc.accommodationSaveBlockedCreate
                      : loc.accommodationSaveBlockedModify),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }

    if (_isSaving) return false;
    setState(() => _isSaving = true);
    try {
      if (!_formKey.currentState!.validate()) {
        return false;
      }
      // Validar nombre del hotel
      if (_hotelNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.accommodationNameRequiredError),
            backgroundColor: IosFormColors.danger,
          ),
        );
        return false;
      }

      // Validar fechas
      if (_selectedCheckOut.isBefore(_selectedCheckIn) ||
          _selectedCheckOut.isAtSameMomentAs(_selectedCheckIn)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.checkOutAfterCheckInError),
            backgroundColor: IosFormColors.danger,
          ),
        );
        return false;
      }

      // Validar participantes (igual que eventos)
      if (!_isForAllParticipants && _selectedParticipantTrackIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.mustSelectAtLeastOneParticipant),
            backgroundColor: IosFormColors.danger,
          ),
        );
        return false;
      }

      // Normalizar el tipo seleccionado antes de guardar
      final normalizedType = _normalizeType(_selectedType);

      double? costValue;
      try {
        costValue = await _getConvertedCost();
      } catch (_) {
        // Si falla la conversión de moneda, guardar sin coste
      }

      final address = _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim();
      // Evitar persistir la dirección en el nombre (datos legacy / Places).
      var rawName = _hotelNameController.text.trim();
      if (_hotelNameLooksLikeAddress(rawName, address)) {
        final fromPlace = _lastPlaceDetails?.displayName.trim();
        final fromExtra = widget.accommodation?.commonPart?.extraData?['placeName']
            as String?;
        final fallback = (fromPlace != null && fromPlace.isNotEmpty)
            ? fromPlace
            : (fromExtra != null && fromExtra.trim().isNotEmpty)
                ? fromExtra.trim()
                : rawName.split(',').first.trim();
        if (fallback.isNotEmpty) {
          rawName = fallback;
          _hotelNameController.text = fallback;
        }
      }

      final hotelName =
          Sanitizer.sanitizePlainText(rawName, maxLength: 100);
      final description =
          Sanitizer.sanitizePlainText(_descriptionController.text, maxLength: 1000)
                  .isEmpty
              ? null
              : Sanitizer.sanitizePlainText(
                  _descriptionController.text, maxLength: 1000);

      // T225: extraData con coordenadas y dirección del lugar (Places)
      final baseExtra = Map<String, dynamic>.from(
          widget.accommodation?.commonPart?.extraData ?? {});
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

      final url =
          _urlController.text.trim().isEmpty ? null : _urlController.text.trim();
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

      Map<String, AccommodationPersonalPart>? personalParts;
      final userId = ref.read(currentUserProvider)?.id;
      if (userId != null && userId.isNotEmpty) {
        personalParts = Map<String, AccommodationPersonalPart>.from(
          widget.accommodation?.personalParts ?? {},
        );
        final roomNumber = Sanitizer.sanitizePlainText(
          _roomNumberController.text,
          maxLength: 50,
        );
        final bedType = Sanitizer.sanitizePlainText(
          _bedTypeController.text,
          maxLength: 50,
        );
        final preferencesText = Sanitizer.sanitizePlainText(
          _preferencesController.text,
          maxLength: 200,
        );
        final personalNotes = Sanitizer.sanitizePlainText(
          _personalNotesController.text,
          maxLength: 1000,
        );
        personalParts[userId] = AccommodationPersonalPart(
          participantId: userId,
          roomNumber: roomNumber.isEmpty ? null : roomNumber,
          bedType: bedType.isEmpty ? null : bedType,
          preferences: preferencesText.isEmpty
              ? null
              : {'text': preferencesText},
          fields: personalNotes.isEmpty
              ? null
              : {'notasPersonales': personalNotes},
        );
      }

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
        participantTrackIds:
            _isForAllParticipants ? [] : selectedParticipantIds,
        cost: costValue,
        createdAt: widget.accommodation?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        commonPart: commonPart,
        personalParts: personalParts,
        documents: _accommodationDocuments.isEmpty
            ? null
            : List<EventDocument>.from(_accommodationDocuments),
        isDraft: _isDraft,
        reservationCancellation: _reservationSectionKey.currentState?.toModel(),
      );

      if (widget.onSaved != null) {
        widget.onSaved!(accommodation);
      }
      return true;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

/// Presentación a pantalla completa en móvil (barrier opaco, sin safe area del sistema en el shell).
Future<T?> showAccommodationFormDialog<T>({
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
