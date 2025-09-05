import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';

class PlanCardWidget extends StatelessWidget {
  final Plan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlanCardWidget({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? Colors.red.shade100 : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade300,
          child: Text(
            plan.name[0],
            style: TextStyle(color: Colors.red.shade800),
          ),
        ),
        title: Text(
          plan.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID del plan eliminado
            Text(
              'UNP ID: ${plan.unpId}',
              style: TextStyle(
                fontSize: 10, // Reducido de tamaño por defecto
                color: Colors.grey.shade600,
              ),
            ),
            if (plan.description != null && plan.description!.isNotEmpty)
              Text(
                plan.description!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              '${plan.startDate.day}/${plan.startDate.month}/${plan.startDate.year} - ${plan.endDate.day}/${plan.endDate.month}/${plan.endDate.year}',
              style: TextStyle(
                fontSize: 14, // Aumentado de 9 a 14
                fontWeight: FontWeight.w500, // Añadido peso de fuente
                color: Colors.grey.shade700, // Color más oscuro para mejor legibilidad
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue.shade600),
              onPressed: onTap,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade600),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
