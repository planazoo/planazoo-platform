import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/domain/models/auth_state.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/auth_service.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:unp_calendario/features/auth/presentation/notifiers/user_notifier.dart';

// Providers para servicios
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Provider para AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authService: ref.read(authServiceProvider),
    userService: ref.read(userServiceProvider),
  );
});

// Provider para el usuario actual
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

// Provider para verificar si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
});

// Provider para verificar si está cargando
final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isLoading;
});

// Provider para obtener el error actual
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.errorMessage;
});

// Provider para UserNotifier
final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  return UserNotifier(
    userService: ref.read(userServiceProvider),
  );
});

// Provider para el usuario actual (alternativo)
final currentUserDataProvider = Provider<UserModel?>((ref) {
  final userState = ref.watch(userNotifierProvider);
  return userState.value;
});

// Provider para verificar si el usuario está cargando
final userLoadingProvider = Provider<bool>((ref) {
  final userState = ref.watch(userNotifierProvider);
  return userState.isLoading;
});

// Provider para obtener el error del usuario
final userErrorProvider = Provider<String?>((ref) {
  final userState = ref.watch(userNotifierProvider);
  return userState.hasError ? userState.error.toString() : null;
});
