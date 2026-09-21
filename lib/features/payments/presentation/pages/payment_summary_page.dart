import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/calendar/domain/models/event.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan_participation.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/accommodation_providers.dart';
import 'package:unp_calendario/features/calendar/presentation/providers/plan_participation_providers.dart';
import '../../domain/models/payment_summary.dart';
import '../../domain/models/personal_payment.dart';
import '../../domain/models/plan_expense.dart';
import '../../domain/services/balance_service.dart';
import '../providers/payment_providers.dart';
import 'package:unp_calendario/features/calendar/domain/models/accommodation.dart';
import 'package:unp_calendario/shared/services/currency_formatter_service.dart';
import 'package:unp_calendario/features/payments/presentation/pages/payment_expenses_list_page.dart';
import 'package:unp_calendario/features/payments/presentation/widgets/add_expense_dialog.dart';
import 'package:unp_calendario/features/auth/presentation/providers/auth_providers.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/widgets/common/ios_grouped_form.dart';
import 'package:unp_calendario/widgets/wd_accommodation_dialog.dart';
import 'package:unp_calendario/widgets/wd_event_dialog.dart';

/// T102: Página de resumen de pagos y balances del plan
class PaymentSummaryPage extends ConsumerWidget {
  final Plan plan;
  /// En [PlanDetailPage] evita la flecha del AppBar que hace pop de todo el detalle (P16).
  final bool embedInPlanDetail;

  const PaymentSummaryPage({
    super.key,
    required this.plan,
    this.embedInPlanDetail = false,
  });

  static const Color _cPageBg = Color(0xFF111827);
  static const Color _cSurfaceBg = Color(0xFF1F2937);
  static const Color _cTextPrimary = Colors.white;
  static const Color _cTextSecondary = Colors.white70;
  static const Color _cTextTertiary = Colors.white60;
  static const Color _cDanger = Colors.redAccent;
  static const double _aBorderStrong = 0.12;
  static const double _aBorderSubtle = 0.08;
  static const double _aSurfaceMuted = 0.04;
  static const double _aSurfaceChip = 0.06;
  static const double _aAccentSelected = 0.32;

