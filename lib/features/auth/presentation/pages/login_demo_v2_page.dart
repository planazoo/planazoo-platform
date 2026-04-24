import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';

/// Demo visual de login v2.
/// No usa lógica real de auth: solo maqueta de UX/UI.
class LoginDemoV2Page extends StatefulWidget {
  const LoginDemoV2Page({super.key});

  @override
  State<LoginDemoV2Page> createState() => _LoginDemoV2PageState();
}

class _LoginDemoV2PageState extends State<LoginDemoV2Page> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFF111827),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  color: const Color(0xFF1F2937),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'planaz',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30,
                                ),
                              ),
                              TextSpan(
                                text: 'oo',
                                style: GoogleFonts.poppins(
                                  color: AppColorScheme.color2,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Demo Login v2',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _field(
                          controller: _emailController,
                          label: 'Email o usuario',
                          hint: 'tu@email.com o @usuario',
                          icon: Icons.alternate_email,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hint: 'Tu contraseña',
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          trailing: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('He olvidado mi contraseña'),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Iniciar sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColorScheme.color2,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'o',
                                style: GoogleFonts.poppins(color: Colors.white54),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata, size: 24),
                            label: const Text('Continuar con Google'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {},
                          child: const Text('No tienes cuenta? Registrate'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Esta pantalla es solo demo visual.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? trailing,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white60),
        suffixIcon: trailing,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorScheme.color2, width: 1.8),
        ),
      ),
    );
  }
}
