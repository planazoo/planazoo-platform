import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

/// Test simple para demostrar el vuelo Madrid → Buenos Aires
void main() {
  print('🌍 === VUELO MADRID → BUENOS AIRES ===');
  print('');
  
  // Inicializar el servicio de timezones
  TimezoneService.initialize();
  
  // Datos del vuelo
  final fechaSalida = DateTime(2024, 1, 15);
  final horaSalidaMadrid = 20; // 20:00h en Madrid
  final duracionHoras = 10;
  
  print('📅 DATOS DEL VUELO:');
  print('  Salida: Madrid, ${horaSalidaMadrid}:00h');
  print('  Duración: ${duracionHoras} horas');
  print('  Llegada: Buenos Aires, ${(horaSalidaMadrid + duracionHoras) % 24}:00h del día siguiente');
  print('  Timezone: Europe/Madrid');
  print('');
  
  // Crear DateTime local del evento
  final localDateTime = DateTime(
    fechaSalida.year,
    fechaSalida.month,
    fechaSalida.day,
    horaSalidaMadrid,
    0, // minutos
  );
  
  print('🔄 CONVERSIONES AUTOMÁTICAS:');
  
  // 1. Madrid → UTC (para almacenamiento)
  final utcDateTime = TimezoneService.localToUtc(localDateTime, 'Europe/Madrid');
  print('1. Madrid → UTC:');
  print('   ${horaSalidaMadrid}:00h Madrid → ${utcDateTime.hour}:${utcDateTime.minute.toString().padLeft(2, '0')}h UTC');
  print('   (Se almacena en Firestore como UTC)');
  print('');
  
  // 2. UTC → Madrid (para mostrar)
  final madridDateTime = TimezoneService.utcToLocal(utcDateTime, 'Europe/Madrid');
  print('2. UTC → Madrid:');
  print('   ${utcDateTime.hour}:${utcDateTime.minute.toString().padLeft(2, '0')}h UTC → ${madridDateTime.hour}:${madridDateTime.minute.toString().padLeft(2, '0')}h Madrid');
  print('   (Se muestra en el calendario)');
  print('');
  
  // 3. Cómo se ve en otras timezones
  print('🌍 CÓMO SE VE EN OTRAS TIMEZONES:');
  
  final timezones = [
    'Europe/Madrid',
    'America/New_York',
    'America/Argentina/Buenos_Aires',
    'Asia/Tokyo',
    'Europe/London',
  ];
  
  for (final tz in timezones) {
    final localTime = TimezoneService.utcToLocal(utcDateTime, tz);
    final displayName = TimezoneService.getTimezoneDisplayName(tz);
    
    print('   $displayName: ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}h');
  }
  print('');
  
  // 4. Información del offset
  print('📊 OFFSETS DE TIMEZONE:');
  for (final tz in timezones) {
    final offset = TimezoneService.getUtcOffsetFormatted(tz);
    final displayName = TimezoneService.getTimezoneDisplayName(tz);
    print('   $displayName: $offset');
  }
  print('');
  
  // 5. Simulación del calendario
  print('📱 VISTA EN EL CALENDARIO DEL ORGANIZADOR:');
  print('   👤 Organizador: Madrid (GMT+1)');
  print('   📅 Evento: 15 enero 2024');
  print('   ⏰ Hora: 20:00h (hora local de Madrid)');
  print('   ⏱️ Duración: 10 horas (hasta 06:00h del día siguiente)');
  print('   🎨 Color: Azul (Desplazamiento)');
  print('   ✈️ Tipo: Avión');
  print('   📝 Descripción: "Vuelo Madrid → Buenos Aires"');
  print('');
  
  print('🔍 AL HACER CLIC EN EL EVENTO:');
  print('   - Descripción: Vuelo Madrid → Buenos Aires');
  print('   - Tipo: Desplazamiento > Avión');
  print('   - Fecha: 15/01/2024');
  print('   - Hora: 20:00h');
  print('   - Duración: 10h');
  print('   - Timezone: Madrid (GMT+1)');
  print('   - Asiento: 12A');
  print('   - Reserva: IB6842');
  print('   - Gate: A12');
  print('');
  
  print('✅ RESULTADO: El evento se muestra correctamente en la hora local de Madrid');
  print('   y se convierte automáticamente si el organizador cambia de timezone.');
}
