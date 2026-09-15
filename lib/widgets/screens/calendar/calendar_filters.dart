import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/calendar_view_mode.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/services/track_service.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';

/// Clase que maneja la lógica de filtros del calendario
class CalendarFilters {
  final TrackService _trackService;

  CalendarFilters(this._trackService);

  /// Obtiene los tracks filtrados según el modo de vista actual
  List<ParticipantTrack> getFilteredTracks(
    CalendarViewMode viewMode,
    String? currentUserId,
    List<String> filteredParticipantIds,
  ) {
    switch (viewMode) {
      case CalendarViewMode.all:
        return _trackService.getVisibleTracks();
      case CalendarViewMode.personal:
        if (currentUserId != null) {
          final mine = _trackService
              .getVisibleTracks()
              .where((track) => track.participantId == currentUserId)
              .toList();
          if (mine.isNotEmpty) return mine;
        }
        // Fallback: usar el primer track si no hay usuario actual
        final tracks = _trackService.getVisibleTracks();
        return tracks.isNotEmpty ? [tracks.first] : [];
      case CalendarViewMode.custom:
        return _trackService
            .getVisibleTracks()
            .where(
              (track) => filteredParticipantIds.contains(track.participantId),
            )
            .toList();
    }
  }

  /// Obtiene el nombre del modo de vista actual
  String getCurrentViewName(CalendarViewMode viewMode) {
    switch (viewMode) {
      case CalendarViewMode.all:
        return 'Plan Completo';
      case CalendarViewMode.personal:
        return 'Mi Agenda';
      case CalendarViewMode.custom:
        return 'Personalizada';
    }
  }

  /// Obtiene el icono del modo de vista actual
  IconData getCurrentViewIcon(CalendarViewMode viewMode) {
    switch (viewMode) {
      case CalendarViewMode.all:
        return Icons.calendar_view_day;
      case CalendarViewMode.personal:
        return Icons.person;
      case CalendarViewMode.custom:
        return Icons.filter_list;
    }
  }

  /// Muestra el diálogo de vista personalizada
  void showCustomViewDialog(
    BuildContext context,
    List<String> filteredParticipantIds,
    Function(CalendarViewMode viewMode, List<String> participantIds) onApply, {
    Map<String, String>? displayNames,
  }) {
    final allTracks = _trackService.getVisibleTracks();
    final selectedTracks = Set<String>.from(
      filteredParticipantIds.isNotEmpty
          ? filteredParticipantIds
          : allTracks.map((t) => t.participantId),
    );

    String labelFor(ParticipantTrack track, int index) {
      final fromMap = displayNames?[track.participantId]?.trim();
      if (fromMap != null && fromMap.isNotEmpty) return fromMap;
      if (track.participantName.trim().isNotEmpty &&
          track.participantName != track.participantId) {
        return track.participantName.trim();
      }
      return 'Participante ${index + 1}';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final allSelected = allTracks.isNotEmpty &&
              allTracks.every((t) => selectedTracks.contains(t.participantId));
          return AlertDialog(
            title: const Text('Seleccionar participantes'),
            content: SizedBox(
              width: 400,
              height: 340,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setDialogState(() {
                          if (allSelected) {
                            selectedTracks.clear();
                          } else {
                            selectedTracks
                              ..clear()
                              ..addAll(
                                allTracks.map((t) => t.participantId),
                              );
                          }
                        });
                      },
                      child: Text(
                        allSelected
                            ? 'Deseleccionar todos'
                            : 'Seleccionar todos',
                        style: TextStyle(color: AppColorScheme.color2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allTracks.length,
                      itemBuilder: (context, index) {
                        final track = allTracks[index];
                        final isSelected =
                            selectedTracks.contains(track.participantId);
                        return CheckboxListTile(
                          title: Text(labelFor(track, index)),
                          value: isSelected,
                          activeColor: AppColorScheme.color2,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedTracks.add(track.participantId);
                              } else {
                                selectedTracks.remove(track.participantId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: selectedTracks.isNotEmpty
                    ? () {
                        onApply(
                          CalendarViewMode.custom,
                          selectedTracks.toList(),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Construye el PopupMenuButton para seleccionar filtros
  Widget buildFilterMenu(
    CalendarViewMode currentViewMode,
    Function(CalendarViewMode) onFilterSelected,
    Function() onCustomFilter,
  ) {
    return PopupMenuButton<CalendarViewMode>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getCurrentViewIcon(currentViewMode), color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(
            getCurrentViewName(currentViewMode),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
        ],
      ),
      onSelected: (CalendarViewMode result) {
        if (result == CalendarViewMode.custom) {
          onCustomFilter();
        } else {
          onFilterSelected(result);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<CalendarViewMode>>[
        PopupMenuItem<CalendarViewMode>(
          value: CalendarViewMode.all,
          child: Row(
            children: [
              Icon(Icons.calendar_view_day, color: AppColorScheme.color1),
              const SizedBox(width: 8),
              const Text('Plan Completo'),
            ],
          ),
        ),
        PopupMenuItem<CalendarViewMode>(
          value: CalendarViewMode.personal,
          child: Row(
            children: [
              Icon(Icons.person, color: AppColorScheme.color1),
              const SizedBox(width: 8),
              const Text('Mi Agenda'),
            ],
          ),
        ),
        PopupMenuItem<CalendarViewMode>(
          value: CalendarViewMode.custom,
          child: Row(
            children: [
              Icon(Icons.filter_list, color: AppColorScheme.color1),
              const SizedBox(width: 8),
              const Text('Personalizada'),
            ],
          ),
        ),
      ],
    );
  }
}
