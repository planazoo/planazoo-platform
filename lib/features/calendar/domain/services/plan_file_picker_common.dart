import 'dart:typed_data';

class PickedPlanFile {
  final String name;
  final Uint8List bytes;
  final int size;
  final String? mimeType;

  const PickedPlanFile({
    required this.name,
    required this.bytes,
    required this.size,
    this.mimeType,
  });
}

/// Selección hecha pero sin bytes legibles (p. ej. path iOS inaccesible).
class PlanFilePickReadException implements Exception {
  const PlanFilePickReadException();
}
