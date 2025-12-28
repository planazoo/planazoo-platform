import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/auth/domain/models/user_model.dart';
import 'package:unp_calendario/features/auth/domain/services/user_service.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/event_participant.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/domain/services/event_participant_service.dart';
import 'package:unp_calendario/features/calendar/domain/services/plan_participation_service.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';

class AdminInsightsScreen extends ConsumerStatefulWidget {
  const AdminInsightsScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<AdminInsightsScreen> createState() => _AdminInsightsScreenState();
}

class _AdminInsightsScreenState extends ConsumerState<AdminInsightsScreen> {
  late Future<_AdminInsightsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_AdminInsightsData> _loadData() async {
    final planService = ref.read(planServiceProvider);
    final participationService = PlanParticipationService();
    final eventParticipantService = EventParticipantService();
    final userService = UserService();
    final firestore = FirebaseFirestore.instance;

    final plansSnapshot = await planService.getPlans().first;
    final activePlans = plansSnapshot.where((plan) => _isPlanActive(plan.state)).toList();

    final users = await userService.getAllUsers();
    final userMap = {for (final user in users) user.id: user};

    final entries = <_AdminPlanEntry>[];
    final participantIds = <String>{};

    for (final plan in activePlans) {
      if (plan.id == null) continue;
      final participations = await participationService.getPlanParticipations(plan.id!).first;

      final eventsQuery = await firestore
          .collection('events')
          .where('planId', isEqualTo: plan.id)
          .get();
      final events = <Event>[];
      final eventParticipantsMap = <String, List<EventParticipant>>{};
      final accommodations = <Accommodation>[];
      for (final doc in eventsQuery.docs) {
        final data = doc.data();
        final typeFamily = data['typeFamily'];
        final isDraft = data['isDraft'] ?? false;
        if (typeFamily == 'alojamiento') {
          accommodations.add(Accommodation.fromFirestore(doc));
        } else {
          if (!(isDraft as bool)) {
            final event = Event.fromFirestore(doc);
            events.add(event);

            if (event.id != null) {
              final eventParticipants = await eventParticipantService
                  .getAllEventParticipants(event.id!)
                  .first;
              eventParticipants.sort(
                (a, b) => _compareUsers(userMap[a.userId], userMap[b.userId]),
              );
              eventParticipantsMap[event.id!] = eventParticipants;
            }
          }
        }
      }

      for (final participation in participations) {
        participantIds.add(participation.userId);
      }

      entries.add(_AdminPlanEntry(
        plan: plan,
        participations: participations,
        events: events,
        accommodations: accommodations,
        eventParticipants: eventParticipantsMap,
      ));
    }

    final sortedParticipantIds = participantIds.toList()
      ..sort((a, b) => _compareUsers(userMap[a], userMap[b]));

    return _AdminInsightsData(
      entries: entries,
      userMap: userMap,
      participantIds: sortedParticipantIds,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadData();
    });
    await _future;
  }

  void _exportPlansCsv(BuildContext context, _AdminInsightsData data) async {
    final loc = AppLocalizations.of(context)!;
    final buffer = StringBuffer();
    final header = [
      'Plan',
      'Inicio',
      'Fin',
      ...data.participantIds.map((id) => data.userMap[id]?.displayIdentifier ?? id),
    ];
    buffer.writeln(header.join(','));

    for (final entry in data.entries) {
      final row = <String>[
        entry.plan.name,
        DateFormatter.formatDate(entry.plan.startDate),
        DateFormatter.formatDate(entry.plan.endDate),
      ];
      for (final participantId in data.participantIds) {
        final participation = entry.participations.firstWhere(
          (p) => p.userId == participantId,
          orElse: () => _emptyParticipation,
        );
        if (participation == _emptyParticipation) {
          row.add('');
        } else {
          row.add(_roleShortLabel(participation.role));
        }
      }
      buffer.writeln(row.map(_escapeCsv).join(','));
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.adminInsightsExportCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<_AdminInsightsData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  loc.adminInsightsError,
                  style: AppTypography.bodyStyle.copyWith(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(loc.adminInsightsRetry),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data;
        if (data == null || data.entries.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.adminInsightsTitle,
                        style: AppTypography.largeTitle.copyWith(
                          color: AppColorScheme.color4,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.adminInsightsRefresh),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    loc.adminInsightsEmpty,
                    style: AppTypography.bodyStyle.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.adminInsightsTitle,
                      style: AppTypography.largeTitle.copyWith(
                        color: AppColorScheme.color4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => _exportPlansCsv(context, data),
                    icon: const Icon(Icons.download),
                    label: Text(loc.adminInsightsExportCsv),
                  ),
                  const SizedBox(width: 12),
                  if (widget.onClose != null)
                    FilledButton.tonalIcon(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close),
                      label: Text(loc.adminInsightsClose),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _PlanParticipantsMatrix(data: data),
              const SizedBox(height: 24),
              ...data.entries.map((entry) => _PlanDetailsCard(
                    entry: entry,
                    data: data,
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _PlanParticipantsMatrix extends StatelessWidget {
  const _PlanParticipantsMatrix({required this.data});

  final _AdminInsightsData data;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final columns = <DataColumn>[
      DataColumn(label: Text(loc.adminInsightsColumnPlan, style: _headerStyle)),
      DataColumn(label: Text(loc.adminInsightsColumnStart, style: _headerStyle)),
      DataColumn(label: Text(loc.adminInsightsColumnEnd, style: _headerStyle)),
      ...data.participantIds.map(
        (id) => DataColumn(
          label: _buildParticipantHeader(
            user: data.userMap[id],
          ),
        ),
      ),
    ];

    final rows = data.entries.map((entry) {
      final cells = <DataCell>[
        DataCell(Text(entry.plan.name, style: _bodyStyle)),
        DataCell(Text(DateFormatter.formatDate(entry.plan.startDate), style: _bodyStyle)),
        DataCell(Text(DateFormatter.formatDate(entry.plan.endDate), style: _bodyStyle)),
      ];

      for (final participantId in data.participantIds) {
        final participation = entry.participations.firstWhere(
          (p) => p.userId == participantId,
          orElse: () => _emptyParticipation,
        );
        if (participation == _emptyParticipation) {
          cells.add(const DataCell(Text('')));
        } else {
          cells.add(
            DataCell(
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColorScheme.color2.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _roleShortLabel(participation.role),
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColorScheme.color2,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }

      return DataRow(cells: cells);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns,
        rows: rows,
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
        dataRowColor: MaterialStateProperty.all(Colors.white),
        columnSpacing: 24,
      ),
    );
  }
}

class _PlanDetailsCard extends StatelessWidget {
  const _PlanDetailsCard({required this.entry, required this.data});

  final _AdminPlanEntry entry;
  final _AdminInsightsData data;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final userMap = data.userMap;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          entry.plan.name,
          style: AppTypography.mediumTitle.copyWith(color: AppColorScheme.color4),
        ),
        subtitle: Text(
          '${DateFormatter.formatDate(entry.plan.startDate)} · ${DateFormatter.formatDate(entry.plan.endDate)}',
          style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
        ),
        children: [
          _SectionTitle(label: loc.adminInsightsParticipantsSection),
          _ParticipantsTable(entry: entry, userMap: userMap),
          const SizedBox(height: 16),
          _SectionTitle(label: loc.adminInsightsEventsSection),
          _EventsTable(
            entry: entry,
            data: data,
          ),
          const SizedBox(height: 16),
          _SectionTitle(label: loc.adminInsightsAccommodationsSection),
          _AccommodationsTable(accommodations: entry.accommodations),
        ],
      ),
    );
  }
}

class _ParticipantsTable extends StatelessWidget {
  const _ParticipantsTable({required this.entry, required this.userMap});

  final _AdminPlanEntry entry;
  final Map<String, UserModel> userMap;

  @override
  Widget build(BuildContext context) {
    if (entry.participations.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.adminInsightsNoParticipants,
        style: AppTypography.bodyStyle.copyWith(color: Colors.grey.shade600),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(AppLocalizations.of(context)!.adminInsightsColumnParticipant, style: _headerStyle)),
          DataColumn(label: Text(AppLocalizations.of(context)!.adminInsightsColumnRole, style: _headerStyle)),
          DataColumn(label: Text(AppLocalizations.of(context)!.adminInsightsColumnTimezone, style: _headerStyle)),
          DataColumn(label: Text(AppLocalizations.of(context)!.adminInsightsColumnJoined, style: _headerStyle)),
        ],
        rows: entry.participations.map((p) {
          final user = userMap[p.userId];
          return DataRow(cells: [
            DataCell(Text(user?.displayIdentifier ?? p.userId, style: _bodyStyle)),
            DataCell(Text(_roleFullLabel(p.role), style: _bodyStyle)),
            DataCell(Text(p.personalTimezone ?? user?.defaultTimezone ?? '-', style: _bodyStyle)),
            DataCell(Text(DateFormatter.formatDate(p.joinedAt), style: _bodyStyle)),
          ]);
        }).toList(),
      ),
    );
  }
}

class _EventsTable extends StatelessWidget {
  const _EventsTable({required this.entry, required this.data});

  final _AdminPlanEntry entry;
  final _AdminInsightsData data;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (entry.events.isEmpty) {
      return Text(
        loc.adminInsightsNoEvents,
        style: AppTypography.bodyStyle.copyWith(color: Colors.grey.shade600),
      );
    }

    final participants = [...entry.participations]
      ..sort(
        (a, b) => _compareUsers(data.userMap[a.userId], data.userMap[b.userId]),
      );

    final columns = <DataColumn>[
      DataColumn(label: Text(loc.adminInsightsColumnEvent, style: _headerStyle)),
      DataColumn(label: Text(loc.adminInsightsColumnDate, style: _headerStyle)),
      DataColumn(label: Text(loc.adminInsightsColumnTime, style: _headerStyle)),
      ...participants.map(
        (participation) => DataColumn(
          label: _buildParticipantHeader(
            user: data.userMap[participation.userId],
            subtitle: _roleShortLabel(participation.role),
          ),
        ),
      ),
    ];

    final rows = entry.events.map((event) {
      final eventParticipants =
          event.id != null ? (entry.eventParticipants[event.id] ?? const <EventParticipant>[]) : const <EventParticipant>[];

      final cells = <DataCell>[
        DataCell(Text(event.description, style: _bodyStyle)),
        DataCell(Text(DateFormatter.formatDate(event.date), style: _bodyStyle)),
        DataCell(Text(_formatEventTime(context, event), style: _bodyStyle)),
      ];

      for (final participation in participants) {
        final participantRecord = _findEventParticipant(eventParticipants, participation.userId);
        cells.add(
          DataCell(
            _buildEventParticipantCell(
              context: context,
              loc: loc,
              event: event,
              participant: participantRecord,
            ),
          ),
        );
      }

      return DataRow(cells: cells);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns,
        rows: rows,
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
        dataRowColor: MaterialStateProperty.all(Colors.white),
        columnSpacing: 24,
      ),
    );
  }
}

