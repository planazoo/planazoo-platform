import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../../shared/services/logger_service.dart';

/// Servicio para detectar el estado de conectividad (solo móviles)
/// 
/// Monitorea el estado de conexión a internet y notifica cambios.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true; // Por defecto asumimos online

  /// Stream del estado de conectividad (true = online, false = offline)
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  /// Estado actual de conectividad
  bool get isOnline => _isOnline;

  /// Inicializa el monitoreo de conectividad (solo móviles)
  Future<void> initialize() async {
    if (kIsWeb) {
      LoggerService.info('ConnectivityService no se inicializa en web', context: 'CONNECTIVITY_SERVICE');
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      LoggerService.info('ConnectivityService solo funciona en móviles', context: 'CONNECTIVITY_SERVICE');
      return;
    }

    try {
      // Verificar estado inicial
      final initialResult = await _connectivity.checkConnectivity();
      _isOnline = _hasInternetConnection(initialResult);
      _connectivityController?.add(_isOnline);

      // Escuchar cambios
      _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = _hasInternetConnection(results);
        
        if (wasOnline != _isOnline) {
          LoggerService.info(
            'Estado de conectividad cambió: ${_isOnline ? "ONLINE" : "OFFLINE"}',
            context: 'CONNECTIVITY_SERVICE',
          );
          _connectivityController?.add(_isOnline);
        }
      });

      LoggerService.database(
        'ConnectivityService inicializado (estado inicial: ${_isOnline ? "ONLINE" : "OFFLINE"})',
        operation: 'INIT',
      );
    } catch (e) {
      LoggerService.error('Error inicializando ConnectivityService', context: 'CONNECTIVITY_SERVICE', error: e);
    }
  }

  /// Verifica si hay conexión a internet basándose en los resultados de conectividad
  bool _hasInternetConnection(List<ConnectivityResult> results) {
    // Si no hay resultados, asumimos offline
    if (results.isEmpty) return false;
    
    // Si hay WiFi o móvil, asumimos online
    // Nota: connectivity_plus no puede verificar si realmente hay internet,
    // solo si hay conexión de red. Para verificación real de internet,
    // se necesitaría hacer un ping o request HTTP.
    return results.any((result) => 
      result == ConnectivityResult.wifi || 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet
    );
  }

  /// Verifica el estado actual de conectividad
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = _hasInternetConnection(results);
      return _isOnline;
    } catch (e) {
      LoggerService.error('Error verificando conectividad', context: 'CONNECTIVITY_SERVICE', error: e);
      return false;
    }
  }

  /// Detiene el monitoreo de conectividad
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _connectivityController?.close();
    _connectivityController = null;
  }
}

