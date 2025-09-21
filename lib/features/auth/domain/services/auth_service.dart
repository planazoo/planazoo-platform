import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth;

  AuthService({fb_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance;

  // Stream de cambios de usuario de Firebase Auth
  Stream<fb_auth.User?> get userChanges => _firebaseAuth.authStateChanges();

  // Iniciar sesión con email y contraseña
  Future<fb_auth.UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error desconocido al iniciar sesión: $e');
    }
  }

  // Registrarse con email y contraseña
  Future<fb_auth.UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error desconocido al registrarse: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Obtener usuario actual
  fb_auth.User? get currentUser => _firebaseAuth.currentUser;

  // Enviar email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error desconocido al enviar email de restablecimiento: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error desconocido al enviar email de verificación: $e');
    }
  }

  // Actualizar nombre de usuario
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error desconocido al actualizar nombre: $e');
    }
  }

  // Actualizar URL de foto de perfil
  Future<void> updatePhotoURL(String photoURL) async {
    try {
      await _firebaseAuth.currentUser?.updatePhotoURL(photoURL);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error desconocido al actualizar foto: $e');
    }
  }

  // Actualizar contraseña
  Future<void> updatePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error desconocido al actualizar contraseña: $e');
    }
  }

  // Eliminar usuario
  Future<void> deleteUser() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error desconocido al eliminar usuario: $e');
    }
  }

  // Reautenticar usuario (necesario para operaciones sensibles como cambiar contraseña o eliminar cuenta)
  Future<fb_auth.UserCredential> reauthenticateUser(String email, String password) async {
    try {
      final credential = fb_auth.EmailAuthProvider.credential(email: email, password: password);
      return await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error desconocido al reautenticar: $e');
    }
  }

  // Manejar excepciones de Firebase Auth
  String _handleFirebaseAuthException(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'El email no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'requires-recent-login':
        return 'Esta operación requiere un inicio de sesión reciente';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
