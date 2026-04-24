import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/pages/pg_plan_detail_page.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_search_widget.dart';
import 'package:unp_calendario/widgets/plan/plan_calendar_view.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_card_widget.dart';
import 'package:unp_calendario/pages/pg_profile_page.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/features/security/utils/sanitizer.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
import 'package:unp_calendario/widgets/notifications/wd_notification_list_dialog.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/features/chat/presentation/providers/chat_providers.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_notifications_screen.dart';
import 'package:unp_calendario/widgets/dialogs/wd_plans_with_unread_chat_modal.dart';

/// Página de lista de planes para móviles (iOS/Android)
/// Incluye: barra superior con botón crear plan, búsqueda, filtros, lista y navegación inferior
class PlansListPage extends ConsumerStatefulWidget {
  const PlansListPage({super.key});

  @override
  ConsumerState<PlansListPage> createState() => _PlansListPageState();
}

class _PlansListPageState extends ConsumerState<PlansListPage> {
  static const Color _cPageBg = Color(0xFF111827);
  static const Color _cSurfaceBg = Color(0xFF1F2937);
  static const Color _cTextPrimary = Colors.white;
  static const Color _cTextSecondary = Colors.white70;
  static const Color _cTextTertiary = Colors.white60;
  static const double _aBorderStrong = 0.12;

  List<Plan> _allPlans = [];
  List<Plan> _filteredPlans = [];
  String _searchQuery = '';
  String _selectedFilter = 'todos'; // 'todos', 'estoy_in', 'pendientes', 'cerrados'
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unpIdController = TextEditingController();
  final bool _isCreating = false;
  /// Vista lista vs calendario mensual (paridad con web / lista puntos P8).
  bool _useCalendarView = false;

  @override
  void dispose() {
    _nameController.dispose();
    _unpIdController.dispose();
    super.dispose();
  }

  void _filterPlans(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Plan> filtered = List.from(_allPlans);

    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      final searchQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((plan) {
        final nameMatch = plan.name.toLowerCase().contains(searchQuery);
        final stateMatch = (plan.state ?? '').toLowerCase().contains(searchQuery);
        final startMatch = DateFormatter.formatDate(plan.startDate).toLowerCase().contains(searchQuery);
        final endMatch = DateFormatter.formatDate(plan.endDate).toLowerCase().contains(searchQuery);
        return nameMatch || stateMatch || startMatch || endMatch;
      }).toList();
    }

    // Aplicar filtro de estado (por ahora solo 'todos', los demás se implementarán después)
    if (_selectedFilter != 'todos') {
      // TODO: Implementar filtros específicos cuando tengamos la lógica de participación
      // filtered = filtered.where((plan) => ...).toList();
    }

