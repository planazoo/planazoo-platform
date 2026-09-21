import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import 'package:unp_calendario/features/payments/domain/models/payment_summary.dart';
import 'package:unp_calendario/features/payments/domain/models/personal_payment.dart';
import 'package:unp_calendario/features/payments/domain/models/plan_expense.dart';
import 'package:unp_calendario/features/payments/domain/services/balance_service.dart';
import 'package:unp_calendario/features/payments/presentation/providers/payment_providers.dart';
import 'package:unp_calendario/features/payments/presentation/widgets/add_expense_dialog.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:unp_calendario/widgets/wd_accommodation_dialog.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';

/// Lista general de gastos del plan (visión de cuadre / reparto).
class PaymentExpensesListPage extends ConsumerWidget {
  const PaymentExpensesListPage({super.key, required this.plan});

  final Plan plan;

  static const Color _pageBg = Color(0xFF111827);
  static const Color _surface = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final planId = plan.id;
    if (planId == null) {
      return Theme(
        data: AppTheme.darkTheme,
        child: Scaffold(
          backgroundColor: _pageBg,
          appBar: AppBar(
            title: Text(loc.paymentsExpensesListTitle),
            backgroundColor: _pageBg,
          ),
          body: const SizedBox.shrink(),
        ),
      );
    }

