import 'package:flutter/material.dart';
import 'package:unp_calendario/features/calendar/domain/models/plan.dart';
import 'package:unp_calendario/shared/utils/plan_range_utils.dart';
import 'package:intl/intl.dart';

/// T107: Diálogo para confirmar la expansión del plan cuando un evento se extiende fuera del rango
class ExpandPlanDialog extends StatelessWidget {
  final Plan plan;
  final Map<String, dynamic> expansionInfo;

  const ExpandPlanDialog({
    super.key,
    required this.plan,
    required this.expansionInfo,
  });

  @override
  Widget build(BuildContext context) {
    final extendsBefore = expansionInfo['extendsBefore'] as bool;
    final extendsAfter = expansionInfo['extendsAfter'] as bool;
    final daysToExpandBefore = expansionInfo['daysToExpandBefore'] as int;
    final daysToExpandAfter = expansionInfo['daysToExpandAfter'] as int;
    final newStartDate = expansionInfo['newStartDate'] as DateTime;
    final newEndDate = expansionInfo['newEndDate'] as DateTime;
    
    final newPlanValues = PlanRangeUtils.calculateExpandedPlanValues(plan, expansionInfo);
    final newColumnCount = newPlanValues['columnCount'] as int;
    
    final dateFormat = DateFormat('dd/MM/yyyy');

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.expand_more, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(child: Text('Expandir Plan')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Este evento se extiende fuera del rango actual del plan.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Rango actual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rango actual:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(plan.startDate)} - ${dateFormat.format(plan.endDate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Duración: ${plan.columnCount} días',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Información de expansión
            if (extendsBefore || extendsAfter) ...[
              Text(
                'El plan se expandirá para incluir:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              if (extendsBefore)
                _buildExpansionItem(
                  'Antes',
                  '$daysToExpandBefore día${daysToExpandBefore != 1 ? 's' : ''}',
                  Icons.arrow_back,
                ),
              if (extendsAfter)
                _buildExpansionItem(
                  'Después',
                  '$daysToExpandAfter día${daysToExpandAfter != 1 ? 's' : ''}',
                  Icons.arrow_forward,
                ),
            ],
            
            const SizedBox(height: 16),
            
            // Nuevo rango
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nuevo rango:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(newStartDate)} - ${dateFormat.format(newEndDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade900,
                    ),
                  ),
                  Text(
                    'Nueva duración: $newColumnCount días',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Advertencia
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Todos los participantes serán notificados del cambio de duración del plan.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Expandir Plan'),
        ),
      ],
    );
  }

  Widget _buildExpansionItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

