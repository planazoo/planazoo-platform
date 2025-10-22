import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

/// Archivo de testing manual para el sistema de timezones
/// 
/// Este archivo contiene funciones de prueba para verificar que el sistema
/// de timezones funciona correctamente con diferentes casos de uso.
class TimezoneManualTest {
  
  /// Ejecuta todas las pruebas manuales de timezone
  static void runAllTests() {
    print('🌍 === INICIANDO TESTS MANUALES DE TIMEZONE ===');
    
    testBasicConversions();
    testDSTHandling();
    testEdgeCases();
    testEventConversions();
    testTimezoneValidation();
    
    print('🌍 === TESTS MANUALES COMPLETADOS ===');
  }
  
  /// Prueba conversiones básicas UTC ↔️ timezone
  static void testBasicConversions() {
    print('\n📅 === TEST: Conversiones Básicas ===');
    
    // Madrid (GMT+1/+2)
    final madridTime = DateTime(2024, 1, 15, 14, 30);
    final madridUtc = TimezoneService.localToUtc(madridTime, 'Europe/Madrid');
    final madridBack = TimezoneService.utcToLocal(madridUtc, 'Europe/Madrid');
    
    print('Madrid: ${madridTime.hour}:${madridTime.minute.toString().padLeft(2, '0')} → UTC: ${madridUtc.hour}:${madridUtc.minute.toString().padLeft(2, '0')} → Madrid: ${madridBack.hour}:${madridBack.minute.toString().padLeft(2, '0')}');
    
    // Nueva York (GMT-5/-4)
    final nyTime = DateTime(2024, 1, 15, 10, 0);
    final nyUtc = TimezoneService.localToUtc(nyTime, 'America/New_York');
    final nyBack = TimezoneService.utcToLocal(nyUtc, 'America/New_York');
    
    print('Nueva York: ${nyTime.hour}:${nyTime.minute.toString().padLeft(2, '0')} → UTC: ${nyUtc.hour}:${nyUtc.minute.toString().padLeft(2, '0')} → Nueva York: ${nyBack.hour}:${nyBack.minute.toString().padLeft(2, '0')}');
    
    // Tokio (GMT+9)
    final tokyoTime = DateTime(2024, 1, 15, 20, 0);
    final tokyoUtc = TimezoneService.localToUtc(tokyoTime, 'Asia/Tokyo');
    final tokyoBack = TimezoneService.utcToLocal(tokyoUtc, 'Asia/Tokyo');
    
    print('Tokio: ${tokyoTime.hour}:${tokyoTime.minute.toString().padLeft(2, '0')} → UTC: ${tokyoUtc.hour}:${tokyoUtc.minute.toString().padLeft(2, '0')} → Tokio: ${tokyoBack.hour}:${tokyoBack.minute.toString().padLeft(2, '0')}');
  }
  
  /// Prueba el manejo de horario de verano (DST)
  static void testDSTHandling() {
    print('\n☀️ === TEST: Horario de Verano (DST) ===');
    
    // Madrid en invierno (GMT+1)
    final winterDate = DateTime(2024, 1, 15);
    final winterOffset = TimezoneService.getUtcOffsetForDate('Europe/Madrid', winterDate);
    final isDSTWinter = TimezoneService.isDaylightSavingTime('Europe/Madrid', winterDate);
    
    print('Madrid invierno (${winterDate.month}/${winterDate.day}): GMT+${winterOffset.toInt()}, DST: $isDSTWinter');
    
    // Madrid en verano (GMT+2)
    final summerDate = DateTime(2024, 7, 15);
    final summerOffset = TimezoneService.getUtcOffsetForDate('Europe/Madrid', summerDate);
    final isDSTSummer = TimezoneService.isDaylightSavingTime('Europe/Madrid', summerDate);
    
    print('Madrid verano (${summerDate.month}/${summerDate.day}): GMT+${summerOffset.toInt()}, DST: $isDSTSummer');
    
    // Nueva York en invierno (GMT-5)
    final nyWinterOffset = TimezoneService.getUtcOffsetForDate('America/New_York', winterDate);
    final nyIsDSTWinter = TimezoneService.isDaylightSavingTime('America/New_York', winterDate);
    
    print('Nueva York invierno: GMT${nyWinterOffset.toInt()}, DST: $nyIsDSTWinter');
    
    // Nueva York en verano (GMT-4)
    final nySummerOffset = TimezoneService.getUtcOffsetForDate('America/New_York', summerDate);
    final nyIsDSTSummer = TimezoneService.isDaylightSavingTime('America/New_York', summerDate);
    
    print('Nueva York verano: GMT${nySummerOffset.toInt()}, DST: $nyIsDSTSummer');
  }
  
