import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';

/// T252: Pantalla "Propuestas pendientes" para que el organizador acepte o rechace eventos propuestos por participantes.
class ProposalsPendingScreen extends ConsumerWidget {
  final Plan plan;

  const ProposalsPendingScreen({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final planId = plan.id ?? '';
    final isOrganizer = currentUser != null && plan.userId == currentUser.id;

    final bar = _buildSectionBar(loc.proposalsPendingTitle);

    if (currentUser == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          const Expanded(child: Center(child: Text('Inicia sesión'))),
        ],
      );
    }

    if (!isOrganizer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  loc.proposalsOnlyOrganizer,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final proposalsAsync = ref.watch(planProposalEventsStreamProvider(planId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bar,
        Expanded(
          child: proposalsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    loc.proposalsEmpty,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _ProposalCard(
                    event: event,
                    onAccept: () => _acceptProposal(ref, event),
                    onReject: () => _rejectProposal(ref, event),
                    loc: loc,
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColorScheme.color2),
            ),
            error: (err, _) => Center(
              child: Text(
                err.toString(),
                style: GoogleFonts.poppins(color: Colors.red.shade300, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBar(String title) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColorScheme.color2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptProposal(WidgetRef ref, Event event) async {
    if (event.id == null) return;
    final eventService = ref.read(eventServiceProvider);
    await eventService.confirmEvent(event.id!);
    ref.invalidate(planProposalEventsStreamProvider(event.planId));
    ref.invalidate(planEventsStreamProvider(event.planId));
  }

  Future<void> _rejectProposal(WidgetRef ref, Event event) async {
    if (event.id == null) return;
    final eventService = ref.read(eventServiceProvider);
    await eventService.deleteEvent(event.id!);
    ref.invalidate(planProposalEventsStreamProvider(event.planId));
    ref.invalidate(planEventsStreamProvider(event.planId));
  }
}

class _ProposalCard extends StatelessWidget {
  final Event event;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final AppLocalizations loc;

  const _ProposalCard({
    required this.event,
    required this.onAccept,
    required this.onReject,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = '${event.hour.toString().padLeft(2, '0')}:${event.startMinute.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormatter.formatDate(event.date)} · $timeStr',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onReject,
                  child: Text(loc.proposalsReject, style: GoogleFonts.poppins(color: Colors.red.shade300)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(backgroundColor: AppColorScheme.color2),
                  child: Text(loc.proposalsAccept, style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
