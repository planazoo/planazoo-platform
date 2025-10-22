import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/services/timezone_service.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';

void main() {
  group('TimezoneService Tests', () {
    setUp(() {
      // Inicializar timezones para testing
      TimezoneService.initialize();
    });

    test('Inicialización de timezones', () {
      expect(TimezoneService.isValidTimezone('Europe/Madrid'), true);
      expect(TimezoneService.isValidTimezone('America/New_York'), true);
      expect(TimezoneService.isValidTimezone('Asia/Tokyo'), true);
      expect(TimezoneService.isValidTimezone('Invalid/Timezone'), false);
    });

    test('Conversión Madrid (GMT+1) a UTC', () {
      // Evento a las 14:00 en Madrid (GMT+1)
      final madridTime = DateTime(2024, 1, 15, 14, 0);
      final utcTime = TimezoneService.localToUtc(madridTime, 'Europe/Madrid');
      
      // Debería ser 13:00 UTC (14:00 - 1 hora)
      expect(utcTime.hour, 13);
      expect(utcTime.minute, 0);
    });

    test('Conversión Nueva York (GMT-5) a UTC', () {
      // Evento a las 10:00 en Nueva York (GMT-5)
      final nyTime = DateTime(2024, 1, 15, 10, 0);
      final utcTime = TimezoneService.localToUtc(nyTime, 'America/New_York');
      
      // Debería ser 15:00 UTC (10:00 + 5 horas)
      expect(utcTime.hour, 15);
      expect(utcTime.minute, 0);
    });

    test('Conversión Tokio (GMT+9) a UTC', () {
      // Evento a las 20:00 en Tokio (GMT+9)
      final tokyoTime = DateTime(2024, 1, 15, 20, 0);
      final utcTime = TimezoneService.localToUtc(tokyoTime, 'Asia/Tokyo');
      
      // Debería ser 11:00 UTC (20:00 - 9 horas)
      expect(utcTime.hour, 11);
      expect(utcTime.minute, 0);
    });

    test('Conversión UTC a Madrid (GMT+1)', () {
      // Evento a las 13:00 UTC
      final utcTime = DateTime.utc(2024, 1, 15, 13, 0);
      final madridTime = TimezoneService.utcToLocal(utcTime, 'Europe/Madrid');
      
      // Debería ser 14:00 en Madrid (13:00 + 1 hora)
      expect(madridTime.hour, 14);
      expect(madridTime.minute, 0);
    });

    test('Conversión UTC a Nueva York (GMT-5)', () {
      // Evento a las 15:00 UTC
      final utcTime = DateTime.utc(2024, 1, 15, 15, 0);
      final nyTime = TimezoneService.utcToLocal(utcTime, 'America/New_York');
      
      // Debería ser 10:00 en Nueva York (15:00 - 5 horas)
      expect(nyTime.hour, 10);
      expect(utcTime.minute, 0);
    });

    test('Conversión UTC a Tokio (GMT+9)', () {
      // Evento a las 11:00 UTC
      final utcTime = DateTime.utc(2024, 1, 15, 11, 0);
      final tokyoTime = TimezoneService.utcToLocal(utcTime, 'Asia/Tokyo');
      
      // Debería ser 20:00 en Tokio (11:00 + 9 horas)
      expect(tokyoTime.hour, 20);
      expect(tokyoTime.minute, 0);
    });

    test('Offset UTC formateado', () {
      expect(TimezoneService.getUtcOffsetFormatted('Europe/Madrid'), 'GMT+1');
      expect(TimezoneService.getUtcOffsetFormatted('America/New_York'), 'GMT-5');
      expect(TimezoneService.getUtcOffsetFormatted('Asia/Tokyo'), 'GMT+9');
    });

    test('Nombres de timezone legibles', () {
      expect(TimezoneService.getTimezoneDisplayName('Europe/Madrid'), 'Madrid (GMT+1)');
      expect(TimezoneService.getTimezoneDisplayName('America/New_York'), 'Nueva York (GMT-5)');
      expect(TimezoneService.getTimezoneDisplayName('Asia/Tokyo'), 'Tokio (GMT+9)');
    });

    test('Timezones comunes disponibles', () {
      final commonTimezones = TimezoneService.getCommonTimezones();
      expect(commonTimezones.contains('Europe/Madrid'), true);
      expect(commonTimezones.contains('America/New_York'), true);
      expect(commonTimezones.contains('Asia/Tokyo'), true);
      expect(commonTimezones.contains('Europe/London'), true);
    });

    test('Conversión de evento a UTC', () {
      final event = Event(
        planId: 'test-plan',
        userId: 'test-user',
        date: DateTime(2024, 1, 15),
        hour: 14,
        startMinute: 30,
        duration: 2,
        durationMinutes: 120,
        description: 'Test event',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        timezone: 'Europe/Madrid',
      );

      final utcEvent = TimezoneService.convertEventToUtc(event.toFirestore(), 'Europe/Madrid');
      
      // El evento debería convertirse a UTC
      expect(utcEvent['hour'], 13); // 14:30 Madrid = 13:30 UTC
      expect(utcEvent['startMinute'], 30);
    });

    test('Conversión de evento desde UTC', () {
      final utcEvent = {
        'date': DateTime.utc(2024, 1, 15, 13, 30),
        'hour': 13,
        'startMinute': 30,
        'description': 'Test event',
      };

      final localEvent = TimezoneService.convertEventFromUtc(utcEvent, 'Europe/Madrid');
      
      // El evento debería convertirse a timezone local
      expect(localEvent['hour'], 14); // 13:30 UTC = 14:30 Madrid
      expect(localEvent['startMinute'], 30);
    });

    test('Caso edge: Evento que cruza medianoche', () {
      // Evento de 23:00 a 01:00 en Madrid
      final startTime = DateTime(2024, 1, 15, 23, 0);
      final utcStart = TimezoneService.localToUtc(startTime, 'Europe/Madrid');
      
      // Debería ser 22:00 UTC
      expect(utcStart.hour, 22);
      expect(utcStart.minute, 0);
      
      // El día siguiente a las 01:00 en Madrid
      final endTime = DateTime(2024, 1, 16, 1, 0);
      final utcEnd = TimezoneService.localToUtc(endTime, 'Europe/Madrid');
      
      // Debería ser 00:00 UTC del día siguiente
      expect(utcEnd.hour, 0);
      expect(utcEnd.minute, 0);
    });

    test('Timezone por defecto del sistema', () {
      expect(TimezoneService.getSystemTimezone(), 'Europe/Madrid');
    });
  });

  group('Event Model with Timezone Tests', () {
    test('Evento con timezone se serializa correctamente', () {
      final event = Event(
        planId: 'test-plan',
        userId: 'test-user',
        date: DateTime(2024, 1, 15),
        hour: 14,
        startMinute: 30,
        duration: 2,
        durationMinutes: 120,
        description: 'Test event with timezone',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        timezone: 'Europe/Madrid',
      );

      final firestoreData = event.toFirestore();
      expect(firestoreData['timezone'], 'Europe/Madrid');
    });

    test('Evento sin timezone se serializa correctamente', () {
      final event = Event(
        planId: 'test-plan',
        userId: 'test-user',
        date: DateTime(2024, 1, 15),
        hour: 14,
        startMinute: 30,
        duration: 2,
        durationMinutes: 120,
        description: 'Test event without timezone',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        timezone: null,
      );

      final firestoreData = event.toFirestore();
      expect(firestoreData.containsKey('timezone'), false);
    });

    test('Evento se deserializa correctamente desde Firestore', () {
      final firestoreData = {
        'planId': 'test-plan',
        'userId': 'test-user',
        'date': DateTime(2024, 1, 15),
        'hour': 14,
        'startMinute': 30,
        'duration': 2,
        'durationMinutes': 120,
        'description': 'Test event from Firestore',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'timezone': 'Europe/Madrid',
        'isBaseEvent': true,
      };

      // Simular DocumentSnapshot
      final mockDoc = MockDocumentSnapshot(firestoreData);
      final event = Event.fromFirestore(mockDoc);
      
      expect(event.timezone, 'Europe/Madrid');
      expect(event.description, 'Test event from Firestore');
    });
  });
}

// Mock para DocumentSnapshot
class MockDocumentSnapshot {
  final Map<String, dynamic> data;
  final String id = 'test-doc-id';

  MockDocumentSnapshot(this.data);

  Map<String, dynamic> data() => data;
}
