import 'package:unp_calendario/features/calendar/domain/models/plan.dart';

/// T272: resolución de colores de acento (carril/borde) por plan y familia de evento.
class PlanEventAccentColors {
  PlanEventAccentColors._();

  static const String defaultBaseColor = 'color2';

  static const List<String> typeFamilies = [
    'Desplazamiento',
    'Restauración',
    'Actividad',
    'Acción',
    'Otro',
  ];

  /// Misma paleta que el selector del diálogo de evento.
  static const List<String> palette = [
    'color2',
    'blue',
    'green',
    'orange',
    'purple',
    'red',
    'teal',
    'indigo',
    'pink',
  ];

  static String normalizeFamily(String? typeFamily) {
    final raw = (typeFamily ?? '').trim();
    if (raw.isEmpty) return 'Otro';
    if (raw == 'Transporte' || raw.toLowerCase() == 'transporte') {
      return 'Desplazamiento';
    }
    for (final fam in typeFamilies) {
      if (fam.toLowerCase() == raw.toLowerCase()) return fam;
    }
    return raw;
  }

  static String baseColor(Plan plan) {
    final base = plan.eventAccentBaseColor?.trim();
    if (base == null || base.isEmpty) return defaultBaseColor;
    return base;
  }

  /// Color de acento para una familia según la config del plan.
  static String resolve(Plan plan, String? typeFamily) {
    final fam = normalizeFamily(typeFamily);
    final mapped = plan.eventTypeAccentColors[fam]?.trim();
    if (mapped != null && mapped.isNotEmpty) return mapped;
    return baseColor(plan);
  }

  /// Color efectivo guardado en familia (explícito o base).
  static String effectiveFamilyColor(Plan plan, String typeFamily) {
    return resolve(plan, typeFamily);
  }

  /// Aplica cambio de color base: familias que seguían el base anterior pasan al nuevo.
  static Plan applyBaseColorChange(Plan plan, String newBase) {
    final oldBase = baseColor(plan);
    final nextMap = Map<String, String>.from(plan.eventTypeAccentColors);
    for (final fam in typeFamilies) {
      final current = nextMap[fam]?.trim();
      if (current == null || current.isEmpty || current == oldBase) {
        nextMap[fam] = newBase;
      }
    }
    return plan.copyWith(
      eventAccentBaseColor: newBase,
      eventTypeAccentColors: nextMap,
    );
  }

  /// Familias cuyos eventos hay que propagar tras cambiar el base.
  static List<String> familiesAffectedByBaseChange(Plan before, String newBase) {
    final oldBase = baseColor(before);
    final affected = <String>[];
    for (final fam in typeFamilies) {
      final previous = resolve(before, fam);
      if (previous == oldBase) {
        affected.add(fam);
      }
    }
    return affected;
  }

  static Plan applyFamilyColorChange(Plan plan, String typeFamily, String color) {
    final fam = normalizeFamily(typeFamily);
    final nextMap = Map<String, String>.from(plan.eventTypeAccentColors);
    nextMap[fam] = color;
    return plan.copyWith(eventTypeAccentColors: nextMap);
  }

  static Plan restoreDefaults(Plan plan) {
    final base = baseColor(plan);
    final nextMap = <String, String>{
      for (final fam in typeFamilies) fam: base,
    };
    return plan.copyWith(
      eventAccentBaseColor: base,
      eventTypeAccentColors: nextMap,
    );
  }
}
