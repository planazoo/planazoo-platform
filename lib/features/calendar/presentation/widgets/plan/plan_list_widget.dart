import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/features/calendar/presentation/widgets/plan/wd_plan_card_widget.dart';

class PlanListWidget extends StatelessWidget {
  final List<Plan> plans;
  final String? selectedPlanId;
  final bool isLoading;
  final Function(String) onPlanSelected;
  final Function(String) onPlanDeleted;

  const PlanListWidget({
    super.key,
    required this.plans,
    required this.selectedPlanId,
    required this.isLoading,
    required this.onPlanSelected,
    required this.onPlanDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final isSelected = selectedPlanId == plan.id;
        
        return PlanCardWidget(
          plan: plan,
          isSelected: isSelected,
          onTap: () => onPlanSelected(plan.id!),
          onDelete: () => onPlanDeleted(plan.id!),
        );
      },
    );
  }
}
