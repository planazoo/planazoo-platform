// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Planazoo';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle => 'Access your account';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get emailOrUsernameLabel => 'Email or Username';

  @override
  String get emailOrUsernameHint => 'your@email.com or @username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Your password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get googleSignInError => 'Error signing in with Google';

  @override
  String get googleSignInCancelled => 'Sign in cancelled';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get resendVerification => 'Resend verification';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerLink => 'Sign up';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Join Planazoo and start planning';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'Your full name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Repeat your password';

  @override
  String get registerButton => 'Create Account';

  @override
  String get acceptTerms => 'I accept the terms and conditions';

  @override
  String get loginLink => 'Already have an account? Sign in';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email format';

  @override
  String get emailOrUsernameInvalid => 'Enter a valid email or username';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get passwordNeedsLowercase =>
      'Password must contain at least one lowercase letter';

  @override
  String get passwordNeedsUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get passwordNeedsNumber => 'Password must contain at least one number';

  @override
  String get passwordNeedsSpecialChar =>
      'Password must contain at least one special character (!@#\$%^&*)';

  @override
  String get passwordRulesTitle => 'Your new password must include:';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordSubtitle =>
      'Enter your current password and set a new secure one.';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get passwordMustBeDifferent =>
      'The new password must be different from the current one';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordChangedSuccess => 'Password updated successfully';

  @override
  String get passwordChangeError => 'Unable to change the password';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'e.g: juancarlos, maria_garcia';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get usernameInvalid =>
      'Username must be 3-30 characters and can only contain lowercase letters, numbers, and underscores (a-z, 0-9, _)';

  @override
  String get usernameTaken => 'This username is already taken';

  @override
  String get usernameAvailable => 'Username available';

  @override
  String usernameSuggestion(String suggestions) {
    return 'Suggestions: $suggestions';
  }

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsNotMatch => 'Passwords do not match';

  @override
  String get termsRequired => 'You must accept the terms and conditions';

  @override
  String get loginSuccess => 'Welcome!';

  @override
  String get registerSuccess =>
      'Account created! Check your email to verify your account.';

  @override
  String get emailVerificationSent => 'Verification email resent';

  @override
  String get passwordResetSent => 'Password reset email sent';

  @override
  String get userNotFound => 'No account found with this email';

  @override
  String get usernameNotFound => 'No user found with that username';

  @override
  String get wrongPassword => 'Incorrect password';

  @override
  String get emailAlreadyInUse => 'An account with this email already exists';

  @override
  String get weakPassword => 'Password is too weak. Use at least 6 characters';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get userDisabled => 'This account has been disabled';

  @override
  String get tooManyRequests => 'Too many attempts. Try again later';

  @override
  String get networkError => 'Connection error. Check your internet';

  @override
  String get invalidCredentials => 'Incorrect email or password';

  @override
  String get operationNotAllowed => 'This operation is not allowed';

  @override
  String get emailNotVerified =>
      'Please verify your email before signing in. Check your inbox.';

  @override
  String get genericError => 'Sign in error. Try again';

  @override
  String get registerError => 'Account creation error. Try again';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordMessage =>
      'Enter your email to receive a reset link.';

  @override
  String get sendResetEmail => 'Send';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get resendVerificationTitle => 'Resend verification';

  @override
  String get resendVerificationMessage =>
      'Enter your email and password to resend the verification email.';

  @override
  String get resend => 'Resend';

  @override
  String get profileTooltip => 'View profile';

  @override
  String profileCurrentTimezone(String timezone) {
    return 'Current timezone: $timezone';
  }

  @override
  String get profileTimezoneOption => 'Set timezone';

  @override
  String get profileTimezoneDialogTitle => 'Select timezone';

  @override
  String profileTimezoneDialogDescription(String timezone) {
    return 'You\'re using $timezone. If it doesn\'t match your current location, times might appear off.';
  }

  @override
  String profileTimezoneDialogDeviceSuggestion(String timezone) {
    return 'Use device time ($timezone)';
  }

  @override
  String get profileTimezoneDialogDeviceHint =>
      'We recommend updating it if you\'re travelling.';

  @override
  String get profileTimezoneDialogSearchHint => 'Search city or zone';

  @override
  String get profileTimezoneDialogNoResults => 'No matching timezones found.';

  @override
  String get profileTimezoneDialogSystemTag => 'Device timezone';

  @override
  String get profileTimezoneUpdateSuccess => 'Timezone updated successfully.';

  @override
  String get profileTimezoneInvalidError =>
      'The selected timezone is not valid.';

  @override
  String get profileTimezoneUpdateError =>
      'We couldn’t update your timezone. Please try again.';

  @override
  String get timezoneBannerTitle => 'Update your timezone?';

  @override
  String timezoneBannerMessage(String deviceTimezone, String userTimezone) {
    return 'Your device is currently in $deviceTimezone, but your preference is $userTimezone. If you keep it unchanged, event times might be off.';
  }

  @override
  String timezoneBannerUpdateButton(String timezone) {
    return 'Update to $timezone';
  }

  @override
  String timezoneBannerKeepButton(String timezone) {
    return 'Keep $timezone';
  }

  @override
  String get timezoneBannerUpdateSuccess =>
      'Timezone updated. All schedules are now aligned.';

  @override
  String get timezoneBannerUpdateError =>
      'We couldn’t update your profile timezone right now. Please try again later.';

  @override
  String timezoneBannerKeepMessage(String timezone) {
    return 'We’ll keep $timezone. You can change it anytime from your profile.';
  }

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get profilePersonalDataTitle => 'Personal information';

  @override
  String get profilePersonalDataSubtitle =>
      'Update your name and profile photo.';

  @override
  String get profileEditPersonalInformation => 'Edit personal information';

  @override
  String get profileSecurityAndAccessTitle => 'Security & access';

  @override
  String get profileSecurityAndAccessSubtitle =>
      'Manage your account security.';

  @override
  String get profilePrivacyAndSecurityOption => 'Privacy & security';

  @override
  String get profileLanguageOption => 'Language';

  @override
  String get profileSignOutOption => 'Sign out';

  @override
  String get profileAdvancedActionsTitle => 'Advanced actions';

  @override
  String get profileAdvancedActionsSubtitle =>
      'Additional options available for your account.';

  @override
  String get profileDeleteAccountOption => 'Delete account';

  @override
  String get profilePrivacyDialogTitle => 'Privacy & security';

  @override
  String get profilePrivacyDialogIntro => 'Your data is protected with:';

  @override
  String get profilePrivacyDialogEncryption =>
      'End-to-end encryption in Firestore';

  @override
  String get profilePrivacyDialogEmailVerification =>
      'Mandatory email verification (except Google)';

  @override
  String get profilePrivacyDialogRateLimiting =>
      'Rate limiting to prevent abuse';

  @override
  String get profilePrivacyDialogAccessControl =>
      'Role-based access controls (organizer, co-organizer, etc.)';

  @override
  String get profilePrivacyDialogMoreInfo =>
      'For more information check GUIA_SEGURIDAD.md.';

  @override
  String get profileLanguageDialogTitle => 'Select language';

  @override
  String get profileLanguageOptionSpanish => 'Spanish';

  @override
  String get profileLanguageOptionEnglish => 'English';

  @override
  String get profileDeleteAccountDescription =>
      'This action is irreversible. Please enter your password to confirm.';

  @override
  String get profileDeleteAccountEmptyPasswordError =>
      'Enter your password to continue.';

  @override
  String get profileDeleteAccountWrongPasswordError =>
      'Incorrect password. Try again.';

  @override
  String get profileDeleteAccountTooManyAttemptsError =>
      'Too many failed attempts. Wait a few minutes and try again.';

  @override
  String get profileDeleteAccountRecentLoginError =>
      'Please sign in again and repeat the operation to confirm the deletion.';

  @override
  String get profileDeleteAccountGenericError =>
      'We couldn\'t delete your account. Please try again in a few minutes.';

  @override
  String get confirmDeleteTitle => 'Confirm deletion';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this planazoo? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteSuccess => 'Planazoo deleted successfully';

  @override
  String get deleteError => 'Error deleting planazoo';

  @override
  String get loadError => 'Error loading planazoos';

  @override
  String get generateGuests => 'Generating guest users...';

  @override
  String get guestsGenerated => 'guest users generated successfully!';

  @override
  String get userNotAuthenticated => 'Error: User not authenticated';

  @override
  String get generateMiniFrank => 'Generating Mini-Frank plan...';

  @override
  String get miniFrankGenerated => 'Mini-Frank plan generated successfully!';

  @override
  String get generateMiniFrankError => 'Error generating Mini-Frank plan';

  @override
  String get view => 'View';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change the application language';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get createPlan => 'Create Plan';

  @override
  String get createPlanGeneralSectionTitle => 'General Information';

  @override
  String get createPlanNameLabel => 'Plan name';

  @override
  String get createPlanNameHint => 'Eg: London Vacation 2025';

  @override
  String get createPlanNameRequiredError => 'Please enter a name';

  @override
  String get createPlanNameTooShortError =>
      'The name must have at least 3 characters';

  @override
  String get createPlanNameTooLongError =>
      'The name cannot exceed 100 characters';

  @override
  String get createPlanUnpIdLabel => 'UNP ID';

  @override
  String get createPlanUnpIdHint => 'Generating...';

  @override
  String get createPlanUnpGeneratedHelper => 'Generated automatically';

  @override
  String createPlanUnpIdHeader(String id) {
    return 'ID: $id';
  }

  @override
  String get createPlanUnpIdLoading => 'Generating UNP ID...';

  @override
  String get createPlanQuickIntro =>
      'You can complete the rest of the plan configuration on the next screen.';

  @override
  String get createPlanContinueButton => 'Continue';

  @override
  String get createPlanAuthError => 'You need to sign in to create a plan.';

  @override
  String get createPlanGenericError =>
      'We couldn\'t create the plan. Please try again.';

  @override
  String get createPlanDescriptionLabel => 'Description (optional)';

  @override
  String get createPlanDescriptionHint => 'Briefly describe the plan';

  @override
  String get createPlanConfigurationSectionTitle => 'Configuration';

  @override
  String get createPlanCurrencyLabel => 'Plan currency';

  @override
  String get createPlanVisibilityLabel => 'Visibility';

  @override
  String get createPlanVisibilityPrivate => 'Private - Only participants';

  @override
  String get createPlanVisibilityPublic => 'Public - Visible to everyone';

  @override
  String get createPlanVisibilityPrivateShort => 'Private';

  @override
  String get createPlanVisibilityPublicShort => 'Public';

  @override
  String get createPlanImageSectionTitle => 'Plan image (optional)';

  @override
  String get createPlanSelectImage => 'Change image';

  @override
  String get planDetailsNoDescription => 'No description provided yet.';

  @override
  String get planDetailsNoParticipants => 'No participants added yet.';

  @override
  String get planDetailsInfoTitle => 'Detailed information';

  @override
  String get planDetailsMetaTitle => 'Plan identifiers';

  @override
  String get planTimezoneLabel => 'Plan timezone';

  @override
  String get planTimezoneHelper =>
      'Used as the default reference when creating events and converting participants\' schedules.';

  @override
  String get planDetailsStateTitle => 'State management';

  @override
  String get planDetailsParticipantsTitle => 'Participants';

  @override
  String get planDetailsParticipantsManageLink => 'Manage participants';

  @override
  String get planDetailsBudgetLabel => 'Estimated budget';

  @override
  String get planDetailsBudgetInvalid =>
      'Enter a valid positive number (use a decimal point)';

  @override
  String get cancelChanges => 'Discard changes';

  @override
  String get planDetailsSaveSuccess => 'Changes saved successfully.';

  @override
  String get planDetailsUnsavedChanges => 'You have unsaved changes.';

  @override
  String get planDetailsNoAvailableParticipants =>
      'There are no users available to add.';

  @override
  String planDetailsParticipantsAdded(int count) {
    return '$count participants added.';
  }

  @override
  String get planDetailsSaveError => 'Could not save the changes.';

  @override
  String get planDeleteDialogTitle => 'Delete plan';

  @override
  String get planDeleteDialogMessage =>
      'This will permanently remove the plan, all events, and participations.\\n\\nPlease re-enter your password to confirm.';

  @override
  String get planDeleteDialogPasswordLabel => 'Password';

  @override
  String get planDeleteDialogPasswordRequired =>
      'Enter your password to confirm.';

  @override
  String get planDeleteDialogAuthError =>
      'Incorrect password or insufficient permissions to delete this plan.';

  @override
  String get planDeleteDialogConfirm => 'Delete plan';

  @override
  String planDeleteSuccess(String name) {
    return 'Plan \"$name\" deleted successfully.';
  }

  @override
  String get planDeleteError => 'Error deleting plan';

  @override
  String planRoleLabel(String role) {
    return 'Role: $role';
  }

  @override
  String get planRoleOrganizer => 'Organizer';

  @override
  String get planRoleParticipant => 'Participant';

  @override
  String get planRoleObserver => 'Observer';

  @override
  String get planRoleUnknown => 'Unknown role';

  @override
  String get planViewModeList => 'List';

  @override
  String get planViewModeCalendar => 'Calendar';

  @override
  String get dashboardFilterAll => 'All';
  @override
  String get dashboardFilterEstoyIn => "I'm in";
  @override
  String get dashboardFilterPending => 'Pending';
  @override
  String get dashboardFilterClosed => 'Closed';
  @override
  String get dashboardSelectPlan => 'Select a plan';
  @override
  String get dashboardUiShowcaseTooltip => 'UI Showcase';
  @override
  String get dashboardLogo => 'planazoo';
  @override
  String get dashboardTabPlanazoo => 'planazoo';
  @override
  String get dashboardTabCalendar => 'calendar';
  @override
  String get dashboardTabIn => 'in';
  @override
  String get dashboardTabStats => 'stats';
  @override
  String get dashboardTabPayments => 'payments';
  @override
  String get dashboardTabChat => 'chat';

  @override
  String get understood => 'Understood';

  @override
  String get dashboardFirestoreInitializing => 'Initializing Firestore...';

  @override
  String get dashboardFirestoreInitialized => '✅ Firestore Initialized';

  @override
  String get dashboardTestUsersLabel => '👥 Test Users:';

  @override
  String get dashboardTestUsersPasswordNote => 'All users use password: test123456';

  @override
  String get dashboardTestUsersEmailNote => 'All emails go to: unplanazoo@gmail.com';

  @override
  String get dashboardFirestoreSessionNote => '⚠️ Note: Your current session may have changed. If needed, sign in again.';

  @override
  String get dashboardFirestoreIndexes => '📊 Firestore Indexes:';

  @override
  String get dashboardFirestoreIndexesWarning => '⚠️ IMPORTANT: Indexes are NOT deployed automatically from the app.';

  @override
  String get dashboardFirestoreIndexesDeployHint => 'You must deploy them manually using:';

  @override
  String get dashboardFirestoreIndexesDeployCommand => 'firebase deploy --only firestore:indexes';

  @override
  String get dashboardFirestoreConsoleHint => 'Or from Firebase Console:';

  @override
  String get dashboardFirestoreConsoleSteps => '1. Go to Firebase Console\n2. Firestore Database → Indexes\n3. Verify there are 25 indexes defined\n4. Indexes will be created automatically';

  @override
  String get dashboardFirestoreDocs => '📝 See full documentation:';

  @override
  String get dashboardFirestoreDocsPaths => 'docs/configuracion/FIRESTORE_INDEXES_AUDIT.md\ndocs/configuracion/USUARIOS_PRUEBA.md';

  @override
  String dashboardFirestoreInitError(String error) => '❌ Error initializing Firestore: $error';

  @override
  String get dashboardDeleteTestUsersTitle => '🗑️ Delete Test Users';

  @override
  String get dashboardDeleteTestUsersSelect => 'Select the users you want to delete:';

  @override
  String get dashboardDeleteTestUsersWarning => '⚠️ WARNING: This will delete users from Firebase Auth and Firestore. This cannot be undone.';

  @override
  String get dashboardSelectAll => 'Select all';

  @override
  String get dashboardDeselectAll => 'Deselect all';

  @override
  String dashboardDeletingUsersCount(int count) => 'Deleting $count user(s)...';

  @override
  String get dashboardDeletionCompleted => '✅ Deletion Completed';

  @override
  String dashboardDeletedFromFirestore(int count) => 'Deleted from Firestore: $count';

  @override
  String dashboardNotFoundCount(int count) => 'Not found: $count';

  @override
  String dashboardErrorsCount(int count) => 'Errors: $count';

  @override
  String get dashboardErrorsDetail => 'Error details:';

  @override
  String get dashboardDeleteAuthNote => '⚠️ NOTE: Users must also be deleted manually from Firebase Auth Console if they exist there.';

  @override
  String dashboardDeleteUsersError(String error) => '❌ Error deleting users: $error';

  @override
  String get dashboardGeneratingFrankenstein => '🧟 Generating Frankenstein plan...';

  @override
  String get dashboardFrankensteinSuccess => '🎉 Frankenstein plan generated successfully!';

  @override
  String get dashboardFrankensteinError => '❌ Error generating Frankenstein plan';

  @override
  String get planCalendarEmpty => 'No plans scheduled in these months.';

  @override
  String get createPlanDatesSectionTitle => 'Plan dates';

  @override
  String createPlanStartDateLabel(String date) {
    return 'Start: $date';
  }

  @override
  String createPlanEndDateLabel(String date) {
    return 'End: $date';
  }

  @override
  String get createPlanDurationLabel => 'Duration';

  @override
  String createPlanDurationValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '# days',
      one: '# day',
    );
    return '$_temp0';
  }

  @override
  String get createPlanParticipantsSectionTitle => 'Participants (optional)';

  @override
  String get createPlanImageSelected => 'Image selected';

  @override
  String get createPlanImageSelectedSuccess => 'Image selected successfully';

  @override
  String get createPlanImageSelectError =>
      'There was an error selecting the image';

  @override
  String get createPlanCreating => 'Creating...';

  @override
  String get createPlanAddParticipantsButton => 'Add participants';

  @override
  String get createPlanNoParticipants => 'No participants added yet.';

  @override
  String get createPlanParticipantsBottomSheetTitle => 'Select participants';

  @override
  String get createPlanParticipantsSave => 'Save selection';

  @override
  String get edit => 'Edit';

  @override
  String get editInfo => 'Edit information';

  @override
  String get remove => 'Remove';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get accept => 'Accept';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountMessage =>
      'This action is irreversible. All your data, plans and events will be deleted.';

  @override
  String get confirmPassword => 'Confirm your password';

  @override
  String get participantsRegistered => 'Registered participants';

  @override
  String get accommodationNameRequired => 'Accommodation name is required';

  @override
  String minCharacters(int count) {
    return 'Minimum $count characters';
  }

  @override
  String maxCharacters(int count) {
    return 'Maximum $count characters';
  }

  @override
  String get accommodationType => 'Accommodation type';

  @override
  String get invalidAccommodationType => 'Invalid accommodation type';

  @override
  String get description => 'Description';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get additionalNotes => 'Additional notes';

  @override
  String get accommodationName => 'Accommodation name';

  @override
  String get accommodationNameHint => 'Hotel, apartment, etc.';

  @override
  String get costCurrency => 'Cost currency';

  @override
  String get cost => 'Cost';

  @override
  String get costOptional => 'Accommodation cost (optional)';

  @override
  String get costHint => 'Ex: 450.00';

  @override
  String get eventDescription => 'Description';

  @override
  String get eventDescriptionHint => 'Event name';

  @override
  String get eventType => 'Event type';

  @override
  String get eventSubtype => 'Subtype';

  @override
  String get selectValidTypeFirst => 'Select a valid type first';

  @override
  String get invalidSubtype => 'Invalid subtype for selected type';

  @override
  String get isDraft => 'Is draft';

  @override
  String get isDraftSubtitle => 'Drafts are shown with lower opacity';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get duration => 'Duration';

  @override
  String get timezone => 'Timezone';

  @override
  String get arrivalTimezone => 'Arrival timezone';

  @override
  String get maxParticipants => 'Max participants (optional)';

  @override
  String get maxParticipantsHint => 'Ex: 10 (leave empty for no limit)';

  @override
  String get seat => 'Seat';

  @override
  String get seatHint => 'Ex: 12A, Window';

  @override
  String get menu => 'Menu/Food';

  @override
  String get menuHint => 'Ex: Vegetarian, Gluten-free';

  @override
  String get preferences => 'Preferences';

  @override
  String get preferencesHint => 'Ex: Near exit, Quiet';

  @override
  String get reservationNumber => 'Reservation number';

  @override
  String get reservationNumberHint => 'Ex: ABC123, 456789';

  @override
  String get gate => 'Gate';

  @override
  String get gateHint => 'Ex: Gate A12, Door 3';

  @override
  String get personalNotes => 'Personal notes';

  @override
  String get createEvent => 'Create Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get creator => 'Creator';

  @override
  String get initializingPermissions => 'Initializing permissions...';

  @override
  String get eventNotSaved => 'Event not saved. Plan was not expanded.';

  @override
  String planCreatedSuccess(String name) {
    return 'Plan \"$name\" created successfully';
  }

  @override
  String planDeletedSuccess(String name) {
    return 'Plan \"$name\" deleted successfully';
  }

  @override
  String get usernameUpdated => 'Username updated';

  @override
  String get participants => 'Participants';

  @override
  String get participant => 'Participant';

  @override
  String get fullPlan => 'Full Plan';

  @override
  String get plans => 'Plans';

  @override
  String get newAccommodation => 'New Accommodation';

  @override
  String get editAccommodation => 'Edit Accommodation';

  @override
  String get checkIn => 'Check-in';

  @override
  String get checkOut => 'Check-out';

  @override
  String nights(int count) {
    return '$count night(s)';
  }

  @override
  String get color => 'Color:';

  @override
  String get participantsLabel => 'Participants:';

  @override
  String get noParticipantsSelected =>
      'No participants selected (will appear in the first track)';

  @override
  String errorLoadingParticipants(String error) {
    return 'Error loading participants: $error';
  }

  @override
  String get mustBeValidNumber => 'Must be a valid number';

  @override
  String get cannotBeNegative => 'Cannot be negative';

  @override
  String get maxAmount => 'Maximum 1,000,000';

  @override
  String get calculating => 'Calculating...';

  @override
  String convertedTo(String currency) {
    return 'Converted to $currency:';
  }

  @override
  String get conversionError => 'Could not calculate conversion';

  @override
  String get generateGuestsButton => '👥 Guests';

  @override
  String get generateMiniFrankButton => '🧬 Mini-Frank';

  @override
  String get generateFrankensteinButton => '🧟 Frankenstein';

  @override
  String get accommodationNameRequiredError => 'Accommodation name is required';

  @override
  String get checkOutAfterCheckInError =>
      'Check-out date must be after check-in date';

  @override
  String get requiresConfirmation => 'Requires participant confirmation';

  @override
  String get requiresConfirmationSubtitle =>
      'Participants will need to explicitly confirm their attendance';

  @override
  String get cardObtained => 'Card obtained';

  @override
  String get cardObtainedSubtitle => 'Mark if you already have the card/ticket';

  @override
  String get adminInsightsTooltip => 'Admin view';

  @override
  String get adminInsightsTitle => 'Plan administration overview';

  @override
  String get adminInsightsExportCsv => 'Export CSV';

  @override
  String get adminInsightsExportCopied => 'CSV copied to clipboard';

  @override
  String get adminInsightsRefresh => 'Refresh';

  @override
  String get adminInsightsEmpty => 'There are no active plans to display.';

  @override
  String get adminInsightsError => 'We couldn\'t load the data.';

  @override
  String get adminInsightsRetry => 'Retry';

  @override
  String get adminInsightsClose => 'Close';

  @override
  String get adminInsightsParticipantsSection => 'Participants';

  @override
  String get adminInsightsEventsSection => 'Events';

  @override
  String get adminInsightsAccommodationsSection => 'Accommodations';

  @override
  String get adminInsightsNoParticipants =>
      'No active participants in this plan.';

  @override
  String get adminInsightsNoEvents => 'No active events registered.';

  @override
  String get adminInsightsNoAccommodations => 'No accommodations registered.';

  @override
  String get adminInsightsColumnPlan => 'Plan';

  @override
  String get adminInsightsColumnStart => 'Start';

  @override
  String get adminInsightsColumnEnd => 'End';

  @override
  String get adminInsightsColumnParticipant => 'Participant';

  @override
  String get adminInsightsColumnRole => 'Role';

  @override
  String get adminInsightsColumnTimezone => 'Timezone';

  @override
  String get adminInsightsColumnJoined => 'Joined';

  @override
  String get adminInsightsColumnEvent => 'Event';

  @override
  String get adminInsightsColumnDate => 'Date';

  @override
  String get adminInsightsColumnTime => 'Time';

  @override
  String get adminInsightsColumnParticipantsShort => 'Participants';

  @override
  String get adminInsightsColumnAccommodation => 'Accommodation';

  @override
  String get adminInsightsColumnCheckIn => 'Check-in';

  @override
  String get adminInsightsColumnCheckOut => 'Check-out';

  @override
  String get adminInsightsEventStatusRegistered => 'Participating';

  @override
  String get adminInsightsEventStatusNotRegistered => 'Not participating';

  @override
  String get adminInsightsEventStatusCancelled => 'Cancelled';

  @override
  String get adminInsightsEventConfirmationPending => 'Pending';

  @override
  String get adminInsightsEventConfirmationAccepted => 'Accepted';

  @override
  String get adminInsightsEventConfirmationDeclined => 'Declined';

  @override
  String get adminInsightsEventConfirmationMissing => 'No response';

  @override
  String get planSummaryTitle => 'Plan summary';

  @override
  String get planSummaryCopiedToClipboard => 'Summary copied to clipboard';

  @override
  String get planSummaryCopy => 'Copy';

  @override
  String get planSummaryCopied => 'Copied';

  @override
  String get planSummaryClose => 'Close';

  @override
  String get planSummaryError => 'Could not generate the summary.';

  @override
  String get planSummaryGenerating => 'Generating summary...';

  @override
  String get planSummaryButtonTooltip => 'View summary';

  @override
  String get planSummaryButtonLabel => 'Summary';
}
