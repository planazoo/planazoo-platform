import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';

/// Claves de filtro por categoría en el resumen del plan.
///
/// Las familias coinciden con las canónicas del formulario de evento.
/// [accommodationKey] cubre alojamientos y eventos con `typeFamily` alojamiento.
class PlanSummaryCategoryFilter {
  PlanSummaryCategoryFilter._();

  static const String accommodationKey = '__accommodation__';

  static const List<String> families = [
    'Desplazamiento',
    'Restauración',
    'Actividad',
    'Acción',
    'Otro',
  ];

  static List<String> get allKeys => [...families, accommodationKey];

  /// `null` = sin filtro (mostrar todo). Conjunto vacío = no mostrar nada.
  static bool isActive(Set<String>? selected) => selected != null;

  static bool eventMatches(Event event, Set<String>? selected) {
    if (selected == null) return true;
    if (selected.isEmpty) return false;
    final fam = event.typeFamily ?? event.commonPart?.family;
    if (_isAccommodationFamily(fam) &&
        selected.contains(accommodationKey)) {
      return true;
    }
    for (final key in families) {
      if (selected.contains(key) && _familyEquals(fam, key)) return true;
    }
    // Eventos sin familia: solo si «Otro» está activo.
    if ((fam == null || fam.trim().isEmpty) && selected.contains('Otro')) {
      return true;
    }
    return false;
  }

  static bool accommodationMatches(
    Accommodation accommodation,
    Set<String>? selected,
  ) {
    if (selected == null) return true;
    return selected.contains(accommodationKey);
  }

  static bool _isAccommodationFamily(String? fam) {
    final n = (fam ?? '').toLowerCase();
    return n.contains('alojamiento') || n.contains('hotel');
  }

  static bool _familyEquals(String? raw, String canonical) {
    final a = (raw ?? '').trim().toLowerCase();
    final b = canonical.trim().toLowerCase();
    if (a.isEmpty) return false;
    if (a == b) return true;
    // Acentos / variantes suaves.
    return _fold(a) == _fold(b);
  }

  static String _fold(String s) => s
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
}
