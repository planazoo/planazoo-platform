/// Clave Maps JavaScript API. Reutiliza Places si no hay MAPS_API_KEY.
class PlanMapApiKey {
  PlanMapApiKey._();

  static const String _maps =
      String.fromEnvironment('MAPS_API_KEY', defaultValue: '');
  static const String _places =
      String.fromEnvironment('PLACES_API_KEY', defaultValue: '');

  static String get value => _maps.isNotEmpty ? _maps : _places;

  static bool get isConfigured => value.isNotEmpty;
}
