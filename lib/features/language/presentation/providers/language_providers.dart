import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para el idioma actual
final currentLanguageProvider = StateProvider<Locale>((ref) {
  return const Locale('es', ''); // Español por defecto
});

// Provider para cambiar el idioma
final languageNotifierProvider = Provider<LanguageNotifier>((ref) {
  return LanguageNotifier(ref);
});

class LanguageNotifier {
  final Ref _ref;
  
  LanguageNotifier(this._ref);
  
  void changeLanguage(Locale locale) {
    _ref.read(currentLanguageProvider.notifier).state = locale;
  }
  
  Locale get currentLanguage => _ref.read(currentLanguageProvider);
}
