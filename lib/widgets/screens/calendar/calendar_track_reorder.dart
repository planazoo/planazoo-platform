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
            child: _buildUnifiedView(tracks, selectedTracks, currentUserId, setDialogState),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aplicar cambios de reordenación y selección
                final newOrderIds = tracks.map((track) => track.participantId).toList();
                _trackService.reorderTracksByParticipantIds(newOrderIds);
                _trackService.setSelectedTracks(selectedTracks.toList());
                onReorderComplete();
                onSelectionComplete();
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista unificada con drag & drop + checkboxes
  Widget _buildUnifiedView(
    List<ParticipantTrack> tracks, 
    Set<String> selectedTracks, 
    String currentUserId,
    StateSetter setDialogState,
  ) {
    return Column(
      children: [
        // Botones de selección rápida
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Arrastra para reordenar • Marca para seleccionar',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
        
        // Lista con drag & drop + checkboxes
        Expanded(
          child: ReorderableListView.builder(
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
              final isSelected = selectedTracks.contains(track.participantId);
              final isCurrentUser = track.participantId == currentUserId;
              
              return Container(
                key: ValueKey(track.id),
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                ),
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.drag_indicator, color: Colors.grey),
                      const SizedBox(width: 8),
                      Checkbox(
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
                      ),
                    ],
                  ),
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
                  trailing: isCurrentUser 
                      ? const Icon(Icons.person, color: Colors.blue)
                      : const Icon(Icons.person_outline),
                ),
              );
            },
          ),
        ),
        
        // Validación
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

  /// Construye el botón de gestión de participantes para el AppBar
  Widget buildParticipantManagementButton(VoidCallback onPressed) {
    return IconButton(
      icon: const Icon(Icons.people, color: Colors.white),
      tooltip: 'Gestionar Participantes',
      onPressed: onPressed,
    );
  }
}
