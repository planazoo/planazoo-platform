import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/services/logger_service.dart';
import '../models/event_participant.dart';
import 'plan_participation_service.dart';

/// Servicio para gestionar participantes por evento
/// 
/// Permite que los participantes del plan se apunten a eventos individuales
class EventParticipantService {
  static const String _collectionName = 'event_participants';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlanParticipationService _participationService = PlanParticipationService();

  /// Apuntarse a un evento
  /// 
  /// Verifica que el usuario participe en el plan del evento antes de permitir el registro
  Future<bool> registerParticipant({
    required String eventId,
    required String userId,
    required String planId,
  }) async {
    try {
      // Verificar que el usuario participa en el plan
      final isParticipant = await _participationService.isUserParticipant(planId, userId);
      if (!isParticipant) {
        LoggerService.warning('User $userId cannot register to event $eventId: not a plan participant');
        return false;
      }

      // Verificar si ya está apuntado
      final existing = await isUserRegistered(eventId, userId);
      if (existing) {
        LoggerService.warning('User $userId already registered to event $eventId');
        return true; // Ya está apuntado, considerar éxito
      }

      // Crear registro
      final eventParticipant = EventParticipant(
        eventId: eventId,
        userId: userId,
        registeredAt: DateTime.now(),
        status: 'registered',
      );

      await _firestore
          .collection(_collectionName)
          .add(eventParticipant.toFirestore());

      LoggerService.database(
        'User $userId registered to event $eventId',
        operation: 'CREATE',
      );
      return true;
    } catch (e) {
      LoggerService.error(
        'Error registering participant to event: $eventId, $userId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Cancelar participación en un evento
  Future<bool> cancelRegistration({
    required String eventId,
    required String userId,
  }) async {
    try {
      // Buscar el registro
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'registered')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        LoggerService.warning('User $userId is not registered to event $eventId');
        return false;
      }

      // Actualizar estado a 'cancelled'
      await querySnapshot.docs.first.reference.update({'status': 'cancelled'});

      LoggerService.database(
        'User $userId cancelled registration to event $eventId',
        operation: 'UPDATE',
      );
      return true;
    } catch (e) {
      LoggerService.error(
        'Error cancelling registration: $eventId, $userId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Obtener todos los participantes registrados de un evento
  Stream<List<EventParticipant>> getEventParticipants(String eventId) {
    return _firestore
        .collection(_collectionName)
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'registered')
        .orderBy('registeredAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventParticipant.fromFirestore(doc))
          .toList();
    }).handleError((error) {
      // No registrar errores de permisos cuando el usuario no está autenticado (comportamiento esperado después de logout)
      final errorString = error.toString();
      if (errorString.contains('permission-denied')) {
        // Silenciar errores de permisos - es normal después de logout
        return <EventParticipant>[];
      }
      LoggerService.error(
        'Error getting event participants: $eventId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: error,
      );
      return <EventParticipant>[];
    });
  }

  /// Obtener todos los participantes de un evento (incluye confirmaciones - T120 Fase 2)
  /// Retorna todos los participantes independientemente de status o confirmationStatus
  Stream<List<EventParticipant>> getAllEventParticipants(String eventId) {
    return _firestore
        .collection(_collectionName)
        .where('eventId', isEqualTo: eventId)
        .orderBy('registeredAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventParticipant.fromFirestore(doc))
          .toList();
    }).handleError((error) {
      // No registrar errores de permisos cuando el usuario no está autenticado (comportamiento esperado después de logout)
      final errorString = error.toString();
      if (errorString.contains('permission-denied')) {
        // Silenciar errores de permisos - es normal después de logout
        return <EventParticipant>[];
      }
      LoggerService.error(
        'Error getting all event participants: $eventId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: error,
      );
      return <EventParticipant>[];
    });
  }

  /// Obtener todos los participantes registrados de un evento (versión Future)
  Future<List<EventParticipant>> getEventParticipantsFuture(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'registered')
          .orderBy('registeredAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EventParticipant.fromFirestore(doc))
          .toList();
    } catch (e) {
      // No registrar errores de permisos cuando el usuario no está autenticado (comportamiento esperado después de logout)
      final errorString = e.toString();
      if (errorString.contains('permission-denied')) {
        // Silenciar errores de permisos - es normal después de logout
        return [];
      }
      LoggerService.error(
        'Error getting event participants (Future): $eventId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return [];
    }
  }

  /// Verificar si un usuario está apuntado a un evento
  Future<bool> isUserRegistered(String eventId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'registered')
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      LoggerService.error(
        'Error checking user registration: $eventId, $userId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Contar número de participantes registrados en un evento
  Future<int> countParticipants(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'registered')
          .count()
          .get();
      
      return querySnapshot.count ?? 0;
    } catch (e) {
      LoggerService.error(
        'Error counting participants: $eventId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return 0;
    }
  }

  /// Confirmar asistencia a un evento que requiere confirmación (T120 Fase 2)
  /// 
  /// Cambia el confirmationStatus de 'pending' a 'confirmed'
  Future<bool> confirmAttendance({
    required String eventId,
    required String userId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        LoggerService.warning('User $userId has no participation record for event $eventId');
        return false;
      }

      await querySnapshot.docs.first.reference.update({
        'confirmationStatus': 'confirmed',
      });

      LoggerService.database(
        'User $userId confirmed attendance to event $eventId',
        operation: 'UPDATE',
      );
      return true;
    } catch (e) {
      LoggerService.error(
        'Error confirming attendance: $eventId, $userId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Declinar asistencia a un evento que requiere confirmación (T120 Fase 2)
  /// 
  /// Cambia el confirmationStatus de 'pending' a 'declined'
  Future<bool> declineAttendance({
    required String eventId,
    required String userId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        LoggerService.warning('User $userId has no participation record for event $eventId');
        return false;
      }

      await querySnapshot.docs.first.reference.update({
        'confirmationStatus': 'declined',
      });

      LoggerService.database(
        'User $userId declined attendance to event $eventId',
        operation: 'UPDATE',
      );
      return true;
    } catch (e) {
      LoggerService.error(
        'Error declining attendance: $eventId, $userId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Crear registros de confirmación pendiente para todos los participantes del plan (T120 Fase 2)
  /// 
  /// Se llama cuando un evento se marca como requiresConfirmation=true
  /// Crea EventParticipant con confirmationStatus='pending' para todos los participantes del plan
  Future<bool> createPendingConfirmationsForAllParticipants({
    required String eventId,
    required String planId,
  }) async {
    try {
      // Obtener todos los participantes del plan
      final participants = await _participationService.getPlanParticipants(planId);
      
      final batch = _firestore.batch();
      int created = 0;

      for (final participation in participants) {
        // Verificar si ya existe un registro para este usuario y evento
        final existing = await _firestore
            .collection(_collectionName)
            .where('eventId', isEqualTo: eventId)
            .where('userId', isEqualTo: participation.userId)
            .limit(1)
            .get();

        // Si no existe, crear uno nuevo con confirmationStatus='pending'
        if (existing.docs.isEmpty) {
          final eventParticipant = EventParticipant(
            eventId: eventId,
            userId: participation.userId,
            registeredAt: DateTime.now(),
            status: null, // No es registro voluntario
            confirmationStatus: 'pending',
          );
          
          final docRef = _firestore.collection(_collectionName).doc();
          batch.set(docRef, eventParticipant.toFirestore());
          created++;
        } else {
          // Si existe pero no tiene confirmationStatus, actualizarlo
          final existingData = existing.docs.first.data();
          if (existingData['confirmationStatus'] == null) {
            batch.update(existing.docs.first.reference, {
              'confirmationStatus': 'pending',
            });
            created++;
          }
        }
      }

      if (created > 0) {
        await batch.commit();
        LoggerService.database(
          'Created $created pending confirmations for event $eventId',
          operation: 'CREATE',
        );
      }

      return true;
    } catch (e) {
      LoggerService.error(
        'Error creating pending confirmations: $eventId, plan: $planId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return false;
    }
  }

  /// Obtener participantes que requieren confirmación (confirmationStatus='pending')
  Future<List<EventParticipant>> getPendingConfirmations(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('confirmationStatus', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => EventParticipant.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error getting pending confirmations: $eventId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return [];
    }
  }

  /// Obtener participantes confirmados (confirmationStatus='confirmed')
  Future<List<EventParticipant>> getConfirmedParticipants(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('confirmationStatus', isEqualTo: 'confirmed')
          .get();

      return snapshot.docs
          .map((doc) => EventParticipant.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error getting confirmed participants: $eventId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return [];
    }
  }

  /// Obtener el estado de confirmación de un usuario para un evento
  /// Retorna: 'pending', 'confirmed', 'declined', o null si no aplica
  Future<String?> getUserConfirmationStatus(String eventId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final data = querySnapshot.docs.first.data();
      return data['confirmationStatus'] as String?;
    } catch (e) {
      LoggerService.error(
        'Error getting user confirmation status: $eventId, $userId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return null;
    }
  }

  /// Eliminar todos los participantes de un evento (usado al eliminar el evento)
  Future<bool> deleteAllParticipants(String eventId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      LoggerService.database(
        'All participants deleted for event $eventId',
        operation: 'DELETE',
      );
      return true;
    } catch (e) {
      LoggerService.error(
        'Error deleting all participants for event: $eventId',
        context: 'EVENT_PARTICIPANT_SERVICE',
        error: e,
      );
      return false;
    }
  }
}