  static const double _fsAppBar = 16;
  static const double _fsSectionSubtitle = 11;
  static const double _fsValue = 13;
  static const double _sp12 = 12;
  static const double _sp16 = 16;

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: _cSurfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cTextPrimary.withValues(alpha: _aBorderStrong)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(paymentSummaryProvider(plan.id!));
    final balanceService = ref.watch(balanceServiceProvider);

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: _cPageBg,
        appBar: embedInPlanDetail ? null : AppBar(
          automaticallyImplyLeading: true,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            loc.paymentsSummaryTitle,
            style: GoogleFonts.poppins(
              fontSize: _fsAppBar,
              fontWeight: FontWeight.w600,
              color: _cTextPrimary,
            ),
          ),
          backgroundColor: _cPageBg,
          foregroundColor: _cTextPrimary,
          iconTheme: const IconThemeData(color: _cTextPrimary),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline, color: AppColorScheme.color3),
              tooltip: loc.paymentsDisclaimerText,
              onPressed: () => _showDisclaimerDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: loc.paymentsAddExpense,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (ctx) => AddExpenseDialog(
                      plan: plan,
                      onSaved: () =>
                          ref.invalidate(paymentSummaryProvider(plan.id!)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: summaryAsync.when(
            data: (summary) {
              final transferSuggestions = balanceService.calculateTransferSuggestions(summary);
              return _buildSummaryContent(context, ref, summary, transferSuggestions);
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColorScheme.color2),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: _cDanger),
                    const SizedBox(height: 16),
                    Text(
                      loc.paymentsSummaryError,
                      style: GoogleFonts.poppins(
                        fontSize: _fsAppBar,
                        fontWeight: FontWeight.w600,
                        color: _cDanger,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _cTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryContent(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary,
    List<TransferSuggestion> transferSuggestions,
  ) {
    final loc = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(_sp12, 8, _sp12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGeneralSummary(context, summary),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final tabController = DefaultTabController.of(context);
                    return ListenableBuilder(
                      listenable: tabController,
                      builder: (context, _) {
                        return IosSegmentedControl(
                          labels: [
                            loc.paymentsActivityTitle,
                            loc.paymentsTabBalances,
                            loc.paymentsTabTransfers,
                          ],
                          selectedIndex: tabController.index,
                          fontSize: 12,
                          onChanged: tabController.animateTo,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(_sp12, 0, _sp12, _sp16),
                  children: [
                    _buildActivitySection(
                      context,
                      ref,
                      summary,
                      hideTitle: true,
                    ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.fromLTRB(_sp12, 0, _sp12, _sp16),
                  children: [
                    _buildBalancesSection(
                      context,
                      ref,
                      summary,
                      hideTitle: true,
                    ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.fromLTRB(_sp12, 0, _sp12, _sp16),
                  children: [
                    _buildTransferSuggestionsSection(
                      context,
                      transferSuggestions,
                      hideTitle: true,
                    ),
                    const SizedBox(height: 16),
                    _buildSettlementExportLink(
                      context,
                      ref,
                      summary,
                      transferSuggestions,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cSurfaceBg,
        title: Text(
          loc.paymentsSummaryTitle,
          style: GoogleFonts.poppins(
            color: _cTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: Text(
          loc.paymentsDisclaimerText,
          style: GoogleFonts.poppins(
            color: _cTextSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementExportLink(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary,
    List<TransferSuggestion> transferSuggestions,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: _cTextTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: () => _copySettlementReport(
          context,
          ref,
          summary,
          transferSuggestions,
        ),
        icon: const Icon(Icons.copy_all_outlined, size: 16),
        label: Text(
          loc.paymentsSettlementExportButton,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
    );
  }

  Future<void> _copySettlementReport(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary,
    List<TransferSuggestion> transferSuggestions,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final planId = plan.id;
    if (planId == null) return;
    final currency = plan.currency;

    final expenses =
        ref.read(planExpensesProvider(planId)).asData?.value ??
            const <PlanExpense>[];
    // El resumen no observa paymentsByPlanProvider; hay que esperar el stream
    // o el export omite garantías aunque ya estén en los balances.
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
    // Si el stream de participantes aún no está listo, usar los del resumen.
    final effectiveRealIds = realParticipantIds.isNotEmpty
        ? realParticipantIds
        : summary.balancesByParticipant.keys.toSet();
    final nameByUserId = {
      for (final e in summary.balancesByParticipant.entries)
        e.key: e.value.userName,
    };
    final eventById = {
      for (final e in events)
        if (e.id != null && e.id!.isNotEmpty) e.id!: e,
    };
    final accommodationById = {
      for (final a in accommodations)
        if (a.id != null && a.id!.isNotEmpty) a.id!: a,
    };

    final movements = <({DateTime d, DateTime c, PlanExpense? e, PersonalPayment? g})>[
      for (final e in expenses) (d: e.expenseDate, c: e.createdAt, e: e, g: null),
      for (final g in guarantees)
        (d: g.paymentDate, c: g.createdAt, e: null, g: g),
    ]..sort((a, b) {
        final byDate = b.d.compareTo(a.d);
        if (byDate != 0) return byDate;
        return b.c.compareTo(a.c);
      });

    final buf = StringBuffer();
    buf.writeln('=== CUADRE DE PAGOS ===');
    buf.writeln('Plan: ${plan.name}');
    buf.writeln('Moneda: $currency');
    buf.writeln('');
    buf.writeln('--- RESUMEN ---');
    buf.writeln(
      'Coste total: ${CurrencyFormatterService.formatAmount(summary.totalCost, currency)}',
    );
    buf.writeln(
      'Total pagado: ${CurrencyFormatterService.formatAmount(summary.totalPaid, currency)}',
    );
    final net = summary.totalPaid - summary.totalCost;
    buf.writeln(
      'Diferencia (pagado - coste): ${CurrencyFormatterService.formatAmount(net, currency)}',
    );
    buf.writeln(
      'Suma balances participantes: ${CurrencyFormatterService.formatAmount(summary.balancesByParticipant.values.fold<double>(0, (s, b) => s + b.balance), currency)}',
    );
    buf.writeln('');

    buf.writeln('--- MOVIMIENTOS (${movements.length}) ---');
    if (movements.isEmpty) {
      buf.writeln('(ninguno)');
    } else {
      for (var i = 0; i < movements.length; i++) {
        final m = movements[i];
        if (m.e != null) {
          final e = m.e!;
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
          } else if (e.accommodationId != null &&
              e.accommodationId!.isNotEmpty) {
            final acc = accommodationById[e.accommodationId!];
            final t = acc?.hotelName.trim();
            linked =
                'alojamiento: ${(t != null && t.isNotEmpty) ? t : loc.paymentsExpenseAccommodationFallbackTitle}';
          }
          buf.writeln(
            '${i + 1}. [gasto] $concept — ${CurrencyFormatterService.formatAmount(e.amount, currency)}',
          );
          buf.writeln('   Fecha: ${DateFormat('yyyy-MM-dd').format(e.expenseDate)}');
          buf.writeln('   Pagó: $payer');
          buf.writeln('   Reparto: $split');
          buf.writeln('   Entre: $people');
          if (linked.isNotEmpty) buf.writeln('   Vinculado: $linked');
        } else {
          final p = m.g!;
          final payer = nameByUserId[p.participantId] ?? p.participantId;
          final concept =
              (p.concept != null && p.concept!.trim().isNotEmpty)
                  ? p.concept!.trim()
                  : loc.paymentsGuaranteeListConcept;
          final shareIds = guaranteeShareParticipantIds(
            payment: p,
            events: events,
            accommodations: accommodations,
            realParticipantIds: effectiveRealIds,
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
          } else if (p.accommodationId != null &&
              p.accommodationId!.isNotEmpty) {
            final acc = accommodationById[p.accommodationId!];
            final t = acc?.hotelName.trim();
            linked =
                'alojamiento: ${(t != null && t.isNotEmpty) ? t : loc.paymentsExpenseAccommodationFallbackTitle}';
          }
          buf.writeln(
            '${i + 1}. [garantia] $concept — ${CurrencyFormatterService.formatAmount(p.amount, currency)}',
          );
          buf.writeln('   Fecha: ${DateFormat('yyyy-MM-dd').format(p.paymentDate)}');
          buf.writeln('   Pagó: $payer');
          buf.writeln(
            '   Reparto: ${loc.paymentsGuaranteeSplitLabel(shareIds.length)}',
          );
          if (people.isNotEmpty) buf.writeln('   Entre: $people');
          if (linked.isNotEmpty) buf.writeln('   Vinculado: $linked');
        }
        buf.writeln('');
      }
    }

    buf.writeln('--- BALANCES POR PARTICIPANTE ---');
    final balances = summary.balancesByParticipant.values.toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
    for (final b in balances) {
      buf.writeln(
        '${b.userName}: coste=${CurrencyFormatterService.formatAmount(b.totalCost, currency)} pagado=${CurrencyFormatterService.formatAmount(b.totalPaid, currency)} saldo=${CurrencyFormatterService.formatAmount(b.balance, currency)}',
      );
      for (final pay in b.payments) {
        final label = pay.concept ??
            pay.eventDescription ??
            'Sin concepto';
        buf.writeln(
          '   - ${CurrencyFormatterService.formatAmount(pay.amount, currency)} · $label · ${DateFormat('yyyy-MM-dd').format(pay.paymentDate)}',
        );
      }
    }
    buf.writeln('');

    buf.writeln('--- SUGERENCIAS DE TRANSFERENCIA ---');
    if (transferSuggestions.isEmpty) {
      buf.writeln(loc.paymentsSettlementExportNoTransfers);
    } else {
      for (final s in transferSuggestions) {
        buf.writeln(
          '${s.fromUserName} → ${s.toUserName}: ${CurrencyFormatterService.formatAmount(s.amount, currency)}',
        );
      }
      final transferSum = transferSuggestions.fold<double>(
        0,
        (sum, s) => sum + s.amount,
      );
      buf.writeln(
        'Suma transferencias: ${CurrencyFormatterService.formatAmount(transferSum, currency)}',
      );
    }

    await Clipboard.setData(ClipboardData(text: buf.toString().trimRight()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.paymentsSettlementExportCopied),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  Widget _buildGeneralSummary(BuildContext context, PaymentSummary summary) {
    final planCurrency = plan.currency;
    final loc = AppLocalizations.of(context)!;
    // Evitar -£0.00 por ruido de coma flotante
    final rawBalance = summary.totalPaid - summary.totalCost;
    final totalBalance = rawBalance.abs() < 0.005 ? 0.0 : rawBalance;
    final balanceColor = _getBalanceColor(totalBalance);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactStat(
              loc.paymentsGeneralSummaryTotalCost,
              CurrencyFormatterService.formatAmount(
                  summary.totalCost, planCurrency),
              AppColorScheme.color2,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: _cTextPrimary.withValues(alpha: _aBorderSubtle),
          ),
          Expanded(
            child: _buildCompactStat(
              loc.paymentsGeneralSummaryTotalPaid,
              CurrencyFormatterService.formatAmount(
                  summary.totalPaid, planCurrency),
              Colors.green.shade400,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: _cTextPrimary.withValues(alpha: _aBorderSubtle),
          ),
          Expanded(
            child: _buildCompactStat(
              loc.paymentsGeneralSummaryBalanceTitle,
              CurrencyFormatterService.formatAmount(
                  totalBalance, planCurrency),
              balanceColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: _cTextTertiary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary, {
    bool hideTitle = false,
  }) {
    final loc = AppLocalizations.of(context)!;
    final planCurrency = plan.currency;
    final expensesAsync = ref.watch(planExpensesProvider(plan.id!));
    final paymentsAsync = ref.watch(paymentsByPlanProvider(plan.id!));
    final eventsAsync = ref.watch(planEventsStreamProvider(plan.id!));
    final accommodationsAsync =
        ref.watch(planAccommodationsStreamProvider(plan.id!));

    return expensesAsync.when(
      data: (expenses) {
        final guarantees = (paymentsAsync.asData?.value ??
                const <PersonalPayment>[])
            .where((p) => p.isGuarantee)
            .toList();
        return eventsAsync.when(
          data: (planEvents) {
            return accommodationsAsync.when(
              data: (accommodations) {
                final eventTitles = <String, String>{};
                for (final ev in planEvents) {
                  final id = ev.id;
                  if (id == null || id.isEmpty) continue;
                  final t = ev.description.trim();
                  eventTitles[id] = t.isNotEmpty
                      ? t
                      : loc.paymentsExpenseEventFallbackTitle;
                }
                final accommodationTitles = <String, String>{};
                for (final acc in accommodations) {
                  final id = acc.id;
                  if (id == null || id.isEmpty) continue;
                  final t = acc.hotelName.trim();
                  accommodationTitles[id] = t.isNotEmpty
                      ? t
                      : loc.paymentsExpenseAccommodationFallbackTitle;
                }
                return _buildActivityExpenseCard(
                  context,
                  ref,
                  summary,
                  expenses,
                  guarantees,
                  planCurrency,
                  eventTitles,
                  accommodationTitles,
                  {
                    for (final e in planEvents)
                      if (e.id != null && e.id!.isNotEmpty) e.id!: e,
                  },
                  {
                    for (final a in accommodations)
                      if (a.id != null && a.id!.isNotEmpty) a.id!: a,
                  },
                  loc,
                  hideTitle: hideTitle,
                );
              },
              loading: () => _buildActivityExpenseCard(
                context,
                ref,
                summary,
                expenses,
                guarantees,
                planCurrency,
                _eventTitlesFromEvents(planEvents, loc),
                const {},
                {
                  for (final e in planEvents)
                    if (e.id != null && e.id!.isNotEmpty) e.id!: e,
                },
                const {},
                loc,
                hideTitle: hideTitle,
              ),
              error: (_, __) => _buildActivityExpenseCard(
                context,
                ref,
                summary,
                expenses,
                guarantees,
                planCurrency,
                _eventTitlesFromEvents(planEvents, loc),
                const {},
                {
                  for (final e in planEvents)
                    if (e.id != null && e.id!.isNotEmpty) e.id!: e,
                },
                const {},
                loc,
                hideTitle: hideTitle,
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Map<String, String> _eventTitlesFromEvents(
    List<Event> planEvents,
    AppLocalizations loc,
  ) {
    final eventTitles = <String, String>{};
    for (final ev in planEvents) {
      final id = ev.id;
      if (id == null || id.isEmpty) continue;
      final t = ev.description.trim();
      eventTitles[id] =
          t.isNotEmpty ? t : loc.paymentsExpenseEventFallbackTitle;
    }
    return eventTitles;
  }

  Widget _buildActivityExpenseCard(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary,
    List<PlanExpense> expenses,
    List<PersonalPayment> guarantees,
    String planCurrency,
    Map<String, String> eventTitles,
    Map<String, String> accommodationTitles,
    Map<String, Event> eventById,
    Map<String, Accommodation> accommodationById,
    AppLocalizations loc, {
    bool hideTitle = false,
  }) {
    final userIdToName = {
      for (final e in summary.balancesByParticipant.entries)
        e.key: e.value.userName
    };
    final movements = <({DateTime d, DateTime c, PlanExpense? e, PersonalPayment? g})>[
      for (final e in expenses)
        (d: e.expenseDate, c: e.createdAt, e: e, g: null),
      for (final g in guarantees)
        (d: g.paymentDate, c: g.createdAt, e: null, g: g),
    ]..sort((a, b) {
        final byDate = b.d.compareTo(a.d);
        if (byDate != 0) return byDate;
        return b.c.compareTo(a.c);
      });

    final addButton = TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: AppColorScheme.color2,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(Icons.add, size: 18),
      label: Text(loc.paymentsAddExpense),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (ctx) => AddExpenseDialog(
              plan: plan,
              userIdToName: userIdToName,
              onSaved: () =>
                  ref.invalidate(paymentSummaryProvider(plan.id!)),
            ),
          ),
        );
      },
    );

    final listLink = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: _cTextSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
      onPressed: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute<void>(
            builder: (_) => PaymentExpensesListPage(plan: plan),
          ),
        )
            .then((_) {
          ref.invalidate(paymentSummaryProvider(plan.id!));
        });
      },
      child: Text(
        loc.paymentsExpensesListButton,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 6, 4),
            child: Row(
              children: [
                if (!hideTitle)
                  Expanded(
                    child: Text(
                      loc.paymentsActivityTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  listLink,
                if (!hideTitle) listLink,
                if (hideTitle) const Spacer(),
                addButton,
              ],
            ),
          ),
          if (movements.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
              child: Text(
                loc.paymentsActivityEmpty,
                style: GoogleFonts.poppins(
                  fontSize: _fsValue,
                  color: _cTextSecondary,
                ),
              ),
            )
          else
            for (var i = 0; i < movements.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 58,
                  color: _cTextPrimary.withValues(alpha: _aBorderSubtle),
                ),
              if (movements[i].e != null)
                _buildActivityExpenseRow(
                  context,
                  ref,
                  plan,
                  movements[i].e!,
                  summary,
                  planCurrency,
                  eventTitles,
                  accommodationTitles,
                  loc,
                  userIdToName,
                )
              else
                _buildActivityGuaranteeRow(
                  context,
                  ref,
                  movements[i].g!,
                  summary,
                  planCurrency,
                  eventTitles,
                  accommodationTitles,
                  eventById,
                  accommodationById,
                  loc,
                ),
            ],
        ],
      ),
    );
  }

  Widget _activityLeadingIcon({
    required IconData icon,
    required Color accent,
    bool emphasize = false,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: emphasize ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(10),
        border: emphasize
            ? Border.all(color: accent.withValues(alpha: 0.45))
            : null,
      ),
      child: Icon(icon, size: 18, color: accent),
    );
  }

  Widget _activityLinkChip({
    required String label,
    required IconData icon,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _cTextPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _cTextPrimary.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: _cTextSecondary),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _cTextSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _guaranteeDisplayTitle(
    PersonalPayment payment,
    String? linkedLabel,
    AppLocalizations loc,
  ) {
    var concept = (payment.concept != null && payment.concept!.trim().isNotEmpty)
        ? payment.concept!.trim()
        : '';
    final prefixes = <String>[
      '${loc.reservationGuaranteeLabel}:',
      'Garantía:',
      'Guarantee:',
    ];
    for (final prefix in prefixes) {
      if (concept.toLowerCase().startsWith(prefix.toLowerCase())) {
        concept = concept.substring(prefix.length).trim();
        break;
      }
    }
    if (concept.isNotEmpty) return concept;
    if (linkedLabel != null && linkedLabel.isNotEmpty) return linkedLabel;
    return loc.paymentsGuaranteeListConcept;
  }

  Widget _buildActivityGuaranteeRow(
    BuildContext context,
    WidgetRef ref,
    PersonalPayment payment,
    PaymentSummary summary,
    String planCurrency,
    Map<String, String> eventTitles,
    Map<String, String> accommodationTitles,
    Map<String, Event> eventById,
    Map<String, Accommodation> accommodationById,
    AppLocalizations loc,
  ) {
    final payerName =
        summary.balancesByParticipant[payment.participantId]?.userName ??
            payment.participantId;
    final dateStr = DateFormat('dd/MM/yyyy').format(payment.paymentDate);

    String? linkedLabel;
    var linkIcon = Icons.event_outlined;
    Event? linkedEvent;
    Accommodation? linkedAccommodation;
    if (payment.eventId != null && payment.eventId!.isNotEmpty) {
      linkedLabel =
          eventTitles[payment.eventId!] ?? loc.paymentsExpenseUnknownLinkedEvent;
      linkedEvent = eventById[payment.eventId!];
      linkIcon = Icons.event_outlined;
    } else if (payment.accommodationId != null &&
        payment.accommodationId!.isNotEmpty) {
      linkedLabel = accommodationTitles[payment.accommodationId!] ??
          loc.paymentsExpenseUnknownLinkedAccommodation;
      linkedAccommodation = accommodationById[payment.accommodationId!];
      linkIcon = Icons.hotel_outlined;
    }

    final title = _guaranteeDisplayTitle(payment, linkedLabel, loc);
    final linkForChip =
        (linkedLabel != null &&
                linkedLabel.trim().toLowerCase() != title.trim().toLowerCase())
            ? linkedLabel
            : null;
    final canOpen = linkedEvent != null || linkedAccommodation != null;

    return Container(
      color: AppColorScheme.color2.withValues(alpha: 0.06),
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _activityLeadingIcon(
            icon: Icons.verified_user_outlined,
            accent: AppColorScheme.color2,
            emphasize: true,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColorScheme.color2.withValues(alpha: 0.25),
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
                          fontSize: 14,
                          color: _cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _cTextTertiary,
                  ),
                ),
                Text(
                  payerName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _cTextTertiary,
                  ),
                ),
                if (linkForChip != null)
                  _activityLinkChip(label: linkForChip, icon: linkIcon),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              CurrencyFormatterService.formatAmount(
                  payment.amount, planCurrency),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.greenAccent.shade200,
              ),
            ),
          ),
          if (canOpen)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: _cTextTertiary, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onSelected: (value) async {
                final ev = linkedEvent;
                final acc = linkedAccommodation;
                if (value == 'open_event' && ev != null) {
                  await _openLinkedEvent(context, ref, ev);
                } else if (value == 'open_acc' && acc != null) {
                  await _openLinkedAccommodation(context, ref, acc);
                }
              },
              itemBuilder: (ctx) => [
                if (linkedEvent != null)
                  PopupMenuItem<String>(
                    value: 'open_event',
                    child: Text(loc.paymentsOpenLinkedEvent),
                  ),
                if (linkedAccommodation != null)
                  PopupMenuItem<String>(
                    value: 'open_acc',
                    child: Text(loc.paymentsOpenLinkedAccommodation),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _openLinkedEvent(
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
          ref.invalidate(paymentsByPlanProvider(planId));
          if (context.mounted) Navigator.of(context).pop();
        },
        onDeleted: (id) async {
          await eventService.deleteEvent(id);
          ref.invalidate(planEventsStreamProvider(planId));
          ref.invalidate(paymentSummaryProvider(planId));
          ref.invalidate(paymentsByPlanProvider(planId));
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _openLinkedAccommodation(
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
          final ok = await accommodationService.updateAccommodation(updated);
          if (!ok) throw Exception('updateAccommodation failed');
          ref.invalidate(planAccommodationsStreamProvider(planId));
          ref.invalidate(paymentSummaryProvider(planId));
          ref.invalidate(paymentsByPlanProvider(planId));
          if (context.mounted) Navigator.of(context).pop();
        },
        onDeleted: (id) async {
          await accommodationService.deleteAccommodation(id);
          ref.invalidate(planAccommodationsStreamProvider(planId));
          ref.invalidate(paymentSummaryProvider(planId));
          ref.invalidate(paymentsByPlanProvider(planId));
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildActivityExpenseRow(
    BuildContext context,
    WidgetRef ref,
    Plan plan,
    PlanExpense expense,
    PaymentSummary summary,
    String planCurrency,
    Map<String, String> eventTitles,
    Map<String, String> accommodationTitles,
    AppLocalizations loc,
    Map<String, String> userIdToName,
  ) {
    final payerName =
        summary.balancesByParticipant[expense.payerId]?.userName ?? expense.payerId;
    final currentUser = ref.watch(currentUserProvider);
    final canManage = _canManagePlanExpense(plan, expense, currentUser?.id);
    final dateStr = DateFormat('dd/MM/yyyy').format(expense.expenseDate);
    final concept = expense.concept?.isNotEmpty == true
        ? expense.concept!
        : loc.paymentsExpenseDefaultConcept;

    String? linkedLabel;
    var linkIcon = Icons.event_outlined;
    if (expense.eventId != null && expense.eventId!.isNotEmpty) {
      linkedLabel = eventTitles[expense.eventId!] ??
          loc.paymentsExpenseUnknownLinkedEvent;
      linkIcon = Icons.event_outlined;
    } else if (expense.accommodationId != null &&
        expense.accommodationId!.isNotEmpty) {
      linkedLabel = accommodationTitles[expense.accommodationId!] ??
          loc.paymentsExpenseUnknownLinkedAccommodation;
      linkIcon = Icons.hotel_outlined;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _activityLeadingIcon(
            icon: Icons.receipt_long_outlined,
            accent: _cTextSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concept,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _cTextTertiary,
                  ),
                ),
                Text(
                  payerName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _cTextTertiary,
                  ),
                ),
                if (linkedLabel != null)
                  _activityLinkChip(label: linkedLabel, icon: linkIcon),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 4),
            child: Text(
              CurrencyFormatterService.formatAmount(
                  expense.amount, planCurrency),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.greenAccent.shade200,
              ),
            ),
          ),
          if (expense.id != null && canManage)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: _cTextTertiary, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onSelected: (value) async {
                if (value == 'edit') {
                  if (!context.mounted) return;
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      fullscreenDialog: true,
                      builder: (ctx) => AddExpenseDialog(
                        plan: plan,
                        userIdToName: userIdToName,
                        existingExpense: expense,
                        onSaved: () =>
                            ref.invalidate(paymentSummaryProvider(plan.id!)),
                      ),
                    ),
                  );
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
                    ref.invalidate(paymentSummaryProvider(plan.id!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.paymentsExpenseDeleted),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.paymentsExpenseDeleteError)),
                    );
                  }
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text(loc.paymentsEditExpense),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text(loc.delete),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBalancesSection(
    BuildContext context,
    WidgetRef ref,
    PaymentSummary summary, {
    bool hideTitle = false,
  }) {
    final loc = AppLocalizations.of(context)!;
    final balances = summary.balancesByParticipant.values.toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));

    // Material (no DecoratedBox): ExpansionTile → ListTile ink assertion.
    return Material(
      color: _cSurfaceBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _cTextPrimary.withValues(alpha: _aBorderStrong),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14, hideTitle ? 10 : 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hideTitle) ...[
                  Text(
                    loc.paymentsBalancesSectionTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: _cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  loc.paymentsBalancesTricountHint,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    height: 1.35,
                    color: _cTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < balances.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: _cTextPrimary.withValues(alpha: _aBorderSubtle),
              ),
            _buildParticipantBalanceCard(context, ref, balances[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantBalanceCard(
    BuildContext context,
    WidgetRef ref,
    ParticipantBalance balance,
  ) {
    final loc = AppLocalizations.of(context)!;
    final planCurrency = plan.currency;
    final balanceColor = _getBalanceColor(balance.balance);
    final amountText =
        CurrencyFormatterService.formatAmount(balance.balance, planCurrency);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(12, 2, 8, 2),
        childrenPadding: EdgeInsets.zero,
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: _cTextPrimary.withValues(alpha: _aSurfaceChip),
        textColor: _cTextPrimary,
        collapsedTextColor: _cTextPrimary,
        iconColor: _cTextTertiary,
        collapsedIconColor: _cTextTertiary,
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: balanceColor.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getBalanceIcon(balance.balance),
            color: balanceColor,
            size: 18,
          ),
        ),
        title: Text(
          balance.userName,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _cTextPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _getBalanceStatusText(context, balance),
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: _cTextSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: balanceColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                amountText,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: balanceColor,
                ),
              ),
            ),
            const Icon(Icons.expand_more, color: _cTextTertiary, size: 20),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceDetailRow(
                  loc.paymentsBalanceAssignedCost,
                  CurrencyFormatterService.formatAmount(
                      balance.totalCost, planCurrency),
                ),
                const SizedBox(height: 6),
                _buildBalanceDetailRow(
                  loc.paymentsBalanceTotalPaid,
                  CurrencyFormatterService.formatAmount(
                      balance.totalPaid, planCurrency),
                ),
                const SizedBox(height: 6),
                Divider(
                    color: _cTextPrimary.withValues(alpha: _aBorderSubtle)),
                const SizedBox(height: 6),
                _buildBalanceDetailRow(
                  loc.paymentsGeneralSummaryBalanceTitle,
                  CurrencyFormatterService.formatAmount(
                      balance.balance, planCurrency),
                  isBold: true,
                  color: balanceColor,
                ),
                if (balance.payments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    loc.paymentsBalancePaymentsTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _cTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...balance.payments.map((payment) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 14, color: Colors.green.shade400),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${CurrencyFormatterService.formatAmount(payment.amount, planCurrency)} · ${payment.concept ?? payment.eventDescription ?? "Sin concepto"}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _cTextSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(payment.paymentDate),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _cTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTypography.bodyStyle.copyWith(
              color: _cTextSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyStyle.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? _cTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildTransferSuggestionsSection(
    BuildContext context,
    List<TransferSuggestion> suggestions, {
    bool hideTitle = false,
  }) {
    final planCurrency = plan.currency;
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(_sp12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hideTitle) ...[
            Row(
              children: [
                Icon(Icons.swap_horiz, color: AppColorScheme.color2),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.paymentsTransferSuggestionsTitle,
                    style: AppTypography.titleStyle.copyWith(
                      color: _cTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            loc.paymentsTransferSuggestionsSubtitle,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: _fsSectionSubtitle,
              color: _cTextTertiary,
            ),
          ),
          const SizedBox(height: _sp16),
          if (suggestions.isEmpty)
            Text(
              loc.paymentsSettlementExportNoTransfers,
              style: AppTypography.bodyStyle.copyWith(
                fontSize: _fsValue,
                color: _cTextSecondary,
              ),
            )
          else
            ...suggestions.map((suggestion) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _cTextPrimary.withValues(alpha: _aSurfaceMuted),
                  border: Border.all(
                    color: AppColorScheme.color2
                        .withValues(alpha: _aAccentSelected),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      suggestion.fromUserName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _cTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          size: 16,
                          color: AppColorScheme.color2,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatterService.formatAmount(
                            suggestion.amount,
                            planCurrency,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColorScheme.color2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      suggestion.toUserName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _cTextPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getBalanceColor(double balance) {
    if (balance > 0) {
      return Colors.green; // Acreedor
    } else if (balance < 0) {
      return _cDanger; // Deudor
    } else {
      return Colors.grey; // Equilibrado
    }
  }

  IconData _getBalanceIcon(double balance) {
    if (balance > 0) {
      return Icons.trending_up; // Acreedor
    } else if (balance < 0) {
      return Icons.trending_down; // Deudor
    } else {
      return Icons.check_circle; // Equilibrado
    }
  }

  String _getBalanceStatusText(BuildContext context, ParticipantBalance balance) {
    final planCurrency = plan.currency; // T153
    final loc = AppLocalizations.of(context)!;
    if (balance.isCreditor) {
      return loc.paymentsBalanceStatusCreditor(
        CurrencyFormatterService.formatAmount(balance.toReceiveAmount, planCurrency),
      );
    } else if (balance.isDebtor) {
      return loc.paymentsBalanceStatusDebtor(
        CurrencyFormatterService.formatAmount(balance.pendingAmount, planCurrency),
      );
    } else {
      return loc.paymentsBalanceStatusSettled;
    }
  }

  /// Organizador, quien pagó o quien registró el gasto pueden editar/eliminar.
  bool _canManagePlanExpense(Plan plan, PlanExpense expense, String? currentUserId) {
    if (currentUserId == null) return false;
    if (plan.userId == currentUserId) return true;
    if (expense.payerId == currentUserId) return true;
    if (expense.registeredBy != null && expense.registeredBy == currentUserId) return true;
    return false;
  }
}

