import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';

Plan samplePlan({
  required String userId,
  required String name,
  String unpId = 'ua-1',
  String state = 'planificando',
  DateTime? createdAt,
}) {
  final now = createdAt ?? DateTime(2026, 8, 16, 12);
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 6));
  return Plan(
    name: name,
    unpId: unpId,
    userId: userId,
    baseDate: start,
    startDate: start,
    endDate: end,
    columnCount: Plan.calendarDaysInclusive(start, end),
    description: null,
    state: state,
    visibility: 'private',
    timezone: 'Europe/Madrid',
    currency: 'EUR',
    participants: 0,
    createdAt: now,
    updatedAt: now,
    savedAt: now,
  );
}

PlanService planServiceWithFake(FakeFirebaseFirestore firestore) {
  return PlanService(
    firestore: firestore,
    participationService: PlanParticipationService(firestore: firestore),
  );
}

EventService eventServiceWithFake(FakeFirebaseFirestore firestore) {
  return EventService(firestore: firestore);
}

Event sampleEvent({
  required String planId,
  required String userId,
  String description = 'Cena',
  DateTime? date,
  int hour = 20,
  int durationMinutes = 90,
  bool isDraft = false,
  bool isBaseEvent = false,
  String? typeFamily,
  double? cost,
  int? maxParticipants,
  String? timezone,
  String? arrivalTimezone,
  bool requiresConfirmation = false,
  List<String> participantTrackIds = const [],
  EventCommonPart? commonPart,
}) {
  final day = date ?? DateTime(2026, 8, 18);
  return Event(
    planId: planId,
    userId: userId,
    date: DateTime(day.year, day.month, day.day),
    hour: hour,
    duration: 2,
    durationMinutes: durationMinutes,
    description: description,
    createdAt: DateTime(2026, 8, 16, 12),
    updatedAt: DateTime(2026, 8, 16, 12),
    isDraft: isDraft,
    isBaseEvent: isBaseEvent,
    typeFamily: typeFamily,
    cost: cost,
    maxParticipants: maxParticipants,
    timezone: timezone,
    arrivalTimezone: arrivalTimezone,
    requiresConfirmation: requiresConfirmation,
    participantTrackIds: participantTrackIds,
    commonPart: commonPart,
  );
}
