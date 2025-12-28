import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../features/calendar/domain/models/plan.dart';
import '../../../../features/calendar/domain/models/event.dart';
import '../../../../features/calendar/domain/models/plan_participation.dart';
import '../../../../shared/services/logger_service.dart';
import 'plan_local_service.dart';
import 'event_local_service.dart';
import 'participation_local_service.dart';
import 'sync_service.dart';
import 'hive_service.dart';

/// Servicio para sincronización en tiempo real con Firestore listeners (solo móviles)
/// 
/// Escucha cambios en Firestore y sincroniza automáticamente con la base de datos local.
class RealtimeSyncService {
  final PlanLocalService _planLocalService = PlanLocalService();
  final EventLocalService _eventLocalService = EventLocalService();
  final ParticipationLocalService _participationLocalService = ParticipationLocalService();
  final SyncService _syncService = SyncService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, StreamSubscription> _subscriptions = {};
  bool _isInitialized = false;

  /// Verifica si estamos en móvil
  bool get isMobile => HiveService.isMobile;

  /// Inicializa los listeners de sincronización en tiempo real
  Future<void> initialize(String userId) async {
    if (!isMobile) {
      LoggerService.info('RealtimeSyncService no se inicializa (no móvil)', context: 'REALTIME_SYNC');
      return;
    }

    if (_isInitialized) {
      LoggerService.info('RealtimeSyncService ya está inicializado', context: 'REALTIME_SYNC');
      return;
    }

    try {
      // Inicializar listeners para planes
      await _initializePlansListener(userId);
      
      // Inicializar listeners para participaciones
      await _initializeParticipationsListener(userId);
      
      // Los eventos se sincronizan cuando cambian los planes
      _isInitialized = true;
      
      LoggerService.database('RealtimeSyncService inicializado para usuario: $userId', operation: 'INIT');
    } catch (e) {
      LoggerService.error('Error inicializando RealtimeSyncService', context: 'REALTIME_SYNC', error: e);
    }
  }

  /// Inicializa listener para planes del usuario
  Future<void> _initializePlansListener(String userId) async {
    final subscription = _firestore
        .collection('plans')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) async {
        for (var change in snapshot.docChanges) {
          await _handlePlanChange(change);
        }
      },
      onError: (error) {
        LoggerService.error('Error en listener de planes', context: 'REALTIME_SYNC', error: error);
      },
    );

    _subscriptions['plans_$userId'] = subscription;
  }

  /// Maneja cambios en planes
  Future<void> _handlePlanChange(DocumentChange change) async {
    try {
      final plan = Plan.fromFirestore(change.doc);
      
      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          // Guardar o actualizar en local
          await _planLocalService.savePlan(plan);
          
          // Inicializar listener de eventos para este plan
          if (plan.id != null) {
            await _initializeEventsListener(plan.id!);
          }
          
          LoggerService.database(
            'Plan sincronizado en tiempo real: ${plan.id} (${change.type == DocumentChangeType.added ? "creado" : "actualizado"})',
            operation: 'REALTIME_SYNC',
          );
          break;
        case DocumentChangeType.removed:
          // Eliminar de local
          if (plan.id != null) {
            await _planLocalService.deletePlan(plan.id!);
            
            // Cancelar listener de eventos para este plan
            _subscriptions['events_${plan.id}']?.cancel();
            _subscriptions.remove('events_${plan.id}');
          }
          
          LoggerService.database(
            'Plan eliminado en tiempo real: ${plan.id}',
            operation: 'REALTIME_SYNC',
          );
          break;
      }
    } catch (e) {
      LoggerService.error('Error manejando cambio de plan', context: 'REALTIME_SYNC', error: e);
    }
  }

  /// Inicializa listener para eventos de un plan
  Future<void> _initializeEventsListener(String planId) async {
    // Si ya existe un listener para este plan, no crear otro
    if (_subscriptions.containsKey('events_$planId')) {
      return;
    }

    final subscription = _firestore
        .collection('events')
        .where('planId', isEqualTo: planId)
        .snapshots()
        .listen(
      (snapshot) async {
        for (var change in snapshot.docChanges) {
          await _handleEventChange(change);
        }
      },
      onError: (error) {
        LoggerService.error('Error en listener de eventos', context: 'REALTIME_SYNC', error: error);
      },
    );

    _subscriptions['events_$planId'] = subscription;
  }

  /// Maneja cambios en eventos
  Future<void> _handleEventChange(DocumentChange change) async {
    try {
      final event = Event.fromFirestore(change.doc);
      
      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          // Guardar o actualizar en local
          await _eventLocalService.saveEvent(event);
          
          LoggerService.database(
            'Evento sincronizado en tiempo real: ${event.id} (${change.type == DocumentChangeType.added ? "creado" : "actualizado"})',
            operation: 'REALTIME_SYNC',
          );
          break;
        case DocumentChangeType.removed:
          // Eliminar de local
          if (event.id != null) {
            await _eventLocalService.deleteEvent(event.id!);
          }
          
          LoggerService.database(
            'Evento eliminado en tiempo real: ${event.id}',
            operation: 'REALTIME_SYNC',
          );
          break;
      }
    } catch (e) {
      LoggerService.error('Error manejando cambio de evento', context: 'REALTIME_SYNC', error: e);
    }
  }

  /// Inicializa listener para participaciones del usuario
  Future<void> _initializeParticipationsListener(String userId) async {
    final subscription = _firestore
        .collection('plan_participations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) async {
        for (var change in snapshot.docChanges) {
          await _handleParticipationChange(change);
        }
      },
      onError: (error) {
        LoggerService.error('Error en listener de participaciones', context: 'REALTIME_SYNC', error: error);
      },
    );

    _subscriptions['participations_$userId'] = subscription;
  }

  /// Maneja cambios en participaciones
  Future<void> _handleParticipationChange(DocumentChange change) async {
    try {
      final participation = PlanParticipation.fromFirestore(change.doc);
      
      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          // Guardar o actualizar en local
          await _participationLocalService.saveParticipation(participation);
          
          // Si es una nueva participación, inicializar listener de eventos para ese plan
          if (change.type == DocumentChangeType.added && participation.planId.isNotEmpty) {
            await _initializeEventsListener(participation.planId);
          }
          
          LoggerService.database(
            'Participación sincronizada en tiempo real: ${participation.id} (${change.type == DocumentChangeType.added ? "creada" : "actualizada"})',
            operation: 'REALTIME_SYNC',
          );
          break;
        case DocumentChangeType.removed:
          // Eliminar de local
          if (participation.id != null) {
            await _participationLocalService.deleteParticipation(participation.id!);
          }
          
          LoggerService.database(
            'Participación eliminada en tiempo real: ${participation.id}',
            operation: 'REALTIME_SYNC',
          );
          break;
      }
    } catch (e) {
      LoggerService.error('Error manejando cambio de participación', context: 'REALTIME_SYNC', error: e);
    }
  }

  /// Detiene todos los listeners
  void dispose() {
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _isInitialized = false;
    LoggerService.database('RealtimeSyncService detenido', operation: 'DISPOSE');
  }
}