  /// Prueba casos edge (cruzar medianoche, etc.)
  static void testEdgeCases() {
    print('\n⚠️ === TEST: Casos Edge ===');
    
    // Evento que cruza medianoche en Madrid
    final lateNight = DateTime(2024, 1, 15, 23, 30);
    final lateNightUtc = TimezoneService.localToUtc(lateNight, 'Europe/Madrid');
    
    print('Madrid 23:30 → UTC: ${lateNightUtc.hour}:${lateNightUtc.minute.toString().padLeft(2, '0')} (día ${lateNightUtc.day})');
    
    // Evento temprano en Tokio
    final earlyMorning = DateTime(2024, 1, 15, 1, 0);
    final earlyMorningUtc = TimezoneService.localToUtc(earlyMorning, 'Asia/Tokyo');
    
    print('Tokio 01:00 → UTC: ${earlyMorningUtc.hour}:${earlyMorningUtc.minute.toString().padLeft(2, '0')} (día ${earlyMorningUtc.day})');
    
    // Conversión de vuelta
    final earlyMorningBack = TimezoneService.utcToLocal(earlyMorningUtc, 'Asia/Tokyo');
    print('UTC ${earlyMorningUtc.hour}:${earlyMorningUtc.minute.toString().padLeft(2, '0')} → Tokio: ${earlyMorningBack.hour}:${earlyMorningBack.minute.toString().padLeft(2, '0')}');
  }
  
  /// Prueba conversiones de eventos
  static void testEventConversions() {
    print('\n📋 === TEST: Conversiones de Eventos ===');
    
    // Evento en Madrid
    final madridEvent = {
      'date': DateTime(2024, 1, 15),
      'hour': 14,
      'startMinute': 30,
      'description': 'Reunión en Madrid',
    };
    
    final madridEventUtc = TimezoneService.convertEventToUtc(madridEvent, 'Europe/Madrid');
    final madridEventBack = TimezoneService.convertEventFromUtc(madridEventUtc, 'Europe/Madrid');
    
    print('Evento Madrid: ${madridEvent['hour']}:${madridEvent['startMinute'].toString().padLeft(2, '0')}');
    print('→ UTC: ${madridEventUtc['hour']}:${madridEventUtc['startMinute'].toString().padLeft(2, '0')}');
    print('→ Madrid: ${madridEventBack['hour']}:${madridEventBack['startMinute'].toString().padLeft(2, '0')}');
    
    // Evento en Nueva York
    final nyEvent = {
      'date': DateTime(2024, 1, 15),
      'hour': 10,
      'startMinute': 0,
      'description': 'Conferencia en Nueva York',
    };
    
    final nyEventUtc = TimezoneService.convertEventToUtc(nyEvent, 'America/New_York');
    final nyEventBack = TimezoneService.convertEventFromUtc(nyEventUtc, 'America/New_York');
    
    print('Evento Nueva York: ${nyEvent['hour']}:${nyEvent['startMinute'].toString().padLeft(2, '0')}');
    print('→ UTC: ${nyEventUtc['hour']}:${nyEventUtc['startMinute'].toString().padLeft(2, '0')}');
    print('→ Nueva York: ${nyEventBack['hour']}:${nyEventBack['startMinute'].toString().padLeft(2, '0')}');
  }
  
