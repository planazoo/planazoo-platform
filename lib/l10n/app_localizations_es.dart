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
  String get paymentsSummaryTitle => 'Resumen de pagos';

  @override
  String get paymentsRegisterPayment => 'Registrar pago';

  @override
  String get paymentsSummaryError => 'Error al cargar resumen de pagos';

  @override
  String get paymentsDisclaimerText =>
      'La app no procesa cobros; solo sirve para anotar pagos y cuadrar entre el grupo.';

  @override
  String get paymentsKittyTitle => 'Bote común';

  @override
  String get paymentsKittyBalanceLabel => 'Saldo';

  @override
  String get paymentsKittyAddContribution => 'Aportación';

  @override
  String get paymentsKittyAddExpense => 'Gasto del bote';

  @override
  String get paymentsKittyContributionsTitle => 'Aportaciones';

  @override
  String paymentsKittyMoreItems(int count) {
    return '+ $count más';
  }

  @override
  String get paymentsKittyExpensesTitle => 'Gastos del bote';

  @override
  String paymentsKittyExpensesLoadError(String error) {
    return 'Error al cargar gastos del bote: $error';
  }

  @override
  String paymentsKittyLoadError(String error) {
    return 'Error al cargar bote: $error';
  }

  @override
  String get paymentsGeneralSummaryTitle => 'Resumen general';

  @override
  String get paymentsGeneralSummaryTotalCost => 'Coste total';

  @override
  String get paymentsGeneralSummaryTotalPaid => 'Total pagado';

  @override
  String get paymentsGeneralSummaryParticipants => 'Participantes';

  @override
  String get paymentsGeneralSummaryBalanceTitle => 'Balance general';

  @override
  String get paymentsBalancesSectionTitle => 'Balances por participante';

  @override
  String get paymentsBalancesTricountHint =>
      'Coste asignado = tu parte del gasto; total pagado = lo que salió de ti; saldo = diferencia (estilo Tricount).';

  @override
  String get paymentsBalanceAssignedCost => 'Coste asignado';

  @override
  String get paymentsBalanceTotalPaid => 'Total pagado';

  @override
  String get paymentsBalancePaymentsTitle => 'Pagos registrados:';

  @override
  String get paymentsTransferSuggestionsTitle =>
      'Sugerencias de transferencias';

  @override
  String get paymentsTransferSuggestionsSubtitle =>
      'Propuesta mínima de pagos para cuadrar cuentas entre personas.';

  @override
  String get paymentsBalanceChartTitle => 'Distribución de balances';

  @override
  String paymentsBalanceStatusCreditor(String amount) {
    return 'Le deben $amount';
  }

  @override
  String paymentsBalanceStatusDebtor(String amount) {
    return 'Debe $amount';
  }

  @override
  String get paymentsBalanceStatusSettled => 'Balance equilibrado';

  @override
  String get paymentsEditExpense => 'Editar gasto';

  @override
  String get paymentsExpenseUpdated => 'Gasto actualizado';

  @override
  String get paymentsExpenseDeleteConfirmTitle => '¿Eliminar este gasto?';

  @override
  String get paymentsExpenseDeleteConfirmBody =>
      'Desaparecerá del plan y de los balances. No se puede deshacer.';

  @override
  String get paymentsExpenseDeleted => 'Gasto eliminado';

  @override
  String get paymentsExpenseDeleteError => 'No se pudo eliminar el gasto';

  @override
  String get paymentsExpenseFromEventPayerHint =>
      'Indica quién pagó con su dinero; el reparto entre personas lo eliges más abajo.';

  @override
  String get paymentsActivityEmpty =>
      'Sin gastos. Añade uno con el botón de arriba.';

  @override
  String paymentsExpenseRowMeta(String date, String payer) {
    return '$date · $payer pagó';
  }

  @override
  String get paymentsExpenseDefaultConcept => 'Gasto';

  @override
  String get paymentsAddExpense => 'Añadir gasto';

  @override
  String get paymentsAddExpenseTitle => 'Nuevo gasto (quién pagó, reparto)';

  @override
  String get paymentsExpensePayer => 'Quién pagó';

  @override
  String get paymentsExpenseAmount => 'Importe';

  @override
  String get paymentsExpenseConcept => 'Concepto (opcional)';

  @override
  String get paymentsExpenseDate => 'Fecha';

  @override
  String get paymentsExpenseLinkedEventLabel => 'Evento (opcional)';

  @override
  String get paymentsExpenseNoEventOption => 'Ninguno';

  @override
  String get paymentsExpenseEventFallbackTitle => 'Evento';

  @override
  String get paymentsExpenseUnknownLinkedEvent => 'Evento (referencia)';

  @override
  String get paymentsExpenseSplitBetween => 'Repartir entre';

  @override
  String get paymentsActivityTitle => 'Actividad';

  @override
  String get paymentsExpenseSaved => 'Gasto registrado';

  @override
  String get paymentsExpenseSaveError => 'Error al guardar el gasto';

  @override
  String get paymentsExpenseSplitEqual => 'Reparto igual';

  @override
  String get paymentsExpenseSplitCustom => 'Reparto personalizado';

  @override
  String get paymentsExpensePerPerson => 'Por persona';

  @override
  String get paymentsCalculator => 'Calculadora';

  @override
  String get paymentsEditPayment => 'Editar pago';

  @override
  String get paymentsPersonalPaymentCurrency => 'Moneda del pago';

  @override
  String get paymentsPersonalAmountValidationRequired => 'Introduce un importe';

  @override
  String get paymentsPersonalAmountValidationInvalid => 'Importe no válido';

  @override
  String get paymentsPersonalAmountValidationTooHigh =>
      'Importe demasiado alto (máx. 1.000.000)';

  @override
  String paymentsPersonalConvertedTo(String currency) {
    return 'Convertido a $currency:';
  }

  @override
  String get paymentsPersonalExchangeDisclaimer =>
      'Los tipos de cambio son orientativos. El valor real será el aplicado por tu banco o tarjeta en el momento del pago.';

  @override
  String get paymentsPersonalCalculating => 'Calculando…';

  @override
  String get paymentsPersonalMethod => 'Método';

  @override
  String get paymentsPersonalMethodHint => 'Selecciona un método';

  @override
  String get paymentsPersonalDescriptionOptional => 'Descripción (opcional)';

  @override
  String get paymentsPersonalStatus => 'Estado';

  @override
  String get paymentsPersonalStatusPending => 'Pendiente';

  @override
  String get paymentsPersonalStatusPaid => 'Pagado';

  @override
  String get paymentsPersonalStatusRefunded => 'Reembolsado';

  @override
  String get paymentsPersonalEventLabel => 'Evento';

  @override
  String get paymentsPersonalYouPaid => 'Tú (yo pagué)';

  @override
  String get paymentsPersonalRegister => 'Registrar';

  @override
  String get paymentsPersonalPaymentSaved => 'Pago registrado';

  @override
  String get paymentsPersonalPaymentUpdated => 'Pago actualizado';

  @override
  String get paymentsPersonalPaymentSaveError => 'No se pudo guardar el pago';

  @override
  String get paymentsMethodCash => 'Efectivo';

  @override
  String get paymentsMethodTransfer => 'Transferencia';

  @override
  String get paymentsMethodCard => 'Tarjeta';

  @override
  String get paymentsMethodBizum => 'Bizum';

  @override
  String get paymentsMethodPayPal => 'PayPal';

  @override
  String get paymentsMethodOther => 'Otro';

  @override
  String get loginSuccess => '¡Bienvenido!';

  @override
  String get registerSuccess =>
      '¡Cuenta creada! Revisa tu email para verificar tu cuenta.';

  @override
  String get registerSuccessSpamNote =>
      'Si no lo ves, revisa la bandeja de spam o correo no deseado.';

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
  String get createPlanDatesOptionalHint =>
      'Las fechas (inicio y fin) se pueden rellenar más adelante en la información del plan.';

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
  String get planDetailsAnnouncementsTitle => 'Avisos';

  @override
  String get planDetailsAnnouncementsHelp =>
      'Mensajes del organizador y participantes visibles para todos en el plan. Aquí puedes publicar avisos y ver el historial.';

  @override
  String get helpMoreInfo => 'Más información';

  @override
  String get planDetailsBudgetLabel => 'Presupuesto estimado';

  @override
  String get planBudgetLabelShort => 'Presupuesto';

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
  String get planDetailsBarUnsavedShort => 'Sin guardar';

  @override
  String get planDetailsBarCancelShort => 'Cancelar';

  @override
  String get planDetailsBarSaveShort => 'Guardar';

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
  String get planInfoDangerZoneTitle => 'Eliminar plan';

  @override
  String get planInfoDangerZoneSubtitle =>
      'Eliminar el plan borrará todos los eventos asociados. Esta acción no se puede deshacer.';

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
  String get calendarOptionsTooltip => 'Opciones del calendario';

  @override
  String calendarTitleDaysRange(int start, int end, int total, int visible) {
    return 'Días $start-$end de $total ($visible visibles)';
  }

  @override
  String get calendarPreviousDays => 'Días anteriores';

  @override
  String get calendarNextDays => 'Días siguientes';

  @override
  String get calendarMenuSectionView => 'Vista';

  @override
  String get calendarMenuPlanComplete => 'Plan completo';

  @override
  String get calendarMenuMyAgenda => 'Mi agenda';

  @override
  String get calendarMenuCustomView => 'Vista personalizada';

  @override
  String get calendarMenuSectionEventFilter => 'Filtro eventos';

  @override
  String get calendarMenuAllEvents => 'Todos los eventos';

  @override
  String get calendarMenuDraftsOnly => 'Solo borradores';

  @override
  String get calendarMenuConfirmedOnly => 'Solo confirmados';

  @override
  String get calendarMenuProposalsOnly => 'Solo propuestas';

  @override
  String get calendarMenuSectionDaysVisible => 'Días visibles';

  @override
  String get calendarMenuDays1 => '1 día';

  @override
  String get calendarMenuDays3 => '3 días';

  @override
  String get calendarMenuDays7 => '7 días';

  @override
  String get calendarMenuDaysAllPlan => 'Todos los días del plan';

  @override
  String get eventSelectTypeFirstHint =>
      'Elige primero un tipo de evento para ver el resto de campos.';

  @override
  String get planReferenceNotesTitle => 'Notas y referencias del plan';

  @override
  String get planReferenceNotesHint =>
      'Correos con agencias, proveedores, texto que quieras tener a mano (solo texto).';

  @override
  String get myPlanSummaryParticipantsSection => 'Participantes';

  @override
  String get eventLongNotesLabel => 'Notas largas / texto de agencia';

  @override
  String get adminOrphanScanTitle => 'Registros huérfanos (participaciones)';

  @override
  String get adminOrphanScanButton => 'Analizar participaciones sin plan';

  @override
  String adminOrphanScanResult(int total, int orphans) {
    return 'Total documentos: $total. Huérfanos: $orphans.';
  }

  @override
  String get calendarMenuManageParticipants => 'Gestionar participantes';

  @override
  String get calendarMenuFullscreen => 'Pantalla completa';

  @override
  String get calendarMenuManageRoles => 'Gestión de roles';

  @override
  String get dashboardTabIn => 'in';

  @override
  String get dashboardTabStats => 'stats';

  @override
  String get dashboardTabPayments => 'pagos';

  @override
  String get dashboardTabChat => 'chat';

  @override
  String get dashboardTabPendingEvents => 'Buzón';

  @override
  String get dashboardTabNotifications => 'notificaciones';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsSectionInvitations => 'Invitaciones a planes';

  @override
  String get notificationsSectionEmailEvents => 'Eventos desde correo';

  @override
  String get notificationsFilterAll => 'Todas';

  @override
  String get notificationsFilterAction => 'Pendientes de acción';

  @override
  String get notificationsFilterInfo => 'Solo informativas';

  @override
  String get notificationsMarkAllAsRead => 'Marcar todas como leídas';

  @override
  String get notificationsEmpty => 'No hay notificaciones';

  @override
  String get notificationsGenerateTestData =>
      'Generar notificaciones de prueba';

  @override
  String notificationsTestDataGenerated(int invitations, int pending, int app) {
    return 'Creadas: $invitations invitaciones, $pending eventos correo, $app notificaciones';
  }

  @override
  String get pendingEventsTitle => 'Eventos desde correo';

  @override
  String get pendingEventsEmpty =>
      'No tienes eventos pendientes. Reenvía confirmaciones a la dirección de la plataforma.';

  @override
  String get pendingEventsAssignToPlan => 'Asignar a plan';

  @override
  String get pendingEventsDiscard => 'Descartar';

  @override
  String get pendingEventUnparsed => 'Sin parsear';

  @override
  String get pendingEventAssignTitle => 'Elegir plan';

  @override
  String get pendingEventAssigned => 'Evento asignado al plan';

  @override
  String get pendingEventDiscarded => 'Evento descartado';

  @override
  String get pendingEventDiscardConfirm => '¿Descartar este evento pendiente?';

  @override
  String get pendingEventsNoPlans =>
      'No tienes planes. Crea uno antes de asignar.';

  @override
  String get understood => 'Entendido';

  @override
  String get dashboardFirestoreInitializing => 'Inicializando Firestore...';

  @override
  String get dashboardFirestoreInitialized => '✅ Firestore Inicializado';

  @override
  String get dashboardTestUsersLabel => '👥 Usuarios de Prueba:';

  @override
  String get dashboardTestUsersPasswordNote =>
      'Todos los usuarios usan la contraseña: test123456';

  @override
  String get dashboardTestUsersEmailNote =>
      'Todos los emails llegan a: unplanazoo@gmail.com';

  @override
  String get dashboardFirestoreSessionNote =>
      '⚠️ Nota: Tu sesión actual puede haber cambiado. Si es necesario, vuelve a hacer login.';

  @override
  String get dashboardFirestoreIndexes => '📊 Índices de Firestore:';

  @override
  String get dashboardFirestoreIndexesWarning =>
      '⚠️ IMPORTANTE: Los índices NO se despliegan automáticamente desde la app.';

  @override
  String get dashboardFirestoreIndexesDeployHint =>
      'Debes desplegarlos manualmente usando:';

  @override
  String get dashboardFirestoreIndexesDeployCommand =>
      'firebase deploy --only firestore:indexes';

  @override
  String get dashboardFirestoreConsoleHint => 'O desde Firebase Console:';

  @override
  String get dashboardFirestoreConsoleSteps =>
      '1. Ve a Firebase Console\n2. Firestore Database → Indexes\n3. Verifica que hay 25 índices definidos\n4. Los índices se crearán automáticamente';

  @override
  String get dashboardFirestoreDocs => '📝 Ver documentación completa:';

  @override
  String get dashboardFirestoreDocsPaths =>
      'docs/configuracion/FIRESTORE_INDEXES_AUDIT.md\ndocs/configuracion/USUARIOS_PRUEBA.md';

  @override
  String dashboardFirestoreInitError(String error) {
    return '❌ Error al inicializar Firestore: $error';
  }

  @override
  String get dashboardDeleteTestUsersTitle => '🗑️ Eliminar Usuarios de Prueba';

  @override
  String get dashboardDeleteTestUsersSelect =>
      'Selecciona los usuarios que deseas eliminar:';

  @override
  String get dashboardDeleteTestUsersWarning =>
      '⚠️ ADVERTENCIA: Esta acción eliminará los usuarios de Firebase Auth y Firestore. No se puede deshacer.';

  @override
  String get dashboardSelectAll => 'Seleccionar todos';

  @override
  String get dashboardDeselectAll => 'Deseleccionar todos';

  @override
  String dashboardDeletingUsersCount(int count) {
    return 'Eliminando $count usuario(s)...';
  }

  @override
  String get dashboardDeletionCompleted => '✅ Eliminación Completada';

  @override
  String dashboardDeletedFromFirestore(int count) {
    return 'Eliminados de Firestore: $count';
  }

  @override
  String dashboardNotFoundCount(int count) {
    return 'No encontrados: $count';
  }

  @override
  String dashboardErrorsCount(int count) {
    return 'Errores: $count';
  }

  @override
  String get dashboardErrorsDetail => 'Errores detallados:';

  @override
  String get dashboardDeleteAuthNote =>
      '⚠️ NOTA: Los usuarios también deben eliminarse manualmente de Firebase Auth Console si existen ahí.';

  @override
  String dashboardDeleteUsersError(String error) {
    return '❌ Error al eliminar usuarios: $error';
  }

  @override
  String get dashboardGeneratingFrankenstein =>
      '🧟 Generando plan Frankenstein...';

  @override
  String get dashboardFrankensteinSuccess =>
      '🎉 Plan Frankenstein generado exitosamente!';

  @override
  String get dashboardFrankensteinError =>
      '❌ Error al generar plan Frankenstein';

  @override
  String get dashboardNoPlansYet => 'Aún no tienes planes';

  @override
  String get dashboardCreateFirstPlanHint =>
      'Crea tu primer plan con el botón +';

  @override
  String dashboardInvitationsPendingCount(int count) {
    return 'Tienes $count invitación(es) pendiente(s)';
  }

  @override
  String get dashboardMessageCenterOpenNotifications => 'Ver notificaciones';

  @override
  String get statusInvitationPending => 'Invitación pendiente';

  @override
  String get statusPendingToAccept => 'Pendiente de aceptar';

  @override
  String get statusAccepted => 'Aceptado';

  @override
  String get statusRejected => 'Rechazado';

  @override
  String get statusShortIn => 'dentro';

  @override
  String get statusShortOut => 'fuera';

  @override
  String get statusShortPending => 'pend.';

  @override
  String get myStatusLabel => 'Mi estado';

  @override
  String get planCardInvitationBadge => 'Invitación';

  @override
  String get planCardPendingBadge => 'Pendiente';

  @override
  String get planCardChipInvitationQuestion => '¿Quieres unirte a este plan?';

  @override
  String planCardLeavePlanConfirmBody(String planName) {
    return 'Si sales de \"$planName\", dejarás de ver este plan en tu lista y dejarás de recibir avisos.\n\nPara volver a entrar más adelante, el organizador tendrá que invitarte de nuevo.';
  }

  @override
  String get planMyStatusHelpTitle => 'Mi estado en el plan';

  @override
  String get planMyStatusHelpDefault =>
      'El chip resume tu relación con este plan:\n\n• pend. — Tienes una invitación o una participación pendiente de aceptar. Pulsa el chip para aceptar o rechazar.\n\n• dentro — Ya participas (o eres organizador). Si no eres organizador, pulsa para salir del plan.\n\n• fuera — Declinaste la invitación. Si el organizador te invita de nuevo, lo verás en Notificaciones.\n\nLas invitaciones por correo también se gestionan desde Notificaciones.';

  @override
  String get planStatusRejectedSnackbar =>
      'Indicaste que no te unías a este plan. Si recibes una nueva invitación, aparecerá en Notificaciones.';

  @override
  String get planStatusSemanticsPending =>
      'Pendiente de aceptar o rechazar invitación al plan';

  @override
  String get planStatusSemanticsIn => 'Participas en el plan';

  @override
  String get planStatusSemanticsOut => 'Rechazaste unirte a este plan';

  @override
  String get planCardOrganizerChipMessage =>
      'Como organizador, gestiona el plan desde su ficha.';

  @override
  String get planCardLeavePlanTitle => 'Salir del plan';

  @override
  String get planCardLeavePlanButton => 'Salir';

  @override
  String get planCardLeftPlanSuccess => 'Has salido del plan';

  @override
  String get planCardLeftPlanError => 'No se pudo salir del plan';

  @override
  String invitationPlanLabel(String planId) {
    return 'Plan: $planId';
  }

  @override
  String invitationRoleLabel(String role) {
    return 'Rol: $role';
  }

  @override
  String get invitationPendingEmailLabel =>
      'Invitación por email (pendiente de registro)';

  @override
  String get invitationAcceptedParticipant =>
      'Invitación aceptada. Ya eres participante del plan.';

  @override
  String get invitationAcceptFailed =>
      'No se pudo aceptar. Prueba con el link del correo.';

  @override
  String get reject => 'Rechazar';

  @override
  String get invitationRejected => 'Invitación rechazada';

  @override
  String get invitationRejectFailed => 'No se pudo rechazar.';

  @override
  String get linkCopiedToClipboard => 'Link copiado al portapapeles';

  @override
  String get copyLink => 'Copiar link';

  @override
  String get mustSignInToAcceptInvitations =>
      '❌ Debes iniciar sesión para aceptar invitaciones';

  @override
  String get continueButton => 'Continuar';

  @override
  String get invitationAcceptedAddedToPlan =>
      '✅ Invitación aceptada. Has sido añadido al plan.';

  @override
  String get invitationRejectedSuccess => 'Invitación rechazada';

  @override
  String get dashboardSelectPlanazoo => 'Selecciona un Planazoo';

  @override
  String get dashboardClickPlanToSeeCalendar =>
      'Haz clic en un planazoo de la lista\nderecha para ver su calendario';

  @override
  String get dashboardEmailLabel => 'email';

  @override
  String get dashboardIntroduceEmail => 'Introduce el mail';

  @override
  String get dashboardSelectPlanToSeeParticipants =>
      'Selecciona un plan para ver los participantes';

  @override
  String get dashboardSelectPlanToSeeChat =>
      'Selecciona un plan para ver el chat';

  @override
  String get dashboardSelectPlanToSeePayments =>
      'Selecciona un plan para ver el resumen de pagos';

  @override
  String get dashboardSelectPlanToSeeStats =>
      'Selecciona un plan para ver las estadísticas';

  @override
  String get dashboardSelectPlanToSeeNotifications =>
      'Selecciona un plan para ver sus notificaciones';

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
  String get placeSearchHint => 'Buscar lugar (hotel, dirección…)';

  @override
  String get placeAddressLabel => 'Dirección';

  @override
  String get costCurrency => 'Moneda del coste';

  @override
  String get cost => 'Coste';

  @override
  String get costOptional => 'Coste del alojamiento (opcional)';

  @override
  String get costHint => 'Ej: 450.00';

  @override
  String get eventDescription => 'Descripción del evento';

  @override
  String get eventDescriptionHint => 'Nombre del evento';

  @override
  String get eventLocationLabel => 'Lugar';

  @override
  String get eventAddressSingleLabel => 'Localización';

  @override
  String get eventAddressSingleHint => 'Lugar o dirección del evento';

  @override
  String get eventUrlLabel => 'Enlace web';

  @override
  String get eventUrlHint => 'https://...';

  @override
  String get eventLocationHint => 'Buscar lugar (dirección, sitio…)';

  @override
  String get eventAddressLabel => 'Dirección';

  @override
  String get openInGoogleMaps => 'Abrir en Google Maps';

  @override
  String get departureAirportLabel => 'Aeropuerto de salida';

  @override
  String get departureAirportHint => 'Ej: Madrid Barajas, MAD';

  @override
  String get arrivalAirportLabel => 'Aeropuerto de llegada';

  @override
  String get arrivalAirportHint => 'Ej: Roma Fiumicino, FCO';

  @override
  String get taxiOriginLabel => 'Origen';

  @override
  String get taxiOriginHint => 'Dirección de recogida';

  @override
  String get taxiDestinationLabel => 'Destino';

  @override
  String get taxiDestinationHint => 'Dirección de llegada';

  @override
  String get taxiSeatsLabel => 'Plazas del taxi';

  @override
  String get taxiSeatsHint => 'Número de plazas';

  @override
  String get eventTransferTerminalLabel => 'Terminal / puerta';

  @override
  String get eventTransferTerminalHint => 'Ej: T2, puerta B12';

  @override
  String get eventTransferAirlineLabel => 'Aerolínea / vuelo';

  @override
  String get eventTransferAirlineHint => 'Ej: Iberia, IB1234';

  @override
  String get eventTransferAirportMeetLabel => 'Presentación en aeropuerto';

  @override
  String get eventTransferAirportMeetHint =>
      'Ej: 2 h antes del vuelo, mostrador…';

  @override
  String get eventRentalCompanyLabel => 'Compañía de alquiler';

  @override
  String get eventRentalCompanyHint => 'Ej: Hertz, Europcar, Sixt';

  @override
  String get eventRentalOfficeLabel => 'Oficina de recogida/entrega';

  @override
  String get eventRentalOfficeHint => 'Ej: Aeropuerto T4, centro ciudad';

  @override
  String get eventRentalContractCodeLabel => 'Contrato o reserva';

  @override
  String get eventRentalContractCodeHint => 'Ej: RC-123456';

  @override
  String get eventRentalVehiclePlateLabel => 'Matrícula (opcional)';

  @override
  String get eventRentalVehiclePlateHint => 'Ej: 1234ABC';

  @override
  String get eventRentalPickupReturnNotesLabel => 'Checklist recogida/entrega';

  @override
  String get eventRentalPickupReturnNotesHint =>
      'Ej: combustible, daños visibles, km, política de devolución';

  @override
  String get flightNumberLabel => 'Número de vuelo';

  @override
  String get flightNumberHint => 'Ej: IB6842, AF1135';

  @override
  String get flightDateLabel => 'Fecha del vuelo';

  @override
  String get getFlightDataButton => 'Obtener datos del vuelo';

  @override
  String get flightNumberRequired =>
      'Introduce el número de vuelo (ej: IB6842).';

  @override
  String get flightDataLoaded => 'Datos del vuelo cargados.';

  @override
  String get eventTabGeneral => 'General';

  @override
  String get eventTabMyInfo => 'Mi información';

  @override
  String get eventTabOthersInfo => 'Info de Otros';

  @override
  String get eventReadOnlySnackBar =>
      'Este dato es común al plan y solo puede editarlo el creador o un administrador.';

  @override
  String get eventType => 'Tipo de evento';

  @override
  String get eventSubtype => 'Subtipo';

  @override
  String get changeTypeLabel => 'Cambiar tipo';

  @override
  String get changeSubtypeLabel => 'Cambiar subtipo';

  @override
  String get chooseSubtypeLabel => 'Elegir subtipo';

  @override
  String get selectValidTypeFirst => 'Selecciona primero un tipo válido';

  @override
  String get invalidSubtype => 'Subtipo inválido para el tipo seleccionado';

  @override
  String get eventDialogFixValidationErrors =>
      'Revisa los campos marcados o incompletos antes de guardar.';

  @override
  String get eventDialogParticipantsScopeLabel => 'Participantes del evento';

  @override
  String get eventDialogForAllParticipantsTitle =>
      'Este evento es para todos los participantes del plan';

  @override
  String get eventDialogForAllParticipantsSubtitleOn =>
      'Todos los participantes estarán incluidos automáticamente';

  @override
  String get eventDialogForAllParticipantsSubtitleOff =>
      'Selecciona participantes específicos abajo';

  @override
  String get eventDialogAddLinkedExpenseTooltip =>
      'Añadir gasto ligado a este evento';

  @override
  String get calendarContextEditEvent => 'Editar evento';

  @override
  String get calendarContextCopyEvent => 'Copiar evento';

  @override
  String get calendarContextDeleteEvent => 'Eliminar evento';

  @override
  String get calendarContextCopiedOk => 'Evento copiado correctamente';

  @override
  String get calendarContextCopiedOkWithOffset =>
      'Copia creada (+30 min), color distinto y prefijo COPIA';

  @override
  String get calendarContextCopiedError => 'No se pudo copiar el evento';

  @override
  String get calendarContextDeleteTitle => 'Eliminar evento';

  @override
  String get calendarContextDeleteMessage =>
      '¿Seguro que quieres eliminar este evento?';

  @override
  String get calendarContextDeletedOk => 'Evento eliminado correctamente';

  @override
  String get calendarContextDeletedError => 'No se pudo eliminar el evento';

  @override
  String get eventSponsoredTag => 'Patrocinado';

  @override
  String eventSponsoredBy(String sponsor) {
    return 'Patrocinado por $sponsor';
  }

  @override
  String get eventSponsoredStaticHint =>
      'Prueba estática de monetización contextual (sin anuncios activos).';

  @override
  String get eventSponsoredOpenOffer => 'Ver oferta';

  @override
  String get eventSponsoredOpenError =>
      'No se pudo abrir el enlace del patrocinador';

  @override
  String get eventStatusDraft => 'Borrador';

  @override
  String get eventStatusConfirmed => 'Confirmado';

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
  String eventDurationFormatMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get eventDurationFormatOneHour => '1 hora';

  @override
  String eventDurationFormatHoursOnly(int hours) {
    return '$hours h';
  }

  @override
  String eventDurationFormatHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

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

  @override
  String get myPlanSummaryTab => 'Mi resumen';

  @override
  String get planNotesTabTitle => 'Notas';

  @override
  String get planNotesTabCommon => 'Común';

  @override
  String get planNotesTabPersonal => 'Personal';

  @override
  String get planNotesPreparationTitle => 'Preparación';

  @override
  String get planNotesCommonIntro =>
      'Notas y lista de preparación compartidas. Quién puede editar la lista lo define el organizador.';

  @override
  String get planNotesPersonalIntro =>
      'Solo tú ves esta nota y tu lista de preparación personal.';

  @override
  String get planNotesCommonNoteLabel => 'Nota compartida';

  @override
  String get planNotesPersonalNoteLabel => 'Nota personal';

  @override
  String get planNotesAddPrepItem => 'Añadir ítem';

  @override
  String get planNotesSave => 'Guardar';

  @override
  String get planNotesSaved => 'Guardado';

  @override
  String get planNotesSaveError =>
      'No se pudo guardar. Revisa conexión o permisos.';

  @override
  String get planNotesReadOnlyHint =>
      'Puedes ver esta sección pero no editarla.';

  @override
  String get planNotesPolicyTitle =>
      'Quién puede editar la lista de preparación común';

  @override
  String get planNotesPolicyOrganizerOnly => 'Solo el organizador';

  @override
  String get planNotesPolicySelected => 'Algunos participantes';

  @override
  String get planNotesPolicyAll => 'Todos los participantes';

  @override
  String get planNotesSelectParticipantsTitle =>
      'Elige quién puede editar la lista';

  @override
  String get planNotesApplySelection => 'Aplicar';

  @override
  String get planNotesNoWorkspaceYet =>
      'Las notas compartidas aún no están disponibles.';

  @override
  String get planNotesNewItemHint => 'Nuevo ítem';

  @override
  String get calendarViewModeCalendar => 'Calendario';

  @override
  String get myPlanSummaryHint => 'Esta es tu vista como participante';

  @override
  String get myPlanSummaryToday => 'Hoy';

  @override
  String get myPlanSummaryTomorrow => 'Mañana';

  @override
  String get myPlanSummaryFlights => 'Desplazamientos';

  @override
  String get myPlanSummaryFlightsHint =>
      'Tren, avión, coche y otros desplazamientos';

  @override
  String get myPlanSummaryAccommodation => 'Alojamientos';

  @override
  String get myPlanSummaryImportant => 'Lo más importante';

  @override
  String get myPlanSummaryResumenSection => 'Resumen';

  @override
  String get myPlanSummaryViewMine => 'mío';

  @override
  String get myPlanSummaryViewPlan => 'todos';

  @override
  String get myPlanSummaryLabelAll => 'Todos';

  @override
  String get myPlanSummaryChronological => 'Plan completo';

  @override
  String get myPlanSummaryMyInfo => 'Mi información';

  @override
  String get myPlanSummaryEmpty =>
      'Aún no tienes eventos ni alojamientos en este plan.';

  @override
  String get myPlanSummaryGoToCalendar => 'Ir al calendario';

  @override
  String get myPlanSummaryNoMyInfo =>
      'No tienes datos personales en eventos de hoy o mañana.';

  @override
  String get myPlanSummarySeeMore => 'Ver más';

  @override
  String get myPlanSummarySeeLess => 'Ver menos';

  @override
  String get myPlanSummaryDraftsOnlyTooltip => 'Solo borradores';

  @override
  String myPlanSummaryParticipantsCount(int count) {
    return '$count participantes';
  }

  @override
  String get myPlanSummaryQuickImportant => 'Importante';

  @override
  String get myPlanSummaryQuickParticipants => 'Participantes';

  @override
  String get myPlanSummaryQuickToday => 'hoy';

  @override
  String get myPlanSummaryQuickTomorrow => 'mañana';

  @override
  String get myPlanSummaryTimeNextDaySuffix => ' (+1)';

  @override
  String get proposalsTab => 'Propuestas';

  @override
  String get proposalsPendingTitle => 'Propuestas pendientes';

  @override
  String get proposalsEmpty => 'No hay propuestas pendientes';

  @override
  String get proposalsOnlyOrganizer =>
      'Solo el organizador puede revisar las propuestas de eventos.';

  @override
  String get proposalsAccept => 'Aceptar';

  @override
  String get proposalsReject => 'Rechazar';

  @override
  String get viewMySummaryLabel => 'Ver mi resumen';

  @override
  String get viewMySummaryTooltip => 'Ir a Mi resumen';

  @override
  String get eventProposalParticipantHint =>
      'Guardarás este evento como propuesta. El organizador recibirá una notificación y podrá aceptarla o rechazarla desde el calendario.';

  @override
  String get plansListNoPlansYet => 'No tienes planes aún';

  @override
  String get plansListCreateFirstPlan => 'Crea tu primer plan para comenzar';

  @override
  String get plansListNoPlansFound => 'No se encontraron planes';

  @override
  String get plansListLoadError => 'Error al cargar planes';

  @override
  String get plansListFiltersButton => 'Filtros';

  @override
  String get plansListViewModeTooltip => 'Vista lista o calendario';

  @override
  String get plansListFilterAll => 'Todos';

  @override
  String get plansListFilterIn => 'Estoy in';

  @override
  String get plansListFilterPending => 'Pendientes';

  @override
  String get plansListFilterClosed => 'Cerrados';

  @override
  String get plansListProfileTooltip => 'Perfil';

  @override
  String get invitationTitle => 'Invitación a Plan';

  @override
  String get invitationNotFound => 'Invitación no encontrada o inválida';

  @override
  String get invitationExpired => 'Esta invitación ha expirado';

  @override
  String get invitationAlreadyAccepted => 'Ya has aceptado esta invitación';

  @override
  String get invitationAlreadyRejected => 'Has rechazado esta invitación';

  @override
  String invitationLoadError(Object error) {
    return 'Error al cargar la invitación: $error';
  }

  @override
  String get invitationLoginToAccept =>
      'Inicia sesión para aceptar la invitación';

  @override
  String get invitationNeedAccount =>
      'Necesitas una cuenta para unirte al plan';

  @override
  String get invitationLoginButton => 'Iniciar sesión';

  @override
  String get invitationCreateAccount => 'Crear cuenta';

  @override
  String get invitationAcceptButton => 'Aceptar invitación';

  @override
  String get invitationProcessing => 'Procesando...';

  @override
  String get invitationRejectButton => 'Rechazar invitación';

  @override
  String get invitationAcceptSuccess =>
      'Invitación aceptada. Redirigiendo al plan...';

  @override
  String get invitationAcceptError => 'Error al aceptar la invitación';

  @override
  String get invitationRejectConfirmTitle => 'Rechazar invitación';

  @override
  String get invitationRejectConfirmMessage =>
      '¿Estás seguro de que quieres rechazar esta invitación?';

  @override
  String get invitationCancel => 'Cancelar';

  @override
  String get invitationRejectConfirmButton => 'Rechazar';

  @override
  String get invitationRejectError => 'Error al rechazar la invitación';

  @override
  String get invitationBack => 'Volver';

  @override
  String get invitationYouHaveBeenInvited => '¡Has sido invitado!';

  @override
  String get invitationInvitedToJoinPlan =>
      'Te han invitado a unirse a un plan';

  @override
  String get invitationPlanDetails => 'Detalles del Plan';

  @override
  String get invitationLabelName => 'Nombre';

  @override
  String get invitationLabelDescription => 'Descripción';

  @override
  String get invitationLabelStartDate => 'Fecha inicio';

  @override
  String get invitationLabelEndDate => 'Fecha fin';

  @override
  String get invitationLabelInvitedEmail => 'Email invitado';

  @override
  String get invitationCustomMessage => 'Mensaje personalizado';

  @override
  String invitationWrongUserWarning(String invitedEmail, String currentEmail) {
    return 'Esta invitación es para $invitedEmail, pero estás conectado como $currentEmail. Por favor, inicia sesión con el email correcto.';
  }

  @override
  String invitationExpiresOn(String date) {
    return 'Esta invitación expira el $date';
  }

  @override
  String genericErrorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get noPermissionEditEvent =>
      'No tienes permisos para editar este evento';

  @override
  String get noPermissionEditPersonalInfoOthers =>
      'No tienes permisos para editar la información personal de otros participantes.';

  @override
  String get noPermissionTitle => 'Sin permisos';

  @override
  String get helpManualOpenFromLogin => 'Manual rápido (beta)';

  @override
  String get helpManualTitle => 'Manual rápido para nuevos usuarios';

  @override
  String get helpManualIntro =>
      'Guía breve para la fase de pruebas. Te ayuda a empezar y entender los flujos más importantes de Planazoo.';

  @override
  String get helpManualSectionGettingStartedTitle => '1) Primeros pasos';

  @override
  String get helpManualGettingStarted1 =>
      'Si ya tienes cuenta, inicia sesión con email/usuario y contraseña, o con Google.';

  @override
  String get helpManualGettingStarted2 =>
      'Si no tienes cuenta, regístrate y verifica tu email antes de continuar.';

  @override
  String get helpManualGettingStarted3 =>
      'Selecciona idioma en la esquina superior derecha cuando estés en login.';

  @override
  String get helpManualSectionPlanAndCalendarTitle => '2) Planes y calendario';

  @override
  String get helpManualPlanCalendar1 =>
      'Crea un plan y define fechas; luego añade eventos y alojamientos.';

  @override
  String get helpManualPlanCalendar2 =>
      'En móvil, la edición principal es por tap y diálogo; en web hay más acciones avanzadas.';

  @override
  String get helpManualPlanCalendar3 =>
      'Usa la vista de resumen para revisar rápidamente eventos, vuelos y alojamientos.';

  @override
  String get helpManualSectionInvitationsTitle =>
      '3) Invitaciones y participantes';

  @override
  String get helpManualInvitations1 =>
      'Invita por email o usuario según el flujo disponible en tu pantalla de participantes.';

  @override
  String get helpManualInvitations2 =>
      'Cuando te inviten, verás estado pending/in/out y podrás responder desde los chips.';

  @override
  String get helpManualInvitations3 =>
      'Si un usuario no aparece, revisa que el email invitado sea correcto y que esté registrado.';

  @override
  String get helpManualSectionNotificationsTitle => '4) Notificaciones';

  @override
  String get helpManualNotifications1 =>
      'Consulta la campana para ver notificaciones del plan y elementos pendientes de acción.';

  @override
  String get helpManualNotifications2 =>
      'Las no leídas aparecen destacadas; al entrar en detalle se marcan como leídas.';

  @override
  String get helpManualNotifications3 =>
      'Si no ves avisos esperados, abre el plan y revisa también la pestaña de notificaciones.';

  @override
  String get helpManualSectionTipsTitle => '5) Consejos para pruebas';

  @override
  String get helpManualTips1 =>
      'Prioriza validar creación/edición de evento, invitaciones y flujo de notificaciones.';

  @override
  String get helpManualTips2 =>
      'Comprueba siempre web e iOS para detectar diferencias de comportamiento.';

  @override
  String get helpManualTips3 =>
      'Si algo falla, anota pasos exactos, usuario usado y pantalla para reproducirlo rápido.';

  @override
  String get tooltipCreateAccommodation => 'Crear alojamiento';

  @override
  String get tooltipChangePlanState => 'Cambiar estado del plan';

  @override
  String get tooltipCreateParticipantGroup => 'Crear grupo';

  @override
  String get tooltipAddEmailToGroup => 'Añadir email';

  @override
  String get tooltipManageParticipantsCalendar => 'Gestionar participantes';

  @override
  String get tooltipChangeUserPerspective => 'Cambiar perspectiva de usuario';

  @override
  String get tooltipPaymentAdd => 'Añadir';

  @override
  String get tooltipCopyInviteLink => 'Copiar enlace';

  @override
  String get tooltipCancelAction => 'Cancelar';

  @override
  String get snackUserNotAuthenticated => 'Usuario no autenticado';

  @override
  String get snackSelectParticipant => 'Selecciona un participante';

  @override
  String get snackInvalidMonetaryAmount => 'Importe no válido';

  @override
  String get snackSelectWhoPaid => 'Selecciona quién pagó';

  @override
  String get snackSelectAtLeastOneForSplit =>
      'Selecciona al menos un participante en el reparto';

  @override
  String get snackCheckCustomSplitAmounts =>
      'Comprueba los importes del reparto personalizado';

  @override
  String snackExpenseSplitSumMismatch(String splitSum, String totalAmount) {
    return 'La suma del reparto ($splitSum) debe coincidir con el importe total ($totalAmount)';
  }

  @override
  String get snackInvalidEmailShort => 'Email inválido';

  @override
  String get snackEmailAlreadyInGroup => 'Este email ya está en el grupo';

  @override
  String snackHelpUpdatedCount(int count) {
    return 'Ayuda actualizada: $count textos';
  }

  @override
  String get snackContributionSaved => 'Aportación registrada';

  @override
  String get snackExpenseRegistered => 'Gasto registrado';

  @override
  String get snackSaveFailed => 'Error al guardar';

  @override
  String get snackExpenseConceptRequired => 'Indica el concepto del gasto';

  @override
  String get snackPleaseEnterEmail => 'Por favor ingresa un email';

  @override
  String get snackInvitationSentSuccess => 'Invitación enviada';

  @override
  String get snackUserPromotedToOrganizer => 'Usuario promovido a organizador';

  @override
  String get snackUserRemovedFromPlan => 'Usuario removido del plan';

  @override
  String get calendarSelectAtLeastOneParticipant =>
      'Debes seleccionar al menos un participante';

  @override
  String get snackHelpSyncFailed => 'Error al sincronizar la ayuda';

  @override
  String get snackInviteDailyLimitReached =>
      'Error al enviar invitación. Verifica que no hayas alcanzado el límite de invitaciones diarias (50/día).';

  @override
  String get snackCannotAddParticipantsCurrentState =>
      'No se pueden añadir participantes en el estado actual del plan.';

  @override
  String get inviteUserDialogTitle => 'Invitar usuario';

  @override
  String get inviteUserDialogDescription =>
      'Ingresa el email del usuario que quieres invitar:';

  @override
  String get inviteUserInvite => 'Invitar';

  @override
  String snackHelpSyncFailedDetail(String error) {
    return 'Error al sincronizar la ayuda: $error';
  }

  @override
  String get kittyAddContributionTitle => 'Añadir aportación al bote';

  @override
  String get kittyRegisterExpenseTitle => 'Registrar gasto del bote';

  @override
  String get kittyYourOwnContribution => 'Tú (mi aportación)';

  @override
  String get kittySelectParticipantHint => 'Selecciona participante';

  @override
  String get kittyAmountLabel => 'Monto *';

  @override
  String get kittyConceptOptionalLabel => 'Concepto (opcional)';

  @override
  String get kittyDateLabel => 'Fecha *';

  @override
  String get kittyExpenseConceptLabel => 'Concepto *';

  @override
  String get kittyValidationEnterAmount => 'Ingresa un monto';

  @override
  String get kittyValidationSelectParticipant => 'Selecciona un participante';

  @override
  String kittyLoadParticipantsError(String error) {
    return 'Error: $error';
  }

  @override
  String get kittyExpenseNotAllowedTitle => 'No permitido';

  @override
  String get kittyExpenseOrganizerOnlyBody =>
      'Solo el organizador del plan puede registrar gastos del bote.';

  @override
  String get participantRemoveConfirmMessage =>
      '¿Estás seguro de que quieres eliminar a este participante del plan?';

  @override
  String participantsInviteResending(String email) {
    return 'Re-enviando invitación a $email';
  }

  @override
  String get participantsInviteResendButton => 'Re-enviar invitación';

  @override
  String get snackPreviousInvitationCancelled =>
      'Invitación anterior cancelada';

  @override
  String get snackInvitationCancelledShort => 'Invitación cancelada';

  @override
  String get snackInvitationCancelFailed => 'No se pudo cancelar';

  @override
  String get tooltipCancelPreviousInvitation => 'Cancelar invitación anterior';

  @override
  String get snackLinkCopiedShort => 'Enlace copiado';

  @override
  String get invitationCreatedTitle => 'Invitación creada';

  @override
  String get invitationShareLinkHint =>
      'Comparte este enlace con la persona invitada:';

  @override
  String get inviteOptionalMessageLabel => 'Mensaje (opcional)';

  @override
  String snackInviteSentToUserDisplay(String userDisplay) {
    return 'Invitación enviada a $userDisplay. Puede aceptar o rechazar.';
  }

  @override
  String snackInviteSendError(String error) {
    return 'Error al enviar invitación: $error';
  }

  @override
  String get inviteByEmailTitle => 'Invitar por email';

  @override
  String invitePendingExistsForEmail(String email) {
    return 'Ya existe una invitación pendiente para $email.\n\n¿Qué deseas hacer?';
  }

  @override
  String get roleFieldLabel => 'Rol';

  @override
  String get participantRoleLabel => 'Participante';

  @override
  String get observerRoleLabel => 'Observador';

  @override
  String get inviteSendInvitation => 'Enviar invitación';

  @override
  String get snackUserAlreadyParticipant =>
      'Este usuario ya es participante del plan';

  @override
  String get snackPendingInviteExists =>
      'Ya existe una invitación pendiente para este email';

  @override
  String get snackCouldNotCreateInvitation => 'No se pudo crear la invitación';

  @override
  String snackInviteSentWillAppearPending(String email) {
    return 'Invitación enviada a $email. Aparecerá en la lista como pendiente.';
  }

  @override
  String snackInviteCreatedForEmail(String email) {
    return 'Invitación creada para $email';
  }

  @override
  String snackUserAddedToPlan(String email) {
    return 'Usuario $email añadido al plan';
  }

  @override
  String snackCreateInviteError(String detail) {
    return 'Error al crear invitación: $detail';
  }

  @override
  String get inviterNameFallback => 'Un usuario';

  @override
  String snackInviteUserBlockedOrFailed(String userDisplay) {
    return '$userDisplay ya es participante o no se pudo crear la invitación';
  }

  @override
  String get snackParticipantRemovedFromPlan =>
      'Participante eliminado del plan';

  @override
  String snackParticipantRemoveError(String error) {
    return 'Error al eliminar participante: $error';
  }

  @override
  String get invitationsSectionTitle => 'Invitaciones';

  @override
  String get entityAttachmentsPlanTitle => 'Archivos del plan';

  @override
  String get entityAttachmentsEventTitle => 'Archivos del evento';

  @override
  String get entityAttachmentsAccommodationTitle => 'Archivos del alojamiento';

  @override
  String get entityAttachmentsUpload => 'Subir';

  @override
  String get entityAttachmentsUploading => 'Subiendo...';

  @override
  String get entityAttachmentsEmpty => 'Sin archivos adjuntos';

  @override
  String get entityAttachmentsDeleteTitle => 'Eliminar archivo';

  @override
  String entityAttachmentsDeleteConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get entityAttachmentsReadError =>
      'No se pudo leer el archivo seleccionado.';

  @override
  String entityAttachmentsUploadError(String error) {
    return 'No se pudo subir el archivo: $error';
  }

  @override
  String get entityAttachmentsDeleteError => 'No se pudo eliminar el archivo.';

  @override
  String get entityAttachmentsSnackbarAdded =>
      'Archivo adjuntado. Pulsa Guardar para confirmar cambios.';

  @override
  String get entityAttachmentsSnackbarRemoved =>
      'Archivo eliminado. Pulsa Guardar para confirmar cambios.';
}
