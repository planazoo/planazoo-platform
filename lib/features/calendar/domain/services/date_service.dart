import '../models/calendar_date.dart';
import '../../../../shared/utils/constants.dart';

class DateService {
  static CalendarDate getDateForColumn(DateTime baseDate, int columnIndex) {
    // 🚀 CORRECCIÓN: Ahora las columnas empiezan desde 0
    // Columna 0 = baseDate, Columna 1 = baseDate + 1 día, etc.
    return CalendarDate.fromBaseDate(baseDate, columnIndex);
  }

  static List<CalendarDate> getDatesForColumns(DateTime baseDate, int columnCount) {
    return List.generate(
      columnCount,
      // 🚀 CORRECCIÓN: Ahora las columnas empiezan desde 0, no desde 1
      (index) => getDateForColumn(baseDate, index),
    );
  }

  static bool isValidDateRange(DateTime date) {
    return date.year >= AppConstants.minYear && date.year <= AppConstants.maxYear;
  }

  static DateTime getToday() {
    return DateTime.now();
  }

  static String getDayName(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[date.weekday - 1];
  }
} 