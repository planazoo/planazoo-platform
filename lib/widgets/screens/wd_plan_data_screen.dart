import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/state_transition_dialog.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/widgets/dialogs/announcement_dialog.dart';
import 'package:unp_calendario/widgets/screens/announcement_timeline.dart';
import 'package:unp_calendario/shared/utils/days_remaining_utils.dart';
import 'package:unp_calendario/widgets/plan/days_remaining_indicator.dart';
import 'package:unp_calendario/shared/utils/plan_validation_utils.dart';
import 'package:unp_calendario/widgets/dialogs/plan_validation_dialog.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/plan/wd_participants_list_widget.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan_state_badge.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/shared/constants/help_context_ids.dart';
import 'package:unp_calendario/shared/providers/help_text_providers.dart';
import 'package:unp_calendario/widgets/help/help_icon_button.dart';

class PlanDataScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onPlanDeleted;
  final VoidCallback? onManageParticipants;
  /// Si se proporciona, el botón resumen abre la página de resumen en lugar del diálogo.
  final VoidCallback? onOpenSummary;
  final bool showAppBar;

  const PlanDataScreen({
    super.key,
    required this.plan,
    this.onPlanDeleted,
    this.onManageParticipants,
    this.onOpenSummary,
    this.showAppBar = true,
  });

  @override
  ConsumerState<PlanDataScreen> createState() => _PlanDataScreenState();
}

class _PlanDataScreenState extends ConsumerState<PlanDataScreen> {
  late Plan currentPlan;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isUploadingImage = false;
  final _planFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late String _selectedVisibility;
  late String _selectedCurrency;
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedTimezone;
  double? _budget;
  bool _hasUnsavedChanges = false;
  bool _isSavingPlan = false;

