import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/services/track_service.dart';

/// Clase que maneja la lógica de reordenación y selección de tracks
class CalendarTrackReorder {
  final TrackService _trackService;
  
  CalendarTrackReorder(this._trackService);

  /// Muestra el diálogo integrado de gestión de participantes
  void showParticipantManagementDialog(
    BuildContext context,
    String planId,
    String currentUserId,
    VoidCallback onReorderComplete,
    VoidCallback onSelectionComplete,
  ) {
    final tracks = List<ParticipantTrack>.from(_trackService.getVisibleTracks());
    final selectedTracks = Set<String>.from(tracks.map((t) => t.participantId));
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Gestionar Participantes'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Reordenar', icon: Icon(Icons.swap_vert)),
                      Tab(text: 'Seleccionar', icon: Icon(Icons.checklist)),
                      Tab(text: 'Todos', icon: Icon(Icons.visibility)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildReorderTab(tracks, setDialogState),
                        _buildSelectTab(tracks, selectedTracks, currentUserId, setDialogState),
                        _buildViewAllTab(tracks, currentUserId),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aplicar cambios según el tab activo
                final tabController = DefaultTabController.of(context);
                if (tabController.index == 0) {
                  // Reordenar
                  final newOrderIds = tracks.map((track) => track.participantId).toList();
                  _trackService.reorderTracksByParticipantIds(newOrderIds);
                  onReorderComplete();
                } else if (tabController.index == 1) {
                  // Seleccionar
                  _trackService.setSelectedTracks(selectedTracks.toList());
                  onSelectionComplete();
                }
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Tab de reordenación (funcionalidad original)
  Widget _buildReorderTab(List<ParticipantTrack> tracks, StateSetter setDialogState) {
    return ReorderableListView.builder(
      itemCount: tracks.length,
      onReorder: (int oldIndex, int newIndex) {
        setDialogState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = tracks.removeAt(oldIndex);
          tracks.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
          key: ValueKey(track.id),
          leading: const Icon(Icons.drag_indicator),
          title: Text(track.participantName.isNotEmpty 
              ? track.participantName 
              : 'Participante ${index + 1}'),
          subtitle: Text('Track ${index + 1}'),
        );
      },
    );
  }

  /// Tab de selección (nueva funcionalidad T80)
  Widget _buildSelectTab(
    List<ParticipantTrack> tracks, 
    Set<String> selectedTracks, 
    String currentUserId,
    StateSetter setDialogState,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Seleccionar participantes a mostrar:'),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      selectedTracks.clear();
                      selectedTracks.addAll(tracks.map((t) => t.participantId));
                    });
                  },
                  child: const Text('Todos'),
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      selectedTracks.clear();
                      selectedTracks.add(currentUserId);
                    });
                  },
                  child: const Text('Solo Yo'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final isSelected = selectedTracks.contains(track.participantId);
              final isCurrentUser = track.participantId == currentUserId;
              
              return CheckboxListTile(
                value: isSelected,
                onChanged: isCurrentUser ? null : (value) {
                  setDialogState(() {
                    if (value == true) {
                      selectedTracks.add(track.participantId);
                    } else {
                      selectedTracks.remove(track.participantId);
                    }
                  });
                },
                title: Row(
                  children: [
                    Text(track.participantName.isNotEmpty 
                        ? track.participantName 
                        : 'Participante ${index + 1}'),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'TÚ',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text('Track ${index + 1}'),
                secondary: isCurrentUser 
                    ? const Icon(Icons.person, color: Colors.blue)
                    : const Icon(Icons.person_outline),
              );
            },
          ),
        ),
        if (selectedTracks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '⚠️ Debes seleccionar al menos un participante',
              style: TextStyle(color: Colors.orange),
            ),
          ),
      ],
    );
  }

  /// Tab de vista de todos (solo lectura)
  Widget _buildViewAllTab(List<ParticipantTrack> tracks, String currentUserId) {
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isCurrentUser = track.participantId == currentUserId;
        
        return ListTile(
          leading: isCurrentUser 
              ? const Icon(Icons.person, color: Colors.blue)
              : const Icon(Icons.person_outline),
          title: Row(
            children: [
              Text(track.participantName.isNotEmpty 
                  ? track.participantName 
                  : 'Participante ${index + 1}'),
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TÚ',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text('Track ${index + 1}'),
          trailing: const Icon(Icons.visibility, color: Colors.grey),
        );
      },
    );
  }

  /// Construye el botón de gestión de participantes para el AppBar
  Widget buildParticipantManagementButton(VoidCallback onPressed) {
    return IconButton(
      icon: const Icon(Icons.people, color: Colors.white),
      tooltip: 'Gestionar Participantes',
      onPressed: onPressed,
    );
  }
}
