import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unp_calendario/app/theme/color_scheme.dart';
import 'package:unp_calendario/app/theme/typography.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/l10n/app_localizations.dart';
import 'package:unp_calendario/shared/utils/date_formatter.dart';

const double _kCellSpacing = 6;
const double _kMonthSpacing = 20;
const double _kTitleHeight = 30;
const double _kTitleBottomSpacing = 10;
const double _kWeekHeaderHeight = 22;
const double _kWeekHeaderBottomSpacing = 6;

double _gridHeightForMonth(DateTime month, double cellSize) {
  final firstDayOfMonth = DateTime(month.year, month.month, 1);
  final leadingDays = (firstDayOfMonth.weekday + 6) % 7;
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final totalCells = leadingDays + daysInMonth;
  final totalWeeks = (totalCells / 7).ceil();
  if (totalWeeks <= 0) return cellSize;
  return totalWeeks * cellSize + (totalWeeks - 1) * _kCellSpacing;
}

double _monthTotalHeight(DateTime month, double cellSize) {
  final gridHeight = _gridHeightForMonth(month, cellSize);
  return _kTitleHeight +
      _kTitleBottomSpacing +
      _kWeekHeaderHeight +
      _kWeekHeaderBottomSpacing +
      gridHeight;
}

class PlanCalendarView extends StatefulWidget {
  final List<Plan> plans;
  final bool isLoading;
  final ValueChanged<Plan>? onPlanSelected;
  final DateTime? baseDate;

  const PlanCalendarView({
    super.key,
    required this.plans,
    this.isLoading = false,
    this.onPlanSelected,
    this.baseDate,
  });

  @override
  State<PlanCalendarView> createState() => _PlanCalendarViewState();
}

class _PlanCalendarViewState extends State<PlanCalendarView> {
  static const int _monthsBefore = 5;
  static const int _monthsAfter = 6;

  late final List<DateTime> _months;
  late List<double> _monthHeights;
  late final ScrollController _scrollController;
  bool _didJumpToInitial = false;

