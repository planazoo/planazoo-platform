import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/reservation_cancellation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

class _UpcomingCancellationRow {
  final String label;
  final bool isAccommodation;
  final CancellationTier tier;
  final ReservationCancellation reservation;

  const _UpcomingCancellationRow({
    required this.label,
    required this.isAccommodation,
    required this.tier,
    required this.reservation,
  });
}

/// Lista «Próximas cancelaciones» para Info del plan (T273).
class UpcomingCancellationsSection extends ConsumerWidget {
  final String planId;
  final bool isCompact;

  const UpcomingCancellationsSection({
    super.key,
    required this.planId,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(planEventsStreamProvider(planId));
    final accAsync = ref.watch(planAccommodationsStreamProvider(planId));

    final events = eventsAsync.valueOrNull ?? const <Event>[];
    final accs = accAsync.valueOrNull ?? const <Accommodation>[];
    final rows = _buildRows(events, accs);
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_busy, color: Colors.orangeAccent.shade200, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.upcomingCancellationsTitle,
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            loc.upcomingCancellationsSubtitle,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 12),
          ...rows.map((row) => _buildRow(context, loc, row)),
        ],
      ),
    );
  }

  List<_UpcomingCancellationRow> _buildRows(
    List<Event> events,
    List<Accommodation> accs,
  ) {
    final now = DateTime.now();
    final out = <_UpcomingCancellationRow>[];
    for (final e in events) {
      final r = e.reservationCancellation;
      if (r == null) continue;
      for (final t in r.tiers) {
        if (t.deadlineAt.isAfter(now)) {
          out.add(_UpcomingCancellationRow(
            label: e.description.trim().isEmpty ? 'Evento' : e.description.trim(),
            isAccommodation: false,
            tier: t,
            reservation: r,
          ));
        }
      }
    }
    for (final a in accs) {
      final r = a.reservationCancellation;
      if (r == null) continue;
      for (final t in r.tiers) {
        if (t.deadlineAt.isAfter(now)) {
          out.add(_UpcomingCancellationRow(
            label: a.hotelName.trim().isEmpty ? 'Alojamiento' : a.hotelName.trim(),
            isAccommodation: true,
            tier: t,
            reservation: r,
          ));
        }
      }
    }
    out.sort((a, b) => a.tier.deadlineAt.compareTo(b.tier.deadlineAt));
    return out.take(8).toList();
  }

  Widget _buildRow(
    BuildContext context,
    AppLocalizations loc,
    _UpcomingCancellationRow row,
  ) {
    final d = row.tier.deadlineAt;
    final deadlineStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final pct = row.tier.refundPercent;
    final pctStr = pct == pct.roundToDouble()
        ? pct.toStringAsFixed(0)
        : pct.toStringAsFixed(1);
    final urgent = d.isBefore(DateTime.now().add(const Duration(hours: 48)));
    final fee = row.reservation.cancellationFixedFee;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            row.isAccommodation ? Icons.hotel : Icons.event,
            size: 18,
            color: urgent ? Colors.orangeAccent.shade200 : Colors.white54,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  loc.upcomingCancellationRow(deadlineStr, pctStr),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: urgent ? Colors.orangeAccent.shade100 : Colors.white70,
                  ),
                ),
                if (fee != null && fee > 0)
                  Text(
                    loc.upcomingCancellationFixedFee(fee.toStringAsFixed(
                      fee == fee.roundToDouble() ? 0 : 2,
                    )),
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
