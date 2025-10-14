import 'package:unp_calendario/features/calendar/domain/models/event_segment.dart';

/// Representa un grupo de segmentos de eventos que se solapan en el tiempo
/// Similar a OverlappingEventGroup pero trabaja con EventSegment
class OverlappingSegmentGroup {
  final List<EventSegment> segments;
  final DateTime date;
  final int startMinute;
  final int endMinute;
  final int maxOverlap;

  const OverlappingSegmentGroup({
    required this.segments,
    required this.date,
    required this.startMinute,
    required this.endMinute,
    required this.maxOverlap,
  });

  /// Detecta segmentos solapados para una lista de segmentos
  static List<OverlappingSegmentGroup> detectOverlappingGroups(List<EventSegment> segments) {
    if (segments.isEmpty) return [];

    final groups = <OverlappingSegmentGroup>[];
    final processedSegmentIds = <String>{};

    // Ordenar segmentos por hora de inicio
    final sortedSegments = List<EventSegment>.from(segments);
    sortedSegments.sort((a, b) => a.startMinute.compareTo(b.startMinute));

    for (final segment in sortedSegments) {
      if (processedSegmentIds.contains(segment.id)) continue;

      // Encontrar todos los segmentos que se solapan con este
      final overlappingSegments = <EventSegment>[segment];
      processedSegmentIds.add(segment.id);

      int groupStartMinute = segment.startMinute;
      int groupEndMinute = segment.endMinute;

      // Buscar solapamientos
      for (final otherSegment in sortedSegments) {
        if (processedSegmentIds.contains(otherSegment.id)) continue;

        final otherStart = otherSegment.startMinute;
        final otherEnd = otherSegment.endMinute;

        // ¿Se solapan?
        if (_hasOverlap(groupStartMinute, groupEndMinute, otherStart, otherEnd)) {
          overlappingSegments.add(otherSegment);
          processedSegmentIds.add(otherSegment.id);

          // Expandir rango del grupo
          groupStartMinute = groupStartMinute < otherStart ? groupStartMinute : otherStart;
          groupEndMinute = groupEndMinute > otherEnd ? groupEndMinute : otherEnd;
        }
      }

      // Crear grupo
      groups.add(OverlappingSegmentGroup(
        segments: overlappingSegments,
        date: segment.segmentDate,
        startMinute: groupStartMinute,
        endMinute: groupEndMinute,
        maxOverlap: overlappingSegments.length,
      ));
    }

    return groups;
  }

  /// Verifica si dos rangos de tiempo se solapan
  static bool _hasOverlap(int start1, int end1, int start2, int end2) {
    return (start1 < end2) && (end1 > start2);
  }

  /// Obtiene la posición horizontal de un segmento en el grupo (0.0 a 1.0)
  double getSegmentPositionRatio(EventSegment segment) {
    final index = segments.indexOf(segment);
    if (index == -1) return 0.0;
    return index / maxOverlap;
  }

  /// Obtiene el ancho de un segmento en el grupo (0.0 a 1.0)
  double getSegmentWidthRatio() {
    return 1.0 / maxOverlap;
  }

  @override
  String toString() {
    return 'OverlappingSegmentGroup(${segments.length} segments, $startMinute-$endMinute)';
  }
}

