/// Archivo o imagen ligado a una comunicación (mail o nota).
class CommunicationAttachment {
  final String name;
  final String url;
  final String type;
  final int size;
  final String? contentId;

  const CommunicationAttachment({
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    this.contentId,
  });

  bool get isImage {
    final t = type.toLowerCase();
    if (t.startsWith('image/')) return true;
    final n = name.toLowerCase();
    return n.endsWith('.png') ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.gif') ||
        n.endsWith('.webp') ||
        n.endsWith('.heic');
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'type': type,
      'size': size,
      if (contentId != null && contentId!.isNotEmpty) 'contentId': contentId,
    };
  }

  factory CommunicationAttachment.fromMap(Map<String, dynamic> map) {
    return CommunicationAttachment(
      name: map['name'] as String? ?? '',
      url: map['url'] as String? ?? '',
      type: map['type'] as String? ?? '',
      size: (map['size'] as num?)?.toInt() ?? 0,
      contentId: map['contentId'] as String?,
    );
  }

  static List<CommunicationAttachment> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    final out = <CommunicationAttachment>[];
    for (final e in raw) {
      if (e is Map) {
        final a = CommunicationAttachment.fromMap(Map<String, dynamic>.from(e));
        if (a.url.isNotEmpty) out.add(a);
      }
    }
    return out;
  }

  static List<Map<String, dynamic>> listToMaps(List<CommunicationAttachment> items) {
    return items.map((a) => a.toMap()).toList();
  }
}
