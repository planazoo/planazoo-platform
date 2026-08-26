import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/plan_date_range_validation.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_file_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/state_transition_dialog.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/dialogs/announcement_dialog.dart';
import 'package:unp_calendario/widgets/screens/announcement_timeline.dart';
import 'package:unp_calendario/shared/utils/days_remaining_utils.dart';
import 'package:unp_calendario/shared/utils/plan_validation_utils.dart';
import 'package:unp_calendario/widgets/dialogs/plan_validation_dialog.dart';
import 'package:unp_calendario/widgets/dialogs/delete_plan_dialogs.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/notifications/domain/services/notification_helper.dart';
import 'package:unp_calendario/widgets/plan/membership_solo_items_warning.dart';
import 'package:unp_calendario/widgets/plan/upcoming_cancellations_section.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/plan/wd_participants_list_widget.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/shared/utils/plan_state_l10n.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/shared/constants/help_context_ids.dart';
import 'package:unp_calendario/widgets/help/help_icon_button.dart';
import 'package:unp_calendario/shared/utils/color_utils.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_event_accent_colors.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanDataScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onPlanDeleted;
  final VoidCallback? onManageParticipants;

  /// Si se proporciona, el botón resumen abre la página de resumen en lugar del diálogo.
  final VoidCallback? onOpenSummary;
  final bool showAppBar;

  /// Tras guardar datos del plan (sin invalidar el stream global: evita ciclos de dispose en web).
  final ValueChanged<Plan>? onPlanUpdated;

  /// T276: preview pending — sin salir/editar como miembro.
  final bool forceReadOnly;

  /// Si no es null, la barra Editar/Cancelar/Guardar se hostea fuera (p. ej. SectionTitleBar).
  final ValueChanged<PlanInfoEditChrome?>? onEditChromeChanged;

  const PlanDataScreen({
    super.key,
    required this.plan,
    this.onPlanDeleted,
    this.onManageParticipants,
    this.onOpenSummary,
    this.showAppBar = true,
    this.onPlanUpdated,
    this.forceReadOnly = false,
    this.onEditChromeChanged,
  });

  @override
  ConsumerState<PlanDataScreen> createState() => _PlanDataScreenState();
}

/// Chrome de edición para hostear Cancelar | Info | Editar/Guardar fuera del body.
class PlanInfoEditChrome {
  const PlanInfoEditChrome({
    required this.editing,
    required this.canEdit,
    required this.saving,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  final bool editing;
  final bool canEdit;
  final bool saving;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;
}

class _PlanDataScreenState extends ConsumerState<PlanDataScreen> {
  late Plan currentPlan;
  Uint8List? _selectedImageBytes;
  bool _isUploadingImage = false;
  bool _isUploadingAttachment = false;
  final _planFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _referenceNotesController;
  late TextEditingController _budgetController;
  late String _selectedVisibility;
  late String _selectedCurrency;
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedTimezone;
  double? _budget;
  bool _hasUnsavedChanges = false;
  bool _isUpdatingEventColors = false;
  bool _isSavingPlan = false;
  List<PlanAttachment> _planAttachments = [];
  String? _formEventAccentBaseColor;
  late Map<String, String> _formEventTypeAccentColors;
  // P12: secciones Info colapsables (Participantes / Avisos / Meta / Eliminar plan)
  bool _infoSectionParticipantsExpanded = false;
  bool _infoSectionAnnouncementsExpanded = false;
  bool _infoSectionMetaExpanded = false;
  bool _infoSectionDangerExpanded = false;

  /// Descripción del plan: bloque expandible (cerrado por defecto).
  bool _planDescriptionExpanded = false;

  /// UX D: ficha en lectura; formulario solo al pulsar Editar.
  bool _isEditing = false;
  bool _viewNotesExpanded = false;

  final GlobalKey _participantsSectionKey = GlobalKey();
  final ScrollController _infoScrollController = ScrollController();

  static const Color _cPageBg = IosFormColors.pageBg;

  Color get _pageBackground => _cPageBg;

  bool get _canEditPlanDetails =>
      !widget.forceReadOnly &&
      !PlanStatePermissions.isReadOnly(currentPlan);

  @override
  void initState() {
    super.initState();
    currentPlan = widget.plan;
    _initializeFormState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notifyEditChrome();
    });
  }

  void _initializeFormState() {
    _nameController = TextEditingController(text: currentPlan.name);
    _descriptionController =
        TextEditingController(text: currentPlan.description ?? '');
    _referenceNotesController =
        TextEditingController(text: currentPlan.referenceNotes ?? '');
    _budget = currentPlan.budget;
    _budgetController = TextEditingController(
      text: _budget != null ? _formatBudgetForInput(_budget!) : '',
    );
    _selectedVisibility = currentPlan.visibility ?? 'private';
    _selectedCurrency = currentPlan.currency;
    _startDate = currentPlan.startDate;
    _endDate = currentPlan.endDate;
    _selectedTimezone =
        currentPlan.timezone ?? TimezoneService.getSystemTimezone();
    _planAttachments = List<PlanAttachment>.from(currentPlan.attachments);
    _syncFormEventColorsFromPlan(currentPlan);
    _hasUnsavedChanges = false;
  }

  void _syncFormEventColorsFromPlan(Plan plan) {
    _formEventAccentBaseColor = plan.eventAccentBaseColor;
    _formEventTypeAccentColors =
        Map<String, String>.from(plan.eventTypeAccentColors);
  }

  Plan get _planForColorPreview => currentPlan.copyWith(
        eventAccentBaseColor: _formEventAccentBaseColor,
        eventTypeAccentColors: _formEventTypeAccentColors,
      );

  /// Aplica al formulario el plan recibido (p. ej. desde el padre o tras refresco).
  void _applyPlanToFormFields(Plan plan) {
    currentPlan = plan;
    _nameController.text = plan.name;
    _descriptionController.text = plan.description ?? '';
    _referenceNotesController.text = plan.referenceNotes ?? '';
    _budget = plan.budget;
    _budgetController.text =
        _budget != null ? _formatBudgetForInput(_budget!) : '';
    _selectedVisibility = plan.visibility ?? 'private';
    _selectedCurrency = plan.currency;
    _startDate = plan.startDate;
    _endDate = plan.endDate;
    _selectedTimezone = plan.timezone ?? TimezoneService.getSystemTimezone();
    _planAttachments = List<PlanAttachment>.from(plan.attachments);
    _syncFormEventColorsFromPlan(plan);
    _hasUnsavedChanges = false;
  }

