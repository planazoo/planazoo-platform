import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/auth/domain/models/auth_state.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/auth/presentation/pages/login_page.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const AuthGuard({
    super.key,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // No mostrar errores aquí cuando estamos mostrando LoginPage (status = error o unauthenticated)
    // LoginPage maneja sus propios errores para evitar duplicación
    // AuthGuard solo muestra LoginPage, no debe mostrar errores de login

    return switch (authState.status) {
      AuthStatus.initial => _buildLoading(context),
      AuthStatus.loading => _buildLoading(context),
      AuthStatus.authenticated => child,
      AuthStatus.unauthenticated => const LoginPage(),
      AuthStatus.error => const LoginPage(), // Mostrar LoginPage en lugar de página de error
      AuthStatus.registrationSuccess => const LoginPage(), // Redirigir a login después del registro
    };
  }

  Widget _buildLoading(BuildContext context) {
    if (loadingWidget != null) {
      return loadingWidget!;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String errorMessage) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error de Autenticación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Recargar la página o intentar de nuevo
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget específico para mostrar solo cuando está autenticado
class AuthenticatedOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AuthenticatedOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (isAuthenticated) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

// Widget específico para mostrar solo cuando NO está autenticado
class UnauthenticatedOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const UnauthenticatedOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

// Hook para verificar autenticación en cualquier widget
class AuthChecker extends ConsumerWidget {
  final Widget Function(BuildContext context, bool isAuthenticated) builder;

  const AuthChecker({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    return builder(context, isAuthenticated);
  }
}
