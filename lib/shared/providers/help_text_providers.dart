import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/help_text_service.dart';

/// T157: Provider del servicio de textos de ayuda (Firestore + caché offline).
final helpTextServiceProvider = Provider<HelpTextService>((ref) {
  return HelpTextService();
});

const String _keyShowUpdateHelpButton = 'show_update_help_button';

/// T157: Notifier para mostrar/ocultar el botón "Actualizar ayuda" en W1 (long-press en logo).
class ShowUpdateHelpButtonNotifier extends StateNotifier<bool> {
  ShowUpdateHelpButtonNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_keyShowUpdateHelpButton) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowUpdateHelpButton, state);
  }
}

/// T157: Si true, se muestra el botón "Actualizar ayuda" en la barra lateral (solo admins). Activar con long-press en el logo.
final showUpdateHelpButtonProvider =
    StateNotifierProvider<ShowUpdateHelpButtonNotifier, bool>((ref) {
  return ShowUpdateHelpButtonNotifier();
});
