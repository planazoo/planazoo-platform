import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unp_calendario/features/calendar/domain/event_description_validation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';

import 'plan_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<(FakeFirebaseFirestore, PlanService, EventService, String)> seedPlan() async {
    final firestore = FakeFirebaseFirestore();
    final plans = planServiceWithFake(firestore);
    final events = eventServiceWithFake(firestore);
    final planId = (await plans.createPlan(
      samplePlan(userId: 'user-ua', name: 'Viaje', unpId: 'ua-1'),
    ))!;
    return (firestore, plans, events, planId);
  }

  group('E1 EVENT-C-001 create + read', () {
    test('participant creates event and can re-read it', () async {
      final (_, _, events, planId) = await seedPlan();

      final id = await events.createEvent(
        sampleEvent(planId: planId, userId: 'user-ua', description: 'Cena'),
      );
      expect(id, isNotNull);

      final created = await events.getEventById(id!);
      expect(created, isNotNull);
      expect(created!.description, 'Cena');
      expect(created.planId, planId);
      expect(created.userId, 'user-ua');
      expect(created.hour, 20);
      expect(created.durationMinutes, 90);
      expect(created.isDraft, isFalse);
    });

    test('getEventById returns null for unknown id', () async {
      final (_, _, events, _) = await seedPlan();
      expect(await events.getEventById('missing'), isNull);
    });

    test('EVENT-C-002 empty description is rejected', () async {
      final (_, _, events, planId) = await seedPlan();
      expect(validateEventDescription(''), EventDescriptionValidationError.empty);
      expect(
        await events.createEvent(
          sampleEvent(planId: planId, userId: 'user-ua', description: '  '),
        ),
        isNull,
      );
    });

    test('non-participant cannot create', () async {
      final (_, _, events, planId) = await seedPlan();
      expect(
        await events.createEvent(
          sampleEvent(planId: planId, userId: 'user-ub', description: 'Cena'),
        ),
        isNull,
      );
    });
  });

  group('E2 EVENT-R-001 list', () {
    test('participant sees plan events; outsider sees none; alojamiento excluded',
        () async {
      final (firestore, _, events, planId) = await seedPlan();
      final id = await events.createEvent(
        sampleEvent(planId: planId, userId: 'user-ua'),
      );
      await firestore.collection('events').doc('aloj-1').set({
        'planId': planId,
        'typeFamily': 'alojamiento',
        'placeName': 'Hotel',
        'date': DateTime(2026, 8, 18),
        'hour': 0,
      });
      await firestore.collection('events').doc('other').set({
        'planId': 'otro-plan',
        'userId': 'user-ua',
        'description': 'Otro',
        'date': DateTime(2026, 8, 18),
        'hour': 10,
        'duration': 1,
        'durationMinutes': 60,
        'isDraft': false,
        'createdAt': DateTime(2026, 8, 16),
        'updatedAt': DateTime(2026, 8, 16),
      });

      final listed =
          await events.getEventsByPlanId(planId, 'user-ua').first;
      expect(listed.map((e) => e.id), contains(id));
      expect(listed.map((e) => e.id), isNot(contains('aloj-1')));
      expect(listed.map((e) => e.id), isNot(contains('other')));

      expect(await events.getEventById('aloj-1'), isNull);
      expect(await events.getEventsByPlanId(planId, 'user-ub').first, isEmpty);
    });

    test('EVENT-R-004 list can be filtered by typeFamily', () async {
      final (_, _, events, planId) = await seedPlan();
      await events.createEvent(
        sampleEvent(
          planId: planId,
          userId: 'user-ua',
          description: 'Vuelo',
          typeFamily: 'Desplazamiento',
        ),
      );
      await events.createEvent(
        sampleEvent(
          planId: planId,
          userId: 'user-ua',
          description: 'Museo',
          hour: 11,
          typeFamily: 'Actividad',
        ),
      );

      final listed =
          await events.getEventsByPlanId(planId, 'user-ua').first;
      final flights =
          listed.where((e) => e.typeFamily == 'Desplazamiento').toList();
      expect(flights, hasLength(1));
      expect(flights.single.description, 'Vuelo');
    });
  });

  group('E3 EVENT-U-001/002 update', () {
    test('updates description and time; keeps createdAt', () async {
      final (_, _, events, planId) = await seedPlan();
      final id = await events.createEvent(
        sampleEvent(planId: planId, userId: 'user-ua'),
      );
      final created = await events.getEventById(id!);
      final originalCreatedAt = created!.createdAt;

      expect(
        await events.updateEvent(
          created.copyWith(
            description: 'Cena tardía',
            hour: 21,
            date: DateTime(2026, 8, 19),
          ),
        ),
        isTrue,
      );

      final updated = await events.getEventById(id);
      expect(updated!.description, 'Cena tardía');
      expect(updated.hour, 21);
      expect(updated.date, DateTime(2026, 8, 19));
      expect(
        updated.createdAt.millisecondsSinceEpoch,
        originalCreatedAt.millisecondsSinceEpoch,
      );
    });

    test('updateEvent without id returns false', () async {
      final (_, _, events, planId) = await seedPlan();
      expect(
        await events.updateEvent(
          sampleEvent(planId: planId, userId: 'user-ua'),
        ),
        isFalse,
      );
    });
  });

  group('E4 EVENT-C-012 / EVENT-U-007 draft', () {
    test('draft is hidden from confirmed list until confirmEvent', () async {
      final (_, _, events, planId) = await seedPlan();
      final id = await events.createEvent(
        sampleEvent(
          planId: planId,
          userId: 'user-ua',
          description: 'Idea',
          isDraft: true,
        ),
      );

      expect(
        (await events.getDraftEventsByPlanId(planId, 'user-ua').first)
            .map((e) => e.id),
        contains(id),
      );
      expect(
        await events.getConfirmedEventsByPlanId(planId, 'user-ua').first,
        isEmpty,
      );

      expect(await events.confirmEvent(id!), isTrue);
      expect(
        await events.getDraftEventsByPlanId(planId, 'user-ua').first,
        isEmpty,
      );
      expect(
        (await events.getConfirmedEventsByPlanId(planId, 'user-ua').first)
            .map((e) => e.id),
        contains(id),
      );
    });
  });

  group('E5 EVENT-C-011 / C-014 persist extra fields', () {
    test('persists cost and type/subtype', () async {
      final (_, _, events, planId) = await seedPlan();
      final id = await events.createEvent(
        sampleEvent(
          planId: planId,
          userId: 'user-ua',
          description: 'Avión',
          typeFamily: 'Desplazamiento',
          cost: 120.5,
        ).copyWith(typeSubtype: 'Avión'),
      );
      final created = await events.getEventById(id!);
      expect(created!.cost, 120.5);
      expect(created.typeFamily, 'Desplazamiento');
      expect(created.typeSubtype, 'Avión');
    });
  });

  group('E6 EVENT-D-001 / D-005 delete', () {
    test('deletes event and event_participants; other events stay', () async {
      final (firestore, _, events, planId) = await seedPlan();
      final id = await events.createEvent(
        sampleEvent(planId: planId, userId: 'user-ua'),
      );
      final other = await events.createEvent(
        sampleEvent(
          planId: planId,
          userId: 'user-ua',
          description: 'Otro',
          hour: 10,
        ),
      );
      await firestore.collection('event_participants').doc('ep-1').set({
        'eventId': id,
        'userId': 'user-ua',
      });

      expect(await events.deleteEvent(id!), isTrue);
      expect(await events.getEventById(id), isNull);
      expect(
        (await firestore.collection('event_participants').doc('ep-1').get())
            .exists,
        isFalse,
      );
      expect(await events.getEventById(other!), isNotNull);
    });

    test('deleteEvent unknown id returns false', () async {
      final (_, _, events, _) = await seedPlan();
      expect(await events.deleteEvent('missing'), isFalse);
    });
  });

  group('E8 EVENT-C-005 / C-006 duration', () {
    test('persists custom duration; rejects more than 24h', () async {
      final (_, _, events, planId) = await seedPlan();
      final id = await events.createEvent(
        sampleEvent(
          planId: planId,
          userId: 'user-ua',
          durationMinutes: 45,
        ),
      );
      expect((await events.getEventById(id!))!.durationMinutes, 45);

      expect(
        await events.createEvent(
          sampleEvent(
            planId: planId,
            userId: 'user-ua',
            description: 'Maratón',
            durationMinutes: 1500,
          ),
        ),
        isNull,
      );
    });
  });

  group('E9 EVENT-C-009 / C-007 / C-003 persist fields', () {
    test('persists maxParticipants, timezone and commonPart audience', () async {
      final (_, _, events, planId) = await seedPlan();
      final id = await events.createEvent(
        sampleEvent(
          planId: planId,
          userId: 'user-ua',
          maxParticipants: 5,
          timezone: 'Europe/Madrid',
          arrivalTimezone: 'America/New_York',
          participantTrackIds: const ['user-ua'],
          commonPart: EventCommonPart(
            description: 'Cena',
            date: DateTime(2026, 8, 18),
            startHour: 20,
            startMinute: 0,
            durationMinutes: 90,
            isForAllParticipants: false,
            participantIds: const ['user-ua'],
          ),
        ),
      );
      final created = await events.getEventById(id!);
      expect(created!.maxParticipants, 5);
      expect(created.timezone, 'Europe/Madrid');
      expect(created.arrivalTimezone, 'America/New_York');
      expect(created.commonPart, isNotNull);
      expect(created.commonPart!.isForAllParticipants, isFalse);
      expect(created.commonPart!.participantIds, ['user-ua']);
      expect(created.participantTrackIds, ['user-ua']);
    });

    test('rejects more assigned tracks than maxParticipants', () async {
      final (_, _, events, planId) = await seedPlan();
      expect(
        await events.createEvent(
          sampleEvent(
            planId: planId,
            userId: 'user-ua',
            maxParticipants: 2,
            participantTrackIds: const ['a', 'b', 'c'],
          ),
        ),
        isNull,
      );
    });
  });

  group('E10 EVENT-C-011 / C-017 / C-010 service guards', () {
    test('rejects negative cost and date outside plan range', () async {
      final (_, _, events, planId) = await seedPlan();
      expect(
        await events.createEvent(
          sampleEvent(
            planId: planId,
            userId: 'user-ua',
            cost: -10,
          ),
        ),
        isNull,
      );
      expect(
        await events.createEvent(
          sampleEvent(
            planId: planId,
            userId: 'user-ua',
            date: DateTime(2026, 8, 30),
          ),
        ),
        isNull,
      );
    });

    test('saveEvent with requiresConfirmation creates pending rows', () async {
      final (firestore, _, events, planId) = await seedPlan();
      final saved = await events.saveEvent(
        sampleEvent(
          planId: planId,
          userId: 'user-ua',
          description: 'Padel',
          requiresConfirmation: true,
        ),
      );
      expect(saved, isNotNull);
      expect(saved!.requiresConfirmation, isTrue);
      expect(saved.description, 'Padel');

      final pending = await firestore
          .collection('event_participants')
          .where('eventId', isEqualTo: saved.id)
          .where('confirmationStatus', isEqualTo: 'pending')
          .get();
      expect(pending.docs, isNotEmpty);
      expect(
        pending.docs.map((d) => d.data()['userId']),
        contains('user-ua'),
      );
    });
  });

  group('E11 EVENT-D-004 plan state blocks write/delete', () {
    test('cannot create or delete when plan is finished', () async {
      final (firestore, _, events, planId) = await seedPlan();
      final id = await events.createEvent(
        sampleEvent(planId: planId, userId: 'user-ua'),
      );
      expect(id, isNotNull);

      await firestore.collection('plans').doc(planId).update({
        'state': 'finalizado',
      });

      expect(
        await events.createEvent(
          sampleEvent(
            planId: planId,
            userId: 'user-ua',
            description: 'Tarde',
            hour: 10,
          ),
        ),
        isNull,
      );
      expect(await events.deleteEvent(id!), isFalse);
      expect(await events.getEventById(id), isNotNull);
    });
  });
}
