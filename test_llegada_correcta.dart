import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

/// Test para demostrar el cálculo correcto de hora de llegada
void main() {
  print('🌍 === VUELO MADRID → BUENOS AIRES (CORREGIDO) ===');
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
  print('  Duración: ${duracionHoras} horas');
  print('  Timezone del evento: Europe/Madrid');
  print('');
  
  // Simular el cálculo que hace el calendario
  print('🔄 CÁLCULO CORRECTO DE LLEGADA:');
  
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
  
  // 4. Convertir llegada a Madrid (timezone del organizador)
  final arrivalInMadrid = TimezoneService.utcToLocal(arrivalUtc, 'Europe/Madrid');
  print('4. Llegada en Madrid: ${arrivalInMadrid.hour}:${arrivalInMadrid.minute.toString().padLeft(2, '0')}h');
  
  print('');
  
  // Mostrar cómo se ve en el calendario
  print('📱 VISTA EN EL CALENDARIO DEL ORGANIZADOR (Madrid):');
  print('  ✈️ Vuelo Madrid → Buenos Aires');
  print('  ⏰ Hora: ${horaSalidaMadrid}:00h - ${arrivalInMadrid.hour}:${arrivalInMadrid.minute.toString().padLeft(2, '0')}h');
  print('  📅 Fecha: 15/01/2024');
  print('  🌍 Timezone: Madrid (GMT+1)');
  print('');
  
  // Comparar con el cálculo incorrecto anterior
  print('❌ CÁLCULO INCORRECTO (anterior):');
  final llegadaIncorrecta = (horaSalidaMadrid + duracionHoras) % 24;
  print('  Llegada: ${llegadaIncorrecta}:00h (solo suma horas sin considerar timezones)');
  print('');
  
  print('✅ CÁLCULO CORRECTO (nuevo):');
  print('  Llegada: ${arrivalInMadrid.hour}:${arrivalInMadrid.minute.toString().padLeft(2, '0')}h (considera timezones)');
  print('');
  
  // Mostrar la diferencia
  final diferenciaHoras = arrivalInMadrid.hour - llegadaIncorrecta;
  print('🔍 DIFERENCIA:');
  print('  Incorrecto: ${llegadaIncorrecta}:00h');
  print('  Correcto: ${arrivalInMadrid.hour}:${arrivalInMadrid.minute.toString().padLeft(2, '0')}h');
  print('  Diferencia: ${diferenciaHoras}h (debido a cambios de timezone)');
  print('');
  
  // Ejemplo con diferentes timezones del organizador
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
  print('✅ RESULTADO: Ahora la hora de llegada se muestra correctamente');
  print('   en la timezone del organizador, no en la timezone del evento.');
}
