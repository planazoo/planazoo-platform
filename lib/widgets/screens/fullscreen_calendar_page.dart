import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/widgets/screens/wd_calendar_screen.dart';

class FullScreenCalendarPage extends StatelessWidget {
  final Plan plan;
  final int? visibleDays;

  const FullScreenCalendarPage({
    super.key,
    required this.plan,
    this.visibleDays,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarScreen(
      plan: plan,
      initialVisibleDays: visibleDays,
    );
  }
}
