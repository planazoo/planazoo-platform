import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/help_text.dart';
import 'logger_service.dart';

/// T157: Servicio para obtener textos de ayuda desde Firestore (offline-first con caché).
class HelpTextService {
  HelpTextService({FirebaseFirestore? firestore, SharedPreferences? prefs})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = prefs;

  static const String _collectionName = 'help_texts';
  static const String _cachePrefix = 'help_text_';

  final FirebaseFirestore _firestore;
  final SharedPreferences? _prefs;

  SharedPreferences? _resolvedPrefs;

  Future<SharedPreferences?> _getPrefs() async {
    if (_prefs != null) return _prefs;
    if (_resolvedPrefs != null) return _resolvedPrefs;
    try {
      _resolvedPrefs = await SharedPreferences.getInstance();
    } catch (_) {
      _resolvedPrefs = null;
    }
    return _resolvedPrefs;
  }

  final Map<String, HelpText> _memoryCache = {};

  /// Obtiene el texto de ayuda para [helpId] en el idioma [locale].
  /// Si no hay red o no existe el doc, devuelve null (la UI usará texto por defecto).
  /// Los resultados se cachean en memoria y en SharedPreferences para offline.
  Future<HelpText?> getHelpText(String helpId, String locale) async {
    final cacheKey = '${helpId}_$locale';

    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    try {
      final doc = await _firestore.collection(_collectionName).doc(helpId).get();
      if (!doc.exists || doc.data() == null) {
        return _loadFromPrefs(cacheKey);
      }

      final data = doc.data()!;
      final helpText = HelpText.fromFirestore(data, locale);
      _memoryCache[cacheKey] = helpText;
      await _saveToPrefs(cacheKey, helpText);
      return helpText;
    } catch (e) {
      LoggerService.warning(
        'HelpTextService: error fetching $helpId ($locale), using cache or default',
        context: 'HelpTextService',
      );
      return _loadFromPrefs(cacheKey);
    }
  }

  static const String _prefsSeparator = '\t';

  Future<HelpText?> _loadFromPrefs(String cacheKey) async {
    final prefs = await _getPrefs();
    if (prefs == null) return null;
    final raw = prefs.getString(_cachePrefix + cacheKey);
    if (raw == null) return null;
    final parts = raw.split(_prefsSeparator);
    if (parts.isEmpty || parts[0].isEmpty) return null;
    final body = parts[0];
    final url = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null;
    final helpText = HelpText(body: body, url: url);
    _memoryCache[cacheKey] = helpText;
    return helpText;
  }

  Future<void> _saveToPrefs(String cacheKey, HelpText helpText) async {
    final prefs = await _getPrefs();
    if (prefs == null) return;
    final value = '${helpText.body}$_prefsSeparator${helpText.title ?? ''}$_prefsSeparator${helpText.url ?? ''}';
    await prefs.setString(_cachePrefix + cacheKey, value);
  }

  /// Invalida la caché en memoria (opcional; para tests o forzar recarga).
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  /// T157: Sincroniza los textos del seed a Firestore. Solo admins pueden escribir.
  /// [seed] = mapa helpId -> { es, en, url }. Devuelve número de documentos escritos.
  Future<int> syncHelpTextsToFirestore(Map<String, dynamic> seed) async {
    int count = 0;
    for (final entry in seed.entries) {
      final helpId = entry.key;
      final data = entry.value;
      if (data is! Map<String, dynamic>) continue;
      final es = data['es'] as String? ?? '';
      final en = data['en'] as String? ?? '';
      final url = data['url'] as String? ?? '';
      final contextDesc = data['context'] as String? ?? '';
      await _firestore.collection(_collectionName).doc(helpId).set({
        'es': es,
        'en': en,
        'url': url,
        'context': contextDesc,
      });
      count++;
    }
    clearMemoryCache();
    return count;
  }
}
