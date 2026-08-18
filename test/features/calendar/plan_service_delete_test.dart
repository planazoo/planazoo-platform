import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/plan_notes/domain/services/plan_notes_service.dart';

import 'plan_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('P15 PLAN-D-001 deletePlan (fake Firestore, no events)', () {
    test('owner delete removes plan, participation and notes workspace',
        () async {
      final firestore = FakeFirebaseFirestore();
      final service = planServiceWithFake(firestore);
      const userId = 'user-ua';

      final planId = await service.createPlan(
        samplePlan(userId: userId, name: 'A borrar', unpId: 'ua-1'),
      );
      expect(planId, isNotNull);

      expect(await service.deletePlan(planId!), isTrue);
      expect(await service.getPlanById(planId), isNull);

      final listed = await service.getPlansByUserId(userId).first;
      expect(listed, isEmpty);

      final participation = await PlanParticipationService(firestore: firestore)
          .getParticipation(planId, userId);
      expect(participation, isNull);

      final workspace = await firestore
          .collection('plans')
          .doc(planId)
          .collection(PlanNotesService.workspaceCollection)
          .doc(PlanNotesService.workspaceDocId)
          .get();
      expect(workspace.exists, isFalse);
    });
  });

  group('P16 PLAN-D-004/005 cascade', () {
    Future<String> seedPlanWithRelated(FakeFirebaseFirestore firestore) async {
      final service = planServiceWithFake(firestore);
      final planId = (await service.createPlan(
        samplePlan(userId: 'user-ua', name: 'Con extras', unpId: 'ua-1'),
      ))!;

      await firestore.collection('events').doc('ev-1').set({
        'planId': planId,
        'description': 'Cena',
      });
      await firestore.collection('events').doc('aloj-1').set({
        'planId': planId,
        'typeFamily': 'alojamiento',
        'placeName': 'Hotel',
      });
      await firestore.collection('event_participants').doc('ep-1').set({
        'eventId': 'ev-1',
        'userId': 'user-ua',
      });
      await firestore.collection('plan_invitations').doc('inv-1').set({
        'planId': planId,
        'email': 'ub@test.com',
        'status': 'pending',
      });
      await firestore.collection('plan_permissions').doc('perm-1').set({
        'planId': planId,
        'userId': 'user-ub',
      });
      await firestore
          .collection('plans')
          .doc(planId)
          .collection(PlanNotesService.personalCollection)
          .doc('user-ua')
          .set({'commonNoteText': 'nota personal'});

      await firestore.collection('events').doc('ev-other').set({
        'planId': 'otro-plan',
        'description': 'No tocar',
      });
      return planId;
    }

    test('deletePlan removes events and accommodations; other plans untouched',
        () async {
      final firestore = FakeFirebaseFirestore();
      final planId = await seedPlanWithRelated(firestore);
      final service = planServiceWithFake(firestore);

      expect(await service.deletePlan(planId), isTrue);
      expect(await service.getPlanById(planId), isNull);

      expect((await firestore.collection('events').doc('ev-1').get()).exists, isFalse);
      expect(
        (await firestore.collection('events').doc('aloj-1').get()).exists,
        isFalse,
      );
      expect(
        (await firestore.collection('events').doc('ev-other').get()).exists,
        isTrue,
      );
    });

    test('deletePlan removes invitations, event_participants, permissions, personal notes',
        () async {
      final firestore = FakeFirebaseFirestore();
      final planId = await seedPlanWithRelated(firestore);

      expect(await planServiceWithFake(firestore).deletePlan(planId), isTrue);

      expect(
        (await firestore.collection('plan_invitations').doc('inv-1').get()).exists,
        isFalse,
      );
      expect(
        (await firestore.collection('event_participants').doc('ep-1').get())
            .exists,
        isFalse,
      );
      expect(
        (await firestore.collection('plan_permissions').doc('perm-1').get())
            .exists,
        isFalse,
      );
      expect(
        (await firestore
                .collection('plans')
                .doc(planId)
                .collection(PlanNotesService.personalCollection)
                .doc('user-ua')
                .get())
            .exists,
        isFalse,
      );
    });

    test('deleteEventsByPlanId removes events and accommodations', () async {
      final firestore = FakeFirebaseFirestore();
      final planId = await seedPlanWithRelated(firestore);

      expect(
        await eventServiceWithFake(firestore).deleteEventsByPlanId(planId),
        isTrue,
      );

      expect((await firestore.collection('events').doc('ev-1').get()).exists, isFalse);
      expect(
        (await firestore.collection('events').doc('aloj-1').get()).exists,
        isFalse,
      );
      expect(
        (await firestore.collection('events').doc('ev-other').get()).exists,
        isTrue,
      );
      expect(await planServiceWithFake(firestore).getPlanById(planId), isNotNull);
    });
  });
}
