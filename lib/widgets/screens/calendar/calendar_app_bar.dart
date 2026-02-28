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
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// Clase que maneja la construcción del AppBar del calendario
class CalendarAppBar {
  final Plan plan;
  final int currentDayGroup;
  final int visibleDays;
  final CalendarViewMode viewMode;
  final CalendarFilters calendarFilters;
  final CalendarTrackReorder calendarTrackReorder;
  final List<PlanParticipation> participations;
  final String? selectedUserId;
  final String? currentTimezone;
  
  CalendarAppBar({
    required this.plan,
    required this.currentDayGroup,
    required this.visibleDays,
    required this.viewMode,
    required this.calendarFilters,
    required this.calendarTrackReorder,
    required this.participations,
    this.selectedUserId,
    this.currentTimezone,
  });

  /// Construye el AppBar completo
  /// [eventDraftFilter] y [onEventDraftFilterChanged]: T242 filtro eventos todos/borrador.
  PreferredSizeWidget buildAppBar(
    BuildContext context, {
    required VoidCallback onPreviousDayGroup,
    required VoidCallback onNextDayGroup,
    required Function(int) onVisibleDaysChanged,
    required Function(CalendarViewMode) onFilterChanged,
    required VoidCallback onCustomFilter,
    required VoidCallback onReorderTracks,
    required VoidCallback onFullscreen,
    required Future<bool> Function() canManageRoles,
    required VoidCallback onManageRoles,
    required Function(String) onUserSelected,
    VoidCallback? onShowSummary,
    String? summaryButtonLabel,
    String eventDraftFilter = 'all',
    void Function(String)? onEventDraftFilterChanged,
  }) {
    final startDay = currentDayGroup * visibleDays + 1;
    final endDay = startDay + visibleDays - 1;
    final totalDays = plan.durationInDays;

    return AppBar(
      toolbarHeight: 48.0,
      title: _buildTitle(context, startDay, endDay, totalDays, onPreviousDayGroup, onNextDayGroup),
      actions: _buildActions(
        context,
        onVisibleDaysChanged: onVisibleDaysChanged,
        canManageRoles: canManageRoles,
        onManageRoles: onManageRoles,
        onPersonalView: () => onFilterChanged(CalendarViewMode.personal),
        onFilterChanged: onFilterChanged,
        onCustomFilter: onCustomFilter,
        onReorderTracks: onReorderTracks,
        onFullscreen: onFullscreen,
        onUserSelected: onUserSelected,
        onShowSummary: onShowSummary,
        summaryButtonLabel: summaryButtonLabel,
        eventDraftFilter: eventDraftFilter,
        onEventDraftFilterChanged: onEventDraftFilterChanged,
      ),
      backgroundColor: AppColorScheme.color2,
      foregroundColor: Colors.white,
    );
  }

