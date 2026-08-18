import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
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
