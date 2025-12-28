import 'package:hive_flutter/hive_flutter.dart';
import 'hive_service.dart';
import '../../../../shared/services/logger_service.dart';

/// Servicio base para persistencia local con Hive (solo móviles)
/// 
/// Proporciona métodos CRUD básicos para almacenar datos localmente.
/// Solo funciona en iOS y Android.
abstract class LocalStorageService<T> {
  final String boxName;

  LocalStorageService(this.boxName);

  /// Verifica si estamos en móvil
  bool get isMobile => HiveService.isMobile;

  /// Convierte un objeto a Map para almacenar en Hive
  Map<String, dynamic> toMap(T item);

  /// Crea un objeto desde un Map de Hive
  T fromMap(Map<String, dynamic> map);

  /// Obtiene la box de Hive (solo móviles)
  Future<Box> _getBox() async {
    if (!isMobile) {
      throw UnsupportedError('LocalStorageService solo funciona en móviles');
    }
    return await HiveService.openBox(boxName);
  }

  /// Guarda un item localmente
  Future<void> save(String key, T item) async {
    if (!isMobile) {
      LoggerService.info('LocalStorageService.save ignorado (no móvil)', context: 'LOCAL_STORAGE');
      return;
    }

    try {
      final box = await _getBox();
      await box.put(key, toMap(item));
      LoggerService.database('Item guardado localmente: $key [$boxName]', operation: 'SAVE');
    } catch (e) {
      LoggerService.error('Error guardando item localmente', context: 'LOCAL_STORAGE', error: e);
      rethrow;
    }
  }

  /// Obtiene un item por su key
  Future<T?> get(String key) async {
    if (!isMobile) return null;

    try {
      final box = await _getBox();
      final data = box.get(key);
      if (data == null) return null;
      return fromMap(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      LoggerService.error('Error obteniendo item localmente', context: 'LOCAL_STORAGE', error: e);
      return null;
    }
  }

  /// Obtiene todos los items
  Future<List<T>> getAll() async {
    if (!isMobile) return [];

    try {
      final box = await _getBox();
      final items = <T>[];
      for (var key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          try {
            items.add(fromMap(Map<String, dynamic>.from(data as Map)));
          } catch (e) {
            LoggerService.error('Error parseando item: $key', context: 'LOCAL_STORAGE', error: e);
          }
        }
      }
      return items;
    } catch (e) {
      LoggerService.error('Error obteniendo todos los items', context: 'LOCAL_STORAGE', error: e);
      return [];
    }
  }

  /// Elimina un item
  Future<void> delete(String key) async {
    if (!isMobile) return;

    try {
      final box = await _getBox();
      await box.delete(key);
      LoggerService.database('Item eliminado localmente: $key [$boxName]', operation: 'DELETE');
    } catch (e) {
      LoggerService.error('Error eliminando item localmente', context: 'LOCAL_STORAGE', error: e);
      rethrow;
    }
  }

  /// Elimina todos los items
  Future<void> deleteAll() async {
    if (!isMobile) return;

    try {
      final box = await _getBox();
      await box.clear();
      LoggerService.database('Todos los items eliminados [$boxName]', operation: 'DELETE_ALL');
    } catch (e) {
      LoggerService.error('Error eliminando todos los items', context: 'LOCAL_STORAGE', error: e);
      rethrow;
    }
  }

  /// Verifica si existe un item
  Future<bool> exists(String key) async {
    if (!isMobile) return false;

    try {
      final box = await _getBox();
      return box.containsKey(key);
    } catch (e) {
      LoggerService.error('Error verificando existencia', context: 'LOCAL_STORAGE', error: e);
      return false;
    }
  }
}

