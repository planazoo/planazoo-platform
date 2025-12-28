import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/accommodation.dart';
import '../../../../shared/services/logger_service.dart';

class AccommodationService {
  static const String _collectionName = 'events'; // Los alojamientos están en events
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener todos los alojamientos de un plan
  Stream<List<Accommodation>> getAccommodations(String planId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: planId)
          .where('typeFamily', isEqualTo: 'alojamiento')
          .orderBy('checkIn')
          .snapshots()
          .map((snapshot) {
        final accommodations = snapshot.docs.map((doc) {
          try {
            return Accommodation.fromFirestore(doc);
          } catch (e) {
            LoggerService.error('Error parseando alojamiento ${doc.id}', context: 'ACCOMMODATION_SERVICE', error: e);
            return null;
          }
        }).where((acc) => acc != null).cast<Accommodation>().toList();
        
        LoggerService.database('Alojamientos cargados: ${accommodations.length} para plan $planId', operation: 'QUERY');
        return accommodations;
      }).handleError((error) {
        LoggerService.error('Error en stream de alojamientos para plan $planId', context: 'ACCOMMODATION_SERVICE', error: error);
        // Si falta el índice, devolver lista vacía en lugar de fallar completamente
        if (error.toString().contains('index') || error.toString().contains('Index')) {
          LoggerService.warning('Parece que falta un índice compuesto en Firestore. Verifica firestore.indexes.json', context: 'ACCOMMODATION_SERVICE');
        }
        return <Accommodation>[];
      });
    } catch (e) {
      LoggerService.error('Error creando stream de alojamientos para plan $planId', context: 'ACCOMMODATION_SERVICE', error: e);
      return Stream.value(<Accommodation>[]);
    }
  }

  /// Obtener un alojamiento por ID
  Future<Accommodation?> getAccommodationById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['typeFamily'] == 'alojamiento') {
          return Accommodation.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      // Error getting accommodation: $e
      return null;
    }
  }

  /// Crear un nuevo alojamiento
  Future<String?> createAccommodation(Accommodation accommodation) async {
    try {
      final data = accommodation.toFirestore();
      LoggerService.database('Creando alojamiento: ${accommodation.hotelName} para plan ${accommodation.planId}', operation: 'CREATE');
      final docRef = await _firestore.collection(_collectionName).add(data);
      LoggerService.database('Alojamiento creado con ID: ${docRef.id}', operation: 'CREATE');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error creando alojamiento', context: 'ACCOMMODATION_SERVICE', error: e);
      return null;
    }
  }

  /// Actualizar un alojamiento existente
  Future<bool> updateAccommodation(Accommodation accommodation) async {
    if (accommodation.id == null) return false;
    
    try {
      final updatedAccommodation = accommodation.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collectionName)
          .doc(accommodation.id)
          .update(updatedAccommodation.toFirestore());
      return true;
    } catch (e) {
      // Error updating accommodation: $e
      return false;
    }
  }

  /// Eliminar un alojamiento
  Future<bool> deleteAccommodation(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      return true;
    } catch (e) {
      // Error deleting accommodation: $e
      return false;
    }
  }

  /// Guardar alojamiento (crear o actualizar)
  Future<bool> saveAccommodation(Accommodation accommodation) async {
    if (accommodation.id == null) {
      // Crear nuevo alojamiento
      final now = DateTime.now();
      final newAccommodation = accommodation.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      LoggerService.database('Guardando nuevo alojamiento: ${newAccommodation.hotelName}', operation: 'SAVE');
      final id = await createAccommodation(newAccommodation);
      if (id != null) {
        LoggerService.database('Alojamiento guardado exitosamente con ID: $id', operation: 'SAVE');
      } else {
        LoggerService.error('No se pudo crear el alojamiento', context: 'ACCOMMODATION_SERVICE');
      }
      return id != null;
    } else {
      // Actualizar alojamiento existente
      LoggerService.database('Actualizando alojamiento: ${accommodation.id}', operation: 'UPDATE');
      final success = await updateAccommodation(accommodation);
      if (success) {
        LoggerService.database('Alojamiento actualizado exitosamente: ${accommodation.id}', operation: 'UPDATE');
      } else {
        LoggerService.error('No se pudo actualizar el alojamiento: ${accommodation.id}', context: 'ACCOMMODATION_SERVICE');
      }
      return success;
    }
  }

  /// Mover un alojamiento a nuevas fechas
  Future<bool> moveAccommodation(Accommodation accommodation, DateTime newCheckIn, DateTime newCheckOut) async {
    try {
      final movedAccommodation = accommodation.copyWith(
        checkIn: newCheckIn,
        checkOut: newCheckOut,
        updatedAt: DateTime.now(),
      );
      return await updateAccommodation(movedAccommodation);
    } catch (e) {
      // Error moving accommodation: $e
      return false;
    }
  }

  /// Verificar si hay conflictos de fechas para un alojamiento
  Future<bool> hasDateConflict(Accommodation accommodation, {String? excludeId}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('planId', isEqualTo: accommodation.planId)
          .where('typeFamily', isEqualTo: 'alojamiento');

      if (excludeId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: excludeId);
      }

      final querySnapshot = await query.get();
      
      for (final doc in querySnapshot.docs) {
        final existingAccommodation = Accommodation.fromFirestore(doc);
        
        // Verificar si hay solapamiento de fechas
        if (_hasDateOverlap(accommodation, existingAccommodation)) {
          return true; // Hay conflicto
        }
      }
      
      return false; // No hay conflictos
    } catch (e) {
      // Error checking date conflicts: $e
      return false;
    }
  }

  /// Verificar si dos alojamientos tienen fechas solapadas
  bool _hasDateOverlap(Accommodation acc1, Accommodation acc2) {
    // acc1.checkIn < acc2.checkOut && acc1.checkOut > acc2.checkIn
    return acc1.checkIn.isBefore(acc2.checkOut) && acc1.checkOut.isAfter(acc2.checkIn);
  }
}
