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
}
