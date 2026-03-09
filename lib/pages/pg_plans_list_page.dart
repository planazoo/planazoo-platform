import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/image_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/widgets/screens/wd_plan_data_screen.dart';
import 'package:unp_calendario/pages/pg_plan_detail_page.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_search_widget.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_list_widget.dart';
import 'package:unp_calendario/pages/pg_profile_page.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/features/security/utils/sanitizer.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/widgets/notifications/wd_notification_badge.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';
import 'package:unp_calendario/widgets/plan/plan_summary_button.dart';
import 'package:unp_calendario/features/chat/presentation/providers/chat_providers.dart';
import 'package:unp_calendario/features/notifications/presentation/providers/notification_providers.dart';
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
  List<Plan> _allPlans = [];
  List<Plan> _filteredPlans = [];
  String _searchQuery = '';
  String _selectedFilter = 'todos'; // 'todos', 'estoy_in', 'pendientes', 'cerrados'
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unpIdController = TextEditingController();
  bool _isCreating = false;

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

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: Text(
            loc.appTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade800, // Color sólido, sin gradiente
            ),
          ),
          actions: [
            // Botón crear plan (arriba a la derecha)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _showCreatePlanDialog,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
            color: AppColorScheme.color2, // Color sólido, sin gradiente
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorScheme.color2.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '+',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
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
            // Botones de filtro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterButton('todos', loc.plansListFilterAll, isDarkMode),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterButton('estoy_in', loc.plansListFilterIn, isDarkMode),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterButton('pendientes', loc.plansListFilterPending, isDarkMode),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterButton('cerrados', loc.plansListFilterClosed, isDarkMode),
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
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.plansListNoPlansYet,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.plansListCreateFirstPlan,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
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
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.plansListNoPlansFound,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
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
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade500,
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade800,
                const Color(0xFF2C2C2C),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Notificaciones (icono naranja si hay no leídas)
                  const NotificationBadge(
                    iconColor: Colors.white,
                    iconSize: 28,
                  ),
                  const SizedBox(width: 8),
                  // Chat (icono relleno naranja si hay no leídos)
                  IconButton(
                    icon: Icon(
                      totalChatUnread > 0 ? Icons.chat_bubble : Icons.chat_bubble_outline,
                      size: 28,
                      color: totalChatUnread > 0 ? AppColorScheme.color3 : Colors.white,
                    ),
                    onPressed: () {
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
                  // Icono de perfil
                  IconButton(
                    icon: Icon(
                      Icons.person,
                      size: 28,
                      color: Colors.white,
                    ),
                    onPressed: () {
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

  Widget _buildFilterButton(String filterValue, String label, bool isDarkMode) {
    final isSelected = _selectedFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterValue;
        });
        _applyFilters();
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorScheme.color2,
                    AppColorScheme.color2.withOpacity(0.85),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade800,
          border: Border.all(
            color: AppColorScheme.color2.withOpacity(0.7),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColorScheme.color2.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.grey.shade400,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, Plan plan, bool isDarkMode) {
    final startDate = plan.startDate;
    final endDate = plan.endDate;
    final dateRange = '${DateFormatter.formatDate(startDate)} - ${DateFormatter.formatDate(endDate)}';

    final notifUnread = plan.id != null
        ? ref.watch(planUnreadCountProvider(plan.id)).valueOrNull ?? 0
        : 0;
    final chatUnread = plan.id != null
        ? ref.watch(unreadMessagesCountProvider(plan.id!)).valueOrNull ?? 0
        : 0;
    final iconColor = Colors.grey.shade400;
    final notifIconColor = notifUnread > 0 ? AppColorScheme.color3 : iconColor;
    final chatIconColor = chatUnread > 0 ? AppColorScheme.color3 : iconColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            const Color(0xFF2C2C2C),
          ],
        ),
        borderRadius: BorderRadius.zero,
        border: Border(
          top: BorderSide(color: Colors.grey.shade700.withOpacity(0.5), width: 1),
          bottom: BorderSide(color: Colors.grey.shade700.withOpacity(0.5), width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlanDetailPage(plan: plan),
              ),
            );
          },
          borderRadius: BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del plan (thumbnail)
                _buildPlanCardImage(plan),
                const SizedBox(width: 16),
                // Zona principal: nombre, descripción, fechas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (plan.description != null && plan.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          plan.description!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateRange,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Columna vertical estrecha: iconos resumen, notificaciones, chat
                if (plan.id != null) ...[
                  Container(
                    width: 1,
                    height: 44,
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    color: Colors.grey.shade600.withOpacity(0.5),
                  ),
                  SizedBox(
                    width: 40,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PlanSummaryButton(
                        plan: plan,
                        iconOnly: true,
                        foregroundColor: iconColor,
                        onShowInPanel: (_) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlanDetailPage(plan: plan, initialTab: 'mySummary'),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () {
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
                        child: _buildPlanCardBadgeIcon(
                          icon: notifUnread > 0 ? Icons.notifications : Icons.notifications_outlined,
                          color: notifIconColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlanDetailPage(plan: plan, initialTab: 'chat'),
                            ),
                          );
                        },
                        child: _buildPlanCardBadgeIcon(
                          icon: chatUnread > 0 ? Icons.chat_bubble : Icons.chat_bubble_outline,
                          color: chatIconColor,
                        ),
                      ),
                    ],
                  ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const double _cardBadgeIconSize = 20.0;
  static const double _planCardImageSize = 48.0;

  Widget _buildPlanCardImage(Plan plan) {
    if (plan.imageUrl != null && ImageService.isValidImageUrl(plan.imageUrl)) {
      return Container(
        width: _planCardImageSize,
        height: _planCardImageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColorScheme.color2.withOpacity(0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: plan.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColorScheme.color2.withOpacity(0.1),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildPlanCardPlaceholderImage(),
          ),
        ),
      );
    }
    return _buildPlanCardPlaceholderImage();
  }

  Widget _buildPlanCardPlaceholderImage() {
    return Container(
      width: _planCardImageSize,
      height: _planCardImageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorScheme.color2.withOpacity(0.3)),
        color: AppColorScheme.color2.withOpacity(0.1),
      ),
      child: Icon(
        Icons.image,
        color: AppColorScheme.color2.withOpacity(0.5),
        size: 24,
      ),
    );
  }

  Widget _buildPlanCardBadgeIcon({
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Icon(icon, size: _cardBadgeIconSize, color: color),
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
      final columnCount = endDate.difference(startDate).inDays + 1;

      final plan = Plan(
        name: sanitizedName,
        unpId: sanitizedUnpId,
        userId: currentUser.id,
        baseDate: startDate,
        startDate: startDate,
        endDate: endDate,
        columnCount: columnCount,
        description: null,
        state: 'borrador',
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
        backgroundColor: Colors.grey.shade800,
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
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: loc.createPlanNameHint,
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(Icons.edit, color: Colors.grey.shade400),
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
                    color: Colors.grey.shade400,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                loc.createPlanQuickIntro,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
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
              foregroundColor: Colors.grey.shade400,
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
                  color: AppColorScheme.color2.withOpacity(0.4),
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
