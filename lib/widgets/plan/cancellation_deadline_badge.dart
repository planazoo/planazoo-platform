import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/reservation_cancellation.dart';

/// Icono compacto cuando hay un límite de cancelación próximo (T273).
class CancellationDeadlineBadge extends StatelessWidget {
  final ReservationCancellation? reservation;
  final double size;
  /// Si true, solo muestra si el límite está en [within].
  final Duration within;
  final Color? color;

  const CancellationDeadlineBadge({
    super.key,
    required this.reservation,
    this.size = 12,
    this.within = const Duration(days: 14),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    if (r == null || !r.hasUpcomingDeadline(within: within)) {
      return const SizedBox.shrink();
    }
    final urgent = r.hasUpcomingDeadline(within: const Duration(hours: 48));
    return Tooltip(
      message: _tooltip(r),
      child: Icon(
        Icons.event_busy,
        size: size,
        color: color ??
            (urgent ? Colors.orangeAccent.shade200 : Colors.white70),
      ),
    );
  }

  String _tooltip(ReservationCancellation r) {
    final next = r.nextDeadline;
    final tier = r.nextTier;
    if (next == null) return '';
    final d =
        '${next.day.toString().padLeft(2, '0')}/${next.month.toString().padLeft(2, '0')} '
        '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}';
    final pct = tier?.refundPercent;
    if (pct == null) return 'Cancelación hasta $d';
    final pctStr = pct == pct.roundToDouble()
        ? pct.toStringAsFixed(0)
        : pct.toStringAsFixed(1);
    return 'Cancelación: recuperas $pctStr% hasta $d';
  }
}
