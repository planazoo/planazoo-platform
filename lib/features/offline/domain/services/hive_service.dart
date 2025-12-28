import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../shared/services/logger_service.dart';

/// Servicio para inicializar y gestionar Hive (solo para móviles)
/// 
/// Este servicio solo se inicializa en iOS y Android.
/// Para web, las operaciones offline se manejan de otra forma.
class HiveService {
  static const String _boxNamePlans = 'plans';
  static const String _boxNameEvents = 'events';
  static const String _boxNameParticipations = 'participations';
  static const String _boxNameSyncQueue = 'sync_queue';
  
  static bool _isInitialized = false;
  static bool _isMobile = false;

  /// Verifica si estamos en una plataforma móvil
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Inicializa Hive solo si estamos en móvil
  static Future<void> initialize() async {
    if (kIsWeb) {
      LoggerService.info('Hive no se inicializa en web', context: 'HIVE_SERVICE');
      return;
    }

    if (!isMobile) {
      LoggerService.info('Hive solo se inicializa en móviles (iOS/Android)', context: 'HIVE_SERVICE');
      return;
    }

    if (_isInitialized) {
      LoggerService.info('Hive ya está inicializado', context: 'HIVE_SERVICE');
      return;
    }

    try {
      await Hive.initFlutter();
      _isMobile = true;
      _isInitialized = true;
      LoggerService.database('Hive inicializado correctamente', operation: 'INIT');
    } catch (e) {
      LoggerService.error('Error inicializando Hive', context: 'HIVE_SERVICE', error: e);
      rethrow;
    }
  }

  /// Abre una box de Hive (solo móviles)
  static Future<Box> openBox(String boxName) async {
    if (!_isInitialized || !_isMobile) {
      throw StateError('Hive no está inicializado o no estamos en móvil');
    }
    return await Hive.openBox(boxName);
  }

  /// Obtiene una box ya abierta (solo móviles)
  static Box? getBox(String boxName) {
    if (!_isInitialized || !_isMobile) {
      return null;
    }
    if (!Hive.isBoxOpen(boxName)) {
      return null;
    }
    return Hive.box(boxName);
  }

  /// Cierra todas las boxes
  static Future<void> closeAll() async {
    if (!_isInitialized) return;
    await Hive.close();
    _isInitialized = false;
    LoggerService.database('Todas las boxes de Hive cerradas', operation: 'CLOSE');
  }

  // Getters para nombres de boxes
  static String get boxNamePlans => _boxNamePlans;
  static String get boxNameEvents => _boxNameEvents;
  static String get boxNameParticipations => _boxNameParticipations;
  static String get boxNameSyncQueue => _boxNameSyncQueue;
}

