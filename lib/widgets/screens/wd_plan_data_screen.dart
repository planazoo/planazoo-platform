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
import 'package:unp_calendario/widgets/plan/plan_summary_button.dart';
import 'package:unp_calendario/shared/models/currency.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';

class PlanDataScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onPlanDeleted;
  final VoidCallback? onManageParticipants;
  final bool showAppBar;

  const PlanDataScreen({
    super.key,
    required this.plan,
    this.onPlanDeleted,
    this.onManageParticipants,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.planDetailsSaveSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.planDetailsSaveError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
    AsyncValue<List<PlanParticipation>> participantsAsync,
  ) {
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
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                    ],
                  ),
                  Chip(
                    label: Text(
                      '${participants.length}',
                      style: AppTypography.bodyStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColorScheme.color2,
                      ),
                    ),
                    backgroundColor: AppColorScheme.color2.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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

    Widget buildHeader() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            if (_hasUnsavedChanges) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  loc.planDetailsUnsavedChanges,
                  style: AppTypography.bodyStyle.copyWith(
                    fontSize: 12,
                    color: Colors.orange.shade200,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
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
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: Colors.orange.shade300),
                  foregroundColor: Colors.orange.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(loc.cancelChanges, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _isSavingPlan || PlanStatePermissions.isReadOnly(currentPlan) ? null : _savePlanDetails,
                icon: _isSavingPlan
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(loc.saveChanges, style: const TextStyle(fontSize: 12)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
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
                          _buildPlanImageSection(),
                          const SizedBox(height: cardSpacing),
                          _buildPlanSummarySection(loc, participantsCount, currentRoleLabel, currentUserHandle),
                          const SizedBox(height: cardSpacing),
                          _buildStateManagementSection(loc),
                          const SizedBox(height: cardSpacing),
                          _buildInfoSection(loc, showBaseInfo: true),
                          const SizedBox(height: cardSpacing),
                          _buildParticipantsSection(loc, participantsAsync),
                          const SizedBox(height: cardSpacing),
                          _buildAnnouncementsSection(),
                          const SizedBox(height: cardSpacing),
                          _buildLeavePlanButton(),
                          const SizedBox(height: cardSpacing),
                          _buildDeleteButton(),
                          const SizedBox(height: cardSpacing),
                          _buildInfoSection(loc, showBaseInfo: false),
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

  Widget _buildInfoSection(AppLocalizations loc, {required bool showBaseInfo}) {
    final showCountdown = DaysRemainingUtils.shouldShowDaysRemaining(currentPlan);

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
          if (showBaseInfo) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    loc.planDetailsInfoTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (currentPlan.id != null)
                  PlanSummaryButton(
                    plan: currentPlan,
                    iconOnly: false,
                    foregroundColor: _textSecondary,
                  ),
              ],
            ),
            const SizedBox(height: 16),
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
                  _buildDropdownTile(
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
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
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
                  const SizedBox(height: 16),
                  _buildBudgetField(loc),
                ];
                final rightColumn = [
                  _buildDropdownTile(
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
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
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
                  const SizedBox(height: 16),
                  _buildTimezoneTile(loc),
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
      ),
    );
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
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: loc.planTimezoneLabel,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          helperText: loc.planTimezoneHelper,
          helperMaxLines: 2,
          helperStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade400,
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
                          fontSize: 13,
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
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
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
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
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
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: loc.planDetailsBudgetLabel,
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
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              PlanStatePermissions.getBlockedReason('view', currentPlan) ?? 
                  'Este plan tiene restricciones de edición según su estado.',
              style: AppTypography.bodyStyle.copyWith(
                fontSize: 13,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateManagementSection(AppLocalizations loc) {
    final currentUser = ref.read(currentUserProvider);
    final isOwner = currentUser?.id == currentPlan.userId;
    final currentState = currentPlan.state ?? 'borrador';
    // Solo mostrar controles si es el organizador y el plan no está finalizado o cancelado
    if (!isOwner || currentState == 'finalizado' || currentState == 'cancelado') {
      return const SizedBox.shrink();
    }

    // Determinar qué transiciones son válidas
    List<Map<String, dynamic>> availableTransitions = [];

    switch (currentState) {
      case 'borrador':
        availableTransitions.add({
          'state': 'planificando',
          'label': 'Iniciar Planificación',
          'icon': Icons.event_note,
        });
        break;
      case 'planificando':
        availableTransitions.add({
          'state': 'confirmado',
          'label': 'Confirmar Plan',
          'icon': Icons.check_circle_outline,
        });
        availableTransitions.add({
          'state': 'cancelado',
          'label': 'Cancelar Plan',
          'icon': Icons.cancel_outlined,
        });
        break;
      case 'confirmado':
        availableTransitions.add({
          'state': 'en_curso',
          'label': 'Marcar como En Curso',
          'icon': Icons.play_circle_outline,
        });
        availableTransitions.add({
          'state': 'planificando',
          'label': 'Volver a Planificación',
          'icon': Icons.undo,
        });
        availableTransitions.add({
          'state': 'cancelado',
          'label': 'Cancelar Plan',
          'icon': Icons.cancel_outlined,
        });
        break;
      case 'en_curso':
        availableTransitions.add({
          'state': 'finalizado',
          'label': 'Finalizar Plan',
          'icon': Icons.check_circle,
        });
        break;
    }

    if (availableTransitions.isEmpty) {
      return const SizedBox.shrink();
    }

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
            children: [
              Icon(Icons.sync_alt, color: AppColorScheme.color2),
              const SizedBox(width: 8),
              Text(
                loc.planDetailsStateTitle,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Estado actual: ${PlanStateService.getStateDisplayInfo(currentState)['label']}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: availableTransitions
                .map(
                  (transition) => OutlinedButton.icon(
                    onPressed: () => _changePlanState(transition['state'] as String),
                    icon: Icon(transition['icon'] as IconData, size: 16),
                    label: Text(
                      transition['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: AppColorScheme.color2.withOpacity(0.7),
                        width: 2,
                      ),
                      foregroundColor: AppColorScheme.color2,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no autenticado'),
            backgroundColor: Colors.red,
          ),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Estado del plan actualizado a: ${PlanStateService.getStateDisplayInfo(newState)['label']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar el estado del plan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
              icon: const Icon(Icons.exit_to_app, size: 18),
              label: const Text('Salir del plan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade300,
                side: BorderSide(color: Colors.orange.shade400),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Has salido del plan', style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo salir del plan', style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Error leaving plan', context: 'PlanDataScreen', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al salir del plan: $e', style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.red.shade700,
          ),
        );
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Zona de Peligro',
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 13,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Eliminar este plan eliminará todos los eventos asociados y no se puede deshacer.',
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Eliminar Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.planDeleteError),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.planDeleteSuccess(currentPlan.name)),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } catch (e) {
      LoggerService.error('Error deleting plan', context: 'PLAN_DATA_SCREEN', error: e);
      if (!context.mounted) return false;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.planDeleteError),
          backgroundColor: Colors.red,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.planDeleteError),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.planDeleteSuccess(currentPlan.name)),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mapDeleteErrorMessage(e.toString().replaceFirst('Exception: ', ''), AppLocalizations.of(context)!)),
            backgroundColor: Colors.red,
          ),
        );
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

  Widget _buildPlanImageSection() {
    const double imageHeight = 200;
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
      child: _buildPlanImage(imageHeight),
    );
  }

  Widget _buildPlanSummarySection(AppLocalizations loc, int participantsCount, String? roleLabel, String userHandle) {
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
          // R1: Campo nombre del plan
          Container(
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
              controller: _nameController,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
              decoration: InputDecoration(
                labelText: loc.createPlanNameLabel,
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (_) => _markDirty(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.createPlanNameRequiredError;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),
          // R2: Campo descripción
          Container(
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
              controller: _descriptionController,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
              decoration: InputDecoration(
                labelText: loc.createPlanDescriptionLabel,
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
              minLines: 2,
              maxLines: 4,
              onChanged: (_) => _markDirty(),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildAnnouncementsSection() {
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
                    Tooltip(
                      message: AppLocalizations.of(context)!.planDetailsAnnouncementsHelp,
                      child: Icon(
                        Icons.help_outline,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
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
          // Timeline de avisos
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 300),
            child: AnnouncementTimeline(
              planId: currentPlan.id!,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(validationError), backgroundColor: Colors.red),
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la imagen: $message'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
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