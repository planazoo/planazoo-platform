import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/widgets/plan/wd_plan_card_widget.dart';

class PlanListWidget extends StatelessWidget {
  final List<Plan> plans;
  final String? selectedPlanId;
  final bool isLoading;
  final Function(String) onPlanSelected;
  final Function(String) onPlanDeleted;
  /// Al clic en icono notificaciones: abrir notificaciones del plan.
  final void Function(Plan plan)? onNotificationsTap;
  /// Al clic en icono chat: abrir chat del plan.
  final void Function(Plan plan)? onChatTap;

  const PlanListWidget({
    super.key,
    required this.plans,
    required this.selectedPlanId,
    required this.isLoading,
    required this.onPlanSelected,
    required this.onPlanDeleted,
    this.onNotificationsTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay planes, W28 debe quedar en blanco (sin spinner ni mensajes)
    if (plans.isEmpty) {
      return Container();
    }

    // Si hay planes pero estamos en carga, mostrar spinner
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      // Alineado con W13 (Buscar planes): mismo inset horizontal.
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final isSelected = selectedPlanId == plan.id;
        
        return PlanCardWidget(
          plan: plan,
          isSelected: isSelected,
          onTap: () => onPlanSelected(plan.id!),
          onDelete: () => onPlanDeleted(plan.id!),
          onNotificationsTap: onNotificationsTap,
          onChatTap: onChatTap,
        );
      },
    );
  }
}