    setState(() {
      _filteredPlans = filtered;
    });
  }

  void _onPlansLoaded(List<Plan> plans) {
    setState(() {
      _allPlans = plans;
      _filteredPlans = List.from(plans);
    });
    _applyFilters();
  }

  void _showCreatePlanDialog() {
    _nameController.clear();
    _unpIdController.clear();
    _generateAutoUnpId();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _CreatePlanModal(
          nameController: _nameController,
          unpIdController: _unpIdController,
          isCreating: _isCreating,
          onPlanCreated: (plan) {
            // El plan se añadirá automáticamente al stream
            Navigator.of(context).pop();
            if (plan.id != null) {
              // Navegar al plan recién creado
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlanDetailPage(plan: plan),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _generateAutoUnpId() async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final planService = ref.read(planServiceProvider);
        final generatedId = await planService.generateUniqueUnpId(
          currentUser.id,
          username: currentUser.username,
        );
        if (mounted) {
          setState(() {
            _unpIdController.text = generatedId;
          });
        }
      }
    } catch (e) {
      LoggerService.error('Error generating auto UNP ID', context: 'CREATE_PLAN_MODAL', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final plansAsync = ref.watch(plansStreamProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Actualizar planes cuando cambian
    plansAsync.whenData(_onPlansLoaded);

    int totalChatUnread = 0;
    for (final p in _allPlans) {
      if (p.id != null) {
        totalChatUnread += ref.watch(unreadMessagesCountProvider(p.id!)).valueOrNull ?? 0;
      }
    }
    final unreadNotifications = ref.watch(globalUnreadCountProvider).valueOrNull ?? 0;

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: _cPageBg,
        appBar: AppBar(
          title: Text(
            loc.appTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: _cTextPrimary,
            ),
          ),
          backgroundColor: _cPageBg,
          foregroundColor: _cTextPrimary,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: _cPageBg,
            ),
          ),
          actions: [
            // Botón crear plan (arriba a la derecha)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 40,
                height: 40,
                child: FilledButton(
                  onPressed: _showCreatePlanDialog,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorScheme.color2,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: Text(
                    '+',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: PlanSearchWidget(
                onSearchChanged: _filterPlans,
              ),
            ),
            // Una fila: [Filtros ▼] | [Lista | Calendario]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: PopupMenuButton<String>(
                      tooltip: loc.plansListFiltersButton,
                      initialValue: _selectedFilter,
                      color: _cSurfaceBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _cTextPrimary.withValues(alpha: _aBorderStrong),
                          width: 1,
                        ),
                      ),
                      onSelected: (value) {
                        setState(() => _selectedFilter = value);
                        _applyFilters();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'todos',
                          child: _filterMenuRow(loc.plansListFilterAll, 'todos'),
                        ),
                        PopupMenuItem<String>(
                          value: 'estoy_in',
                          child: _filterMenuRow(loc.plansListFilterIn, 'estoy_in'),
                        ),
                        PopupMenuItem<String>(
                          value: 'pendientes',
                          child: _filterMenuRow(loc.plansListFilterPending, 'pendientes'),
                        ),
                        PopupMenuItem<String>(
                          value: 'cerrados',
                          child: _filterMenuRow(loc.plansListFilterClosed, 'cerrados'),
                        ),
                      ],
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _cSurfaceBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _cTextPrimary.withValues(alpha: _aBorderStrong),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.filter_list, color: AppColorScheme.color2, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    loc.plansListFiltersButton,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: _cTextTertiary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _filterLabelForSelected(loc),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: _cTextPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: _cTextSecondary, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: loc.plansListViewModeTooltip,
                    child: ToggleButtons(
                      isSelected: [!_useCalendarView, _useCalendarView],
                      onPressed: (i) => setState(() => _useCalendarView = i == 1),
                      borderRadius: BorderRadius.circular(12),
                      borderColor: _cTextPrimary.withValues(alpha: _aBorderStrong),
                      selectedBorderColor: AppColorScheme.color2,
                      selectedColor: Colors.white,
                      fillColor: AppColorScheme.color2,
                      color: _cTextSecondary,
                      constraints: const BoxConstraints(minHeight: 44, minWidth: 48),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Icon(Icons.view_list, size: 22),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Icon(Icons.calendar_month, size: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Lista de planes
            Expanded(
              child: plansAsync.when(
                data: (plans) {
                  if (_filteredPlans.isEmpty && _allPlans.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: _cTextTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.plansListNoPlansYet,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: _cTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.plansListCreateFirstPlan,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _cTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_filteredPlans.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: _cTextTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.plansListNoPlansFound,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: _cTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_useCalendarView) {
                    return PlanCalendarView(
                      plans: _filteredPlans,
                      baseDate: DateTime.now(),
                      onPlanSelected: (plan) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PlanDetailPage(plan: plan),
                          ),
                        );
                      },
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _filteredPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _filteredPlans[index];
                      return _buildPlanCard(context, ref, plan, isDarkMode);
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: AppColorScheme.color2,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.plansListLoadError,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _cTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _cTextTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Barra inferior con acceso al perfil
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: _cPageBg,
            border: Border(
              top: BorderSide(color: _cTextPrimary.withValues(alpha: _aBorderStrong)),
            ),
          ),
          child: SafeArea(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Notificaciones (icono naranja si hay no leídas)
                  _buildBottomNotificationNavIcon(
                    context: context,
                    unreadCount: unreadNotifications,
                  ),
                  const SizedBox(width: 8),
                  // Chat (icono relleno naranja si hay no leídos)
                  _buildBottomNavIcon(
                    icon: totalChatUnread > 0
                        ? Icons.chat_bubble
                        : Icons.chat_bubble_outline,
                    isActive: totalChatUnread > 0,
                    onTap: () {
                      showPlansWithUnreadChatModal(
                        context: context,
                        plans: _allPlans,
                        onPlanSelected: (plan) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlanDetailPage(plan: plan, initialTab: 'chat'),
                            ),
                          );
                        },
                      );
                    },
                    tooltip: loc.dashboardTabChat,
                  ),
                  const SizedBox(width: 8),
                  _buildBottomNavIcon(
                    icon: Icons.help_outline,
                    onTap: () {
                      Navigator.of(context).pushNamed('/help');
                    },
                    tooltip: loc.helpManualOpenFromLogin,
                  ),
                  const SizedBox(width: 8),
                  // Hub temporal para revisar demos UI
                  _buildBottomNavIcon(
                    icon: Icons.design_services_outlined,
                    onTap: () {
                      Navigator.of(context).pushNamed('/demo/ui-review');
                    },
                    tooltip: 'UI Review Hub',
                  ),
                  const SizedBox(width: 8),
                  // Icono de perfil
                  _buildBottomNavIcon(
                    icon: Icons.person,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    tooltip: loc.plansListProfileTooltip,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _filterLabelForSelected(AppLocalizations loc) {
    switch (_selectedFilter) {
      case 'estoy_in':
        return loc.plansListFilterIn;
      case 'pendientes':
        return loc.plansListFilterPending;
      case 'cerrados':
        return loc.plansListFilterClosed;
      case 'todos':
      default:
        return loc.plansListFilterAll;
    }
  }

  Widget _buildBottomNavIcon({
    required VoidCallback onTap,
    required IconData icon,
    required String tooltip,
    bool isActive = false,
    Color? iconColorOverride,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppColorScheme.color2 : _cSurfaceBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppColorScheme.color2
                  : _cTextPrimary.withValues(alpha: _aBorderStrong),
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: iconColorOverride ?? _cTextPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNotificationNavIcon({
    required BuildContext context,
    required int unreadCount,
  }) {
    final hasUnread = unreadCount > 0;
    return Tooltip(
      message: AppLocalizations.of(context)!.notificationsTitle,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const NotificationListDialog(),
          );
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: hasUnread ? AppColorScheme.color2 : _cSurfaceBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasUnread
                  ? AppColorScheme.color2
                  : _cTextPrimary.withValues(alpha: _aBorderStrong),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: _cTextPrimary,
                ),
              ),
              if (hasUnread)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColorScheme.color3,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _cPageBg, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterMenuRow(String label, String filterValue) {
    final selected = _selectedFilter == filterValue;
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: selected
              ? Icon(Icons.check, size: 20, color: AppColorScheme.color2)
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _cTextPrimary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, Plan plan, bool isDarkMode) {
    return PlanCardWidget(
      plan: plan,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlanDetailPage(plan: plan),
          ),
        );
      },
      onNotificationsTap: (_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(plan.name),
                backgroundColor: AppColorScheme.color2,
              ),
              body: WdPlanNotificationsScreen(plan: plan),
            ),
          ),
        );
      },
      onChatTap: (_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlanDetailPage(plan: plan, initialTab: 'chat'),
          ),
        );
      },
    );
  }

}

