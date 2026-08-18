import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/plan_notes/domain/services/plan_notes_service.dart';

Plan _samplePlan({
  required String userId,
  required String name,
  String unpId = 'ua-1',
}) {
  final now = DateTime(2026, 8, 16, 12);
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
    state: 'planificando',
    visibility: 'private',
    timezone: 'Europe/Madrid',
    currency: 'EUR',
    participants: 0,
    createdAt: now,
    updatedAt: now,
    savedAt: now,
  );
}

PlanService _service(FakeFirebaseFirestore firestore) {
  return PlanService(
    firestore: firestore,
    participationService: PlanParticipationService(firestore: firestore),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlanService.createPlan + getPlanById (fake Firestore)', () {
    test('PLAN-C-001: creates plan, organizer participation and notes workspace',
        () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore);
      const userId = 'user-ua';

      final planId = await service.createPlan(
        _samplePlan(userId: userId, name: 'Londres 2026'),
      );

      expect(planId, isNotNull);
      expect(planId, isNotEmpty);

      final created = await service.getPlanById(planId!);
      expect(created, isNotNull);
      expect(created!.name, 'Londres 2026');
      expect(created.userId, userId);
      expect(created.state, 'planificando');
      expect(created.visibility, 'private');
      expect(created.unpId, 'ua-1');
      expect(created.participants, 1);

      final participation = await PlanParticipationService(firestore: firestore)
          .getParticipation(planId, userId);
      expect(participation, isNotNull);
      expect(participation!.role, 'organizer');
      expect(participation.status, 'accepted');
      expect(participation.isActive, isTrue);

      final workspace = await firestore
          .collection('plans')
          .doc(planId)
          .collection(PlanNotesService.workspaceCollection)
          .doc(PlanNotesService.workspaceDocId)
          .get();
      expect(workspace.exists, isTrue);
      expect(
        (workspace.data()?['planParticipantUserIds'] as List?)?.cast<String>(),
        contains(userId),
      );
    });

    test('getPlanById returns null for unknown id', () async {
      final service = _service(FakeFirebaseFirestore());
      final missing = await service.getPlanById('does-not-exist');
      expect(missing, isNull);
    });

    test('generateUniqueUnpId increments per user', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore);
      const userId = 'user-ua';

      final firstId = await service.createPlan(
        _samplePlan(userId: userId, name: 'Plan A', unpId: 'ua-1'),
      );
      expect(firstId, isNotNull);

      final next = await service.generateUniqueUnpId(userId, username: 'ua');
      expect(next, 'ua-2');
    });
  });

  group('PlanService.updatePlan (fake Firestore)', () {
    test('P6: updates fields and keeps createdAt', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore);
      const userId = 'user-ua';

      final planId = await service.createPlan(
        _samplePlan(userId: userId, name: 'Londres 2026'),
      );
      final created = await service.getPlanById(planId!);
      expect(created, isNotNull);
      final originalCreatedAt = created!.createdAt;

      final newStart = DateTime(2026, 9, 1);
      final newEnd = DateTime(2026, 9, 10);
      final ok = await service.updatePlan(
        created.copyWith(
          name: 'París 2026',
          description: 'Viaje',
          startDate: newStart,
          endDate: newEnd,
          baseDate: newStart,
          columnCount: Plan.calendarDaysInclusive(newStart, newEnd),
          timezone: 'Europe/Paris',
          budget: 1500,
        ),
      );
      expect(ok, isTrue);

      final updated = await service.getPlanById(planId);
      expect(updated, isNotNull);
      expect(updated!.name, 'París 2026');
      expect(updated.description, 'Viaje');
      expect(updated.timezone, 'Europe/Paris');
      expect(updated.budget, 1500);
      expect(updated.startDate, DateTime(2026, 9, 1));
      expect(updated.endDate, DateTime(2026, 9, 10));
      expect(updated.state, 'planificando');
      expect(
        updated.createdAt.millisecondsSinceEpoch,
        originalCreatedAt.millisecondsSinceEpoch,
      );
      expect(
        updated.updatedAt.isAfter(originalCreatedAt) ||
            updated.updatedAt.isAtSameMomentAs(originalCreatedAt),
        isTrue,
      );
    });

    test('updatePlan without id returns false', () async {
      final service = _service(FakeFirebaseFirestore());
      final ok = await service.updatePlan(
        _samplePlan(userId: 'user-ua', name: 'Sin id'),
      );
      expect(ok, isFalse);
    });

    test('P20 PLAN-C-003: updatePlan rejects end before start', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore);
      final planId = await service.createPlan(
        _samplePlan(userId: 'user-ua', name: 'Londres 2026'),
      );
      final created = await service.getPlanById(planId!);
      final originalEnd = created!.endDate;

      final ok = await service.updatePlan(
        created.copyWith(
          startDate: DateTime(2026, 8, 20),
          endDate: DateTime(2026, 8, 10),
        ),
      );
      expect(ok, isFalse);
      expect((await service.getPlanById(planId))!.endDate, originalEnd);
    });
  });

  group('P20 PLAN-C-003 createPlan date range', () {
    test('rejects end before start', () async {
      final service = _service(FakeFirebaseFirestore());
      final plan = _samplePlan(userId: 'user-ua', name: 'Londres 2026');
      final inverted = plan.copyWith(
        startDate: DateTime(2026, 8, 20),
        endDate: DateTime(2026, 8, 10),
        baseDate: DateTime(2026, 8, 20),
      );

      expect(await service.createPlan(inverted), isNull);
    });
  });
}
