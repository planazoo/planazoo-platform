import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_service.dart';

import 'plan_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('P7 isValidTransition (FLUJO_ESTADOS_PLAN)', () {
    const svc = _Transitions();

    test('allows documented forward paths', () {
      expect(svc.isValid('planificando', 'confirmado'), isTrue);
      expect(svc.isValid('planificando', 'cancelado'), isTrue);
      expect(svc.isValid('confirmado', 'en_curso'), isTrue);
      expect(svc.isValid('confirmado', 'cancelado'), isTrue);
      expect(svc.isValid('confirmado', 'planificando'), isTrue);
      expect(svc.isValid('en_curso', 'finalizado'), isTrue);
      expect(svc.isValid('planificando', 'planificando'), isTrue);
    });

    test('rejects illegal and terminal transitions', () {
      expect(svc.isValid('planificando', 'en_curso'), isFalse);
      expect(svc.isValid('planificando', 'finalizado'), isFalse);
      expect(svc.isValid('en_curso', 'cancelado'), isFalse);
      expect(svc.isValid('en_curso', 'planificando'), isFalse);
      expect(svc.isValid('finalizado', 'planificando'), isFalse);
      expect(svc.isValid('cancelado', 'planificando'), isFalse);
      expect(svc.isValid('planificando', 'no-existe'), isFalse);
    });
  });

  group('P18 availableManualTransitions (menú Info)', () {
    test('matches documented menu per state', () {
      expect(
        PlanStateService.availableManualTransitions('planificando'),
        ['confirmado', 'cancelado'],
      );
      expect(
        PlanStateService.availableManualTransitions('confirmado'),
        ['en_curso', 'planificando', 'cancelado'],
      );
      expect(
        PlanStateService.availableManualTransitions('en_curso'),
        ['finalizado'],
      );
      expect(PlanStateService.availableManualTransitions('finalizado'), isEmpty);
      expect(PlanStateService.availableManualTransitions('cancelado'), isEmpty);
      expect(PlanStateService.availableManualTransitions(null), ['confirmado', 'cancelado']);
    });

    test('every menu option is a valid transition', () {
      const svc = _Transitions();
      for (final from in PlanStateService.validStates) {
        for (final to in PlanStateService.availableManualTransitions(from)) {
          expect(svc.isValid(from, to), isTrue, reason: '$from → $to');
        }
      }
    });
  });

  group('P7 changePlanState (fake Firestore)', () {
    test('owner can move planificando → confirmado', () async {
      final firestore = FakeFirebaseFirestore();
      final plans = planServiceWithFake(firestore);
      final states = PlanStateService(planService: plans);

      final planId = await plans.createPlan(
        samplePlan(userId: 'user-ua', name: 'Viaje', unpId: 'ua-1'),
      );

      final ok = await states.changePlanState(
        planId: planId!,
        newState: 'confirmado',
        userId: 'user-ua',
      );
      expect(ok, isTrue);
      expect((await plans.getPlanById(planId))!.state, 'confirmado');
    });

    test('participant cannot change state', () async {
      final firestore = FakeFirebaseFirestore();
      final plans = planServiceWithFake(firestore);
      final states = PlanStateService(planService: plans);

      final planId = await plans.createPlan(
        samplePlan(userId: 'user-ua', name: 'Viaje', unpId: 'ua-1'),
      );

      final ok = await states.changePlanState(
        planId: planId!,
        newState: 'confirmado',
        userId: 'user-ub',
      );
      expect(ok, isFalse);
      expect((await plans.getPlanById(planId))!.state, 'planificando');
    });

    test('illegal transition is rejected', () async {
      final firestore = FakeFirebaseFirestore();
      final plans = planServiceWithFake(firestore);
      final states = PlanStateService(planService: plans);

      final planId = await plans.createPlan(
        samplePlan(userId: 'user-ua', name: 'Viaje', unpId: 'ua-1'),
      );

      final ok = await states.changePlanState(
        planId: planId!,
        newState: 'finalizado',
        userId: 'user-ua',
      );
      expect(ok, isFalse);
      expect((await plans.getPlanById(planId))!.state, 'planificando');
    });
  });

  group('P8 cancel (slice T261, fake Firestore)', () {
    test('owner can cancel from planificando; plan stays in list', () async {
      final firestore = FakeFirebaseFirestore();
      final plans = planServiceWithFake(firestore);
      final states = PlanStateService(planService: plans);

      final planId = await plans.createPlan(
        samplePlan(userId: 'user-ua', name: 'Viaje', unpId: 'ua-1'),
      );

      final ok = await states.changePlanState(
        planId: planId!,
        newState: 'cancelado',
        userId: 'user-ua',
      );
      expect(ok, isTrue);

      final cancelled = await plans.getPlanById(planId);
      expect(cancelled!.state, 'cancelado');

      final listed = await plans.getPlansByUserId('user-ua').first;
      expect(listed.map((p) => p.id), contains(planId));
    });

    test('cannot cancel from en_curso', () async {
      final firestore = FakeFirebaseFirestore();
      final plans = planServiceWithFake(firestore);
      final states = PlanStateService(planService: plans);

      final planId = await plans.createPlan(
        samplePlan(userId: 'user-ua', name: 'Viaje', unpId: 'ua-1'),
      );
      final current = await plans.getPlanById(planId!);
      expect(
        await plans.updatePlan(current!.copyWith(state: 'en_curso')),
        isTrue,
      );

      final ok = await states.changePlanState(
        planId: planId,
        newState: 'cancelado',
        userId: 'user-ua',
      );
      expect(ok, isFalse);
      expect((await plans.getPlanById(planId))!.state, 'en_curso');
    });
  });

  group('P17 checkAndExecuteAutomaticTransitions (fake Firestore)', () {
    final now = DateTime.now();
    final pastStart = now.subtract(const Duration(days: 3));
    final pastEnd = now.subtract(const Duration(days: 1));
    final futureStart = now.add(const Duration(days: 2));
    final futureEnd = now.add(const Duration(days: 5));

    Future<(PlanService, PlanStateService, String)> seed({
      required String state,
      required DateTime start,
      required DateTime end,
    }) async {
      final firestore = FakeFirebaseFirestore();
      final plans = planServiceWithFake(firestore);
      final states = PlanStateService(planService: plans);
      final planId = (await plans.createPlan(
        samplePlan(userId: 'user-ua', name: 'Viaje', unpId: 'ua-1'),
      ))!;
      final current = await plans.getPlanById(planId);
      await plans.updatePlan(
        current!.copyWith(
          state: state,
          startDate: start,
          endDate: end,
          baseDate: start,
          columnCount: Plan.calendarDaysInclusive(start, end),
        ),
      );
      return (plans, states, planId);
    }

    test('confirmado + start in the past → en_curso', () async {
      final (plans, states, planId) = await seed(
        state: 'confirmado',
        start: pastStart,
        end: futureEnd,
      );

      expect(await states.checkAndExecuteAutomaticTransitions(planId: planId), isTrue);
      expect((await plans.getPlanById(planId))!.state, 'en_curso');
    });

    test('confirmado + start in the future → unchanged', () async {
      final (plans, states, planId) = await seed(
        state: 'confirmado',
        start: futureStart,
        end: futureEnd,
      );

      expect(await states.checkAndExecuteAutomaticTransitions(planId: planId), isFalse);
      expect((await plans.getPlanById(planId))!.state, 'confirmado');
    });

    test('planificando is not auto-advanced even if start passed', () async {
      final (plans, states, planId) = await seed(
        state: 'planificando',
        start: pastStart,
        end: futureEnd,
      );

      expect(await states.checkAndExecuteAutomaticTransitions(planId: planId), isFalse);
      expect((await plans.getPlanById(planId))!.state, 'planificando');
    });

    test('en_curso + end in the past → finalizado', () async {
      final (plans, states, planId) = await seed(
        state: 'en_curso',
        start: pastStart,
        end: pastEnd,
      );

      expect(await states.checkAndExecuteAutomaticTransitions(planId: planId), isTrue);
      expect((await plans.getPlanById(planId))!.state, 'finalizado');
    });

    test('en_curso + end in the future → unchanged', () async {
      final (plans, states, planId) = await seed(
        state: 'en_curso',
        start: pastStart,
        end: futureEnd,
      );

      expect(await states.checkAndExecuteAutomaticTransitions(planId: planId), isFalse);
      expect((await plans.getPlanById(planId))!.state, 'en_curso');
    });

    test('cancelado is not auto-advanced', () async {
      final (plans, states, planId) = await seed(
        state: 'cancelado',
        start: pastStart,
        end: pastEnd,
      );

      expect(await states.checkAndExecuteAutomaticTransitions(planId: planId), isFalse);
      expect((await plans.getPlanById(planId))!.state, 'cancelado');
    });

    test('confirmado with both dates past: first call en_curso, second finalizado',
        () async {
      final (plans, states, planId) = await seed(
        state: 'confirmado',
        start: pastStart,
        end: pastEnd,
      );

      expect(await states.checkAndExecuteAutomaticTransitions(planId: planId), isTrue);
      expect((await plans.getPlanById(planId))!.state, 'en_curso');

      expect(await states.checkAndExecuteAutomaticTransitions(planId: planId), isTrue);
      expect((await plans.getPlanById(planId))!.state, 'finalizado');
    });

    test('unknown plan id returns false', () async {
      final firestore = FakeFirebaseFirestore();
      final states = PlanStateService(planService: planServiceWithFake(firestore));

      expect(
        await states.checkAndExecuteAutomaticTransitions(planId: 'missing'),
        isFalse,
      );
    });
  });
}

/// Wrapper so the transition tests do not construct PlanStateService
/// (and thus EventService / Firestore) just to call a static-like method.
class _Transitions {
  const _Transitions();

  bool isValid(String from, String to) =>
      PlanStateService().isValidTransition(from, to);
}