    final expensesAsync = ref.watch(planExpensesProvider(planId));
    final eventsAsync = ref.watch(planEventsStreamProvider(planId));
    final accommodationsAsync =
        ref.watch(planAccommodationsStreamProvider(planId));
    final summaryAsync = ref.watch(paymentSummaryProvider(planId));
    final realParticipantsAsync =
        ref.watch(planRealParticipantsProvider(planId));

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          backgroundColor: _pageBg,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(
            loc.paymentsExpensesListTitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: loc.paymentsExpensesExportMenu,
              icon: const Icon(Icons.share_outlined),
              onSelected: (value) {
                if (value == 'text') {
                  _copyExport(context, ref, asCsv: false);
                } else if (value == 'csv') {
                  _copyExport(context, ref, asCsv: true);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'text',
                  child: Text(loc.paymentsExpensesExportText),
                ),
                PopupMenuItem(
                  value: 'csv',
                  child: Text(loc.paymentsExpensesExportCsv),
                ),
              ],
            ),
            IconButton(
              tooltip: loc.paymentsAddExpense,
              icon: const Icon(Icons.add),
              onPressed: () => _openAddExpense(context, ref, const {}),
            ),
          ],
        ),
        body: SafeArea(
          child: _buildBody(
            context,
            ref,
            planId,
            loc,
            expensesAsync,
            ref.watch(paymentsByPlanProvider(planId)),
            eventsAsync,
            accommodationsAsync,
            summaryAsync,
            realParticipantsAsync,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    String planId,
    AppLocalizations loc,
    AsyncValue<List<PlanExpense>> expensesAsync,
    AsyncValue<List<PersonalPayment>> paymentsAsync,
    AsyncValue<List<Event>> eventsAsync,
    AsyncValue<List<Accommodation>> accommodationsAsync,
    AsyncValue<PaymentSummary> summaryAsync,
    AsyncValue<List<PlanParticipation>> realParticipantsAsync,
  ) {
    if (expensesAsync.isLoading || paymentsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (expensesAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            expensesAsync.error.toString(),
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (paymentsAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            paymentsAsync.error.toString(),
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final expenses = expensesAsync.asData?.value ?? const <PlanExpense>[];
    final guarantees = (paymentsAsync.asData?.value ?? const <PersonalPayment>[])
        .where((p) => p.isGuarantee)
        .toList();
    final events = eventsAsync.asData?.value ?? const <Event>[];
    final accommodations =
        accommodationsAsync.asData?.value ?? const <Accommodation>[];
    final realParticipantIds = (realParticipantsAsync.asData?.value ??
            const <PlanParticipation>[])
        .map((p) => p.userId)
        .toSet();
    final nameByUserId = <String, String>{};
    final summary = summaryAsync.asData?.value;
    if (summary != null) {
      for (final e in summary.balancesByParticipant.entries) {
        nameByUserId[e.key] = e.value.userName;
      }
    }

    final movements = <_ListMovement>[
      for (final e in expenses) _ListMovement.expense(e),
      for (final g in guarantees) _ListMovement.guarantee(g),
    ]..sort((a, b) {
        final byDate = b.sortDate.compareTo(a.sortDate);
        if (byDate != 0) return byDate;
        return b.createdAt.compareTo(a.createdAt);
      });

    if (movements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 48, color: Colors.white.withValues(alpha: 0.35)),
              const SizedBox(height: 12),
              Text(
                loc.paymentsExpensesListEmpty,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _openAddExpense(context, ref, nameByUserId),
                icon: const Icon(Icons.add),
                label: Text(loc.paymentsAddExpense),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColorScheme.color2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final eventById = {
      for (final e in events)
        if (e.id != null && e.id!.isNotEmpty) e.id!: e,
    };
    final accommodationById = {
      for (final a in accommodations)
        if (a.id != null && a.id!.isNotEmpty) a.id!: a,
    };

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: movements.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: IosFormColors.cardGap),
      itemBuilder: (context, index) {
        final m = movements[index];
        if (m.expense != null) {
          final expense = m.expense!;
          return _ExpenseListCard(
            plan: plan,
            expense: expense,
            nameByUserId: nameByUserId,
            event: expense.eventId != null
                ? eventById[expense.eventId!]
                : null,
            accommodation: expense.accommodationId != null
                ? accommodationById[expense.accommodationId!]
                : null,
            onOpenEvent: (event) => _openEvent(context, ref, event),
            onOpenAccommodation: (acc) =>
                _openAccommodation(context, ref, acc),
            onEdit: () => _openAddExpense(
              context,
              ref,
              nameByUserId,
              existing: expense,
            ),
            onDeleted: () {
              ref.invalidate(paymentSummaryProvider(planId));
              ref.invalidate(planExpensesProvider(planId));
            },
          );
        }
        final guarantee = m.guarantee!;
        return _GuaranteeListCard(
          plan: plan,
          payment: guarantee,
          nameByUserId: nameByUserId,
          shareParticipantIds: guaranteeShareParticipantIds(
            payment: guarantee,
            events: events,
            accommodations: accommodations,
            realParticipantIds: realParticipantIds,
          ),
          event: guarantee.eventId != null
              ? eventById[guarantee.eventId!]
              : null,
          accommodation: guarantee.accommodationId != null
              ? accommodationById[guarantee.accommodationId!]
              : null,
          onOpenEvent: (event) => _openEvent(context, ref, event),
          onOpenAccommodation: (acc) =>
              _openAccommodation(context, ref, acc),
        );
      },
    );
  }

  Future<void> _copyExport(
    BuildContext context,
    WidgetRef ref, {
    required bool asCsv,
  }) async {
    final loc = AppLocalizations.of(context)!;
    final planId = plan.id;
    if (planId == null) return;

    final expenses =
        ref.read(planExpensesProvider(planId)).asData?.value ??
            const <PlanExpense>[];
    List<PersonalPayment> payments;
    try {
      payments = await ref
          .read(paymentsByPlanProvider(planId).future)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      payments = ref.read(paymentsByPlanProvider(planId)).asData?.value ??
          const <PersonalPayment>[];
    }
    final guarantees = payments.where((p) => p.isGuarantee).toList();
    final events =
        ref.read(planEventsStreamProvider(planId)).asData?.value ??
            const <Event>[];
    final accommodations =
        ref.read(planAccommodationsStreamProvider(planId)).asData?.value ??
            const <Accommodation>[];
    final realParticipantIds = (ref
                .read(planRealParticipantsProvider(planId))
                .asData
                ?.value ??
            const <PlanParticipation>[])
        .map((p) => p.userId)
        .toSet();
    final summary = ref.read(paymentSummaryProvider(planId)).asData?.value;
    final nameByUserId = <String, String>{
      if (summary != null)
        for (final e in summary.balancesByParticipant.entries)
          e.key: e.value.userName,
    };
    final effectiveRealIds = realParticipantIds.isNotEmpty
        ? realParticipantIds
        : nameByUserId.keys.toSet();
    final eventById = {
      for (final e in events)
        if (e.id != null && e.id!.isNotEmpty) e.id!: e,
    };
    final accommodationById = {
      for (final a in accommodations)
        if (a.id != null && a.id!.isNotEmpty) a.id!: a,
    };

    final movements = <_ListMovement>[
      for (final e in expenses) _ListMovement.expense(e),
      for (final g in guarantees) _ListMovement.guarantee(g),
    ]..sort((a, b) {
        final byDate = b.sortDate.compareTo(a.sortDate);
        if (byDate != 0) return byDate;
        return b.createdAt.compareTo(a.createdAt);
      });

    if (movements.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.paymentsExpensesExportEmpty)),
      );
      return;
    }

    final payload = asCsv
        ? _formatMovementsCsv(
            loc: loc,
            plan: plan,
            movements: movements,
            nameByUserId: nameByUserId,
            eventById: eventById,
            accommodationById: accommodationById,
            events: events,
            accommodations: accommodations,
            realParticipantIds: effectiveRealIds,
          )
        : _formatMovementsText(
            loc: loc,
            plan: plan,
            movements: movements,
            nameByUserId: nameByUserId,
            eventById: eventById,
            accommodationById: accommodationById,
            events: events,
            accommodations: accommodations,
            realParticipantIds: effectiveRealIds,
          );

    await Clipboard.setData(ClipboardData(text: payload));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.paymentsExpensesExportCopied),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  String _formatMovementsText({
    required AppLocalizations loc,
    required Plan plan,
    required List<_ListMovement> movements,
    required Map<String, String> nameByUserId,
    required Map<String, Event> eventById,
    required Map<String, Accommodation> accommodationById,
    required List<Event> events,
    required List<Accommodation> accommodations,
    required Set<String> realParticipantIds,
  }) {
    final buf = StringBuffer();
    buf.writeln('${loc.paymentsExpensesListTitle} — ${plan.name}');
    buf.writeln('Moneda: ${plan.currency}');
    buf.writeln('Total filas: ${movements.length}');
    buf.writeln('');

    for (var i = 0; i < movements.length; i++) {
      final m = movements[i];
      final row = _movementExportFields(
        loc: loc,
        movement: m,
        nameByUserId: nameByUserId,
        eventById: eventById,
        accommodationById: accommodationById,
        events: events,
        accommodations: accommodations,
        realParticipantIds: realParticipantIds,
      );
      buf.writeln('${i + 1}. [${row.type}] ${row.concept} — ${row.amount}');
      buf.writeln('   Fecha: ${row.date}');
      buf.writeln('   Pagó: ${row.payer}');
      buf.writeln('   Reparto: ${row.split}');
      if (row.splitPeople.isNotEmpty) {
        buf.writeln('   Entre: ${row.splitPeople}');
      }
      if (row.linked.isNotEmpty) {
        buf.writeln('   Vinculado: ${row.linked}');
      }
      buf.writeln('');
    }
    return buf.toString().trimRight();
  }

  String _formatMovementsCsv({
    required AppLocalizations loc,
    required Plan plan,
    required List<_ListMovement> movements,
    required Map<String, String> nameByUserId,
    required Map<String, Event> eventById,
    required Map<String, Accommodation> accommodationById,
    required List<Event> events,
    required List<Accommodation> accommodations,
    required Set<String> realParticipantIds,
  }) {
    final buf = StringBuffer();
    buf.writeln(
      _csvRow([
        'tipo',
        'fecha',
        'concepto',
        'importe',
        'moneda',
        'pagador',
        'reparto',
        'participantes',
        'vinculo',
        'plan',
      ]),
    );
    for (final m in movements) {
      final row = _movementExportFields(
        loc: loc,
        movement: m,
        nameByUserId: nameByUserId,
        eventById: eventById,
        accommodationById: accommodationById,
        events: events,
        accommodations: accommodations,
        realParticipantIds: realParticipantIds,
      );
      buf.writeln(
        _csvRow([
          row.type,
          row.date,
          row.concept,
          row.amountRaw,
          plan.currency,
          row.payer,
          row.split,
          row.splitPeople,
          row.linked,
          plan.name,
        ]),
      );
    }
    return buf.toString();
  }

  _ExportFields _movementExportFields({
    required AppLocalizations loc,
    required _ListMovement movement,
    required Map<String, String> nameByUserId,
    required Map<String, Event> eventById,
    required Map<String, Accommodation> accommodationById,
    required List<Event> events,
    required List<Accommodation> accommodations,
    required Set<String> realParticipantIds,
  }) {
    if (movement.expense != null) {
      final e = movement.expense!;
      final payer = nameByUserId[e.payerId] ?? e.payerId;
      final concept = (e.concept != null && e.concept!.trim().isNotEmpty)
          ? e.concept!.trim()
          : loc.paymentsExpenseDefaultConcept;
      final split = e.equalSplit
          ? loc.paymentsExpenseSplitSummaryEqual(e.participantIds.length)
          : loc.paymentsExpenseSplitSummaryCustom(e.participantIds.length);
      final people = e.participantIds
          .map((id) => nameByUserId[id] ?? id)
          .join(', ');
      String linked = '';
      if (e.eventId != null && e.eventId!.isNotEmpty) {
        final ev = eventById[e.eventId!];
        final t = ev?.description.trim();
        linked =
            'evento: ${(t != null && t.isNotEmpty) ? t : loc.paymentsExpenseEventFallbackTitle}';
      } else if (e.accommodationId != null && e.accommodationId!.isNotEmpty) {
        final acc = accommodationById[e.accommodationId!];
        final t = acc?.hotelName.trim();
        linked =
            'alojamiento: ${(t != null && t.isNotEmpty) ? t : loc.paymentsExpenseAccommodationFallbackTitle}';
      }
      return _ExportFields(
        type: 'gasto',
        date: DateFormat('yyyy-MM-dd').format(e.expenseDate),
        concept: concept,
        amount: CurrencyFormatterService.formatAmount(e.amount, plan.currency),
        amountRaw: e.amount.toString(),
        payer: payer,
        split: split,
        splitPeople: people,
        linked: linked,
      );
    }

    final p = movement.guarantee!;
    final payer = nameByUserId[p.participantId] ?? p.participantId;
    final concept = (p.concept != null && p.concept!.trim().isNotEmpty)
        ? p.concept!.trim()
        : loc.paymentsGuaranteeListConcept;
    final shareIds = guaranteeShareParticipantIds(
      payment: p,
      events: events,
      accommodations: accommodations,
      realParticipantIds: realParticipantIds,
    ).toList()
      ..sort();
    final people =
        shareIds.map((id) => nameByUserId[id] ?? id).join(', ');
    String linked = '';
    if (p.eventId != null && p.eventId!.isNotEmpty) {
      final ev = eventById[p.eventId!];
      final t = ev?.description.trim();
      linked =
          'evento: ${(t != null && t.isNotEmpty) ? t : loc.paymentsExpenseEventFallbackTitle}';
    } else if (p.accommodationId != null && p.accommodationId!.isNotEmpty) {
      final acc = accommodationById[p.accommodationId!];
      final hotelName = acc?.hotelName.trim();
      linked =
          'alojamiento: ${(hotelName != null && hotelName.isNotEmpty) ? hotelName : loc.paymentsExpenseAccommodationFallbackTitle}';
    }
    return _ExportFields(
      type: 'garantia',
      date: DateFormat('yyyy-MM-dd').format(p.paymentDate),
      concept: concept,
      amount: CurrencyFormatterService.formatAmount(p.amount, plan.currency),
      amountRaw: p.amount.toString(),
      payer: payer,
      split: loc.paymentsGuaranteeSplitLabel(shareIds.length),
      splitPeople: people,
      linked: linked,
    );
  }

  String _csvRow(List<String> cells) {
    return cells.map(_csvEscape).join(',');
  }

  String _csvEscape(String value) {
    final needsQuotes = value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    final escaped = value.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }

  Future<void> _openAddExpense(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> nameByUserId, {
    PlanExpense? existing,
  }) async {
    final planId = plan.id;
    if (planId == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => AddExpenseDialog(
          plan: plan,
          userIdToName: nameByUserId,
          existingExpense: existing,
          onSaved: () {
            ref.invalidate(paymentSummaryProvider(planId));
            ref.invalidate(planExpensesProvider(planId));
            ref.invalidate(paymentsByPlanProvider(planId));
          },
        ),
      ),
    );
  }

  Future<void> _openEvent(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    final planId = plan.id;
    if (planId == null) return;
    final eventService = ref.read(eventServiceProvider);
    Event toShow = event;
    if (event.id != null) {
      final fresh = await eventService.getEventByIdFromServer(event.id!) ??
          await eventService.getEventById(event.id!);
      if (fresh != null) toShow = fresh;
    }
    if (!context.mounted) return;
    await showEventFormDialog<void>(
      context: context,
      barrierDismissible: false,
      dialog: EventDialog(
        event: toShow,
        planId: planId,
        onSaved: (updated) async {
          final ok = await eventService.updateEvent(updated);
          if (!ok) throw Exception('updateEvent failed');
          ref.invalidate(planEventsStreamProvider(planId));
          ref.invalidate(paymentSummaryProvider(planId));
          if (context.mounted) Navigator.of(context).pop();
        },
        onDeleted: (id) async {
          await eventService.deleteEvent(id);
          ref.invalidate(planEventsStreamProvider(planId));
          ref.invalidate(paymentSummaryProvider(planId));
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _openAccommodation(
    BuildContext context,
    WidgetRef ref,
    Accommodation accommodation,
  ) async {
    final planId = plan.id;
    if (planId == null) return;
    final accommodationService = ref.read(accommodationServiceProvider);
    await showAccommodationFormDialog<void>(
      context: context,
      barrierDismissible: false,
      dialog: AccommodationDialog(
        accommodation: accommodation,
        planId: planId,
        planStartDate: plan.startDate,
        planEndDate: plan.endDate,
        onSaved: (updated) async {
          await accommodationService.updateAccommodation(updated);
          ref.invalidate(planAccommodationsStreamProvider(planId));
          ref.invalidate(paymentSummaryProvider(planId));
          if (context.mounted) Navigator.of(context).pop();
        },
        onDeleted: (id) async {
          await accommodationService.deleteAccommodation(id);
          ref.invalidate(planAccommodationsStreamProvider(planId));
          ref.invalidate(paymentSummaryProvider(planId));
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _ExpenseListCard extends ConsumerWidget {
  const _ExpenseListCard({
    required this.plan,
    required this.expense,
    required this.nameByUserId,
    required this.event,
    required this.accommodation,
    required this.onOpenEvent,
    required this.onOpenAccommodation,
    required this.onEdit,
    required this.onDeleted,
  });

  final Plan plan;
  final PlanExpense expense;
  final Map<String, String> nameByUserId;
  final Event? event;
  final Accommodation? accommodation;
  final ValueChanged<Event> onOpenEvent;
  final ValueChanged<Accommodation> onOpenAccommodation;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currency = plan.currency;
    final payerName =
        nameByUserId[expense.payerId] ?? expense.payerId;
    final dateStr = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .format(expense.expenseDate);
    final concept = (expense.concept != null && expense.concept!.trim().isNotEmpty)
        ? expense.concept!.trim()
        : loc.paymentsExpenseDefaultConcept;
    final splitLabel = expense.equalSplit
        ? loc.paymentsExpenseSplitSummaryEqual(expense.participantIds.length)
        : loc.paymentsExpenseSplitSummaryCustom(expense.participantIds.length);
    final splitNames = expense.participantIds
        .map((id) => nameByUserId[id] ?? id)
        .join(', ');
    final currentUser = ref.watch(currentUserProvider);
    final canManage = _canManage(plan, expense, currentUser?.id);

    String? linkedLabel;
    VoidCallback? onOpenLinked;
    if (event != null) {
      final t = event!.description.trim();
      linkedLabel = t.isNotEmpty ? t : loc.paymentsExpenseEventFallbackTitle;
      onOpenLinked = () => onOpenEvent(event!);
    } else if (accommodation != null) {
      final t = accommodation!.hotelName.trim();
      linkedLabel =
          t.isNotEmpty ? t : loc.paymentsExpenseAccommodationFallbackTitle;
      onOpenLinked = () => onOpenAccommodation(accommodation!);
    } else if (expense.eventId != null && expense.eventId!.isNotEmpty) {
      linkedLabel = loc.paymentsExpenseUnknownLinkedEvent;
    } else if (expense.accommodationId != null &&
        expense.accommodationId!.isNotEmpty) {
      linkedLabel = loc.paymentsExpenseUnknownLinkedAccommodation;
    }

    return Material(
      color: PaymentExpensesListPage._surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: canManage ? onEdit : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      concept,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatterService.formatAmount(
                      expense.amount,
                      currency,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.greenAccent.shade200,
                    ),
                  ),
                  if (canManage)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,
                          color: Colors.white54, size: 20),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          onEdit();
                          return;
                        }
                        if (value == 'delete') {
                          final confirmed = await IosFormConfirmSheet.show(
                            context: context,
                            title: loc.paymentsExpenseDeleteConfirmTitle,
                            message: loc.paymentsExpenseDeleteConfirmBody,
                            cancelLabel: loc.cancel,
                            confirmLabel: loc.delete,
                            destructive: true,
                          );
                          if (confirmed != true || !context.mounted) return;
                          final ok = await ref
                              .read(expenseServiceProvider)
                              .deleteExpense(expense.id!);
                          if (!context.mounted) return;
                          if (ok) {
                            onDeleted();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loc.paymentsExpenseDeleted),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loc.paymentsExpenseDeleteError),
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(loc.paymentsEditExpense),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(loc.delete),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                loc.paymentsExpenseRowMeta(dateStr, payerName),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                splitLabel,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (splitNames.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  splitNames,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (linkedLabel != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: onOpenLinked != null
                      ? ActionChip(
                          avatar: Icon(
                            event != null
                                ? Icons.event_outlined
                                : Icons.hotel_outlined,
                            size: 16,
                            color: AppColorScheme.color2,
                          ),
                          label: Text(
                            linkedLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.06),
                          side: BorderSide(
                            color: AppColorScheme.color2.withValues(alpha: 0.5),
                          ),
                          onPressed: onOpenLinked,
                        )
                      : Text(
                          '· $linkedLabel',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColorScheme.color3,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _canManage(Plan plan, PlanExpense expense, String? currentUserId) {
    if (currentUserId == null || expense.id == null) return false;
    if (plan.userId == currentUserId) return true;
    if (expense.payerId == currentUserId) return true;
    if (expense.registeredBy != null &&
        expense.registeredBy == currentUserId) {
      return true;
    }
    return false;
  }
}


class _ListMovement {
  const _ListMovement._({
    required this.sortDate,
    required this.createdAt,
    this.expense,
    this.guarantee,
  });

  factory _ListMovement.expense(PlanExpense expense) => _ListMovement._(
        sortDate: expense.expenseDate,
        createdAt: expense.createdAt,
        expense: expense,
      );

  factory _ListMovement.guarantee(PersonalPayment payment) => _ListMovement._(
        sortDate: payment.paymentDate,
        createdAt: payment.createdAt,
        guarantee: payment,
      );

  final DateTime sortDate;
  final DateTime createdAt;
  final PlanExpense? expense;
  final PersonalPayment? guarantee;
}

class _ExportFields {
  const _ExportFields({
    required this.type,
    required this.date,
    required this.concept,
    required this.amount,
    required this.amountRaw,
    required this.payer,
    required this.split,
    required this.splitPeople,
    required this.linked,
  });

  final String type;
  final String date;
  final String concept;
  final String amount;
  final String amountRaw;
  final String payer;
  final String split;
  final String splitPeople;
  final String linked;
}

class _GuaranteeListCard extends StatelessWidget {
  const _GuaranteeListCard({
    required this.plan,
    required this.payment,
    required this.nameByUserId,
    required this.shareParticipantIds,
    required this.event,
    required this.accommodation,
    required this.onOpenEvent,
    required this.onOpenAccommodation,
  });

  final Plan plan;
  final PersonalPayment payment;
  final Map<String, String> nameByUserId;
  final Set<String> shareParticipantIds;
  final Event? event;
  final Accommodation? accommodation;
  final ValueChanged<Event> onOpenEvent;
  final ValueChanged<Accommodation> onOpenAccommodation;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currency = plan.currency;
    final payerName =
        nameByUserId[payment.participantId] ?? payment.participantId;
    final dateStr = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .format(payment.paymentDate);
    final shareIds = shareParticipantIds.toList()..sort();
    final splitNames =
        shareIds.map((id) => nameByUserId[id] ?? id).join(', ');

    String? linkedLabel;
    VoidCallback? onOpenLinked;
    IconData linkedIcon = Icons.event_outlined;
    if (event != null) {
      final t = event!.description.trim();
      linkedLabel = t.isNotEmpty ? t : loc.paymentsExpenseEventFallbackTitle;
      onOpenLinked = () => onOpenEvent(event!);
      linkedIcon = Icons.event_outlined;
    } else if (accommodation != null) {
      final t = accommodation!.hotelName.trim();
      linkedLabel =
          t.isNotEmpty ? t : loc.paymentsExpenseAccommodationFallbackTitle;
      onOpenLinked = () => onOpenAccommodation(accommodation!);
      linkedIcon = Icons.hotel_outlined;
    } else if (payment.eventId != null && payment.eventId!.isNotEmpty) {
      linkedLabel = loc.paymentsExpenseUnknownLinkedEvent;
    } else if (payment.accommodationId != null &&
        payment.accommodationId!.isNotEmpty) {
      linkedLabel = loc.paymentsExpenseUnknownLinkedAccommodation;
      linkedIcon = Icons.hotel_outlined;
    }

    var title = (payment.concept != null && payment.concept!.trim().isNotEmpty)
        ? payment.concept!.trim()
        : '';
    for (final prefix in <String>[
      '${loc.reservationGuaranteeLabel}:',
      'Garantía:',
      'Guarantee:',
    ]) {
      if (title.toLowerCase().startsWith(prefix.toLowerCase())) {
        title = title.substring(prefix.length).trim();
        break;
      }
    }
    if (title.isEmpty) {
      title = linkedLabel ?? loc.paymentsGuaranteeListConcept;
    }
    final chipLabel =
        (linkedLabel != null &&
                linkedLabel.trim().toLowerCase() != title.trim().toLowerCase())
            ? linkedLabel
            : null;

    return Material(
      color: PaymentExpensesListPage._surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpenLinked,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColorScheme.color2.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      loc.reservationGuaranteeLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColorScheme.color2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatterService.formatAmount(
                      payment.amount,
                      currency,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.greenAccent.shade200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dateStr,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              Text(
                payerName,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.paymentsGuaranteeSplitLabel(shareIds.length),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (splitNames.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  splitNames,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
              if (chipLabel != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: onOpenLinked != null
                      ? ActionChip(
                          avatar: Icon(
                            linkedIcon,
                            size: 16,
                            color: AppColorScheme.color2,
                          ),
                          label: Text(
                            chipLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.06),
                          side: BorderSide(
                            color: AppColorScheme.color2.withValues(alpha: 0.5),
                          ),
                          onPressed: onOpenLinked,
                        )
                      : Text(
                          '· $chipLabel',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColorScheme.color3,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
