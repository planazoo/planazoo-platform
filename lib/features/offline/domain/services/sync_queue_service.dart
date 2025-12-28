import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_queue_item.dart';
import 'hive_service.dart';
import '../../../../shared/services/logger_service.dart';

/// Servicio para gestionar la cola de sincronización (solo móviles)
/// 
/// Maneja operaciones pendientes de sincronizar con Firestore,
/// con retry automático y backoff exponencial.
class SyncQueueService {
  static const _uuid = Uuid();
  final String _boxName = HiveService.boxNameSyncQueue;

  /// Verifica si estamos en móvil
  bool get isMobile => HiveService.isMobile;

  /// Obtiene la box de sincronización
  Future<Box> _getBox() async {
    if (!isMobile) {
      throw UnsupportedError('SyncQueueService solo funciona en móviles');
    }
    return await HiveService.openBox(_boxName);
  }

  /// Añade un item a la cola de sincronización
  Future<String> enqueue({
    required String operation, // 'create', 'update', 'delete'
    required String collection, // 'plans', 'events', 'participations', etc.
    String? documentId, // ID del documento (null si es create)
    required Map<String, dynamic> data, // Datos a sincronizar
  }) async {
    if (!isMobile) {
      LoggerService.info('SyncQueueService.enqueue ignorado (no móvil)', context: 'SYNC_QUEUE');
      return '';
    }

    try {
      final item = SyncQueueItem(
        id: _uuid.v4(),
        operation: operation,
        collection: collection,
        documentId: documentId ?? '',
        data: data,
        createdAt: DateTime.now(),
      );

      final box = await _getBox();
      await box.put(item.id, item.toMap());
      
      LoggerService.database(
        'Item añadido a cola de sincronización: ${item.operation} ${item.collection}',
        operation: 'ENQUEUE',
      );

      return item.id;
    } catch (e) {
      LoggerService.error('Error añadiendo item a cola', context: 'SYNC_QUEUE', error: e);
      rethrow;
    }
  }

  /// Obtiene todos los items pendientes
  Future<List<SyncQueueItem>> getPendingItems() async {
    if (!isMobile) return [];

    try {
      final box = await _getBox();
      final items = <SyncQueueItem>[];

      for (var key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          try {
            items.add(SyncQueueItem.fromMap(Map<String, dynamic>.from(data as Map)));
          } catch (e) {
            LoggerService.error('Error parseando item de cola: $key', context: 'SYNC_QUEUE', error: e);
          }
        }
      }

      // Ordenar por fecha de creación (más antiguos primero)
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return items;
    } catch (e) {
      LoggerService.error('Error obteniendo items pendientes', context: 'SYNC_QUEUE', error: e);
      return [];
    }
  }

  /// Obtiene items que pueden ser reintentados
  Future<List<SyncQueueItem>> getRetryableItems() async {
    final pending = await getPendingItems();
    return pending.where((item) => item.canRetry).toList();
  }

  /// Marca un item como procesado exitosamente (lo elimina de la cola)
  Future<void> markAsCompleted(String itemId) async {
    if (!isMobile) return;

    try {
      final box = await _getBox();
      await box.delete(itemId);
      LoggerService.database(
        'Item completado y eliminado de cola: $itemId',
        operation: 'COMPLETE',
      );
    } catch (e) {
      LoggerService.error('Error marcando item como completado', context: 'SYNC_QUEUE', error: e);
      rethrow;
    }
  }

  /// Marca un item como fallido (incrementa retry count)
  Future<void> markAsFailed(String itemId, String error) async {
    if (!isMobile) return;

    try {
      final box = await _getBox();
      final data = box.get(itemId);
      if (data == null) return;

      final item = SyncQueueItem.fromMap(Map<String, dynamic>.from(data as Map));
      final updatedItem = item.copyWith(
        retryCount: item.retryCount + 1,
        lastRetryAt: DateTime.now(),
        error: error,
      );

      await box.put(itemId, updatedItem.toMap());
      
      LoggerService.database(
        'Item marcado como fallido (intento ${updatedItem.retryCount}/5): $itemId',
        operation: 'FAIL',
      );
    } catch (e) {
      LoggerService.error('Error marcando item como fallido', context: 'SYNC_QUEUE', error: e);
      rethrow;
    }
  }

  /// Elimina un item de la cola (usado para limpiar items que excedieron el máximo de reintentos)
  Future<void> removeItem(String itemId) async {
    if (!isMobile) return;

    try {
      final box = await _getBox();
      await box.delete(itemId);
      LoggerService.database(
        'Item eliminado de cola (máximo de reintentos alcanzado): $itemId',
        operation: 'REMOVE',
      );
    } catch (e) {
      LoggerService.error('Error eliminando item de cola', context: 'SYNC_QUEUE', error: e);
      rethrow;
    }
  }

  /// Limpia items que excedieron el máximo de reintentos
  Future<int> cleanupFailedItems() async {
    if (!isMobile) return 0;

    try {
      final pending = await getPendingItems();
      final failed = pending.where((item) => !item.canRetry && item.retryCount >= 5).toList();
      
      for (var item in failed) {
        await removeItem(item.id);
      }

      if (failed.isNotEmpty) {
        LoggerService.database(
          '${failed.length} items eliminados (máximo de reintentos alcanzado)',
          operation: 'CLEANUP',
        );
      }

      return failed.length;
    } catch (e) {
      LoggerService.error('Error limpiando items fallidos', context: 'SYNC_QUEUE', error: e);
      return 0;
    }
  }

  /// Obtiene el número de items pendientes
  Future<int> getPendingCount() async {
    if (!isMobile) return 0;
    final pending = await getPendingItems();
    return pending.length;
  }

  /// Limpia toda la cola (útil para testing o reset)
  Future<void> clearAll() async {
    if (!isMobile) return;

    try {
      final box = await _getBox();
      await box.clear();
      LoggerService.database('Cola de sincronización limpiada completamente', operation: 'CLEAR');
    } catch (e) {
      LoggerService.error('Error limpiando cola', context: 'SYNC_QUEUE', error: e);
      rethrow;
    }
  }
}

