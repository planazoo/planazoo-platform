import 'package:flutter/foundation.dart' show kIsWeb;

/// Convierte una URI entrante (custom scheme o https) en ruta de app `/invitation/...`.
///
/// Soporta:
/// - `https://app.planoon.com/invitation/{token}[?action=…]`
/// - `planazoo://invitation/{token}[?action=…]`
/// - `planazoo:///invitation/{token}[?action=…]`
String? invitationRouteFromUri(Uri uri) {
  String? token;

  if (uri.scheme == 'planazoo') {
    if (uri.host == 'invitation' && uri.pathSegments.isNotEmpty) {
      token = uri.pathSegments.first;
    } else if (uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'invitation') {
      token = uri.pathSegments[1];
    }
  } else if (uri.scheme == 'https' || uri.scheme == 'http') {
    if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'invitation') {
      token = uri.pathSegments[1];
    }
  }

  if (token == null || token.isEmpty) return null;

  final action = uri.queryParameters['action'];
  if (action != null && action.isNotEmpty) {
    return '/invitation/$token?action=$action';
  }
  return '/invitation/$token';
}

/// En web la ruta path ya llega por el navegador; no hace falta app_links.
bool get shouldListenNativeDeepLinks => !kIsWeb;
