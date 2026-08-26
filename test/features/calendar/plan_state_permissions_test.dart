import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_state_permissions.dart';

import 'plan_test_helpers.dart';

void main() {
  group('P12 PlanStatePermissions (matriz FLUJO_ESTADOS)', () {
    test('dates only while planificando; read-only when finished or cancelled',
        () {
      final drafting = samplePlan(userId: 'ua', name: 'A');
      final confirmed =
          samplePlan(userId: 'ua', name: 'A', state: 'confirmado');
      final inProgress =
          samplePlan(userId: 'ua', name: 'A', state: 'en_curso');
      final done = samplePlan(userId: 'ua', name: 'A', state: 'finalizado');
      final cancelled =
          samplePlan(userId: 'ua', name: 'A', state: 'cancelado');

      expect(PlanStatePermissions.canModifyDates(drafting), isTrue);
      expect(PlanStatePermissions.canModifyDates(confirmed), isFalse);
      expect(PlanStatePermissions.canModifyDates(inProgress), isFalse);

      expect(PlanStatePermissions.canAddParticipants(drafting), isTrue);
      expect(PlanStatePermissions.canAddParticipants(confirmed), isTrue);
      expect(PlanStatePermissions.canAddParticipants(inProgress), isFalse);

      expect(PlanStatePermissions.canCancelPlan(drafting), isTrue);
      expect(PlanStatePermissions.canCancelPlan(confirmed), isTrue);
      expect(PlanStatePermissions.canCancelPlan(inProgress), isFalse);
      expect(PlanStatePermissions.canCancelPlan(done), isFalse);

      expect(PlanStatePermissions.isReadOnly(done), isTrue);
      expect(PlanStatePermissions.isReadOnly(cancelled), isTrue);
      expect(PlanStatePermissions.canEditBasicInfo(cancelled), isFalse);
      expect(PlanStatePermissions.canEditBasicInfo(drafting), isTrue);
    });

    test('EVENT-D-004 events: add/modify/delete blocked when finished or cancelled',
        () {
      final drafting = samplePlan(userId: 'ua', name: 'A');
      final confirmed =
          samplePlan(userId: 'ua', name: 'A', state: 'confirmado');
      final inProgress =
          samplePlan(userId: 'ua', name: 'A', state: 'en_curso');
      final done = samplePlan(userId: 'ua', name: 'A', state: 'finalizado');
      final cancelled =
          samplePlan(userId: 'ua', name: 'A', state: 'cancelado');

      expect(PlanStatePermissions.canAddEvents(drafting), isTrue);
      expect(PlanStatePermissions.canAddEvents(confirmed), isTrue);
      expect(PlanStatePermissions.canAddEvents(inProgress), isTrue);
      expect(PlanStatePermissions.canAddEvents(done), isFalse);
      expect(PlanStatePermissions.canAddEvents(cancelled), isFalse);

      expect(PlanStatePermissions.canModifyEvents(drafting), isTrue);
      expect(PlanStatePermissions.canModifyEvents(done), isFalse);
      expect(PlanStatePermissions.canModifyEvents(cancelled), isFalse);

      expect(PlanStatePermissions.canDeleteEvents(drafting), isTrue);
      expect(PlanStatePermissions.canDeleteEvents(inProgress), isTrue);
      expect(PlanStatePermissions.canDeleteEvents(done), isFalse);
      expect(PlanStatePermissions.canDeleteEvents(cancelled), isFalse);
    });
  });
}
