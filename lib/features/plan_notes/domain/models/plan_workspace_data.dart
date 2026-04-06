import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unp_calendario/features/plan_notes/domain/models/plan_preparation_item.dart';

/// Política de edición de la lista común de preparación (T262).
enum PreparationCommonEditPolicy {
  organizerOnly('organizer_only'),
  selectedParticipants('selected_participants'),
  allParticipants('all_participants');

  final String firestoreValue;
  const PreparationCommonEditPolicy(this.firestoreValue);

  static PreparationCommonEditPolicy fromString(String? v) {
    switch (v) {
      case 'selected_participants':
        return PreparationCommonEditPolicy.selectedParticipants;
      case 'all_participants':
        return PreparationCommonEditPolicy.allParticipants;
      default:
        return PreparationCommonEditPolicy.organizerOnly;
    }
  }
}

/// Documento `plans/{planId}/plan_workspace/default` — notas comunes + preparación compartida.
class PlanWorkspaceData {
  final String commonNoteText;
  final List<PlanPreparationItem> preparationItems;
  final PreparationCommonEditPolicy preparationCommonEditPolicy;
  final List<String> preparationCommonEditorUserIds;
  final List<String> planParticipantUserIds;
  final DateTime? updatedAt;

  const PlanWorkspaceData({
    this.commonNoteText = '',
    this.preparationItems = const [],
    this.preparationCommonEditPolicy = PreparationCommonEditPolicy.organizerOnly,
    this.preparationCommonEditorUserIds = const [],
    this.planParticipantUserIds = const [],
    this.updatedAt,
  });

  factory PlanWorkspaceData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlanWorkspaceData(
      commonNoteText: data['commonNoteText']?.toString() ?? '',
      preparationItems: preparationItemsFromFirestore(data['preparationItems']),
      preparationCommonEditPolicy:
          PreparationCommonEditPolicy.fromString(data['preparationCommonEditPolicy']?.toString()),
      preparationCommonEditorUserIds: _stringList(data['preparationCommonEditorUserIds']),
      planParticipantUserIds: _stringList(data['planParticipantUserIds']),
      updatedAt: timestampToDateTime(data['updatedAt']),
    );
  }

  static List<String> _stringList(dynamic v) {
    if (v is! List) return const [];
    return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'commonNoteText': commonNoteText,
      'preparationItems': preparationItemsToFirestore(preparationItems),
      'preparationCommonEditPolicy': preparationCommonEditPolicy.firestoreValue,
      'preparationCommonEditorUserIds': preparationCommonEditorUserIds,
      'planParticipantUserIds': planParticipantUserIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Actualización solo de contenido común (participantes: sin tocar política ni listas de ids).
  Map<String, dynamic> toParticipantContentFirestoreMap() {
    return {
      'commonNoteText': commonNoteText,
      'preparationItems': preparationItemsToFirestore(preparationItems),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PlanWorkspaceData copyWith({
    String? commonNoteText,
    List<PlanPreparationItem>? preparationItems,
    PreparationCommonEditPolicy? preparationCommonEditPolicy,
    List<String>? preparationCommonEditorUserIds,
    List<String>? planParticipantUserIds,
    DateTime? updatedAt,
  }) {
    return PlanWorkspaceData(
      commonNoteText: commonNoteText ?? this.commonNoteText,
      preparationItems: preparationItems ?? this.preparationItems,
      preparationCommonEditPolicy: preparationCommonEditPolicy ?? this.preparationCommonEditPolicy,
      preparationCommonEditorUserIds:
          preparationCommonEditorUserIds ?? this.preparationCommonEditorUserIds,
      planParticipantUserIds: planParticipantUserIds ?? this.planParticipantUserIds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Notas personales por plan: `plans/{planId}/personal_plan_notes/{userId}`.
class PersonalPlanNotesData {
  final String personalNoteText;
  final List<PlanPreparationItem> preparationItems;
  final DateTime? updatedAt;

  const PersonalPlanNotesData({
    this.personalNoteText = '',
    this.preparationItems = const [],
    this.updatedAt,
  });

  factory PersonalPlanNotesData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PersonalPlanNotesData(
      personalNoteText: data['personalNoteText']?.toString() ?? '',
      preparationItems: preparationItemsFromFirestore(data['preparationItems']),
      updatedAt: timestampToDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'personalNoteText': personalNoteText,
      'preparationItems': preparationItemsToFirestore(preparationItems),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PersonalPlanNotesData copyWith({
    String? personalNoteText,
    List<PlanPreparationItem>? preparationItems,
    DateTime? updatedAt,
  }) {
    return PersonalPlanNotesData(
      personalNoteText: personalNoteText ?? this.personalNoteText,
      preparationItems: preparationItems ?? this.preparationItems,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
