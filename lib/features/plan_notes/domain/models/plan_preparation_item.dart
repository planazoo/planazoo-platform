import 'package:cloud_firestore/cloud_firestore.dart';

/// Ítem de la lista «Preparación» (mini-tarea con checkbox).
class PlanPreparationItem {
  final String id;
  final String text;
  final bool done;

  const PlanPreparationItem({
    required this.id,
    required this.text,
    this.done = false,
  });

  factory PlanPreparationItem.fromMap(Map<String, dynamic> map) {
    return PlanPreparationItem(
      id: map['id']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      done: map['done'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'done': done,
    };
  }

  PlanPreparationItem copyWith({
    String? id,
    String? text,
    bool? done,
  }) {
    return PlanPreparationItem(
      id: id ?? this.id,
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }
}

List<PlanPreparationItem> preparationItemsFromFirestore(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((e) {
        if (e is Map<String, dynamic>) {
          return PlanPreparationItem.fromMap(e);
        }
        if (e is Map) {
          return PlanPreparationItem.fromMap(Map<String, dynamic>.from(e));
        }
        return null;
      })
      .whereType<PlanPreparationItem>()
      .where((i) => i.id.isNotEmpty)
      .toList();
}

List<Map<String, dynamic>> preparationItemsToFirestore(List<PlanPreparationItem> items) {
  return items.map((e) => e.toMap()).toList();
}

DateTime? timestampToDateTime(dynamic v) {
  if (v is Timestamp) return v.toDate();
  return null;
}
