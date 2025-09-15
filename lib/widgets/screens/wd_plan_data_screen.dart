import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';

class PlanDataScreen extends StatelessWidget {
  final Plan plan;

  const PlanDataScreen({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.name ?? 'Plan Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Name: ${plan.name ?? 'N/A'}'),
            Text('Description: ${plan.description ?? 'N/A'}'),
            Text('ID: ${plan.id}'),
          ],
        ),
      ),
    );
  }
}