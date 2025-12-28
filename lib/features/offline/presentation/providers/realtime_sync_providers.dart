import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/realtime_sync_service.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/auth/domain/models/auth_state.dart';

/// Provider para RealtimeSyncService
/// 
/// Se inicializa automáticamente cuando el usuario se autentica
final realtimeSyncServiceProvider = Provider<RealtimeSyncService>((ref) {
  final service = RealtimeSyncService();
  
  // Inicializar cuando el usuario esté autenticado
  ref.listen(authNotifierProvider, (previous, next) {
    if (next.status == AuthStatus.authenticated && next.user != null) {
      // Inicializar servicio de sincronización en tiempo real
      service.initialize(next.user!.id);
    } else if (previous?.status == AuthStatus.authenticated) {
      // Si el usuario se desautenticó, detener el servicio
      service.dispose();
    }
  });
  
  // Limpiar cuando el provider se destruye
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider que fuerza la inicialización del servicio (para asegurar que se monitoree)
final realtimeSyncInitializerProvider = Provider<void>((ref) {
  // Solo observar el provider para forzar su inicialización
  ref.watch(realtimeSyncServiceProvider);
  return;
});