// Modal para crear plan (reutilizado de DashboardPage)
class _CreatePlanModal extends ConsumerStatefulWidget {
  final TextEditingController nameController;
  final TextEditingController unpIdController;
  final bool isCreating;
  final Function(Plan) onPlanCreated;

  const _CreatePlanModal({
    required this.nameController,
    required this.unpIdController,
    required this.isCreating,
    required this.onPlanCreated,
  });

  @override
  ConsumerState<_CreatePlanModal> createState() => _CreatePlanModalState();
}

class _CreatePlanModalState extends ConsumerState<_CreatePlanModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _isCreating = widget.isCreating;
  }

  Future<void> _createPlan() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    final loc = AppLocalizations.of(context)!;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.createPlanAuthError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final now = DateTime.now();
      final sanitizedName = Sanitizer.sanitizePlainText(widget.nameController.text, maxLength: 100);
      final sanitizedUnpId = Sanitizer.sanitizePlainText(widget.unpIdController.text, maxLength: 40);
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(const Duration(days: 6));
      final columnCount = Plan.calendarDaysInclusive(startDate, endDate);

      final plan = Plan(
        name: sanitizedName,
        unpId: sanitizedUnpId,
        userId: currentUser.id,
        baseDate: startDate,
        startDate: startDate,
        endDate: endDate,
        columnCount: columnCount,
        description: null,
        state: 'planificando',
        visibility: 'private',
        timezone: TimezoneService.getSystemTimezone(),
        currency: 'EUR',
        participants: 0,
        createdAt: now,
        updatedAt: now,
        savedAt: now,
      );

      final planService = ref.read(planServiceProvider);
      final planId = await planService.createPlan(plan);

      if (planId == null) {
        throw Exception('plan-create-error');
      }

      final createdPlan = await planService.getPlanById(planId);

      if (!mounted) return;

      Navigator.of(context).pop();
      if (createdPlan != null) {
        widget.onPlanCreated(createdPlan);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.createPlanGenericError),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Theme(
      data: AppTheme.darkTheme,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text(
          loc.createPlan,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.1,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937), // Color sólido, sin gradiente
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12).withValues(alpha: 0.5),
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
                  ),
                  child: TextFormField(
                    controller: widget.nameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: loc.createPlanNameLabel,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: loc.createPlanNameHint,
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                      prefixIcon: Icon(Icons.edit, color: Colors.white70),
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
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 18,
                      ),
                    ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.createPlanNameRequiredError;
                  }
                  if (value.trim().length < 3) {
                    return loc.createPlanNameTooShortError;
                  }
                  if (value.trim().length > 100) {
                    return loc.createPlanNameTooLongError;
                  }
                  return null;
                },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.unpIdController.text.isEmpty
                      ? loc.createPlanUnpIdLoading
                      : loc.createPlanUnpIdHeader(widget.unpIdController.text),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                loc.createPlanQuickIntro,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
              ),
            ],
          ),
        ),
      ),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
            ),
            child: Text(
              loc.cancel,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
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
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isCreating ? null : _createPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      loc.create,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
