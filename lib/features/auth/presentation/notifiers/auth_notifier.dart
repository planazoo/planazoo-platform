import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:unp_calendario/features/auth/domain/models/auth_state.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/auth_service.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserService _userService;
  bool _isRegistering = false; // Flag para evitar conflictos durante registro

  AuthNotifier({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService,
        super(const AuthState(status: AuthStatus.initial)) {
    _init();
  }

  void _init() {
    // Escuchar cambios en el estado de autenticación
    _authService.userChanges.listen((fb_auth.User? firebaseUser) async {
      // No procesar si estamos en medio de un registro
      if (_isRegistering) {
        return;
      }
      
      if (firebaseUser != null) {
        // Verificar si el email está verificado ANTES de procesar
        if (!firebaseUser.emailVerified) {
          // Cerrar sesión si el email no está verificado
          await _authService.signOut();
          state = AuthState(
            status: AuthStatus.error,
            errorMessage: 'Por favor, verifica tu email antes de iniciar sesión. Revisa tu bandeja de entrada.',
          );
          return;
        }
        
        // Usuario autenticado y verificado - obtener datos existentes
        try {
          final userModel = await _userService.getUser(firebaseUser.uid);
          
          if (userModel != null) {
            // Actualizar último login
            final updatedUser = userModel.copyWith(lastLoginAt: DateTime.now());
            await _userService.updateUser(updatedUser);
            
            state = AuthState(
              status: AuthStatus.authenticated,
              user: updatedUser,
            );
          } else {
            // Usuario no existe en Firestore
            state = AuthState(
              status: AuthStatus.error,
              errorMessage: 'Usuario no encontrado. Por favor, regístrate primero.',
            );
          }
        } catch (e) {
          state = AuthState(
            status: AuthStatus.error,
            errorMessage: 'Error al obtener datos del usuario: $e',
          );
        }
      } else {
        // Usuario no autenticado
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  // Iniciar sesión con email y contraseña
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.signInWithEmailAndPassword(email, password);
      // El estado se actualizará automáticamente a través del stream
      // La verificación de email se hace en _init()
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Registrarse con email y contraseña
  Future<void> registerWithEmailAndPassword(String email, String password, {String? displayName}) async {
    try {
      _isRegistering = true; // Marcar que estamos registrando
      state = state.copyWith(status: AuthStatus.loading);
      
      await _authService.registerWithEmailAndPassword(email, password);
      
      // Actualizar displayName si se proporciona
      if (displayName != null && displayName.isNotEmpty) {
        await _authService.updateDisplayName(displayName);
      }
      
      // Crear usuario en Firestore después del registro exitoso
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final userModel = UserModel.fromFirebaseAuth(currentUser);
        await _userService.createUser(userModel);
        
        // Enviar email de verificación
        await _authService.sendEmailVerification();
        
        // Cerrar sesión inmediatamente después del registro
        await _authService.signOut();
        
        // Emitir estado de éxito de registro
        state = AuthState(
          status: AuthStatus.registrationSuccess,
          user: userModel,
        );
      }
      
      _isRegistering = false; // Marcar que terminamos de registrar
    } catch (e) {
      _isRegistering = false; // Marcar que terminamos de registrar
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Alias para compatibilidad
  Future<void> createUserWithEmailAndPassword(String email, String password, {String? displayName}) async {
    return registerWithEmailAndPassword(email, password, displayName: displayName);
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // El estado se actualizará automáticamente a través del stream
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error al cerrar sesión: $e',
      );
    }
  }

  // Método para limpiar usuarios huérfanos (solo para desarrollo)
  Future<void> clearOrphanedUsers() async {
    try {
      print('🧹 Limpiando usuarios huérfanos...');
      await _authService.signOut();
      print('✅ Usuarios huérfanos limpiados');
    } catch (e) {
      print('❌ Error al limpiar usuarios huérfanos: $e');
    }
  }

  // Enviar email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = const AuthState(status: AuthStatus.loading);
      await _authService.sendPasswordResetEmail(email);
      // No cambiar el estado aquí, solo limpiar el loading
      // El SnackBar de éxito se maneja en la UI
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Enviar email de verificación
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Reenviar email de verificación (para usuarios no autenticados)
  Future<void> resendEmailVerification(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      // Iniciar sesión temporalmente
      await _authService.signInWithEmailAndPassword(email, password);
      
      // Enviar email de verificación
      await _authService.sendEmailVerification();
      
      // Cerrar sesión inmediatamente
      await _authService.signOut();
      
      state = AuthState(
        status: AuthStatus.registrationSuccess,
        errorMessage: 'Email de verificación reenviado. Revisa tu bandeja de entrada.',
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Actualizar perfil del usuario
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (state.user == null) return;

    try {
      // Actualizar en Firebase Auth
      if (displayName != null) {
        await _authService.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await _authService.updatePhotoURL(photoURL);
      }

      // Actualizar en Firestore
      final updatedUser = state.user!.copyWith(
        displayName: displayName ?? state.user!.displayName,
        photoURL: photoURL ?? state.user!.photoURL,
      );
      
      await _userService.updateUser(updatedUser);
      
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error al actualizar perfil: $e',
      );
    }
  }

  // Cambiar contraseña
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (state.user == null) return;

    try {
      // Reautenticar usuario
      await _authService.reauthenticateUser(state.user!.email, currentPassword);
      
      // Cambiar contraseña
      await _authService.updatePassword(newPassword);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Eliminar cuenta
  Future<void> deleteAccount(String password) async {
    if (state.user == null) return;

    try {
      // Reautenticar usuario
      await _authService.reauthenticateUser(state.user!.email, password);
      
      // Eliminar de Firestore
      await _userService.deleteUser(state.user!.id);
      
      // Eliminar de Firebase Auth
      await _authService.deleteUser();
      
      // El estado se actualizará automáticamente a través del stream
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Limpiar errores
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}