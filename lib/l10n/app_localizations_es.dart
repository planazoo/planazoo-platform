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

  @override
  String get confirmDeleteTitle => 'Confirmar eliminación';

  @override
  String get confirmDeleteMessage =>
      '¿Estás seguro de que quieres eliminar este planazoo? Esta acción no se puede deshacer.';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteSuccess => 'Planazoo eliminado exitosamente';

  @override
  String get deleteError => 'Error al eliminar planazoo';

  @override
  String get loadError => 'Error al cargar planazoos';

  @override
  String get generateGuests => 'Generando usuarios invitados...';

  @override
  String get guestsGenerated => 'usuarios invitados generados exitosamente!';

  @override
  String get userNotAuthenticated => 'Error: Usuario no autenticado';

  @override
  String get generateMiniFrank => 'Generando plan Mini-Frank...';

  @override
  String get miniFrankGenerated => 'Plan Mini-Frank generado exitosamente!';

  @override
  String get generateMiniFrankError => 'Error al generar plan Mini-Frank';

  @override
  String get view => 'Ver';

  @override
  String get accountSettings => 'Configuración de Cuenta';

  @override
  String get language => 'Idioma';

  @override
  String get changeLanguage => 'Cambiar el idioma de la aplicación';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get createPlan => 'Crear Plan';

  @override
  String get edit => 'Editar';

  @override
  String get editInfo => 'Editar información';

  @override
  String get remove => 'Quitar';

  @override
  String get add => 'Añadir';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get accept => 'Aceptar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountTitle => 'Eliminar Cuenta';

  @override
  String get deleteAccountMessage =>
      'Esta acción es irreversible. Se eliminarán todos tus datos, planes y eventos.';

  @override
  String get confirmPassword => 'Confirma tu contraseña';

  @override
  String get participantsRegistered => 'Participantes apuntados';

  @override
  String get accommodationNameRequired =>
      'El nombre del alojamiento es obligatorio';

  @override
  String minCharacters(int count) {
    return 'Mínimo $count caracteres';
  }

  @override
  String maxCharacters(int count) {
    return 'Máximo $count caracteres';
  }

  @override
  String get accommodationType => 'Tipo de alojamiento';

  @override
  String get invalidAccommodationType => 'Tipo de alojamiento inválido';

  @override
  String get description => 'Descripción';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get additionalNotes => 'Notas adicionales';

  @override
  String get accommodationName => 'Nombre del alojamiento';

  @override
  String get accommodationNameHint => 'Hotel, apartamento, etc.';

  @override
  String get costCurrency => 'Moneda del coste';

  @override
  String get cost => 'Coste';

  @override
  String get costOptional => 'Coste del alojamiento (opcional)';

  @override
  String get costHint => 'Ej: 450.00';

  @override
  String get eventDescription => 'Descripción';

  @override
  String get eventDescriptionHint => 'Nombre del evento';

  @override
  String get eventType => 'Tipo de evento';

  @override
  String get eventSubtype => 'Subtipo';

  @override
  String get selectValidTypeFirst => 'Selecciona primero un tipo válido';

  @override
  String get invalidSubtype => 'Subtipo inválido para el tipo seleccionado';

  @override
  String get isDraft => 'Es borrador';

  @override
  String get isDraftSubtitle => 'Los borradores se muestran con menor opacidad';

  @override
  String get date => 'Fecha';

  @override
  String get time => 'Hora';

  @override
  String get duration => 'Duración';

  @override
  String get timezone => 'Timezone';

  @override
  String get arrivalTimezone => 'Timezone de llegada';

  @override
  String get maxParticipants => 'Límite de participantes (opcional)';

  @override
  String get maxParticipantsHint => 'Ej: 10 (dejar vacío para sin límite)';

  @override
  String get seat => 'Asiento';

  @override
  String get seatHint => 'Ej: 12A, Ventana';

  @override
  String get menu => 'Menú/Comida';

  @override
  String get menuHint => 'Ej: Vegetariano, Sin gluten';

  @override
  String get preferences => 'Preferencias';

  @override
  String get preferencesHint => 'Ej: Cerca de la salida, Silencioso';

  @override
  String get reservationNumber => 'Número de reserva';

  @override
  String get reservationNumberHint => 'Ej: ABC123, 456789';

  @override
  String get gate => 'Puerta/Gate';

  @override
  String get gateHint => 'Ej: Gate A12, Puerta 3';

  @override
  String get personalNotes => 'Notas personales';

  @override
  String get createEvent => 'Crear Evento';

  @override
  String get editEvent => 'Editar Evento';

  @override
  String get creator => 'Creador';

  @override
  String get initializingPermissions => 'Inicializando permisos...';

  @override
  String get eventNotSaved => 'Evento no guardado. El plan no fue expandido.';

  @override
  String planCreatedSuccess(String name) {
    return 'Plan \"$name\" creado exitosamente';
  }

  @override
  String planDeletedSuccess(String name) {
    return 'Plan \"$name\" eliminado exitosamente';
  }

  @override
  String get usernameUpdated => 'Nombre de usuario actualizado';

  @override
  String get participants => 'Participantes';

  @override
  String get participant => 'Participante';

  @override
  String get fullPlan => 'Plan Completo';

  @override
  String get plans => 'Plans';
}