  // Helper para detectar modo oscuro
  bool get _isDarkMode {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Colores del estilo Sofisticado (siempre modo oscuro)
  Color get _cardBackgroundStart => Colors.grey.shade800;
  Color get _cardBackgroundEnd => const Color(0xFF2C2C2C);
  Color get _cardBorder => Colors.grey.shade700.withOpacity(0.5);
  Color get _textPrimary => Colors.white;
  Color get _textSecondary => Colors.grey.shade400;
  Color get _inputBackground => Colors.grey.shade800;
  Color get _inputText => Colors.white;

  /// Estilo del contenido de los campos (igual que nombre del plan)
  TextStyle get _infoContentStyle => GoogleFonts.poppins(
        fontSize: 15,
        color: _textPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  @override
  void initState() {
    super.initState();
    currentPlan = widget.plan;
    _initializeFormState();
  }

  void _initializeFormState() {
    _nameController = TextEditingController(text: currentPlan.name);
    _descriptionController = TextEditingController(text: currentPlan.description ?? '');
    _budget = currentPlan.budget;
    _budgetController = TextEditingController(
      text: _budget != null ? _formatBudgetForInput(_budget!) : '',
    );
    _selectedVisibility = currentPlan.visibility ?? 'private';
    _selectedCurrency = currentPlan.currency;
    _startDate = currentPlan.startDate;
    _endDate = currentPlan.endDate;
    _selectedTimezone = currentPlan.timezone ?? TimezoneService.getSystemTimezone();
    _hasUnsavedChanges = false;
  }

  @override
  void didUpdateWidget(covariant PlanDataScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plan.id != oldWidget.plan.id ||
        widget.plan.updatedAt != oldWidget.plan.updatedAt ||
        widget.plan != oldWidget.plan) {
      currentPlan = widget.plan;
      _nameController.text = currentPlan.name;
      _descriptionController.text = currentPlan.description ?? '';
      _budget = currentPlan.budget;
      _budgetController.text = _budget != null ? _formatBudgetForInput(_budget!) : '';
      _selectedVisibility = currentPlan.visibility ?? 'private';
      _selectedCurrency = currentPlan.currency;
      _startDate = currentPlan.startDate;
      _endDate = currentPlan.endDate;
      _selectedTimezone = currentPlan.timezone ?? TimezoneService.getSystemTimezone();
      _hasUnsavedChanges = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  /// SnackBar estándar UI: éxito (verde), Poppins blanco 14, floating.
  void _showSnackBarSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
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
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showDatesModal() async {
    DateTime tempStart = _startDate;
    DateTime tempEnd = _endDate;
    final applied = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Theme(
          data: AppTheme.darkTheme,
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return AlertDialog(
                backgroundColor: Colors.grey.shade800,
                title: Text(
                  'Fechas del plan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDateTile(
                      label: 'Inicio',
                      value: tempStart,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempStart,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          final normalized = DateTime(picked.year, picked.month, picked.day);
                          setInnerState(() {
                            tempStart = normalized;
                            if (tempEnd.isBefore(tempStart)) tempEnd = tempStart;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateTile(
                      label: 'Fin',
                      value: tempEnd,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempEnd,
                          firstDate: tempStart,
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setInnerState(() {
                            tempEnd = DateTime(picked.year, picked.month, picked.day);
                          });
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(color: Colors.grey.shade400),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.color2,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Aplicar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            },
          ),
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

    final loc = AppLocalizations.of(context)!;
    try {
      final sanitizedName = _nameController.text.trim();
      final sanitizedDescription = _descriptionController.text.trim();
      final normalizedStart = DateTime(_startDate.year, _startDate.month, _startDate.day);
      final normalizedEnd = DateTime(_endDate.year, _endDate.month, _endDate.day);
      final newColumnCount = normalizedEnd.difference(normalizedStart).inDays + 1;

      final updatedPlan = currentPlan.copyWith(
        name: sanitizedName,
        description: sanitizedDescription.isEmpty ? null : sanitizedDescription,
        baseDate: normalizedStart,
        startDate: normalizedStart,
        endDate: normalizedEnd,
        columnCount: newColumnCount,
        visibility: _selectedVisibility,
        currency: _selectedCurrency,
        timezone: _selectedTimezone,
        budget: _budget,
      );

      final planService = ref.read(planServiceProvider);
      final success = await planService.updatePlan(updatedPlan);

      if (!mounted) return;

      if (success) {
        final refreshedPlan = await planService.getPlanById(updatedPlan.id!);
        if (!mounted) return;
        setState(() {
          currentPlan = refreshedPlan ?? updatedPlan;
          _budget = currentPlan.budget;
          _budgetController.text = _budget != null ? _formatBudgetForInput(_budget!) : '';
          _hasUnsavedChanges = false;
        });
        _showSnackBarSuccess(loc.planDetailsSaveSuccess);
      } else {
        _showSnackBarError(loc.planDetailsSaveError);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBarError('Error al guardar el plan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPlan = false;
        });
      }
    }
  }

  Widget _buildParticipantsSection(
    AppLocalizations loc,
    AsyncValue<List<PlanParticipation>> participantsAsync, {
    bool isCompact = false,
  }) {
    if (currentPlan.id == null) {
      return const SizedBox.shrink();
    }

    return participantsAsync.when(
      data: (participants) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _cardBackgroundStart,
                _cardBackgroundEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _cardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.group_outlined, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        loc.planDetailsParticipantsTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      HelpIconButton(
                        helpId: HelpContextIds.planDetailsParticipants,
                        contextLabel: loc.planDetailsParticipantsTitle,
                        defaultBody: 'Lista de personas que forman parte del plan. El organizador puede invitar, asignar roles (organizador, participante, observador) y quitar participantes. Gestionar participantes abre la pantalla completa de administración.',
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.onManageParticipants != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: widget.onManageParticipants,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(loc.planDetailsParticipantsManageLink),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColorScheme.color2,
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (participants.isEmpty)
                Text(
                  loc.planDetailsNoParticipants,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textSecondary,
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
        );
      },
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _cardBackgroundStart,
              _cardBackgroundEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _cardBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 2),
              spreadRadius: -4,
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          'Error al cargar participantes: $error',
          style: AppTypography.bodyStyle.copyWith(
            fontSize: 13,
            color: Colors.red,
          ),
        ),
      ),
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
    final currentRoleLabel = _resolveCurrentUserRoleLabel(
      currentUser,
      allParticipantsAsync,
      loc,
    );
    final currentUserHandle = _formatUserHandle(currentUser);

    final isCompact = MediaQuery.of(context).size.width < 900;

    /// Barra superior W31: título "Info del plan", iconos resumen + in/out (salir plan), y Cancelar/Guardar si hay cambios.
    final isOrganizer = currentUser?.id == currentPlan.userId;
    Widget buildHeader() {
      return Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColorScheme.color2,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Info del plan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasUnsavedChanges) ...[
                      TextButton(
                        onPressed: _isSavingPlan ? null : () {
                          _nameController.text = currentPlan.name;
                          _descriptionController.text = currentPlan.description ?? '';
                          _budget = currentPlan.budget;
                          _budgetController.text = _budget != null ? _formatBudgetForInput(_budget!) : '';
                          _selectedVisibility = currentPlan.visibility ?? 'private';
                          _selectedCurrency = currentPlan.currency;
                          _startDate = currentPlan.startDate;
                          _endDate = currentPlan.endDate;
                          _selectedTimezone = currentPlan.timezone ?? TimezoneService.getSystemTimezone();
                          setState(() => _hasUnsavedChanges = false);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          foregroundColor: Colors.orange.shade200,
                        ),
                        child: Text(loc.planDetailsBarCancelShort, style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade200)),
                      ),
                      const SizedBox(width: 6),
                      FilledButton(
                        onPressed: _isSavingPlan || PlanStatePermissions.isReadOnly(currentPlan) ? null : _savePlanDetails,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isSavingPlan
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(loc.planDetailsBarSaveShort, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildBody() {
      final horizontalPadding = isCompact ? 16.0 : 20.0;
      final verticalPadding = isCompact ? 16.0 : 20.0;

      return Container(
        color: Colors.grey.shade900,
        child: Column(
          children: [
            buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: Form(
                  key: _planFormKey,
                  child: Builder(
                    builder: (context) {
                      const double cardSpacing = 24;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (PlanStatePermissions.isReadOnly(currentPlan)) ...[
                            _buildReadOnlyWarning(),
                            const SizedBox(height: cardSpacing),
                          ],
                          _buildPlanImageSection(isCompact: isCompact),
                          const SizedBox(height: cardSpacing),
                          _buildPlanSummarySection(loc, participantsCount, currentRoleLabel, currentUserHandle, isCompact: isCompact),
                          const SizedBox(height: cardSpacing),
                          _buildInfoSection(loc, showBaseInfo: true, isCompact: isCompact),
                          const SizedBox(height: cardSpacing),
                          _buildParticipantsSection(loc, participantsAsync, isCompact: isCompact),
                          const SizedBox(height: cardSpacing),
                          _buildAnnouncementsSection(isCompact: isCompact),
                          const SizedBox(height: cardSpacing),
                          _buildLeavePlanButton(),
                          const SizedBox(height: cardSpacing),
                          _buildDeleteButton(),
                          if (isOrganizer) ...[
                            const SizedBox(height: cardSpacing),
                            _buildInfoSection(loc, showBaseInfo: false, isCompact: isCompact),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final body = buildBody();

    if (isCompact && widget.showAppBar) {
      final canPop = Navigator.of(context).canPop();
      return Theme(
        data: AppTheme.darkTheme,
        child: Scaffold(
        appBar: AppBar(
          title: Text(currentPlan.name),
          leading: canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
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
        backgroundColor: Colors.grey.shade900,
        body: body,
        ),
      );
    }

    return Theme(
      data: AppTheme.darkTheme,
      child: body,
    );
  }

  Widget _buildInfoSection(AppLocalizations loc, {required bool showBaseInfo, bool isCompact = false}) {
    final showCountdown = DaysRemainingUtils.shouldShowDaysRemaining(currentPlan);

    final child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBaseInfo) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= 600;
                final leftColumn = [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTile(
                          label: 'Inicio',
                          value: _startDate,
                          onTap: _showDatesModal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTile(
                          label: 'Fin',
                          value: _endDate,
                          onTap: _showDatesModal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDropdownTile(
                          label: loc.createPlanCurrencyLabel,
                          value: _selectedCurrency,
                          items: Currency.supportedCurrencies
                              .map(
                                (currency) => DropdownMenuItem(
                                  value: currency.code,
                                  child: Text(
                                    '${currency.code} - ${currency.symbol} ${currency.name}',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          selectedItemBuilder: (context) => Currency.supportedCurrencies
                              .map(
                                (currency) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    currency.code,
                                    style: _infoContentStyle,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCurrency = value;
                              _markDirty();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildBudgetField(loc),
                      ),
                    ],
                  ),
                ];
                final rightColumn = [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDropdownTile(
                          label: loc.createPlanVisibilityLabel,
                    value: _selectedVisibility,
                    items: [
                      DropdownMenuItem(
                        value: 'private',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.createPlanVisibilityPrivateShort,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.createPlanVisibilityPrivate,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'public',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.createPlanVisibilityPublicShort,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.createPlanVisibilityPublic,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    selectedItemBuilder: (context) => [
                      loc.createPlanVisibilityPrivateShort,
                      loc.createPlanVisibilityPublicShort,
                    ]
                        .map(
                          (short) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              short,
                              style: _infoContentStyle,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVisibility = value;
                        _markDirty();
                      });
                    },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildTimezoneTile(loc),
                      ),
                    ],
                  ),
                ];
                if (useTwoColumns) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: leftColumn,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: rightColumn,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...leftColumn,
                    const SizedBox(height: 16),
                    ...rightColumn,
                  ],
                );
              },
            ),
          ] else ...[
            Text(
              loc.planDetailsMetaTitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildReadOnlyTile('UNP ID', currentPlan.unpId),
                if (currentPlan.id != null)
                  _buildReadOnlyTile('ID interno', currentPlan.id!),
                _buildReadOnlyTile('Creado', _formatDate(currentPlan.createdAt)),
              ],
            ),
          ],
          if (showCountdown) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorScheme.color2.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DaysRemainingIndicator(
                plan: currentPlan,
                fontSize: 14,
                compact: false,
                showIcon: true,
                showStartingSoonBadge: true,
              ),
            ),
          ],
        ],
    );
    // Misma estructura en web y móvil: fechas, moneda, presupuesto, visibilidad, zona horaria sin card extra.
    return child;
  }

  Widget _buildReadOnlyTile(String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            value,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 13,
              color: AppColorScheme.color4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneTile(AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final commonTimezones = TimezoneService.getCommonTimezones().toList();
    final fallbackTimezone = TimezoneService.getSystemTimezone();
    final availableTimezones = commonTimezones.isNotEmpty ? commonTimezones : [fallbackTimezone];
    final selected = _selectedTimezone ?? currentPlan.timezone ?? fallbackTimezone;
    final safeSelectedTimezone = availableTimezones.contains(selected) ? selected : availableTimezones.first;

    return Container(
      decoration: BoxDecoration(
            color: Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: safeSelectedTimezone,
        isExpanded: true,
        style: _infoContentStyle,
        decoration: InputDecoration(
          labelText: loc.planTimezoneLabel,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
        ),
        dropdownColor: Colors.grey.shade800,
        items: availableTimezones
            .map(
              (tz) => DropdownMenuItem<String>(
                value: tz,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        TimezoneService.getTimezoneDisplayName(tz),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      TimezoneService.getUtcOffsetFormatted(tz),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        selectedItemBuilder: (context) => availableTimezones
            .map(
              (tz) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  TimezoneService.getTimezoneDisplayName(tz),
                  overflow: TextOverflow.ellipsis,
                  style: _infoContentStyle,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _selectedTimezone = value;
            _markDirty();
          });
        },
      ),
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String> onChanged,
    DropdownButtonBuilder? selectedItemBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
            color: Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        style: _infoContentStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
        ),
        dropdownColor: Colors.grey.shade800,
        items: items,
        selectedItemBuilder: selectedItemBuilder,
        onChanged: (selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
      ),
    );
  }

  Widget _buildBudgetField(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
            color: Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: TextFormField(
        controller: _budgetController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: _infoContentStyle,
        decoration: InputDecoration(
          labelText: (_budget == null && _budgetController.text.trim().isEmpty)
              ? loc.planBudgetLabelShort
              : loc.planDetailsBudgetLabel,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
          suffixText: _selectedCurrency,
        ),
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
            _budget = trimmed.isEmpty ? null : double.tryParse(sanitized);
          });
          _markDirty();
        },
      ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
            color: Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
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
            suffixIcon: Icon(Icons.edit_calendar, color: Colors.grey.shade400),
          ),
          child: Text(
            _formatDate(value),
            style: _infoContentStyle,
          ),
        ),
      ),
    );
  }

