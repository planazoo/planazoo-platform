import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/features/auth/domain/models/auth_state.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:unp_calendario/features/language/presentation/widgets/language_selector.dart';
import 'package:unp_calendario/features/security/utils/validator.dart';
import 'package:unp_calendario/features/security/widgets/password_rules_checklist.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String? _usernameError;
  List<String> _usernameSuggestions = [];
  bool _hasAttemptedSubmit = false; // Flag para controlar cuándo mostrar errores

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // Escuchar cambios de estado
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.hasError) {
        // Limpiar el error después de mostrarlo
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ref.read(authNotifierProvider.notifier).clearError();
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
                    _getUserFriendlyErrorMessage(next.errorMessage!),
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
      } else if (next.isRegistrationSuccess) {
        // Mostrar mensaje de éxito y redirigir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.registerSuccess,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
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
        
        // Redirigir a la página de login después de un breve delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Título "Planazoo" centrado
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.appTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Campo de nombre
                          _buildNameField(),
                          const SizedBox(height: 20),
                          // Campo de email
                          _buildEmailField(),
                          const SizedBox(height: 20),
                          // Campo de username
                          _buildUsernameField(),
                          const SizedBox(height: 20),
                          // Campo de contraseña
                          _buildPasswordField(),
                          PasswordRulesChecklist(
                            password: _passwordController.text,
                          ),
                          const SizedBox(height: 20),
                          // Campo de confirmar contraseña
                          _buildConfirmPasswordField(),
                          const SizedBox(height: 20),
                          // Checkbox de términos y condiciones
                          _buildTermsCheckbox(),
                          const SizedBox(height: 32),
                          // Botón de registro
                          _buildRegisterButton(authNotifier, authState.isLoading),
                          const SizedBox(height: 24),
                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade700)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade700)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Enlace de inicio de sesión
                          _buildLoginLink(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Selector de idioma en la esquina superior derecha
              Positioned(
                top: 16,
                right: 16,
                child: const LanguageSelector(),
              ),
              // Botón de retroceso en la esquina superior izquierda
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        textInputAction: TextInputAction.next,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (value) {
          // Forzar rebuild para actualizar estado del botón
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: '${AppLocalizations.of(context)!.nameLabel} *',
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          hintText: AppLocalizations.of(context)!.nameHint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(Icons.person_outlined, color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColorScheme.color2,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      validator: (value) {
        // Solo mostrar errores si se ha intentado enviar el formulario
        if (!_hasAttemptedSubmit) return null;
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.nameRequired;
        }
        if (value.length < 2) {
          return AppLocalizations.of(context)!.nameMinLength;
        }
        return null;
      },
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (value) {
          // Forzar rebuild para actualizar estado del botón
          setState(() {});
        },
        onFieldSubmitted: (value) {
          // Validar al presionar Enter o salir del campo
          _formKey.currentState?.validate();
        },
        decoration: InputDecoration(
          labelText: '${AppLocalizations.of(context)!.emailLabel} *',
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          hintText: AppLocalizations.of(context)!.emailHint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade400),
          errorMaxLines: 2,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColorScheme.color2,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          // Solo mostrar error de campo vacío si se ha intentado enviar
          if (!_hasAttemptedSubmit) return null;
          return AppLocalizations.of(context)!.emailRequired;
        }
        // Validar formato de email usando Validator
        if (!Validator.isValidEmail(value)) {
          return AppLocalizations.of(context)!.emailInvalid;
        }
        return null;
      },
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800, // Color sólido, sin gradiente
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade700.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 1),
                spreadRadius: -2,
              ),
            ],
          ),
          child: TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: '${AppLocalizations.of(context)!.usernameLabel} *',
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              hintText: AppLocalizations.of(context)!.usernameHint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              prefixIcon: Icon(Icons.alternate_email, color: Colors.grey.shade400),
              errorText: _usernameError,
              errorMaxLines: 3,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColorScheme.color2,
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            ),
          onChanged: (value) {
            // Limpiar error cuando el usuario escribe
            if (_usernameError != null) {
              setState(() {
                _usernameError = null;
                _usernameSuggestions = [];
              });
            }
            // Forzar rebuild para actualizar estado del botón
            setState(() {});
          },
          onFieldSubmitted: (value) {
            // Validar solo este campo al presionar Enter o salir
            final trimmed = value.trim();
            if (trimmed.isEmpty) {
              setState(() {
                _usernameError = AppLocalizations.of(context)!.usernameRequired;
              });
            } else if (trimmed != trimmed.toLowerCase()) {
              setState(() {
                _usernameError = AppLocalizations.of(context)!.usernameInvalid;
              });
            } else if (!Validator.isValidUsername(trimmed)) {
              setState(() {
                _usernameError = AppLocalizations.of(context)!.usernameInvalid;
              });
            } else {
              setState(() {
                _usernameError = null;
              });
            }
            // Forzar rebuild para mostrar/ocultar el error
            if (mounted) {
              setState(() {});
            }
          },
          validator: (value) {
            // Si hay un error específico de username (ocupado, etc.), mostrarlo
            if (_usernameError != null) {
              return _usernameError;
            }
            // Solo validar formato si se ha intentado enviar o si el campo tiene contenido
            if (value == null || value.isEmpty) {
              // Solo mostrar error si se ha intentado enviar
              if (!_hasAttemptedSubmit) return null;
              return AppLocalizations.of(context)!.usernameRequired;
            }
            final trimmed = value.trim();
            // Validar primero si tiene mayúsculas (antes de convertir a minúsculas)
            if (trimmed != trimmed.toLowerCase()) {
              return AppLocalizations.of(context)!.usernameInvalid;
            }
            // Luego validar el formato
            if (!Validator.isValidUsername(trimmed)) {
              return AppLocalizations.of(context)!.usernameInvalid;
            }
            return null;
          },
          ),
        ),
        // Mostrar sugerencias si hay
        if (_usernameSuggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.usernameSuggestion(_usernameSuggestions.join(', ')),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.orange.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: _usernameSuggestions.map((suggestion) {
                    return ActionChip(
                      label: Text(
                        '@$suggestion',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          _usernameController.text = suggestion;
                          _usernameError = null;
                          _usernameSuggestions = [];
                        });
                        // Forzar validación del formulario para limpiar el error visual
                        _formKey.currentState?.validate();
                      },
                      backgroundColor: Colors.orange.shade900.withOpacity(0.3),
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.orange.shade300,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.newPassword],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (value) {
          // Forzar rebuild para actualizar estado del botón
          setState(() {});
        },
        onFieldSubmitted: (value) {
          // Validar al presionar Enter o salir del campo
          _formKey.currentState?.validate();
        },
        decoration: InputDecoration(
          labelText: '${AppLocalizations.of(context)!.passwordLabel} *',
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          hintText: AppLocalizations.of(context)!.passwordHint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey.shade400),
          errorMaxLines: 2,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade400,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColorScheme.color2,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      validator: (value) {
        final validationResult = Validator.validatePassword(value);
        
        // Si el campo está vacío, solo mostrar error si se ha intentado enviar
        if (validationResult.errorCode == 'passwordRequired') {
          if (!_hasAttemptedSubmit) return null;
          return AppLocalizations.of(context)!.passwordRequired;
        }
        
        // Si hay otros errores de validación, mostrarlos siempre
        if (!validationResult.isValid && validationResult.errorCode != null) {
          final loc = AppLocalizations.of(context)!;
          switch (validationResult.errorCode) {
            case 'passwordMinLength':
              return loc.passwordMinLength;
            case 'passwordNeedsLowercase':
              return loc.passwordNeedsLowercase;
            case 'passwordNeedsUppercase':
              return loc.passwordNeedsUppercase;
            case 'passwordNeedsNumber':
              return loc.passwordNeedsNumber;
            case 'passwordNeedsSpecialChar':
              return loc.passwordNeedsSpecialChar;
            default:
              return null;
          }
        }
        
        return null;
      },
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: TextFormField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (value) {
          // Forzar rebuild para actualizar estado del botón
          setState(() {});
        },
        onFieldSubmitted: (value) {
          // Validar antes de intentar registrar
          if (_formKey.currentState?.validate() ?? false) {
            // Ejecutar registro al presionar Enter si todo es válido
            final authNotifier = ref.read(authNotifierProvider.notifier);
            _handleRegister(authNotifier);
          }
        },
        autofillHints: const [AutofillHints.newPassword],
        decoration: InputDecoration(
          labelText: '${AppLocalizations.of(context)!.confirmPasswordLabel} *',
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          hintText: AppLocalizations.of(context)!.confirmPasswordHint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey.shade400),
          errorMaxLines: 2,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade400,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColorScheme.color2,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          // Solo mostrar error de campo vacío si se ha intentado enviar
          if (!_hasAttemptedSubmit) return null;
          return AppLocalizations.of(context)!.confirmPasswordRequired;
        }
        // Validar que coincida con la contraseña siempre
        if (value != _passwordController.text) {
          return AppLocalizations.of(context)!.passwordsNotMatch;
        }
        return null;
      },
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppColorScheme.color2,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodyStyle.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  children: [
                    TextSpan(text: AppLocalizations.of(context)!.acceptTerms),
                    TextSpan(
                      text: 'Términos y Condiciones',
                      style: AppTypography.interactiveStyle.copyWith(
                        color: AppColorScheme.color2,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' y la '),
                    TextSpan(
                      text: 'Política de Privacidad',
                      style: AppTypography.interactiveStyle.copyWith(
                        color: AppColorScheme.color2,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Verificar si el formulario es válido (sin mostrar errores)
  bool _isFormValid() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    // Verificar que todos los campos estén completos
    if (name.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return false;
    }
    
    // Verificar que no haya errores de validación
    if (name.length < 2) return false;
    if (!email.contains('@')) return false;
    if (username.isEmpty || username != username.toLowerCase() || !Validator.isValidUsername(username.toLowerCase())) return false;
    if (password.length < 6) return false;
    if (password != confirmPassword) return false;
    if (_usernameError != null) return false;
    
    return true;
  }

  Widget _buildRegisterButton(AuthNotifier authNotifier, bool isLoading) {
    final isFormValid = _isFormValid();
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColorScheme.color2, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColorScheme.color2.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading || !_acceptTerms || !isFormValid ? null : () => _handleRegister(authNotifier),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
              : Text(
                AppLocalizations.of(context)!.registerButton,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800, // Color sólido, sin gradiente
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade700.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.loginLink,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  String _getUserFriendlyErrorMessage(String errorMessage) {
    // Convertir errores técnicos en mensajes amigables
    if (errorMessage.contains('email-already-in-use')) {
      return AppLocalizations.of(context)!.emailAlreadyInUse;
    } else if (errorMessage.contains('weak-password')) {
      return AppLocalizations.of(context)!.weakPassword;
    } else if (errorMessage.contains('invalid-email')) {
      return AppLocalizations.of(context)!.invalidEmail;
    } else if (errorMessage.contains('operation-not-allowed')) {
      return AppLocalizations.of(context)!.operationNotAllowed;
    } else if (errorMessage.contains('network-request-failed')) {
      return AppLocalizations.of(context)!.networkError;
    } else if (errorMessage.contains('too-many-requests')) {
      return AppLocalizations.of(context)!.tooManyRequests;
    } else if (errorMessage.contains('username-taken')) {
      return AppLocalizations.of(context)!.usernameTaken;
    } else {
      return AppLocalizations.of(context)!.registerError;
    }
  }

  // Generar sugerencias de username
  List<String> _generateUsernameSuggestions(String baseUsername) {
    final suggestions = <String>[];
    final base = baseUsername.trim().toLowerCase();
    
    // Intentar con números
    for (int i = 1; i <= 3; i++) {
      final candidate = '$base$i';
      if (Validator.isValidUsername(candidate)) {
        suggestions.add(candidate);
      }
    }
    
    // Intentar con año actual
    final year = DateTime.now().year.toString();
    final candidateYear = '${base}_$year';
    if (Validator.isValidUsername(candidateYear) && !suggestions.contains(candidateYear)) {
      suggestions.add(candidateYear);
    }
    
    return suggestions.take(3).toList();
  }

  Future<void> _handleRegister(AuthNotifier authNotifier) async {
    // Activar flag para mostrar errores en todos los campos
    setState(() {
      _hasAttemptedSubmit = true;
    });
    
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.termsRequired),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Validar username antes de registrar
    final username = _usernameController.text.trim().toLowerCase();
    
    // Validar formato
    if (!Validator.isValidUsername(username)) {
      setState(() {
        _usernameError = AppLocalizations.of(context)!.usernameInvalid;
      });
      _formKey.currentState!.validate();
      return;
    }

    // Verificar disponibilidad
    final userService = ref.read(userServiceProvider);
    final isAvailable = await userService.isUsernameAvailable(username);
    
    if (!isAvailable) {
      // Generar sugerencias
      final suggestions = _generateUsernameSuggestions(username);
      setState(() {
        _usernameError = AppLocalizations.of(context)!.usernameTaken;
        _usernameSuggestions = suggestions;
      });
      _formKey.currentState!.validate();
      return;
    }

    // Si todo está bien, proceder con el registro
    authNotifier.createUserWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
      displayName: _nameController.text.trim(),
      username: username,
    );
  }
}
