import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';

/// T252: Vista "Mi resumen" / "Mi itinerario" para participantes del plan.
/// Muestra: lo más importante del plan, hoy/mañana, accesos rápidos (vuelos, alojamiento), lista cronológica.
class MyPlanSummaryScreen extends ConsumerStatefulWidget {
  final Plan plan;
  final VoidCallback? onOpenEvent;
  final VoidCallback? onOpenAccommodation;

  const MyPlanSummaryScreen({
    super.key,
    required this.plan,
    this.onOpenEvent,
    this.onOpenAccommodation,
  });

  @override
  ConsumerState<MyPlanSummaryScreen> createState() => _MyPlanSummaryScreenState();
}

class _MyPlanSummaryScreenState extends ConsumerState<MyPlanSummaryScreen> {
  bool _hasShownHint = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final planId = widget.plan.id ?? '';
    final eventsAsync = ref.watch(planEventsStreamProvider(planId));
    final accommodations = ref.watch(accommodationsProvider(AccommodationNotifierParams(planId: planId)));

    if (currentUser == null) {
      return Center(
        child: Text(
          loc.loginTitle,
          style: GoogleFonts.poppins(color: Colors.grey.shade400),
        ),
      );
    }

    final userId = currentUser.id;
    final isOwner = widget.plan.userId == userId;

    /// Barra superior estándar W31 (GUIA_UI): 48 px, color2, título Poppins 16 w600.
    final bar = _buildSectionBar(loc.myPlanSummaryTab);

    return eventsAsync.when(
      data: (allEvents) {
        final myEvents = allEvents.where((e) =>
            e.participantTrackIds.isEmpty || e.participantTrackIds.contains(userId)).toList();
        myEvents.sort((a, b) {
          final c = a.date.compareTo(b.date);
          if (c != 0) return c;
          final h = (a.hour * 60 + a.startMinute).compareTo(b.hour * 60 + b.startMinute);
          return h;
        });

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final todayEvents = myEvents.where((e) {
          final d = DateTime(e.date.year, e.date.month, e.date.day);
          return d == today;
        }).toList();
        final tomorrowEvents = myEvents.where((e) {
          final d = DateTime(e.date.year, e.date.month, e.date.day);
          return d == tomorrow;
        }).toList();

        final flights = myEvents.where((e) =>
            (e.typeFamily == 'Desplazamiento' && e.typeSubtype == 'Avión') ||
            (e.typeFamily?.toLowerCase().contains('vuelo') == true)).toList();
        final myAccommodations = accommodations.where((a) =>
            a.participantTrackIds.isEmpty || a.participantTrackIds.contains(userId)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            bar,
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (!_hasShownHint && !isOwner) _buildFirstTimeHint(loc),
                      _buildImportantBlock(loc, todayEvents, tomorrowEvents, userId),
                      const SizedBox(height: 20),
                      _buildTodayTomorrowSection(loc, todayEvents, tomorrowEvents, today, tomorrow),
                      const SizedBox(height: 20),
                      _buildQuickAccessSection(loc, flights, myAccommodations),
                      const SizedBox(height: 20),
                      _buildChronologicalSection(loc, myEvents),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColorScheme.color2),
            ),
          ),
        ],
      ),
      error: (err, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          Expanded(
            child: Center(
              child: Text(
                err.toString(),
                style: GoogleFonts.poppins(color: Colors.red.shade300, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barra superior estándar (GUIA_UI § Panel W31): 48 px, color2, título Poppins 16 w600.
  Widget _buildSectionBar(String title) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColorScheme.color2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
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

  Widget _buildFirstTimeHint(AppLocalizations loc) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasShownHint) {
        setState(() => _hasShownHint = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.myPlanSummaryHint),
            backgroundColor: AppColorScheme.color2,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
    return const SizedBox.shrink();
  }

  Widget _buildImportantBlock(
    AppLocalizations loc,
    List<Event> todayEvents,
    List<Event> tomorrowEvents,
    String userId,
  ) {
    final plan = widget.plan;
    final allNear = [...todayEvents, ...tomorrowEvents];
    final myInfoLines = <String>[];
    for (final e in allNear) {
      final part = e.personalParts?[userId];
      if (part?.fields != null && part!.fields!.isNotEmpty) {
        final parts = part.fields!.entries
            .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
            .map((e) => '${e.key}: ${e.value}')
            .toList();
        if (parts.isNotEmpty) {
          myInfoLines.add('${e.description}: ${parts.join(', ')}');
        }
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.myPlanSummaryImportant,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColorScheme.color2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormatter.formatDate(plan.startDate)} – ${DateFormatter.formatDate(plan.endDate)}',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
          ),
          if (plan.timezone != null) ...[
            const SizedBox(height: 4),
            Text(
              plan.timezone!,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
          if (myInfoLines.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              loc.myPlanSummaryMyInfo,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            ...myInfoLines.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    line,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildTodayTomorrowSection(
    AppLocalizations loc,
    List<Event> todayEvents,
    List<Event> tomorrowEvents,
    DateTime today,
    DateTime tomorrow,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDayBlock(loc.myPlanSummaryToday, DateFormatter.formatDate(today), todayEvents),
        const SizedBox(height: 12),
        _buildDayBlock(loc.myPlanSummaryTomorrow, DateFormatter.formatDate(tomorrow), tomorrowEvents),
      ],
    );
  }

  Widget _buildDayBlock(String title, String dateStr, List<Event> events) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade700.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            Text(
              '—',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
            )
          else
            ...events.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${_formatEventTime(e)} ${e.description}',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                  ),
                )),
        ],
      ),
    );
  }

  String _formatEventTime(Event e) {
    final h = e.hour.toString().padLeft(2, '0');
    final m = e.startMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildQuickAccessSection(
    AppLocalizations loc,
    List<Event> flights,
    List<Accommodation> accommodations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.myPlanSummaryFlights,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        if (flights.isEmpty)
          Text(
            '—',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
          )
        else
          ...flights.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${DateFormatter.formatDate(e.date)} ${_formatEventTime(e)} ${e.description}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                ),
              )),
        const SizedBox(height: 16),
        Text(
          loc.myPlanSummaryAccommodation,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        if (accommodations.isEmpty)
          Text(
            '—',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
          )
        else
          ...accommodations.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${a.hotelName} (${DateFormatter.formatDate(a.checkIn)} – ${DateFormatter.formatDate(a.checkOut)})',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                ),
              )),
      ],
    );
  }

  Widget _buildChronologicalSection(AppLocalizations loc, List<Event> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.myPlanSummaryChronological,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (events.isEmpty)
          Text(
            '—',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
          )
        else
          ...events.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(
                        '${DateFormatter.formatDateShort(e.date)} ${_formatEventTime(e)}',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.description,
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}
