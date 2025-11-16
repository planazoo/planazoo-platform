import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_card_widget.dart';

class PlanListWidget extends ConsumerWidget {
  final List<Plan> plans;
  final String? selectedPlanId;
  final bool isLoading;
  final Function(Plan)? onPlanTap;

  const PlanListWidget({
    super.key,
    required this.plans,
    this.selectedPlanId,
    this.isLoading = false,
    this.onPlanTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (plans.isEmpty) {
      return const Center(child: Text('No plans found'));
    }

    return ListView.builder(
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return PlanCardWidget(
          plan: plan,
          isSelected: plan.id == selectedPlanId,
          onTap: () => onPlanTap?.call(plan),
        );
      },
    );
  }
}
