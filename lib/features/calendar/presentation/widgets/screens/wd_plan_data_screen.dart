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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 32,
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Datos del Planazoo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          
          // Datos del plan
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nombre:', plan.name),
                  if (plan.description != null && plan.description!.isNotEmpty)
                    _buildInfoRow('Descripción:', plan.description!),
                  _buildInfoRow('UNP ID:', plan.unpId),
                  _buildInfoRow('Fecha inicio:', '${plan.startDate.day}/${plan.startDate.month}/${plan.startDate.year}'),
                  _buildInfoRow('Fecha fin:', '${plan.endDate.day}/${plan.endDate.month}/${plan.endDate.year}'),
                  _buildInfoRow('Duración:', '${plan.endDate.difference(plan.startDate).inDays + 1} días'),
                  if (plan.budget != null)
                    _buildInfoRow('Presupuesto:', '€${plan.budget!.toStringAsFixed(2)}'),
                  if (plan.participants != null)
                    _buildInfoRow('Participantes:', plan.participants.toString()),
                  _buildInfoRow('Fecha creación:', '${plan.createdAt.day}/${plan.createdAt.month}/${plan.createdAt.year}'),
                  _buildInfoRow('Última actualización:', '${plan.updatedAt.day}/${plan.updatedAt.month}/${plan.updatedAt.year}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
