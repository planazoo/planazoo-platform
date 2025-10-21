import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/calendar_view_mode.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_filters.dart';
import 'package:unp_calendario/widgets/screens/calendar/calendar_track_reorder.dart';
import 'package:unp_calendario/widgets/screens/fullscreen_calendar_page.dart';
import 'package:unp_calendario/widgets/dialogs/manage_roles_dialog.dart';
import 'package:unp_calendario/shared/services/permission_service.dart';
import 'package:unp_calendario/shared/models/permission.dart';

/// Clase que maneja la construcción del AppBar del calendario
class CalendarAppBar {
  final Plan plan;
  final int currentDayGroup;
  final int visibleDays;
  final CalendarViewMode viewMode;
  final CalendarFilters calendarFilters;
  final CalendarTrackReorder calendarTrackReorder;
  
  CalendarAppBar({
    required this.plan,
    required this.currentDayGroup,
    required this.visibleDays,
    required this.viewMode,
    required this.calendarFilters,
    required this.calendarTrackReorder,
  });

  /// Construye el AppBar completo
  PreferredSizeWidget buildAppBar({
    required VoidCallback onPreviousDayGroup,
    required VoidCallback onNextDayGroup,
    required Function(int) onVisibleDaysChanged,
    required Function(CalendarViewMode) onFilterChanged,
    required VoidCallback onCustomFilter,
    required VoidCallback onReorderTracks,
    required VoidCallback onFullscreen,
    required Future<bool> Function() canManageRoles,
    required VoidCallback onManageRoles,
  }) {
    final startDay = currentDayGroup * visibleDays + 1;
    final endDay = startDay + visibleDays - 1;
    final totalDays = plan.durationInDays;
    
    return AppBar(
      toolbarHeight: 48.0,
      title: _buildTitle(startDay, endDay, totalDays, onPreviousDayGroup, onNextDayGroup),
      actions: _buildActions(
        onVisibleDaysChanged: onVisibleDaysChanged,
        canManageRoles: canManageRoles,
        onManageRoles: onManageRoles,
        onPersonalView: () => onFilterChanged(CalendarViewMode.personal),
        onFilterChanged: onFilterChanged,
        onCustomFilter: onCustomFilter,
        onReorderTracks: onReorderTracks,
        onFullscreen: onFullscreen,
      ),
      backgroundColor: AppColorScheme.color1,
      foregroundColor: Colors.white,
    );
  }

  /// Construye el título del AppBar con navegación
  Widget _buildTitle(int startDay, int endDay, int totalDays, VoidCallback onPrevious, VoidCallback onNext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentDayGroup > 0 ? onPrevious : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Días anteriores',
        ),
        Text(
          'Días $startDay-${startDay + visibleDays - 1} de $totalDays ($visibleDays visibles)',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        IconButton(
          onPressed: (startDay + visibleDays - 1) < totalDays ? onNext : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Días siguientes',
        ),
      ],
    );
  }

  /// Construye las acciones del AppBar
  List<Widget> _buildActions({
    required Function(int) onVisibleDaysChanged,
    required Future<bool> Function() canManageRoles,
    required VoidCallback onManageRoles,
    required VoidCallback onPersonalView,
    required Function(CalendarViewMode) onFilterChanged,
    required VoidCallback onCustomFilter,
    required VoidCallback onReorderTracks,
    required VoidCallback onFullscreen,
  }) {
    return [
      // Control de días visibles
      _buildVisibleDaysMenu(onVisibleDaysChanged),
      
      // Gestión de roles (solo para admins)
      FutureBuilder<bool>(
        future: canManageRoles(),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              tooltip: 'Gestión de Roles',
              onPressed: onManageRoles,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      
      // Acceso rápido a Mi Agenda
      IconButton(
        icon: const Icon(Icons.person, color: Colors.white),
        tooltip: 'Mi Agenda',
        onPressed: onPersonalView,
      ),
      
      // Selector de filtros de vista
      calendarFilters.buildFilterMenu(
        viewMode,
        onFilterChanged,
        onCustomFilter,
      ),
      
      // Botón para gestionar participantes
      calendarTrackReorder.buildParticipantManagementButton(onReorderTracks),
      
      // Botón de pantalla completa
      IconButton(
        icon: const Icon(Icons.fullscreen, color: Colors.white),
        tooltip: 'Pantalla completa',
        onPressed: onFullscreen,
      ),
    ];
  }

  /// Construye el menú de días visibles
  Widget _buildVisibleDaysMenu(Function(int) onVisibleDaysChanged) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.tune, color: Colors.white),
      tooltip: 'Ajustar días visibles',
      onSelected: onVisibleDaysChanged,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.calendar_view_day, size: 16),
              const SizedBox(width: 8),
              const Text('1 día'),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 3,
          child: Row(
            children: [
              Icon(Icons.calendar_view_week, size: 16),
              const SizedBox(width: 8),
              const Text('3 días'),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 7,
          child: Row(
            children: [
              Icon(Icons.calendar_view_month, size: 16),
              const SizedBox(width: 8),
              const Text('7 días'),
            ],
          ),
        ),
      ],
    );
  }
}
