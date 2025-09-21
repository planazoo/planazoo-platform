// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Planazoo';

  @override
  String get loginTitle => 'Iniciar Sesión';

  @override
  String get loginSubtitle => 'Accede a tu cuenta';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'tu@email.com';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordHint => 'Tu contraseña';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get resendVerification => 'Reenviar verificación';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get registerLink => 'Regístrate';

  @override
  String get registerTitle => 'Crear Cuenta';

  @override
  String get registerSubtitle => 'Únete a Planazoo y comienza a planificar';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get nameHint => 'Tu nombre completo';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get confirmPasswordHint => 'Repite tu contraseña';

  @override
  String get registerButton => 'Crear Cuenta';

  @override
  String get acceptTerms => 'Acepto los términos y condiciones';

  @override
  String get loginLink => '¿Ya tienes cuenta? Iniciar sesión';

  @override
  String get emailRequired => 'El email es requerido';

  @override
  String get emailInvalid => 'El formato del email no es válido';

  @override
  String get passwordRequired => 'La contraseña es requerida';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get nameRequired => 'El nombre es requerido';

  @override
  String get nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get confirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get passwordsNotMatch => 'Las contraseñas no coinciden';

  @override
  String get termsRequired => 'Debes aceptar los términos y condiciones';

  @override
  String get loginSuccess => '¡Bienvenido!';

  @override
  String get registerSuccess =>
      '¡Cuenta creada! Revisa tu email para verificar tu cuenta.';

  @override
  String get emailVerificationSent => 'Email de verificación reenviado';

  @override
  String get passwordResetSent => 'Email de restablecimiento enviado';

  @override
  String get userNotFound => 'No se encontró una cuenta con este email';

  @override
  String get wrongPassword => 'Contraseña incorrecta';

  @override
  String get emailAlreadyInUse => 'Ya existe una cuenta con este email';

  @override
  String get weakPassword =>
      'La contraseña es muy débil. Usa al menos 6 caracteres';

  @override
  String get invalidEmail => 'El formato del email no es válido';

  @override
  String get userDisabled => 'Esta cuenta ha sido deshabilitada';

  @override
  String get tooManyRequests => 'Demasiados intentos. Intenta más tarde';

  @override
  String get networkError => 'Error de conexión. Verifica tu internet';

  @override
  String get invalidCredentials => 'Email o contraseña incorrectos';

  @override
  String get operationNotAllowed => 'Esta operación no está permitida';

  @override
  String get emailNotVerified =>
      'Por favor, verifica tu email antes de iniciar sesión. Revisa tu bandeja de entrada.';

  @override
  String get genericError => 'Error al iniciar sesión. Intenta de nuevo';

  @override
  String get registerError => 'Error al crear la cuenta. Intenta de nuevo';

  @override
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordMessage =>
      'Ingresa tu email para recibir un enlace de restablecimiento.';

  @override
  String get sendResetEmail => 'Enviar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get resendVerificationTitle => 'Reenviar verificación';

  @override
  String get resendVerificationMessage =>
      'Ingresa tu email y contraseña para reenviar el email de verificación.';

  @override
  String get resend => 'Reenviar';

  @override
  String get profileTooltip => 'Ver perfil';
}
