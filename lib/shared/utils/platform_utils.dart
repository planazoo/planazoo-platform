import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Utilidades para detectar la plataforma y tipo de dispositivo
class PlatformUtils {
  /// Detecta si estamos en una plataforma móvil nativa (iOS o Android)
  static bool get isMobilePlatform {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Detecta si estamos en web (cualquier tipo)
  static bool get isWeb => kIsWeb;

  /// Detecta si estamos en web móvil (web accedida desde dispositivo móvil)
  /// Usa el ancho de pantalla para determinar si es móvil
  static bool isWebMobile(BuildContext context) {
    if (!kIsWeb) return false;
    final width = MediaQuery.of(context).size.width;
    // Consideramos móvil si el ancho es menor a 768px (breakpoint común)
    return width < 768;
  }

  /// Detecta si debemos mostrar la UI móvil
  /// Retorna true si:
  /// - Es plataforma móvil nativa (iOS/Android), O
  /// - Es web accedida desde dispositivo móvil
  static bool shouldShowMobileUI(BuildContext context) {
    return isMobilePlatform || isWebMobile(context);
  }

  /// Detecta si debemos mostrar la UI desktop/web
  /// Retorna true si:
  /// - Es web accedida desde desktop (ancho >= 768px)
  static bool shouldShowDesktopUI(BuildContext context) {
    return kIsWeb && !isWebMobile(context);
  }
}
