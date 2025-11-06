import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para persistir la preferencia de idioma del usuario
class LanguageStorageService {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'es';

  /// Guarda el idioma preferido del usuario
  Future<bool> saveLanguage(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      return false;
    }
  }

  /// Carga el idioma preferido guardado
  /// Retorna null si no hay idioma guardado o si hay error
  Future<Locale?> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        return Locale(languageCode);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el idioma guardado o el idioma por defecto
  Future<Locale> getLanguageOrDefault() async {
    final savedLanguage = await loadLanguage();
    return savedLanguage ?? const Locale(_defaultLanguage);
  }

  /// Elimina el idioma guardado (para testing o reset)
  Future<bool> clearLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_languageKey);
    } catch (e) {
      return false;
    }
  }
}

