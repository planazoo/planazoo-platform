import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../../../../features/security/utils/sanitizer.dart';
import '../models/plan_announcement.dart';

/// Servicio para gestionar avisos de planes en Firestore
class AnnouncementService {
  static const String _collectionName = 'plans';
  static const String _subCollectionName = 'announcements';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crear un nuevo aviso para un plan
  Future<String?> createAnnouncement(
    String planId,
    PlanAnnouncement announcement,
  ) async {
    try {
      // Sanitizar el mensaje
      final sanitizedMessage = Sanitizer.sanitizePlainText(
        announcement.message,
        maxLength: 1000,
      );

      // Crear aviso con mensaje sanitizado
      final sanitizedAnnouncement = announcement.copyWith(
        message: sanitizedMessage,
      );

      // Guardar en Firestore
      final docRef = await _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .add(sanitizedAnnouncement.toFirestore());

      LoggerService.database(
        'Announcement created: $planId/${docRef.id}',
        operation: 'CREATE',
      );

      return docRef.id;
    } catch (e) {
      LoggerService.error(
        'Error creating announcement for plan: $planId',
        context: 'ANNOUNCEMENT_SERVICE',
        error: e,
      );
      return null;
    }
  }

  /// Obtener todos los avisos de un plan
  Stream<List<PlanAnnouncement>> getAnnouncements(String planId) {
    return _firestore
        .collection(_collectionName)
        .doc(planId)
        .collection(_subCollectionName)
        .orderBy('createdAt', descending: true) // Más recientes primero
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PlanAnnouncement.fromFirestore(doc))
          .toList();
    });
  }

  /// Eliminar un aviso
  Future<bool> deleteAnnouncement(
    String planId,
    String announcementId,
  ) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .doc(announcementId)
          .delete();

      LoggerService.database(
        'Announcement deleted: $planId/$announcementId',
        operation: 'DELETE',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting announcement: $planId/$announcementId',
        context: 'ANNOUNCEMENT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Obtener un aviso específico por ID
  Future<PlanAnnouncement?> getAnnouncementById(
    String planId,
    String announcementId,
  ) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .doc(announcementId)
          .get();

      if (doc.exists) {
        return PlanAnnouncement.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error(
        'Error getting announcement: $planId/$announcementId',
        context: 'ANNOUNCEMENT_SERVICE',
        error: e,
      );
      return null;
    }
  }

  /// Contar avisos de un plan (útil para estadísticas)
  Future<int> countAnnouncements(String planId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      LoggerService.error(
        'Error counting announcements for plan: $planId',
        context: 'ANNOUNCEMENT_SERVICE',
        error: e,
      );
      return 0;
    }
  }

  /// Eliminar todos los avisos de un plan (útil para limpieza)
  Future<bool> deleteAllAnnouncements(String planId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .doc(planId)
          .collection(_subCollectionName)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      LoggerService.database(
        'All announcements deleted for plan: $planId',
        operation: 'DELETE',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting all announcements for plan: $planId',
        context: 'ANNOUNCEMENT_SERVICE',
        error: e,
      );
      return false;
    }
  }
}

