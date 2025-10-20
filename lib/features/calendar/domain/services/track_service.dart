import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/participant_track.dart';
import '../models/plan_participation.dart';

/// Servicio para gestionar los tracks de participantes en el calendario
class TrackService {
  final List<ParticipantTrack> _tracks = [];

  /// Obtiene todos los tracks ordenados por posición
  List<ParticipantTrack> getAllTracks() {
    final sortedTracks = List<ParticipantTrack>.from(_tracks);
    sortedTracks.sort((a, b) => a.position.compareTo(b.position));
    return sortedTracks;
  }

  /// Obtiene solo los tracks visibles ordenados por posición
  List<ParticipantTrack> getVisibleTracks() {
    return getAllTracks().where((track) => track.isVisible).toList();
  }

  /// Obtiene un track por su ID
  ParticipantTrack? getTrackById(String id) {
    try {
      return _tracks.firstWhere((track) => track.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un track por el ID del participante
  ParticipantTrack? getTrackByParticipantId(String participantId) {
    try {
      return _tracks.firstWhere((track) => track.participantId == participantId);
    } catch (e) {
      return null;
    }
  }

  /// Crea un nuevo track para un participante
  ParticipantTrack createTrack({
    required String participantId,
    required String participantName,
    String? customColor,
  }) {
    final now = DateTime.now();
    final newPosition = _getNextPosition();
    
    final track = ParticipantTrack(
      id: _generateTrackId(),
      participantId: participantId,
      participantName: participantName,
      position: newPosition,
      customColor: customColor ?? TrackColors.getColorForPosition(newPosition),
      isVisible: true,
      createdAt: now,
      updatedAt: now,
    );

    _tracks.add(track);
    return track;
  }

  /// Actualiza un track existente
  ParticipantTrack updateTrack(ParticipantTrack updatedTrack) {
    final index = _tracks.indexWhere((track) => track.id == updatedTrack.id);
    if (index == -1) {
      throw Exception('Track not found: ${updatedTrack.id}');
    }

    final trackWithUpdatedTime = updatedTrack.copyWith(
      updatedAt: DateTime.now(),
    );

    _tracks[index] = trackWithUpdatedTime;
    return trackWithUpdatedTime;
  }

  /// Elimina un track
  void deleteTrack(String trackId) {
    _tracks.removeWhere((track) => track.id == trackId);
  }

  /// Reordena los tracks cambiando sus posiciones según participantIds
  void reorderTracksByParticipantIds(List<String> participantIdsInNewOrder) {
    for (int i = 0; i < participantIdsInNewOrder.length; i++) {
      final participantId = participantIdsInNewOrder[i];
      final track = getTrackByParticipantId(participantId);
      if (track != null) {
        final updatedTrack = track.copyWith(position: i);
        updateTrack(updatedTrack);
      }
    }
  }

  /// Cambia la visibilidad de un track
  void toggleTrackVisibility(String trackId) {
    final track = getTrackById(trackId);
    if (track != null) {
      final updatedTrack = track.copyWith(isVisible: !track.isVisible);
      updateTrack(updatedTrack);
    }
  }

  /// Cambia el color de un track
  void updateTrackColor(String trackId, String color) {
    final track = getTrackById(trackId);
    if (track != null) {
      final updatedTrack = track.copyWith(customColor: color);
      updateTrack(updatedTrack);
    }
  }

  /// Obtiene el número de tracks visibles
  int getVisibleTracksCount() {
    return getVisibleTracks().length;
  }

  /// Verifica si un participante ya tiene un track
  bool hasTrackForParticipant(String participantId) {
    return _tracks.any((track) => track.participantId == participantId);
  }

  /// Crea tracks para todos los participantes de una lista
  List<ParticipantTrack> createTracksForParticipants(List<Map<String, String>> participants) {
    final createdTracks = <ParticipantTrack>[];
    
    for (final participant in participants) {
      final participantId = participant['id'] ?? '';
      final participantName = participant['name'] ?? 'Participante';
      
      if (!hasTrackForParticipant(participantId)) {
        final track = createTrack(
          participantId: participantId,
          participantName: participantName,
        );
        createdTracks.add(track);
      }
    }
    
    return createdTracks;
  }

  /// Carga el orden global (por participantIds) desde Firestore y lo aplica
  Future<void> loadOrderFromFirestore(String planId) async {
    final doc = await FirebaseFirestore.instance.collection('plans').doc(planId).get();
    if (!doc.exists) return;
    final data = doc.data();
    if (data == null) return;
    final List<dynamic>? ids = data['trackOrderParticipantIds'] as List<dynamic>?;
    if (ids == null || ids.isEmpty) return;
    final savedIds = ids.map((e) => e.toString()).toList();
    final existingParticipantIds = _tracks.map((t) => t.participantId).toSet();
    final filtered = savedIds.where((id) => existingParticipantIds.contains(id)).toList();
    for (int i = 0; i < filtered.length; i++) {
      final track = getTrackByParticipantId(filtered[i]);
      if (track != null) {
        _tracks[_tracks.indexWhere((t) => t.id == track.id)] = track.copyWith(position: i);
      }
    }
  }

  /// Guarda el orden global (por participantIds) en Firestore
  Future<void> saveOrderToFirestore(String planId, List<String> participantIdsInNewOrder) async {
    await FirebaseFirestore.instance.collection('plans').doc(planId).set(
      {
        'trackOrderParticipantIds': participantIdsInNewOrder,
        'trackOrderUpdatedAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }

  /// Sincroniza tracks con participantes reales del plan
  List<ParticipantTrack> syncTracksWithPlanParticipants(List<PlanParticipation> participations) {
    final createdTracks = <ParticipantTrack>[];
    
    // Limpiar tracks de participantes que ya no están en el plan
    _tracks.removeWhere((track) {
      final participationExists = participations.any((p) => 
        p.userId == track.participantId && p.isActive);
      return !participationExists;
    });
    
    // Crear tracks para participantes nuevos
    for (final participation in participations) {
      if (participation.isActive && !hasTrackForParticipant(participation.userId)) {
        final track = createTrack(
          participantId: participation.userId,
          participantName: _getParticipantDisplayName(participation),
        );
        createdTracks.add(track);
      }
    }
    
    return createdTracks;
  }

  /// Obtiene el nombre de visualización para un participante
  String _getParticipantDisplayName(PlanParticipation participation) {
    // Mapeo de user IDs a nombres reales para el plan Frankenstein
    final userNames = {
      'uJRMMGniO2bwfbdD3S11QMXQT912': 'Cristian Claraso',
      'mar_batllori': 'Mar Batllori',
      'emma_claraso': 'Emma Claraso',
      'matilde_claraso': 'Matilde Claraso',
      'jimena_claraso': 'Jimena Claraso',
    };
    
    return userNames[participation.userId] ?? participation.userId;
  }

  /// Obtiene la siguiente posición disponible para un nuevo track
  int _getNextPosition() {
    if (_tracks.isEmpty) return 0;
    final maxPosition = _tracks.map((track) => track.position).reduce((a, b) => a > b ? a : b);
    return maxPosition + 1;
  }

  /// Genera un ID único para un track
  String _generateTrackId() {
    return 'track_${DateTime.now().millisecondsSinceEpoch}_${_tracks.length}';
  }

  /// Limpia todos los tracks (útil para testing)
  void clearAllTracks() {
    _tracks.clear();
  }

  /// Obtiene estadísticas de los tracks
  Map<String, int> getTrackStats() {
    return {
      'total': _tracks.length,
      'visible': getVisibleTracksCount(),
      'hidden': _tracks.length - getVisibleTracksCount(),
    };
  }
}
