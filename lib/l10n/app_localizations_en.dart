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
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Your password';

  @override
  String get loginButton => 'Sign In';

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
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

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
}
