import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/shared/services/fcm_service.dart';

/// Provider que inicializa FCM cuando el usuario se autentica
final fcmInitializerProvider = Provider<void>((ref) {
  final authState = ref.watch(authNotifierProvider);
  
  if (authState.isAuthenticated && authState.user != null) {
    // Inicializar FCM de forma asíncrona (no bloquea la UI)
    FCMService.initialize(authState.user!.id).then((success) {
      if (success) {
        // FCM inicializado correctamente
      }
    });
  } else {
    // Usuario no autenticado, limpiar tokens
    FCMService.cleanup();
  }
  
  // Este provider solo observa, no retorna valor
  return;
});