  /// Prueba validación de timezones
  static void testTimezoneValidation() {
    print('\n✅ === TEST: Validación de Timezones ===');
    
    final validTimezones = [
      'Europe/Madrid',
      'America/New_York',
      'Asia/Tokyo',
      'Europe/London',
      'Australia/Sydney',
    ];
    
    final invalidTimezones = [
      'Invalid/Timezone',
      'Europe/NonExistent',
      'America/FakeCity',
    ];
    
    print('Timezones válidos:');
    for (final tz in validTimezones) {
      final isValid = TimezoneService.isValidTimezone(tz);
      final displayName = TimezoneService.getTimezoneDisplayName(tz);
      final offset = TimezoneService.getUtcOffsetFormatted(tz);
      print('  $tz: $isValid → $displayName ($offset)');
    }
    
    print('\nTimezones inválidos:');
    for (final tz in invalidTimezones) {
      final isValid = TimezoneService.isValidTimezone(tz);
      print('  $tz: $isValid');
    }
    
    print('\nTimezones comunes disponibles:');
    final commonTimezones = TimezoneService.getCommonTimezones();
    for (final tz in commonTimezones.take(5)) {
      final displayName = TimezoneService.getTimezoneDisplayName(tz);
      print('  $displayName');
    }
    
    print('\nTimezone del sistema: ${TimezoneService.getSystemTimezone()}');
  }
  
  /// Prueba específica para verificar que los eventos se muestran correctamente
  static void testEventDisplay() {
    print('\n📱 === TEST: Visualización de Eventos ===');
    
    // Simular eventos con diferentes timezones
    final events = [
      {
        'description': 'Reunión en Madrid',
        'timezone': 'Europe/Madrid',
        'localTime': DateTime(2024, 1, 15, 14, 30),
      },
      {
        'description': 'Conferencia en Nueva York',
        'timezone': 'America/New_York',
        'localTime': DateTime(2024, 1, 15, 10, 0),
      },
      {
        'description': 'Cena en Tokio',
        'timezone': 'Asia/Tokyo',
        'localTime': DateTime(2024, 1, 15, 20, 0),
      },
    ];
    
    print('Eventos con hora local del evento:');
    for (final event in events) {
      final localTime = event['localTime'] as DateTime;
      final timezone = event['timezone'] as String;
      final description = event['description'] as String;
      
      // Convertir a UTC para almacenamiento
      final utcTime = TimezoneService.localToUtc(localTime, timezone);
      
      // Convertir de vuelta a local para mostrar
      final displayTime = TimezoneService.utcToLocal(utcTime, timezone);
      
      print('  $description: ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')} ($timezone)');
      print('    → Almacenado en UTC: ${utcTime.hour}:${utcTime.minute.toString().padLeft(2, '0')}');
      print('    → Mostrado como: ${displayTime.hour}:${displayTime.minute.toString().padLeft(2, '0')}');
    }
  }
}

/// Widget de prueba para mostrar el sistema de timezones en la UI
class TimezoneTestWidget extends StatelessWidget {
  const TimezoneTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 Test de Timezones'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sistema de Timezones - Tests Manuales',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                TimezoneManualTest.runAllTests();
              },
              child: const Text('🚀 Ejecutar Todos los Tests'),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                TimezoneManualTest.testEventDisplay();
              },
              child: const Text('📱 Test Visualización de Eventos'),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Timezones Disponibles:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            ...TimezoneService.getCommonTimezones().map((tz) {
              final displayName = TimezoneService.getTimezoneDisplayName(tz);
              final offset = TimezoneService.getUtcOffsetFormatted(tz);
              
              return Card(
                child: ListTile(
                  title: Text(displayName),
                  subtitle: Text('$tz ($offset)'),
                  trailing: Icon(
                    TimezoneService.isValidTimezone(tz) ? Icons.check : Icons.error,
                    color: TimezoneService.isValidTimezone(tz) ? Colors.green : Colors.red,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
