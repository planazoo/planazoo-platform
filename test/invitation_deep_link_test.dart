import 'package:flutter_test/flutter_test.dart';
import 'package:unp_calendario/shared/utils/invitation_deep_link.dart';

void main() {
  group('invitationRouteFromUri', () {
    test('https invitation with action', () {
      final uri = Uri.parse(
        'https://app.planoon.com/invitation/tok123?action=accept',
      );
      expect(
        invitationRouteFromUri(uri),
        '/invitation/tok123?action=accept',
      );
    });

    test('custom scheme host=invitation', () {
      final uri = Uri.parse('planazoo://invitation/tok456');
      expect(invitationRouteFromUri(uri), '/invitation/tok456');
    });

    test('custom scheme path form', () {
      final uri = Uri.parse('planazoo:///invitation/tok789?action=reject');
      expect(
        invitationRouteFromUri(uri),
        '/invitation/tok789?action=reject',
      );
    });

    test('unrelated uri returns null', () {
      expect(
        invitationRouteFromUri(Uri.parse('https://app.planoon.com/plans')),
        isNull,
      );
    });
  });
}
