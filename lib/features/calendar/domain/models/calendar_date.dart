class CalendarDate {
  final DateTime date;
  final int columnIndex;

  const CalendarDate({
    required this.date,
    required this.columnIndex,
  });

  CalendarDate.fromBaseDate(DateTime baseDate, this.columnIndex)
      // 🚀 CORRECCIÓN: Ahora las columnas empiezan desde 0
      // Columna 0 = baseDate, Columna 1 = baseDate + 1 día, etc.
      : date = baseDate.add(Duration(days: columnIndex));

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDate &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          columnIndex == other.columnIndex;

  @override
  int get hashCode => date.hashCode ^ columnIndex.hashCode;
} 