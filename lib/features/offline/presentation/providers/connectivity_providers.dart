import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/connectivity_service.dart';

/// Provider para ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  
  // Inicializar el servicio
  service.initialize();
  
  // Limpiar cuando el provider se destruye
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// StreamProvider para el estado de conectividad
/// Retorna true si está online, false si está offline
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

/// Provider para el estado actual de conectividad (síncrono)
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStatusProvider);
  return connectivityAsync.when(
    data: (isOnline) => isOnline,
    loading: () => true, // Por defecto asumimos online mientras carga
    error: (_, __) => false, // Si hay error, asumimos offline
  );
});

