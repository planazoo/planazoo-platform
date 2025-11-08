import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:unp_calendario/features/auth/domain/models/auth_state.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/auth_service.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/security/services/rate_limiter_service.dart';
import 'package:unp_calendario/features/security/utils/sanitizer.dart';
import 'package:unp_calendario/features/security/utils/validator.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserService _userService;
  final RateLimiterService _rateLimiter = RateLimiterService();
  bool _isRegistering = false; // Flag para evitar conflictos durante registro
  String? _pendingErrorMessage; // Error pendiente de consumir por la UI

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
        // Excepción: usuarios de Google no requieren verificación (Google ya verifica)
        final isGoogleUser = firebaseUser.providerData.any((provider) => provider.providerId == 'google.com');
        
        if (!firebaseUser.emailVerified && !isGoogleUser) {
          // Cerrar sesión si el email no está verificado (solo para usuarios de email/password)
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
            UserModel updatedUser = userModel.copyWith(lastLoginAt: DateTime.now());
            
            // Generar username automático si no tiene uno
            if (updatedUser.username == null || updatedUser.username!.isEmpty) {
              final generatedUsername = await _generateAutomaticUsername(updatedUser);
              if (generatedUsername != null) {
                updatedUser = updatedUser.copyWith(username: generatedUsername);
                await _userService.updateUsername(updatedUser.id, generatedUsername);
              }
            }
            
            await _userService.updateUser(updatedUser);
            
            state = AuthState(
              status: AuthStatus.authenticated,
              user: updatedUser,
            );
          } else {
            // Usuario no existe en Firestore - crear uno nuevo (puede ser de Google)
            final newUserModel = UserModel.fromFirebaseAuth(firebaseUser);
            
            // Generar username automático
            final generatedUsername = await _generateAutomaticUsername(newUserModel);
            final userModelWithUsername = generatedUsername != null
                ? newUserModel.copyWith(username: generatedUsername)
                : newUserModel;
            
            // Crear usuario en Firestore
            await _userService.createUser(userModelWithUsername);
            
            // Actualizar último login
            final updatedUser = userModelWithUsername.copyWith(lastLoginAt: DateTime.now());
            await _userService.updateUser(updatedUser);
            
            state = AuthState(
              status: AuthStatus.authenticated,
              user: updatedUser,
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
        if (_pendingErrorMessage != null) {
          state = AuthState(
            status: AuthStatus.error,
            errorMessage: _pendingErrorMessage,
          );
          _pendingErrorMessage = null;
          return;
        }

        if (!state.hasError) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        } else {
          // Mantener el error vigente y asegurar que no sigamos en loading
          state = state.copyWith(isLoading: false);
        }
      }
    });
  }

  // Iniciar sesión con email/username y contraseña
  Future<void> signInWithEmailAndPassword(String emailOrUsername, String password) async {
    try {
      String email = emailOrUsername;
      
      // Detectar si es email o username
      final trimmed = emailOrUsername.trim();
      final isEmail = trimmed.contains('@');
      
      if (!isEmail) {
        // Es username - buscar el email asociado
        String username = trimmed;
        // Quitar @ si está presente
        if (username.startsWith('@')) {
          username = username.substring(1);
        }
        
        final user = await _userService.getUserByUsername(username);
        if (user == null) {
          state = AuthState(
            status: AuthStatus.error,
            errorMessage: 'username-not-found',
          );
          return;
        }
        email = user.email;
      }
      else {
        // Verificar si el email existe en Firestore antes de intentar login
        final normalizedEmail = trimmed;
        final existingUser = await _userService.getUserByEmail(normalizedEmail);
        if (existingUser == null) {
          _pendingErrorMessage = 'user-not-found';
          state = const AuthState(
            status: AuthStatus.error,
            errorMessage: 'user-not-found',
          );
          return;
        }
        email = normalizedEmail;
      }
      
      // Verificar rate limiting antes de intentar login
      final rateLimitCheck = await _rateLimiter.checkLoginAttempt(email);
      
      if (!rateLimitCheck.allowed) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: rateLimitCheck.getErrorMessage(),
        );
        return;
      }

      state = AuthState(
        status: AuthStatus.loading,
        user: state.user,
        isLoading: true,
      );
      
      try {
        await _authService.signInWithEmailAndPassword(email, password);
        // Login exitoso - limpiar contador
        await _rateLimiter.recordLoginAttempt(email, true);
        _pendingErrorMessage = null;
        // El estado se actualizará automáticamente a través del stream
        // La verificación de email se hace en _init()
      } catch (e) {
        // Login fallido - registrar intento
        await _rateLimiter.recordLoginAttempt(email, false);
        
        // Re-verificar rate limiting para mostrar mensaje actualizado
        final updatedCheck = await _rateLimiter.checkLoginAttempt(email);
        
        // Extraer el código de error del mensaje
        String errorMessage = e.toString();
        // Si viene como "Exception: wrong-password", extraer solo "wrong-password"
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11); // Remover "Exception: "
        }

        if (updatedCheck.requiresCaptcha) {
          errorMessage = 'Por seguridad, completa el CAPTCHA para continuar. ${errorMessage}';
        } else if (!updatedCheck.allowed) {
          errorMessage = updatedCheck.getErrorMessage();
        }

        _pendingErrorMessage = errorMessage;
        
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      // Extraer el código de error del mensaje
      String errorMessage = e.toString();
      // Si viene como "Exception: wrong-password", extraer solo "wrong-password"
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11); // Remover "Exception: "
      }

      _pendingErrorMessage = errorMessage;

      state = AuthState(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      );
    } finally {
      // No reiniciar _pendingErrorMessage aquí para que la UI lo consuma
    }
  }

  // Registrarse con email y contraseña
  Future<void> registerWithEmailAndPassword(String email, String password, {String? displayName, String? username}) async {
    try {
      _isRegistering = true; // Marcar que estamos registrando
      state = state.copyWith(status: AuthStatus.loading);
      
      // Validar y normalizar username si se proporciona
      String? normalizedUsername;
      if (username != null && username.isNotEmpty) {
        normalizedUsername = username.trim().toLowerCase();
        // Verificar disponibilidad (la validación de formato ya se hizo en la UI)
        final isAvailable = await _userService.isUsernameAvailable(normalizedUsername);
        if (!isAvailable) {
          _isRegistering = false;
          state = AuthState(
            status: AuthStatus.error,
            errorMessage: 'username-taken',
          );
          return;
        }
      }
      
      await _authService.registerWithEmailAndPassword(email, password);
      
      // Sanitizar displayName si se proporciona
      final sanitizedDisplayName = displayName != null && displayName.isNotEmpty
          ? Sanitizer.sanitizePlainText(displayName, maxLength: 100)
          : null;
      
      // Actualizar displayName si se proporciona
      if (sanitizedDisplayName != null && sanitizedDisplayName.isNotEmpty) {
        await _authService.updateDisplayName(sanitizedDisplayName);
      }
      
      // Crear usuario en Firestore después del registro exitoso
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final userModel = UserModel.fromFirebaseAuth(currentUser);
        // Asegurar que el displayName sanitizado y username se guarden en Firestore
        final userModelWithData = userModel.copyWith(
          displayName: sanitizedDisplayName,
          username: normalizedUsername,
        );
        await _userService.createUser(userModelWithData);
        
        // Enviar email de verificación
        await _authService.sendEmailVerification();
        
        // Cerrar sesión inmediatamente después del registro
        await _authService.signOut();
        
        // Emitir estado de éxito de registro
        state = AuthState(
          status: AuthStatus.registrationSuccess,
          user: userModelWithData,
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
  Future<void> createUserWithEmailAndPassword(String email, String password, {String? displayName, String? username}) async {
    return registerWithEmailAndPassword(email, password, displayName: displayName, username: username);
  }

  // Iniciar sesión con Google
  Future<void> signInWithGoogle() async {
    try {
      _pendingErrorMessage = null;

      state = AuthState(
        status: state.isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        user: state.user,
        isLoading: true,
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!state.isLoading) return;
        state = state.copyWith(isLoading: false);
      });

      await _authService.signInWithGoogle();

      state = state.copyWith(isLoading: false);

      // El estado se actualizará automáticamente a través del stream en _init()
      // que detectará el usuario autenticado y creará/actualizará el usuario en Firestore
    } catch (e) {
      String errorMessage = e.toString();
      
      // Manejar cancelación de Google Sign-In
      if (errorMessage.contains('google-sign-in-cancelled')) {
        state = AuthState(
          status: state.isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        );
        return;
      }

      if (errorMessage.contains('google-sign-in-gapi-client-missing')) {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Para iniciar sesión con Google en web, asegúrate de haber configurado correctamente el Client ID y los scripts de Google en index.html.',
        );
        return;
      }
      
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      );
    }
  }

  // Generar username automático basado en email o displayName
  Future<String?> _generateAutomaticUsername(UserModel user) async {
    // Intentar generar desde displayName primero
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final fromDisplayName = _extractUsernameFromDisplayName(user.displayName!);
      if (fromDisplayName != null) {
        final available = await _findAvailableUsername(fromDisplayName);
        if (available != null) return available;
      }
    }
    
    // Si no funciona, intentar desde email
    if (user.email.isNotEmpty) {
      final fromEmail = _extractUsernameFromEmail(user.email);
      if (fromEmail != null) {
        final available = await _findAvailableUsername(fromEmail);
        if (available != null) return available;
      }
    }
    
    // Si todo falla, generar uno aleatorio
    return await _findAvailableUsername('user${DateTime.now().millisecondsSinceEpoch % 10000}');
  }

  // Extraer username válido desde displayName
  String? _extractUsernameFromDisplayName(String displayName) {
    // Convertir a minúsculas y reemplazar espacios y caracteres especiales
    var username = displayName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    
    // Asegurar longitud mínima
    if (username.length < 3) return null;
    
    // Truncar a 30 caracteres
    if (username.length > 30) {
      username = username.substring(0, 30);
    }
    
    return Validator.isValidUsername(username) ? username : null;
  }

  // Extraer username válido desde email
  String? _extractUsernameFromEmail(String email) {
    // Obtener la parte antes del @
    final parts = email.split('@');
    if (parts.isEmpty) return null;
    
    var username = parts[0]
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    
    // Asegurar longitud mínima
    if (username.length < 3) return null;
    
    // Truncar a 30 caracteres
    if (username.length > 30) {
      username = username.substring(0, 30);
    }
    
    return Validator.isValidUsername(username) ? username : null;
  }

  // Encontrar un username disponible, probando variaciones
  Future<String?> _findAvailableUsername(String base) async {
    // Probar el base primero
    if (await _userService.isUsernameAvailable(base)) {
      return base;
    }
    
    // Intentar con números
    for (int i = 1; i <= 999; i++) {
      final candidate = '$base$i';
      if (candidate.length > 30) break; // No exceder límite
      if (await _userService.isUsernameAvailable(candidate)) {
        return candidate;
      }
    }
    
    // Intentar con timestamp corto
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    final candidate = '${base}_$timestamp';
    if (candidate.length <= 30 && await _userService.isUsernameAvailable(candidate)) {
      return candidate;
    }
    
    return null;
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
    await _authService.signOut();
  }

  // Enviar email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Verificar rate limiting antes de enviar
      final rateLimitCheck = await _rateLimiter.checkPasswordReset(email);
      
      if (!rateLimitCheck.allowed) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: rateLimitCheck.getErrorMessage(),
        );
        return;
      }

      state = const AuthState(status: AuthStatus.loading);
      
      try {
        await _authService.sendPasswordResetEmail(email);
        // Registrar envío exitoso
        await _rateLimiter.recordPasswordReset(email);
        state = const AuthState(status: AuthStatus.unauthenticated);
      } catch (e) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: e.toString(),
        );
      }
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
      // Sanitizar y validar entradas
      final sanitizedDisplayName = displayName != null
          ? Sanitizer.sanitizePlainText(displayName, maxLength: 100)
          : null;
      final validPhotoUrl = photoURL != null && photoURL.isNotEmpty
          ? (Validator.isSafeUrl(photoURL) ? photoURL : null)
          : null;

      // Actualizar en Firebase Auth
      if (sanitizedDisplayName != null) {
        await _authService.updateDisplayName(sanitizedDisplayName);
      }
      if (validPhotoUrl != null) {
        await _authService.updatePhotoURL(validPhotoUrl);
      }

      // Actualizar en Firestore
      final updatedUser = state.user!.copyWith(
        displayName: sanitizedDisplayName ?? state.user!.displayName,
        photoURL: validPhotoUrl ?? state.user!.photoURL,
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
    // Solo limpiar el error si no estamos en estado de error
    // Esto evita cambiar el estado cuando se está mostrando el error
    if (state.hasError) {
      state = state.copyWith(
        errorMessage: null,
        status: state.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
    }
  }

  // Actualizar username del usuario
  Future<void> updateUsername(String username) async {
    if (state.user == null) return;
    try {
      // Normalizar: texto plano -> trim -> minúsculas
      final trimmed = Sanitizer.sanitizePlainText(username, maxLength: 30).toLowerCase();
      // Filtrar caracteres inválidos por si acaso
      final normalized = trimmed.replaceAll(RegExp(r'[^a-z0-9_]'), '');

      if (!Validator.isValidUsername(normalized)) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: 'El username debe tener 3-30 caracteres y solo [a-z0-9_] en minúsculas.',
        );
        return;
      }

      // Comprobar disponibilidad
      final available = await _userService.isUsernameAvailable(normalized, excludeUserId: state.user!.id);
      if (!available) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: 'Este username ya está en uso. Prueba con otro.',
        );
        return;
      }

      // Guardar en Firestore
      final ok = await _userService.updateUsername(state.user!.id, normalized);
      if (!ok) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: 'No se pudo guardar el username. Intenta de nuevo.',
        );
        return;
      }

      // Refrescar estado local
      final updatedUser = state.user!.copyWith(username: normalized);
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error al actualizar username: $e',
      );
    }
  }
}