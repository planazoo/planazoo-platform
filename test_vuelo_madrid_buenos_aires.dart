import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';

/// Archivo de prueba para el vuelo Madrid → Buenos Aires
/// 
/// Este archivo demuestra cómo se ve un evento con timezone específico
/// y cómo se manejan las conversiones automáticas.
class VueloMadridBuenosAiresTest {
  
  /// Crea el evento de vuelo Madrid → Buenos Aires
  static Event crearVueloMadridBuenosAires() {
    // Fecha de salida: 15 de enero de 2024
    final fechaSalida = DateTime(2024, 1, 15);
    
    // Crear evento en timezone de Madrid
    final evento = Event(
      id: 'vuelo_madrid_buenos_aires_001',
      planId: 'plan_test_timezone',
      userId: 'cristian_claraso',
      date: fechaSalida,
      hour: 20, // 20:00h en Madrid
      startMinute: 0,
      duration: 10, // 10 horas
      durationMinutes: 600, // 10 horas = 600 minutos
      description: 'Vuelo Madrid → Buenos Aires',
      color: 'blue',
      typeFamily: 'Desplazamiento',
      typeSubtype: 'Avión',
      participantTrackIds: ['cristian_claraso'],
      isDraft: false,
      timezone: 'Europe/Madrid', // Timezone de Madrid
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      commonPart: EventCommonPart(
        description: 'Vuelo Madrid → Buenos Aires',
        date: fechaSalida,
        startHour: 20,
        startMinute: 0,
        durationMinutes: 600,
        customColor: 'blue',
        family: 'Desplazamiento',
        subtype: 'Avión',
        isDraft: false,
        participantIds: ['cristian_claraso'],
      ),
      personalParts: {
        'cristian_claraso': EventPersonalPart(
          participantId: 'cristian_claraso',
          fields: {
            'asiento': '12A',
            'numeroReserva': 'IB6842',
            'gate': 'Gate A12',
            'notasPersonales': 'Vuelo nocturno, llevar almohada',
          },
        ),
      },
    );
    
    return evento;
  }
  
  /// Muestra cómo se ve el evento en diferentes timezones
  static void mostrarConversiones() {
    print('🌍 === VUELO MADRID → BUENOS AIRES ===');
    print('');
    
    final evento = crearVueloMadridBuenosAires();
    
    // 1. Evento original (Madrid)
    print('📅 EVENTO ORIGINAL (Madrid):');
    print('  Salida: ${evento.hour}:${evento.startMinute.toString().padLeft(2, '0')}h');
    print('  Duración: ${evento.durationMinutes ~/ 60}h ${evento.durationMinutes % 60}min');
    print('  Timezone: ${evento.timezone}');
    print('  Llegada estimada: ${(evento.hour + evento.durationMinutes ~/ 60) % 24}:${(evento.startMinute + evento.durationMinutes % 60) % 60}h del día siguiente');
    print('');
    
    // 2. Conversión a UTC para almacenamiento
    final utcEvent = TimezoneService.convertEventToUtc(evento.toFirestore(), evento.timezone!);
    print('💾 ALMACENADO EN FIRESTORE (UTC):');
    print('  Salida: ${utcEvent['hour']}:${utcEvent['startMinute'].toString().padLeft(2, '0')}h UTC');
    print('  Duración: ${evento.durationMinutes ~/ 60}h ${evento.durationMinutes % 60}min');
    print('');
    
    // 3. Cómo se ve en diferentes timezones
    print('🌍 CÓMO SE VE EN DIFERENTES TIMEZONES:');
    
    final timezones = [
      'Europe/Madrid',
      'America/New_York',
      'America/Argentina/Buenos_Aires',
      'Asia/Tokyo',
      'Europe/London',
    ];
    
    for (final tz in timezones) {
      final localEvent = TimezoneService.convertEventFromUtc(utcEvent, tz);
      final displayName = TimezoneService.getTimezoneDisplayName(tz);
      
      print('  $displayName:');
      print('    Salida: ${localEvent['hour']}:${localEvent['startMinute'].toString().padLeft(2, '0')}h');
      
      // Calcular llegada
      final llegadaHora = (localEvent['hour'] + evento.durationMinutes ~/ 60) % 24;
      final llegadaMinuto = (localEvent['startMinute'] + evento.durationMinutes % 60) % 60;
      print('    Llegada: ${llegadaHora.toString().padLeft(2, '0')}:${llegadaMinuto.toString().padLeft(2, '0')}h');
      print('');
    }
    
    // 4. Información adicional
    print('✈️ INFORMACIÓN DEL VUELO:');
    print('  Ruta: Madrid (MAD) → Buenos Aires (EZE)');
    print('  Duración: 10 horas');
    print('  Tipo: Vuelo nocturno');
    print('  Asiento: 12A');
    print('  Reserva: IB6842');
    print('  Gate: A12');
    print('');
    
    // 5. Casos especiales
    print('⚠️ CASOS ESPECIALES:');
    print('  - El evento cruza medianoche (20:00 → 06:00+1)');
    print('  - Diferentes horarios de verano/invierno');
    print('  - Conversiones automáticas UTC ↔️ local');
    print('  - Persistencia en Firestore en UTC');
  }
  
