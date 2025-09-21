import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Título de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Planazoo'**
  String get appTitle;

  /// Título de la página de login
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginTitle;

  /// Subtítulo de la página de login
  ///
  /// In es, this message translates to:
  /// **'Accede a tu cuenta'**
  String get loginSubtitle;

  /// Etiqueta del campo de email
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Hint del campo de email
  ///
  /// In es, this message translates to:
  /// **'tu@email.com'**
  String get emailHint;

  /// Etiqueta del campo de contraseña
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// Hint del campo de contraseña
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña'**
  String get passwordHint;

  /// Texto del botón de login
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginButton;

  /// Enlace de recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// Enlace de reenviar verificación
  ///
  /// In es, this message translates to:
  /// **'Reenviar verificación'**
  String get resendVerification;

  /// Texto de no tener cuenta
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get noAccount;

  /// Enlace para ir al registro
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get registerLink;

  /// Título de la página de registro
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get registerTitle;

  /// Subtítulo de la página de registro
  ///
  /// In es, this message translates to:
  /// **'Únete a Planazoo y comienza a planificar'**
  String get registerSubtitle;

  /// Etiqueta del campo de nombre
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nameLabel;

  /// Hint del campo de nombre
  ///
  /// In es, this message translates to:
  /// **'Tu nombre completo'**
  String get nameHint;

  /// Etiqueta del campo de confirmar contraseña
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPasswordLabel;

  /// Hint del campo de confirmar contraseña
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get confirmPasswordHint;

  /// Texto del botón de registro
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get registerButton;

  /// Checkbox de aceptar términos
  ///
  /// In es, this message translates to:
  /// **'Acepto los términos y condiciones'**
  String get acceptTerms;

  /// Enlace para ir al login
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? Iniciar sesión'**
  String get loginLink;

  /// Error de email requerido
  ///
  /// In es, this message translates to:
  /// **'El email es requerido'**
  String get emailRequired;

  /// Error de formato de email
  ///
  /// In es, this message translates to:
  /// **'El formato del email no es válido'**
  String get emailInvalid;

  /// Error de contraseña requerida
  ///
  /// In es, this message translates to:
  /// **'La contraseña es requerida'**
  String get passwordRequired;

  /// Error de longitud mínima de contraseña
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get passwordMinLength;

  /// Error de nombre requerido
  ///
  /// In es, this message translates to:
  /// **'El nombre es requerido'**
  String get nameRequired;

  /// Error de longitud mínima de nombre
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 2 caracteres'**
  String get nameMinLength;

  /// Error de confirmación de contraseña requerida
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get confirmPasswordRequired;

  /// Error de contraseñas no coinciden
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsNotMatch;

  /// Error de términos requeridos
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos y condiciones'**
  String get termsRequired;

  /// Mensaje de login exitoso
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido!'**
  String get loginSuccess;

  /// Mensaje de registro exitoso
  ///
  /// In es, this message translates to:
  /// **'¡Cuenta creada! Revisa tu email para verificar tu cuenta.'**
  String get registerSuccess;

  /// Mensaje de email de verificación reenviado
  ///
  /// In es, this message translates to:
  /// **'Email de verificación reenviado'**
  String get emailVerificationSent;

  /// Mensaje de email de restablecimiento enviado
  ///
  /// In es, this message translates to:
  /// **'Email de restablecimiento enviado'**
  String get passwordResetSent;

  /// Error de usuario no encontrado
  ///
  /// In es, this message translates to:
  /// **'No se encontró una cuenta con este email'**
  String get userNotFound;

  /// Error de contraseña incorrecta
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta'**
  String get wrongPassword;

  /// Error de email ya en uso
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con este email'**
  String get emailAlreadyInUse;

  /// Error de contraseña débil
  ///
  /// In es, this message translates to:
  /// **'La contraseña es muy débil. Usa al menos 6 caracteres'**
  String get weakPassword;

  /// Error de email inválido
  ///
  /// In es, this message translates to:
  /// **'El formato del email no es válido'**
  String get invalidEmail;

  /// Error de cuenta deshabilitada
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta ha sido deshabilitada'**
  String get userDisabled;

  /// Error de demasiados intentos
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Intenta más tarde'**
  String get tooManyRequests;

  /// Error de red
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Verifica tu internet'**
  String get networkError;

  /// Error de credenciales inválidas
  ///
  /// In es, this message translates to:
  /// **'Email o contraseña incorrectos'**
  String get invalidCredentials;

  /// Error de operación no permitida
  ///
  /// In es, this message translates to:
  /// **'Esta operación no está permitida'**
  String get operationNotAllowed;

  /// Error de email no verificado
  ///
  /// In es, this message translates to:
  /// **'Por favor, verifica tu email antes de iniciar sesión. Revisa tu bandeja de entrada.'**
  String get emailNotVerified;

  /// Error genérico de login
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión. Intenta de nuevo'**
  String get genericError;

  /// Error genérico de registro
  ///
  /// In es, this message translates to:
  /// **'Error al crear la cuenta. Intenta de nuevo'**
  String get registerError;

  /// Título del diálogo de recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get forgotPasswordTitle;

  /// Mensaje del diálogo de recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu email para recibir un enlace de restablecimiento.'**
  String get forgotPasswordMessage;

  /// Botón de enviar email de restablecimiento
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get sendResetEmail;

  /// Botón de cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Botón de cerrar
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// Título del diálogo de reenviar verificación
  ///
  /// In es, this message translates to:
  /// **'Reenviar verificación'**
  String get resendVerificationTitle;

  /// Mensaje del diálogo de reenviar verificación
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu email y contraseña para reenviar el email de verificación.'**
  String get resendVerificationMessage;

  /// Botón de reenviar
  ///
  /// In es, this message translates to:
  /// **'Reenviar'**
  String get resend;

  /// Tooltip del icono de perfil en W1
  ///
  /// In es, this message translates to:
  /// **'Ver perfil'**
  String get profileTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
