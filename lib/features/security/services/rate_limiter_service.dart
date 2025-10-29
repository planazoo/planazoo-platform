import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Servicio para rate limiting (límites de uso) en el cliente
/// Persiste contadores usando SharedPreferences
class RateLimiterService {
  static const String _prefix = 'rate_limit_';

  // Límites configurados
  static const int loginMaxAttempts = 5;
  static const Duration loginWindow = Duration(minutes: 15);
  static const int loginCaptchaThreshold = 3;

  static const int passwordResetMaxAttempts = 3;
  static const Duration passwordResetWindow = Duration(hours: 1);

  static const int invitationsMaxAttempts = 50;
  static const Duration invitationsWindow = Duration(days: 1);

  static const int plansMaxAttempts = 50;
  static const Duration plansWindow = Duration(days: 1);

  static const int eventsMaxAttempts = 200;
  static const Duration eventsWindow = Duration(days: 1);

  /// Verificar si se puede realizar un intento de login
  /// Retorna (puedeIntentar, intentosRestantes, requiereCaptcha, bloqueadoHasta)
  Future<RateLimitResult> checkLoginAttempt(String email) async {
    final key = '${_prefix}login_${email.toLowerCase()}';
    return await _checkRateLimit(
      key: key,
      maxAttempts: loginMaxAttempts,
      window: loginWindow,
    );
  }

  /// Registrar un intento de login (éxito o fallo)
  Future<void> recordLoginAttempt(String email, bool success) async {
    final key = '${_prefix}login_${email.toLowerCase()}';
    await _recordAttempt(key: key, maxAttempts: loginMaxAttempts, window: loginWindow);
    
    if (success) {
      // Limpiar contador si el login fue exitoso
      await _clearAttempts(key);
    }
  }

  /// Verificar si se puede enviar email de recuperación de contraseña
  Future<RateLimitResult> checkPasswordReset(String email) async {
    final key = '${_prefix}password_reset_${email.toLowerCase()}';
    return await _checkRateLimit(
      key: key,
      maxAttempts: passwordResetMaxAttempts,
      window: passwordResetWindow,
    );
  }

  /// Registrar envío de email de recuperación de contraseña
  Future<void> recordPasswordReset(String email) async {
    final key = '${_prefix}password_reset_${email.toLowerCase()}';
    await _recordAttempt(key: key, maxAttempts: passwordResetMaxAttempts, window: passwordResetWindow);
  }

  /// Verificar si se pueden enviar más invitaciones
  Future<RateLimitResult> checkInvitation(String userId) async {
    final key = '${_prefix}invitations_$userId';
    return await _checkRateLimit(
      key: key,
      maxAttempts: invitationsMaxAttempts,
      window: invitationsWindow,
    );
  }

  /// Registrar envío de invitación
  Future<void> recordInvitation(String userId) async {
    final key = '${_prefix}invitations_$userId';
    await _recordAttempt(key: key, maxAttempts: invitationsMaxAttempts, window: invitationsWindow);
  }

  /// Verificar si se puede crear más planes
  Future<RateLimitResult> checkPlanCreation(String userId) async {
    final key = '${_prefix}plans_$userId';
    return await _checkRateLimit(
      key: key,
      maxAttempts: plansMaxAttempts,
      window: plansWindow,
    );
  }

  /// Registrar creación de plan
  Future<void> recordPlanCreation(String userId) async {
    final key = '${_prefix}plans_$userId';
    await _recordAttempt(key: key, maxAttempts: plansMaxAttempts, window: plansWindow);
  }

  /// Verificar si se puede crear más eventos en un plan
  Future<RateLimitResult> checkEventCreation(String planId) async {
    final key = '${_prefix}events_$planId';
    return await _checkRateLimit(
      key: key,
      maxAttempts: eventsMaxAttempts,
      window: eventsWindow,
    );
  }

  /// Registrar creación de evento
  Future<void> recordEventCreation(String planId) async {
    final key = '${_prefix}events_$planId';
    await _recordAttempt(key: key, maxAttempts: eventsMaxAttempts, window: eventsWindow);
  }

  /// Verificar límite de rate
  Future<RateLimitResult> _checkRateLimit({
    required String key,
    required int maxAttempts,
    required Duration window,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(key);

    if (dataStr == null) {
      // No hay intentos previos
      return RateLimitResult(
        allowed: true,
        remainingAttempts: maxAttempts,
        requiresCaptcha: false,
        blockedUntil: null,
      );
    }

    final data = jsonDecode(dataStr) as Map<String, dynamic>;
    final attempts = (data['attempts'] as List).map((e) => DateTime.parse(e as String)).toList();
    final firstAttempt = attempts.first;

    // Limpiar intentos fuera de la ventana
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    attempts.removeWhere((attempt) => attempt.isBefore(windowStart));

    if (attempts.length >= maxAttempts) {
      // Límite alcanzado
      final blockedUntil = firstAttempt.add(window);
      return RateLimitResult(
        allowed: false,
        remainingAttempts: 0,
        requiresCaptcha: false,
        blockedUntil: blockedUntil,
      );
    }

    // Verificar si requiere CAPTCHA (solo para login)
    bool requiresCaptcha = false;
    if (key.contains('login') && attempts.length >= loginCaptchaThreshold) {
      requiresCaptcha = true;
    }

    return RateLimitResult(
      allowed: true,
      remainingAttempts: maxAttempts - attempts.length,
      requiresCaptcha: requiresCaptcha,
      blockedUntil: null,
    );
  }

  /// Registrar un intento
  Future<void> _recordAttempt({
    required String key,
    required int maxAttempts,
    required Duration window,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(key);

    List<DateTime> attempts;
    if (dataStr == null) {
      attempts = [];
    } else {
      final data = jsonDecode(dataStr) as Map<String, dynamic>;
      attempts = (data['attempts'] as List).map((e) => DateTime.parse(e as String)).toList();
    }

    // Limpiar intentos fuera de la ventana
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    attempts.removeWhere((attempt) => attempt.isBefore(windowStart));

    // Añadir nuevo intento
    attempts.add(now);

    // Guardar
    final data = {
      'attempts': attempts.map((e) => e.toIso8601String()).toList(),
      'lastAttempt': now.toIso8601String(),
    };
    await prefs.setString(key, jsonEncode(data));
  }

  /// Limpiar intentos (usado cuando hay éxito)
  Future<void> _clearAttempts(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Limpiar todos los rate limits (útil para testing o admin)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

/// Resultado de verificación de rate limit
class RateLimitResult {
  final bool allowed;
  final int remainingAttempts;
  final bool requiresCaptcha;
  final DateTime? blockedUntil;

  RateLimitResult({
    required this.allowed,
    required this.remainingAttempts,
    required this.requiresCaptcha,
    this.blockedUntil,
  });

  /// Mensaje de error para mostrar al usuario
  String getErrorMessage() {
    if (!allowed && blockedUntil != null) {
      final minutes = blockedUntil!.difference(DateTime.now()).inMinutes;
      if (minutes > 60) {
        final hours = (minutes / 60).ceil();
        return 'Demasiados intentos. Intenta nuevamente en $hours hora${hours > 1 ? 's' : ''}';
      }
      return 'Demasiados intentos. Intenta nuevamente en $minutes minuto${minutes > 1 ? 's' : ''}';
    }
    if (requiresCaptcha) {
      return 'Por seguridad, completa el CAPTCHA para continuar';
    }
    return 'Límite de intentos alcanzado';
  }
}

