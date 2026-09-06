/// Paleta de días para el mapa del plan (independiente del color por tipo de evento).
class PlanMapDayColors {
  PlanMapDayColors._();

  static const List<String> hexPalette = [
    '#E53935', // rojo
    '#1E88E5', // azul
    '#43A047', // verde
    '#FB8C00', // naranja
    '#8E24AA', // morado
    '#00897B', // teal
    '#3949AB', // índigo
    '#D81B60', // rosa
    '#6D4C41', // marrón
    '#00ACC1', // cian
    '#7CB342', // verde lima
    '#F4511E', // naranja profundo
  ];

  static String hexForDay(int dayIndex) {
    if (hexPalette.isEmpty) return '#E53935';
    final i = dayIndex % hexPalette.length;
    return hexPalette[i < 0 ? i + hexPalette.length : i];
  }
}
