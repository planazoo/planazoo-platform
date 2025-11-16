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

  /// Etiqueta del campo de email o username en login
  ///
  /// In es, this message translates to:
  /// **'Email o Usuario'**
  String get emailOrUsernameLabel;

  /// Hint del campo de email o username en login
  ///
  /// In es, this message translates to:
  /// **'tu@email.com o @usuario'**
  String get emailOrUsernameHint;

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

  /// Texto del botón de login con Google
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// Error genérico de login con Google
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión con Google'**
  String get googleSignInError;

  /// Mensaje cuando el usuario cancela el login con Google
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión cancelado'**
  String get googleSignInCancelled;

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

  /// Error de formato de email o username en login
  ///
  /// In es, this message translates to:
  /// **'Ingresa un email válido o un nombre de usuario'**
  String get emailOrUsernameInvalid;

  /// Error de contraseña requerida
  ///
  /// In es, this message translates to:
  /// **'La contraseña es requerida'**
  String get passwordRequired;

  /// Error de longitud mínima de contraseña
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get passwordMinLength;

  /// Error de contraseña sin letra minúscula
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe contener al menos una letra minúscula'**
  String get passwordNeedsLowercase;

  /// Error de contraseña sin letra mayúscula
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe contener al menos una letra mayúscula'**
  String get passwordNeedsUppercase;

  /// Error de contraseña sin número
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe contener al menos un número'**
  String get passwordNeedsNumber;

  /// Error de contraseña sin carácter especial
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe contener al menos un carácter especial (!@#\$%^&*)'**
  String get passwordNeedsSpecialChar;

  /// Título que introduce las reglas de contraseña en el diálogo
  ///
  /// In es, this message translates to:
  /// **'La nueva contraseña debe incluir:'**
  String get passwordRulesTitle;

  /// Título del diálogo para cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePasswordTitle;

  /// Texto introductorio del diálogo para cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Introduce tu contraseña actual y define una nueva contraseña segura.'**
  String get changePasswordSubtitle;

  /// Etiqueta del campo para la contraseña actual
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get currentPasswordLabel;

  /// Etiqueta del campo para introducir la nueva contraseña
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get newPasswordLabel;

  /// Etiqueta del campo para confirmar la nueva contraseña
  ///
  /// In es, this message translates to:
  /// **'Confirmar nueva contraseña'**
  String get confirmNewPasswordLabel;

  /// Mensaje de error cuando la contraseña nueva coincide con la actual
  ///
  /// In es, this message translates to:
  /// **'La nueva contraseña debe ser distinta a la actual'**
  String get passwordMustBeDifferent;

  /// Mensaje de error de confirmación de contraseña
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// Mensaje de éxito al cambiar la contraseña
  ///
  /// In es, this message translates to:
  /// **'Contraseña cambiada correctamente'**
  String get passwordChangedSuccess;

  /// Mensaje genérico de error al cambiar la contraseña
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar la contraseña'**
  String get passwordChangeError;

  /// Texto del botón para guardar cambios
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChanges;

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

  /// Etiqueta del campo de username
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario'**
  String get usernameLabel;

  /// Hint del campo de username
  ///
  /// In es, this message translates to:
  /// **'ej: juancarlos, maria_garcia'**
  String get usernameHint;

  /// Error de username requerido
  ///
  /// In es, this message translates to:
  /// **'El nombre de usuario es requerido'**
  String get usernameRequired;

  /// Error de formato de username inválido
  ///
  /// In es, this message translates to:
  /// **'El nombre de usuario debe tener 3-30 caracteres y solo puede contener letras minúsculas, números y guiones bajos (a-z, 0-9, _)'**
  String get usernameInvalid;

  /// Error de username ya ocupado
  ///
  /// In es, this message translates to:
  /// **'Este nombre de usuario ya está en uso'**
  String get usernameTaken;

  /// Mensaje de username disponible
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario disponible'**
  String get usernameAvailable;

  /// Mensaje con sugerencias de username
  ///
  /// In es, this message translates to:
  /// **'Sugerencias: {suggestions}'**
  String usernameSuggestion(String suggestions);

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

  /// Error de username no encontrado en login
  ///
  /// In es, this message translates to:
  /// **'No se encontró un usuario con ese nombre de usuario'**
  String get usernameNotFound;

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

  /// Texto que muestra la zona horaria actual del usuario en el perfil
  ///
  /// In es, this message translates to:
  /// **'Zona horaria actual: {timezone}'**
  String profileCurrentTimezone(String timezone);

  /// Opción del perfil para abrir el diálogo de zona horaria
  ///
  /// In es, this message translates to:
  /// **'Configurar zona horaria'**
  String get profileTimezoneOption;

  /// Título del diálogo de selección de zona horaria
  ///
  /// In es, this message translates to:
  /// **'Seleccionar zona horaria'**
  String get profileTimezoneDialogTitle;

  /// Descripción del diálogo de zona horaria
  ///
  /// In es, this message translates to:
  /// **'Estás usando {timezone}. Si no coincide con tu ubicación actual, los horarios podrían mostrarse desfasados.'**
  String profileTimezoneDialogDescription(String timezone);

  /// Texto del botón que sugiere usar la hora detectada del dispositivo
  ///
  /// In es, this message translates to:
  /// **'Usar hora del dispositivo ({timezone})'**
  String profileTimezoneDialogDeviceSuggestion(String timezone);

  /// Texto de ayuda para el botón de hora del dispositivo
  ///
  /// In es, this message translates to:
  /// **'Te recomendamos actualizarla si estás viajando.'**
  String get profileTimezoneDialogDeviceHint;

  /// Placeholder del campo de búsqueda de zonas horarias
  ///
  /// In es, this message translates to:
  /// **'Buscar ciudad o zona'**
  String get profileTimezoneDialogSearchHint;

  /// Mensaje cuando no hay resultados en la búsqueda de zonas horarias
  ///
  /// In es, this message translates to:
  /// **'No encontramos zonas que coincidan.'**
  String get profileTimezoneDialogNoResults;

  /// Etiqueta para identificar la zona horaria del dispositivo
  ///
  /// In es, this message translates to:
  /// **'Zona del dispositivo'**
  String get profileTimezoneDialogSystemTag;

  /// Mensaje de éxito al actualizar la zona horaria
  ///
  /// In es, this message translates to:
  /// **'Zona horaria actualizada correctamente.'**
  String get profileTimezoneUpdateSuccess;

  /// Mensaje de error cuando la zona horaria no pasa validación
  ///
  /// In es, this message translates to:
  /// **'La zona horaria seleccionada no es válida.'**
  String get profileTimezoneInvalidError;

  /// Mensaje de error cuando falla la actualización de zona horaria
  ///
  /// In es, this message translates to:
  /// **'No pudimos actualizar la zona horaria. Inténtalo de nuevo.'**
  String get profileTimezoneUpdateError;

  /// Título del banner que avisa de cambio de timezone
  ///
  /// In es, this message translates to:
  /// **'¿Actualizar la zona horaria?'**
  String get timezoneBannerTitle;

  /// Mensaje del banner que describe la diferencia de timezone
  ///
  /// In es, this message translates to:
  /// **'Detectamos que tu dispositivo está en {deviceTimezone}, pero tu preferencia actual es {userTimezone}. Si no la cambias, los horarios pueden mostrarse desfasados.'**
  String timezoneBannerMessage(String deviceTimezone, String userTimezone);

  /// No description provided for @timezoneBannerUpdateButton.
  ///
  /// In es, this message translates to:
  /// **'Actualizar a {timezone}'**
  String timezoneBannerUpdateButton(String timezone);

  /// No description provided for @timezoneBannerKeepButton.
  ///
  /// In es, this message translates to:
  /// **'Mantener {timezone}'**
  String timezoneBannerKeepButton(String timezone);

  /// Mensaje de éxito tras aceptar el cambio de timezone
  ///
  /// In es, this message translates to:
  /// **'Actualizamos tu zona horaria. Todos los horarios ya están sincronizados.'**
  String get timezoneBannerUpdateSuccess;

  /// Mensaje de error si falla la actualización de timezone desde el banner
  ///
  /// In es, this message translates to:
  /// **'No pudimos actualizar la zona horaria del perfil. Inténtalo más tarde.'**
  String get timezoneBannerUpdateError;

  /// Mensaje mostrado cuando el usuario decide mantener su timezone actual
  ///
  /// In es, this message translates to:
  /// **'Mantendremos {timezone}. Puedes cambiarla en el perfil cuando quieras.'**
  String timezoneBannerKeepMessage(String timezone);

  /// Etiqueta que muestra la fecha de alta del usuario
  ///
  /// In es, this message translates to:
  /// **'Miembro desde {date}'**
  String profileMemberSince(String date);

  /// Título de la sección de datos personales
  ///
  /// In es, this message translates to:
  /// **'Datos personales'**
  String get profilePersonalDataTitle;

  /// Subtítulo de la sección de datos personales
  ///
  /// In es, this message translates to:
  /// **'Actualiza tu nombre y foto de perfil.'**
  String get profilePersonalDataSubtitle;

  /// Opción para editar información personal
  ///
  /// In es, this message translates to:
  /// **'Editar información personal'**
  String get profileEditPersonalInformation;

  /// Título de la sección de seguridad
  ///
  /// In es, this message translates to:
  /// **'Seguridad y acceso'**
  String get profileSecurityAndAccessTitle;

  /// Subtítulo de la sección de seguridad
  ///
  /// In es, this message translates to:
  /// **'Gestiona la seguridad de tu cuenta.'**
  String get profileSecurityAndAccessSubtitle;

  /// Opción para abrir el modal de privacidad
  ///
  /// In es, this message translates to:
  /// **'Privacidad y seguridad'**
  String get profilePrivacyAndSecurityOption;

  /// Opción para abrir el selector de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get profileLanguageOption;

  /// Opción para cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileSignOutOption;

  /// Título de la sección de acciones avanzadas
  ///
  /// In es, this message translates to:
  /// **'Acciones avanzadas'**
  String get profileAdvancedActionsTitle;

  /// Subtítulo de la sección de acciones avanzadas
  ///
  /// In es, this message translates to:
  /// **'Opciones adicionales disponibles para tu cuenta.'**
  String get profileAdvancedActionsSubtitle;

  /// Opción para eliminar la cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get profileDeleteAccountOption;

  /// Título del diálogo de privacidad
  ///
  /// In es, this message translates to:
  /// **'Privacidad y seguridad'**
  String get profilePrivacyDialogTitle;

  /// Texto introductorio del diálogo de privacidad
  ///
  /// In es, this message translates to:
  /// **'Tus datos están protegidos con:'**
  String get profilePrivacyDialogIntro;

  /// Punto sobre encriptación en el diálogo de privacidad
  ///
  /// In es, this message translates to:
  /// **'Encriptación de extremo a extremo en Firestore'**
  String get profilePrivacyDialogEncryption;

  /// Punto sobre verificación de email en el diálogo de privacidad
  ///
  /// In es, this message translates to:
  /// **'Verificación de email obligatoria (excepto Google)'**
  String get profilePrivacyDialogEmailVerification;

  /// Punto sobre rate limiting en el diálogo de privacidad
  ///
  /// In es, this message translates to:
  /// **'Rate limiting para prevenir abuso'**
  String get profilePrivacyDialogRateLimiting;

  /// Punto sobre controles de acceso en el diálogo de privacidad
  ///
  /// In es, this message translates to:
  /// **'Controles de acceso por roles (organizador, coorganizador, etc.)'**
  String get profilePrivacyDialogAccessControl;

  /// Nota al pie del diálogo de privacidad
  ///
  /// In es, this message translates to:
  /// **'Para más información consulta GUIA_SEGURIDAD.md.'**
  String get profilePrivacyDialogMoreInfo;

  /// Título del diálogo de selección de idioma
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get profileLanguageDialogTitle;

  /// Opción de idioma español
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get profileLanguageOptionSpanish;

  /// Opción de idioma inglés
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get profileLanguageOptionEnglish;

  /// Descripción del diálogo de eliminación de cuenta
  ///
  /// In es, this message translates to:
  /// **'Esta acción es irreversible. Para confirmar, introduce tu contraseña.'**
  String get profileDeleteAccountDescription;

  /// Error cuando la contraseña está vacía en la eliminación de cuenta
  ///
  /// In es, this message translates to:
  /// **'Introduce tu contraseña para continuar.'**
  String get profileDeleteAccountEmptyPasswordError;

  /// Error de contraseña incorrecta al eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta. Inténtalo de nuevo.'**
  String get profileDeleteAccountWrongPasswordError;

  /// Error por demasiados intentos al eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos fallidos. Espera unos minutos antes de volver a intentarlo.'**
  String get profileDeleteAccountTooManyAttemptsError;

  /// Error por requerir login reciente al eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Vuelve a iniciar sesión y repite la operación para confirmar la eliminación.'**
  String get profileDeleteAccountRecentLoginError;

  /// Error genérico al eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cuenta. Inténtalo de nuevo en unos minutos.'**
  String get profileDeleteAccountGenericError;

  /// Título del diálogo de confirmar eliminación
  ///
  /// In es, this message translates to:
  /// **'Confirmar eliminación'**
  String get confirmDeleteTitle;

  /// Mensaje del diálogo de confirmar eliminación
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar este planazoo? Esta acción no se puede deshacer.'**
  String get confirmDeleteMessage;

  /// Botón de eliminar
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Mensaje de eliminación exitosa
  ///
  /// In es, this message translates to:
  /// **'Planazoo eliminado exitosamente'**
  String get deleteSuccess;

  /// Mensaje de error al eliminar
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar planazoo'**
  String get deleteError;

  /// Mensaje de error al cargar
  ///
  /// In es, this message translates to:
  /// **'Error al cargar planazoos'**
  String get loadError;

  /// Mensaje de generando invitados
  ///
  /// In es, this message translates to:
  /// **'Generando usuarios invitados...'**
  String get generateGuests;

  /// Mensaje de invitados generados
  ///
  /// In es, this message translates to:
  /// **'usuarios invitados generados exitosamente!'**
  String get guestsGenerated;

  /// Error de usuario no autenticado
  ///
  /// In es, this message translates to:
  /// **'Error: Usuario no autenticado'**
  String get userNotAuthenticated;

  /// Mensaje de generando Mini-Frank
  ///
  /// In es, this message translates to:
  /// **'Generando plan Mini-Frank...'**
  String get generateMiniFrank;

  /// Mensaje de Mini-Frank generado
  ///
  /// In es, this message translates to:
  /// **'Plan Mini-Frank generado exitosamente!'**
  String get miniFrankGenerated;

  /// Error al generar Mini-Frank
  ///
  /// In es, this message translates to:
  /// **'Error al generar plan Mini-Frank'**
  String get generateMiniFrankError;

  /// Botón de ver
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get view;

  /// Título de configuración de cuenta
  ///
  /// In es, this message translates to:
  /// **'Configuración de Cuenta'**
  String get accountSettings;

  /// Título de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Descripción del selector de idioma
  ///
  /// In es, this message translates to:
  /// **'Cambiar el idioma de la aplicación'**
  String get changeLanguage;

  /// Botón de guardar
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Botón de crear
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// Título del formulario para crear un plan
  ///
  /// In es, this message translates to:
  /// **'Crear Plan'**
  String get createPlan;

  /// No description provided for @createPlanGeneralSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Información general'**
  String get createPlanGeneralSectionTitle;

  /// No description provided for @createPlanNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del plan'**
  String get createPlanNameLabel;

  /// No description provided for @createPlanNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Vacaciones Londres 2025'**
  String get createPlanNameHint;

  /// No description provided for @createPlanNameRequiredError.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un nombre'**
  String get createPlanNameRequiredError;

  /// No description provided for @createPlanNameTooShortError.
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 3 caracteres'**
  String get createPlanNameTooShortError;

  /// No description provided for @createPlanNameTooLongError.
  ///
  /// In es, this message translates to:
  /// **'El nombre no puede exceder 100 caracteres'**
  String get createPlanNameTooLongError;

  /// No description provided for @createPlanUnpIdLabel.
  ///
  /// In es, this message translates to:
  /// **'UNP ID'**
  String get createPlanUnpIdLabel;

  /// No description provided for @createPlanUnpIdHint.
  ///
  /// In es, this message translates to:
  /// **'Generando...'**
  String get createPlanUnpIdHint;

  /// No description provided for @createPlanUnpGeneratedHelper.
  ///
  /// In es, this message translates to:
  /// **'Generado automáticamente'**
  String get createPlanUnpGeneratedHelper;

  /// No description provided for @createPlanUnpIdHeader.
  ///
  /// In es, this message translates to:
  /// **'ID: {id}'**
  String createPlanUnpIdHeader(String id);

  /// No description provided for @createPlanUnpIdLoading.
  ///
  /// In es, this message translates to:
  /// **'Generando UNP ID...'**
  String get createPlanUnpIdLoading;

  /// No description provided for @createPlanQuickIntro.
  ///
  /// In es, this message translates to:
  /// **'Podrás completar el resto de la configuración del plan en la siguiente pantalla.'**
  String get createPlanQuickIntro;

  /// No description provided for @createPlanContinueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get createPlanContinueButton;

  /// No description provided for @createPlanAuthError.
  ///
  /// In es, this message translates to:
  /// **'Necesitas iniciar sesión para crear un plan.'**
  String get createPlanAuthError;

  /// No description provided for @createPlanGenericError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el plan. Inténtalo de nuevo.'**
  String get createPlanGenericError;

  /// No description provided for @createPlanDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get createPlanDescriptionLabel;

  /// No description provided for @createPlanDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Describe brevemente el plan'**
  String get createPlanDescriptionHint;

  /// No description provided for @createPlanConfigurationSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get createPlanConfigurationSectionTitle;

  /// No description provided for @createPlanCurrencyLabel.
  ///
  /// In es, this message translates to:
  /// **'Moneda del plan'**
  String get createPlanCurrencyLabel;

  /// No description provided for @createPlanVisibilityLabel.
  ///
  /// In es, this message translates to:
  /// **'Visibilidad'**
  String get createPlanVisibilityLabel;

  /// No description provided for @createPlanVisibilityPrivate.
  ///
  /// In es, this message translates to:
  /// **'Privado - Solo participantes'**
  String get createPlanVisibilityPrivate;

  /// No description provided for @createPlanVisibilityPublic.
  ///
  /// In es, this message translates to:
  /// **'Público - Visible para todos'**
  String get createPlanVisibilityPublic;

  /// No description provided for @createPlanVisibilityPrivateShort.
  ///
  /// In es, this message translates to:
  /// **'Privado'**
  String get createPlanVisibilityPrivateShort;

  /// No description provided for @createPlanVisibilityPublicShort.
  ///
  /// In es, this message translates to:
  /// **'Público'**
  String get createPlanVisibilityPublicShort;

  /// No description provided for @createPlanImageSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Imagen del plan (opcional)'**
  String get createPlanImageSectionTitle;

  /// No description provided for @createPlanSelectImage.
  ///
  /// In es, this message translates to:
  /// **'Cambiar imagen'**
  String get createPlanSelectImage;

  /// No description provided for @planDetailsNoDescription.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción añadida.'**
  String get planDetailsNoDescription;

  /// No description provided for @planDetailsNoParticipants.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has añadido participantes.'**
  String get planDetailsNoParticipants;

  /// No description provided for @planDetailsInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información detallada'**
  String get planDetailsInfoTitle;

  /// No description provided for @planDetailsMetaTitle.
  ///
  /// In es, this message translates to:
  /// **'Identificación del plan'**
  String get planDetailsMetaTitle;

  /// No description provided for @planTimezoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Zona horaria del plan'**
  String get planTimezoneLabel;

  /// No description provided for @planTimezoneHelper.
  ///
  /// In es, this message translates to:
  /// **'Se aplicará como referencia al crear eventos y convertir horarios para los participantes.'**
  String get planTimezoneHelper;

  /// No description provided for @planDetailsStateTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestión de estado'**
  String get planDetailsStateTitle;

  /// No description provided for @planDetailsParticipantsTitle.
  ///
  /// In es, this message translates to:
  /// **'Participantes'**
  String get planDetailsParticipantsTitle;

  /// No description provided for @planDetailsParticipantsManageLink.
  ///
  /// In es, this message translates to:
  /// **'Gestionar participantes'**
  String get planDetailsParticipantsManageLink;

  /// No description provided for @planDetailsBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto estimado'**
  String get planDetailsBudgetLabel;

  /// No description provided for @planDetailsBudgetInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número positivo válido (usa punto decimal)'**
  String get planDetailsBudgetInvalid;

  /// No description provided for @cancelChanges.
  ///
  /// In es, this message translates to:
  /// **'Cancelar cambios'**
  String get cancelChanges;

  /// No description provided for @planDetailsSaveSuccess.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados correctamente.'**
  String get planDetailsSaveSuccess;

  /// No description provided for @planDetailsUnsavedChanges.
  ///
  /// In es, this message translates to:
  /// **'Tienes cambios sin guardar.'**
  String get planDetailsUnsavedChanges;

  /// No description provided for @planDetailsNoAvailableParticipants.
  ///
  /// In es, this message translates to:
  /// **'No hay usuarios disponibles para añadir.'**
  String get planDetailsNoAvailableParticipants;

  /// No description provided for @planDetailsParticipantsAdded.
  ///
  /// In es, this message translates to:
  /// **'Se añadieron {count} participantes.'**
  String planDetailsParticipantsAdded(int count);

  /// No description provided for @planDetailsSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los cambios.'**
  String get planDetailsSaveError;

  /// No description provided for @planDeleteDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar plan'**
  String get planDeleteDialogTitle;

  /// No description provided for @planDeleteDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres eliminar este plan definitivamente?\\n\\nSe borrarán el plan, sus eventos y participaciones. Esta acción no se puede deshacer. Introduce tu contraseña para confirmarlo.'**
  String get planDeleteDialogMessage;

  /// No description provided for @planDeleteDialogPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get planDeleteDialogPasswordLabel;

  /// No description provided for @planDeleteDialogPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu contraseña para confirmar.'**
  String get planDeleteDialogPasswordRequired;

  /// No description provided for @planDeleteDialogAuthError.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta o sin permisos para eliminar este plan.'**
  String get planDeleteDialogAuthError;

  /// No description provided for @planDeleteDialogConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar plan'**
  String get planDeleteDialogConfirm;

  /// No description provided for @planDeleteSuccess.
  ///
  /// In es, this message translates to:
  /// **'Plan \"{name}\" eliminado correctamente.'**
  String planDeleteSuccess(String name);

  /// No description provided for @planDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar el plan'**
  String get planDeleteError;

  /// No description provided for @planRoleLabel.
  ///
  /// In es, this message translates to:
  /// **'Rol: {role}'**
  String planRoleLabel(String role);

  /// No description provided for @planRoleOrganizer.
  ///
  /// In es, this message translates to:
  /// **'Organizador'**
  String get planRoleOrganizer;

  /// No description provided for @planRoleParticipant.
  ///
  /// In es, this message translates to:
  /// **'Participante'**
  String get planRoleParticipant;

  /// No description provided for @planRoleObserver.
  ///
  /// In es, this message translates to:
  /// **'Observador'**
  String get planRoleObserver;

  /// No description provided for @planRoleUnknown.
  ///
  /// In es, this message translates to:
  /// **'Rol desconocido'**
  String get planRoleUnknown;

  /// No description provided for @planViewModeList.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get planViewModeList;

  /// No description provided for @planViewModeCalendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get planViewModeCalendar;

  /// No description provided for @planCalendarEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay planes en estos meses.'**
  String get planCalendarEmpty;

  /// No description provided for @createPlanDatesSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Fechas del plan'**
  String get createPlanDatesSectionTitle;

  /// No description provided for @createPlanStartDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio: {date}'**
  String createPlanStartDateLabel(String date);

  /// No description provided for @createPlanEndDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fin: {date}'**
  String createPlanEndDateLabel(String date);

  /// No description provided for @createPlanDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get createPlanDurationLabel;

  /// No description provided for @createPlanDurationValue.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, one {# día} other {# días}}'**
  String createPlanDurationValue(int days);

  /// No description provided for @createPlanParticipantsSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Participantes (opcional)'**
  String get createPlanParticipantsSectionTitle;

  /// No description provided for @createPlanImageSelected.
  ///
  /// In es, this message translates to:
  /// **'Imagen seleccionada'**
  String get createPlanImageSelected;

  /// No description provided for @createPlanImageSelectedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Imagen seleccionada correctamente'**
  String get createPlanImageSelectedSuccess;

  /// No description provided for @createPlanImageSelectError.
  ///
  /// In es, this message translates to:
  /// **'Error al seleccionar imagen'**
  String get createPlanImageSelectError;

  /// No description provided for @createPlanCreating.
  ///
  /// In es, this message translates to:
  /// **'Creando...'**
  String get createPlanCreating;

  /// No description provided for @createPlanAddParticipantsButton.
  ///
  /// In es, this message translates to:
  /// **'Añadir participantes'**
  String get createPlanAddParticipantsButton;

  /// No description provided for @createPlanNoParticipants.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has añadido participantes.'**
  String get createPlanNoParticipants;

  /// No description provided for @createPlanParticipantsBottomSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona participantes'**
  String get createPlanParticipantsBottomSheetTitle;

  /// No description provided for @createPlanParticipantsSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar selección'**
  String get createPlanParticipantsSave;

  /// Botón de editar
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Botón de editar información
  ///
  /// In es, this message translates to:
  /// **'Editar información'**
  String get editInfo;

  /// Botón de quitar
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get remove;

  /// Botón de añadir
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// Botón o label de buscar
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// Botón de filtrar
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// Botón de ordenar
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// Botón de aceptar
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// Botón de confirmar
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// Botón de eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get deleteAccount;

  /// Título del diálogo de eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get deleteAccountTitle;

  /// Mensaje del diálogo de eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Esta acción es irreversible. Se eliminarán todos tus datos, planes y eventos.'**
  String get deleteAccountMessage;

  /// Label del campo de confirmar contraseña para eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get confirmPassword;

  /// Título de sección de participantes apuntados
  ///
  /// In es, this message translates to:
  /// **'Participantes apuntados'**
  String get participantsRegistered;

  /// Error de nombre de alojamiento requerido
  ///
  /// In es, this message translates to:
  /// **'El nombre del alojamiento es obligatorio'**
  String get accommodationNameRequired;

  /// Error de mínimo de caracteres
  ///
  /// In es, this message translates to:
  /// **'Mínimo {count} caracteres'**
  String minCharacters(int count);

  /// Error de máximo de caracteres
  ///
  /// In es, this message translates to:
  /// **'Máximo {count} caracteres'**
  String maxCharacters(int count);

  /// Label del tipo de alojamiento
  ///
  /// In es, this message translates to:
  /// **'Tipo de alojamiento'**
  String get accommodationType;

  /// Error de tipo de alojamiento inválido
  ///
  /// In es, this message translates to:
  /// **'Tipo de alojamiento inválido'**
  String get invalidAccommodationType;

  /// Label de descripción
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// Label de descripción opcional
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descriptionOptional;

  /// Hint de notas adicionales
  ///
  /// In es, this message translates to:
  /// **'Notas adicionales'**
  String get additionalNotes;

  /// Label del nombre de alojamiento
  ///
  /// In es, this message translates to:
  /// **'Nombre del alojamiento'**
  String get accommodationName;

  /// Hint del nombre de alojamiento
  ///
  /// In es, this message translates to:
  /// **'Hotel, apartamento, etc.'**
  String get accommodationNameHint;

  /// Label de moneda del coste
  ///
  /// In es, this message translates to:
  /// **'Moneda del coste'**
  String get costCurrency;

  /// Label de coste
  ///
  /// In es, this message translates to:
  /// **'Coste'**
  String get cost;

  /// Label de coste opcional
  ///
  /// In es, this message translates to:
  /// **'Coste del alojamiento (opcional)'**
  String get costOptional;

  /// Hint del coste
  ///
  /// In es, this message translates to:
  /// **'Ej: 450.00'**
  String get costHint;

  /// Label de descripción de evento
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get eventDescription;

  /// Hint de descripción de evento
  ///
  /// In es, this message translates to:
  /// **'Nombre del evento'**
  String get eventDescriptionHint;

  /// Label de tipo de evento
  ///
  /// In es, this message translates to:
  /// **'Tipo de evento'**
  String get eventType;

  /// Label de subtipo de evento
  ///
  /// In es, this message translates to:
  /// **'Subtipo'**
  String get eventSubtype;

  /// Error de seleccionar tipo válido primero
  ///
  /// In es, this message translates to:
  /// **'Selecciona primero un tipo válido'**
  String get selectValidTypeFirst;

  /// Error de subtipo inválido
  ///
  /// In es, this message translates to:
  /// **'Subtipo inválido para el tipo seleccionado'**
  String get invalidSubtype;

  /// Label de es borrador
  ///
  /// In es, this message translates to:
  /// **'Es borrador'**
  String get isDraft;

  /// Subtítulo de es borrador
  ///
  /// In es, this message translates to:
  /// **'Los borradores se muestran con menor opacidad'**
  String get isDraftSubtitle;

  /// Label de fecha
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// Label de hora
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get time;

  /// Label de duración
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get duration;

  /// Label de timezone
  ///
  /// In es, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// Label de timezone de llegada
  ///
  /// In es, this message translates to:
  /// **'Timezone de llegada'**
  String get arrivalTimezone;

  /// Label de límite de participantes
  ///
  /// In es, this message translates to:
  /// **'Límite de participantes (opcional)'**
  String get maxParticipants;

  /// Hint de límite de participantes
  ///
  /// In es, this message translates to:
  /// **'Ej: 10 (dejar vacío para sin límite)'**
  String get maxParticipantsHint;

  /// Label de asiento
  ///
  /// In es, this message translates to:
  /// **'Asiento'**
  String get seat;

  /// Hint de asiento
  ///
  /// In es, this message translates to:
  /// **'Ej: 12A, Ventana'**
  String get seatHint;

  /// Label de menú/comida
  ///
  /// In es, this message translates to:
  /// **'Menú/Comida'**
  String get menu;

  /// Hint de menú/comida
  ///
  /// In es, this message translates to:
  /// **'Ej: Vegetariano, Sin gluten'**
  String get menuHint;

  /// Label de preferencias
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferences;

  /// Hint de preferencias
  ///
  /// In es, this message translates to:
  /// **'Ej: Cerca de la salida, Silencioso'**
  String get preferencesHint;

  /// Label de número de reserva
  ///
  /// In es, this message translates to:
  /// **'Número de reserva'**
  String get reservationNumber;

  /// Hint de número de reserva
  ///
  /// In es, this message translates to:
  /// **'Ej: ABC123, 456789'**
  String get reservationNumberHint;

  /// Label de puerta/gate
  ///
  /// In es, this message translates to:
  /// **'Puerta/Gate'**
  String get gate;

  /// Hint de puerta/gate
  ///
  /// In es, this message translates to:
  /// **'Ej: Gate A12, Puerta 3'**
  String get gateHint;

  /// Label de notas personales
  ///
  /// In es, this message translates to:
  /// **'Notas personales'**
  String get personalNotes;

  /// Título de crear evento
  ///
  /// In es, this message translates to:
  /// **'Crear Evento'**
  String get createEvent;

  /// Título de editar evento
  ///
  /// In es, this message translates to:
  /// **'Editar Evento'**
  String get editEvent;

  /// Badge de creador
  ///
  /// In es, this message translates to:
  /// **'Creador'**
  String get creator;

  /// Mensaje de inicializando permisos
  ///
  /// In es, this message translates to:
  /// **'Inicializando permisos...'**
  String get initializingPermissions;

  /// Error de evento no guardado
  ///
  /// In es, this message translates to:
  /// **'Evento no guardado. El plan no fue expandido.'**
  String get eventNotSaved;

  /// Mensaje de plan creado exitosamente
  ///
  /// In es, this message translates to:
  /// **'Plan \"{name}\" creado exitosamente'**
  String planCreatedSuccess(String name);

  /// Mensaje de plan eliminado exitosamente
  ///
  /// In es, this message translates to:
  /// **'Plan \"{name}\" eliminado exitosamente'**
  String planDeletedSuccess(String name);

  /// Mensaje de nombre de usuario actualizado
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario actualizado'**
  String get usernameUpdated;

  /// Título de participantes
  ///
  /// In es, this message translates to:
  /// **'Participantes'**
  String get participants;

  /// Label de participante
  ///
  /// In es, this message translates to:
  /// **'Participante'**
  String get participant;

  /// Label de plan completo
  ///
  /// In es, this message translates to:
  /// **'Plan Completo'**
  String get fullPlan;

  /// Título de planes
  ///
  /// In es, this message translates to:
  /// **'Plans'**
  String get plans;

  /// Título de nuevo alojamiento
  ///
  /// In es, this message translates to:
  /// **'Nuevo Alojamiento'**
  String get newAccommodation;

  /// Título de editar alojamiento
  ///
  /// In es, this message translates to:
  /// **'Editar Alojamiento'**
  String get editAccommodation;

  /// Label de check-in
  ///
  /// In es, this message translates to:
  /// **'Check-in'**
  String get checkIn;

  /// Label de check-out
  ///
  /// In es, this message translates to:
  /// **'Check-out'**
  String get checkOut;

  /// Duración en noches
  ///
  /// In es, this message translates to:
  /// **'{count} noche(s)'**
  String nights(int count);

  /// Label de color
  ///
  /// In es, this message translates to:
  /// **'Color:'**
  String get color;

  /// Label de participantes
  ///
  /// In es, this message translates to:
  /// **'Participantes:'**
  String get participantsLabel;

  /// Mensaje cuando no hay participantes seleccionados
  ///
  /// In es, this message translates to:
  /// **'Sin participantes seleccionados (aparecerá en el primer track)'**
  String get noParticipantsSelected;

  /// Error al cargar participantes
  ///
  /// In es, this message translates to:
  /// **'Error al cargar participantes: {error}'**
  String errorLoadingParticipants(String error);

  /// Validación de número válido
  ///
  /// In es, this message translates to:
  /// **'Debe ser un número válido'**
  String get mustBeValidNumber;

  /// Validación de número no negativo
  ///
  /// In es, this message translates to:
  /// **'No puede ser negativo'**
  String get cannotBeNegative;

  /// Validación de monto máximo
  ///
  /// In es, this message translates to:
  /// **'Máximo 1.000.000'**
  String get maxAmount;

  /// Mensaje de calculando conversión
  ///
  /// In es, this message translates to:
  /// **'Calculando...'**
  String get calculating;

  /// Mensaje de conversión
  ///
  /// In es, this message translates to:
  /// **'Convertido a {currency}:'**
  String convertedTo(String currency);

  /// Error al calcular conversión
  ///
  /// In es, this message translates to:
  /// **'No se pudo calcular la conversión'**
  String get conversionError;

  /// Botón de generar invitados
  ///
  /// In es, this message translates to:
  /// **'👥 Invitados'**
  String get generateGuestsButton;

  /// Botón de generar Mini-Frank
  ///
  /// In es, this message translates to:
  /// **'🧬 Mini-Frank'**
  String get generateMiniFrankButton;

  /// Botón de generar Frankenstein
  ///
  /// In es, this message translates to:
  /// **'🧟 Frankenstein'**
  String get generateFrankensteinButton;

  /// Error de validación: nombre de alojamiento requerido
  ///
  /// In es, this message translates to:
  /// **'El nombre del alojamiento es obligatorio'**
  String get accommodationNameRequiredError;

  /// Error de validación: check-out debe ser después de check-in
  ///
  /// In es, this message translates to:
  /// **'La fecha de check-out debe ser posterior al check-in'**
  String get checkOutAfterCheckInError;

  /// Checkbox de requiere confirmación
  ///
  /// In es, this message translates to:
  /// **'Requiere confirmación de participantes'**
  String get requiresConfirmation;

  /// Subtítulo de requiere confirmación
  ///
  /// In es, this message translates to:
  /// **'Los participantes deberán confirmar explícitamente su asistencia'**
  String get requiresConfirmationSubtitle;

  /// Switch de tarjeta obtenida
  ///
  /// In es, this message translates to:
  /// **'Tarjeta obtenida'**
  String get cardObtained;

  /// Subtítulo de tarjeta obtenida
  ///
  /// In es, this message translates to:
  /// **'Marcar si ya tienes la tarjeta/entrada'**
  String get cardObtainedSubtitle;

  /// No description provided for @adminInsightsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Vista administrativa'**
  String get adminInsightsTooltip;

  /// No description provided for @adminInsightsTitle.
  ///
  /// In es, this message translates to:
  /// **'Vista administrativa de planes'**
  String get adminInsightsTitle;

  /// No description provided for @adminInsightsExportCsv.
  ///
  /// In es, this message translates to:
  /// **'Exportar CSV'**
  String get adminInsightsExportCsv;

  /// No description provided for @adminInsightsExportCopied.
  ///
  /// In es, this message translates to:
  /// **'CSV copiado al portapapeles'**
  String get adminInsightsExportCopied;

  /// No description provided for @adminInsightsRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get adminInsightsRefresh;

  /// No description provided for @adminInsightsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay planes activos para mostrar.'**
  String get adminInsightsEmpty;

  /// No description provided for @adminInsightsError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los datos.'**
  String get adminInsightsError;

  /// No description provided for @adminInsightsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get adminInsightsRetry;

  /// No description provided for @adminInsightsClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get adminInsightsClose;

  /// No description provided for @adminInsightsParticipantsSection.
  ///
  /// In es, this message translates to:
  /// **'Participantes'**
  String get adminInsightsParticipantsSection;

  /// No description provided for @adminInsightsEventsSection.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get adminInsightsEventsSection;

  /// No description provided for @adminInsightsAccommodationsSection.
  ///
  /// In es, this message translates to:
  /// **'Alojamientos'**
  String get adminInsightsAccommodationsSection;

  /// No description provided for @adminInsightsNoParticipants.
  ///
  /// In es, this message translates to:
  /// **'No hay participantes activos en este plan.'**
  String get adminInsightsNoParticipants;

  /// No description provided for @adminInsightsNoEvents.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos activos registrados.'**
  String get adminInsightsNoEvents;

  /// No description provided for @adminInsightsNoAccommodations.
  ///
  /// In es, this message translates to:
  /// **'No hay alojamientos registrados.'**
  String get adminInsightsNoAccommodations;

  /// No description provided for @adminInsightsColumnPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get adminInsightsColumnPlan;

  /// No description provided for @adminInsightsColumnStart.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get adminInsightsColumnStart;

  /// No description provided for @adminInsightsColumnEnd.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get adminInsightsColumnEnd;

  /// No description provided for @adminInsightsColumnParticipant.
  ///
  /// In es, this message translates to:
  /// **'Participante'**
  String get adminInsightsColumnParticipant;

  /// No description provided for @adminInsightsColumnRole.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get adminInsightsColumnRole;

  /// No description provided for @adminInsightsColumnTimezone.
  ///
  /// In es, this message translates to:
  /// **'Zona horaria'**
  String get adminInsightsColumnTimezone;

  /// No description provided for @adminInsightsColumnJoined.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get adminInsightsColumnJoined;

  /// No description provided for @adminInsightsColumnEvent.
  ///
  /// In es, this message translates to:
  /// **'Evento'**
  String get adminInsightsColumnEvent;

  /// No description provided for @adminInsightsColumnDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get adminInsightsColumnDate;

  /// No description provided for @adminInsightsColumnTime.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get adminInsightsColumnTime;

  /// No description provided for @adminInsightsColumnParticipantsShort.
  ///
  /// In es, this message translates to:
  /// **'Participantes'**
  String get adminInsightsColumnParticipantsShort;

  /// No description provided for @adminInsightsColumnAccommodation.
  ///
  /// In es, this message translates to:
  /// **'Alojamiento'**
  String get adminInsightsColumnAccommodation;

  /// No description provided for @adminInsightsColumnCheckIn.
  ///
  /// In es, this message translates to:
  /// **'Check-in'**
  String get adminInsightsColumnCheckIn;

  /// No description provided for @adminInsightsColumnCheckOut.
  ///
  /// In es, this message translates to:
  /// **'Check-out'**
  String get adminInsightsColumnCheckOut;

  /// No description provided for @adminInsightsEventStatusRegistered.
  ///
  /// In es, this message translates to:
  /// **'Participa'**
  String get adminInsightsEventStatusRegistered;

  /// No description provided for @adminInsightsEventStatusNotRegistered.
  ///
  /// In es, this message translates to:
  /// **'No participa'**
  String get adminInsightsEventStatusNotRegistered;

  /// No description provided for @adminInsightsEventStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get adminInsightsEventStatusCancelled;

  /// No description provided for @adminInsightsEventConfirmationPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get adminInsightsEventConfirmationPending;

  /// No description provided for @adminInsightsEventConfirmationAccepted.
  ///
  /// In es, this message translates to:
  /// **'Aceptado'**
  String get adminInsightsEventConfirmationAccepted;

  /// No description provided for @adminInsightsEventConfirmationDeclined.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get adminInsightsEventConfirmationDeclined;

  /// No description provided for @adminInsightsEventConfirmationMissing.
  ///
  /// In es, this message translates to:
  /// **'Sin respuesta'**
  String get adminInsightsEventConfirmationMissing;
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
