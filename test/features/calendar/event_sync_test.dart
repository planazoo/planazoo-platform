import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_sync_service.dart';

void main() {
  group('EventSyncService Tests', () {
    late EventSyncService syncService;

    setUp(() {
      syncService = EventSyncService();
    });

    test('should detect common part changes correctly', () {
      // Arrange
      final oldEvent = Event(
        id: 'test1',
        planId: 'plan1',
        userId: 'user1',
        date: DateTime(2024, 1, 1),
        hour: 10,
        duration: 1,
        description: 'Old description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        commonPart: EventCommonPart(
          description: 'Old description',
          date: DateTime(2024, 1, 1),
          startHour: 10,
          startMinute: 0,
          durationMinutes: 60,
        ),
      );

      final newEvent = Event(
        id: 'test1',
        planId: 'plan1',
        userId: 'user1',
        date: DateTime(2024, 1, 1),
        hour: 10,
        duration: 1,
        description: 'New description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        commonPart: EventCommonPart(
          description: 'New description', // Cambio en descripción
          date: DateTime(2024, 1, 1),
          startHour: 10,
          startMinute: 0,
          durationMinutes: 60,
        ),
      );

      // Act
      final isCommonChange = syncService.isCommonPartChange(oldEvent, newEvent);
      final isPersonalChange = syncService.isPersonalPartChange(oldEvent, newEvent);

      // Assert
      expect(isCommonChange, true);
      expect(isPersonalChange, false);
    });

    test('should detect personal part changes correctly', () {
      // Arrange
      final oldEvent = Event(
        id: 'test1',
        planId: 'plan1',
        userId: 'user1',
        date: DateTime(2024, 1, 1),
        hour: 10,
        duration: 1,
        description: 'Same description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        commonPart: EventCommonPart(
          description: 'Same description',
          date: DateTime(2024, 1, 1),
          startHour: 10,
          startMinute: 0,
          durationMinutes: 60,
        ),
        personalParts: {
          'user1': EventPersonalPart(
            participantId: 'user1',
            fields: {'asiento': '12A'},
          ),
        },
      );

      final newEvent = Event(
        id: 'test1',
        planId: 'plan1',
        userId: 'user1',
        date: DateTime(2024, 1, 1),
        hour: 10,
        duration: 1,
        description: 'Same description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        commonPart: EventCommonPart(
          description: 'Same description', // Sin cambios
          date: DateTime(2024, 1, 1),
          startHour: 10,
          startMinute: 0,
          durationMinutes: 60,
        ),
        personalParts: {
          'user1': EventPersonalPart(
            participantId: 'user1',
            fields: {'asiento': '15B'}, // Cambio en asiento
          ),
        },
      );

      // Act
      final isCommonChange = syncService.isCommonPartChange(oldEvent, newEvent);
      final isPersonalChange = syncService.isPersonalPartChange(oldEvent, newEvent);

      // Assert
      expect(isCommonChange, false);
      expect(isPersonalChange, true);
    });

    test('should create event copy correctly', () {
      // Arrange
      final baseEvent = Event(
        id: 'base1',
        planId: 'plan1',
        userId: 'user1',
        date: DateTime(2024, 1, 1),
        hour: 10,
        duration: 1,
        description: 'Test event',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isBaseEvent: true,
        commonPart: EventCommonPart(
          description: 'Test event',
          date: DateTime(2024, 1, 1),
          startHour: 10,
          startMinute: 0,
          durationMinutes: 60,
          participantIds: ['user1', 'user2'],
        ),
      );

      // Act
      final eventCopy = baseEvent.createCopyForParticipant('user2');

      // Assert
      expect(eventCopy.id, null); // No tiene ID aún
      expect(eventCopy.userId, 'user2');
      expect(eventCopy.isBaseEvent, false);
      expect(eventCopy.baseEventId, 'base1');
      expect(eventCopy.commonPart?.description, 'Test event');
      expect(eventCopy.personalParts?['user2']?.participantId, 'user2');
    });

    test('should identify event types correctly', () {
      // Arrange
      final baseEvent = Event(
        id: 'base1',
        planId: 'plan1',
        userId: 'user1',
        date: DateTime(2024, 1, 1),
        hour: 10,
        duration: 1,
        description: 'Base event',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isBaseEvent: true,
      );

      final eventCopy = Event(
        id: 'copy1',
        planId: 'plan1',
        userId: 'user2',
        date: DateTime(2024, 1, 1),
        hour: 10,
        duration: 1,
        description: 'Copy event',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isBaseEvent: false,
        baseEventId: 'base1',
      );

      // Act & Assert
      expect(baseEvent.isEventOriginal, true);
      expect(baseEvent.isEventCopy, false);
      expect(baseEvent.eventBaseId, 'base1');

      expect(eventCopy.isEventOriginal, false);
      expect(eventCopy.isEventCopy, true);
      expect(eventCopy.eventBaseId, 'base1');
    });
  });
}
