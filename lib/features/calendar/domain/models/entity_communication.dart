import 'package:cloud_firestore/cloud_firestore.dart';
import 'communication_attachment.dart';

/// Copia de un mail colocada en un evento o alojamiento.
/// `events/{entityId}/communications/{id}`.
class EntityCommunication {
  final String id;
  final String kind;
  final String subject;
  final String bodyPlain;
  final String? bodyHtml;
  final String? fromEmail;
  final String visibility;
  final String ownerId;
  final String? planId;
  final Map<String, dynamic>? parsed;
  final String? templateId;
  final List<CommunicationAttachment> attachments;
  final DateTime? createdAt;
  final DateTime? placedAt;

  const EntityCommunication({
    required this.id,
    this.kind = 'email',
    required this.subject,
    required this.bodyPlain,
    this.bodyHtml,
    this.fromEmail,
    this.visibility = 'plan',
    required this.ownerId,
    this.planId,
    this.parsed,
    this.templateId,
    this.attachments = const [],
    this.createdAt,
    this.placedAt,
  });

  bool get isPrivate => visibility == 'private';

  factory EntityCommunication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EntityCommunication(
      id: doc.id,
      kind: data['kind'] as String? ?? 'email',
      subject: data['subject'] as String? ?? '',
      bodyPlain: data['bodyPlain'] as String? ?? '',
      bodyHtml: data['bodyHtml'] as String?,
      fromEmail: data['fromEmail'] as String?,
      visibility: data['visibility'] as String? ?? 'plan',
      ownerId: data['ownerId'] as String? ?? '',
      planId: data['planId'] as String?,
      parsed: data['parsed'] as Map<String, dynamic>?,
      templateId: data['templateId'] as String?,
      attachments: CommunicationAttachment.listFrom(data['attachments']),
      createdAt: _toDate(data['createdAt']),
      placedAt: _toDate(data['placedAt']),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