  /// Construye el título del AppBar con navegación
  Widget _buildTitle(BuildContext context, int startDay, int endDay, int totalDays, VoidCallback onPrevious, VoidCallback onNext) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentDayGroup > 0 ? onPrevious : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: loc.calendarPreviousDays,
        ),
        Text(
          loc.calendarTitleDaysRange(startDay, endDay, totalDays, visibleDays),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        IconButton(
          onPressed: (startDay + visibleDays - 1) < totalDays ? onNext : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: loc.calendarNextDays,
        ),
      ],
    );
  }

  /// Construye las acciones del AppBar
  List<Widget> _buildActions(
    BuildContext context, {
    required Function(int) onVisibleDaysChanged,
    required Future<bool> Function() canManageRoles,
    required VoidCallback onManageRoles,
    required VoidCallback onPersonalView,
    required Function(CalendarViewMode) onFilterChanged,
    required VoidCallback onCustomFilter,
    required VoidCallback onReorderTracks,
    required VoidCallback onFullscreen,
    required Function(String) onUserSelected,
    VoidCallback? onShowSummary,
    String? summaryButtonLabel,
    String eventDraftFilter = 'all',
    void Function(String)? onEventDraftFilterChanged,
  }) {
    return [
      // Botón Ver resumen (cuando se proporciona callback, p. ej. en dashboard)
      if (onShowSummary != null && summaryButtonLabel != null && summaryButtonLabel.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
          child: TextButton.icon(
            onPressed: onShowSummary,
            icon: const Icon(Icons.summarize, size: 18, color: Colors.white),
            label: Text(
              summaryButtonLabel,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 36),
            ),
          ),
        ),
      // T242 (2): Menú categorizado con todas las opciones del calendario
      _buildGroupedOptionsMenu(
        context,
        onVisibleDaysChanged: onVisibleDaysChanged,
        canManageRoles: canManageRoles,
        onManageRoles: onManageRoles,
        onPersonalView: onPersonalView,
        onFilterChanged: onFilterChanged,
        onCustomFilter: onCustomFilter,
        onReorderTracks: onReorderTracks,
        onFullscreen: onFullscreen,
        eventDraftFilter: eventDraftFilter,
        onEventDraftFilterChanged: onEventDraftFilterChanged,
      ),
    ];
  }

  /// T242 (2): Menú categorizado con Vista, Filtro eventos, Días visibles, Participantes, Pantalla completa, Roles
  Widget _buildGroupedOptionsMenu(
    BuildContext context, {
    required Function(int) onVisibleDaysChanged,
    required Future<bool> Function() canManageRoles,
    required VoidCallback onManageRoles,
    required VoidCallback onPersonalView,
    required Function(CalendarViewMode) onFilterChanged,
    required VoidCallback onCustomFilter,
    required VoidCallback onReorderTracks,
    required VoidCallback onFullscreen,
    String eventDraftFilter = 'all',
    void Function(String)? onEventDraftFilterChanged,
  }) {
    final loc = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      tooltip: loc.calendarOptionsTooltip,
      onSelected: (String value) {
        if (value.startsWith('_')) return;
        switch (value) {
          case 'view_all':
            onFilterChanged(CalendarViewMode.all);
            break;
          case 'view_personal':
            onPersonalView();
            break;
          case 'view_custom':
            onCustomFilter();
            break;
          case 'filter_all':
            onEventDraftFilterChanged?.call('all');
            break;
          case 'filter_draft':
            onEventDraftFilterChanged?.call('draft');
            break;
          case 'filter_confirmed':
            onEventDraftFilterChanged?.call('confirmed');
            break;
          case 'days_1':
          case 'days_3':
          case 'days_7':
            onVisibleDaysChanged(int.parse(value.split('_')[1]));
            break;
          case 'participants':
            onReorderTracks();
            break;
          case 'fullscreen':
            onFullscreen();
            break;
          case 'roles':
            onManageRoles();
            break;
        }
      },
      itemBuilder: (BuildContext _) {
        final entries = <PopupMenuEntry<String>>[
          PopupMenuItem<String>(value: '_header', enabled: false, height: 28, child: Text(loc.calendarMenuSectionView, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          PopupMenuItem<String>(value: 'view_all', child: Row(children: [Icon(Icons.calendar_view_day, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuPlanComplete)])),
          PopupMenuItem<String>(value: 'view_personal', child: Row(children: [Icon(Icons.person, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuMyAgenda)])),
          PopupMenuItem<String>(value: 'view_custom', child: Row(children: [Icon(Icons.filter_list, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuCustomView)])),
          const PopupMenuDivider(),
        ];
        if (onEventDraftFilterChanged != null) {
          entries.add(PopupMenuItem<String>(value: '_h2', enabled: false, height: 28, child: Text(loc.calendarMenuSectionEventFilter, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))));
          entries.add(PopupMenuItem<String>(value: 'filter_all', child: Row(children: [Icon(Icons.event_note, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuAllEvents)])));
          entries.add(PopupMenuItem<String>(value: 'filter_draft', child: Row(children: [Icon(Icons.edit_note, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuDraftsOnly)])));
          entries.add(PopupMenuItem<String>(value: 'filter_confirmed', child: Row(children: [Icon(Icons.check_circle_outline, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuConfirmedOnly)])));
          entries.add(const PopupMenuDivider());
        }
        entries.add(PopupMenuItem<String>(value: '_h3', enabled: false, height: 28, child: Text(loc.calendarMenuSectionDaysVisible, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))));
        entries.add(PopupMenuItem<String>(value: 'days_1', child: Row(children: [Icon(Icons.calendar_view_day, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuDays1)])));
        entries.add(PopupMenuItem<String>(value: 'days_3', child: Row(children: [Icon(Icons.calendar_view_week, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuDays3)])));
        entries.add(PopupMenuItem<String>(value: 'days_7', child: Row(children: [Icon(Icons.calendar_view_month, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuDays7)])));
        entries.add(const PopupMenuDivider());
        entries.add(PopupMenuItem<String>(value: 'participants', child: Row(children: [Icon(Icons.people, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuManageParticipants)])));
        entries.add(PopupMenuItem<String>(value: 'fullscreen', child: Row(children: [Icon(Icons.fullscreen, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuFullscreen)])));
        entries.add(PopupMenuItem<String>(value: 'roles', child: Row(children: [Icon(Icons.admin_panel_settings, size: 18, color: AppColorScheme.color2), const SizedBox(width: 8), Text(loc.calendarMenuManageRoles)])));
        return entries;
      },
    );
  }
}
