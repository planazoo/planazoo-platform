import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Servicio para manejar conversiones de timezone
class TimezoneService {
  static bool _initialized = false;

  /// Inicializa la base de datos de timezones
  static void initialize() {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
  }

  /// Convierte una fecha/hora local a UTC
  /// 
  /// [localDateTime] - Fecha/hora en timezone local del evento
  /// [timezone] - IANA timezone (ej: "Europe/Madrid", "America/New_York")
  /// 
  /// Retorna: DateTime en UTC
  static DateTime localToUtc(DateTime localDateTime, String timezone) {
    initialize();
    
    final location = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.from(localDateTime, location);
    return tzDateTime.toUtc();
  }

  /// Convierte una fecha/hora UTC a timezone local
  /// 
  /// [utcDateTime] - Fecha/hora en UTC
  /// [timezone] - IANA timezone (ej: "Europe/Madrid", "America/New_York")
  /// 
  /// Retorna: DateTime en timezone local
  static DateTime utcToLocal(DateTime utcDateTime, String timezone) {
    initialize();
    
    final location = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.from(utcDateTime, location);
    return tzDateTime.toLocal();
  }

  /// Obtiene el offset UTC actual para una timezone
  /// 
  /// [timezone] - IANA timezone
  /// 
  /// Retorna: Offset en horas (ej: 1.0 para GMT+1, -5.0 para GMT-5)
  static double getUtcOffset(String timezone) {
    initialize();
    
    final location = tz.getLocation(timezone);
    final now = tz.TZDateTime.now(location);
    return now.timeZoneOffset.inHours.toDouble();
  }

  /// Obtiene el offset UTC formateado para una timezone
  /// 
  /// [timezone] - IANA timezone
  /// 
  /// Retorna: String formateado (ej: "GMT+1", "GMT-5")
  static String getUtcOffsetFormatted(String timezone) {
    final offset = getUtcOffset(timezone);
    final sign = offset >= 0 ? '+' : '';
    return 'GMT$sign${offset.toInt()}';
  }

  /// Verifica si una timezone es válida
  /// 
  /// [timezone] - IANA timezone a verificar
  /// 
  /// Retorna: true si la timezone es válida
  static bool isValidTimezone(String timezone) {
    try {
      initialize();
      tz.getLocation(timezone);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la lista de timezones más comunes
  /// 
  /// Retorna: Lista de timezones con formato "Ciudad (GMT±X)"
  static List<String> getCommonTimezones() {
    return [
      'Europe/Madrid',      // GMT+1/+2
      'Europe/London',      // GMT+0/+1
      'Europe/Paris',       // GMT+1/+2
      'Europe/Berlin',      // GMT+1/+2
      'Europe/Rome',        // GMT+1/+2
      'America/New_York',   // GMT-5/-4
      'America/Los_Angeles', // GMT-8/-7
      'America/Chicago',    // GMT-6/-5
      'America/Toronto',    // GMT-5/-4
      'Asia/Tokyo',         // GMT+9
      'Asia/Shanghai',      // GMT+8
      'Asia/Kolkata',       // GMT+5:30
      'Asia/Dubai',         // GMT+4
      'Australia/Sydney',   // GMT+10/+11
      'Pacific/Auckland',   // GMT+12/+13
    ];
  }

  /// Obtiene el nombre legible de una timezone
  /// 
  /// [timezone] - IANA timezone
  /// 
  /// Retorna: Nombre legible (ej: "Madrid (GMT+1)")
  static String getTimezoneDisplayName(String timezone) {
    final offset = getUtcOffsetFormatted(timezone);
    
    // Mapeo de nombres legibles
    final displayNames = {
      'Europe/Madrid': 'Madrid',
      'Europe/London': 'Londres',
      'Europe/Paris': 'París',
      'Europe/Berlin': 'Berlín',
      'Europe/Rome': 'Roma',
      'America/New_York': 'Nueva York',
      'America/Los_Angeles': 'Los Ángeles',
      'America/Chicago': 'Chicago',
      'America/Toronto': 'Toronto',
      'Asia/Tokyo': 'Tokio',
      'Asia/Shanghai': 'Shanghái',
      'Asia/Kolkata': 'Nueva Delhi',
      'Asia/Dubai': 'Dubái',
      'Australia/Sydney': 'Sídney',
      'Pacific/Auckland': 'Auckland',
    };

    final cityName = displayNames[timezone] ?? timezone.split('/').last;
    return '$cityName ($offset)';
  }

  /// Obtiene la timezone por defecto del sistema
  /// 
  /// Retorna: IANA timezone del sistema
  static String getSystemTimezone() {
    initialize();
    return tz.local.name;
  }

  /// Convierte un evento a UTC para almacenamiento
  /// 
  /// [event] - Evento con fecha/hora en timezone local
  /// [timezone] - Timezone del evento
  /// 
  /// Retorna: Evento con fecha/hora convertida a UTC
  static Map<String, dynamic> convertEventToUtc(Map<String, dynamic> event, String timezone) {
    final localDate = event['date'] as DateTime;
    final hour = event['hour'] as int;
    final startMinute = event['startMinute'] as int? ?? 0;
    
    // Crear DateTime local del evento
    final localDateTime = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
      hour,
      startMinute,
    );
    
    // Convertir a UTC
    final utcDateTime = localToUtc(localDateTime, timezone);
    
    // Crear copia del evento con fecha/hora UTC
    final utcEvent = Map<String, dynamic>.from(event);
    utcEvent['date'] = utcDateTime;
    utcEvent['hour'] = utcDateTime.hour;
    utcEvent['startMinute'] = utcDateTime.minute;
    
    return utcEvent;
  }

  /// Convierte un evento de UTC a timezone local para mostrar
  /// 
  /// [event] - Evento con fecha/hora en UTC
  /// [timezone] - Timezone del evento
  /// 
  /// Retorna: Evento con fecha/hora convertida a timezone local
  static Map<String, dynamic> convertEventFromUtc(Map<String, dynamic> event, String timezone) {
    final utcDate = event['date'] as DateTime;
    final hour = event['hour'] as int;
    final startMinute = event['startMinute'] as int? ?? 0;
    
    // Crear DateTime UTC del evento
    final utcDateTime = DateTime.utc(
      utcDate.year,
      utcDate.month,
      utcDate.day,
      hour,
      startMinute,
    );
    
    // Convertir a timezone local
    final localDateTime = utcToLocal(utcDateTime, timezone);
    
    // Crear copia del evento con fecha/hora local
    final localEvent = Map<String, dynamic>.from(event);
    localEvent['date'] = localDateTime;
    localEvent['hour'] = localDateTime.hour;
    localEvent['startMinute'] = localDateTime.minute;
    
    return localEvent;
  }
}
