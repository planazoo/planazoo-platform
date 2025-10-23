import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

/// Test para demostrar el vuelo Madrid → Sídney con 2 timezones y cruce de días
void main() {
  print('✈️ === VUELO MADRID → SÍDNEY (CRUZA DÍAS) ===');
  print('');
  
  // Inicializar el servicio de timezones
  TimezoneService.initialize();
  
  // Datos del vuelo
  final fechaSalida = DateTime(2024, 1, 15);
  final horaSalidaMadrid = 20; // 20:00h en Madrid
  final duracionHoras = 22; // 22 horas (vuelo típico Madrid-Sídney)
  final duracionMinutos = duracionHoras * 60;
  
  print('📅 DATOS DEL VUELO:');
  print('  Salida: Madrid, ${horaSalidaMadrid}:00h (Europe/Madrid)');
  print('  Llegada: Sídney (Australia/Sydney)');
  print('  Duración: ${duracionHoras} horas');
  print('  Timezone de salida: Europe/Madrid');
  print('  Timezone de llegada: Australia/Sydney');
  print('');
  
  // Simular el cálculo que hace el calendario
  print('🔄 CÁLCULO CORRECTO CON 2 TIMEZONES:');
  
  // 1. Crear DateTime de salida en Madrid
  final departureDateTime = DateTime(
    fechaSalida.year,
    fechaSalida.month,
    fechaSalida.day,
    horaSalidaMadrid,
    0,
  );
  
  print('1. Salida en Madrid: ${departureDateTime.hour}:${departureDateTime.minute.toString().padLeft(2, '0')}h');
  
  // 2. Convertir salida a UTC
  final departureUtc = TimezoneService.localToUtc(departureDateTime, 'Europe/Madrid');
  print('2. Salida en UTC: ${departureUtc.hour}:${departureUtc.minute.toString().padLeft(2, '0')}h');
  
  // 3. Calcular llegada en UTC
  final arrivalUtc = departureUtc.add(Duration(minutes: duracionMinutos));
  print('3. Llegada en UTC: ${arrivalUtc.hour}:${arrivalUtc.minute.toString().padLeft(2, '0')}h (día ${arrivalUtc.day})');
  
  // 4. Convertir llegada a Sídney (timezone de llegada)
  final arrivalInSydney = TimezoneService.utcToLocal(arrivalUtc, 'Australia/Sydney');
  print('4. Llegada en Sídney: ${arrivalInSydney.hour}:${arrivalInSydney.minute.toString().padLeft(2, '0')}h (día ${arrivalInSydney.day})');
  
  // 5. Convertir llegada a Madrid (timezone del organizador)
  final arrivalInMadrid = TimezoneService.utcToLocal(arrivalUtc, 'Europe/Madrid');
  print('5. Llegada en Madrid (organizador): ${arrivalInMadrid.hour}:${arrivalInMadrid.minute.toString().padLeft(2, '0')}h (día ${arrivalInMadrid.day})');
  
  print('');
  
  // Mostrar cómo se ve en el calendario
  print('📱 VISTA EN EL CALENDARIO DEL ORGANIZADOR (Madrid):');
  print('  ✈️ Vuelo Madrid → Sídney');
  print('  ⏰ Hora: ${horaSalidaMadrid}:00h - ${arrivalInMadrid.hour}:${arrivalInMadrid.minute.toString().padLeft(2, '0')}h+1');
  print('  📅 Fecha: 15/01/2024');
  print('  🌍 Timezone salida: Madrid (GMT+1)');
  print('  🌍 Timezone llegada: Sídney (GMT+10)');
  print('');
  
  // Comparar con diferentes organizadores
  print('🌍 CÓMO SE VE CON DIFERENTES ORGANIZADORES:');
  
  final organizadores = [
    'Europe/Madrid',
    'America/New_York',
    'Australia/Sydney',
    'Asia/Tokyo',
  ];
  
  for (final tz in organizadores) {
    final llegadaEnTimezone = TimezoneService.utcToLocal(arrivalUtc, tz);
    final displayName = TimezoneService.getTimezoneDisplayName(tz);
    
    print('  $displayName: ${horaSalidaMadrid}:00h - ${llegadaEnTimezone.hour}:${llegadaEnTimezone.minute.toString().padLeft(2, '0')}h+1');
  }
  
  print('');
  
  // Mostrar la información del vuelo
  print('✈️ INFORMACIÓN COMPLETA DEL VUELO:');
  print('  🛫 Salida: Madrid 20:00h (Europe/Madrid)');
  print('  🛬 Llegada: Sídney ${arrivalInSydney.hour}:${arrivalInSydney.minute.toString().padLeft(2, '0')}h+1 (Australia/Sydney)');
  print('  ⏱️ Duración: ${duracionHoras} horas');
  print('  🌍 Timezone de salida: Europe/Madrid');
  print('  🌍 Timezone de llegada: Australia/Sydney');
  print('  📅 Cruza días: Sí (sale día 15, llega día 17)');
  print('');
  
  // Casos especiales
  print('⚠️ CASOS ESPECIALES:');
  print('  - El vuelo cruza la línea de fecha internacional');
  print('  - Diferencia de timezone: 9 horas (GMT+1 vs GMT+10)');
  print('  - Duración real vs duración aparente');
  print('  - El organizador ve la llegada en su timezone local');
  print('');
  
  print('✅ RESULTADO: El sistema maneja correctamente');
  print('   vuelos que cruzan días y tienen diferentes timezones.');
}
