import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';

import 'plan_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PLAN-R-001 / PLAN-R-002 / PLAN-R-004 (fake Firestore)', () {
    test('PLAN-R-001: getPlansByUserId lists only own plans', () async {
      final firestore = FakeFirebaseFirestore();
      final service = planServiceWithFake(firestore);

      await service.createPlan(
        samplePlan(userId: 'user-ua', name: 'Plan UA 1', unpId: 'ua-1'),
      );
      await service.createPlan(
        samplePlan(
          userId: 'user-ua',
          name: 'Plan UA 2',
          unpId: 'ua-2',
          createdAt: DateTime(2026, 8, 16, 13),
        ),
      );
      await service.createPlan(
        samplePlan(userId: 'user-ub', name: 'Plan UB', unpId: 'ub-1'),
      );

      final uaPlans = await service.getPlansByUserId('user-ua').first;
      expect(uaPlans.map((p) => p.name), unorderedEquals(['Plan UA 1', 'Plan UA 2']));
      expect(uaPlans.every((p) => p.userId == 'user-ua'), isTrue);

      final ubPlans = await service.getPlansByUserId('user-ub').first;
      expect(ubPlans.map((p) => p.name), ['Plan UB']);
    });

    test('PLAN-R-002: participant sees plan via getPlansForUser, not as owner',
        () async {
      final firestore = FakeFirebaseFirestore();
      final service = planServiceWithFake(firestore);
      final participation = PlanParticipationService(firestore: firestore);

      final planId = await service.createPlan(
        samplePlan(userId: 'user-ua', name: 'Plan compartido', unpId: 'ua-1'),
      );
      expect(planId, isNotNull);

      await participation.createParticipation(
        planId: planId!,
        userId: 'user-ub',
        role: 'participant',
        autoAccept: true,
      );

      final asOwner = await service.getPlansByUserId('user-ub').first;
      expect(asOwner, isEmpty);

      final visible = await service
          .getPlansForUser('user-ub')
          .timeout(const Duration(seconds: 5))
          .firstWhere((plans) => plans.any((p) => p.id == planId));
      expect(visible.map((p) => p.id), contains(planId));
      expect(visible.single.name, 'Plan compartido');
    });

    test('PLAN-R-004: list can be filtered by state', () async {
      final firestore = FakeFirebaseFirestore();
      final service = planServiceWithFake(firestore);

      final draftingId = await service.createPlan(
        samplePlan(userId: 'user-ua', name: 'Borrador', unpId: 'ua-1'),
      );
      final confirmedId = await service.createPlan(
        samplePlan(
          userId: 'user-ua',
          name: 'Confirmado',
          unpId: 'ua-2',
          createdAt: DateTime(2026, 8, 16, 13),
        ),
      );

      final confirmed = await service.getPlanById(confirmedId!);
      expect(
        await service.updatePlan(confirmed!.copyWith(state: 'confirmado')),
        isTrue,
      );

      final all = await service.getPlansByUserId('user-ua').first;
      final byState = all.where((p) => p.state == 'confirmado').toList();
      expect(byState, hasLength(1));
      expect(byState.single.id, confirmedId);
      expect(all.map((p) => p.id), containsAll([draftingId, confirmedId]));
    });

    test('PLAN-R-003: getPlanByUnpId finds plan; unknown returns null', () async {
      final firestore = FakeFirebaseFirestore();
      final service = planServiceWithFake(firestore);

      final planId = await service.createPlan(
        samplePlan(userId: 'user-ua', name: 'Londres 2026', unpId: 'ua-42'),
      );

      final found = await service.getPlanByUnpId('ua-42');
      expect(found, isNotNull);
      expect(found!.id, planId);
      expect(found.name, 'Londres 2026');
      expect(found.state, 'planificando');
      expect(found.timezone, 'Europe/Madrid');

      expect(await service.getPlanByUnpId('no-existe'), isNull);
    });

    test('PLAN-R-005: own list can be filtered by name', () async {
      final firestore = FakeFirebaseFirestore();
      final service = planServiceWithFake(firestore);

      await service.createPlan(
        samplePlan(userId: 'user-ua', name: 'Londres 2026', unpId: 'ua-1'),
      );
      await service.createPlan(
        samplePlan(
          userId: 'user-ua',
          name: 'París 2026',
          unpId: 'ua-2',
          createdAt: DateTime(2026, 8, 16, 13),
        ),
      );

      final all = await service.getPlansByUserId('user-ua').first;
      final hits = all
          .where((p) => p.name.toLowerCase().contains('londres'))
          .toList();
      expect(hits, hasLength(1));
      expect(hits.single.name, 'Londres 2026');
    });
  });
}
