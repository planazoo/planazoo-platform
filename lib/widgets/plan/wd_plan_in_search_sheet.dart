import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';

/// Abre el sheet de búsqueda dentro del plan (eventos + alojamientos).
Future<void> showPlanInSearchSheet({
  required BuildContext context,
  required List<Event> events,
  required List<Accommodation> accommodations,
  required void Function(Event event) onEventTap,
  required void Function(Accommodation accommodation) onAccommodationTap,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: IosFormColors.groupedBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (ctx) {
      return _PlanInSearchSheet(
        events: events,
        accommodations: accommodations,
        onEventTap: onEventTap,
        onAccommodationTap: onAccommodationTap,
      );
    },
  );
}

class _PlanInSearchSheet extends StatefulWidget {
  final List<Event> events;
  final List<Accommodation> accommodations;
  final void Function(Event event) onEventTap;
  final void Function(Accommodation accommodation) onAccommodationTap;

  const _PlanInSearchSheet({
    required this.events,
    required this.accommodations,
    required this.onEventTap,
    required this.onAccommodationTap,
  });

  @override
  State<_PlanInSearchSheet> createState() => _PlanInSearchSheetState();
}

class _PlanInSearchSheetState extends State<_PlanInSearchSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<_Hit> _hits() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <_Hit>[];
    for (final e in widget.events) {
      if (_eventMatches(e, q)) {
        out.add(_Hit.event(e));
      }
    }
    for (final a in widget.accommodations) {
      if (_accommodationMatches(a, q)) {
        out.add(_Hit.accommodation(a));
      }
    }
    out.sort((a, b) => a.sortDate.compareTo(b.sortDate));
    return out;
  }

  bool _eventMatches(Event e, String q) {
    final hay = [
      e.description,
      e.typeFamily ?? '',
      e.typeSubtype ?? '',
      e.commonPart?.description ?? '',
      e.commonPart?.location ?? '',
      e.commonPart?.family ?? '',
      e.commonPart?.subtype ?? '',
    ].join(' ').toLowerCase();
    return hay.contains(q);
  }

  bool _accommodationMatches(Accommodation a, String q) {
    final common = a.commonPart;
    final hay = [
      a.hotelName,
      a.description ?? '',
      a.typeFamily,
      a.typeSubtype,
      common?.hotelName ?? '',
      common?.address ?? '',
      common?.typeSubtype ?? '',
    ].join(' ').toLowerCase();
    return hay.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final hits = _hits();
    final q = _query.trim();

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.72,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: IosFormColors.separator,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: loc.planInSearchHint,
                        hintStyle: GoogleFonts.poppins(
                          color: IosFormColors.textTertiary,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColorScheme.color2,
                          size: 22,
                        ),
                        suffixIcon: q.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                color: Colors.white70,
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                              ),
                        filled: true,
                        fillColor: IosFormColors.pageBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      loc.cancel,
                      style: GoogleFonts.poppins(
                        color: AppColorScheme.color2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: q.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          loc.planInSearchNoQuery,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: IosFormColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : hits.isEmpty
                      ? Center(
                          child: Text(
                            loc.planInSearchEmpty,
                            style: GoogleFonts.poppins(
                              color: IosFormColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                          itemCount: hits.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          itemBuilder: (context, index) {
                            final hit = hits[index];
                            return ListTile(
                              leading: Icon(
                                hit.isAccommodation
                                    ? Icons.hotel_outlined
                                    : Icons.event_outlined,
                                color: AppColorScheme.color2,
                              ),
                              title: Text(
                                hit.title,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                hit.subtitle,
                                style: GoogleFonts.poppins(
                                  color: IosFormColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                final e = hit.event;
                                final a = hit.accommodation;
                                if (e != null) {
                                  widget.onEventTap(e);
                                } else if (a != null) {
                                  widget.onAccommodationTap(a);
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hit {
  final Event? event;
  final Accommodation? accommodation;
  final String title;
  final String subtitle;
  final DateTime sortDate;

  const _Hit._({
    this.event,
    this.accommodation,
    required this.title,
    required this.subtitle,
    required this.sortDate,
  });

  factory _Hit.event(Event e) {
    final typeCandidates = [
      e.typeSubtype,
      e.typeFamily,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    final type = typeCandidates.isEmpty ? null : typeCandidates.first;
    final time =
        '${e.hour.toString().padLeft(2, '0')}:${(e.startMinute).toString().padLeft(2, '0')}';
    final date = DateFormatter.formatDateShort(e.date);
    return _Hit._(
      event: e,
      title: e.description.trim().isEmpty ? (type ?? '…') : e.description,
      subtitle: [date, time, if (type != null) type].join(' · '),
      sortDate: e.date,
    );
  }

  factory _Hit.accommodation(Accommodation a) {
    final name = a.hotelName.trim().isNotEmpty
        ? a.hotelName
        : (a.commonPart?.hotelName ?? '…');
    final addr = (a.commonPart?.address ?? '').trim();
    final range =
        '${DateFormatter.formatDateShort(a.checkIn)} – ${DateFormatter.formatDateShort(a.checkOut)}';
    return _Hit._(
      accommodation: a,
      title: name,
      subtitle: [range, if (addr.isNotEmpty) addr].join(' · '),
      sortDate: a.checkIn,
    );
  }

  bool get isAccommodation => accommodation != null;
}
