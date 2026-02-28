import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Resultado de una predicción de autocompletado (Places API New).
class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String? fullText;

  const PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    this.fullText,
  });
}

/// Datos de un lugar tras Place Details (nombre, dirección, coordenadas).
class PlaceDetails {
  final String displayName;
  final String? formattedAddress;
  final double? lat;
  final double? lng;

  const PlaceDetails({
    required this.displayName,
    this.formattedAddress,
    this.lat,
    this.lng,
  });
}

/// Servicio para Places API (New): autocomplete y place details.
/// API key: pasar por --dart-define=PLACES_API_KEY=xxx (nunca commitear).
class PlacesApiService {
  static const _baseUrl = 'https://places.googleapis.com/v1';

  final String apiKey;

  PlacesApiService({String? apiKey})
      : apiKey = apiKey ?? const String.fromEnvironment('PLACES_API_KEY', defaultValue: '');

  bool get isConfigured => apiKey.isNotEmpty;

  /// Autocomplete para lugares. [input] es el texto que escribe el usuario.
  /// En web se usa Cloud Function (proxy) por CORS; en móvil se llama a la API directa.
  Future<List<PlacePrediction>> autocomplete({
    required String input,
    String? sessionToken,
    List<String>? includedPrimaryTypes,
    String? languageCode,
  }) async {
    final trimmed = input.trim();
    if (trimmed.length < 2) return [];

    if (kIsWeb) {
      return _autocompleteViaFunction(
        input: trimmed,
        sessionToken: sessionToken,
        includedPrimaryTypes: includedPrimaryTypes,
        languageCode: languageCode,
      );
    }

    if (apiKey.isEmpty) return [];
    final body = <String, dynamic>{
      'input': trimmed,
      if (sessionToken != null) 'sessionToken': sessionToken,
      if (includedPrimaryTypes != null && includedPrimaryTypes.isNotEmpty)
        'includedPrimaryTypes': includedPrimaryTypes,
      if (languageCode != null) 'languageCode': languageCode,
    };
    final response = await http.post(
      Uri.parse('$_baseUrl/places:autocomplete'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) return [];
    return _parseSuggestions(response.body);
  }

  Future<List<PlacePrediction>> _autocompleteViaFunction({
    required String input,
    String? sessionToken,
    List<String>? includedPrimaryTypes,
    String? languageCode,
  }) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('placesAutocomplete')
          .call(<String, dynamic>{
        'input': input,
        if (sessionToken != null) 'sessionToken': sessionToken,
        if (languageCode != null) 'languageCode': languageCode,
        if (includedPrimaryTypes != null && includedPrimaryTypes.isNotEmpty)
          'includedPrimaryTypes': includedPrimaryTypes,
      });
      final data = result.data as Map<String, dynamic>?;
      final suggestions = data?['suggestions'] as List<dynamic>? ?? [];
      return _predictionsFromList(suggestions);
    } catch (_) {
      return [];
    }
  }

  List<PlacePrediction> _parseSuggestions(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final suggestions = data['suggestions'] as List<dynamic>? ?? [];
      return _predictionsFromList(suggestions);
    } catch (_) {
      return [];
    }
  }

  List<PlacePrediction> _predictionsFromList(List<dynamic> suggestions) {
    final results = <PlacePrediction>[];
    for (final s in suggestions) {
      final map = s as Map<String, dynamic>;
      final placePred = map['placePrediction'] as Map<String, dynamic>?;
      if (placePred == null) continue;
      final placeId = placePred['placeId'] as String? ?? '';
      final text = placePred['text'] as Map<String, dynamic>?;
      final fullText = text?['text'] as String?;
      final structured = placePred['structuredFormat'] as Map<String, dynamic>?;
      String mainText = '';
      String secondaryText = '';
      if (structured != null) {
        final main = structured['mainText'] as Map<String, dynamic>?;
        final secondary = structured['secondaryText'] as Map<String, dynamic>?;
        mainText = main?['text'] as String? ?? '';
        secondaryText = secondary?['text'] as String? ?? '';
      }
      if (mainText.isEmpty && fullText != null) mainText = fullText;
      results.add(PlacePrediction(
        placeId: placeId,
        mainText: mainText,
        secondaryText: secondaryText,
        fullText: fullText,
      ));
    }
    return results;
  }

  /// Obtener detalles de un lugar por [placeId].
  /// En web se usa Cloud Function (proxy); en móvil, API directa.
  Future<PlaceDetails?> getPlaceDetails({
    required String placeId,
    String? sessionToken,
    String? languageCode,
  }) async {
    if (placeId.isEmpty) return null;

    if (kIsWeb) {
      return _detailsViaFunction(
        placeId: placeId,
        sessionToken: sessionToken,
        languageCode: languageCode,
      );
    }

    if (apiKey.isEmpty) return null;
    var uri = Uri.parse('$_baseUrl/places/$placeId').replace(
      queryParameters: {
        'fields': 'displayName,formattedAddress,location',
        if (sessionToken != null) 'sessionToken': sessionToken,
        if (languageCode != null) 'languageCode': languageCode,
      },
    );
    final response = await http.get(
      uri,
      headers: {'X-Goog-Api-Key': apiKey},
    );
    if (response.statusCode != 200) return null;
    return _parsePlaceDetails(response.body);
  }

  Future<PlaceDetails?> _detailsViaFunction({
    required String placeId,
    String? sessionToken,
    String? languageCode,
  }) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('placesDetails')
          .call(<String, dynamic>{
        'placeId': placeId,
        if (sessionToken != null) 'sessionToken': sessionToken,
        if (languageCode != null) 'languageCode': languageCode,
      });
      final data = result.data as Map<String, dynamic>?;
      if (data == null) return null;
      return _detailsFromMap(data);
    } catch (_) {
      return null;
    }
  }

  PlaceDetails? _parsePlaceDetails(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return _detailsFromMap(data);
    } catch (_) {
      return null;
    }
  }

  PlaceDetails? _detailsFromMap(Map<String, dynamic> data) {
    String displayName = '';
    final displayNameRaw = data['displayName'];
    if (displayNameRaw is Map<String, dynamic>) {
      displayName = displayNameRaw['text'] as String? ?? '';
    } else if (displayNameRaw is String) {
      displayName = displayNameRaw;
    }
    if (displayName.isEmpty && data['name'] != null) {
      final name = data['name'];
      displayName = name is String ? name : name.toString();
      if (displayName.startsWith('places/')) displayName = displayName.replaceFirst('places/', '');
    }
    final formattedAddress = data['formattedAddress'] as String?;
    double? lat;
    double? lng;
    final loc = data['location'] as Map<String, dynamic>?;
    if (loc != null) {
      lat = (loc['latitude'] as num?)?.toDouble();
      lng = (loc['longitude'] as num?)?.toDouble();
    }
    return PlaceDetails(
      displayName: displayName,
      formattedAddress: formattedAddress,
      lat: lat,
      lng: lng,
    );
  }
}
