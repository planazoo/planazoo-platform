import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class InboundEmailEntry {
  final String id;
  final String email;
  final bool verified;
  final DateTime? createdAt;

  const InboundEmailEntry({
    required this.id,
    required this.email,
    required this.verified,
    this.createdAt,
  });

  factory InboundEmailEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InboundEmailEntry(
      id: doc.id,
      email: (data['email'] as String? ?? '').toLowerCase().trim(),
      verified: data['verified'] == true,
      createdAt: data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }
}

class InboundEmailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<InboundEmailEntry>> streamExtras(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('inbound_emails')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(InboundEmailEntry.fromFirestore).toList();
      list.sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
      return list;
    });
  }

  Future<void> requestVerification(String email) async {
    await FirebaseFunctions.instance.httpsCallable('requestInboundEmailVerification').call({
      'email': email,
    });
  }

  Future<void> remove(String email) async {
    await FirebaseFunctions.instance.httpsCallable('removeInboundEmail').call({
      'email': email,
    });
  }
}