class _AccommodationsTable extends StatelessWidget {
  const _AccommodationsTable({required this.accommodations});

  final List<Accommodation> accommodations;

  @override
  Widget build(BuildContext context) {
    if (accommodations.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.adminInsightsNoAccommodations,
        style: AppTypography.bodyStyle.copyWith(color: Colors.grey.shade600),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(AppLocalizations.of(context)!.adminInsightsColumnAccommodation, style: _headerStyle)),
          DataColumn(label: Text(AppLocalizations.of(context)!.adminInsightsColumnCheckIn, style: _headerStyle)),
          DataColumn(label: Text(AppLocalizations.of(context)!.adminInsightsColumnCheckOut, style: _headerStyle)),
        ],
        rows: accommodations.map((acc) {
          return DataRow(cells: [
            DataCell(Text(acc.hotelName, style: _bodyStyle)),
            DataCell(Text(DateFormatter.formatDate(acc.checkIn), style: _bodyStyle)),
            DataCell(Text(DateFormatter.formatDate(acc.checkOut), style: _bodyStyle)),
          ]);
        }).toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: AppTypography.bodyStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColorScheme.color4,
        ),
      ),
    );
  }
}

Widget _buildParticipantHeader({UserModel? user, String? subtitle}) {
  return SizedBox(
    width: 140,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user?.displayIdentifier ?? '-',
          style: _headerStyle,
          textAlign: TextAlign.center,
          maxLines: 3,
          softWrap: true,
        ),
        if (subtitle != null && subtitle.isNotEmpty)
          Text(
            subtitle,
            style: _headerSecondaryStyle,
            textAlign: TextAlign.center,
          ),
      ],
    ),
  );
}

