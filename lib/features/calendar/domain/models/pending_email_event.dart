import 'package:cloud_firestore/cloud_firestore.dart';

/// Evento pendiente de asignar a un plan (buzón de correos reenviados).
/// Documento en `users/{userId}/pending_email_events/{eventId}`.
class PendingEmailEvent {
  final String id;
  final String subject;
  final String bodyPlain;
  final String? fromEmail;
  final Map<String, dynamic>? parsed;
  final String? templateId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PendingEmailEvent({
    required this.id,
    required this.subject,
    required this.bodyPlain,
    this.fromEmail,
    this.parsed,
    this.templateId,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory PendingEmailEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PendingEmailEvent(
      id: doc.id,
      subject: data['subject'] as String? ?? '',
      bodyPlain: data['bodyPlain'] as String? ?? '',
      fromEmail: data['fromEmail'] as String?,
      parsed: data['parsed'] as Map<String, dynamic>?,
      templateId: data['templateId'] as String?,
      status: data['status'] as String? ?? 'pending',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  /// Título para mostrar: parsed.title o subject.
  String get displayTitle {
    if (parsed != null && parsed!['title'] != null) {
      final t = parsed!['title'];
      if (t is String && t.trim().isNotEmpty) return t.trim();
    }
    return subject.isNotEmpty ? subject : '-';
  }

  /// Ubicación extraída (parsed.location) si existe.
  String? get location => parsed != null && parsed!['location'] != null ? parsed!['location'].toString() : null;

  /// Fecha/hora inicio extraída (parsed.start_datetime o start_date + start_time) si existe.
  DateTime? get startDateTime {
    if (parsed == null) return null;
    if (parsed!['start_datetime'] != null) {
      final v = parsed!['start_datetime'];
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
    }
    return null;
  }

  /// Tipo de evento (parsed.event_type) si existe.
  String? get eventType => parsed != null && parsed!['event_type'] != null ? parsed!['event_type'].toString() : null;

  bool get isParsed => parsed != null && parsed!.isNotEmpty;
}
