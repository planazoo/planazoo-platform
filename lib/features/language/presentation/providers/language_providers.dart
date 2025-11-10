import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/language_storage_service.dart';

// Servicio de persistencia
final languageStorageServiceProvider = Provider<LanguageStorageService>((ref) {
  return LanguageStorageService();
});

// Provider para el idioma actual (async para cargar desde storage)
final currentLanguageProvider = FutureProvider<Locale>((ref) async {
  final storageService = ref.read(languageStorageServiceProvider);
  return await storageService.getLanguageOrDefault();
});

// Provider para el idioma actual (síncrono, para usar en UI)
final currentLanguageSyncProvider = StateProvider<Locale>((ref) {
  // Inicializar con el valor por defecto, se actualizará cuando cargue
  return const Locale('es');
});

// Provider para cambiar el idioma
final languageNotifierProvider = Provider<LanguageNotifier>((ref) {
  return LanguageNotifier(ref);
});

class LanguageNotifier {
  final Ref _ref;
  final LanguageStorageService _storageService;
  
  LanguageNotifier(this._ref) : _storageService = _ref.read(languageStorageServiceProvider);
  
  /// Cambia el idioma y lo persiste
  Future<void> changeLanguage(Locale locale) async {
    // Guardar en storage
    await _storageService.saveLanguage(locale);
    
    // Actualizar providers
    _ref.read(currentLanguageSyncProvider.notifier).state = locale;
    _ref.invalidate(currentLanguageProvider);
  }
  
  /// Carga el idioma guardado al iniciar la app
  Future<void> loadSavedLanguage() async {
    final savedLanguage = await _storageService.getLanguageOrDefault();
    _ref.read(currentLanguageSyncProvider.notifier).state = savedLanguage;
  }
  
  Locale get currentLanguage => _ref.read(currentLanguageSyncProvider);
}