  /// Aviso solo lectura: estándar UIShowcase — fondo oscuro, borde y texto naranja (contraste en tema oscuro).
  Widget _buildReadOnlyWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade700),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade300,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              PlanStatePermissions.getBlockedReason('view', currentPlan) ??
                  'Este plan tiene restricciones de edición según su estado.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.orange.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Transiciones de estado permitidas para el plan actual (solo para organizador).
  List<Map<String, dynamic>> _getAvailableStateTransitions() {
    final currentState = currentPlan.state ?? 'planificando';
    if (currentState == 'finalizado' || currentState == 'cancelado') return [];
    final List<Map<String, dynamic>> list = [];
    switch (currentState) {
      case 'planificando':
        list.add({'state': 'confirmado', 'label': 'Confirmar Plan', 'icon': Icons.check_circle_outline});
        list.add({'state': 'cancelado', 'label': 'Cancelar Plan', 'icon': Icons.cancel_outlined});
        break;
      case 'confirmado':
        list.add({'state': 'en_curso', 'label': 'Marcar como En Curso', 'icon': Icons.play_circle_outline});
        list.add({'state': 'planificando', 'label': 'Volver a Planificación', 'icon': Icons.undo});
        list.add({'state': 'cancelado', 'label': 'Cancelar Plan', 'icon': Icons.cancel_outlined});
        break;
      case 'en_curso':
        list.add({'state': 'finalizado', 'label': 'Finalizar Plan', 'icon': Icons.check_circle});
        break;
    }
    return list;
  }

  Future<void> _changePlanState(String newState) async {
    // VALID-1, VALID-2: Ejecutar validaciones adicionales antes de confirmar
    if (newState == 'confirmado' && currentPlan.id != null) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        // Obtener eventos y participantes
        final eventService = ref.read(eventServiceProvider);
      final participantsAsync = ref.read(planRealParticipantsProvider(currentPlan.id!));
        
        final events = await eventService
            .getEventsByPlanId(currentPlan.id!, currentUser.id)
            .first
            .timeout(const Duration(seconds: 10));
        
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
    final confirmed = await showStateTransitionDialog(
      context: context,
      plan: currentPlan,
      newState: newState,
    );

    if (!confirmed || currentPlan.id == null) return;

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        _showSnackBarError('Error: Usuario no autenticado');
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
          _showSnackBarSuccess('Estado del plan actualizado a: ${PlanStateService.getStateDisplayInfo(newState)['label']}');
        }
      } else if (mounted) {
        _showSnackBarError('Error al cambiar el estado del plan');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBarError('Error: ${e.toString()}');
      }
    }
  }

  /// Botón "Salir del plan" para participantes (no organizador). Elimina su participación.
  Widget _buildLeavePlanButton() {
    final currentUser = ref.watch(currentUserProvider);
    if (currentPlan.id == null || currentUser == null) return const SizedBox.shrink();
    final isOwner = currentUser.id == currentPlan.userId;
    if (isOwner) return const SizedBox.shrink();

    final participantsAsync = ref.watch(planParticipantsProvider(currentPlan.id!));
    final isParticipant = participantsAsync.maybeWhen(
      data: (list) => list.any((p) => p.userId == currentUser.id),
      orElse: () => false,
    );
    if (!isParticipant) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBackgroundStart,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salir del plan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dejarás de ser participante y no verás los eventos ni el chat de este plan.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLeavePlanConfirmation(context),
              icon: Icon(Icons.exit_to_app, size: 18, color: Colors.red.shade700),
              label: Text('Salir del plan', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red.shade700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade400, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLeavePlanConfirmation(BuildContext context) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || currentPlan.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: AppTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade800,
          title: Text(
            'Salir del plan',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Text(
            '¿Estás seguro de que quieres salir de "${currentPlan.name}"? Dejarás de ver eventos y participantes.',
            style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.grey.shade400)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Salir', style: GoogleFonts.poppins(color: Colors.orange.shade300)),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final participationService = ref.read(planParticipationServiceProvider);
      final success = await participationService.removeParticipation(currentPlan.id!, currentUser.id);
      if (!context.mounted) return;
      if (success) {
        ref.read(planParticipationNotifierProvider(currentPlan.id!).notifier).reload();
        widget.onPlanDeleted?.call();
        _showSnackBarSuccess('Has salido del plan');
      } else {
        _showSnackBarError('No se pudo salir del plan');
      }
    } catch (e) {
      LoggerService.error('Error leaving plan', context: 'PlanDataScreen', error: e);
      if (context.mounted) {
        _showSnackBarError('Error al salir del plan: $e');
      }
    }
  }

  Widget _buildDeleteButton() {
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.id == currentPlan.userId;
    if (!isOwner) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade700, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zona de Peligro',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.red.shade200,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Eliminar este plan eliminará todos los eventos asociados y no se puede deshacer.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.red.shade200,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete, size: 18),
              label: Text('Eliminar Plan', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatUserHandle(UserModel? user) {
    if (user == null) return '';
    final username = user.username?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return '';
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

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DeletePlanDialog(
        loc: loc,
        onDelete: _deletePlan,
      ),
    );

    if (confirmed == true) {
      widget.onPlanDeleted?.call();
    }
  }

  Future<bool> _deletePlan(String password) async {
    if (currentPlan.id == null) return false;

    try {
      final loc = AppLocalizations.of(context)!;
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
      LoggerService.error('Error deleting plan', context: 'PLAN_DATA_SCREEN', error: e);
      if (!context.mounted) return false;
      final loc = AppLocalizations.of(context)!;
      _showSnackBarError(loc.planDeleteError);
      return false;
    }
  }
}

// Widget separado para el diálogo de eliminación que maneja su propio controlador
class _DeletePlanDialog extends StatefulWidget {
  final AppLocalizations loc;
  final Future<bool> Function(String password) onDelete;

  const _DeletePlanDialog({
    required this.loc,
    required this.onDelete,
  });

  @override
  State<_DeletePlanDialog> createState() => _DeletePlanDialogState();
}

class _DeletePlanDialogState extends State<_DeletePlanDialog> {
  late TextEditingController _passwordController;
  bool _isDeleting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.loc.planDeleteDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.loc.planDeleteDialogMessage,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            enabled: !_isDeleting,
            decoration: InputDecoration(
              labelText: widget.loc.planDeleteDialogPasswordLabel,
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(false),
          child: Text(widget.loc.cancelChanges),
        ),
        FilledButton(
          onPressed: _isDeleting
              ? null
              : () async {
                  final password = _passwordController.text.trim();
                  if (password.isEmpty) {
                    setState(() {
                      _errorText = widget.loc.planDeleteDialogPasswordRequired;
                    });
                    return;
                  }
                  setState(() {
                    _isDeleting = true;
                    _errorText = null;
                  });
                  final success = await widget.onDelete(password);
                  if (!mounted) return;
                  if (success) {
                    Navigator.of(context).pop(true);
                  } else {
                    setState(() {
                      _isDeleting = false;
                      _errorText = widget.loc.planDeleteDialogAuthError;
                    });
                  }
                },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.loc.planDeleteDialogConfirm),
        ),
      ],
    );
  }
}

