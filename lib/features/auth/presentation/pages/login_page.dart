import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/domain/models/auth_state.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:unp_calendario/features/language/presentation/widgets/language_selector.dart';
import 'package:unp_calendario/features/security/utils/validator.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/features/auth/presentation/pages/register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _lastShownError; // Para evitar mostrar el mismo error múltiples veces

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // Escuchar cambios de estado
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.hasError && next.errorMessage != null) {
        // Evitar mostrar el mismo error múltiples veces
        final errorMessage = next.errorMessage!;
        if (_lastShownError == errorMessage) {
          return; // Ya se mostró este error, no volver a mostrarlo
        }
        
        _lastShownError = errorMessage;
        
        // Traducir el mensaje de error
        final friendlyMessage = _getUserFriendlyErrorMessage(errorMessage);
        
        // Limpiar el error después de mostrarlo (dar tiempo para que se muestre el SnackBar)
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            ref.read(authNotifierProvider.notifier).clearError();
            _lastShownError = null; // Resetear después de limpiar
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    friendlyMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.close,
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      } else if (!next.hasError) {
        // Si no hay error, resetear el último error mostrado
        _lastShownError = null;
      }
    });

    return Scaffold(
      backgroundColor: AppColorScheme.color0,
      body: Column(
        children: [
          // Barra superior
          Container(
            width: double.infinity,
            height: 60,
            color: AppColorScheme.color2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const LanguageSelector(),
                ],
              ),
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo centrado
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColorScheme.color2,
                                          AppColorScheme.color2.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColorScheme.color2.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(context)!.loginTitle,
                                    style: AppTypography.titleStyle.copyWith(
                                      fontSize: 28,
                                      color: AppColorScheme.color4,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.loginSubtitle,
                                    style: AppTypography.bodyStyle.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                
                // Campo de email
                _buildEmailField(),
                
                const SizedBox(height: 20),
                
                // Campo de contraseña
                _buildPasswordField(),
                
                const SizedBox(height: 12),
                
                // Enlaces de ayuda
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Enlace de reenviar verificación
                    Flexible(
                      child: TextButton(
                        onPressed: _showResendVerificationDialog,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.resendVerification,
                          style: AppTypography.interactiveStyle.copyWith(
                            color: Colors.orange.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    // Enlace de restablecer contraseña
                    Flexible(
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.forgotPassword,
                          style: AppTypography.interactiveStyle.copyWith(
                            color: AppColorScheme.color2,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Botón de iniciar sesión
                _buildLoginButton(authNotifier, authState.isLoading),
                
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'o',
                        style: AppTypography.bodyStyle.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Botón de Google Sign-In
                _buildGoogleSignInButton(authNotifier, authState.isLoading),
                
                const SizedBox(height: 24),
                
                // Enlace de registro
                _buildRegisterLink(),
                
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    final isEmail = _emailController.text.contains('@');
    final isUsername = _emailController.text.isNotEmpty && 
                       !_emailController.text.contains('@') && 
                       _emailController.text.startsWith('@');
    
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      onChanged: (value) {
        // Validación en tiempo real
        if (value.isNotEmpty) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.emailOrUsernameLabel,
        hintText: AppLocalizations.of(context)!.emailOrUsernameHint,
        prefixIcon: Icon(
          isEmail ? Icons.email_outlined : Icons.alternate_email,
          color: _emailController.text.isNotEmpty
              ? AppColorScheme.color2
              : Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.color2, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.emailRequired;
        }
        // Validar que sea email válido o username válido (con o sin @)
        final trimmed = value.trim();
        final isEmailFormat = Validator.isValidEmail(trimmed);
        final isUsernameFormat = trimmed.startsWith('@') 
            ? Validator.isValidUsername(trimmed.substring(1))
            : Validator.isValidUsername(trimmed);
        
        if (!isEmailFormat && !isUsernameFormat) {
          return AppLocalizations.of(context)!.emailOrUsernameInvalid;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) {
        // Ejecutar login al presionar Enter
        final authNotifier = ref.read(authNotifierProvider.notifier);
        _handleLogin(authNotifier);
      },
      onChanged: (value) {
        // Validación en tiempo real
        if (value.isNotEmpty) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.passwordLabel,
        hintText: AppLocalizations.of(context)!.passwordHint,
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: _passwordController.text.isNotEmpty && _passwordController.text.length >= 6
              ? AppColorScheme.color2
              : Colors.grey.shade400,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.color2, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.passwordRequired;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context)!.passwordMinLength;
        }
        return null;
      },
    );
  }

  Widget _buildGoogleSignInButton(AuthNotifier authNotifier, bool isLoading) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : () => _handleGoogleSignIn(authNotifier),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        ),
        icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.black87),
        label: Text(
          AppLocalizations.of(context)!.continueWithGoogle,
          style: AppTypography.interactiveStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AuthNotifier authNotifier, bool isLoading) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorScheme.color2,
            AppColorScheme.color2.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColorScheme.color2.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleLogin(authNotifier),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.loginButton,
                      style: AppTypography.interactiveStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              '${AppLocalizations.of(context)!.noAccount} ',
              style: AppTypography.bodyStyle.copyWith(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ),
          Flexible(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.registerLink,
                style: AppTypography.interactiveStyle.copyWith(
                  color: AppColorScheme.color2,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin(AuthNotifier authNotifier) {
    if (_formKey.currentState!.validate()) {
      authNotifier.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _handleGoogleSignIn(AuthNotifier authNotifier) {
    authNotifier.signInWithGoogle();
  }

  String _getUserFriendlyErrorMessage(String errorMessage) {
    // Normalizar el mensaje para comparación (convertir a minúsculas y eliminar espacios)
    final normalizedError = errorMessage.toLowerCase().trim();
    
    // Convertir errores técnicos en mensajes amigables
    // Manejar variaciones: "username-not-found", "user-name-not-found", etc.
    if (normalizedError.contains('username-not-found') || 
        normalizedError.contains('user-name-not-found') ||
        normalizedError == 'username-not-found' ||
        normalizedError == 'user-name-not-found') {
      return AppLocalizations.of(context)!.usernameNotFound;
    } else if (normalizedError.contains('user-not-found') && !normalizedError.contains('username')) {
      return AppLocalizations.of(context)!.userNotFound;
    } else if (normalizedError.contains('google-sign-in-cancelled')) {
      return AppLocalizations.of(context)!.googleSignInCancelled;
    } else if (errorMessage.contains('google-sign-in-error') || errorMessage.contains('Error desconocido al iniciar sesión con Google')) {
      return AppLocalizations.of(context)!.googleSignInError;
    } else if (normalizedError.contains('wrong-password') || 
               normalizedError.contains('contraseña incorrecta') ||
               errorMessage.contains('Contraseña incorrecta')) {
      return AppLocalizations.of(context)!.wrongPassword;
    } else if (normalizedError.contains('invalid-credential') ||
               normalizedError.contains('credenciales inválidas') ||
               errorMessage.contains('Credenciales inválidas')) {
      // invalid-credential puede significar contraseña incorrecta (dependiendo del contexto)
      // Por ahora, asumimos que es contraseña incorrecta si viene de login
      return AppLocalizations.of(context)!.wrongPassword;
    } else if (normalizedError.contains('invalid-email')) {
      return AppLocalizations.of(context)!.invalidEmail;
    } else if (normalizedError.contains('user-disabled')) {
      return AppLocalizations.of(context)!.userDisabled;
    } else if (normalizedError.contains('too-many-requests')) {
      return AppLocalizations.of(context)!.tooManyRequests;
    } else if (normalizedError.contains('network-request-failed')) {
      return AppLocalizations.of(context)!.networkError;
    } else if (errorMessage.contains('operation-not-allowed')) {
      return AppLocalizations.of(context)!.operationNotAllowed;
    } else if (errorMessage.contains('verifica tu email')) {
      return errorMessage; // Mensaje específico de verificación de email
    } else {
      return AppLocalizations.of(context)!.genericError;
    }
  }

  void _showResendVerificationDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.email_outlined, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.resendVerificationTitle),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.resendVerificationMessage,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.text, // Permite + y otros caracteres
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'tu@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emailRequired;
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return AppLocalizations.of(context)!.emailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Tu contraseña',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.passwordRequired;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
                  child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await ref.read(authNotifierProvider.notifier)
                      .resendEmailVerification(
                        emailController.text.trim(),
                        passwordController.text,
                      );
                  
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Text('Email de verificación reenviado'),
                        ],
                      ),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } catch (e) {
                  // El error se manejará automáticamente por el listener
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
                  child: Text(AppLocalizations.of(context)!.resend),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock_reset_rounded,
              color: AppColorScheme.color2,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.forgotPasswordTitle),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.forgotPasswordMessage,
                style: AppTypography.bodyStyle.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.text, // Permite + y otros caracteres
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'tu@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColorScheme.color2, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emailRequired;
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return AppLocalizations.of(context)!.emailInvalid;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
                  child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await ref.read(authNotifierProvider.notifier)
                      .sendPasswordResetEmail(emailController.text.trim());
                  
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Text('Email de restablecimiento enviado'),
                        ],
                      ),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } catch (e) {
                  // El error se manejará automáticamente por el listener
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.color2,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
                  child: Text(AppLocalizations.of(context)!.sendResetEmail),
          ),
        ],
      ),
    );
  }
}
