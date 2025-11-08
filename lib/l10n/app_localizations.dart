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

  /// Botón de crear plan
  ///
  /// In es, this message translates to:
  /// **'Crear Plan'**
  String get createPlan;

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