  /// Simula cómo se vería en el calendario del organizador
  static void simularVistaCalendario() {
    print('📱 === VISTA EN EL CALENDARIO DEL ORGANIZADOR ===');
    print('');
    
    final evento = crearVueloMadridBuenosAires();
    
    // Simular que el organizador está en Madrid
    final organizadorTimezone = 'Europe/Madrid';
    
    print('👤 ORGANIZADOR (Madrid):');
    print('  Timezone: $organizadorTimezone');
    print('  Hora local: ${evento.hour}:${evento.startMinute.toString().padLeft(2, '0')}h');
    print('');
    
    print('📅 EVENTO EN EL CALENDARIO:');
    print('  📍 Posición: Fila de Cristian, Columna 15 enero');
    print('  ⏰ Hora: 20:00h (hora local de Madrid)');
    print('  ⏱️ Duración: 10 horas (hasta 06:00h del día siguiente)');
    print('  🎨 Color: Azul (Desplazamiento)');
    print('  ✈️ Tipo: Avión');
    print('  📝 Descripción: "Vuelo Madrid → Buenos Aires"');
    print('');
    
    print('🔍 DETALLES AL HACER CLIC:');
    print('  - Descripción: Vuelo Madrid → Buenos Aires');
    print('  - Tipo: Desplazamiento > Avión');
    print('  - Fecha: 15/01/2024');
    print('  - Hora: 20:00h');
    print('  - Duración: 10h');
    print('  - Timezone: Madrid (GMT+1)');
    print('  - Asiento: 12A');
    print('  - Reserva: IB6842');
    print('  - Gate: A12');
    print('');
    
    print('🌍 CONVERSIONES AUTOMÁTICAS:');
    print('  - Al crear: Madrid 20:00h → UTC 19:00h (se guarda)');
    print('  - Al mostrar: UTC 19:00h → Madrid 20:00h (se muestra)');
    print('  - Si organizador cambia timezone: se convierte automáticamente');
  }
}

/// Widget de prueba para mostrar el vuelo en la UI
class VueloTestWidget extends StatelessWidget {
  const VueloTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✈️ Test Vuelo Madrid → Buenos Aires'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vuelo Madrid → Buenos Aires',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Datos del Vuelo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Salida', 'Madrid, 20:00h'),
                    _buildInfoRow('Llegada', 'Buenos Aires, 06:00h+1'),
                    _buildInfoRow('Duración', '10 horas'),
                    _buildInfoRow('Timezone', 'Europe/Madrid'),
                    _buildInfoRow('Asiento', '12A'),
                    _buildInfoRow('Reserva', 'IB6842'),
                    _buildInfoRow('Gate', 'A12'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌍 Conversiones de Timezone',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Madrid', '20:00h (GMT+1)'),
                    _buildInfoRow('UTC', '19:00h (se almacena)'),
                    _buildInfoRow('Nueva York', '14:00h (GMT-5)'),
                    _buildInfoRow('Buenos Aires', '16:00h (GMT-3)'),
                    _buildInfoRow('Tokio', '04:00h+1 (GMT+9)'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                VueloMadridBuenosAiresTest.mostrarConversiones();
              },
              child: const Text('🚀 Ejecutar Test de Conversiones'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () {
                VueloMadridBuenosAiresTest.simularVistaCalendario();
              },
              child: const Text('📱 Simular Vista Calendario'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
