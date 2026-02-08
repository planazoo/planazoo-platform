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
  String get emailOrUsernameLabel => 'Email o Usuario';

  @override
  String get emailOrUsernameHint => 'tu@email.com o @usuario';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordHint => 'Tu contraseña';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get googleSignInError => 'Error al iniciar sesión con Google';

  @override
  String get googleSignInCancelled => 'Inicio de sesión cancelado';

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
  String get emailOrUsernameInvalid =>
      'Ingresa un email válido o un nombre de usuario';

  @override
  String get passwordRequired => 'La contraseña es requerida';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordNeedsLowercase =>
      'La contraseña debe contener al menos una letra minúscula';

  @override
  String get passwordNeedsUppercase =>
      'La contraseña debe contener al menos una letra mayúscula';

  @override
  String get passwordNeedsNumber =>
      'La contraseña debe contener al menos un número';

  @override
  String get passwordNeedsSpecialChar =>
      'La contraseña debe contener al menos un carácter especial (!@#\$%^&*)';

  @override
  String get passwordRulesTitle => 'La nueva contraseña debe incluir:';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get changePasswordSubtitle =>
      'Introduce tu contraseña actual y define una nueva contraseña segura.';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get confirmNewPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get passwordMustBeDifferent =>
      'La nueva contraseña debe ser distinta a la actual';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordChangedSuccess => 'Contraseña cambiada correctamente';

  @override
  String get passwordChangeError => 'Error al cambiar la contraseña';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get nameRequired => 'El nombre es requerido';

  @override
  String get nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get usernameLabel => 'Nombre de usuario';

  @override
  String get usernameHint => 'ej: juancarlos, maria_garcia';

  @override
  String get usernameRequired => 'El nombre de usuario es requerido';

  @override
  String get usernameInvalid =>
      'El nombre de usuario debe tener 3-30 caracteres y solo puede contener letras minúsculas, números y guiones bajos (a-z, 0-9, _)';

  @override
  String get usernameTaken => 'Este nombre de usuario ya está en uso';

  @override
  String get usernameAvailable => 'Nombre de usuario disponible';

  @override
  String usernameSuggestion(String suggestions) {
    return 'Sugerencias: $suggestions';
  }

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
  String get usernameNotFound =>
      'No se encontró un usuario con ese nombre de usuario';

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
  String profileCurrentTimezone(String timezone) {
    return 'Zona horaria actual: $timezone';
  }

  @override
  String get profileTimezoneOption => 'Configurar zona horaria';

  @override
  String get profileTimezoneDialogTitle => 'Seleccionar zona horaria';

  @override
  String profileTimezoneDialogDescription(String timezone) {
    return 'Estás usando $timezone. Si no coincide con tu ubicación actual, los horarios podrían mostrarse desfasados.';
  }

  @override
  String profileTimezoneDialogDeviceSuggestion(String timezone) {
    return 'Usar hora del dispositivo ($timezone)';
  }

  @override
  String get profileTimezoneDialogDeviceHint =>
      'Te recomendamos actualizarla si estás viajando.';

  @override
  String get profileTimezoneDialogSearchHint => 'Buscar ciudad o zona';

  @override
  String get profileTimezoneDialogNoResults =>
      'No encontramos zonas que coincidan.';

  @override
  String get profileTimezoneDialogSystemTag => 'Zona del dispositivo';

  @override
  String get profileTimezoneUpdateSuccess =>
      'Zona horaria actualizada correctamente.';

  @override
  String get profileTimezoneInvalidError =>
      'La zona horaria seleccionada no es válida.';

  @override
  String get profileTimezoneUpdateError =>
      'No pudimos actualizar la zona horaria. Inténtalo de nuevo.';

  @override
  String get timezoneBannerTitle => '¿Actualizar la zona horaria?';

  @override
  String timezoneBannerMessage(String deviceTimezone, String userTimezone) {
    return 'Detectamos que tu dispositivo está en $deviceTimezone, pero tu preferencia actual es $userTimezone. Si no la cambias, los horarios pueden mostrarse desfasados.';
  }

  @override
  String timezoneBannerUpdateButton(String timezone) {
    return 'Actualizar a $timezone';
  }

  @override
  String timezoneBannerKeepButton(String timezone) {
    return 'Mantener $timezone';
  }

  @override
  String get timezoneBannerUpdateSuccess =>
      'Actualizamos tu zona horaria. Todos los horarios ya están sincronizados.';

  @override
  String get timezoneBannerUpdateError =>
      'No pudimos actualizar la zona horaria del perfil. Inténtalo más tarde.';

  @override
  String timezoneBannerKeepMessage(String timezone) {
    return 'Mantendremos $timezone. Puedes cambiarla en el perfil cuando quieras.';
  }

  @override
  String profileMemberSince(String date) {
    return 'Miembro desde $date';
  }

  @override
  String get profilePersonalDataTitle => 'Datos personales';

  @override
  String get profilePersonalDataSubtitle =>
      'Actualiza tu nombre y foto de perfil.';

  @override
  String get profileEditPersonalInformation => 'Editar información personal';

  @override
  String get profileSecurityAndAccessTitle => 'Seguridad y acceso';

  @override
  String get profileSecurityAndAccessSubtitle =>
      'Gestiona la seguridad de tu cuenta.';

  @override
  String get profilePrivacyAndSecurityOption => 'Privacidad y seguridad';

  @override
  String get profileLanguageOption => 'Idioma';

  @override
  String get profileSignOutOption => 'Cerrar sesión';

  @override
  String get profileAdvancedActionsTitle => 'Acciones avanzadas';

  @override
  String get profileAdvancedActionsSubtitle =>
      'Opciones adicionales disponibles para tu cuenta.';

  @override
  String get profileDeleteAccountOption => 'Eliminar cuenta';

  @override
  String get profilePrivacyDialogTitle => 'Privacidad y seguridad';

  @override
  String get profilePrivacyDialogIntro => 'Tus datos están protegidos con:';

  @override
  String get profilePrivacyDialogEncryption =>
      'Encriptación de extremo a extremo en Firestore';

  @override
  String get profilePrivacyDialogEmailVerification =>
      'Verificación de email obligatoria (excepto Google)';

  @override
  String get profilePrivacyDialogRateLimiting =>
      'Rate limiting para prevenir abuso';

  @override
  String get profilePrivacyDialogAccessControl =>
      'Controles de acceso por roles (organizador, coorganizador, etc.)';

  @override
  String get profilePrivacyDialogMoreInfo =>
      'Para más información consulta GUIA_SEGURIDAD.md.';

  @override
  String get profileLanguageDialogTitle => 'Seleccionar idioma';

  @override
  String get profileLanguageOptionSpanish => 'Español';

  @override
  String get profileLanguageOptionEnglish => 'English';

  @override
  String get profileDeleteAccountDescription =>
      'Esta acción es irreversible. Para confirmar, introduce tu contraseña.';

  @override
  String get profileDeleteAccountEmptyPasswordError =>
      'Introduce tu contraseña para continuar.';

  @override
  String get profileDeleteAccountWrongPasswordError =>
      'Contraseña incorrecta. Inténtalo de nuevo.';

  @override
  String get profileDeleteAccountTooManyAttemptsError =>
      'Demasiados intentos fallidos. Espera unos minutos antes de volver a intentarlo.';

  @override
  String get profileDeleteAccountRecentLoginError =>
      'Vuelve a iniciar sesión y repite la operación para confirmar la eliminación.';

  @override
  String get profileDeleteAccountGenericError =>
      'No se pudo eliminar la cuenta. Inténtalo de nuevo en unos minutos.';

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
  String get createPlanGeneralSectionTitle => 'Información general';

  @override
  String get createPlanNameLabel => 'Nombre del plan';

  @override
  String get createPlanNameHint => 'Ej: Vacaciones Londres 2025';

  @override
  String get createPlanNameRequiredError => 'Por favor ingresa un nombre';

  @override
  String get createPlanNameTooShortError =>
      'El nombre debe tener al menos 3 caracteres';

  @override
  String get createPlanNameTooLongError =>
      'El nombre no puede exceder 100 caracteres';

  @override
  String get createPlanUnpIdLabel => 'UNP ID';

  @override
  String get createPlanUnpIdHint => 'Generando...';

  @override
  String get createPlanUnpGeneratedHelper => 'Generado automáticamente';

  @override
  String createPlanUnpIdHeader(String id) {
    return 'ID: $id';
  }

  @override
  String get createPlanUnpIdLoading => 'Generando UNP ID...';

  @override
  String get createPlanQuickIntro =>
      'Podrás completar el resto de la configuración del plan en la siguiente pantalla.';

  @override
  String get createPlanContinueButton => 'Continuar';

  @override
  String get createPlanAuthError =>
      'Necesitas iniciar sesión para crear un plan.';

  @override
  String get createPlanGenericError =>
      'No se pudo crear el plan. Inténtalo de nuevo.';

  @override
  String get createPlanDescriptionLabel => 'Descripción (opcional)';

  @override
  String get createPlanDescriptionHint => 'Describe brevemente el plan';

  @override
  String get createPlanConfigurationSectionTitle => 'Configuración';

  @override
  String get createPlanCurrencyLabel => 'Moneda del plan';

  @override
  String get createPlanVisibilityLabel => 'Visibilidad';

  @override
  String get createPlanVisibilityPrivate => 'Privado - Solo participantes';

  @override
  String get createPlanVisibilityPublic => 'Público - Visible para todos';

  @override
  String get createPlanVisibilityPrivateShort => 'Privado';

  @override
  String get createPlanVisibilityPublicShort => 'Público';

  @override
  String get createPlanImageSectionTitle => 'Imagen del plan (opcional)';

  @override
  String get createPlanSelectImage => 'Cambiar imagen';

  @override
  String get planDetailsNoDescription => 'Sin descripción añadida.';

  @override
  String get planDetailsNoParticipants =>
      'Todavía no has añadido participantes.';

  @override
  String get planDetailsInfoTitle => 'Información detallada';

  @override
  String get planDetailsMetaTitle => 'Identificación del plan';

  @override
  String get planTimezoneLabel => 'Zona horaria del plan';

  @override
  String get planTimezoneHelper =>
      'Se aplicará como referencia al crear eventos y convertir horarios para los participantes.';

  @override
  String get planDetailsStateTitle => 'Gestión de estado';

  @override
  String get planDetailsParticipantsTitle => 'Participantes';

  @override
  String get planDetailsParticipantsManageLink => 'Gestionar participantes';

  @override
  String get planDetailsBudgetLabel => 'Presupuesto estimado';

  @override
  String get planDetailsBudgetInvalid =>
      'Introduce un número positivo válido (usa punto decimal)';

  @override
  String get cancelChanges => 'Cancelar cambios';

  @override
  String get planDetailsSaveSuccess => 'Cambios guardados correctamente.';

  @override
  String get planDetailsUnsavedChanges => 'Tienes cambios sin guardar.';

  @override
  String get planDetailsNoAvailableParticipants =>
      'No hay usuarios disponibles para añadir.';

  @override
  String planDetailsParticipantsAdded(int count) {
    return 'Se añadieron $count participantes.';
  }

  @override
  String get planDetailsSaveError => 'No se pudieron guardar los cambios.';

  @override
  String get planDeleteDialogTitle => 'Eliminar plan';

  @override
  String get planDeleteDialogMessage =>
      '¿Quieres eliminar este plan definitivamente?\\n\\nSe borrarán el plan, sus eventos y participaciones. Esta acción no se puede deshacer. Introduce tu contraseña para confirmarlo.';

  @override
  String get planDeleteDialogPasswordLabel => 'Contraseña';

  @override
  String get planDeleteDialogPasswordRequired =>
      'Introduce tu contraseña para confirmar.';

  @override
  String get planDeleteDialogAuthError =>
      'Contraseña incorrecta o sin permisos para eliminar este plan.';

  @override
  String get planDeleteDialogConfirm => 'Eliminar plan';

  @override
  String planDeleteSuccess(String name) {
    return 'Plan \"$name\" eliminado correctamente.';
  }

  @override
  String get planDeleteError => 'Error al eliminar el plan';

  @override
  String planRoleLabel(String role) {
    return 'Rol: $role';
  }

  @override
  String get planRoleOrganizer => 'Organizador';

  @override
  String get planRoleParticipant => 'Participante';

  @override
  String get planRoleObserver => 'Observador';

  @override
  String get planRoleUnknown => 'Rol desconocido';

  @override
  String get planViewModeList => 'Lista';

  @override
  String get planViewModeCalendar => 'Calendario';

  @override
  String get dashboardFilterAll => 'Todos';
  @override
  String get dashboardFilterEstoyIn => 'Estoy in';
  @override
  String get dashboardFilterPending => 'Pendientes';
  @override
  String get dashboardFilterClosed => 'Cerrados';
  @override
  String get dashboardSelectPlan => 'Selecciona un plan';
  @override
  String get dashboardUiShowcaseTooltip => 'UI Showcase';
  @override
  String get dashboardLogo => 'planazoo';
  @override
  String get dashboardTabPlanazoo => 'planazoo';
  @override
  String get dashboardTabCalendar => 'calendario';
  @override
  String get dashboardTabIn => 'in';
  @override
  String get dashboardTabStats => 'stats';
  @override
  String get dashboardTabPayments => 'pagos';
  @override
  String get dashboardTabChat => 'chat';

  @override
  String get planCalendarEmpty => 'No hay planes en estos meses.';

  @override
  String get createPlanDatesSectionTitle => 'Fechas del plan';

  @override
  String createPlanStartDateLabel(String date) {
    return 'Inicio: $date';
  }

  @override
  String createPlanEndDateLabel(String date) {
    return 'Fin: $date';
  }

  @override
  String get createPlanDurationLabel => 'Duración';

  @override
  String createPlanDurationValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '# días',
      one: '# día',
    );
    return '$_temp0';
  }

  @override
  String get createPlanParticipantsSectionTitle => 'Participantes (opcional)';

  @override
  String get createPlanImageSelected => 'Imagen seleccionada';

  @override
  String get createPlanImageSelectedSuccess =>
      'Imagen seleccionada correctamente';

  @override
  String get createPlanImageSelectError => 'Error al seleccionar imagen';

  @override
  String get createPlanCreating => 'Creando...';

  @override
  String get createPlanAddParticipantsButton => 'Añadir participantes';

  @override
  String get createPlanNoParticipants =>
      'Todavía no has añadido participantes.';

  @override
  String get createPlanParticipantsBottomSheetTitle =>
      'Selecciona participantes';

  @override
  String get createPlanParticipantsSave => 'Guardar selección';

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

  @override
  String get newAccommodation => 'Nuevo Alojamiento';

  @override
  String get editAccommodation => 'Editar Alojamiento';

  @override
  String get checkIn => 'Check-in';

  @override
  String get checkOut => 'Check-out';

  @override
  String nights(int count) {
    return '$count noche(s)';
  }

  @override
  String get color => 'Color:';

  @override
  String get participantsLabel => 'Participantes:';

  @override
  String get noParticipantsSelected =>
      'Sin participantes seleccionados (aparecerá en el primer track)';

  @override
  String errorLoadingParticipants(String error) {
    return 'Error al cargar participantes: $error';
  }

  @override
  String get mustBeValidNumber => 'Debe ser un número válido';

  @override
  String get cannotBeNegative => 'No puede ser negativo';

  @override
  String get maxAmount => 'Máximo 1.000.000';

  @override
  String get calculating => 'Calculando...';

  @override
  String convertedTo(String currency) {
    return 'Convertido a $currency:';
  }

  @override
  String get conversionError => 'No se pudo calcular la conversión';

  @override
  String get generateGuestsButton => '👥 Invitados';

  @override
  String get generateMiniFrankButton => '🧬 Mini-Frank';

  @override
  String get generateFrankensteinButton => '🧟 Frankenstein';

  @override
  String get accommodationNameRequiredError =>
      'El nombre del alojamiento es obligatorio';

  @override
  String get checkOutAfterCheckInError =>
      'La fecha de check-out debe ser posterior al check-in';

  @override
  String get requiresConfirmation => 'Requiere confirmación de participantes';

  @override
  String get requiresConfirmationSubtitle =>
      'Los participantes deberán confirmar explícitamente su asistencia';

  @override
  String get cardObtained => 'Tarjeta obtenida';

  @override
  String get cardObtainedSubtitle => 'Marcar si ya tienes la tarjeta/entrada';

  @override
  String get adminInsightsTooltip => 'Vista administrativa';

  @override
  String get adminInsightsTitle => 'Vista administrativa de planes';

  @override
  String get adminInsightsExportCsv => 'Exportar CSV';

  @override
  String get adminInsightsExportCopied => 'CSV copiado al portapapeles';

  @override
  String get adminInsightsRefresh => 'Actualizar';

  @override
  String get adminInsightsEmpty => 'No hay planes activos para mostrar.';

  @override
  String get adminInsightsError => 'No se pudieron cargar los datos.';

  @override
  String get adminInsightsRetry => 'Reintentar';

  @override
  String get adminInsightsClose => 'Cerrar';

  @override
  String get adminInsightsParticipantsSection => 'Participantes';

  @override
  String get adminInsightsEventsSection => 'Eventos';

  @override
  String get adminInsightsAccommodationsSection => 'Alojamientos';

  @override
  String get adminInsightsNoParticipants =>
      'No hay participantes activos en este plan.';

  @override
  String get adminInsightsNoEvents => 'No hay eventos activos registrados.';

  @override
  String get adminInsightsNoAccommodations =>
      'No hay alojamientos registrados.';

  @override
  String get adminInsightsColumnPlan => 'Plan';

  @override
  String get adminInsightsColumnStart => 'Inicio';

  @override
  String get adminInsightsColumnEnd => 'Fin';

  @override
  String get adminInsightsColumnParticipant => 'Participante';

  @override
  String get adminInsightsColumnRole => 'Rol';

  @override
  String get adminInsightsColumnTimezone => 'Zona horaria';

  @override
  String get adminInsightsColumnJoined => 'Alta';

  @override
  String get adminInsightsColumnEvent => 'Evento';

  @override
  String get adminInsightsColumnDate => 'Fecha';

  @override
  String get adminInsightsColumnTime => 'Hora';

  @override
  String get adminInsightsColumnParticipantsShort => 'Participantes';

  @override
  String get adminInsightsColumnAccommodation => 'Alojamiento';

  @override
  String get adminInsightsColumnCheckIn => 'Check-in';

  @override
  String get adminInsightsColumnCheckOut => 'Check-out';

  @override
  String get adminInsightsEventStatusRegistered => 'Participa';

  @override
  String get adminInsightsEventStatusNotRegistered => 'No participa';

  @override
  String get adminInsightsEventStatusCancelled => 'Cancelado';

  @override
  String get adminInsightsEventConfirmationPending => 'Pendiente';

  @override
  String get adminInsightsEventConfirmationAccepted => 'Aceptado';

  @override
  String get adminInsightsEventConfirmationDeclined => 'Rechazado';

  @override
  String get adminInsightsEventConfirmationMissing => 'Sin respuesta';

  @override
  String get planSummaryTitle => 'Resumen del plan';

  @override
  String get planSummaryCopiedToClipboard => 'Resumen copiado al portapapeles';

  @override
  String get planSummaryCopy => 'Copiar';

  @override
  String get planSummaryCopied => 'Copiado';

  @override
  String get planSummaryClose => 'Cerrar';

  @override
  String get planSummaryError => 'No se pudo generar el resumen.';

  @override
  String get planSummaryGenerating => 'Generando resumen...';

  @override
  String get planSummaryButtonTooltip => 'Ver resumen';

  @override
  String get planSummaryButtonLabel => 'Resumen';
}