String _formatEventTime(BuildContext context, Event event) {
  final time = TimeOfDay(hour: event.hour, minute: event.startMinute);
  return time.format(context);
}

EventParticipant? _findEventParticipant(List<EventParticipant> participants, String userId) {
  for (final participant in participants) {
    if (participant.userId == userId) {
      return participant;
    }
  }
  return null;
}

Widget _buildEventParticipantCell({
  required BuildContext context,
  required AppLocalizations loc,
  required Event event,
  required EventParticipant? participant,
}) {
  String participationLabel;
  Color participationColor;

  if (participant == null) {
    participationLabel = loc.adminInsightsEventStatusNotRegistered;
    participationColor = Colors.grey.shade500;
  } else if (participant.isCancelled) {
    participationLabel = loc.adminInsightsEventStatusCancelled;
    participationColor = Colors.red.shade500;
  } else if (participant.isRegistered) {
    participationLabel = loc.adminInsightsEventStatusRegistered;
    participationColor = Colors.green.shade600;
  } else {
    participationLabel = loc.adminInsightsEventStatusNotRegistered;
    participationColor = Colors.grey.shade500;
  }

  String? confirmationLabel;
  Color? confirmationColor;

  if (event.requiresConfirmation) {
    final status = participant?.confirmationStatus;
    if (status == 'confirmed') {
      confirmationLabel = loc.adminInsightsEventConfirmationAccepted;
      confirmationColor = Colors.green.shade700;
    } else if (status == 'declined') {
      confirmationLabel = loc.adminInsightsEventConfirmationDeclined;
      confirmationColor = Colors.red.shade600;
    } else if (status == 'pending') {
      confirmationLabel = loc.adminInsightsEventConfirmationPending;
      confirmationColor = Colors.orange.shade700;
    } else {
      confirmationLabel = loc.adminInsightsEventConfirmationMissing;
      confirmationColor = Colors.grey.shade500;
    }
  }

  return SizedBox(
    width: 140,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          participationLabel,
          style: _bodyStyle.copyWith(
            color: participationColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (confirmationLabel != null)
          Text(
            confirmationLabel!,
            style: _statusSecondaryStyle.copyWith(
              color: confirmationColor ?? Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    ),
  );
}

class _AdminInsightsData {
  const _AdminInsightsData({
    required this.entries,
    required this.userMap,
    required this.participantIds,
  });

  final List<_AdminPlanEntry> entries;
  final Map<String, UserModel> userMap;
  final List<String> participantIds;
}

class _AdminPlanEntry {
  const _AdminPlanEntry({
    required this.plan,
    required this.participations,
    required this.events,
    required this.accommodations,
    required this.eventParticipants,
  });

  final Plan plan;
  final List<PlanParticipation> participations;
  final List<Event> events;
  final List<Accommodation> accommodations;
  final Map<String, List<EventParticipant>> eventParticipants;
}

final PlanParticipation _emptyParticipation = PlanParticipation(
  planId: '',
  userId: '',
  role: 'participant',
  joinedAt: DateTime.utc(1970, 1, 1),
);

bool _isPlanActive(String? state) {
  if (state == null) return true;
  return state != 'cancelado' && state != 'finalizado';
}

int _compareUsers(UserModel? a, UserModel? b) {
  final aName = a?.displayIdentifier ?? a?.email ?? '';
  final bName = b?.displayIdentifier ?? b?.email ?? '';
  return aName.toLowerCase().compareTo(bName.toLowerCase());
}

String _roleShortLabel(String role) {
  switch (role) {
    case 'organizer':
      return 'ORG';
    case 'coorganizer':
      return 'COORG';
    case 'observer':
      return 'OBS';
    default:
      return 'PART';
  }
}

String _roleFullLabel(String role) {
  switch (role) {
    case 'organizer':
      return 'Organizador';
    case 'coorganizer':
      return 'Coorganizador';
    case 'observer':
      return 'Observador';
    default:
      return 'Participante';
  }
}

String _escapeCsv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
  return value;
}

const TextStyle _headerStyle = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 12,
  color: AppColorScheme.color4,
);

const TextStyle _headerSecondaryStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 10,
  color: AppColorScheme.color4,
);

const TextStyle _bodyStyle = TextStyle(
  fontSize: 12,
  color: AppColorScheme.color4,
);

const TextStyle _statusSecondaryStyle = TextStyle(
  fontSize: 11,
  color: Colors.grey,
);
