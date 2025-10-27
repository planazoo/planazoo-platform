import 'package:flutter/foundation.dart';

/// Servicio de logging profesional para reemplazar print statements
class LoggerService {
  // Tag eliminado para mantener logs más limpios
  
  /// Log de debug (solo en modo debug)
  static void debug(String message, {String? context}) {
    if (kDebugMode) {
      final contextStr = context != null ? '[$context]' : '';
      print('DEBUG$contextStr: $message');
    }
  }
  
  /// Log de información
  static void info(String message, {String? context}) {
    final contextStr = context != null ? '[$context]' : '';
      print('INFO$contextStr: $message');
  }
  
  /// Log de advertencia
  static void warning(String message, {String? context}) {
    final contextStr = context != null ? '[$context]' : '';
      print('WARNING$contextStr: $message');
  }
  
  /// Log de error
  static void error(String message, {String? context, Object? error, StackTrace? stackTrace}) {
    final contextStr = context != null ? '[$context]' : '';
      print('ERROR$contextStr: $message');
    
    if (error != null) {
      print('ERROR$contextStr: Error details: $error');
    }
    
    if (stackTrace != null) {
      print('ERROR$contextStr: Stack trace: $stackTrace');
    }
  }
  
  /// Log de evento del calendario
  static void calendar(String message, {String? operation}) {
    final operationStr = operation != null ? '[$operation]' : '';
      print('CALENDAR$operationStr: $message');
  }
  
  /// Log de evento de alojamiento
  static void accommodation(String message, {String? operation}) {
    final operationStr = operation != null ? '[$operation]' : '';
      print('ACCOMMODATION$operationStr: $message');
  }
  
  /// Log de evento de usuario
  static void user(String message, {String? operation}) {
    final operationStr = operation != null ? '[$operation]' : '';
      print('USER$operationStr: $message');
  }
  
  /// Log de operación de base de datos
  static void database(String message, {String? operation}) {
    final operationStr = operation != null ? '[$operation]' : '';
      print('DATABASE$operationStr: $message');
  }
}