// Método _deletePlan debe estar en _PlanDataScreenState
extension _PlanDataScreenStateExtension on _PlanDataScreenState {
  Future<bool> _deletePlan(String password) async {
    if (currentPlan.id == null) return false;

    try {
      final loc = AppLocalizations.of(context)!;
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
      if (context.mounted) {
        _showSnackBarError(_mapDeleteErrorMessage(e.toString().replaceFirst('Exception: ', ''), AppLocalizations.of(context)!));
      }
      return false;
    }
  }

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

  String? _resolveCurrentUserRoleLabel(
    UserModel? currentUser,
    AsyncValue<List<PlanParticipation>> participantsAsync,
    AppLocalizations loc,
  ) {
    if (currentUser == null) return null;
    if (currentPlan.userId == currentUser.id) {
      return loc.planRoleOrganizer;
    }

    final role = participantsAsync.maybeWhen<String?>(
      data: (participants) {
        for (final participation in participants) {
          if (participation.userId == currentUser.id) {
            return participation.role;
          }
        }
        return null;
      },
      orElse: () => null,
    );

    return _mapRoleToText(role, loc);
  }

  String _mapRoleToText(String? role, AppLocalizations loc) {
    switch (role) {
      case 'organizer':
        return loc.planRoleOrganizer;
      case 'participant':
        return loc.planRoleParticipant;
      case 'observer':
        return loc.planRoleObserver;
      default:
        return loc.planRoleUnknown;
    }
  }