  @override
  void didUpdateWidget(covariant PlanDataScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plan.id != oldWidget.plan.id) {
      _applyPlanToFormFields(widget.plan);
      return;
    }
    // No pisar el formulario con un plan del padre más antiguo que el que ya tenemos:
    // tras guardar, `currentPlan` queda con el `updatedAt` del servidor; el provider
    // puede emitir todavía una pasada con el documento previo y devolvía la fecha fin anterior.
    if (_hasUnsavedChanges) {
      return;
    }
    final incomingAttachments =
        widget.plan.attachments.map((a) => a.url).join('|');
    final localAttachments =
        currentPlan.attachments.map((a) => a.url).join('|');
    final attachmentsChanged = incomingAttachments != localAttachments;
    if (widget.plan.updatedAt.isAfter(currentPlan.updatedAt) ||
        attachmentsChanged) {
      _applyPlanToFormFields(widget.plan);
    }
  }

  @override
  void dispose() {
    final cb = widget.onEditChromeChanged;
    if (cb != null) {
      // No notificar al padre en sync durante unmount (árbol bloqueado → setState ilegal).
      WidgetsBinding.instance.addPostFrameCallback((_) => cb(null));
    }
    _infoScrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _referenceNotesController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _notifyEditChrome() {
    final cb = widget.onEditChromeChanged;
    if (cb == null) return;
    cb(
      PlanInfoEditChrome(
        editing: _isEditing,
        canEdit: _canEditPlanDetails,
        saving: _isSavingPlan,
        onEdit: _enterEditing,
        onCancel: _discardUnsavedChanges,
        onSave: () {
          _onSavePressed();
        },
      ),
    );
  }

  void _enterEditing() {
    setState(() => _isEditing = true);
    _notifyEditChrome();
  }

  void _discardUnsavedChanges() {
    _nameController.text = currentPlan.name;
    _descriptionController.text = currentPlan.description ?? '';
    _referenceNotesController.text = currentPlan.referenceNotes ?? '';
    _budget = currentPlan.budget;
    _budgetController.text =
        _budget != null ? _formatBudgetForInput(_budget!) : '';
    _selectedVisibility = currentPlan.visibility ?? 'private';
    _selectedCurrency = currentPlan.currency;
    _startDate = currentPlan.startDate;
    _endDate = currentPlan.endDate;
    _selectedTimezone =
        currentPlan.timezone ?? TimezoneService.getSystemTimezone();
    _planAttachments = List<PlanAttachment>.from(currentPlan.attachments);
    _syncFormEventColorsFromPlan(currentPlan);
    setState(() {
      _hasUnsavedChanges = false;
      _isEditing = false;
    });
    _notifyEditChrome();
  }

  Future<void> _onSavePressed() async {
    if (_hasUnsavedChanges) {
      await _savePlanDetails();
    } else {
      setState(() => _isEditing = false);
      _notifyEditChrome();
    }
  }

  void _markDirty() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  /// P10: al salir con cambios sin guardar, preguntar guardar / descartar / seguir editando.
  Future<void> _handleExitRequest() async {
    if (!_hasUnsavedChanges) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
    final loc = AppLocalizations.of(context)!;
    final choice = await IosFormActionSheet.show<String>(
      context: context,
      title: loc.planDetailsUnsavedChanges,
      message: loc.planDetailsUnsavedPrompt,
      options: [
        IosFormActionSheetOption(
          value: 'save',
          label: loc.planDetailsBarSaveShort,
          primary: true,
        ),
        IosFormActionSheetOption(
          value: 'discard',
          label: loc.cancelChanges,
          destructive: true,
        ),
        IosFormActionSheetOption(
          value: 'cancel',
          label: loc.planDetailsUnsavedKeepEditing,
          cancel: true,
        ),
      ],
    );
    if (!mounted) return;
    if (choice == 'save') {
      await _savePlanDetails();
      if (mounted && !_hasUnsavedChanges && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else if (choice == 'discard') {
      _discardUnsavedChanges();
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  /// SnackBar estándar UI: éxito (verde), Poppins blanco 14, floating.
  void _showSnackBarSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// SnackBar estándar UI: error (rojo), Poppins blanco 14, floating.
  void _showSnackBarError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showDatesModal() async {
    final loc = AppLocalizations.of(context)!;
    DateTime tempStart = _startDate;
    DateTime tempEnd = _endDate;

    Future<void> pickStart(StateSetter setInner) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: tempStart,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        final normalized = DateTime(picked.year, picked.month, picked.day);
        setInner(() {
          tempStart = normalized;
          tempEnd = clampPlanEndToStart(tempStart, tempEnd);
        });
      }
    }

    Future<void> pickEnd(StateSetter setInner) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: tempEnd,
        firstDate: tempStart,
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setInner(() {
          tempEnd = DateTime(picked.year, picked.month, picked.day);
        });
      }
    }

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
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                      loc.createPlanDatesSectionTitle,
                      style: const TextStyle(
                        color: IosFormColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    IosGroupedCard(
                      children: [
                        IosSettingsRow(
                          label: loc.invitationLabelStartDate,
                          value: DateFormatter.formatDate(tempStart),
                          chevron: true,
                          onTap: () => pickStart(setInner),
                        ),
                        const IosRowSeparator(),
                        IosSettingsRow(
                          label: loc.invitationLabelEndDate,
                          value: DateFormatter.formatDate(tempEnd),
                          chevron: true,
                          onTap: () => pickEnd(setInner),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    IosFormSheetActions(
                      cancelLabel: loc.cancel,
                      confirmLabel: loc.planNotesApplySelection,
                      onCancel: () => Navigator.of(ctx).pop(false),
                      onConfirm: () => Navigator.of(ctx).pop(true),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (applied == true) {
      setState(() {
        _startDate = tempStart;
        _endDate = tempEnd;
        _markDirty();
      });
    }
  }

  Future<void> _savePlanDetails() async {
    final formState = _planFormKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;
    if (currentPlan.id == null) return;

    setState(() {
      _isSavingPlan = true;
    });
    _notifyEditChrome();

    final loc = AppLocalizations.of(context)!;
    final planBeforeSave = currentPlan;
    try {
      final sanitizedName = _nameController.text.trim();
      final sanitizedDescription = _descriptionController.text.trim();
      final normalizedStart =
          DateTime(_startDate.year, _startDate.month, _startDate.day);
      final normalizedEnd =
          DateTime(_endDate.year, _endDate.month, _endDate.day);
      final newColumnCount =
          Plan.calendarDaysInclusive(normalizedStart, normalizedEnd);

      final refNotes = _referenceNotesController.text.trim();
      final updatedPlan = currentPlan.copyWith(
        name: sanitizedName,
        description: sanitizedDescription.isEmpty ? null : sanitizedDescription,
        referenceNotes: refNotes.isEmpty ? null : refNotes,
        baseDate: normalizedStart,
        startDate: normalizedStart,
        endDate: normalizedEnd,
        columnCount: newColumnCount,
        visibility: _selectedVisibility,
        currency: _selectedCurrency,
        timezone: _selectedTimezone,
        budget: _budget,
        attachments: _planAttachments,
        eventAccentBaseColor: _formEventAccentBaseColor,
        eventTypeAccentColors: _formEventTypeAccentColors,
      );

      final planService = ref.read(planServiceProvider);
      final success = await planService.updatePlan(updatedPlan);

      if (!mounted) return;

      if (success) {
        final refreshedPlan = await planService.getPlanById(updatedPlan.id!);
        if (!mounted) return;
        final savedPlan = refreshedPlan ?? updatedPlan;
        await _propagateEventColorsIfChanged(planBeforeSave, savedPlan);
        if (!mounted) return;
        setState(() {
          currentPlan = savedPlan;
          _budget = currentPlan.budget;
          _budgetController.text =
              _budget != null ? _formatBudgetForInput(_budget!) : '';
          _startDate = currentPlan.startDate;
          _endDate = currentPlan.endDate;
          _syncFormEventColorsFromPlan(currentPlan);
          _hasUnsavedChanges = false;
          _isEditing = false;
        });
        _notifyEditChrome();
        // No usar ref.invalidate(plansStreamProvider): re-suscribe el StreamProvider y en Chrome puede
        // provocar "disposed EngineFlutterView" + errores en cascada del WidgetInspector al reportar.
        // El stream de Firestore (getPlansForUser) ya emite al actualizar el documento.
        widget.onPlanUpdated?.call(currentPlan);
        _showSnackBarSuccess(loc.planDetailsSaveSuccess);
      } else {
        _showSnackBarError(loc.planDetailsSaveError);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBarError(loc.planDetailsSaveErrorWithDetail('$e'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPlan = false;
        });
        _notifyEditChrome();
      }
    }
  }

  Widget _buildParticipantsSection(
    AppLocalizations loc,
    AsyncValue<List<PlanParticipation>> participantsAsync, {
    required int participantsCount,
    bool isCompact = false,
  }) {
    if (currentPlan.id == null) {
      return const SizedBox.shrink();
    }

    final countLabel = participantsCount > 0 ? '$participantsCount' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IosSectionLabel(loc.planDetailsParticipantsTitle),
        participantsAsync.when(
          data: (participants) {
            return IosGroupedCard(
              children: [
                IosCollapsibleHeader(
                  title: loc.planDetailsParticipantsTitle,
                  subtitle: countLabel,
                  expanded: _infoSectionParticipantsExpanded,
                  onToggle: () => setState(() =>
                      _infoSectionParticipantsExpanded =
                          !_infoSectionParticipantsExpanded),
                  trailing: HelpIconButton(
                    helpId: HelpContextIds.planDetailsParticipants,
                    contextLabel: loc.planDetailsParticipantsTitle,
                    defaultBody: loc.planDetailsParticipantsHelp,
                  ),
                ),
                if (_infoSectionParticipantsExpanded) ...[
                  const IosRowSeparator(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.onManageParticipants != null) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: widget.onManageParticipants,
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label:
                                  Text(loc.planDetailsParticipantsManageLink),
                              style: TextButton.styleFrom(
                                foregroundColor: IosFormColors.accent,
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (participants.isEmpty)
                          Text(
                            loc.planDetailsNoParticipants,
                            style: const TextStyle(
                              fontSize: 15,
                              color: IosFormColors.textSecondary,
                            ),
                          )
                        else
                          ParticipantsListWidget(
                            planId: currentPlan.id!,
                            showActions: false,
                            compact: isCompact,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const IosGroupedCard(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: IosFormColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
      error: (error, stackTrace) => IosGroupedCard(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Text(
              loc.planDetailsParticipantsLoadError('$error'),
              style: const TextStyle(
                fontSize: 15,
                color: IosFormColors.danger,
              ),
            ),
          ),
        ],
      ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final allParticipantsAsync = currentPlan.id != null
        ? ref.watch(planParticipantsProvider(currentPlan.id!))
        : const AsyncValue<List<PlanParticipation>>.data(<PlanParticipation>[]);
    final participantsAsync = currentPlan.id != null
        ? ref.watch(planRealParticipantsProvider(currentPlan.id!))
        : const AsyncValue<List<PlanParticipation>>.data(<PlanParticipation>[]);
    final participantsCount = participantsAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final canManagePlanAttachments = allParticipantsAsync.maybeWhen(
      data: (participants) {
        if (currentUser == null) return false;
        if (currentUser.id == currentPlan.userId) return true;
        return participants.any(
          (p) =>
              p.userId == currentUser.id &&
              (p.role == 'admin' || p.role == 'organizer'),
        );
      },
      orElse: () => currentUser?.id == currentPlan.userId,
    );

    final isCompact = MediaQuery.of(context).size.width < 900;
    final isOrganizer = currentUser?.id == currentPlan.userId;
    final hostEditChrome = widget.onEditChromeChanged != null;

    Widget buildEditBar({String? title}) {
      return IosFormEditBar(
        editing: _isEditing,
        canEdit: _canEditPlanDetails,
        saving: _isSavingPlan,
        centeredTitle: true,
        editLabel: loc.edit,
        cancelLabel: loc.planDetailsBarCancelShort,
        saveLabel: loc.planDetailsBarSaveShort,
        title: title ?? loc.planDetailsBarTitleShort,
        onEdit: _enterEditing,
        onCancel: _discardUnsavedChanges,
        onSave: () {
          _onSavePressed();
        },
      );
    }

    void scrollToParticipants() {
      setState(() => _infoSectionParticipantsExpanded = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _participantsSectionKey.currentContext;
        if (ctx == null) return;
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      });
    }

    Widget buildBody() {
      final horizontalPadding = isCompact ? 16.0 : 20.0;
      final verticalPadding = isCompact ? 8.0 : 16.0;
      final dateRange =
          '${DateFormatter.formatDate(_startDate)} – ${DateFormatter.formatDate(_endDate)}';
      final heroChips = <IosHeroChipData>[
        if (participantsCount > 0)
          IosHeroChipData(
            loc.planDetailsParticipantsChip(participantsCount),
            onTap: scrollToParticipants,
          ),
      ];
      if (DaysRemainingUtils.shouldShowDaysRemaining(currentPlan)) {
        final days = DaysRemainingUtils.calculateDaysRemaining(currentPlan);
        if (days != null) {
          final soon = DaysRemainingUtils.shouldShowStartingSoon(currentPlan);
          heroChips.add(
            IosHeroChipData(
              DaysRemainingUtils.getDaysRemainingText(days),
              accent: soon || days <= 7,
            ),
          );
        }
      }

      final scroll = SingleChildScrollView(
        controller: _infoScrollController,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalPadding,
          horizontalPadding,
          verticalPadding + 16,
        ),
        child: Form(
          key: _planFormKey,
          child: Builder(
            builder: (context) {
              const double cardSpacing = 8;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.forceReadOnly ||
                      PlanStatePermissions.isReadOnly(currentPlan)) ...[
                    _buildReadOnlyWarning(),
                    const SizedBox(height: 12),
                  ],
                  IosHeroHeader(
                    title: (!_isEditing && widget.showAppBar)
                        ? (_nameController.text.trim().isEmpty
                            ? currentPlan.name
                            : _nameController.text.trim())
                        : null,
                    subtitle: dateRange,
                    chips: heroChips,
                    leading: _buildCompactPlanAvatar(
                      size: isCompact ? 56 : 64,
                    ),
                  ),
                  const SizedBox(height: cardSpacing),
                  _buildInfoSection(loc,
                      showBaseInfo: true,
                      isCompact: isCompact,
                      isOrganizer: isOrganizer),
                  const SizedBox(height: cardSpacing),
                  _buildPlanSummarySection(
                    loc,
                    isCompact: isCompact,
                    canManagePlanAttachments: canManagePlanAttachments,
                  ),
                  if (currentPlan.id != null && !_isEditing) ...[
                    const SizedBox(height: cardSpacing),
                    UpcomingCancellationsSection(
                      planId: currentPlan.id!,
                      isCompact: isCompact,
                    ),
                  ],
                  const SizedBox(height: cardSpacing),
                  KeyedSubtree(
                    key: _participantsSectionKey,
                    child: _buildParticipantsSection(
                      loc,
                      participantsAsync,
                      participantsCount: participantsCount,
                      isCompact: isCompact,
                    ),
                  ),
                  const SizedBox(height: cardSpacing),
                  if (isOrganizer && !widget.forceReadOnly) ...[
                    _buildEventColorsSection(loc, isCompact: isCompact),
                    const SizedBox(height: cardSpacing),
                    _buildAnnouncementsSection(isCompact: isCompact),
                    const SizedBox(height: cardSpacing),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IosSectionLabel(loc.planDetailsMetaTitle),
                        _buildInfoSection(loc,
                            showBaseInfo: false,
                            isCompact: isCompact,
                            isOrganizer: isOrganizer),
                      ],
                    ),
                    const SizedBox(height: cardSpacing),
                  ],
                  if (!widget.forceReadOnly && !_isEditing) ...[
                    _buildLeavePlanButton(),
                    const SizedBox(height: 12),
                    _buildDeleteButton(),
                  ],
                ],
              );
            },
          ),
        ),
      );

      return Container(
        color: _pageBackground,
        child: hostEditChrome
            ? scroll
            : Column(
                children: [
                  buildEditBar(title: loc.planDetailsBarTitleShort),
                  Expanded(child: scroll),
                ],
              ),
      );
    }

    final body = buildBody();

    if (isCompact && widget.showAppBar) {
      final canPop = Navigator.of(context).canPop();
      return PopScope(
        canPop: !_hasUnsavedChanges,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleExitRequest();
        },
        child: Theme(
          data: AppTheme.darkTheme,
          child: Scaffold(
            appBar: AppBar(
              title: Text(currentPlan.name),
              leading: canPop
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _handleExitRequest,
                    )
                  : null,
              actions: [
                if (widget.onManageParticipants != null)
                  IconButton(
                    icon: const Icon(Icons.group_outlined),
                    tooltip: loc.planDetailsParticipantsTitle,
                    onPressed: widget.onManageParticipants,
                  ),
              ],
            ),
            backgroundColor: _pageBackground,
            body: body,
          ),
        ),
      );
    }

    // Embebido en PlanDetailPage (iOS): barra Editar/Guardar + aviso al salir atrás.
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleExitRequest();
      },
      child: Theme(
        data: AppTheme.darkTheme,
        child: body,
      ),
    );
  }

  Widget _buildInfoSection(AppLocalizations loc,
      {required bool showBaseInfo,
      bool isCompact = false,
      bool isOrganizer = false}) {
    if (!showBaseInfo) {
      return IosGroupedCard(
        children: [
          IosCollapsibleHeader(
            title: loc.planDetailsMetaTitle,
            expanded: _infoSectionMetaExpanded,
            onToggle: () => setState(
                () => _infoSectionMetaExpanded = !_infoSectionMetaExpanded),
          ),
          if (_infoSectionMetaExpanded) ...[
            const IosRowSeparator(),
            IosSettingsRow(label: loc.planDetailsMetaUnpIdLabel, value: currentPlan.unpId),
            if (currentPlan.id != null) ...[
              const IosRowSeparator(),
              IosSettingsRow(label: loc.planDetailsMetaIdLabel, value: currentPlan.id!),
            ],
            const IosRowSeparator(),
            IosSettingsRow(
              label: loc.planDetailsMetaCreatedLabel,
              value: _formatDate(currentPlan.createdAt),
            ),
          ],
        ],
      );
    }

    final visibilityShort = _selectedVisibility == 'public'
        ? loc.createPlanVisibilityPublicShort
        : loc.createPlanVisibilityPrivateShort;
    final tz = _selectedTimezone ??
        currentPlan.timezone ??
        TimezoneService.getSystemTimezone();
    final tzLabel = TimezoneService.getTimezoneDisplayName(tz);
    final budgetText = _budget == null
        ? '—'
        : '${_formatBudgetForInput(_budget!)} $_selectedCurrency';
    final datesText =
        '${DateFormatter.formatDate(_startDate)} – ${DateFormatter.formatDate(_endDate)}';
    final stateInfo = PlanStateService.getStateDisplayInfo(currentPlan.state);
    final stateLabel = localizedPlanStateLabel(loc, currentPlan.state);
    final stateColor = Color(stateInfo['color'] as int);
    final stateTransitions = _getAvailableStateTransitions(loc);
    final canChangeState = _isEditing &&
        isOrganizer &&
        stateTransitions.isNotEmpty &&
        !widget.forceReadOnly;

    Widget stateRow({required bool chevron}) {
      return IosSettingsRow(
        label: loc.planDetailsStateLabel,
        value: stateLabel,
        valueDotColor: stateColor,
        valueColor: stateColor,
        chevron: chevron && canChangeState,
        onTap: canChangeState
            ? () => _pickPlanState(loc, stateTransitions)
            : null,
      );
    }

    if (!_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IosSectionLabel(loc.planDetailsSectionGeneral),
          IosGroupedCard(
            children: [
              stateRow(chevron: true),
              const IosRowSeparator(),
              IosSettingsRow(
                label: loc.createPlanVisibilityLabel,
                value: visibilityShort,
              ),
              const IosRowSeparator(),
              IosSettingsRow(
                label: loc.planTimezoneLabel,
                value: tzLabel,
              ),
              const IosRowSeparator(),
              IosSettingsRow(
                label: loc.createPlanCurrencyLabel,
                value: _selectedCurrency,
              ),
              const IosRowSeparator(),
              IosSettingsRow(
                label: loc.planDetailsBudgetLabel,
                value: budgetText,
              ),
            ],
          ),
        ],
      );
    }

    // Modo edición: campos interactivos en card agrupada.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IosSectionLabel(loc.planDetailsSectionGeneral),
        IosGroupedCard(
          children: [
            IosEditField(
              label: loc.createPlanNameLabel,
              controller: _nameController,
              onChanged: (_) {
                _markDirty();
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.createPlanNameRequiredError;
                }
                return null;
              },
            ),
            const IosRowSeparator(),
            IosSettingsRow(
              label: loc.planDetailsDatesLabel,
              value: datesText,
              chevron: true,
              onTap: _showDatesModal,
            ),
            const IosRowSeparator(),
            stateRow(chevron: true),
            const IosRowSeparator(),
            IosSettingsRow(
              label: loc.createPlanVisibilityLabel,
              value: visibilityShort,
              chevron: true,
              onTap: () => _pickVisibility(loc),
            ),
            const IosRowSeparator(),
            IosSettingsRow(
              label: loc.planTimezoneLabel,
              value: tzLabel,
              chevron: true,
              onTap: () => _pickTimezone(loc),
            ),
            const IosRowSeparator(),
            IosSettingsRow(
              label: loc.createPlanCurrencyLabel,
              value: _selectedCurrency,
              chevron: true,
              onTap: () => _pickCurrency(loc),
            ),
            const IosRowSeparator(),
            IosEditField(
              label: '${loc.planDetailsBudgetLabel} ($_selectedCurrency)',
              controller: _budgetController,
              hint: loc.planBudgetLabelShort,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return null;
                final sanitized = trimmed.replaceAll(',', '.');
                final parsed = double.tryParse(sanitized);
                if (parsed == null || parsed < 0) {
                  return loc.planDetailsBudgetInvalid;
                }
                return null;
              },
              onChanged: (raw) {
                final trimmed = raw.trim();
                final sanitized = trimmed.replaceAll(',', '.');
                setState(() {
                  _budget =
                      trimmed.isEmpty ? null : double.tryParse(sanitized);
                });
                _markDirty();
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickVisibility(AppLocalizations loc) async {
    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.createPlanVisibilityLabel,
      options: [
        IosFormPickerOption(
          value: 'private',
          title: loc.createPlanVisibilityPrivateShort,
          selected: _selectedVisibility == 'private',
        ),
        IosFormPickerOption(
          value: 'public',
          title: loc.createPlanVisibilityPublicShort,
          selected: _selectedVisibility == 'public',
        ),
      ],
    );
    if (!mounted || picked == null || picked == _selectedVisibility) return;
    setState(() {
      _selectedVisibility = picked;
      _markDirty();
    });
  }

  Future<void> _pickTimezone(AppLocalizations loc) async {
    final commonTimezones = TimezoneService.getCommonTimezones().toList();
    final fallbackTimezone = TimezoneService.getSystemTimezone();
    final availableTimezones =
        commonTimezones.isNotEmpty ? commonTimezones : [fallbackTimezone];
    final selected =
        _selectedTimezone ?? currentPlan.timezone ?? fallbackTimezone;

    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.planTimezoneLabel,
      maxHeightFactor: 0.55,
      options: availableTimezones
          .map(
            (tz) => IosFormPickerOption(
              value: tz,
              title: TimezoneService.getTimezoneDisplayName(tz),
              subtitle: TimezoneService.getUtcOffsetFormatted(tz),
              selected: tz == selected,
            ),
          )
          .toList(),
    );
    if (!mounted || picked == null || picked == selected) return;
    setState(() {
      _selectedTimezone = picked;
      _markDirty();
    });
  }

  Future<void> _pickCurrency(AppLocalizations loc) async {
    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.createPlanCurrencyLabel,
      maxHeightFactor: 0.45,
      options: Currency.supportedCurrencies
          .map(
            (currency) => IosFormPickerOption(
              value: currency.code,
              title: '${currency.code} · ${currency.symbol}',
              selected: currency.code == _selectedCurrency,
            ),
          )
          .toList(),
    );
    if (!mounted || picked == null || picked == _selectedCurrency) return;
    setState(() {
      _selectedCurrency = picked;
      _markDirty();
    });
  }

  Future<void> _pickPlanState(
    AppLocalizations loc,
    List<Map<String, dynamic>> stateTransitions,
  ) async {
    if (stateTransitions.isEmpty) return;
    if (stateTransitions.length == 1) {
      await _changePlanState(stateTransitions.first['state'] as String);
      return;
    }

    final picked = await IosFormPickerSheet.show<String>(
      context: context,
      title: loc.planDetailsStateLabel,
      options: stateTransitions.map((t) {
        final state = t['state'] as String;
        final info = PlanStateService.getStateDisplayInfo(state);
        final color = Color(info['color'] as int);
        return IosFormPickerOption(
          value: state,
          title: t['label'] as String,
          leading: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      }).toList(),
    );
    if (picked != null && mounted) {
      await _changePlanState(picked);
    }
  }

  /// Aviso solo lectura (patrón D).
  Widget _buildReadOnlyWarning() {
    return IosInfoBanner(
      message: PlanStatePermissions.getBlockedReason('view', currentPlan) ??
          AppLocalizations.of(context)!.planDetailsReadOnlyFallback,
    );
  }

  /// Transiciones de estado permitidas para el plan actual (solo para organizador).
  List<Map<String, dynamic>> _getAvailableStateTransitions(AppLocalizations loc) {
    const icons = {
      'confirmado': Icons.check_circle_outline,
      'en_curso': Icons.play_circle_outline,
      'planificando': Icons.undo,
      'cancelado': Icons.cancel_outlined,
      'finalizado': Icons.check_circle,
    };
    return PlanStateService.availableManualTransitions(currentPlan.state)
        .map(
          (state) => {
            'state': state,
            'label': localizedPlanStateActionLabel(loc, state),
            'icon': icons[state]!,
          },
        )
        .toList();
  }

  Future<void> _changePlanState(String newState) async {
    final loc = AppLocalizations.of(context)!;
    // VALID-1, VALID-2: Ejecutar validaciones adicionales antes de confirmar
    if (newState == 'confirmado' && currentPlan.id != null) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        // Obtener eventos y participantes
        final eventService = ref.read(eventServiceProvider);
        final participantsAsync =
            ref.read(planRealParticipantsProvider(currentPlan.id!));

        final events = await eventService
            .getEventsByPlanId(currentPlan.id!, currentUser.id)
            .first
            .timeout(const Duration(seconds: 10));
        if (!mounted) return;

        final participants = participantsAsync.when(
          data: (data) => data,
          loading: () => <PlanParticipation>[],
          error: (_, __) => <PlanParticipation>[],
        );

        // Ejecutar validaciones
        final validation = PlanValidationService.validatePlanForConfirmation(
          plan: currentPlan,
          events: events,
          participations: participants,
        );

        // Si hay warnings o errors, mostrarlos
        if (validation.warnings.isNotEmpty || validation.errors.isNotEmpty) {
          final validationResult = await showPlanValidationDialog(
            context: context,
            validation: validation,
          );

          // Si el usuario no quiere continuar, cancelar
          if (validationResult != true) {
            return;
          }
        }
      }
    }

    // Mostrar diálogo de confirmación
    if (!mounted) return;
    final confirmed = await showStateTransitionDialog(
      context: context,
      plan: currentPlan,
      newState: newState,
    );

    if (!confirmed || currentPlan.id == null) return;

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        _showSnackBarError(loc.planDetailsNotAuthenticated);
        return;
      }

      final stateService = PlanStateService();
      final success = await stateService.changePlanState(
        planId: currentPlan.id!,
        newState: newState,
        userId: currentUser.id,
      );

      if (success && mounted) {
        // Actualizar el plan localmente
        final planService = ref.read(planServiceProvider);
        final updatedPlan = await planService.getPlanById(currentPlan.id!);
        if (updatedPlan != null && mounted) {
          setState(() {
            currentPlan = updatedPlan;
          });
          _showSnackBarSuccess(loc.planDetailsStateUpdated(
            localizedPlanStateLabel(loc, newState),
          ));
        }
      } else if (mounted) {
        _showSnackBarError(loc.planDetailsStateChangeFailed);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBarError(loc.planDetailsStateChangeError(e.toString()));
      }
    }
  }

  /// Botón "Salir del plan" para participantes (no organizador). Elimina su participación.
  Widget _buildLeavePlanButton() {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    if (currentPlan.id == null || currentUser == null) {
      return const SizedBox.shrink();
    }
    final isOwner = currentUser.id == currentPlan.userId;
    if (isOwner) return const SizedBox.shrink();

    final participantsAsync =
        ref.watch(planParticipantsProvider(currentPlan.id!));
    final isParticipant = participantsAsync.maybeWhen(
      data: (list) => list.any((p) => p.userId == currentUser.id),
      orElse: () => false,
    );
    if (!isParticipant) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IosDestructiveTile(
          label: loc.planCardLeavePlanTitle,
          onPressed: () => _showLeavePlanConfirmation(context),
        ),
        const SizedBox(height: 8),
        Text(
          loc.planDetailsLeavePlanHint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: IosFormColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _showLeavePlanConfirmation(BuildContext context) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || currentPlan.id == null) return;
    final loc = AppLocalizations.of(context)!;
    final soloItems = await ref
        .read(planParticipationServiceProvider)
        .previewSoloOwnedItemsOnLeave(
          planId: currentPlan.id!,
          userId: currentUser.id,
        );
    if (!context.mounted) return;
    final soloWarn = formatMembershipSoloItemsWarning(
      loc,
      soloItems,
      leavingSelf: true,
    );
    final body = soloWarn.isEmpty
        ? loc.planCardLeavePlanConfirmBody(currentPlan.name)
        : '${loc.planCardLeavePlanConfirmBody(currentPlan.name)}\n\n$soloWarn';

    final confirmed = await IosFormConfirmSheet.show(
      context: context,
      title: loc.planCardLeavePlanTitle,
      message: body,
      cancelLabel: loc.cancel,
      confirmLabel: loc.planCardLeavePlanButton,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final participationService = ref.read(planParticipationServiceProvider);
      final leftDisplay = currentUser.displayName?.trim().isNotEmpty == true
          ? currentUser.displayName!.trim()
          : currentUser.email;
      final organizerId = currentPlan.userId;
      final success = await participationService.removeParticipation(
          currentPlan.id!, currentUser.id);
      if (!context.mounted) return;
      if (success) {
        if (organizerId.isNotEmpty && organizerId != currentUser.id) {
          await NotificationHelper().notifyParticipantLeft(
            organizerUserId: organizerId,
            planId: currentPlan.id!,
            leftUserDisplay: leftDisplay,
            planName: currentPlan.name,
            deletedSoloItemLabels: soloOwnedItemLabelsForNotification(soloItems),
          );
        }
        if (!context.mounted) return;
        ref
            .read(planParticipationNotifierProvider(currentPlan.id!).notifier)
            .reload();
        widget.onPlanDeleted?.call();
        _showSnackBarSuccess(loc.planDetailsLeavePlanSuccess);
      } else {
        _showSnackBarError(loc.planDetailsLeavePlanFailed);
      }
    } catch (e) {
      LoggerService.error('Error leaving plan',
          context: 'PlanDataScreen', error: e);
      if (context.mounted) {
        _showSnackBarError(loc.planDetailsLeavePlanError('$e'));
      }
    }
  }

  Widget _buildDeleteButton() {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.id == currentPlan.userId;
    if (!isOwner) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: IosFormColors.groupedBg,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() =>
                    _infoSectionDangerExpanded = !_infoSectionDangerExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.planInfoDangerZoneTitle,
                          style: const TextStyle(
                            color: IosFormColors.danger,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Icon(
                        _infoSectionDangerExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: IosFormColors.danger,
                      ),
                    ],
                  ),
                ),
              ),
              if (_infoSectionDangerExpanded) ...[
                const IosRowSeparator(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        loc.planInfoDangerZoneSubtitle,
                        style: const TextStyle(
                          color: IosFormColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      IosDestructiveTile(
                        label: loc.planDeleteDialogConfirm,
                        onPressed: () => _showDeleteConfirmation(context),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) => DateFormatter.formatDate(date);

  String _formatBudgetForInput(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    final confirmed = await showDeletePlanPasswordSheet(
      context,
      loc: loc,
      onDelete: _deletePlan,
    );

    if (confirmed) {
      widget.onPlanDeleted?.call();
    }
  }

  Future<bool> _deletePlan(String password) async {
    if (currentPlan.id == null) return false;
    final loc = AppLocalizations.of(context)!;

    try {
      final authService = ref.read(authServiceProvider);
      final planService = ref.read(planServiceProvider);
      final eventService = ref.read(eventServiceProvider);

      final planId = currentPlan.id!;

      final success = await authService.deletePlan(
        planId: planId,
        reauthenticate: true,
        password: password,
      );

      if (!success) {
        return false;
      }

      if (currentPlan.imageUrl != null) {
        await ImageService.deletePlanImage(currentPlan.imageUrl!);
      }

      await eventService.deleteEventsByPlanId(planId);

      final deleted = await planService.deletePlan(planId);
      if (!context.mounted) return deleted;

      if (!deleted) {
        _showSnackBarError(loc.planDeleteError);
        return false;
      }

      _showSnackBarSuccess(loc.planDeleteSuccess(currentPlan.name));
      return true;
    } catch (e) {
      LoggerService.error('Error deleting plan',
          context: 'PLAN_DATA_SCREEN', error: e);
      if (!mounted) return false;
      _showSnackBarError(_mapDeleteErrorMessage(
          e.toString().replaceFirst('Exception: ', ''), loc));
      return false;
    }
  }

  void _setScreenState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }
}

extension _PlanDataScreenStateExtension on _PlanDataScreenState {
  String _mapDeleteErrorMessage(String errorCode, AppLocalizations loc) {
    String normalized = errorCode.trim();
    if (normalized.startsWith('Exception: ')) {
      normalized = normalized.substring('Exception: '.length);
    }
    switch (normalized) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'requires-recent-login':
        return loc.planDeleteDialogAuthError;
      case 'auth/missing-password':
        return loc.planDeleteDialogPasswordRequired;
      case 'auth/no-email':
      case 'auth/no-current-user':
        return loc.planDeleteError;
      default:
        return loc.planDeleteError;
    }
  }


  /// Avatar compacto del hero; cámara solo en modo edición (vía [_buildPlanAvatar]).
  Widget _buildCompactPlanAvatar({required double size}) {
    return _buildPlanAvatar(size);
  }

  String _familyLabel(AppLocalizations loc, String family) {
    switch (family) {
      case 'Desplazamiento':
        return loc.planEventColorsFamilyDesplazamiento;
      case 'Restauración':
        return loc.planEventColorsFamilyRestauracion;
      case 'Actividad':
        return loc.planEventColorsFamilyActividad;
      case 'Acción':
        return loc.planEventColorsFamilyAccion;
      case 'Otro':
        return loc.planEventColorsFamilyOtro;
      default:
        return family;
    }
  }

  Widget _buildEventColorsSection(AppLocalizations loc, {bool isCompact = false}) {
    final previewPlan = _planForColorPreview;
    final base = PlanEventAccentColors.baseColor(previewPlan);
    final canEditColors = _isEditing;

    Widget colorRow(String label, String colorName, VoidCallback? onPick) {
      return IosColorSettingRow(
        label: label,
        color: ColorUtils.colorFromName(colorName),
        chevron: canEditColors,
        onTap: canEditColors && !_isSavingPlan ? onPick : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IosSectionLabel(loc.planEventColorsTitle),
        IosGroupedCard(
          children: [
            colorRow(
              loc.planEventColorsBase,
              base,
              () => _pickBaseColor(loc),
            ),
            const IosRowSeparator(),
            IosGroupedCardCaption(loc.planEventColorsSubtitle),
            for (var i = 0; i < PlanEventAccentColors.typeFamilies.length; i++) ...[
              if (i > 0) const IosRowSeparator(),
              colorRow(
                _familyLabel(loc, PlanEventAccentColors.typeFamilies[i]),
                PlanEventAccentColors.effectiveFamilyColor(
                  previewPlan,
                  PlanEventAccentColors.typeFamilies[i],
                ),
                () => _pickFamilyColor(
                  loc,
                  PlanEventAccentColors.typeFamilies[i],
                ),
              ),
            ],
            if (canEditColors) ...[
              const IosRowSeparator(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSavingPlan ? null : _restoreDraftEventColorDefaults,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Text(
                      loc.planEventColorsRestore,
                      style: TextStyle(
                        color: IosFormColors.accent,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (_isSavingPlan && _isUpdatingEventColors) ...[
              const IosRowSeparator(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<String?> _showColorPickerSheet(AppLocalizations loc, String current) {
    return IosFormColorPickerSheet.show(
      context: context,
      title: loc.planEventColorsPickTitle,
      selectedId: current,
      options: PlanEventAccentColors.palette
          .map(
            (name) => IosFormColorPickerOption(
              id: name,
              color: ColorUtils.colorFromName(name),
            ),
          )
          .toList(),
    );
  }

  void _applyDraftEventColors(Plan nextPlan) {
    _setScreenState(() {
      _formEventAccentBaseColor = nextPlan.eventAccentBaseColor;
      _formEventTypeAccentColors =
          Map<String, String>.from(nextPlan.eventTypeAccentColors);
      _markDirty();
    });
  }

  Future<void> _pickBaseColor(AppLocalizations loc) async {
    final current = PlanEventAccentColors.baseColor(_planForColorPreview);
    final picked = await _showColorPickerSheet(loc, current);
    if (picked == null || picked == current || !mounted) return;
    _applyDraftEventColors(
      PlanEventAccentColors.applyBaseColorChange(_planForColorPreview, picked),
    );
  }

  Future<void> _pickFamilyColor(AppLocalizations loc, String family) async {
    final current =
        PlanEventAccentColors.effectiveFamilyColor(_planForColorPreview, family);
    final picked = await _showColorPickerSheet(loc, current);
    if (picked == null || picked == current || !mounted) return;
    _applyDraftEventColors(
      PlanEventAccentColors.applyFamilyColorChange(
        _planForColorPreview,
        family,
        picked,
      ),
    );
  }

  void _restoreDraftEventColorDefaults() {
    _applyDraftEventColors(
      PlanEventAccentColors.restoreDefaults(_planForColorPreview),
    );
  }

  Future<void> _propagateEventColorsIfChanged(Plan before, Plan after) async {
    if (before.id == null) return;
    final changedFamilies = <String>[];
    for (final fam in PlanEventAccentColors.typeFamilies) {
      if (PlanEventAccentColors.effectiveFamilyColor(before, fam) !=
          PlanEventAccentColors.effectiveFamilyColor(after, fam)) {
        changedFamilies.add(fam);
      }
    }
    if (changedFamilies.isEmpty) return;

    _setScreenState(() => _isUpdatingEventColors = true);
    try {
      final eventService = ref.read(eventServiceProvider);
      final planId = before.id!;
      for (final fam in changedFamilies) {
        await eventService.updateAccentColorForTypeFamilies(
          planId: planId,
          typeFamilies: [fam],
          colorName: PlanEventAccentColors.effectiveFamilyColor(after, fam),
        );
      }
      ref.invalidate(planEventsStreamProvider(planId));
    } catch (e, st) {
      LoggerService.error(
        'Event accent propagation after save failed',
        context: 'PLAN_DATA',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        _showSnackBarError(loc.planDetailsEventColorsUpdateError('$e'));
      }
    } finally {
      if (mounted) {
        _setScreenState(() => _isUpdatingEventColors = false);
      }
    }
  }

  Widget _buildPlanSummarySection(
    AppLocalizations loc, {
    bool isCompact = false,
    bool canManagePlanAttachments = false,
  }) {
    if (!_isEditing) {
      final hasDescription = _descriptionController.text.trim().isNotEmpty;
      final hasNotes = _referenceNotesController.text.trim().isNotEmpty;
      if (!hasDescription && !hasNotes) {
        return _buildPlanAttachmentsBar(
          loc,
          canManage: false,
          isCompact: isCompact,
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IosSectionLabel(loc.planDetailsSectionDescription),
          IosGroupedCard(
            children: [
              if (hasDescription)
                IosExpandableText(
                  text: _descriptionController.text,
                  expanded: _planDescriptionExpanded,
                  onToggle: () => _setScreenState(
                    () =>
                        _planDescriptionExpanded = !_planDescriptionExpanded,
                  ),
                  seeMoreLabel: loc.planDetailsSeeMore,
                  seeLessLabel: loc.planDetailsSeeLess,
                ),
              if (hasDescription && hasNotes) const IosRowSeparator(),
              if (hasNotes) ...[
                if (hasDescription)
                  IosGroupedCardCaption(loc.planDetailsSectionNotes),
                IosExpandableText(
                  text: _referenceNotesController.text,
                  expanded: _viewNotesExpanded,
                  onToggle: () => _setScreenState(
                    () => _viewNotesExpanded = !_viewNotesExpanded,
                  ),
                  seeMoreLabel: loc.planDetailsSeeMore,
                  seeLessLabel: loc.planDetailsSeeLess,
                ),
              ],
            ],
          ),
          _buildPlanAttachmentsBar(
            loc,
            canManage: false,
            isCompact: isCompact,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IosSectionLabel(loc.planDetailsSectionDescription),
        IosGroupedCard(
          children: [
            IosEditField(
              label: loc.createPlanDescriptionLabel,
              controller: _descriptionController,
              hint: loc.createPlanDescriptionHint,
              minLines: 3,
              maxLines: 8,
              onChanged: (_) => _markDirty(),
            ),
          ],
        ),
        IosSectionLabel(loc.planDetailsSectionNotes),
        IosGroupedCard(
          children: [
            IosEditField(
              label: loc.planReferenceNotesTitle,
              controller: _referenceNotesController,
              hint: loc.planReferenceNotesHint,
              minLines: 3,
              maxLines: 8,
              onChanged: (_) => _markDirty(),
            ),
          ],
        ),
        _buildPlanAttachmentsBar(
          loc,
          canManage: canManagePlanAttachments,
          isCompact: isCompact,
        ),
      ],
    );
  }

  Widget _buildPlanAttachmentsBar(AppLocalizations loc,
      {required bool canManage, required bool isCompact}) {
    final files = _planAttachments;
    final showInEdit = _isEditing && canManage;
    if (files.isEmpty && !showInEdit) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    if (showInEdit) {
      children.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (_isUploadingAttachment || currentPlan.id == null)
                ? null
                : _pickAndUploadPlanAttachment,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (_isUploadingAttachment)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.upload_file,
                        size: 20, color: IosFormColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isUploadingAttachment
                          ? loc.entityAttachmentsUploading
                          : loc.entityAttachmentsUpload,
                      style: TextStyle(
                        color: IosFormColors.accent,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (files.isEmpty) {
      if (children.isNotEmpty) children.add(const IosRowSeparator());
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Text(
            loc.entityAttachmentsEmpty,
            style: const TextStyle(
              fontSize: 15,
              color: IosFormColors.textSecondary,
            ),
          ),
        ),
      );
    } else {
      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        if (children.isNotEmpty) children.add(const IosRowSeparator());
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _openPlanAttachment(file.url),
                    child: Text(
                      file.name,
                      style: TextStyle(
                        color: IosFormColors.accent,
                        fontSize: 17,
                        decoration: TextDecoration.underline,
                        decorationColor: IosFormColors.accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatFileSize(file.size),
                  style: const TextStyle(
                    fontSize: 15,
                    color: IosFormColors.textSecondary,
                  ),
                ),
                if (canManage) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: loc.entityAttachmentsDeleteTitle,
                    onPressed: _isUploadingAttachment
                        ? null
                        : () => _deletePlanAttachment(file),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: IosFormColors.danger,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IosSectionLabel(loc.entityAttachmentsPlanTitle),
        IosGroupedCard(children: children),
      ],
    );
  }

  Future<void> _pickAndUploadPlanAttachment() async {
    final planId = currentPlan.id;
    if (planId == null) return;
    final PickedPlanFile picked;
    try {
      final result = await PlanFileService.pickAttachment();
      if (result == null) return;
      picked = result;
    } catch (_) {
      if (!mounted) return;
      _showSnackBarError(
          AppLocalizations.of(context)!.entityAttachmentsReadError);
      return;
    }

    final validationError = PlanFileService.validateAttachment(picked);
    if (validationError != null) {
      _showSnackBarError(validationError);
      return;
    }

    _setScreenState(() {
      _isUploadingAttachment = true;
    });

    try {
      final uploaded =
          await PlanFileService.uploadAttachment(planId: planId, file: picked);
      if (!mounted) return;
      _setScreenState(() {
        _planAttachments = [..._planAttachments, uploaded];
      });
      _markDirty();
      _showSnackBarSuccess(
          AppLocalizations.of(context)!.entityAttachmentsSnackbarAdded);
    } catch (e) {
      if (!mounted) return;
      final message =
          e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
      _showSnackBarError(
          AppLocalizations.of(context)!.entityAttachmentsUploadError(message));
    } finally {
      _setScreenState(() {
        _isUploadingAttachment = false;
      });
    }
  }

  Future<void> _deletePlanAttachment(PlanAttachment attachment) async {
    final loc = AppLocalizations.of(context)!;
    final confirm = await IosFormConfirmSheet.show(
      context: context,
      title: loc.entityAttachmentsDeleteTitle,
      message: loc.entityAttachmentsDeleteConfirm(attachment.name),
      cancelLabel: loc.cancel,
      confirmLabel: loc.delete,
      destructive: true,
    );
    if (!confirm) return;

    _setScreenState(() {
      _isUploadingAttachment = true;
    });
    try {
      await PlanFileService.deleteAttachment(attachment.url);
      if (!mounted) return;
      _setScreenState(() {
        _planAttachments =
            _planAttachments.where((f) => f.url != attachment.url).toList();
      });
      _markDirty();
      _showSnackBarSuccess(
          AppLocalizations.of(context)!.entityAttachmentsSnackbarRemoved);
    } catch (e) {
      if (!mounted) return;
      _showSnackBarError(
          AppLocalizations.of(context)!.entityAttachmentsDeleteError);
    } finally {
      _setScreenState(() {
        _isUploadingAttachment = false;
      });
    }
  }

  Future<void> _openPlanAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Widget _buildPlanAvatar(double size) {
    final imageUrl = currentPlan.imageUrl;

    Widget buildImage() {
      if (_selectedImageBytes != null) {
        return ClipOval(
          child: Image.memory(
            _selectedImageBytes!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      }
      if (imageUrl != null && ImageService.isValidImageUrl(imageUrl)) {
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColorScheme.color2.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => _buildAvatarFallback(size),
          ),
        );
      }
      return _buildAvatarFallback(size);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70),
          ),
          child: buildImage(),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: (!_isEditing || !_canEditPlanDetails)
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: _isUploadingImage ? null : _pickImage,
                  child: Container(
                    padding: EdgeInsets.all(size < 72 ? 6 : 10),
                    decoration: BoxDecoration(
                      color: AppColorScheme.color2,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _isUploadingImage
                        ? SizedBox(
                            width: size < 72 ? 12 : 16,
                            height: size < 72 ? 12 : 16,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.photo_camera,
                            color: Colors.white, size: size < 72 ? 14 : 18),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColorScheme.color2.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.image_outlined,
        color: AppColorScheme.color2.withValues(alpha: 0.5),
        size: size * 0.4,
      ),
    );
  }

  Widget _buildAnnouncementsSection({bool isCompact = false}) {
    if (currentPlan.id == null) {
      return const SizedBox.shrink();
    }

    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IosSectionLabel(loc.planDetailsAnnouncementsTitle),
        IosGroupedCard(
          children: [
            IosCollapsibleHeader(
              title: loc.planDetailsAnnouncementsTitle,
              expanded: _infoSectionAnnouncementsExpanded,
              onToggle: () => _setScreenState(() =>
                  _infoSectionAnnouncementsExpanded =
                      !_infoSectionAnnouncementsExpanded),
              trailing: HelpIconButton(
                helpId: HelpContextIds.planDetailsAviso,
                contextLabel: loc.planDetailsAnnouncementsTitle,
                defaultBody: loc.planDetailsAnnouncementsHelp,
              ),
            ),
            if (_infoSectionAnnouncementsExpanded) ...[
              const IosRowSeparator(),
              if (_isEditing) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AnnouncementDialog(planId: currentPlan.id!),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(loc.planDetailsAnnouncementsPublish),
                      style: TextButton.styleFrom(
                        foregroundColor: IosFormColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
              ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: 160, maxHeight: 420),
                child: AnnouncementTimeline(
                  planId: currentPlan.id!,
                  compact: isCompact,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final loc = AppLocalizations.of(context)!;
    final XFile? image = await ImageService.pickImageFromGallery();
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    _setScreenState(() {
      _selectedImageBytes = bytes;
      _isUploadingImage = true;
    });

    try {
      final validationError = await ImageService.validateImage(image);
      if (validationError != null) {
        if (mounted) {
          _showSnackBarError(validationError);
        }
        return;
      }

      final uploadedImageUrl =
          await ImageService.uploadPlanImage(image, currentPlan.id!);
      final updatedPlan = currentPlan.copyWith(imageUrl: uploadedImageUrl);
      final planService = ref.read(planServiceProvider);
      final success = await planService.updatePlan(updatedPlan);

      if (!success) {
        throw Exception(loc.planDetailsSaveError);
      }

      if (mounted) {
        _setScreenState(() {
          currentPlan = updatedPlan;
          _selectedImageBytes = null;
        });
        _showSnackBarSuccess(loc.planDetailsImageUpdateSuccess);
      }
    } catch (e) {
      final message =
          e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
      if (mounted) {
        _showSnackBarError(loc.planDetailsImageSaveError(message));
      }
    } finally {
      _setScreenState(() {
        _isUploadingImage = false;
        _selectedImageBytes = null;
      });
    }
  }
}
