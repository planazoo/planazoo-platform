import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_sync_service.dart';

void main() {
  group('Circular Dependency Tests', () {
    test('should create EventService without circular dependency', () {
      // Arrange & Act
      final eventService = EventService();
      
      // Assert
      expect(eventService, isNotNull);
      expect(eventService, isA<EventService>());
    });

    test('should create EventSyncService without circular dependency', () {
      // Arrange & Act
      final syncService = EventSyncService();
      
      // Assert
      expect(syncService, isNotNull);
      expect(syncService, isA<EventSyncService>());
    });

    test('should create both services independently', () {
      // Arrange & Act
      final eventService = EventService();
      final syncService = EventSyncService();
      
      // Assert
      expect(eventService, isNotNull);
      expect(syncService, isNotNull);
      expect(eventService, isA<EventService>());
      expect(syncService, isA<EventSyncService>());
    });
  });
}
