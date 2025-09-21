import 'package:unp_calendario/features/auth/domain/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  registrationSuccess,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  // Estado inicial
  const AuthState.initial() : this(status: AuthStatus.initial);

  // Estado de carga
  const AuthState.loading() : this(status: AuthStatus.loading, isLoading: true);

  // Estado autenticado
  const AuthState.authenticated(UserModel user) 
      : this(status: AuthStatus.authenticated, user: user);

  // Estado no autenticado
  const AuthState.unauthenticated() 
      : this(status: AuthStatus.unauthenticated);

  // Estado de error
  const AuthState.error(String message) 
      : this(status: AuthStatus.error, errorMessage: message);

  // Getters de conveniencia
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;
  bool get isInitial => status == AuthStatus.initial;
  bool get isRegistrationSuccess => status == AuthStatus.registrationSuccess;

  // Copy with method
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        user.hashCode ^
        errorMessage.hashCode ^
        isLoading.hashCode;
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, errorMessage: $errorMessage, isLoading: $isLoading)';
  }
}
