import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/pages/pg_calendar_page.dart';

class CalendarScreen extends StatelessWidget {
  final Plan plan;

  const CalendarScreen({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    // Usar CalendarPage completo con Key única para forzar recreación
    // cuando cambie el plan seleccionado
    return CalendarPage(
      key: ValueKey(plan.id), // Key única por plan
      plan: plan,
    );
  }
}
