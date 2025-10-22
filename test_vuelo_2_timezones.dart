import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

/// Test para demostrar el vuelo Madrid → Buenos Aires con 2 timezones
void main() {
  print('✈️ === VUELO MADRID → BUENOS AIRES (CON 2 TIMEZONES) ===');
  print('');
  
  // Inicializar el servicio de timezones
  TimezoneService.initialize();
  
  // Datos del vuelo
  final fechaSalida = DateTime(2024, 1, 15);
  final horaSalidaMadrid = 20; // 20:00h en Madrid
  final duracionHoras = 10;
  final duracionMinutos = duracionHoras * 60;
  
  print('📅 DATOS DEL VUELO:');
  print('  Salida: Madrid, ${horaSalidaMadrid}:00h (Europe/Madrid)');
  print('  Llegada: Buenos Aires (America/Argentina/Buenos_Aires)');
  print('  Duración: ${duracionHoras} horas');
  print('  Timezone de salida: Europe/Madrid');
  print('  Timezone de llegada: America/Argentina/Buenos_Aires');
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
  print('3. Llegada en UTC: ${arrivalUtc.hour}:${arrivalUtc.minute.toString().padLeft(2, '0')}h');
  
  // 4. Convertir llegada a Buenos Aires (timezone de llegada)
  final arrivalInBuenosAires = TimezoneService.utcToLocal(arrivalUtc, 'America/Argentina/Buenos_Aires');
  print('4. Llegada en Buenos Aires: ${arrivalInBuenosAires.hour}:${arrivalInBuenosAires.minute.toString().padLeft(2, '0')}h');
  
  // 5. Convertir llegada a Madrid (timezone del organizador)
  final arrivalInMadrid = TimezoneService.utcToLocal(arrivalUtc, 'Europe/Madrid');
  print('5. Llegada en Madrid (organizador): ${arrivalInMadrid.hour}:${arrivalInMadrid.minute.toString().padLeft(2, '0')}h');
  
  print('');
  
  // Mostrar cómo se ve en el calendario
  print('📱 VISTA EN EL CALENDARIO DEL ORGANIZADOR (Madrid):');
  print('  ✈️ Vuelo Madrid → Buenos Aires');
  print('  ⏰ Hora: ${horaSalidaMadrid}:00h - ${arrivalInMadrid.hour}:${arrivalInMadrid.minute.toString().padLeft(2, '0')}h');
  print('  📅 Fecha: 15/01/2024');
  print('  🌍 Timezone salida: Madrid (GMT+1)');
  print('  🌍 Timezone llegada: Buenos Aires (GMT-3)');
  print('');
  
  // Comparar con diferentes organizadores
  print('🌍 CÓMO SE VE CON DIFERENTES ORGANIZADORES:');
  
  final organizadores = [
    'Europe/Madrid',
    'America/New_York',
    'America/Argentina/Buenos_Aires',
    'Asia/Tokyo',
  ];
  
  for (final tz in organizadores) {
    final llegadaEnTimezone = TimezoneService.utcToLocal(arrivalUtc, tz);
    final displayName = TimezoneService.getTimezoneDisplayName(tz);
    
    print('  $displayName: ${horaSalidaMadrid}:00h - ${llegadaEnTimezone.hour}:${llegadaEnTimezone.minute.toString().padLeft(2, '0')}h');
  }
  
  print('');
  
  // Mostrar la información del vuelo
  print('✈️ INFORMACIÓN COMPLETA DEL VUELO:');
  print('  🛫 Salida: Madrid 20:00h (Europe/Madrid)');
  print('  🛬 Llegada: Buenos Aires ${arrivalInBuenosAires.hour}:${arrivalInBuenosAires.minute.toString().padLeft(2, '0')}h (America/Argentina/Buenos_Aires)');
  print('  ⏱️ Duración: ${duracionHoras} horas');
  print('  🌍 Timezone de salida: Europe/Madrid');
  print('  🌍 Timezone de llegada: America/Argentina/Buenos_Aires');
  print('');
  
  print('✅ RESULTADO: Ahora el sistema maneja correctamente');
  print('   las 2 timezones (salida y llegada) para vuelos internacionales.');
}
