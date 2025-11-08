import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth;
  GoogleSignIn? _googleSignIn;
  final GoogleSignIn? _providedGoogleSignIn;

  AuthService({
    fb_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _providedGoogleSignIn = googleSignIn;

  // Lazy initialization de GoogleSignIn para evitar errores en web si no hay Client ID
  // Solo se inicializa cuando realmente se necesita (en signInWithGoogle)
  // Esto evita que falle al crear el AuthService si no hay Client ID configurado
  GoogleSignIn _getGoogleSignInInstance() {
    if (_googleSignIn == null) {
      try {
        _googleSignIn = _providedGoogleSignIn ?? GoogleSignIn(
          // Para web, el clientId se puede obtener del meta tag o pasarlo aquí
          // Si no se proporciona, google_sign_in intentará leerlo del meta tag
          // clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com', // Descomentar y reemplazar si es necesario
        );
      } catch (e) {
        // Si falla la inicialización (por ejemplo, falta Client ID en web),
        // lanzar un error más descriptivo
        throw Exception('Google Sign-In no está configurado correctamente. Verifica que el Client ID esté configurado en web/index.html o en el código. Error: $e');
      }
    }
    return _googleSignIn!;
  }

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

  // Iniciar sesión con Google
  Future<fb_auth.UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = fb_auth.GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        try {
          return await _firebaseAuth.signInWithPopup(googleProvider);
        } on fb_auth.FirebaseAuthException catch (e) {
          if (e.code == 'popup-closed-by-user' ||
              e.code == 'cancelled-popup-request' ||
              e.code == 'user-cancelled' ||
              e.code == 'web-context-canceled') {
            throw Exception('google-sign-in-cancelled');
          }
          throw _handleFirebaseAuthException(e);
        }
      }

      // Iniciar el flujo de autenticación de Google
      // Inicializar GoogleSignIn solo cuando se necesita
      final GoogleSignIn googleSignIn = _getGoogleSignInInstance();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        throw Exception('google-sign-in-cancelled');
      }

      // Obtener los detalles de autenticación del usuario
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear una nueva credencial
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión con Firebase usando la credencial de Google
      return await _firebaseAuth.signInWithCredential(credential);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('google-sign-in-cancelled') ||
          errorString.contains('popup-closed-by-user') ||
          errorString.contains('cancelled-popup-request') ||
          errorString.contains('user-cancelled') ||
          errorString.contains('web-context-canceled')) {
        throw Exception('google-sign-in-cancelled');
      }
      throw Exception('Error desconocido al iniciar sesión con Google: $e');
    }
  }

  // Manejar excepciones de Firebase Auth
  // Devuelve el código de error para que la UI pueda traducirlo
  // TODO (T162): Esto debería devolver códigos en lugar de mensajes traducidos
  Exception _handleFirebaseAuthException(fb_auth.FirebaseAuthException e) {
    // Devolver Exception con el código de error como mensaje
    // Esto permite que la UI traduzca el mensaje correctamente
    return Exception(e.code);
  }
}
