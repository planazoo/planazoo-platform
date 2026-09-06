import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/inbound_mailbox.dart';
import 'package:unp_calendario/features/calendar/domain/models/pending_email_event.dart';
import 'package:unp_calendario/features/calendar/domain/services/pending_email_event_service.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/screens/wd_pending_event_card.dart';
import 'package:unp_calendario/widgets/plan/compose_communication_sheet.dart';

/// Buzón de comunicaciones sin colocar (mails reenviados).
class WdPendingEmailEventsScreen extends ConsumerWidget {
  const WdPendingEmailEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authService = ref.watch(authServiceProvider);
    final authUid = authService.currentUser?.uid;
    if (user == null || authUid == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final service = PendingEmailEventService();
    final loc = AppLocalizations.of(context)!;
    return StreamBuilder<List<PendingEmailEvent>>(
      stream: service.streamPendingEvents(authUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: AppTypography.bodyStyle.copyWith(color: Colors.red.shade700),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final pending = (snapshot.data ?? []).where((e) => e.status == 'pending').toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.pendingEventsTitle, style: AppTypography.titleStyle),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => PendingEmailEventActions.copyInboundAddress(context),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            kPlanoonInboundMailbox,
                            style: AppTypography.bodyStyle.copyWith(
                              color: AppColorScheme.color2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.copy, size: 18, color: AppColorScheme.color2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.pendingEventsInboxHint,
                    style: AppTypography.caption.copyWith(color: AppColorScheme.color4),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => ComposeCommunicationSheet.show(
                        context,
                        userId: authUid,
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(loc.communicationAdd),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: pending.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          loc.pendingEventsEmpty,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyStyle.copyWith(color: AppColorScheme.color4),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: pending.length,
                      itemBuilder: (context, index) {
                        final item = pending[index];
                        return WdPendingEventCard(
                          pending: item,
                          userId: authUid,
                          onTap: () => PendingEmailEventActions.showBody(
                            context,
                            item,
                            userId: authUid,
                            onPlace: () => PendingEmailEventActions.showAssignDialog(
                              context,
                              ref,
                              item,
                              authUid,
                            ),
                          ),
                          onAssign: () => PendingEmailEventActions.showAssignDialog(
                            context,
                            ref,
                            item,
                            authUid,
                          ),
                          onDiscard: () => PendingEmailEventActions.discard(context, ref, item, authUid),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
