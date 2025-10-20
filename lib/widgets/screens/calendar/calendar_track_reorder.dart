import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/participant_track.dart';
import 'package:unp_calendario/features/calendar/domain/services/track_service.dart';

/// Clase que maneja la lógica de reordenación de tracks
class CalendarTrackReorder {
  final TrackService _trackService;
  
  CalendarTrackReorder(this._trackService);

  /// Muestra el diálogo de reordenación de tracks
  void showReorderDialog(
    BuildContext context,
    String planId,
    VoidCallback onReorderComplete,
  ) {
    final tracks = List<ParticipantTrack>.from(_trackService.getVisibleTracks());
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reordenar Participantes'),
          content: SizedBox(
            width: 400,
            height: 300,
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
                return ListTile(
                  key: ValueKey(track.id),
                  leading: const Icon(Icons.drag_indicator),
                  title: Text(track.participantName.isNotEmpty 
                      ? track.participantName 
                      : 'Participante ${index + 1}'),
                  subtitle: Text('Track ${index + 1}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final newOrderIds = tracks.map((track) => track.participantId).toList();
                _trackService.reorderTracksByParticipantIds(newOrderIds);
                onReorderComplete();
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón de reordenación para el AppBar
  Widget buildReorderButton(VoidCallback onPressed) {
    return IconButton(
      icon: const Icon(Icons.swap_vert, color: Colors.white),
      tooltip: 'Reordenar Tracks',
      onPressed: onPressed,
    );
  }
}
