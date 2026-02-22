import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unp_calendario/firebase_options.dart';
import 'package:unp_calendario/features/auth/domain/models/auth_state.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/auth_service.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class _FakeUserService extends UserService {
  final Map<String, UserModel> usersByEmail;
  final Map<String, UserModel> usersByUsername;

  _FakeUserService({
    required this.usersByEmail,
    required this.usersByUsername,
  });

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    return usersByEmail[email];
  }

  @override
  Future<UserModel?> getUserByUsername(String username) async {
    return usersByUsername[username.trim().toLowerCase()];
  }
}

class _FakeAuthService extends AuthService {
  final Map<String, String> outcomesByEmail;

  _FakeAuthService({required this.outcomesByEmail}) : super(firebaseAuth: fb_auth.FirebaseAuth.instance);

  @override
  Stream<fb_auth.User?> get userChanges => const Stream.empty();

  @override
  Future<fb_auth.UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final outcome = outcomesByEmail[email] ?? 'ok';
    switch (outcome) {
      case 'ok':
        return _FakeUserCredential();
      case 'wrong_password':
        throw Exception('wrong-password');
      default:
        throw Exception('unexpected-backendResult:$outcome');
    }
  }
}

class _FakeUser implements fb_auth.User {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserCredential implements fb_auth.UserCredential {
  @override
  fb_auth.AdditionalUserInfo? get additionalUserInfo => null;

  @override
  fb_auth.User? get user => _FakeUser();

  @override
  fb_auth.AuthCredential? get credential => null;
}

class _FakePlanParticipationService extends PlanParticipationService {}

void main() {
  group(
    'AuthNotifier signInWithEmailAndPassword vs LOGIN-00X logical cases',
    () {
    late List<dynamic> cases;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      try {
        await Firebase.initializeApp(options: firebaseOptions);
      } catch (e) {
        // Si ya está inicializado (duplicate-app), ignoramos.
        if (!e.toString().contains('duplicate-app')) {
          rethrow;
        }
      }
      SharedPreferences.setMockInitialValues({});
      final file = File('tests/login_cases.json');
      expect(await file.exists(), isTrue,
          reason: 'tests/login_cases.json must exist');
      final raw = await file.readAsString();
      cases = jsonDecode(raw) as List<dynamic>;
    });

    test('AuthNotifier produces expected error codes for LOGIN error cases',
        () async {
      for (final dynamic entry in cases) {
        final map = entry as Map<String, dynamic>;
        final id = map['id']?.toString() ?? 'unknown';
        final target =
            (map['target'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
        final input =
            (map['input'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
        final expected =
            (map['expected'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

        if (target['module'] != 'auth' || target['scenario'] != 'login') {
          continue;
        }

        // El caso LOGIN-008 (formato inválido) hoy se valida en la UI/validator,
        // no en AuthNotifier; lo dejamos fuera de esta prueba.
        if (id.startsWith('LOGIN-008')) {
          continue;
        }

        final identifier = input['identifier']?.toString() ?? '';
        final backendResult = input['backendResult']?.toString() ?? '';

        // Configurar fakes según backendResult.
        final usersByEmail = <String, UserModel>{};
        final usersByUsername = <String, UserModel>{};
        final outcomesByEmail = <String, String>{};

        // Usuario base para los casos donde exista.
        final testUser = UserModel(
          id: 'test-user-id',
          email: 'unplanazoo+admin@gmail.com',
          displayName: 'Test User',
          createdAt: DateTime.now(),
        );

        String resolvedEmail = testUser.email;

        final isEmail = identifier.contains('@');
        if (backendResult == 'user_not_found_email') {
          // No añadimos usuario por email -> getUserByEmail devolverá null.
          resolvedEmail = identifier;
        } else if (backendResult == 'user_not_found_username') {
          // No añadimos usuario por username -> getUserByUsername devolverá null.
          resolvedEmail = testUser.email;
          usersByEmail[resolvedEmail] = testUser;
        } else {
          // Casos donde el usuario existe (ok / wrong_password).
          if (isEmail) {
            resolvedEmail = identifier;
            usersByEmail[resolvedEmail] = testUser.copyWith(email: resolvedEmail);
          } else {
            resolvedEmail = testUser.email;
            var username = identifier.trim();
            if (username.startsWith('@')) {
              username = username.substring(1);
            }
            usersByUsername[username.toLowerCase()] = testUser;
          }
        }

        if (backendResult == 'wrong_password') {
          outcomesByEmail[resolvedEmail] = 'wrong_password';
        } else {
          outcomesByEmail[resolvedEmail] = 'ok';
        }

        final fakeAuthService = _FakeAuthService(outcomesByEmail: outcomesByEmail);
        final fakeUserService = _FakeUserService(
          usersByEmail: usersByEmail,
          usersByUsername: usersByUsername,
        );
        final fakePlanParticipationService = _FakePlanParticipationService();

        final notifier = AuthNotifier(
          authService: fakeAuthService,
          userService: fakeUserService,
          planParticipationService: fakePlanParticipationService,
        );

        await notifier.signInWithEmailAndPassword(
          identifier,
          input['password']?.toString() ?? '',
        );

        final expectedStatus = expected['status']?.toString();
        final expectedMessageKey = expected['messageKey'];

        if (expectedStatus == 'success') {
          expect(
            notifier.state.status != AuthStatus.error,
            true,
            reason: 'Case $id expected success but got error=${notifier.state.errorMessage}',
          );
        } else {
          expect(
            notifier.state.status,
            AuthStatus.error,
            reason: 'Case $id expected error status',
          );
          expect(
            notifier.state.errorMessage,
            expectedMessageKey,
            reason: 'Case $id expected errorMessage=$expectedMessageKey but got ${notifier.state.errorMessage}',
          );
        }
      }
    });
  }, skip: 'Requiere entorno Firebase real; usar login_logic_test y bin/run_tests.dart para pruebas lógicas.');
}