  @override
  void initState() {
    super.initState();
    final now = widget.baseDate ?? DateTime.now();
    _months = List.generate(
      _monthsBefore + _monthsAfter + 1,
      (index) => DateTime(now.year, now.month - _monthsBefore + index),
    );
    _monthHeights = List.filled(_months.length, 0);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final loc = AppLocalizations.of(context)!;
    final planDays = _buildPlanDayMap(widget.plans);

    if (widget.plans.isEmpty) {
      return Center(
        child: Text(
          loc.planCalendarEmpty,
          style: AppTypography.bodyStyle.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final cellSize =
              (availableWidth - _kCellSpacing * (7 - 1)) / 7;

          _monthHeights = _months
              .map((month) => _monthTotalHeight(month, cellSize))
              .toList();

          if (!_didJumpToInitial) {
            final initialOffset = _monthHeights
                .take(_monthsBefore)
                .fold<double>(0, (sum, height) => sum + height + _kMonthSpacing);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(initialOffset);
              }
            });
            _didJumpToInitial = true;
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: _months.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final month = _months[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _months.length - 1 ? 0 : _kMonthSpacing,
                ),
                child: _MonthCalendar(
                  month: month,
                  planDays: planDays,
                  cellSize: cellSize,
                  onPlanSelected: widget.onPlanSelected,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<DateTime, List<Plan>> _buildPlanDayMap(List<Plan> plans) {
    final Map<DateTime, List<Plan>> result = {};
    for (final plan in plans) {
      final start = DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day);
      final end = DateTime(plan.endDate.year, plan.endDate.month, plan.endDate.day);
      var current = start;
      while (!current.isAfter(end)) {
        final key = DateTime(current.year, current.month, current.day);
        result.putIfAbsent(key, () => []).add(plan);
        current = current.add(const Duration(days: 1));
      }
    }
    return result;
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, List<Plan>> planDays;
  final double cellSize;
  final ValueChanged<Plan>? onPlanSelected;

  const _MonthCalendar({
    required this.month,
    required this.planDays,
    required this.cellSize,
    this.onPlanSelected,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final monthLabel = DateFormat('MMMM yyyy', loc.localeName).format(month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final leadingDays = (firstDayOfMonth.weekday + 6) % 7; // Lunes = 0
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final totalCells = leadingDays + daysInMonth;
    final gridHeight = _gridHeightForMonth(month, cellSize);
    final monthHeight = _monthTotalHeight(month, cellSize);

    return SizedBox(
      height: monthHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _kTitleHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                toBeginningOfSentenceCase(monthLabel) ?? monthLabel,
                style: AppTypography.mediumTitle.copyWith(
                  color: AppColorScheme.color2,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: _kTitleBottomSpacing),
          SizedBox(
            height: _kWeekHeaderHeight,
            child: const _WeekdayHeader(),
          ),
          const SizedBox(height: _kWeekHeaderBottomSpacing),
          SizedBox(
            height: gridHeight,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: _kCellSpacing,
                mainAxisSpacing: _kCellSpacing,
                childAspectRatio: 1,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                if (index < leadingDays) {
                  return const SizedBox.shrink();
                }
                final dayNumber = index - leadingDays + 1;
                final date = DateTime(month.year, month.month, dayNumber);
                final plansForDay = planDays[date] ?? const <Plan>[];
                final hasPlans = plansForDay.isNotEmpty;

                return _DayCell(
                  date: date,
                  dayNumber: dayNumber,
                  hasPlans: hasPlans,
                  plans: plansForDay,
                  onPlanSelected: onPlanSelected,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final weekdayNames = DateFormat.E(loc.localeName)
        .dateSymbols
        .STANDALONESHORTWEEKDAYS
        .toList();

    // Reordenar para que empiece en lunes
    final orderedWeekdays = [
      weekdayNames[1],
      weekdayNames[2],
      weekdayNames[3],
      weekdayNames[4],
      weekdayNames[5],
      weekdayNames[6],
      weekdayNames[0],
    ];

    return Row(
      children: orderedWeekdays
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final int dayNumber;
  final bool hasPlans;
  final List<Plan> plans;
  final ValueChanged<Plan>? onPlanSelected;

  const _DayCell({
    required this.date,
    required this.dayNumber,
    required this.hasPlans,
    required this.plans,
    this.onPlanSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tooltipMessage = hasPlans
        ? plans
            .map((plan) => plan.name.trim())
            .where((name) => name.isNotEmpty)
            .join('\n')
        : '';

    Widget cell = GestureDetector(
      onTap: hasPlans ? () => _handleTap(context) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasPlans ? AppColorScheme.color2.withOpacity(0.75) : Colors.grey.shade300,
            width: 0.8,
          ),
          color: hasPlans ? AppColorScheme.color2.withOpacity(0.08) : Colors.white,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 5,
              top: 4,
              child: Text(
                '$dayNumber',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasPlans ? AppColorScheme.color2 : Colors.grey.shade700,
                ),
              ),
            ),
            if (hasPlans)
              Positioned(
                left: 4,
                bottom: 3,
                child: _PlanCountBadge(count: plans.length),
              ),
          ],
        ),
      ),
    );

    if (hasPlans && tooltipMessage.isNotEmpty) {
      cell = Tooltip(
        message: tooltipMessage,
        waitDuration: const Duration(milliseconds: 250),
        child: cell,
      );
    }

    return cell;
  }

  Future<void> _handleTap(BuildContext context) async {
    if (plans.length == 1) {
      onPlanSelected?.call(plans.first);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.formatDate(date),
                  style: AppTypography.mediumTitle.copyWith(
                    color: AppColorScheme.color2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...plans.map(
                  (plan) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(plan.name),
                    subtitle: Text(
                      '${DateFormatter.formatDate(plan.startDate)} – ${DateFormatter.formatDate(plan.endDate)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).pop();
                      onPlanSelected?.call(plan);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanCountBadge extends StatelessWidget {
  final int count;

  const _PlanCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColorScheme.color2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