  Widget _buildPlanImageSection({bool isCompact = false}) {
    final currentUser = ref.watch(currentUserProvider);
    final showLeaveButton = currentUser != null && currentPlan.userId != currentUser.id;
    final isOwner = currentUser?.id == currentPlan.userId;
    final stateTransitions = _getAvailableStateTransitions();
    final showStateMenu = isOwner && stateTransitions.isNotEmpty;

    Widget buildRightColumn() {
      final column = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PlanStateBadge(plan: currentPlan, onColoredBackground: true),
          if (showStateMenu) ...[
            const SizedBox(height: 10),
            PopupMenuButton<String>(
              tooltip: 'Cambiar estado del plan',
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.grey.shade800,
              onSelected: (newState) => _changePlanState(newState),
              itemBuilder: (context) => stateTransitions
                  .map(
                    (t) => PopupMenuItem<String>(
                      value: t['state'] as String,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t['icon'] as IconData, size: 20, color: AppColorScheme.color2),
                          const SizedBox(width: 12),
                          Text(
                            t['label'] as String,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: isCompact
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.sync_alt, color: AppColorScheme.color2, size: 28),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sync_alt, size: 18, color: AppColorScheme.color2),
                          const SizedBox(width: 6),
                          Text(
                            'Cambiar estado',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColorScheme.color2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: AppColorScheme.color2, size: 22),
                        ],
                      ),
                    ),
            ),
          ],
          if (showLeaveButton) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _showLeavePlanConfirmation(context),
              icon: Icon(Icons.exit_to_app, size: 18, color: Colors.orange.shade300),
              label: Text(
                'Salir del plan',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade300,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ],
      );
      // En compact (iOS/móvil) dar ancho mínimo a la columna derecha para que el menú de estado no se pise
      if (isCompact) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 80),
          child: column,
        );
      }
      return column;
    }

    // Misma estructura en móvil y web: una sola card, foto a la izquierda, estado + Salir del plan a la derecha.
    final double avatarSize = isCompact ? 88.0 : 140.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardBackgroundStart, _cardBackgroundEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 6), spreadRadius: 0),
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 2), spreadRadius: -4),
        ],
      ),
      child: Row(
        children: [
          _buildPlanAvatar(avatarSize),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: buildRightColumn(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSummarySection(AppLocalizations loc, int participantsCount, String? roleLabel, String userHandle, {bool isCompact = false}) {
    // Estilo tipo form de evento: sin recuadro común, campos con borde sutil
    final inputDecoration = (String label) => InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
      contentPadding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 18, vertical: isCompact ? 12 : 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColorScheme.color2, width: 2),
      ),
      filled: true,
      fillColor: _inputBackground,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.poppins(fontSize: isCompact ? 14 : 15, color: _textPrimary, letterSpacing: 0.1),
          decoration: inputDecoration(loc.createPlanNameLabel),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => _markDirty(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return loc.createPlanNameRequiredError;
            return null;
          },
        ),
        SizedBox(height: isCompact ? 12 : 16),
        TextFormField(
          controller: _descriptionController,
          style: GoogleFonts.poppins(fontSize: isCompact ? 14 : 15, color: _textPrimary, letterSpacing: 0.1),
          decoration: inputDecoration(loc.createPlanDescriptionLabel),
          minLines: 2,
          maxLines: 4,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );

    // Misma estructura en web y móvil: nombre y descripción sin card extra (paridad con Info del plan móvil).
    return content;
  }

  Widget _buildPlanImage(double height) {
    final imageUrl = currentPlan.imageUrl;

    Widget buildImage() {
      if (_selectedImageBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            _selectedImageBytes!,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
          ),
        );
      }
      if (imageUrl != null && ImageService.isValidImageUrl(imageUrl)) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: AppColorScheme.color2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => _buildImageFallback(height),
          ),
        );
      }
      return _buildImageFallback(height);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // Sin bordes
          ),
          child: buildImage(),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _isUploadingImage ? null : _pickImage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColorScheme.color2,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _isUploadingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.photo_camera, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageFallback(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColorScheme.color2.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.image_outlined,
        color: AppColorScheme.color2.withOpacity(0.5),
        size: 48,
      ),
    );
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
                color: AppColorScheme.color2.withOpacity(0.1),
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
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: buildImage(),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: GestureDetector(
            onTap: _isUploadingImage ? null : _pickImage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColorScheme.color2,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _isUploadingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.photo_camera, color: Colors.white, size: 18),
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
        color: AppColorScheme.color2.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.image_outlined,
        color: AppColorScheme.color2.withOpacity(0.5),
        size: size * 0.4,
      ),
    );
  }

  Widget _buildAnnouncementsSection({bool isCompact = false}) {
    if (currentPlan.id == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardBackgroundStart,
            _cardBackgroundEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // T231: Apartado Avisos — decisión mantener/simplificar/quitar: docs/ux/plan_info_aviso_t231.md
          // Header con título y botón
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.planDetailsAnnouncementsTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    HelpIconButton(
                      helpId: HelpContextIds.planDetailsAviso,
                      contextLabel: AppLocalizations.of(context)!.planDetailsAnnouncementsTitle,
                      defaultBody: AppLocalizations.of(context)!.planDetailsAnnouncementsHelp,
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColorScheme.color3,
                        AppColorScheme.color3.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorScheme.color3.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AnnouncementDialog(planId: currentPlan.id!),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      'Publicar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Timeline de avisos (compact en iOS: menos altura por ítem, fondo oscuro)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 420),
            child: AnnouncementTimeline(
              planId: currentPlan.id!,
              compact: isCompact,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImageService.pickImageFromGallery();
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImage = image;
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

      final uploadedImageUrl = await ImageService.uploadPlanImage(image, currentPlan.id!);
      final updatedPlan = currentPlan.copyWith(imageUrl: uploadedImageUrl);
      final planService = ref.read(planServiceProvider);
      final success = await planService.updatePlan(updatedPlan);

      if (!success) {
        throw Exception('Error al actualizar el plan en la base de datos');
      }

      if (mounted) {
        setState(() {
          currentPlan = updatedPlan;
          _selectedImage = null;
          _selectedImageBytes = null;
        });
        _showSnackBarSuccess('Imagen actualizada correctamente');
      }
    } catch (e) {
      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
      if (mounted) {
        _showSnackBarError('Error al guardar la imagen: $message');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _selectedImage = null;
          _selectedImageBytes = null;
        });
      }
    }
  }
}