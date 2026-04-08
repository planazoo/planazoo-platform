import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/shared/services/fcm_service.dart';
import 'package:unp_calendario/shared/services/logger_service.dart';

/// Provider que inicializa FCM cuando el usuario se autentica
final fcmInitializerProvider = Provider<void>((ref) {
  final authState = ref.watch(authNotifierProvider);
  LoggerService.info(
    'fcmInitializerProvider auth(isAuthenticated=${authState.isAuthenticated}, hasUser=${authState.user != null})',
    context: 'FCM_BOOT',
  );
  
  if (authState.isAuthenticated && authState.user != null) {
    LoggerService.info(
      'fcmInitializerProvider initialize(userId=${authState.user!.id})',
      context: 'FCM_BOOT',
    );
    // Inicializar FCM de forma asíncrona (no bloquea la UI)
    FCMService.initialize(authState.user!.id).then((success) {
      LoggerService.info(
        'fcmInitializerProvider initialize(done success=$success)',
        context: 'FCM_BOOT',
      );
      if (success) {
        // FCM inicializado correctamente
      }
    });
  } else {
    LoggerService.info('fcmInitializerProvider cleanup()', context: 'FCM_BOOT');
    // Usuario no autenticado, limpiar tokens
    FCMService.cleanup();
  }
  
  // Este provider solo observa, no retorna valor
  return;
});
